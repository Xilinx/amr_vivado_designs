// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP - Top Level Register Interface
//            - Version Information
//            - Interrupt Control
//
////////////////////////////////////////////////////////////

//(* DowngradeIPIdentifiedWarnings="yes" *)
module smbus_v1_1_top_reg
  import smbus_v1_1_pkg::*;
#(
  parameter int C_MAJOR_VERSION       = 1,        // IP Major Version
  parameter int C_MINOR_VERSION       = 0,        // IP Minor Version
  parameter int C_CORE_REVISION       = 0,        // IP Core Revision
  parameter int C_PATCH_REVISION      = 0,        // IP Patch Revision
  parameter int C_NUM_TARGET_DEVICES  = 8,        // Number of supported Target devices
  parameter int C_SMBUS_DEV_CLASS     = 0,        // Default SMBus Device Class (100KHz/400KHz/1MHz)
  parameter int C_FREQ_HZ_AXI_ACLK    = 100000000 // AXI ACLK Frequency (Hz)
) (
  // Register Interface
  smbus_v1_1_reg_if.sub             reg_top_if,

  // Clock/Reset
  input  logic                      clk,
  input  logic                      resetn,

  // Interrupts
  input  phy_cmn_irq_t              phy_cmn_irq,
  input  tgt_phy_irq_t              tgt_phy_irq,
  input  tgt_irq_t                  tgt_irq,
  input  ctlr_phy_irq_t             ctlr_phy_irq,
  input  ctlr_irq_t                 ctlr_irq,
  output logic                      ip2intc_irpt
);

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------
localparam bit [31:0] C_MAGIC_NUM           = 32'h534D_4273;
localparam int        C_ADDR_WIDTH          = $bits(reg_top_if.reg_wr_addr);
localparam int        C_NUM_IRQS            = 16;
localparam int        C_NUM_ERR_IRQS        = 20;

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// --------------------------------------------------------
// Variables/Nets
// --------------------------------------------------------

logic [C_NUM_IRQS-1:0]      top_irq_in;
logic                       gie;
logic [C_NUM_IRQS-1:0]      ier;
logic [C_NUM_IRQS-1:0]      isr;
logic [C_NUM_IRQS-1:0]      isr_reset;
logic [C_NUM_IRQS-1:0]      isr_force;

logic [C_NUM_ERR_IRQS-1:0]  err_irq_in;
logic                       error_irq;
logic [C_NUM_ERR_IRQS-1:0]  err_ier;
logic [C_NUM_ERR_IRQS-1:0]  err_isr;
logic [C_NUM_ERR_IRQS-1:0]  err_isr_reset;
logic [C_NUM_ERR_IRQS-1:0]  err_isr_force;

// ========================================================
// Interrupt Control

// Top Level Interrupts
assign top_irq_in[0]   = error_irq;
assign top_irq_in[1]   = tgt_phy_irq.loa;
assign top_irq_in[2]   = tgt_irq.pec_error;
assign top_irq_in[3]   = tgt_irq.done;
assign top_irq_in[4]   = tgt_irq.desc_fifo_empty;
assign top_irq_in[5]   = tgt_irq.rx_fifo_fill_threshold;
assign top_irq_in[6]   = tgt_irq.read;
assign top_irq_in[7]   = tgt_irq.write;
assign top_irq_in[8]   = tgt_irq.desc_fifo_almost_empty;
assign top_irq_in[9]   = ctlr_phy_irq.loa;
assign top_irq_in[10]  = ctlr_phy_irq.nack_err;
assign top_irq_in[11]  = ctlr_irq.pec_error;
assign top_irq_in[12]  = ctlr_irq.done;
assign top_irq_in[13]  = ctlr_irq.desc_fifo_empty;
assign top_irq_in[14]  = ctlr_irq.rx_fifo_fill_threshold;
assign top_irq_in[15]  = ctlr_irq.desc_fifo_almost_empty;

