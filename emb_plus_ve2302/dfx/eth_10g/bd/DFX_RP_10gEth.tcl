# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a generated script based on design: DFX_RP_10gEth
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
# source DFX_RP_10gEth.tcl

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
set design_name DFX_RP_10gEth

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
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:clk_wizard:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:axi_mcdma:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:inline_hdl:ilslice:*\
user.org:user:mrmac_10g_mux:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:mrmac:*\
xilinx.com:ip:util_vector_logic:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:axi_apb_bridge:*\
xilinx.com:ip:gt_quad_base:*\
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:gt_tx_interface_rtl:1.0 TX0_GT_IP_Interface

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:gt_tx_interface_rtl:1.0 TX1_GT_IP_Interface

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:gt_rx_interface_rtl:1.0 RX0_GT_IP_Interface

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:gt_rx_interface_rtl:1.0 RX1_GT_IP_Interface

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN_D

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_LITE_APB


  # Create pins
  create_bd_pin -dir O gtpowergood
  create_bd_pin -dir I -from 7 -to 0 ch0_txrate
  create_bd_pin -dir I -type gt_usrclk ch0_txusrclk
  create_bd_pin -dir I -from 7 -to 0 ch1_txrate
  create_bd_pin -dir I -type gt_usrclk ch1_txusrclk
  create_bd_pin -dir I -from 7 -to 0 ch0_rxrate
  create_bd_pin -dir I -type gt_usrclk ch0_rxusrclk
  create_bd_pin -dir I -from 7 -to 0 ch1_rxrate
  create_bd_pin -dir I -type gt_usrclk ch1_rxusrclk
  create_bd_pin -dir I -from 2 -to 0 ch0_loopback
  create_bd_pin -dir I -from 2 -to 0 ch1_loopback
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLR_tx_ch0
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLRB_LEAF_tx_ch0
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk ch0_tx_usr_clk2
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLR_tx_ch1
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLRB_LEAF_tx_ch1
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk ch1_tx_usr_clk2
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLR_rx_ch0
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLRB_LEAF_rx_ch0
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk ch0_rx_usr_clk2
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLR_rx_ch1
  create_bd_pin -dir I -from 0 -to 0 MBUFG_GT_CLRB_LEAF_rx_ch1
  create_bd_pin -dir O -from 0 -to 0 -type gt_usrclk ch1_rx_usr_clk2
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir O -from 0 -to 0 ch1_tx_usr_clk
  create_bd_pin -dir O -from 0 -to 0 ch1_rx_usr_clk
  create_bd_pin -dir O -from 0 -to 0 ch0_tx_usr_clk
  create_bd_pin -dir O -from 0 -to 0 ch0_rx_usr_clk
  create_bd_pin -dir I ch0_txmstdatapathreset
  create_bd_pin -dir I ch0_txmstreset
  create_bd_pin -dir I ch1_txmstdatapathreset
  create_bd_pin -dir I ch1_txmstreset
  create_bd_pin -dir I ch0_txuserrdy
  create_bd_pin -dir O ch0_txmstresetdone
  create_bd_pin -dir O ch0_txpmaresetdone
  create_bd_pin -dir I ch1_txuserrdy
  create_bd_pin -dir O ch1_txpmaresetdone
  create_bd_pin -dir O ch1_txmstresetdone
  create_bd_pin -dir O ch0_rxpmaresetdone
  create_bd_pin -dir I ch0_rxuserrdy
  create_bd_pin -dir I ch0_rxmstreset
  create_bd_pin -dir I ch0_rxmstdatapathreset
  create_bd_pin -dir O ch0_rxmstresetdone
  create_bd_pin -dir O ch1_rxpmaresetdone
  create_bd_pin -dir I ch1_rxuserrdy
  create_bd_pin -dir I ch1_rxmstreset
  create_bd_pin -dir I ch1_rxmstdatapathreset
  create_bd_pin -dir O ch1_rxmstresetdone

  # Create instance: mbufg_gt_tx_clkout_ch0, and set properties
  set mbufg_gt_tx_clkout_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mbufg_gt_tx_clkout_ch0 ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {MBUFG_GT} \
  ] $mbufg_gt_tx_clkout_ch0


  # Create instance: mbufg_gt_tx_clkout_ch2, and set properties
  set mbufg_gt_tx_clkout_ch2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mbufg_gt_tx_clkout_ch2 ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {MBUFG_GT} \
  ] $mbufg_gt_tx_clkout_ch2


  # Create instance: mbufg_gt_rx_clkout_ch0, and set properties
  set mbufg_gt_rx_clkout_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mbufg_gt_rx_clkout_ch0 ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {MBUFG_GT} \
  ] $mbufg_gt_rx_clkout_ch0


  # Create instance: mbufg_gt_rx_clkout_ch1, and set properties
  set mbufg_gt_rx_clkout_ch1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf mbufg_gt_rx_clkout_ch1 ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {MBUFG_GT} \
  ] $mbufg_gt_rx_clkout_ch1


  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf_0


  # Create instance: xlconst_mbufg_0, and set properties
  set xlconst_mbufg_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconst_mbufg_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
    CONFIG.CONST_WIDTH {1} \
  ] $xlconst_mbufg_0


  # Create instance: axi_apb_bridge_0, and set properties
  set axi_apb_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge axi_apb_bridge_0 ]
  set_property CONFIG.C_APB_NUM_SLAVES {1} $axi_apb_bridge_0


  # Create instance: xlconstant_tx_usr_clk, and set properties
  set xlconstant_tx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_tx_usr_clk ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_tx_usr_clk


  # Create instance: xlconstant_rx_usr_clk, and set properties
  set xlconstant_rx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_rx_usr_clk ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_rx_usr_clk


  # Create instance: gt_quad_base, and set properties
  set gt_quad_base [ create_bd_cell -type ip -vlnv xilinx.com:ip:gt_quad_base gt_quad_base ]
  set_property -dict [list \
    CONFIG.APB3_CLK_FREQUENCY {99.999901} \
    CONFIG.CHANNEL_ORDERING {/MRMAC_GT/GT/gt_quad_base/TX0_GT_IP_Interface dynamic_design_mrmac_10g_156_core_0_0./MRMAC_GT/mrmac_10g_156_core/gt_tx_serdes_interface_0.0 /MRMAC_GT/GT/gt_quad_base/TX1_GT_IP_Interface\
dynamic_design_mrmac_10g_156_core_0_1./MRMAC_GT/mrmac_10g_156_core/gt_tx_serdes_interface_1.1 /MRMAC_GT/GT/gt_quad_base/RX0_GT_IP_Interface dynamic_design_mrmac_10g_156_core_0_0./MRMAC_GT/mrmac_10g_156_core/gt_rx_serdes_interface_0.0\
/MRMAC_GT/GT/gt_quad_base/RX1_GT_IP_Interface dynamic_design_mrmac_10g_156_core_0_1./MRMAC_GT/mrmac_10g_156_core/gt_rx_serdes_interface_1.1} \
    CONFIG.GT_TYPE {GTYP} \
    CONFIG.PORTS_INFO_DICT {LANE_SEL_DICT {PROT0 {RX0 TX0} PROT1 {RX1 TX1} unconnected {RX2 RX3 TX2 TX3}} GT_TYPE GTYP REG_CONF_INTF APB3_INTF BOARD_PARAMETER { }} \
    CONFIG.PROT0_ENABLE {true} \
    CONFIG.PROT0_GT_DIRECTION {DUPLEX} \
    CONFIG.PROT0_LR0_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 10.3125 TX_PLL_TYPE\
RPLL TX_REFCLK_FREQUENCY 156.25 TX_ACTUAL_REFCLK_FREQUENCY 156.250000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 32\
TX_INT_DATA_WIDTH 32 TX_BUFFER_MODE 1 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 644.531\
TX_DIFF_SWING_EMPH_MODE CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE PRESET None RX_PAM_SEL\
NRZ RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None RX_LINE_RATE 10.3125 RX_PLL_TYPE RPLL RX_REFCLK_FREQUENCY 156.25 RX_ACTUAL_REFCLK_FREQUENCY\
156.250000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH 32 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE RXPROGDIVCLK\
RXPROGDIV_FREQ_ENABLE true RXPROGDIV_FREQ_SOURCE RPLL RXPROGDIV_FREQ_VAL 644.531 RXRECCLK_FREQ_ENABLE true RXRECCLK_FREQ_VAL 644.531 INS_LOSS_NYQ 20 RX_EQ_MODE AUTO RX_COUPLING AC RX_TERMINATION PROGRAMMABLE\
RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 200 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE false RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE false RX_COMMA_P_ENABLE false RX_COMMA_M_ENABLE false RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 0101111100 RX_COMMA_M_VAL 1010000011 RX_COMMA_MASK 0000000000 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 0 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE DISABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL\
00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CC_K 00000000 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00000000 RX_CC_K_0_0 false RX_CC_DISP_0_0 false\
RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3\
00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0 00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1\
false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2 false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 250 PCIE_USERCLK_FREQ\
250 RX_JTOL_FC 6.1862627 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE\
ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET NONE RX_COMMA_VALID_ONLY 0 GT_TYPE GTYP} \
    CONFIG.PROT0_LR10_SETTINGS {NA NA} \
    CONFIG.PROT0_LR11_SETTINGS {NA NA} \
    CONFIG.PROT0_LR12_SETTINGS {NA NA} \
    CONFIG.PROT0_LR13_SETTINGS {NA NA} \
    CONFIG.PROT0_LR14_SETTINGS {NA NA} \
    CONFIG.PROT0_LR15_SETTINGS {NA NA} \
    CONFIG.PROT0_LR1_SETTINGS {NA NA} \
    CONFIG.PROT0_LR2_SETTINGS {NA NA} \
    CONFIG.PROT0_LR3_SETTINGS {NA NA} \
    CONFIG.PROT0_LR4_SETTINGS {NA NA} \
    CONFIG.PROT0_LR5_SETTINGS {NA NA} \
    CONFIG.PROT0_LR6_SETTINGS {NA NA} \
    CONFIG.PROT0_LR7_SETTINGS {NA NA} \
    CONFIG.PROT0_LR8_SETTINGS {NA NA} \
    CONFIG.PROT0_LR9_SETTINGS {NA NA} \
    CONFIG.PROT0_NO_OF_LANES {1} \
    CONFIG.PROT0_RX_MASTERCLK_SRC {RX0} \
    CONFIG.PROT0_TX_MASTERCLK_SRC {TX0} \
    CONFIG.PROT1_ENABLE {true} \
    CONFIG.PROT1_GT_DIRECTION {DUPLEX} \
    CONFIG.PROT1_LR0_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 10.3125 TX_PLL_TYPE\
