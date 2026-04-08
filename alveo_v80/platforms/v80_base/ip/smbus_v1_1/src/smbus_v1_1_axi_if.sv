// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - AXI4-Lite Interface Definition
//
////////////////////////////////////////////////////////////

interface smbus_v1_1_axi_if #(
  parameter int C_DATA_WIDTH = 32,
  parameter int C_ADDR_WIDTH = 32
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// AXI4-Lite Interface Signals
// --------------------------------------------------------

// Write Address Channel
logic [C_ADDR_WIDTH-1:0]      awaddr;
logic                         awvalid;
logic                         awready;

// Write Data Channel
logic [C_DATA_WIDTH-1:0]      wdata;
logic [(C_DATA_WIDTH/8)-1:0]  wstrb;
logic                         wvalid;
logic                         wready;

// Write Response Channel
logic                         bvalid;
logic                         bready;
logic [1:0]                   bresp;

// Read Address Channel
logic [C_ADDR_WIDTH-1:0]      araddr;
logic                         arvalid;
logic                         arready;

// Read Data Channel
logic [C_DATA_WIDTH-1:0]      rdata;
logic [1:0]                   rresp;
logic                         rvalid;
logic                         rready;

// --------------------------------------------------------
// AXI4-Lite Manager Interface
// --------------------------------------------------------
modport man (
  output awaddr,
  output awvalid,
  input  awready,
  output wdata,
  output wstrb,
  output wvalid,
  input  wready,
  input  bvalid,
  input  bresp,
  output bready,
  output araddr,
  output arvalid,
  input  arready,
  input  rdata,
  input  rresp,
  input  rvalid,
  output rready
);

// --------------------------------------------------------
// AXI4-Lite Subordinate Interface
// --------------------------------------------------------
modport sub (
  input  awaddr,
  input  awvalid,
  output awready,
  input  wdata,
  input  wstrb,
  input  wvalid,
  output wready,
  output bvalid,
  output bresp,
  input  bready,
  input  araddr,
  input  arvalid,
  output arready,
  output rdata,
  output rresp,
  output rvalid,
  input  rready
);

// --------------------------------------------------------
// AXI4-Lite Monitor Interface
// --------------------------------------------------------
modport mon (
  input awaddr,
  input awvalid,
  input awready,
  input wdata,
  input wstrb,
  input wvalid,
  input wready,
  input bvalid,
  input bresp,
  input bready,
  input araddr,
  input arvalid,
  input arready,
  input rdata,
  input rresp,
  input rvalid,
  input rready
);

endinterface : smbus_v1_1_axi_if
