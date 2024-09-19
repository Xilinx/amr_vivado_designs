# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

##### GTYP Bank 104 
set_property PACKAGE_PIN F2 [get_ports {GT_Serial_grx_p[0]}]
set_property PACKAGE_PIN F1 [get_ports {GT_Serial_grx_n[0]}]
set_property PACKAGE_PIN E5 [get_ports {GT_Serial_gtx_p[0]}]
set_property PACKAGE_PIN E4 [get_ports {GT_Serial_gtx_n[0]}]

set_property PACKAGE_PIN D2 [get_ports {GT_Serial_grx_p[1]}]
set_property PACKAGE_PIN D1 [get_ports {GT_Serial_grx_n[1]}]
set_property PACKAGE_PIN D8 [get_ports {GT_Serial_gtx_p[1]}]
set_property PACKAGE_PIN D7 [get_ports {GT_Serial_gtx_n[1]}]

set_property LOC GTYP_REFCLK_X0Y2    [get_cells */MRMAC_GT/GT/util_ds_buf_0/U0/USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I]

create_clock -period 6.4 -name {CLK_IN_D_clk_p[0]} -waveform {0.000 3.2} [get_ports {CLK_IN_D_clk_p[0]}]

set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/MRMAC_GT/GT/mbufg_gt_rx_clkout_ch1/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/MRMAC_GT/GT/mbufg_gt_tx_clkout_ch0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks -of_objects [get_pins {*/MRMAC_GT/GT/mbufg_gt_rx_clkout_ch0/U0/USE_MBUFG_GT_SYNC.GEN_MBUFG_GT[0].MBUFG_GT_U/O2}]]

set ref_clk_period_pl_0 [get_property PERIOD [get_clocks clk_pl_0]]
set ref_clk_period_MMCME5_CLKOUT0 [get_property PERIOD [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]]]

set_max_delay -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]] ${ref_clk_period_pl_0}
set_max_delay -from [get_clocks -of_objects [get_pins */clk_wizard_axis_clk/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0]] -to [get_clocks clk_pl_0] ${ref_clk_period_MMCME5_CLKOUT0}


