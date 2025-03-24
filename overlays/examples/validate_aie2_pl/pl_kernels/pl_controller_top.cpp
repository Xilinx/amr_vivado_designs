/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
#include "pl_controller_kernel.hpp"
#define N 1
#if N > 1
extern "C" void
pl_controller_top(hls::stream<ap_axiu<8, 0, 0, 0>> &syncOut,
                  hls::stream<ap_axiu<8, 0, 0, 0>> &syncIn,
                  ap_uint<32> ctrlPktID, ap_uint<32> *pm,
                  hls::stream<ap_axiu<32, 0, 0, 0>> ctrlOut[N]) {

#pragma HLS interface axis port = syncOut
#pragma HLS interface axis port = syncIn
#if N == 2
#pragma HLS interface axis port = ctrlOut[0]
#pragma HLS interface axis port = ctrlOut[1]
#endif

#pragma HLS interface s_axilite port = ctrlPktID bundle = control

#pragma HLS interface m_axi port = pm offset = slave bundle = gmem
#pragma HLS interface s_axilite port = pm bundle = control

#pragma HLS interface s_axilite port = return bundle = control
  xf::plctrl::pl_controller_kernel<N>(ctrlOut, syncOut, syncIn, ctrlPktID, pm);
};
#else
extern "C" void pl_controller_top(hls::stream<ap_axiu<8, 0, 0, 0>> &syncOut,
                                  hls::stream<ap_axiu<8, 0, 0, 0>> &syncIn,
                                  ap_uint<32> ctrlPktID, ap_uint<32> *pm,
                                  hls::stream<ap_axiu<32, 0, 0, 0>> &ctrlOut) {

#pragma HLS interface axis port = syncOut
#pragma HLS interface axis port = syncIn
#pragma HLS interface axis port = ctrlOut

#pragma HLS interface s_axilite port = ctrlPktID bundle = control

#pragma HLS interface m_axi port = pm offset = slave bundle = gmem
#pragma HLS interface s_axilite port = pm bundle = control

#pragma HLS interface s_axilite port = return bundle = control
  xf::plctrl::pl_controller_kernel_1(ctrlOut, syncOut, syncIn, ctrlPktID, pm);
};
#endif
