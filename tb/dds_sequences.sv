`ifndef DDS_SEQUENCES_SV
`define DDS_SEQUENCES_SV
// =============================================================
// 3.  SEQUENCES
// =============================================================

// 3a.  Fixed-frequency  —  drives one frequency for N cycles
//      Used by smoke tests and mid-op reset test
class dds_fixed_freq_seq extends uvm_sequence #(dds_seq_item);
    `uvm_object_utils(dds_fixed_freq_seq)
    int unsigned freq_hz   = 10_000_000;  // desired Hz
    int unsigned num_trans = 128;
    bit [13:0]   phase_off = 14'h0;
    bit          sine_sel  = 1'b1;

    function new(string name = "dds_fixed_freq_seq"); super.new(name); endfunction

    task body();
        dds_seq_item item;
        repeat (num_trans) begin
            item = dds_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                desired_freq_hz      == freq_hz;
                phase_offset         == phase_off;
                CFR1_SINE_OUT        == sine_sel;
                CFR1_CLR_PHASE_ACCUM == 0;
                CFR1_AUTO_CLR_PHASE  == 0;
                CFR1_DIGITAL_PWRDN   == 0;
            }) `uvm_fatal("RAND", "fixed_freq_seq randomize failed")
            finish_item(item);
        end
    endtask
endclass : dds_fixed_freq_seq


// 3b.  Random  —  fully randomised across 1 kHz – 190 MHz
class dds_random_seq extends uvm_sequence #(dds_seq_item);
    `uvm_object_utils(dds_random_seq)
    int unsigned num_trans = 500;

    function new(string name = "dds_random_seq"); super.new(name); endfunction

    task body();
        repeat (num_trans) begin
            dds_seq_item item = dds_seq_item::type_id::create("item");
            start_item(item);
            // desired_freq_hz randomised by item constraints (1 kHz–190 MHz)
            // PWRDN toggled 10% to exercise power-down path
            if (!item.randomize() with {
                CFR1_DIGITAL_PWRDN dist { 0 :/ 90, 1 :/ 10 };
                CFR1_SINE_OUT == 1'b1;
            }) `uvm_fatal("RAND", "random_seq randomize failed")
            finish_item(item);
        end
    endtask
endclass : dds_random_seq


// 3c.  Frequency sweep  —  kHz + MHz + near-Nyquist, SINE and COSINE
//      kHz entries: verified by ref-model sample comparison (no waveform counting)
//      MHz entries: same ref-model path; also observable in waveform viewer
class dds_sweep_seq extends uvm_sequence #(dds_seq_item);
    `uvm_object_utils(dds_sweep_seq)
    int unsigned samples_per_freq = 32;

    int unsigned freq_list[] = '{
        // kHz band
        1_000,   10_000,   100_000,   500_000,
        // Low MHz
        1_000_000,   5_000_000,   10_000_000,
        // Mid MHz
        25_000_000,  50_000_000,  100_000_000,
        // Near-Nyquist
        150_000_000, 190_000_000
    };

    function new(string name = "dds_sweep_seq"); super.new(name); endfunction

    task send(int unsigned freq_hz, bit [13:0] poff, bit sine_sel);
        dds_seq_item item = dds_seq_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
            desired_freq_hz      == freq_hz;
            phase_offset         == poff;
            CFR1_SINE_OUT        == sine_sel;
            CFR1_CLR_PHASE_ACCUM == 0;
            CFR1_AUTO_CLR_PHASE  == 0;
            CFR1_DIGITAL_PWRDN   == 0;
        }) `uvm_fatal("RAND", "sweep_seq randomize failed")
        finish_item(item);
    endtask

    task body();
        foreach (freq_list[i]) begin
            `uvm_info("SWEEP", $sformatf("Testing %0.3f kHz",
                      real'(freq_list[i])/1e3), UVM_MEDIUM)
            repeat (samples_per_freq) send(freq_list[i], 14'h0000, 1'b1); // SINE
            repeat (samples_per_freq) send(freq_list[i], 14'h1000, 1'b0); // COSINE
        end
    endtask
endclass : dds_sweep_seq

`endif 
