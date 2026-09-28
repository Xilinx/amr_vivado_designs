

module clk_throttling #(
    parameter C_THROTTLE_MODE = 1, // 1: clock throttling with BUFG, 0: throttle clock enable
    parameter SYNTH_SIZE = 8,
    parameter RST_ACTIVE_HIGH = 1, // 1 means Active High, 0 means Active Low
    parameter DEST_SYNC_FF = 4,
    parameter SIM_DEVICE = "ULTRASCALE_PLUS"
)(
    input wire Clk_In,
    input wire Rst_In,
    input wire Enable,
    //input wire Rate_Upd_Tog,
    //input wire [SYNTH_SIZE-1:0] Rate_In,
    input wire [31:0] Control,
    output wire Clk_Out,
    output wire Throttle
);

    // Internal signals
    reg [SYNTH_SIZE-1:0] Rate_int = 0;
    reg [SYNTH_SIZE-1:0] Synth = 0;
    reg Gate_Fast = 0;
    reg Gate_Fast_d1 = 0;
    reg Rate_Upd = 0;
    wire Rate_Upd_Tog_CDC;
    reg Rate_Upd_Tog_CDC_d1 = 0;
    wire Rst_In_rsync;
    wire Clk_Int;
    wire [SYNTH_SIZE-1:0] Rate_In_cdc;
    wire [31:0] control_cdc;

    localparam STARTUP_SYNTH = 0; // 1 = 100%, 0 = 0%
    localparam CONST_MAX = {1'b1, {SYNTH_SIZE-1{1'b0}}};

    assign Rate_Upd_Tog_CDC  = control_cdc[8];
    assign Rate_In_cdc  = control_cdc[6:0];


    // CDC for Control
    xpm_cdc_array_single #(
        .DEST_SYNC_FF(DEST_SYNC_FF),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) rate_cdc (
        .src_clk(1'b0),
        .src_in(Control),
        .dest_clk(Clk_Int),
        .dest_out(control_cdc)
    );

//    // CDC for Rate_Upd_Tog
//    xpm_cdc_single #(
//        .DEST_SYNC_FF(DEST_SYNC_FF + 1),
//        .SRC_INPUT_REG(0)
//    ) rate_upd_cdc (
//        .src_clk(1'b0),
//        .src_in(Rate_Upd_Tog),
//        .dest_clk(Clk_Int),
//        .dest_out(Rate_Upd_Tog_CDC)
//    );
//
    // CDC for Reset
    xpm_cdc_async_rst #(
        .DEST_SYNC_FF(DEST_SYNC_FF),
        .RST_ACTIVE_HIGH(RST_ACTIVE_HIGH)
    ) RPS (
        .src_arst(Rst_In),
        .dest_clk(Clk_Int),
        .dest_arst(Rst_In_rsync)
    );

//------------------------------------------------------------------------------
//-      Controller Logic
//------------------------------------------------------------------------------

    // Wait for a change of state of the Rate_Upd_Tog input, and reload the Rate signal
    always @(posedge Clk_Int) begin
        Rate_Upd_Tog_CDC_d1 <= Rate_Upd_Tog_CDC;
        Rate_Upd <= Rate_Upd_Tog_CDC ^ Rate_Upd_Tog_CDC_d1;
        if (Rate_Upd) begin
            Rate_int <= Rate_In_cdc;
        end

        // Implement N/M Synthesiser
        // Treat all values >= 128 as 100%
        if (Rate_int[SYNTH_SIZE-1]) begin
            Synth <= {1'b0, Synth[SYNTH_SIZE-2:0]} + CONST_MAX;
        end else begin
            Synth <= {1'b0, Synth[SYNTH_SIZE-2:0]} + Rate_int;
        end

        Gate_Fast <= Synth[SYNTH_SIZE-1];
        // Flop the gate signals to assist timing closure
        Gate_Fast_d1 <= Gate_Fast;

        if (!Enable || (RST_ACTIVE_HIGH && Rst_In_rsync) || (!RST_ACTIVE_HIGH && !Rst_In_rsync)) begin
            Rate_int <= {SYNTH_SIZE{STARTUP_SYNTH}};  // Default to whatever STARTUP_SYNTH is set to
            Synth <= {SYNTH_SIZE{STARTUP_SYNTH}};
            Gate_Fast <= STARTUP_SYNTH;
            Gate_Fast_d1 <= STARTUP_SYNTH;
        end
    end

  // Gated clock buffer
    generate
        if (C_THROTTLE_MODE == 1) begin
            wire In_Bufg_CE;

    // force the LUT to avoid any optimization of i_BUFG.
    // Depending on the shell clock structure (UCS in BLP), vivado trims away cascaded buffer if they are not in the same partition

            (* DONT_TOUCH = "TRUE" *) LUT1 #(
              .INIT ('h3)
            ) i_CE_LUT (
              .I0 (1'b1),
              .O  (In_Bufg_CE)
            );

            (* DONT_TOUCH = "TRUE" *) BUFGCE #(
                .SIM_DEVICE(SIM_DEVICE),
                .CE_TYPE("ASYNC")
            ) i_BUFG (
                .I(Clk_In),
                .CE(In_Bufg_CE),
                .O(Clk_Int)
            );

          // From UG949 - Because the BUFGCE and BUFGCE_DIV do not have the same cell delay, Xilinx recommends using the same clock buffer for both synchronous clocks
          // Generate BUFGCE_DIV for Fast clock, contrinuous clock and DIV clock when divided clock is enabled

            (* DONT_TOUCH = "TRUE" *) BUFGCE #(
                .SIM_DEVICE(SIM_DEVICE)
            ) FCLK (
                .I(Clk_Int),
                .CE(Gate_Fast_d1),
                .O(Clk_Out)
            );

            assign Throttle = 1'b1;
        end else begin
            assign Clk_Int = Clk_In;
            assign Clk_Out = Clk_Int;
            assign Throttle = Gate_Fast_d1;
        end
    endgenerate

endmodule
