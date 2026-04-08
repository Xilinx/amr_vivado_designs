// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - AXI4-Lite Interface
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_axi_reg #(
  parameter int C_DATA_WIDTH       = 32,  // Data width
  parameter int C_NUM_ADDR_GROUPS  = 4,   // Number of address decode groups, must be 2**N
  parameter int C_ADDR_BIT_OFFSET  = 10   // Size of each group
) (
  // AXI4-Lite Subordinate Interface
  smbus_v1_1_axi_if.sub                                         axi_if,

  // Clock/Reset
  input  logic                                                  aclk,
  input  logic                                                  aresetn,

  // Register Read Interface
  output logic                          [C_NUM_ADDR_GROUPS-1:0] reg_rd_valid_o,
  output logic                          [C_ADDR_BIT_OFFSET-1:0] reg_rd_addr_o,
  input  logic                          [C_NUM_ADDR_GROUPS-1:0] reg_rd_done_i,
  input  logic [C_NUM_ADDR_GROUPS-1:0]                    [1:0] reg_rd_resp_i,
  input  logic [C_NUM_ADDR_GROUPS-1:0]       [C_DATA_WIDTH-1:0] reg_rd_data_i,

  // Register Write Interface
  output logic                          [C_NUM_ADDR_GROUPS-1:0] reg_wr_valid_o,
  output logic                          [C_ADDR_BIT_OFFSET-1:0] reg_wr_addr_o,
  output logic                           [(C_DATA_WIDTH/8)-1:0] reg_wr_be_o,
  output logic                               [C_DATA_WIDTH-1:0] reg_wr_data_o,
  input  logic                          [C_NUM_ADDR_GROUPS-1:0] reg_wr_done_i,
  input  logic [C_NUM_ADDR_GROUPS-1:0]                    [1:0] reg_wr_resp_i
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

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// Function to decode the address and set the correct reg valid bit
function automatic logic [C_NUM_ADDR_GROUPS-1:0] fn_reg_valid (
  input [(C_ADDR_BIT_OFFSET+$clog2(C_NUM_ADDR_GROUPS)-1):C_ADDR_BIT_OFFSET] axi_addr
);
  logic [C_NUM_ADDR_GROUPS-1:0] reg_valid = '0;

  for (int i=0; i<C_NUM_ADDR_GROUPS; i++) begin
    if (axi_addr == i) begin
      reg_valid[i] = 1'b1;
    end
  end
  return (reg_valid);
endfunction : fn_reg_valid

// Function to OR the received response
function automatic logic [1:0] fn_axi_resp (
  input [C_NUM_ADDR_GROUPS-1:0] [1:0] reg_resp
);
  logic [1:0] [C_NUM_ADDR_GROUPS-1:0] resp_int;
  logic [1:0]                         resp;

  resp_int  = '0;
  resp      = '0;

  // Re-order related bits into subfields
  for (int i=0; i<C_NUM_ADDR_GROUPS; i++) begin
    for (int j=0; j<2; j++) begin
      resp_int[j][i] = reg_resp[i][j];
    end
  end

  // OR-Reduce each subfield to a single bit
  for (int i=0; i<2; i++) begin
    resp[i] = |resp_int[i];
  end
  return (resp);
endfunction : fn_axi_resp

// Function to OR the received read data
function automatic logic [C_DATA_WIDTH-1:0] fn_axi_rdata (
  input [C_NUM_ADDR_GROUPS-1:0] [C_DATA_WIDTH-1:0] reg_rd_data
);
  logic [C_DATA_WIDTH-1:0] [C_NUM_ADDR_GROUPS-1:0] data_int;
  logic [C_DATA_WIDTH-1:0]                         data;

  data_int  = '0;
  data      = '0;

  // Re-order related bits into subfields
  for (int i=0; i<C_NUM_ADDR_GROUPS; i++) begin
    for (int j=0; j<C_DATA_WIDTH; j++) begin
      data_int[j][i] = reg_rd_data[i][j];
    end
  end

  // OR-Reduce each subfield to a single bit
  for (int i=0; i<C_DATA_WIDTH; i++) begin
    data[i] = |data_int[i];
  end
  return (data);
endfunction : fn_axi_rdata

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
logic wr_rdy;
logic wr_wait;
logic rd_wait;

// ========================================================

// AXI Write
always_ff @(posedge aclk) begin
  if (!aresetn) begin
    wr_rdy         <= '0;
    wr_wait        <= '0;
    reg_wr_valid_o <= '0;
    reg_wr_addr_o  <= '0;
    reg_wr_be_o    <= '0;
    reg_wr_data_o  <= '0;
    axi_if.bvalid  <= '0;
    axi_if.bresp   <= '0;
  end else begin
    // Defaults
    wr_rdy         <= '0;
    wr_wait        <= wr_wait;
    reg_wr_valid_o <= '0;
    reg_wr_addr_o  <= reg_wr_addr_o;
    reg_wr_be_o    <= reg_wr_be_o;
    reg_wr_data_o  <= reg_wr_data_o;
    axi_if.bvalid  <= '0;
    axi_if.bresp   <= '0;

    if (!wr_wait && !wr_rdy && axi_if.awvalid && axi_if.wvalid) begin
      wr_rdy         <= 1'b1;
      wr_wait        <= 1'b1;
      reg_wr_valid_o <= fn_reg_valid(.axi_addr(axi_if.awaddr[
          C_ADDR_BIT_OFFSET+:$clog2(C_NUM_ADDR_GROUPS)]));
      reg_wr_addr_o  <= axi_if.awaddr[0+:C_ADDR_BIT_OFFSET];
      reg_wr_be_o    <= axi_if.wstrb;
      reg_wr_data_o  <= axi_if.wdata;
    end else if (|reg_wr_done_i) begin
      axi_if.bvalid  <= 1'b1;
      axi_if.bresp   <= fn_axi_resp(.reg_resp(reg_wr_resp_i));
      reg_wr_addr_o  <= '0;
      reg_wr_be_o    <= '0;
      reg_wr_data_o  <= '0;
    end else if (axi_if.bvalid) begin
      if (!axi_if.bready) begin
        axi_if.bvalid <= axi_if.bvalid;
        axi_if.bresp  <= axi_if.bresp;
      end else begin
        wr_wait       <= 1'b0;
      end
    end
  end
end
assign axi_if.awready = wr_rdy;
assign axi_if.wready  = wr_rdy;

// ========================================================

// AXI Read
always_ff @(posedge aclk) begin
  if (!aresetn) begin
    axi_if.arready  <= '0;
    rd_wait         <= '0;
    reg_rd_valid_o  <= '0;
    reg_rd_addr_o   <= '0;
    axi_if.rvalid   <= '0;
    axi_if.rresp    <= '0;
    axi_if.rdata    <= '0;
  end else begin
    // Defaults
    axi_if.arready  <= '0;
    rd_wait         <= rd_wait;
    reg_rd_valid_o  <= '0;
    reg_rd_addr_o   <= '0;
    axi_if.rvalid   <= '0;
    axi_if.rresp    <= '0;
    axi_if.rdata    <= '0;
    if (!rd_wait && !axi_if.arready && axi_if.arvalid) begin
      axi_if.arready  <= 1'b1;
      rd_wait         <= 1'b1;
      reg_rd_valid_o  <= fn_reg_valid(.axi_addr(axi_if.araddr[
          C_ADDR_BIT_OFFSET+:$clog2(C_NUM_ADDR_GROUPS)]));
      reg_rd_addr_o   <= axi_if.araddr[0+:C_ADDR_BIT_OFFSET];
    end else if (|reg_rd_done_i) begin
      axi_if.rvalid   <= 1'b1;
      axi_if.rresp    <= fn_axi_resp(.reg_resp(reg_rd_resp_i));
      axi_if.rdata    <= fn_axi_rdata(.reg_rd_data(reg_rd_data_i));
    end else if (axi_if.rvalid) begin
      if (!axi_if.rready) begin
        axi_if.rvalid  <= axi_if.rvalid;
        axi_if.rresp   <= axi_if.rresp;
        axi_if.rdata   <= axi_if.rdata;
      end else begin
        rd_wait        <= 1'b0;
      end
    end
  end
end

endmodule : smbus_v1_1_axi_reg
