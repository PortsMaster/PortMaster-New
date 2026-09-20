#include "objects/stringreplace.h"
#include "stringcommon.h"

StringReplace::StringReplace(int x, int y, int id)
: FrameObject(x, y, id)
{
}

void StringReplace::add_replacement(const std::string & from,
                                    const std::string & to)
{
    replacements.push_back(StringReplacement(from, to));
}

std::string StringReplace::replace(const std::string & src,
                                   const std::string & from,
                                   const std::string & to)
{
    std::string ret(src);
    ireplace_substring(ret, from, to);
    return ret;
}

std::string StringReplace::replace(const std::string & src)
{
    std::string ret(src);
    vector<StringReplacement>::const_iterator it;
    for (it = replacements.begin(); it != replacements.end(); it++) {
        const StringReplacement & r = *it;
        ireplace_substring(ret, r.from, r.to);
    }
    return ret;
}
