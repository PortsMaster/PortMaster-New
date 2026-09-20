#include <string>
#include "types.h"

enum EREGISTER_SET
{
    RS_BOOL,
    RS_INT4,
    RS_FLOAT4,
    RS_SAMPLER
};

struct ConstantDesc
{
    std::string Name;
    EREGISTER_SET RegisterSet;
    int RegisterIndex;
    int RegisterCount;
    int Rows;
    int Columns;
    int Elements;
    int StructMembers;
    size_t Bytes;
};

class ConstantTable
{
public:
    vector<ConstantDesc> constants;

    bool read(const void* data);
    int get_constant(const char * name);
};

// Structs
struct CTHeader
{
    uint32_t Size;
    uint32_t Creator;
    uint32_t Version;
    uint32_t Constants;
    uint32_t ConstantInfo;
    uint32_t Flags;
    uint32_t Target;
};

struct CTInfo
{
    uint32_t Name;
    uint16_t RegisterSet;
    uint16_t RegisterIndex;
    uint16_t RegisterCount;
    uint16_t Reserved;
    uint32_t TypeInfo;
    uint32_t DefaultValue;
};

struct CTType
{
    uint16_t Class;
    uint16_t Type;
    uint16_t Rows;
    uint16_t Columns;
    uint16_t Elements;
    uint16_t StructMembers;
    uint32_t StructMemberInfo;
};

// Shader instruction opcodes
const uint32_t SIO_COMMENT = 0x0000FFFE;
const uint32_t SIO_END = 0x0000FFFF;
const uint32_t SI_OPCODE_MASK = 0x0000FFFF;
const uint32_t SI_COMMENTSIZE_MASK = 0x7FFF0000;
const uint32_t CTAB_CONSTANT = 0x42415443;

// Member functions
bool ConstantTable::read(const void* data)
{
    constants.clear();

    const uint32_t* ptr = (const uint32_t*)(data);
    while(*++ptr != SIO_END) {
        if ((*ptr & SI_OPCODE_MASK) == SIO_COMMENT) {
            // Check for CTAB comment
            uint32_t comment_size = (*ptr & SI_COMMENTSIZE_MASK) >> 16;
            if (*(ptr+1) != CTAB_CONSTANT) {
                ptr += comment_size;
                continue;
            }

            // Read header
            const char* ctab = (const char*)(ptr+2);
            size_t ctab_size = (comment_size-1)*4;

            const CTHeader* header = (const CTHeader*)(ctab);
            if(ctab_size < sizeof(*header) || header->Size != sizeof(*header))
                return false;

            // Read constants
            constants.reserve(header->Constants);
            const CTInfo* info = (const CTInfo*)(ctab + header->ConstantInfo);
            for(uint32_t i = 0; i < header->Constants; ++i) {
                const CTType* type = (const CTType*)(ctab + info[i].TypeInfo);

                // Fill struct
                ConstantDesc desc;
                desc.Name = ctab + info[i].Name;
                desc.RegisterSet = (EREGISTER_SET)(info[i].RegisterSet);
                desc.RegisterIndex = info[i].RegisterIndex;
                desc.RegisterCount = info[i].RegisterCount;
                desc.Rows = type->Rows;
                desc.Columns = type->Columns;
                desc.Elements = type->Elements;
                desc.StructMembers = type->StructMembers;
                desc.Bytes = 4 * desc.Elements * desc.Rows * desc.Columns;
                constants.push_back(desc);
            }
            return true;
        }
    }
    return false;
}

int ConstantTable::get_constant(const char * name)
{
    vector<ConstantDesc>::const_iterator it;
    for(it = constants.begin(); it != constants.end(); ++it) {
        if (it->Name.compare(1, std::string::npos, name) == 0)
            return it->RegisterIndex;
    }
    return -1;
}
