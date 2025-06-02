# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

########################################################
###
### Timing constraints
###
########################################################

create_clock -period 40.000 -name clk1_25MHz -waveform {0.000 20.000} [get_ports clk1_25MHz]
create_clock -period 40.000 -name clk2_25MHz -waveform {0.000 20.000} [get_ports clk2_25MHz]



########################################################
###
### XDC for Axi Ethernet Subsystem design for VCK190 - altered for RAVE
###
########################################################


set_property PACKAGE_PIN D27 [get_ports mdio_0_mdio_io]
set_property IOSTANDARD LVCMOS15 [get_ports mdio_0_mdio_io]
set_property SLEW SLOW [get_ports mdio_0_mdio_io]
set_property DRIVE 8 [get_ports mdio_0_mdio_io]


set_property PACKAGE_PIN B28 [get_ports mdio_0_mdc]
set_property IOSTANDARD LVCMOS15 [get_ports mdio_0_mdc]
set_property SLEW SLOW [get_ports mdio_0_mdc]
set_property DRIVE 8 [get_ports mdio_0_mdc]

set_property PACKAGE_PIN H25 [get_ports rgmii_0_txc]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_0_txc]
set_property SLEW SLOW [get_ports rgmii_0_txc]
set_property DRIVE 8 [get_ports rgmii_0_txc]

set_property PACKAGE_PIN J26 [get_ports rgmii_0_tx_ctl]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_0_tx_ctl]
set_property SLEW SLOW [get_ports rgmii_0_tx_ctl]
set_property DRIVE 8 [get_ports rgmii_0_tx_ctl]

