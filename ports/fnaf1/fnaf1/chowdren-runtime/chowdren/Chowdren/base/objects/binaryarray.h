#ifndef CHOWDREN_BINARYARRAY_H
#define CHOWDREN_BINARYARRAY_H

#include "frameobject.h"
#include <string>
#include "datastream.h"
#include "types.h"

class Workspace
{
public:
    std::string name;
    std::stringstream data;

    Workspace(BaseStream & stream);
    Workspace(const std::string & name);
};

typedef hash_map<std::string, Workspace*> WorkspaceMap;

class BinaryArray : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(BinaryArray)

    WorkspaceMap workspaces;
    Workspace * current;

    BinaryArray(int x, int y, int type_id);
    ~BinaryArray();
    void load_workspaces(const std::string & filename);
    void create_workspace(const std::string & name);
    void switch_workspace(const std::string & name);
    void switch_workspace(Workspace * workspace);
    bool has_workspace(const std::string & name);
    void load_file(const std::string & filename);
    std::string read_string(int pos, size_t size);
    size_t get_size();
};

#endif // CHOWDREN_BINARYARRAY_H
