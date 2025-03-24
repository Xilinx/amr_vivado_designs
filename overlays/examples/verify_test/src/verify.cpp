/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/

extern "C" {
void verify(char* buf) {
    buf[0] = 'H';
    buf[1] = 'e';
    buf[2] = 'l';
    buf[3] = 'l';
    buf[4] = 'o';
    buf[5] = ' ';
    buf[6] = 'W';
    buf[7] = 'o';
    buf[8] = 'r';
    buf[9] = 'l';
    buf[10] = 'd';
    buf[11] = '\n';
    buf[12] = '\0';
}
}
