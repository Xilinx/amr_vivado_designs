# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: ve2302_xdma_gmsl
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
# source config_bd.tcl



# Set design_name
variable design_name
set design_name $proj_name

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
xilinx.com:ip:versal_cips:*\
xilinx.com:ip:axi_noc:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:inline_hdl:ilreduced_logic:*\
xilinx.com:inline_hdl:ilvector_logic:*\
xilinx.com:ip:xdma:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_gpio:*\
amd.com:user:axi_addr_mask:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:axis_switch:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:mipi_csi2_rx_subsystem:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:xlslice:*\
xilinx.com:ip:axis_subset_converter:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:v_frmbuf_wr:*\
xilinx.com:ip:gt_quad_base:*\
xilinx.com:ip:pcie_versal:*\
xilinx.com:ip:pcie_phy_versal:*\
xilinx.com:ip:util_ds_buf:*\
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


# Hierarchical cell: base_clocking
proc create_hier_cell_base_clocking { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_base_clocking() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_swctrl_reset_cntl


  # Create pins
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type clk clk_pl_axi
  create_bd_pin -dir I -type rst resetn_pcie
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pcie_sync
  create_bd_pin -dir I -type rst resetn_pl_axi
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_axi_sync
  create_bd_pin -dir O -from 0 -to 0 force_reset_enable
  create_bd_pin -dir I force_reset_result

  # Create instance: force_reset_gpio, and set properties
  set force_reset_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio force_reset_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000000} \
    CONFIG.C_GPIO2_WIDTH {1} \
    CONFIG.C_GPIO_WIDTH {1} \
    CONFIG.C_IS_DUAL {1} \
  ] $force_reset_gpio


  # Create instance: pcie_reset_sync, and set properties
  set pcie_reset_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pcie_reset_sync ]
  set_property -dict [list \
    CONFIG.C_AUX_RST_WIDTH {1} \
    CONFIG.C_EXT_RST_WIDTH {1} \
  ] $pcie_reset_sync


  # Create instance: pl_reset_sync, and set properties
  set pl_reset_sync [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset pl_reset_sync ]
  set_property -dict [list \
    CONFIG.C_AUX_RST_WIDTH {1} \
    CONFIG.C_EXT_RST_WIDTH {1} \
  ] $pl_reset_sync


  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_swctrl_reset_cntl_1 [get_bd_intf_pins s_axi_swctrl_reset_cntl] [get_bd_intf_pins force_reset_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net clk_pcie_net  [get_bd_pins clk_pcie] \
  [get_bd_pins pcie_reset_sync/slowest_sync_clk]
  connect_bd_net -net clk_pl_axi_net  [get_bd_pins clk_pl_axi] \
  [get_bd_pins pl_reset_sync/slowest_sync_clk] \
  [get_bd_pins force_reset_gpio/s_axi_aclk]
  connect_bd_net -net force_reset_gpio_gpio_io_o  [get_bd_pins force_reset_gpio/gpio_io_o] \
  [get_bd_pins force_reset_enable]
  connect_bd_net -net force_reset_result_1  [get_bd_pins force_reset_result] \
  [get_bd_pins force_reset_gpio/gpio2_io_i]
  connect_bd_net -net pcie_reset_sync_interconnect_aresetn  [get_bd_pins pcie_reset_sync/interconnect_aresetn] \
  [get_bd_pins resetn_pcie_sync]
  connect_bd_net -net pl_reset_sync_interconnect_aresetn  [get_bd_pins pl_reset_sync/interconnect_aresetn] \
  [get_bd_pins resetn_pl_axi_sync] \
  [get_bd_pins force_reset_gpio/s_axi_aresetn]
  connect_bd_net -net resetn_pcie_1  [get_bd_pins resetn_pcie] \
  [get_bd_pins pcie_reset_sync/ext_reset_in]
  connect_bd_net -net resetn_pl_axi_1  [get_bd_pins resetn_pl_axi] \
  [get_bd_pins pl_reset_sync/ext_reset_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: blp_logic
proc create_hier_cell_blp_logic { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_blp_logic() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_mgmt_ctrl


  # Create pins
  create_bd_pin -dir I -type clk clk_pcie
  create_bd_pin -dir I -type clk clk_pl_axi
  create_bd_pin -dir O -from 0 -to 0 force_reset_enable
  create_bd_pin -dir I force_reset_result
  create_bd_pin -dir I -type rst resetn_pl_axi
  create_bd_pin -dir O -from 0 -to 0 -type rst resetn_pl_axi_sync
  create_bd_pin -dir O -from 31 -to 0 msix_usr_func_num
  create_bd_pin -dir O -from 15 -to 0 msix_irq_req
  create_bd_pin -dir I -from 11 -to 0 pf1_irq
  create_bd_pin -dir I -from 3 -to 0 pf0_irq

  # Create instance: base_clocking
  create_hier_cell_base_clocking $hier_obj base_clocking

  # Create instance: usr_irq_func_num, and set properties
  set usr_irq_func_num [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant usr_irq_func_num ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x55555500} \
    CONFIG.CONST_WIDTH {32} \
  ] $usr_irq_func_num


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {2} $ilconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net base_clocking_s_axi_swctrl_reset_cntl [get_bd_intf_pins s_axi_mgmt_ctrl] [get_bd_intf_pins base_clocking/s_axi_swctrl_reset_cntl]

  # Create port connections
  connect_bd_net -net In0_1  [get_bd_pins pf0_irq] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net In1_1  [get_bd_pins pf1_irq] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net base_clocking_force_reset_enable  [get_bd_pins base_clocking/force_reset_enable] \
  [get_bd_pins force_reset_enable]
  connect_bd_net -net clk_pcie_net  [get_bd_pins clk_pcie] \
  [get_bd_pins base_clocking/clk_pcie]
  connect_bd_net -net clk_pl_axi_net  [get_bd_pins clk_pl_axi] \
  [get_bd_pins base_clocking/clk_pl_axi]
  connect_bd_net -net force_reset_result_1  [get_bd_pins force_reset_result] \
  [get_bd_pins base_clocking/force_reset_result]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins msix_irq_req]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins usr_irq_func_num/dout] \
  [get_bd_pins msix_usr_func_num]
  connect_bd_net -net resetn_pl_axi_net  [get_bd_pins resetn_pl_axi] \
  [get_bd_pins base_clocking/resetn_pl_axi]
  create_bd_net resetn_pl_axi_sync_net
  connect_bd_net -net [get_bd_nets resetn_pl_axi_sync_net]  [get_bd_pins base_clocking/resetn_pl_axi_sync] \
  [get_bd_pins base_clocking/resetn_pcie] \
  [get_bd_pins resetn_pl_axi_sync]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: xdma_0_support