// Update the ISR and top level interrupt output
always_ff @(posedge clk) begin
  if (!resetn) begin
    isr           <= '0;
    ip2intc_irpt  <= '0;
  end else begin
    // Defaults
    ip2intc_irpt  <= '0;

    // Update the Interrupt Status Register
    for (int i=0; i<C_NUM_IRQS; i++) begin
      if (top_irq_in[i] || isr_force[i]) begin
        // Set the interrupt status when the input is asserted or forced via register interface
        isr[i]  <= '1;
      end else if (isr_reset[i]) begin
        // Clear the interrupt status when set via register interface
        isr[i]  <= '0;
      end
    end

    // Gate the top level interrupt based on GIE
    if (gie) begin
      // Once enabled, assert the top level interrupt if both ISR and IER are set
      ip2intc_irpt  <= |(isr & ier);
    end
  end
end

// Error Interrupts
// Infrequent errors are combined in a second stage that feed forward into the top on error_irq.
// This is to minimize the number of two register reads that s/w needs to do in order to
// determine the complete interrupt status.
assign err_irq_in[0]   = phy_cmn_irq.smbclk_low_timeout;
assign err_irq_in[1]   = phy_cmn_irq.smbdat_low_timeout;
assign err_irq_in[2]   = phy_cmn_irq.unexpected_bus_idle;
assign err_irq_in[3]   = tgt_irq.desc_error;
assign err_irq_in[4]   = tgt_irq.desc_fifo_underflow;
assign err_irq_in[5]   = tgt_irq.desc_fifo_overflow;
assign err_irq_in[6]   = tgt_irq.desc_fifo_error;
assign err_irq_in[7]   = tgt_irq.rx_fifo_underflow;
assign err_irq_in[8]   = tgt_irq.rx_fifo_overflow;
assign err_irq_in[9]   = tgt_irq.rx_fifo_error;
assign err_irq_in[10]  = tgt_phy_irq.text_timeout;
assign err_irq_in[11]  = ctlr_irq.desc_error;
assign err_irq_in[12]  = ctlr_irq.desc_fifo_underflow;
assign err_irq_in[13]  = ctlr_irq.desc_fifo_overflow;
assign err_irq_in[14]  = ctlr_irq.desc_fifo_error;
assign err_irq_in[15]  = ctlr_irq.rx_fifo_underflow;
assign err_irq_in[16]  = ctlr_irq.rx_fifo_overflow;
assign err_irq_in[17]  = ctlr_irq.rx_fifo_error;
assign err_irq_in[18]  = ctlr_phy_irq.text_timeout;
assign err_irq_in[19]  = ctlr_phy_irq.cext_timeout;

always_ff @(posedge clk) begin
  if (!resetn) begin
    error_irq   <= '0;
    err_isr     <= '0;
  end else begin
    // Update Error Interrupt Status Register
    for (int i=0; i<C_NUM_ERR_IRQS; i++) begin
      if (err_irq_in[i] || err_isr_force[i]) begin
        // Set the interrupt status when the input is asserted or forced via register interface
        err_isr[i]  <= '1;
      end else if (err_isr_reset[i]) begin
        // Clear the interrupt status when set via register interface
        err_isr[i]  <= '0;
      end
    end

    // Assert the error interrupt if both ISR and IER are set
    error_irq  <= |(err_isr & err_ier);
  end
end

// ========================================================

