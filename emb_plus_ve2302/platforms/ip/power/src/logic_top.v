///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2023, Advanced Micro Devices, Inc.  All rights reserved.
// SPDX-License-Identifier: MIT
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module logic_top # (
    parameter NUM_LOGIC_BLOCKS 	= 10,
    parameter C_THROTTLE_MODE = 1
    )
    (
	input clk,
	input rst,
  input tog_en,
  input [31:0] control,
  output [31:0] status
    );

  wire enable;
//  wire [31:0] control_cdc;
//
//    xpm_cdc_array_single #(
//        .DEST_SYNC_FF(4),
//        .WIDTH(32),
//        .SRC_INPUT_REG(0)
//    ) control_cdc_inst (
//        .src_clk(1'b0),
//        .src_in(control),
//        .dest_clk(clk),
//        .dest_out(control_cdc)
//    );


//  assign enable = control_cdc[0];
  assign enable = 1'b1;

  	   logic #(
        .C_REG_BLOCK_SIZE (64),
        .C_NUM_BLOCKS (NUM_LOGIC_BLOCKS),
        .C_THROTTLE_MODE (C_THROTTLE_MODE)
       ) ulogic1 (
		       .clk(clk),
		       .reset(rst),
           .enable(enable),
           .tog_en(tog_en),
           .status(status)
		       );

endmodule