// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Top
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_top #(
  parameter int C_ADDR_WIDTH          = 12,
  parameter int C_SMBUS_DEV_CLASS     = 0,
  parameter int C_NUM_TARGET_DEVICES  = 8,
  parameter int C_FREQ_HZ_AXI_ACLK    = 100000000,
  parameter int C_MINOR_VERSION       = 0,
  parameter int C_MAJOR_VERSION       = 1,
  parameter int C_CORE_REVISION       = 0,
  parameter int C_PATCH_REVISION      = 0
) (
  // Clock Ports
  input  logic                         s_axi_aclk,

  // Reset Ports
  input  logic                         s_axi_aresetn,

  // S_AXI Interface Ports
  input  logic [C_ADDR_WIDTH-1:0]      s_axi_awaddr,
  input  logic                         s_axi_awvalid,
  output logic                         s_axi_awready,
  input  logic [32-1:0]                s_axi_wdata,
  input  logic [4-1:0]                 s_axi_wstrb,
  input  logic                         s_axi_wvalid,
  output logic                         s_axi_wready,
  output logic [2-1:0]                 s_axi_bresp,
  output logic                         s_axi_bvalid,
  input  logic                         s_axi_bready,
  input  logic [C_ADDR_WIDTH-1:0]      s_axi_araddr,
  input  logic                         s_axi_arvalid,
  output logic                         s_axi_arready,
  output logic [32-1:0]                s_axi_rdata,
  output logic [2-1:0]                 s_axi_rresp,
  output logic                         s_axi_rvalid,
  input  logic                         s_axi_rready,

  // Interrupt Ports
  output logic                         ip2intc_irpt,

  // SMBus Ports
  input  logic                         smbclk_i,
  output logic                         smbclk_o,
  output logic                         smbclk_t,
  input  logic                         smbdat_i,
  output logic                         smbdat_o,
  output logic                         smbdat_t
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Package Import
// --------------------------------------------------------
import smbus_v1_1_pkg::*;

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------
localparam int C_NUM_ADDR_GROUPS  = 8;
localparam int C_ADDR_BIT_OFFSET  = C_ADDR_WIDTH - $clog2(C_NUM_ADDR_GROUPS);

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------
phy_cmn_irq_t     phy_cmn_irq;
phy_cmn_stat_t    phy_cmn_stat;
phy_cmn_ctl_t     tgt_phy_ctl;
phy_cmn_ctl_t     ctlr_phy_ctl;
tgt_ctl_t         tgt_ctl;
tgt_phy_stat_t    tgt_phy_stat;
tgt_phy_irq_t     tgt_phy_irq;
tgt_irq_t         tgt_irq;
ctlr_ctl_t        ctlr_ctl;
ctlr_phy_stat_t   ctlr_phy_stat;
ctlr_phy_irq_t    ctlr_phy_irq;
ctlr_irq_t        ctlr_irq;

// ========================================================

// AXI4-Lite Interface Instantiation
smbus_v1_1_axi_if #(.C_ADDR_WIDTH(C_ADDR_WIDTH)) axi_if();

// Interface/port connections
assign axi_if.awaddr  = s_axi_awaddr;
assign axi_if.awvalid = s_axi_awvalid;
assign s_axi_awready  = axi_if.awready;
assign axi_if.wdata   = s_axi_wdata;
assign axi_if.wstrb   = s_axi_wstrb;
assign axi_if.wvalid  = s_axi_wvalid;
assign s_axi_wready   = axi_if.wready;
assign s_axi_bresp    = axi_if.bresp;
assign s_axi_bvalid   = axi_if.bvalid;
assign axi_if.bready  = s_axi_bready;
assign axi_if.araddr  = s_axi_araddr;
assign axi_if.arvalid = s_axi_arvalid;
assign s_axi_arready  = axi_if.arready;
assign s_axi_rdata    = axi_if.rdata;
assign s_axi_rresp    = axi_if.rresp;
assign s_axi_rvalid   = axi_if.rvalid;
assign axi_if.rready  = s_axi_rready;

// ========================================================

// Register Interface Instantiation
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_top_if();
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_phy_cmn_if();
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_tgt_phy_if();
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_tgt_if();
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_ctlr_phy_if();
smbus_v1_1_reg_if #(.C_ADDR_WIDTH(C_ADDR_BIT_OFFSET)) reg_ctlr_if();

// ========================================================

// AXI Module Instantiation
smbus_v1_1_axi #(
  .C_NUM_ADDR_GROUPS(C_NUM_ADDR_GROUPS),
  .C_ADDR_BIT_OFFSET(C_ADDR_BIT_OFFSET),
  .C_AXI_ADDR_WIDTH(C_ADDR_WIDTH)
) axi_inst (
  .axi_if,
  .reg_top_if,
  .reg_phy_cmn_if,
  .reg_tgt_phy_if,
  .reg_tgt_if,
  .reg_ctlr_phy_if,
  .reg_ctlr_if,
  .aclk(s_axi_aclk),
  .aresetn(s_axi_aresetn)
);

