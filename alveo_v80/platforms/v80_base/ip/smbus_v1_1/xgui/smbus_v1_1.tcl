# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
#
# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_FREQ_HZ_AXI_ACLK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_NUM_TARGET_DEVICES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_SMBUS_DEV_CLASS" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to update C_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to validate C_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_FREQ_HZ_AXI_ACLK { PARAM_VALUE.C_FREQ_HZ_AXI_ACLK } {
	# Procedure called to update C_FREQ_HZ_AXI_ACLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FREQ_HZ_AXI_ACLK { PARAM_VALUE.C_FREQ_HZ_AXI_ACLK } {
	# Procedure called to validate C_FREQ_HZ_AXI_ACLK
	return true
}

proc update_PARAM_VALUE.C_NUM_TARGET_DEVICES { PARAM_VALUE.C_NUM_TARGET_DEVICES } {
	# Procedure called to update C_NUM_TARGET_DEVICES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_TARGET_DEVICES { PARAM_VALUE.C_NUM_TARGET_DEVICES } {
	# Procedure called to validate C_NUM_TARGET_DEVICES
	return true
}

proc update_PARAM_VALUE.C_SMBUS_DEV_CLASS { PARAM_VALUE.C_SMBUS_DEV_CLASS } {
	# Procedure called to update C_SMBUS_DEV_CLASS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SMBUS_DEV_CLASS { PARAM_VALUE.C_SMBUS_DEV_CLASS } {
	# Procedure called to validate C_SMBUS_DEV_CLASS
	return true
}


proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SMBUS_DEV_CLASS { MODELPARAM_VALUE.C_SMBUS_DEV_CLASS PARAM_VALUE.C_SMBUS_DEV_CLASS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SMBUS_DEV_CLASS}] ${MODELPARAM_VALUE.C_SMBUS_DEV_CLASS}
}

proc update_MODELPARAM_VALUE.C_NUM_TARGET_DEVICES { MODELPARAM_VALUE.C_NUM_TARGET_DEVICES PARAM_VALUE.C_NUM_TARGET_DEVICES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_TARGET_DEVICES}] ${MODELPARAM_VALUE.C_NUM_TARGET_DEVICES}
}

proc update_MODELPARAM_VALUE.C_FREQ_HZ_AXI_ACLK { MODELPARAM_VALUE.C_FREQ_HZ_AXI_ACLK PARAM_VALUE.C_FREQ_HZ_AXI_ACLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FREQ_HZ_AXI_ACLK}] ${MODELPARAM_VALUE.C_FREQ_HZ_AXI_ACLK}
}

proc update_MODELPARAM_VALUE.C_MINOR_VERSION { MODELPARAM_VALUE.C_MINOR_VERSION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_MINOR_VERSION". Setting updated value from the model parameter.
set_property value 0 ${MODELPARAM_VALUE.C_MINOR_VERSION}
}

proc update_MODELPARAM_VALUE.C_MAJOR_VERSION { MODELPARAM_VALUE.C_MAJOR_VERSION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_MAJOR_VERSION". Setting updated value from the model parameter.
set_property value 1 ${MODELPARAM_VALUE.C_MAJOR_VERSION}
}

proc update_MODELPARAM_VALUE.C_CORE_REVISION { MODELPARAM_VALUE.C_CORE_REVISION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_CORE_REVISION". Setting updated value from the model parameter.
set_property value 0 ${MODELPARAM_VALUE.C_CORE_REVISION}
}

proc update_MODELPARAM_VALUE.C_PATCH_REVISION { MODELPARAM_VALUE.C_PATCH_REVISION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_PATCH_REVISION". Setting updated value from the model parameter.
set_property value 0 ${MODELPARAM_VALUE.C_PATCH_REVISION}
}

