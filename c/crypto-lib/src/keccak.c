/**
 * @file keccak.c
 * @brief Keccak-256 hash implementation for Ethereum addresses
 */

#include "keccak.h"
#include <string.h>
#include <stdio.h>
#include <ctype.h>

// Keccak round constants
static const uint64_t keccak_round_constants[24] = {
    0x0000000000000001ULL, 0x0000000000008082ULL, 0x800000000000808aULL,
    0x8000000080008000ULL, 0x000000000000808bULL, 0x0000000080000001ULL,
    0x8000000080008081ULL, 0x8000000000008009ULL, 0x000000000000008aULL,
    0x0000000000000088ULL, 0x0000000080008009ULL, 0x000000008000000aULL,
    0x000000008000808bULL, 0x800000000000008bULL, 0x8000000000008089ULL,
    0x8000000000008003ULL, 0x8000000000008002ULL, 0x8000000000000080ULL,
    0x000000000000800aULL, 0x800000008000000aULL, 0x8000000080008081ULL,
    0x8000000000008080ULL, 0x0000000080000001ULL, 0x8000000080008008ULL
};

// Rotation offsets
static const int keccak_rotations[24] = {
    1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
    27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
};

// Simplified Keccak-256 (for demonstration)
void keccak256(const uint8_t *input, size_t input_len, uint8_t *output) {
    // This is a simplified version for demonstration
    // In production, use a proper crypto library like OpenSSL or libkeccak

    uint8_t state[200] = {0};

    // Absorb phase
    size_t rate = 136; // 1088 bits / 8
    size_t offset = 0;

    while (offset < input_len) {
        size_t block_size = (input_len - offset < rate) ?
                           (input_len - offset) : rate;

        for (size_t i = 0; i < block_size; i++) {
            state[i] ^= input[offset + i];
        }

        // Keccak-f[1600] permutation would go here
        // (simplified for this example)

        offset += block_size;
    }

    // Padding
    state[input_len % rate] ^= 0x01;
    state[rate - 1] ^= 0x80;

    // Squeeze phase
    memcpy(output, state, KECCAK256_HASH_SIZE);
}

void bytes_to_hex(const uint8_t *bytes, size_t len, char *hex_out) {
    for (size_t i = 0; i < len; i++) {
        sprintf(hex_out + (i * 2), "%02x", bytes[i]);
    }
    hex_out[len * 2] = '\0';
}

int hex_to_bytes(const char *hex, uint8_t *bytes, size_t len) {
    size_t hex_len = strlen(hex);

    if (hex_len % 2 != 0) {
        return -1;
    }

    if (hex_len / 2 != len) {
        return -1;
    }

    for (size_t i = 0; i < len; i++) {
        char byte_str[3] = {hex[i * 2], hex[i * 2 + 1], '\0'};
        bytes[i] = (uint8_t)strtol(byte_str, NULL, 16);
    }

    return 0;
}
