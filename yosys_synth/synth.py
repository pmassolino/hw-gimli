#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#--------------------------------------------------------------------------------#
# Implementation by Pedro Maat C. Massolino,                                     #
# hereby denoted as "the implementer".                                           #
#                                                                                #
# To the extent possible under law, the implementer has waived all copyright     #
# and related or neighboring rights to the source code in this file.             #
# http://creativecommons.org/publicdomain/zero/1.0/                              #
#--------------------------------------------------------------------------------#

import os
import sys
import io
import math

def synthesize_asic_entity(yosys_location, yosys_synth_script, target_cell, entity_name, timing_constraint, synthesis_output_folder):
    # Check if folder exists, and if not create
    if(not os.path.isdir(synthesis_output_folder)):
        os.mkdir(synthesis_output_folder)
    # Check if folder exists for the synthesis script, if not, create it
    int_synthesis_output_folder = synthesis_output_folder + '/' + yosys_synth_script[:-4]
    if(not os.path.isdir(int_synthesis_output_folder)):
        os.mkdir(int_synthesis_output_folder)
    # Check if folder exists for the target cell, if not, create it
    int_synthesis_output_folder = int_synthesis_output_folder + '/' + target_cell['name']
    if(not os.path.isdir(int_synthesis_output_folder)):
        os.mkdir(int_synthesis_output_folder)
    command = 'SYNTH_TOP_UNIT_NAME=' + entity_name + ' '
    command = command + 'SYNTH_ASIC_CELL_LOCATION=' + target_cell['liberty_file'] + ' '
    command = command + 'SYNTH_ASIC_PIN_CONSTRAINTS=' + target_cell['pin_constr_file'] + ' '
    command = command + 'SYNTH_TIMING_CONSTRAINT=' + timing_constraint + ' '
    command = command + 'SYNTH_OUTPUT_CIRCUIT_FOLDER=' + int_synthesis_output_folder + ' '
    log_filename = int_synthesis_output_folder + '/' + entity_name + '__t_' + timing_constraint + '.yslog'
    command = command + yosys_location + ' -l ' + log_filename + ' -c ' + yosys_synth_script + ' -q'
    print(command)
    os.system(command)
    
    # Open log and look for the delay and area results
    result_filename = int_synthesis_output_folder + '/' + entity_name + '__t_' + timing_constraint + '.result'
    # Area string to look for
    area_result_line_1 = 'Chip area for module ' + "'" + "\\" +  entity_name + "':"
    area_result_line_2 = 'Chip area for top module ' + "'" + "\\" +  entity_name + "':"
    possible_area_result_lines = []
    # Delay string to look for
    delay_result_line = 'Delay ='
    possible_delay_result_lines = []
    with open(log_filename, "r") as log_file:
        for log_line in log_file:
            if (delay_result_line in log_line):
                possible_delay_result_lines += [log_line]
            if (area_result_line_1 in log_line):
                possible_area_result_lines += [log_line]
            if (area_result_line_2 in log_line):
                possible_area_result_lines += [log_line]
    # Only write the biggest area found for the top architecture
    if(len(possible_area_result_lines) <= 1):
        biggest_area_line = 0
    else:
        biggest_area_line = 0
        temp_line_splitted = possible_area_result_lines[0].split(":")
        biggest_area_line_result = float((temp_line_splitted[1]).strip())
        for i in range(1, len(possible_area_result_lines)):
            temp_line_splitted = possible_area_result_lines[i].split(":")
            temp_area_line_result = float((temp_line_splitted[1]).strip())
            if(temp_area_line_result > biggest_area_line_result):
                biggest_area_line = i
                biggest_area_line_result = temp_area_line_result
    # Only write the first delay found. This needs to be redone, because ABC doesn't give proper delay results for non flattened results.
    with open(result_filename, "w") as result_file:
        result_file.write(possible_area_result_lines[biggest_area_line])
        result_file.write(possible_delay_result_lines[0])

