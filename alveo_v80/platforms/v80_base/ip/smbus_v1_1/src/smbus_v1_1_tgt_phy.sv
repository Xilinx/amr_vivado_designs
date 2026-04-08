// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Target PHY Logic
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_tgt_phy
  import smbus_v1_1_pkg::*;
#(
  parameter int C_SMBUS_DEV_CLASS = 0,
  parameter int C_FREQ_HZ_CLK     = 100000000
) (
  // Register Control Interface
  smbus_v1_1_reg_if.sub       reg_tgt_phy_if,

  // Clock & Reset
  input  logic                clk,
  input  logic                resetn,

  // Interrupts
  output tgt_phy_irq_t        tgt_phy_irq,

  // Control/Status
  input  phy_cmn_stat_t       phy_cmn_stat,
  input  tgt_ctl_t            tgt_ctl,
  output phy_cmn_ctl_t        phy_cmn_ctl,
  output tgt_phy_stat_t       tgt_phy_stat
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
localparam int  C_ADDR_WIDTH = $bits(reg_tgt_phy_if.reg_wr_addr);

// FSM state bit selects
localparam int  TG_PHY_SYNC         = 0,
                TG_PHY_IDLE         = 1,
                TG_PHY_HEADER       = 2,
                TG_PHY_WR_RESP      = 3,
                TG_PHY_WR_BYTE      = 4,
                TG_PHY_CLK_STRETCH  = 5,
                TG_PHY_RD_BYTE      = 6,
                TG_PHY_RD_RESP      = 7;

// Sized for max 500MHz clock, allows for (tSU:DAT + tR/tF) of 2.048us
localparam int  C_TIMER_CT_WIDTH          = 11;

// Sized for max 500MHz clock, allows for prescaler of 1.024us
localparam int  C_TEXT_PRESCALE_CT_WIDTH  = 10;

// Sized for 1us prescaler, allows for tLOW:TEXT of max 32.768ms to be measured
localparam int  C_TEXT_TIMEOUT_CT_WIDTH   = 15;

// Fixed latency in the Target FSM
localparam int  C_TGT_PHY_LATENCY         = 2;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// Target PHY FSM States - OneHot Encoded
typedef enum logic [7:0] {
  ST_TG_PHY_SYNC        = 1 << TG_PHY_SYNC,
  ST_TG_PHY_IDLE        = 1 << TG_PHY_IDLE,
  ST_TG_PHY_HEADER      = 1 << TG_PHY_HEADER,
  ST_TG_PHY_WR_RESP     = 1 << TG_PHY_WR_RESP,
  ST_TG_PHY_WR_BYTE     = 1 << TG_PHY_WR_BYTE,
  ST_TG_PHY_CLK_STRETCH = 1 << TG_PHY_CLK_STRETCH,
  ST_TG_PHY_RD_BYTE     = 1 << TG_PHY_RD_BYTE,
  ST_TG_PHY_RD_RESP     = 1 << TG_PHY_RD_RESP
} state_tg_phy_fsm_t;

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
state_tg_phy_fsm_t                    current_st;
state_tg_phy_fsm_t                    next_st;
logic                                 smbclk_ctl;
logic                                 smbdat_ctl;
logic                                 phy_idle;
logic [3:0]                           header_count;
logic                                 header_count_msb_d1;
logic [3:0]                           bit_count;
logic                                 bit_count_msb_d1;
logic                                 header_valid;
logic [7:0]                           header;
logic                                 rx_byte_valid;
logic [7:0]                           rx_byte;
logic [2:0]                           phase;
logic                                 timer_enable;
logic                                 timer_expired;
logic [7:0]                           tx_byte;
logic                                 phy_loa;
logic                                 rd_ack_valid;
logic                                 rd_ack;
logic                                 wr_ack;
logic                                 wr_ack_ready;
logic                                 tx_byte_ready;
logic                                 phy_error;
logic [C_TIMER_CT_WIDTH-2:0]          data_setup_time;
logic [C_TIMER_CT_WIDTH-2:0]          data_hold_time;
logic [C_TIMER_CT_WIDTH-2:0]          timer;
logic [C_TIMER_CT_WIDTH-2:0]          timer_ct;
logic [C_TIMER_CT_WIDTH-1:0]          timer_ct_nxt;
logic [C_TEXT_PRESCALE_CT_WIDTH-2:0]  text_cur_ct;
logic [C_TEXT_PRESCALE_CT_WIDTH-1:0]  text_cur_ct_nxt;
logic [C_TEXT_PRESCALE_CT_WIDTH-2:0]  text_prescaler;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_ct;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_max_ct;
logic [C_TEXT_TIMEOUT_CT_WIDTH-1:0]   text_timeout;
logic                                 text_max_clr;
logic                                 text_irq;

// ========================================================
// Target PHY FSM

// Update the current state
always_ff @(posedge clk) begin
  if (!resetn) begin
    current_st  <= ST_TG_PHY_SYNC;
  end else begin
    current_st  <= next_st;
  end
end

// Determine the next state
always_comb begin
  next_st = current_st;
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[TG_PHY_SYNC]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Wait for common PHY to signal inactive (either a STOP, Bus Idle or smbclk low timeout),
          // then move to idle state
          next_st = ST_TG_PHY_IDLE;
        end
      end
    current_st[TG_PHY_IDLE]:
      begin
        if (phy_cmn_stat.start) begin
          // Wait for a START condition, then move to header state
          next_st = ST_TG_PHY_HEADER;
        end
      end
    current_st[TG_PHY_HEADER]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs while waiting on the header byte,
          // move to idle
          next_st = ST_TG_PHY_IDLE;
        end else if (header_count[3] && phy_cmn_stat.smbclk_fe) begin
          // Once the header byte is assembled and the smbclk falling edge occurs,
          // move to clk_stretch
          next_st = ST_TG_PHY_CLK_STRETCH;
        end
      end
    current_st[TG_PHY_WR_BYTE]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs, move to idle
          next_st = ST_TG_PHY_IDLE;
        end else if (phy_cmn_stat.start) begin
          // If a START is detected then the transaction is switching into a read, move to header
          next_st = ST_TG_PHY_HEADER;
        end else if (bit_count[3] && phy_cmn_stat.smbclk_fe) begin
          // Once the write byte is assembled, wait on the smbclk falling edge for last bit,
          // move to clk_stretch
          next_st = ST_TG_PHY_CLK_STRETCH;
        end
      end
    current_st[TG_PHY_CLK_STRETCH]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs, move to idle
          next_st = ST_TG_PHY_IDLE;
        end else if (tgt_ctl.wr_ack_valid) begin
          // If write transaction and write response available then move to wr_resp
          next_st = ST_TG_PHY_WR_RESP;
        end else if (tgt_ctl.tx_byte_valid) begin
          // If read transaction and transmit byte available then move to rd_byte
          next_st = ST_TG_PHY_RD_BYTE;
        end
      end
    current_st[TG_PHY_WR_RESP]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs
          next_st = ST_TG_PHY_IDLE;
        end else if (phase[2] && phase[0] && !wr_ack) begin
          // If instructed to NACK byte, then move to SYNC and
          // wait for current transaction to finish
          next_st = ST_TG_PHY_SYNC;
        end else if (phase[2] && phase[0] && !header[0]) begin
          // ACK sent, write transaction so move to wr_byte state
          next_st = ST_TG_PHY_WR_BYTE;
        end else if (phase[2] && phase[0] && header[0]) begin
          // ACK sent, read transaction so move to clk_stretch state
          next_st = ST_TG_PHY_CLK_STRETCH;
        end
      end
    current_st[TG_PHY_RD_BYTE]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs
          next_st = ST_TG_PHY_IDLE;
        end else if (phy_loa) begin
          // Loss of arbitration during the read, move to sync state
          next_st = ST_TG_PHY_SYNC;
        end else if (phase[2] && phase[1]) begin
          // Byte transmission complete, move to rd_resp state
          next_st = ST_TG_PHY_RD_RESP;
        end
      end
    current_st[TG_PHY_RD_RESP]:
      begin
        if (phy_cmn_stat.phy_inactive) begin
          // Detect if a STOP, Bus Idle or smbclk timeout occurs, move to idle
          next_st = ST_TG_PHY_IDLE;
        end else if (rd_ack_valid && rd_ack && phy_cmn_stat.smbclk_fe) begin
          // ACK response, Controller is requesting another byte, move to clk_stretch
          next_st = ST_TG_PHY_CLK_STRETCH;
        end else if (rd_ack_valid && !rd_ack && phy_cmn_stat.smbclk_fe) begin
          // NACK response, Controller read is complete, move to sync
          next_st = ST_TG_PHY_SYNC;
        end
      end
    default: next_st = ST_TG_PHY_SYNC;
  endcase
end

// Set the Target PHY outputs based on the FSM state
always_ff @(posedge clk) begin
  // Defaults
  smbdat_ctl            <= '1;
  phy_idle              <= '0;
  header_count          <= '0;
  header_count_msb_d1   <= header_count[3];
  bit_count             <= '0;
  bit_count_msb_d1      <= bit_count[3];
  rx_byte_valid         <= '0;
  phase                 <= '0;
  timer_enable          <= '0;
  timer                 <= data_hold_time;
  phy_loa               <= '0;
  rd_ack                <= '0;
  rd_ack_valid          <= '0;
  wr_ack                <= '0;
  wr_ack_ready          <= '0;
  tx_byte_ready         <= '0;
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[TG_PHY_SYNC]:
      begin
        // State Defaults
        phy_idle        <= '1;
        header_valid    <= '0;
        header          <= '0;
        smbclk_ctl      <= '1;
      end
    current_st[TG_PHY_IDLE]:
      begin
        // State Defaults
        phy_idle        <= '1;
        header_valid    <= '0;
        header          <= '0;
        smbclk_ctl      <= '1;
        rx_byte         <= '0;
      end
    current_st[TG_PHY_HEADER]:
      begin
        // State Defaults
        header_count  <= header_count;
        header_valid  <= '0;

        // Shift in the header byte
        if (phy_cmn_stat.smbclk_re && !header_count[3]) begin
          header        <= {header[6:0],phy_cmn_stat.smbdat_latched};
          rx_byte       <= {rx_byte[6:0],phy_cmn_stat.smbdat_latched};
          header_count  <= header_count + 1'b1;
        end

        // Signal header byte valid - hold until the header state is re-entered
        if (header_count[3]) begin
          header_valid  <= '1;
        end

        // Signal the Rx byte is valid - single cycle
        if (header_count[3] && !header_count_msb_d1) begin
          rx_byte_valid <= '1;
        end
      end
    current_st[TG_PHY_WR_BYTE]:
      begin
        // State Defaults
        bit_count <= bit_count;

        // Shift in the byte
        if (phy_cmn_stat.smbclk_re && !bit_count[3]) begin
          rx_byte     <= {rx_byte[6:0],phy_cmn_stat.smbdat_latched};
          bit_count   <= bit_count + 1'b1;
        end

        // Signal byte valid for a single cycle
        if (bit_count[3] && !bit_count_msb_d1) begin
          rx_byte_valid <= '1;
        end
      end
    current_st[TG_PHY_CLK_STRETCH]:
      begin
        // State Defaults
        smbdat_ctl <= smbdat_ctl;

        if (tgt_ctl.tx_byte_valid) begin
          tx_byte <= tgt_ctl.tx_byte;
        end

        if (!tgt_ctl.wr_ack_valid && !tgt_ctl.tx_byte_valid) begin
          // If no response is available yet, then start stretching smbclk
          smbclk_ctl    <= '0;
          // If clock stretching has started, then start the data hold time timer early
          timer_enable  <= '1;
        end

      end
    current_st[TG_PHY_WR_RESP]:
      begin
        // State Defaults
        phase           <= phase;
        smbdat_ctl      <= smbdat_ctl;
        smbclk_ctl      <= smbclk_ctl;
        timer_enable    <= timer_enable;
        timer           <= timer;
        wr_ack          <= wr_ack;

        // Wait for the data hold time (tHD:DAT) to be met before changing smbdat
        if (phase == 3'b000) begin
          timer_enable  <= '1;

          if (timer_expired) begin
            // Once data hold time met, disable timer and configure timer for setup time
            timer_enable  <= '0;
            timer         <= data_setup_time;
            phase         <= phase + 1'b1;
          end
        end

        // Output the ACK/NACK response on smbdat
        if (phase == 3'b001) begin
          smbdat_ctl    <= ~tgt_ctl.wr_ack;
          wr_ack        <= tgt_ctl.wr_ack;
          wr_ack_ready  <= '1;

          if (!smbclk_ctl) begin
            // If clock stretching is active,
            // then wait until (tSU:DAT + tF/tR) time on smbdat is met before releasing smbclk
            timer_enable  <= '1;
            phase         <= phase + 1'b1;
          end else begin
            // Skip to waiting for next smbclk rising edge
            phase         <= phase + 2'h2;
          end
        end

        // Once the data setup timer expires, then release smbclk high-z
        if (phase == 3'b010 && timer_expired) begin
          smbclk_ctl  <= '1;
          phase       <= phase + 1'b1;
        end

        // Wait for the next smbclk rising edge
        if (phase == 3'b011 && phy_cmn_stat.smbclk_re) begin
          phase       <= phase + 1'b1;
        end

        // Wait for the next smbclk falling edge
        if (phase == 3'b100 && phy_cmn_stat.smbclk_fe) begin
          if (wr_ack) begin
            // Release smbdat high-z if a write, else hold smbdat to prevent a glitch if read
            smbdat_ctl  <= header[0] ? '0 : '1;
          end
          phase       <= phase + 1'b1;
        end
      end
    current_st[TG_PHY_RD_BYTE]:
      begin
        // State Defaults
        bit_count       <= bit_count;
        phase           <= phase;
        timer_enable    <= timer_enable;
        timer           <= timer;
        smbdat_ctl      <= tx_byte[7];
        tx_byte_ready   <= '1;

        // Wait for the data hold time (tHD:DAT) to be met before changing smbdat
        if (phase == 3'b000) begin
          timer_enable  <= '1;
          smbdat_ctl    <= smbdat_ctl;

          if (timer_expired) begin
            // Once data hold time met, disable timer and configure timer for setup time
            timer_enable  <= '0;
            timer         <= data_setup_time;
            phase         <= phase + 1'b1;
          end
        end

        // Ensure data setup time is met before releasing smbclk high-z
        if (phase == 3'b001) begin
          if (!smbclk_ctl) begin
            // If clock stretching is active,
            // then wait until (tSU:DAT + tF/tR) time on smbdat is met before releasing smbclk
            // This ensures the setup time is met for the MSB,
            // subsequent bits are then transmitted without clock stretching
            timer_enable  <= '1;
            phase         <= phase + 1'b1;
          end else begin
            // Skip to waiting for next smbclk rising edge
            phase         <= phase + 2'h2;
            timer         <= data_hold_time;
          end
        end

        // Once the data setup timer expires, then release smbclk high-z
        if (phase == 3'b010 && timer_expired) begin
          smbclk_ctl    <= '1;
          timer_enable  <= '0;
          timer         <= data_hold_time;
          phase         <= phase + 1'b1;
        end

        // Wait for the next smbclk rising edge, check for LOA
        if (phase == 3'b011 && phy_cmn_stat.smbclk_re) begin
          if (phy_cmn_stat.smbdat_latched != tx_byte[7]) begin
            // Detect target loss of arbitration for transmit data
            phy_loa <= '1;
          end
          phase       <= phase + 1'b1;
          bit_count   <= bit_count + 1'b1;
        end

        // Wait for the smbclk falling edge, start data hold timer (tHD:DAT)
        if (phase == 3'b100 && phy_cmn_stat.smbclk_fe) begin
          timer_enable  <= '1;
          phase         <= phase + 1'b1;
        end

        // Update the transmit bit and count on next smbclk falling edge
        if (phase == 3'b101 && timer_expired) begin
          if (!bit_count[3]) begin
            // Byte transmission not complete, update the tx bit and move the phase back
            tx_byte   <= {tx_byte[6:0],1'b1};
            phase     <= phase - 2'h2;
          end else begin
            // Byte transmission complete, move to end phase
            phase     <= phase + 1'b1;
          end
          timer_enable  <= '0;
        end
      end
    current_st[TG_PHY_RD_RESP]:
      begin
        // State Defaults
        rd_ack_valid  <= rd_ack_valid;
        rd_ack        <= rd_ack;

        // Sample the read response on next rising edge
        if (phy_cmn_stat.smbclk_re) begin
          rd_ack        <= ~phy_cmn_stat.smbdat_latched;
          rd_ack_valid  <= '1;
        end
      end
  endcase
end

// ========================================================
// Flag if the reason for the PHY going Idle is due to an error
// The target logic requires this to differentiate between good/bad end of transaction

always_ff @(posedge clk) begin
  if (!resetn) begin
    phy_error  <= '0;
  end else begin
    if (!phy_idle) begin
      // Update the error status until the PHY goes Idle, then hold
      phy_error <= phy_loa | phy_cmn_stat.unexpected_bus_idle | phy_cmn_stat.smbclk_timeout;
    end
  end
end

// ========================================================

// Event Timer - Flag when the data setup time has been met while clock stretching
always_ff @(posedge clk) begin
  if (!resetn) begin
    timer_ct        <= timer;
    timer_expired   <= '0;
  end else begin
    if (!timer_enable) begin
      // Reload the timer with the data setup count
      timer_ct      <= timer;
      timer_expired <= '0;
    end else if (timer_ct_nxt[C_TIMER_CT_WIDTH-1]) begin
      // On count underrun, flag timer expired
      timer_expired <= '1;
    end else begin
      // Count while the timer is enabled
      timer_ct <= timer_ct_nxt[C_TIMER_CT_WIDTH-2:0];
    end
  end
end

// Assign the next count
assign timer_ct_nxt = timer_ct - 1'b1;

// ========================================================
// Measure the Target tLOW:TEXT timeout from the Target perspective
// Implements a high-tide marker for amount of clock stretching introduced by the target PHY and
// raises an interrupt if the configured threshold is reached.
// A breach of this limit has no consequent action locally within the IP,
// but the Controller may decide to abort if it is breached.

always_ff @(posedge clk) begin
  if (!resetn) begin
    text_cur_ct   <= '0;
    text_ct       <= '0;
    text_max_ct   <= '0;
    text_irq      <= '0;
  end else begin
    // Defaults
    text_irq  <= '0;

    if (!phy_cmn_stat.bus_active) begin
      // When no transaction is in progress, then reset the counts
      text_cur_ct <= text_prescaler;
      text_ct     <= '0;
    end else begin
      if (!smbclk_ctl) begin
        // When clock stretching is active, update the prescaler and timeout counts
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

// Target PHY Status interface
assign tgt_phy_stat.header_valid  = header_valid;
assign tgt_phy_stat.header        = header;
assign tgt_phy_stat.rx_byte_valid = rx_byte_valid;
assign tgt_phy_stat.rx_byte       = rx_byte;
assign tgt_phy_stat.phy_idle      = phy_idle;
assign tgt_phy_stat.rd_ack_valid  = rd_ack_valid;
assign tgt_phy_stat.rd_ack        = rd_ack;
assign tgt_phy_stat.wr_ack_ready  = wr_ack_ready;
assign tgt_phy_stat.tx_byte_ready = tx_byte_ready;
assign tgt_phy_stat.phy_error     = phy_error;

// PHY Common Control interface
assign phy_cmn_ctl.smbclk_ctl     = smbclk_ctl;
assign phy_cmn_ctl.smbdat_ctl     = smbdat_ctl;

// Target PHY Interrupt interface
assign tgt_phy_irq.loa            = phy_loa;
assign tgt_phy_irq.text_timeout   = text_irq;

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    data_setup_time             <= (C_TIMER_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TSU_DAT_MIN[C_SMBUS_DEV_CLASS], 1'b1));
    text_prescaler              <= (C_TEXT_PRESCALE_CT_WIDTH-1)'
        (fn_default_count(C_FREQ_HZ_CLK, C_TEXT_TIMEOUT_PRESCALER[C_SMBUS_DEV_CLASS], 1'b1));
    text_timeout                <= (C_TEXT_TIMEOUT_CT_WIDTH)'
        (fn_default_count(C_TEXT_TIMEOUT_PRESCALER_FREQ_HZ, C_TEXT_TIMEOUT_MAX[C_SMBUS_DEV_CLASS],
        1'b1) + 1'b1);
    text_max_clr                <= '0;
    reg_tgt_phy_if.reg_wr_done  <= '0;
    // Device Class 0 requires a non-zero hold time to provide SMBus 2.0 backwards compatibility
    if (C_SMBUS_DEV_CLASS == 0) begin : device_class_0
      // Default accounts for fixed latency
      data_hold_time              <= (C_TIMER_CT_WIDTH-1)'
          (fn_default_count(C_FREQ_HZ_CLK, C_THD_DAT_MIN[C_SMBUS_DEV_CLASS], 1'b1)
          - phy_cmn_stat.default_input_lat - C_TGT_PHY_LATENCY);
    end else begin : device_class_1_2
      // Zero hold time, don't account for fixed latency which would result in a negative hold time
      data_hold_time              <= (C_TIMER_CT_WIDTH-1)'
          (fn_default_count(C_FREQ_HZ_CLK, C_THD_DAT_MIN[C_SMBUS_DEV_CLASS], 1'b1));
    end
  end else begin
    // Defaults
    reg_tgt_phy_if.reg_wr_done  <= '0;
    text_max_clr                <= '0;

    if (reg_tgt_phy_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|reg_tgt_phy_if.reg_wr_addr[C_ADDR_WIDTH-1:5])) begin
        case (reg_tgt_phy_if.reg_wr_addr[4:0]) inside
          // Target PHY Data Setup - 0x00
          5'b000??: data_setup_time  <= reg_tgt_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
          // Target PHY Text Timeout Prescaler - 0x04
          5'b001??: text_prescaler   <= reg_tgt_phy_if.reg_wr_data[C_TEXT_PRESCALE_CT_WIDTH-2:0];
          // Target PHY Text Timeout - 0x08
          5'b010??: text_timeout     <= reg_tgt_phy_if.reg_wr_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0];
          // Target PHY Text Max Count - 0x0C
          5'b011??: text_max_clr     <= '1;
          // Target PHY Data Hold - 0x14
          5'b101??: data_hold_time   <= reg_tgt_phy_if.reg_wr_data[C_TIMER_CT_WIDTH-2:0];
        endcase
      end
      // Signal write done
      reg_tgt_phy_if.reg_wr_done <= '1;
    end
  end
end

// Always respond with OKAY to writes
assign reg_tgt_phy_if.reg_wr_resp = '0;

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_tgt_phy_if.reg_rd_data <= '0;
  reg_tgt_phy_if.reg_rd_done <= '0;

  if (reg_tgt_phy_if.reg_rd_valid) begin
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_tgt_phy_if.reg_rd_addr[C_ADDR_WIDTH-1:5])) begin
      case (reg_tgt_phy_if.reg_rd_addr[4:0]) inside
        // Target PHY Data Setup - 0x00
        5'b000??: reg_tgt_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= data_setup_time;
        // Target PHY Text Timeout Prescaler - 0x04
        5'b001??: reg_tgt_phy_if.reg_rd_data[C_TEXT_PRESCALE_CT_WIDTH-2:0]  <= text_prescaler;
        // Target PHY Text Timeout - 0x08
        5'b010??: reg_tgt_phy_if.reg_rd_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0]   <= text_timeout;
        // Target PHY Text Timeout Max Count - 0x0C
        5'b011??: reg_tgt_phy_if.reg_rd_data[C_TEXT_TIMEOUT_CT_WIDTH-1:0]   <= text_max_ct;
        // Target PHY Debug State - 0x10
        5'b100??: reg_tgt_phy_if.reg_rd_data[0+:$bits(current_st)]          <= current_st;
        // Target PHY Data Hold - 0x14
        5'b101??: reg_tgt_phy_if.reg_rd_data[C_TIMER_CT_WIDTH-2:0]          <= data_hold_time;
        default:  reg_tgt_phy_if.reg_rd_data                                <= '0;
      endcase
    end
    // Signal read done
    reg_tgt_phy_if.reg_rd_done <= '1;
  end
end

// Always respond with OKAY to reads
assign reg_tgt_phy_if.reg_rd_resp = '0;

endmodule : smbus_v1_1_tgt_phy
