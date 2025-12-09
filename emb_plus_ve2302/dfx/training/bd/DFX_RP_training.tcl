# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: DFX_RP_training
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
# source DFX_RP_training.tcl
# The design that will be created by this Tcl script contains the following
# module references:
# clk_shim, clk_shim

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcve2302-sfva784-2MP-e-S
   set_property BOARD_PART xilinx.com:emb-plus-vpr-4616:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name DFX_RP_training

variable dfx_dir
set dfx_dir $dfx_dir


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
   #    1) Design_name not set

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
xilinx.com:ip:axi_intc:*\
xilinx.com:ip:ai_engine:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:axi_ethernet:*\
xilinx.com:ip:axi_vip:*\
xilinx.com:ip:mrmac:*\
xilinx.com:inline_hdl:ilvector_logic:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axi_apb_bridge:*\
xilinx.com:ip:bufg_gt:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:gtwiz_versal:*\
xilinx.com:ip:xlconcat:*\
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

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
clk_shim\
clk_shim\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
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


# Hierarchical cell: bufg_gt_txoutclk
proc create_hier_cell_bufg_gt_txoutclk { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_bufg_gt_txoutclk() - Empty argument(s)!"}
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
  set S_AXI_PCIE [ create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PCIE ]
  set M_AXI_0 [ create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_0 ]
  set M_AXI_1 [ create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_1 ]

  # Create pins
  create_bd_pin -dir O -from 3 -to 0 tx_usr_clk
  create_bd_pin -dir I -type clk outclk

  # Create instance: conct_tx_usr_clk, and set properties
  set conct_tx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat conct_tx_usr_clk ]
  set_property CONFIG.NUM_PORTS {4} $conct_tx_usr_clk


  # Create instance: gt_bufg_gt_txoutclk_ch0, and set properties
  set gt_bufg_gt_txoutclk_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_txoutclk_ch0 ]

  # Create instance: ilconstant_drive_to_zero, and set properties
  set ilconstant_drive_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero


  # Create port connections
  connect_bd_net -net bufg_gt_0_usrclk  [get_bd_pins gt_bufg_gt_txoutclk_ch0/usrclk] \
  [get_bd_pins conct_tx_usr_clk/In0] \
  [get_bd_pins conct_tx_usr_clk/In1]
  connect_bd_net -net conct_tx_usr_clk_dout  [get_bd_pins conct_tx_usr_clk/dout] \
  [get_bd_pins tx_usr_clk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins outclk] \
  [get_bd_pins gt_bufg_gt_txoutclk_ch0/outclk]
  connect_bd_net -net ilconstant_drive_to_zero_dout  [get_bd_pins ilconstant_drive_to_zero/dout] \
  [get_bd_pins conct_tx_usr_clk/In2] \
  [get_bd_pins conct_tx_usr_clk/In3]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: bufg_gt_rxoutclk
