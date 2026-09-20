#ifndef CHOWDREN_STRINGREPLACE_H
#define CHOWDREN_STRINGREPLACE_H

#include <string>
#include "types.h"
#include "frameobject.h"

class StringReplacement
{
public:
    std::string from, to;

    StringReplacement(const std::string & from, const std::string & to)
    : from(from), to(to)
    {
    }
};

class StringReplace : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(StringReplace)

    vector<StringReplacement> replacements;

    StringReplace(int x, int y, int id);

    void add_replacement(const std::string & from,
                         const std::string & to);

    static std::string replace(const std::string & src,
                               const std::string & from,
                               const std::string & to);
    std::string replace(const std::string & src);
};

#endif // CHOWDREN_STRINGREPLACE_H
