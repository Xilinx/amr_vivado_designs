# Copyright (C) 2024, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
SILICON ?= prod

VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

ifeq ($(SILICON), es1)
  UUID = $(UUID_ES1)
  VIV_DESIGN = ve2302_es1_10g_mrmac
else
  UUID = $(UUID_PROD)
  VIV_DESIGN = ve2302_10g_mrmac
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
	
.PHONY: xsa
xsa: $(VIV_XSA)
$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS) -silicon $(SILICON)	

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe

