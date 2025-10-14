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
# source DFX_RP_1gEth.tcl

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
set design_name DFX_RP_1gEth

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
xilinx.com:ip:axi_dma:*\
xilinx.com:ip:axi_ethernet:*\
xilinx.com:ip:axi_noc:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:ai_engine:*\
xilinx.com:ip:axi_bram_ctrl:*\
xilinx.com:ip:emb_mem_gen:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:inline_hdl:ilconstant:*\
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
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_tieoff_unused_axi() - Empty argument(s)!"}
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


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_PCIE [get_bd_intf_pins S_AXI_PCIE] \
  [get_bd_intf_pins axi_vip_0/S_AXI]

  # Create port connections
  connect_bd_net -net aclk  [get_bd_pins aclk] \
  [get_bd_pins axi_vip_0/aclk]
  connect_bd_net -net aresetn  [get_bd_pins aresetn] \
  [get_bd_pins axi_vip_0/aresetn]



  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth_bufs
proc create_hier_cell_eth_bufs { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_eth_bufs() - Empty argument(s)!"}
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
  create_bd_pin -dir O mdio_i
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

  # Create instance: clk_shim RTL module to use IBUF
  create_bd_cell -type module -reference clk_shim clk_shim

  # Create port connections
  connect_bd_net -net clk_shim_in [get_bd_pins clk_25MHz_in] \
  [get_bd_pins clk_shim/clk_in]
  connect_bd_net -net clk_shim_out [get_bd_pins clk_25MHz] \
  [get_bd_pins clk_shim/clk_out]
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
  ## 1G Ethernet Logic Begins
  ##
  ####################################################################

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm_dre {1} \
    CONFIG.c_sg_length_width {16} \
    CONFIG.c_sg_use_stsapp_length {1} \
  ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_1 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm_dre {1} \
    CONFIG.c_sg_length_width {16} \
    CONFIG.c_sg_use_stsapp_length {1} \
  ] $axi_dma_1

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_0 ]
  set_property CONFIG.PHY_TYPE {RGMII} $axi_ethernet_0


  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet axi_ethernet_1 ]
  set_property CONFIG.PHY_TYPE {RGMII} $axi_ethernet_1


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
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.PRIM_IN_FREQ {25.000} \
  ] $clk_wizard_0


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
    CONFIG.PRIM_SOURCE {Global_buffer} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.PRIM_IN_FREQ {25.000} \
  ] $clk_wizard_1


  # Create instance: eth0_bufs
  create_hier_cell_eth_bufs [current_bd_instance .] eth0_bufs

  # Create instance: eth1_bufs
  create_hier_cell_eth_bufs [current_bd_instance .] eth1_bufs

  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {8} $ilconcat_0


  # Create instance: ilconcat_1, and set properties
  set ilconcat_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1 ]
  set_property CONFIG.NUM_PORTS {1} $ilconcat_1


  # Create instance: ilconcat_2, and set properties
  set ilconcat_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_2 ]
  set_property CONFIG.NUM_PORTS {1} $ilconcat_2


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {6} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1 ]
  set_property CONFIG.NUM_SI {3} $smartconnect_1


  # Create instance: smartconnect_2, and set properties
  set smartconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_2 ]
  set_property CONFIG.NUM_SI {3} $smartconnect_2


  # Create instance: ilconstant_gnd, and set properties
  set ilconstant_gnd [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_gnd ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {1} \
  ] $ilconstant_gnd

  # Create instance: tieoff_unused
  create_hier_cell_tieoff_unused [current_bd_instance .] tieoff_unused

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_pcie_fixed_M00_AXI [get_bd_intf_pins axi_noc_pcie_fixed/M00_AXI] [get_bd_intf_pins tieoff_unused/S_AXI_PCIE]
  connect_bd_intf_net -intf_net RGMII_0 [get_bd_intf_ports RGMII_0] [get_bd_intf_pins axi_ethernet_0/rgmii]
  connect_bd_intf_net -intf_net RGMII_1 [get_bd_intf_ports RGMII_1] [get_bd_intf_pins axi_ethernet_1/rgmii]

  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_dma_0/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_1/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXIS_CNTRL [get_bd_intf_pins axi_ethernet_1/s_axis_txc] [get_bd_intf_pins axi_dma_1/M_AXIS_CNTRL]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXIS_MM2S [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_MM2S [get_bd_intf_pins axi_dma_1/M_AXI_MM2S] [get_bd_intf_pins smartconnect_2/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_S2MM [get_bd_intf_pins axi_dma_1/M_AXI_S2MM] [get_bd_intf_pins smartconnect_2/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_SG [get_bd_intf_pins axi_dma_1/M_AXI_SG] [get_bd_intf_pins smartconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_dma_0/S_AXIS_STS] [get_bd_intf_pins axi_ethernet_0/m_axis_rxs]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxd [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins axi_ethernet_1/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxs [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_dma_1/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_fixed_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_ethernet_0/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_ethernet_1/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_dma_1/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_0/M04_AXI] [get_bd_intf_pins axi_intc_lpd/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins axi_intc_fpd/s_axi]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins axi_noc_fixed_1/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins axi_noc_fixed_1/S01_AXI]

  # Create port connections
  connect_bd_net -net pcie_aclk  [get_bd_ports pcie_aclk] \
  [get_bd_pins tieoff_unused/aclk] \
  [get_bd_pins axi_noc_fixed_0/aclk0] \
  [get_bd_pins axi_noc_fixed_1/aclk0] \
  [get_bd_pins axi_noc_pcie_fixed/aclk0] \
  [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
  [get_bd_pins axi_dma_0/m_axi_sg_aclk] \
  [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
  [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] \
  [get_bd_pins axi_dma_1/s_axi_lite_aclk] \
  [get_bd_pins axi_dma_1/m_axi_sg_aclk] \
  [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] \
  [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] \
  [get_bd_pins axi_ethernet_0/s_axi_lite_clk] \
  [get_bd_pins axi_ethernet_0/axis_clk] \
  [get_bd_pins axi_ethernet_1/s_axi_lite_clk] \
  [get_bd_pins axi_ethernet_1/axis_clk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins smartconnect_1/aclk] \
  [get_bd_pins smartconnect_2/aclk] \
  [get_bd_pins axi_intc_lpd/s_axi_aclk] \
  [get_bd_pins axi_intc_fpd/s_axi_aclk]

  connect_bd_net -net pcie_aresetn  [get_bd_ports pcie_aresetn] \
  [get_bd_pins tieoff_unused/aresetn] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins axi_intc_lpd/s_axi_aresetn] \
  [get_bd_pins axi_intc_fpd/s_axi_aresetn]

  connect_bd_net -net axi_dma_0_mm2s_cntrl_reset_out_n  [get_bd_pins axi_dma_0/mm2s_cntrl_reset_out_n] \
  [get_bd_pins axi_ethernet_0/axi_txc_arstn]
  connect_bd_net -net axi_dma_0_mm2s_introut  [get_bd_pins axi_dma_0/mm2s_introut] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n  [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] \
  [get_bd_pins axi_ethernet_0/axi_txd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_introut  [get_bd_pins axi_dma_0/s2mm_introut] \
  [get_bd_pins ilconcat_0/In3]
  connect_bd_net -net axi_dma_0_s2mm_prmry_reset_out_n  [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n] \
  [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_sts_reset_out_n  [get_bd_pins axi_dma_0/s2mm_sts_reset_out_n] \
  [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
  connect_bd_net -net axi_dma_1_mm2s_cntrl_reset_out_n  [get_bd_pins axi_dma_1/mm2s_cntrl_reset_out_n] \
  [get_bd_pins axi_ethernet_1/axi_txc_arstn]
  connect_bd_net -net axi_dma_1_mm2s_introut  [get_bd_pins axi_dma_1/mm2s_introut] \
  [get_bd_pins ilconcat_0/In4]
  connect_bd_net -net axi_dma_1_mm2s_prmry_reset_out_n  [get_bd_pins axi_dma_1/mm2s_prmry_reset_out_n] \
  [get_bd_pins axi_ethernet_1/axi_txd_arstn]
  connect_bd_net -net axi_dma_1_s2mm_introut  [get_bd_pins axi_dma_1/s2mm_introut] \
  [get_bd_pins ilconcat_0/In5]
  connect_bd_net -net axi_dma_1_s2mm_prmry_reset_out_n  [get_bd_pins axi_dma_1/s2mm_prmry_reset_out_n] \
  [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
  connect_bd_net -net axi_dma_1_s2mm_sts_reset_out_n  [get_bd_pins axi_dma_1/s2mm_sts_reset_out_n] \
  [get_bd_pins axi_ethernet_1/axi_rxs_arstn]
  connect_bd_net -net axi_ethernet_0_interrupt  [get_bd_pins axi_ethernet_0/interrupt] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net axi_ethernet_0_mac_irq  [get_bd_pins axi_ethernet_0/mac_irq] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net axi_ethernet_0_phy_rst_n  [get_bd_pins axi_ethernet_0/phy_rst_n] \
  [get_bd_pins ilconcat_2/In0]
  connect_bd_net -net axi_ethernet_1_interrupt  [get_bd_pins axi_ethernet_1/interrupt] \
  [get_bd_pins ilconcat_0/In7]
  connect_bd_net -net axi_ethernet_1_mac_irq  [get_bd_pins axi_ethernet_1/mac_irq] \
  [get_bd_pins ilconcat_0/In6]
  connect_bd_net -net axi_ethernet_1_phy_rst_n  [get_bd_pins axi_ethernet_1/phy_rst_n] \
  [get_bd_pins ilconcat_1/In0]
  connect_bd_net -net clk1_25MHz  [get_bd_pins eth0_bufs/clk_25MHz] \
  [get_bd_pins clk_wizard_0/clk_in1]
  connect_bd_net -net clk1_25MHz_io  [get_bd_ports clk1_25MHz] \
  [get_bd_pins eth0_bufs/clk_25MHz_in]
  connect_bd_net -net clk2_25MHz  [get_bd_pins eth1_bufs/clk_25MHz] \
  [get_bd_pins clk_wizard_1/clk_in1]
  connect_bd_net -net clk2_25MHz_io  [get_bd_ports clk2_25MHz] \
  [get_bd_pins eth1_bufs/clk_25MHz_in]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins clk_wizard_0/clk_out1] \
  [get_bd_pins axi_ethernet_0/gtx_clk]
  connect_bd_net -net clk_wizard_1_clk_out1  [get_bd_pins clk_wizard_1/clk_out1] \
  [get_bd_pins axi_ethernet_1/gtx_clk]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins axi_intc_lpd/intr]
  connect_bd_net -net ilconstant_gnd_dout  [get_bd_pins ilconstant_gnd/dout] \
  [get_bd_pins axi_intc_fpd/intr]
  connect_bd_net -net mdc  [get_bd_pins axi_ethernet_1/mdio_mdc] \
  [get_bd_pins eth1_bufs/mdc]
  connect_bd_net -net mdc_0  [get_bd_pins axi_ethernet_0/mdio_mdc] \
  [get_bd_pins eth0_bufs/mdc]
  connect_bd_net -net mdc_0_io  [get_bd_ports mdc_0] \
  [get_bd_pins eth0_bufs/mdc_io]
  connect_bd_net -net mdc_1_io  [get_bd_ports mdc_1] \
  [get_bd_pins eth1_bufs/mdc_io]
  connect_bd_net -net mdio_0_i  [get_bd_pins eth0_bufs/mdio_i] \
  [get_bd_pins axi_ethernet_0/mdio_mdio_i]
  connect_bd_net -net mdio_0_io  [get_bd_ports mdio_0] \
  [get_bd_pins eth0_bufs/mdio_io]
  connect_bd_net -net mdio_0_o  [get_bd_pins axi_ethernet_0/mdio_mdio_o] \
  [get_bd_pins eth0_bufs/mdio_o]
  connect_bd_net -net mdio_0_t  [get_bd_pins axi_ethernet_0/mdio_mdio_t] \
  [get_bd_pins eth0_bufs/mdio_t]
  connect_bd_net -net mdio_1_i  [get_bd_pins eth1_bufs/mdio_i] \
  [get_bd_pins axi_ethernet_1/mdio_mdio_i]
  connect_bd_net -net mdio_1_io  [get_bd_ports mdio_1] \
  [get_bd_pins eth1_bufs/mdio_io]
  connect_bd_net -net mdio_1_o  [get_bd_pins axi_ethernet_1/mdio_mdio_o] \
  [get_bd_pins eth1_bufs/mdio_o]
  connect_bd_net -net mdio_1_t  [get_bd_pins axi_ethernet_1/mdio_mdio_t] \
  [get_bd_pins eth1_bufs/mdio_t]
  connect_bd_net -net peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_dma_0/axi_resetn] \
  [get_bd_pins axi_dma_1/axi_resetn] \
  [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] \
  [get_bd_pins axi_ethernet_1/s_axi_lite_resetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins smartconnect_1/aresetn] \
  [get_bd_pins smartconnect_2/aresetn]
  connect_bd_net -net reset_phy_0_n  [get_bd_pins ilconcat_2/dout] \
  [get_bd_pins eth0_bufs/reset_phy_n]
  connect_bd_net -net reset_phy_0_n_io  [get_bd_ports reset_phy_0_n] \
  [get_bd_pins eth0_bufs/reset_phy_n_io]
  connect_bd_net -net reset_phy_1_n  [get_bd_pins ilconcat_1/dout] \
  [get_bd_pins eth1_bufs/reset_phy_n]
  connect_bd_net -net reset_phy_1_n_io  [get_bd_ports reset_phy_1_n] \
  [get_bd_pins eth1_bufs/reset_phy_n_io]

  # Create address segments

  # AIE
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces AIE_INI] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force

  # Control Versal
  assign_bd_address -offset 0x020200800000 -range 0x00001000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_lpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200810000 -range 0x00001000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_fpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200820000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200830000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200840000 -range 0x00040000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020200880000 -range 0x00040000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force

  # DDR Low
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs M01_INI/Reg] -force

  # DDR High (none)

  # Control PCIe
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs tieoff_unused/axi_vip_0/S_AXI/Reg] -force

  set_property USAGE memory [get_bd_addr_segs M00_INI/Reg]
  set_property USAGE memory [get_bd_addr_segs M01_INI/Reg]


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


