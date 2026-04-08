// Copyright (C) 2022-2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
//
////////////////////////////////////////////////////////////
//
// SMBus IP Package
//
////////////////////////////////////////////////////////////

package smbus_v1_1_pkg;

// --------------------------------------------------------
// Time Units/Precision
// --------------------------------------------------------
// synthesis translate_off
timeunit 1ns/1ps;
// synthesis translate_on

// --------------------------------------------------------
// Parameters
// --------------------------------------------------------
// SMBus AC Timing Parameters
// Stores the relevant timing values in uS for all 3 device classes (100K/400K/1M)
localparam int       C_NUM_DEVICE_CLASSES                             = 3;
localparam shortreal C_TSPIKE_MAX        [C_NUM_DEVICE_CLASSES]       = '{0.05, 0.05, 0.05};
localparam shortreal C_TBUF_MIN          [C_NUM_DEVICE_CLASSES]       = '{4.70, 1.30, 0.50};
localparam shortreal C_THIGH_MAX         [C_NUM_DEVICE_CLASSES]       = '{50.0, 50.0, 50.0};
// Min parameters include a 10% derating to give additional margin for default values
localparam shortreal C_THIGH_MIN         [C_NUM_DEVICE_CLASSES]       = '{4.400, 0.660, 0.286};
localparam shortreal C_TLOW_MIN          [C_NUM_DEVICE_CLASSES]       = '{5.170, 1.430, 0.550};
localparam shortreal C_THD_STA_MIN       [C_NUM_DEVICE_CLASSES]       = '{4.400, 0.660, 0.286};
localparam shortreal C_TSU_STA_MIN       [C_NUM_DEVICE_CLASSES]       = '{5.170, 0.660, 0.286};
localparam shortreal C_TSU_STO_MIN       [C_NUM_DEVICE_CLASSES]       = '{4.400, 0.660, 0.286};
localparam shortreal C_THD_DAT_MIN       [C_NUM_DEVICE_CLASSES]       = '{0.330, 0.001, 0.001};
// tSU:DAT Min includes tR
localparam shortreal C_TSU_DAT_MIN       [C_NUM_DEVICE_CLASSES]       = '{1.25, 0.40, 0.17};

// Due to duration, timeout values are measured using a prescaler rather than directly with the
// system clock. The default used is 10us, tTIMEOUT Min/Max have the prescaler added to ensure
// we don't detect early
localparam int       C_TIMEOUT_PRESCALER_FREQ_HZ                      = 100000;
localparam shortreal C_TIMEOUT_PRESCALER [C_NUM_DEVICE_CLASSES]       = '{10.0, 10.0, 10.0};
localparam shortreal C_TTIMEOUT_MIN      [C_NUM_DEVICE_CLASSES]       = '{25010.0,
    25010.0, 25010.0};
localparam shortreal C_TTIMEOUT_MAX      [C_NUM_DEVICE_CLASSES]       = '{35010.0,
    35010.0, 35010.0};

// tLOW:TEXT Timeout - measured in both the Target and Controller,
// a first stage prescaler is used (default 1uS)
localparam int       C_TEXT_TIMEOUT_PRESCALER_FREQ_HZ                 = 1000000;
localparam shortreal C_TEXT_TIMEOUT_PRESCALER [C_NUM_DEVICE_CLASSES]  = '{1.00, 1.00, 1.00};
localparam shortreal C_TEXT_TIMEOUT_MAX       [C_NUM_DEVICE_CLASSES]  = '{25000.0,
    25000.0, 25000.0};

// tLOW:CEXT Timeout - measured in Controller, a first stage prescaler is used (default 1uS)
localparam int       C_CEXT_TIMEOUT_PRESCALER_FREQ_HZ                 = 1000000;
localparam shortreal C_CEXT_TIMEOUT_PRESCALER [C_NUM_DEVICE_CLASSES]  = '{1.00, 1.00, 1.00};
localparam shortreal C_CEXT_TIMEOUT_MAX       [C_NUM_DEVICE_CLASSES]  = '{10000.0,
    10000.0, 10000.0};

// --------------------------------------------------------
// Types
// --------------------------------------------------------

