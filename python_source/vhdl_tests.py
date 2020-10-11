#!/usr/bin/env python3

import os
import random

import gimli

from hacspec.speclib import *

def print_state_to_VHDL(x, file):
    output = ""
    for j in range(12):
        output =  ("{0:0"+str(32)+"b}").format(int(x[j])) + output
    file.write(output)
    file.write('\n')

def print_gimli_permutation(number_of_tests, VHDL_file_name="gimli_permutation.dat"):
    tests_folder = "../data_tests/"
    if(not os.path.isdir(tests_folder)):
        os.makedirs(tests_folder)
    with open(tests_folder+VHDL_file_name, 'w') as VHDL_memory_file:
        VHDL_memory_file.write((("{0:0d}").format(number_of_tests)))
        VHDL_memory_file.write('\n')
        const_state_t = array_t(uint32_t, 12)
        x = const_state_t([uint32(0x6467d8c4), uint32(0x07dcf83b), uint32(0x3b0bb0d4), uint32(0x1b21364c),
                           uint32(0x083431dc), uint32(0x0efbbe8e), uint32(0x0054e884), uint32(0x648bd955),
                           uint32(0x4a5db42e), uint32(0xca0641cb), uint32(0x8673d2c2), uint32(0x2e30d809)])
        for i in range(number_of_tests):
            print_state_to_VHDL(x, VHDL_memory_file)
            x = gimli.gimli(x)
            print_state_to_VHDL(x, VHDL_memory_file)
            nx = [uint32(random.randint(0, 2**32-1)) for j in range(12)]
            x = const_state_t(nx)

if __name__ == "__main__":
    print_gimli_permutation(100)
