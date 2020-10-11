#!/usr/bin/env python3

from hacspec.speclib import *

from gimli import gimli
from gimli_hash import gimli_hash
from gimli_aead import gimli_aead_encrypt, gimli_aead_decrypt


def test_permutation() -> None:
    # Verify the all 0 test vector
    const_state_t = array_t(uint32_t, 12)
    zero_state = const_state_t([uint32(0) for _ in range(12)])
    exp_state = const_state_t([uint32(0x6467d8c4), uint32(0x07dcf83b), uint32(0x3b0bb0d4), uint32(0x1b21364c),
                               uint32(0x083431dc), uint32(0x0efbbe8e), uint32(0x0054e884), uint32(0x648bd955),
                               uint32(0x4a5db42e), uint32(0xca0641cb), uint32(0x8673d2c2), uint32(0x2e30d809)])

    res_state = gimli(zero_state)
    if (res_state == exp_state):
        print("[SUCCESS] Gimli-permutation passed.")
    else:
        print("[FAIL] Gimli-permutation, all zero test vector not passed.")

def test_hash() -> None:
    input_length = 1
    message_t = array_t(uint8_t, input_length)
    hash_t = array_t(uint8_t, 32)

    input_state = message_t([uint8(0xff)])
    exp_output = hash_t([uint8(0x83), uint8(0x1c), uint8(0x87), uint8(0x6d),
                         uint8(0xa3), uint8(0x3a), uint8(0x2d), uint8(0x6c),
                         uint8(0xc4), uint8(0x87), uint8(0xfe), uint8(0x53),
                         uint8(0x6a), uint8(0x27), uint8(0x25), uint8(0x91),
                         uint8(0x1b), uint8(0x6b), uint8(0xd7), uint8(0xdc),
                         uint8(0x73), uint8(0x84), uint8(0x65), uint8(0x2f),
                         uint8(0x71), uint8(0x23), uint8(0x5f), uint8(0x5f),
                         uint8(0x53), uint8(0xd3), uint8(0x03), uint8(0x29)])
    output = gimli_hash(input_state, input_length)
    if output != exp_output:
        print("[FAIL] Gimli-hash testvector not passed.")
    else:
        print("[SUCCESS] Gimli-hash passed.")

def test_aead_encrypt() -> None:
    adlen = 1
    mlen = 1
    key_t = array_t(uint8_t, 32)
    nonce_t = array_t(uint8_t, 16)
    ad_t = array_t(uint8_t, adlen)
    msg_t = array_t(uint8_t, mlen)
    ct_t = array_t(uint8_t, 17)

    key = key_t([uint8(i) for i in range(32)])
    nonce = nonce_t([uint8(i) for i in range(16)])
    ad = ad_t([uint8(0x00)])
    msg = msg_t([uint8(0x00)])
    ct = ct_t([uint8(i) for i in [
        0xD4, 0x4B, 0xFE, 0xBD, 0xB1, 0x38, 0x2A, 0x0F, 0xAC, 0x73, 0xBC, 0x9C, 0xDD, 0x06, 0x57, 0xC7, 0x62
    ]])

    out, tag = gimli_aead_encrypt(msg, ad, nonce, key)

    if out != ct[:mlen] or tag != ct[mlen:]:
        print("[FAIL] Gimli-aead encrypt testvector not passed.")
    else:
        print("[SUCCESS] Gimli-aead encrypt passed.")

def test_aead_decrypt() -> None:
    adlen = 1
    mlen = 1
    key_t = array_t(uint8_t, 32)
    nonce_t = array_t(uint8_t, 16)
    ad_t = array_t(uint8_t, adlen)
    msg_t = array_t(uint8_t, mlen)
    ct_t = array_t(uint8_t, 17)

    key = key_t([uint8(i) for i in range(32)])
    nonce = nonce_t([uint8(i) for i in range(16)])
    ad = ad_t([uint8(0x00)])
    msg = msg_t([uint8(0x00)])
    ct = ct_t([uint8(i) for i in [
        0xD4, 0x4B, 0xFE, 0xBD, 0xB1, 0x38, 0x2A, 0x0F, 0xAC, 0x73, 0xBC, 0x9C, 0xDD, 0x06, 0x57, 0xC7, 0x62
    ]])

    out = gimli_aead_decrypt(ct[:mlen], ad, ct[mlen:], nonce, key)

    if out != msg[:mlen]:
        print("[FAIL] Gimli-aead decrypt testvector not passed.")
    else:
        print("[SUCCESS] Gimli-aead decrypt passed.")

def test_own_hash() -> None:
    input_length = 0
    message_t = array_t(uint8_t, input_length)
    hash_t = array_t(uint8_t, 32)

    input_state = message_t([])
    output = gimli_hash(input_state, input_length)
    print(output)

def test_own_aead_encryption() -> None:
    adlen = 0
    mlen = 0
    key_t = array_t(uint8_t, 32)
    nonce_t = array_t(uint8_t, 16)
    ad_t = array_t(uint8_t, adlen)
    msg_t = array_t(uint8_t, mlen)
    ct_t = array_t(uint8_t, 16+mlen)

    key = key_t([uint8(i) for i in range(32)])
    nonce = nonce_t([uint8(i) for i in range(16)])
    ad = ad_t([])
    msg = msg_t([])

    out, tag = gimli_aead_encrypt(msg, ad, nonce, key)

    print(out)
    print(tag)

def test_own_aead_decryption() -> None:
    adlen = 0
    mlen = 0
    key_t = array_t(uint8_t, 32)
    nonce_t = array_t(uint8_t, 16)
    ad_t = array_t(uint8_t, adlen)
    msg_t = array_t(uint8_t, mlen)
    ct_t = array_t(uint8_t, 0+mlen)

    key = key_t([uint8(i) for i in range(32)])
    nonce = nonce_t([uint8(i) for i in range(16)])
    ad = ad_t([])
    msg = msg_t([])
    ct = ct_t([uint8(i) for i in [
        0x14, 0xda, 0x9b, 0xb7, 0x12, 0x0b, 0xf5, 0x8b, 0x98, 0x5a, 0x8e, 0x00, 0xfd, 0xeb, 0xa1, 0x5b
    ]])

    out = gimli_aead_decrypt(ct[:mlen], ad, ct[mlen:], nonce, key)

    print(out)

if __name__ == "__main__":
    test_permutation()
    test_hash()
    test_aead_encrypt()
    test_aead_decrypt()
    
    #test_own_hash()
    #test_own_aead_encryption()
    #test_own_aead_decryption()
