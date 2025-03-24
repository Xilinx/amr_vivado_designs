/**
* Copyright (C) 2023 Advanced Micro Devices, Inc.
* SPDX-License-Identifier: MIT
*/
#ifndef _XF_PLCTRLAIE_ENUMS_HPP_
#define _XF_PLCTRLAIE_ENUMS_HPP_
namespace xf {
namespace plctrl {
namespace enums {
enum { SYNC_REQ = 0, SYNC_ACK = 1 };
enum {
  ADF_GRAPH_RUN = 0,
  ADF_GRAPH_WAIT = 1,
  ADF_GRAPH_RTP_UPDATE = 2,
  ADF_GRAPH_RTP_READ = 3,
  WAIT_FOR_DMA_IDLE = 4,
  SET_DMA_BD_LENGTH = 5,
  ENQUEUE_DMA_BD = 6,
  LOAD_AIE_PM = 7,
  SLEEP = 8,
  HALT = 9,
  SET_AIE_ITERATION = 10,
  ENABLE_AIE_CORES = 11,
  DISABLE_AIE_CORES = 12,
  SYNC = 13,
  LOOP_BEGIN = 14,
  LOOP_END = 15,
  SET_DMA_BD = 16,
  UPDATE_AIE_RTP = 17,
  WRITE
};
} // end of namespace enums
using namespace enums;

} // end of namespace plctrl

} // end of pl
#endif