// ========================================================

// Top Registers / Interrupt Control Module Instantiation
smbus_v1_1_top_reg #(
  .C_MAJOR_VERSION(C_MAJOR_VERSION),
  .C_MINOR_VERSION(C_MINOR_VERSION),
  .C_CORE_REVISION(C_CORE_REVISION),
  .C_PATCH_REVISION(C_PATCH_REVISION),
  .C_FREQ_HZ_AXI_ACLK(C_FREQ_HZ_AXI_ACLK),
  .C_NUM_TARGET_DEVICES(C_NUM_TARGET_DEVICES),
  .C_SMBUS_DEV_CLASS(C_SMBUS_DEV_CLASS)
) top_reg_inst (
  .reg_top_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .phy_cmn_irq,
  .tgt_phy_irq,
  .tgt_irq,
  .ctlr_phy_irq,
  .ctlr_irq,
  .ip2intc_irpt
);

// ========================================================

// PHY Common Module Instantiation
smbus_v1_1_phy_common #(
  .C_SMBUS_DEV_CLASS(C_SMBUS_DEV_CLASS),
  .C_FREQ_HZ_CLK(C_FREQ_HZ_AXI_ACLK)
) phy_common_inst (
  .reg_phy_cmn_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .phy_cmn_irq,
  .phy_cmn_stat,
  .tgt_phy_ctl,
  .ctlr_phy_ctl,
  .smbclk_i,
  .smbclk_o,
  .smbclk_t,
  .smbdat_i,
  .smbdat_o,
  .smbdat_t
);

// ========================================================

// Target PHY Module Instantiation
smbus_v1_1_tgt_phy #(
  .C_SMBUS_DEV_CLASS(C_SMBUS_DEV_CLASS),
  .C_FREQ_HZ_CLK(C_FREQ_HZ_AXI_ACLK)
) tgt_phy_inst(
  .reg_tgt_phy_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .phy_cmn_stat,
  .tgt_ctl,
  .phy_cmn_ctl(tgt_phy_ctl),
  .tgt_phy_stat,
  .tgt_phy_irq
);

// ========================================================

// Target Module Instantiation
smbus_v1_1_tgt #(
  .C_NUM_TARGET_DEVICES(C_NUM_TARGET_DEVICES)
) tgt_inst (
  .reg_tgt_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .tgt_irq,
  .tgt_phy_stat,
  .tgt_ctl
);

// ========================================================

// Controller PHY Module Instantiation
smbus_v1_1_ctlr_phy  #(
  .C_SMBUS_DEV_CLASS(C_SMBUS_DEV_CLASS),
  .C_FREQ_HZ_CLK(C_FREQ_HZ_AXI_ACLK)
) ctlr_phy_inst (
  .reg_ctlr_phy_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .ctlr_phy_irq,
  .phy_cmn_stat,
  .ctlr_ctl,
  .phy_cmn_ctl(ctlr_phy_ctl),
  .ctlr_phy_stat
);

// ========================================================

// Controller Module Instantiation
smbus_v1_1_ctlr ctlr_inst(
  .reg_ctlr_if,
  .clk(s_axi_aclk),
  .resetn(s_axi_aresetn),
  .ctlr_irq,
  .ctlr_phy_stat,
  .ctlr_ctl
);

endmodule : smbus_v1_1_top