RPLL TX_REFCLK_FREQUENCY 156.25 TX_ACTUAL_REFCLK_FREQUENCY 156.250000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 32\
TX_INT_DATA_WIDTH 32 TX_BUFFER_MODE 1 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 644.531\
TX_DIFF_SWING_EMPH_MODE CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE PRESET None RX_PAM_SEL\
NRZ RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None RX_LINE_RATE 10.3125 RX_PLL_TYPE RPLL RX_REFCLK_FREQUENCY 156.25 RX_ACTUAL_REFCLK_FREQUENCY\
156.250000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH 32 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE RXPROGDIVCLK\
RXPROGDIV_FREQ_ENABLE true RXPROGDIV_FREQ_SOURCE RPLL RXPROGDIV_FREQ_VAL 644.531 RXRECCLK_FREQ_ENABLE true RXRECCLK_FREQ_VAL 644.531 INS_LOSS_NYQ 20 RX_EQ_MODE AUTO RX_COUPLING AC RX_TERMINATION PROGRAMMABLE\
RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 200 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE false RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE false RX_COMMA_P_ENABLE false RX_COMMA_M_ENABLE false RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 0101111100 RX_COMMA_M_VAL 1010000011 RX_COMMA_MASK 0000000000 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 0 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE DISABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL\
00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CC_K 00000000 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00000000 RX_CC_K_0_0 false RX_CC_DISP_0_0 false\
RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3\
00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0 00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1\
false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2 false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 250 PCIE_USERCLK_FREQ\
250 RX_JTOL_FC 6.1862627 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE\
ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET NONE RX_COMMA_VALID_ONLY 0 GT_TYPE GTYP} \
    CONFIG.PROT1_LR10_SETTINGS {NA NA} \
    CONFIG.PROT1_LR11_SETTINGS {NA NA} \
    CONFIG.PROT1_LR12_SETTINGS {NA NA} \
    CONFIG.PROT1_LR13_SETTINGS {NA NA} \
    CONFIG.PROT1_LR14_SETTINGS {NA NA} \
    CONFIG.PROT1_LR15_SETTINGS {NA NA} \
    CONFIG.PROT1_LR1_SETTINGS {NA NA} \
    CONFIG.PROT1_LR2_SETTINGS {NA NA} \
    CONFIG.PROT1_LR3_SETTINGS {NA NA} \
    CONFIG.PROT1_LR4_SETTINGS {NA NA} \
    CONFIG.PROT1_LR5_SETTINGS {NA NA} \
    CONFIG.PROT1_LR6_SETTINGS {NA NA} \
    CONFIG.PROT1_LR7_SETTINGS {NA NA} \
    CONFIG.PROT1_LR8_SETTINGS {NA NA} \
    CONFIG.PROT1_LR9_SETTINGS {NA NA} \
    CONFIG.PROT1_NO_OF_LANES {1} \
    CONFIG.PROT1_RX_MASTERCLK_SRC {RX1} \
    CONFIG.PROT1_TX_MASTERCLK_SRC {TX1} \
    CONFIG.QUAD_USAGE {TX_QUAD_CH {TXQuad_0_/MRMAC_GT/GT/gt_quad_base {/MRMAC_GT/GT/gt_quad_base dynamic_design_mrmac_10g_156_core_0_0.IP_CH0,dynamic_design_mrmac_10g_156_core_0_1.IP_CH1,undef,undef MSTRCLK\
1,1,0,0 IS_CURRENT_QUAD 1}} RX_QUAD_CH {RXQuad_0_/MRMAC_GT/GT/gt_quad_base {/MRMAC_GT/GT/gt_quad_base dynamic_design_mrmac_10g_156_core_0_0.IP_CH0,dynamic_design_mrmac_10g_156_core_0_1.IP_CH1,undef,undef\
MSTRCLK 1,1,0,0 IS_CURRENT_QUAD 1}}} \
    CONFIG.REFCLK_LIST {{/CLK_IN_D_clk_p[0]}} \
    CONFIG.REFCLK_STRING {HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_PROT1_R0_156.25_MHz_unique1} \
    CONFIG.RX0_LANE_SEL {PROT0} \
    CONFIG.RX1_LANE_SEL {PROT1} \
    CONFIG.RX2_LANE_SEL {unconnected} \
    CONFIG.RX3_LANE_SEL {unconnected} \
    CONFIG.TX0_LANE_SEL {PROT0} \
    CONFIG.TX1_LANE_SEL {PROT1} \
    CONFIG.TX2_LANE_SEL {unconnected} \
    CONFIG.TX3_LANE_SEL {unconnected} \
  ] $gt_quad_base

  set_property -dict [list \
    CONFIG.APB3_CLK_FREQUENCY.VALUE_MODE {auto} \
    CONFIG.CHANNEL_ORDERING.VALUE_MODE {auto} \
    CONFIG.GT_TYPE.VALUE_MODE {auto} \
    CONFIG.PROT0_ENABLE.VALUE_MODE {auto} \
    CONFIG.PROT0_GT_DIRECTION.VALUE_MODE {auto} \
    CONFIG.PROT0_LR0_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR10_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR11_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR12_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR13_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR14_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR15_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR1_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR2_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR3_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR4_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR5_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR6_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR7_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR8_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR9_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_NO_OF_LANES.VALUE_MODE {auto} \
    CONFIG.PROT0_RX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.PROT0_TX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.PROT1_ENABLE.VALUE_MODE {auto} \
    CONFIG.PROT1_GT_DIRECTION.VALUE_MODE {auto} \
    CONFIG.PROT1_LR0_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR10_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR11_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR12_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR13_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR14_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR15_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR1_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR2_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR3_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR4_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR5_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR6_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR7_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR8_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_LR9_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT1_NO_OF_LANES.VALUE_MODE {auto} \
    CONFIG.PROT1_RX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.PROT1_TX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.QUAD_USAGE.VALUE_MODE {auto} \
    CONFIG.REFCLK_LIST.VALUE_MODE {auto} \
    CONFIG.RX0_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX1_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX2_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX3_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX0_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX1_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX2_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX3_LANE_SEL.VALUE_MODE {auto} \
  ] $gt_quad_base


  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_1 [get_bd_intf_pins CLK_IN_D] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_apb_bridge_0/AXI4_LITE] [get_bd_intf_pins AXI4_LITE_APB]
  connect_bd_intf_net -intf_net RX0_GT_IP_Interface_1 [get_bd_intf_pins RX0_GT_IP_Interface] [get_bd_intf_pins gt_quad_base/RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net RX1_GT_IP_Interface_1 [get_bd_intf_pins RX1_GT_IP_Interface] [get_bd_intf_pins gt_quad_base/RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net TX0_GT_IP_Interface_1 [get_bd_intf_pins TX0_GT_IP_Interface] [get_bd_intf_pins gt_quad_base/TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net TX1_GT_IP_Interface_1 [get_bd_intf_pins TX1_GT_IP_Interface] [get_bd_intf_pins gt_quad_base/TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net axi_apb_bridge_0_APB_M [get_bd_intf_pins gt_quad_base/APB3_INTF] [get_bd_intf_pins axi_apb_bridge_0/APB_M]
  connect_bd_intf_net -intf_net gt_quad_base1_GT_Serial [get_bd_intf_pins GT_Serial] [get_bd_intf_pins gt_quad_base/GT_Serial]

  # Create port connections
  connect_bd_net -net ch0_loopback_1  [get_bd_pins ch0_loopback] \
  [get_bd_pins gt_quad_base/ch0_loopback]
  connect_bd_net -net ch0_rxmstdatapathreset_1  [get_bd_pins ch0_rxmstdatapathreset] \
  [get_bd_pins gt_quad_base/ch0_rxmstdatapathreset]
  connect_bd_net -net ch0_rxmstreset_1  [get_bd_pins ch0_rxmstreset] \
  [get_bd_pins gt_quad_base/ch0_rxmstreset]
  connect_bd_net -net ch0_rxrate_1  [get_bd_pins ch0_rxrate] \
  [get_bd_pins gt_quad_base/ch0_rxrate]
  connect_bd_net -net ch0_rxuserrdy_1  [get_bd_pins ch0_rxuserrdy] \
  [get_bd_pins gt_quad_base/ch0_rxuserrdy]
  connect_bd_net -net ch0_rxusrclk_1  [get_bd_pins ch0_rxusrclk] \
  [get_bd_pins gt_quad_base/ch0_rxusrclk]
  connect_bd_net -net ch0_txmstdatapathreset_1  [get_bd_pins ch0_txmstdatapathreset] \
  [get_bd_pins gt_quad_base/ch0_txmstdatapathreset]
  connect_bd_net -net ch0_txmstreset_1  [get_bd_pins ch0_txmstreset] \
  [get_bd_pins gt_quad_base/ch0_txmstreset]
  connect_bd_net -net ch0_txrate_1  [get_bd_pins ch0_txrate] \
  [get_bd_pins gt_quad_base/ch0_txrate]
  connect_bd_net -net ch0_txuserrdy_1  [get_bd_pins ch0_txuserrdy] \
  [get_bd_pins gt_quad_base/ch0_txuserrdy]
  connect_bd_net -net ch0_txusrclk_1  [get_bd_pins ch0_txusrclk] \
  [get_bd_pins gt_quad_base/ch0_txusrclk]
  connect_bd_net -net ch1_loopback_1  [get_bd_pins ch1_loopback] \
  [get_bd_pins gt_quad_base/ch1_loopback]
  connect_bd_net -net ch1_rxmstdatapathreset_1  [get_bd_pins ch1_rxmstdatapathreset] \
  [get_bd_pins gt_quad_base/ch1_rxmstdatapathreset]
  connect_bd_net -net ch1_rxmstreset_1  [get_bd_pins ch1_rxmstreset] \
  [get_bd_pins gt_quad_base/ch1_rxmstreset]
  connect_bd_net -net ch1_rxrate_1  [get_bd_pins ch1_rxrate] \
  [get_bd_pins gt_quad_base/ch1_rxrate]
  connect_bd_net -net ch1_rxuserrdy_1  [get_bd_pins ch1_rxuserrdy] \
  [get_bd_pins gt_quad_base/ch1_rxuserrdy]
  connect_bd_net -net ch1_rxusrclk_1  [get_bd_pins ch1_rxusrclk] \
  [get_bd_pins gt_quad_base/ch1_rxusrclk]
  connect_bd_net -net ch1_txmstdatapathreset_1  [get_bd_pins ch1_txmstdatapathreset] \
  [get_bd_pins gt_quad_base/ch1_txmstdatapathreset]
  connect_bd_net -net ch1_txmstreset_1  [get_bd_pins ch1_txmstreset] \
  [get_bd_pins gt_quad_base/ch1_txmstreset]
  connect_bd_net -net ch1_txrate_1  [get_bd_pins ch1_txrate] \
  [get_bd_pins gt_quad_base/ch1_txrate]
  connect_bd_net -net ch1_txuserrdy_1  [get_bd_pins ch1_txuserrdy] \
  [get_bd_pins gt_quad_base/ch1_txuserrdy]
  connect_bd_net -net ch1_txusrclk_1  [get_bd_pins ch1_txusrclk] \
  [get_bd_pins gt_quad_base/ch1_txusrclk]
  connect_bd_net -net gt_quad_base1_ch0_rxoutclk  [get_bd_pins gt_quad_base/ch0_rxoutclk] \
  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_I]
  connect_bd_net -net gt_quad_base1_ch0_txoutclk  [get_bd_pins gt_quad_base/ch0_txoutclk] \
  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_I]
  connect_bd_net -net gt_quad_base1_ch1_rxoutclk  [get_bd_pins gt_quad_base/ch1_rxoutclk] \
  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_I]
  connect_bd_net -net gt_quad_base1_ch1_txoutclk  [get_bd_pins gt_quad_base/ch1_txoutclk] \
  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_I]
  connect_bd_net -net gt_quad_base1_gtpowergood  [get_bd_pins gt_quad_base/gtpowergood] \
  [get_bd_pins gtpowergood]
  connect_bd_net -net gt_quad_base_ch0_rxmstresetdone  [get_bd_pins gt_quad_base/ch0_rxmstresetdone] \
  [get_bd_pins ch0_rxmstresetdone]
  connect_bd_net -net gt_quad_base_ch0_rxpmaresetdone  [get_bd_pins gt_quad_base/ch0_rxpmaresetdone] \
  [get_bd_pins ch0_rxpmaresetdone]
  connect_bd_net -net gt_quad_base_ch0_txmstresetdone  [get_bd_pins gt_quad_base/ch0_txmstresetdone] \
  [get_bd_pins ch0_txmstresetdone]
  connect_bd_net -net gt_quad_base_ch0_txpmaresetdone  [get_bd_pins gt_quad_base/ch0_txpmaresetdone] \
  [get_bd_pins ch0_txpmaresetdone]
  connect_bd_net -net gt_quad_base_ch1_rxmstresetdone  [get_bd_pins gt_quad_base/ch1_rxmstresetdone] \
  [get_bd_pins ch1_rxmstresetdone]
  connect_bd_net -net gt_quad_base_ch1_rxpmaresetdone  [get_bd_pins gt_quad_base/ch1_rxpmaresetdone] \
  [get_bd_pins ch1_rxpmaresetdone]
  connect_bd_net -net gt_quad_base_ch1_txmstresetdone  [get_bd_pins gt_quad_base/ch1_txmstresetdone] \
  [get_bd_pins ch1_txmstresetdone]
  connect_bd_net -net gt_quad_base_ch1_txpmaresetdone  [get_bd_pins gt_quad_base/ch1_txpmaresetdone] \
  [get_bd_pins ch1_txpmaresetdone]
  connect_bd_net -net mbufg_gt_rx_clkout_ch0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_O1] \
  [get_bd_pins ch0_rx_usr_clk]
  connect_bd_net -net mbufg_gt_rx_clkout_ch0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_O2] \
  [get_bd_pins ch0_rx_usr_clk2]
  connect_bd_net -net mbufg_gt_rx_clkout_ch1_MBUFG_GT_O1  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_O1] \
  [get_bd_pins ch1_rx_usr_clk]
  connect_bd_net -net mbufg_gt_rx_clkout_ch1_MBUFG_GT_O2  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_O2] \
  [get_bd_pins ch1_rx_usr_clk2]
  connect_bd_net -net mbufg_gt_tx_clkout_ch0_MBUFG_GT_O1  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_O1] \
  [get_bd_pins ch0_tx_usr_clk]
  connect_bd_net -net mbufg_gt_tx_clkout_ch0_MBUFG_GT_O2  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_O2] \
  [get_bd_pins ch0_tx_usr_clk2]
  connect_bd_net -net mbufg_gt_tx_clkout_ch2_MBUFG_GT_O1  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_O1] \
  [get_bd_pins ch1_tx_usr_clk]
  connect_bd_net -net mbufg_gt_tx_clkout_ch2_MBUFG_GT_O2  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_O2] \
  [get_bd_pins ch1_tx_usr_clk2]
  connect_bd_net -net mrmac_10g_156_core_rx_clr_out_0  [get_bd_pins MBUFG_GT_CLR_rx_ch0] \
  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_CLR]
  connect_bd_net -net mrmac_10g_156_core_rx_clr_out_1  [get_bd_pins MBUFG_GT_CLR_rx_ch1] \
  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_CLR]
  connect_bd_net -net mrmac_10g_156_core_rx_clrb_leaf_out_0  [get_bd_pins MBUFG_GT_CLRB_LEAF_rx_ch0] \
  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net mrmac_10g_156_core_rx_clrb_leaf_out_1  [get_bd_pins MBUFG_GT_CLRB_LEAF_rx_ch1] \
  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net mrmac_10g_156_core_tx_clr_out_0  [get_bd_pins MBUFG_GT_CLR_tx_ch0] \
  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_CLR]
  connect_bd_net -net mrmac_10g_156_core_tx_clr_out_1  [get_bd_pins MBUFG_GT_CLR_tx_ch1] \
  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_CLR]
  connect_bd_net -net mrmac_10g_156_core_tx_clrb_leaf_out_0  [get_bd_pins MBUFG_GT_CLRB_LEAF_tx_ch0] \
  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net mrmac_10g_156_core_tx_clrb_leaf_out_1  [get_bd_pins MBUFG_GT_CLRB_LEAF_tx_ch1] \
  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_CLRB_LEAF]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_apb_bridge_0/s_axi_aclk] \
  [get_bd_pins gt_quad_base/apb3clk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_apb_bridge_0/s_axi_aresetn] \
  [get_bd_pins gt_quad_base/apb3presetn]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT  [get_bd_pins util_ds_buf_0/IBUF_OUT] \
  [get_bd_pins gt_quad_base/GT_REFCLK0]
  connect_bd_net -net xlconst_mbufg_0_dout  [get_bd_pins xlconst_mbufg_0/dout] \
  [get_bd_pins mbufg_gt_tx_clkout_ch0/MBUFG_GT_CE] \
  [get_bd_pins mbufg_gt_tx_clkout_ch2/MBUFG_GT_CE] \
  [get_bd_pins mbufg_gt_rx_clkout_ch0/MBUFG_GT_CE] \
  [get_bd_pins mbufg_gt_rx_clkout_ch1/MBUFG_GT_CE]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_tx_usr_clk/dout] \
  [get_bd_pins gt_quad_base/ch2_txusrclk] \
  [get_bd_pins gt_quad_base/ch3_txusrclk]
  connect_bd_net -net xlconstant_2_dout  [get_bd_pins xlconstant_rx_usr_clk/dout] \
  [get_bd_pins gt_quad_base/ch2_rxusrclk] \
  [get_bd_pins gt_quad_base/ch3_rxusrclk]

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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_GPIO_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_MRMAC

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_GPIO_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN_D

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI4_LITE_APB

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_GPIO_2


  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I tx_axis_tlast_0
  create_bd_pin -dir I -from 63 -to 0 tx_axis_tdata0
  create_bd_pin -dir O tx_axis_tready_0
  create_bd_pin -dir I tx_axis_tvalid_0
  create_bd_pin -dir I -from 0 -to 3 -type rst rx_flexif_reset
  create_bd_pin -dir I -from 10 -to 0 tx_axis_tkeep_user0
  create_bd_pin -dir O -from 10 -to 0 rx_axis_tkeep_user0
  create_bd_pin -dir O rx_axis_tlast_0
  create_bd_pin -dir O rx_axis_tvalid_0
  create_bd_pin -dir O -from 63 -to 0 rx_axis_tdata0
  create_bd_pin -dir I -from 3 -to 0 -type clk tx_axi_clk
  create_bd_pin -dir O rx_axis_tvalid_1
  create_bd_pin -dir O rx_axis_tlast_1
  create_bd_pin -dir O -from 63 -to 0 rx_axis_tdata2
  create_bd_pin -dir O tx_axis_tready_1
  create_bd_pin -dir O -from 10 -to 0 rx_axis_tkeep_user2
  create_bd_pin -dir I -from 63 -to 0 tx_axis_tdata2
  create_bd_pin -dir I tx_axis_tvalid_1
  create_bd_pin -dir I tx_axis_tlast_1
  create_bd_pin -dir I -from 10 -to 0 tx_axis_tkeep_user2
  create_bd_pin -dir I -from 3 -to 0 -type clk rx_ts_clk

  # Create instance: axi_gpio_gt_rate_reset_ctl0, and set properties
  set axi_gpio_gt_rate_reset_ctl0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_gt_rate_reset_ctl0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_gt_rate_reset_ctl0


  # Create instance: mrmac_10g_156_core, and set properties
  set mrmac_10g_156_core [ create_bd_cell -type ip -vlnv xilinx.com:ip:mrmac mrmac_10g_156_core ]
  set_property -dict [list \
    CONFIG.FAST_SIM_MODE {0} \
    CONFIG.FEC_SLICE0_CFG_C0 {FEC Disabled (Bypass)} \
    CONFIG.FEC_SLICE1_CFG_C0 {FEC Disabled (Bypass)} \
    CONFIG.FEC_SLICE2_CFG_C0 {FEC Disabled (Bypass)} \
    CONFIG.FEC_SLICE3_CFG_C0 {FEC Disabled (Bypass)} \
    CONFIG.GT_PIPELINE_STAGES {0} \
    CONFIG.GT_REF_CLK_FREQ_C0 {156.25} \
    CONFIG.GT_TYPE_C0 {GTYP} \
    CONFIG.MAC_PORT0_ENABLE_TIME_STAMPING_C0 {0} \
    CONFIG.MAC_PORT0_PREEMPTION_C0 {0} \
    CONFIG.MAC_PORT0_RATE_C0 {10GE} \
    CONFIG.MAC_PORT0_RX_FLOW_C0 {0} \
    CONFIG.MAC_PORT0_TX_FLOW_C0 {0} \
    CONFIG.MAC_PORT1_ENABLE_TIME_STAMPING_C0 {0} \
    CONFIG.MAC_PORT1_PREEMPTION_C0 {0} \
    CONFIG.MAC_PORT1_RATE_C0 {10GE} \
    CONFIG.MAC_PORT1_RX_FLOW_C0 {0} \
    CONFIG.MAC_PORT1_TX_FLOW_C0 {0} \
    CONFIG.MAC_PORT2_RATE_C0 {N/U} \
    CONFIG.MAC_PORT3_RATE_C0 {N/U} \
    CONFIG.MRMAC_CONFIGURATION_TYPE {Static Configuration} \
    CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT0_C0 {Independent 32b  Non-Segmented} \
    CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT1_C0 {Independent 32b  Non-Segmented} \
    CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT2_C0 {N/U} \
    CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT3_C0 {N/U} \
    CONFIG.MRMAC_LOCATION_C0 {MRMAC_X0Y0} \
    CONFIG.MRMAC_MODE_C0 {MAC+PCS} \
    CONFIG.MRMAC_PRESET_C0 {Start from scratch} \
    CONFIG.MRMAC_SPEED_C0 {Mixed/Custom} \
    CONFIG.NUM_GT_CHANNELS {2} \
    CONFIG.PORT0_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
    CONFIG.PORT0_1588v2_Operation_MODE_C0 {No operation} \
    CONFIG.PORT1_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
    CONFIG.PORT1_1588v2_Operation_MODE_C0 {No operation} \
    CONFIG.PORT2_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
    CONFIG.PORT2_1588v2_Operation_MODE_C0 {No operation} \
    CONFIG.PORT3_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
    CONFIG.PORT3_1588v2_Operation_MODE_C0 {No operation} \
    CONFIG.TIMESTAMP_CLK_PERIOD_NS {4.0000} \
    CONFIG.MRMAC_IS_GT_WIZ_OLD {1} \
  ] $mrmac_10g_156_core


  # Create instance: axi_gpio_reset_mask, and set properties
  set axi_gpio_reset_mask [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_reset_mask ]
  set_property -dict [list \
	  CONFIG.C_ALL_INPUTS {0} \
	  CONFIG.C_ALL_INPUTS_2 {1} \
	  CONFIG.C_ALL_OUTPUTS {0} \
	  CONFIG.C_GPIO2_WIDTH {8} \
	  CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_reset_mask


  # Create instance: axi_gpio_gt_rate_reset_ctl1, and set properties
  set axi_gpio_gt_rate_reset_ctl1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_gt_rate_reset_ctl1 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_gt_rate_reset_ctl1


  # Create instance: xlconcat_gt_reset_rx_datapath, and set properties
  set xlconcat_gt_reset_rx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_gt_reset_rx_datapath ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_gt_reset_rx_datapath


  # Create instance: xlconcat_gt_reset_tx_datapath, and set properties
  set xlconcat_gt_reset_tx_datapath [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_gt_reset_tx_datapath ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_gt_reset_tx_datapath


  # Create instance: xlslice_gt_rest_tx_datapath_1, and set properties
  set xlslice_gt_rest_tx_datapath_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_rest_tx_datapath_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {3} \
  ] $xlslice_gt_rest_tx_datapath_1


  # Create instance: xlslice_gt_rest_all_1, and set properties
  set xlslice_gt_rest_all_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_rest_all_1 ]
  set_property CONFIG.DIN_WIDTH {3} $xlslice_gt_rest_all_1


  # Create instance: xlconcat_gt_reset_all, and set properties
  set xlconcat_gt_reset_all [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_gt_reset_all ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_gt_reset_all


  # Create instance: xlslice_gt_reset_tx_datapath_0, and set properties
  set xlslice_gt_reset_tx_datapath_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_tx_datapath_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {3} \
  ] $xlslice_gt_reset_tx_datapath_0


  # Create instance: xlslice_gt_reset_rx_datapath_0, and set properties
  set xlslice_gt_reset_rx_datapath_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_rx_datapath_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {3} \
  ] $xlslice_gt_reset_rx_datapath_0


  # Create instance: xlslice_gt_reset_all_0, and set properties
  set xlslice_gt_reset_all_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_all_0 ]
  set_property CONFIG.DIN_WIDTH {3} $xlslice_gt_reset_all_0


  # Create instance: xlslice_gt_reset_rx_datapath_1, and set properties
  set xlslice_gt_reset_rx_datapath_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_reset_rx_datapath_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {3} \
  ] $xlslice_gt_reset_rx_datapath_1


  # Create instance: GT
  create_hier_cell_GT $hier_obj GT

  # Create instance: concat_tx_usr_clk, and set properties
  set concat_tx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat concat_tx_usr_clk ]
  set_property CONFIG.NUM_PORTS {4} $concat_tx_usr_clk


  # Create instance: concat_rx_usr_clk, and set properties
  set concat_rx_usr_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat concat_rx_usr_clk ]
  set_property CONFIG.NUM_PORTS {4} $concat_rx_usr_clk


  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {4} \
  ] $util_vector_logic_0


  # Create instance: xlconcat_rst_done, and set properties
  set xlconcat_rst_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_rst_done ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {4} \
    CONFIG.IN1_WIDTH {4} \
  ] $xlconcat_rst_done


  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic util_vector_logic_1 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {4} \
  ] $util_vector_logic_1


  # Create instance: xlslice_gt_rate_tx_rx_ch0, and set properties
  set xlslice_gt_rate_tx_rx_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_rate_tx_rx_ch0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DOUT_WIDTH {8} \
  ] $xlslice_gt_rate_tx_rx_ch0


  # Create instance: xlslice_gt_rate_tx_rx_ch1, and set properties
  set xlslice_gt_rate_tx_rx_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_gt_rate_tx_rx_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DOUT_WIDTH {8} \
  ] $xlslice_gt_rate_tx_rx_ch1


  # Create instance: mrmac_constant_drive_zero_0, and set properties
  set mrmac_constant_drive_zero_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_constant_drive_zero_0 ]
  set_property CONFIG.CONST_VAL {0} $mrmac_constant_drive_zero_0


  # Create instance: mrmac_contant_drive_zero_8bit, and set properties
  set mrmac_contant_drive_zero_8bit [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_contant_drive_zero_8bit ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {8} \
  ] $mrmac_contant_drive_zero_8bit


  # Create instance: mrmac_tx_preample_value, and set properties
  set mrmac_tx_preample_value [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_tx_preample_value ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0x555555555555d5} \
    CONFIG.CONST_WIDTH {56} \
  ] $mrmac_tx_preample_value


  # Create instance: mrmac_pm_tick_drive_zero, and set properties
  set mrmac_pm_tick_drive_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_pm_tick_drive_zero ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $mrmac_pm_tick_drive_zero


  # Create instance: xlconstant_rx_reset_done, and set properties
  set xlconstant_rx_reset_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_rx_reset_done ]
  set_property CONFIG.CONST_VAL {1} $xlconstant_rx_reset_done


  # Create instance: concat_rx_usr_clk_div2, and set properties
  set concat_rx_usr_clk_div2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat concat_rx_usr_clk_div2 ]
  set_property CONFIG.NUM_PORTS {4} $concat_rx_usr_clk_div2


  # Create instance: xlconstant_tx_rx_usr_clk_zero, and set properties
  set xlconstant_tx_rx_usr_clk_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_tx_rx_usr_clk_zero ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_tx_rx_usr_clk_zero


  # Create instance: concat_tx_usr_clk_div2, and set properties
  set concat_tx_usr_clk_div2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat concat_tx_usr_clk_div2 ]
  set_property CONFIG.NUM_PORTS {4} $concat_tx_usr_clk_div2


  # Create instance: mrmac_constant_drive_zero_1, and set properties
  set mrmac_constant_drive_zero_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_constant_drive_zero_1 ]
  set_property CONFIG.CONST_VAL {0} $mrmac_constant_drive_zero_1


  # Create instance: mrmac_constant_drive_zero_66bit, and set properties
  set mrmac_constant_drive_zero_66bit [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant mrmac_constant_drive_zero_66bit ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {66} \
  ] $mrmac_constant_drive_zero_66bit


  # Create instance: xlconcat_tx_usr_rdy, and set properties
  set xlconcat_tx_usr_rdy [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_tx_usr_rdy ]
  set_property CONFIG.NUM_PORTS {2} $xlconcat_tx_usr_rdy


  # Create instance: xlconcat_mst_tx_dp_rst, and set properties
  set xlconcat_mst_tx_dp_rst [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_mst_tx_dp_rst ]
  set_property CONFIG.NUM_PORTS {2} $xlconcat_mst_tx_dp_rst


  # Create instance: tx_usr_rdy_ch0, and set properties
  set tx_usr_rdy_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice tx_usr_rdy_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $tx_usr_rdy_ch0


  # Create instance: tx_usr_rdy_ch1, and set properties
  set tx_usr_rdy_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice tx_usr_rdy_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $tx_usr_rdy_ch1


  # Create instance: tx_mst_dp_rst_ch0, and set properties
  set tx_mst_dp_rst_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice tx_mst_dp_rst_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $tx_mst_dp_rst_ch0


  # Create instance: tx_mst_dp_rst_ch1, and set properties
  set tx_mst_dp_rst_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice tx_mst_dp_rst_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $tx_mst_dp_rst_ch1


  # Create instance: xlconcat_tx_mst_rst, and set properties
  set xlconcat_tx_mst_rst [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_tx_mst_rst ]

  # Create instance: xlslice_tx_mst_rst_ch0, and set properties
  set xlslice_tx_mst_rst_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_tx_mst_rst_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $xlslice_tx_mst_rst_ch0


  # Create instance: xlslice_tx_mst_rst_ch1, and set properties
  set xlslice_tx_mst_rst_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_tx_mst_rst_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $xlslice_tx_mst_rst_ch1


  # Create instance: xlconcat_rx_usr_rdy, and set properties
  set xlconcat_rx_usr_rdy [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_rx_usr_rdy ]

  # Create instance: rx_usr_rdy_ch0, and set properties
  set rx_usr_rdy_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_usr_rdy_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $rx_usr_rdy_ch0


  # Create instance: rx_usr_rdy_ch1, and set properties
  set rx_usr_rdy_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_usr_rdy_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $rx_usr_rdy_ch1


  # Create instance: xlconcat_mst_rx_dp_rst_out, and set properties
  set xlconcat_mst_rx_dp_rst_out [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_mst_rx_dp_rst_out ]

  # Create instance: rx_mst_dp_reset_ch0, and set properties
  set rx_mst_dp_reset_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_mst_dp_reset_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $rx_mst_dp_reset_ch0


  # Create instance: rx_mst_dp_reset_ch1, and set properties
  set rx_mst_dp_reset_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_mst_dp_reset_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $rx_mst_dp_reset_ch1


  # Create instance: xlconcat_mst_rx_rst_out, and set properties
  set xlconcat_mst_rx_rst_out [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_mst_rx_rst_out ]

  # Create instance: rx_mst_reset_ch0, and set properties
  set rx_mst_reset_ch0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_mst_reset_ch0 ]
  set_property CONFIG.DIN_WIDTH {2} $rx_mst_reset_ch0


  # Create instance: rx_mst_reset_ch1, and set properties
  set rx_mst_reset_ch1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice rx_mst_reset_ch1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $rx_mst_reset_ch1


  # Create instance: xlconcat_rx_rst_done, and set properties
  set xlconcat_rx_rst_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_rx_rst_done ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_rx_rst_done


  # Create instance: xlconcat_tx_rst_done1, and set properties
  set xlconcat_tx_rst_done1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_tx_rst_done1 ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_tx_rst_done1


  # Create instance: xlconstant_tx_reset_done, and set properties
  set xlconstant_tx_reset_done [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_tx_reset_done ]

  # Create instance: reset_zero, and set properties
  set reset_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant reset_zero ]
  set_property CONFIG.CONST_VAL {0} $reset_zero


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_gpio_gt_rate_reset_ctl0/S_AXI] [get_bd_intf_pins S_AXI_GPIO_0]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins mrmac_10g_156_core/s_axi] [get_bd_intf_pins S_AXI_MRMAC]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins GT/CLK_IN_D] [get_bd_intf_pins CLK_IN_D]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins GT/AXI4_LITE_APB] [get_bd_intf_pins S_AXI4_LITE_APB]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins GT/GT_Serial] [get_bd_intf_pins GT_Serial]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins axi_gpio_reset_mask/S_AXI] [get_bd_intf_pins S_AXI_GPIO_2]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins axi_gpio_gt_rate_reset_ctl1/S_AXI] [get_bd_intf_pins S_AXI_GPIO_1]
  connect_bd_intf_net -intf_net mrmac_10g_156_core_gt_rx_serdes_interface_0 [get_bd_intf_pins mrmac_10g_156_core/gt_rx_serdes_interface_0] [get_bd_intf_pins GT/RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net mrmac_10g_156_core_gt_rx_serdes_interface_1 [get_bd_intf_pins mrmac_10g_156_core/gt_rx_serdes_interface_1] [get_bd_intf_pins GT/RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net mrmac_10g_156_core_gt_tx_serdes_interface_0 [get_bd_intf_pins mrmac_10g_156_core/gt_tx_serdes_interface_0] [get_bd_intf_pins GT/TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net mrmac_10g_156_core_gt_tx_serdes_interface_1 [get_bd_intf_pins mrmac_10g_156_core/gt_tx_serdes_interface_1] [get_bd_intf_pins GT/TX1_GT_IP_Interface]

  # Create port connections
  connect_bd_net -net GT_ch0_rx_usr_clk  [get_bd_pins GT/ch0_rx_usr_clk] \
  [get_bd_pins concat_rx_usr_clk/In0]
  create_bd_net GT_ch0_rx_usr_clk2
  connect_bd_net -net [get_bd_nets GT_ch0_rx_usr_clk2]  [get_bd_pins GT/ch0_rx_usr_clk2] \
  [get_bd_pins GT/ch0_rxusrclk] \
  [get_bd_pins concat_rx_usr_clk_div2/In0]
  connect_bd_net -net GT_ch0_rxmstresetdone  [get_bd_pins GT/ch0_rxmstresetdone] \
  [get_bd_pins mrmac_10g_156_core/mst_rx_resetdone_in_0] \
  [get_bd_pins xlconcat_rx_rst_done/In0]
  connect_bd_net -net GT_ch0_rxpmaresetdone  [get_bd_pins GT/ch0_rxpmaresetdone] \
  [get_bd_pins mrmac_10g_156_core/rx_pma_resetdone_in_0]
  connect_bd_net -net GT_ch0_tx_usr_clk  [get_bd_pins GT/ch0_tx_usr_clk] \
  [get_bd_pins concat_tx_usr_clk/In1] \
  [get_bd_pins concat_tx_usr_clk/In0]
  create_bd_net GT_ch0_tx_usr_clk2
  connect_bd_net -net [get_bd_nets GT_ch0_tx_usr_clk2]  [get_bd_pins GT/ch0_tx_usr_clk2] \
  [get_bd_pins GT/ch1_txusrclk] \
  [get_bd_pins GT/ch0_txusrclk] \
  [get_bd_pins concat_tx_usr_clk_div2/In1] \
  [get_bd_pins concat_tx_usr_clk_div2/In0]
  connect_bd_net -net GT_ch0_txmstresetdone  [get_bd_pins GT/ch0_txmstresetdone] \
  [get_bd_pins mrmac_10g_156_core/mst_tx_resetdone_in_0] \
  [get_bd_pins xlconcat_tx_rst_done1/In0]
  connect_bd_net -net GT_ch0_txpmaresetdone  [get_bd_pins GT/ch0_txpmaresetdone] \
  [get_bd_pins mrmac_10g_156_core/tx_pma_resetdone_in_0]
  connect_bd_net -net GT_ch1_rx_usr_clk  [get_bd_pins GT/ch1_rx_usr_clk] \
  [get_bd_pins concat_rx_usr_clk/In1]
  create_bd_net GT_ch1_rx_usr_clk2
  connect_bd_net -net [get_bd_nets GT_ch1_rx_usr_clk2]  [get_bd_pins GT/ch1_rx_usr_clk2] \
  [get_bd_pins GT/ch1_rxusrclk] \
  [get_bd_pins concat_rx_usr_clk_div2/In1]
  connect_bd_net -net GT_ch1_rxmstresetdone  [get_bd_pins GT/ch1_rxmstresetdone] \
  [get_bd_pins mrmac_10g_156_core/mst_rx_resetdone_in_1] \
  [get_bd_pins xlconcat_rx_rst_done/In1]
  connect_bd_net -net GT_ch1_rxpmaresetdone  [get_bd_pins GT/ch1_rxpmaresetdone] \
  [get_bd_pins mrmac_10g_156_core/rx_pma_resetdone_in_1]
  connect_bd_net -net GT_ch1_txmstresetdone  [get_bd_pins GT/ch1_txmstresetdone] \
  [get_bd_pins mrmac_10g_156_core/mst_tx_resetdone_in_1] \
  [get_bd_pins xlconcat_tx_rst_done1/In1]
  connect_bd_net -net GT_ch1_txpmaresetdone  [get_bd_pins GT/ch1_txpmaresetdone] \
  [get_bd_pins mrmac_10g_156_core/tx_pma_resetdone_in_1]
  connect_bd_net -net GT_gtpowergood  [get_bd_pins GT/gtpowergood] \
  [get_bd_pins mrmac_10g_156_core/gtpowergood_in]
  connect_bd_net -net In4_1  [get_bd_pins xlconstant_tx_rx_usr_clk_zero/dout] \
  [get_bd_pins concat_tx_usr_clk/In3] \
  [get_bd_pins concat_tx_usr_clk/In2] \
  [get_bd_pins concat_rx_usr_clk/In3] \
  [get_bd_pins concat_rx_usr_clk/In2] \
  [get_bd_pins concat_tx_usr_clk_div2/In2] \
  [get_bd_pins concat_tx_usr_clk_div2/In3] \
  [get_bd_pins concat_rx_usr_clk_div2/In2] \
  [get_bd_pins concat_rx_usr_clk_div2/In3]
  connect_bd_net -net Net  [get_bd_pins mrmac_constant_drive_zero_1/dout] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker0] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker1] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker2] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker3] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker4] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker5] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker6] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_almarker7] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_ena_0] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_ena_1] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_ena_2] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_ena_3] \
  [get_bd_pins mrmac_10g_156_core/rx_flex_cm_ena_1] \
  [get_bd_pins mrmac_10g_156_core/rx_flex_cm_ena_0] \
  [get_bd_pins mrmac_10g_156_core/rx_flex_cm_ena_2] \
  [get_bd_pins mrmac_10g_156_core/rx_flex_cm_ena_3]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl0_gpio2_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl0/gpio2_io_o] \
  [get_bd_pins xlslice_gt_reset_tx_datapath_0/Din] \
  [get_bd_pins xlslice_gt_reset_rx_datapath_0/Din] \
  [get_bd_pins xlslice_gt_reset_all_0/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl0_gpio_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl0/gpio_io_o] \
  [get_bd_pins xlslice_gt_rate_tx_rx_ch0/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl1_gpio2_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl1/gpio2_io_o] \
  [get_bd_pins xlslice_gt_rest_tx_datapath_1/Din] \
  [get_bd_pins xlslice_gt_rest_all_1/Din] \
  [get_bd_pins xlslice_gt_reset_rx_datapath_1/Din]
  connect_bd_net -net axi_gpio_gt_rate_reset_ctl1_gpio_io_o  [get_bd_pins axi_gpio_gt_rate_reset_ctl1/gpio_io_o] \
  [get_bd_pins xlslice_gt_rate_tx_rx_ch1/Din]
  connect_bd_net -net ch0_rxrate_1  [get_bd_pins xlslice_gt_rate_tx_rx_ch0/Dout] \
  [get_bd_pins GT/ch0_rxrate] \
  [get_bd_pins GT/ch0_txrate]
  connect_bd_net -net ch1_rxrate_1  [get_bd_pins xlslice_gt_rate_tx_rx_ch1/Dout] \
  [get_bd_pins GT/ch1_rxrate] \
  [get_bd_pins GT/ch1_txrate]
  connect_bd_net -net concat_rx_usr_clk1_dout  [get_bd_pins concat_rx_usr_clk_div2/dout] \
  [get_bd_pins mrmac_10g_156_core/rx_alt_serdes_clk] \
  [get_bd_pins mrmac_10g_156_core/rx_flexif_clk]
  connect_bd_net -net concat_tx_usr_clk1_dout  [get_bd_pins concat_tx_usr_clk_div2/dout] \
  [get_bd_pins mrmac_10g_156_core/tx_alt_serdes_clk] \
  [get_bd_pins mrmac_10g_156_core/tx_flexif_clk]
  connect_bd_net -net concat_tx_usr_clk_dout  [get_bd_pins concat_tx_usr_clk/dout] \
  [get_bd_pins mrmac_10g_156_core/tx_core_clk]
  connect_bd_net -net ctl_tx_send_idle_in_1_1  [get_bd_pins mrmac_constant_drive_zero_0/dout] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_idle_in_1] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_rfi_in_1] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_lfi_in_1] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_idle_in_0] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_lfi_in_0] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_send_rfi_in_0] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_lane0_vlm_bip7_override_01]
  connect_bd_net -net mrmac_10g_156_core_gt_rx_reset_done_out  [get_bd_pins mrmac_10g_156_core/gt_rx_reset_done_out] \
  [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net mrmac_10g_156_core_gt_tx_reset_done_out  [get_bd_pins mrmac_10g_156_core/gt_tx_reset_done_out] \
  [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net mrmac_10g_156_core_mst_rx_dp_reset_out_0  [get_bd_pins mrmac_10g_156_core/mst_rx_dp_reset_out_0] \
  [get_bd_pins xlconcat_mst_rx_dp_rst_out/In0]
  connect_bd_net -net mrmac_10g_156_core_mst_rx_dp_reset_out_1  [get_bd_pins mrmac_10g_156_core/mst_rx_dp_reset_out_1] \
  [get_bd_pins xlconcat_mst_rx_dp_rst_out/In1]
  connect_bd_net -net mrmac_10g_156_core_mst_rx_reset_out_0  [get_bd_pins mrmac_10g_156_core/mst_rx_reset_out_0] \
  [get_bd_pins xlconcat_mst_rx_rst_out/In0]
  connect_bd_net -net mrmac_10g_156_core_mst_rx_reset_out_1  [get_bd_pins mrmac_10g_156_core/mst_rx_reset_out_1] \
  [get_bd_pins xlconcat_mst_rx_rst_out/In1]
  connect_bd_net -net mrmac_10g_156_core_mst_tx_dp_reset_out_0  [get_bd_pins mrmac_10g_156_core/mst_tx_dp_reset_out_0] \
  [get_bd_pins xlconcat_mst_tx_dp_rst/In0]
  connect_bd_net -net mrmac_10g_156_core_mst_tx_dp_reset_out_1  [get_bd_pins mrmac_10g_156_core/mst_tx_dp_reset_out_1] \
  [get_bd_pins xlconcat_mst_tx_dp_rst/In1]
  connect_bd_net -net mrmac_10g_156_core_mst_tx_reset_out_0  [get_bd_pins mrmac_10g_156_core/mst_tx_reset_out_0] \
  [get_bd_pins xlconcat_tx_mst_rst/In0]
  connect_bd_net -net mrmac_10g_156_core_mst_tx_reset_out_1  [get_bd_pins mrmac_10g_156_core/mst_tx_reset_out_1] \
  [get_bd_pins xlconcat_tx_mst_rst/In1]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tdata0  [get_bd_pins mrmac_10g_156_core/rx_axis_tdata0] \
  [get_bd_pins rx_axis_tdata0]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tdata2  [get_bd_pins mrmac_10g_156_core/rx_axis_tdata2] \
  [get_bd_pins rx_axis_tdata2]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tkeep_user0  [get_bd_pins mrmac_10g_156_core/rx_axis_tkeep_user0] \
  [get_bd_pins rx_axis_tkeep_user0]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tkeep_user2  [get_bd_pins mrmac_10g_156_core/rx_axis_tkeep_user2] \
  [get_bd_pins rx_axis_tkeep_user2]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tlast_0  [get_bd_pins mrmac_10g_156_core/rx_axis_tlast_0] \
  [get_bd_pins rx_axis_tlast_0]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tlast_1  [get_bd_pins mrmac_10g_156_core/rx_axis_tlast_1] \
  [get_bd_pins rx_axis_tlast_1]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tvalid_0  [get_bd_pins mrmac_10g_156_core/rx_axis_tvalid_0] \
  [get_bd_pins rx_axis_tvalid_0]
  connect_bd_net -net mrmac_10g_156_core_rx_axis_tvalid_1  [get_bd_pins mrmac_10g_156_core/rx_axis_tvalid_1] \
  [get_bd_pins rx_axis_tvalid_1]
  connect_bd_net -net mrmac_10g_156_core_rx_clr_out_0  [get_bd_pins mrmac_10g_156_core/rx_clr_out_0] \
  [get_bd_pins GT/MBUFG_GT_CLR_rx_ch0]
  connect_bd_net -net mrmac_10g_156_core_rx_clr_out_1  [get_bd_pins mrmac_10g_156_core/rx_clr_out_1] \
  [get_bd_pins GT/MBUFG_GT_CLR_rx_ch1]
  connect_bd_net -net mrmac_10g_156_core_rx_clrb_leaf_out_0  [get_bd_pins mrmac_10g_156_core/rx_clrb_leaf_out_0] \
  [get_bd_pins GT/MBUFG_GT_CLRB_LEAF_rx_ch0]
  connect_bd_net -net mrmac_10g_156_core_rx_clrb_leaf_out_1  [get_bd_pins mrmac_10g_156_core/rx_clrb_leaf_out_1] \
  [get_bd_pins GT/MBUFG_GT_CLRB_LEAF_rx_ch1]
  connect_bd_net -net mrmac_10g_156_core_rxuserrdy_out_0  [get_bd_pins mrmac_10g_156_core/rxuserrdy_out_0] \
  [get_bd_pins xlconcat_rx_usr_rdy/In0]
  connect_bd_net -net mrmac_10g_156_core_rxuserrdy_out_1  [get_bd_pins mrmac_10g_156_core/rxuserrdy_out_1] \
  [get_bd_pins xlconcat_rx_usr_rdy/In1]
  connect_bd_net -net mrmac_10g_156_core_tx_axis_tready_0  [get_bd_pins mrmac_10g_156_core/tx_axis_tready_0] \
  [get_bd_pins tx_axis_tready_0]
  connect_bd_net -net mrmac_10g_156_core_tx_axis_tready_1  [get_bd_pins mrmac_10g_156_core/tx_axis_tready_1] \
  [get_bd_pins tx_axis_tready_1]
  connect_bd_net -net mrmac_10g_156_core_tx_clr_out_0  [get_bd_pins mrmac_10g_156_core/tx_clr_out_0] \
  [get_bd_pins GT/MBUFG_GT_CLR_tx_ch0]
  connect_bd_net -net mrmac_10g_156_core_tx_clr_out_1  [get_bd_pins mrmac_10g_156_core/tx_clr_out_1] \
  [get_bd_pins GT/MBUFG_GT_CLR_tx_ch1]
  connect_bd_net -net mrmac_10g_156_core_tx_clrb_leaf_out_0  [get_bd_pins mrmac_10g_156_core/tx_clrb_leaf_out_0] \
  [get_bd_pins GT/MBUFG_GT_CLRB_LEAF_tx_ch0]
  connect_bd_net -net mrmac_10g_156_core_tx_clrb_leaf_out_1  [get_bd_pins mrmac_10g_156_core/tx_clrb_leaf_out_1] \
  [get_bd_pins GT/MBUFG_GT_CLRB_LEAF_tx_ch1]
  connect_bd_net -net mrmac_10g_156_core_txuserrdy_out_0  [get_bd_pins mrmac_10g_156_core/txuserrdy_out_0] \
  [get_bd_pins xlconcat_tx_usr_rdy/In0]
  connect_bd_net -net mrmac_10g_156_core_txuserrdy_out_1  [get_bd_pins mrmac_10g_156_core/txuserrdy_out_1] \
  [get_bd_pins xlconcat_tx_usr_rdy/In1]
  connect_bd_net -net mrmac_constant_drive_zero_66bit_dout  [get_bd_pins mrmac_constant_drive_zero_66bit/dout] \
  [get_bd_pins mrmac_10g_156_core/tx_flex_data0] \
  [get_bd_pins mrmac_10g_156_core/rx_flex_cm_data0]
  connect_bd_net -net mrmac_contant_drive_zero_8bit_dout  [get_bd_pins mrmac_contant_drive_zero_8bit/dout] \
  [get_bd_pins mrmac_10g_156_core/ctl_tx_lane0_vlm_bip7_override_value_01]
  connect_bd_net -net mrmac_pm_tick_drive_zero_dout  [get_bd_pins mrmac_pm_tick_drive_zero/dout] \
  [get_bd_pins mrmac_10g_156_core/pm_tick]
  connect_bd_net -net reset_zero_dout  [get_bd_pins reset_zero/dout] \
  [get_bd_pins xlconcat_gt_reset_rx_datapath/In2] \
  [get_bd_pins xlconcat_gt_reset_rx_datapath/In3] \
  [get_bd_pins xlconcat_gt_reset_all/In2] \
  [get_bd_pins xlconcat_gt_reset_all/In3] \
  [get_bd_pins xlconcat_gt_reset_tx_datapath/In2] \
  [get_bd_pins xlconcat_gt_reset_tx_datapath/In3]
  connect_bd_net -net rx_flexif_reset_1  [get_bd_pins rx_flexif_reset] \
  [get_bd_pins mrmac_10g_156_core/rx_flexif_reset]
  connect_bd_net -net rx_mst_dp_reset_ch0_Dout  [get_bd_pins rx_mst_dp_reset_ch0/Dout] \
  [get_bd_pins GT/ch0_rxmstdatapathreset]
  connect_bd_net -net rx_mst_dp_reset_ch1_Dout  [get_bd_pins rx_mst_dp_reset_ch1/Dout] \
  [get_bd_pins GT/ch1_rxmstdatapathreset]
  connect_bd_net -net rx_mst_reset_ch0_Dout  [get_bd_pins rx_mst_reset_ch0/Dout] \
  [get_bd_pins GT/ch0_rxmstreset]
  connect_bd_net -net rx_mst_reset_ch1_Dout  [get_bd_pins rx_mst_reset_ch1/Dout] \
  [get_bd_pins GT/ch1_rxmstreset]
  connect_bd_net -net rx_serdes_clk_1  [get_bd_pins concat_rx_usr_clk/dout] \
  [get_bd_pins mrmac_10g_156_core/rx_serdes_clk] \
  [get_bd_pins mrmac_10g_156_core/rx_core_clk]
  connect_bd_net -net rx_serdes_reset_1  [get_bd_pins util_vector_logic_0/Res] \
  [get_bd_pins mrmac_10g_156_core/rx_serdes_reset] \
  [get_bd_pins mrmac_10g_156_core/rx_core_reset]
  connect_bd_net -net rx_ts_clk_1  [get_bd_pins rx_ts_clk] \
  [get_bd_pins mrmac_10g_156_core/rx_ts_clk] \
  [get_bd_pins mrmac_10g_156_core/tx_ts_clk]
  connect_bd_net -net rx_usr_rdy_ch0_Dout  [get_bd_pins rx_usr_rdy_ch0/Dout] \
  [get_bd_pins GT/ch0_rxuserrdy]
  connect_bd_net -net rx_usr_rdy_ch1_Dout  [get_bd_pins rx_usr_rdy_ch1/Dout] \
  [get_bd_pins GT/ch1_rxuserrdy]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl0/s_axi_aclk] \
  [get_bd_pins mrmac_10g_156_core/s_axi_aclk] \
  [get_bd_pins axi_gpio_reset_mask/s_axi_aclk] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl1/s_axi_aclk] \
  [get_bd_pins GT/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl0/s_axi_aresetn] \
  [get_bd_pins mrmac_10g_156_core/s_axi_aresetn] \
  [get_bd_pins axi_gpio_gt_rate_reset_ctl1/s_axi_aresetn] \
  [get_bd_pins GT/s_axi_aresetn] \
  [get_bd_pins axi_gpio_reset_mask/s_axi_aresetn]
  connect_bd_net -net tx_axi_clk_1  [get_bd_pins tx_axi_clk] \
  [get_bd_pins mrmac_10g_156_core/tx_axi_clk] \
  [get_bd_pins mrmac_10g_156_core/rx_axi_clk]
  connect_bd_net -net tx_axis_tdata0_1  [get_bd_pins tx_axis_tdata0] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tdata0]
  connect_bd_net -net tx_axis_tdata2_1  [get_bd_pins tx_axis_tdata2] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tdata2]
  connect_bd_net -net tx_axis_tkeep_user0_1  [get_bd_pins tx_axis_tkeep_user0] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tkeep_user0]
  connect_bd_net -net tx_axis_tkeep_user2_1  [get_bd_pins tx_axis_tkeep_user2] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tkeep_user2]
  connect_bd_net -net tx_axis_tlast_0_1  [get_bd_pins tx_axis_tlast_0] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tlast_0]
  connect_bd_net -net tx_axis_tlast_1_1  [get_bd_pins tx_axis_tlast_1] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tlast_1]
  connect_bd_net -net tx_axis_tvalid_0_1  [get_bd_pins tx_axis_tvalid_0] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tvalid_0]
  connect_bd_net -net tx_axis_tvalid_1_1  [get_bd_pins tx_axis_tvalid_1] \
  [get_bd_pins mrmac_10g_156_core/tx_axis_tvalid_1]
  connect_bd_net -net tx_dp_rst_ch0_Dout  [get_bd_pins tx_mst_dp_rst_ch0/Dout] \
  [get_bd_pins GT/ch0_txmstdatapathreset]
  connect_bd_net -net tx_mst_dp_rst_ch1_Dout  [get_bd_pins tx_mst_dp_rst_ch1/Dout] \
  [get_bd_pins GT/ch1_txmstdatapathreset]
  connect_bd_net -net tx_preamblein_1_1  [get_bd_pins mrmac_tx_preample_value/dout] \
  [get_bd_pins mrmac_10g_156_core/tx_preamblein_1] \
  [get_bd_pins mrmac_10g_156_core/tx_preamblein_2] \
  [get_bd_pins mrmac_10g_156_core/tx_preamblein_3] \
  [get_bd_pins mrmac_10g_156_core/tx_preamblein_0]
  connect_bd_net -net tx_serdes_reset_1  [get_bd_pins util_vector_logic_1/Res] \
  [get_bd_pins mrmac_10g_156_core/tx_serdes_reset] \
  [get_bd_pins mrmac_10g_156_core/tx_core_reset]
  connect_bd_net -net tx_usr_rdy_ch0_Dout  [get_bd_pins tx_usr_rdy_ch0/Dout] \
  [get_bd_pins GT/ch0_txuserrdy]
  connect_bd_net -net tx_usr_rdy_ch1_Dout  [get_bd_pins tx_usr_rdy_ch1/Dout] \
  [get_bd_pins GT/ch1_txuserrdy]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins xlconcat_rx_rst_done/dout] \
  [get_bd_pins xlconcat_rst_done/In0]
  connect_bd_net -net xlconcat_gt_reset_all_dout  [get_bd_pins xlconcat_gt_reset_all/dout] \
  [get_bd_pins mrmac_10g_156_core/gt_reset_all_in]
  connect_bd_net -net xlconcat_gt_reset_rx_datapath_dout  [get_bd_pins xlconcat_gt_reset_rx_datapath/dout] \
  [get_bd_pins mrmac_10g_156_core/gt_reset_rx_datapath_in]
  connect_bd_net -net xlconcat_gt_reset_tx_datapath_dout  [get_bd_pins xlconcat_gt_reset_tx_datapath/dout] \
  [get_bd_pins mrmac_10g_156_core/gt_reset_tx_datapath_in]
  connect_bd_net -net xlconcat_mst_rx_dp_rst_out_dout  [get_bd_pins xlconcat_mst_rx_dp_rst_out/dout] \
  [get_bd_pins rx_mst_dp_reset_ch1/Din] \
  [get_bd_pins rx_mst_dp_reset_ch0/Din]
  connect_bd_net -net xlconcat_mst_rx_rst_out_dout  [get_bd_pins xlconcat_mst_rx_rst_out/dout] \
  [get_bd_pins rx_mst_reset_ch0/Din] \
  [get_bd_pins rx_mst_reset_ch1/Din]
  connect_bd_net -net xlconcat_mst_tx_dp_rst_dout  [get_bd_pins xlconcat_mst_tx_dp_rst/dout] \
  [get_bd_pins tx_mst_dp_rst_ch0/Din] \
  [get_bd_pins tx_mst_dp_rst_ch1/Din]
  connect_bd_net -net xlconcat_rst_done_dout  [get_bd_pins xlconcat_rst_done/dout] \
  [get_bd_pins axi_gpio_reset_mask/gpio2_io_i]
  connect_bd_net -net xlconcat_rx_usr_rdy_dout  [get_bd_pins xlconcat_rx_usr_rdy/dout] \
  [get_bd_pins rx_usr_rdy_ch0/Din] \
  [get_bd_pins rx_usr_rdy_ch1/Din]
  connect_bd_net -net xlconcat_tx_mst_rst_dout  [get_bd_pins xlconcat_tx_mst_rst/dout] \
  [get_bd_pins xlslice_tx_mst_rst_ch0/Din] \
  [get_bd_pins xlslice_tx_mst_rst_ch1/Din]
  connect_bd_net -net xlconcat_tx_rst_done1_dout  [get_bd_pins xlconcat_tx_rst_done1/dout] \
  [get_bd_pins xlconcat_rst_done/In1]
  connect_bd_net -net xlconcat_tx_usr_rdy_dout  [get_bd_pins xlconcat_tx_usr_rdy/dout] \
  [get_bd_pins tx_usr_rdy_ch1/Din] \
  [get_bd_pins tx_usr_rdy_ch0/Din]
  connect_bd_net -net xlconstant_rx_reset_done_dout  [get_bd_pins xlconstant_rx_reset_done/dout] \
  [get_bd_pins xlconcat_rx_rst_done/In2] \
  [get_bd_pins xlconcat_rx_rst_done/In3]
  connect_bd_net -net xlconstant_tx_reset_done_dout  [get_bd_pins xlconstant_tx_reset_done/dout] \
  [get_bd_pins xlconcat_tx_rst_done1/In2] \
  [get_bd_pins xlconcat_tx_rst_done1/In3]
  connect_bd_net -net xlslice_gt_reset_all_0_Dout  [get_bd_pins xlslice_gt_reset_all_0/Dout] \
  [get_bd_pins xlconcat_gt_reset_all/In0]
  connect_bd_net -net xlslice_gt_reset_rx_datapath_0_Dout  [get_bd_pins xlslice_gt_reset_rx_datapath_0/Dout] \
  [get_bd_pins xlconcat_gt_reset_rx_datapath/In0]
  connect_bd_net -net xlslice_gt_reset_rx_datapath_1_Dout  [get_bd_pins xlslice_gt_reset_rx_datapath_1/Dout] \
  [get_bd_pins xlconcat_gt_reset_rx_datapath/In1]
  connect_bd_net -net xlslice_gt_reset_tx_datapath_0_Dout  [get_bd_pins xlslice_gt_reset_tx_datapath_0/Dout] \
  [get_bd_pins xlconcat_gt_reset_tx_datapath/In0]
  connect_bd_net -net xlslice_gt_rest_all_1_Dout  [get_bd_pins xlslice_gt_rest_all_1/Dout] \
  [get_bd_pins xlconcat_gt_reset_all/In1]
  connect_bd_net -net xlslice_gt_rest_tx_datapath_1_Dout  [get_bd_pins xlslice_gt_rest_tx_datapath_1/Dout] \
  [get_bd_pins xlconcat_gt_reset_tx_datapath/In1]
  connect_bd_net -net xlslice_tx_mst_rst_ch0_Dout  [get_bd_pins xlslice_tx_mst_rst_ch0/Dout] \
  [get_bd_pins GT/ch0_txmstreset]
  connect_bd_net -net xlslice_tx_mst_rst_ch1_Dout  [get_bd_pins xlslice_tx_mst_rst_ch1/Dout] \
  [get_bd_pins GT/ch1_txmstreset]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DATAPATH_MCDMA_1
