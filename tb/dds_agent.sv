`ifndef DDS_AGENT_SV
`define DDS_AGENT_SV

// =============================================================
// 9.  AGENT
// =============================================================
class dds_agent extends uvm_agent;
    `uvm_component_utils(dds_agent)
    dds_driver  drv;
    dds_monitor mon;
    uvm_sequencer #(dds_seq_item) seqr;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer #(dds_seq_item)::type_id::create("seqr", this);
        drv  = dds_driver ::type_id::create("drv",  this);
        mon  = dds_monitor::type_id::create("mon",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass : dds_agent


`endif
