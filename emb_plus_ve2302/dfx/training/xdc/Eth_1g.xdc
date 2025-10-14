# Copyright (C) 2024 - 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

########################################################
###
### XDC for Axi Ethernet Subsystem design for RAVE DFX
###
########################################################
create_clock -period 40.000 [get_ports clk1_25MHz]
create_clock -period 40.000 [get_ports clk2_25MHz]


# Bank 703
set_property PACKAGE_PIN D27 [get_ports mdio_0]
set_property IOSTANDARD LVCMOS12 [get_ports mdio_0]
set_property SLEW SLOW [get_ports mdio_0]
set_property DRIVE 8 [get_ports mdio_0]

# Bank 703
set_property PACKAGE_PIN B28 [get_ports mdc_0]
set_property IOSTANDARD LVCMOS12 [get_ports mdc_0]
set_property SLEW SLOW [get_ports mdc_0]
set_property DRIVE 8 [get_ports mdc_0]

# Bank 703
set_property PACKAGE_PIN H25 [get_ports rgmii_0_txc]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_0_txc]
set_property SLEW SLOW [get_ports rgmii_0_txc]
set_property DRIVE 8 [get_ports rgmii_0_txc]

# Bank 703
set_property PACKAGE_PIN J26 [get_ports rgmii_0_tx_ctl]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_0_tx_ctl]
set_property SLEW SLOW [get_ports rgmii_0_tx_ctl]
set_property DRIVE 8 [get_ports rgmii_0_tx_ctl]