proc create_hier_cell_DATAPATH_MCDMA_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DATAPATH_MCDMA_1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_MM2S

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_S2MM

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_SG

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type rst axis_rx_rstn
  create_bd_pin -dir I -type rst axis_tx_rstn
  create_bd_pin -dir I mcdma_clk
  create_bd_pin -dir O -type intr mm2s_ch1_introut
  create_bd_pin -dir I -from 63 -to 0 rx_axis_tdata0
  create_bd_pin -dir I -from 10 -to 0 rx_axis_tkeep_user0
  create_bd_pin -dir I rx_axis_tlast_0
  create_bd_pin -dir I rx_axis_tvalid_0
  create_bd_pin -dir O -type intr s2mm_ch1_introut
  create_bd_pin -dir I -type clk s_axi_lite_aclk
  create_bd_pin -dir I -type rst s_axi_lite_aresetn
  create_bd_pin -dir O -from 63 -to 0 tx_axis_tdata0
  create_bd_pin -dir O -from 10 -to 0 tx_axis_tkeep_user0
  create_bd_pin -dir O tx_axis_tlast_0
  create_bd_pin -dir I tx_axis_tready_0
  create_bd_pin -dir O tx_axis_tvalid_0

  # Create instance: axi_mcdma_0, and set properties
  set axi_mcdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mcdma axi_mcdma_0 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm_dre {1} \
    CONFIG.c_m_axi_mm2s_data_width {64} \
    CONFIG.c_m_axi_s2mm_data_width {64} \
    CONFIG.c_m_axis_mm2s_tdata_width {64} \
    CONFIG.c_mm2s_burst_size {256} \
    CONFIG.c_prmry_is_aclk_async {0} \
    CONFIG.c_s2mm_burst_size {256} \
    CONFIG.c_sg_length_width {14} \
  ] $axi_mcdma_0


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_1


  # Create instance: axis_data_fifo_rx_0, and set properties
  set axis_data_fifo_rx_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_rx_0 ]
  set_property -dict [list \
    CONFIG.ACLKEN_CONV_MODE {0} \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_PROG_FULL {0} \
    CONFIG.HAS_RD_DATA_COUNT {0} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_WR_DATA_COUNT {0} \
    CONFIG.IS_ACLK_ASYNC {0} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_rx_0


  # Create instance: axis_data_fifo_tx_0, and set properties
  set axis_data_fifo_tx_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_tx_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {0} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_tx_0


  # Create instance: datapath_0_concat_tkeep, and set properties
  set datapath_0_concat_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat datapath_0_concat_tkeep ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {8} \
    CONFIG.IN1_WIDTH {3} \
  ] $datapath_0_concat_tkeep


  # Create instance: datapath_0_constant_tkeep, and set properties
  set datapath_0_constant_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant datapath_0_constant_tkeep ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {3} \
  ] $datapath_0_constant_tkeep


  # Create instance: datapath_0_slice_tkeep, and set properties
  set datapath_0_slice_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice datapath_0_slice_tkeep ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_WIDTH {11} \
    CONFIG.DOUT_WIDTH {8} \
  ] $datapath_0_slice_tkeep


  # Create instance: mrmac_10g_mux_0, and set properties
  set mrmac_10g_mux_0 [ create_bd_cell -type ip -vlnv user.org:user:mrmac_10g_mux mrmac_10g_mux_0 ]

  # Create instance: xlconstant_7, and set properties
  set xlconstant_7 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_7 ]
  set_property CONFIG.CONST_VAL {1} $xlconstant_7


  # Create interface connections
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXIS_MM2S [get_bd_intf_pins axi_mcdma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_data_fifo_tx_0/S_AXIS]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_MM2S [get_bd_intf_pins M_AXI_MM2S] [get_bd_intf_pins axi_mcdma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_S2MM [get_bd_intf_pins M_AXI_S2MM] [get_bd_intf_pins axi_mcdma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_SG [get_bd_intf_pins M_AXI_SG] [get_bd_intf_pins axi_mcdma_0/M_AXI_SG]
  connect_bd_intf_net -intf_net axis_data_fifo_rx_0_M_AXIS [get_bd_intf_pins axi_mcdma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_rx_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_tx_0_M_AXIS [get_bd_intf_pins axis_data_fifo_tx_0/M_AXIS] [get_bd_intf_pins mrmac_10g_mux_0/tx_s_axis]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_mcdma_0/S_AXI_LITE]

  # Create port connections
  connect_bd_net -net axi_mcdma_0_mm2s_ch1_introut  [get_bd_pins axi_mcdma_0/mm2s_ch1_introut] \
  [get_bd_pins mm2s_ch1_introut]
  connect_bd_net -net axi_mcdma_0_s2mm_ch1_introut  [get_bd_pins axi_mcdma_0/s2mm_ch1_introut] \
  [get_bd_pins s2mm_ch1_introut]
  connect_bd_net -net axis_clock_converter_0_m_axis_tvalid  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tvalid] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tvalid]
  connect_bd_net -net axis_data_fifo_0_m_axis_tdata  [get_bd_pins axis_data_fifo_0/m_axis_tdata] \
  [get_bd_pins tx_axis_tdata0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tkeep  [get_bd_pins axis_data_fifo_0/m_axis_tkeep] \
  [get_bd_pins datapath_0_concat_tkeep/In0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tlast  [get_bd_pins axis_data_fifo_0/m_axis_tlast] \
  [get_bd_pins tx_axis_tlast_0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tvalid  [get_bd_pins axis_data_fifo_0/m_axis_tvalid] \
  [get_bd_pins tx_axis_tvalid_0]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready  [get_bd_pins axis_data_fifo_0/s_axis_tready] \
  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tready]
  connect_bd_net -net axis_data_fifo_1_m_axis_tdata  [get_bd_pins axis_data_fifo_1/m_axis_tdata] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tdata]
  connect_bd_net -net axis_data_fifo_1_m_axis_tkeep  [get_bd_pins axis_data_fifo_1/m_axis_tkeep] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tkeep]
  connect_bd_net -net axis_data_fifo_1_m_axis_tlast  [get_bd_pins axis_data_fifo_1/m_axis_tlast] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tlast]
  connect_bd_net -net axis_data_fifo_1_m_axis_tvalid  [get_bd_pins axis_data_fifo_1/m_axis_tvalid] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tvalid]
  connect_bd_net -net axis_data_fifo_rx_0_s_axis_tready  [get_bd_pins axis_data_fifo_rx_0/s_axis_tready] \
  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tready]
  connect_bd_net -net datapath_0_slice_tkeep_Dout  [get_bd_pins datapath_0_slice_tkeep/Dout] \
  [get_bd_pins axis_data_fifo_1/s_axis_tkeep]
  connect_bd_net -net m_axis_aresetn1_1  [get_bd_pins axis_tx_rstn] \
  [get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
  [get_bd_pins mrmac_10g_mux_0/tx_s_aresetn] \
  [get_bd_pins axis_data_fifo_tx_0/s_axis_aresetn]
  connect_bd_net -net mcdma_clk_1  [get_bd_pins mcdma_clk] \
  [get_bd_pins axi_mcdma_0/s_axi_aclk] \
  [get_bd_pins axis_data_fifo_0/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_1/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_tx_0/s_axis_aclk] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_aclk] \
  [get_bd_pins mrmac_10g_mux_0/tx_s_aclk]
  connect_bd_net -net mrmac_0_rx_axis_tkeep_user0  [get_bd_pins rx_axis_tkeep_user0] \
  [get_bd_pins datapath_0_slice_tkeep/Din]
  connect_bd_net -net mrmac_10g_mux_0_rx_m_axis_tdata  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tdata] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tdata]
  connect_bd_net -net mrmac_10g_mux_0_rx_m_axis_tkeep  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tkeep] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tkeep]
  connect_bd_net -net mrmac_10g_mux_0_rx_s_axis_tready  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tready] \
  [get_bd_pins axis_data_fifo_1/m_axis_tready]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tdata  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tdata] \
  [get_bd_pins axis_data_fifo_0/s_axis_tdata]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tkeep  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tkeep] \
  [get_bd_pins axis_data_fifo_0/s_axis_tkeep]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tlast  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tlast] \
  [get_bd_pins axis_data_fifo_0/s_axis_tlast]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tvalid  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tvalid] \
  [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
  connect_bd_net -net rx_axis_tdata0_1  [get_bd_pins rx_axis_tdata0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tdata]
  connect_bd_net -net rx_axis_tlast_0_1  [get_bd_pins rx_axis_tlast_0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tlast]
  connect_bd_net -net rx_axis_tvalid_0_1  [get_bd_pins rx_axis_tvalid_0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tvalid]
  connect_bd_net -net s_axis_aresetn1_1  [get_bd_pins axis_rx_rstn] \
  [get_bd_pins axis_data_fifo_1/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_aresetn] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_aresetn]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins s_axi_lite_aresetn] \
  [get_bd_pins axi_mcdma_0/axi_resetn]
  connect_bd_net -net s_axis_tlast_2  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tlast] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tlast]
  connect_bd_net -net tx_axis_tready_0_1  [get_bd_pins tx_axis_tready_0] \
  [get_bd_pins axis_data_fifo_0/m_axis_tready]
  connect_bd_net -net versal_cips_0_pl_clk0  [get_bd_pins s_axi_lite_aclk] \
  [get_bd_pins axi_mcdma_0/s_axi_lite_aclk]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins datapath_0_concat_tkeep/dout] \
  [get_bd_pins tx_axis_tkeep_user0]
  connect_bd_net -net xlconstant_1_dout  [get_bd_pins datapath_0_constant_tkeep/dout] \
  [get_bd_pins datapath_0_concat_tkeep/In1]
  connect_bd_net -net xlconstant_7_dout  [get_bd_pins xlconstant_7/dout] \
  [get_bd_pins mrmac_10g_mux_0/sel_10g_mode]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DATAPATH_MCDMA_0
