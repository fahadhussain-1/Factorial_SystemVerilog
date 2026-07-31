`timescale 1ns/1ps
`ifndef DDS_CORE_IF_SV
`define DDS_CORE_IF_SV


    // =============================================================
    // 1.  INTERFACE
    // =============================================================
    interface dds_core_if (input logic clk);
        logic        rst;
        logic [31:0] ftw;
        logic [13:0] phase_offset;
        logic        CFR1_CLR_PHASE_ACCUM, CFR1_AUTO_CLR_PHASE;
        logic        CFR1_SINE_OUT, CFR1_DIGITAL_PWRDN;
        logic signed [13:0] sine_out;

        clocking drv_cb @(posedge clk);
            default input #1 output #1;
            output ftw, phase_offset;
            output CFR1_CLR_PHASE_ACCUM, CFR1_AUTO_CLR_PHASE;
            output CFR1_SINE_OUT, CFR1_DIGITAL_PWRDN;
        endclocking

        clocking mon_cb @(posedge clk);
            default input #1;
            input ftw, phase_offset;
            input CFR1_CLR_PHASE_ACCUM, CFR1_AUTO_CLR_PHASE;
            input CFR1_SINE_OUT, CFR1_DIGITAL_PWRDN;
            input sine_out;
        endclocking
    endinterface : dds_core_if
`endif