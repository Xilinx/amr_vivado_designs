# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# This is a configuration file for the board_test design.
# It is used to set up the design for a specific board and variant.
################################################################

proc variant_get {variant key} {
    global variant_cfg
    return [dict get $variant_cfg $variant $key]
}

# Dictionary, variant_cfg, contains the variant configurations and TAGS for verify BRAM
set variant_cfg {
    func {
        verify_tag FUNC
        verify_mem_file verify_func.mem
        verify_map_file verify_func_map.txt

        num_dsp          30
        num_logic_blocks 11
        num_ramb18        7
        num_ramb36        3
        num_uram          5
    }

    stress {
        verify_tag STRS
        verify_mem_file verify_stress.mem
        verify_map_file verify_stress_map.txt

        num_dsp          330
        num_logic_blocks 150
        num_ramb18        100
        num_ramb36        50
        num_uram          108
    }
}
