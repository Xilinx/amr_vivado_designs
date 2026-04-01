# Copyright (C) 2024 - 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

########################################################
###
### XDC for 10G MRMAC design for RAVE DFX
###
########################################################

##### GTYP Bank 104
set_property PACKAGE_PIN F2 [get_ports {GT_Serial_grx_p[0]}]
set_property PACKAGE_PIN F1 [get_ports {GT_Serial_grx_n[0]}]
set_property PACKAGE_PIN E5 [get_ports {GT_Serial_gtx_p[0]}]
set_property PACKAGE_PIN E4 [get_ports {GT_Serial_gtx_n[0]}]

set_property PACKAGE_PIN D2 [get_ports {GT_Serial_grx_p[1]}]
set_property PACKAGE_PIN D1 [get_ports {GT_Serial_grx_n[1]}]
set_property PACKAGE_PIN D8 [get_ports {GT_Serial_gtx_p[1]}]
set_property PACKAGE_PIN D7 [get_ports {GT_Serial_gtx_n[1]}]

set_property LOC GTYP_REFCLK_X0Y2 [get_cells */*/MRMAC_GT/GT/util_ds_buf_0/U0/USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I]

create_clock -period 6.4 -name {CLK_IN_D_clk_p} -waveform {0.000 3.2} [get_ports {CLK_IN_D_clk_p}]

set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/*/MRMAC_GT/GT/gt_bufg_gt_rxoutclk_div2_ch1/inst/bufg_gt_usrclk_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/*/MRMAC_GT/GT/gt_bufg_gt_txoutclk_div2_ch0/inst/bufg_gt_usrclk_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/*/MRMAC_GT/GT/gt_bufg_gt_rxoutclk_div2_ch0/inst/bufg_gt_usrclk_inst/O}]]

set ref_clk_period_pl_0 [get_property PERIOD [get_clocks clk_pl_0]]
set ref_clk_period_MMCME5_CLKOUT0 [get_property PERIOD [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]]]

set_max_delay -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]] ${ref_clk_period_pl_0}
set_max_delay -from [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]] -to [get_clocks clk_pl_0] ${ref_clk_period_MMCME5_CLKOUT0}
