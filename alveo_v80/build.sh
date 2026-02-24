#!/usr/bin/env bash
# Copyright (c) 2026 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT

set -Eeuo pipefail

DESIGN="alveo_v80"

# Local variables - determine script location
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${ROOT_DIR}/src"
BUILD_DIR="$(pwd)/build_${DESIGN}"
SDT_DIR="${BUILD_DIR}/sdt"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage:"
  echo ""
  echo "  ${0} [JOBS=<n>]"
  echo "    Generate xsa + sdt (default)"
  echo ""
  echo "Environment:"
  echo "  JOBS: optional param to set number of synthesis jobs (default: 8)"
  echo ""
  exit 0
fi

mkdir -p "${BUILD_DIR}"

vivado \
	-source "${SRC_DIR}/create_design.tcl" \
	-source "${SRC_DIR}/build_design.tcl" \
	-mode batch \
	-notrace \
	-nojournal \
	-tclargs -jobs ${JOBS:-8} \
	-log "${BUILD_DIR}/vivado.log" && \
	sdtgen -eval "sdtgen set_dt_param -xsa ${BUILD_DIR}/${DESIGN}.xsa -dir ${SDT_DIR}; generate_sdt"
echo "BUILD_DIR: ${BUILD_DIR}"
