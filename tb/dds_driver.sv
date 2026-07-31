`ifndef DDS_DRIVER_SV
`define DDS_DRIVER_SV
// =============================================================
// 4.  DRIVER
// =============================================================
class dds_driver extends uvm_driver #(dds_seq_item);
    `uvm_component_utils(dds_driver)
    virtual dds_core_if vif;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual dds_core_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "dds_driver: no vif")
    endfunction

    task run_phase(uvm_phase phase);
        dds_seq_item item;
        // Safe idle state
        vif.drv_cb.ftw <= 0;  vif.drv_cb.phase_offset <= 0;
        vif.drv_cb.CFR1_CLR_PHASE_ACCUM <= 0;  vif.drv_cb.CFR1_AUTO_CLR_PHASE <= 0;
        vif.drv_cb.CFR1_SINE_OUT <= 1;          vif.drv_cb.CFR1_DIGITAL_PWRDN  <= 0;

        forever begin
            seq_item_port.get_next_item(item);
            @(vif.drv_cb);
            vif.drv_cb.ftw                  <= item.ftw;   // computed from desired_freq_hz
            vif.drv_cb.phase_offset         <= item.phase_offset;
            vif.drv_cb.CFR1_CLR_PHASE_ACCUM <= item.CFR1_CLR_PHASE_ACCUM;
            vif.drv_cb.CFR1_AUTO_CLR_PHASE  <= item.CFR1_AUTO_CLR_PHASE;
            vif.drv_cb.CFR1_SINE_OUT        <= item.CFR1_SINE_OUT;
            vif.drv_cb.CFR1_DIGITAL_PWRDN   <= item.CFR1_DIGITAL_PWRDN;
            `uvm_info("DRV", item.convert2string(), UVM_HIGH)
            seq_item_port.item_done();
        end
    endtask
endclass : dds_driver

`endif