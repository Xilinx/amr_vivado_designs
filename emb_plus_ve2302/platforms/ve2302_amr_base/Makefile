# Copyright (C) 2025, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

SHELL := /bin/bash

RM = rm -rf
PWD = $(shell readlink -f .)

VIVADO = $(XILINX_VIVADO)/bin/vivado
SDTGEN = $(XILINX_VIVADO)/bin/sdtgen
JOBS ?= 8
VIV_PRJ_DIR = project
VIV_SCRIPTS_DIR = scripts

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"
VIV_DESIGN = ve2302_amr_base
VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl
VIV_CONFIG = $(VIV_SCRIPTS_DIR)/config_bd.tcl

# SDT generation
VIV_SDT = project_sdt
SDT_SCRIPT_DIR = ../scripts
SDT_SRC = $(SDT_SCRIPT_DIR)/gen_sdt_dfx.tcl

# deb
VERSION = 2.0
MAINTAINER = AMD
BOARD = ve2302
DFX_LIST := bram_gpio
# Build up lists
DFX_FILES_LIST := $(foreach DFX,$(DFX_LIST),$(VIV_PRJ_DIR)/partial_pdis/$(DFX)_partial.pdi)
DEB_FILES_LIST := $(foreach DFX,$(DFX_LIST),amr-$(DFX)-dma-test-$(BOARD)_$(VERSION).deb)
DFX_XSA_LIST := $(foreach DFX,$(DFX_LIST),$(VIV_PRJ_DIR)/$(VIV_DESIGN)_$(DFX).xsa)
DFX_FILE = $(VIV_PRJ_DIR)/partial_pdis/${DFX}_partial.pdi
EXAMPLE_LIST := $(subst _,-,$(DFX_LIST))

# Each item in combined list will be in the format of DFX:EXAMPLE:DFX_FILE:DEB_FILE
MAX_LEN := $(words $(DFX_LIST))
COMBINED_LIST := $(foreach i, $(shell seq 1 $(MAX_LEN)), \
    $(word $(i), $(DFX_LIST)):$(word $(i), $(EXAMPLE_LIST)):$(word $(i), $(DFX_FILES_LIST)):$(word $(i), $(DEB_FILES_LIST)) \
)

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>]'
	@echo '    Generate xsa '
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
all: xsa sdt deb

$(DFX_FILES_LIST): $(VIV_XSA)

xsa: $(VIV_XSA)
$(VIV_XSA): $(VIV_SRC) $(VIV_CONFIG)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi

sdt: $(SDT_SRC) $(VIV_XSA)
	$(SDTGEN) $(SDT_SRC) -xsa_path $(VIV_XSA) -rm "$(DFX_XSA_LIST)"
	tclsh $(SDT_SCRIPT_DIR)/fix_dtsi.tcl

.PHONY: deb
deb: $(DEB_FILES_LIST)
$(DEB_FILES_LIST): $(DFX_FILES_LIST)
	@echo $(COMBINED_LIST)
	@for item in $(COMBINED_LIST); do \
		echo "Processing item: $$item"; \
		OLD_IFS="$$IFS"; \
		IFS=':'; \
		read -r DFX EXAMPLE DFX_FILE DEB_FILE <<< "$$item"; \
		echo "  Part 1: $$DFX"; \
		echo "  Part 2: $$EXAMPLE"; \
		echo "  Part 3: $$DFX_FILE"; \
		echo "  Part 4: $$DEB_FILE"; \
		IFS=$$OLD_IFS; \
		BUILD_DIR="`echo amr-$$EXAMPLE-dma-test-$(BOARD)`"; \
		echo "BUILD_DIR = $$BUILD_DIR"; \
		DEB_DIR="`echo $$BUILD_DIR/opt/xilinx/firmware/emb_plus/ve2302_bram_gpio/base/test/`"; \
		echo "DEB_DIR = $$DEB_DIR"; \
		mkdir -p $$DEB_DIR; \
		mkdir -p $$BUILD_DIR/DEBIAN; \
		chmod 00755 $$BUILD_DIR/DEBIAN; \
		CONTROL_FILE="`echo $$BUILD_DIR/DEBIAN/control`"; \
		echo "CONTROL_FILE = $$CONTROL_FILE"; \
		echo "Package: $$BUILD_DIR" > $$CONTROL_FILE; \
		echo "Architecture: all" >> $$CONTROL_FILE; \
		echo "Version: $(VERSION)" >> $$CONTROL_FILE; \
		echo "Priority: optional" >> $$CONTROL_FILE; \
		echo "Description: $(KERNEL) firmware" >> $$CONTROL_FILE; \
		echo "Maintainer: $(MAINTAINER)" >> $$CONTROL_FILE; \
		cp $$DFX_FILE $$DEB_DIR; \
		echo "Now generating the debian package for $$DFX called $$DEB_FILE"; \
		dpkg-deb --build ./$$BUILD_DIR; \
		mv $$BUILD_DIR.deb $$DEB_FILE; \
		ls $$DEB_FILE; \
	done

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log* *.xpe .crashReporter hd_visual *.swp
	$(RM) $(VIV_SDT) $(BUILD_DIR) $(DEB_FILE)
	@for item in $(COMBINED_LIST); do \
		IFS=':' read -r DFX EXAMPLE DFX_FILE DEB_FILE <<< "$$item"; \
		BUILD_DIR="`echo amr-$$EXAMPLE-dma-test-$(BOARD)`"; \
		$(RM) $$BUILD_DIR; \
	done
