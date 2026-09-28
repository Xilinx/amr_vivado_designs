///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2023 - 2026, Advanced Micro Devices, Inc.  All rights reserved.
// SPDX-License-Identifier: MIT
///////////////////////////////////////////////////////////////////////////////

module power #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32,
  parameter NUM_LOGIC_BLOCKS 		= 1200,
  parameter NUM_RAMB_36_DC 		= 500,
  parameter NUM_RAMB_18_DC 		= 1000,
  parameter NUM_DSP = 3000,
  parameter NUM_URAM = 500
 ) (
    input system_rstn,
    input system_clk,
    input power_clk,
    input power_rstn,

    // AXI Lite interface
    input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,

    input wire [DATA_WIDTH-1:0] s_axi_wdata,
    input wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,

    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,

    input wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,

    output wire [DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready
);

    localparam DATAWIDTH_36K     		= 36;
    localparam DATAWIDTH_18K     		= 18;
    localparam nbtap = 4;
    localparam dsize = 16;
    localparam C_THROTTLE_MODE = 1;


// Define wires for status inputs
    wire [31:0] top_status;
    wire [31:0] logic_status;
    wire [31:0] bram_18_status;
    wire [31:0] bram_36_status;
    wire [31:0] dsp_status;
    wire [31:0] uram_status;

    wire [31:0] top_status_cdc;
    wire [31:0] logic_status_cdc;
    wire [31:0] bram_18_status_cdc;
    wire [31:0] bram_36_status_cdc;
    wire [31:0] dsp_status_cdc;
    wire [31:0] uram_status_cdc;

    wire [31*6-1:0] status_concat;
    wire [31*6-1:0] status_concat_cdc;

    // Define wires for control outputs
    wire [31:0] top_control;
    wire [31:0] logic_control;
    wire [31:0] bram_18_control;
    wire [31:0] bram_36_control;
    wire [31:0] dsp_control;
    wire [31:0] uram_control;

    wire pwr_clk;
    wire tog_en;

// Register Interface
axi_lite_registers #(
    .ADDR_WIDTH (8),
    .DATA_WIDTH (32)
) register_inst (
        .clk(system_clk),
        .resetn(system_rstn),

        // AXI Lite interface connections
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

        // Status inputs
        .top_status(top_status_cdc),
        .logic_status(logic_status_cdc),
        .bram_18_status(bram_18_status_cdc),
        .bram_36_status(bram_36_status_cdc),
        .dsp_status(dsp_status_cdc),
        .uram_status(uram_status_cdc),

        // Control outputs
        .top_control(top_control),
        .logic_control(logic_control),
        .bram_18_control(bram_18_control),
        .bram_36_control(bram_36_control),
        .dsp_control(dsp_control),
        .uram_control(uram_control)
);

    clk_throttling #(
        .C_THROTTLE_MODE    ( C_THROTTLE_MODE ),
        .SYNTH_SIZE         ( 7              ),
        .DEST_SYNC_FF       ( 4    ),
        .RST_ACTIVE_HIGH    ( 1               ),
        .SIM_DEVICE         ("VERSAL_HBM")
    ) clk_throttle (
        .Clk_In         ( power_clk          ),
        .Rst_In         ( ~power_rstn            ),
        .Enable         ( 1'b1              ),

        .Control        (top_control ),

        //.Rate_Upd_Tog   ( top_control[8]   ),
        //.Rate_In        ( top_control[6:0]  ),

        .Clk_Out        ( pwr_clk           ),
        .Throttle       ( tog_en          )
    );

    assign status_concat = {top_status, logic_status, bram_18_status, bram_36_status, dsp_status, uram_status};
    assign {top_status_cdc, logic_status_cdc, bram_18_status_cdc, bram_36_status_cdc, dsp_status_cdc, uram_status_cdc} = status_concat_cdc;

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32*6),
        .SRC_INPUT_REG(0)
    ) status_cdc_inst (
        .src_clk(1'b0),
        .src_in(status_concat),
        .dest_clk(clk),
        .dest_out(status_concat_cdc)
    );

	logic_top  #(
    .NUM_LOGIC_BLOCKS(NUM_LOGIC_BLOCKS),
    .C_THROTTLE_MODE (C_THROTTLE_MODE)
    ) ulogic
		(
		.clk(pwr_clk),
		.rst(~power_rstn),
    .tog_en(tog_en),
    .control(logic_control),
    .status(logic_status)
		);

    bram_36_top #(
        .C_FAMILY           ( "versal"                              ),
        .C_THROTTLE_MODE    ( C_THROTTLE_MODE                         ),
        .C_NUM_BLOCKS ( NUM_RAMB_36_DC                        ),
        .DISABLE_SIM_ASSERT ( 1 )
    ) inst_bram_36_top (
        .clk        ( pwr_clk   ),
        .reset      ( 1'b0      ),
        .control     ( bram_36_control   ),
        .status      (bram_36_status  ),
        .tog_en     ( tog_en  )
    );

    bram_18_top #(
        .C_FAMILY           ( "versal"                              ),
        .C_THROTTLE_MODE    ( C_THROTTLE_MODE                         ),
        .C_NUM_BLOCKS ( NUM_RAMB_18_DC                        ),
        .DISABLE_SIM_ASSERT ( 1 )
    ) inst_bram_18_top (
        .clk        ( pwr_clk   ),
        .reset      ( 1'b0      ),
        .control     ( bram_18_control   ),
        .status      (bram_18_status  ),
        .tog_en     ( tog_en  )
    );

    dsp_top #(
        .C_FAMILY           ( "versal"                                  ),
        .C_THROTTLE_MODE    ( C_THROTTLE_MODE                             ),
        .C_NUM_BLOCKS       ( NUM_DSP    )
    ) inst_dsp_top (
        .clk        ( pwr_clk   ),
        .reset      ( 1'b0      ),
        .control     ( dsp_control    ),
        .status      (dsp_status  ),
        .tog_en     ( tog_en  )

    );

    uram_top #(
        .C_FAMILY           ( "versal"                                  ),
        .C_THROTTLE_MODE    ( C_THROTTLE_MODE                             ),
        .C_NUM_BLOCKS       ( NUM_URAM    )
    ) inst_uram_top (
        .clk        ( pwr_clk   ),
        .reset      ( 1'b0      ),
        .control     ( uram_control    ),
        .status      (uram_status  ),
        .tog_en     ( tog_en  )
    );

  // Uniquifier for status

endmodule
