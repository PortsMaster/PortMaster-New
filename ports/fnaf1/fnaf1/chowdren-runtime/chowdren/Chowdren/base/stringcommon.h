#ifndef CHOWDREN_STRINGCOMMON_H
#define CHOWDREN_STRINGCOMMON_H

#include <string>
#include <sstream>
#include <ctype.h>
#include "types.h"
#include <algorithm>
#include "dynnum.h"
#include <boost/algorithm/string/replace.hpp>

int fast_atoi(const std::string & value);
double fast_atof(const char * p, const char * end);
std::string fast_itoa(int value);
std::string fast_lltoa(long long value);
std::string fast_dtoa(double value);

extern std::string empty_string;

inline double string_to_double(const std::string & in)
{
    if (in.empty())
        return 0.0;
    const char * start = &in[0];
    const char * end = start + in.size();
    return fast_atof(start, end);
}

inline int string_to_int(const std::string & in)
{
    return fast_atoi(in);
}

inline double string_to_number(const std::string & in)
{
#ifdef CHOWDREN_USE_DYNAMIC_NUMBER
    double ret = string_to_double(in);
    int int_ret = int(ret);
    if (int_ret == ret)
        return DynamicNumber(int_ret);
    return DynamicNumber(ret);
#else
    return string_to_double(in);
#endif
}

inline const std::string & number_to_string(const std::string & value)
{
    return value;
}

inline std::string number_to_string(double value)
{
    return fast_dtoa(value);
}

inline std::string number_to_string(int value)
{
    return fast_itoa(value);
}

inline std::string number_to_string(size_t value)
{
    return fast_itoa(value);
}

inline std::string number_to_string(long long value)
{
    return fast_lltoa(value);
}

// On LP64/LLP64 (any 64-bit ABI), size_t and uint64_t are the same type,
// so this overload would collide with number_to_string(size_t) above.
#if !defined(_LP64) && !defined(__LP64__) && !defined(_WIN64)
inline std::string number_to_string(uint64_t value)
{
    return fast_lltoa(value);
}
#endif

inline void to_lower(std::string & str)
{
    std::transform(str.begin(), str.end(), str.begin(),
                   static_cast<int(*)(int)>(tolower));
}

inline void replace_substring(std::string & str,
                              const std::string & from,
                              const std::string & to)
{
    if (from.empty())
        return;
    boost::algorithm::replace_all(str, from, to);
}

// case-insensitive version
inline void ireplace_substring(std::string & str,
                               const std::string & from,
                               const std::string & to)
{
    if (from.empty())
        return;
    boost::algorithm::ireplace_all(str, from, to);
}

inline void split_string(const std::string & s, char delim,
                         vector<std::string> & elems)
{
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

inline void split_string(const std::string & str, const std::string & delims,
                         vector<std::string> & elems)
{
    std::string::size_type last_pos = str.find_first_not_of(delims, 0);
    std::string::size_type pos = str.find_first_of(delims, last_pos);

    while (std::string::npos != pos || std::string::npos != last_pos) {
        elems.push_back(str.substr(last_pos, pos - last_pos));
        last_pos = str.find_first_not_of(delims, pos);
        pos = str.find_first_of(delims, last_pos);
    }
}

inline bool ends_with(const std::string & str, const std::string & suffix)
{
    if (str.size() < suffix.size())
        return false;
    return str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

#endif // CHOWDREN_STRINGCOMMON_H
