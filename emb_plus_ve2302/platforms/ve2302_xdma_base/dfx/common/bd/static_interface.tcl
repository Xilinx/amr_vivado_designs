# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

  # Create interface ports to STATIC_DESIGN
  set AIE_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name AIE_INI_internoc direction I left 0 right 0 } \
   } \
  AIE_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $AIE_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports AIE_INI]

  set M00_INI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name M00_INI_internoc direction O left 0 right 0 } \
   } \
  M00_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $M00_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports M00_INI]

  set M01_INI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name M01_INI_internoc direction O left 0 right 0 } \
   } \
  M01_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $M01_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports M01_INI]

  set PCIE_PL_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name PCIE_PL_INI_internoc direction I left 0 right 0 } \
   } \
  PCIE_PL_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $PCIE_PL_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports PCIE_PL_INI]

  set S00_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name S00_INI_internoc direction I left 0 right 0 } \
   } \
  S00_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $S00_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports S00_INI]

# Create unique I/O interface ports to/from board for 10G Ethernet design
  set CLK_IN_D [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -default_portmap CLK_IN_D ]
  set_property HDL_ATTRIBUTE.LOCKED TRUE $CLK_IN_D
  set GT_Serial [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 -default_portmap GT_Serial ]
  set_property HDL_ATTRIBUTE.LOCKED TRUE $GT_Serial

    # Create ports to STATIC REGION
  set pcie_aclk [ create_bd_port -dir I -type clk -freq_hz 125000000 pcie_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {pcie_aresetn} \
 ] $pcie_aclk

  set pcie_aresetn [ create_bd_port -dir I -type rst pcie_aresetn ]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_aresetn

  set pl_0_clk [ create_bd_port -dir I -type clk -freq_hz 99999901 pl_0_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {pl_0_resetn} \
 ] $pl_0_clk

  set pl_0_resetn [ create_bd_port -dir I -type rst pl_0_resetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pl_0_resetn

  set pl_1_clk [ create_bd_port -dir I -type clk -freq_hz 199999802 pl_1_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {pl_1_resetn} \
 ] $pl_1_clk

  set pl_1_resetn [ create_bd_port -dir I -type rst pl_1_resetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pl_1_resetn

  set lpd_interrupt [ create_bd_port -dir O -type intr lpd_interrupt ]
  set fpd_interrupt [ create_bd_port -dir O -type intr fpd_interrupt ]

  # Create instance: axi_noc_fixed_0, and set properties
  # Interface to STATIC_DESIGN/M_PL_INI
  set axi_noc_fixed_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_fixed_0 ]
  set_property -dict [list \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_fixed_0

  set_property -dict [ list \
   CONFIG.APERTURES {{0x202_0080_0000 8M}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_fixed_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /axi_noc_fixed_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /axi_noc_fixed_0/aclk0]

  # Create instance: axi_noc_fixed_1, and set properties
  # Interface to STATIC_DESIGN/S00_DDR_INI and STATIC_DESIGN/S01_DDR_INI
  set axi_noc_fixed_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_fixed_1 ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_SI {2} \
  ] $axi_noc_fixed_1

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /axi_noc_fixed_1/M00_INI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
 ] [get_bd_intf_pins /axi_noc_fixed_1/M01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_fixed_1/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_fixed_1/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI} \
 ] [get_bd_pins /axi_noc_fixed_1/aclk0]

  # Create instance: axi_intc_lpd, and set properties
  # Interfaces to STATIC_DESIGN/lpd_intr
  set axi_intc_lpd [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_lpd ]
  set_property CONFIG.C_IRQ_CONNECTION {1} $axi_intc_lpd

  # Create instance: axi_intc_fpd, and set properties
  # Interfaces to STATIC_DESIGN/fpd_intr
  set axi_intc_fpd [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_fpd ]
  set_property CONFIG.C_IRQ_CONNECTION {1} $axi_intc_fpd

  # Create instance: axi_noc_pcie_fixed, and set properties
  set axi_noc_pcie_fixed [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_pcie_fixed ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_pcie_fixed

  set_property -dict [ list \
   CONFIG.CATEGORY {pl} \
   CONFIG.APERTURES {{0x202_0000_0000 8M}} \
 ] [get_bd_intf_pins /axi_noc_pcie_fixed/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /axi_noc_pcie_fixed/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /axi_noc_pcie_fixed/aclk0]

  # Create instance: ConfigNoc, and set properties
  set ConfigNoc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc ConfigNoc ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {0} \
  ] $ConfigNoc

  set_property -dict [ list \
   CONFIG.CATEGORY {aie} \
 ] [get_bd_intf_pins /ConfigNoc/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}} \
 ] [get_bd_intf_pins /ConfigNoc/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /ConfigNoc/aclk0]

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine ai_engine_0 ]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins /ai_engine_0/S00_AXI]

  # Create interface connections
  connect_bd_intf_net -intf_net M01_INI [get_bd_intf_pins axi_noc_fixed_1/M01_INI] [get_bd_intf_ports M01_INI]
  connect_bd_intf_net -intf_net M00_INI [get_bd_intf_pins axi_noc_fixed_1/M00_INI] [get_bd_intf_ports M00_INI]
  connect_bd_intf_net -intf_net S00_INI [get_bd_intf_pins axi_noc_fixed_0/S00_INI] [get_bd_intf_ports S00_INI]
  connect_bd_intf_net -intf_net ConfigNoc_M00_AXI [get_bd_intf_pins ConfigNoc/M00_AXI] [get_bd_intf_pins ai_engine_0/S00_AXI]
  connect_bd_intf_net -intf_net AIE_INI [get_bd_intf_ports AIE_INI] [get_bd_intf_pins ConfigNoc/S00_INI]
  connect_bd_intf_net -intf_net PCIE_PL_INI [get_bd_intf_ports PCIE_PL_INI] [get_bd_intf_pins axi_noc_pcie_fixed/S00_INI]

  connect_bd_net -net ai_engine_0_s00_axi_aclk  [get_bd_pins ai_engine_0/s00_axi_aclk] \
  [get_bd_pins ConfigNoc/aclk0]
  connect_bd_net -net fpd_interrupt  [get_bd_pins axi_intc_fpd/irq] \
  [get_bd_ports fpd_interrupt]
  connect_bd_net -net lpd_interrupt  [get_bd_pins axi_intc_lpd/irq] \
  [get_bd_ports lpd_interrupt]

