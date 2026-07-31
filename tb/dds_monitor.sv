`ifndef DDS_MONITOR_SV
`define DDS_MONITOR_SV
// =============================================================
// 5.  MONITOR
// =============================================================
class dds_monitor extends uvm_monitor;
    `uvm_component_utils(dds_monitor)
    virtual dds_core_if  vif;
    uvm_analysis_port #(dds_seq_item) ap;
    dds_seq_item pipeline_q[$];  // delay line: depth = PIPE_LAT

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual dds_core_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "dds_monitor: no vif")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.mon_cb);
            begin : capture
                dds_seq_item cap = dds_seq_item::type_id::create("cap");
                // Reverse-compute desired_freq_hz + band from captured FTW
                cap.init_from_ftw(vif.mon_cb.ftw);
                cap.phase_offset         = vif.mon_cb.phase_offset;
                cap.CFR1_CLR_PHASE_ACCUM = vif.mon_cb.CFR1_CLR_PHASE_ACCUM;
                cap.CFR1_AUTO_CLR_PHASE  = vif.mon_cb.CFR1_AUTO_CLR_PHASE;
                cap.CFR1_SINE_OUT        = vif.mon_cb.CFR1_SINE_OUT;
                cap.CFR1_DIGITAL_PWRDN   = vif.mon_cb.CFR1_DIGITAL_PWRDN;
                pipeline_q.push_back(cap);
            end
            if (pipeline_q.size() > PIPE_LAT) begin
                dds_seq_item out = pipeline_q.pop_front();
                out.sine_out = vif.mon_cb.sine_out;
                ap.write(out);
                `uvm_info("MON", out.convert2string(), UVM_HIGH)
            end
        end
    endtask
endclass : dds_monitor
`endif