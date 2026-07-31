`ifndef DDS_ENV_SV
`define DDS_ENV_SV
// =============================================================
// 10. ENVIRONMENT
// =============================================================
class dds_env extends uvm_env;
    `uvm_component_utils(dds_env)
    dds_agent      agent;
    dds_scoreboard sb;
    dds_coverage   cov;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = dds_agent     ::type_id::create("agent", this);
        sb    = dds_scoreboard::type_id::create("sb",    this);
        cov   = dds_coverage  ::type_id::create("cov",   this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.mon.ap.connect(sb.analysis_export);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction
endclass : dds_env
`endif