module axi_lite_registers #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire resetn,

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
    input wire s_axi_rready,

    // Connections to other power blocks
    output reg [DATA_WIDTH-1:0] top_control,
    output reg [DATA_WIDTH-1:0] logic_control,
    output reg [DATA_WIDTH-1:0] bram_18_control,
    output reg [DATA_WIDTH-1:0] bram_36_control,
    output reg [DATA_WIDTH-1:0] dsp_control,
    output reg [DATA_WIDTH-1:0] uram_control,
    input wire [DATA_WIDTH-1:0] top_status,
    input wire [DATA_WIDTH-1:0] logic_status,
    input wire [DATA_WIDTH-1:0] bram_18_status,
    input wire [DATA_WIDTH-1:0] bram_36_status,
    input wire [DATA_WIDTH-1:0] dsp_status,
    input wire [DATA_WIDTH-1:0] uram_status
);

    // Register addresses
    localparam CONTROL_ADDR       = 'h00;
    localparam STATUS_ADDR        = 'h04;
    localparam LOGIC_CONTROL_ADDR = 'h08;
    localparam LOGIC_STATUS_ADDR  = 'h0C;
    localparam BRAM_18_CONTROL_ADDR  = 'h10;
    localparam BRAM_18_STATUS_ADDR   = 'h14;
    localparam BRAM_36_CONTROL_ADDR  = 'h18;
    localparam BRAM_36_STATUS_ADDR   = 'h1C;
    localparam DSP_CONTROL_ADDR   = 'h20;
    localparam DSP_STATUS_ADDR    = 'h24;
    localparam URAM_CONTROL_ADDR   = 'h28;
    localparam URAM_STATUS_ADDR    = 'h2C;

    // Control Registers
    reg [DATA_WIDTH-1:0] top_control_reg;
    reg [DATA_WIDTH-1:0] logic_control_reg;
    reg [DATA_WIDTH-1:0] bram_18_control_reg;
    reg [DATA_WIDTH-1:0] bram_36_control_reg;
    reg [DATA_WIDTH-1:0] dsp_control_reg;
    reg [DATA_WIDTH-1:0] uram_control_reg;

    // Status Registers
    reg [DATA_WIDTH-1:0] top_status_reg;
    reg [DATA_WIDTH-1:0] logic_status_reg;
    reg [DATA_WIDTH-1:0] bram_18_status_reg;
    reg [DATA_WIDTH-1:0] bram_36_status_reg;
    reg [DATA_WIDTH-1:0] dsp_status_reg;
    reg [DATA_WIDTH-1:0] uram_status_reg;


    // CDC declarations
    wire [DATA_WIDTH-1:0] top_status_cdc;
    wire [DATA_WIDTH-1:0] logic_status_cdc;
    wire [DATA_WIDTH-1:0] bram_18_status_cdc;
    wire [DATA_WIDTH-1:0] bram_36_status_cdc;
    wire [DATA_WIDTH-1:0] dsp_status_cdc;
    wire [DATA_WIDTH-1:0] uram_status_cdc;

    // AXI Lite signals
    reg awready_reg;
    reg wready_reg;
    reg bvalid_reg;
    reg arready_reg;
    reg rvalid_reg;
    reg [DATA_WIDTH-1:0] rdata_reg;
    reg clear_tog_update;

     // Write logic (some have defaults assigned)
    always @(posedge clk) begin
        if (!resetn) begin
            top_control_reg <= 'h0000_0000;
            logic_control_reg <= 'h0000_0001;
            bram_18_control_reg <= 'h0000_0001;
            bram_36_control_reg <= 'h0000_0001;
            dsp_control_reg <= 'h0000_0001;
            uram_control_reg <= 'h0000_0001;
            awready_reg <= 0;
            wready_reg <= 0;
            bvalid_reg <= 0;
            clear_tog_update <= 0;
        end else begin
            awready_reg <= 1'b1;
            wready_reg <= 1'b1;

            if (s_axi_awvalid && s_axi_wvalid && awready_reg && wready_reg) begin
                case (s_axi_awaddr)
                    CONTROL_ADDR: begin
                      top_control_reg <= s_axi_wdata;
                      if (s_axi_wdata[8]) begin
                        clear_tog_update <= 1;
                      end
                    end
                    LOGIC_CONTROL_ADDR: logic_control_reg <= s_axi_wdata;
                    BRAM_18_CONTROL_ADDR:  bram_18_control_reg <= s_axi_wdata;
                    BRAM_36_CONTROL_ADDR:  bram_36_control_reg <= s_axi_wdata;
                    DSP_CONTROL_ADDR:   dsp_control_reg <= s_axi_wdata;
                    URAM_CONTROL_ADDR:  uram_control_reg <= s_axi_wdata;
                    default: ;
                endcase
                bvalid_reg <= 1;
            end else if (s_axi_bready && bvalid_reg) begin
                bvalid_reg <= 0;
            end

            // Clear top_control bit 8 automatically
            if (clear_tog_update) begin
              top_control_reg[8] <= 1'b0;
              clear_tog_update <= 0;
            end
        end
    end

    // Read logic
    always @(posedge clk) begin
        if (!resetn) begin
            arready_reg <= 0;
            rvalid_reg <= 0;
            rdata_reg <= 0;
        end else begin
            arready_reg <= 1'b1;

            if (s_axi_arvalid && arready_reg) begin
                case (s_axi_araddr)
                    CONTROL_ADDR:       rdata_reg <= top_control_reg;
                    STATUS_ADDR:        rdata_reg <= top_status_reg;
                    LOGIC_CONTROL_ADDR: rdata_reg <= logic_control_reg;
                    LOGIC_STATUS_ADDR:  rdata_reg <= logic_status_reg;
                    BRAM_18_CONTROL_ADDR:  rdata_reg <= bram_18_control_reg;
                    BRAM_18_STATUS_ADDR:   rdata_reg <= bram_18_status_reg;
                    BRAM_36_CONTROL_ADDR:  rdata_reg <= bram_36_control_reg;
                    BRAM_36_STATUS_ADDR:   rdata_reg <= bram_36_status_reg;
                    DSP_CONTROL_ADDR:   rdata_reg <= dsp_control_reg;
                    DSP_STATUS_ADDR:    rdata_reg <= dsp_status_reg;
                    URAM_CONTROL_ADDR:   rdata_reg <= uram_control_reg;
                    URAM_STATUS_ADDR:    rdata_reg <= uram_status_reg;
                    default: rdata_reg <= 0;
                endcase
                rvalid_reg <= 1;
            end else if (s_axi_rready && rvalid_reg) begin
                rvalid_reg <= 0;
            end
        end
    end

    // Assign outputs
    assign s_axi_awready = awready_reg;
    assign s_axi_wready = wready_reg;
    assign s_axi_bresp = 2'b00; // OKAY response
    assign s_axi_bvalid = bvalid_reg;
    assign s_axi_arready = arready_reg;
    assign s_axi_rdata = rdata_reg;
    assign s_axi_rresp = 2'b00; // OKAY response
    assign s_axi_rvalid = rvalid_reg;

