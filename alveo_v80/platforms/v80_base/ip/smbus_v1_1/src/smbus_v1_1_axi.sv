// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - AXI4-Lite Interface
//          - Register Interface Top Level Address Decode
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_axi #(
  parameter int C_NUM_ADDR_GROUPS  = 8,   // Number of address decode groups
  parameter int C_ADDR_BIT_OFFSET  = 9,   // Address range of each address group
  parameter int C_AXI_ADDR_WIDTH   = 12,  // Address Width of AXI-Lite interface
  parameter int C_DATA_WIDTH       = 32   // Data width of AXI and Reg interfaces
) (
  // AXI4-Lite Subordinate Interface
  smbus_v1_1_axi_if.sub             axi_if,

  // Manager Register Interfaces
  smbus_v1_1_reg_if.man             reg_top_if,
  smbus_v1_1_reg_if.man             reg_phy_cmn_if,
  smbus_v1_1_reg_if.man             reg_tgt_phy_if,
  smbus_v1_1_reg_if.man             reg_tgt_if,
  smbus_v1_1_reg_if.man             reg_ctlr_phy_if,
  smbus_v1_1_reg_if.man             reg_ctlr_if,

  // Clock/Reset
  input  logic                      aclk,
  input  logic                      aresetn
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

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------

logic                          [C_NUM_ADDR_GROUPS-1:0] reg_rd_valid;
logic                          [C_ADDR_BIT_OFFSET-1:0] reg_rd_addr;
logic                          [C_NUM_ADDR_GROUPS-1:0] reg_rd_done;
logic                          [C_NUM_ADDR_GROUPS-1:0] reg_rd_done_int;
logic [C_NUM_ADDR_GROUPS-1:0]                    [1:0] reg_rd_resp;
logic [C_NUM_ADDR_GROUPS-1:0]       [C_DATA_WIDTH-1:0] reg_rd_data;
logic                          [C_NUM_ADDR_GROUPS-1:0] reg_wr_valid;
logic                          [C_ADDR_BIT_OFFSET-1:0] reg_wr_addr;
logic                           [(C_DATA_WIDTH/8)-1:0] reg_wr_be;
logic                               [C_DATA_WIDTH-1:0] reg_wr_data;
logic                          [C_NUM_ADDR_GROUPS-1:0] reg_wr_done;
logic                          [C_NUM_ADDR_GROUPS-1:0] reg_wr_done_int;
logic [C_NUM_ADDR_GROUPS-1:0]                    [1:0] reg_wr_resp;

// ========================================================

// --------------------------------------------------------
// AXI Register Interface Module Instantiation

smbus_v1_1_axi_reg #(
  .C_NUM_ADDR_GROUPS(C_NUM_ADDR_GROUPS),
  .C_ADDR_BIT_OFFSET(C_ADDR_BIT_OFFSET)
) axi_reg_inst (
  .axi_if,
  .aclk,
  .aresetn,
  .reg_rd_valid_o(reg_rd_valid),
  .reg_rd_addr_o(reg_rd_addr),
  .reg_rd_done_i(reg_rd_done),
  .reg_rd_resp_i(reg_rd_resp),
  .reg_rd_data_i(reg_rd_data),
  .reg_wr_valid_o(reg_wr_valid),
  .reg_wr_addr_o(reg_wr_addr),
  .reg_wr_be_o(reg_wr_be),
  .reg_wr_data_o(reg_wr_data),
  .reg_wr_done_i(reg_wr_done),
  .reg_wr_resp_i(reg_wr_resp)
);

// --------------------------------------------------------
// Register Interface assignments

// Top Level Registers (Version/IRQ Control)
assign reg_top_if.reg_rd_valid      = reg_rd_valid[0];
assign reg_top_if.reg_rd_addr       = reg_rd_addr;
assign reg_rd_done[0]               = reg_top_if.reg_rd_done;
assign reg_rd_resp[0]               = reg_top_if.reg_rd_resp;
assign reg_rd_data[0]               = reg_top_if.reg_rd_data;

assign reg_top_if.reg_wr_valid      = reg_wr_valid[0];
assign reg_top_if.reg_wr_addr       = reg_wr_addr;
assign reg_top_if.reg_wr_be         = reg_wr_be;
assign reg_top_if.reg_wr_data       = reg_wr_data;
assign reg_wr_done[0]               = reg_top_if.reg_wr_done;
assign reg_wr_resp[0]               = reg_top_if.reg_wr_resp;

// PHY Common Registers
assign reg_phy_cmn_if.reg_rd_valid  = reg_rd_valid[1];
assign reg_phy_cmn_if.reg_rd_addr   = reg_rd_addr;
assign reg_rd_done[1]               = reg_phy_cmn_if.reg_rd_done;
assign reg_rd_resp[1]               = reg_phy_cmn_if.reg_rd_resp;
assign reg_rd_data[1]               = reg_phy_cmn_if.reg_rd_data;

