// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Controller PHY Logic
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_ctlr_phy
  import smbus_v1_1_pkg::*;
#(
  parameter int C_SMBUS_DEV_CLASS = 0,
  parameter int C_FREQ_HZ_CLK     = 100000000
) (
  // Register Control Interface
  smbus_v1_1_reg_if.sub       reg_ctlr_phy_if,

  // Clock & Reset
  input  logic                clk,
  input  logic                resetn,

  // Interrupts
  output ctlr_phy_irq_t       ctlr_phy_irq,

  // Control/Status
  input  phy_cmn_stat_t       phy_cmn_stat,
  input  ctlr_ctl_t           ctlr_ctl,
  output phy_cmn_ctl_t        phy_cmn_ctl,
  output ctlr_phy_stat_t      ctlr_phy_stat
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
localparam int C_ADDR_WIDTH           = $bits(reg_ctlr_phy_if.reg_wr_addr);

// FSM state bit selects
localparam int  CT_PHY_IDLE           = 0,
                CT_PHY_START          = 1,
                CT_PHY_WR_BYTE        = 2,
                CT_PHY_WR_RESP        = 3,
                CT_PHY_CLK_STRETCH    = 4,
                CT_PHY_RD_BYTE        = 5,
                CT_PHY_RD_RESP        = 6,
                CT_PHY_STOP           = 7;

// Sized for max 500MHz clock to support 50us count
localparam int  C_TIMER_CT_WIDTH          = 16;

// Sized for max 500MHz clock, allows for prescaler of 1.024us
localparam int  C_TEXT_PRESCALE_CT_WIDTH  = 10;

// Sized for 1us prescaler, allows for tLOW:TEXT of max 32.768ms to be measured
localparam int  C_TEXT_TIMEOUT_CT_WIDTH   = 15;

// Sized for max 500MHz clock, allows for prescaler of 1.024us
localparam int  C_CEXT_PRESCALE_CT_WIDTH  = 10;

// Sized for 1us prescaler, allows for tLOW:CEXT of max 16.384ms to be measured
localparam int  C_CEXT_TIMEOUT_CT_WIDTH   = 14;
localparam int  C_CTLR_PHY_LATENCY        = 2;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// Controller PHY FSM States - OneHot Encoded
typedef enum logic [7:0] {
  ST_CT_PHY_IDLE        = 1 << CT_PHY_IDLE,
  ST_CT_PHY_START       = 1 << CT_PHY_START,
  ST_CT_PHY_WR_BYTE     = 1 << CT_PHY_WR_BYTE,
  ST_CT_PHY_WR_RESP     = 1 << CT_PHY_WR_RESP,
  ST_CT_PHY_CLK_STRETCH = 1 << CT_PHY_CLK_STRETCH,
  ST_CT_PHY_RD_BYTE     = 1 << CT_PHY_RD_BYTE,
  ST_CT_PHY_RD_RESP     = 1 << CT_PHY_RD_RESP,
  ST_CT_PHY_STOP        = 1 << CT_PHY_STOP
} state_ct_phy_fsm_t;

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
state_ct_phy_fsm_t                    current_st;
state_ct_phy_fsm_t                    next_st;
logic                                 smbclk_ctl;
logic                                 smbdat_ctl;
logic                                 phy_idle;
logic                                 phy_error;
logic [C_TIMER_CT_WIDTH-2:0]          data_hold_time;
logic [C_TIMER_CT_WIDTH-2:0]          start_hold_time;
logic [C_TIMER_CT_WIDTH-2:0]          start_setup_time;
logic [C_TIMER_CT_WIDTH-2:0]          stop_setup_time;
logic [C_TIMER_CT_WIDTH-2:0]          clk_tlow_time;
logic [C_TIMER_CT_WIDTH-2:0]          clk_thigh_time;
logic [C_TIMER_CT_WIDTH-2:0]          timer_a;
logic [C_TIMER_CT_WIDTH-2:0]          timer_a_ct;
logic [C_TIMER_CT_WIDTH-1:0]          timer_a_ct_nxt;
logic                                 timer_a_en;
logic                                 timer_a_exp;
logic [C_TIMER_CT_WIDTH-2:0]          timer_b;
logic [C_TIMER_CT_WIDTH-2:0]          timer_b_ct;
logic [C_TIMER_CT_WIDTH-1:0]          timer_b_ct_nxt;
logic                                 timer_b_en;
logic                                 timer_b_exp;
logic [3:0]                           ctl_phase;
logic [3:0]                           data_phase;
logic [3:0]                           resp_phase;
logic [3:0]                           bit_count;
logic                                 bit_count_msb_d1;
logic                                 rx_byte_valid;
logic [7:0]                           rx_byte;
logic                                 ctlr_loa;
logic                                 nack_err;
logic                                 nack_err_irq;
logic                                 clk_stretch;
logic                                 repeated_start;
logic [7:0]                           tx_byte;
logic                                 read_write;
logic                                 rd_ack;
logic                                 rd_ack_ready;
logic                                 wr_ack;
logic                                 wr_ack_valid;
logic [C_TEXT_PRESCALE_CT_WIDTH-2:0]  text_cur_ct;
logic [C_TEXT_PRESCALE_CT_WIDTH-1:0]  text_cur_ct_nxt;
logic [C_TEXT_PRESCALE_CT_WIDTH-2:0]  text_prescaler;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_ct;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_max_ct;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_timeout;
logic                                 text_max_clr;
logic                                 text_irq;
logic                                 text_en;
logic [C_CEXT_PRESCALE_CT_WIDTH-2:0]  cext_cur_ct;
logic [C_CEXT_PRESCALE_CT_WIDTH-1:0]  cext_cur_ct_nxt;
logic [C_CEXT_PRESCALE_CT_WIDTH-2:0]  cext_prescaler;
logic [C_CEXT_TIMEOUT_CT_WIDTH-1:0]   cext_ct;
logic [C_CEXT_TIMEOUT_CT_WIDTH-1:0]   cext_max_ct;
logic [C_CEXT_TIMEOUT_CT_WIDTH-1:0]   cext_timeout;
logic                                 cext_max_clr;
logic                                 cext_irq;
logic                                 cext_ct_clr;

// ========================================================
// Controller PHY FSM

// Update the current state
always_ff @(posedge clk) begin
  if (!resetn) begin
    current_st  <= ST_CT_PHY_IDLE;
  end else begin
    current_st  <= next_st;
  end
end

// Determine the next state
always_comb begin
  next_st = current_st;
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[CT_PHY_IDLE]:
      begin
        if (ctlr_ctl.start_stop_valid && ctlr_ctl.start_stop) begin
          // Wait for Controller to signal START, then move to start state
          next_st = ST_CT_PHY_START;
        end
      end
    current_st[CT_PHY_START]:
      begin
        if (phy_cmn_stat.smbclk_timeout || ctlr_loa) begin
          // PHY has detected smbclk low timeout or loss of arbitration, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (ctl_phase[3]) begin
          // Once (REPEATED)-START complete, then move to write byte state
          next_st = ST_CT_PHY_WR_BYTE;
        end
      end
    current_st[CT_PHY_WR_BYTE]:
      begin
        if (phy_cmn_stat.phy_inactive || ctlr_loa) begin
          // PHY has gone inactive or loss of arbitration detected, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (data_phase[3]) begin
          // Once byte transmission complete, then move to write response state
          next_st = ST_CT_PHY_WR_RESP;
        end
      end
    current_st[CT_PHY_WR_RESP]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // PHY has gone inactive, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (resp_phase[3]) begin
          if (!wr_ack || ctlr_ctl.quick_cmd) begin
            // Target has responded with NACK or Controller sending a Quick command,
            // move to stop state
            next_st = ST_CT_PHY_STOP;
          end else if (wr_ack && read_write) begin
            // Target has responded with ACK, read transaction so move to read byte state
            next_st = ST_CT_PHY_RD_BYTE;
          end else if (wr_ack && !read_write) begin
            // Target has responded with ACK, write transaction so move to clk stretch state
            next_st = ST_CT_PHY_CLK_STRETCH;
          end
        end
      end
    current_st[CT_PHY_CLK_STRETCH]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // PHY has gone inactive, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (ctlr_ctl.start_stop_valid && !ctlr_ctl.start_stop) begin
          // Controller sent STOP instruction, move to stop state
          next_st = ST_CT_PHY_STOP;
        end else if (ctlr_ctl.start_stop_valid && ctlr_ctl.start_stop) begin
          // Controller sent START instruction, move to start state
          next_st = ST_CT_PHY_START;
        end else if (ctlr_ctl.tx_byte_valid) begin
          // Controller sent byte for transmission, move to write byte state
          next_st = ST_CT_PHY_WR_BYTE;
        end else if (ctlr_ctl.rd_ack_valid) begin
          // Controller sent response for read byte, move to read response state
          next_st = ST_CT_PHY_RD_RESP;
        end
      end
    current_st[CT_PHY_RD_BYTE]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // PHY has gone inactive, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (data_phase[3]) begin
          // Read byte complete, move to clk stretch state
          next_st = ST_CT_PHY_CLK_STRETCH;
        end
      end
    current_st[CT_PHY_RD_RESP]:
      begin
        if (phy_cmn_stat.phy_inactive || ctlr_loa) begin
          // PHY has gone inactive or loss of arbitration detected, move to idle state
          next_st = ST_CT_PHY_IDLE;
        end else if (resp_phase[3] && rd_ack) begin
          // ACK response sent for last read byte, Controller wants to read another byte,
          // move to read byte state
          next_st = ST_CT_PHY_RD_BYTE;
        end else if (resp_phase[3] && !rd_ack) begin
          // NACK response sent for last read byte, Controller is finished reading,
          // move to stop state
          next_st = ST_CT_PHY_STOP;
        end
      end
    current_st[CT_PHY_STOP]:
      begin
        if (phy_cmn_stat.phy_inactive || ctlr_loa || ctl_phase[3]) begin
          // PHY has gone inactive, loss of arbitration detected or STOP condition complete,
          // move to idle state
          next_st = ST_CT_PHY_IDLE;
        end
      end
    default: next_st = ST_CT_PHY_IDLE;
  endcase
end

// Set the Controller PHY outputs based on the FSM state
always_ff @(posedge clk) begin
  // Defaults
  phy_idle          <= '0;
  ctl_phase         <= '0;
  data_phase        <= '0;
  resp_phase        <= '0;
  bit_count         <= '0;
  bit_count_msb_d1  <= bit_count[3];
  rx_byte_valid     <= '0;
  wr_ack_valid      <= '0;
  ctlr_loa          <= '0;
  clk_stretch       <= '0;
  nack_err_irq      <= '0;
  rd_ack_ready      <= '0;
  cext_ct_clr       <= '0;

  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[CT_PHY_IDLE]:
      begin
        // State Defaults
        phy_idle        <= '1;
        smbclk_ctl      <= '1;
        smbdat_ctl      <= '1;
        repeated_start  <= '0;
        nack_err        <= '0;
        timer_a_en      <= '0;
        timer_a         <= '0;
        timer_b_en      <= '0;
        timer_b         <= '0;
        text_en         <= '0;
        rx_byte         <= '0;
      end
    current_st[CT_PHY_START]:
      begin
        // State Defaults
        ctl_phase     <= ctl_phase;

        // Load the header byte to transmit
        if (ctlr_ctl.tx_byte_valid) begin
          tx_byte     <= ctlr_ctl.tx_byte;
          read_write  <= ctlr_ctl.tx_byte[0];
        end

        if (!repeated_start) begin
          // START condition
          // Initial START condition following the detection of the Bus Idle condition

          // Once Bus Idle is detected, bring smbdat low
          if (ctl_phase == 4'b0000 && phy_cmn_stat.bus_idle) begin
            smbdat_ctl  <= '0;
            timer_a     <= start_hold_time;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // Once smbdat is seen as low at the input, then wait for the START hold time (tHD:STA)
          if (ctl_phase == 4'b0001 && !phy_cmn_stat.smbdat) begin
            timer_a_en  <= '1;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // After the START hold time has elapsed or the smbclk brought low by another Controller,
          // then drive smbclk low. Flag repeated start so that on next entry to this state a
          // REPEATED-START is performd rather than START
          if (ctl_phase == 4'b0010 && (timer_a_exp || !phy_cmn_stat.smbclk)) begin
            smbclk_ctl      <= '0;
            timer_a_en      <= '0;
            repeated_start  <= '1;
            ctl_phase       <= 4'b1000;
          end

        end else begin
          // REPEATED-START condition
          // The REPEATED-START condition is used for protocols that transistion from a
          // Write into a Read

          // Drive smbclk low and release smbdat high-z,
          // load the event timer for smbclk low period (tLOW:Min)
          if (ctl_phase == 4'b0000) begin
            smbclk_ctl  <= '0;
            smbdat_ctl  <= '1;
            timer_a     <= clk_tlow_time;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // After smbclk is sampled low (accounts for tF), then start timing for tLOW
          if (ctl_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
            timer_a_en  <= '1;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // After the smbclk tLOW time is met, then release high-z and wait for the rising edge.
          // Prepare the timer
          if (ctl_phase == 4'b0010 && timer_a_exp) begin
            smbclk_ctl  <= '1;
            timer_a_en  <= '0;
            timer_a     <= start_setup_time;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // Enable the TEXT measurement while waiting for the rising edge
          if (ctl_phase == 4'b0011 && phy_cmn_stat.ctlr_comp) begin
            text_en     <= '1;
          end

          // smbclk rising edge detected, check for Loss of Arbitration.
          // Enable the timer for START setup time (tSU:STA)
          if (ctl_phase == 4'b0011 && phy_cmn_stat.smbclk) begin
            if (!phy_cmn_stat.smbdat) begin
              ctlr_loa  <= '1;
            end
            timer_a_en  <= '1;
            text_en     <= '0;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // After the START setup time is met, drive smbdat low to cause the REPEATED-START.
          // Prepare the timer for START hold time (tHD:STA)
          if (ctl_phase == 4'b0100) begin
            if (!phy_cmn_stat.smbclk && !timer_a_exp) begin
              // Another Controller has driven smbclk low before START setup time is met,
              // flag loss of arbitration
              ctlr_loa    <= '1;
            end
            if (phy_cmn_stat.start || timer_a_exp) begin
              // Another Controller has initiated the REPEATED-START or the setup time has elapsed
              smbdat_ctl  <= '0;
              timer_a_en  <= '0;
              timer_a     <= start_hold_time;
              ctl_phase   <= ctl_phase + 1'b1;
            end
          end

          // Wait until the smbdat falling edge is detected (accounts for tF),
          // then wait for the START hold time
          if (ctl_phase == 4'b0101 && !phy_cmn_stat.smbdat) begin
            timer_a_en  <= '1;
            ctl_phase   <= ctl_phase + 1'b1;
          end

          // START hold time met or smbclk driven low by another Controller, drive the smbclk low
          if (ctl_phase == 4'b0110 && (timer_a_exp || !phy_cmn_stat.smbclk)) begin
            smbclk_ctl  <= '0;
            timer_a_en  <= '0;
            ctl_phase   <= 4'b1000;
          end
        end
      end
    current_st[CT_PHY_WR_BYTE]:
      begin
        // State Defaults
        bit_count     <= bit_count;
        data_phase    <= data_phase;

        // If more bits to transmit, drive smbclk low and preload the timers for
        // data hold and clk low
        if (data_phase == 4'b0000 && !bit_count[3]) begin
          smbclk_ctl  <= '0;
          timer_a     <= data_hold_time;
          timer_b     <= clk_tlow_time;
          data_phase  <= data_phase + 1'b1;
        end

        // Wait until smbclk is sampled low (tF), then enable the data hold and clk low timers
        if (data_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
          timer_a_en  <= '1;
          timer_b_en  <= '1;
          data_phase  <= data_phase + 1'b1;
        end

        // After the data hold time (tHD:DAT) has elapsed, update the transmit bit
        // Timer A will always expire first as data hold must be < smbclk tLOW
        if (data_phase == 4'b0010 && timer_a_exp) begin
          smbdat_ctl  <= tx_byte[7];
          tx_byte     <= {tx_byte[6:0],1'b1};
          data_phase  <= data_phase + 1'b1;
        end

        // After smbclk tLOW time is met, release high-z and wait for the rising edge
        if (data_phase == 4'b0011 && timer_b_exp) begin
          smbclk_ctl  <= '1;
          timer_a_en  <= '0;
          timer_b_en  <= '0;
          timer_b     <= clk_thigh_time;
          data_phase  <= data_phase + 1'b1;
        end

        // Enable the TEXT measurement while waiting for the rising edge
        if (data_phase == 4'b0100 && phy_cmn_stat.ctlr_comp) begin
          text_en     <= '1;
        end

        // smbclk rising edge detected, check for loss of arbitration. Start counting smbclk tHIGH
        if (data_phase == 4'b0100 && phy_cmn_stat.smbclk) begin
          if (phy_cmn_stat.smbdat != smbdat_ctl) begin
            ctlr_loa  <= '1;
          end
          timer_b_en  <= '1;
          text_en     <= '0;
          bit_count   <= bit_count + 1'b1;
          data_phase  <= data_phase + 1'b1;
        end

        // Wait for smbclk tHIGH. If smbclk input goes low first then another (faster) Controller
        // has started the next bit transfer, drive smbclk low to maintain clock synchronization
        if (data_phase == 4'b0101) begin
          if (phy_cmn_stat.start) begin
            // Repeated START detected, another Controller has won arbitration
            ctlr_loa  <= '1;
          end
          if (timer_b_exp || !phy_cmn_stat.smbclk) begin
            smbclk_ctl  <= '0;
            timer_b_en  <= '0;
            if (bit_count[3]) begin
              // Byte has been written, move to the end phase
              data_phase  <= '1;
            end else begin
              // More bits to write, go back to the first phase
              data_phase  <= '0;
            end
          end
        end
      end
    current_st[CT_PHY_WR_RESP]:
      begin
        // State Defaults
        resp_phase    <= resp_phase;
        cext_ct_clr   <= '1;

        // Drive smbclk low, load the timers
        if (resp_phase == 4'b0000) begin
          smbclk_ctl  <= '0;
          timer_a     <= data_hold_time;
          timer_b     <= clk_tlow_time;
          resp_phase  <= resp_phase + 1'b1;
        end

        // Wait for smbclk falling edge, then enable the data hold and clk tLOW timers
        if (resp_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
          timer_a_en  <= '1;
          timer_b_en  <= '1;
          resp_phase  <= resp_phase + 1'b1;
        end

        // After the data hold time (tHD:DAT) has elapsed, release smbdat high-z so the Target
        // has control. Timer A will always expire first as data hold must be < smbclk tLOW
        if (resp_phase == 4'b0010 && timer_a_exp) begin
          smbdat_ctl  <= '1;
          resp_phase  <= resp_phase + 1'b1;
        end

        // After smbclk tLOW time is met, release high-z and wait for the rising edge
        if (resp_phase == 4'b0011 && timer_b_exp) begin
          smbclk_ctl   <= '1;
          timer_a_en   <= '0;
          timer_b_en   <= '0;
          timer_b      <= clk_thigh_time;
          resp_phase   <= resp_phase + 1'b1;
        end

        // Enable the TEXT measurement while waiting for the rising edge
        if (resp_phase == 4'b0100 && phy_cmn_stat.ctlr_comp) begin
          text_en     <= '1;
        end

        // smbclk rising edge detected, sample the Target response. Start counting smbclk tHIGH
        if (resp_phase == 4'b0100 && phy_cmn_stat.smbclk) begin
          wr_ack          <= ~phy_cmn_stat.smbdat;
          wr_ack_valid    <= '1;
          nack_err        <= phy_cmn_stat.smbdat;
          timer_b_en      <= '1;
          text_en         <= '0;
          resp_phase      <= resp_phase + 1'b1;
        end

        // Wait for tHIGH time to be met or for smbclk to be driven low by another Controller,
        // drive smbclk low
        if (resp_phase == 4'b0101 && (timer_b_exp || !phy_cmn_stat.smbclk)) begin
          smbclk_ctl   <= '0;
          timer_b_en   <= '0;
          resp_phase   <= '1;
        end
      end
    current_st[CT_PHY_CLK_STRETCH]:
      begin
        // State Defaults
        timer_a_en   <= '0;
        timer_b_en   <= '0;

        // Update the transmit byte
        if (ctlr_ctl.tx_byte_valid) begin
          tx_byte     <= ctlr_ctl.tx_byte;
        end

        // Update the read response
        if (ctlr_ctl.rd_ack_valid) begin
          rd_ack  <= ctlr_ctl.rd_ack;
        end

        // If the Controller has not sent the next command,
        // then wait in this state and flag clock stretching is active
        if (!ctlr_ctl.tx_byte_valid && !ctlr_ctl.start_stop_valid && !ctlr_ctl.rd_ack_valid) begin
          clk_stretch <= '1;
        end
      end
    current_st[CT_PHY_RD_BYTE]:
      begin
        // State Defaults
        data_phase    <= data_phase;
        bit_count     <= bit_count;

        // Drive smbclk low, load the timers if there are more bits to be read
        if (data_phase == 4'b0000 && !bit_count[3]) begin
          smbclk_ctl    <= '0;
          timer_a       <= data_hold_time;
          timer_b       <= clk_tlow_time;
          data_phase    <= data_phase + 1'b1;
        end

        // Wait for smbclk falling edge, then enable the data hold and clk tLOW timers
        if (data_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
          timer_a_en    <= '1;
          timer_b_en    <= '1;
          data_phase    <= data_phase + 1'b1;
        end

        // After the data hold time (tHD:DAT) has elapsed, release smbdat high-z so the
        // Target has control. This is only applicable to the MSB, subsequent bit timing is fully
        // under Target control and is not driven by the Controller
        // Timer A will always expire first as data hold must be < smbclk tLOW
        if (data_phase == 4'b0010 && timer_a_exp) begin
          smbdat_ctl    <= '1;
          data_phase    <= data_phase + 1'b1;
        end

        // After smbclk tLOW time is met, release high-z and wait for the rising edge
        if (data_phase == 4'b0011 && timer_b_exp) begin
          smbclk_ctl    <= '1;
          timer_a_en    <= '0;
          timer_b_en    <= '0;
          timer_b       <= clk_thigh_time;
          data_phase    <= data_phase + 1'b1;
        end

        // Enable the TEXT measurement while waiting for the rising edge
        if (data_phase == 4'b0100 && phy_cmn_stat.ctlr_comp) begin
          text_en     <= '1;
        end

        // smbclk rising edge detected, shift in the read date from the Target.
        // Start counting smbclk tHIGH
        if (data_phase == 4'b0100 && phy_cmn_stat.smbclk) begin
          rx_byte       <= {rx_byte[6:0],phy_cmn_stat.smbdat};
          timer_b_en    <= '1;
          text_en       <= '0;
          bit_count     <= bit_count + 1'b1;
          data_phase    <= data_phase + 1'b1;
        end

        // Signal rx byte valid for a single cycle
        if (bit_count[3] && !bit_count_msb_d1) begin
          rx_byte_valid <= '1;
        end

        // Wait for tHIGH time to be met or for smbclk to be driven low by another Controller,
        // drive smbclk low
        if (data_phase == 4'b0101 && (timer_b_exp || !phy_cmn_stat.smbclk)) begin
          smbclk_ctl  <= '0;
          timer_b_en  <= '0;
          if (bit_count[3]) begin
            // Byte has been read, move to the end phase
            data_phase  <= '1;
          end else begin
            // More bits to read, go back to the first phase
            data_phase  <= '0;
          end
        end
      end
    current_st[CT_PHY_RD_RESP]:
      begin
        // State Defaults
        resp_phase    <= resp_phase;
        rd_ack_ready  <= '1;
        cext_ct_clr   <= '1;

        // Drive smbclk low and preload the timers for data hold and clk low
        if (resp_phase == 4'b0000) begin
          smbclk_ctl  <= '0;
          timer_a     <= data_hold_time;
          timer_b     <= clk_tlow_time;
          resp_phase  <= resp_phase + 1'b1;
        end

        // Wait until smbclk is sampled low (tF), then enable the data hold and clk low timers
        if (resp_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
          timer_a_en  <= '1;
          timer_b_en  <= '1;
          resp_phase  <= resp_phase + 1'b1;
        end

        // After the data hold time (tHD:DAT) has elapsed, update the transmit bit
        // Timer A will always expire first as data hold must be < smbclk tLOW
        if (resp_phase == 4'b0010 && timer_a_exp) begin
          smbdat_ctl  <= ~rd_ack;
          resp_phase  <= resp_phase + 1'b1;
        end

        // After smbclk tLOW time is met, release high-z and wait for the rising edge
        if (resp_phase == 4'b0011 && timer_b_exp) begin
          smbclk_ctl  <= '1;
          timer_a_en  <= '0;
          timer_b_en  <= '0;
          timer_b     <= clk_thigh_time;
          resp_phase  <= resp_phase + 1'b1;
        end

        // Enable the TEXT measurement while waiting for the rising edge
        if (resp_phase == 4'b0100 && phy_cmn_stat.ctlr_comp) begin
          text_en     <= '1;
        end

        // smbclk rising edge detected, check for loss of arbitration. Start counting smbclk tHIGH
        if (resp_phase == 4'b0100 && phy_cmn_stat.smbclk) begin
          if (phy_cmn_stat.smbdat != smbdat_ctl) begin
            ctlr_loa  <= '1;
          end
          timer_b_en  <= '1;
          text_en     <= '0;
          resp_phase  <= resp_phase + 1'b1;
        end

        // Wait for smbclk tHIGH. If smbclk input goes low first then another (faster) Controller
        // has started the next bit transfer, drive smbclk low to maintain clock synchronization
        if (resp_phase == 4'b0101) begin
          if (phy_cmn_stat.start) begin
            // Repeated START detected, another Controller has won arbitration
            ctlr_loa  <= '1;
          end
          if (timer_b_exp || !phy_cmn_stat.smbclk) begin
            smbclk_ctl  <= '0;
            timer_b_en  <= '0;
            resp_phase  <= '1;
          end
        end
      end
    current_st[CT_PHY_STOP]:
      begin
        // State Defaults
        ctl_phase     <= ctl_phase;
        cext_ct_clr   <= '1;

        // Drive smbclk low and preload the timers for data hold and clk low
        if (ctl_phase == 4'b0000) begin
          smbclk_ctl  <= '0;
          timer_a     <= data_hold_time;
          timer_b     <= clk_tlow_time;
          ctl_phase   <= ctl_phase + 1'b1;
        end

        // Wait until smbclk is sampled low (tF), then enable the data hold and clk low timers
        if (ctl_phase == 4'b0001 && !phy_cmn_stat.smbclk) begin
          timer_a_en  <= '1;
          timer_b_en  <= '1;
          ctl_phase   <= ctl_phase + 1'b1;
        end

        // After the data hold time (tHD:DAT) has elapsed, drive smbdat low
        // Timer A will always expire first as data hold must be < smbclk tLOW
        if (ctl_phase == 4'b0010 && timer_a_exp) begin
          smbdat_ctl  <= '0;
          ctl_phase   <= ctl_phase + 1'b1;
        end

        // After smbclk tLOW time is met, release high-z and wait for the rising edge
        if (ctl_phase == 4'b0011 && timer_b_exp) begin
          smbclk_ctl  <= '1;
          timer_a_en  <= '0;
          timer_b_en  <= '0;
          timer_b     <= stop_setup_time;
          ctl_phase   <= ctl_phase + 1'b1;
        end

        // Enable the TEXT measurement while waiting for the rising edge
        if (ctl_phase == 4'b0100 && phy_cmn_stat.ctlr_comp) begin
          text_en     <= '1;
        end

        // smbclk rising edge detected, start counting STOP setup time (tSU:STO)
        if (ctl_phase == 4'b0100 && phy_cmn_stat.smbclk) begin
          timer_b_en  <= '1;
          text_en     <= '0;
          ctl_phase   <= ctl_phase + 1'b1;
        end

        // Wait for STOP setup time (tSU:STO), then release smbdat high-z to create the
        // STOP condition.
        // If smbclk input goes low first then another (faster) Controller has started the
        // next bit transfer, flag loss of arbitration
        if (ctl_phase == 4'b0101) begin
          if (!phy_cmn_stat.smbclk && !timer_b_exp) begin
            // Another Controller has driven smbclk low before STOP setup time is met,
            // flag loss of arbitration
            ctlr_loa    <= '1;
          end
          if (timer_b_exp) begin
            smbdat_ctl    <= '1;
            timer_b_en    <= '0;
            ctl_phase     <= ctl_phase + 1'b1;
          end
        end

        // Check for smbdat rising edge signalling completion of the STOP condition
        if (ctl_phase == 4'b0110) begin
          if (!phy_cmn_stat.smbclk && !phy_cmn_stat.smbdat) begin
            // Another Controller has driven smbclk low and smbdat has not returned high,
            // flag loss of arbitration
            ctlr_loa      <= '1;
          end else if (phy_cmn_stat.phy_inactive) begin
            // STOP or timeout detected, transaction complete
            nack_err_irq  <= nack_err;
            ctl_phase     <= '1;
          end
        end
      end
  endcase
end

// ========================================================
// Flag if the reason for the PHY going Idle is due to an error
// The controller logic requires this to differentiate between good/bad end of transaction

always_ff @(posedge clk) begin
  if (!resetn) begin
    phy_error  <= '0;
  end else begin
    if (ctlr_ctl.disabled) begin
      // Reset PHY error when the Controller is disabled
      phy_error <= '0;
    end else if (ctlr_loa || nack_err || (phy_cmn_stat.smbclk_timeout && !phy_idle)) begin
      // Latch error status on LOA, NACK error and SMBCLK low timeout
      phy_error <= '1;
    end
  end
end

// ========================================================

// Event Timers - Two event timers (A & B) as there are certain conditions that must be
// timed in parallel
always_ff @(posedge clk) begin
  if (!resetn) begin
    timer_a_ct    <= '0;
    timer_a_exp   <= '0;
    timer_b_ct    <= '0;
    timer_b_exp   <= '0;
  end else begin
    // Timer A
    if (!timer_a_en) begin
      // Reload the timer with the count, clear the expiry flag
      timer_a_ct  <= timer_a;
      timer_a_exp <= '0;
    end else if (timer_a_ct_nxt[C_TIMER_CT_WIDTH-1]) begin
      // On count underrun, flag timer expired
      timer_a_exp <= '1;
    end else begin
      // Count while the timer is enabled
      timer_a_ct  <= timer_a_ct_nxt[C_TIMER_CT_WIDTH-2:0];
    end

    // Timer B
    if (!timer_b_en) begin
      // Reload the timer with the count, clear the expiry flag
      timer_b_ct  <= timer_b;
      timer_b_exp <= '0;
    end else if (timer_b_ct_nxt[C_TIMER_CT_WIDTH-1]) begin
      // On count underrun, flag timer expired
      timer_b_exp <= '1;
    end else begin
      // Count while the timer is enabled
      timer_b_ct  <= timer_b_ct_nxt[C_TIMER_CT_WIDTH-2:0];
    end
  end
end

// Assign the next count
assign timer_a_ct_nxt = timer_a_ct - 1'b1;
assign timer_b_ct_nxt = timer_b_ct - 1'b1;

// ========================================================
// Measure the Controller tLOW:CEXT timeout
// Implements a high-tide marker for amount of clock stretching introduced by the Controller PHY and
// raises an interrupt if the configured threshold is reached.
// A breach of this limit has no consequent action locally within the IP, but it is a breach of the
// standard if it occurs. The IP will only clock strectch while it waits on descriptors to be
// written, so a timeout here is indicating that the software response time to the IP is too slow.

always_ff @(posedge clk) begin
  if (!resetn) begin
    cext_cur_ct   <= '0;
    cext_ct       <= '0;
    cext_max_ct   <= '0;
    cext_irq      <= '0;
  end else begin
    // Defaults
    cext_irq  <= '0;

    if (cext_ct_clr) begin
      // Reset the counts on each byte boundary i.e. the ACK/STOP bits
      cext_cur_ct <= cext_prescaler;
      cext_ct     <= '0;
    end else begin
      if (clk_stretch) begin
        // When clock stretching is active, update the prescaler and timeout counts
        if (cext_cur_ct_nxt[C_CEXT_PRESCALE_CT_WIDTH-1]) begin
          // Current prescaler count has underflowed,
          // reload the prescaler and increment the timeout count
          cext_cur_ct <= cext_prescaler;
          cext_ct     <= cext_ct + 1'b1;
        end else begin
          // Decrement the prescaler
          cext_cur_ct <= cext_cur_ct_nxt[C_CEXT_PRESCALE_CT_WIDTH-2:0];
        end
      end
    end

    // Check if the count has reached the interrupt threshold, if so raise the interrupt
    if (cext_ct >= cext_timeout) begin
      cext_irq  <= '1;
    end

    // Update the high-tide count
    if (cext_max_clr) begin
      // Reset the max count when clear requested from register interface
      cext_max_ct <= '0;
    end else if (cext_ct > cext_max_ct) begin
      // Update max to match current measurement if it is larger
      cext_max_ct <= cext_ct;
    end
  end
end

// Assign the next count
assign cext_cur_ct_nxt = cext_cur_ct - 1'b1;

// ========================================================
// Measure the Target tLOW:TEXT timeout from the Controller perspective
// Implements a high-tide marker for amount of clock stretching introduced by the external target
// and raises an interrupt if the configured threshold is reached.
// A breach of this limit has no consequent action locally within the IP, but software may instruct
// the Controller to abort the current transaction if it is breached by sending a STOP descriptor.

always_ff @(posedge clk) begin
  if (!resetn) begin
    text_cur_ct   <= '0;
    text_ct       <= '0;
    text_max_ct   <= '0;
    text_irq      <= '0;
  end else begin
    // Defaults
    text_irq  <= '0;

    if (phy_idle) begin
      // When no transaction is in progress, then reset the counts
      text_cur_ct <= text_prescaler;
      text_ct     <= '0;
    end else begin
      if (text_en) begin
        // When waiting for the clock to go high, update the prescaler and timeout counts
        if (text_cur_ct_nxt[C_TEXT_PRESCALE_CT_WIDTH-1]) begin
          // Current prescaler count has underflowed,
          // reload the prescaler and increment the timeout count
          text_cur_ct <= text_prescaler;
          text_ct     <= text_ct + 1'b1;
        end else begin
          // Decrement the prescaler
          text_cur_ct <= text_cur_ct_nxt[C_TEXT_PRESCALE_CT_WIDTH-2:0];
        end
      end
    end

    // Check if the count has reached the interrupt threshold, if so raise the interrupt
    if (text_ct >= text_timeout) begin
      text_irq  <= '1;
    end

    // Update the high-tide count
    if (text_max_clr) begin
      // Reset the max count when clear requested from register interface
      text_max_ct <= '0;
    end else if (text_ct > text_max_ct) begin
      // Update max to match current measurement if it is larger
      text_max_ct <= text_ct;
    end
  end
end

// Assign the next count
assign text_cur_ct_nxt = text_cur_ct - 1'b1;


// ========================================================
// Assign the outputs

// Controller PHY Status interface
assign ctlr_phy_stat.phy_idle      = phy_idle;
assign ctlr_phy_stat.rx_byte_valid = rx_byte_valid;
assign ctlr_phy_stat.rx_byte       = rx_byte;
assign ctlr_phy_stat.wr_ack_valid  = wr_ack_valid;
assign ctlr_phy_stat.wr_ack        = wr_ack;
assign ctlr_phy_stat.rd_ack_ready  = rd_ack_ready;
assign ctlr_phy_stat.phy_error     = phy_error;

// PHY Common Control interface
assign phy_cmn_ctl.smbclk_ctl     = smbclk_ctl;
assign phy_cmn_ctl.smbdat_ctl     = smbdat_ctl;

// Controller PHY Interrupt interface
assign ctlr_phy_irq.loa           = ctlr_loa;
assign ctlr_phy_irq.nack_err      = nack_err_irq;
assign ctlr_phy_irq.text_timeout  = text_irq;
assign ctlr_phy_irq.cext_timeout  = cext_irq;

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    // Device Class 0 requires a non-zero hold time to provide SMBus 2.0 backwards compatibility
    if (C_SMBUS_DEV_CLASS == 0) begin : device_class_0
      // Default accounts for input latency
      data_hold_time              <= (C_TIMER_CT_WIDTH-1)'
          (fn_default_count(C_FREQ_HZ_CLK, C_THD_DAT_MIN[C_SMBUS_DEV_CLASS], 1'b1)
          - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    end else begin : device_class_1_2
      // Zero hold time, don't account for input latency which would result in a negative hold time
      data_hold_time              <= (C_TIMER_CT_WIDTH-1)'
          (fn_default_count(C_FREQ_HZ_CLK, C_THD_DAT_MIN[C_SMBUS_DEV_CLASS], 1'b1));
    end
    start_hold_time             <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_THD_STA_MIN[C_SMBUS_DEV_CLASS], 1'b1)
        - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    start_setup_time            <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TSU_STA_MIN[C_SMBUS_DEV_CLASS], 1'b1)
        - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    stop_setup_time             <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TSU_STO_MIN[C_SMBUS_DEV_CLASS], 1'b1)
        - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    clk_tlow_time               <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TLOW_MIN[C_SMBUS_DEV_CLASS], 1'b1)
        - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    clk_thigh_time              <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_THIGH_MIN[C_SMBUS_DEV_CLASS], 1'b1)
        - phy_cmn_stat.default_input_lat - C_CTLR_PHY_LATENCY);
    text_prescaler              <= (C_TEXT_PRESCALE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TEXT_TIMEOUT_PRESCALER[C_SMBUS_DEV_CLASS], 1'b1));
    text_timeout                <= (C_TEXT_TIMEOUT_CT_WIDTH)'
        (fn_default_count(C_TEXT_TIMEOUT_PRESCALER_FREQ_HZ, C_TEXT_TIMEOUT_MAX[C_SMBUS_DEV_CLASS],
        1'b1) + 1'b1);
    text_max_clr                <= '0;
    cext_prescaler              <= (C_CEXT_PRESCALE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_CEXT_TIMEOUT_PRESCALER[C_SMBUS_DEV_CLASS], 1'b1));
    cext_timeout                <= (C_CEXT_TIMEOUT_CT_WIDTH)'
        (fn_default_count(C_CEXT_TIMEOUT_PRESCALER_FREQ_HZ, C_CEXT_TIMEOUT_MAX[C_SMBUS_DEV_CLASS],
        1'b1) + 1'b1);
    cext_max_clr                <= '0;
    reg_ctlr_phy_if.reg_wr_done <= '0;
  end else begin
    // Defaults
    reg_ctlr_phy_if.reg_wr_done   <= '0;
    text_max_clr                  <= '0;
    cext_max_clr                  <= '0;

    if (reg_ctlr_phy_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|reg_ctlr_phy_if.reg_wr_addr[C_ADDR_WIDTH-1:6])) begin
        case (reg_ctlr_phy_if.reg_wr_addr[5:0]) inside
          // Data Hold Time - 0x00
          6'b0000??: data_hold_time    <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Start Hold Time - 0x04
          6'b0001??: start_hold_time   <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Start Setup Time - 0x08
          6'b0010??: start_setup_time  <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Stop Setup Time - 0x0C
          6'b0011??: stop_setup_time   <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Clock Low Time - 0x10
          6'b0100??: clk_tlow_time     <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Clock High Time - 0x14
          6'b0101??: clk_thigh_time    <= reg_ctlr_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Text Timeout Prescaler - 0x18
          6'b0110??: text_prescaler    <= reg_ctlr_phy_if.reg_wr_data[C_TEXT_PRESCALE_CT_WIDTH-2:0];
          // Text Timeout - 0x1C
          6'b0111??: text_timeout      <= reg_ctlr_phy_if.reg_wr_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0];
          // Text Max Count - 0x20
          6'b1000??: text_max_clr      <= '1;
          // Cext Timeout Prescaler - 0x24
          6'b1001??: cext_prescaler    <= reg_ctlr_phy_if.reg_wr_data[C_CEXT_PRESCALE_CT_WIDTH-2:0];
          // Cext Timeout - 0x28
          6'b1010??: cext_timeout      <= reg_ctlr_phy_if.reg_wr_data[C_CEXT_TIMEOUT_CT_WIDTH-1:0];
          // Cext Max Count - 0x2C
          6'b1011??: cext_max_clr      <= '1;
        endcase
      end
      // Signal write done
      reg_ctlr_phy_if.reg_wr_done <= 1'b1;
    end
  end
end

// Always respond with OKAY to writes
assign reg_ctlr_phy_if.reg_wr_resp = '0;

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_ctlr_phy_if.reg_rd_data <= '0;
  reg_ctlr_phy_if.reg_rd_done <= '0;

  if (reg_ctlr_phy_if.reg_rd_valid) begin
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_ctlr_phy_if.reg_rd_addr[C_ADDR_WIDTH-1:6])) begin
      case (reg_ctlr_phy_if.reg_rd_addr[5:0]) inside
        // Data Hold Time - 0x00
        6'b0000??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= data_hold_time;
        // Start Hold Time - 0x04
        6'b0001??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= start_hold_time;
        // Start Setup Time - 0x08
        6'b0010??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= start_setup_time;
        // Stop Setup Time - 0x0C
        6'b0011??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= stop_setup_time;
        // Clock Low Time - 0x10
        6'b0100??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= clk_tlow_time;
        // Clock High Time - 0x14
        6'b0101??: reg_ctlr_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= clk_thigh_time;
        // Text Timeout Prescaler - 0x18
        6'b0110??: reg_ctlr_phy_if.reg_rd_data[C_TEXT_PRESCALE_CT_WIDTH-2:0]  <= text_prescaler;
        // Text Timeout - 0x1C
        6'b0111??: reg_ctlr_phy_if.reg_rd_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0]   <= text_timeout;
        // Text Timeout Max Count - 0x20
        6'b1000??: reg_ctlr_phy_if.reg_rd_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0]   <= text_max_ct;
        // Cext Timeout Prescaler - 0x24
        6'b1001??: reg_ctlr_phy_if.reg_rd_data[C_CEXT_PRESCALE_CT_WIDTH-2:0]  <= cext_prescaler;
        // Cext Timeout - 0x28
        6'b1010??: reg_ctlr_phy_if.reg_rd_data[C_CEXT_TIMEOUT_CT_WIDTH-1:0]   <= cext_timeout;
        // Cext Timeout Max Count - 0x2C
        6'b1011??: reg_ctlr_phy_if.reg_rd_data[C_CEXT_TIMEOUT_CT_WIDTH-1:0]   <= cext_max_ct;
        // Debug - FSM State - 0x30
        6'b1100??: reg_ctlr_phy_if.reg_rd_data[$bits(current_st)-1:0]         <= current_st;
        default:   reg_ctlr_phy_if.reg_rd_data                                <= '0;
      endcase
    end
    // Signal read done
    reg_ctlr_phy_if.reg_rd_done <= 1'b1;
  end
end

// Always respond with OKAY to reads
assign reg_ctlr_phy_if.reg_rd_resp = '0;

endmodule : smbus_v1_1_ctlr_phy
