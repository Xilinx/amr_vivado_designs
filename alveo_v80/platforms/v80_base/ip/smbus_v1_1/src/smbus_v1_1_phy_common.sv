// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Target/Controller Common PHY Logic
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)

// xlpp eval_constant %CORE_LICENSE_KEY% begin
  localparam c_is_eval = 0;
// xlpp eval_constant end

module smbus_v1_1_phy_common
  import smbus_v1_1_pkg::*;
#(
  parameter int C_SMBUS_DEV_CLASS = 0,
  parameter int C_FREQ_HZ_CLK     = 100000000
) (
  // Register Control Interface
  smbus_v1_1_reg_if.sub       reg_phy_cmn_if,

  // Clock & Reset
  input  logic                clk,
  input  logic                resetn,

  // Interrupts
  output phy_cmn_irq_t        phy_cmn_irq,

  // Control/Status
  input  phy_cmn_ctl_t        tgt_phy_ctl,
  input  phy_cmn_ctl_t        ctlr_phy_ctl,
  output phy_cmn_stat_t       phy_cmn_stat,

  // SMBus Ports
  input  logic                smbclk_i,
  output logic                smbclk_o,
  output logic                smbclk_t,
  input  logic                smbdat_i,
  output logic                smbdat_o,
  output logic                smbdat_t
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------
localparam int        C_CDC_SYNC_STAGES             = 3;
localparam int        C_ADDR_WIDTH                  = $bits(reg_phy_cmn_if.reg_wr_addr);
localparam bit [11:0] C_SMBCLK_FORCE_LOW            = 12'hCFB;

// Enable the glitch filter by default
localparam bit        C_DEFAULT_FILT_EN             = 1'b1;

// CDC + Transition detection, excludes glitch filter
localparam int        C_INPUT_LATENCY               = C_CDC_SYNC_STAGES + 2;

// Sized for max 500MHz clock, allows for tSPIKE of 64ns
localparam int        C_FILT_CT_WIDTH               = 6;
localparam int        C_DLY_COMP_CT_WIDTH           = C_FILT_CT_WIDTH + 1;

// Sized for max 500MHz clock, allows for tBUF of 8.1us
localparam int        C_BUS_FREE_CT_WIDTH           = 13;

// Sized for max 500MHz clock, allows for tHIGH:MAX of 65.5us
localparam int        C_BUS_INACTIVE_CT_WIDTH       = 16;

// Sized for 500MHz clock, allows for 16.3us prescaler tick
localparam int        C_TO_PRESCALE_CT_WIDTH        = 14;

// Sized for 10us prescaler
localparam int        C_TIMEOUT_CT_WIDTH            = 13;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

function automatic logic [63:0] dcc (   // disable counter calculator
  input logic [31:0] mh,
  input logic [31:0] sc
);
  longint unsigned dy;
  int unsigned z, l  = 0;
  logic [63:0] ud    = 64'b0;
  logic [63:0] gi    = 64'b0;

  begin
    dy = (sc * (mh/10000)) / 384;
    while (dy > 2**30) begin
      l = l + 1;
      dy = dy / 2;
    end

    z = dy;

    if (l + 29 < 64) begin
      ud[l +: 30] = z;
    end

    ud = ~ud + 1;
    gi = ud ^ {1'b0, ud [63:1]};
    return gi;
  end
endfunction : dcc

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic                                 smbclk_in_sync;
logic                                 smbdat_in_sync;
logic                                 filt_en;
logic [C_FILT_CT_WIDTH-2:0]           filt_count;
logic                                 smbclk_in_filt;
logic                                 smbclk_filt;
logic [C_FILT_CT_WIDTH-2:0]           smbclk_filt_ct;
logic [C_FILT_CT_WIDTH-1:0]           smbclk_filt_ct_nxt;
logic                                 smbclk_stable;
logic                                 smbdat_in_filt;
logic                                 smbdat_filt;
logic [C_FILT_CT_WIDTH-2:0]           smbdat_filt_ct;
logic [C_FILT_CT_WIDTH-1:0]           smbdat_filt_ct_nxt;
logic                                 smbclk_filt_d1;
logic                                 smbclk_re;
logic                                 smbclk_fe;
logic                                 smbdat_filt_d1;
logic                                 smbdat_latched;
logic                                 start_in;
logic                                 stop_in;
logic                                 bus_active;

logic [C_BUS_FREE_CT_WIDTH-2:0]       bus_free_time;
logic [C_BUS_FREE_CT_WIDTH-2:0]       bus_free_ct;
logic [C_BUS_FREE_CT_WIDTH-1:0]       bus_free_ct_nxt;
logic                                 bus_free;
logic                                 stop_det;
logic [C_BUS_INACTIVE_CT_WIDTH-2:0]   bus_idle_thresh;
logic [C_BUS_INACTIVE_CT_WIDTH-2:0]   bus_inactive_ct;
logic [C_BUS_INACTIVE_CT_WIDTH-1:0]   bus_inactive_ct_nxt;
logic                                 bus_inactive;
logic                                 bus_idle;
logic                                 phy_inactive;
logic                                 unexpected_bus_idle;

logic [C_TO_PRESCALE_CT_WIDTH-2:0]    timeout_prescaler;
logic [C_TO_PRESCALE_CT_WIDTH-2:0]    timeout_prescaler_ct;
logic [C_TO_PRESCALE_CT_WIDTH-1:0]    timeout_prescaler_ct_nxt;
logic                                 to_prescaler_tick;
logic [C_TIMEOUT_CT_WIDTH-2:0]        timeout_min;
logic [C_TIMEOUT_CT_WIDTH-2:0]        smbclk_low_ct;
logic [C_TIMEOUT_CT_WIDTH-1:0]        smbclk_low_ct_nxt;
logic                                 smbclk_low_timeout;
logic                                 smbclk_timeout_en;
logic                                 smbclk_force_timeout;
logic [11:0]                          smbclk_force_low;
logic [C_TIMEOUT_CT_WIDTH-2:0]        timeout_max;
logic [C_TIMEOUT_CT_WIDTH-2:0]        smbdat_low_ct;
logic [C_TIMEOUT_CT_WIDTH-1:0]        smbdat_low_ct_nxt;
logic                                 smbdat_low_timeout;

logic [C_DLY_COMP_CT_WIDTH-1:0]       dly_comp_ct_nxt;
logic [C_DLY_COMP_CT_WIDTH-2:0]       dly_comp_ct;
logic [C_DLY_COMP_CT_WIDTH-2:0]       dly_comp;
logic                                 ctlr_comp;

(* use_sync_set = "no", use_sync_reset = "no", use_clock_enable = "no" *)
logic                                 disc        = 0;

// ========================================================

// Instantiate license timeout counter

generate
  if (c_is_eval) begin
    (* use_sync_set = "no", use_sync_reset = "no", use_clock_enable = "no" *)
    logic                                 m       = 0;
    (* use_sync_set = "no", use_sync_reset = "no", use_clock_enable = "no" *)
    logic                                 w       = 0;
    (* use_sync_set = "no", use_sync_reset = "no", use_clock_enable = "no" *)
    logic                                 v       = 0;
    (* use_sync_set = "no", use_sync_reset = "no", use_clock_enable = "no" *)
    logic                                 f       = 0;
    logic                                 y       = 0;
    logic                                 j       = 0;
    logic                                 cy      = 0;
    logic                                 r       = 0;
    logic                                 x       = 1;
    logic                                 d       = 0;
    logic [5:0]                           i       = 0;
    logic [7:0]                           next_ji;
    logic                                 gcs_do;

    RAM64X1S #(.INIT(dcc(C_FREQ_HZ_CLK, 144000000)))  // 1 = 100us => 10 = 1ms => 10000 = 1sec  => 1hr = 36000000 => 4hr = 10000*60*60*4 = 144000000
    gcsram (
      .O(gcs_do),
      .A0(i[0]), .A1(i[1]), .A2(i[2]), .A3(i[3]), .A4(i[4]), .A5(i[5]),
      .D(v),
      .WCLK(clk),
      .WE(f)
    );

    // Next counter state
    assign next_ji = { 1'b0 , j , i } + 1;

    always @(posedge clk) begin
      // Ring counter for read/modify/write cycle (hardened against reset-skew)
      m <= !m & !w;
      w <=  m & !w;
      // Read data register for RAM output
      d <= gcs_do;
      // Invert data for writeback
      v <= !d;
      // RAM write enable
      f <= m & j & x & !y;

      if (cy) begin
        // Counter overflow event resets most things.
        x  <= 1;
        y  <= 0;
        cy <= 0;
        j  <= 0;
        i  <= 0;
      end
      else if (w) begin
        // Increment counter
        i  <= next_ji[5:0];
        j  <= next_ji[6];
        cy <= next_ji[7];
        // Latch up y when we see a 1 on x during the update phase
        y  <= y | (x & j);
        // Update x according to phase...
        x  <= d ^ (x & !j);  // Update: copy d into x; parity calc: XOR d into x
      end

      disc <= disc | (cy & !y);  // timeout happens if the counter overflows and y was 0
    end
  end
endgenerate

// Synchronize the smbclk input onto the clk domain

xpm_cdc_single #(
  .DEST_SYNC_FF(C_CDC_SYNC_STAGES),
  .INIT_SYNC_FF(0),
  .SIM_ASSERT_CHK(1),
  .SRC_INPUT_REG(0)
) smbclk_cdc (
  .dest_out(smbclk_in_sync),
  .dest_clk(clk),
  .src_clk(),
  .src_in(smbclk_i)
);

// Synchronize the smbdat input onto the clk domain

xpm_cdc_single #(
  .DEST_SYNC_FF(C_CDC_SYNC_STAGES),
  .INIT_SYNC_FF(0),
  .SIM_ASSERT_CHK(1),
  .SRC_INPUT_REG(0)
) smbdat_cdc (
  .dest_out(smbdat_in_sync),
  .dest_clk(clk),
  .src_clk(),
  .src_in(smbdat_i)
);

// ========================================================

// Filter the inputs to prevent glitches propagating
// Wait for signal to be steady state for filt_count+1 clk cycles before propagating
// A glitch on smbclk will stall smbdat to prevent incorrect START/STOP conditions being detected

// Filter the smbclk input
always_ff @(posedge clk) begin
  if (!resetn) begin
    smbclk_in_filt  <= '1;
    smbclk_stable   <= '1;
    smbclk_filt_ct  <= filt_count;
  end else if (smbclk_in_sync == smbclk_in_filt) begin
    // While the filter input and output match, do nothing except reset the count
    smbclk_stable   <= '1;
    smbclk_filt_ct  <= filt_count;
  end else begin
    if (!smbclk_filt_ct_nxt[5]) begin
      // On input/output mismatch, wait and decrement the count
      smbclk_filt_ct  <= smbclk_filt_ct_nxt[4:0];
      smbclk_stable   <= '0;
    end else begin
      // When the counter underflows then propagate the stable input to filter output
      smbclk_in_filt  <= smbclk_in_sync;
      smbclk_filt_ct  <= filt_count;
      smbclk_stable   <= '1;
    end
  end
end

// Calculate the next count value
assign smbclk_filt_ct_nxt = smbclk_filt_ct - 1'b1;

// Filter the smbdat input
always_ff @(posedge clk) begin
  if (!resetn) begin
    smbdat_in_filt  <= '1;
    smbdat_filt_ct  <= filt_count;
  end else if (smbdat_in_sync == smbdat_in_filt) begin
    // While the filter input and output match, do nothing except reset the count
    smbdat_filt_ct  <= filt_count;
  end else begin
    if (!smbdat_filt_ct_nxt[5]) begin
      // On input/output mismatch, wait and decrement the count
      smbdat_filt_ct  <= smbdat_filt_ct_nxt[4:0];
    end else begin
      // When the counter underflows then propagate the stable input to filter output
      if (smbclk_stable) begin
        // Wait until smbclk is stable before propagating a change to smbdat
        smbdat_in_filt  <= smbdat_in_sync;
        smbdat_filt_ct  <= filt_count;
      end
    end
  end
end

// Calculate the next count value
assign smbdat_filt_ct_nxt = smbdat_filt_ct - 1'b1;

// Mux between the filtered and unfiltered smbclk/smbdat
assign smbclk_filt = filt_en ? smbclk_in_filt : smbclk_in_sync;
assign smbdat_filt = filt_en ? smbdat_in_filt : smbdat_in_sync;

// ========================================================

// Detect the transitions on the smbclk/smbdat inputs

always_ff @(posedge clk) begin
  if (!resetn) begin
    smbclk_filt_d1  <= '1;
    smbdat_filt_d1  <= '1;
    smbclk_re       <= '0;
    smbclk_fe       <= '0;
    smbdat_latched  <= '0;
    start_in        <= '0;
    stop_in         <= '0;
  end else begin
    // Defaults
    smbclk_filt_d1  <= smbclk_filt;
    smbdat_filt_d1  <= smbdat_filt;
    smbclk_re       <= '0;
    smbclk_fe       <= '0;
    start_in        <= '0;
    stop_in         <= '0;

    // Detect the smbclk rising edge, sample smbdat
    if (smbclk_filt && !smbclk_filt_d1) begin
      smbclk_re       <= '1;
      smbdat_latched  <= smbdat_filt;
    end

    // Detect smbclk falling edge
    if (!smbclk_filt && smbclk_filt_d1) begin
      smbclk_fe       <= '1;
    end

    // Detect the START condition
    if (!smbdat_filt && smbdat_filt_d1) begin
      start_in        <= smbclk_filt;
    end

    // Detect the STOP condition
    if (smbdat_filt && !smbdat_filt_d1) begin
      stop_in         <= smbclk_filt;
    end
  end
end

// ========================================================
// Detect the Bus Idle condition, this is defined as:
//  1. Bus Free - i.e. bus inactive for tBUF time since last STOP condition
//  OR
//  2. Bus Inactive (smbclk/smbdat high) for > tHIGH:Max

// Detect the Bus Free condition
// tBUF time has elapsed without bus activity since last STOP condition
always_ff @(posedge clk) begin
  if (!resetn) begin
    bus_free      <= '0;
    stop_det      <= '0;
    bus_free_ct   <= bus_free_time;
  end else begin
    if (smbdat_filt && !smbdat_filt_d1 && smbclk_filt) begin
      // STOP condition detected, reset the count
      bus_free_ct <= bus_free_time;
      bus_free    <= '0;
      stop_det    <= '1;
    end else if (!stop_det) begin
      // STOP not yet detected, bus is considered busy
      bus_free_ct <= bus_free_time;
      bus_free    <= '0;
    end else if ((!smbclk_filt || !smbdat_filt) && stop_det) begin
      // Activity on bus following a STOP, clear bus free
      bus_free_ct <= bus_free_time;
      bus_free    <= '0;
      stop_det    <= '0;
    end else begin
      if (bus_free_ct_nxt[C_BUS_FREE_CT_WIDTH-1]) begin
        // Count has underflowed, tBUF has been reached without activity so declare bus free
        bus_free  <= '1;
      end else begin
        // tBUF not yet reached, decrement the count
        bus_free_ct <= bus_free_ct_nxt[C_BUS_FREE_CT_WIDTH-2:0];
      end
    end
  end
end

// Detect when the bus is inactive - no transitions for > tHIGH:Max
// Required when bus state not yet understood i.e. post reset
always_ff @(posedge clk) begin
  if (!resetn) begin
    bus_inactive    <= '0;
    bus_inactive_ct <= bus_idle_thresh;
  end else begin
    if (!smbclk_filt || !smbdat_filt) begin
      // Activity on the bus, reset the count
      bus_inactive    <= '0;
      bus_inactive_ct <= bus_idle_thresh;
    end else begin
      if (bus_inactive_ct_nxt[C_BUS_INACTIVE_CT_WIDTH-1]) begin
        // Count has underflowed, > tHIGH:Max time has elapsed without activitiy
        // so declare bus inactive
        bus_inactive    <= '1;
      end else begin
        // > tHIGH:Max time not yet reached, decrement the count
        bus_inactive_ct <= bus_inactive_ct_nxt[C_BUS_INACTIVE_CT_WIDTH-2:0];
      end
    end
  end
end

// Assign the next count
assign bus_inactive_ct_nxt  = bus_inactive_ct - 1'b1;
assign bus_free_ct_nxt      = bus_free_ct - 1'b1;

// Bus Idle
always_ff @(posedge clk) begin
  bus_idle <= bus_free | bus_inactive;
end

// PHY Inactive
// Signal to the PHY when either a STOP condition, bus idle or smbclk timeout occurs
always_ff @(posedge clk) begin
  phy_inactive  <= (smbdat_filt && !smbdat_filt_d1 && smbclk_filt) | bus_free | bus_inactive |
      smbclk_low_timeout;
end

// Unexpected Bus Idle - Bus goes in-active before a STOP received i.e. Controller stops mid-packet
always_ff @(posedge clk) begin
  if (!resetn) begin
    bus_active          <= '0;
    unexpected_bus_idle <= '0;
  end else begin
    // Defaults
    unexpected_bus_idle <= '0;

    // Detect when the bus is active i.e. a transaction is in-progress
    if (start_in) begin
      bus_active <= '1;
    end else if (stop_in || bus_inactive) begin
      bus_active <= '0;
    end

    // When a transaction is in-progress and the bus becomes inactive, flag unexpected bus idle
    if (bus_active && bus_inactive) begin
      unexpected_bus_idle <= '1;
    end
  end
end

// ========================================================
// SMBCLK and SMBDAT low timeout detection - tTIMEOUT min and max

// Timeout Prescaler
always_ff @(posedge clk) begin
  if (!resetn) begin
    timeout_prescaler_ct  <= timeout_prescaler;
    to_prescaler_tick     <= '0;
  end else begin
    if (timeout_prescaler_ct_nxt[C_TO_PRESCALE_CT_WIDTH-1]) begin
      // On underflow reset the count, flag the enable
      timeout_prescaler_ct  <= timeout_prescaler;
      to_prescaler_tick     <= '1;
    end else begin
      // Decrement the count
      timeout_prescaler_ct  <= timeout_prescaler_ct_nxt[C_TO_PRESCALE_CT_WIDTH-2:0];
      to_prescaler_tick     <= '0;
    end
  end
end

// Assign the next count
assign timeout_prescaler_ct_nxt = timeout_prescaler_ct - 1'b1;

// SMBCLK low timeout detection - flag when smbclk is persistently low for tTIMEOUT:Min
always_ff @(posedge clk) begin
  if (!resetn) begin
    smbclk_low_timeout  <= '0;
    smbclk_low_ct       <= timeout_min;
  end else begin
    if (smbclk_force_timeout) begin
      // Flag a timeout when the force bit from the register interface is set
      smbclk_low_timeout  <= '1;
    end else if (smbclk_filt_d1) begin
      // When smbclk is high then reset the count
      smbclk_low_timeout  <= '0;
      smbclk_low_ct       <= timeout_min;
    end else begin
      if (smbclk_low_ct_nxt[C_TIMEOUT_CT_WIDTH-1]) begin
        // On count underflow flag the timeout if enabled
        smbclk_low_timeout  <= smbclk_timeout_en;
      end else if (to_prescaler_tick) begin
        // Decrement the count on the next prescaler tick
        smbclk_low_ct       <= smbclk_low_ct_nxt[C_TIMEOUT_CT_WIDTH-2:0];
      end
    end
  end
end

// Assign the next count
assign smbclk_low_ct_nxt = smbclk_low_ct - 1'b1;

// SMBDAT low timeout detection
// flag when smbdat is persistently low for tTIMEOUT:Max after smbclk goes high
always_ff @(posedge clk) begin
  if (!resetn) begin
    smbdat_low_timeout  <= '0;
    smbdat_low_ct       <= timeout_max;
  end else begin
    if (!smbclk_filt_d1 || smbdat_filt_d1) begin
      // When smbclk is low or smbdat high then reset the count
      smbdat_low_timeout  <= '0;
      smbdat_low_ct       <= timeout_max;
    end else begin
      if (smbdat_low_ct_nxt[C_TIMEOUT_CT_WIDTH-1]) begin
        // On count underflow flag the timeout
        smbdat_low_timeout  <= '1;
      end else if (to_prescaler_tick) begin
        // Decrement the count on the next prescaler tick
        smbdat_low_ct       <= smbdat_low_ct_nxt[C_TIMEOUT_CT_WIDTH-2:0];
      end
    end
  end
end

// Assign the next count
assign smbdat_low_ct_nxt = smbdat_low_ct - 1'b1;

// ========================================================
// Input delay compensation signal generation
// Create a signal to assist the Controller in measuring tLOW:TEXT by filtering out the
// input latency i.e. CDC -> Glitch Filter -> Transition Detection -> Controller PHY input
// This will enable the Controller to determine when smbclk is being stretched externally
// and make the measurement more accurate

always_ff @(posedge clk) begin
  if (!resetn) begin
    dly_comp    <= '0;
    dly_comp_ct <= '0;
    ctlr_comp   <= '0;
  end else begin
    // Configure the compensation count based upon the glitch filter configuration
    if (filt_en) begin
      dly_comp  <= filt_count + C_INPUT_LATENCY;
    end else begin
      dly_comp  <= C_INPUT_LATENCY;
    end

    // Defaults
    ctlr_comp <= '0;

    // Update the compensation counter and flag
    if (!ctlr_phy_ctl.smbclk_ctl) begin
      // Controller is driving smbclk, reset the count
      dly_comp_ct <= dly_comp;
    end else if (dly_comp_ct_nxt[C_DLY_COMP_CT_WIDTH-1]) begin
      ctlr_comp   <= '1;
    end else begin
      dly_comp_ct <= dly_comp_ct_nxt[C_DLY_COMP_CT_WIDTH-2:0];
    end
  end
end

assign dly_comp_ct_nxt = dly_comp_ct - 1'b1;

// ========================================================

// SMBus Output/Tri-State control
assign smbclk_o = '0;
assign smbdat_o = '0;

always_ff @(posedge clk) begin
  if (!resetn) begin
    smbclk_t  <= '1;
    smbdat_t  <= '1;
  end else begin
    smbclk_t  <= (tgt_phy_ctl.smbclk_ctl & ctlr_phy_ctl.smbclk_ctl) | disc;
    smbdat_t  <= (tgt_phy_ctl.smbdat_ctl & ctlr_phy_ctl.smbdat_ctl) | disc;

    // Force smbclk low if smbclk_force_low is set to 0xCFB
    if (smbclk_force_low == C_SMBCLK_FORCE_LOW) begin
      smbclk_t  <= '0;
    end
  end
end

// ========================================================
// Assign the interrupt outputs

assign phy_cmn_irq.smbclk_low_timeout   = smbclk_low_timeout;
assign phy_cmn_irq.smbdat_low_timeout   = smbdat_low_timeout;
assign phy_cmn_irq.unexpected_bus_idle  = unexpected_bus_idle;

// Assign the control outputs
assign phy_cmn_stat.smbclk              = smbclk_filt_d1;
assign phy_cmn_stat.smbdat              = smbdat_filt_d1;
assign phy_cmn_stat.smbclk_re           = smbclk_re;
assign phy_cmn_stat.smbclk_fe           = smbclk_fe;
assign phy_cmn_stat.smbdat_latched      = smbdat_latched;
assign phy_cmn_stat.start               = start_in;
assign phy_cmn_stat.stop                = stop_in;
assign phy_cmn_stat.bus_idle            = bus_idle;
assign phy_cmn_stat.unexpected_bus_idle = unexpected_bus_idle;
assign phy_cmn_stat.smbclk_timeout      = smbclk_low_timeout;
assign phy_cmn_stat.phy_inactive        = phy_inactive;
assign phy_cmn_stat.bus_active          = bus_active;
assign phy_cmn_stat.ctlr_comp           = ctlr_comp;
assign phy_cmn_stat.default_input_lat   = C_INPUT_LATENCY + (C_DEFAULT_FILT_EN ?
    (fn_default_count(C_FREQ_HZ_CLK, C_TSPIKE_MAX[C_SMBUS_DEV_CLASS], 1'b0) + 1) : 0);

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    filt_en                     <= C_DEFAULT_FILT_EN;
    filt_count                  <= (C_FILT_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TSPIKE_MAX[C_SMBUS_DEV_CLASS], 1'b0));
    bus_free_time               <= (C_BUS_FREE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TBUF_MIN[C_SMBUS_DEV_CLASS], 1'b1));
    bus_idle_thresh             <= (C_BUS_INACTIVE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_THIGH_MAX[C_SMBUS_DEV_CLASS], 1'b1));
    timeout_prescaler           <= (C_TO_PRESCALE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TIMEOUT_PRESCALER[C_SMBUS_DEV_CLASS], 1'b1));
    timeout_min                 <= (C_TIMEOUT_CT_WIDTH-1)'
        (fn_default_count(C_TIMEOUT_PRESCALER_FREQ_HZ, C_TTIMEOUT_MIN[C_SMBUS_DEV_CLASS], 1'b1));
    timeout_max                 <= (C_TIMEOUT_CT_WIDTH-1)'
        (fn_default_count(C_TIMEOUT_PRESCALER_FREQ_HZ, C_TTIMEOUT_MAX[C_SMBUS_DEV_CLASS], 1'b1));
    smbclk_timeout_en           <= '1;
    smbclk_force_timeout        <= '0;
    smbclk_force_low            <= '0;
    reg_phy_cmn_if.reg_wr_done  <= '0;
  end else begin
    // Defaults
    reg_phy_cmn_if.reg_wr_done  <= '0;
    smbclk_force_timeout        <= '0;

    if (reg_phy_cmn_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|reg_phy_cmn_if.reg_wr_addr[C_ADDR_WIDTH-1:5])) begin
        case (reg_phy_cmn_if.reg_wr_addr[4:0]) inside
          // PHY Status - 0x00 (Read Only)
          5'b000??: ;
          // PHY Filter Control - 0x04
          5'b001??:
            begin
              filt_en     <= reg_phy_cmn_if.reg_wr_data[31];
              filt_count  <= reg_phy_cmn_if.reg_wr_data[C_FILT_CT_WIDTH-2:0];
            end
          // PHY Bus Free Time (tBUF) - 0x08
          5'b010??: bus_free_time     <= reg_phy_cmn_if.reg_wr_data[C_BUS_FREE_CT_WIDTH-2:0];
          // PHY Idle Threshold (>tHIGH:MAX) - 0x0C
          5'b011??: bus_idle_thresh   <= reg_phy_cmn_if.reg_wr_data[C_BUS_INACTIVE_CT_WIDTH-2:0];
          // PHY Timeout Prescaler - 0x10
          5'b100??: timeout_prescaler <= reg_phy_cmn_if.reg_wr_data[C_TO_PRESCALE_CT_WIDTH-2:0];
          // PHY Timeout Min - 0x14
          5'b101??:
            begin
              smbclk_timeout_en <= reg_phy_cmn_if.reg_wr_data[31];
              timeout_min       <= reg_phy_cmn_if.reg_wr_data[C_TIMEOUT_CT_WIDTH-2:0];
            end
          // PHY Timeout Max - 0x18
          5'b110??: timeout_max       <= reg_phy_cmn_if.reg_wr_data[C_TIMEOUT_CT_WIDTH-2:0];
          // PHY Reset Control - 0x1C
          5'b111??:
            begin
              smbclk_force_timeout  <= reg_phy_cmn_if.reg_wr_data[31];
              smbclk_force_low      <= reg_phy_cmn_if.reg_wr_data[11:0];
            end
        endcase
      end
      // Signal write done
      reg_phy_cmn_if.reg_wr_done <= '1;
    end
  end
end

// Always respond with OKAY to writes
assign reg_phy_cmn_if.reg_wr_resp = '0;

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_phy_cmn_if.reg_rd_data <= '0;
  reg_phy_cmn_if.reg_rd_done <= '0;

  if (reg_phy_cmn_if.reg_rd_valid) begin
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_phy_cmn_if.reg_rd_addr[C_ADDR_WIDTH-1:5])) begin
      case (reg_phy_cmn_if.reg_rd_addr[4:0]) inside
        // PHY Status - 0x00
        5'b000??:
          begin
            reg_phy_cmn_if.reg_rd_data[2]                       <= smbdat_low_timeout;
            reg_phy_cmn_if.reg_rd_data[1]                       <= smbclk_low_timeout;
            reg_phy_cmn_if.reg_rd_data[0]                       <= bus_idle;
          end
        // PHY Filter Control - 0x04
        5'b001??:
          begin
            reg_phy_cmn_if.reg_rd_data[31]                      <= filt_en;
            reg_phy_cmn_if.reg_rd_data[$bits(filt_count)-1:0]   <= filt_count;
          end
        // PHY Bus Free Time - 0x08
        5'b010??: reg_phy_cmn_if.reg_rd_data[C_BUS_FREE_CT_WIDTH-2:0]      <= bus_free_time;
        // PHY Bus Idle Threshold - 0x0C
        5'b011??: reg_phy_cmn_if.reg_rd_data[C_BUS_INACTIVE_CT_WIDTH-2:0]  <= bus_idle_thresh;
        // PHY Timeout Prescaler - 0x10
        5'b100??: reg_phy_cmn_if.reg_rd_data[C_TO_PRESCALE_CT_WIDTH-2:0]   <= timeout_prescaler;
        // PHY Timeout Min - 0x14
        5'b101??:
          begin
            reg_phy_cmn_if.reg_rd_data[31]                      <= smbclk_timeout_en;
            reg_phy_cmn_if.reg_rd_data[C_TIMEOUT_CT_WIDTH-2:0]  <= timeout_min;
          end
        // PHY Timeout Max - 0x18
        5'b110??: reg_phy_cmn_if.reg_rd_data[C_TIMEOUT_CT_WIDTH-2:0]       <= timeout_max;
        // PHY Reset Control - 0x1C
        5'b111??: reg_phy_cmn_if.reg_rd_data[11:0]                         <= smbclk_force_low;
        default:  reg_phy_cmn_if.reg_rd_data                               <= '0;
      endcase
    end
    // Signal read done
    reg_phy_cmn_if.reg_rd_done <= '1;
  end
end

// Always respond with OKAY to reads
assign reg_phy_cmn_if.reg_rd_resp = '0;


endmodule : smbus_v1_1_phy_common
