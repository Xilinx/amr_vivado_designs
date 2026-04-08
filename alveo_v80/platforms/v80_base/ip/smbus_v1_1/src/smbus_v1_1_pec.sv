// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Packet Error Correction (PEC) Generation and Checking
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_pec #(
  parameter int C_PEC_WIDTH   = 8,
  parameter int C_DATA_WIDTH  = 8
) (
  // Clock & Reset
  input  logic                    clk,
  input  logic                    resetn,
  input  logic                    pec_reset,

  // Input data
  input  logic [C_DATA_WIDTH-1:0] tx_data,
  input  logic                    tx_data_valid,
  input  logic [C_DATA_WIDTH-1:0] rx_data,
  input  logic                    rx_data_valid,

  // Generated PEC / PEC Error
  output logic [C_PEC_WIDTH-1:0]  pec,
  output logic                    pec_error
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
// Polynomial for PEC is x^8 + x^2 + x^1 + 1
localparam bit [7:0] C_PEC_POLY = 8'h07;

// --------------------------------------------------------
// Types
// --------------------------------------------------------


// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// Function to update the PEC for a given data bit
function automatic logic [C_PEC_WIDTH-1:0] fn_pec_update (
  input logic [C_PEC_WIDTH-1:0] pec_current,
  input logic                   data
);
  logic [C_PEC_WIDTH-1:0] pec_int;

  pec_int = {pec_current[C_PEC_WIDTH-2:0],1'b0};
  if (pec_current[C_PEC_WIDTH-1] != data) begin
    pec_int = pec_int ^ C_PEC_POLY;
  end
  return (pec_int);
endfunction : fn_pec_update

// Function to calculate/update the PEC for a given data byte
function automatic logic [C_PEC_WIDTH-1:0] fn_calc_pec (
  input logic [C_PEC_WIDTH-1:0]   pec_current,
  input logic [C_DATA_WIDTH-1:0]  data
);
  logic [C_PEC_WIDTH-1:0] pec_int;

  pec_int = pec_current;
  for (int i=0; i<C_DATA_WIDTH; i++) begin
    pec_int = fn_pec_update(.pec_current(pec_int), .data(data[C_DATA_WIDTH-1-i]));
  end
  return (pec_int);
endfunction : fn_calc_pec

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic [C_PEC_WIDTH-1:0]   pec_current;
logic [C_DATA_WIDTH-1:0]  data;
logic                     data_valid;

// Generate the PEC based on the valid data and generate the PEC error
always_ff @(posedge clk) begin
  if (!resetn) begin
    pec_current   <= '0;
    pec_error     <= '0;
    data          <= '0;
    data_valid    <= '0;
  end else begin
    // Delay the data valid to align with data
    data_valid    <= tx_data_valid | rx_data_valid;
    if (pec_reset) begin
      // Soft reset to clear the PEC between packets
      pec_current   <= '0;
      pec_error     <= '0;
      data          <= '0;
    end else begin
      if (data_valid) begin
        // Calculate the updated PEC for each received valid byte
        pec_current <= fn_calc_pec(.pec_current(pec_current),.data(data));
        pec_error   <= |(fn_calc_pec(.pec_current(pec_current),.data(data)));
      end

      // Update the data used for PEC calc - Tx/Rx can't both be valid in the same cycle
      if (tx_data_valid) begin
        data  <= tx_data;
      end else if (rx_data_valid) begin
        data  <= rx_data;
      end
    end
  end
end

// Assign the pec output
assign pec = pec_current;

endmodule : smbus_v1_1_pec
