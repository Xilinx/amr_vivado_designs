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

module bram_18_col #(
    parameter         C_FAMILY              = "no_family",
    parameter integer C_THROTTLE_MODE       = 1, // 1: clock throttling with BUFG, 0: throttle clock enable of sites FF input oscillator
    parameter integer N_BRAM                = 0, // N_BRAM max = 12
    parameter integer DISABLE_SIM_ASSERT    = 0
) (
    input wire clk,    // throttle if C_THROTTLE_MODE = 1
    input wire reset,
    input wire enable, // SW
    input wire tog_en,  // throttle if C_THROTTLE_MODE = 0
    output wire status
);


    generate
        if (N_BRAM > 0) begin

            reg sleep = 1'b1;
            // pipeline enable for replication
            always @(posedge clk) begin
                if (reset) begin
                    sleep <= 1'b1;
                end else begin
                    sleep <= ~enable;
                end
            end

            reg ff = 1'b0;
            always @(posedge clk) begin
                if ((C_THROTTLE_MODE == 0) && (tog_en & enable)
                 || (C_THROTTLE_MODE == 1) && (enable)) begin
                    ff <= ~ff;
                end
            end

            for (genvar kk = 0; kk < N_BRAM; kk=kk+1) begin : genblk_bram
                bram_18_el #(
                    .C_FAMILY           ( C_FAMILY              ),
                    .DISABLE_SIM_ASSERT ( DISABLE_SIM_ASSERT    )
                ) u_bram_el (
                    .clk    ( clk   ),
                    .ff     ( ff    ),
                    .sleep  ( sleep )
                );
            end
            assign status = ff;
        end
    endgenerate

endmodule

//-----------------------------------------------------------

