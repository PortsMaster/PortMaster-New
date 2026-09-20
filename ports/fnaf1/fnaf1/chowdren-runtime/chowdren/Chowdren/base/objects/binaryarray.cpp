#include "objects/binaryarray.h"
#include "chowconfig.h"
#include "fileio.h"
#include "datastream.h"

// Workspace

Workspace::Workspace(BaseStream & stream)
{
    stream.read_c_string(name);
    stream.read(data, stream.read_uint32());
}

Workspace::Workspace(const std::string & name)
: name(name)
{
}

// BinaryArray

BinaryArray::BinaryArray(int x, int y, int type_id)
: FrameObject(x, y, type_id), current(NULL)
{

}

void BinaryArray::load_workspaces(const std::string & filename)
{
    FSFile fp(convert_path(filename).c_str(), "r");
    FileStream stream(fp);
    Workspace * workspace;
    while (!stream.at_end()) {
        workspace = new Workspace(stream);
        workspaces[workspace->name] = workspace;
    }
    fp.close();
    switch_workspace(current);
}

BinaryArray::~BinaryArray()
{
    WorkspaceMap::const_iterator it;
    for (it = workspaces.begin(); it != workspaces.end(); ++it)
        delete it->second;
}

void BinaryArray::create_workspace(const std::string & name)
{
    if (workspaces.find(name) != workspaces.end())
        return;
    Workspace * workspace = new Workspace(name);
    workspaces[name] = workspace;
}

void BinaryArray::switch_workspace(const std::string & name)
{
    WorkspaceMap::const_iterator it = workspaces.find(name);
    if (it == workspaces.end())
        return;
    switch_workspace(it->second);
}

void BinaryArray::switch_workspace(Workspace * workspace)
{
    current = workspace;
}

bool BinaryArray::has_workspace(const std::string & name)
{
    return workspaces.count(name) > 0;
}

void BinaryArray::load_file(const std::string & filename)
{
    size_t size;
    char * data;
    read_file(convert_path(filename).c_str(), &data, &size);
    current->data.write(data, size);
    delete[] data;
}

std::string BinaryArray::read_string(int pos, size_t size)
{
    DataStream stream(current->data);
    stream.seek(pos);
    std::string v;
    stream.read_string(v, size);
    return v;
}

size_t BinaryArray::get_size()
{
    std::stringstream & oss = current->data;
    std::stringstream::pos_type current = oss.tellg();
    oss.seekg(0, std::ios::end);
    std::stringstream::pos_type offset = oss.tellg();
    oss.seekg(current);
    return (size_t)offset;
}