proc create_hier_cell_xdma_0_support { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_xdma_0_support() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_cq

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_cfg_fc_rtl:1.1 pcie_cfg_fc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_interrupt_rtl:1.0 pcie_cfg_interrupt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_msg_received_rtl:1.0 pcie_cfg_mesg_rcvd

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_mesg_tx_rtl:1.0 pcie_cfg_mesg_tx

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rq

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie5_cfg_control_rtl:1.0 pcie_cfg_control

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_msix_rtl:1.0 pcie_cfg_external_msix_without_msi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie5_cfg_status_rtl:1.0 pcie_cfg_status

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_transmit_fc_rtl:1.0 pcie_transmit_fc


  # Create pins
  create_bd_pin -dir I -type rst sys_reset
  create_bd_pin -dir O phy_rdy_out
  create_bd_pin -dir O -type clk user_clk
  create_bd_pin -dir O user_lnk_up
  create_bd_pin -dir O -type rst user_reset

  # Create instance: gt_quad_0, and set properties
  set gt_quad_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gt_quad_base gt_quad_0 ]
  set_property -dict [list \
    CONFIG.PORTS_INFO_DICT {LANE_SEL_DICT {PROT0 {RX0 RX1 RX2 RX3 TX0 TX1 TX2 TX3}} GT_TYPE GTYP REG_CONF_INTF APB3_INTF BOARD_PARAMETER { }} \
    CONFIG.PROT_OUTCLK_VALUES {CH0_RXOUTCLK 250 CH0_TXOUTCLK 500 CH1_RXOUTCLK 250 CH1_TXOUTCLK 500 CH2_RXOUTCLK 250 CH2_TXOUTCLK 500 CH3_RXOUTCLK 250 CH3_TXOUTCLK 500} \
    CONFIG.REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_RPLLGTREFCLK0\
refclk_PROT0_R0_100_MHz_unique1} \
  ] $gt_quad_0

  # Create instance: pcie, and set properties
  set pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_versal pcie ]
  set_property -dict [list \
    CONFIG.AXISTEN_IF_CQ_ALIGNMENT_MODE {Address_Aligned} \
    CONFIG.AXISTEN_IF_RQ_ALIGNMENT_MODE {DWORD_Aligned} \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_DEVICE_ID {5710} \
    CONFIG.PF0_INTERRUPT_PIN {NONE} \
    CONFIG.PF0_LINK_STATUS_SLOT_CLOCK_CONFIG {true} \
    CONFIG.PF0_REVISION_ID {00} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {C034} \
    CONFIG.PF0_SUBSYSTEM_ID {000e} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00009FE0} \
    CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00009000} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE {01F} \
    CONFIG.PF1_DEVICE_ID {5711} \
    CONFIG.PF1_INTERRUPT_PIN {NONE} \
    CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_3:2} \
    CONFIG.PF1_MSIX_CAP_PBA_OFFSET {00008FE0} \
    CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_3:2} \
    CONFIG.PF1_MSIX_CAP_TABLE_OFFSET {00008000} \
    CONFIG.PF1_MSIX_CAP_TABLE_SIZE {01F} \
    CONFIG.PF1_REVISION_ID {00} \
    CONFIG.PF1_SUBSYSTEM_ID {000E} \
    CONFIG.PF1_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF1_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
    CONFIG.REF_CLK_FREQ {100_MHz} \
    CONFIG.TL_PF_ENABLE_REG {2} \
    CONFIG.acs_ext_cap_enable {false} \
    CONFIG.axisten_freq {125} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_enable_msg_route_override {TRUE} \
    CONFIG.axisten_if_width {256_bit} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.copy_pf0 {false} \
    CONFIG.dedicate_perst {true} \
    CONFIG.device_port_type {PCI_Express_Endpoint_device} \
    CONFIG.en_dbg_descramble {false} \
    CONFIG.en_ext_clk {FALSE} \
    CONFIG.en_l23_entry {false} \
    CONFIG.en_parity {false} \
    CONFIG.en_transceiver_status_ports {false} \
    CONFIG.enable_auto_rxeq {False} \
    CONFIG.enable_ccix {FALSE} \
    CONFIG.enable_code {0000} \
    CONFIG.enable_dvsec {FALSE} \
    CONFIG.enable_gen4 {true} \
    CONFIG.enable_gtwizard {false} \
    CONFIG.enable_ibert {false} \
    CONFIG.enable_jtag_dbg {false} \
    CONFIG.enable_more_clk {false} \
    CONFIG.ext_pcie_cfg_space_enabled {false} \
    CONFIG.extended_tag_field {true} \
    CONFIG.insert_cips {false} \
    CONFIG.lane_order {Bottom} \
    CONFIG.legacy_ext_pcie_cfg_space_enabled {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {X0Y0} \
    CONFIG.pcie_link_debug {false} \
    CONFIG.pcie_link_debug_axi4_st {false} \
    CONFIG.pf0_ari_enabled {false} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_enabled {true} \
    CONFIG.pf0_bar0_prefetchable {false} \
    CONFIG.pf0_bar0_scale {Megabytes} \
    CONFIG.pf0_bar0_size {16} \
    CONFIG.pf0_bar2_64bit {true} \
    CONFIG.pf0_bar2_enabled {true} \
    CONFIG.pf0_bar2_prefetchable {true} \
    CONFIG.pf0_bar2_scale {Kilobytes} \
    CONFIG.pf0_bar2_size {64} \
    CONFIG.pf0_bar4_64bit {true} \
    CONFIG.pf0_bar4_enabled {true} \
    CONFIG.pf0_bar4_prefetchable {true} \
    CONFIG.pf0_bar4_scale {Megabytes} \
    CONFIG.pf0_bar4_size {256} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_class_code_base {12} \
    CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code_sub {00} \
    CONFIG.pf0_expansion_rom_enabled {false} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_bar0_64bit {true} \
    CONFIG.pf1_bar0_enabled {true} \
    CONFIG.pf1_bar0_prefetchable {false} \
    CONFIG.pf1_bar0_scale {Megabytes} \
    CONFIG.pf1_bar0_size {16} \
    CONFIG.pf1_bar2_64bit {true} \
    CONFIG.pf1_bar2_enabled {true} \
    CONFIG.pf1_bar2_prefetchable {true} \
    CONFIG.pf1_bar2_scale {Kilobytes} \
    CONFIG.pf1_bar2_size {64} \
    CONFIG.pf1_bar4_64bit {true} \
    CONFIG.pf1_bar4_enabled {true} \
    CONFIG.pf1_bar4_prefetchable {true} \
    CONFIG.pf1_bar4_scale {Megabytes} \
    CONFIG.pf1_bar4_size {256} \
    CONFIG.pf1_base_class_menu {Memory_controller} \
    CONFIG.pf1_class_code_base {12} \
    CONFIG.pf1_class_code_interface {00} \
    CONFIG.pf1_class_code_sub {00} \
    CONFIG.pf1_expansion_rom_enabled {false} \
    CONFIG.pf1_msi_enabled {false} \
    CONFIG.pf1_msix_enabled {true} \
    CONFIG.pf1_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_vendor_id {10EE} \
    CONFIG.pipe_line_stage {2} \
    CONFIG.pipe_sim {false} \
    CONFIG.sys_reset_polarity {ACTIVE_LOW} \
    CONFIG.vendor_id {10EE} \
    CONFIG.vfg0_msix_enabled {false} \
    CONFIG.vfg1_msix_enabled {false} \
    CONFIG.xlnx_ref_board {EMB-PLUS-VPR-4616} \
  ] $pcie

  # Create instance: pcie_phy, and set properties
  set pcie_phy [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_phy_versal pcie_phy ]
  set_property -dict [list \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
    CONFIG.aspm {No_ASPM} \
    CONFIG.async_mode {SRNS} \
    CONFIG.disable_double_pipe {YES} \
    CONFIG.en_gt_pclk {false} \
    CONFIG.enable_gtwizard {false} \
    CONFIG.ins_loss_profile {Add-in_Card} \
    CONFIG.lane_order {Bottom} \
    CONFIG.lane_reversal {false} \
    CONFIG.phy_async_en {true} \
    CONFIG.phy_coreclk_freq {500_MHz} \
    CONFIG.phy_refclk_freq {100_MHz} \
    CONFIG.phy_userclk2_freq {125_MHz} \
    CONFIG.phy_userclk_freq {125_MHz} \
    CONFIG.pipeline_stages {2} \
    CONFIG.sim_model {NO} \
    CONFIG.tx_preset {4} \
  ] $pcie_phy


  # Create instance: const_1b1, and set properties
  set const_1b1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant const_1b1 ]

  # Create instance: bufg_gt_sysclk, and set properties
  set bufg_gt_sysclk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt_sysclk ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] $bufg_gt_sysclk


  # Create instance: refclk_ibuf, and set properties
  set refclk_ibuf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf refclk_ibuf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $refclk_ibuf


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins refclk_ibuf/CLK_IN_D] [get_bd_intf_pins pcie_refclk]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins pcie_phy/pcie_mgt] [get_bd_intf_pins pcie_mgt]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins pcie/m_axis_cq] [get_bd_intf_pins m_axis_cq]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins pcie/m_axis_rc] [get_bd_intf_pins m_axis_rc]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins pcie/pcie_cfg_external_msix_without_msi] [get_bd_intf_pins pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins pcie/pcie_cfg_interrupt] [get_bd_intf_pins pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins pcie/pcie_cfg_mesg_rcvd] [get_bd_intf_pins pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins pcie/pcie_cfg_mesg_tx] [get_bd_intf_pins pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins pcie/pcie_cfg_control] [get_bd_intf_pins pcie_cfg_control]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins pcie/pcie_cfg_fc] [get_bd_intf_pins pcie_cfg_fc]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins pcie/pcie_cfg_status] [get_bd_intf_pins pcie_cfg_status]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins pcie/pcie_transmit_fc] [get_bd_intf_pins pcie_transmit_fc]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins pcie/s_axis_cc] [get_bd_intf_pins s_axis_cc]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins pcie/s_axis_rq] [get_bd_intf_pins s_axis_rq]
  connect_bd_intf_net -intf_net gt_quad_0_GT0_BUFGT [get_bd_intf_pins pcie_phy/GT_BUFGT] [get_bd_intf_pins gt_quad_0/GT0_BUFGT]
  connect_bd_intf_net -intf_net gt_quad_0_GT_Serial [get_bd_intf_pins pcie_phy/GT0_Serial] [get_bd_intf_pins gt_quad_0/GT_Serial]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX0 [get_bd_intf_pins pcie_phy/GT_RX0] [get_bd_intf_pins gt_quad_0/RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX1 [get_bd_intf_pins pcie_phy/GT_RX1] [get_bd_intf_pins gt_quad_0/RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX2 [get_bd_intf_pins pcie_phy/GT_RX2] [get_bd_intf_pins gt_quad_0/RX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX3 [get_bd_intf_pins pcie_phy/GT_RX3] [get_bd_intf_pins gt_quad_0/RX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX0 [get_bd_intf_pins pcie_phy/GT_TX0] [get_bd_intf_pins gt_quad_0/TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX1 [get_bd_intf_pins pcie_phy/GT_TX1] [get_bd_intf_pins gt_quad_0/TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX2 [get_bd_intf_pins pcie_phy/GT_TX2] [get_bd_intf_pins gt_quad_0/TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX3 [get_bd_intf_pins pcie_phy/GT_TX3] [get_bd_intf_pins gt_quad_0/TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_gt_rxmargin_q0 [get_bd_intf_pins pcie_phy/gt_rxmargin_q0] [get_bd_intf_pins gt_quad_0/gt_rxmargin_intf]
  connect_bd_intf_net -intf_net pcie_phy_mac_rx [get_bd_intf_pins pcie_phy/phy_mac_rx] [get_bd_intf_pins pcie/phy_mac_rx]
  connect_bd_intf_net -intf_net pcie_phy_mac_tx [get_bd_intf_pins pcie_phy/phy_mac_tx] [get_bd_intf_pins pcie/phy_mac_tx]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_command [get_bd_intf_pins pcie_phy/phy_mac_command] [get_bd_intf_pins pcie/phy_mac_command]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_rx_margining [get_bd_intf_pins pcie_phy/phy_mac_rx_margining] [get_bd_intf_pins pcie/phy_mac_rx_margining]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_status [get_bd_intf_pins pcie_phy/phy_mac_status] [get_bd_intf_pins pcie/phy_mac_status]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_drive [get_bd_intf_pins pcie_phy/phy_mac_tx_drive] [get_bd_intf_pins pcie/phy_mac_tx_drive]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_eq [get_bd_intf_pins pcie_phy/phy_mac_tx_eq] [get_bd_intf_pins pcie/phy_mac_tx_eq]

  # Create port connections
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O  [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] \
  [get_bd_pins pcie_phy/phy_refclk] \
  [get_bd_pins gt_quad_0/apb3clk] \
  [get_bd_pins pcie/sys_clk]
  connect_bd_net -net const_1b1_dout  [get_bd_pins const_1b1/dout] \
  [get_bd_pins bufg_gt_sysclk/BUFG_GT_CE]
  connect_bd_net -net gt_quad_0_ch0_phyready  [get_bd_pins gt_quad_0/ch0_phyready] \
  [get_bd_pins pcie_phy/ch0_phyready]
  connect_bd_net -net gt_quad_0_ch0_phystatus  [get_bd_pins gt_quad_0/ch0_phystatus] \
  [get_bd_pins pcie_phy/ch0_phystatus]
  connect_bd_net -net gt_quad_0_ch0_rxoutclk  [get_bd_pins gt_quad_0/ch0_rxoutclk] \
  [get_bd_pins pcie_phy/gt_rxoutclk]
  connect_bd_net -net gt_quad_0_ch0_txoutclk  [get_bd_pins gt_quad_0/ch0_txoutclk] \
  [get_bd_pins pcie_phy/gt_txoutclk]
  connect_bd_net -net gt_quad_0_ch1_phyready  [get_bd_pins gt_quad_0/ch1_phyready] \
  [get_bd_pins pcie_phy/ch1_phyready]
  connect_bd_net -net gt_quad_0_ch1_phystatus  [get_bd_pins gt_quad_0/ch1_phystatus] \
  [get_bd_pins pcie_phy/ch1_phystatus]
  connect_bd_net -net gt_quad_0_ch2_phyready  [get_bd_pins gt_quad_0/ch2_phyready] \
  [get_bd_pins pcie_phy/ch2_phyready]
  connect_bd_net -net gt_quad_0_ch2_phystatus  [get_bd_pins gt_quad_0/ch2_phystatus] \
  [get_bd_pins pcie_phy/ch2_phystatus]
  connect_bd_net -net gt_quad_0_ch3_phyready  [get_bd_pins gt_quad_0/ch3_phyready] \
  [get_bd_pins pcie_phy/ch3_phyready]
  connect_bd_net -net gt_quad_0_ch3_phystatus  [get_bd_pins gt_quad_0/ch3_phystatus] \
  [get_bd_pins pcie_phy/ch3_phystatus]
  connect_bd_net -net pcie_pcie_ltssm_state  [get_bd_pins pcie/pcie_ltssm_state] \
  [get_bd_pins pcie_phy/pcie_ltssm_state]
  connect_bd_net -net pcie_phy_gt_pcieltssm  [get_bd_pins pcie_phy/gt_pcieltssm] \
  [get_bd_pins gt_quad_0/pcieltssm]
  connect_bd_net -net pcie_phy_gtrefclk  [get_bd_pins pcie_phy/gtrefclk] \
  [get_bd_pins gt_quad_0/GT_REFCLK0]
  connect_bd_net -net pcie_phy_pcierstb  [get_bd_pins pcie_phy/pcierstb] \
  [get_bd_pins gt_quad_0/ch0_pcierstb] \
  [get_bd_pins gt_quad_0/ch1_pcierstb] \
  [get_bd_pins gt_quad_0/ch2_pcierstb] \
  [get_bd_pins gt_quad_0/ch3_pcierstb]
  connect_bd_net -net pcie_phy_phy_coreclk  [get_bd_pins pcie_phy/phy_coreclk] \
  [get_bd_pins pcie/phy_coreclk]
  connect_bd_net -net pcie_phy_phy_mcapclk  [get_bd_pins pcie_phy/phy_mcapclk] \
  [get_bd_pins pcie/phy_mcapclk]
  connect_bd_net -net pcie_phy_phy_pclk  [get_bd_pins pcie_phy/phy_pclk] \
  [get_bd_pins pcie/phy_pclk] \
  [get_bd_pins gt_quad_0/ch0_txusrclk] \
  [get_bd_pins gt_quad_0/ch1_txusrclk] \
  [get_bd_pins gt_quad_0/ch2_txusrclk] \
  [get_bd_pins gt_quad_0/ch3_txusrclk] \
  [get_bd_pins gt_quad_0/ch0_rxusrclk] \
  [get_bd_pins gt_quad_0/ch1_rxusrclk] \
  [get_bd_pins gt_quad_0/ch2_rxusrclk] \
  [get_bd_pins gt_quad_0/ch3_rxusrclk]
  connect_bd_net -net pcie_phy_phy_userclk  [get_bd_pins pcie_phy/phy_userclk] \
  [get_bd_pins pcie/phy_userclk]
  connect_bd_net -net pcie_phy_phy_userclk2  [get_bd_pins pcie_phy/phy_userclk2] \
  [get_bd_pins pcie/phy_userclk2]
  connect_bd_net -net pcie_phy_rdy_out  [get_bd_pins pcie/phy_rdy_out] \
  [get_bd_pins phy_rdy_out]
  connect_bd_net -net pcie_user_clk  [get_bd_pins pcie/user_clk] \
  [get_bd_pins user_clk]
  connect_bd_net -net pcie_user_lnk_up  [get_bd_pins pcie/user_lnk_up] \
  [get_bd_pins user_lnk_up]
  connect_bd_net -net pcie_user_reset  [get_bd_pins pcie/user_reset] \
  [get_bd_pins user_reset]
  connect_bd_net -net refclk_ibuf_IBUF_DS_ODIV2  [get_bd_pins refclk_ibuf/IBUF_DS_ODIV2] \
  [get_bd_pins bufg_gt_sysclk/BUFG_GT_I]
  connect_bd_net -net refclk_ibuf_IBUF_OUT  [get_bd_pins refclk_ibuf/IBUF_OUT] \
  [get_bd_pins pcie_phy/phy_gtrefclk] \
  [get_bd_pins pcie/sys_clk_gt]
  connect_bd_net -net sys_reset_1  [get_bd_pins sys_reset] \
  [get_bd_pins pcie_phy/phy_rst_n] \
  [get_bd_pins pcie/sys_reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gmsl_pipeline
proc create_hier_cell_gmsl_pipeline { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gmsl_pipeline() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 DESER_IIC

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 CFG_IIC


  # Create pins
  create_bd_pin -dir I -type clk clk_in
  create_bd_pin -dir O -type intr csirxss_csi_irq
  create_bd_pin -dir O -type intr iic2intc_irpt
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -type intr interrupt0
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir O -type intr interrupt2
  create_bd_pin -dir O -type intr interrupt3
  create_bd_pin -dir O -type intr iic2intc_irpt1

  # Create instance: axis_switch_0, and set properties
  set axis_switch_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch axis_switch_0 ]
  set_property -dict [list \
    CONFIG.HAS_TLAST {1} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TDEST_WIDTH {4} \
    CONFIG.TUSER_WIDTH {2} \
  ] $axis_switch_0


  # Create instance: axi_gpio_resets, and set properties
  set axi_gpio_resets [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_resets ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
  ] $axi_gpio_resets


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_0


  # Create instance: mipi_csi2_rx_subsyst_0, and set properties
  set mipi_csi2_rx_subsyst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem mipi_csi2_rx_subsyst_0 ]
  set_property -dict [list \
    CONFIG.CMN_NUM_LANES {4} \
    CONFIG.CMN_NUM_PIXELS {2} \
    CONFIG.CMN_PXL_FORMAT {YUV422_8bit} \
    CONFIG.CSI_BUF_DEPTH {8192} \
    CONFIG.C_CSI_EN_ACTIVELANES {true} \
    CONFIG.C_CSI_FILTER_USERDATATYPE {true} \
    CONFIG.DPY_EN_REG_IF {true} \
    CONFIG.DPY_LINE_RATE {1500} \
    CONFIG.SupportLevel {1} \
    CONFIG.VFB_TU_WIDTH {2} \
  ] $mipi_csi2_rx_subsyst_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_1


  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0 ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {8} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: axis_data_fifo_2, and set properties
  set axis_data_fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_2 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_2


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_0 ]
  set_property CONFIG.DIN_WIDTH {4} $xlslice_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {4} \
  ] $xlslice_1


  # Create instance: axis_data_fifo_3, and set properties
  set axis_data_fifo_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_3 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_3


  # Create instance: axis_subset_converter_0, and set properties
  set axis_subset_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter axis_subset_converter_0 ]
  set_property -dict [list \
    CONFIG.M_HAS_TKEEP {0} \
    CONFIG.M_HAS_TLAST {1} \
    CONFIG.M_HAS_TREADY {1} \
    CONFIG.M_HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TDEST_WIDTH {4} \
    CONFIG.M_TID_WIDTH {0} \
    CONFIG.M_TUSER_WIDTH {2} \
    CONFIG.S_HAS_TKEEP {0} \
    CONFIG.S_HAS_TLAST {1} \
    CONFIG.S_HAS_TREADY {1} \
    CONFIG.S_HAS_TSTRB {0} \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.S_TDEST_WIDTH {4} \
    CONFIG.S_TID_WIDTH {0} \
    CONFIG.S_TUSER_WIDTH {2} \
  ] $axis_subset_converter_0


  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_200M,clk_375M,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {200.000,375,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
  ] $clk_wizard_0


  # Create instance: proc_sys_reset_375M, and set properties
  set proc_sys_reset_375M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_375M ]

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
  ] $xlslice_2


  # Create instance: axis_subset_converter_1, and set properties
  set axis_subset_converter_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter axis_subset_converter_1 ]
  set_property -dict [list \
    CONFIG.M_HAS_TKEEP {0} \
    CONFIG.M_HAS_TLAST {1} \
    CONFIG.M_HAS_TREADY {1} \
    CONFIG.M_HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TDEST_WIDTH {4} \
    CONFIG.M_TID_WIDTH {0} \
    CONFIG.M_TUSER_WIDTH {2} \
    CONFIG.S_HAS_TKEEP {0} \
    CONFIG.S_HAS_TLAST {1} \
    CONFIG.S_HAS_TREADY {1} \
    CONFIG.S_HAS_TSTRB {0} \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.S_TDEST_WIDTH {4} \
    CONFIG.S_TID_WIDTH {0} \
    CONFIG.S_TUSER_WIDTH {2} \
  ] $axis_subset_converter_1


  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {4} \
  ] $xlslice_3


  # Create instance: v_frmbuf_wr_0, and set properties
  set v_frmbuf_wr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_0 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
  ] $v_frmbuf_wr_0


  # Create instance: axis_subset_converter_2, and set properties
  set axis_subset_converter_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter axis_subset_converter_2 ]
  set_property -dict [list \
    CONFIG.M_HAS_TKEEP {0} \
    CONFIG.M_HAS_TLAST {1} \
    CONFIG.M_HAS_TREADY {1} \
    CONFIG.M_HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TDEST_WIDTH {4} \
    CONFIG.M_TID_WIDTH {0} \
    CONFIG.M_TUSER_WIDTH {2} \
    CONFIG.S_HAS_TKEEP {0} \
    CONFIG.S_HAS_TLAST {1} \
    CONFIG.S_HAS_TREADY {1} \
    CONFIG.S_HAS_TSTRB {0} \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.S_TDEST_WIDTH {4} \
    CONFIG.S_TID_WIDTH {0} \
    CONFIG.S_TUSER_WIDTH {2} \
  ] $axis_subset_converter_2


  # Create instance: v_frmbuf_wr_1, and set properties
  set v_frmbuf_wr_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_1 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
  ] $v_frmbuf_wr_1


  # Create instance: v_frmbuf_wr_2, and set properties
  set v_frmbuf_wr_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_2 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
  ] $v_frmbuf_wr_2


  # Create instance: axis_subset_converter_3, and set properties
  set axis_subset_converter_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter axis_subset_converter_3 ]
  set_property -dict [list \
    CONFIG.M_HAS_TKEEP {0} \
    CONFIG.M_HAS_TLAST {1} \
    CONFIG.M_HAS_TREADY {1} \
    CONFIG.M_HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TDEST_WIDTH {4} \
    CONFIG.M_TID_WIDTH {0} \
    CONFIG.M_TUSER_WIDTH {2} \
    CONFIG.S_HAS_TKEEP {0} \
    CONFIG.S_HAS_TLAST {1} \
    CONFIG.S_HAS_TREADY {1} \
    CONFIG.S_HAS_TSTRB {0} \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.S_TDEST_WIDTH {4} \
    CONFIG.S_TID_WIDTH {0} \
    CONFIG.S_TUSER_WIDTH {2} \
  ] $axis_subset_converter_3


  # Create instance: v_frmbuf_wr_3, and set properties
  set v_frmbuf_wr_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_3 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
  ] $v_frmbuf_wr_3


  # Create instance: axi_iic_1, and set properties
  set axi_iic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_1 ]

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_SI {2} \
  ] $axi_noc_0


  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /gmsl_pipeline/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /gmsl_pipeline/axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI} \
 ] [get_bd_pins /gmsl_pipeline/axi_noc_0/aclk0]

  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
  ] $smartconnect_1


  # Create instance: smartconnect_2, and set properties
  set smartconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_2 ]
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
  ] $smartconnect_2


  # Create instance: proc_sys_reset_100M, and set properties
  set proc_sys_reset_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_pins DESER_IIC] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_iic_1_IIC [get_bd_intf_pins CFG_IIC] [get_bd_intf_pins axi_iic_1/IIC]
  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M01_INI [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc_0/M01_INI]
  connect_bd_intf_net -intf_net axi_smartconnect_1_M0_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_1_S0_AXI [get_bd_intf_pins v_frmbuf_wr_0/m_axi_mm_video] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_1_S1_AXI [get_bd_intf_pins v_frmbuf_wr_1/m_axi_mm_video] [get_bd_intf_pins smartconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_2_M0_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins axi_noc_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_2_S0_AXI [get_bd_intf_pins v_frmbuf_wr_2/m_axi_mm_video] [get_bd_intf_pins smartconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_2_S1_AXI [get_bd_intf_pins v_frmbuf_wr_3/m_axi_mm_video] [get_bd_intf_pins smartconnect_2/S01_AXI]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins axis_subset_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axis_data_fifo_1/M_AXIS] [get_bd_intf_pins axis_subset_converter_1/S_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_2_M_AXIS [get_bd_intf_pins axis_data_fifo_2/M_AXIS] [get_bd_intf_pins axis_subset_converter_2/S_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_3_M_AXIS [get_bd_intf_pins axis_data_fifo_3/M_AXIS] [get_bd_intf_pins axis_subset_converter_3/S_AXIS]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins axis_subset_converter_0/M_AXIS] [get_bd_intf_pins v_frmbuf_wr_0/s_axis_video]
  connect_bd_intf_net -intf_net axis_subset_converter_1_M_AXIS [get_bd_intf_pins axis_subset_converter_1/M_AXIS] [get_bd_intf_pins v_frmbuf_wr_1/s_axis_video]
  connect_bd_intf_net -intf_net axis_subset_converter_2_M_AXIS [get_bd_intf_pins axis_subset_converter_2/M_AXIS] [get_bd_intf_pins v_frmbuf_wr_2/s_axis_video]
  connect_bd_intf_net -intf_net axis_subset_converter_3_M_AXIS [get_bd_intf_pins axis_subset_converter_3/M_AXIS] [get_bd_intf_pins v_frmbuf_wr_3/s_axis_video]
  connect_bd_intf_net -intf_net axis_switch_0_M00_AXIS [get_bd_intf_pins axis_switch_0/M00_AXIS] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_switch_0_M01_AXIS [get_bd_intf_pins axis_switch_0/M01_AXIS] [get_bd_intf_pins axis_data_fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net axis_switch_0_M02_AXIS [get_bd_intf_pins axis_switch_0/M02_AXIS] [get_bd_intf_pins axis_data_fifo_2/S_AXIS]
  connect_bd_intf_net -intf_net axis_switch_0_M03_AXIS [get_bd_intf_pins axis_switch_0/M03_AXIS] [get_bd_intf_pins axis_data_fifo_3/S_AXIS]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_0_video_out [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out] [get_bd_intf_pins axis_switch_0/S00_AXIS]
  connect_bd_intf_net -intf_net mipi_phy_if [get_bd_intf_pins mipi_phy_if] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins v_frmbuf_wr_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins v_frmbuf_wr_1/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins v_frmbuf_wr_2/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins v_frmbuf_wr_3/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi] [get_bd_intf_pins smartconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins axi_gpio_resets/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M06_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins smartconnect_0/M06_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M07_AXI [get_bd_intf_pins axi_iic_1/S_AXI] [get_bd_intf_pins smartconnect_0/M07_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_S00_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  # Create port connections
  connect_bd_net -net axi_gpio_resets_gpio_io_o  [get_bd_pins axi_gpio_resets/gpio_io_o] \
  [get_bd_pins xlslice_0/Din] \
  [get_bd_pins xlslice_1/Din] \
  [get_bd_pins xlslice_2/Din] \
  [get_bd_pins xlslice_3/Din]
  connect_bd_net -net axi_iic_0_iic2intc_irpt  [get_bd_pins axi_iic_0/iic2intc_irpt] \
  [get_bd_pins iic2intc_irpt]
  connect_bd_net -net axi_iic_1_iic2intc_irpt  [get_bd_pins axi_iic_1/iic2intc_irpt] \
  [get_bd_pins iic2intc_irpt1]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins clk_in] \
  [get_bd_pins clk_wizard_0/clk_in1] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] \
  [get_bd_pins v_frmbuf_wr_0/ap_clk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins smartconnect_1/aclk] \
  [get_bd_pins smartconnect_2/aclk] \
  [get_bd_pins v_frmbuf_wr_1/ap_clk] \
  [get_bd_pins v_frmbuf_wr_2/ap_clk] \
  [get_bd_pins v_frmbuf_wr_3/ap_clk] \
  [get_bd_pins axi_iic_1/s_axi_aclk] \
  [get_bd_pins axi_iic_0/s_axi_aclk] \
  [get_bd_pins axis_subset_converter_1/aclk] \
  [get_bd_pins axis_subset_converter_3/aclk] \
  [get_bd_pins axis_subset_converter_0/aclk] \
  [get_bd_pins axis_subset_converter_2/aclk] \
  [get_bd_pins axis_data_fifo_2/m_axis_aclk] \
  [get_bd_pins axis_data_fifo_1/m_axis_aclk] \
  [get_bd_pins axis_data_fifo_3/m_axis_aclk] \
  [get_bd_pins axis_data_fifo_0/m_axis_aclk] \
  [get_bd_pins axi_gpio_resets/s_axi_aclk] \
  [get_bd_pins axi_noc_0/aclk0] \
  [get_bd_pins proc_sys_reset_100M/slowest_sync_clk]
  connect_bd_net -net cips_pl0_resetn  [get_bd_pins ext_reset_in] \
  [get_bd_pins proc_sys_reset_375M/ext_reset_in] \
  [get_bd_pins proc_sys_reset_100M/ext_reset_in]
  connect_bd_net -net clk_wizard_0_clk_200M  [get_bd_pins clk_wizard_0/clk_200M] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]
  connect_bd_net -net clk_wizard_0_clk_375M  [get_bd_pins clk_wizard_0/clk_375M] \
  [get_bd_pins proc_sys_reset_375M/slowest_sync_clk] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] \
  [get_bd_pins axis_switch_0/aclk] \
  [get_bd_pins axis_data_fifo_0/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_1/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_2/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_3/s_axis_aclk]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq  [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq] \
  [get_bd_pins csirxss_csi_irq]
  connect_bd_net -net proc_sys_reset_100M_interconnect_aresetn  [get_bd_pins proc_sys_reset_100M/interconnect_aresetn] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins smartconnect_1/aresetn] \
  [get_bd_pins smartconnect_2/aresetn]
  connect_bd_net -net proc_sys_reset_100M_peripheral_aresetn  [get_bd_pins proc_sys_reset_100M/peripheral_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] \
  [get_bd_pins axi_iic_1/s_axi_aresetn] \
  [get_bd_pins axi_iic_0/s_axi_aresetn] \
  [get_bd_pins axis_subset_converter_1/aresetn] \
  [get_bd_pins axis_subset_converter_3/aresetn] \
  [get_bd_pins axis_subset_converter_0/aresetn] \
  [get_bd_pins axis_subset_converter_2/aresetn] \
  [get_bd_pins axi_gpio_resets/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_375M_interconnect_aresetn  [get_bd_pins proc_sys_reset_375M/interconnect_aresetn] \
  [get_bd_pins axis_switch_0/aresetn] \
  [get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_1/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_2/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_3/s_axis_aresetn]
  connect_bd_net -net proc_sys_reset_375M_peripheral_aresetn  [get_bd_pins proc_sys_reset_375M/peripheral_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]
  connect_bd_net -net v_frmbuf_wr_0_interrupt  [get_bd_pins v_frmbuf_wr_0/interrupt] \
  [get_bd_pins interrupt0]
  connect_bd_net -net v_frmbuf_wr_1_interrupt  [get_bd_pins v_frmbuf_wr_1/interrupt] \
  [get_bd_pins interrupt1]
  connect_bd_net -net v_frmbuf_wr_2_interrupt  [get_bd_pins v_frmbuf_wr_2/interrupt] \
  [get_bd_pins interrupt2]
  connect_bd_net -net v_frmbuf_wr_3_interrupt  [get_bd_pins v_frmbuf_wr_3/interrupt] \
  [get_bd_pins interrupt3]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins v_frmbuf_wr_0/ap_rst_n]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins v_frmbuf_wr_1/ap_rst_n]
  connect_bd_net -net xlslice_2_Dout  [get_bd_pins xlslice_2/Dout] \
  [get_bd_pins v_frmbuf_wr_2/ap_rst_n]
  connect_bd_net -net xlslice_3_Dout  [get_bd_pins xlslice_3/Dout] \
  [get_bd_pins v_frmbuf_wr_3/ap_rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: blp
proc create_hier_cell_blp { parentCell nameHier} {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_blp() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S0_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S1_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_0

  # Create pins
  create_bd_pin -dir I -type intr pl_ps_irq8
  create_bd_pin -dir I -type intr pl_ps_irq9
  create_bd_pin -dir I -type intr pl_ps_irq10
  create_bd_pin -dir I -type intr pl_ps_irq11
  create_bd_pin -dir I -type intr pl_ps_irq12
  create_bd_pin -dir I -type intr pl_ps_irq13
  create_bd_pin -dir I -type intr pl_ps_irq14
  create_bd_pin -dir O -type clk pl0_ref_clk
  create_bd_pin -dir O -type rst pl0_resetn

##################################################################
# Board Automation
##################################################################

set cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips cips ]

apply_bd_automation -rule xilinx.com:bd_rule:cips \
  -config { \
    board_preset {Yes} \
    boot_config {Custom} \
    configure_noc {Add new AXI NoC} \
    debug_config {JTAG} \
    design_flow {Full System} \
    mc_type {LPDDR} \
    num_mc_ddr {None} \
    num_mc_lpddr {1} \
    pl_clocks {2} \
    pl_resets {1} \
  }  $cips

# Copy NOC as axi_noc_mc_1x to keep all the DDR settings
copy_bd_objs /blp  [get_bd_cells {axi_noc_0}]
set_property name axi_noc_mc_1x [get_bd_cells /blp/axi_noc_1]

# Change settings to use INI ports and match settings used in non-automated flow
# Also add anything the partition metadata script needs to see
set_property -dict [list \
  CONFIG.MC_CH_INTERLEAVING_SIZE {256_Bytes} \
  CONFIG.NUM_NSI {6} \
  CONFIG.NUM_SI {0} \
  CONFIG.CONTROLLERTYPE {LPDDR4_SDRAM} \
  CONFIG.MC_CHAN_REGION1 {DDR_CH1} \
] [get_bd_cells axi_noc_mc_1x]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S00_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S01_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S02_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S03_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} CONFIG.INI_STRATEGY {load}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S04_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} CONFIG.INI_STRATEGY {load}] [get_bd_intf_pins /blp/axi_noc_mc_1x/S05_INI]


