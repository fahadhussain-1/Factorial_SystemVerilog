# =============================================================================
# run.do -- QuestaSim compile + run script for the full DDS_Core UVM environment
#
# Usage:
#   do run.do
#   vsim -c -do run.do
#   vsim -c -do "do run.do dds_core_single_tone_test"
# =============================================================================

quit -sim

if {[file exists work]} {
    vdel -all
}

vlib work
vmap work work

# -----------------------------------------------------------------------------
# RTL (compile order matters: leaf modules before the top that instantiates them)
# -----------------------------------------------------------------------------
vlog -sv +incdir+../rtl ../rtl/Phase_Accumulator.v
vlog -sv +incdir+../rtl ../rtl/Phase_Offset.v
vlog -sv +incdir+../rtl ../rtl/Sine_LUT.v
vlog -sv +incdir+../rtl ../rtl/DDS_Core.v

# -----------------------------------------------------------------------------
# UVM Testbench
# -----------------------------------------------------------------------------
vlog -sv +incdir+../tb \
    ../tb/dds_params_pkg.sv\
    ../tb/dds_core_if.sv \
    ../tb/dds_pkg.sv \
    ../tb/tb_top.sv

# -----------------------------------------------------------------------------
# Select Test
# -----------------------------------------------------------------------------
if {[info exists 1]} {
    set TESTNAME $1
} else {
    set TESTNAME "dds_random_test"
}

# -----------------------------------------------------------------------------
# Elaborate
# -----------------------------------------------------------------------------
# vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=$TESTNAME
vsim -voptargs="+acc -timescale=1ns/1ps" work.tb_top +UVM_TESTNAME=$TESTNAME
# -----------------------------------------------------------------------------
# Optional Waves
# -----------------------------------------------------------------------------
# add wave -r *

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------
run -all

# quit -f
