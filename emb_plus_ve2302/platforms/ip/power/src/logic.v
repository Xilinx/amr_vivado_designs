///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2023, Advanced Micro Devices, Inc.  All rights reserved.
// SPDX-License-Identifier: MIT
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

//module logic #(parameter NUM_BASE_LOGIC_BLOCKS 	= 30)
module logic #(
    parameter integer C_REG_BLOCK_SIZE = 200,
    parameter integer C_NUM_BLOCKS = 2000,
    parameter integer C_THROTTLE_MODE = 1
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        tog_en,
    output wire [31:0] status
);



wire [C_NUM_BLOCKS-1:0]  block_status;

assign status = (C_NUM_BLOCKS > 32) ? block_status[C_NUM_BLOCKS-1:C_NUM_BLOCKS-32] : {{(32-C_NUM_BLOCKS){1'b0}}, block_status[C_NUM_BLOCKS-1:0]};



    generate
        for (genvar yy = 0; yy < C_NUM_BLOCKS; yy=yy+1) begin : CR_Y
                basic_block #(
                    .C_THROTTLE_MODE    ( C_THROTTLE_MODE ),
                    .N_SLICES           ( C_REG_BLOCK_SIZE )
                ) basic_block_inst (
                    .clk    ( clk       ),
                    .reset  ( reset     ),
                    .enable ( enable      ) ,
                    .tog_en ( tog_en ),
                    .status ( block_status[yy])
                );
        end
    endgenerate

endmodule
`default_nettype wire



module basic_block #(
    parameter integer C_THROTTLE_MODE   = 0, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer N_SLICES          = 2
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        tog_en,
    output wire [31:0] status
);

    wire [N_SLICES-1:0] dataout;

    assign status = dataout[N_SLICES-1:N_SLICES-32];

    generate
        if (N_SLICES > 0) begin

            wire ff_en;
            if (C_THROTTLE_MODE == 1) begin
                assign ff_en = enable;
            end else begin
                assign ff_en = tog_en & enable;
            end

            (*dont_touch ="true"*) wire [15:0] wire1 [N_SLICES-1:0];
            for (genvar ii = 0; ii < N_SLICES; ii=ii+1) begin : loop_slice_flop
                if (ii == 0) begin
                    // The FFs of one slice are oscillator. Outputs are driving the other FF of the power CU
                    for (genvar jj = 0; jj < 16; jj=jj+1) begin : genblk_fdre
                        FDRE #(
                            .INIT         ( 0    ), // Initial value of register, 1'b0, 1'b1
                            .IS_C_INVERTED( 1'b0 ), // Optional inversion for C
                            .IS_D_INVERTED( 1'b0 ), // Optional inversion for D
                            .IS_R_INVERTED( 1'b0 )  // Optional inversion for R
                        ) FDRE_inst (
                            .C  ( clk               ),  // 1-bit input: Clock
                            .R  ( reset             ),  // 1-bit input: Synchronous reset
                            .CE ( ff_en             ),  // 1-bit input: Clock enable
                            .D  ( ~wire1[ii][jj]    ),  // 1-bit input: Data
                            .Q  ( wire1[ii][jj]     )   // 1-bit output: Data
                        );
                    end

                end else begin
                    // Other FF of the other slices of the CR are chained, the floorplan of the chain is defined in gen_power_floorplan.tcl
                    for (genvar jj = 0; jj < 16; jj=jj+1) begin : genblk_fdre
                        FDRE #(
                            .INIT         ( 0    ), // Initial value of register, 1'b0, 1'b1
                            .IS_C_INVERTED( 1'b0 ), // Optional inversion for C
                            .IS_D_INVERTED( 1'b0 ), // Optional inversion for D
                            .IS_R_INVERTED( 1'b0 )  // Optional inversion for R
                        ) FDRE_inst (
                            .C  ( clk               ),  // 1-bit input: Clock
                            .R  ( reset             ),  // 1-bit input: Synchronous reset
                            .CE ( enable            ),  // 1-bit input: Clock enable
                            .D  ( wire1[ii-1][jj]   ),  // 1-bit input: Data
                            .Q  ( wire1[ii][jj]     )   // 1-bit output: Data
                        );
                    end
                end
                assign dataout[ii] = wire1[ii][15];
            end
        end
    endgenerate


endmodule