set_property PACKAGE_PIN E26 [get_ports {rgmii_0_td[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_td[3]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[3]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[3]}]

set_property PACKAGE_PIN F26 [get_ports {rgmii_0_td[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_td[2]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[2]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[2]}]

set_property PACKAGE_PIN G26 [get_ports {rgmii_0_td[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_td[1]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[1]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[1]}]

set_property PACKAGE_PIN G25 [get_ports {rgmii_0_td[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_td[0]}]
set_property SLEW SLOW [get_ports {rgmii_0_td[0]}]
set_property DRIVE 8 [get_ports {rgmii_0_td[0]}]

set_property PACKAGE_PIN C25 [get_ports rgmii_0_rxc]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_0_rxc]
set_property SLEW SLOW [get_ports rgmii_0_rxc]
set_property DRIVE 8 [get_ports rgmii_0_rxc]
set_property PULLDOWN TRUE [get_ports rgmii_0_rxc]

set_property PACKAGE_PIN B25 [get_ports rgmii_0_rx_ctl]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_0_rx_ctl]
set_property SLEW SLOW [get_ports rgmii_0_rx_ctl]
set_property DRIVE 8 [get_ports rgmii_0_rx_ctl]
set_property PULLDOWN TRUE [get_ports rgmii_0_rx_ctl]

set_property PACKAGE_PIN B27 [get_ports {rgmii_0_rd[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_rd[3]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[3]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[3]}]
set_property PULLUP TRUE [get_ports rgmii_0_rd[3]]

set_property PACKAGE_PIN B26 [get_ports {rgmii_0_rd[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_rd[2]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[2]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[2]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[2]]

set_property PACKAGE_PIN A26 [get_ports {rgmii_0_rd[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_rd[1]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[1]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[1]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[1]]

set_property PACKAGE_PIN A25 [get_ports {rgmii_0_rd[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_0_rd[0]}]
set_property SLEW SLOW [get_ports {rgmii_0_rd[0]}]
set_property DRIVE 8 [get_ports {rgmii_0_rd[0]}]
set_property PULLDOWN TRUE [get_ports rgmii_0_rd[0]]

set_property PACKAGE_PIN C27 [get_ports reset_phy_0]
set_property IOSTANDARD LVCMOS15 [get_ports reset_phy_0]
set_property SLEW SLOW [get_ports reset_phy_0]
set_property DRIVE 8 [get_ports reset_phy_0]



set_property PACKAGE_PIN A20 [get_ports mdio_1_mdio_io]
set_property IOSTANDARD LVCMOS15 [get_ports mdio_1_mdio_io]
set_property SLEW SLOW [get_ports mdio_1_mdio_io]
set_property DRIVE 8 [get_ports mdio_1_mdio_io]

set_property PACKAGE_PIN A21 [get_ports mdio_1_mdc]
set_property IOSTANDARD LVCMOS15 [get_ports mdio_1_mdc]
set_property SLEW SLOW [get_ports mdio_1_mdc]
set_property DRIVE 8 [get_ports mdio_1_mdc]

set_property PACKAGE_PIN H23 [get_ports rgmii_1_txc]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_1_txc]
set_property SLEW SLOW [get_ports rgmii_1_txc]
set_property DRIVE 8 [get_ports rgmii_1_txc]

set_property PACKAGE_PIN H24 [get_ports rgmii_1_tx_ctl]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_1_tx_ctl]
set_property SLEW SLOW [get_ports rgmii_1_tx_ctl]
set_property DRIVE 8 [get_ports rgmii_1_tx_ctl]

set_property PACKAGE_PIN E23 [get_ports {rgmii_1_td[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_td[3]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[3]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[3]}]

set_property PACKAGE_PIN E22 [get_ports {rgmii_1_td[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_td[2]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[2]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[2]}]


set_property PACKAGE_PIN G23 [get_ports {rgmii_1_td[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_td[1]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[1]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[1]}]

set_property PACKAGE_PIN F22 [get_ports {rgmii_1_td[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_td[0]}]
set_property SLEW SLOW [get_ports {rgmii_1_td[0]}]
set_property DRIVE 8 [get_ports {rgmii_1_td[0]}]

set_property PACKAGE_PIN F23 [get_ports rgmii_1_rxc]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_1_rxc]
set_property SLEW SLOW [get_ports rgmii_1_rxc]
set_property DRIVE 8 [get_ports rgmii_1_rxc]
set_property PULLDOWN TRUE [get_ports rgmii_1_rxc]

set_property PACKAGE_PIN F24 [get_ports rgmii_1_rx_ctl]
set_property IOSTANDARD LVCMOS15 [get_ports rgmii_1_rx_ctl]
set_property SLEW SLOW [get_ports rgmii_1_rx_ctl]
set_property DRIVE 8 [get_ports rgmii_1_rx_ctl]
set_property PULLDOWN TRUE [get_ports rgmii_1_rx_ctl]

set_property PACKAGE_PIN D25 [get_ports {rgmii_1_rd[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_rd[3]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[3]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[3]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[3]]

set_property PACKAGE_PIN D26 [get_ports {rgmii_1_rd[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_rd[2]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[2]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[2]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[2]]

set_property PACKAGE_PIN E24 [get_ports {rgmii_1_rd[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_rd[1]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[1]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[1]}]
set_property PULLUP TRUE [get_ports rgmii_1_rd[1]]

set_property PACKAGE_PIN F25 [get_ports {rgmii_1_rd[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {rgmii_1_rd[0]}]
set_property SLEW SLOW [get_ports {rgmii_1_rd[0]}]
set_property DRIVE 8 [get_ports {rgmii_1_rd[0]}]
set_property PULLDOWN TRUE [get_ports rgmii_1_rd[0]]

set_property PACKAGE_PIN C22 [get_ports reset_phy_1]
set_property IOSTANDARD LVCMOS15 [get_ports reset_phy_1]
set_property SLEW SLOW [get_ports reset_phy_1]
set_property DRIVE 8 [get_ports reset_phy_1]

set_property PACKAGE_PIN D10 [get_ports clk1_25MHz]
set_property IOSTANDARD LVCMOS18 [get_ports clk1_25MHz]
set_property PACKAGE_PIN D11 [get_ports clk2_25MHz]
set_property IOSTANDARD LVCMOS18 [get_ports clk2_25MHz]

#set_property LOC BUFGCTRL_X0Y02[get_cells ve2302_pcie_qdma_i/blp/clk_wizard_0/inst/clock_primitive_inst/BUFG_clkin1_inst]
#set_property LOC BUFGCTRL_X0Y02[get_cells ve2302_pcie_qdma_i/blp/clk_wizard_1/inst/clock_primitive_inst/BUFG_clkin1_inst] > thses constraints did not seem to work

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk1_25MHz_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk2_25MHz_IBUF]