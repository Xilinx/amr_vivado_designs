# Copyright (C) 2023 - 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: ve2302_1gEth
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
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:axi_ethernet:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:ip:axi_dma:*\
xilinx.com:ip:versal_cips:*\
xilinx.com:ip:axi_noc:*\
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
  set mdio_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_0 ]

  set mdio_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_1 ]

  set rgmii_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_0 ]

  set rgmii_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_1 ]



  # Create ports
  set reset_phy_0 [ create_bd_port -dir O -from 0 -to 0 -type rst reset_phy_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_phy_0
  set reset_phy_1 [ create_bd_port -dir O -from 0 -to 0 -type rst reset_phy_1 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_phy_1
  set clk1_25MHz [ create_bd_port -dir I -type clk -freq_hz 25000000 clk1_25MHz ]
  set clk2_25MHz [ create_bd_port -dir I -type clk -freq_hz 25000000 clk2_25MHz ]

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

  # Edit instance: axi_noc_0, and set properties
  set axi_noc_0 [ get_bd_cells axi_noc_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {7} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {8} \
  ] $axi_noc_0

  # Change some of CIPS configuratons to match use case
  set_property -dict [list \
    CONFIG.PS_PMC_CONFIG { \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PS_IRQ_USAGE \
      { \
        {CH0 1} {CH1 1} {CH2 1} {CH3 1} {CH4 1} {CH5 0} {CH6 0} {CH7 0} \
        {CH8 1} {CH9 1} {CH10 1} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} \
      } \
      PS_USE_FPD_CCI_NOC {1} \
      PS_USE_FPD_CCI_NOC0 {1} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {0} \
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

  # End automation


  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_0000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_2 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_0 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_1 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {MC_3 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.REGION {0} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} MC_2 {read_bw {100} write_bw {100} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
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
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S06_AXI:S07_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk6]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

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
  ] $clk_wizard_1


  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0 ]


  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1 ]
  set_property CONFIG.NUM_SI {3} $smartconnect_1


  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_1 ]

  # Create instance: smartconnect_2, and set properties
  set smartconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_2 ]
  set_property CONFIG.NUM_SI {3} $smartconnect_2


  # Create interface connections
  connect_bd_intf_net -intf_net axi_ethernet_0_rgmii [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_pins rgmii_0]
  connect_bd_intf_net -intf_net axi_ethernet_1_rgmii [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_pins rgmii_1]
#  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_noc_mc_1x/CH0_LPDDR4_0] [get_bd_intf_pins CH0_LPDDR4_0_0]
#  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_noc_mc_1x/CH1_LPDDR4_0] [get_bd_intf_pins CH1_LPDDR4_0_0]
#  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins axi_noc_mc_1x/sys_clk0] [get_bd_intf_pins sys_clk0_0]
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
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_pins mdio_0] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxd [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins axi_ethernet_1/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxs [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_dma_1/S_AXIS_STS]
  connect_bd_intf_net -intf_net axi_ethernet_1_mdio [get_bd_intf_pins mdio_1] [get_bd_intf_pins axi_ethernet_1/mdio]
#  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_0/M00_AXI]
#  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_pins axi_noc_0/M00_INI] [get_bd_intf_pins axi_noc_mc_1x/S00_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M01_INI [get_bd_intf_pins axi_noc_0/M01_INI] [get_bd_intf_pins axi_noc_mc_1x/S01_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M02_INI [get_bd_intf_pins axi_noc_0/M02_INI] [get_bd_intf_pins axi_noc_mc_1x/S02_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M03_INI [get_bd_intf_pins axi_noc_0/M03_INI] [get_bd_intf_pins axi_noc_mc_1x/S03_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M04_INI [get_bd_intf_pins axi_noc_0/M04_INI] [get_bd_intf_pins axi_noc_mc_1x/S04_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M05_INI [get_bd_intf_pins axi_noc_0/M05_INI] [get_bd_intf_pins axi_noc_mc_1x/S05_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M06_INI [get_bd_intf_pins axi_noc_0/M06_INI] [get_bd_intf_pins axi_noc_mc_1x/S06_INI]
#  connect_bd_intf_net -intf_net axi_noc_0_M07_INI [get_bd_intf_pins axi_noc_0/M07_INI] [get_bd_intf_pins axi_noc_mc_1x/S07_INI]
#  connect_bd_intf_net -intf_net cips_FPD_CCI_NOC_0 [get_bd_intf_pins cips/FPD_CCI_NOC_0] [get_bd_intf_pins axi_noc_0/S00_AXI]
#  connect_bd_intf_net -intf_net cips_FPD_CCI_NOC_1 [get_bd_intf_pins cips/FPD_CCI_NOC_1] [get_bd_intf_pins axi_noc_0/S01_AXI]
#  connect_bd_intf_net -intf_net cips_FPD_CCI_NOC_2 [get_bd_intf_pins cips/FPD_CCI_NOC_2] [get_bd_intf_pins axi_noc_0/S02_AXI]
#  connect_bd_intf_net -intf_net cips_FPD_CCI_NOC_3 [get_bd_intf_pins cips/FPD_CCI_NOC_3] [get_bd_intf_pins axi_noc_0/S03_AXI]
#  connect_bd_intf_net -intf_net cips_LPD_AXI_NOC_0 [get_bd_intf_pins cips/LPD_AXI_NOC_0] [get_bd_intf_pins axi_noc_0/S05_AXI]
#  connect_bd_intf_net -intf_net cips_PMC_NOC_AXI_0 [get_bd_intf_pins cips/PMC_NOC_AXI_0] [get_bd_intf_pins axi_noc_0/S04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_S00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_ethernet_0/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_ethernet_1/s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_dma_1/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins axi_noc_0/S06_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins axi_noc_0/S07_AXI]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_dma_0/axi_resetn]
  connect_bd_net -net Net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_dma_1/axi_resetn]
  connect_bd_net -net Net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_ethernet_1/s_axi_lite_resetn]
  connect_bd_net -net Net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn]
  connect_bd_net -net axi_dma_0_mm2s_cntrl_reset_out_n [get_bd_pins axi_dma_0/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins cips/pl_ps_irq2]
  connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins cips/pl_ps_irq3]
  connect_bd_net -net axi_dma_0_s2mm_prmry_reset_out_n [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
  connect_bd_net -net axi_dma_0_s2mm_sts_reset_out_n [get_bd_pins axi_dma_0/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
  connect_bd_net -net axi_dma_1_mm2s_cntrl_reset_out_n [get_bd_pins axi_dma_1/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txc_arstn]
  connect_bd_net -net axi_dma_1_mm2s_introut [get_bd_pins axi_dma_1/mm2s_introut] [get_bd_pins cips/pl_ps_irq9]
  connect_bd_net -net axi_dma_1_mm2s_prmry_reset_out_n [get_bd_pins axi_dma_1/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_txd_arstn]
  connect_bd_net -net axi_dma_1_s2mm_introut [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins cips/pl_ps_irq10]
  connect_bd_net -net axi_dma_1_s2mm_prmry_reset_out_n [get_bd_pins axi_dma_1/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxd_arstn]
  connect_bd_net -net axi_dma_1_s2mm_sts_reset_out_n [get_bd_pins axi_dma_1/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_1/axi_rxs_arstn]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins cips/pl_ps_irq1]
  connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins cips/pl_ps_irq0]
  connect_bd_net -net axi_ethernet_0_phy_rst_n [get_bd_pins axi_ethernet_0/phy_rst_n] [get_bd_pins reset_phy_0]
  connect_bd_net -net axi_ethernet_1_interrupt [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins cips/pl_ps_irq8]
  connect_bd_net -net axi_ethernet_1_mac_irq [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins cips/pl_ps_irq4]
  connect_bd_net -net axi_ethernet_1_phy_rst_n [get_bd_pins axi_ethernet_1/phy_rst_n] [get_bd_pins reset_phy_1]
