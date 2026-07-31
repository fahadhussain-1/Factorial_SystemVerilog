`timescale 1ns / 1ps


module DDS_Core(

    input  wire         clk,
    input  wire         rst,
    input  wire         CFR1_CLR_PHASE_ACCUM,
    input  wire         CFR1_AUTO_CLR_PHASE,
    input  wire         CFR1_SINE_OUT,        // select betwee sine or cosine
    input  wire         CFR1_DIGITAL_PWRDN,   // if its 1 to turn off the core

    input  wire [31:0]  ftw,
    input  wire [13:0]  phase_offset,

    output wire  signed [13:0] sine_out
);

    wire [18:0]  phase_offset_out;
    wire [31:0]  phase_acc_out;
    
    // Phase Accumulator Instance
    Phase_Accumulator u_phase_accumulator (
        .clk                 (clk),
        .rst                 (rst),
        .CFR1_DIGITAL_PWRDN  (CFR1_DIGITAL_PWRDN),
        .clr_phase_acc_auto  (CFR1_AUTO_CLR_PHASE),
        .clr_phase_acc_manual(CFR1_CLR_PHASE_ACCUM),
        .ftw                 (ftw),
        .phase_acc_out       (phase_acc_out)
    );
    
    // Phase Offset Instance
    Phase_Offset u_phase_offset (
        .clk                 (clk),
        .rst                 (rst),
        .CFR1_DIGITAL_PWRDN  (CFR1_DIGITAL_PWRDN),
        .phase_acc           (phase_acc_out),
        .phase_offset        (phase_offset),
        .phase_offset_out    (phase_offset_out)
    );
    
    // LUT instance 
    Sine_LUT u_Sine_LUT (
        .clk                 (clk),
        .rst                 (rst),
        .CFR1_DIGITAL_PWRDN  (CFR1_DIGITAL_PWRDN),
        .CFR1_SINE_OUT       (CFR1_SINE_OUT),
        .phase_adjusted      (phase_offset_out),
        .sine_out            (sine_out)
    );
    
endmodule