def synthesize_simple_entity(yosys_location, yosys_synth_script, entity_name, synthesis_output_folder):
    # Check if folder exists, and if not create
    if(not os.path.isdir(synthesis_output_folder)):
        os.mkdir(synthesis_output_folder)
    # Check if folder exists for the synthesis script, if not, create it
    int_synthesis_output_folder = synthesis_output_folder + '/' + yosys_synth_script[:-4]
    if(not os.path.isdir(int_synthesis_output_folder)):
        os.mkdir(int_synthesis_output_folder)
    command = 'SYNTH_TOP_UNIT_NAME=' + entity_name + ' '
    command = command + 'SYNTH_OUTPUT_CIRCUIT_FOLDER=' + int_synthesis_output_folder + ' '
    log_filename = int_synthesis_output_folder + '/' + entity_name + '.yslog'
    command = command + yosys_location + ' -l ' + log_filename + ' -c ' + yosys_synth_script + ' -q'
    
    print(command)
    os.system(command)

def synthesize_asic_list(yosys_location, all_yosys_synth_scripts, all_target_cells, all_entity_names, all_timing_constraints, synthesis_output_folder):
    for each_yosys_synth_ecript in all_yosys_synth_scripts:
       for each_std_cell in all_target_cells:
           for each_entity in all_entity_names:
               for each_timing_constraint in all_timing_constraints:
                   synthesize_asic_entity(yosys_location, each_yosys_synth_ecript, each_std_cell, each_entity, each_timing_constraint, synthesis_output_folder)

def synthesize_simple_list(yosys_location, all_yosys_synth_scripts, all_entity_names, synthesis_output_folder):
    for each_yosys_synth_ecript in all_yosys_synth_scripts:
        for each_entity in all_entity_names:
            synthesize_simple_entity(yosys_location, each_yosys_synth_ecript, each_entity, synthesis_output_folder)

def generate_csv_with_all_results(all_yosys_asic_synth_script, all_target_cells, all_entity_names, all_timing_constraints, synthesis_output_folder):
    area_result_line = 'Chip area'
    delay_result_line = 'Delay ='
    csv_file_name = synthesis_output_folder + '/' + 'results.csv'
    for each_yosys_synth_ecript in all_yosys_asic_synth_script:
        with io.open(csv_file_name, "w", encoding="utf-8", newline='') as csv_file:
            line = '"Entity Name","Technology","Timing Constraint","Area","GE","Delay"\r\n'
            csv_file.write(line)
            for each_std_cell in all_target_cells:
                nand_size = 0.0
                with open(each_std_cell['nand_file'], "r") as nand_file:
                    nand_size = float(nand_file.readline())
                for each_entity in all_entity_names:
                    for each_timing_constraint in all_timing_constraints:
                        line = '"' + each_entity + '"' + ',' + '"' + each_std_cell['name'] + '"' + ',' + '"' + each_timing_constraint + '"' + ','
                        result_filename = synthesis_output_folder + '/' + each_yosys_synth_ecript[:-4] + '/' + each_std_cell['name'] + '/' + each_entity + '__t_' + each_timing_constraint + '.result'
                        with open(result_filename, "r") as result_file:
                            for result_line in result_file:
                                if(area_result_line in result_line):
                                    area_line_splitted = result_line.split(":")
                                    area_result = (area_line_splitted[1]).strip()
                                    line = line + '"' + area_result + '"' + ','
                        area_result_ge = str(int(math.ceil(float(area_result)/nand_size)))
                        line = line + '"' + area_result_ge + '"' + ','
                        with open(result_filename, "r") as result_file:
                            for result_line in result_file:
                                if(delay_result_line in result_line):
                                    delay_line_splitted = result_line.split(delay_result_line)
                                    delay_result = ((delay_line_splitted[1]).split())[0]
                                    line = line + '"' + delay_result + '"'
                        line = line + '\r\n'
                        csv_file.write(line)

