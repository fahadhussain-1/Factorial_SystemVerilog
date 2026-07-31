`ifndef DDS_COVERAGE_SV
`define DDS_COVERAGE_SV
// =============================================================
// 8.  COVERAGE
// =============================================================
class dds_coverage extends uvm_subscriber #(dds_seq_item);
    `uvm_component_utils(dds_coverage)
    virtual dds_core_if vif;

    // Sampled fields (updated in write / run_phase)
    bit [31:0]          tw;
    bit [13:0]          poff;
    bit                 sine_mode, pwrdn, clr;
    freq_band_e         band;
    logic signed [13:0] out_curr, out_prev;

    covergroup cg_ftw;
        cp: coverpoint tw {
            bins zero  = {0};
            bins low = {[32'h1       : 32'h0FFF_FFFF]};
            bins mid   = {[32'h1000_0000 : 32'h7FFF_FFFF]};
            bins high  = {[32'h8000_0000 : 32'hFFFF_FFFF]};
        }
    endgroup

    covergroup cg_phase_offset;
        cp: coverpoint poff {
            bins zero = {14'h0};   bins low  = {[14'h1   : 14'h0FFF]};
            bins half = {14'h1000}; bins high = {[14'h1001 : 14'h3FFF]};
        }
    endgroup

    covergroup cg_ctrl;
        cp_sine : coverpoint sine_mode;
        cp_pwrdn: coverpoint pwrdn;
        cp_clr  : coverpoint clr;
        cx      : cross cp_sine, cp_pwrdn;
    endgroup

    covergroup cg_amplitude;
        cp: coverpoint $signed(out_curr) {
            bins peak_pos = {8191};       bins pos   = {[1    : 8190]};
            bins zero_out = {0};          bins neg   = {[-8191 : -1]};
        }
    endgroup

    // NEW: ensures all frequency bands are exercised
    covergroup cg_freq_band;
        cp: coverpoint band {
            bins khz = {BAND_KHZ};  bins lo  = {BAND_LO};
            bins mid = {BAND_MID};  bins hi  = {BAND_HI};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_ftw = new(); cg_phase_offset = new(); cg_ctrl = new();
        cg_amplitude = new(); cg_freq_band = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual dds_core_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "dds_coverage: no vif")
    endfunction

    function void write(dds_seq_item t);
        tw = t.ftw;  poff = t.phase_offset;  sine_mode = t.CFR1_SINE_OUT;
        pwrdn = t.CFR1_DIGITAL_PWRDN;  band = t.freq_band;
        clr   = t.CFR1_CLR_PHASE_ACCUM | t.CFR1_AUTO_CLR_PHASE;
        cg_ftw.sample();  cg_phase_offset.sample();
        cg_ctrl.sample(); cg_freq_band.sample();
    endfunction

    task run_phase(uvm_phase phase);
        out_prev = 0;
        forever begin
            @(vif.mon_cb);
            out_curr = vif.mon_cb.sine_out;
            cg_amplitude.sample();
            out_prev = out_curr;
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf(
            "\n=== COVERAGE ===\n  FTW=%0.1f%%  Phase=%0.1f%%  Ctrl=%0.1f%%  Amp=%0.1f%%  Band=%0.1f%%",
            cg_ftw.get_coverage(), cg_phase_offset.get_coverage(),
            cg_ctrl.get_coverage(), cg_amplitude.get_coverage(),
            cg_freq_band.get_coverage()), UVM_NONE)
    endfunction
endclass : dds_coverage
`endif 