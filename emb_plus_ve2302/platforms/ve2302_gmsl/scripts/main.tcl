# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

set phy 0
set port A
set jobs 8

# parse arguments
for { set i 0 } { $i < $argc } { incr i } {
  # jobs
  if { [lindex $argv $i] == "-jobs" } {
    incr i
    set jobs [lindex $argv $i]
  }
# pick Port
  if { [lindex $argv $i] == "-port" } {
    incr i
    set port [string toupper [lindex $argv $i]]
    puts "Setting Port to $port"
  }
# pick Phy
  if { [lindex $argv $i] == "-phy" } {
    incr i
    set phy [lindex $argv $i]
    puts "Setting Phy to $phy"
  }
}

# Set project variables
set proj_dir ./project
set proj_board [get_board_parts "*:emb-plus-vpr-4616:*" -latest_file_version]
set bd_tcl_dir ./scripts
set output_dir ./xsa
set output {xsa}
set cam_xdc cam_d${phy}_port${port}.xdc
puts "use XDC $cam_xdc"
set xdc_list {}
lappend xdc_list [list ./xdc/${cam_xdc}]
set ip_repo_path {./ip}

set part xcve2302-sfva784-2MP-e-S
set proj_name ve2302_gmsl


create_project -name $proj_name -force -dir $proj_dir -part $part
set_property board_part $proj_board [current_project]

add_files -fileset constrs_1 $xdc_list

source $bd_tcl_dir/config_bd.tcl

save_bd_design

# Import constraint and hook files, and set their properties as required
set_property used_in_synthesis false [get_files *.xdc]

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

write_hw_platform -fixed -include_bit -force -file ${proj_dir}/${proj_name}.xsa
validate_hw_platform -verbose ${proj_dir}/${proj_name}.xsa

exit