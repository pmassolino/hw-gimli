# Gimli AEAD/Hash LWC hardware implementation

This is the hardware implementation of Gimli AEAD/Hash cipher.
Gimli is a Round 2 candidate for the NIST Lightweight Cryptography (LWC).

The Hardware implementation is compatible with the hardware LWC API from https://cryptography.gmu.edu/athena/index.php?id=LWC
The implementation done in Verilog and doesn't use any files provided by the LWC API.

### Folder structure  
- *data_test*  
	All the necessary KAT files are here for the testbenches.
- *icarus_project*  
	It has the Makefile to run the verilog testbenches.
- *python_source*  
	The Python source code of Gimli as reference code.
- *verilator_project*  
	It has the Makefile to run the Verilator (C++) testbenches and the testbenches themselves.
- *verilog_source*  
	All RTL and testbenches in Verilog.
- *yosys_synth*  
	The scripts to run Yosys for synthesis results.
		
#### Verilog files
- *gimli_non_linear_permutation gimli_all_columns_non_linear_permutation.v gimli_permutation_rounds_combinational*  
	Gimli combinational permutation function circuit.
- *gimli_rounds_simple*  
	Gimli circuit that can perform all basis duplex operations.
- *gimli_stream_buffer_in.v gimli_stream_buffer_out.v gimli_stream_state_machine.v gimli_stream.v*  
	Gimli circuit can perform HASH and AEAD with very specific order of messages, and almost no control messages.
- *gimli_lwc_buffer_in.v gimli_lwc_buffer_out.v gimli_lwc_state_machine.v gimli_lec.v*  
	Gimli circuit can perform HASH and AEAD that is complicant with LWC API.
- *tb_gimli_lwc.v*  
	This is a Verilog testbench for the top level API.
	It is preferable to use the Verilator ones, since this one can be very slow.
- *tb_gimli_rounds_simple.v*  
	Testbench for gimli_rounds_simple.v

#### Verilator testbenches
- *tb_gimli_lwc.cpp*  
	Testbench for the full LWC API. This should be used, since Verilator usually can perform better than Icarus.
- *tb_gimli_stream.cpp*  
	Testbench for the stream version of the circuit.

### Reference

While the Gimli LWC API hardware doesn't have a paper, you can cite the original CHES paper of the permutation.  
	
Daniel J. Bernstein, Stefan Kölbl, Stefan Lucks, Pedro Maat C. Massolino, Florian Mendel, Kashif Nawaz, Tobias Schneider, Peter Schwabe, François-Xavier Standaert, Yosuke Todo, Benoît Viguier. "Gimli: a cross-platform permutation". Cryptographic Hardware and Embedded Systems – CHES 2017. CHES 2017. Lecture Notes in Computer Science, vol 10529. Springer, Cham. [doi:10.1007/978-3-319-66787-4_15](https://doi.org/10.1007/978-3-319-66787-4_15). [LWC Submission](https://csrc.nist.gov/CSRC/media/Projects/lightweight-cryptography/documents/round-2/submissions-rnd2/gimli.zip) 
