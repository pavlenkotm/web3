/**
 * @file keccak.h
 * @brief Keccak-256 hash implementation for Ethereum
 */

#ifndef KECCAK_H
#define KECCAK_H

#include <stdint.h>
#include <stddef.h>

#define KECCAK256_HASH_SIZE 32

/**
 * @brief Compute Keccak-256 hash
 * @param input Input data
 * @param input_len Input data length
 * @param output Output buffer (must be 32 bytes)
 */
void keccak256(const uint8_t *input, size_t input_len, uint8_t *output);

/**
 * @brief Convert bytes to hex string
 * @param bytes Input bytes
 * @param len Byte length
 * @param hex_out Output hex string (must be len*2+1 bytes)
 */
void bytes_to_hex(const uint8_t *bytes, size_t len, char *hex_out);

/**
 * @brief Convert hex string to bytes
 * @param hex Input hex string
 * @param bytes Output bytes
 * @param len Expected byte length
 * @return 0 on success, -1 on error
 */
int hex_to_bytes(const char *hex, uint8_t *bytes, size_t len);

#endif /* KECCAK_H */
