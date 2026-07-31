// =============================================================
// 6.  REFERENCE MODEL
// =============================================================
class dds_ref_model;
    bit [31:0] phase_acc = 0, phase_off_d = 0;

    function automatic logic signed [13:0] tick(
        input bit [31:0] ftw,  input bit [13:0] phase_offset,
        input bit        clr,  input bit        auto_clr,
        input bit        sine_mode, input bit   pwrdn);
        bit [31:0] old_acc;
        real       ang, val;
        old_acc     = phase_acc;
        phase_acc   = (pwrdn | clr | auto_clr) ? 32'd0 : phase_acc + ftw;
        phase_off_d = old_acc + {phase_offset, 18'b0};
        ang = (real'(phase_off_d[31:16]) / 65536.0) * 2.0 * 3.14159265358979;
        if (pwrdn) return 14'sd0;
        val = sine_mode ? $sin(ang) : $cos(ang);
        return $rtoi(val * 8191.0);
    endfunction

    function void reset(); phase_acc = 0; phase_off_d = 0; endfunction
endclass : dds_ref_model

`ifndef DDS_SCOREBOARD_SV
`define DDS_SCOREBOARD_SV
// =============================================================
// 7.  SCOREBOARD
// =============================================================
class dds_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dds_scoreboard)
    uvm_analysis_imp #(dds_seq_item, dds_scoreboard) analysis_export;
    dds_ref_model ref_model;

    int unsigned pass_cnt = 0, fail_cnt = 0, skip_cnt = 0, total = 0;
    localparam int TOL = 4;  // ±4 LSB accounts for LUT quantisation

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
        ref_model = new();
    endfunction

    // Called from do_reset() in base test to sync ref model with DUT
    function void on_reset();
        ref_model.reset();
        `uvm_info("SB", "Ref model synchronised with DUT reset", UVM_LOW)
    endfunction

    function void write(dds_seq_item item);
        logic signed [13:0] exp;
        int diff;
        total++;
        exp = ref_model.tick(item.ftw, item.phase_offset,
                             item.CFR1_CLR_PHASE_ACCUM, item.CFR1_AUTO_CLR_PHASE,
                             item.CFR1_SINE_OUT, item.CFR1_DIGITAL_PWRDN);

        // CLR: output depends on mid-flight pipeline state — skip comparison
        if (item.CFR1_CLR_PHASE_ACCUM || item.CFR1_AUTO_CLR_PHASE) begin
            skip_cnt++;
            `uvm_info("SB", $sformatf("[%0d] SKIP(CLR) | %s", total,
                      item.convert2string()), UVM_MEDIUM)
            return;
        end

        // PWRDN: DUT must output exactly 0 (no tolerance needed)
        if (item.CFR1_DIGITAL_PWRDN) begin
            if (item.sine_out == 14'sd0) pass_cnt++;
            else begin
                fail_cnt++;
                `uvm_error("SB", $sformatf("[%0d] FAIL(PWRDN) exp=0 got=%0d | %s",
                           total, $signed(item.sine_out), item.convert2string()))
            end
            return;
        end

        // Normal comparison (all frequencies, including kHz)
        diff = $signed(item.sine_out) - $signed(exp);
        if (diff < 0) diff = -diff;
        if (diff <= TOL) begin
            pass_cnt++;
            `uvm_info("SB", $sformatf("[%0d] PASS exp=%0d got=%0d diff=%0d | %s",
                      total, $signed(exp), $signed(item.sine_out), diff,
                      item.convert2string()), UVM_MEDIUM)
        end else begin
            fail_cnt++;
            `uvm_error("SB", $sformatf("[%0d] FAIL exp=%0d got=%0d diff=%0d(tol=%0d) | %s",
                       total, $signed(exp), $signed(item.sine_out), diff, TOL,
                       item.convert2string()))
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf(
            "\n=== SCOREBOARD ===  Total=%0d  Pass=%0d  Fail=%0d  Skip=%0d",
            total, pass_cnt, fail_cnt, skip_cnt), UVM_NONE)
        if (fail_cnt) `uvm_error("SB", $sformatf("%0d FAILURE(S)", fail_cnt))
    endfunction
endclass : dds_scoreboard
`endif