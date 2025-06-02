# Copyright (C) 2025, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

set f [open "./project_sdt/pl.dtsi" "r"]
set content [read $f]
close $f

regsub -all "blp_xdma_lite_addr_mask: axi_addr_mask@0 {" $content "blp_xdma_lite_addr_mask: axi_addr_mask@1 {" newContent

set f [open "./project_sdt/pl.dtsi" "w"]
puts -nonewline $f $newContent
close $f