// Assign control outputs and sample inputs
    always @(posedge clk) begin
        if (!resetn) begin
            top_control <= 0;
            logic_control <= 0;
            bram_18_control <= 0;
            bram_36_control <= 0;
            dsp_control <= 0;
            logic_status_reg <= 0;
            dsp_status_reg <= 0;
            bram_18_status_reg <= 0;
            bram_36_status_reg <= 0;
            top_status_reg <= 0;
        end else begin
            top_control <= top_control_reg;
            logic_control <= logic_control_reg;
            bram_18_control <= bram_18_control_reg;
            bram_36_control <= bram_36_control_reg;
            dsp_control <= dsp_control_reg;
            uram_control <= uram_control_reg;

            logic_status_reg <= logic_status_cdc;
            dsp_status_reg <= dsp_status_cdc;
            bram_18_status_reg <= bram_18_status_cdc;
            bram_36_status_reg <= bram_36_status_cdc;
            uram_status_reg <= uram_status_cdc;
            top_status_reg <= top_status_cdc;
        end
    end

// CDC for status bits on pwr_clk

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) logic_cdc (
        .src_clk(1'b0),
        .src_in(logic_status),
        .dest_clk(clk),
        .dest_out(logic_status_cdc)
    );

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) dsp_cdc (
        .src_clk(1'b0),
        .src_in(dsp_status),
        .dest_clk(clk),
        .dest_out(dsp_status_cdc)
    );

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) bram_18_cdc (
        .src_clk(1'b0),
        .src_in(bram_18_status),
        .dest_clk(clk),
        .dest_out(bram_18_status_cdc)
    );

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) bram_36_cdc (
        .src_clk(1'b0),
        .src_in(bram_36_status),
        .dest_clk(clk),
        .dest_out(bram_36_status_cdc)
    );

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) uram_cdc (
        .src_clk(1'b0),
        .src_in(uram_status),
        .dest_clk(clk),
        .dest_out(uram_status_cdc)
    );

    xpm_cdc_array_single #(
        .DEST_SYNC_FF(4),
        .WIDTH(32),
        .SRC_INPUT_REG(0)
    ) top_cdc (
        .src_clk(1'b0),
        .src_in(top_status),
        .dest_clk(clk),
        .dest_out(top_status_cdc)
    );


endmodule
