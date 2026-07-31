`timescale 1ns/1ps
`ifndef DDS_PARAMS_PKG_SV
`define DDS_PARAMS_PKG_SV

package dds_params_pkg;
    parameter real SCLK_HZ    = 400_000_000.0;   // 400 MHz system clock
    parameter real TWO_POW_32 = 4_294_967_296.0;  // 2^32 accumulator depth
    parameter real NYQUIST_HZ = SCLK_HZ / 2.0;   // 200 MHz Nyquist limit
    parameter int  PIPE_LAT   = 4;                // Acc(1)+Offset(1)+LUT(2)

    typedef enum logic [1:0] {
        BAND_KHZ = 2'd0,   //   1 kHz – 999 kHz  (ref-model comparison)
        BAND_LO  = 2'd1,   //   1 MHz –  10 MHz
        BAND_MID = 2'd2,   //  10 MHz – 100 MHz
        BAND_HI  = 2'd3    // 100 MHz – 190 MHz
    } freq_band_e;
endpackage : dds_params_pkg

`endif