#  connect_bd_net -net cips_fpd_cci_noc_axi0_clk [get_bd_pins cips/fpd_cci_noc_axi0_clk] [get_bd_pins axi_noc_0/aclk0]
#  connect_bd_net -net cips_fpd_cci_noc_axi1_clk [get_bd_pins cips/fpd_cci_noc_axi1_clk] [get_bd_pins axi_noc_0/aclk1]
#  connect_bd_net -net cips_fpd_cci_noc_axi2_clk [get_bd_pins cips/fpd_cci_noc_axi2_clk] [get_bd_pins axi_noc_0/aclk2]
#  connect_bd_net -net cips_fpd_cci_noc_axi3_clk [get_bd_pins cips/fpd_cci_noc_axi3_clk] [get_bd_pins axi_noc_0/aclk3]
#  connect_bd_net -net cips_lpd_axi_noc_clk [get_bd_pins cips/lpd_axi_noc_clk] [get_bd_pins axi_noc_0/aclk5]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_ethernet_0/axis_clk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_ethernet_1/s_axi_lite_clk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_ethernet_1/axis_clk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins smartconnect_0/aclk]
#  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins cips/m_axi_fpd_aclk]
#  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins cips/m_axi_lpd_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_noc_0/aclk6]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_0/s_axi_lite_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_0/m_axi_sg_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_1/s_axi_lite_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_1/m_axi_sg_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_1/m_axi_mm2s_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins smartconnect_1/aclk]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins smartconnect_2/aclk]
  connect_bd_net -net cips_pl0_resetn [get_bd_pins cips/pl0_resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in]
#  connect_bd_net -net cips_pmc_axi_noc_axi0_clk [get_bd_pins cips/pmc_axi_noc_axi0_clk] [get_bd_pins axi_noc_0/aclk4]
  connect_bd_net -net clk2_25MHz_1 [get_bd_pins clk2_25MHz] [get_bd_pins clk_wizard_1/clk_in1]
  connect_bd_net -net clk_25MHz_1 [get_bd_pins clk1_25MHz] [get_bd_pins clk_wizard_0/clk_in1]
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins axi_ethernet_0/gtx_clk]
  connect_bd_net -net clk_wizard_1_clk_out1 [get_bd_pins clk_wizard_1/clk_out1] [get_bd_pins axi_ethernet_1/gtx_clk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_2/aresetn]

  # Create address segments
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020100040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_0] [get_bd_addr_segs axi_noc_0/S00_AXI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020100040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_1] [get_bd_addr_segs axi_noc_0/S01_AXI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020100040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_2] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW1] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020100040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/FPD_CCI_NOC_3] [get_bd_addr_segs axi_noc_0/S03_AXI/C1_DDR_LOW1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/LPD_AXI_NOC_0] [get_bd_addr_segs axi_noc_0/S04_AXI/C3_DDR_LOW1] -force
  assign_bd_address -offset 0x020100080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020100000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] -force
  assign_bd_address -offset 0x020100040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_ethernet_1/s_axi/Reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x000800000000 -range 0x000180000000 -target_address_space [get_bd_addr_spaces cips/PMC_NOC_AXI_0] [get_bd_addr_segs axi_noc_0/S05_AXI/C2_DDR_LOW1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW0] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs axi_noc_0/S06_AXI/C0_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs axi_noc_0/S07_AXI/C1_DDR_LOW1]


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


