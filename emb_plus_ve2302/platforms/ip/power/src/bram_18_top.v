// Copyright (C) 2022 Xilinx, Inc.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module bram_18_top #(
    parameter         C_FAMILY                   = "no_family",
    parameter integer C_THROTTLE_MODE            = 1, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer C_NUM_BLOCKS = 8,
    parameter integer DISABLE_SIM_ASSERT    = 0
) (
    input wire clk,
    input wire reset,
    input wire [31:0] control,
    input wire tog_en,
    output wire [31:0] status
);

    wire [C_NUM_BLOCKS-1:0] full_status;
    wire enable;
//    wire [31:0] control_cdc;
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

  assign enable = 1'b1;

    generate
      if (C_NUM_BLOCKS > 32) begin
        assign status = full_status[C_NUM_BLOCKS-1:C_NUM_BLOCKS-32];
      end
      else begin
        localparam FILL = 32 - C_NUM_BLOCKS ;
        assign status = {{FILL{1'b0}}, full_status};
      end
    endgenerate

    generate
        for (genvar ii = 0; ii < C_NUM_BLOCKS; ii=ii+1) begin : genblk_col
            bram_18_col #(
                .C_FAMILY           ( C_FAMILY                  ),
                .C_THROTTLE_MODE    ( C_THROTTLE_MODE           ),
                .N_BRAM             ( 1    ), // hard-code to smaller units
                .DISABLE_SIM_ASSERT ( DISABLE_SIM_ASSERT        )
            ) bram_col_inst (
                .clk    ( clk       ),
                .reset  ( reset     ),
                .enable ( enable    ),
                .tog_en ( tog_en    ),
                .status (full_status[ii] )
            );
        end
    endgenerate

endmodule
`default_nettype wire
