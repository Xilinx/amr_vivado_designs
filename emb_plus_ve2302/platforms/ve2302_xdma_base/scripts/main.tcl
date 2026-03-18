# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Set project variables
set proj_dir ./project
set board emb_plus_ve2302
set bd_tcl_dir ./scripts
set dfx_dir ../../dfx
set ip_dir_list [list ./ip $dfx_dir/eth_10g/ip]
set output_dir ./xsa
set output {xsa}
set static_xdc_list [list ./xdc/pcie.xdc ]
set eth_10g_xdc_list [list $dfx_dir/eth_10g/xdc/mrmac.xdc ]
set train_xdc_list [ list $dfx_dir/training/xdc/mrmac.xdc ]
set pblock_xdc [list ./xdc/pblock.xdc]
set part xcve2302-sfva784-2MP-e-S
set proj_name ve2302_xdma_base
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
add_files -fileset constrs_1 $eth_10g_xdc_list
add_files -fileset constrs_1 $train_xdc_list
set_property used_in_synthesis false [get_files $eth_10g_xdc_list]
set_property used_in_synthesis false [get_files $static_xdc_list]
set_property used_in_synthesis false [get_files $train_xdc_list]

source $dfx_dir/training/bd/DFX_RP_training.tcl
source $dfx_dir/eth_10g/bd/DFX_RP_10gEth.tcl
source $dfx_dir/bram_gpio/bd/DFX_RP_bram_gpio.tcl
source $bd_tcl_dir/config_bd.tcl

save_bd_design

add_files -force -norecurse ./hdl/${proj_name}_wrapper.v
update_compile_order
set_property top ${proj_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

save_bd_design
validate_bd_design

source ./${bd_tcl_dir}/make_dfx.tcl

exit
