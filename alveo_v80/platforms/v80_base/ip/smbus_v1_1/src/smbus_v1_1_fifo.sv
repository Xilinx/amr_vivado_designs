// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Descriptor/Receive FIFO wrapper
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_fifo #(
  parameter int C_FIFO_DEPTH  = 64,
  parameter int C_DATA_WIDTH  = 12,
  parameter int C_FILL_WIDTH  = $clog2(C_FIFO_DEPTH) + 1
) (
  // Clock & Reset
  input  logic                    clk,
  input  logic                    resetn,

  // FIFO Status
  output logic                    fifo_reset_busy,
  output logic [C_FILL_WIDTH-1:0] fifo_fill_level,
  output logic                    fifo_full,
  output logic                    fifo_almost_full,
  output logic                    fifo_overflow,
  output logic                    fifo_empty,
  output logic                    fifo_almost_empty,
  output logic                    fifo_underflow,

  // FIFO Write
  input  logic [C_DATA_WIDTH-1:0] fifo_wr_data,
  input  logic                    fifo_wr_en,
  input  logic                    fifo_wr_reset,

  // FIFO Read
  output logic [C_DATA_WIDTH-1:0] fifo_rd_data,
  output logic                    fifo_rd_data_valid,
  input  logic                    fifo_rd_en,
  input  logic                    fifo_rd_reset
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
localparam int C_PROG_FULL_THRESH   = C_FIFO_DEPTH - 3;
localparam int C_PROG_EMPTY_THRESH  = 3;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic wr_rst_busy;
logic rd_rst_busy;
logic fifo_reset;

// Instantiate the XPM FIFO
xpm_fifo_sync #(
  .FIFO_MEMORY_TYPE("distributed"),
  .ECC_MODE("no_ecc"),
  .SIM_ASSERT_CHK(1),
  .CASCADE_HEIGHT(0),
  .FIFO_WRITE_DEPTH(C_FIFO_DEPTH),
  .WRITE_DATA_WIDTH(C_DATA_WIDTH),
  .WR_DATA_COUNT_WIDTH(C_FILL_WIDTH),
  .PROG_FULL_THRESH(C_PROG_FULL_THRESH),
  .FULL_RESET_VALUE(0),
  .USE_ADV_FEATURES("090D"),
  .READ_MODE("std"),
  .FIFO_READ_LATENCY(1),
  .READ_DATA_WIDTH(C_DATA_WIDTH),
  .RD_DATA_COUNT_WIDTH(C_FILL_WIDTH),
  .PROG_EMPTY_THRESH(C_PROG_EMPTY_THRESH),
  .DOUT_RESET_VALUE("0"),
  .WAKEUP_TIME(0)
) fifo_inst (
  // Common module ports
  .sleep(0),
  .rst(fifo_reset),

  // Write Domain ports
  .wr_clk(clk),
  .wr_en(fifo_wr_en),
  .din(fifo_wr_data),
  .full(fifo_full),
  .prog_full(),
  .wr_data_count(fifo_fill_level),
  .overflow(fifo_overflow),
  .wr_rst_busy(wr_rst_busy),
  .almost_full(fifo_almost_full),
  .wr_ack(),

  // Read Domain ports
  .rd_en(fifo_rd_en),
  .dout(fifo_rd_data),
  .empty(fifo_empty),
  .prog_empty(),
  .rd_data_count(),
  .underflow(fifo_underflow),
  .rd_rst_busy(rd_rst_busy),
  .almost_empty(fifo_almost_empty),
  .data_valid(),

  // ECC Related ports
  .injectsbiterr(0),
  .injectdbiterr(0),
  .sbiterr(),
  .dbiterr()
);

// Reset the FIFO when global reset or read/write domain resets are asserted
assign fifo_reset = ~resetn | fifo_wr_reset | fifo_rd_reset;

// Signal the FIFO is busy with reset in order to gate read/write enables
always_ff @(posedge clk) begin
  if (!resetn) begin
    fifo_reset_busy <= '1;
  end else begin
    fifo_reset_busy <= fifo_wr_reset | wr_rst_busy | fifo_rd_reset | rd_rst_busy;
  end
end

// Signal that the read data is valid after the FIFO read latency
// The built-in data valid doesn't assert in error conditions i.e. underflow/overflow,
// but these conditions are detected and handled separately so always flag data valid here
always_ff @(posedge clk) begin
  if (!resetn) begin
    fifo_rd_data_valid  <= '0;
  end else begin
    // Defaults
    fifo_rd_data_valid  <= '0;

    if (fifo_rd_en) begin
      fifo_rd_data_valid  <= '1;
    end
  end
end

endmodule : smbus_v1_1_fifo
