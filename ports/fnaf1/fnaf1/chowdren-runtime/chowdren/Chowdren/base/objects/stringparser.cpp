#include "objects/stringparser.h"
#include "stringcommon.h"
#include "common.h"
#include "fileio.h"

StringParser::StringParser(int x, int y, int id)
: FrameObject(x, y, id), has_split(false)
{

}

void StringParser::add_delimiter(const std::string & v)
{
    if (v.size() != 1) {
        std::cout << "Delimiter size " << v.size() << " not supported"
            << std::endl;
        return;
    }
    delimiters += v;
}

void StringParser::reset_delimiters()
{
    delimiters.clear();
    has_split = false;
}

void StringParser::load(const std::string & filename)
{
    if (filename[0] == '[')
        // work around HFA bug
        return;
    read_file(filename.c_str(), value);
}

void StringParser::split()
{
    if (has_split)
        return;
    elements.clear();
    split_string(value, delimiters, elements);
    has_split = true;
}

void StringParser::set(const std::string & v)
{
    value = v;
    has_split = false;
}

int StringParser::get_count()
{
    split();
    return int(elements.size());
}

std::string StringParser::set_element(const std::string & value, int index)
{
    if (delimiters.size() <= 0)
        return value;
    index--;
    split();
    std::string ret;
    vector<std::string>::const_iterator it;

    for (int i = 0; i < int(elements.size()); i++) {
        if (i == index)
            ret += value;
        else
            ret += elements[i];
        // XXX not entirely correct behaviour, but good enough
        if (i < int(elements.size()) - 1)
            ret += delimiters[0];
    }
    return ret;
}

const std::string & StringParser::get_element(int i)
{
    i--;
    split();
    if (i < 0 || i >= int(elements.size()))
        return empty_string;
    return elements[i];
}

const std::string & StringParser::get_last_element()
{
    split();
    if (elements.empty())
        return empty_string;
    return elements[elements.size()-1];
}

std::string StringParser::replace(const std::string & from,
                                  const std::string & to)
{
    std::string ret = value;
    replace_substring(ret, from, to);
    return ret;
}

std::string StringParser::remove(const std::string & sub)
{
    std::string ret = value;
    replace_substring(ret, sub, empty_string);
    return ret;
}

std::string StringParser::get_md5()
{
    return ::get_md5(value);
}
