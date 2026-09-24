# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: DFX_RP
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source DFX_RP_board_test.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcve2302-sfva784-2MP-e-S
   set_property BOARD_PART xilinx.com:emb-plus-vpr-4616:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME in main.tcl
variable design_name


# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:axi_noc:*\
xilinx.com:ip:smartconnect:*\
user.org:user:power:*\
xilinx.com:ip:emb_mem_gen:*\
xilinx.com:ip:axi_bram_ctrl:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:proc_sys_reset:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: clk_rst
proc create_hier_cell_clk_rst { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clk_rst() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk pl_1_clk
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O -type clk clk_out3
  create_bd_pin -dir I -type rst pl_1_resetn
  create_bd_pin -dir O -from 0 -to 0 -type rst clk_out_2_peripheral_reset
  create_bd_pin -dir O -from 0 -to 0 -type rst clk_out_2_peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst clk_out_3_peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst clk_out_3_interconnect_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst clk_out_3_peripheral_reset

  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {No_buffer,No_buffer,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {400.000,500.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
    CONFIG.USE_LOCKED {true} \
  ] $clk_wizard_0


  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1 ]

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_2 ]

  # Create instance: proc_sys_reset_3, and set properties
  set proc_sys_reset_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_3 ]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clk_wizard_0/clk_out1] \
  [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins clk_wizard_0/clk_out2] \
  [get_bd_pins clk_out2] \
  [get_bd_pins proc_sys_reset_2/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out3  [get_bd_pins clk_wizard_0/clk_out3] \
  [get_bd_pins proc_sys_reset_3/slowest_sync_clk] \
  [get_bd_pins clk_out3]
  connect_bd_net -net clk_wizard_0_locked  [get_bd_pins clk_wizard_0/locked] \
  [get_bd_pins proc_sys_reset_1/dcm_locked] \
  [get_bd_pins proc_sys_reset_2/dcm_locked] \
  [get_bd_pins proc_sys_reset_3/dcm_locked]
  connect_bd_net -net ext_reset_in_1  [get_bd_pins pl_1_resetn] \
  [get_bd_pins proc_sys_reset_1/ext_reset_in] \
  [get_bd_pins proc_sys_reset_2/ext_reset_in] \
  [get_bd_pins proc_sys_reset_3/ext_reset_in]
  connect_bd_net -net pl_1_clk_1  [get_bd_pins pl_1_clk] \
  [get_bd_pins clk_wizard_0/clk_in1]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn  [get_bd_pins proc_sys_reset_2/peripheral_aresetn] \
  [get_bd_pins clk_out_2_peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_reset  [get_bd_pins proc_sys_reset_2/peripheral_reset] \
  [get_bd_pins clk_out_2_peripheral_reset]
  connect_bd_net -net proc_sys_reset_3_interconnect_aresetn  [get_bd_pins proc_sys_reset_3/interconnect_aresetn] \
  [get_bd_pins clk_out_3_interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_3_peripheral_aresetn  [get_bd_pins proc_sys_reset_3/peripheral_aresetn] \
  [get_bd_pins clk_out_3_peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_3_peripheral_reset  [get_bd_pins proc_sys_reset_3/peripheral_reset] \
  [get_bd_pins clk_out_3_peripheral_reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: verify
proc create_hier_cell_verify { parentCell nameHier mem_file } {

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_verify() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir I -type clk s_axi_clk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: emb_mem_gen_0, and set properties
  set emb_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:emb_mem_gen emb_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.USE_MEMORY_BLOCK {Stand_Alone} \
    CONFIG.MEMORY_TYPE {Single_Port_ROM} \
    CONFIG.READ_LATENCY_A {1} \
    CONFIG.MEMORY_OPTIMIZATION {no_mem_opt} \
  ] $emb_mem_gen_0

  puts "Assigning Memory Initialization file $mem_file"
  # This gets generated in config_bd.tcl and added to the project in main.tcl
  set_property CONFIG.MEMORY_INIT_FILE \
    $mem_file \
    [get_bd_cells emb_mem_gen_0]

  puts "MEM FILE = [get_property CONFIG.MEMORY_INIT_FILE [get_bd_cells emb_mem_gen_0]]"

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bram_ctrl_0 ]
  set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_bram_ctrl_0


  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {12} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {13} \
  ] $ilslice_0


  # Create interface connections
  connect_bd_intf_net -intf_net smartconnect_ingress_0_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

  # Create port connections
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_a  [get_bd_pins axi_bram_ctrl_0/bram_addr_a] \
  [get_bd_pins ilslice_0/Din]
  connect_bd_net -net axi_bram_ctrl_0_bram_clk_a  [get_bd_pins axi_bram_ctrl_0/bram_clk_a] \
  [get_bd_pins emb_mem_gen_0/clka]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_a  [get_bd_pins axi_bram_ctrl_0/bram_en_a] \
  [get_bd_pins emb_mem_gen_0/ena]
  connect_bd_net -net axi_bram_ctrl_0_bram_rst_a  [get_bd_pins axi_bram_ctrl_0/bram_rst_a] \
  [get_bd_pins emb_mem_gen_0/rsta]
  connect_bd_net -net emb_mem_gen_0_douta  [get_bd_pins emb_mem_gen_0/douta] \
  [get_bd_pins axi_bram_ctrl_0/bram_rddata_a]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins emb_mem_gen_0/addra]
  connect_bd_net -net s_axi_aresetn_0_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
  connect_bd_net -net s_axi_clk  [get_bd_pins s_axi_clk] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: pl_power
proc create_hier_cell_pl_power { parentCell nameHier variant } {

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pl_power() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_0

  # Create pins
  create_bd_pin -dir I -type rst system_resetn
  create_bd_pin -dir I -type clk power_clk
  create_bd_pin -dir I -type clk s_axi_clk
  create_bd_pin -dir I -type rst power_rstn

  # Create instance: power_0, and set properties
  set power_0 [ create_bd_cell -type ip -vlnv user.org:user:power power_0 ]
  set_property -dict [list \
    CONFIG.NUM_DSP          [variant_get $variant num_dsp] \
    CONFIG.NUM_LOGIC_BLOCKS [variant_get $variant num_logic_blocks] \
    CONFIG.NUM_RAMB_18_DC   [variant_get $variant num_ramb18] \
    CONFIG.NUM_RAMB_36_DC   [variant_get $variant num_ramb36] \
    CONFIG.NUM_URAM         [variant_get $variant num_uram] \
  ] $power_0

  # Create interface connections
  connect_bd_intf_net -intf_net smartconnect_ingress_0_M01_AXI [get_bd_intf_pins s_axi_0] [get_bd_intf_pins power_0/s_axi]

  # Create port connections
  connect_bd_net -net power_clk_1  [get_bd_pins power_clk] \
  [get_bd_pins power_0/power_clk]
  connect_bd_net -net power_rstn_1  [get_bd_pins power_rstn] \
  [get_bd_pins power_0/power_rstn]
  connect_bd_net -net proc_sys_reset_0_peripheral  [get_bd_pins system_resetn] \
  [get_bd_pins power_0/system_rstn]
  connect_bd_net -net s_axi_clk_1  [get_bd_pins s_axi_clk] \
  [get_bd_pins power_0/system_clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell variant mem_file} {


  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  ####################################################################
  ##
  ## DFX_RP_bram_gpio Logic Begins
  ##
  ####################################################################
  set PCIE_PL_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 PCIE_PL_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $PCIE_PL_INI
  set_property APERTURES {{0x202_0100_0000 16M}} [get_bd_intf_ports PCIE_PL_INI]


  # Create ports
  set pl1_clk [ create_bd_port -dir I -type clk -freq_hz 199999802 pl1_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_PORT {PCIE_PL_INI} \
   CONFIG.ASSOCIATED_RESET {pl1_resetn} \
 ] $pl1_clk
  set pl1_resetn [ create_bd_port -dir I -type rst pl1_resetn ]

  # Create instance: axi_noc_fixed, and set properties
  set axi_noc_fixed [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_fixed ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_fixed

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0100_0000 16M}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc_fixed/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins $axi_noc_fixed/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc_fixed/aclk0]

  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_1


  # Create instance: pl_power
  create_hier_cell_pl_power [current_bd_instance .] pl_power $variant

  # Create instance: verify
  create_hier_cell_verify [current_bd_instance .] verify $mem_file

  # Create instance: clk_rst
  create_hier_cell_clk_rst [current_bd_instance .] clk_rst

  # Create interface connections
  connect_bd_intf_net -intf_net PCIE_PL_INI [get_bd_intf_ports PCIE_PL_INI] [get_bd_intf_pins axi_noc_fixed/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_fixed_M00_AXI [get_bd_intf_pins axi_noc_fixed/M00_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins verify/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M01_AXI [get_bd_intf_pins smartconnect_1/M01_AXI] [get_bd_intf_pins pl_power/s_axi_0]

  # Create port connections
  connect_bd_net -net clk_rst_clk_out2  [get_bd_pins clk_rst/clk_out2] \
  [get_bd_pins pl_power/power_clk]
  connect_bd_net -net clk_rst_clk_out_2_peripheral_aresetn  [get_bd_pins clk_rst/clk_out_2_peripheral_aresetn] \
  [get_bd_pins pl_power/power_rstn]
  connect_bd_net -net clk_rst_clk_out_3_interconnect_aresetn  [get_bd_pins clk_rst/clk_out_3_interconnect_aresetn] \
  [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net pl1_clk_1  [get_bd_ports pl1_clk] \
  [get_bd_pins clk_rst/pl_1_clk]
  connect_bd_net -net pl1_resetn_1  [get_bd_ports pl1_resetn] \
  [get_bd_pins clk_rst/pl_1_resetn]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins clk_rst/clk_out_3_peripheral_aresetn] \
  [get_bd_pins verify/s_axi_aresetn] \
  [get_bd_pins pl_power/system_resetn]
  connect_bd_net -net s_axi_clk_1  [get_bd_pins clk_rst/clk_out3] \
  [get_bd_pins pl_power/s_axi_clk] \
  [get_bd_pins verify/s_axi_clk] \
  [get_bd_pins axi_noc_fixed/aclk0] \
  [get_bd_pins smartconnect_1/aclk]

  # Create address segments

  # PCIe Control
  assign_bd_address -offset 0x020201000000 -range 8K -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs verify/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020201020000 -range 4K -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs pl_power/power_0/s_axi/reg0] -force

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design "" $variant $mem_file


