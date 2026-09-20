#ifndef CHOWDREN_KEYCONV_H
#define CHOWDREN_KEYCONV_H

#include <string>

int translate_vk_to_key(int vk);
int translate_string_to_key(const std::string & name);
std::string translate_vk_to_string(int vk);
std::string translate_key_to_string(int key);

#endif // CHOWDREN_KEYCONV_H
