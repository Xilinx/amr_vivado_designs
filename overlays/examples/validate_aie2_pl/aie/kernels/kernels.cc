/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
/* A simple kernel
 */
#include <adf.h>
#include "include.h"

void simple(input_window_int32* win, output_window_int32* wout) {
    int32 tmp;
    printf("simple: Entering...\n");
    for (unsigned i = 0; i < 32; i++) {
        window_readincr(win, tmp);
        printf("simple: i=%d, win=%d, wout=%d\n", i, tmp, tmp + 1);
        tmp++;
        window_writeincr(wout, tmp);
    }
    printf("simple: Returning...\n");
}