proc create_hier_cell_bufg_gt_rxoutclk { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_bufg_gt_rxoutclk() - Empty argument(s)!"}
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
  create_bd_pin -dir I -type clk outclk
  create_bd_pin -dir I -type clk outclk1
  create_bd_pin -dir O -from 3 -to 0 rx_usr_clk

  # Create instance: conct_rx_usr_clk, and set properties
  set conct_rx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat conct_rx_usr_clk ]
  set_property CONFIG.NUM_PORTS {4} $conct_rx_usr_clk


  # Create instance: gt_bufg_gt_rxoutclk_ch0, and set properties
  set gt_bufg_gt_rxoutclk_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_rxoutclk_ch0 ]

  # Create instance: gt_bufg_gt_rxoutclk_ch1, and set properties
  set gt_bufg_gt_rxoutclk_ch1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_rxoutclk_ch1 ]

  # Create instance: ilconstant_drive_to_zero, and set properties
  set ilconstant_drive_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero


  # Create port connections
  connect_bd_net -net conct_rx_usr_clk_dout  [get_bd_pins conct_rx_usr_clk/dout] \
  [get_bd_pins rx_usr_clk]
  connect_bd_net -net gt_bufg_gt_rxoutclk_ch0_usrclk  [get_bd_pins gt_bufg_gt_rxoutclk_ch0/usrclk] \
  [get_bd_pins conct_rx_usr_clk/In0]
  connect_bd_net -net gt_bufg_gt_rxoutclk_ch1_usrclk  [get_bd_pins gt_bufg_gt_rxoutclk_ch1/usrclk] \
  [get_bd_pins conct_rx_usr_clk/In1]
  connect_bd_net -net ilconstant_drive_to_zero_dout  [get_bd_pins ilconstant_drive_to_zero/dout] \
  [get_bd_pins conct_rx_usr_clk/In2] \
  [get_bd_pins conct_rx_usr_clk/In3]
  connect_bd_net -net outclk1_1  [get_bd_pins outclk1] \
  [get_bd_pins gt_bufg_gt_rxoutclk_ch1/outclk]
  connect_bd_net -net outclk_1  [get_bd_pins outclk] \
  [get_bd_pins gt_bufg_gt_rxoutclk_ch0/outclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GT
proc create_hier_cell_GT { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GT() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_LITE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN_D

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 Quad0_GT_Serial


  # Create pins
  create_bd_pin -dir O gt_refclk_div2_fwd
  create_bd_pin -dir O -from 3 -to 0 rx_usr_clk1
  create_bd_pin -dir O -from 3 -to 0 rx_usr_clk2
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -from 3 -to 0 tx_usr_clk
  create_bd_pin -dir O -from 3 -to 0 tx_usr_clk2
  create_bd_pin -dir O gtpowergood
  create_bd_pin -dir I -from 79 -to 0 INTF0_TX0_ch_txdata
  create_bd_pin -dir I -from 79 -to 0 INTF1_TX0_ch_txdata
  create_bd_pin -dir O -from 79 -to 0 INTF0_RX0_ch_rxdata
  create_bd_pin -dir O -from 79 -to 0 INTF1_RX0_ch_rxdata
  create_bd_pin -dir O -from 3 -to 0 tx_reset_done
  create_bd_pin -dir O -from 3 -to 0 rx_reset_done
  create_bd_pin -dir I -type clk gtwiz_freerun_clk
  create_bd_pin -dir I -type rst QUAD0_apb3presetn

  # Create instance: axi_gpio_gt_rate_reset_ctl_0, and set properties
  set axi_gpio_gt_rate_reset_ctl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_gt_rate_reset_ctl_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_GPIO_WIDTH {32} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_gt_rate_reset_ctl_0


  # Create instance: axi_gpio_gt_rate_reset_ctl_1, and set properties
  set axi_gpio_gt_rate_reset_ctl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_gt_rate_reset_ctl_1 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_GPIO_WIDTH {32} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_gt_rate_reset_ctl_1


  # Create instance: bufg_gt_div_val, and set properties
  set bufg_gt_div_val [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant bufg_gt_div_val ]
  set_property CONFIG.CONST_WIDTH {3} $bufg_gt_div_val


  # Create instance: bufg_gt_rxoutclk
  create_hier_cell_bufg_gt_rxoutclk $hier_obj bufg_gt_rxoutclk

  # Create instance: bufg_gt_txoutclk
  create_hier_cell_bufg_gt_txoutclk $hier_obj bufg_gt_txoutclk

  # Create instance: conct_rx_usr_clk2, and set properties
  set conct_rx_usr_clk2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat conct_rx_usr_clk2 ]
  set_property CONFIG.NUM_PORTS {4} $conct_rx_usr_clk2


  # Create instance: conct_tx_usr_clk2, and set properties
  set conct_tx_usr_clk2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat conct_tx_usr_clk2 ]
  set_property CONFIG.NUM_PORTS {4} $conct_tx_usr_clk2


  # Create instance: gt_axi_apb_bridge_0, and set properties
  set gt_axi_apb_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge gt_axi_apb_bridge_0 ]
  set_property CONFIG.C_APB_NUM_SLAVES {1} $gt_axi_apb_bridge_0


  # Create instance: gt_bufg_gt_refclk_fwd, and set properties
  set gt_bufg_gt_refclk_fwd [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_refclk_fwd ]
  set_property CONFIG.FREQ_HZ {322265625} $gt_bufg_gt_refclk_fwd


  # Create instance: gt_bufg_gt_rxoutclk_div2_ch0, and set properties
  set gt_bufg_gt_rxoutclk_div2_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_rxoutclk_div2_ch0 ]

  # Create instance: gt_bufg_gt_rxoutclk_div2_ch1, and set properties
  set gt_bufg_gt_rxoutclk_div2_ch1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_rxoutclk_div2_ch1 ]

  # Create instance: gt_bufg_gt_txoutclk_div2_ch0, and set properties
  set gt_bufg_gt_txoutclk_div2_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt gt_bufg_gt_txoutclk_div2_ch0 ]

  # Create instance: gt_rate_ctl_ch0_tx_rx, and set properties
  set gt_rate_ctl_ch0_tx_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice gt_rate_ctl_ch0_tx_rx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DOUT_WIDTH {8} \
  ] $gt_rate_ctl_ch0_tx_rx


  # Create instance: gt_rate_ctl_ch1_tx_rx, and set properties
  set gt_rate_ctl_ch1_tx_rx [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice gt_rate_ctl_ch1_tx_rx ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_TO {0} \
    CONFIG.DOUT_WIDTH {8} \
  ] $gt_rate_ctl_ch1_tx_rx


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf_0


  # Create instance: xlslice_gt_reset_all_0, and set properties
  set xlslice_gt_reset_all_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_all_0 ]
  set_property CONFIG.DIN_WIDTH {3} $xlslice_gt_reset_all_0


  # Create instance: xlslice_gt_reset_all_1, and set properties
  set xlslice_gt_reset_all_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_all_1 ]
  set_property CONFIG.DIN_WIDTH {3} $xlslice_gt_reset_all_1


  # Create instance: xlslice_gt_reset_rx_datapath_0, and set properties
  set xlslice_gt_reset_rx_datapath_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_rx_datapath_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {3} \
    CONFIG.DOUT_WIDTH {1} \
  ] $xlslice_gt_reset_rx_datapath_0


  # Create instance: xlslice_gt_reset_rx_datapath_1, and set properties
  set xlslice_gt_reset_rx_datapath_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_rx_datapath_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {3} \
    CONFIG.DOUT_WIDTH {1} \
  ] $xlslice_gt_reset_rx_datapath_1


  # Create instance: xlslice_gt_reset_tx_datapath_0, and set properties
  set xlslice_gt_reset_tx_datapath_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_tx_datapath_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {3} \
    CONFIG.DOUT_WIDTH {1} \
  ] $xlslice_gt_reset_tx_datapath_0


  # Create instance: xlslice_gt_reset_tx_datapath_1, and set properties
  set xlslice_gt_reset_tx_datapath_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_tx_datapath_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {3} \
    CONFIG.DOUT_WIDTH {1} \
  ] $xlslice_gt_reset_tx_datapath_1


  # Create instance: xlslice_gt_loopback_en_0, and set properties
  set xlslice_gt_loopback_en_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_loopback_en_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {10} \
    CONFIG.DIN_TO {8} \
  ] $xlslice_gt_loopback_en_0


  # Create instance: xlslice_gt_loopback_en_1, and set properties
  set xlslice_gt_loopback_en_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_loopback_en_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {10} \
    CONFIG.DIN_TO {8} \
  ] $xlslice_gt_loopback_en_1


  # Create instance: gtwiz_versal_0, and set properties
  set gtwiz_versal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal_0 ]
  set_property -dict [list \
    CONFIG.ENABLE_REG_INTERFACE {true} \
    CONFIG.EN_ADVANCED_CONFIG_SUPPORT {true} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {RX_OUTCLK_SOURCE RXPROGDIVCLK RX_PLL_TYPE LCPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_PLL_TYPE LCPLL RXPROGDIV_FREQ_VAL 644.531 TXPROGDIV_FREQ_VAL 644.531} \
    CONFIG.INTF0_NO_OF_LANES {1} \
    CONFIG.INTF0_PARENTID {undef} \
    CONFIG.INTF1_GT_SETTINGS(LR0_SETTINGS) {RX_OUTCLK_SOURCE RXPROGDIVCLK RX_PLL_TYPE LCPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_PLL_TYPE LCPLL RXPROGDIV_FREQ_VAL 644.531 TXPROGDIV_FREQ_VAL 644.531} \
    CONFIG.INTF1_PARENTID {undef} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_RX0 {{}} QUAD0_TX0 {{}} QUAD0_RX1 {{}} QUAD0_TX1 {{}}} \
    CONFIG.NO_OF_INTERFACE {2} \
    CONFIG.QUAD0_CH0_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH1_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH2_LOOPBACK_EN {true} \
    CONFIG.QUAD0_CH3_LOOPBACK_EN {true} \
    CONFIG.QUAD0_NO_PROT {2} \
    CONFIG.QUAD0_PROT0_LANES {1} \
    CONFIG.QUAD0_PROT0_RX1_EN {false} \
    CONFIG.QUAD0_PROT0_RX2_EN {false} \
    CONFIG.QUAD0_PROT0_RX3_EN {false} \
    CONFIG.QUAD0_PROT0_TX1_EN {false} \
    CONFIG.QUAD0_PROT0_TX2_EN {false} \
    CONFIG.QUAD0_PROT0_TX3_EN {false} \
    CONFIG.QUAD0_PROT1_RX1_EN {true} \
    CONFIG.QUAD0_PROT1_RXMSTCLK {RX1} \
    CONFIG.QUAD0_PROT1_TX1_EN {true} \
    CONFIG.QUAD0_PROT1_TXMSTCLK {TX1} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_PROT1_R0_156.25_MHz_unique1} \
  ] $gtwiz_versal_0

  set_property -dict [list \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF1_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
  ] $gtwiz_versal_0


  # Create instance: tx_reset_done, and set properties
  set tx_reset_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat tx_reset_done ]
  set_property CONFIG.NUM_PORTS {4} $tx_reset_done


  # Create instance: rx_reset_done, and set properties
  set rx_reset_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat rx_reset_done ]
  set_property CONFIG.NUM_PORTS {4} $rx_reset_done


  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_0


  # Create instance: axi_gpio_gt_reset_mask, and set properties
  set axi_gpio_gt_reset_mask [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_gt_reset_mask ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {8} \
    CONFIG.C_GPIO_WIDTH {32} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_gt_reset_mask


  # Create instance: ilconcat_1, and set properties
  set ilconcat_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {4} \
    CONFIG.IN1_WIDTH {4} \
  ] $ilconcat_1


  # Create instance: INTF0_TX0_concat, and set properties
  set INTF0_TX0_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat INTF0_TX0_concat ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {80} \
    CONFIG.IN1_WIDTH {48} \
  ] $INTF0_TX0_concat


  # Create instance: INTF1_TX0_concat, and set properties
  set INTF1_TX0_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat INTF1_TX0_concat ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {80} \
    CONFIG.IN1_WIDTH {48} \
  ] $INTF1_TX0_concat


  # Create instance: ilconstant_1, and set properties
  set ilconstant_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {48} \
  ] $ilconstant_1


  # Create instance: INTF0_RX0_slice, and set properties
  set INTF0_RX0_slice [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice INTF0_RX0_slice ]
  set_property -dict [list \
    CONFIG.DIN_FROM {79} \
    CONFIG.DIN_WIDTH {128} \
  ] $INTF0_RX0_slice


  # Create instance: INTF1_RX0_slice, and set properties
  set INTF1_RX0_slice [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice INTF1_RX0_slice ]
  set_property -dict [list \
    CONFIG.DIN_FROM {79} \
    CONFIG.DIN_WIDTH {128} \
  ] $INTF1_RX0_slice


  # Create instance: ilconstant_rst_done_dummy, and set properties
  set ilconstant_rst_done_dummy [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_rst_done_dummy ]

  # Create instance: ilconstant_drive_to_zero, and set properties
  set ilconstant_drive_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero


  # Create instance: ilconstant_drive_to_zero1, and set properties
  set ilconstant_drive_to_zero1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero1 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero1


  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_1 [get_bd_intf_pins CLK_IN_D] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins gtwiz_versal_0/Quad0_GT_Serial] [get_bd_intf_pins Quad0_GT_Serial]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net gt_axi_apb_bridge_0_APB_M [get_bd_intf_pins gt_axi_apb_bridge_0/APB_M] [get_bd_intf_pins gtwiz_versal_0/Quad0_APB3_INTF]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_gpio_gt_reset_mask/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins AXI4_LITE] [get_bd_intf_pins gt_axi_apb_bridge_0/AXI4_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI1 [get_bd_intf_pins axi_gpio_gt_rate_reset_ctl_0/S_AXI] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_gpio_gt_rate_reset_ctl_1/S_AXI] [get_bd_intf_pins smartconnect_0/M02_AXI]

  # Create port connections
  connect_bd_net -net INTF0_RX0_slice_Dout  [get_bd_pins INTF0_RX0_slice/Dout] \
  [get_bd_pins INTF0_RX0_ch_rxdata]
  connect_bd_net -net INTF0_TX0_ch_txdata_1  [get_bd_pins INTF0_TX0_ch_txdata] \
  [get_bd_pins INTF0_TX0_concat/In0]
  connect_bd_net -net INTF1_RX0_slice_Dout  [get_bd_pins INTF1_RX0_slice/Dout] \
  [get_bd_pins INTF1_RX0_ch_rxdata]
  connect_bd_net -net INTF1_TX0_ch_txdata_1  [get_bd_pins INTF1_TX0_ch_txdata] \
  [get_bd_pins INTF1_TX0_concat/In0]
  connect_bd_net -net INTF1_TX0_concat_dout  [get_bd_pins INTF1_TX0_concat/dout] \
  [get_bd_pins gtwiz_versal_0/INTF1_TX0_ch_txdata]
  connect_bd_net -net QUAD0_apb3presetn_1  [get_bd_pins QUAD0_apb3presetn] \
  [get_bd_pins gtwiz_versal_0/QUAD0_apb3presetn]
  connect_bd_net -net TX0_concat_dout  [get_bd_pins INTF0_TX0_concat/dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_TX0_ch_txdata]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl_0_gpio2_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl_0/gpio2_io_o] \
  [get_bd_pins xlslice_gt_reset_all_0/Din] \
  [get_bd_pins xlslice_gt_reset_rx_datapath_0/Din] \
  [get_bd_pins xlslice_gt_reset_tx_datapath_0/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl_0_gpio_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl_0/gpio_io_o] \
  [get_bd_pins gt_rate_ctl_ch0_tx_rx/Din] \
  [get_bd_pins xlslice_gt_loopback_en_0/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl_1_gpio2_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl_1/gpio2_io_o] \
  [get_bd_pins xlslice_gt_reset_all_1/Din] \
  [get_bd_pins xlslice_gt_reset_rx_datapath_1/Din] \
  [get_bd_pins xlslice_gt_reset_tx_datapath_1/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl_1_gpio_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl_1/gpio_io_o] \
  [get_bd_pins gt_rate_ctl_ch1_tx_rx/Din] \
  [get_bd_pins xlslice_gt_loopback_en_1/Din]
  connect_bd_net -net bufg_gt_div_val_dout  [get_bd_pins bufg_gt_div_val/dout] \
  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch0/gt_bufgtdiv] \
  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch1/gt_bufgtdiv] \
  [get_bd_pins gt_bufg_gt_txoutclk_div2_ch0/gt_bufgtdiv]
  connect_bd_net -net bufg_gt_rxoutclk_rx_usr_clk  [get_bd_pins bufg_gt_rxoutclk/rx_usr_clk] \
  [get_bd_pins rx_usr_clk1]
  connect_bd_net -net bufg_gt_txoutclk_tx_usr_clk  [get_bd_pins bufg_gt_txoutclk/tx_usr_clk] \
  [get_bd_pins tx_usr_clk]
  connect_bd_net -net conct_rx_usr_clk2_dout  [get_bd_pins conct_rx_usr_clk2/dout] \
  [get_bd_pins rx_usr_clk2]
  connect_bd_net -net conct_tx_usr_clk2_dout  [get_bd_pins conct_tx_usr_clk2/dout] \
  [get_bd_pins tx_usr_clk2]
  connect_bd_net -net gt_bufg_gt_refclk_fwd_usrclk  [get_bd_pins gt_bufg_gt_refclk_fwd/usrclk] \
  [get_bd_pins gt_refclk_div2_fwd]
  connect_bd_net -net gt_bufg_gt_rxoutclk_div2_ch0_usrclk  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch0/usrclk] \
  [get_bd_pins conct_rx_usr_clk2/In0] \
  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_usrclk]
  connect_bd_net -net gt_bufg_gt_rxoutclk_div2_ch1_usrclk  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch1/usrclk] \
  [get_bd_pins conct_rx_usr_clk2/In1] \
  [get_bd_pins gtwiz_versal_0/QUAD0_RX1_usrclk]
  connect_bd_net -net gt_bufg_gt_txoutclk_div2_ch0_usrclk  [get_bd_pins gt_bufg_gt_txoutclk_div2_ch0/usrclk] \
  [get_bd_pins conct_tx_usr_clk2/In0] \
  [get_bd_pins conct_tx_usr_clk2/In1] \
  [get_bd_pins gtwiz_versal_0/QUAD0_TX1_usrclk] \
  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_usrclk]
  connect_bd_net -net gt_quad_base_ch0_rxoutclk  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_outclk] \
  [get_bd_pins bufg_gt_rxoutclk/outclk] \
  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch0/outclk]
  connect_bd_net -net gt_quad_base_ch1_rxoutclk  [get_bd_pins gtwiz_versal_0/QUAD0_RX1_outclk] \
  [get_bd_pins bufg_gt_rxoutclk/outclk1] \
  [get_bd_pins gt_bufg_gt_rxoutclk_div2_ch1/outclk]
  connect_bd_net -net gt_rate_ctl_ch0_tx_rx_Dout  [get_bd_pins gt_rate_ctl_ch0_tx_rx/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_RX0_ch_rxrate] \
  [get_bd_pins gtwiz_versal_0/INTF0_TX0_ch_txrate]
  connect_bd_net -net gt_rate_ctl_ch1_tx_rx_Dout  [get_bd_pins gt_rate_ctl_ch1_tx_rx/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF1_RX0_ch_rxrate] \
  [get_bd_pins gtwiz_versal_0/INTF1_TX0_ch_txrate]
  connect_bd_net -net gtwiz_freerun_clk_1  [get_bd_pins gtwiz_freerun_clk] \
  [get_bd_pins gtwiz_versal_0/gtwiz_freerun_clk]
  connect_bd_net -net gtwiz_versal_0_INTF0_RX0_ch_rxdata  [get_bd_pins gtwiz_versal_0/INTF0_RX0_ch_rxdata] \
  [get_bd_pins INTF0_RX0_slice/Din]
  connect_bd_net -net gtwiz_versal_0_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_done_out] \
  [get_bd_pins rx_reset_done/In0]
  connect_bd_net -net gtwiz_versal_0_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_done_out] \
  [get_bd_pins tx_reset_done/In0]
  connect_bd_net -net gtwiz_versal_0_INTF1_RX0_ch_rxdata  [get_bd_pins gtwiz_versal_0/INTF1_RX0_ch_rxdata] \
  [get_bd_pins INTF1_RX0_slice/Din]
  connect_bd_net -net gtwiz_versal_0_INTF1_rst_rx_done_out  [get_bd_pins gtwiz_versal_0/INTF1_rst_rx_done_out] \
  [get_bd_pins rx_reset_done/In1]
  connect_bd_net -net gtwiz_versal_0_INTF1_rst_tx_done_out  [get_bd_pins gtwiz_versal_0/INTF1_rst_tx_done_out] \
  [get_bd_pins tx_reset_done/In1]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_outclk] \
  [get_bd_pins bufg_gt_txoutclk/outclk] \
  [get_bd_pins gt_bufg_gt_txoutclk_div2_ch0/outclk]
  connect_bd_net -net gtwiz_versal_0_gtpowergood  [get_bd_pins gtwiz_versal_0/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net ilconcat_1_dout  [get_bd_pins ilconcat_1/dout] \
  [get_bd_pins axi_gpio_gt_reset_mask/gpio2_io_i]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_pll_and_datapath_in] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_tx_pll_and_datapath_in] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_pll_and_datapath_in] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_rx_pll_and_datapath_in]
  connect_bd_net -net ilconstant_1_dout  [get_bd_pins ilconstant_1/dout] \
  [get_bd_pins INTF1_TX0_concat/In1] \
  [get_bd_pins INTF0_TX0_concat/In1]
  connect_bd_net -net ilconstant_drive_to_zero1_dout  [get_bd_pins ilconstant_drive_to_zero1/dout] \
  [get_bd_pins conct_rx_usr_clk2/In2] \
  [get_bd_pins conct_rx_usr_clk2/In3]
  connect_bd_net -net ilconstant_drive_to_zero_dout  [get_bd_pins ilconstant_drive_to_zero/dout] \
  [get_bd_pins conct_tx_usr_clk2/In2] \
  [get_bd_pins conct_tx_usr_clk2/In3]
  connect_bd_net -net ilconstant_rst_done_dout  [get_bd_pins ilconstant_rst_done_dummy/dout] \
  [get_bd_pins tx_reset_done/In2] \
  [get_bd_pins tx_reset_done/In3] \
  [get_bd_pins rx_reset_done/In3] \
  [get_bd_pins rx_reset_done/In2]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins gt_axi_apb_bridge_0/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl_0/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl_1/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_reset_mask/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net rx_reset_done_dout  [get_bd_pins rx_reset_done/dout] \
  [get_bd_pins rx_reset_done] \
  [get_bd_pins ilconcat_1/In0]
  connect_bd_net -net tx_reset_done_dout  [get_bd_pins tx_reset_done/dout] \
  [get_bd_pins tx_reset_done] \
  [get_bd_pins ilconcat_1/In1]
  connect_bd_net -net util_ds_buf_0_IBUF_DS_ODIV2  [get_bd_pins util_ds_buf_0/IBUF_DS_ODIV2] \
  [get_bd_pins gt_bufg_gt_refclk_fwd/outclk]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT  [get_bd_pins util_ds_buf_0/IBUF_OUT] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK0]
  connect_bd_net -net versal_cips_0_pl_clk0  [get_bd_pins s_axi_aclk] \
  [get_bd_pins gt_axi_apb_bridge_0/s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl_0/s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl_1/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins axi_gpio_gt_reset_mask/s_axi_aclk]
  connect_bd_net -net xlslice_gt_loopback_en_0_Dout  [get_bd_pins xlslice_gt_loopback_en_0/Dout] \
  [get_bd_pins gtwiz_versal_0/QUAD0_ch0_loopback]
  connect_bd_net -net xlslice_gt_loopback_en_1_Dout  [get_bd_pins xlslice_gt_loopback_en_1/Dout] \
  [get_bd_pins gtwiz_versal_0/QUAD0_ch1_loopback]
  connect_bd_net -net xlslice_gt_reset_all_0_Dout  [get_bd_pins xlslice_gt_reset_all_0/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_all_in]
  connect_bd_net -net xlslice_gt_reset_all_1_Dout  [get_bd_pins xlslice_gt_reset_all_1/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_all_in]
  connect_bd_net -net xlslice_gt_reset_rx_datapath_0_Dout  [get_bd_pins xlslice_gt_reset_rx_datapath_0/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_datapath_in]
  connect_bd_net -net xlslice_gt_reset_rx_datapath_1_Dout  [get_bd_pins xlslice_gt_reset_rx_datapath_1/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_rx_datapath_in]
  connect_bd_net -net xlslice_gt_reset_tx_datapath_0_Dout  [get_bd_pins xlslice_gt_reset_tx_datapath_0/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_datapath_in]
  connect_bd_net -net xlslice_gt_reset_tx_datapath_1_Dout  [get_bd_pins xlslice_gt_reset_tx_datapath_1/Dout] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_tx_datapath_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth0_bufs
