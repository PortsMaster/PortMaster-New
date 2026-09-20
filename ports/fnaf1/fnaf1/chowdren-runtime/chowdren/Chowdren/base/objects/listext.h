#ifndef CHOWDREN_LISTEXT_H
#define CHOWDREN_LISTEXT_H

#include "frameobject.h"
#include <string>
#include "datastream.h"
#include "types.h"

typedef vector<std::string> StringList;

class ListObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ListObject)

    enum ListFlags
    {
        SORT_LIST = 1 << 0
    };

    StringList lines;
    int list_flags;
    int current_line;
    int index_offset;

    ListObject(int x, int y, int type_id);
    void load_file(const std::string & name);
    void add_line(const std::string & value);
    void set_line(int index, const std::string & value);
    void delete_line(int line);
    void clear();
    const std::string & get_line(int i);
    const std::string & get_current_line();
    int get_count();
    bool get_focus();
    void disable_focus();
    int find_string(const std::string & text, int flag);
    int find_string_exact(const std::string & text, int flag);
    void sort();
};

#endif // CHOWDREN_LISTEXT_H
