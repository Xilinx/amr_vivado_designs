# Copyright (C) 2024, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
SILICON ?= prod


VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"

ifeq ($(SILICON), es1)
  VIV_DESIGN = ve2302_es1_pcie_qdma
else
  VIV_DESIGN = ve2302_pcie_qdma
endif

VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl
VIV_CONFIG = $(VIV_SCRIPTS_DIR)/config_bd.tcl

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>] [SILICON=<es1,prod>]'
	@echo '    Generate extensible xsa for platform generation'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo '    SILICON: optional param to choose es1 or production  (default: prod)'
	@echo ''


.PHONY: all
all: xsa

xsa: $(VIV_XSA)

$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS) -silicon $(SILICON)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp

