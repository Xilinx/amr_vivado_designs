// Copyright (C) 2025 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

`timescale 1 ps / 1 ps

module clk_shim(
    input clk_in,
    output clk_out
    );
    

IBUF IBUF_inst (
   .O(clk_out), // Buffer output
   .I(clk_in)  // Buffer input (connect directly to top-level port)
);
    
endmodule
