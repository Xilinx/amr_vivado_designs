// Copyright (C) 2025 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT

`timescale 1 ps / 1 ps

module ve2302_xdma_base_wrapper
   (
    ch0_lpddr4_trip1_ca_a,
    ch0_lpddr4_trip1_ca_b,
    ch0_lpddr4_trip1_ck_c_a,
    ch0_lpddr4_trip1_ck_c_b,
    ch0_lpddr4_trip1_ck_t_a,
    ch0_lpddr4_trip1_ck_t_b,
    ch0_lpddr4_trip1_cke_a,
    ch0_lpddr4_trip1_cke_b,
    ch0_lpddr4_trip1_cs_a,
    ch0_lpddr4_trip1_cs_b,
    ch0_lpddr4_trip1_dmi_a,
    ch0_lpddr4_trip1_dmi_b,
    ch0_lpddr4_trip1_dq_a,
    ch0_lpddr4_trip1_dq_b,
    ch0_lpddr4_trip1_dqs_c_a,
    ch0_lpddr4_trip1_dqs_c_b,
    ch0_lpddr4_trip1_dqs_t_a,
    ch0_lpddr4_trip1_dqs_t_b,
    ch0_lpddr4_trip1_reset_n,
    ch1_lpddr4_trip1_ca_a,
    ch1_lpddr4_trip1_ca_b,
    ch1_lpddr4_trip1_ck_c_a,
    ch1_lpddr4_trip1_ck_c_b,
    ch1_lpddr4_trip1_ck_t_a,
    ch1_lpddr4_trip1_ck_t_b,
    ch1_lpddr4_trip1_cke_a,
    ch1_lpddr4_trip1_cke_b,
    ch1_lpddr4_trip1_cs_a,
    ch1_lpddr4_trip1_cs_b,
    ch1_lpddr4_trip1_dmi_a,
    ch1_lpddr4_trip1_dmi_b,
    ch1_lpddr4_trip1_dq_a,
    ch1_lpddr4_trip1_dq_b,
    ch1_lpddr4_trip1_dqs_c_a,
    ch1_lpddr4_trip1_dqs_c_b,
    ch1_lpddr4_trip1_dqs_t_a,
    ch1_lpddr4_trip1_dqs_t_b,
    ch1_lpddr4_trip1_reset_n,
    clk1_25MHz,
    clk2_25MHz,
    gt_pciea0_grx_n,
    gt_pciea0_grx_p,
    gt_pciea0_gtx_n,
    gt_pciea0_gtx_p,
    lpddr4_clk1_clk_n,
    lpddr4_clk1_clk_p,
    mdc_0,
    mdc_1,
    mdio_0,
    mdio_1,
    pcie_refclk_clk_n,
    pcie_refclk_clk_p,
    reset_phy_0_n,
    reset_phy_1_n,
    rgmii_0_rd,
    rgmii_0_rx_ctl,
    rgmii_0_rxc,
    rgmii_0_td,
    rgmii_0_tx_ctl,
    rgmii_0_txc,
    rgmii_1_rd,
    rgmii_1_rx_ctl,
    rgmii_1_rxc,
    rgmii_1_td,
    rgmii_1_tx_ctl,
    rgmii_1_txc,
    CLK_IN_D_clk_n,
    CLK_IN_D_clk_p,
    GT_Serial_grx_n,
    GT_Serial_grx_p,
    GT_Serial_gtx_n,
    GT_Serial_gtx_p
  );
  output [5:0]ch0_lpddr4_trip1_ca_a;
  output [5:0]ch0_lpddr4_trip1_ca_b;
  output ch0_lpddr4_trip1_ck_c_a;
  output ch0_lpddr4_trip1_ck_c_b;
  output ch0_lpddr4_trip1_ck_t_a;
  output ch0_lpddr4_trip1_ck_t_b;
  output ch0_lpddr4_trip1_cke_a;
  output ch0_lpddr4_trip1_cke_b;
  output ch0_lpddr4_trip1_cs_a;
  output ch0_lpddr4_trip1_cs_b;
  inout [1:0]ch0_lpddr4_trip1_dmi_a;
  inout [1:0]ch0_lpddr4_trip1_dmi_b;
  inout [15:0]ch0_lpddr4_trip1_dq_a;
  inout [15:0]ch0_lpddr4_trip1_dq_b;
  inout [1:0]ch0_lpddr4_trip1_dqs_c_a;
  inout [1:0]ch0_lpddr4_trip1_dqs_c_b;
  inout [1:0]ch0_lpddr4_trip1_dqs_t_a;
  inout [1:0]ch0_lpddr4_trip1_dqs_t_b;
  output ch0_lpddr4_trip1_reset_n;
  output [5:0]ch1_lpddr4_trip1_ca_a;
  output [5:0]ch1_lpddr4_trip1_ca_b;
  output ch1_lpddr4_trip1_ck_c_a;
  output ch1_lpddr4_trip1_ck_c_b;
  output ch1_lpddr4_trip1_ck_t_a;
  output ch1_lpddr4_trip1_ck_t_b;
  output ch1_lpddr4_trip1_cke_a;
  output ch1_lpddr4_trip1_cke_b;
  output ch1_lpddr4_trip1_cs_a;
  output ch1_lpddr4_trip1_cs_b;
  inout [1:0]ch1_lpddr4_trip1_dmi_a;
  inout [1:0]ch1_lpddr4_trip1_dmi_b;
  inout [15:0]ch1_lpddr4_trip1_dq_a;
  inout [15:0]ch1_lpddr4_trip1_dq_b;
  inout [1:0]ch1_lpddr4_trip1_dqs_c_a;
  inout [1:0]ch1_lpddr4_trip1_dqs_c_b;
  inout [1:0]ch1_lpddr4_trip1_dqs_t_a;
  inout [1:0]ch1_lpddr4_trip1_dqs_t_b;
  output ch1_lpddr4_trip1_reset_n;
  input [3:0]gt_pciea0_grx_n;
  input [3:0]gt_pciea0_grx_p;
  output [3:0]gt_pciea0_gtx_n;
  output [3:0]gt_pciea0_gtx_p;
  input lpddr4_clk1_clk_n;
  input lpddr4_clk1_clk_p;
  input [0:0]pcie_refclk_clk_n;
  input [0:0]pcie_refclk_clk_p;
  (* io_buffer_type = "none" *) input clk1_25MHz;
  (* io_buffer_type = "none" *) input clk2_25MHz;
  (* io_buffer_type = "none" *) inout mdc_0;
  (* io_buffer_type = "none" *) inout mdc_1;
  (* io_buffer_type = "none" *) inout mdio_0;
  (* io_buffer_type = "none" *) inout mdio_1;
  (* io_buffer_type = "none" *) inout reset_phy_0_n;
  (* io_buffer_type = "none" *) inout reset_phy_1_n;
  (* io_buffer_type = "none" *) input [3:0]rgmii_0_rd;
  (* io_buffer_type = "none" *) input rgmii_0_rx_ctl;
  (* io_buffer_type = "none" *) input rgmii_0_rxc;
  (* io_buffer_type = "none" *) output [3:0]rgmii_0_td;
  (* io_buffer_type = "none" *) output rgmii_0_tx_ctl;
  (* io_buffer_type = "none" *) output rgmii_0_txc;
  (* io_buffer_type = "none" *) input [3:0]rgmii_1_rd;
  (* io_buffer_type = "none" *) input rgmii_1_rx_ctl;
  (* io_buffer_type = "none" *) input rgmii_1_rxc;
  (* io_buffer_type = "none" *) output [3:0]rgmii_1_td;
  (* io_buffer_type = "none" *) output rgmii_1_tx_ctl;
  (* io_buffer_type = "none" *) output rgmii_1_txc;
  (* io_buffer_type = "none" *) input [1:0]GT_Serial_grx_n;
  (* io_buffer_type = "none" *) input [1:0]GT_Serial_grx_p;
  (* io_buffer_type = "none" *) output [1:0]GT_Serial_gtx_n;
  (* io_buffer_type = "none" *) output [1:0]GT_Serial_gtx_p;
  (* io_buffer_type = "none" *) input CLK_IN_D_clk_n;
  (* io_buffer_type = "none" *) input CLK_IN_D_clk_p;

  wire [5:0]ch0_lpddr4_trip1_ca_a;
  wire [5:0]ch0_lpddr4_trip1_ca_b;
  wire ch0_lpddr4_trip1_ck_c_a;
  wire ch0_lpddr4_trip1_ck_c_b;
  wire ch0_lpddr4_trip1_ck_t_a;
  wire ch0_lpddr4_trip1_ck_t_b;
  wire ch0_lpddr4_trip1_cke_a;
  wire ch0_lpddr4_trip1_cke_b;
  wire ch0_lpddr4_trip1_cs_a;
  wire ch0_lpddr4_trip1_cs_b;
  wire [1:0]ch0_lpddr4_trip1_dmi_a;
  wire [1:0]ch0_lpddr4_trip1_dmi_b;
  wire [15:0]ch0_lpddr4_trip1_dq_a;
  wire [15:0]ch0_lpddr4_trip1_dq_b;
  wire [1:0]ch0_lpddr4_trip1_dqs_c_a;
  wire [1:0]ch0_lpddr4_trip1_dqs_c_b;
  wire [1:0]ch0_lpddr4_trip1_dqs_t_a;
  wire [1:0]ch0_lpddr4_trip1_dqs_t_b;
  wire ch0_lpddr4_trip1_reset_n;
  wire [5:0]ch1_lpddr4_trip1_ca_a;
  wire [5:0]ch1_lpddr4_trip1_ca_b;
  wire ch1_lpddr4_trip1_ck_c_a;
  wire ch1_lpddr4_trip1_ck_c_b;
  wire ch1_lpddr4_trip1_ck_t_a;
  wire ch1_lpddr4_trip1_ck_t_b;
  wire ch1_lpddr4_trip1_cke_a;
  wire ch1_lpddr4_trip1_cke_b;
  wire ch1_lpddr4_trip1_cs_a;
  wire ch1_lpddr4_trip1_cs_b;
  wire [1:0]ch1_lpddr4_trip1_dmi_a;
  wire [1:0]ch1_lpddr4_trip1_dmi_b;
  wire [15:0]ch1_lpddr4_trip1_dq_a;
  wire [15:0]ch1_lpddr4_trip1_dq_b;
  wire [1:0]ch1_lpddr4_trip1_dqs_c_a;
  wire [1:0]ch1_lpddr4_trip1_dqs_c_b;
  wire [1:0]ch1_lpddr4_trip1_dqs_t_a;
  wire [1:0]ch1_lpddr4_trip1_dqs_t_b;
  wire ch1_lpddr4_trip1_reset_n;
  wire clk1_25MHz;
  wire clk2_25MHz;
  wire [3:0]gt_pciea0_grx_n;
  wire [3:0]gt_pciea0_grx_p;
  wire [3:0]gt_pciea0_gtx_n;
  wire [3:0]gt_pciea0_gtx_p;
  wire lpddr4_clk1_clk_n;
  wire lpddr4_clk1_clk_p;
  wire mdc_0;
  wire mdc_1;
  wire mdio_0;
  wire mdio_1;
  wire [0:0]pcie_refclk_clk_n;
  wire [0:0]pcie_refclk_clk_p;
  wire reset_phy_0_n;
  wire reset_phy_1_n;
  wire [3:0]rgmii_0_rd;
  wire rgmii_0_rx_ctl;
  wire rgmii_0_rxc;
  wire [3:0]rgmii_0_td;
  wire rgmii_0_tx_ctl;
  wire rgmii_0_txc;
  wire [3:0]rgmii_1_rd;
  wire rgmii_1_rx_ctl;
  wire rgmii_1_rxc;
  wire [3:0]rgmii_1_td;
  wire rgmii_1_tx_ctl;
  wire rgmii_1_txc;
  wire [1:0]GT_Serial_grx_n;
  wire [1:0]GT_Serial_grx_p;
  wire [1:0]GT_Serial_gtx_n;
  wire [1:0]GT_Serial_gtx_p;

  ve2302_xdma_base ve2302_xdma_base_i
       (
        .ch0_lpddr4_trip1_ca_a(ch0_lpddr4_trip1_ca_a),
        .ch0_lpddr4_trip1_ca_b(ch0_lpddr4_trip1_ca_b),
        .ch0_lpddr4_trip1_ck_c_a(ch0_lpddr4_trip1_ck_c_a),
        .ch0_lpddr4_trip1_ck_c_b(ch0_lpddr4_trip1_ck_c_b),
        .ch0_lpddr4_trip1_ck_t_a(ch0_lpddr4_trip1_ck_t_a),
        .ch0_lpddr4_trip1_ck_t_b(ch0_lpddr4_trip1_ck_t_b),
        .ch0_lpddr4_trip1_cke_a(ch0_lpddr4_trip1_cke_a),
        .ch0_lpddr4_trip1_cke_b(ch0_lpddr4_trip1_cke_b),
        .ch0_lpddr4_trip1_cs_a(ch0_lpddr4_trip1_cs_a),
        .ch0_lpddr4_trip1_cs_b(ch0_lpddr4_trip1_cs_b),
        .ch0_lpddr4_trip1_dmi_a(ch0_lpddr4_trip1_dmi_a),
        .ch0_lpddr4_trip1_dmi_b(ch0_lpddr4_trip1_dmi_b),
        .ch0_lpddr4_trip1_dq_a(ch0_lpddr4_trip1_dq_a),
        .ch0_lpddr4_trip1_dq_b(ch0_lpddr4_trip1_dq_b),
        .ch0_lpddr4_trip1_dqs_c_a(ch0_lpddr4_trip1_dqs_c_a),
        .ch0_lpddr4_trip1_dqs_c_b(ch0_lpddr4_trip1_dqs_c_b),
        .ch0_lpddr4_trip1_dqs_t_a(ch0_lpddr4_trip1_dqs_t_a),
        .ch0_lpddr4_trip1_dqs_t_b(ch0_lpddr4_trip1_dqs_t_b),
        .ch0_lpddr4_trip1_reset_n(ch0_lpddr4_trip1_reset_n),
        .ch1_lpddr4_trip1_ca_a(ch1_lpddr4_trip1_ca_a),
        .ch1_lpddr4_trip1_ca_b(ch1_lpddr4_trip1_ca_b),
        .ch1_lpddr4_trip1_ck_c_a(ch1_lpddr4_trip1_ck_c_a),
        .ch1_lpddr4_trip1_ck_c_b(ch1_lpddr4_trip1_ck_c_b),
        .ch1_lpddr4_trip1_ck_t_a(ch1_lpddr4_trip1_ck_t_a),
        .ch1_lpddr4_trip1_ck_t_b(ch1_lpddr4_trip1_ck_t_b),
        .ch1_lpddr4_trip1_cke_a(ch1_lpddr4_trip1_cke_a),
        .ch1_lpddr4_trip1_cke_b(ch1_lpddr4_trip1_cke_b),
        .ch1_lpddr4_trip1_cs_a(ch1_lpddr4_trip1_cs_a),
        .ch1_lpddr4_trip1_cs_b(ch1_lpddr4_trip1_cs_b),
        .ch1_lpddr4_trip1_dmi_a(ch1_lpddr4_trip1_dmi_a),
        .ch1_lpddr4_trip1_dmi_b(ch1_lpddr4_trip1_dmi_b),
        .ch1_lpddr4_trip1_dq_a(ch1_lpddr4_trip1_dq_a),
        .ch1_lpddr4_trip1_dq_b(ch1_lpddr4_trip1_dq_b),
        .ch1_lpddr4_trip1_dqs_c_a(ch1_lpddr4_trip1_dqs_c_a),
        .ch1_lpddr4_trip1_dqs_c_b(ch1_lpddr4_trip1_dqs_c_b),
        .ch1_lpddr4_trip1_dqs_t_a(ch1_lpddr4_trip1_dqs_t_a),
        .ch1_lpddr4_trip1_dqs_t_b(ch1_lpddr4_trip1_dqs_t_b),
        .ch1_lpddr4_trip1_reset_n(ch1_lpddr4_trip1_reset_n),
        .clk1_25MHz(clk1_25MHz),
        .clk2_25MHz(clk2_25MHz),
        .gt_pciea0_grx_n(gt_pciea0_grx_n),
        .gt_pciea0_grx_p(gt_pciea0_grx_p),
        .gt_pciea0_gtx_n(gt_pciea0_gtx_n),
        .gt_pciea0_gtx_p(gt_pciea0_gtx_p),
        .lpddr4_clk1_clk_n(lpddr4_clk1_clk_n),
        .lpddr4_clk1_clk_p(lpddr4_clk1_clk_p),
        .mdc_0(mdc_0),
        .mdc_1(mdc_1),
        .mdio_0(mdio_0),
        .mdio_1(mdio_1),
        .pcie_refclk_clk_n(pcie_refclk_clk_n),
        .pcie_refclk_clk_p(pcie_refclk_clk_p),
        .reset_phy_0_n(reset_phy_0_n),
        .reset_phy_1_n(reset_phy_1_n),
        .rgmii_0_rd(rgmii_0_rd),
        .rgmii_0_rx_ctl(rgmii_0_rx_ctl),
        .rgmii_0_rxc(rgmii_0_rxc),
        .rgmii_0_td(rgmii_0_td),
        .rgmii_0_tx_ctl(rgmii_0_tx_ctl),
        .rgmii_0_txc(rgmii_0_txc),
        .rgmii_1_rd(rgmii_1_rd),
        .rgmii_1_rx_ctl(rgmii_1_rx_ctl),
        .rgmii_1_rxc(rgmii_1_rxc),
        .rgmii_1_td(rgmii_1_td),
        .rgmii_1_tx_ctl(rgmii_1_tx_ctl),
        .rgmii_1_txc(rgmii_1_txc),
        .GT_Serial_grx_n(GT_Serial_grx_n),
        .GT_Serial_grx_p(GT_Serial_grx_p),
        .GT_Serial_gtx_n(GT_Serial_gtx_n),
        .GT_Serial_gtx_p(GT_Serial_gtx_p),
        .CLK_IN_D_clk_n(CLK_IN_D_clk_n),
        .CLK_IN_D_clk_p(CLK_IN_D_clk_p));
endmodule
