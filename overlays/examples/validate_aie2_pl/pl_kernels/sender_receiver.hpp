/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
#ifndef _SENDER_RECEIVER_HPP_
#define _SENDER_RECEIVER_HPP_
#include "ap_axi_sdata.h"
#include "ap_int.h"
#include "enums.hpp"
#include "hls_stream.h"

static void mm2s(ap_uint<32> *mem, hls::stream<ap_axiu<32, 0, 0, 0>> &s,
                 int size) {
  for (int i = 0; i < size; i++) {
#pragma HLS PIPELINE II = 1
    ap_axiu<32, 0, 0, 0> x;
    x.data = mem[i];
    x.keep = -1;
    if (i == size - 1)
      x.last = 1;
    else
      x.last = 0;
    s.write(x);
  }
}

static void s2mm(ap_uint<32> *mem, hls::stream<ap_axiu<32, 0, 0, 0>> &s,
                 int size) {
  for (int i = 0; i < size; i++) {
#pragma HLS PIPELINE II = 1
    ap_axiu<32, 0, 0, 0> x = s.read();
    mem[i] = x.data;
  }
}
static void send_receive_df(ap_uint<32> *mem_in, ap_uint<32> *mem_out,
                            hls::stream<ap_axiu<32, 0, 0, 0>> &s_in,
                            hls::stream<ap_axiu<32, 0, 0, 0>> &s_out,
                            int size) {
#pragma HLS dataflow
  mm2s(mem_in, s_out, size);
  s2mm(mem_out, s_in, size);
}

extern "C" {

void sender_receiver(int loop_count, int num_sample, ap_uint<32> *mem_in,
                     ap_uint<32> *mem_out,
                     hls::stream<ap_axiu<32, 0, 0, 0>> &s_in,
                     hls::stream<ap_axiu<32, 0, 0, 0>> &s_out,
                     hls::stream<ap_axiu<8, 0, 0, 0>> &sync_in,
                     hls::stream<ap_axiu<8, 0, 0, 0>> &sync_out);
}

#endif
