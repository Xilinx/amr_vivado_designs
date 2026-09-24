
set_false_path -quiet -from [get_pins */DFX_RP/clk_rst/proc_sys_reset_3/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C]
set_false_path -quiet -from [get_pins */DFX_RP/clk_rst/proc_sys_reset_2/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C]

# clock throttle
set_false_path -from [get_pins {*/DFX_RP/pl_power/power_0/inst/clk_throttle/Gate_Fast_d1_reg/C}]
