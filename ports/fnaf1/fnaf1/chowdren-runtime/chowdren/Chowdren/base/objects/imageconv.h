#ifndef CHOWDREN_IMAGECONV_H
#define CHOWDREN_IMAGECONV_H

#include <string>

class ImageManipulator
{
public:
    static void load(const std::string & filename);
    static void save(const std::string & filename);
    static void apply_gauss_blur();
};

#endif // CHOWDREN_IMAGECONV_H
