// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Processor Register Interface Definition
//
////////////////////////////////////////////////////////////

interface smbus_v1_1_reg_if #(
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
// Register Read Interface
// --------------------------------------------------------

logic                         reg_rd_valid;
logic [C_ADDR_WIDTH-1:0]      reg_rd_addr;
logic                         reg_rd_done;
logic [1:0]                   reg_rd_resp;
logic [C_DATA_WIDTH-1:0]      reg_rd_data;

// --------------------------------------------------------
// Register Write Interface
// --------------------------------------------------------

logic                         reg_wr_valid;
logic [C_ADDR_WIDTH-1:0]      reg_wr_addr;
logic [(C_DATA_WIDTH/8)-1:0]  reg_wr_be;
logic [C_DATA_WIDTH-1:0]      reg_wr_data;
logic                         reg_wr_done;
logic [1:0]                   reg_wr_resp;

// --------------------------------------------------------
// Register Manager Interface
// --------------------------------------------------------
modport man (
  output reg_rd_valid,
  output reg_rd_addr,
  input  reg_rd_done,
  input  reg_rd_resp,
  input  reg_rd_data,
  output reg_wr_valid,
  output reg_wr_addr,
  output reg_wr_be,
  output reg_wr_data,
  input  reg_wr_done,
  input  reg_wr_resp
);

// --------------------------------------------------------
// Register Subordinate Interface
// --------------------------------------------------------
modport sub (
  input  reg_rd_valid,
  input  reg_rd_addr,
  output reg_rd_done,
  output reg_rd_resp,
  output reg_rd_data,
  input  reg_wr_valid,
  input  reg_wr_addr,
  input  reg_wr_be,
  input  reg_wr_data,
  output reg_wr_done,
  output reg_wr_resp
);

endinterface : smbus_v1_1_reg_if
