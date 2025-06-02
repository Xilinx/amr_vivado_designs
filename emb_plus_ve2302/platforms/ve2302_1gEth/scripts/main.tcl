# Copyright (C) 2024 - 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Set project variables
set proj_dir ./project
set proj_board [get_board_parts "*:emb-plus-vpr-4616:*" -latest_file_version]
set bd_tcl_dir ./scripts
set output_dir ./xsa
set output {xsa}
set xdc_list {./xdc/impl.xdc }
set ip_repo_path {./ip}
set jobs 8
set silicon prod

# parse arguments
for { set i 0 } { $i < $argc } { incr i } {
  # jobs
  if { [lindex $argv $i] == "-jobs" } {
    incr i
    set jobs [lindex $argv $i]
  }
  # silicon
  if { [lindex $argv $i] == "-silicon" } {
    incr i
    set silicon [lindex $argv $i]
  }
}

if {$silicon == "es1"} {
  set part xcve2302-sfva784-2MP-e-S-es1
  set proj_name ve2302_es1_1gEth
} else {
  set part xcve2302-sfva784-2MP-e-S
  set proj_name ve2302_1gEth
}

create_project -name $proj_name -force -dir $proj_dir -part $part
set_property board_part $proj_board [current_project]

add_files -fileset constrs_1 $xdc_list

source $bd_tcl_dir/config_bd.tcl

save_bd_design

# Import constraint and hook files, and set their properties as required
set_property used_in_synthesis false          [get_files *impl*.xdc]

make_wrapper -files [get_files ${proj_name}.bd] -top
import_files -force -norecurse $proj_dir/${proj_name}.srcs/sources_1/bd/${proj_name}/hdl/${proj_name}_wrapper.v
update_compile_order
set_property top ${proj_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

save_bd_design
validate_bd_design

# Generate all output products
generate_target all [get_files ${proj_name}.bd]

launch_runs impl_1 -to_step write_device_image -jobs $jobs
wait_on_run impl_1
open_run impl_1

write_hw_platform -fixed -include_bit -force -file $proj_dir/${proj_name}.xsa
