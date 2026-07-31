`ifndef DDS_TEST_SV
`define DDS_TEST_SV
// =============================================================
// 11. BASE TEST
// =============================================================
class dds_base_test extends uvm_test;
    `uvm_component_utils(dds_base_test)
    dds_env env;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dds_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase); this.print();
    endfunction

    // Assert rst 8 cycles → release → flush pipeline → sync ref model
    task do_reset();
        virtual dds_core_if vif;
        if (!uvm_config_db #(virtual dds_core_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "base_test: no vif")
        vif.rst = 1'b1;
        repeat (8) @(posedge vif.clk);
        vif.rst = 1'b0;
        repeat (PIPE_LAT + 2) @(posedge vif.clk);  // drain stale pipeline items
        env.sb.on_reset();
        `uvm_info("TEST", "Reset done, pipeline flushed, ref model synced", UVM_LOW)
    endtask
endclass : dds_base_test

// =============================================================
// 12. SMOKE TEST  —  10 MHz, 128 cycles, sine mode
// =============================================================
class dds_smoke_test extends dds_base_test;
    `uvm_component_utils(dds_smoke_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        dds_fixed_freq_seq seq = dds_fixed_freq_seq::type_id::create("seq");
        phase.raise_objection(this);
        do_reset();
        seq.freq_hz = 10_000_000;  seq.num_trans = 128;  seq.sine_sel = 1'b1;
        seq.start(env.agent.seqr);
        repeat (10) @(posedge env.agent.mon.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : dds_smoke_test

// =============================================================
// 13. SMOKE1 TEST  —  100 kHz (kHz band), verifies kHz path
// =============================================================
class dds_smoke1_test extends dds_base_test;
    `uvm_component_utils(dds_smoke1_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        dds_fixed_freq_seq seq = dds_fixed_freq_seq::type_id::create("seq");
        phase.raise_objection(this);
        do_reset();
        seq.freq_hz = 100_000;  seq.num_trans = 128;  // kHz band
        seq.start(env.agent.seqr);
        repeat (10) @(posedge env.agent.mon.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : dds_smoke1_test

// =============================================================
// 14. MID-OPERATION RESET TEST
//     50 cycles at 10 MHz → mid-op reset → 100 random transactions
// =============================================================
class dds_mid_op_rst_test extends dds_base_test;
    `uvm_component_utils(dds_mid_op_rst_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        dds_fixed_freq_seq pre  = dds_fixed_freq_seq::type_id::create("pre");
        dds_random_seq     post = dds_random_seq    ::type_id::create("post");
        phase.raise_objection(this);

        do_reset();                                    // cold reset
        pre.freq_hz = 10_000_000;  pre.num_trans = 50;
        pre.start(env.agent.seqr);

        `uvm_info("TEST", "Applying mid-operation reset", UVM_LOW)
        do_reset();                                    // mid-op reset

        post.num_trans = 100;                          // verify recovery
        post.start(env.agent.seqr);
        repeat (10) @(posedge env.agent.mon.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : dds_mid_op_rst_test

// =============================================================
// 15. RANDOM TEST  —  500 transactions, 1 kHz – 190 MHz
// =============================================================
class dds_random_test extends dds_base_test;
    `uvm_component_utils(dds_random_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        dds_random_seq seq = dds_random_seq::type_id::create("seq");
        phase.raise_objection(this);
        do_reset();
        seq.num_trans = 500;
        seq.start(env.agent.seqr);
        repeat (10) @(posedge env.agent.mon.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : dds_random_test

// =============================================================
// 16. SWEEP TEST  —  12 freqs × 32 samples × SINE + COSINE
// =============================================================
class dds_sweep_test extends dds_base_test;
    `uvm_component_utils(dds_sweep_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        dds_sweep_seq seq = dds_sweep_seq::type_id::create("seq");
        phase.raise_objection(this);
        do_reset();
        seq.samples_per_freq = 32;
        seq.start(env.agent.seqr);
        repeat (10) @(posedge env.agent.mon.vif.clk);
        phase.drop_objection(this);
    endtask
endclass : dds_sweep_test
`endif