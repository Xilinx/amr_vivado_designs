# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: alveo_v80
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
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_gpio:*\
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


# Hierarchical cell: PF1
proc create_hier_cell_PF1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_PF1() - Empty argument(s)!"}
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


  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: smartconnect_pf1, and set properties
  set smartconnect_pf1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_pf1 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_pf1


  # Create instance: axi_gpio_test_pf1, and set properties
  set axi_gpio_test_pf1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_test_pf1 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {0} \
    CONFIG.C_DOUT_DEFAULT {0x000000F1} \
  ] $axi_gpio_test_pf1


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_pf1/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_pf1/M00_AXI] [get_bd_intf_pins axi_gpio_test_pf1/S_AXI]

  # Create port connections
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_test_pf1/gpio_io_o] \
  [get_bd_pins axi_gpio_test_pf1/gpio_io_i]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_gpio_test_pf1/s_axi_aclk] \
  [get_bd_pins smartconnect_pf1/aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins smartconnect_pf1/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_gpio_test_pf1/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

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
  set CH0_DDR4_0_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_0 ]

  set sys_clk0_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_0

  set CH0_DDR4_0_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_1 ]

  set sys_clk0_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_1

  set hbm_ref_clk_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_0

  set hbm_ref_clk_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_1

# Uncomment qsfp and mcio ports as required by design
#  set qsfp0_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp0_4x ]
#
#  set qsfp1_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp1_4x ]
#
#  set qsfp2_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp2_4x ]
#
#  set qsfp3_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 qsfp3_4x ]
#
#  set qsfp0_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp0_322mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {322265625} \
#   ] $qsfp0_322mhz
#
#  set qsfp2_322mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp2_322mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {322265625} \
#   ] $qsfp2_322mhz
#
#  set mcio0_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio0_4x ]
#
#  set mcio1_a_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio1_a_4x ]
#
#  set mcio1_b_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio1_b_4x ]
#
#  set mcio2_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 mcio2_4x ]
#
#  set mcio0_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio0_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio0_100mhz
#
#  set mcio1_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio1_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio1_100mhz
#
#  set mcio2_100mhz [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 mcio2_100mhz ]
#  set_property -dict [ list \
#   CONFIG.FREQ_HZ {100000000} \
#   ] $mcio2_100mhz

  set gt_pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $gt_pcie_refclk

  set gt_pciea1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea1 ]



  # Create ports

  # Create instance: cips, and set properties
  set cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips cips ]
  set_property -dict [list \
    CONFIG.CPM_CONFIG { \
      CPM_PCIE0_MODES {None} \
      CPM_PCIE1_ACS_CAP_ON {0} \
      CPM_PCIE1_ARI_CAP_ENABLED {0} \
      CPM_PCIE1_CFG_EXT_IF {0} \
      CPM_PCIE1_CFG_VEND_ID {10ee} \
      CPM_PCIE1_COPY_PF0_QDMA_ENABLED {0} \
      CPM_PCIE1_EXT_PCIE_CFG_SPACE_ENABLED {None} \
      CPM_PCIE1_FUNCTIONAL_MODE {QDMA} \
      CPM_PCIE1_MAX_LINK_SPEED {32.0_GT/s} \
      CPM_PCIE1_MODES {DMA} \
      CPM_PCIE1_MODE_SELECTION {Advanced} \
      CPM_PCIE1_MSI_X_OPTIONS {MSI-X_Internal} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_0 {0x0000008000000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_1 {0x0000008040000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_2 {0x0000008080000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_3 {0x00000080C0000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_4 {0x0000008100000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_5 {0x0000008140000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_0 {0x000000803FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_1 {0x000000807FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_2 {0x00000080BFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_3 {0x00000080FFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_4 {0x000000813FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_5 {0x000000817FFFFFFFF} \
      CPM_PCIE1_PF0_BAR0_QDMA_64BIT {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_ENABLED {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF0_BAR0_QDMA_SCALE {Megabytes} \
      CPM_PCIE1_PF0_BAR0_QDMA_SIZE {16} \
      CPM_PCIE1_PF0_BAR0_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF0_BAR2_QDMA_64BIT {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_ENABLED {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF0_BAR2_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF0_BAR2_QDMA_SIZE {4} \
      CPM_PCIE1_PF0_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF0_BASE_CLASS_VALUE {12} \
      CPM_PCIE1_PF0_CFG_DEV_ID {50b4} \
      CPM_PCIE1_PF0_CFG_SUBSYS_ID {000e} \
      CPM_PCIE1_PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE {0} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_OFFSET {40} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_SIZE {1} \
      CPM_PCIE1_PF0_MSIX_ENABLED {0} \
      CPM_PCIE1_PF0_PCIEBAR2AXIBAR_QDMA_0 {0x0000020100000000} \
      CPM_PCIE1_PF0_SUB_CLASS_VALUE {00} \
      CPM_PCIE1_PF1_BAR0_QDMA_64BIT {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_ENABLED {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF1_BAR0_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF1_BAR0_QDMA_SIZE {512} \
      CPM_PCIE1_PF1_BAR0_QDMA_TYPE {DMA} \
      CPM_PCIE1_PF1_BAR2_QDMA_64BIT {1} \
      CPM_PCIE1_PF1_BAR2_QDMA_ENABLED {1} \
      CPM_PCIE1_PF1_BAR2_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF1_BAR2_QDMA_SCALE {Megabytes} \
      CPM_PCIE1_PF1_BAR2_QDMA_SIZE {256} \
      CPM_PCIE1_PF1_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF1_BASE_CLASS_VALUE {12} \
      CPM_PCIE1_PF1_CFG_DEV_ID {50b5} \
      CPM_PCIE1_PF1_CFG_SUBSYS_ID {000e} \
      CPM_PCIE1_PF1_CFG_SUBSYS_VEND_ID {10EE} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_OFFSET {50000} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_SIZE {8} \
      CPM_PCIE1_PF1_MSIX_ENABLED {1} \
      CPM_PCIE1_PF1_PCIEBAR2AXIBAR_QDMA_2 {0x0000020200000000} \
      CPM_PCIE1_PF1_SUB_CLASS_VALUE {00} \
      CPM_PCIE1_PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
      CPM_PCIE1_TL_PF_ENABLE_REG {2} \
    } \
    CONFIG.PS_PMC_CONFIG { \
      BOOT_MODE {Custom} \
      CLOCK_MODE {Custom} \
      DDR_MEMORY_MODE {Custom} \
      DESIGN_MODE {1} \
      DEVICE_INTEGRITY_MODE {Custom} \
      IO_CONFIG_MODE {Custom} \
      PCIE_APERTURES_DUAL_ENABLE {0} \
      PCIE_APERTURES_SINGLE_ENABLE {1} \
      PMC_BANK_1_IO_STANDARD {LVCMOS3.3} \
      PMC_CRP_OSPI_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PMC_CRP_PL2_REF_CTRL_FREQMHZ {250} \
      PMC_GLITCH_CONFIG {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_1 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_2 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PMC_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO13 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO17 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO26 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO27 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO28 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO29 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO30 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO31 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO32 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO33 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO34 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO35 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO36 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO37 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO38 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO39 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO40 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO41 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO42 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO43 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO44 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO48 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO49 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO50 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO51 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO_EN_FOR_PL_PCIE {0} \
      PMC_OSPI_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
      PMC_REF_CLK_FREQMHZ {33.333333} \
      PMC_SD0_DATA_TRANSFER_MODE {8Bit} \
      PMC_SD0_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x2} {CLK_50_DDR_ITAP_DLY 0x1E} {CLK_50_DDR_OTAP_DLY 0x5} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x5} {ENABLE 1} {IO\
{PMC_MIO 13 .. 25}}} \
      PMC_SD0_SLOT_TYPE {eMMC} \
      PMC_USE_PL_ERR0 {1} \
      PMC_USE_PMC_NOC_AXI0 {1} \
      PS_BANK_2_IO_STANDARD {LVCMOS3.3} \
      PS_BOARD_INTERFACE {Custom} \
      PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ {1000} \
      PS_GEN_IPI0_ENABLE {0} \
      PS_GEN_IPI1_ENABLE {0} \
      PS_GEN_IPI2_ENABLE {0} \
      PS_GEN_IPI3_ENABLE {1} \
      PS_GEN_IPI3_MASTER {R5_0} \
      PS_GEN_IPI4_ENABLE {1} \
      PS_GEN_IPI4_MASTER {R5_0} \
      PS_GEN_IPI5_ENABLE {1} \
      PS_GEN_IPI5_MASTER {R5_1} \
      PS_GEN_IPI6_ENABLE {1} \
      PS_GEN_IPI6_MASTER {R5_1} \
      PS_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PS_I2C0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 2 .. 3}}} \
      PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 1}}} \
      PS_IRQ_USAGE {{CH0 1} {CH1 1} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
      PS_KAT_ENABLE {0} \
      PS_KAT_ENABLE_1 {0} \
      PS_KAT_ENABLE_2 {0} \
      PS_MIO10 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO12 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO14 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO18 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO19 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO22 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO23 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO25 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO4 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO5 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO8 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO9 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PS_M_AXI_LPD_DATA_WIDTH {32} \
      PS_NUM_FABRIC_RESETS {1} \
      PS_PCIE1_PERIPHERAL_ENABLE {0} \
      PS_PCIE2_PERIPHERAL_ENABLE {1} \
      PS_PCIE_EP_RESET1_IO {PMC_MIO 24} \
      PS_PCIE_EP_RESET2_IO {PMC_MIO 25} \
      PS_PCIE_RESET {{ENABLE 1}} \
      PS_PL_CONNECTIVITY_MODE {Custom} \
      PS_SPI0 {{GRP_SS0_ENABLE 1} {GRP_SS0_IO {PS_MIO 15}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PMC_MIO 14}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PMC_MIO 13}} {PERIPHERAL_ENABLE 1} {PERIPHERAL_IO {PS_MIO 12 .. 17}}}\
\
      PS_SPI1 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO {PS_MIO 9}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PS_MIO 8}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PS_MIO 7}} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO {PS_MIO 6 .. 11}}} \
      PS_TTC0_PERIPHERAL_ENABLE {1} \
      PS_TTC1_PERIPHERAL_ENABLE {1} \
      PS_TTC2_PERIPHERAL_ENABLE {1} \
      PS_TTC3_PERIPHERAL_ENABLE {1} \
      PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 8 .. 9}}} \
      PS_UART1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 20 .. 21}}} \
      PS_USE_FPD_CCI_NOC {0} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {1} \
      PS_USE_NOC_LPD_AXI0 {1} \
      PS_USE_PMCPL_CLK0 {1} \
      PS_USE_PMCPL_CLK1 {1} \
      PS_USE_PMCPL_CLK2 {1} \
      PS_USE_S_AXI_LPD {0} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_MEAS100 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 9}} \
      SMON_MEAS101 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_501} {SUPPLY_NUM 10}} \
      SMON_MEAS102 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_502} {SUPPLY_NUM 11}} \
      SMON_MEAS103 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_503} {SUPPLY_NUM 12}} \
      SMON_MEAS104 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_700} {SUPPLY_NUM 13}} \
      SMON_MEAS105 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_701} {SUPPLY_NUM 14}} \
      SMON_MEAS106 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_702} {SUPPLY_NUM 15}} \
      SMON_MEAS118 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 0}} \
      SMON_MEAS119 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 1}} \
      SMON_MEAS120 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 2}} \
      SMON_MEAS121 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_RAM} {SUPPLY_NUM 3}} \
      SMON_MEAS122 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 4}} \
      SMON_MEAS47 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_104} {SUPPLY_NUM 20}} \
      SMON_MEAS48 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_105} {SUPPLY_NUM 21}} \
      SMON_MEAS64 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_104} {SUPPLY_NUM 18}} \
      SMON_MEAS65 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_105} {SUPPLY_NUM 19}} \
      SMON_MEAS81 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_104} {SUPPLY_NUM 22}} \
      SMON_MEAS82 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_105} {SUPPLY_NUM 23}} \
      SMON_MEAS96 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 6}} \
      SMON_MEAS97 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 7}} \
      SMON_MEAS98 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_SMON} {SUPPLY_NUM 8}} \
      SMON_MEAS99 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCINT} {SUPPLY_NUM 5}} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_VOLTAGE_AVERAGING_SAMPLES {8} \
    } \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
  ] $cips


  # Create instance: axi_noc_cips, and set properties
  set axi_noc_cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_cips ]
  set_property -dict [list \
    CONFIG.HBM_NUM_CHNL {16} \
    CONFIG.HBM_REF_CLK_FREQ0 {200.000} \
    CONFIG.HBM_REF_CLK_FREQ1 {200.000} \
    CONFIG.HBM_REF_CLK_SELECTION {External} \
    CONFIG.NUM_CLKS {5} \
    CONFIG.NUM_HBM_BLI {0} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_NSI {0} \
    CONFIG.NUM_SI {4} \
  ] $axi_noc_cips


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.APERTURES {{0x201_0000_0000 16M}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_cips/M00_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_cips/M01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64} } M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M02_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} HBM0_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM1_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
   CONFIG.REMAPS {M00_INI {{0x201_0000_0000 0x1000_0000 16M}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /axi_noc_cips/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}} M01_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} M03_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}} HBM0_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM0_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM1_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM2_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM3_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM4_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM5_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM6_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM7_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM8_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM9_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM10_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM11_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM12_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM13_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM14_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}} HBM15_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
   CONFIG.REMAPS {M01_INI {{0x201_0000_0000 0x1000_0000 16M}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /axi_noc_cips/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI { read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true}}  M02_INI { read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } initial_boot {true} } \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /axi_noc_cips/S02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {  M00_INI { read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} initial_boot {true} } } \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_cips/S03_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:M01_AXI} \
 ] [get_bd_pins /axi_noc_cips/aclk4]

  # Create instance: axi_noc_mc_ddr4_0, and set properties
  set axi_noc_mc_ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_mc_ddr4_0 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC_CHAN_REGION1 {DDR_CH1} \
    CONFIG.MC_COMPONENT_WIDTH {x16} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_DM_WIDTH {9} \
    CONFIG.MC_DQS_WIDTH {9} \
    CONFIG.MC_DQ_WIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {Components} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {16} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_mc_ddr4_0


  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_0/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_0/S01_INI]

  # Create instance: axi_noc_mc_ddr4_1, and set properties
  set axi_noc_mc_ddr4_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_mc_ddr4_1 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC0_CONFIG_NUM {config21} \
    CONFIG.MC0_FLIPPED_PINOUT {false} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH2} \
    CONFIG.MC_COMPONENT_WIDTH {x4} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {RDIMMs} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_PARITY {true} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {18} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_mc_ddr4_1


  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS { MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64} } } \
 ] [get_bd_intf_pins /axi_noc_mc_ddr4_1/S01_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins /axi_noc_mc_ddr4_1/aclk0]

  # Create instance: PF1
  create_hier_cell_PF1 [current_bd_instance .] PF1

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_cips_M00_INI [get_bd_intf_pins axi_noc_cips/M00_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins PF1/S00_AXI] [get_bd_intf_pins axi_noc_cips/M01_AXI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_INI [get_bd_intf_pins axi_noc_cips/M01_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_INI [get_bd_intf_pins axi_noc_cips/M02_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M03_INI [get_bd_intf_pins axi_noc_cips/M03_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_0_CH0_DDR4_0 [get_bd_intf_pins axi_noc_mc_ddr4_0/CH0_DDR4_0] [get_bd_intf_ports CH0_DDR4_0_0]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_1_CH0_DDR4_0 [get_bd_intf_pins axi_noc_mc_ddr4_1/CH0_DDR4_0] [get_bd_intf_ports CH0_DDR4_0_1]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_0 [get_bd_intf_pins cips/CPM_PCIE_NOC_0] [get_bd_intf_pins axi_noc_cips/S00_AXI]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_1 [get_bd_intf_pins cips/CPM_PCIE_NOC_1] [get_bd_intf_pins axi_noc_cips/S01_AXI]
  connect_bd_intf_net -intf_net cips_LPD_AXI_NOC_0 [get_bd_intf_pins cips/LPD_AXI_NOC_0] [get_bd_intf_pins axi_noc_cips/S03_AXI]
  connect_bd_intf_net -intf_net cips_PCIE1_GT [get_bd_intf_pins cips/PCIE1_GT] [get_bd_intf_ports gt_pciea1]
  connect_bd_intf_net -intf_net cips_PMC_NOC_AXI_0 [get_bd_intf_pins cips/PMC_NOC_AXI_0] [get_bd_intf_pins axi_noc_cips/S02_AXI]
  connect_bd_intf_net -intf_net gt_pcie_refclk_1 [get_bd_intf_ports gt_pcie_refclk] [get_bd_intf_pins cips/gt_refclk1]
  connect_bd_intf_net -intf_net hbm_ref_clk_0_1 [get_bd_intf_ports hbm_ref_clk_0] [get_bd_intf_pins axi_noc_cips/hbm_ref_clk0]
  connect_bd_intf_net -intf_net hbm_ref_clk_1_1 [get_bd_intf_ports hbm_ref_clk_1] [get_bd_intf_pins axi_noc_cips/hbm_ref_clk1]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_ports sys_clk0_0] [get_bd_intf_pins axi_noc_mc_ddr4_0/sys_clk0]
  connect_bd_intf_net -intf_net sys_clk0_1_1 [get_bd_intf_ports sys_clk0_1] [get_bd_intf_pins axi_noc_mc_ddr4_1/sys_clk0]

  # Create port connections
  connect_bd_net -net cips_cpm_pcie_noc_axi0_clk  [get_bd_pins cips/cpm_pcie_noc_axi0_clk] \
  [get_bd_pins axi_noc_cips/aclk0]
  connect_bd_net -net cips_cpm_pcie_noc_axi1_clk  [get_bd_pins cips/cpm_pcie_noc_axi1_clk] \
  [get_bd_pins axi_noc_cips/aclk1]
  connect_bd_net -net cips_lpd_axi_noc_clk  [get_bd_pins cips/lpd_axi_noc_clk] \
  [get_bd_pins axi_noc_cips/aclk3]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins cips/pl0_ref_clk] \
  [get_bd_pins cips/m_axi_lpd_aclk] \
  [get_bd_pins axi_noc_cips/aclk4] \
  [get_bd_pins axi_noc_mc_ddr4_1/aclk0] \
  [get_bd_pins PF1/s_axi_aclk]
  connect_bd_net -net cips_pl0_resetn  [get_bd_pins cips/pl0_resetn] \
  [get_bd_pins PF1/aresetn]
  connect_bd_net -net cips_pl2_ref_clk  [get_bd_pins cips/pl2_ref_clk] \
  [get_bd_pins cips/dma1_intrfc_clk]
  connect_bd_net -net cips_pmc_axi_noc_axi0_clk  [get_bd_pins cips/pmc_axi_noc_axi0_clk] \
  [get_bd_pins axi_noc_cips/aclk2]

  # Create address segments
  assign_bd_address -offset 0x020200020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs PF1/axi_gpio_test_pf1/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM0_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM9_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_cips/S00_AXI/HBM15_PC1] -force
  assign_bd_address -offset 0x020100000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0x020200020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs PF1/axi_gpio_test_pf1/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM0_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM9_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_cips/S01_AXI/HBM15_PC1] -force
  assign_bd_address -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_0/S01_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x020100000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_0/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_1/S01_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces cips/CPM_PCIE_NOC_1] [get_bd_addr_segs axi_noc_mc_ddr4_0/S01_INI/C1_DDR_CH1]
  exclude_bd_addr_seg -offset 0x050080000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1]


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