proc create_hier_cell_eth0_bufs { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_eth0_bufs() - Empty argument(s)!"}
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
  create_bd_pin -dir IO mdio_io
  create_bd_pin -dir IO mdc_io
  create_bd_pin -dir IO reset_phy_n_io
  create_bd_pin -dir I -type clk clk_25MHz_in
  create_bd_pin -dir I mdio_t
  create_bd_pin -dir O -from 0 -to 0 mdio_i
  create_bd_pin -dir I mdio_o
  create_bd_pin -dir I mdc
  create_bd_pin -dir I reset_phy_n
  create_bd_pin -dir O -type clk clk_25MHz

  # Create instance: mdio, and set properties
  set mdio [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mdio ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $mdio


  # Create instance: mdc, and set properties
  set mdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mdc ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $mdc


  # Create instance: reset_phy_n, and set properties
  set reset_phy_n [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf reset_phy_n ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $reset_phy_n


  # Create instance: clk_shim, and set properties
  set block_name clk_shim
  set block_cell_name clk_shim
  if { [catch {set clk_shim [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clk_shim eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net clk_shim_in  [get_bd_pins clk_25MHz_in] \
  [get_bd_pins clk_shim/clk_in]
  connect_bd_net -net clk_shim_out  [get_bd_pins clk_shim/clk_out] \
  [get_bd_pins clk_25MHz]
  connect_bd_net -net mdc  [get_bd_pins mdc] \
  [get_bd_pins mdc/IOBUF_IO_I]
  connect_bd_net -net mdc_io  [get_bd_pins mdc_io] \
  [get_bd_pins mdc/IOBUF_IO_IO]
  connect_bd_net -net mdio_i  [get_bd_pins mdio/IOBUF_IO_O] \
  [get_bd_pins mdio_i]
  connect_bd_net -net mdio_io  [get_bd_pins mdio_io] \
  [get_bd_pins mdio/IOBUF_IO_IO]
  connect_bd_net -net mdio_o  [get_bd_pins mdio_o] \
  [get_bd_pins mdio/IOBUF_IO_I]
  connect_bd_net -net mdio_t  [get_bd_pins mdio_t] \
  [get_bd_pins mdio/IOBUF_IO_T]
  connect_bd_net -net reset_phy_n  [get_bd_pins reset_phy_n] \
  [get_bd_pins reset_phy_n/IOBUF_IO_I]
  connect_bd_net -net reset_phy_n_io  [get_bd_pins reset_phy_n_io] \
  [get_bd_pins reset_phy_n/IOBUF_IO_IO]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth1_bufs
proc create_hier_cell_eth1_bufs { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_eth1_bufs() - Empty argument(s)!"}
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
  create_bd_pin -dir IO mdio_io
  create_bd_pin -dir IO mdc_io
  create_bd_pin -dir IO reset_phy_n_io
  create_bd_pin -dir I -type clk clk_25MHz_in
  create_bd_pin -dir I mdio_t
  create_bd_pin -dir O -from 0 -to 0 mdio_i
  create_bd_pin -dir I mdio_o
  create_bd_pin -dir I mdc
  create_bd_pin -dir I reset_phy_n
  create_bd_pin -dir O -type clk clk_25MHz

  # Create instance: mdio, and set properties
  set mdio [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mdio ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $mdio


  # Create instance: mdc, and set properties
  set mdc [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mdc ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $mdc


  # Create instance: reset_phy_n, and set properties
  set reset_phy_n [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf reset_phy_n ]
  set_property CONFIG.C_BUF_TYPE {IOBUF} $reset_phy_n


  # Create instance: clk_shim, and set properties
  set block_name clk_shim
  set block_cell_name clk_shim
  if { [catch {set clk_shim [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clk_shim eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net clk_shim_in  [get_bd_pins clk_25MHz_in] \
  [get_bd_pins clk_shim/clk_in]
  connect_bd_net -net clk_shim_out  [get_bd_pins clk_shim/clk_out] \
  [get_bd_pins clk_25MHz]
  connect_bd_net -net mdc  [get_bd_pins mdc] \
  [get_bd_pins mdc/IOBUF_IO_I]
  connect_bd_net -net mdc_io  [get_bd_pins mdc_io] \
  [get_bd_pins mdc/IOBUF_IO_IO]
  connect_bd_net -net mdio_i  [get_bd_pins mdio/IOBUF_IO_O] \
  [get_bd_pins mdio_i]
  connect_bd_net -net mdio_io  [get_bd_pins mdio_io] \
  [get_bd_pins mdio/IOBUF_IO_IO]
  connect_bd_net -net mdio_o  [get_bd_pins mdio_o] \
  [get_bd_pins mdio/IOBUF_IO_I]
  connect_bd_net -net mdio_t  [get_bd_pins mdio_t] \
  [get_bd_pins mdio/IOBUF_IO_T]
  connect_bd_net -net reset_phy_n  [get_bd_pins reset_phy_n] \
  [get_bd_pins reset_phy_n/IOBUF_IO_I]
  connect_bd_net -net reset_phy_n_io  [get_bd_pins reset_phy_n_io] \
  [get_bd_pins reset_phy_n/IOBUF_IO_IO]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: MRMAC_GT
proc create_hier_cell_MRMAC_GT { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_MRMAC_GT() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_LITE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN_D

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_mrmac

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 Quad0_GT_Serial_0


  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -from 63 -to 0 rx_axis_tdata0
  create_bd_pin -dir O -from 63 -to 0 rx_axis_tdata2
  create_bd_pin -dir O -from 10 -to 0 rx_axis_tkeep_user0
  create_bd_pin -dir O -from 10 -to 0 rx_axis_tkeep_user2
  create_bd_pin -dir O rx_axis_tlast_0
  create_bd_pin -dir O rx_axis_tlast_1
  create_bd_pin -dir O rx_axis_tvalid_0
  create_bd_pin -dir O rx_axis_tvalid_1
  create_bd_pin -dir O tx_axis_tready_0
  create_bd_pin -dir O tx_axis_tready_1
  create_bd_pin -dir I -from 3 -to 0 -type clk rx_axi_clk
  create_bd_pin -dir I -from 0 -to 3 -type rst rx_flexif_reset
  create_bd_pin -dir I -from 3 -to 0 -type clk rx_ts_clk
  create_bd_pin -dir I -from 63 -to 0 tx_axis_tdata0
  create_bd_pin -dir I -from 63 -to 0 tx_axis_tdata2
  create_bd_pin -dir I -from 10 -to 0 tx_axis_tkeep_user0
  create_bd_pin -dir I -from 10 -to 0 tx_axis_tkeep_user2
  create_bd_pin -dir I tx_axis_tlast_0
  create_bd_pin -dir I tx_axis_tlast_1
  create_bd_pin -dir I tx_axis_tvalid_0
  create_bd_pin -dir I tx_axis_tvalid_1
  create_bd_pin -dir I -from 3 -to 0 -type clk tx_axi_clk_0

  # Create instance: mrmac_0, and set properties
  set mrmac_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mrmac mrmac_0 ]
  set_property -dict [list \
    CONFIG.GT_REF_CLK_FREQ_C0 {156.25} \
    CONFIG.MAC_PORT0_RATE_C0 {10GE} \
    CONFIG.MAC_PORT1_RATE_C0 {10GE} \
    CONFIG.MAC_PORT2_RATE_C0 {N/U} \
    CONFIG.MAC_PORT3_RATE_C0 {N/U} \
    CONFIG.MRMAC_MODE_C0 {MAC+PCS} \
    CONFIG.MRMAC_PRESET_C0 {Start from scratch} \
    CONFIG.MRMAC_SPEED_C0 {Mixed/Custom} \
  ] $mrmac_0


  # Create instance: GT
  create_hier_cell_GT $hier_obj GT

  # Create instance: ilconstant_drive_to_zero_4bit, and set properties
  set ilconstant_drive_to_zero_4bit [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero_4bit ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $ilconstant_drive_to_zero_4bit


  # Create instance: ilconstant_drive_to_zero2, and set properties
  set ilconstant_drive_to_zero2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero2 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero2


  # Create instance: ilconstant_drive_to_zero_8bit, and set properties
  set ilconstant_drive_to_zero_8bit [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero_8bit ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {8} \
  ] $ilconstant_drive_to_zero_8bit


  # Create instance: ilconstant_drive_zero_66bit, and set properties
  set ilconstant_drive_zero_66bit [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_zero_66bit ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {66} \
  ] $ilconstant_drive_zero_66bit


  # Create instance: ilconstant_drive_to_zero3, and set properties
  set ilconstant_drive_to_zero3 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_drive_to_zero3 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_drive_to_zero3


  # Create instance: ilconstant_tx_preamble_in, and set properties
  set ilconstant_tx_preamble_in [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_tx_preamble_in ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x555555555555d5} \
    CONFIG.CONST_WIDTH {56} \
  ] $ilconstant_tx_preamble_in


  # Create instance: ilvector_logic_rx_reset, and set properties
  set ilvector_logic_rx_reset [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_rx_reset ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {4} \
  ] $ilvector_logic_rx_reset


  # Create instance: ilvector_logic_tx_reset, and set properties
  set ilvector_logic_tx_reset [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_tx_reset ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {4} \
  ] $ilvector_logic_tx_reset


  # Create interface connections
  connect_bd_intf_net -intf_net AXI4_LITE_0_1 [get_bd_intf_pins AXI4_LITE] [get_bd_intf_pins GT/AXI4_LITE]
  connect_bd_intf_net -intf_net CLK_IN_D_0_1 [get_bd_intf_pins CLK_IN_D] [get_bd_intf_pins GT/CLK_IN_D]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins mrmac_0/s_axi] [get_bd_intf_pins s_axi_mrmac]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins GT/Quad0_GT_Serial] [get_bd_intf_pins Quad0_GT_Serial_0]
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins GT/S00_AXI]

  # Create port connections
  connect_bd_net -net GT_WRAPPER_INTF0_RX0_ch_rxdata  [get_bd_pins GT/INTF0_RX0_ch_rxdata] \
  [get_bd_pins mrmac_0/rx_serdes_data0]
  connect_bd_net -net GT_WRAPPER_INTF1_RX0_ch_rxdata  [get_bd_pins GT/INTF1_RX0_ch_rxdata] \
  [get_bd_pins mrmac_0/rx_serdes_data1]
  connect_bd_net -net GT_WRAPPER_rx_reset_done  [get_bd_pins GT/rx_reset_done] \
  [get_bd_pins ilvector_logic_rx_reset/Op1]
  connect_bd_net -net GT_WRAPPER_rx_usr_clk1  [get_bd_pins GT/rx_usr_clk1] \
  [get_bd_pins mrmac_0/rx_core_clk] \
  [get_bd_pins mrmac_0/rx_serdes_clk]
  connect_bd_net -net GT_WRAPPER_rx_usr_clk2  [get_bd_pins GT/rx_usr_clk2] \
  [get_bd_pins mrmac_0/rx_alt_serdes_clk] \
  [get_bd_pins mrmac_0/rx_flexif_clk]
  connect_bd_net -net GT_WRAPPER_tx_reset_done  [get_bd_pins GT/tx_reset_done] \
  [get_bd_pins ilvector_logic_tx_reset/Op1]
  connect_bd_net -net GT_WRAPPER_tx_usr_clk  [get_bd_pins GT/tx_usr_clk] \
  [get_bd_pins mrmac_0/tx_core_clk]
  connect_bd_net -net GT_WRAPPER_tx_usr_clk2  [get_bd_pins GT/tx_usr_clk2] \
  [get_bd_pins mrmac_0/tx_alt_serdes_clk] \
  [get_bd_pins mrmac_0/tx_flexif_clk]
  connect_bd_net -net Net  [get_bd_pins ilconstant_drive_to_zero_8bit/dout] \
  [get_bd_pins mrmac_0/ctl_tx_lane0_vlm_bip7_override_value_23] \
  [get_bd_pins mrmac_0/ctl_tx_lane0_vlm_bip7_override_value_01]
  connect_bd_net -net Net1  [get_bd_pins ilconstant_drive_to_zero2/dout] \
  [get_bd_pins mrmac_0/ctl_tx_send_idle_in_0] \
  [get_bd_pins mrmac_0/ctl_tx_send_lfi_in_0] \
  [get_bd_pins mrmac_0/ctl_tx_send_rfi_in_0] \
  [get_bd_pins mrmac_0/ctl_tx_send_idle_in_1] \
  [get_bd_pins mrmac_0/ctl_tx_send_lfi_in_1] \
  [get_bd_pins mrmac_0/ctl_tx_send_rfi_in_1] \
  [get_bd_pins mrmac_0/ctl_tx_send_idle_in_2] \
  [get_bd_pins mrmac_0/ctl_tx_lane0_vlm_bip7_override_23] \
  [get_bd_pins mrmac_0/ctl_tx_send_lfi_in_2] \
  [get_bd_pins mrmac_0/ctl_tx_send_rfi_in_2] \
  [get_bd_pins mrmac_0/ctl_tx_send_idle_in_3] \
  [get_bd_pins mrmac_0/ctl_tx_send_lfi_in_3] \
  [get_bd_pins mrmac_0/ctl_tx_send_rfi_in_3] \
  [get_bd_pins mrmac_0/ctl_tx_lane0_vlm_bip7_override_01]
  connect_bd_net -net Net2  [get_bd_pins ilconstant_drive_to_zero3/dout] \
  [get_bd_pins mrmac_0/tx_flex_almarker0] \
  [get_bd_pins mrmac_0/tx_flex_almarker7] \
  [get_bd_pins mrmac_0/tx_flex_almarker1] \
  [get_bd_pins mrmac_0/tx_flex_almarker2] \
  [get_bd_pins mrmac_0/tx_flex_almarker3] \
  [get_bd_pins mrmac_0/tx_flex_almarker4] \
  [get_bd_pins mrmac_0/tx_flex_almarker5] \
  [get_bd_pins mrmac_0/tx_flex_almarker6] \
  [get_bd_pins mrmac_0/rx_flex_cm_ena_1] \
  [get_bd_pins mrmac_0/rx_flex_cm_ena_2] \
  [get_bd_pins mrmac_0/rx_flex_cm_ena_3] \
  [get_bd_pins mrmac_0/tx_flex_ena_0] \
  [get_bd_pins mrmac_0/tx_flex_ena_3] \
  [get_bd_pins mrmac_0/tx_flex_ena_2] \
  [get_bd_pins mrmac_0/tx_flex_ena_1] \
  [get_bd_pins mrmac_0/rx_flex_cm_ena_0]
  connect_bd_net -net Net3  [get_bd_pins ilconstant_drive_zero_66bit/dout] \
  [get_bd_pins mrmac_0/tx_flex_data0] \
  [get_bd_pins mrmac_0/rx_flex_cm_data0]
  connect_bd_net -net Net4  [get_bd_pins ilconstant_tx_preamble_in/dout] \
  [get_bd_pins mrmac_0/tx_preamblein_1] \
  [get_bd_pins mrmac_0/tx_preamblein_2] \
  [get_bd_pins mrmac_0/tx_preamblein_3] \
  [get_bd_pins mrmac_0/tx_preamblein_0]
  connect_bd_net -net ilconstant_drive_to_zero_4bit_dout  [get_bd_pins ilconstant_drive_to_zero_4bit/dout] \
  [get_bd_pins mrmac_0/pm_tick]
  connect_bd_net -net ilvector_logic_rx_reset_Res  [get_bd_pins ilvector_logic_rx_reset/Res] \
  [get_bd_pins mrmac_0/rx_core_reset] \
  [get_bd_pins mrmac_0/rx_serdes_reset]
  connect_bd_net -net ilvector_logic_tx_reset_Res  [get_bd_pins ilvector_logic_tx_reset/Res] \
  [get_bd_pins mrmac_0/tx_core_reset] \
  [get_bd_pins mrmac_0/tx_serdes_reset]
  connect_bd_net -net mrmac_0_rx_axis_tdata0  [get_bd_pins mrmac_0/rx_axis_tdata0] \
  [get_bd_pins rx_axis_tdata0]
  connect_bd_net -net mrmac_0_rx_axis_tdata2  [get_bd_pins mrmac_0/rx_axis_tdata2] \
  [get_bd_pins rx_axis_tdata2]
  connect_bd_net -net mrmac_0_rx_axis_tkeep_user0  [get_bd_pins mrmac_0/rx_axis_tkeep_user0] \
  [get_bd_pins rx_axis_tkeep_user0]
  connect_bd_net -net mrmac_0_rx_axis_tkeep_user2  [get_bd_pins mrmac_0/rx_axis_tkeep_user2] \
  [get_bd_pins rx_axis_tkeep_user2]
  connect_bd_net -net mrmac_0_rx_axis_tlast_0  [get_bd_pins mrmac_0/rx_axis_tlast_0] \
  [get_bd_pins rx_axis_tlast_0]
  connect_bd_net -net mrmac_0_rx_axis_tlast_1  [get_bd_pins mrmac_0/rx_axis_tlast_1] \
  [get_bd_pins rx_axis_tlast_1]
  connect_bd_net -net mrmac_0_rx_axis_tvalid_0  [get_bd_pins mrmac_0/rx_axis_tvalid_0] \
  [get_bd_pins rx_axis_tvalid_0]
  connect_bd_net -net mrmac_0_rx_axis_tvalid_1  [get_bd_pins mrmac_0/rx_axis_tvalid_1] \
  [get_bd_pins rx_axis_tvalid_1]
  connect_bd_net -net mrmac_0_tx_axis_tready_0  [get_bd_pins mrmac_0/tx_axis_tready_0] \
  [get_bd_pins tx_axis_tready_0]
  connect_bd_net -net mrmac_0_tx_axis_tready_1  [get_bd_pins mrmac_0/tx_axis_tready_1] \
  [get_bd_pins tx_axis_tready_1]
  connect_bd_net -net mrmac_0_tx_serdes_data0  [get_bd_pins mrmac_0/tx_serdes_data0] \
  [get_bd_pins GT/INTF0_TX0_ch_txdata]
  connect_bd_net -net mrmac_0_tx_serdes_data1  [get_bd_pins mrmac_0/tx_serdes_data1] \
  [get_bd_pins GT/INTF1_TX0_ch_txdata]
  connect_bd_net -net rx_axi_clk_0_1  [get_bd_pins rx_axi_clk] \
  [get_bd_pins mrmac_0/rx_axi_clk]
  connect_bd_net -net rx_flexif_reset_0_1  [get_bd_pins rx_flexif_reset] \
  [get_bd_pins mrmac_0/rx_flexif_reset]
  connect_bd_net -net rx_ts_clk_0_1  [get_bd_pins rx_ts_clk] \
  [get_bd_pins mrmac_0/tx_ts_clk] \
  [get_bd_pins mrmac_0/rx_ts_clk]
  connect_bd_net -net s_axi_aclk_0_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins GT/s_axi_aclk] \
  [get_bd_pins GT/gtwiz_freerun_clk] \
  [get_bd_pins mrmac_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_0_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins GT/s_axi_aresetn] \
  [get_bd_pins GT/QUAD0_apb3presetn] \
  [get_bd_pins mrmac_0/s_axi_aresetn]
  connect_bd_net -net tx_axi_clk_0_1  [get_bd_pins tx_axi_clk_0] \
  [get_bd_pins mrmac_0/tx_axi_clk]
  connect_bd_net -net tx_axis_tdata0_0_1  [get_bd_pins tx_axis_tdata0] \
  [get_bd_pins mrmac_0/tx_axis_tdata0]
  connect_bd_net -net tx_axis_tdata2_0_1  [get_bd_pins tx_axis_tdata2] \
  [get_bd_pins mrmac_0/tx_axis_tdata2]
  connect_bd_net -net tx_axis_tkeep_user0_0_1  [get_bd_pins tx_axis_tkeep_user0] \
  [get_bd_pins mrmac_0/tx_axis_tkeep_user0]
  connect_bd_net -net tx_axis_tkeep_user2_0_1  [get_bd_pins tx_axis_tkeep_user2] \
  [get_bd_pins mrmac_0/tx_axis_tkeep_user2]
  connect_bd_net -net tx_axis_tlast_0_0_1  [get_bd_pins tx_axis_tlast_0] \
  [get_bd_pins mrmac_0/tx_axis_tlast_0]
  connect_bd_net -net tx_axis_tlast_1_0_1  [get_bd_pins tx_axis_tlast_1] \
  [get_bd_pins mrmac_0/tx_axis_tlast_1]
  connect_bd_net -net tx_axis_tvalid_0_0_1  [get_bd_pins tx_axis_tvalid_0] \
  [get_bd_pins mrmac_0/tx_axis_tvalid_0]
  connect_bd_net -net tx_axis_tvalid_1_0_1  [get_bd_pins tx_axis_tvalid_1] \
  [get_bd_pins mrmac_0/tx_axis_tvalid_1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: tieoff_unused
proc create_hier_cell_tieoff_unused { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_tieoff_unused() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_PCIE

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_1


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: axi_vip_0, and set properties
  set axi_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_0 ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.INTERFACE_MODE {SLAVE} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
  ] $axi_vip_0


  # Create instance: axi_vip_1, and set properties
  set axi_vip_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_1 ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {1} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {0} \
    CONFIG.INTERFACE_MODE {MASTER} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW {1} \
    CONFIG.WUSER_WIDTH {0} \
  ] $axi_vip_1


  # Create instance: axi_vip_2, and set properties
  set axi_vip_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_2 ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {1} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {0} \
    CONFIG.INTERFACE_MODE {MASTER} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW {1} \
    CONFIG.WUSER_WIDTH {0} \
  ] $axi_vip_2


  # Create interface connections
  connect_bd_intf_net -intf_net M_AXI_0 [get_bd_intf_pins M_AXI_0] [get_bd_intf_pins axi_vip_1/M_AXI]
  connect_bd_intf_net -intf_net M_AXI_1 [get_bd_intf_pins M_AXI_1] [get_bd_intf_pins axi_vip_2/M_AXI]
  connect_bd_intf_net -intf_net S_AXI_PCIE [get_bd_intf_pins S_AXI_PCIE] [get_bd_intf_pins axi_vip_0/S_AXI]

  # Create port connections
  connect_bd_net -net aclk  [get_bd_pins aclk] \
  [get_bd_pins axi_vip_0/aclk] \
  [get_bd_pins axi_vip_1/aclk] \
  [get_bd_pins axi_vip_2/aclk]
  connect_bd_net -net aresetn  [get_bd_pins aresetn] \
  [get_bd_pins axi_vip_0/aresetn] \
  [get_bd_pins axi_vip_1/aresetn] \
  [get_bd_pins axi_vip_2/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hier_1g_components
proc create_hier_cell_hier_1g_components { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hier_1g_components() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_1


  # Create pins
  create_bd_pin -dir I -type clk pcie_aclk
  create_bd_pin -dir I -type rst axi_resetn
  create_bd_pin -dir O -type intr mm2s_introut
  create_bd_pin -dir O -type intr s2mm_introut
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir O -type intr mm2s_introut1
  create_bd_pin -dir O -type intr s2mm_introut1
  create_bd_pin -dir O -type intr mac_irq
  create_bd_pin -dir O -type intr interrupt
  create_bd_pin -dir O -type intr mac_irq1
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir IO mdio_1
  create_bd_pin -dir IO mdc_1
  create_bd_pin -dir IO reset_phy_1_n
  create_bd_pin -dir I clk2_25MHz
  create_bd_pin -dir IO mdio_0
  create_bd_pin -dir IO mdc_0
  create_bd_pin -dir IO reset_phy_0_n
  create_bd_pin -dir I clk1_25MHz

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {Buffer,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {125.000,100.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
    CONFIG.PRIM_IN_FREQ {25.000} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
  ] $clk_wizard_0


  # Create instance: ilconcat_1, and set properties
  set ilconcat_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1 ]
  set_property CONFIG.NUM_PORTS {1} $ilconcat_1


  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0 ]
  set_property CONFIG.PHY_TYPE {RGMII} $axi_ethernet_0


  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1 ]
  set_property CONFIG.PHY_TYPE {RGMII} $axi_ethernet_1


  # Create instance: eth1_bufs
  create_hier_cell_eth1_bufs $hier_obj eth1_bufs

  # Create instance: eth0_bufs
  create_hier_cell_eth0_bufs $hier_obj eth0_bufs

  # Create instance: ilconcat_2, and set properties
  set ilconcat_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_2 ]
  set_property CONFIG.NUM_PORTS {1} $ilconcat_2


  # Create instance: clk_wizard_1, and set properties
  set clk_wizard_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_1 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {Buffer,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {125.000,100.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
    CONFIG.PRIM_IN_FREQ {25.000} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
  ] $clk_wizard_1


  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net rgmii_0 [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_pins rgmii_0]
  connect_bd_intf_net -intf_net rgmii_1 [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_pins rgmii_1]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_ethernet_0/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_ethernet_1/s_axi]

  # Create port connections
  connect_bd_net -net axi_ethernet_0_interrupt  [get_bd_pins axi_ethernet_0/interrupt] \
  [get_bd_pins interrupt]
  connect_bd_net -net axi_ethernet_0_mac_irq  [get_bd_pins axi_ethernet_0/mac_irq] \
  [get_bd_pins mac_irq]
  connect_bd_net -net axi_ethernet_0_phy_rst_n  [get_bd_pins axi_ethernet_0/phy_rst_n] \
  [get_bd_pins ilconcat_2/In0]
  connect_bd_net -net axi_ethernet_1_interrupt  [get_bd_pins axi_ethernet_1/interrupt] \
  [get_bd_pins interrupt1]
  connect_bd_net -net axi_ethernet_1_mac_irq  [get_bd_pins axi_ethernet_1/mac_irq] \
  [get_bd_pins mac_irq1]
  connect_bd_net -net axi_ethernet_1_phy_rst_n  [get_bd_pins axi_ethernet_1/phy_rst_n] \
  [get_bd_pins ilconcat_1/In0]
  connect_bd_net -net clk1_25MHz  [get_bd_pins eth0_bufs/clk_25MHz] \
  [get_bd_pins clk_wizard_0/clk_in1]
  connect_bd_net -net clk1_25MHz_io  [get_bd_pins clk1_25MHz] \
  [get_bd_pins eth0_bufs/clk_25MHz_in]
  connect_bd_net -net clk2_25MHz_io  [get_bd_pins clk2_25MHz] \
  [get_bd_pins eth1_bufs/clk_25MHz_in]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clk_wizard_0/clk_out1] \
  [get_bd_pins axi_ethernet_0/gtx_clk]
  connect_bd_net -net clk_wizard_1_clk_out1  [get_bd_pins clk_wizard_1/clk_out1] \
  [get_bd_pins axi_ethernet_1/gtx_clk]
  connect_bd_net -net eth1_bufs_clk_25MHz  [get_bd_pins eth1_bufs/clk_25MHz] \
  [get_bd_pins clk_wizard_1/clk_in1]
  connect_bd_net -net mdc  [get_bd_pins axi_ethernet_1/mdio_mdc] \
  [get_bd_pins eth1_bufs/mdc]
  connect_bd_net -net mdc_0  [get_bd_pins axi_ethernet_0/mdio_mdc] \
  [get_bd_pins eth0_bufs/mdc]
  connect_bd_net -net mdc_0_io  [get_bd_pins mdc_0] \
  [get_bd_pins eth0_bufs/mdc_io]
  connect_bd_net -net mdc_1_io  [get_bd_pins mdc_1] \
  [get_bd_pins eth1_bufs/mdc_io]
  connect_bd_net -net mdio_0_i  [get_bd_pins eth0_bufs/mdio_i] \
  [get_bd_pins axi_ethernet_0/mdio_mdio_i]
  connect_bd_net -net mdio_0_io  [get_bd_pins mdio_0] \
  [get_bd_pins eth0_bufs/mdio_io]
  connect_bd_net -net mdio_0_o  [get_bd_pins axi_ethernet_0/mdio_mdio_o] \
  [get_bd_pins eth0_bufs/mdio_o]
  connect_bd_net -net mdio_0_t  [get_bd_pins axi_ethernet_0/mdio_mdio_t] \
  [get_bd_pins eth0_bufs/mdio_t]
  connect_bd_net -net mdio_1_i  [get_bd_pins eth1_bufs/mdio_i] \
  [get_bd_pins axi_ethernet_1/mdio_mdio_i]
  connect_bd_net -net mdio_1_io  [get_bd_pins mdio_1] \
  [get_bd_pins eth1_bufs/mdio_io]
  connect_bd_net -net mdio_1_o  [get_bd_pins axi_ethernet_1/mdio_mdio_o] \
  [get_bd_pins eth1_bufs/mdio_o]
  connect_bd_net -net mdio_1_t  [get_bd_pins axi_ethernet_1/mdio_mdio_t] \
  [get_bd_pins eth1_bufs/mdio_t]
  connect_bd_net -net pcie_aclk  [get_bd_pins pcie_aclk] \
  [get_bd_pins axi_ethernet_0/s_axi_lite_clk] \
  [get_bd_pins axi_ethernet_0/axis_clk] \
  [get_bd_pins axi_ethernet_1/s_axi_lite_clk] \
  [get_bd_pins axi_ethernet_1/axis_clk] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net peripheral_aresetn  [get_bd_pins axi_resetn] \
  [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] \
  [get_bd_pins axi_ethernet_1/s_axi_lite_resetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net reset_phy_0_n_io  [get_bd_pins reset_phy_0_n] \
  [get_bd_pins eth0_bufs/reset_phy_n_io]
  connect_bd_net -net reset_phy_1_n  [get_bd_pins ilconcat_1/dout] \
  [get_bd_pins eth1_bufs/reset_phy_n]
  connect_bd_net -net reset_phy_1_n_io  [get_bd_pins reset_phy_1_n] \
  [get_bd_pins eth1_bufs/reset_phy_n_io]
  connect_bd_net -net reset_phy_n_1  [get_bd_pins ilconcat_2/dout] \
  [get_bd_pins eth0_bufs/reset_phy_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hier_10g_components
proc create_hier_cell_hier_10g_components { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hier_10g_components() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN_D

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial


  # Create pins
  create_bd_pin -dir I -type clk pl_0_clk
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir I -type rst pl_0_resetn
  create_bd_pin -dir O -type intr mm2s_ch1_introut
  create_bd_pin -dir O -type intr s2mm_ch1_introut
  create_bd_pin -dir O -type intr mm2s_ch1_introut1
  create_bd_pin -dir O -type intr s2mm_ch1_introut1
  create_bd_pin -dir O -type clk clk_out1

  # Create instance: smartconnect_axi_lite, and set properties
  set smartconnect_axi_lite [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_axi_lite ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_axi_lite


  # Create instance: xlconcat_ts_clk, and set properties
  set xlconcat_ts_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_ts_clk ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_ts_clk


  # Create instance: proc_sys_reset_axis, and set properties
  set proc_sys_reset_axis [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_axis ]

  # Create instance: proc_sys_reset_lite, and set properties
  set proc_sys_reset_lite [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_lite ]
  set_property CONFIG.C_NUM_BUS_RST {4} $proc_sys_reset_lite


  # Create instance: ts_clk_to_zero, and set properties
  set ts_clk_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ts_clk_to_zero ]
  set_property CONFIG.CONST_VAL {0} $ts_clk_to_zero


  # Create instance: axis_clk_to_zero, and set properties
  set axis_clk_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant axis_clk_to_zero ]
  set_property CONFIG.CONST_VAL {0} $axis_clk_to_zero


  # Create instance: xlconcat_tx_rx_axi_clk, and set properties
  set xlconcat_tx_rx_axi_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_tx_rx_axi_clk ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_tx_rx_axi_clk


  # Create instance: MRMAC_GT
  create_hier_cell_MRMAC_GT $hier_obj MRMAC_GT

  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_1 [get_bd_intf_pins CLK_IN_D] [get_bd_intf_pins MRMAC_GT/CLK_IN_D]
  connect_bd_intf_net -intf_net MRMAC_GT_Quad0_GT_Serial_0 [get_bd_intf_pins GT_Serial] [get_bd_intf_pins MRMAC_GT/Quad0_GT_Serial_0]
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_axi_lite/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M00_AXI [get_bd_intf_pins smartconnect_axi_lite/M00_AXI] [get_bd_intf_pins MRMAC_GT/s_axi_mrmac]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M01_AXI [get_bd_intf_pins smartconnect_axi_lite/M01_AXI] [get_bd_intf_pins MRMAC_GT/AXI4_LITE]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M02_AXI [get_bd_intf_pins smartconnect_axi_lite/M02_AXI] [get_bd_intf_pins MRMAC_GT/S00_AXI]

  # Create port connections
  connect_bd_net -net axis_clk_to_zero_dout  [get_bd_pins axis_clk_to_zero/dout] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In2] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In3]
  connect_bd_net -net pl_0_clk  [get_bd_pins pl_0_clk] \
  [get_bd_pins proc_sys_reset_lite/slowest_sync_clk] \
  [get_bd_pins smartconnect_axi_lite/aclk] \
  [get_bd_pins proc_sys_reset_axis/slowest_sync_clk] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In0] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In1] \
  [get_bd_pins smartconnect_axi_lite/aclk1] \
  [get_bd_pins clk_out1] \
  [get_bd_pins MRMAC_GT/s_axi_aclk]
  connect_bd_net -net pl_0_resetn  [get_bd_pins pl_0_resetn] \
  [get_bd_pins proc_sys_reset_axis/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_axis/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn] \
  [get_bd_pins proc_sys_reset_lite/ext_reset_in]
  connect_bd_net -net proc_sys_reset_1_interconnect_aresetn  [get_bd_pins proc_sys_reset_lite/interconnect_aresetn] \
  [get_bd_pins smartconnect_axi_lite/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_lite/peripheral_aresetn] \
  [get_bd_pins MRMAC_GT/s_axi_aresetn]
  connect_bd_net -net rx_flexif_reset_1  [get_bd_pins proc_sys_reset_lite/bus_struct_reset] \
  [get_bd_pins MRMAC_GT/rx_flexif_reset]
  connect_bd_net -net rx_ts_clk_1  [get_bd_pins xlconcat_ts_clk/dout] \
  [get_bd_pins MRMAC_GT/rx_ts_clk]
  connect_bd_net -net ts_clk_to_zero_dout  [get_bd_pins ts_clk_to_zero/dout] \
  [get_bd_pins xlconcat_ts_clk/In2] \
  [get_bd_pins xlconcat_ts_clk/In3] \
  [get_bd_pins xlconcat_ts_clk/In0] \
  [get_bd_pins xlconcat_ts_clk/In1]
  connect_bd_net -net xlconcat_tx_rx_axi_clk_dout  [get_bd_pins xlconcat_tx_rx_axi_clk/dout] \
  [get_bd_pins MRMAC_GT/rx_axi_clk] \
  [get_bd_pins MRMAC_GT/tx_axi_clk_0]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name
  variable dfx_dir

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
  ## Set up interface to STATIC_DESIGN, same for all RMs
  ##
  ####################################################################
  # Source script to set up interface to STATIC_DESIGN
  source ${dfx_dir}/common/bd/static_interface.tcl

  # Create instance: hier_10g_components
  create_hier_cell_hier_10g_components [current_bd_instance .] hier_10g_components

  # Create instance: hier_1g_components
  create_hier_cell_hier_1g_components [current_bd_instance .] hier_1g_components

  # Create instance: tieoff_unused
  create_hier_cell_tieoff_unused [current_bd_instance .] tieoff_unused

  # Create instance: proc_sys_reset_pcie_clk, and set properties
  set proc_sys_reset_pcie_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_pcie_clk ]

  # Create instance: proc_sys_reset_pl0_clk, and set properties
  set proc_sys_reset_pl0_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_pl0_clk ]

  # Create instance: proc_sys_reset_pl1_clk, and set properties
  set proc_sys_reset_pl1_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_pl1_clk ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D [get_bd_intf_ports CLK_IN_D] [get_bd_intf_pins hier_10g_components/CLK_IN_D]
  connect_bd_intf_net -intf_net S_AXI_PCIE [get_bd_intf_pins tieoff_unused/S_AXI_PCIE] [get_bd_intf_pins axi_noc_pcie_fixed/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins axi_noc_fixed_0/M00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net hier_10g_components_GT_Serial [get_bd_intf_ports GT_Serial] [get_bd_intf_pins hier_10g_components/GT_Serial]
  connect_bd_intf_net -intf_net hier_1g_components_rgmii_0 [get_bd_intf_ports RGMII_0] [get_bd_intf_pins hier_1g_components/rgmii_0]
  connect_bd_intf_net -intf_net hier_1g_components_rgmii_1 [get_bd_intf_ports RGMII_1] [get_bd_intf_pins hier_1g_components/rgmii_1]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins hier_1g_components/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins hier_10g_components/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_intc_fpd/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_intc_lpd/s_axi]
  connect_bd_intf_net -intf_net tieoff_unused_M_AXI [get_bd_intf_pins tieoff_unused/M_AXI_0] [get_bd_intf_pins axi_noc_fixed_1/S00_AXI]
  connect_bd_intf_net -intf_net tieoff_unused_M_AXI1 [get_bd_intf_pins tieoff_unused/M_AXI_1] [get_bd_intf_pins axi_noc_fixed_1/S01_AXI]

  # Create port connections
  connect_bd_net -net Net  [get_bd_ports mdc_0] \
  [get_bd_pins hier_1g_components/mdc_0]
  connect_bd_net -net Net1  [get_bd_ports mdio_0] \
  [get_bd_pins hier_1g_components/mdio_0]
  connect_bd_net -net Net2  [get_bd_ports reset_phy_1_n] \
  [get_bd_pins hier_1g_components/reset_phy_1_n]
  connect_bd_net -net Net3  [get_bd_ports reset_phy_0_n] \
  [get_bd_pins hier_1g_components/reset_phy_0_n]
  connect_bd_net -net Net4  [get_bd_ports mdc_1] \
  [get_bd_pins hier_1g_components/mdc_1]
  connect_bd_net -net Net5  [get_bd_ports mdio_1] \
  [get_bd_pins hier_1g_components/mdio_1]
  connect_bd_net -net clk1_25MHz_1  [get_bd_ports clk1_25MHz] \
  [get_bd_pins hier_1g_components/clk2_25MHz]
  connect_bd_net -net clk2_25MHz_1  [get_bd_ports clk2_25MHz] \
  [get_bd_pins hier_1g_components/clk1_25MHz]
  connect_bd_net -net pcie_aclk_1  [get_bd_ports pcie_aclk] \
  [get_bd_pins axi_noc_pcie_fixed/aclk0] \
  [get_bd_pins proc_sys_reset_pcie_clk/slowest_sync_clk] \
  [get_bd_pins hier_1g_components/pcie_aclk] \
  [get_bd_pins tieoff_unused/aclk] \
  [get_bd_pins axi_noc_fixed_1/aclk0] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net pcie_aresetn_1  [get_bd_ports pcie_aresetn] \
  [get_bd_pins proc_sys_reset_pcie_clk/ext_reset_in]
  connect_bd_net -net pl_0_clk_1  [get_bd_ports pl_0_clk] \
  [get_bd_pins proc_sys_reset_pl0_clk/slowest_sync_clk] \
  [get_bd_pins axi_intc_lpd/s_axi_aclk] \
  [get_bd_pins hier_10g_components/pl_0_clk] \
  [get_bd_pins axi_noc_fixed_0/aclk0] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net pl_0_resetn_1  [get_bd_ports pl_0_resetn] \
  [get_bd_pins proc_sys_reset_pl0_clk/ext_reset_in]
  connect_bd_net -net pl_1_clk_1  [get_bd_ports pl_1_clk] \
  [get_bd_pins proc_sys_reset_pl1_clk/slowest_sync_clk] \
  [get_bd_pins axi_intc_fpd/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk2]
  connect_bd_net -net pl_1_resetn_1  [get_bd_ports pl_1_resetn] \
  [get_bd_pins proc_sys_reset_pl1_clk/ext_reset_in]
  connect_bd_net -net proc_sys_reset_pcie_clk_interconnect_aresetn  [get_bd_pins proc_sys_reset_pcie_clk/interconnect_aresetn] \
  [get_bd_pins hier_1g_components/aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_pcie_clk_peripheral_aresetn  [get_bd_pins proc_sys_reset_pcie_clk/peripheral_aresetn] \
  [get_bd_pins hier_1g_components/axi_resetn] \
  [get_bd_pins tieoff_unused/aresetn]
  connect_bd_net -net proc_sys_reset_pl0_clk_peripheral_aresetn  [get_bd_pins proc_sys_reset_pl0_clk/peripheral_aresetn] \
  [get_bd_pins axi_intc_lpd/s_axi_aresetn] \
  [get_bd_pins hier_10g_components/pl_0_resetn]
  connect_bd_net -net proc_sys_reset_pl1_clk_peripheral_aresetn  [get_bd_pins proc_sys_reset_pl1_clk/peripheral_aresetn] \
  [get_bd_pins axi_intc_fpd/s_axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces tieoff_unused/axi_vip_1/Master_AXI] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces tieoff_unused/axi_vip_2/Master_AXI] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces AIE_INI] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs tieoff_unused/axi_vip_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200840000 -range 0x00040000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_1g_components/axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020200880000 -range 0x00040000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_1g_components/axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x020200820000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_10g_components/MRMAC_GT/GT/axi_gpio_gt_rate_reset_ctl_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200830000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_10g_components/MRMAC_GT/GT/axi_gpio_gt_rate_reset_ctl_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x0202008C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_10g_components/MRMAC_GT/GT/axi_gpio_gt_reset_mask/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_fpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200810000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_lpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x0202008D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_10g_components/MRMAC_GT/GT/gtwiz_versal_0/Quad0_APB3_INTF/Reg] -force
  assign_bd_address -offset 0x0202008E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs hier_10g_components/MRMAC_GT/mrmac_0/s_axi/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


