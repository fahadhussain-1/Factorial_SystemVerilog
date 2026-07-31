`ifndef DDS_SEQ_ITEM_SV
`define DDS_SEQ_ITEM_SV
    
    // =============================================================
    // 2.  SEQUENCE ITEM
    //     desired_freq_hz  : randomised (Hz) — the solver knob
    //     ftw              : NOT rand — computed in post_randomize()
    //                        FTW = round(f_desired × 2³² / SCLK_HZ)
    //
    //  kHz frequencies ARE included (10% weight).
    //  Verification for kHz: scoreboard does sample-by-sample ref-model
    //  comparison (mathematical), NOT zero-crossing counting.
    //  This correctly validates the DDS at any frequency without
    //  requiring billions of simulated clock cycles.
    // =============================================================
    class dds_seq_item extends uvm_sequence_item;
        `uvm_object_utils(dds_seq_item)

        // --- Stimulus ---
        rand int unsigned desired_freq_hz;  // Hz, 1 kHz – 190 MHz
        bit  [31:0]       ftw;             // derived — do NOT randomise directly
        rand bit [13:0]   phase_offset;
        rand bit          CFR1_CLR_PHASE_ACCUM, CFR1_AUTO_CLR_PHASE;
        rand bit          CFR1_SINE_OUT,        CFR1_DIGITAL_PWRDN;
        freq_band_e       freq_band;        // set by classify()

        // --- Response (filled by monitor) ---
        logic signed [13:0] sine_out;

        // --- Constraints ---
        constraint c_freq_range {
            desired_freq_hz inside {[1_000 : 190_000_000]};
        }
        // 10 % kHz | 40 % 1–10 MHz | 35 % 10–100 MHz | 15 % 100–190 MHz
        constraint c_freq_dist {
            desired_freq_hz dist {
                [1_000       :    999_999] :/ 10,
                [1_000_000   :  10_000_000] :/ 40,
                [10_000_001  : 100_000_000] :/ 35,
                [100_000_001 : 190_000_000] :/ 15
            };
        }
        constraint c_pwrdn_off { soft CFR1_DIGITAL_PWRDN == 1'b0; }
        constraint c_clr_rare  {
            CFR1_CLR_PHASE_ACCUM dist { 0 :/ 95, 1 :/ 5 };
            CFR1_AUTO_CLR_PHASE  dist { 0 :/ 95, 1 :/ 5 };
        }

        function new(string name = "dds_seq_item"); super.new(name); endfunction

        // Called after randomise: compute FTW, set band
        function void post_randomize();
            ftw = 32'($rtoi(real'(desired_freq_hz) * TWO_POW_32 / SCLK_HZ + 0.5));
            classify();
        endfunction

        // Called by monitor: reverse-compute freq from captured FTW
        function void init_from_ftw(bit [31:0] f);
            ftw = f;
            desired_freq_hz = int'(real'(f) * SCLK_HZ / TWO_POW_32 + 0.5);
            classify();
        endfunction

        function void classify();
            if      (desired_freq_hz <   1_000_000) freq_band = BAND_KHZ;
            else if (desired_freq_hz <  10_000_000) freq_band = BAND_LO;
            else if (desired_freq_hz < 100_000_000) freq_band = BAND_MID;
            else                                    freq_band = BAND_HI;
        endfunction

        function string convert2string();
            return $sformatf(
                "f=%0.3fkHz ftw=0x%08X poff=0x%04X CLR=%b AUTO=%b SINE=%b PWRDN=%b [%s] sine=%0d",
                real'(desired_freq_hz)/1e3, ftw, phase_offset,
                CFR1_CLR_PHASE_ACCUM, CFR1_AUTO_CLR_PHASE,
                CFR1_SINE_OUT, CFR1_DIGITAL_PWRDN, freq_band.name(), $signed(sine_out));
        endfunction
    endclass : dds_seq_item
`endif