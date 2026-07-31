

// =============================================================
// 17. TOP MODULE  —  400 MHz clock (2.5 ns period)
// =============================================================
`timescale 1ns/1ps
module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import dds_pkg::*;

    logic clk = 1'b0;
    always #1.25 clk = ~clk;   // 400 MHz

    dds_core_if dut_if (.clk(clk));

    DDS_Core dut (
        .clk                  (clk),
        .rst                  (dut_if.rst),
        .CFR1_CLR_PHASE_ACCUM (dut_if.CFR1_CLR_PHASE_ACCUM),
        .CFR1_AUTO_CLR_PHASE  (dut_if.CFR1_AUTO_CLR_PHASE),
        .CFR1_SINE_OUT        (dut_if.CFR1_SINE_OUT),
        .CFR1_DIGITAL_PWRDN   (dut_if.CFR1_DIGITAL_PWRDN),
        .ftw                  (dut_if.ftw),
        .phase_offset         (dut_if.phase_offset),
        .sine_out             (dut_if.sine_out)
    );

    //initial begin $dumpfile("dump.vcd"); $dumpvars(0, tb_top); end

    initial begin
        uvm_config_db #(virtual dds_core_if)::set(null, "*", "vif", dut_if);
        run_test();   // +UVM_TESTNAME=dds_smoke_test  (or any test above)
    end

    // 50 µs timeout = 20,000 cycles @ 400 MHz — sufficient for all tests
    //initial #50_000 `uvm_fatal("TIMEOUT", "Simulation exceeded 50 µs")
endmodule : tb_top
