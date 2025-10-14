# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# parse arguments
for { set i 0 } { $i < $argc } { incr i } {
  # xsa path
  if { [lindex $argv $i] == "-xsa_path" } {
    incr i
    set xsa_path [lindex $argv $i]
  }
  if { [lindex $argv $i] == "-rm" } {
    incr i
    set rm_list [lindex $argv $i]
  }
}

puts "Using RMs $rm_list"

sdtgen set_dt_param -debug enable
sdtgen set_dt_param -dir ./project_sdt
sdtgen set_dt_param -xsa $xsa_path
sdtgen set_dt_param -board_dts versal-emb-plus-ve2302-reva
sdtgen set_dt_param -rm_xsa $rm_list
sdtgen generate_sdt
