// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Target Logic
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_tgt
  import smbus_v1_1_pkg::*;
#(
  parameter int C_NUM_TARGET_DEVICES  = 8
) (
  // Register Control Interface
  smbus_v1_1_reg_if.sub       reg_tgt_if,

  // Clock & Reset
  input  logic                clk,
  input  logic                resetn,

  // Interrupts
  output tgt_irq_t            tgt_irq,

  // Control/Status
  input  tgt_phy_stat_t       tgt_phy_stat,
  output tgt_ctl_t            tgt_ctl
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
localparam int C_ADDR_WIDTH           = $bits(reg_tgt_if.reg_wr_addr);
localparam int C_DESC_FIFO_DATA_WIDTH = 12;
localparam int C_DESC_FIFO_DEPTH      = 64;
localparam int C_DESC_FIFO_FILL_WIDTH = $clog2(C_DESC_FIFO_DEPTH) + 1;
localparam int C_RX_FIFO_DATA_WIDTH   = 8;
localparam int C_RX_FIFO_DEPTH        = 64;
localparam int C_RX_FIFO_FILL_WIDTH   = $clog2(C_RX_FIFO_DEPTH) + 1;
localparam int C_RX_FIFO_FILL_THRESH_DEFAULT = 1;

// FSM state bit selects
localparam int  TG_SEQ_IDLE             = 0,
                TG_SEQ_HDR_CHK          = 1,
                TG_SEQ_WAIT_ON_WR       = 2,
                TG_SEQ_DESC_FETCH       = 3,
                TG_SEQ_WR_RESP          = 4,
                TG_SEQ_RD_DATA          = 5,
                TG_SEQ_WAIT_ON_RD_RESP  = 6;

// Write Descriptor IDs
localparam bit [2:0]  DESC_WR_ACK   = 3'b000,
                      DESC_WR_NACK  = 3'b001,
                      DESC_WR_PEC   = 3'b010;

// Read Descriptor IDs
localparam bit [2:0]  DESC_RD       = 3'b000,
                      DESC_RD_PEC   = 3'b001;
// --------------------------------------------------------
// Types
// --------------------------------------------------------
// Target Sequence FSM States - OneHot Encoded
typedef enum logic [6:0] {
  ST_TG_SEQ_IDLE            = 1 << TG_SEQ_IDLE,
  ST_TG_SEQ_HDR_CHK         = 1 << TG_SEQ_HDR_CHK,
  ST_TG_SEQ_WAIT_ON_WR      = 1 << TG_SEQ_WAIT_ON_WR,
  ST_TG_SEQ_DESC_FETCH      = 1 << TG_SEQ_DESC_FETCH,
  ST_TG_SEQ_WR_RESP         = 1 << TG_SEQ_WR_RESP,
  ST_TG_SEQ_RD_DATA         = 1 << TG_SEQ_RD_DATA,
  ST_TG_SEQ_WAIT_ON_RD_RESP = 1 << TG_SEQ_WAIT_ON_RD_RESP
} state_tg_seq_fsm_t;

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
state_tg_seq_fsm_t                      current_st;
state_tg_seq_fsm_t                      next_st;

logic [C_NUM_TARGET_DEVICES-1:0] [6:0]  tgt_device_addr;
logic [C_NUM_TARGET_DEVICES-1:0]        tgt_device_en;
logic [C_NUM_TARGET_DEVICES-1:0]        tgt_match;
logic                                   tgt_active;
logic                                   tgt_active_valid;
logic                                   header_valid_d1;

logic [C_DESC_FIFO_DATA_WIDTH-1:0]      desc_fifo_wr_data;
logic                                   desc_fifo_wr_en;
logic                                   desc_fifo_wr_en_d1;
logic [C_DESC_FIFO_FILL_WIDTH-1:0]      desc_fifo_fill_level;
logic                                   desc_fifo_overflow;
logic                                   desc_fifo_almost_full;
logic                                   desc_fifo_full;
logic [C_DESC_FIFO_DATA_WIDTH-1:0]      desc_fifo_rd_data;
logic                                   desc_fifo_rd_data_valid;
logic                                   desc_fifo_rd_en;
logic                                   desc_fifo_rd_reset;
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

logic                                   tx_byte_valid;
logic                                   wr_ack;
logic                                   wr_ack_valid;
logic                                   wr_irq;
logic                                   rd_irq;
logic                                   done_irq;
logic                                   hdr_irq_raised;
logic                                   wr_err_irq_raised;
logic                                   rd_irq_raised;
logic                                   rx_fifo_wr_error;
logic                                   rx_fifo_wr_error_d1;
logic                                   rx_fifo_rd_error;
logic                                   rx_fifo_error_irq;
logic                                   rx_byte_valid;
logic                                   desc_fifo_empty_irq;
logic                                   desc_fifo_almost_empty_irq;
logic                                   desc_fifo_error_irq;
logic                                   fifo_rd_pending;
logic                                   pec_error_irq;
logic                                   desc_valid;
logic [3:0]                             desc_id;
logic                                   desc_error_irq;
logic                                   tx_byte_pending;
logic [7:0]                             tx_byte;
logic                                   pec_tx_byte_valid;
logic [7:0]                             pec_tx_byte;
logic                                   force_pec_error;

logic [7:0]                             pec;
logic                                   pec_error;

// ========================================================
// Target Sequence FSM

// Update the current state
always_ff @(posedge clk) begin
  if (!resetn) begin
    current_st  <= ST_TG_SEQ_IDLE;
  end else begin
    current_st  <= next_st;
  end
end

// Determine the next state
always_comb begin
  next_st = current_st;
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[TG_SEQ_IDLE]:
      begin
        if (!tgt_phy_stat.phy_idle) begin
          // Wait for PHY to become active, move to the header check state
          next_st = ST_TG_SEQ_HDR_CHK;
        end
      end
    current_st[TG_SEQ_HDR_CHK]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          // If the header check outcome was to NACK, then wait on the idle
          next_st = ST_TG_SEQ_IDLE;
        end else if (tgt_phy_stat.wr_ack_ready && tgt_active_valid && tgt_active) begin
          // If the outcome of the header check was to send an ACK response,
          // then move the state forward based on whether it is a read/write transaction.
          if (tgt_phy_stat.header[0]) begin
            // Read transaction, move to descriptor fetch
            next_st = ST_TG_SEQ_DESC_FETCH;
          end else begin
            // Write transaction, move to wait on write
            next_st = ST_TG_SEQ_WAIT_ON_WR;
          end
        end
      end
    current_st[TG_SEQ_WAIT_ON_WR]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          next_st = ST_TG_SEQ_IDLE;
        end else if (!tgt_phy_stat.header_valid) begin
          // If the header byte is no longer valid,
          // then Repeated-Start received, move to header check
          next_st = ST_TG_SEQ_HDR_CHK;
        end else if (rx_byte_valid) begin
          // Another write byte received, move to desc_fetch to fetch another descriptor and
          // process the response
          next_st = ST_TG_SEQ_DESC_FETCH;
        end
      end
    current_st[TG_SEQ_DESC_FETCH]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          next_st = ST_TG_SEQ_IDLE;
        end else if (desc_valid && !desc_id[3]) begin
          // Recevied a write descriptor, move to wr_resp
          next_st = ST_TG_SEQ_WR_RESP;
        end else if (desc_valid && desc_id[3]) begin
          // Received a read descriptor, move to rd_data
          next_st = ST_TG_SEQ_RD_DATA;
        end
      end
    current_st[TG_SEQ_WR_RESP]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          next_st = ST_TG_SEQ_IDLE;
        end else if (tgt_phy_stat.wr_ack_ready) begin
          // Once the PHY has registered the write response, move to wait on write
          next_st = ST_TG_SEQ_WAIT_ON_WR;
        end
      end
    current_st[TG_SEQ_RD_DATA]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          next_st = ST_TG_SEQ_IDLE;
        end else if (tgt_phy_stat.tx_byte_ready) begin
          // PHY has acknowledged byte to transmit, move to wait_on_rd_resp
          next_st = ST_TG_SEQ_WAIT_ON_RD_RESP;
        end
      end
    current_st[TG_SEQ_WAIT_ON_RD_RESP]:
      begin
        if (tgt_phy_stat.phy_idle) begin
          // If the PHY goes idle, move to idle state
          next_st = ST_TG_SEQ_IDLE;
        end else if (tgt_phy_stat.rd_ack_valid && tgt_phy_stat.rd_ack) begin
          // PHY has received an ACK response for the read byte, move to desc_fetch
          next_st = ST_TG_SEQ_DESC_FETCH;
        end
      end
      default: next_st = ST_TG_SEQ_IDLE;
  endcase
end

// Set the Target outputs based on the FSM state
always_ff @(posedge clk) begin
  // Defaults
  tx_byte_valid               <= '0;
  wr_ack                      <= '0;
  wr_ack_valid                <= '0;
  wr_irq                      <= '0;
  rd_irq                      <= '0;
  done_irq                    <= '0;
  hdr_irq_raised              <= '0;
  rd_irq_raised               <= '0;
  rx_fifo_wr_en               <= '0;
  rx_fifo_wr_error_d1         <= rx_fifo_wr_error;
  rx_byte_valid               <= '0;
  desc_fifo_empty_irq         <= '0;
  desc_fifo_almost_empty_irq  <= '0;
  desc_fifo_rd_en             <= '0;
  desc_valid                  <= '0;
  fifo_rd_pending             <= '0;
  pec_error_irq               <= '0;
  desc_error_irq              <= '0;
  tx_byte_pending             <= '0;
  pec_tx_byte_valid           <= '0;

  // Detect an overflow of the Rx FIFO, hold the error until it can be checked in subsequent state
  if (rx_fifo_overflow) begin
    rx_fifo_wr_error  <= '1;
  end

  // FSM State decode
  unique case (1'b1)
    // Use a reverse case as the states are OneHot encoded
    current_st[TG_SEQ_IDLE]:
      begin
        // State Defaults
        rx_fifo_wr_error    <= '0;
        wr_err_irq_raised   <= '0;
      end
    current_st[TG_SEQ_HDR_CHK]:
      begin
        // State Defaults
        wr_err_irq_raised   <= '0;

        if (tgt_phy_stat.header_valid && tgt_active_valid && tgt_active) begin
          // Transaction address matches configured address,
          // instruct PHY to send ACK and raise rd/wr interrupt
          wr_ack_valid    <= '1;
          wr_ack          <= '1;
          wr_irq          <= ~tgt_phy_stat.header[0] & ~hdr_irq_raised;
          rd_irq          <= tgt_phy_stat.header[0] & ~hdr_irq_raised;
          hdr_irq_raised  <= '1;
        end else if (tgt_phy_stat.header_valid && tgt_active_valid && !tgt_active) begin
          // Transaction address doesn't match any configured address, instruct PHY to NACK
          wr_ack_valid  <= '1;
          wr_ack        <= '0;
        end
      end
    current_st[TG_SEQ_WAIT_ON_WR]:
      begin
        if (tgt_phy_stat.rx_byte_valid) begin
          // Write the received byte into the Rx FIFO if it is not in reset
          rx_byte_valid     <= '1;
          rx_fifo_wr_data   <= tgt_phy_stat.rx_byte;
          rx_fifo_wr_en     <= ~rx_fifo_rd_reset & ~rx_fifo_reset_busy;
          // Flag that the write has failed due to FIFO reset
          rx_fifo_wr_error  <= rx_fifo_rd_reset | rx_fifo_reset_busy;
        end

        if (!tgt_phy_stat.phy_error && tgt_phy_stat.phy_idle) begin
          // PHY has gone idle, but no error flagged so transaction has ended successfully,
          // raise done interrupt unless a write error interrupt has been previously raised
          done_irq          <= ~wr_err_irq_raised;
        end
      end
    current_st[TG_SEQ_DESC_FETCH]:
      begin
        // State Defaults
        fifo_rd_pending <= fifo_rd_pending;

        if (desc_fifo_empty && !fifo_rd_pending) begin
          // Descriptor FIFO is empty and a descriptor is required, raise interrupt
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

          // Verify that the correct type of descriptor is received
          if (desc_fifo_rd_data[11] != tgt_phy_stat.header[0]) begin
            // Mismatch between descriptor type and transaction type, invalidate the ID
            desc_id <= {tgt_phy_stat.header[0],3'b111};
          end
        end
      end
    current_st[TG_SEQ_WR_RESP]:
      begin
        if (rx_fifo_wr_error) begin
          // A received byte has been dropped due to the Rx FIFO being in reset or full
          // NACK the current byte to flag this error back to the Controller
          wr_ack_valid  <= '1;
          wr_ack        <= '0;
        end else begin
          // No Rx FIFO error, process the descriptor to determine the response
          case (desc_id[2:0])
            DESC_WR_ACK:
              begin
                // Write ACK descriptor, instruct PHY to ACK byte
                wr_ack_valid  <= '1;
                wr_ack        <= '1;
              end
            DESC_WR_NACK:
              begin
                // Write NACK descriptor, instruct PHY to NACK byte
                wr_ack_valid  <= '1;
                wr_ack        <= '0;
              end
            DESC_WR_PEC:
              begin
                // Write PEC descriptor, check PEC error status and ACK if good, otherwise NACK
                if (pec_error || force_pec_error) begin
                  // PEC error, NACK byte and raise PEC error interrupt
                  wr_ack_valid      <= '1;
                  wr_ack            <= '0;
                  pec_error_irq     <= ~wr_err_irq_raised;
                  wr_err_irq_raised <= '1;
                end else begin
                  // PEC good, ACK byte
                  wr_ack_valid      <= '1;
                  wr_ack            <= '1;
                end
              end
            default:
              begin
                // Invalid descriptor received, NACK byte and raise error interrupt
                wr_ack_valid        <= '1;
                wr_ack              <= '0;
                desc_error_irq      <= ~wr_err_irq_raised;
                wr_err_irq_raised   <= '1;
              end
          endcase
        end
      end
    current_st[TG_SEQ_RD_DATA]:
      begin
        // State Defaults
        tx_byte_pending <= tx_byte_pending;

        // Process the descriptor to determine the response
        case (desc_id[2:0])
          DESC_RD:
            begin
              // Read data descriptor, instruct PHY to transmit the payload
              tx_byte             <= desc_fifo_rd_data[7:0];
              tx_byte_valid       <= '1;

              // Set the byte for PEC calculation, single cycle valid
              pec_tx_byte         <= desc_fifo_rd_data[7:0];
              pec_tx_byte_valid   <= ~tx_byte_pending;
              tx_byte_pending     <= '1;
            end
          DESC_RD_PEC:
            begin
              // Read PEC descriptor, instruct PHY to transmit the calculated PEC byte
              // Invert the PEC to insert an error if force PEC error is enabled
              tx_byte         <= force_pec_error ? ~pec : pec;
              tx_byte_valid   <= '1;
            end
          default:
            begin
              // Invalid descriptor received, send 0x00 and raise error interrupt
              tx_byte         <= '0;
              tx_byte_valid   <= '1;
              desc_error_irq  <= ~rd_irq_raised;
              rd_irq_raised   <= '1;

              // Set the byte for PEC calculation, single cycle valid
              // Invert the byte used for PEC calc in order to poision the PEC so the fault
              // is detected by the Controller (if applicable)
              pec_tx_byte         <= '1;
              pec_tx_byte_valid   <= ~tx_byte_pending;
              tx_byte_pending     <= '1;
            end
        endcase
      end
    current_st[TG_SEQ_WAIT_ON_RD_RESP]:
      begin

        if (tgt_phy_stat.rd_ack_valid && !tgt_phy_stat.rd_ack) begin
          // PHY has received NACK response from Controller, raise the done interrupt
          done_irq      <= ~rd_irq_raised;
          rd_irq_raised <= '1;
        end

      end
  endcase
end

// ========================================================
// Device Address Comparator
// Check if the received target address matches any of the configured devices

always_ff @(posedge clk) begin
  if (!resetn) begin
    tgt_match         <= '0;
    tgt_active        <= '0;
    tgt_active_valid  <= '0;
    header_valid_d1   <= '0;
  end else begin
    // Defaults
    tgt_match   <= '0;

    // Compare each enabled device against the received target address
    for (int i=0; i<C_NUM_TARGET_DEVICES; i++) begin
      if (tgt_device_en[i] && tgt_phy_stat.header_valid) begin
        // First stage reduction, xnor each enabled address and reduce to a single bit per device
        tgt_match[i]  <= &(tgt_device_addr[i] ^~ tgt_phy_stat.header[7:1]);
      end
    end

    // Second stage reduction, determine when a match is found and the target is active
    tgt_active  <= |tgt_match;

    // Create a valid indicator for tgt_active by delaying header_valid
    header_valid_d1   <= tgt_phy_stat.header_valid;
    tgt_active_valid  <= header_valid_d1;
  end
end

// ========================================================
// Target Descriptor FIFO Instantiation
// Store the control descriptors written by software until required

smbus_v1_1_fifo #(
  .C_FIFO_DEPTH(C_DESC_FIFO_DEPTH),
  .C_DATA_WIDTH(C_DESC_FIFO_DATA_WIDTH)
) tgt_desc_fifo_inst (
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
  .fifo_wr_reset(1'b0),
  // FIFO Read Domain
  .fifo_rd_data(desc_fifo_rd_data),
  .fifo_rd_data_valid(desc_fifo_rd_data_valid),
  .fifo_rd_en(desc_fifo_rd_en),
  .fifo_rd_reset(desc_fifo_rd_reset)
);

// When the Target PHY is Idle, keep the Descriptor FIFO in reset
assign desc_fifo_rd_reset = tgt_phy_stat.phy_idle;

// ========================================================
// Target Receive FIFO Instantiation
// Store the bytes recevied during a write transaction until they can be read by s/w
// The header bytes are not written to the Rx FIFO, but all other bytes are (inc. PEC)

smbus_v1_1_fifo #(
  .C_FIFO_DEPTH(C_RX_FIFO_DEPTH),
  .C_DATA_WIDTH(C_RX_FIFO_DATA_WIDTH)
) tgt_rx_fifo_inst (
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
// Target Receive FIFO Fill Threshold Interrupt / Max Fill Level

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

// Target Receive FIFO Error Interrupt
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
// Target Packet Error Correction (PEC) Instantiation
// Perform the PEC CRC calculation and checking on the stream of bytes within a packet

smbus_v1_1_pec tgt_pec_inst (
  .clk,
  .resetn,
  .pec_reset(tgt_phy_stat.phy_idle),
  .tx_data(pec_tx_byte),
  .tx_data_valid(pec_tx_byte_valid),
  .rx_data(tgt_phy_stat.rx_byte),
  .rx_data_valid(tgt_phy_stat.rx_byte_valid),
  .pec,
  .pec_error
);

// ========================================================
// Assign the outputs

// Target Control interface
assign tgt_ctl.wr_ack_valid           = wr_ack_valid;
assign tgt_ctl.wr_ack                 = wr_ack;
assign tgt_ctl.tx_byte_valid          = tx_byte_valid;
assign tgt_ctl.tx_byte                = tx_byte;

// Target Interrupt interface
assign tgt_irq.read                   = rd_irq;
assign tgt_irq.write                  = wr_irq;
assign tgt_irq.done                   = done_irq;
assign tgt_irq.pec_error              = pec_error_irq;
assign tgt_irq.desc_fifo_empty        = desc_fifo_empty_irq;
assign tgt_irq.desc_fifo_almost_empty = desc_fifo_almost_empty_irq;
assign tgt_irq.desc_fifo_underflow    = desc_fifo_underflow;
assign tgt_irq.desc_fifo_overflow     = desc_fifo_overflow;
assign tgt_irq.desc_fifo_error        = desc_fifo_error_irq;
assign tgt_irq.desc_error             = desc_error_irq;
assign tgt_irq.rx_fifo_fill_threshold = rx_fifo_fill_thresh_irq;
assign tgt_irq.rx_fifo_underflow      = rx_fifo_underflow;
assign tgt_irq.rx_fifo_overflow       = rx_fifo_overflow;
assign tgt_irq.rx_fifo_error          = rx_fifo_error_irq;

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    tgt_device_en           <= '0;
    tgt_device_addr         <= '0;
    desc_fifo_wr_en         <= '0;
    desc_fifo_wr_en_d1      <= '0;
    desc_fifo_wr_data       <= '0;
    desc_fifo_error_irq     <= '0;
    rx_fifo_rd_reset        <= '0;
    rx_fifo_max_fill_clr    <= '0;
    rx_fifo_fill_thresh     <= C_RX_FIFO_FILL_THRESH_DEFAULT;
    force_pec_error         <= '0;
    reg_tgt_if.reg_wr_done  <= '0;
    reg_tgt_if.reg_wr_resp  <= '0;
  end else begin
    // Defaults
    reg_tgt_if.reg_wr_done  <= '0;
    reg_tgt_if.reg_wr_resp  <= '0;
    desc_fifo_wr_en         <= '0;
    desc_fifo_wr_en_d1      <= desc_fifo_wr_en;
    desc_fifo_error_irq     <= '0;
    rx_fifo_rd_reset        <= '0;
    rx_fifo_max_fill_clr    <= '0;

    if (reg_tgt_if.reg_wr_valid) begin
      // Signal write done on next cycle for all accesses except for descriptor FIFO writes,
      // wait an extra cycle to determine if FIFO overflow occurred
      reg_tgt_if.reg_wr_done <= '1;
      // Exclude unused address space to prevent aliasing
      if (!(|reg_tgt_if.reg_wr_addr[C_ADDR_WIDTH-1:6])) begin
        case (reg_tgt_if.reg_wr_addr[5:0]) inside
          // Target Descriptor FIFO - 0x04
          6'b0001??:
            begin
              if (desc_fifo_rd_reset || desc_fifo_reset_busy) begin
                // Attempt made to write to the descriptor fifo while in reset,
                // raise error irq and respond with SLVERR, descriptor is dropped in this scenario
                desc_fifo_error_irq     <= '1;
                reg_tgt_if.reg_wr_resp  <= 2'b10;
              end else begin
                // Write to the descriptor FIFO,
                // don't assert done until we know it succeeded so the correct response can be sent
                desc_fifo_wr_en         <= '1;
                reg_tgt_if.reg_wr_done  <= '0;
              end
              desc_fifo_wr_data   <= reg_tgt_if.reg_wr_data[11:0];
            end
          // Target Receive FIFO - 0x0C
          6'b0011??:
            begin
              rx_fifo_rd_reset    <= reg_tgt_if.reg_wr_data[31];
            end
          // Target Receive FIFO Status - 0x10
          6'b0100??:
            begin
              rx_fifo_max_fill_clr  <= |reg_tgt_if.reg_wr_data[16+:C_RX_FIFO_FILL_WIDTH];
            end
          // Target Receive FIFO Fill Threshold - 0x14
          6'b0101??:
            begin
              rx_fifo_fill_thresh <= reg_tgt_if.reg_wr_data[0+:C_RX_FIFO_FILL_WIDTH];
            end
          // Target Debug - 0x18
          6'b0110??:
            begin
              force_pec_error     <= reg_tgt_if.reg_wr_data[31];
            end
          // Target Control [0:7] - 0x20 : 0x3F
          6'b1?????:
            begin
              // Un-roll the target control registers based on number of enabled target devices
              for (int i=0; i<C_NUM_TARGET_DEVICES; i++) begin
                if (reg_tgt_if.reg_wr_addr[4:2] == i) begin
                  tgt_device_en[i]    <= reg_tgt_if.reg_wr_data[31];
                  tgt_device_addr[i]  <= reg_tgt_if.reg_wr_data[7:1];
                end
              end
            end
        endcase
      end
    end

    // Respond to the descriptor FIFO write, if the write caused an overflow then send SLVERR
    if (desc_fifo_wr_en_d1) begin
      reg_tgt_if.reg_wr_done  <= '1;
      reg_tgt_if.reg_wr_resp  <= {desc_fifo_overflow,1'b0};
    end
  end
end

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_tgt_if.reg_rd_data  <= '0;
  reg_tgt_if.reg_rd_done  <= '0;
  reg_tgt_if.reg_rd_resp  <= '0;
  rx_fifo_rd_en           <= '0;
  rx_fifo_rd_error        <= '0;

  if (reg_tgt_if.reg_rd_valid) begin
    // Default is 1 cycle latency on read done, except for FIFO read which is 2
    reg_tgt_if.reg_rd_done  <= '1;
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_tgt_if.reg_rd_addr[C_ADDR_WIDTH-1:6])) begin
      case (reg_tgt_if.reg_rd_addr[5:0]) inside
        // Target Status - 0x00
        6'b0000??:
          begin
            reg_tgt_if.reg_rd_data[8]   <= tgt_active;
            reg_tgt_if.reg_rd_data[7:0] <= tgt_phy_stat.header;
          end
        // Target Descriptor FIFO Status - 0x08
        6'b0010??:
          begin
            reg_tgt_if.reg_rd_data[8+:C_DESC_FIFO_FILL_WIDTH] <= desc_fifo_fill_level;
            reg_tgt_if.reg_rd_data[5]                         <= desc_fifo_full;
            reg_tgt_if.reg_rd_data[4]                         <= desc_fifo_almost_full;
            reg_tgt_if.reg_rd_data[1]                         <= desc_fifo_almost_empty;
            reg_tgt_if.reg_rd_data[0]                         <= desc_fifo_empty;
          end
        // Target Receive FIFO - 0x0C
        6'b0011??:
          begin
            if (rx_fifo_reset_busy) begin
              // Rx FIFO in reset, don't read enable FIFO and respond with SLVERR,
              // raise error interrupt
              reg_tgt_if.reg_rd_resp  <= 2'b10;
              rx_fifo_rd_error        <= '1;
            end else begin
              // Read the FIFO, don't worry if empty,
              // underflow will be reported in the response and via interrupt
              rx_fifo_rd_en           <= '1;
              reg_tgt_if.reg_rd_done  <= '0;
            end
          end
        // Target Receive FIFO Status - 0x10
        6'b0100??:
          begin
            reg_tgt_if.reg_rd_data[16+:C_RX_FIFO_FILL_WIDTH]  <= rx_fifo_max_fill;
            reg_tgt_if.reg_rd_data[8+:C_RX_FIFO_FILL_WIDTH]   <= rx_fifo_fill_level;
            reg_tgt_if.reg_rd_data[6]                         <= rx_fifo_reset_busy;
            reg_tgt_if.reg_rd_data[5]                         <= rx_fifo_full;
            reg_tgt_if.reg_rd_data[4]                         <= rx_fifo_almost_full;
            reg_tgt_if.reg_rd_data[1]                         <= rx_fifo_almost_empty;
            reg_tgt_if.reg_rd_data[0]                         <= rx_fifo_empty;
          end
        // Target Receive FIFO Fill Threshold - 0x14
        6'b0101??:
          begin
            reg_tgt_if.reg_rd_data[0+:C_RX_FIFO_FILL_WIDTH]   <= rx_fifo_fill_thresh;
          end
        // Target Debug - 0x18
        6'b0110??:
          begin
            reg_tgt_if.reg_rd_data[31]                        <= force_pec_error;
            reg_tgt_if.reg_rd_data[0+:$bits(current_st)]      <= current_st;
          end
        // Target Control [0:7] - 0x20 : 0x3F
        6'b1?????:
          begin
            // Un-roll the target control registers based on number of enabled target devices (1-8)
            for (int i=0; i<C_NUM_TARGET_DEVICES; i++) begin
              if (reg_tgt_if.reg_rd_addr[4:2] == i) begin
                reg_tgt_if.reg_rd_data[31]    <= tgt_device_en[i];
                reg_tgt_if.reg_rd_data[7:1]   <= tgt_device_addr[i];
              end
            end
          end
        default: reg_tgt_if.reg_rd_data  <= '0;
      endcase
    end
  end

  // Respond with the Receive FIFO read data when available after the read latency
  // If the read triggered a FIFO underflow, then respond with SLVERR
  if (rx_fifo_rd_data_valid) begin
    reg_tgt_if.reg_rd_data[7:0]   <= rx_fifo_rd_data;
    reg_tgt_if.reg_rd_done        <= '1;
    reg_tgt_if.reg_rd_resp        <= {rx_fifo_underflow,1'b0};
  end
end

endmodule : smbus_v1_1_tgt
