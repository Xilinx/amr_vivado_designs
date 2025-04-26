`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2017 12:03:43 PM
// Design Name: 
// Module Name: axi_addr_remap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_addr_remap #(
    parameter S_AXI_ADDR_WIDTH = 32,
    parameter M_AXI_ADDR_WIDTH = 32,
    parameter [S_AXI_ADDR_WIDTH-1:0] REMAP_ADDR = 64'h00000000,
    parameter [M_AXI_ADDR_WIDTH-1:0] TRANS_ADDR = 64'h00000000) (
input                 s_axi_aclk,
input                 s_axi_aresetn,
input  [S_AXI_ADDR_WIDTH-1:0]         s_axi_awaddr,
input                 s_axi_awvalid,
output                s_axi_awready,
input  [31:0]         s_axi_wdata,
input  [3:0]          s_axi_wstrb,
input                 s_axi_wvalid,
output                s_axi_wready,
output [1:0]          s_axi_bresp,
output                s_axi_bvalid,
input                 s_axi_bready,
input  [S_AXI_ADDR_WIDTH-1:0]         s_axi_araddr,
input                 s_axi_arvalid,
output                s_axi_arready,
output [31:0]         s_axi_rdata,
output [1:0]          s_axi_rresp,
output                s_axi_rvalid,
input                 s_axi_rready,

input                 m_axi_aclk,
input                 m_axi_aresetn,
output  [M_AXI_ADDR_WIDTH-1:0]        m_axi_awaddr,
output                m_axi_awvalid,
input                 m_axi_awready,
output  [31:0]        m_axi_wdata,
output  [3:0]         m_axi_wstrb,
output                m_axi_wvalid,
input                 m_axi_wready,
output                m_axi_wlast,
input [1:0]           m_axi_bresp,
input                 m_axi_bvalid,
output                m_axi_bready,
output  [M_AXI_ADDR_WIDTH-1:0]        m_axi_araddr,
output                m_axi_arvalid,
input                 m_axi_arready,
input [31:0]          m_axi_rdata,
input [1:0]           m_axi_rresp,
input                 m_axi_rvalid,
output                m_axi_rready

   );
   
   assign m_axi_awaddr  = s_axi_awaddr-REMAP_ADDR+TRANS_ADDR;
   assign m_axi_awvalid = s_axi_awvalid;
   assign s_axi_awready = m_axi_awready;
   assign m_axi_wdata   = s_axi_wdata; 
   assign m_axi_wstrb   = s_axi_wstrb;
   assign m_axi_wvalid  = s_axi_wvalid;
   assign s_axi_wready  = m_axi_wready;
   assign s_axi_bresp   = m_axi_bresp;
   assign s_axi_bvalid  = m_axi_bvalid;
   assign m_axi_bready  = s_axi_bready;
   assign m_axi_araddr  = s_axi_araddr-REMAP_ADDR+TRANS_ADDR;
   assign m_axi_arvalid = s_axi_arvalid;
   assign s_axi_arready = m_axi_arready;
   assign s_axi_rdata   = m_axi_rdata;
   assign s_axi_rresp   = m_axi_rresp;
   assign s_axi_rvalid  = m_axi_rvalid;
   assign m_axi_rready  = s_axi_rready;


   
endmodule
