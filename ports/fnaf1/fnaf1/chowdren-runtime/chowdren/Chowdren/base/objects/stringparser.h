#ifndef CHOWDREN_STRINGPARSER_H
#define CHOWDREN_STRINGPARSER_H

#include <string>
#include "types.h"
#include "frameobject.h"

class StringParser : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(StringParser)

    vector<std::string> elements;
    std::string delimiters;
    std::string value;
    bool has_split;

    StringParser(int x, int y, int id);
    void split();
    void load(const std::string & filename);
    void set(const std::string & value);
    void add_delimiter(const std::string & delim);
    void reset_delimiters();
    const std::string & get_element(int index);
    std::string set_element(const std::string & value, int index);
    const std::string & get_last_element();
    std::string replace(const std::string & from, const std::string & to);
    std::string remove(const std::string & sub);
    int get_count();
    std::string get_md5();
};

#endif // CHOWDREN_STRINGPARSER_H