def generate_simulation_synthesized_design(yosys_synth_script, target_cell, entity_name, timing_constraint, testbench_name, synthesis_output_folder, testbench_folder):
    testbench_synthesized_entity = testbench_folder + '/' + testbench_name + '.v'
    if(os.path.exists(testbench_synthesized_entity)):
        synthesized_entity = synthesis_output_folder + '/' + yosys_synth_script[:-4] + '/' + target_cell['name'] + '/' + entity_name + '.v'
        cell_library_verilog = target_cell['verilog_library']
        output_folder = synthesis_output_folder + '/' + yosys_synth_script[:-4] + '/' + 'sim_' + target_cell['name']
        if(not os.path.isdir(output_folder)):
            os.mkdir(output_folder)
        simulation_testbench = output_folder + '/' + testbench_name + '_design '
        
        command = 'iverilog -s ' + testbench_name + ' -o ' + simulation_testbench + ' ' + testbench_synthesized_entity + ' ' + synthesized_entity + ' ' + cell_library_verilog
        print(command)
        os.system(command)

def generate_all_simulation_synthesized_design(all_yosys_synth_scripts, all_target_cells, all_entity_names, all_timing_constraints, all_testbench_names, synthesis_output_folder, testbench_folder):
    for each_yosys_synth_ecript in all_yosys_synth_scripts:
        for each_target_cell in all_target_cells:
            for each_entity_name, each_testbench_name in zip(all_entity_names, all_testbench_names):
                for each_timing_constraint in all_timing_constraints:
                    generate_simulation_synthesized_design(each_yosys_synth_ecript, each_target_cell, each_entity_name, each_timing_constraint, each_testbench_name, synthesis_output_folder, testbench_folder)

def generate_simulation_simple_synthesized_design(yosys_synth_script, entity_name, testbench_name, synthesis_output_folder, testbench_folder):
    testbench_synthesized_entity = testbench_folder + '/' + testbench_name + '.v'
    if(os.path.exists(testbench_synthesized_entity)):
        synthesized_entity = synthesis_output_folder + '/' + yosys_synth_script[:-4] + '/' + entity_name + '.v'
        output_folder = synthesis_output_folder + '/' + yosys_synth_script[:-4] + '/' + 'sim'
        if(not os.path.isdir(output_folder)):
            os.mkdir(output_folder)
        simulation_testbench = output_folder + '/' + testbench_name + '_design '
        
        command = 'iverilog -s ' + testbench_name + ' -o ' + simulation_testbench + ' ' + testbench_synthesized_entity + ' ' + synthesized_entity
        print(command)
        os.system(command)

def generate_all_simulation_simple_synthesized_design(all_yosys_synth_scripts, all_entity_names, all_testbench_names, synthesis_output_folder, testbench_folder):
    for each_yosys_synth_ecript in all_yosys_synth_scripts:
        for each_entity_name, each_testbench_name in zip(all_entity_names, all_testbench_names):
            generate_simulation_simple_synthesized_design(each_yosys_synth_ecript, each_entity_name, each_testbench_name, synthesis_output_folder, testbench_folder)

# STD cells descriptions

asic_cells_base_folder = '../../../asic_cells/'

gscl45nm_library = {
'name' : 'gscl45nm',
'liberty_file' : asic_cells_base_folder + 'gscl45nm/gscl45nm.lib',
'pin_constr_file' : asic_cells_base_folder + 'gscl45nm/gscl45nm.constr',
'nand_file' : asic_cells_base_folder + 'gscl45nm/gscl45nm.nand',
'verilog_library' : asic_cells_base_folder + 'gscl45nm/gscl45nm.v',
}

nangate1_library = {
'name' : 'NangateOpenCellLibrary_typical_ccs',
'liberty_file' : asic_cells_base_folder + 'NangateOpenCellLibrary_typical_ccs/NangateOpenCellLibrary_typical_ccs.lib',
'pin_constr_file' : asic_cells_base_folder + 'NangateOpenCellLibrary_typical_ccs/NangateOpenCellLibrary_typical_ccs.constr',
'nand_file' : asic_cells_base_folder + 'NangateOpenCellLibrary_typical_ccs/NangateOpenCellLibrary_typical_ccs.nand',
'verilog_library' : asic_cells_base_folder + 'gscl45nm/gscl45nm.v',
}

