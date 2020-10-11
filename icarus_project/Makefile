.PHONY: clean

ICARUS_VERILOG_SIMULATOR=iverilog
ICARUS_VERILOG_VVP=vvp
ICARUS_VERILOG_DUMP_TYPE=fst

VERILOG_SOURCE_FOLDER=../verilog_source

GIMLI_NON_LINEAR_SOURCE=\
	$(VERILOG_SOURCE_FOLDER)/gimli_non_linear_permutation.v

GIMLI_ALL_COLUMNS_NON_LINEAR_SOURCE=\
	$(GIMLI_NON_LINEAR_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/gimli_all_columns_non_linear_permutation.v

GIMLI_PERMUTATION_ROUNDS_COMBINATIONAL_SOURCE=\
	$(GIMLI_ALL_COLUMNS_NON_LINEAR_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/gimli_permutation_rounds_combinational.v

GIMLI_ROUNDS_SIMPLE_SOURCE=\
	$(GIMLI_PERMUTATION_ROUNDS_COMBINATIONAL_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/gimli_rounds_simple.v

GIMLI_STREAM_SOURCE=\
	$(GIMLI_ROUNDS_SIMPLE_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/gimli_stream_buffer_in.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_stream_buffer_out.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_stream_state_machine.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_stream.v

GIMLI_LWC_SOURCE=\
	$(GIMLI_STREAM_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/gimli_lwc_buffer_in.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_lwc_buffer_out.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_lwc_state_machine.v\
	$(VERILOG_SOURCE_FOLDER)/gimli_lwc.v

TB_GIMLI_ROUNDS_SIMPLE_SOURCE=\
	$(GIMLI_ROUNDS_SIMPLE_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/tb_gimli_rounds_simple.v

TB_GIMLI_LWC_SOURCE=\
	$(GIMLI_LWC_SOURCE)\
	$(VERILOG_SOURCE_FOLDER)/tb_gimli_lwc.v

tb_gimli_rounds_simple: $(TB_GIMLI_ROUNDS_SIMPLE_SOURCE)
	IVERILOG_DUMPER="$(ICARUS_VERILOG_DUMP_TYPE)" $(ICARUS_VERILOG_SIMULATOR) -s $@ -o $@_design $(TB_GIMLI_ROUNDS_SIMPLE_SOURCE)
	$(ICARUS_VERILOG_VVP) $@_design -$(ICARUS_VERILOG_DUMP_TYPE)

tb_gimli_lwc: $(TB_GIMLI_LWC_SOURCE)
	IVERILOG_DUMPER="$(ICARUS_VERILOG_DUMP_TYPE)" $(ICARUS_VERILOG_SIMULATOR) -s $@ -o $@_design $(TB_GIMLI_LWC_SOURCE)
	$(ICARUS_VERILOG_VVP) $@_design -$(ICARUS_VERILOG_DUMP_TYPE)

clean:
	@echo "Cleaning up..."
	rm -f "dump"
	rm -f "dump_gimli_lwc"
	rm -f "tb_gimli_rounds_simple_design"
	rm -f "tb_gimli_lwc_design"
	@echo "Cleaning done."