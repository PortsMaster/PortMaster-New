#ifndef CHOWDREN_PATH_H
#define CHOWDREN_PATH_H

#include <string>
#include <algorithm>
#include "stringcommon.h"

#define PATH_SEP "\\/"

#ifdef _WIN32
#define PATH_SEP_SINGLE "\\"
#else
#define PATH_SEP_SINGLE "/"
#endif

inline std::string get_app_path()
{
    return "./";
}

inline std::string get_app_drive()
{
    return "";
}

inline std::string get_app_dir()
{
    return "./";
}

inline std::string get_temp_path()
{
    return "./";
}

inline std::string get_path_filename(const std::string & path)
{
    size_t pos = path.find_last_of(PATH_SEP);
    if (pos == std::string::npos)
        return path;
    return path.substr(pos + 1);
}

inline std::string get_path_dirname(const std::string & path)
{
    size_t pos = path.find_last_of(PATH_SEP);
    if (pos == std::string::npos)
        return "";
    return path.substr(0, pos + 1);
}

inline std::string get_path_basename(const std::string & path)
{
    std::string path2 = get_path_filename(path);
    return path2.substr(0, path2.find_last_of("."));
}

inline std::string get_path_ext(const std::string & path)
{
    std::string ext;
    std::string::size_type pos = path.find_last_of(".");
    if (pos != std::string::npos)
        ext = path.substr(pos + 1);
    to_lower(ext);
    return ext;
}

inline std::string join_path(const std::string & a, const std::string & b)
{
    if (a.empty())
        return b;
    char c = a[a.size()-1];
    if (c == '\\' || c == '/')
        return a + b;
    return a + PATH_SEP_SINGLE + b;
}

inline void make_ascii(std::string & path)
{
    std::string::iterator it;
    for (it = path.begin(); it != path.end(); ++it) {
        unsigned char c = (unsigned char)*it;
        switch (c) {
            case 0xC0:
            case 0xC1:
            case 0xC2:
            case 0xC3:
            case 0xC4:
            case 0xC5:
            case 0xC6:
                *it = 'A';
                break;
            case 0xC7:
                *it = 'C';
                break;
            case 0xC8:
            case 0xC9:
            case 0xCA:
            case 0xCB:
                *it = 'E';
                break;
            case 0xCC:
            case 0xCD:
            case 0xCE:
            case 0xCF:
                *it = 'I';
                break;
            case 0xD0:
                *it = 'D';
                break;
            case 0xD1:
                *it = 'N';
                break;
            case 0xD2:
            case 0xD3:
            case 0xD4:
            case 0xD5:
            case 0xD6:
            case 0xD8:
                *it = 'O';
                break;
            case 0xD9:
            case 0xDA:
            case 0xDB:
            case 0xDC:
                *it = 'U';
                break;
            case 0xDD:
                *it = 'Y';
                break;
            case 0xE0:
            case 0xE1:
            case 0xE2:
            case 0xE3:
            case 0xE4:
            case 0xE5:
            case 0xE6:
                *it = 'a';
                break;
            case 0xE7:
                *it = 'c';
                break;
            case 0xE8:
            case 0xE9:
            case 0xEA:
            case 0xEB:
                *it = 'e';
                break;
            case 0xEC:
            case 0xED:
            case 0xEE:
            case 0xEF:
                *it = 'i';
                break;
            case 0xF0:
            case 0xF2:
            case 0xF3:
            case 0xF4:
            case 0xF5:
            case 0xF6:
            case 0xF8:
                *it = 'o';
                break;
            case 0xF9:
            case 0xFA:
            case 0xFB:
            case 0xFC:
                *it = 'u';
                break;
            case 0xFD:
            case 0xFF:
                *it = 'y';
                break;
        }
    }
}

#endif // CHOWDREN_PATH_H
