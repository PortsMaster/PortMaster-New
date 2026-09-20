#ifndef CHOWDREN_BLOWFISH_H
#define CHOWDREN_BLOWFISH_H

#include <stdint.h>
#include <stddef.h>
#include <string>

class Blowfish {
public:
    void set_key(const std::string& key);
    void set_key(const char* key, size_t byte_length);

    // Buffer will be padded with PKCS #5 automatically
    // "dst" and "src" must be different instance
    void encrypt(std::string* dst, const std::string& src) const;
    void decrypt(std::string* dst, const std::string& src) const;

    // Buffer length must be a multiple of the block length (64bit)
    void encrypt(char* dst, const char* src, size_t byte_length) const;
    void decrypt(char* dst, const char* src, size_t byte_length) const;

private:
    void encrypt_block(uint32_t *left, uint32_t *right) const;
    void decrypt_block(uint32_t *left, uint32_t *right) const;
    uint32_t feistel(uint32_t value) const;

private:
    uint32_t pary_[18];
    uint32_t sbox_[4][256];
};

#endif // CHOWDREN_BLOWFISH_H