// Register Interface - Write
always_ff @(posedge clk) begin
  if (!resetn) begin
    gie                     <= '0;
    ier                     <= '0;
    isr_reset               <= '0;
    err_ier                 <= '0;
    err_isr_reset           <= '0;
    isr_force               <= '0;
    err_isr_force           <= '0;
    reg_top_if.reg_wr_done  <= '0;
  end else begin
    // Defaults
    reg_top_if.reg_wr_done  <= '0;
    isr_reset               <= '0;
    err_isr_reset           <= '0;
    isr_force               <= '0;
    err_isr_force           <= '0;

    if (reg_top_if.reg_wr_valid) begin
      // Exclude unused address space to prevent aliasing
      if (!(|reg_top_if.reg_wr_addr[C_ADDR_WIDTH-1:6])) begin
        case (reg_top_if.reg_wr_addr[5:0]) inside
          // IRQ GIE - 0x20
          6'b1000??: gie            <= reg_top_if.reg_wr_data[0];
          // IRQ IER - 0x24
          6'b1001??: ier            <= reg_top_if.reg_wr_data[C_NUM_IRQS-1:0];
          // IRQ ISR - 0x28
          6'b1010??: isr_reset      <= reg_top_if.reg_wr_data[C_NUM_IRQS-1:0];
          // Error IRQ IER - 0x2C
          6'b1011??: err_ier        <= reg_top_if.reg_wr_data[C_NUM_ERR_IRQS-1:0];
          // Error IRQ ISR - 0x30
          6'b1100??: err_isr_reset  <= reg_top_if.reg_wr_data[C_NUM_ERR_IRQS-1:0];
          // IRQ ISR Force - 0x34
          6'b1101??: isr_force      <= reg_top_if.reg_wr_data[C_NUM_IRQS-1:0];
          // Error IRQ ISR Force - 0x38
          6'b1110??: err_isr_force  <= reg_top_if.reg_wr_data[C_NUM_ERR_IRQS-1:0];
        endcase
      end
      // Signal write done
      reg_top_if.reg_wr_done <= 1'b1;
    end
  end
end

// Always respond with OKAY to writes
assign reg_top_if.reg_wr_resp = '0;

// Register Interface - Read
always_ff @(posedge clk) begin
  //Defaults
  reg_top_if.reg_rd_data <= '0;
  reg_top_if.reg_rd_done <= '0;

  if (reg_top_if.reg_rd_valid) begin
    // Return 0 from unused address space to prevent aliasing
    if (!(|reg_top_if.reg_rd_addr[C_ADDR_WIDTH-1:6])) begin
      case (reg_top_if.reg_rd_addr[5:0]) inside
        // Major/Minor Version - 0x00
        6'b0000??:
          begin
            reg_top_if.reg_rd_data[31:16]                      <= C_MAJOR_VERSION;
            reg_top_if.reg_rd_data[15:0]                       <= C_MINOR_VERSION;
          end
        // Patch/Core Revision - 0x04
        6'b0001??:
          begin
            reg_top_if.reg_rd_data[31:16]                      <= C_PATCH_REVISION;
            reg_top_if.reg_rd_data[15:0]                       <= C_CORE_REVISION;
          end
        // Magic Number - 0x08
        6'b0010??: reg_top_if.reg_rd_data                      <= C_MAGIC_NUM;
        // Build Config 0 - 0x0C
        6'b0011??: reg_top_if.reg_rd_data                      <= C_FREQ_HZ_AXI_ACLK;
        // Build Config 1 - 0x10
        6'b0100??:
          begin
            reg_top_if.reg_rd_data[7:4]                        <= (4)'(C_NUM_TARGET_DEVICES);
            reg_top_if.reg_rd_data[3:0]                        <= (4)'(C_SMBUS_DEV_CLASS);
          end
        // IRQ GIE - 0x20
        6'b1000??: reg_top_if.reg_rd_data[0]                   <= gie;
        // IRQ IER - 0x24
        6'b1001??: reg_top_if.reg_rd_data[C_NUM_IRQS-1:0]      <= ier;
        // IRQ ISR - 0x28
        6'b1010??: reg_top_if.reg_rd_data[C_NUM_IRQS-1:0]      <= isr;
        // Error IRQ IER - 0x2C
        6'b1011??: reg_top_if.reg_rd_data[C_NUM_ERR_IRQS-1:0]  <= err_ier;
        // Error IRQ ISR - 0x30
        6'b1100??: reg_top_if.reg_rd_data[C_NUM_ERR_IRQS-1:0]  <= err_isr;
        default:   reg_top_if.reg_rd_data                      <= '0;
      endcase
    end
    // Signal read done
    reg_top_if.reg_rd_done <= 1'b1;
  end
end

// Always respond with OKAY to reads
assign reg_top_if.reg_rd_resp = '0;

endmodule : smbus_v1_1_top_reg
