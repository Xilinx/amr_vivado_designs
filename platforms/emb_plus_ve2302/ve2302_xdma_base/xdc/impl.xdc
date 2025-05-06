# Copyright (C) 2023 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

# Timing
# ------------------------------------------------------------------------------

# JUSTIFICIATION:  Kernel interrupts are level triggered but may be driven by a flop on an arbitrary clock source within the kernel.
# The set_false_path suppresses false timing failures that would otherwise be reported.