module bram_18_el #(
    parameter         C_FAMILY           = "no_family",
    parameter integer DISABLE_SIM_ASSERT = 0
) (
    input  wire clk,
    input  wire ff,
    input  wire sleep
 );

    // Use this to suppress warning in simulation, don't care in RTL
    wire  dummy;
    generate
        if (DISABLE_SIM_ASSERT == 1) begin
            wire  dummy_comb = (~sleep);
            reg dummy_seq = 1'b0;
            reg dummy_seq_d = 1'b0;
            always @(posedge clk) begin
                dummy_seq   <= dummy_comb;
                dummy_seq_d <= dummy_seq;
            end
            assign  dummy = dummy_comb & dummy_seq & dummy_seq_d; // Apply for some cycles
        end else begin
            assign  dummy = 1'b1;
        end
    endgenerate

    generate
        if (C_FAMILY == "versal") begin

           // RAMB18E5: 18K-bit Configurable Synchronous Block RAM
           //           Versal AI Core series
           // Xilinx HDL Language Template, version 2026.1

           (*dont_touch = "true"*) RAMB18E5 #(
              .CASCADE_ORDER_A              ( "NONE"                ), // "FIRST", "MIDDLE", "LAST", "NONE"
              .CASCADE_ORDER_B              ( "NONE"                ), // "FIRST", "MIDDLE", "LAST", "NONE"
              .CLOCK_DOMAINS                ( "COMMON"              ), // "COMMON", "INDEPENDENT"
              .SIM_COLLISION_CHECK          ( "NONE"                ), // Collision check: "ALL", "GENERATE_X_ONLY", "NONE", "WARNING_ONLY"
              .DOA_REG                      ( 1                     ), // Optional output register (0, 1)
              .DOB_REG                      ( 1                     ), // Optional output register (0, 1)
              .INIT_FILE                    ( "NONE"                ), // Initialization File: RAM initialization file
              .PR_SAVE_DATA                 ( "FALSE"               ), // PartialReconfig: Skip initialization after partial reconfiguration
              .IS_ARST_A_INVERTED           ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_ARST_B_INVERTED           ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_CLKARDCLK_INVERTED        ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_CLKBWRCLK_INVERTED        ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_ENARDEN_INVERTED          ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_ENBWREN_INVERTED          ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_RSTRAMARSTRAM_INVERTED    ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_RSTRAMB_INVERTED          ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_RSTREGARSTREG_INVERTED    ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .IS_RSTREGB_INVERTED          ( 1'b0                  ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
              .READ_WIDTH_A                 ( 36                    ), // Read width per port
              .WRITE_WIDTH_B                ( 36                    ), // Write width per port
              .RSTREG_PRIORITY_A            ( "RSTREG"              ), // Reset or enable priority ("RSTREG", "REGCE")
              .RSTREG_PRIORITY_B            ( "RSTREG"              ), // Reset or enable priority ("RSTREG", "REGCE")
              .RST_MODE_A                   ( "SYNC"                ), // Set synchronous or asynchronous reset.
              .RST_MODE_B                   ( "SYNC"                ), // Set synchronous or asynchronous reset.
              .SRVAL_A                      ( 18'h00000         ), // Set/reset value for output
              .SRVAL_B                      ( 18'h00000         ), // Set/reset value for output
              .SLEEP_ASYNC                  ( "FALSE"               ), // Sleep Async: Sleep function asynchronous or synchronous ("TRUE", "FALSE")
              .WRITE_MODE_A                 ( "READ_FIRST"          ), // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
              .WRITE_MODE_B                 ( "READ_FIRST"          )  // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
           ) bram_inst (
              // Port A Data outputs: Port A data
              .DOUTADOUT        (                   ), // 16-bit output: Port A Data/LSB data
              .DOUTPADOUTP      (                   ), // 2-bit output: Port A parity/LSB parity
              // Port B Data outputs: Port B dataA
              .DOUTBDOUT        (                   ), // 16-bit output: Port B data/MSB data
              .DOUTPBDOUTP      (                   ), // 2-bit output: Port B parity/MSB parity
              // Cascade Signals inputs: Multi-BRAM cascade signals
              .CASDINA          ( 16'b0             ), // 16-bit input: Port A cascade input data
              .CASDINB          ( 16'b0             ), // 16-bit input: Port B cascade input data
              .CASDINPA         ( 2'b0              ), // 2-bit input: Port A cascade input parity data
              .CASDINPB         ( 2'b0              ), // 2-bit input: Port B cascade input parity data
              .CASDOMUXA        ( 1'b0              ), // 1-bit input: Port A unregistered data (0=BRAM data, 1=CASDINA)
              .CASDOMUXB        ( 1'b0              ), // 1-bit input: Port B unregistered data (0=BRAM data, 1=CASDINB)
              .CASDOMUXEN_A     ( dummy             ), // 1-bit input: Port A unregistered output data enable
              .CASDOMUXEN_B     ( dummy             ), // 1-bit input: Port B unregistered output data enable
              .CASOREGIMUXA     ( 1'b0              ), // 1-bit input: Port A registered data (0=BRAM data, 1=CASDINA)
              .CASOREGIMUXB     ( 1'b0              ), // 1-bit input: Port B registered data (0=BRAM data, 1=CASDINB)
              .CASOREGIMUXEN_A  ( dummy             ), // 1-bit input: Port A registered output data enable
              .CASOREGIMUXEN_B  ( dummy             ), // 1-bit input: Port B registered output data enable
              // Port A Address/Control Signals inputs: Port A address and control signals
              .ADDRARDADDR      ( {{8{ff}}, 3'b111} ), // 11-bit input: A/Read port address
              .ARST_A           ( 1'b0              ), // 1-bit input: Port A asynchronous reset
              .CLKARDCLK        ( clk               ), // 1-bit input: A/Read port clock
              .ENARDEN          ( dummy             ), // 1-bit input: Port A enable/Read enable
              .REGCEAREGCE      ( dummy             ), // 1-bit input: Port A register enable/Register enable
              .RSTRAMARSTRAM    ( 1'b0              ), // 1-bit input: Port A set/reset
              .RSTREGARSTREG    ( 1'b0              ), // 1-bit input: Port A register set/reset
              .WEA              ( {4{dummy}}        ), // 4-bit input: Port A write enable
              // Port A Data inputs: Port A data
              .DINADIN          ( {16{ff}}          ), // 16-bit input: Port A data/LSB data
              .DINPADINP        ( {2{ff}}           ), // 2-bit input: Port A parity/LSB parity
              // Port B Address/Control Signals inputs: Port B address and control signals
              .ADDRBWRADDR      ( {{8{ff}}, 3'b111} ), // 11-bit input: B/Write port address
              .ARST_B           ( 1'b0              ), // 1-bit input: Port B asynchronous reset
              .CLKBWRCLK        ( clk               ), // 1-bit input: B/Write port clock
              .ENBWREN          ( dummy             ), // 1-bit input: Port B enable/Write enable
              .REGCEB           ( dummy             ), // 1-bit input: Port B register enable
              .RSTRAMB          ( 1'b0              ), // 1-bit input: Port B set/reset
              .RSTREGB          ( 1'b0              ), // 1-bit input: Port B register set/reset
              .WEBWE            ( {4{dummy}}        ), // 4-bit input: Port B write enable/Write enable
              // Port B Data inputs: Port B data
              .DINBDIN          ( {16{ff}}          ), // 16-bit input: Port B data/MSB data
              .DINPBDINP        ( {2{ff}}           )  // 2-bit input: Port B parity/MSB parity
           );

        end else begin

            // RAMB18E2: 18K-bit Configurable Synchronous Block RAM
            //           Virtex UltraScale+
            // Xilinx HDL Language Template, version 2026.1

            (*dont_touch = "true"*) RAMB18E2 #(
                .CASCADE_ORDER_A            ( "NONE"        ), // "FIRST", "MIDDLE", "LAST", "NONE"
                .CASCADE_ORDER_B            ( "NONE"        ), // "FIRST", "MIDDLE", "LAST", "NONE"
                .CLOCK_DOMAINS              ( "COMMON"      ), // "COMMON", "INDEPENDENT"
                .DOB_REG                    ( 1             ), // Optional output register (0, 1)
                .SIM_COLLISION_CHECK        ( "NONE"        ), // Collision check: "ALL", "GENERATE_X_ONLY", "NONE", "WARNING_ONLY"
                .DOA_REG                    ( 1             ), // Optional output register (0, 1)
                .ENADDRENA                  ( "FALSE"       ), // Address enable pin enable, "TRUE", "FALSE"
                .ENADDRENB                  ( "FALSE"       ), // Address enable pin enable, "TRUE", "FALSE"
                .IS_CLKARDCLK_INVERTED      ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_CLKBWRCLK_INVERTED      ( 1'b1          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_ENARDEN_INVERTED        ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_ENBWREN_INVERTED        ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_RSTRAMARSTRAM_INVERTED  ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_RSTRAMB_INVERTED        ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_RSTREGARSTREG_INVERTED  ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .IS_RSTREGB_INVERTED        ( 1'b0          ), // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
                .RDADDRCHANGEA              ( "FALSE"       ), // Disable memory access when output value does not change ("TRUE", "FALSE")
                .RDADDRCHANGEB              ( "FALSE"       ), // Disable memory access when output value does not change ("TRUE", "FALSE")
                .READ_WIDTH_A               ( 36            ), // Read width per port
                .WRITE_WIDTH_B              ( 36            ), // Write width per port
                .RSTREG_PRIORITY_A          ( "RSTREG"      ), // Reset or enable priority ("RSTREG", "REGCE")
                .RSTREG_PRIORITY_B          ( "RSTREG"      ), // Reset or enable priority ("RSTREG", "REGCE")
                .SLEEP_ASYNC                ( "FALSE"       ), // Sleep Async: Sleep function asynchronous or synchronous ("TRUE", "FALSE")
                .WRITE_MODE_A               ( "READ_FIRST"  ), // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
                .WRITE_MODE_B               ( "READ_FIRST"  )  // WriteMode: "WRITE_FIRST", "NO_CHANGE", "READ_FIRST"
            ) bram_inst (
                // Cascade Signals outputs: Multi-BRAM cascade signals
                .CASDOUTB           (               ), // 16-bit output: Port B cascade output data
                .CASDOUTA           (               ), // 16-bit output: Port A cascade output data
                .CASDOUTPA          (               ), // 2-bit  output: Port A cascade output parity data
                .CASDOUTPB          (               ), // 2-bit  output: Port B cascade output parity data
                .CASOUTDBITERR      (               ), // 1-bit  output: DBITERR cascade output
                .CASOUTSBITERR      (               ), // 1-bit  output: SBITERR cascade output
                // Port A Data outputs: Port A data
                .DOUTADOUT          (               ), // 16-bit output: Port A ata/LSB data
                .DOUTPADOUTP        (               ), // 2-bit  output: Port A parity/LSB parity
                // Port B Data outputs: Port B data
                .DOUTBDOUT          (               ), // 16-bit output: Port B data/MSB data
                .DOUTPBDOUTP        (               ), // 2-bit  output: Port B parity/MSB parity
                // Cascade Signals inputs: Multi-BRAM cascade signals
                .CASDIMUXA          ( 1'b0          ), // 1-bit  input: Port A input data (0=DINA, 1=CASDINA)
                .CASDIMUXB          ( 1'b0          ), // 1-bit  input: Port B input data (0=DINB, 1=CASDINB)
                .CASDINA            ( 16'b0         ), // 16-bit input: Port A cascade input data
                .CASDINB            ( 16'b0         ), // 16-bit input: Port B cascade input data
                .CASDINPA           ( 2'b0          ), // 2-bit  input: Port A cascade input parity data
                .CASDINPB           ( 2'b0          ), // 2-bit  input: Port B cascade input parity data
                .CASDOMUXA          ( 1'b0          ), // 1-bit  input: Port A unregistered data (0=BRAM data, 1=CASDINA)
                .CASDOMUXB          ( 1'b0          ), // 1-bit  input: Port B unregistered data (0=BRAM data, 1=CASDINB)
                .CASDOMUXEN_A       ( dummy         ), // 1-bit  input: Port A unregistered output data enable
                .CASDOMUXEN_B       ( dummy         ), // 1-bit  input: Port B unregistered output data enable
                .CASOREGIMUXA       ( 1'b0          ), // 1-bit  input: Port A registered data (0=BRAM data, 1=CASDINA)
                .CASOREGIMUXB       ( 1'b0          ), // 1-bit  input: Port B registered data (0=BRAM data, 1=CASDINB)
                .CASOREGIMUXEN_A    ( dummy         ), // 1-bit  input: Port A registered output data enable
                .CASOREGIMUXEN_B    ( dummy         ), // 1-bit  input: Port B registered output data enable
                // Port A Address/Control Signals inputs: Port A address and control signals
                .ADDRARDADDR        ( {14{ff}}      ), // 14-bit input: A/Read port address
                .ADDRENA            ( dummy         ), // 1-bit  input: Active-High A/Read port address enable
                .CLKARDCLK          ( clk           ), // 1-bit  input: A/Read port clock
                .ENARDEN            ( dummy         ), // 1-bit  input: Port A enable/Read enable
                .REGCEAREGCE        ( dummy         ), // 1-bit  input: Port A register enable/Register enable
                .RSTRAMARSTRAM      ( 1'b0          ), // 1-bit  input: Port A set/reset
                .RSTREGARSTREG      ( 1'b0          ), // 1-bit  input: Port A register set/reset
                .SLEEP              ( sleep         ), // 1-bit  input: Sleep Mode
                .WEA                ( {2{dummy}}    ), // 2-bit input: Port A byte-wide write enable. When used as SDP memory, this port is not used.
                // Port A Data inputs: Port A data
                .DINADIN            ( {16{ff}}      ), // 16-bit input: Port B data/MSB data
                .DINPADINP          ( {2{ff}}       ), // 2-bit  input: Port B parity/MSB parity
                // Port B Address/Control Signals inputs: Port B address and control signals
                .ADDRBWRADDR        ( {14{ff}}      ), // 14-bit input: B/Write port address
                .ADDRENB            ( dummy         ), // 1-bit  input: Active-High B/Write port address enable
                .CLKBWRCLK          ( clk           ), // 1-bit  input: B/Write port clock
                .ENBWREN            ( dummy         ), // 1-bit  input: Port B enable/Write enable
                .REGCEB             ( dummy         ), // 1-bit  input: Port B register enable
                .RSTRAMB            ( 1'b0          ), // 1-bit  input: Port B set/reset
                .RSTREGB            ( 1'b0          ), // 1-bit  input: Port B register set/reset
                .WEBWE              ( {4{dummy}}    ), // 4-bit  input: Port B write enable/Write enable. In SDP mode, this is the byte-wide write enable.
                 // Port B Data inputs: Port B data
                .DINBDIN            ( {16{ff}}      ), // 16-bit input: Port B data/MSB data
                .DINPBDINP          ( {2{ff}}       )  // 2-bit  input: Port B parity/MSB parity
            );

        end
    endgenerate

endmodule
`default_nettype wire
