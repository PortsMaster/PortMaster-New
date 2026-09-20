#include "objects/stringtokenizer.h"
#include "stringcommon.h"

// StringTokenizer

StringTokenizer::StringTokenizer(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
}

void StringTokenizer::split(const std::string & text,
                            const std::string & delims)
{
    elements.clear();
    split_string(text, delims, elements);
}

const std::string & StringTokenizer::get(int index)
{
    if (index < 0 || index >= int(elements.size()))
        return empty_string;
    return elements[index];
}
