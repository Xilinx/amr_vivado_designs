# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_DSP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_LOGIC_BLOCKS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_RAMB_18_DC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_RAMB_36_DC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_URAM" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_DSP { PARAM_VALUE.NUM_DSP } {
	# Procedure called to update NUM_DSP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_DSP { PARAM_VALUE.NUM_DSP } {
	# Procedure called to validate NUM_DSP
	return true
}

proc update_PARAM_VALUE.NUM_LOGIC_BLOCKS { PARAM_VALUE.NUM_LOGIC_BLOCKS } {
	# Procedure called to update NUM_LOGIC_BLOCKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_LOGIC_BLOCKS { PARAM_VALUE.NUM_LOGIC_BLOCKS } {
	# Procedure called to validate NUM_LOGIC_BLOCKS
	return true
}

proc update_PARAM_VALUE.NUM_RAMB_18_DC { PARAM_VALUE.NUM_RAMB_18_DC } {
	# Procedure called to update NUM_RAMB_18_DC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_RAMB_18_DC { PARAM_VALUE.NUM_RAMB_18_DC } {
	# Procedure called to validate NUM_RAMB_18_DC
	return true
}

proc update_PARAM_VALUE.NUM_RAMB_36_DC { PARAM_VALUE.NUM_RAMB_36_DC } {
	# Procedure called to update NUM_RAMB_36_DC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_RAMB_36_DC { PARAM_VALUE.NUM_RAMB_36_DC } {
	# Procedure called to validate NUM_RAMB_36_DC
	return true
}

proc update_PARAM_VALUE.NUM_URAM { PARAM_VALUE.NUM_URAM } {
	# Procedure called to update NUM_URAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_URAM { PARAM_VALUE.NUM_URAM } {
	# Procedure called to validate NUM_URAM
	return true
}


proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_LOGIC_BLOCKS { MODELPARAM_VALUE.NUM_LOGIC_BLOCKS PARAM_VALUE.NUM_LOGIC_BLOCKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_LOGIC_BLOCKS}] ${MODELPARAM_VALUE.NUM_LOGIC_BLOCKS}
}

proc update_MODELPARAM_VALUE.NUM_RAMB_36_DC { MODELPARAM_VALUE.NUM_RAMB_36_DC PARAM_VALUE.NUM_RAMB_36_DC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_RAMB_36_DC}] ${MODELPARAM_VALUE.NUM_RAMB_36_DC}
}

proc update_MODELPARAM_VALUE.NUM_RAMB_18_DC { MODELPARAM_VALUE.NUM_RAMB_18_DC PARAM_VALUE.NUM_RAMB_18_DC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_RAMB_18_DC}] ${MODELPARAM_VALUE.NUM_RAMB_18_DC}
}

proc update_MODELPARAM_VALUE.NUM_DSP { MODELPARAM_VALUE.NUM_DSP PARAM_VALUE.NUM_DSP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_DSP}] ${MODELPARAM_VALUE.NUM_DSP}
}

proc update_MODELPARAM_VALUE.NUM_URAM { MODELPARAM_VALUE.NUM_URAM PARAM_VALUE.NUM_URAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_URAM}] ${MODELPARAM_VALUE.NUM_URAM}
}

