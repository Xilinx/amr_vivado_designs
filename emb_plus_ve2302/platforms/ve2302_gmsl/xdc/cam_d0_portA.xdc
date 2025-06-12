# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# setting additional WDI params
set_property BITSTREAM.GENERAL.NPIDMAMODE Yes [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Pin Assignments
set_property PACKAGE_PIN F14 [get_ports CFG_IIC_scl_io]
set_property PACKAGE_PIN E14 [get_ports CFG_IIC_sda_io]

set_property PULLUP true [get_ports CFG_IIC_scl_io]
set_property PULLUP true [get_ports CFG_IIC_sda_io]
set_property DRIVE 8 [get_ports CFG_IIC_scl_io]
set_property DRIVE 8 [get_ports CFG_IIC_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports CFG_IIC_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports CFG_IIC_sda_io]

# MIPI PHY0 CHANNEL A CONFIG
set_property PACKAGE_PIN C14 [get_ports DESER_IIC_scl_io]
set_property PACKAGE_PIN C13 [get_ports DESER_IIC_sda_io]

set_property PULLUP true [get_ports DESER_IIC_scl_io]
set_property PULLUP true [get_ports DESER_IIC_sda_io]
set_property DRIVE 8 [get_ports DESER_IIC_scl_io]
set_property DRIVE 8 [get_ports DESER_IIC_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports DESER_IIC_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports DESER_IIC_sda_io]

set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_data_p[*]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_data_n[*]}]
set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_clk*]
set_property DIFF_TERM_ADV TERM_100 [get_ports mipi_phy_if_clk*]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_data_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_data_n[*]}]

set_property PACKAGE_PIN G21 [get_ports mipi_phy_if_clk_p]
set_property PACKAGE_PIN H22 [get_ports mipi_phy_if_clk_n]
set_property PACKAGE_PIN B20 [get_ports {mipi_phy_if_data_p[0]}]
set_property PACKAGE_PIN C21 [get_ports {mipi_phy_if_data_n[0]}]
set_property PACKAGE_PIN A20 [get_ports {mipi_phy_if_data_p[1]}]
set_property PACKAGE_PIN A21 [get_ports {mipi_phy_if_data_n[1]}]
set_property PACKAGE_PIN D20 [get_ports {mipi_phy_if_data_p[2]}]
set_property PACKAGE_PIN D21 [get_ports {mipi_phy_if_data_n[2]}]
set_property PACKAGE_PIN E20 [get_ports {mipi_phy_if_data_p[3]}]
set_property PACKAGE_PIN F21 [get_ports {mipi_phy_if_data_n[3]}]
