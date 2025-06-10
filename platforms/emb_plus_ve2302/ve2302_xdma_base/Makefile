# Copyright (C) 2025, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
SDTGEN = $(XILINX_VIVADO)/bin/sdtgen
JOBS ?= 8
VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"
VIV_DESIGN = ve2302_xdma_base
VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl
VIV_CONFIG = $(VIV_SCRIPTS_DIR)/config_bd.tcl

# SDT generation
VIV_SDT = project_sdt
SDT_SCRIPT_DIR = ../scripts
SDT_SRC = $(SDT_SCRIPT_DIR)/gen_sdt.tcl


.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>]'
	@echo '    Generate xsa'
	@echo ''
	@echo '  make sdt'
	@echo '    Generate sdt files'
	@echo ''
	@echo '  make all [JOBS=<n>]'
	@echo '    Generate xsa and sdt files'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo ''

.PHONY: all
all: xsa sdt

xsa: $(VIV_XSA)
$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi

sdt: $(SDT_SRC) $(VIV_XSA)
	$(SDTGEN) $(SDT_SRC) -xsa_path $(VIV_XSA)
	tclsh $(SDT_SCRIPT_DIR)/fix_dtsi.tcl

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp
	$(RM) $(VIV_SDT)
