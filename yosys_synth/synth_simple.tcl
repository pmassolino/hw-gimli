# read all source files
source "source.tcl"
#
# Check, expand and clean up design hierarchy
yosys hierarchy -check -top "$::env(SYNTH_TOP_UNIT_NAME)"
#
# Begin translation process and coarse optimizations
#
# Convert high-level behavioral parts ("processes") to d-type flip-flops and muxes
yosys proc
# Flatten design
yosys flatten
# Perform const folding and simple expression rewriting
yosys opt_expr
# Remove unused cells and wires
yosys opt_clean
# Check for obvious problems in the design
yosys check
# Perform simple optimizations
yosys opt
# Reduce the word size of operations if possible
yosys wreduce
# Extract ALU and MACC cells
yosys alumacc
# perform sat-based resource sharing
yosys share
# Perform simple optimizations
yosys opt
# extract and optimize finite state machines
yosys fsm
# Perform simple optimizations
yosys opt -fast
# Translate memories to basic cells
yosys memory -nomap
# Remove unused cells and wires
yosys opt_clean
#
# More fine optimizations
#
# Perform simple optimizations
yosys opt -fast -full
# Translate multiport memories to basic cells
yosys memory_map
# Perform simple optimizations
yosys opt -full
# Generic technology mapper
yosys techmap
# Perform simple optimizations
yosys opt
# Use ABC for technology mapping
yosys abc -g simple
#
yosys opt_clean
# Print some statistics
yosys stat -top $::env(SYNTH_TOP_UNIT_NAME)
#
yosys write_verilog [expr {"$::env(SYNTH_OUTPUT_CIRCUIT_FOLDER)/$::env(SYNTH_TOP_UNIT_NAME).v"}]