# Turn off memory controller in NOC attached to CIPS directly and match settings in non-automated flow
set_property name axi_noc_ic [get_bd_cells axi_noc_0]
set_property -dict [list \
  CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {Custom} \
  CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {Custom} \
  CONFIG.NUM_CLKS {9} \
  CONFIG.NUM_MC {0} \
    CONFIG.NUM_MI {3} \
  CONFIG.NUM_NMI {4} \
  CONFIG.NUM_SI {9} \
  CONFIG.sys_clk0_BOARD_INTERFACE {Custom} \
] [get_bd_cells axi_noc_ic]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.APERTURES {{0x201_0000_0000 2G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.APERTURES {{0x202_0000_0000 2G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M01_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_C000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/M02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {800} write_bw {800} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {800} write_bw {800} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M02_INI {read_bw {800} write_bw {800} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M03_INI {read_bw {800} write_bw {800} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {800} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S04_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {800} write_bw {800} initial_boot {true}} M02_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S05_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {800}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.REMAPS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S06_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.REMAPS {M02_INI {{0x0080_0000 0x1000_0000 8M}} M00_AXI {{0x000_0000 0x201_0000_0000 8M}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S07_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M03_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {M01_AXI:0x40} \
   CONFIG.REMAPS {M03_INI {{0x0800_0000 0x0500_0000_0000 128M}} M01_AXI {{0x0 0x202_0000_0000 8M}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /blp/axi_noc_ic/S08_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:M02_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk7]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:M01_AXI:S06_AXI:S07_AXI:S08_AXI} \
 ] [get_bd_pins /blp/axi_noc_ic/aclk8]

# Make the connections
connect_bd_intf_net [get_bd_intf_pins lpddr4_clk1] [get_bd_intf_pins axi_noc_mc_1x/sys_clk0]
connect_bd_intf_net [get_bd_intf_pins ch0_lpddr4_trip1] [get_bd_intf_pins axi_noc_mc_1x/CH0_LPDDR4_0]
connect_bd_intf_net [get_bd_intf_pins ch1_lpddr4_trip1] [get_bd_intf_pins axi_noc_mc_1x/CH1_LPDDR4_0]

# Change some of CIPs configuratons to match use case
  set_property -dict [list \
    CONFIG.PS_PMC_CONFIG { \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PS_IRQ_USAGE \
      { \
        {CH0 1} \
        {CH8 1} {CH9 1} {CH10 1} {CH11 1} {CH12 1} {CH13 1} {CH14 1} \
      } \
      PS_USE_FPD_CCI_NOC {1} \
      PS_USE_FPD_CCI_NOC0 {1} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_LPD_AXI0 {1} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_INTERFACE_TO_USE {I2C} \
      SMON_MEAS10 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_302} {SUPPLY_NUM 8}} \
      SMON_MEAS11 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 7}} \
      SMON_MEAS18 {{ALARM_ENABLE 0} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_703} {SUPPLY_NUM 9}} \
      SMON_MEAS20 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 2}} \
      SMON_MEAS21 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 3}} \
      SMON_MEAS22 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 4}} \
      SMON_MEAS24 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 5}} \
      SMON_MEAS25 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 1.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {1 V unipolar}} {NAME VP_VN} {SUPPLY_NUM 6}} \
      SMON_MEAS6 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 0}} \
      SMON_MEAS7 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 1}} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_VAUX_CH0 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 1} {IO_N LPD_MIO25_502} {IO_P LPD_MIO24_502} {MODE {1 V unipolar}} {NAME VAUX_CH0} {SUPPLY_NUM 10}} \
    } \
  ] $cips

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_3 {read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_2 {read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {15000} write_bw {15000} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S02_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S03_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S04_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /blp/axi_noc_mc_1x/S05_INI]

  # Create instance: force_reset_concat_0, and set properties
  set force_reset_concat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat force_reset_concat_0 ]

  # Create instance: force_reset_and_0, and set properties
  set force_reset_and_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic force_reset_and_0 ]
  set_property CONFIG.C_SIZE {2} $force_reset_and_0


  # Create instance: force_reset_not_0, and set properties
  set force_reset_not_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic force_reset_not_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $force_reset_not_0


  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma xdma_0 ]
  set_property -dict [list \
    CONFIG.axi_bypass_64bit_en {true} \
    CONFIG.axi_bypass_prefetchable {true} \
    CONFIG.axi_data_width {256_bit} \
    CONFIG.axil_master_prefetchable {false} \
    CONFIG.axilite_master_size {16} \
    CONFIG.axist_bypass_size {256} \
    CONFIG.pf_swap {true} \
    CONFIG.enable_gtwizard {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.mult_pf_des {true} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_prefetchable {false} \
    CONFIG.pf0_bar0_scale {Megabytes} \
    CONFIG.pf0_bar0_size {16} \
    CONFIG.pf0_bar2_scale {Kilobytes} \
    CONFIG.pf0_bar2_type {Memory} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_class_code_base {12} \
    CONFIG.pf0_class_code_sub {00} \
    CONFIG.pf0_device_id {5710} \
    CONFIG.pf0_interrupt_pin {NONE} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf0_subsystem_id {000e} \
    CONFIG.pf1_bar0_64bit {true} \
    CONFIG.pf1_bar0_prefetchable {false} \
    CONFIG.pf1_bar0_scale {Megabytes} \
    CONFIG.pf1_bar0_size {16} \
    CONFIG.pf1_bar2_64bit {true} \
    CONFIG.pf1_bar2_prefetchable {true} \
    CONFIG.pf1_bar2_scale {Kilobytes} \
    CONFIG.pf1_bar2_size {64} \
    CONFIG.pf1_bar2_type {Memory} \
    CONFIG.pf1_bar4_64bit {true} \
    CONFIG.pf1_bar4_prefetchable {true} \
    CONFIG.pf1_bar4_scale {Megabytes} \
    CONFIG.pf1_bar4_size {256} \
    CONFIG.pf1_base_class_menu {Memory_controller} \
    CONFIG.pf1_class_code_base {12} \
    CONFIG.pf1_class_code_sub {00} \
    CONFIG.pf1_device_id {5711} \
    CONFIG.pf1_msix_enabled {true} \
    CONFIG.pf1_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_subsystem_id {000e} \
    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X4} \
    CONFIG.tl_pf_enable_reg {2} \
    CONFIG.two_bypass_bar {true} \
    CONFIG.xdma_num_usr_irq {16} \
    CONFIG.xdma_pcie_64bit_en {true} \
    CONFIG.xdma_pcie_prefetchable {true} \
    CONFIG.xdma_rnum_chnl {2} \
    CONFIG.xdma_wnum_chnl {2} \
  ] $xdma_0


  # Create instance: xdma_0_smc, and set properties
  set xdma_0_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect xdma_0_smc ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__view__ { functional { S00_Entry { SUPPORTS_WRAP 0 } } timing { M01_Exit { REGSLICE 0 } S00_Entry { MMU_REGSLICE 0 TR_REGSLICE 0 } M00_Exit { REGSLICE 0 } } }   } \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $xdma_0_smc



  # Create instance: xdma_0_support
  create_hier_cell_xdma_0_support [current_bd_instance .] xdma_0_support

  # Create instance: blp_logic
  create_hier_cell_blp_logic $hier_obj blp_logic

  # Create instance: xdma_lite_prot_conv, and set properties
  set xdma_lite_prot_conv [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect xdma_lite_prot_conv]
  set_property -dict [list \
    CONFIG.NUM_SI {1} \
  ] $xdma_lite_prot_conv

