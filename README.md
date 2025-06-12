# emb_plus_vivado_designs


## Introduction

This repo is used to capture Vivado XSA generation of the Embedded+ HW/PL platform
The emb_plus_ve2302 hw_platform targets the ve2302 FPGA.

## Contents

This repo contains several flat designs (non-DFX) and a DFX design with a single
reconfigurable region.

### Flat Designs
- ve2302_1gEth      - Two channels of 1G Ethernet
- ve2302_10g_mrmac  - Two 10G Ethernet channels utilizing the MRMAC hard block in Versal
- ve2302_gmsl       - Versal-only GMSL pipeline
- ve2302_xdma_gmsl  - GMSL pipeline with XDMA/PCIe

### DFX Designs

Consists of the base design and different modules that can be inserted into the
reconfigurable region.

- ve2302_xdma_base  - Base design for DFX, initially containing the bram_gpio RM.

There is currently only one RM available for this design, but the repo will expand
to contain more in the future.

- bram_gpio

## Tools Version

This branch is targeting the Vivado 2025.1 tools.

## Instructions

To clone this repo, run:
```
git clone https://github.com/Xilinx/emb_plus_vivado_designs.git
```

## Directory Structure

The directory structure of the repository is shown as follows:
```
emb_plus_vivado_designs
+-- emb_plus_ve2302
¦ +-- dfx
¦ ¦  +-- bram_gpio
¦ +-- platforms
¦ ¦  +-- scripts
¦ ¦  +-- ve2302_1gEth
¦ ¦  +-- ve2302_10g_mrmac
¦ ¦  +-- ve2302_gmsl
¦ ¦  +-- ve2302_xdma_base
¦ ¦  +-- ve2302_xdma_gmsl
+-- README
```

## Build Instructions

To build the flat designs, run the following from the directory for the platform
you want to build:

```
make all
```

To build the DFX design, run the following from ve2302_xdma_base directory:

```
make all DFX=bram_gpio
```

Since there is only one DFX module being supported, it defaults to bram_gpio, so the
DFX=bram_gpio flag can be omitted.  When more DFX modules are supported, pass the
other flavors in this manner.  The name of the module should match the directory name
under the dfx subdirectory.

The outputs of the Vivado build will be under project directory for each platform.

## License

Copyright (C) 2024 - 2025 Advanced Micro Devices, Inc.
SPDX-License-Identifier: MIT