proc create_hier_cell_DATAPATH_MCDMA_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DATAPATH_MCDMA_0() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_MM2S

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_S2MM

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_SG

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type rst axis_rx_rstn
  create_bd_pin -dir I -type rst axis_tx_rstn
  create_bd_pin -dir I mcdma_clk
  create_bd_pin -dir O -type intr mm2s_ch1_introut
  create_bd_pin -dir I -from 63 -to 0 rx_axis_tdata0
  create_bd_pin -dir I -from 10 -to 0 rx_axis_tkeep_user0
  create_bd_pin -dir I rx_axis_tlast_0
  create_bd_pin -dir I rx_axis_tvalid_0
  create_bd_pin -dir O -type intr s2mm_ch1_introut
  create_bd_pin -dir I -type clk s_axi_lite_aclk
  create_bd_pin -dir I -type rst s_axi_lite_aresetn
  create_bd_pin -dir O -from 63 -to 0 tx_axis_tdata0
  create_bd_pin -dir O -from 10 -to 0 tx_axis_tkeep_user0
  create_bd_pin -dir O tx_axis_tlast_0
  create_bd_pin -dir I tx_axis_tready_0
  create_bd_pin -dir O tx_axis_tvalid_0

  # Create instance: axi_mcdma_0, and set properties
  set axi_mcdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mcdma axi_mcdma_0 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm_dre {1} \
    CONFIG.c_m_axi_mm2s_data_width {64} \
    CONFIG.c_m_axi_s2mm_data_width {64} \
    CONFIG.c_m_axis_mm2s_tdata_width {64} \
    CONFIG.c_mm2s_burst_size {256} \
    CONFIG.c_prmry_is_aclk_async {0} \
    CONFIG.c_s2mm_burst_size {256} \
    CONFIG.c_sg_length_width {14} \
  ] $axi_mcdma_0


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_0


  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_1 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_1


  # Create instance: axis_data_fifo_rx_0, and set properties
  set axis_data_fifo_rx_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_rx_0 ]
  set_property -dict [list \
    CONFIG.ACLKEN_CONV_MODE {0} \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_PROG_FULL {0} \
    CONFIG.HAS_RD_DATA_COUNT {0} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_WR_DATA_COUNT {0} \
    CONFIG.IS_ACLK_ASYNC {0} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_rx_0


  # Create instance: axis_data_fifo_tx_0, and set properties
  set axis_data_fifo_tx_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_tx_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {2048} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.IS_ACLK_ASYNC {0} \
    CONFIG.TDATA_NUM_BYTES {8} \
  ] $axis_data_fifo_tx_0


  # Create instance: datapath_0_concat_tkeep, and set properties
  set datapath_0_concat_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat datapath_0_concat_tkeep ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {8} \
    CONFIG.IN1_WIDTH {3} \
  ] $datapath_0_concat_tkeep


  # Create instance: datapath_0_constant_tkeep, and set properties
  set datapath_0_constant_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant datapath_0_constant_tkeep ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {3} \
  ] $datapath_0_constant_tkeep


  # Create instance: datapath_0_slice_tkeep, and set properties
  set datapath_0_slice_tkeep [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice datapath_0_slice_tkeep ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_WIDTH {11} \
    CONFIG.DOUT_WIDTH {8} \
  ] $datapath_0_slice_tkeep


  # Create instance: mrmac_10g_mux_0, and set properties
  set mrmac_10g_mux_0 [ create_bd_cell -type ip -vlnv user.org:user:mrmac_10g_mux mrmac_10g_mux_0 ]

  # Create instance: xlconstant_7, and set properties
  set xlconstant_7 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant xlconstant_7 ]
  set_property CONFIG.CONST_VAL {1} $xlconstant_7


  # Create interface connections
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXIS_MM2S [get_bd_intf_pins axi_mcdma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_data_fifo_tx_0/S_AXIS]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_MM2S [get_bd_intf_pins M_AXI_MM2S] [get_bd_intf_pins axi_mcdma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_S2MM [get_bd_intf_pins M_AXI_S2MM] [get_bd_intf_pins axi_mcdma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_mcdma_0_M_AXI_SG [get_bd_intf_pins M_AXI_SG] [get_bd_intf_pins axi_mcdma_0/M_AXI_SG]
  connect_bd_intf_net -intf_net axis_data_fifo_rx_0_M_AXIS [get_bd_intf_pins axi_mcdma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_rx_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_tx_0_M_AXIS [get_bd_intf_pins axis_data_fifo_tx_0/M_AXIS] [get_bd_intf_pins mrmac_10g_mux_0/tx_s_axis]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_mcdma_0/S_AXI_LITE]

  # Create port connections
  connect_bd_net -net axi_mcdma_0_mm2s_ch1_introut  [get_bd_pins axi_mcdma_0/mm2s_ch1_introut] \
  [get_bd_pins mm2s_ch1_introut]
  connect_bd_net -net axi_mcdma_0_s2mm_ch1_introut  [get_bd_pins axi_mcdma_0/s2mm_ch1_introut] \
  [get_bd_pins s2mm_ch1_introut]
  connect_bd_net -net axis_clock_converter_0_m_axis_tvalid  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tvalid] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tvalid]
  connect_bd_net -net axis_data_fifo_0_m_axis_tdata  [get_bd_pins axis_data_fifo_0/m_axis_tdata] \
  [get_bd_pins tx_axis_tdata0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tkeep  [get_bd_pins axis_data_fifo_0/m_axis_tkeep] \
  [get_bd_pins datapath_0_concat_tkeep/In0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tlast  [get_bd_pins axis_data_fifo_0/m_axis_tlast] \
  [get_bd_pins tx_axis_tlast_0]
  connect_bd_net -net axis_data_fifo_0_m_axis_tvalid  [get_bd_pins axis_data_fifo_0/m_axis_tvalid] \
  [get_bd_pins tx_axis_tvalid_0]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready  [get_bd_pins axis_data_fifo_0/s_axis_tready] \
  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tready]
  connect_bd_net -net axis_data_fifo_1_m_axis_tdata  [get_bd_pins axis_data_fifo_1/m_axis_tdata] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tdata]
  connect_bd_net -net axis_data_fifo_1_m_axis_tkeep  [get_bd_pins axis_data_fifo_1/m_axis_tkeep] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tkeep]
  connect_bd_net -net axis_data_fifo_1_m_axis_tlast  [get_bd_pins axis_data_fifo_1/m_axis_tlast] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tlast]
  connect_bd_net -net axis_data_fifo_1_m_axis_tvalid  [get_bd_pins axis_data_fifo_1/m_axis_tvalid] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tvalid]
  connect_bd_net -net axis_data_fifo_rx_0_s_axis_tready  [get_bd_pins axis_data_fifo_rx_0/s_axis_tready] \
  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tready]
  connect_bd_net -net datapath_0_slice_tkeep_Dout  [get_bd_pins datapath_0_slice_tkeep/Dout] \
  [get_bd_pins axis_data_fifo_1/s_axis_tkeep]
  connect_bd_net -net m_axis_aresetn1_1  [get_bd_pins axis_tx_rstn] \
  [get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
  [get_bd_pins mrmac_10g_mux_0/tx_s_aresetn] \
  [get_bd_pins axis_data_fifo_tx_0/s_axis_aresetn]
  connect_bd_net -net mcdma_clk_1  [get_bd_pins mcdma_clk] \
  [get_bd_pins axi_mcdma_0/s_axi_aclk] \
  [get_bd_pins axis_data_fifo_0/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_1/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_tx_0/s_axis_aclk] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_aclk] \
  [get_bd_pins mrmac_10g_mux_0/tx_s_aclk]
  connect_bd_net -net mrmac_0_rx_axis_tkeep_user0  [get_bd_pins rx_axis_tkeep_user0] \
  [get_bd_pins datapath_0_slice_tkeep/Din]
  connect_bd_net -net mrmac_10g_mux_0_rx_m_axis_tdata  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tdata] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tdata]
  connect_bd_net -net mrmac_10g_mux_0_rx_m_axis_tkeep  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tkeep] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tkeep]
  connect_bd_net -net mrmac_10g_mux_0_rx_s_axis_tready  [get_bd_pins mrmac_10g_mux_0/rx_s_axis_tready] \
  [get_bd_pins axis_data_fifo_1/m_axis_tready]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tdata  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tdata] \
  [get_bd_pins axis_data_fifo_0/s_axis_tdata]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tkeep  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tkeep] \
  [get_bd_pins axis_data_fifo_0/s_axis_tkeep]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tlast  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tlast] \
  [get_bd_pins axis_data_fifo_0/s_axis_tlast]
  connect_bd_net -net mrmac_10g_mux_0_tx_m_axis_tvalid  [get_bd_pins mrmac_10g_mux_0/tx_m_axis_tvalid] \
  [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
  connect_bd_net -net rx_axis_tdata0_1  [get_bd_pins rx_axis_tdata0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tdata]
  connect_bd_net -net rx_axis_tlast_0_1  [get_bd_pins rx_axis_tlast_0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tlast]
  connect_bd_net -net rx_axis_tvalid_0_1  [get_bd_pins rx_axis_tvalid_0] \
  [get_bd_pins axis_data_fifo_1/s_axis_tvalid]
  connect_bd_net -net s_axis_aresetn1_1  [get_bd_pins axis_rx_rstn] \
  [get_bd_pins axis_data_fifo_1/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_aresetn] \
  [get_bd_pins mrmac_10g_mux_0/rx_s_aresetn]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins s_axi_lite_aresetn] \
  [get_bd_pins axi_mcdma_0/axi_resetn]
  connect_bd_net -net s_axis_tlast_2  [get_bd_pins mrmac_10g_mux_0/rx_m_axis_tlast] \
  [get_bd_pins axis_data_fifo_rx_0/s_axis_tlast]
  connect_bd_net -net tx_axis_tready_0_1  [get_bd_pins tx_axis_tready_0] \
  [get_bd_pins axis_data_fifo_0/m_axis_tready]
  connect_bd_net -net versal_cips_0_pl_clk0  [get_bd_pins s_axi_lite_aclk] \
  [get_bd_pins axi_mcdma_0/s_axi_lite_aclk]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins datapath_0_concat_tkeep/dout] \
  [get_bd_pins tx_axis_tkeep_user0]
  connect_bd_net -net xlconstant_1_dout  [get_bd_pins datapath_0_constant_tkeep/dout] \
  [get_bd_pins datapath_0_concat_tkeep/In1]
  connect_bd_net -net xlconstant_7_dout  [get_bd_pins xlconstant_7/dout] \
  [get_bd_pins mrmac_10g_mux_0/sel_10g_mode]

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

  ####################################################################
  ##
  ## 10G Ethernet Logic Begins
  ##
  ####################################################################

  # Create instance: DATAPATH_MCDMA_0
  create_hier_cell_DATAPATH_MCDMA_0 [current_bd_instance .] DATAPATH_MCDMA_0

  # Create instance: DATAPATH_MCDMA_1
  create_hier_cell_DATAPATH_MCDMA_1 [current_bd_instance .] DATAPATH_MCDMA_1

  # Create instance: MRMAC_GT
  create_hier_cell_MRMAC_GT [current_bd_instance .] MRMAC_GT

  # Create instance: axis_clk_to_zero, and set properties
  set axis_clk_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant axis_clk_to_zero ]
  set_property CONFIG.CONST_VAL {0} $axis_clk_to_zero

  # Create instance: const_gnd, and set properties
  set const_gnd [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant const_gnd ]
  set_property CONFIG.CONST_VAL {0} $const_gnd


  # Create instance: clk_wizard_axis_clk, and set properties
  set clk_wizard_axis_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard_axis_clk ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {322.265,100.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
    CONFIG.PRIM_SOURCE {No_buffer} \
  ] $clk_wizard_axis_clk

  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {4} $ilconcat_0


  # Create instance: proc_sys_reset_axis, and set properties
  set proc_sys_reset_axis [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_axis ]

  # Create instance: proc_sys_reset_lite, and set properties
  set proc_sys_reset_lite [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_lite ]
  set_property CONFIG.C_NUM_BUS_RST {4} $proc_sys_reset_lite


  # Create instance: smartconnect_axi_lite, and set properties
  set smartconnect_axi_lite [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_axi_lite ]
  set_property -dict [list \
    CONFIG.NUM_MI {7} \
    CONFIG.NUM_SI {1} \
    CONFIG.NUM_CLKS {2} \
  ] $smartconnect_axi_lite


  # Create instance: smartconnect_gpios, and set properties
  set smartconnect_gpios [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_gpios ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_gpios


  # Create instance: smartconnect_mcdma1, and set properties
  set smartconnect_mcdma1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_mcdma1 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_SI {3} \
  ] $smartconnect_mcdma1


  # Create instance: smartconnect_mcmdm0, and set properties
  set smartconnect_mcmdm0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_mcmdm0 ]
  set_property CONFIG.NUM_SI {3} $smartconnect_mcmdm0


  # Create instance: ts_clk_to_zero, and set properties
  set ts_clk_to_zero [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ts_clk_to_zero ]
  set_property CONFIG.CONST_VAL {0} $ts_clk_to_zero


  # Create instance: xlconcat_ts_clk, and set properties
  set xlconcat_ts_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_ts_clk ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_ts_clk


  # Create instance: xlconcat_tx_rx_axi_clk, and set properties
  set xlconcat_tx_rx_axi_clk [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlconcat_tx_rx_axi_clk ]
  set_property CONFIG.NUM_PORTS {4} $xlconcat_tx_rx_axi_clk

  # Create instance: tieoff_unused
  create_hier_cell_tieoff_unused [current_bd_instance .] tieoff_unused

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_pcie_fixed_M00_AXI [get_bd_intf_pins axi_noc_pcie_fixed/M00_AXI] [get_bd_intf_pins tieoff_unused/S_AXI_PCIE]
  connect_bd_intf_net -intf_net CLK_IN_D [get_bd_intf_ports CLK_IN_D] [get_bd_intf_pins MRMAC_GT/CLK_IN_D]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_0_M_AXI_MM2S [get_bd_intf_pins DATAPATH_MCDMA_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_mcmdm0/S00_AXI]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_0_M_AXI_S2MM [get_bd_intf_pins DATAPATH_MCDMA_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_mcmdm0/S01_AXI]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_0_M_AXI_SG [get_bd_intf_pins DATAPATH_MCDMA_0/M_AXI_SG] [get_bd_intf_pins smartconnect_mcmdm0/S02_AXI]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_1_M_AXI_MM2S [get_bd_intf_pins DATAPATH_MCDMA_1/M_AXI_MM2S] [get_bd_intf_pins smartconnect_mcdma1/S00_AXI]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_1_M_AXI_S2MM [get_bd_intf_pins DATAPATH_MCDMA_1/M_AXI_S2MM] [get_bd_intf_pins smartconnect_mcdma1/S01_AXI]
  connect_bd_intf_net -intf_net DATAPATH_MCDMA_1_M_AXI_SG [get_bd_intf_pins DATAPATH_MCDMA_1/M_AXI_SG] [get_bd_intf_pins smartconnect_mcdma1/S02_AXI]
  connect_bd_intf_net -intf_net MRMAC_GT_GT_Serial [get_bd_intf_ports GT_Serial] [get_bd_intf_pins MRMAC_GT/GT_Serial]
  connect_bd_intf_net -intf_net S_AXI_LITE_2 [get_bd_intf_pins DATAPATH_MCDMA_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_axi_lite/M03_AXI]
  connect_bd_intf_net -intf_net axi_noc_fixed_0_M00_AXI [get_bd_intf_pins axi_noc_fixed_0/M00_AXI] [get_bd_intf_pins smartconnect_axi_lite/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_mcdma1/M00_AXI] [get_bd_intf_pins axi_noc_fixed_1/S01_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_axi_lite/M00_AXI] [get_bd_intf_pins MRMAC_GT/S_AXI_MRMAC]
  connect_bd_intf_net -intf_net smartconnect_1_M01_AXI [get_bd_intf_pins smartconnect_axi_lite/M01_AXI] [get_bd_intf_pins MRMAC_GT/S_AXI4_LITE_APB]
  connect_bd_intf_net -intf_net smartconnect_1_M02_AXI [get_bd_intf_pins smartconnect_axi_lite/M02_AXI] [get_bd_intf_pins smartconnect_gpios/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_gpios/M00_AXI] [get_bd_intf_pins MRMAC_GT/S_AXI_GPIO_0]
  connect_bd_intf_net -intf_net smartconnect_2_M01_AXI [get_bd_intf_pins smartconnect_gpios/M01_AXI] [get_bd_intf_pins MRMAC_GT/S_AXI_GPIO_1]
  connect_bd_intf_net -intf_net smartconnect_2_M02_AXI [get_bd_intf_pins smartconnect_gpios/M02_AXI] [get_bd_intf_pins MRMAC_GT/S_AXI_GPIO_2]
  connect_bd_intf_net -intf_net smartconnect_3_M00_AXI [get_bd_intf_pins smartconnect_mcmdm0/M00_AXI] [get_bd_intf_pins axi_noc_fixed_1/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M04_AXI [get_bd_intf_pins smartconnect_axi_lite/M04_AXI] [get_bd_intf_pins DATAPATH_MCDMA_1/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M05_AXI [get_bd_intf_pins smartconnect_axi_lite/M05_AXI] [get_bd_intf_pins axi_intc_lpd/s_axi]
  connect_bd_intf_net -intf_net smartconnect_axi_lite_M06_AXI [get_bd_intf_pins smartconnect_axi_lite/M06_AXI] [get_bd_intf_pins axi_intc_fpd/s_axi]

  # Create port connections
  connect_bd_net -net pl_0_clk  [get_bd_ports pl_0_clk] \
  [get_bd_pins tieoff_unused/aclk] \
  [get_bd_pins axi_noc_fixed_0/aclk0] \
  [get_bd_pins axi_noc_pcie_fixed/aclk0] \
  [get_bd_pins clk_wizard_axis_clk/clk_in1] \
  [get_bd_pins proc_sys_reset_lite/slowest_sync_clk] \
  [get_bd_pins smartconnect_axi_lite/aclk] \
  [get_bd_pins smartconnect_gpios/aclk] \
  [get_bd_pins MRMAC_GT/s_axi_aclk] \
  [get_bd_pins DATAPATH_MCDMA_0/s_axi_lite_aclk] \
  [get_bd_pins DATAPATH_MCDMA_1/s_axi_lite_aclk]

  connect_bd_net -net pl_0_resetn [get_bd_ports pl_0_resetn] \
  [get_bd_pins proc_sys_reset_axis/ext_reset_in] \
  [get_bd_pins tieoff_unused/aresetn]

  connect_bd_net -net DATAPATH_MCDMA_0_mm2s_ch1_introut  [get_bd_pins DATAPATH_MCDMA_0/mm2s_ch1_introut] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net DATAPATH_MCDMA_0_s2mm_ch1_introut  [get_bd_pins DATAPATH_MCDMA_0/s2mm_ch1_introut] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net DATAPATH_MCDMA_0_tx_axis_tdata0  [get_bd_pins DATAPATH_MCDMA_0/tx_axis_tdata0] \
  [get_bd_pins MRMAC_GT/tx_axis_tdata0]
  connect_bd_net -net DATAPATH_MCDMA_0_tx_axis_tkeep_user0  [get_bd_pins DATAPATH_MCDMA_0/tx_axis_tkeep_user0] \
  [get_bd_pins MRMAC_GT/tx_axis_tkeep_user0]
  connect_bd_net -net DATAPATH_MCDMA_0_tx_axis_tlast_0  [get_bd_pins DATAPATH_MCDMA_0/tx_axis_tlast_0] \
  [get_bd_pins MRMAC_GT/tx_axis_tlast_0]
  connect_bd_net -net DATAPATH_MCDMA_0_tx_axis_tvalid_0  [get_bd_pins DATAPATH_MCDMA_0/tx_axis_tvalid_0] \
  [get_bd_pins MRMAC_GT/tx_axis_tvalid_0]
  connect_bd_net -net DATAPATH_MCDMA_1_mm2s_ch1_introut  [get_bd_pins DATAPATH_MCDMA_1/mm2s_ch1_introut] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net DATAPATH_MCDMA_1_s2mm_ch1_introut  [get_bd_pins DATAPATH_MCDMA_1/s2mm_ch1_introut] \
  [get_bd_pins ilconcat_0/In3]
  connect_bd_net -net DATAPATH_MCDMA_1_tx_axis_tdata0  [get_bd_pins DATAPATH_MCDMA_1/tx_axis_tdata0] \
  [get_bd_pins MRMAC_GT/tx_axis_tdata2]
  connect_bd_net -net DATAPATH_MCDMA_1_tx_axis_tkeep_user0  [get_bd_pins DATAPATH_MCDMA_1/tx_axis_tkeep_user0] \
  [get_bd_pins MRMAC_GT/tx_axis_tkeep_user2]
  connect_bd_net -net DATAPATH_MCDMA_1_tx_axis_tlast_0  [get_bd_pins DATAPATH_MCDMA_1/tx_axis_tlast_0] \
  [get_bd_pins MRMAC_GT/tx_axis_tlast_1]
  connect_bd_net -net DATAPATH_MCDMA_1_tx_axis_tvalid_0  [get_bd_pins DATAPATH_MCDMA_1/tx_axis_tvalid_0] \
  [get_bd_pins MRMAC_GT/tx_axis_tvalid_1]
  connect_bd_net -net Din_1  [get_bd_pins MRMAC_GT/rx_axis_tkeep_user2] \
  [get_bd_pins DATAPATH_MCDMA_1/rx_axis_tkeep_user0]
  connect_bd_net -net MRMAC_GT_rx_axis_tdata0  [get_bd_pins MRMAC_GT/rx_axis_tdata0] \
  [get_bd_pins DATAPATH_MCDMA_0/rx_axis_tdata0]
  connect_bd_net -net MRMAC_GT_rx_axis_tkeep_user0  [get_bd_pins MRMAC_GT/rx_axis_tkeep_user0] \
  [get_bd_pins DATAPATH_MCDMA_0/rx_axis_tkeep_user0]
  connect_bd_net -net MRMAC_GT_rx_axis_tlast_0  [get_bd_pins MRMAC_GT/rx_axis_tlast_0] \
  [get_bd_pins DATAPATH_MCDMA_0/rx_axis_tlast_0]
  connect_bd_net -net MRMAC_GT_rx_axis_tvalid_0  [get_bd_pins MRMAC_GT/rx_axis_tvalid_0] \
  [get_bd_pins DATAPATH_MCDMA_0/rx_axis_tvalid_0]
  connect_bd_net -net MRMAC_GT_tx_axis_tready_0  [get_bd_pins MRMAC_GT/tx_axis_tready_0] \
  [get_bd_pins DATAPATH_MCDMA_0/tx_axis_tready_0]
  connect_bd_net -net axis_clk_1  [get_bd_pins clk_wizard_axis_clk/clk_out1] \
  [get_bd_pins proc_sys_reset_axis/slowest_sync_clk] \
  [get_bd_pins smartconnect_mcdma1/aclk] \
  [get_bd_pins smartconnect_mcmdm0/aclk] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In0] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In1] \
  [get_bd_pins DATAPATH_MCDMA_0/mcdma_clk] \
  [get_bd_pins DATAPATH_MCDMA_1/mcdma_clk] \
  [get_bd_ports clk_out1] \
  [get_bd_pins axi_noc_fixed_1/aclk0] \
  [get_bd_pins axi_intc_lpd/s_axi_aclk] \
  [get_bd_pins axi_intc_fpd/s_axi_aclk] \
  [get_bd_pins smartconnect_axi_lite/aclk1]
  connect_bd_net -net axis_clk_to_zero_dout  [get_bd_pins axis_clk_to_zero/dout] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In2] \
  [get_bd_pins xlconcat_tx_rx_axi_clk/In3]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins axi_intc_lpd/intr]
  connect_bd_net -net const_gnd [get_bd_pins const_gnd/dout] \
  [get_bd_pins axi_intc_fpd/intr]
  connect_bd_net -net m_axis_tready_1  [get_bd_pins MRMAC_GT/tx_axis_tready_1] \
  [get_bd_pins DATAPATH_MCDMA_1/tx_axis_tready_0]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_axis/peripheral_aresetn] \
  [get_bd_pins proc_sys_reset_lite/ext_reset_in] \
  [get_bd_pins smartconnect_mcdma1/aresetn] \
  [get_bd_pins smartconnect_mcmdm0/aresetn] \
  [get_bd_pins DATAPATH_MCDMA_0/axis_tx_rstn] \
  [get_bd_pins DATAPATH_MCDMA_0/axis_rx_rstn] \
  [get_bd_pins DATAPATH_MCDMA_1/axis_rx_rstn] \
  [get_bd_pins DATAPATH_MCDMA_1/axis_tx_rstn] \
  [get_bd_pins axi_intc_lpd/s_axi_aresetn] \
  [get_bd_pins axi_intc_fpd/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_1_bus_struct_reset  [get_bd_pins proc_sys_reset_lite/bus_struct_reset] \
  [get_bd_pins MRMAC_GT/rx_flexif_reset]
  connect_bd_net -net proc_sys_reset_1_interconnect_aresetn  [get_bd_pins proc_sys_reset_lite/interconnect_aresetn] \
  [get_bd_pins smartconnect_axi_lite/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_lite/peripheral_aresetn] \
  [get_bd_pins smartconnect_gpios/aresetn] \
  [get_bd_pins MRMAC_GT/s_axi_aresetn] \
  [get_bd_pins DATAPATH_MCDMA_0/s_axi_lite_aresetn] \
  [get_bd_pins DATAPATH_MCDMA_1/s_axi_lite_aresetn]
  connect_bd_net -net rx_ts_clk_1  [get_bd_pins xlconcat_ts_clk/dout] \
  [get_bd_pins MRMAC_GT/rx_ts_clk]
  connect_bd_net -net s_axis_tdata_1  [get_bd_pins MRMAC_GT/rx_axis_tdata2] \
  [get_bd_pins DATAPATH_MCDMA_1/rx_axis_tdata0]
  connect_bd_net -net s_axis_tlast_1  [get_bd_pins MRMAC_GT/rx_axis_tlast_1] \
  [get_bd_pins DATAPATH_MCDMA_1/rx_axis_tlast_0]
  connect_bd_net -net s_axis_tvalid_1  [get_bd_pins MRMAC_GT/rx_axis_tvalid_1] \
  [get_bd_pins DATAPATH_MCDMA_1/rx_axis_tvalid_0]
  connect_bd_net -net ts_clk_to_zero_dout  [get_bd_pins ts_clk_to_zero/dout] \
  [get_bd_pins xlconcat_ts_clk/In2] \
  [get_bd_pins xlconcat_ts_clk/In3] \
  [get_bd_pins xlconcat_ts_clk/In0] \
  [get_bd_pins xlconcat_ts_clk/In1]
  connect_bd_net -net xlconcat_tx_rx_axi_clk_dout  [get_bd_pins xlconcat_tx_rx_axi_clk/dout] \
  [get_bd_pins MRMAC_GT/tx_axi_clk]

  # Create address segments
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces AIE_INI] [get_bd_addr_segs ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020200000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PCIE_PL_INI] [get_bd_addr_segs tieoff_unused/axi_vip_0/S_AXI/Reg] -force

  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C2_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_0/axi_mcdma_0/Data_MM2S] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C2_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_0/axi_mcdma_0/Data_S2MM] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C2_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_0/axi_mcdma_0/Data_SG] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C3_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_1/axi_mcdma_0/Data_MM2S] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C3_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_1/axi_mcdma_0/Data_S2MM] [get_bd_addr_segs M01_INI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_axi_noc_mc_1x_C3_DDR_LOW0 -target_address_space [get_bd_addr_spaces DATAPATH_MCDMA_1/axi_mcdma_0/Data_SG] [get_bd_addr_segs M01_INI/Reg] -force

  assign_bd_address -offset 0x020200800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_lpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200810000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs axi_intc_fpd/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200820000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs MRMAC_GT/axi_gpio_gt_rate_reset_ctl0/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200830000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs MRMAC_GT/axi_gpio_gt_rate_reset_ctl1/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200840000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs MRMAC_GT/axi_gpio_reset_mask/S_AXI/Reg] -force
  assign_bd_address -offset 0x020200850000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs DATAPATH_MCDMA_0/axi_mcdma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200860000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs DATAPATH_MCDMA_1/axi_mcdma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x020200870000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs MRMAC_GT/GT/gt_quad_base/APB3_INTF/Reg] -force
  assign_bd_address -offset 0x020200880000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs MRMAC_GT/mrmac_10g_156_core/s_axi/Reg] -force

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


