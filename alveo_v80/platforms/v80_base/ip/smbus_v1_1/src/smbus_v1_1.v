// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
/////////////////////////////////////////////////////////////
//
// SMBus IP
//
////////////////////////////////////////////////////////////

`timescale 1ns/1ps

//(* DowngradeIPIdentifiedWarnings="yes" *)


module smbus_v1_1 #(
  parameter integer C_ADDR_WIDTH          = 12,
  parameter integer C_SMBUS_DEV_CLASS     = 0,
  parameter integer C_NUM_TARGET_DEVICES  = 8,
  parameter integer C_FREQ_HZ_AXI_ACLK    = 100000000,
  parameter integer C_MINOR_VERSION       = 0,
  parameter integer C_MAJOR_VERSION       = 1,
  parameter integer C_CORE_REVISION       = 0,
  parameter integer C_PATCH_REVISION      = 0
) (
  // Clock Ports
  input  wire                         s_axi_aclk,

  // Reset Ports
  input  wire                         s_axi_aresetn,

  // S_AXI Interface Ports
  input  wire [C_ADDR_WIDTH-1:0]      s_axi_awaddr,
  input  wire                         s_axi_awvalid,
  output wire                         s_axi_awready,
  input  wire [32-1:0]                s_axi_wdata,
  input  wire [4-1:0]                 s_axi_wstrb,
  input  wire                         s_axi_wvalid,
  output wire                         s_axi_wready,
  output wire [2-1:0]                 s_axi_bresp,
  output wire                         s_axi_bvalid,
  input  wire                         s_axi_bready,
  input  wire [C_ADDR_WIDTH-1:0]      s_axi_araddr,
  input  wire                         s_axi_arvalid,
  output wire                         s_axi_arready,
  output wire [32-1:0]                s_axi_rdata,
  output wire [2-1:0]                 s_axi_rresp,
  output wire                         s_axi_rvalid,
  input  wire                         s_axi_rready,

  // Interrupt Ports
  output wire                         ip2intc_irpt,

  // SMBus Ports
  input  wire                         smbclk_i,
  output wire                         smbclk_o,
  output wire                         smbclk_t,
  input  wire                         smbdat_i,
  output wire                         smbdat_o,
  output wire                         smbdat_t
);

// --------------------------------------------------------
// SMBus Top Level Instantiation
// --------------------------------------------------------
smbus_v1_1_top #(
  .C_ADDR_WIDTH(C_ADDR_WIDTH),
  .C_SMBUS_DEV_CLASS(C_SMBUS_DEV_CLASS),
  .C_NUM_TARGET_DEVICES(C_NUM_TARGET_DEVICES),
  .C_FREQ_HZ_AXI_ACLK(C_FREQ_HZ_AXI_ACLK),
  .C_MAJOR_VERSION(C_MAJOR_VERSION),
  .C_MINOR_VERSION(C_MINOR_VERSION),
  .C_CORE_REVISION(C_CORE_REVISION),
  .C_PATCH_REVISION(C_PATCH_REVISION)
) smbus_top_inst (
  // Clocks
  .s_axi_aclk(s_axi_aclk),

  // Resets
  .s_axi_aresetn(s_axi_aresetn),

  // S_AXI Interface
  .s_axi_awaddr(s_axi_awaddr),
  .s_axi_awvalid(s_axi_awvalid),
  .s_axi_awready(s_axi_awready),
  .s_axi_wdata(s_axi_wdata),
  .s_axi_wstrb(s_axi_wstrb),
  .s_axi_wvalid(s_axi_wvalid),
  .s_axi_wready(s_axi_wready),
  .s_axi_bresp(s_axi_bresp),
  .s_axi_bvalid(s_axi_bvalid),
  .s_axi_bready(s_axi_bready),
  .s_axi_araddr(s_axi_araddr),
  .s_axi_arvalid(s_axi_arvalid),
  .s_axi_arready(s_axi_arready),
  .s_axi_rdata(s_axi_rdata),
  .s_axi_rresp(s_axi_rresp),
  .s_axi_rvalid(s_axi_rvalid),
  .s_axi_rready(s_axi_rready),

  // Interrupt
  .ip2intc_irpt(ip2intc_irpt),

  // SMBus
  .smbclk_i(smbclk_i),
  .smbclk_o(smbclk_o),
  .smbclk_t(smbclk_t),
  .smbdat_i(smbdat_i),
  .smbdat_o(smbdat_o),
  .smbdat_t(smbdat_t)
);

endmodule
