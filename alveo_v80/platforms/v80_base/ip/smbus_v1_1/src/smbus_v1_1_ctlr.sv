// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Controller Logic
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_ctlr
  import smbus_v1_1_pkg::*;
(
  // Register Control Interface
  smbus_v1_1_reg_if.sub       reg_ctlr_if,

  // Clock & Reset
  input  logic                clk,
  input  logic                resetn,

  // Interrupts
  output ctlr_irq_t           ctlr_irq,

  // Control/Status
  input  ctlr_phy_stat_t      ctlr_phy_stat,
  output ctlr_ctl_t           ctlr_ctl
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
localparam int C_ADDR_WIDTH                   = $bits(reg_ctlr_if.reg_wr_addr);
localparam int C_DESC_FIFO_DATA_WIDTH         = 12;
localparam int C_DESC_FIFO_DEPTH              = 64;
localparam int C_DESC_FIFO_FILL_WIDTH         = $clog2(C_DESC_FIFO_DEPTH) + 1;
localparam int C_RX_FIFO_DATA_WIDTH           = 8;
localparam int C_RX_FIFO_DEPTH                = 64;
localparam int C_RX_FIFO_FILL_WIDTH           = $clog2(C_RX_FIFO_DEPTH) + 1;
localparam int C_RX_FIFO_FILL_THRESH_DEFAULT  = 1;

// FSM state bit selects
localparam int  CT_SEQ_IDLE           = 0,
                CT_SEQ_DESC_FETCH     = 1,
                CT_SEQ_HEADER         = 2,
                CT_SEQ_WR_BYTE        = 3,
                CT_SEQ_WAIT_ON_RD     = 4,
                CT_SEQ_RD_RESP        = 5,
                CT_SEQ_STOP           = 6,
                CT_SEQ_WAIT_PHY_IDLE  = 7,
                CT_SEQ_CTLR_DISABLE   = 8;

// Read/Write Descriptor IDs
localparam bit [2:0]  DESC_START   = 3'b000,
                      DESC_QUICK   = 3'b001,
                      DESC_BYTE    = 3'b010,
                      DESC_STOP    = 3'b011,
                      DESC_PEC     = 3'b100;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// Controller Sequence FSM States - OneHot Encoded
typedef enum logic [8:0] {
  ST_CT_SEQ_IDLE          = 1 << CT_SEQ_IDLE,
  ST_CT_SEQ_DESC_FETCH    = 1 << CT_SEQ_DESC_FETCH,
  ST_CT_SEQ_HEADER        = 1 << CT_SEQ_HEADER,
  ST_CT_SEQ_WR_BYTE       = 1 << CT_SEQ_WR_BYTE,
  ST_CT_SEQ_WAIT_ON_RD    = 1 << CT_SEQ_WAIT_ON_RD,
  ST_CT_SEQ_RD_RESP       = 1 << CT_SEQ_RD_RESP,
  ST_CT_SEQ_STOP          = 1 << CT_SEQ_STOP,
  ST_CT_SEQ_WAIT_PHY_IDLE = 1 << CT_SEQ_WAIT_PHY_IDLE,
  ST_CT_SEQ_CTLR_DISABLE  = 1 << CT_SEQ_CTLR_DISABLE
} state_ct_seq_fsm_t;

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
state_ct_seq_fsm_t                      current_st;
state_ct_seq_fsm_t                      next_st;

logic [C_DESC_FIFO_DATA_WIDTH-1:0]      desc_fifo_wr_data;
logic                                   desc_fifo_wr_en;
logic                                   desc_fifo_wr_en_d1;
logic                                   desc_fifo_wr_reset;
logic [C_DESC_FIFO_FILL_WIDTH-1:0]      desc_fifo_fill_level;
logic                                   desc_fifo_overflow;
logic                                   desc_fifo_almost_full;
logic                                   desc_fifo_full;
logic [C_DESC_FIFO_DATA_WIDTH-1:0]      desc_fifo_rd_data;
logic                                   desc_fifo_rd_data_valid;
logic                                   desc_fifo_rd_en;
logic                                   desc_fifo_underflow;
logic                                   desc_fifo_almost_empty;
logic                                   desc_fifo_empty;
logic                                   desc_fifo_reset_busy;

logic [C_RX_FIFO_DATA_WIDTH-1:0]        rx_fifo_wr_data;
logic                                   rx_fifo_wr_en;
logic [C_RX_FIFO_FILL_WIDTH-1:0]        rx_fifo_fill_level;
logic [C_RX_FIFO_FILL_WIDTH-1:0]        rx_fifo_max_fill;
logic                                   rx_fifo_max_fill_clr;
logic                                   rx_fifo_overflow;
logic                                   rx_fifo_almost_full;
logic                                   rx_fifo_full;
logic [C_RX_FIFO_DATA_WIDTH-1:0]        rx_fifo_rd_data;
logic                                   rx_fifo_rd_data_valid;
logic                                   rx_fifo_rd_en;
logic                                   rx_fifo_rd_reset;
logic                                   rx_fifo_underflow;
logic                                   rx_fifo_almost_empty;
logic                                   rx_fifo_empty;
logic                                   rx_fifo_reset_busy;
logic [C_RX_FIFO_FILL_WIDTH-1:0]        rx_fifo_fill_thresh;
logic                                   rx_fifo_fill_thresh_irq;

logic [7:0]                             pec;
logic                                   pec_error;

logic                                   ctlr_enable;
logic                                   ctlr_disable;
logic                                   ctlr_active;
logic                                   desc_fifo_empty_irq;
logic                                   desc_fifo_almost_empty_irq;
logic                                   desc_fifo_error_irq;
logic                                   desc_valid;
logic [3:0]                             desc_id;
logic                                   desc_error_irq;
logic                                   fifo_rd_pending;
logic                                   start_stop;
logic                                   start_stop_valid;
logic                                   read_write;
logic                                   tx_byte_valid;
logic                                   tx_byte_valid_pec;
logic [7:0]                             tx_byte;
logic                                   rx_fifo_wr_error;
logic                                   rx_fifo_wr_error_d1;
logic                                   rx_fifo_rd_error;
logic                                   rx_fifo_error_irq;
logic                                   rx_byte_valid;
logic                                   rd_ack;
logic                                   rd_ack_valid;
logic                                   pec_error_irq;
logic                                   force_pec_error;
logic                                   ctlr_done_irq;
logic                                   ctlr_en;
logic                                   quick_cmd;

// ========================================================
// Controller Sequence FSM

// Update the current state
always_ff @(posedge clk) begin
  if (!resetn) begin
    current_st  <= ST_CT_SEQ_IDLE;
  end else begin
    current_st  <= next_st;
  end
end

// Determine the next state
always_comb begin
  next_st = current_st;
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[CT_SEQ_IDLE]:
      begin
        if (ctlr_enable) begin
          // Wait for Controller to be enabled, then move to descriptor fetch state
          next_st = ST_CT_SEQ_DESC_FETCH;
        end
      end
    current_st[CT_SEQ_DESC_FETCH]:
      begin
        if (ctlr_disable) begin
          // Controller has been disabled, move to idle state
          next_st = ST_CT_SEQ_IDLE;
        end else if (ctlr_phy_stat.phy_error) begin
          // PHY has encountered an error, move to wait for phy idle state
          next_st = ST_CT_SEQ_WAIT_PHY_IDLE;
        end else if (desc_valid) begin
          if (desc_id[2:0] == DESC_START || desc_id[2:0] == DESC_QUICK) begin
            // Start or Quick Descriptor command, move to header state
            next_st = ST_CT_SEQ_HEADER;
          end else if (desc_id[3]) begin
            // Read - Byte, Stop or PEC Descriptor command, move to read response state
            next_st = ST_CT_SEQ_RD_RESP;
          end else if (!desc_id[3]) begin
            // Write - Byte, Stop or PEC Descriptor command, move to write byte state
            next_st = ST_CT_SEQ_WR_BYTE;
          end
        end
      end
    current_st[CT_SEQ_HEADER]:
      begin
        if (ctlr_phy_stat.phy_error) begin
          // PHY has encountered an error, move to wait for phy idle state
          next_st = ST_CT_SEQ_WAIT_PHY_IDLE;
        end else if (ctlr_phy_stat.wr_ack_valid && ctlr_phy_stat.wr_ack) begin
          // ACK received from Target
          if (desc_id[2:0] == DESC_QUICK) begin
            // Quick command, move to stop state
            next_st = ST_CT_SEQ_STOP;
          end else if (desc_id[3]) begin
            // Read transaction, move to wait on read state
            next_st = ST_CT_SEQ_WAIT_ON_RD;
          end else begin
            // Write transaction, move to descriptor fetch state
            next_st = ST_CT_SEQ_DESC_FETCH;
          end
        end
      end
    current_st[CT_SEQ_WR_BYTE]:
      begin
        if (ctlr_phy_stat.phy_error) begin
          // PHY has encountered an error, move to wait for phy idle state
          next_st = ST_CT_SEQ_WAIT_PHY_IDLE;
        end else if (ctlr_phy_stat.wr_ack_valid && ctlr_phy_stat.wr_ack) begin
          // ACK received from Target
          if (desc_id[2:0] inside {DESC_STOP,DESC_PEC}) begin
            // Stop/PEC descriptor, move to stop state
            next_st = ST_CT_SEQ_STOP;
          end else begin
            // Byte written so next descriptor required, move to descriptor fetch state
            next_st = ST_CT_SEQ_DESC_FETCH;
          end
        end
      end
    current_st[CT_SEQ_WAIT_ON_RD]:
      begin
        if (ctlr_phy_stat.phy_error) begin
          // PHY has encountered an error, move to wait for phy idle state
          next_st = ST_CT_SEQ_WAIT_PHY_IDLE;
        end else if (rx_byte_valid) begin
          // Read byte received, move to descriptor fetch
          next_st = ST_CT_SEQ_DESC_FETCH;
        end
      end
    current_st[CT_SEQ_RD_RESP]:
      begin
        if (ctlr_phy_stat.phy_error) begin
          // PHY has encountered an error, move to wait for phy idle state
          next_st = ST_CT_SEQ_WAIT_PHY_IDLE;
        end else if (ctlr_phy_stat.phy_idle) begin
          // PHY has completed transmission and gone idle, move to controller disable state
          next_st = ST_CT_SEQ_CTLR_DISABLE;
        end else if (ctlr_phy_stat.rd_ack_ready && rd_ack) begin
          // PHY has started to transmit the ACK for the read byte, move to wait on read state
          next_st = ST_CT_SEQ_WAIT_ON_RD;
        end
      end
    current_st[CT_SEQ_STOP]:
      begin
        if (ctlr_phy_stat.phy_idle) begin
          // PHY has gone idle, move to controller disable state
          next_st = ST_CT_SEQ_CTLR_DISABLE;
        end
      end
    current_st[CT_SEQ_WAIT_PHY_IDLE]:
      begin
        if (ctlr_phy_stat.phy_idle) begin
          // PHY has gone idle, move to controller disable state
          next_st = ST_CT_SEQ_CTLR_DISABLE;
        end
      end
    current_st[CT_SEQ_CTLR_DISABLE]:
      begin
        if (ctlr_disable) begin
          // Controller has been disabled, move to idle state
          next_st = ST_CT_SEQ_IDLE;
        end
      end
    default: next_st = ST_CT_SEQ_IDLE;
  endcase
end

// Set the Controller outputs based on the Sequence FSM state
always_ff @(posedge clk) begin
  // Defaults
  desc_fifo_empty_irq         <= '0;
  desc_fifo_almost_empty_irq  <= '0;
  desc_fifo_rd_en             <= '0;
  desc_valid                  <= '0;
  desc_error_irq              <= '0;
  fifo_rd_pending             <= '0;
  start_stop_valid            <= '0;
  tx_byte_valid               <= '0;
  tx_byte_valid_pec           <= '0;
  ctlr_disable                <= '0;
  rx_fifo_wr_en               <= '0;
  rx_fifo_wr_error_d1         <= rx_fifo_wr_error;
  rx_byte_valid               <= '0;
  pec_error_irq               <= '0;
  ctlr_done_irq               <= '0;
  rd_ack_valid                <= '0;

  // Detect an overflow of the Rx FIFO, hold the error until it can be checked in subsequent state
  if (rx_fifo_overflow) begin
    rx_fifo_wr_error  <= '1;
  end

  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[CT_SEQ_IDLE]:
      begin
        // State Defaults
        ctlr_active       <= '0;
        rx_fifo_wr_error  <= '0;
        quick_cmd         <= '0;
      end
    current_st[CT_SEQ_DESC_FETCH]:
      begin
        // State Defaults
        fifo_rd_pending <= fifo_rd_pending;

        if ((desc_fifo_empty || desc_fifo_wr_reset || desc_fifo_reset_busy) && !fifo_rd_pending) begin
          // Descriptor FIFO is empty or in reset and a descriptor is required, raise interrupt
          desc_fifo_empty_irq <= '1;
        end else if (!fifo_rd_pending) begin
          // Descriptor available, no read pending so read from the FIFO
          desc_fifo_rd_en   <= '1;
          fifo_rd_pending   <= '1;
        end

        if (desc_fifo_almost_empty && !fifo_rd_pending) begin
          // Raise interrupt if the FIFO is almost empty before the read is initiated
          desc_fifo_almost_empty_irq  <= '1;
        end

        if (desc_fifo_rd_data_valid) begin
          // Update the descriptor ID returned from the FIFO
          desc_valid    <= '1;
          desc_id       <= desc_fifo_rd_data[11:8];

          if (!ctlr_active && !(desc_fifo_rd_data[10:8] inside {DESC_START,DESC_QUICK})) begin
            // Controller is not currently active and descriptor is not for Start/Quick,
            // raise descriptor error interrupt and disable the Controller
            desc_error_irq  <= '1;
            ctlr_disable    <= '1;
          end else if (desc_fifo_rd_data[10:8] inside {3'b101,3'b110,3'b111}) begin
            // Invalid descriptor ID, raise the descriptor error interrupt
            desc_error_irq  <= '1;
            if (ctlr_active) begin
              // If the Controller has already started a transaction i.e. START + Header sent,
              // then initiate a STOP to cleanly terminate the transaction
              if (read_write) begin
                desc_id <= {1'b1,DESC_STOP};
              end else begin
                desc_id <= {1'b0,DESC_STOP};
              end
            end
          end
        end
      end
    current_st[CT_SEQ_HEADER]:
      begin
        // Instruct the PHY to send the (REPEATED-)START and header byte
        start_stop        <= '1;
        start_stop_valid  <= '1;
        tx_byte           <= desc_fifo_rd_data[7:0];
        tx_byte_valid     <= '1;

        // Single cycle valid to the PEC
        if (!tx_byte_valid) begin
          tx_byte_valid_pec <= '1;
        end

        if (desc_id[2:0] == DESC_QUICK) begin
          quick_cmd <= '1;
        end

        // Flag the controller as active, store whether this transaction is a read or write
        ctlr_active       <= '1;
        read_write        <= desc_fifo_rd_data[0];
      end
    current_st[CT_SEQ_WR_BYTE]:
      begin
        // Send the next byte for write transmission to the PHY
        tx_byte_valid <= '1;

        // Single cycle valid to the PEC, unless it is a PEC descriptor
        if (!tx_byte_valid && desc_id[2:0] != DESC_PEC) begin
          tx_byte_valid_pec <= '1;
        end

        if (desc_id[2:0] inside {DESC_BYTE,DESC_STOP}) begin
          // For byte/stop descriptors, send the payload to the PHY
          tx_byte <= desc_fifo_rd_data[7:0];
        end else begin
          // For PEC descriptor, send the calculated PEC
          // If force PEC error is enabled then corrupt the PEC
          tx_byte <= force_pec_error ? ~pec : pec;
        end
      end
    current_st[CT_SEQ_WAIT_ON_RD]:
      begin
        // Wait for the PHY to signal a valid read byte
        if (ctlr_phy_stat.rx_byte_valid) begin
          // Write the received byte into the Rx FIFO if it is not in reset
          rx_byte_valid     <= '1;
          rx_fifo_wr_data   <= ctlr_phy_stat.rx_byte;
          rx_fifo_wr_en     <= ~rx_fifo_rd_reset & ~rx_fifo_reset_busy;
          // Flag that the write has failed due to FIFO reset
          rx_fifo_wr_error  <= rx_fifo_rd_reset | rx_fifo_reset_busy;
        end
      end
    current_st[CT_SEQ_RD_RESP]:
      begin
        // Instruct the PHY to transmit either an ACK or NACK response for the read byte
        rd_ack_valid  <= '1;
        if (rx_fifo_wr_error) begin
          // Failed to write the last received byte into the Rx FIFO,
          // instruct PHY to NACK the read byte
          rd_ack  <= '0;
        end else if (desc_id[2:0] == DESC_BYTE) begin
          // Instruct the PHY to ACK the received read byte
          rd_ack  <= '1;
        end else if (desc_id[2:0] inside {DESC_STOP,DESC_PEC}) begin
          // Final byte recevied, instruct PHY to NACK the read byte
          rd_ack  <= '0;
        end
      end
    current_st[CT_SEQ_STOP]:
      begin
        // Instruct the PHY to send the STOP condition
        start_stop        <= '0;
        start_stop_valid  <= '1;
      end
    current_st[CT_SEQ_WAIT_PHY_IDLE]: ;
      // Default outputs clear the control signals, just wait in this state until phy idle
    current_st[CT_SEQ_CTLR_DISABLE]:
      begin
        // Disable the Controller
        ctlr_disable  <= '1;
        if (desc_id[3] && desc_id[2:0] == DESC_PEC && (pec_error || force_pec_error)) begin
          // Check the Read PEC error status, raise the pec error interrupt if set
          pec_error_irq <= '1;
        end else begin
          // Raise the done interrupt if the PHY hasn't reported an error
          ctlr_done_irq <= ~ctlr_phy_stat.phy_error;
        end
      end
  endcase
end

// ========================================================
// Controller Enable

always_ff @(posedge clk) begin
  if (!resetn) begin
    ctlr_enable <= '0;
  end else begin
    if (ctlr_disable) begin
      // Disable the controller when signalled by the FSM
      ctlr_enable <= '0;
    end else if (ctlr_en) begin
      // Enable the controller when control register is set
      ctlr_enable <= '1;
    end
  end
end

// ========================================================
// Controller Receive FIFO Fill Threshold Interrupt / Max Fill Level

always_ff @(posedge clk) begin
  if (!resetn) begin
    rx_fifo_fill_thresh_irq  <= '0;
    rx_fifo_max_fill         <= '0;
  end else begin
    //Default
    rx_fifo_fill_thresh_irq  <= '0;

    // Assert the interrupt if fifo fill level is >= to the configured fill threshold
    if (rx_fifo_fill_level >= rx_fifo_fill_thresh) begin
      rx_fifo_fill_thresh_irq <= '1;
    end

    // Clear/update the max fill level observed by the Rx FIFO
    if (rx_fifo_max_fill_clr) begin
      rx_fifo_max_fill  <= '0;
    end else if (rx_fifo_fill_level > rx_fifo_max_fill) begin
      rx_fifo_max_fill  <= rx_fifo_fill_level;
    end
  end
end

// Controller Receive FIFO Error Interrupt
// Asserted when either a read or write to the FIFO is attempted while it is in reset
always_ff @(posedge clk) begin
  if (!resetn) begin
    rx_fifo_error_irq <= '0;
  end else begin
    // Raise interrupt on rising edge of write error (as it is latched) or read error (single cycle)
    rx_fifo_error_irq <= (rx_fifo_wr_error & ~rx_fifo_wr_error_d1) | rx_fifo_rd_error;
  end
end

// ========================================================
// Controller Descriptor FIFO Instantiation
// Store the control descriptors written by software until required

smbus_v1_1_fifo #(
  .C_FIFO_DEPTH(C_DESC_FIFO_DEPTH),
  .C_DATA_WIDTH(C_DESC_FIFO_DATA_WIDTH)
) ctlr_desc_fifo_inst (
  .clk,
  .resetn,
  // FIFO Status
  .fifo_reset_busy(desc_fifo_reset_busy),
  .fifo_fill_level(desc_fifo_fill_level),
  .fifo_full(desc_fifo_full),
  .fifo_almost_full(desc_fifo_almost_full),
  .fifo_overflow(desc_fifo_overflow),
  .fifo_empty(desc_fifo_empty),
  .fifo_almost_empty(desc_fifo_almost_empty),
  .fifo_underflow(desc_fifo_underflow),
  // FIFO Write Domain
  .fifo_wr_data(desc_fifo_wr_data),
  .fifo_wr_en(desc_fifo_wr_en),
  .fifo_wr_reset(desc_fifo_wr_reset),
  // FIFO Read Domain
  .fifo_rd_data(desc_fifo_rd_data),
  .fifo_rd_data_valid(desc_fifo_rd_data_valid),
  .fifo_rd_en(desc_fifo_rd_en),
  .fifo_rd_reset(1'b0)
);

// ========================================================
// Controller Receive FIFO Instantiation
// Store the bytes recevied during a read transaction until they can be read by s/w

smbus_v1_1_fifo #(
  .C_FIFO_DEPTH(C_RX_FIFO_DEPTH),
  .C_DATA_WIDTH(C_RX_FIFO_DATA_WIDTH)
) ctlr_rx_fifo_inst (
  .clk,
  .resetn,
  // FIFO Status
  .fifo_reset_busy(rx_fifo_reset_busy),
  .fifo_fill_level(rx_fifo_fill_level),
  .fifo_full(rx_fifo_full),
  .fifo_almost_full(rx_fifo_almost_full),
  .fifo_overflow(rx_fifo_overflow),
  .fifo_empty(rx_fifo_empty),
  .fifo_almost_empty(rx_fifo_almost_empty),
  .fifo_underflow(rx_fifo_underflow),
  // FIFO Write Domain
  .fifo_wr_data(rx_fifo_wr_data),
  .fifo_wr_en(rx_fifo_wr_en),
  .fifo_wr_reset(1'b0),
  // FIFO Read Domain
  .fifo_rd_data(rx_fifo_rd_data),
  .fifo_rd_data_valid(rx_fifo_rd_data_valid),
  .fifo_rd_en(rx_fifo_rd_en),
  .fifo_rd_reset(rx_fifo_rd_reset)
);

// ========================================================
// Controller Packet Error Correction (PEC) Instantiation
// Perform the PEC CRC calculation and checking on the stream of bytes within a packet

smbus_v1_1_pec ctlr_pec_inst (
  .clk,
  .resetn,
  .pec_reset(ctlr_disable),
  .tx_data(tx_byte),
  .tx_data_valid(tx_byte_valid_pec),
  .rx_data(ctlr_phy_stat.rx_byte),
  .rx_data_valid(ctlr_phy_stat.rx_byte_valid),
  .pec,
  .pec_error
);

// ========================================================
// Assign the outputs

// Control interface to PHY
assign ctlr_ctl.start_stop        = start_stop;
assign ctlr_ctl.start_stop_valid  = start_stop_valid;
assign ctlr_ctl.rd_ack_valid      = rd_ack_valid;
assign ctlr_ctl.rd_ack            = rd_ack;
assign ctlr_ctl.tx_byte_valid     = tx_byte_valid;
assign ctlr_ctl.tx_byte           = tx_byte;
assign ctlr_ctl.quick_cmd         = quick_cmd;
assign ctlr_ctl.disabled          = ctlr_disable;

// Interrupt interface
assign ctlr_irq.done                    = ctlr_done_irq;
assign ctlr_irq.pec_error               = pec_error_irq;
assign ctlr_irq.desc_error              = desc_error_irq;
assign ctlr_irq.desc_fifo_error         = desc_fifo_error_irq;
assign ctlr_irq.desc_fifo_empty         = desc_fifo_empty_irq;
assign ctlr_irq.desc_fifo_almost_empty  = desc_fifo_almost_empty_irq;
assign ctlr_irq.desc_fifo_underflow     = desc_fifo_underflow;
assign ctlr_irq.desc_fifo_overflow      = desc_fifo_overflow;
assign ctlr_irq.rx_fifo_fill_threshold  = rx_fifo_fill_thresh_irq;
assign ctlr_irq.rx_fifo_underflow       = rx_fifo_underflow;
assign ctlr_irq.rx_fifo_overflow        = rx_fifo_overflow;
assign ctlr_irq.rx_fifo_error           = rx_fifo_error_irq;

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    ctlr_en                  <= '0;
    desc_fifo_wr_reset       <= '0;
    desc_fifo_wr_en          <= '0;
    desc_fifo_wr_en_d1       <= '0;
    desc_fifo_error_irq      <= '0;
    rx_fifo_rd_reset         <= '0;
    rx_fifo_max_fill_clr     <= '0;
    rx_fifo_fill_thresh      <= C_RX_FIFO_FILL_THRESH_DEFAULT;
    force_pec_error          <= '0;
    reg_ctlr_if.reg_wr_done  <= '0;
    reg_ctlr_if.reg_wr_resp  <= '0;
  end else begin
    // Defaults
    reg_ctlr_if.reg_wr_done  <= '0;
    reg_ctlr_if.reg_wr_resp  <= '0;
    ctlr_en                  <= '0;
    desc_fifo_wr_reset       <= '0;
    desc_fifo_wr_en          <= '0;
    desc_fifo_wr_en_d1       <= desc_fifo_wr_en;
    desc_fifo_error_irq      <= '0;
    rx_fifo_rd_reset         <= '0;
    rx_fifo_max_fill_clr     <= '0;

    if (reg_ctlr_if.reg_wr_valid) begin
      // Signal write done on next cycle for all accesses except for descriptor FIFO writes,
      // wait an extra cycle to determine if FIFO overflow occurred
      reg_ctlr_if.reg_wr_done <= '1;
      // Exclude unused address space to prevent aliasing
      if (!(|reg_ctlr_if.reg_wr_addr[C_ADDR_WIDTH-1:6])) begin
        case (reg_ctlr_if.reg_wr_addr[5:0]) inside
          // Controller Control - 0x00
          6'b0000??: ctlr_en            <= reg_ctlr_if.reg_wr_data[0];
          // Controller Descriptor FIFO - 0x08
          6'b0010??:
            begin
              if (desc_fifo_reset_busy) begin
                // Attempt made to write to the descriptor fifo while in reset,
                // raise error irq and respond with SLVERR, descriptor is dropped in this scenario
                desc_fifo_error_irq     <= '1;
                reg_ctlr_if.reg_wr_resp <= 2'b10;
              end else begin
                // Write to the descriptor FIFO unless a reset is being initiated,
                // don't assert done until we know it succeeded so the correct response can be sent
                desc_fifo_wr_en         <= ~reg_ctlr_if.reg_wr_data[31];
                reg_ctlr_if.reg_wr_done <= reg_ctlr_if.reg_wr_data[31];
              end
              desc_fifo_wr_reset  <= reg_ctlr_if.reg_wr_data[31];
              desc_fifo_wr_data   <= reg_ctlr_if.reg_wr_data[11:0];
            end
          // Controller Receive FIFO - 0x10
          6'b0100??:
            begin
              rx_fifo_rd_reset    <= reg_ctlr_if.reg_wr_data[31];
            end
          // Controller Receive FIFO Status - 0x14
          6'b0101??:
            begin
              rx_fifo_max_fill_clr  <= |reg_ctlr_if.reg_wr_data[16+:C_RX_FIFO_FILL_WIDTH];
            end
          // Controller Receive FIFO Fill Threshold - 0x18
          6'b0110??:
            begin
              rx_fifo_fill_thresh <= reg_ctlr_if.reg_wr_data[0+:C_RX_FIFO_FILL_WIDTH];
            end
          // Controller Debug - 0x1C
          6'b0111??:
            begin
              force_pec_error     <= reg_ctlr_if.reg_wr_data[31];
            end
        endcase
      end
    end
    // Respond to the descriptor FIFO write, if the write caused an overflow then send SLVERR
    if (desc_fifo_wr_en_d1) begin
      reg_ctlr_if.reg_wr_done  <= '1;
      reg_ctlr_if.reg_wr_resp  <= {desc_fifo_overflow,1'b0};
    end
  end
end

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_ctlr_if.reg_rd_data <= '0;
  reg_ctlr_if.reg_rd_done <= '0;
  reg_ctlr_if.reg_rd_resp <= '0;
  rx_fifo_rd_en           <= '0;
  rx_fifo_rd_error        <= '0;

  if (reg_ctlr_if.reg_rd_valid) begin
    // Default is 1 cycle latency on read done, except for FIFO read which is 2
    reg_ctlr_if.reg_rd_done  <= '1;
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_ctlr_if.reg_rd_addr[C_ADDR_WIDTH-1:6])) begin
      case (reg_ctlr_if.reg_rd_addr[5:0]) inside
        // Controller Status - 0x04
        6'b0001??: reg_ctlr_if.reg_rd_data[0]                  <= ctlr_enable;
        // Controller Descriptor FIFO Status - 0x0C
        6'b0011??:
          begin
            reg_ctlr_if.reg_rd_data[8+:C_DESC_FIFO_FILL_WIDTH] <= desc_fifo_fill_level;
            reg_ctlr_if.reg_rd_data[6]                         <= desc_fifo_reset_busy;
            reg_ctlr_if.reg_rd_data[5]                         <= desc_fifo_full;
            reg_ctlr_if.reg_rd_data[4]                         <= desc_fifo_almost_full;
            reg_ctlr_if.reg_rd_data[1]                         <= desc_fifo_almost_empty;
            reg_ctlr_if.reg_rd_data[0]                         <= desc_fifo_empty;
          end
        // Controller Receive FIFO - 0x10
        6'b0100??:
          begin
            if (rx_fifo_reset_busy) begin
              // Rx FIFO in reset, don't read enable FIFO and respond with SLVERR,
              // raise error interrupt
              reg_ctlr_if.reg_rd_resp   <= 2'b10;
              rx_fifo_rd_error          <= '1;
            end else begin
              // Read the FIFO, don't worry if empty,
              // underflow will be reported in the response and via interrupt
              rx_fifo_rd_en             <= '1;
              reg_ctlr_if.reg_rd_done   <= '0;
            end
          end
        // Controller Receive FIFO Status - 0x14
        6'b0101??:
          begin
            reg_ctlr_if.reg_rd_data[16+:C_RX_FIFO_FILL_WIDTH]  <= rx_fifo_max_fill;
            reg_ctlr_if.reg_rd_data[8+:C_RX_FIFO_FILL_WIDTH]   <= rx_fifo_fill_level;
            reg_ctlr_if.reg_rd_data[6]                         <= rx_fifo_reset_busy;
            reg_ctlr_if.reg_rd_data[5]                         <= rx_fifo_full;
            reg_ctlr_if.reg_rd_data[4]                         <= rx_fifo_almost_full;
            reg_ctlr_if.reg_rd_data[1]                         <= rx_fifo_almost_empty;
            reg_ctlr_if.reg_rd_data[0]                         <= rx_fifo_empty;
          end
        // Controller Receive FIFO Fill Threshold - 0x18
        6'b0110??:
          begin
            reg_ctlr_if.reg_rd_data[0+:C_RX_FIFO_FILL_WIDTH]   <= rx_fifo_fill_thresh;
          end
        // Controller Debug - 0x1C
        6'b0111??:
          begin
            reg_ctlr_if.reg_rd_data[31]                        <= force_pec_error;
            reg_ctlr_if.reg_rd_data[0+:$bits(current_st)]      <= current_st;
          end
        default:  reg_ctlr_if.reg_rd_data                      <= '0;
      endcase
    end
  end
  // Respond with the Receive FIFO read data when available after the read latency
  // If the read triggered a FIFO underflow, then respond with SLVERR
  if (rx_fifo_rd_data_valid) begin
    reg_ctlr_if.reg_rd_data[7:0]   <= rx_fifo_rd_data;
    reg_ctlr_if.reg_rd_done        <= '1;
    reg_ctlr_if.reg_rd_resp        <= {rx_fifo_underflow,1'b0};
  end
end

endmodule : smbus_v1_1_ctlr