// PHY Common Interrupt Type
typedef struct {
  logic smbclk_low_timeout;
  logic smbdat_low_timeout;
  logic unexpected_bus_idle;
} phy_cmn_irq_t;

// PHY Common Status Type
typedef struct {
  logic smbclk;
  logic smbdat;
  logic smbclk_re;
  logic smbclk_fe;
  logic smbdat_latched;
  logic start;
  logic stop;
  logic bus_idle;
  logic unexpected_bus_idle;
  logic smbclk_timeout;
  logic phy_inactive;
  logic bus_active;
  logic ctlr_comp;
  int   default_input_lat;
} phy_cmn_stat_t;

// PHY Common Control Type
typedef struct {
  logic smbclk_ctl;
  logic smbdat_ctl;
} phy_cmn_ctl_t;

// Target PHY Status Type
typedef struct {
  logic       phy_idle;
  logic       header_valid;
  logic [7:0] header;
  logic       rx_byte_valid;
  logic [7:0] rx_byte;
  logic       rd_ack_valid;
  logic       rd_ack;
  logic       wr_ack_ready;
  logic       tx_byte_ready;
  logic       phy_error;
} tgt_phy_stat_t;

// Target PHY Interrupt Type
typedef struct {
  logic loa;
  logic text_timeout;
} tgt_phy_irq_t;

// Target Control Type
typedef struct {
  logic       wr_ack_valid;
  logic       wr_ack;
  logic       tx_byte_valid;
  logic [7:0] tx_byte;
} tgt_ctl_t;

// Target Interrupt Type
typedef struct {
  logic read;
  logic write;
  logic done;
  logic pec_error;
  logic desc_fifo_empty;
  logic desc_fifo_almost_empty;
  logic desc_fifo_underflow;
  logic desc_fifo_overflow;
  logic desc_fifo_error;
  logic desc_error;
  logic rx_fifo_fill_threshold;
  logic rx_fifo_underflow;
  logic rx_fifo_overflow;
  logic rx_fifo_error;
} tgt_irq_t;

// Controller PHY Status Type
typedef struct {
  logic       phy_idle;
  logic       wr_ack_valid;
  logic       wr_ack;
  logic       rx_byte_valid;
  logic [7:0] rx_byte;
  logic       rd_ack_ready;
  logic       phy_error;
} ctlr_phy_stat_t;

// Controller PHY Interrupt Type
typedef struct {
  logic loa;
  logic nack_err;
  logic text_timeout;
  logic cext_timeout;
} ctlr_phy_irq_t;

// Controller Control Type
typedef struct {
  logic       start_stop;
  logic       start_stop_valid;
  logic       rd_ack_valid;
  logic       rd_ack;
  logic       tx_byte_valid;
  logic [7:0] tx_byte;
  logic       quick_cmd;
  logic       disabled;
} ctlr_ctl_t;

// Controller Interrupt Type
typedef struct {
  logic done;
  logic pec_error;
  logic desc_error;
  logic desc_fifo_error;
  logic desc_fifo_empty;
  logic desc_fifo_almost_empty;
  logic desc_fifo_underflow;
  logic desc_fifo_overflow;
  logic rx_fifo_fill_threshold;
  logic rx_fifo_underflow;
  logic rx_fifo_overflow;
  logic rx_fifo_error;
} ctlr_irq_t;

// --------------------------------------------------------
// Functions
// --------------------------------------------------------

// Function to calculate the default count values for a given SMBus AC timing
// parameter based on input clock frequency
function automatic int fn_default_count (
  input int       freq_hz_clk,      // Input clock frequency (Hz)
  input shortreal timing_param_us,  // AC timing parameter (uS)
  input bit       round_up          // Flag to indicate if the count should be rounded up or down
);
  shortreal clk_period;
  int       count;

  // Calculate the clock period in microseconds
  clk_period = (1.0/freq_hz_clk)*1000000.0;

  // Calculate the count value, subtract one as all counters use underflow to detect expiry
  if (round_up) begin
    // Round up so that the count value will always meet the time requested
    count = int'($ceil((timing_param_us/clk_period))) - 1;
  end else begin
    // Round down so that the count value does not breach the time requested
    count = int'($floor((timing_param_us/clk_period))) - 1;
  end
  return (count);
endfunction : fn_default_count

endpackage : smbus_v1_1_pkg