assign reg_phy_cmn_if.reg_wr_valid  = reg_wr_valid[1];
assign reg_phy_cmn_if.reg_wr_addr   = reg_wr_addr;
assign reg_phy_cmn_if.reg_wr_be     = reg_wr_be;
assign reg_phy_cmn_if.reg_wr_data   = reg_wr_data;
assign reg_wr_done[1]               = reg_phy_cmn_if.reg_wr_done;
assign reg_wr_resp[1]               = reg_phy_cmn_if.reg_wr_resp;

// Target PHY Registers
assign reg_tgt_phy_if.reg_rd_valid  = reg_rd_valid[2];
assign reg_tgt_phy_if.reg_rd_addr   = reg_rd_addr;
assign reg_rd_done[2]               = reg_tgt_phy_if.reg_rd_done;
assign reg_rd_resp[2]               = reg_tgt_phy_if.reg_rd_resp;
assign reg_rd_data[2]               = reg_tgt_phy_if.reg_rd_data;

assign reg_tgt_phy_if.reg_wr_valid  = reg_wr_valid[2];
assign reg_tgt_phy_if.reg_wr_addr   = reg_wr_addr;
assign reg_tgt_phy_if.reg_wr_be     = reg_wr_be;
assign reg_tgt_phy_if.reg_wr_data   = reg_wr_data;
assign reg_wr_done[2]               = reg_tgt_phy_if.reg_wr_done;
assign reg_wr_resp[2]               = reg_tgt_phy_if.reg_wr_resp;

// Target Registers
assign reg_tgt_if.reg_rd_valid      = reg_rd_valid[3];
assign reg_tgt_if.reg_rd_addr       = reg_rd_addr;
assign reg_rd_done[3]               = reg_tgt_if.reg_rd_done;
assign reg_rd_resp[3]               = reg_tgt_if.reg_rd_resp;
assign reg_rd_data[3]               = reg_tgt_if.reg_rd_data;

assign reg_tgt_if.reg_wr_valid      = reg_wr_valid[3];
assign reg_tgt_if.reg_wr_addr       = reg_wr_addr;
assign reg_tgt_if.reg_wr_be         = reg_wr_be;
assign reg_tgt_if.reg_wr_data       = reg_wr_data;
assign reg_wr_done[3]               = reg_tgt_if.reg_wr_done;
assign reg_wr_resp[3]               = reg_tgt_if.reg_wr_resp;

// Controller PHY Registers
assign reg_ctlr_phy_if.reg_rd_valid = reg_rd_valid[4];
assign reg_ctlr_phy_if.reg_rd_addr  = reg_rd_addr;
assign reg_rd_done[4]               = reg_ctlr_phy_if.reg_rd_done;
assign reg_rd_resp[4]               = reg_ctlr_phy_if.reg_rd_resp;
assign reg_rd_data[4]               = reg_ctlr_phy_if.reg_rd_data;

assign reg_ctlr_phy_if.reg_wr_valid = reg_wr_valid[4];
assign reg_ctlr_phy_if.reg_wr_addr  = reg_wr_addr;
assign reg_ctlr_phy_if.reg_wr_be    = reg_wr_be;
assign reg_ctlr_phy_if.reg_wr_data  = reg_wr_data;
assign reg_wr_done[4]               = reg_ctlr_phy_if.reg_wr_done;
assign reg_wr_resp[4]               = reg_ctlr_phy_if.reg_wr_resp;

// Controller Registers
assign reg_ctlr_if.reg_rd_valid     = reg_rd_valid[5];
assign reg_ctlr_if.reg_rd_addr      = reg_rd_addr;
assign reg_rd_done[5]               = reg_ctlr_if.reg_rd_done;
assign reg_rd_resp[5]               = reg_ctlr_if.reg_rd_resp;
assign reg_rd_data[5]               = reg_ctlr_if.reg_rd_data;

assign reg_ctlr_if.reg_wr_valid     = reg_wr_valid[5];
assign reg_ctlr_if.reg_wr_addr      = reg_wr_addr;
assign reg_ctlr_if.reg_wr_be        = reg_wr_be;
assign reg_ctlr_if.reg_wr_data      = reg_wr_data;
assign reg_wr_done[5]               = reg_ctlr_if.reg_wr_done;
assign reg_wr_resp[5]               = reg_ctlr_if.reg_wr_resp;

// Tie-off unused register interfaces (6 & 7)

assign reg_rd_resp[7:6] = '0;
assign reg_rd_data[7:6] = '0;
assign reg_rd_done[7:6] = reg_rd_done_int[7:6];
assign reg_wr_resp[7:6] = '0;
assign reg_wr_done[7:6] = reg_wr_done_int[7:6];

// Signal read/write done for access into un-used address space
always_ff @(posedge aclk) begin
  // Defaults
  reg_rd_done_int  <= '0;
  reg_wr_done_int  <= '0;

  for (int i=6; i<C_NUM_ADDR_GROUPS; i++) begin
    if (reg_rd_valid[i]) begin
      reg_rd_done_int[i]  <= '1;
    end

    if (reg_wr_valid[i]) begin
      reg_wr_done_int[i]  <= '1;
    end
  end
end

endmodule : smbus_v1_1_axi
