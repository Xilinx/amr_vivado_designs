# Copyright (C) 2025 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT


create_pblock pblock_ulp
add_cells_to_pblock [get_pblocks pblock_ulp] [get_cells -quiet [list ve2302_xdma_base_i/DFX_RP]]
resize_pblock [get_pblocks pblock_ulp] -add {SLICE_X0Y92:SLICE_X15Y111 SLICE_X0Y112:SLICE_X99Y187}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCE_X2Y0:BUFGCE_X2Y23}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCE_HDIO_X0Y0:BUFGCE_HDIO_X0Y3}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCE_DIV_X3Y0:BUFGCE_DIV_X3Y3}
resize_pblock [get_pblocks pblock_ulp] -add {BUFGCTRL_X3Y0:BUFGCTRL_X3Y7}
resize_pblock [get_pblocks pblock_ulp] -add {DPLL_X0Y0:DPLL_X1Y3}
resize_pblock [get_pblocks pblock_ulp] -add {DSP58_CPLX_X0Y29:DSP58_CPLX_X1Y93}
resize_pblock [get_pblocks pblock_ulp] -add {DSP_X0Y29:DSP_X3Y93}
resize_pblock [get_pblocks pblock_ulp] -add {GCLK_PD_X2Y96:GCLK_PD_X2Y143}
resize_pblock [get_pblocks pblock_ulp] -add {HDIOLOGIC_X0Y0:HDIOLOGIC_X0Y10}
resize_pblock [get_pblocks pblock_ulp] -add {IOB_X13Y3:IOB_X13Y13}
resize_pblock [get_pblocks pblock_ulp] -add {IRI_QUAD_X0Y396:IRI_QUAD_X66Y983}
resize_pblock [get_pblocks pblock_ulp] -add {MMCM_X0Y0:MMCM_X3Y0}
resize_pblock [get_pblocks pblock_ulp] -add {NOC_NMU512_X0Y3:NOC_NMU512_X0Y4}
resize_pblock [get_pblocks pblock_ulp] -add {NOC_NSU512_X0Y1:NOC_NSU512_X0Y4}
resize_pblock [get_pblocks pblock_ulp] -add {RAMB18_X0Y48:RAMB18_X2Y119}
resize_pblock [get_pblocks pblock_ulp] -add {RAMB36_X0Y24:RAMB36_X2Y59}
resize_pblock [get_pblocks pblock_ulp] -add {URAM288_X0Y24:URAM288_X2Y59}
resize_pblock [get_pblocks pblock_ulp] -add {URAM_CAS_DLY_X0Y1:URAM_CAS_DLY_X2Y1}
resize_pblock [get_pblocks pblock_ulp] -add {CLOCKREGION_X3Y0:CLOCKREGION_X3Y0 CLOCKREGION_X0Y3:CLOCKREGION_X2Y3 CLOCKREGION_X0Y4:CLOCKREGION_X3Y4}
set_property SNAPPING_MODE ON [get_pblocks pblock_ulp]
set_property DONT_TOUCH true [get_cells */DFX_RP]


# Lock NMU512 and NSU512 for STATIC_DESIGN
set_property LOC NOC_NMU512_X0Y0 [get_cells */STATIC_DESIGN/axi_noc_ic/inst/S06_AXI_nmu/*/NOC_NMU512_INST]
set_property LOC NOC_NMU512_X0Y1 [get_cells */STATIC_DESIGN/axi_noc_ic/inst/S07_AXI_nmu/*/NOC_NMU512_INST]
set_property LOC NOC_NMU512_X0Y2 [get_cells */STATIC_DESIGN/axi_noc_ic/inst/S08_AXI_nmu/*/NOC_NMU512_INST]
set_property LOC NOC_NSU512_X0Y0 [get_cells */STATIC_DESIGN/axi_noc_ic/inst/M00_AXI_nsu/*/NOC_NSU512_INST]

