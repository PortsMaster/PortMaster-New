#include "objects/listext.h"
#include "chowconfig.h"

// ListObject

ListObject::ListObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), list_flags(0)
{

}

void ListObject::load_file(const std::string & name)
{
    std::string data;
    if (!read_file(name.c_str(), data))
        return;
    StringStream ss(data);
    std::string line;
    while (!ss.at_end()) {
        ss.read_line(line);
        add_line(line);
    }

    if (list_flags & SORT_LIST)
        sort();
}

void ListObject::delete_line(int line)
{
    line += index_offset;
    if (line < 0 || line >= int(lines.size()))
        return;
    lines.erase(lines.begin() + line);
}

void ListObject::clear()
{
    lines.clear();
}

void ListObject::add_line(const std::string & value)
{
    lines.push_back(value);

    if (list_flags & SORT_LIST)
        sort();
}

const std::string & ListObject::get_line(int i)
{
    i += index_offset;
    if (i < 0 || i >= int(lines.size()))
        return empty_string;
    return lines[i];
}

const std::string & ListObject::get_current_line()
{
    return get_line(current_line);
}

int ListObject::find_string(const std::string & text, int flag)
{
    std::cout << "ListObject::find_string not implemented: " << text << " "
        << flag << std::endl;
    return -1;
}

int ListObject::find_string_exact(const std::string & text, int flag)
{
    std::cout << "ListObject::find_string_exact not implemented: "
        << text << " " << flag << std::endl;
    return -1;
}

void ListObject::set_line(int line, const std::string & value)
{
    line += index_offset;
    if (line < 0 || line >= int(lines.size()))
        return;
    lines[line] = value;

    if (list_flags & SORT_LIST)
        sort();
}

int ListObject::get_count()
{
    return int(lines.size());
}

bool ListObject::get_focus()
{
    // std::cout << "List: get_focus not implemented" << std::endl;
    return false;
}

void ListObject::disable_focus()
{
    // std::cout << "List: disable_focus not implemented" << std::endl;
}

void ListObject::sort()
{
    std::sort(lines.begin(), lines.end());
}
