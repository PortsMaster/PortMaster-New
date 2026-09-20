#ifndef CHOWDREN_STRINGTOKENIZER_H
#define CHOWDREN_STRINGTOKENIZER_H

#include "frameobject.h"
#include <string>
#include "types.h"

class StringTokenizer : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(StringTokenizer)

    vector<std::string> elements;

    StringTokenizer(int x, int y, int type_id);
    void split(const std::string & text, const std::string & delims);
    const std::string & get(int index);

    int get_count()
    {
        return elements.size();
    }
};

#endif // CHOWDREN_STRINGTOKENIZER_H
