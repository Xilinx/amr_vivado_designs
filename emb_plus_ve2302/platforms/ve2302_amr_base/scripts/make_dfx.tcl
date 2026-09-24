# Copyright (C) 2025 - 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

current_bd_design [get_bd_designs ${proj_name}]
set_property -dict [list \
  CONFIG.ENABLE_DFX {true} \
  CONFIG.LOCK_PROPAGATE {true} \
] [get_bd_cells DFX_RP]

validate_bd_design
save_bd_design

add_files -fileset constrs_1 $pblock_xdc_list
set_property used_in_synthesis false [get_files $pblock_xdc_list]

create_fileset -constrset constrs_power
add_files -fileset constrs_power $power_xdc_list
set_property used_in_synthesis false [get_files $power_xdc_list]

# Do this last
generate_target all [get_files ${proj_name}.bd]

set rm_list [get_reconfig_modules]
set bram_inst [lindex $rm_list [lsearch -regexp $rm_list "bram"]]
set stress_inst [lindex $rm_list [lsearch -regexp $rm_list "stress"]]
set func_inst [lindex $rm_list [lsearch -regexp $rm_list "func"]]

create_pr_configuration -name config_bram_gpio -partitions [list ${proj_name}_i/DFX_RP:$bram_inst ]
create_pr_configuration -name config_stress -partitions [list ${proj_name}_i/DFX_RP:$stress_inst ]
create_pr_configuration -name config_func -partitions [list ${proj_name}_i/DFX_RP:$func_inst ]
create_pr_configuration -name config_gb -partitions { }  -greyboxes [list ${proj_name}_i/DFX_RP ]


set_property PR_CONFIGURATION config_bram_gpio [get_runs impl_1]
create_run child_func_impl_1 -parent_run impl_1 -flow {Vivado Advanced Implementation 2025} -pr_config config_func
create_run child_stress_impl_1 -parent_run impl_1 -flow {Vivado Advanced Implementation 2025} -pr_config config_stress
create_run child_grey_impl_1 -parent_run impl_1 -flow {Vivado Advanced Implementation 2025} -pr_config config_gb

set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
set_property CONSTRSET constrs_power [get_runs child_func_impl_1]
set_property CONSTRSET constrs_power [get_runs child_stress_impl_1]
set_property APPLY_CONSTRSET 1 [get_runs child_stress_impl_1]
set_property APPLY_CONSTRSET 1 [get_runs child_func_impl_1]

launch_runs impl_1 -to_step write_device_image -jobs 10
wait_on_run impl_1

if { $quick } {
  launch_runs child_grey_impl_1 -to_step write_device_image -jobs 10
  wait_on_run child_grey_impl_1
} else {
  launch_runs child_func_impl_1 child_stress_impl_1 child_grey_impl_1 -to_step write_device_image -jobs 10
  wait_on_run child_func_impl_1 child_stress_impl_1 child_grey_impl_1
}


# Store partial PDIs in a subdirectory for deb generation (erase old directory if exists)
if {[file isdirectory ${proj_dir}/partial_pdis]} {
  file delete -force ${proj_dir}/partial_pdis
}
file mkdir ${proj_dir}/partial_pdis

open_run child_grey_impl_1
# Use greybox version for initial download (static + greybox RM)
write_hw_platform -force -fixed -hw -static ${proj_dir}/${proj_name}.xsa
validate_hw_platform -verbose ${proj_dir}/${proj_name}.xsa
write_hw_platform -force -fixed -hw -rp ${proj_name}_i/DFX_RP ${proj_dir}/${proj_name}_greybox.xsa
validate_hw_platform -verbose ${proj_dir}/${proj_name}_greybox.xsa
file copy [glob ${proj_dir}/${proj_name}.runs/child_grey_impl_1/*_partial.pdi] ${proj_dir}/partial_pdis/greybox_partial.pdi

open_run impl_1
# Just use the partial from bram_gpio
write_hw_platform -force -fixed -hw -rp ${proj_name}_i/DFX_RP ${proj_dir}/${proj_name}_bram_gpio.xsa
validate_hw_platform -verbose ${proj_dir}/${proj_name}_bram_gpio.xsa
file copy [glob  ${proj_dir}/${proj_name}.runs/impl_1/*_partial.pdi] ${proj_dir}/partial_pdis/bram_gpio_partial.pdi

if { $quick != 1 } {
  open_run child_func_impl_1
  # Just use the partial from board_test func
  write_hw_platform -force -fixed -hw -rp ${proj_name}_i/DFX_RP ${proj_dir}/${proj_name}_func.xsa
  validate_hw_platform -verbose ${proj_dir}/${proj_name}_func.xsa
  file copy [glob  ${proj_dir}/${proj_name}.runs/child_func_impl_1/*_partial.pdi] ${proj_dir}/partial_pdis/func_partial.pdi

  open_run child_stress_impl_1
  # Just use the partial from board_test stress
  write_hw_platform -force -fixed -hw -rp ${proj_name}_i/DFX_RP ${proj_dir}/${proj_name}_stress.xsa
  validate_hw_platform -verbose ${proj_dir}/${proj_name}_stress.xsa
  file copy [glob  ${proj_dir}/${proj_name}.runs/child_stress_impl_1/*_partial.pdi] ${proj_dir}/partial_pdis/stress_partial.pdi
}

