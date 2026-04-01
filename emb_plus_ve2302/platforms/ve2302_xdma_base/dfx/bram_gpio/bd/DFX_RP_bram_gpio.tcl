# Copyright (C) 2025 Advanced Micro Devices, Inc.
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
# source DFX_RP_bram_gpio.tcl

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
set design_name DFX_RP_bram_gpio

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
xilinx.com:ip:axi_bram_ctrl:*\
xilinx.com:ip:emb_mem_gen:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:axi_vip:*\
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M0_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M1_AXI

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: axi_vip_0, and set properties
  set axi_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_0 ]
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


  # Create interface connections
  connect_bd_intf_net -intf_net axi_vip_0_M_AXI [get_bd_intf_pins M0_AXI] [get_bd_intf_pins axi_vip_0/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_1_M_AXI [get_bd_intf_pins M1_AXI] [get_bd_intf_pins axi_vip_1/M_AXI]

  # Create port connections
  connect_bd_net -net aclk  [get_bd_pins aclk] \
  [get_bd_pins axi_vip_1/aclk] \
  [get_bd_pins axi_vip_0/aclk]
  connect_bd_net -net aresetn  [get_bd_pins aresetn] \
  [get_bd_pins axi_vip_1/aresetn] \
  [get_bd_pins axi_vip_0/aresetn]

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
  source $dfx_dir/common/bd/static_interface.tcl

  ####################################################################
  ##
  ## DFX_RP_bram_gpio Logic Begins
  ##
  ####################################################################

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bram_ctrl_0 ]

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:emb_mem_gen axi_bram_ctrl_0_bram ]
  set_property CONFIG.MEMORY_TYPE {True_Dual_Port_RAM} $axi_bram_ctrl_0_bram


  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_ALL_INPUTS_2 {0} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_0

  # Create instance: axi_test_gpio_pf1, and set properties
  set axi_test_gpio_pf1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_test_gpio_pf1 ]
  set_property CONFIG.C_DOUT_DEFAULT {0x000000F1} $axi_test_gpio_pf1


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__view__ { functional { S00_Entry { SUPPORTS_WRAP 0 } } timing { S00_Entry { MMU_REGSLICE 0 TR_REGSLICE 0 } M00_Exit { REGSLICE 0 } } }   } \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create instance: ilconstant_gnd, and set properties
  set ilconstant_gnd [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_gnd ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {1} \
  ] $ilconstant_gnd

  # Create instance: tieoff_unused
  create_hier_cell_tieoff_unused [current_bd_instance .] tieoff_unused

  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_1


  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_fixed_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins smartconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins smartconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M02_AXI [get_bd_intf_pins smartconnect_1/M02_AXI] [get_bd_intf_pins axi_test_gpio_pf1/S_AXI]
  connect_bd_intf_net -intf_net axi_noc_fixed_1_S00_AXI [get_bd_intf_pins tieoff_unused/M0_AXI] [get_bd_intf_pins axi_noc_fixed_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_fixed_1_S01_AXI [get_bd_intf_pins tieoff_unused/M1_AXI] [get_bd_intf_pins axi_noc_fixed_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_noc_pcie_fixed_M00_AXI [get_bd_intf_pins axi_noc_pcie_fixed/M00_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_intc_fpd/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_intc_lpd/s_axi]

  # Create port connections
  connect_bd_net -net pcie_aclk  [get_bd_ports pcie_aclk] \
  [get_bd_pins axi_test_gpio_pf1/s_axi_aclk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins axi_noc_pcie_fixed/aclk0] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] \
  [get_bd_pins axi_noc_fixed_0/aclk0] \
  [get_bd_pins axi_noc_fixed_1/aclk0] \
  [get_bd_pins axi_intc_lpd/s_axi_aclk] \
  [get_bd_pins axi_intc_fpd/s_axi_aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins tieoff_unused/aclk] \
  [get_bd_pins smartconnect_1/aclk]
  connect_bd_net -net pcie_aresetn  [get_bd_ports pcie_aresetn] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]

  connect_bd_net -net const_gnd [get_bd_pins ilconstant_gnd/dout] \
  [get_bd_pins axi_intc_fpd/intr] \
  [get_bd_pins axi_intc_lpd/intr]

  connect_bd_net -net proc_sys_reset_0_peripheral [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_test_gpio_pf1/s_axi_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] \
  [get_bd_pins axi_intc_fpd/s_axi_aresetn] \
  [get_bd_pins axi_intc_lpd/s_axi_aresetn] \
  [get_bd_pins tieoff_unused/aresetn]


  connect_bd_net -net proc_sys_reset_0_interconnect [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins smartconnect_1/aresetn]

  connect_bd_net -net axi_gpio_0_gpio2_io_o  [get_bd_pins axi_gpio_0/gpio2_io_o] \
  [get_bd_pins axi_gpio_0/gpio_io_i]
  connect_bd_net -net axi_test_gpio_pf1_io_o  [get_bd_pins axi_test_gpio_pf1/gpio_io_o] \
  [get_bd_pins axi_test_gpio_pf1/gpio_io_i]

  # Create address segments
  # AIE
  assign_bd_address -offset 0x020000000000 -range 4G -target_address_space [get_bd_addr_spaces AIE_INI] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force

  # DDR (no addresses)

  # Versal control
  assign_bd_address -offset 0x020200810000 -range 64K -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_fpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200800000 -range 64K -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_lpd/S_AXI/Reg] -force

  # PCIe Control
  assign_bd_address -offset 0x020200030000 -range 8K -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x020200010000 -range 4K -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200020000 -range 4K -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs axi_test_gpio_pf1/S_AXI/Reg] -force

  # Exclude DDR
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces tieoff_unused/axi_vip_1/Master_AXI] [get_bd_addr_segs M01_INI/Reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces tieoff_unused/axi_vip_0/Master_AXI] [get_bd_addr_segs M00_INI/Reg]

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


