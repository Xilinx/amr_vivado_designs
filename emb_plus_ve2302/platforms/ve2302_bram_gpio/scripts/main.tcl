# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Set project variables
set proj_dir ./project
set board emb_plus_ve2302
set bd_tcl_dir ./scripts
set ip_dir_list [list ../ip]
set output_dir ./xsa
set output {xsa}
set static_xdc_list [list ./xdc/pcie.xdc ]
set pblock_xdc [list ./xdc/pblock.xdc]
set part xcve2302-sfva784-2MP-e-S
set proj_name ve2302_bram_gpio
set proj_board [get_board_parts "*:emb-plus-vpr-4616:*" -latest_file_version]
set jobs 8


# parse arguments
for { set i 0 } { $i < $argc } { incr i } {
  # jobs
  if { [lindex $argv $i] == "-jobs" } {
    incr i
    set jobs [lindex $argv $i]
  }
}

create_project -name $proj_name -force -dir $proj_dir -part $part
set_property board_part $proj_board [current_project]

# set up IP repo
set_property ip_repo_paths $ip_dir_list [current_fileset]
update_ip_catalog -rebuild

add_files -fileset constrs_1 $static_xdc_list

source $bd_tcl_dir/DFX_RP_bram_gpio.tcl
source $bd_tcl_dir/config_bd.tcl

save_bd_design

make_wrapper -files [get_files $proj_dir/$proj_name.srcs/sources_1/bd/$proj_name/$proj_name.bd] -top

add_files -norecurse $proj_dir/$proj_name.gen/sources_1/bd/$proj_name/hdl/${proj_name}_wrapper.v

update_compile_order
set_property top ${proj_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

save_bd_design
validate_bd_design

source ./${bd_tcl_dir}/make_dfx.tcl

exit
