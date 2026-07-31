`timescale 1ns/1ps
`ifndef DDS_PKG_SV
`define DDS_PKG_SV

package dds_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import dds_params_pkg::*;

  `include "dds_seq_item.sv"
  `include "dds_driver.sv"
  `include "dds_monitor.sv"
  `include "dds_agent.sv"
  `include "dds_scoreboard.sv"
  `include "dds_coverage.sv"
  `include "dds_env.sv"
  `include "dds_sequences.sv"
  `include "dds_test.sv"
endpackage

`endif