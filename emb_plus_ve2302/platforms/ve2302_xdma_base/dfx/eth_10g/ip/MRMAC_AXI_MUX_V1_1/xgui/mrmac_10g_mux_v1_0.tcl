# Copyright (C) 2020 - 2022 Xilinx, Inc.
# Copyright (C) 2023 - 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}


