# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: ve2302_gmsl
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

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcve2302-sfva784-2MP-e-S
}


# CHANGE DESIGN NAME HERE
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
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:mipi_csi2_rx_subsystem:*\
xilinx.com:ip:axis_switch:*\
xilinx.com:ip:axis_subset_converter:*\
xilinx.com:ip:v_frmbuf_wr:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:xlslice:*\
xilinx.com:ip:util_vector_logic:*\
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


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

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
  set mipi_phy_if [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if ]

  set CFG_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 CFG_IIC ]

  set DESER_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 DESER_IIC ]

  # Create ports

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
    pl_clocks {1} \
    pl_resets {1} \
  }  $cips

  # Change some of CIPS configuratons to match use case
  set_property -dict [list \
    CONFIG.PS_PMC_CONFIG { \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PS_IRQ_USAGE \
      { \
        {CH0 0} {CH1 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} \
        {CH8 1} {CH9 1} {CH10 1} {CH11 1} {CH12 1} {CH13 1} {CH14 1} {CH15 1} \
      } \
      PS_USE_FPD_CCI_NOC {1} \
      PS_USE_FPD_CCI_NOC0 {1} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {0} \
      PS_USE_NOC_LPD_AXI0 {1} \
      PS_USE_PMCPL_CLK0 {1} \
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

  # End automation
  # Edit instance: axi_noc_0, and set properties
  set axi_noc_0 [ get_bd_cells axi_noc_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {7} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {10} \
  ] $axi_noc_0

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_2 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x140} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_2 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x100} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /axi_noc_0/S05_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S06_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S07_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S08_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S09_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S06_AXI:S07_AXI:S08_AXI:S09_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk6]

  # Create instance: proc_sys_reset_100M, and set properties
  set proc_sys_reset_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_100M ]

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

  # Create instance: v_frmbuf_wr_0, and set properties
  set v_frmbuf_wr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_0 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
  ] $v_frmbuf_wr_0

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {8} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0

  # Create instance: v_frmbuf_wr_1, and set properties
  set v_frmbuf_wr_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_1 ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {32} \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
  ] $v_frmbuf_wr_1

  # Create instance: v_frmbuf_wr_2, and set properties
  set v_frmbuf_wr_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_2 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
  ] $v_frmbuf_wr_2

  # Create instance: v_frmbuf_wr_3, and set properties
  set v_frmbuf_wr_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_3 ]
  set_property -dict [list \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
  ] $v_frmbuf_wr_3

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0 ]

  # Create instance: axi_iic_1, and set properties
  set axi_iic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_1 ]

  # Create instance: proc_sys_reset_375M, and set properties
  set proc_sys_reset_375M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_375M ]

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_1


  # Create instance: axis_data_fifo_2, and set properties
  set axis_data_fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_2 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_2


  # Create instance: axis_data_fifo_3, and set properties
  set axis_data_fifo_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_3 ]
  set_property -dict [list \
    CONFIG.FIFO_MODE {2} \
    CONFIG.IS_ACLK_ASYNC {1} \
  ] $axis_data_fifo_3


  # Create instance: axi_gpio_resets, and set properties
  set axi_gpio_resets [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_resets ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
  ] $axi_gpio_resets


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


  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
  ] $xlslice_2


  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {4} \
  ] $xlslice_3


  # Create interface connections
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports DESER_IIC] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_iic_1_IIC [get_bd_intf_ports CFG_IIC] [get_bd_intf_pins axi_iic_1/IIC]
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
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
  connect_bd_intf_net -intf_net mipi_phy_if [get_bd_intf_ports mipi_phy_if] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins v_frmbuf_wr_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins v_frmbuf_wr_1/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins v_frmbuf_wr_2/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins v_frmbuf_wr_3/s_axi_CTRL] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi] [get_bd_intf_pins smartconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins axi_gpio_resets/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M06_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins smartconnect_0/M06_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M07_AXI [get_bd_intf_pins axi_iic_1/S_AXI] [get_bd_intf_pins smartconnect_0/M07_AXI]
  connect_bd_intf_net -intf_net v_frmbuf_wr_0_m_axi_mm_video [get_bd_intf_pins axi_noc_0/S06_AXI] [get_bd_intf_pins v_frmbuf_wr_0/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_frmbuf_wr_1_m_axi_mm_video [get_bd_intf_pins axi_noc_0/S07_AXI] [get_bd_intf_pins v_frmbuf_wr_1/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_frmbuf_wr_2_m_axi_mm_video [get_bd_intf_pins axi_noc_0/S08_AXI] [get_bd_intf_pins v_frmbuf_wr_2/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_frmbuf_wr_3_m_axi_mm_video [get_bd_intf_pins axi_noc_0/S09_AXI] [get_bd_intf_pins v_frmbuf_wr_3/m_axi_mm_video]

  # Create port connections
  connect_bd_net -net axi_gpio_resets_gpio_io_o  [get_bd_pins axi_gpio_resets/gpio_io_o] \
  [get_bd_pins xlslice_0/Din] \
  [get_bd_pins xlslice_1/Din] \
  [get_bd_pins xlslice_2/Din] \
  [get_bd_pins xlslice_3/Din]
  connect_bd_net -net axi_iic_0_iic2intc_irpt  [get_bd_pins axi_iic_0/iic2intc_irpt] \
  [get_bd_pins cips/pl_ps_irq13]
  connect_bd_net -net axi_iic_1_iic2intc_irpt  [get_bd_pins axi_iic_1/iic2intc_irpt] \
  [get_bd_pins cips/pl_ps_irq14]
  connect_bd_net -net cips_pl0_ref_clk  [get_bd_pins cips/pl0_ref_clk] \
  [get_bd_pins proc_sys_reset_100M/slowest_sync_clk] \
  [get_bd_pins axi_noc_0/aclk6] \
  [get_bd_pins clk_wizard_0/clk_in1] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] \
  [get_bd_pins v_frmbuf_wr_0/ap_clk] \
  [get_bd_pins smartconnect_0/aclk] \
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
  [get_bd_pins axi_gpio_resets/s_axi_aclk]
  connect_bd_net -net cips_pl0_resetn  [get_bd_pins cips/pl0_resetn] \
  [get_bd_pins proc_sys_reset_100M/ext_reset_in] \
  [get_bd_pins proc_sys_reset_375M/ext_reset_in]
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
  [get_bd_pins cips/pl_ps_irq8]
  connect_bd_net -net proc_sys_reset_100M_peripheral_aresetn  [get_bd_pins proc_sys_reset_100M/peripheral_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] \
  [get_bd_pins axi_iic_1/s_axi_aresetn] \
  [get_bd_pins axi_iic_0/s_axi_aresetn] \
  [get_bd_pins axis_subset_converter_1/aresetn] \
  [get_bd_pins axis_subset_converter_3/aresetn] \
  [get_bd_pins axis_subset_converter_0/aresetn] \
  [get_bd_pins axis_subset_converter_2/aresetn] \
  [get_bd_pins axi_gpio_resets/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_300M_interconnect_aresetn  [get_bd_pins proc_sys_reset_100M/interconnect_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_375M_interconnect_aresetn  [get_bd_pins proc_sys_reset_375M/interconnect_aresetn] \
  [get_bd_pins axis_switch_0/aresetn] \
  [get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_1/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_2/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_3/s_axis_aresetn]
  connect_bd_net -net proc_sys_reset_375M_peripheral_aresetn  [get_bd_pins proc_sys_reset_375M/peripheral_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]
  connect_bd_net -net v_frmbuf_wr_0_interrupt  [get_bd_pins v_frmbuf_wr_0/interrupt] \
  [get_bd_pins cips/pl_ps_irq9]
  connect_bd_net -net v_frmbuf_wr_1_interrupt  [get_bd_pins v_frmbuf_wr_1/interrupt] \
  [get_bd_pins cips/pl_ps_irq10]
  connect_bd_net -net v_frmbuf_wr_2_interrupt  [get_bd_pins v_frmbuf_wr_2/interrupt] \
  [get_bd_pins cips/pl_ps_irq11]
  connect_bd_net -net v_frmbuf_wr_3_interrupt  [get_bd_pins v_frmbuf_wr_3/interrupt] \
  [get_bd_pins cips/pl_ps_irq12]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins v_frmbuf_wr_0/ap_rst_n]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins v_frmbuf_wr_1/ap_rst_n]
  connect_bd_net -net xlslice_2_Dout  [get_bd_pins xlslice_2/Dout] \
  [get_bd_pins v_frmbuf_wr_2/ap_rst_n]
  connect_bd_net -net xlslice_3_Dout  [get_bd_pins xlslice_3/Dout] \
  [get_bd_pins v_frmbuf_wr_3/ap_rst_n]

  # Create address segments
  assign_bd_address -offset 0x020100060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x020100040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x020100040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x020100040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW1] -force
  assign_bd_address -offset 0x020100040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x020100060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_gpio_resets/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_iic_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x020100040000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs v_frmbuf_wr_1/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs v_frmbuf_wr_2/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x020100030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs v_frmbuf_wr_3/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces v_frmbuf_wr_1/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces v_frmbuf_wr_2/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S08_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces v_frmbuf_wr_3/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S09_AXI/C3_DDR_LOW0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces v_frmbuf_wr_1/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces v_frmbuf_wr_2/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S08_AXI/C2_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces v_frmbuf_wr_3/Data_m_axi_mm_video] [get_bd_addr_segs axi_noc_0/S09_AXI/C3_DDR_LOW1]


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


