# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "M_AXI_ADDR_WIDTH" -parent ${Page_0}
  set REMAP_ADDR [ipgui::add_param $IPINST -name "REMAP_ADDR" -parent ${Page_0}]
  set_property tooltip {Slave address to be remapped} ${REMAP_ADDR}
  ipgui::add_param $IPINST -name "S_AXI_ADDR_WIDTH" -parent ${Page_0}
  set TRANS_ADDR [ipgui::add_param $IPINST -name "TRANS_ADDR" -parent ${Page_0}]
  set_property tooltip {New mapping for master} ${TRANS_ADDR}


}

proc update_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to update M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to validate M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.REMAP_ADDR { PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to update REMAP_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REMAP_ADDR { PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to validate REMAP_ADDR
	return true
}

proc update_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to update S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to validate S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.TRANS_ADDR { PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to update TRANS_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRANS_ADDR { PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to validate TRANS_ADDR
	return true
}


proc update_MODELPARAM_VALUE.S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.S_AXI_ADDR_WIDTH PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.M_AXI_ADDR_WIDTH PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.REMAP_ADDR { MODELPARAM_VALUE.REMAP_ADDR PARAM_VALUE.REMAP_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REMAP_ADDR}] ${MODELPARAM_VALUE.REMAP_ADDR}
}

proc update_MODELPARAM_VALUE.TRANS_ADDR { MODELPARAM_VALUE.TRANS_ADDR PARAM_VALUE.TRANS_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRANS_ADDR}] ${MODELPARAM_VALUE.TRANS_ADDR}
}