# GPIO to test PF0 axi_lite
  # Create instance: axi_test_gpio_pf0, and set properties
  set axi_test_gpio_pf0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_test_gpio_pf0 ]
  set_property CONFIG.C_DOUT_DEFAULT {0x000000F0} $axi_test_gpio_pf0

# GPIO to test PF1 axi_bypass
# Create instance: axi_test_gpio_pf1, and set properties
  set axi_test_gpio_pf1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_test_gpio_pf1 ]
  set_property CONFIG.C_DOUT_DEFAULT {0x000000F1} $axi_test_gpio_pf1

  # Create instance: xdma_lite_addr_mask, and set properties
  set xdma_lite_addr_mask [ create_bd_cell -type ip -vlnv amd.com:user:axi_addr_mask xdma_lite_addr_mask ]
  set_property -dict [list \
    CONFIG.C_ADDR_WIDTH {64} \
    CONFIG.S_ADDR_MASK {0x0000000000FFFFFF} \
  ] $xdma_lite_addr_mask

  # Create instance: xdma_bypass_addr_mask, and set properties
  set xdma_bypass_addr_mask [ create_bd_cell -type ip -vlnv amd.com:user:axi_addr_mask xdma_bypass_addr_mask ]
  set_property -dict [list \
    CONFIG.C_ADDR_WIDTH {64} \
    CONFIG.C_ARUSER_WIDTH {8} \
    CONFIG.C_AWUSER_WIDTH {8} \
    CONFIG.C_DATA_WIDTH {256} \
    CONFIG.C_ID_WIDTH {4} \
    CONFIG.S_ADDR_MASK {0x000000000FFFFFFF} \
  ] $xdma_bypass_addr_mask


  # Create instance: pf0_irq_tmp, and set properties
  set pf0_irq_tmp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant pf0_irq_tmp ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $pf0_irq_tmp


  # Create instance: pf1_irq_tmp, and set properties
  set pf1_irq_tmp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant pf1_irq_tmp ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {12} \
  ] $pf1_irq_tmp


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net S04_INI_1 [get_bd_intf_pins S0_INI] [get_bd_intf_pins axi_noc_mc_1x/S04_INI]
  connect_bd_intf_net -intf_net S05_INI_1 [get_bd_intf_pins S1_INI] [get_bd_intf_pins axi_noc_mc_1x/S05_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M00_AXI [get_bd_intf_pins axi_noc_ic/M00_AXI] [get_bd_intf_pins xdma_0_smc/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_ic_M00_INI [get_bd_intf_pins axi_noc_ic/M00_INI] [get_bd_intf_pins axi_noc_mc_1x/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M01_AXI [get_bd_intf_pins axi_noc_ic/M01_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_ic_M01_INI [get_bd_intf_pins axi_noc_ic/M01_INI] [get_bd_intf_pins axi_noc_mc_1x/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M02_AXI [get_bd_intf_pins M_AXI_0] [get_bd_intf_pins axi_noc_ic/M02_AXI]
  connect_bd_intf_net -intf_net axi_noc_ic_M02_INI [get_bd_intf_pins axi_noc_ic/M02_INI] [get_bd_intf_pins axi_noc_mc_1x/S02_INI]
  connect_bd_intf_net -intf_net axi_noc_ic_M03_INI [get_bd_intf_pins axi_noc_ic/M03_INI] [get_bd_intf_pins axi_noc_mc_1x/S03_INI]
  connect_bd_intf_net -intf_net pcie_refclk [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins xdma_0_support/pcie_refclk]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_test_gpio_pf1/S_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins axi_noc_ic/S06_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS [get_bd_intf_pins xdma_0/M_AXI_BYPASS] [get_bd_intf_pins xdma_bypass_addr_mask/s_axi]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins xdma_lite_prot_conv/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_cfg_control_if [get_bd_intf_pins xdma_0/pcie_cfg_control_if] [get_bd_intf_pins xdma_0_support/pcie_cfg_control]
  connect_bd_intf_net -intf_net xdma_0_pcie_cfg_external_msix_without_msi_if [get_bd_intf_pins xdma_0/pcie4_cfg_external_msix_without_msi_if] [get_bd_intf_pins xdma_0_support/pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net xdma_0_pcie_cfg_interrupt [get_bd_intf_pins xdma_0/pcie4_cfg_interrupt] [get_bd_intf_pins xdma_0_support/pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net xdma_0_s_axis_cc [get_bd_intf_pins xdma_0/s_axis_cc] [get_bd_intf_pins xdma_0_support/s_axis_cc]
  connect_bd_intf_net -intf_net xdma_0_s_axis_rq [get_bd_intf_pins xdma_0/s_axis_rq] [get_bd_intf_pins xdma_0_support/s_axis_rq]
  connect_bd_intf_net -intf_net xdma_0_smc_M00_AXI [get_bd_intf_pins xdma_0_smc/M00_AXI] [get_bd_intf_pins xdma_0/S_AXI_B]
  connect_bd_intf_net -intf_net xdma_0_smc_M01_AXI [get_bd_intf_pins xdma_0_smc/M01_AXI] [get_bd_intf_pins blp_logic/s_axi_mgmt_ctrl]
  connect_bd_intf_net -intf_net xdma_0_smc_M02_AXI [get_bd_intf_pins xdma_0_smc/M02_AXI] [get_bd_intf_pins axi_test_gpio_pf0/S_AXI]
  connect_bd_intf_net -intf_net xdma_0_support_m_axis_cq [get_bd_intf_pins xdma_0/m_axis_cq] [get_bd_intf_pins xdma_0_support/m_axis_cq]
  connect_bd_intf_net -intf_net xdma_0_support_m_axis_rc [get_bd_intf_pins xdma_0/m_axis_rc] [get_bd_intf_pins xdma_0_support/m_axis_rc]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_cfg_fc [get_bd_intf_pins xdma_0/pcie_cfg_fc] [get_bd_intf_pins xdma_0_support/pcie_cfg_fc]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_cfg_mesg_rcvd [get_bd_intf_pins xdma_0/pcie4_cfg_mesg_rcvd] [get_bd_intf_pins xdma_0_support/pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_cfg_mesg_tx [get_bd_intf_pins xdma_0/pcie4_cfg_mesg_tx] [get_bd_intf_pins xdma_0_support/pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_cfg_status [get_bd_intf_pins xdma_0/pcie_cfg_status_if] [get_bd_intf_pins xdma_0_support/pcie_cfg_status]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_mgt_gt_pciea0 [get_bd_intf_pins gt_pciea0] [get_bd_intf_pins xdma_0_support/pcie_mgt]
  connect_bd_intf_net -intf_net xdma_0_support_pcie_transmit_fc [get_bd_intf_pins xdma_0/pcie_transmit_fc] [get_bd_intf_pins xdma_0_support/pcie_transmit_fc]
  connect_bd_intf_net -intf_net xdma_bypass_addr_mask_m_axi [get_bd_intf_pins xdma_bypass_addr_mask/m_axi] [get_bd_intf_pins axi_noc_ic/S08_AXI]
  connect_bd_intf_net -intf_net xdma_lite_addr_mask_m_axi [get_bd_intf_pins xdma_lite_addr_mask/m_axi] [get_bd_intf_pins axi_noc_ic/S07_AXI]
  connect_bd_intf_net -intf_net xdma_lite_prot_conv_M00_AXI [get_bd_intf_pins xdma_lite_prot_conv/M00_AXI] [get_bd_intf_pins xdma_lite_addr_mask/s_axi]

  # Create port connections
  connect_bd_net -net axi_test_gpio_pf0_io_o  [get_bd_pins axi_test_gpio_pf0/gpio_io_o] \
  [get_bd_pins axi_test_gpio_pf0/gpio_io_i]
  connect_bd_net -net axi_test_gpio_pf1_gpio_io_o  [get_bd_pins axi_test_gpio_pf1/gpio_io_o] \
  [get_bd_pins axi_test_gpio_pf1/gpio_io_i]
  connect_bd_net -net blp_logic_dout  [get_bd_pins blp_logic/msix_usr_func_num] \
  [get_bd_pins xdma_0/usr_irq_function_number]
  connect_bd_net -net blp_logic_dout1  [get_bd_pins blp_logic/msix_irq_req] \
  [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net blp_logic_force_reset_enable  [get_bd_pins blp_logic/force_reset_enable] \
  [get_bd_pins force_reset_concat_0/In0]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins cips/pl0_ref_clk] \
  [get_bd_pins axi_noc_ic/aclk7] \
  [get_bd_pins blp_logic/clk_pl_axi] \
  [get_bd_pins cips/m_axi_lpd_aclk] \
  [get_bd_pins xdma_0_smc/aclk1] \
  [get_bd_pins pl0_ref_clk]
  connect_bd_net -net cips_pl0_resetn  [get_bd_pins cips/pl0_resetn] \
  [get_bd_pins blp_logic/resetn_pl_axi] \
  [get_bd_pins pl0_resetn]
  connect_bd_net -net cips_pl_pcie_resetn  [get_bd_pins cips/pl_pcie0_resetn] \
  [get_bd_pins xdma_0_support/sys_reset]
  connect_bd_net -net force_reset_and_0_Res  [get_bd_pins force_reset_and_0/Res] \
  [get_bd_pins blp_logic/force_reset_result]
  connect_bd_net -net force_reset_concat_0_dout  [get_bd_pins force_reset_concat_0/dout] \
  [get_bd_pins force_reset_and_0/Op1]
  connect_bd_net -net force_reset_not_0_Res  [get_bd_pins force_reset_not_0/Res] \
  [get_bd_pins force_reset_concat_0/In1]
  connect_bd_net -net pf0_irq_tmp_dout  [get_bd_pins pf0_irq_tmp/dout] \
  [get_bd_pins blp_logic/pf0_irq]
  connect_bd_net -net pf1_irq  [get_bd_pins pf1_irq_tmp/dout] \
  [get_bd_pins blp_logic/pf1_irq]
  connect_bd_net -net pl_ps_irq10_1  [get_bd_pins pl_ps_irq10] \
  [get_bd_pins cips/pl_ps_irq10]
  connect_bd_net -net pl_ps_irq11_1  [get_bd_pins pl_ps_irq11] \
  [get_bd_pins cips/pl_ps_irq11]
  connect_bd_net -net pl_ps_irq12_1  [get_bd_pins pl_ps_irq12] \
  [get_bd_pins cips/pl_ps_irq12]
  connect_bd_net -net pl_ps_irq13_1  [get_bd_pins pl_ps_irq13] \
  [get_bd_pins cips/pl_ps_irq13]
  connect_bd_net -net pl_ps_irq14_1  [get_bd_pins pl_ps_irq14] \
  [get_bd_pins cips/pl_ps_irq14]
  connect_bd_net -net pl_ps_irq8_1  [get_bd_pins pl_ps_irq8] \
  [get_bd_pins cips/pl_ps_irq8]
  connect_bd_net -net pl_ps_irq9_1  [get_bd_pins pl_ps_irq9] \
  [get_bd_pins cips/pl_ps_irq9]
  connect_bd_net -net xdma_0_pcie_noc_axi_clk  [get_bd_pins xdma_0/axi_aclk] \
  [get_bd_pins xdma_0_smc/aclk] \
  [get_bd_pins axi_noc_ic/aclk8] \
  [get_bd_pins xdma_lite_prot_conv/aclk] \
  [get_bd_pins axi_test_gpio_pf0/s_axi_aclk] \
  [get_bd_pins xdma_lite_addr_mask/aclk] \
  [get_bd_pins xdma_bypass_addr_mask/aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins axi_test_gpio_pf1/s_axi_aclk]
  connect_bd_net -net xdma_0_support_phy_rdy_out  [get_bd_pins xdma_0_support/phy_rdy_out] \
  [get_bd_pins xdma_0/phy_rdy_out_sd]
  connect_bd_net -net xdma_0_support_user_lnk_up  [get_bd_pins xdma_0_support/user_lnk_up] \
  [get_bd_pins xdma_0/user_lnk_up_sd]
  connect_bd_net -net xdma_0_support_user_reset  [get_bd_pins xdma_0_support/user_reset] \
  [get_bd_pins xdma_0/user_reset_sd]
  connect_bd_net -net xdma_axi_aresetn  [get_bd_pins xdma_0/axi_aresetn] \
  [get_bd_pins force_reset_not_0/Op1] \
  [get_bd_pins xdma_0_smc/aresetn] \
  [get_bd_pins xdma_lite_prot_conv/aresetn] \
  [get_bd_pins axi_test_gpio_pf0/s_axi_aresetn] \
  [get_bd_pins xdma_lite_addr_mask/aresetn] \
  [get_bd_pins xdma_bypass_addr_mask/aresetn] \
  [get_bd_pins axi_test_gpio_pf1/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net xdma_pcie_user_clk  [get_bd_pins xdma_0_support/user_clk] \
  [get_bd_pins blp_logic/clk_pcie] \
  [get_bd_pins axi_noc_ic/aclk6] \
  [get_bd_pins xdma_0/user_clk_sd]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell} {

  variable script_folder
  variable design_name

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

  # Create interface ports

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name pcie_refclk_clk_n direction I } \
   CLK_P { physical_name pcie_refclk_clk_p direction I } \
 } \
  pcie_refclk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  set gt_pciea0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 -portmaps { \
   GRX_N { physical_name gt_pciea0_grx_n direction I left 7 right 0 } \
   GRX_P { physical_name gt_pciea0_grx_p direction I left 7 right 0 } \
   GTX_N { physical_name gt_pciea0_gtx_n direction O left 7 right 0 } \
   GTX_P { physical_name gt_pciea0_gtx_p direction O left 7 right 0 } \
 } \
  gt_pciea0 ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $gt_pciea0

  # Create interface ports
  set mipi_phy_if [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if ]

  set CFG_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 CFG_IIC ]

  set DESER_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 DESER_IIC ]

  # Create ports

  # Create instance: blp
  create_hier_cell_blp [current_bd_instance .] blp

  # Create instance: gmsl_pipeline
  create_hier_cell_gmsl_pipeline [current_bd_instance .] gmsl_pipeline

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins gmsl_pipeline/S00_AXI] [get_bd_intf_pins blp/M_AXI_0]
  connect_bd_intf_net -intf_net blp_gt_pciea0 [get_bd_intf_ports gt_pciea0] [get_bd_intf_pins blp/gt_pciea0]
  connect_bd_intf_net -intf_net gmsl_pipeline_CFG_IIC [get_bd_intf_ports CFG_IIC] [get_bd_intf_pins gmsl_pipeline/CFG_IIC]
  connect_bd_intf_net -intf_net gmsl_pipeline_DESER_IIC [get_bd_intf_ports DESER_IIC] [get_bd_intf_pins gmsl_pipeline/DESER_IIC]
  connect_bd_intf_net -intf_net gmsl_pipeline_M00_INI [get_bd_intf_pins gmsl_pipeline/M00_INI] [get_bd_intf_pins blp/S0_INI]
  connect_bd_intf_net -intf_net gmsl_pipeline_M01_INI [get_bd_intf_pins gmsl_pipeline/M01_INI] [get_bd_intf_pins blp/S1_INI]
  connect_bd_intf_net -intf_net mipi_phy_if_1 [get_bd_intf_ports mipi_phy_if] [get_bd_intf_pins gmsl_pipeline/mipi_phy_if]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins blp/pcie_refclk]

  # Create port connections
  connect_bd_net -net clk_in1_1  [get_bd_pins blp/pl0_ref_clk] \
  [get_bd_pins gmsl_pipeline/clk_in]
  connect_bd_net -net ext_reset_in_1  [get_bd_pins blp/pl0_resetn] \
  [get_bd_pins gmsl_pipeline/ext_reset_in]
  connect_bd_net -net gmsl_pipeline_csirxss_csi_irq  [get_bd_pins gmsl_pipeline/csirxss_csi_irq] \
  [get_bd_pins blp/pl_ps_irq8]
  connect_bd_net -net gmsl_pipeline_iic2intc_irpt  [get_bd_pins gmsl_pipeline/iic2intc_irpt] \
  [get_bd_pins blp/pl_ps_irq13]
  connect_bd_net -net gmsl_pipeline_iic2intc_irpt1  [get_bd_pins gmsl_pipeline/iic2intc_irpt1] \
  [get_bd_pins blp/pl_ps_irq14]
  connect_bd_net -net gmsl_pipeline_interrupt0  [get_bd_pins gmsl_pipeline/interrupt0] \
  [get_bd_pins blp/pl_ps_irq9]
  connect_bd_net -net gmsl_pipeline_interrupt1  [get_bd_pins gmsl_pipeline/interrupt1] \
  [get_bd_pins blp/pl_ps_irq10]
  connect_bd_net -net gmsl_pipeline_interrupt2  [get_bd_pins gmsl_pipeline/interrupt2] \
  [get_bd_pins blp/pl_ps_irq11]
  connect_bd_net -net gmsl_pipeline_interrupt3  [get_bd_pins gmsl_pipeline/interrupt3] \
  [get_bd_pins blp/pl_ps_irq12]


  save_bd_design

  # Create address segments
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x020200040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020200050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C2_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x020200040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020200050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_1] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x020200040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020200050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_2] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x020200040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020200050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/FPD_CCI_NOC_3] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/LPD_AXI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/LPD_AXI_NOC_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C2_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/axi_noc_mc_1x/S01_INI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x020200040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020200050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020200080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs gmsl_pipeline/v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces blp/xdma_0/M_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces blp/xdma_0/M_AXI_BYPASS] [get_bd_addr_segs blp/xdma_bypass_addr_mask/s_axi/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces blp/xdma_0/M_AXI_LITE] [get_bd_addr_segs blp/xdma_lite_addr_mask/s_axi/reg0] -force
  assign_bd_address -offset 0x00800000 -range 0x00800000 -target_address_space [get_bd_addr_spaces blp/xdma_lite_addr_mask/m_axi] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/xdma_lite_addr_mask/m_axi] [get_bd_addr_segs blp/axi_test_gpio_pf0/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/xdma_lite_addr_mask/m_axi] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg] -force
  assign_bd_address -offset 0x00100000 -range 0x00100000 -target_address_space [get_bd_addr_spaces blp/xdma_lite_addr_mask/m_axi] [get_bd_addr_segs blp/xdma_0/S_AXI_B/BAR0] -force
  assign_bd_address -offset 0x08000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces blp/xdma_bypass_addr_mask/m_axi] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces blp/xdma_bypass_addr_mask/m_axi] [get_bd_addr_segs blp/axi_test_gpio_pf1/S_AXI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_1/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_2/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_CH1] -force
  assign_bd_address -offset 0x050000000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_3/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_CH1] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/axi_test_gpio_pf0/S_AXI/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/blp_logic/base_clocking/force_reset_gpio/S_AXI/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/cips/PMC_NOC_AXI_0] [get_bd_addr_segs blp/xdma_0/S_AXI_B/BAR0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/xdma_0/M_AXI] [get_bd_addr_segs blp/axi_noc_mc_1x/S00_INI/C3_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/xdma_bypass_addr_mask/m_axi] [get_bd_addr_segs blp/axi_noc_mc_1x/S03_INI/C1_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces blp/xdma_lite_addr_mask/m_axi] [get_bd_addr_segs blp/axi_noc_mc_1x/S02_INI/C0_DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_1/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S04_INI/C1_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_2/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_LOW0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces gmsl_pipeline/v_frmbuf_wr_3/Data_m_axi_mm_video] [get_bd_addr_segs blp/axi_noc_mc_1x/S05_INI/C2_DDR_LOW0]

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
