.PHONY: clean

# Empty (no trace)
# FST - Enables FST
# Otherwise anyhting will enable VCD
DUMP_TRACE_FORMAT=

VERILATOR=verilator
VERILATOR_FLAGS=--cc
VERILATOR_FLAGS+=-Wall
VERILATOR_FLAGS+=-Wno-UNUSED

VERILATOR_CPP=g++
VERILATOR_CPP_WARNINGS=-Wparentheses
VERILATOR_CPP_INCLUDE_FOLDER=/usr/local/share/verilator/include
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated.cpp

VERILATOR_CPP_DEFINES=
VERILATOR_CPP_LINK_OPTIONS=

ifdef DUMP_TRACE_FORMAT
ifeq ($(DUMP_TRACE_FORMAT), FST)
VERILATOR_FLAGS+=--trace-fst
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION+=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated_fst_c.cpp
VERILATOR_CPP_DEFINES+=-DDUMP_TRACE_ON -DDUMP_TRACE_FST
VERILATOR_CPP_LINK_OPTIONS+=-lz
else
VERILATOR_FLAGS+=--trace
VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION+=$(VERILATOR_CPP_INCLUDE_FOLDER)/verilated_vcd_c.cpp
VERILATOR_CPP_DEFINES+=-DDUMP_TRACE_ON
endif
endif

VERILOG_SOURCE_FOLDER=../verilog_source

GIMLI_NON_LINEAR_SOURCE=\
	$(VERILOG_SOURCE_FOLDER)/gimli_non_linear_permutation.v

GIMLI_ALL_COLUMNS_NON_LINEAR_SOURCE=\
	$(VERILOG_SOURCE_FOLDER)/gimli_all_columns_non_linear_permutation.v\
	$(GIMLI_NON_LINEAR_SOURCE)

GIMLI_PERMUTATION_ROUNDS_COMBINATIONAL_SOURCE=\
	$(VERILOG_SOURCE_FOLDER)/gimli_permutation_rounds_combinational.v\
	$(GIMLI_ALL_COLUMNS_NON_LINEAR_SOURCE)

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

tb_gimli_stream: $(GIMLI_STREAM_SOURCE) tb_gimli_stream.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_stream $(GIMLI_STREAM_SOURCE) tb_gimli_stream.cpp
	make -C obj_dir -f Vgimli_stream.mk
	@echo "Building a Verilator-based simulation for $(@)"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		$(@).cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_stream__ALL.a \
		-o $(@)

tb_gimli_lwc: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for $(@)"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		$(@).cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o $(@)

tb_gimli_lwc_1: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=1 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_2: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=2 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_3: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=3 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_4: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=4 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_6: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=6 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_8: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=8 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

tb_gimli_lwc_12: $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module gimli_lwc -GCOMBINATIONAL_ROUNDS=12 $(GIMLI_LWC_SOURCE) tb_gimli_lwc.cpp
	make -C obj_dir -f Vgimli_lwc.mk
	@echo "Building a Verilator-based simulation for tb_gimli_lwc"
	$(VERILATOR_CPP) $(VERILATOR_CPP_WARNINGS) $(VERILATOR_CPP_DEFINES) -I $(VERILATOR_CPP_INCLUDE_FOLDER) -I obj_dir \
		$(VERILATOR_CPP_SOURCE_FILES_FINAL_COMPILATION)\
		tb_gimli_lwc.cpp $(VERILATOR_CPP_LINK_OPTIONS) obj_dir/Vgimli_lwc__ALL.a \
		-o tb_gimli_lwc

clean:
	@echo "Cleaning up..."
	rm -r -f obj_dir
	rm -r -f tb_gimli_stream
	rm -r -f tb_gimli_stream.vcd
	rm -r -f tb_gimli_stream.fst
	rm -r -f tb_gimli_stream.fst.hier
	rm -r -f tb_gimli_lwc
	rm -r -f tb_gimli_lwc.vcd
	rm -r -f tb_gimli_lwc.fst
	rm -r -f tb_gimli_lwc.fst.hier
	@echo "Cleaning done."