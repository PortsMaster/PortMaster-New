#ifndef CHOWDREN_ASSETFILE_H
#define CHOWDREN_ASSETFILE_H

#include "fileio.h"
#include "assets.h"
#include <string>

#define OFFSET_SIZE(x) ((x)>1?(x):1)
#define IMAGE_ARRAY_SIZE OFFSET_SIZE(IMAGE_COUNT)
#define FONT_ARRAY_SIZE OFFSET_SIZE(FONT_COUNT)
#define SOUND_ARRAY_SIZE OFFSET_SIZE(SOUND_COUNT)
#define SHADER_ARRAY_SIZE OFFSET_SIZE(SHADER_COUNT)
#define FILE_ARRAY_SIZE OFFSET_SIZE(FILE_COUNT)
#define INVALID_ASSET_ID ((unsigned int)(-1))

class AssetFile : public FSFile
{
public:
    enum AssetType
    {
        IMAGE_DATA = 0,
        SOUND_DATA,
        FONT_DATA,
        SHADER_DATA,
        FILE_DATA
    };

    AssetFile();
    void open();
    using FSFile::open;
    void set_item(int index, AssetType type);
};

// for temporary files
class TempPath
{
public:
    int id;

    TempPath(int id)
    : id(id)
    {
    }

    void read(std::string & data);
};

TempPath create_temp_file(const std::string & path);

#endif // CHOWDREN_ASSETFILE_H