# Bank 703
set_property PACKAGE_PIN E26 [get_ports {rgmii_0_td[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_td[3]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[3]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[3]}]

# Bank 703
set_property PACKAGE_PIN F26 [get_ports {rgmii_0_td[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_td[2]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[2]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[2]}]

# Bank 703
set_property PACKAGE_PIN G26 [get_ports {rgmii_0_td[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_td[1]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[1]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[1]}]

# Bank 703
set_property PACKAGE_PIN G25 [get_ports {rgmii_0_td[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_td[0]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[0]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[0]}]

# Bank 703
set_property PACKAGE_PIN C25 [get_ports rgmii_0_rxc]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_0_rxc]
set_property SLEW SLOW [get_ports rgmii_0_rxc]
set_property DRIVE 8 [get_ports rgmii_0_rxc]
set_property PULLDOWN TRUE [get_ports rgmii_0_rxc]

# Bank 703
set_property PACKAGE_PIN B25 [get_ports rgmii_0_rx_ctl]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_0_rx_ctl]
set_property SLEW SLOW [get_ports rgmii_0_rx_ctl]
set_property DRIVE 8 [get_ports rgmii_0_rx_ctl]
set_property PULLDOWN TRUE [get_ports rgmii_0_rx_ctl]

# Bank 703
set_property PACKAGE_PIN B27 [get_ports {rgmii_0_rd[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_rd[3]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[3]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[3]}]
set_property PULLUP TRUE [get_ports rgmii_0_rd[3]]

# Bank 703
set_property PACKAGE_PIN B26 [get_ports {rgmii_0_rd[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_rd[2]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[2]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[2]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[2]]

# Bank 703
set_property PACKAGE_PIN A26 [get_ports {rgmii_0_rd[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_rd[1]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[1]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[1]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[1]]

# Bank 703
set_property PACKAGE_PIN A25 [get_ports {rgmii_0_rd[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_0_rd[0]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[0]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[0]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[0]]

# Bank 703
set_property PACKAGE_PIN C27 [get_ports reset_phy_0_n]
set_property IOSTANDARD LVCMOS12 [get_ports reset_phy_0_n]
set_property SLEW SLOW [get_ports reset_phy_0_n]
set_property DRIVE 8 [get_ports reset_phy_0_n]

# Bank 703
set_property PACKAGE_PIN A20 [get_ports mdio_1]
set_property IOSTANDARD LVCMOS12 [get_ports mdio_1]
set_property SLEW SLOW [get_ports mdio_1]
set_property DRIVE 8 [get_ports mdio_1]

# Bank 703
set_property PACKAGE_PIN A21 [get_ports mdc_1]
set_property IOSTANDARD LVCMOS12 [get_ports mdc_1]
set_property SLEW SLOW [get_ports mdc_1]
set_property DRIVE 8 [get_ports mdc_1]

# Bank 703
set_property PACKAGE_PIN H23 [get_ports rgmii_1_txc]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_1_txc]
set_property SLEW SLOW [get_ports rgmii_1_txc]
set_property DRIVE 8 [get_ports rgmii_1_txc]

# Bank 703
set_property PACKAGE_PIN H24 [get_ports rgmii_1_tx_ctl]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_1_tx_ctl]
set_property SLEW SLOW [get_ports rgmii_1_tx_ctl]
set_property DRIVE 8 [get_ports rgmii_1_tx_ctl]

# Bank 703
set_property PACKAGE_PIN E23 [get_ports {rgmii_1_td[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_td[3]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[3]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[3]}]

# Bank 703
set_property PACKAGE_PIN E22 [get_ports {rgmii_1_td[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_td[2]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[2]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[2]}]

# Bank 703
set_property PACKAGE_PIN G23 [get_ports {rgmii_1_td[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_td[1]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[1]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[1]}]

# Bank 703
set_property PACKAGE_PIN F22 [get_ports {rgmii_1_td[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_td[0]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[0]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[0]}]

# Bank 703
set_property PACKAGE_PIN F23 [get_ports rgmii_1_rxc]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_1_rxc]
set_property SLEW SLOW [get_ports rgmii_1_rxc]
set_property DRIVE 8 [get_ports rgmii_1_rxc]
set_property PULLDOWN TRUE [get_ports rgmii_1_rxc]

# Bank 703
set_property PACKAGE_PIN F24 [get_ports rgmii_1_rx_ctl]
set_property IOSTANDARD LVCMOS12 [get_ports rgmii_1_rx_ctl]
set_property SLEW SLOW [get_ports rgmii_1_rx_ctl]
set_property DRIVE 8 [get_ports rgmii_1_rx_ctl]
set_property PULLDOWN TRUE [get_ports rgmii_1_rx_ctl]

# Bank 703
set_property PACKAGE_PIN D25 [get_ports {rgmii_1_rd[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_rd[3]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[3]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[3]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[3]]

# Bank 703
set_property PACKAGE_PIN D26 [get_ports {rgmii_1_rd[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_rd[2]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[2]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[2]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[2]]

# Bank 703
set_property PACKAGE_PIN E24 [get_ports {rgmii_1_rd[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_rd[1]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[1]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[1]}]
set_property PULLUP TRUE [get_ports rgmii_1_rd[1]]

# Bank 703
set_property PACKAGE_PIN F25 [get_ports {rgmii_1_rd[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {rgmii_1_rd[0]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[0]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[0]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[0]]

# Bank 703
set_property PACKAGE_PIN C22 [get_ports reset_phy_1_n]
set_property IOSTANDARD LVCMOS12 [get_ports reset_phy_1_n]
set_property SLEW SLOW [get_ports reset_phy_1_n]
set_property DRIVE 8 [get_ports reset_phy_1_n]

# Bank 302 VCCO_HDIO
set_property PACKAGE_PIN D10 [get_ports clk1_25MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk1_25MHz]
# Bank 302 VCCO_HDIO
set_property PACKAGE_PIN D11 [get_ports clk2_25MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk2_25MHz]

set_property CLOCK_REGION X2Y0 [get_cells */DFX_RP/hier_1g_components/clk_wizard_1/inst/clock_primitive_inst/BUFG_clkin1_inst]
set_property CLOCK_REGION X3Y0 [get_cells */DFX_RP/hier_1g_components/clk_wizard_0/inst/clock_primitive_inst/BUFG_clkin1_inst]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets */DFX_RP/hier_1g_components/eth0_bufs/clk_shim/inst/clk_out]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets */DFX_RP/hier_1g_components/eth1_bufs/clk_shim/inst/clk_out]
