# emb_plus_vivado_designs


## Introduction

This repo is used to capture Vivado XSA generation of the Embedded+ HW/PL platform
The emb_plus_ve2302 hw_platform targets the ve2302 FPGA.

## Contents

### DFX Designs

Consists of the base design and different modules that can be inserted into the
reconfigurable region.

- ve2302_xdma_base  - Base design for DFX

There are currently two RMs available for this design, but the repo will expand
to contain more in the future.

- bram_gpio 	(simple design for testing)
- eth_10g 	(dual 10g MRMAC paths)

## Tools Version

This branch is targeting the Vivado 2026.1 tools.

## Instructions

To clone this repo, run:
```
git clone https://github.com/Xilinx/amr_vivado_designs.git
```

## Directory Structure

The directory structure of the repository is shown as follows:
```
amr_vivado_designs
+-- alveo_v80
| +-- platforms
| |  +-- scripts
| |  +-- v80_base
+-- emb_plus_ve2302
| +-- platforms
| |  +-- ip 
| |  +-- scripts
| |  +-- ve2302_amr_base
| |  | +-- dfx
| |  | |  +-- bram_gpio
| |  | +-- scripts 
| |  | +-- xdc
| |  +-- ve2302_xdma_base
| |  | +-- dfx
| |  | |  +-- bram_gpio
| |  | |  +-- common
| |  | |  +-- eth_10g 
| |  | |  +-- training
| |  | +-- hdl
| |  | +-- scripts 
| |  | +-- xdc
+-- LICENSE
+-- README.md
```

## Build Instructions

To build any of the designs, run the following from the directory for the platform
you want to build:

```
make all
```

The outputs of the Vivado build will be under project directory for each platform.

## License

Copyright (C) 2024 - 2026 Advanced Micro Devices, Inc.
SPDX-License-Identifier: MIT
