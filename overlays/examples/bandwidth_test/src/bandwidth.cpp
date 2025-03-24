/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/


#include <ap_int.h>

auto constexpr DATAWIDTH = 512;
using TYPE = ap_uint<DATAWIDTH>;

extern "C" {
void bandwidth(TYPE* input, TYPE* output, unsigned int buf_size, unsigned int reps) {
    unsigned int num_blocks = (buf_size - 1) / 64 + 1;
read_write:
    for (int repindex = 0; repindex < reps; repindex++) {
        for (int blockindex = 0; blockindex < num_blocks; blockindex++) {
            TYPE temp = input[blockindex];
            output[blockindex] = temp;
        }
    }
}
}
