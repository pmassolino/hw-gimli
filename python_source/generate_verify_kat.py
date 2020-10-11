#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import hacspec.speclib

import gimli_aead
import gimli_hash

import binascii

def init_buffer(number_bytes):
    value = bytearray(number_bytes)
    for i in range(number_bytes):
        value[i] = i % 256
    return value
    
def generate_hash_test(test_file_name = "LWC_HASH_KAT_256_p.txt", number_of_tests = 1024):
    out_file = open(test_file_name, 'w')
    messages = init_buffer(number_of_tests)
    for count in range(number_of_tests+1):
        processed_message = hacspec.speclib.bytes.from_hex(messages[:count].hex())
        hash_out = gimli_hash.gimli_hash(processed_message, len(processed_message))
        hash_out_str = hacspec.speclib.bytes.to_hex(hash_out)
        out_file.write("Count = " + str(count+1) + '\n')
        out_file.write("Msg = " + ((messages[:count]).hex()).upper() + '\n')
        out_file.write("MD = " + (hash_out_str).upper() + '\n')
        out_file.write("\n")
    out_file.close()

def verify_hash_test(test_file_name = "LWC_HASH_KAT_256_p.txt"):
    read_file = open(test_file_name, 'r')
    current_line = read_file.readline()
    while(current_line != ''):
        count_str = (current_line.split('=')[1]).strip()
        count = int(count_str)
        current_line = read_file.readline()
        message_str = (current_line.split('=')[1]).strip()
        message = hacspec.speclib.bytes.from_hex(message_str)
        current_line = read_file.readline()
        expected_hash_str = (current_line.split('=')[1]).strip()
        expected_hash = hacspec.speclib.bytes.from_hex(expected_hash_str)
        hash_out = gimli_hash.gimli_hash(message, len(message))
        if(hash_out != expected_hash):
            hash_out_str = hacspec.speclib.bytes.to_hex(hash_out)
            print("Count = " + str(count) + '\n')
            print("Msg = " + message_str + '\n')
            print("MD = " + expected_hash_str + '\n')
            print("MD = " + (hash_out_str).upper() + '\n')
            print("\n")
            break
        current_line = read_file.readline() # There is one blank line between tests
        current_line = read_file.readline()
    read_file.close()

def generate_aead_test(test_file_name = "LWC_AEAD_KAT_256_128_p.txt", number_of_tests_m = 32, number_of_tests_ad = 32, tag_bytes = 16, nonce_bytes = 16, key_bytes = 32):
    out_file = open(test_file_name, 'w')
    messages = init_buffer(number_of_tests_m)
    associated_datas = init_buffer(number_of_tests_ad)
    nonce = init_buffer(nonce_bytes)
    key = init_buffer(key_bytes)
    count = 1
    for i in range(number_of_tests_m+1):
        for j in range(number_of_tests_ad+1):
            processed_message = hacspec.speclib.bytes.from_hex((messages[:i]).hex())
            processed_associated_datas = hacspec.speclib.bytes.from_hex((associated_datas[:j]).hex())
            processed_nonce = hacspec.speclib.bytes.from_hex((nonce).hex())
            processed_key = hacspec.speclib.bytes.from_hex((key).hex())
            ciphertext, tag = gimli_aead.gimli_aead_encrypt(processed_message, processed_associated_datas, processed_nonce, processed_key)
            ciphertext_str = hacspec.speclib.bytes.to_hex(ciphertext)
            tag_str = hacspec.speclib.bytes.to_hex(tag)
            out_file.write("Count = " + str(count) + '\n')
            out_file.write("Key = " + ((key).hex()).upper() + '\n')
            out_file.write("Nonce = " + ((nonce).hex()).upper() + '\n')
            out_file.write("PT = " + ((messages[:i]).hex()).upper() + '\n')
            out_file.write("AD = " + ((associated_datas[:j]).hex()).upper() + '\n')
            out_file.write("CT = " + (ciphertext_str).upper() + (tag_str).upper() + '\n')
            out_file.write("\n")
            count += 1
    out_file.close()

def verify_aead_test(test_file_name = "LWC_AEAD_KAT_256_128_p.txt", tag_bytes = 16):
    read_file = open(test_file_name, 'r')
    current_line = read_file.readline()
    while(current_line != ''):
        count_str = (current_line.split('=')[1]).strip()
        count = int(count_str)
        current_line = read_file.readline()
        key_str = (current_line.split('=')[1]).strip()
        key = hacspec.speclib.bytes.from_hex(key_str)
        current_line = read_file.readline()
        nonce_str = (current_line.split('=')[1]).strip()
        nonce = hacspec.speclib.bytes.from_hex(nonce_str)
        current_line = read_file.readline()
        message_str = (current_line.split('=')[1]).strip()
        message = bytearray.fromhex(message_str)
        current_line = read_file.readline()
        associated_data_str = (current_line.split('=')[1]).strip()
        associated_data = hacspec.speclib.bytes.from_hex(associated_data_str)
        current_line = read_file.readline()
        ciphertext_str = (current_line.split('=')[1]).strip()
        ciphertext = hacspec.speclib.bytes.from_hex(ciphertext_str[:len(message_str)])
        tag = hacspec.speclib.bytes.from_hex(ciphertext_str[len(message_str):])
        message = gimli_aead.gimli_aead_decrypt(ciphertext, associated_data, tag, nonce, key)
        current_line = read_file.readline() # There is one blank line between tests
        current_line = read_file.readline()
    read_file.close()

#generate_hash_test()
#verify_hash_test(test_file_name = "../data_tests/LWC_HASH_KAT_256.txt")
generate_aead_test()
#verify_aead_test(test_file_name = "../data_tests/LWC_AEAD_KAT_256_128.txt")