# Adding cells to the list

all_std_cells_libraries = []

all_std_cells_libraries += [gscl45nm_library]
all_std_cells_libraries += [nangate1_library]

yosys_location = 'yosys'
all_yosys_asic_synth_script = ['synth_asic.tcl']
all_yosys_simple_synth_script = ['synth_simple.tcl']

# All timing constraints

all_timing_constraints = []
all_timing_constraints += ['10000']


# All entity names

all_entity_names = []
all_entity_names += ['gimli_permutation_rounds_combinational']
all_entity_names += ['gimli_rounds_simple']
all_entity_names += ['gimli_stream']
all_entity_names += ['gimli_lwc']

testbench_folder = '../verilog_source'

# All testbench names

all_testbench_names = [('tb_' + each_entity_name) for each_entity_name in all_entity_names]

# Synthesis output folder

synthesis_output_folder = 'synth_out'

if __name__ == "__main__" :

    if(len(sys.argv) == 1):
        print('This is a basic synthesizes script')
        print('')
        print('You can try to synthesize an entity not named here by just writing the name directly')
        print('synth.py entity_name')
        print('')
        print('You can also synthesize one of the entities already listed here by writing -l and their number')
        print('synth.py -l 0 1 2')
        print('')
        print('If you want everyone to be synthesized you can also just run -all')
        print('synth.py -all')
        print('')
        print('If you want to generate asic csv report use -g')
        print('synth.py -g')
        print('')
        print('Generates the simulation executables of the synthesized design with icarus')
        print('synth.py -sim [-enable_waveform]')
        print('')
        print('Here are all timings in the script')
        for i in range(len(all_timing_constraints)):
            print(all_timing_constraints[i])
        print('')
        print('Here are all entities already in the script')
        for i in range(len(all_entity_names)):
            print(str(i) + ' - ' + all_entity_names[i])
    else:
        if(sys.argv[1] == '-all'):
            synthesize_asic_list(yosys_location, all_yosys_asic_synth_script, all_std_cells_libraries, all_entity_names, all_timing_constraints, synthesis_output_folder)
            synthesize_simple_list(yosys_location, all_yosys_simple_synth_script, all_entity_names, synthesis_output_folder)
        elif(sys.argv[1] == '-l'):
            selected_entity_names = []
            list_of_numbers = [str(i) for i in sys.argv[2:]]
            list_of_numbers = " ".join(list_of_numbers)
            for i in range(len(all_entity_names)):
                if(str(i) in list_of_numbers):
                    selected_entity_names += [all_entity_names[i]]
            synthesize_asic_list(yosys_location, all_yosys_asic_synth_script, all_std_cells_libraries, selected_entity_names, all_timing_constraints, synthesis_output_folder)
            synthesize_simple_list(yosys_location, all_yosys_simple_synth_script, selected_entity_names, synthesis_output_folder)
        elif(sys.argv[1] == '-g'):
            generate_csv_with_all_results(all_yosys_asic_synth_script, all_std_cells_libraries, all_entity_names, all_timing_constraints, synthesis_output_folder)
        elif(sys.argv[1] == '-sim'):
            generate_all_simulation_synthesized_design(all_yosys_asic_synth_script, all_std_cells_libraries, all_entity_names, all_timing_constraints, all_testbench_names, synthesis_output_folder, testbench_folder)
            generate_all_simulation_simple_synthesized_design(all_yosys_simple_synth_script, all_entity_names, all_testbench_names, synthesis_output_folder, testbench_folder)
        else:
            new_entity_name = [sys.argv[2]]
            synthesize_asic_list(yosys_location, all_yosys_asic_synth_script, all_std_cells_libraries, new_entity_name, all_timing_constraints, synthesis_output_folder)
            synthesize_simple_list(yosys_location, all_yosys_simple_synth_script, new_entity_name, synthesis_output_folder)