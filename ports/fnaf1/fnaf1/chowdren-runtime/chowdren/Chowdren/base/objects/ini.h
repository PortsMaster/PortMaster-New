#ifndef CHOWDREN_INI_H
#define CHOWDREN_INI_H

#include "frameobject.h"
#include "types.h"
#include "assetfile.h"

#ifdef CHOWDREN_INI_KEEP_ORDER
#include <boost/container/flat_map.hpp>
#define ini_map boost::container::flat_map
#else
#define ini_map hash_map
#endif

typedef ini_map<std::string, std::string> OptionMap;
typedef ini_map<std::string, OptionMap> SectionMap;

class INI : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(INI)

    static hash_map<std::string, SectionMap> global_data;
    std::string current_group;
    std::string current_item;
    bool is_global;
    SectionMap * data;
    vector<std::pair<std::string, std::string> > search_results;
    bool overwrite;
    bool read_only;
    bool auto_save;
    bool use_compression;
    std::string filename;
    std::string encrypt_key;
    unsigned int search_time;
    bool changed;

    INI(int x, int y, int type_id);
    static void reset_global_data();
#ifdef CHOWDREN_CACHE_INI
    static void reset_cache();
#endif
    static int _parse_handler(void* user, const char* section,
                              const char* name, const char* value);
    void parse_handler(const std::string & section, const std::string & name,
                       const std::string & value);
    void set_group(const std::string & name);
    void set_group(const std::string & name, bool new_group);
    void set_item(const std::string & name);
    const std::string & get_string(const std::string & group,
                                   const std::string & item);
    const std::string & get_string(const std::string & item);
    const std::string & get_string_default(const std::string & group,
                                           const std::string & item,
                                           const std::string & def);
    const std::string & get_string_default(const std::string & item,
                                           const std::string & def);
    const std::string & get_string_index(const std::string & group,
                                         unsigned int index);
    const std::string & get_string_index(unsigned int index);
    const std::string & get_item_name(const std::string & group,
                                      unsigned int index);
    const std::string & get_item_name(unsigned int index);
    const std::string & get_group_name(unsigned int index);

    // value double
    double get_value(const std::string & group, const std::string & item,
                     double def=0.0);
    double get_value(const std::string & item, double def=0.0);
    double get_value_index(const std::string & group, unsigned int index);
    double get_value_index(unsigned int index);
    void set_value(const std::string & group, const std::string & item,
                   double value);
    void set_value(const std::string & item, double value);
    int get_value_int(const std::string & group, const std::string & item,
                      int def=0);
    int get_value_int(const std::string & item, int def=0);
    void set_value_int(const std::string & group, const std::string & item,
                       int value);
    void set_value_int(const std::string & item, int value);
    void set_string(const std::string & group, const std::string & item,
                    const std::string & value);
    void set_string(const std::string & item, const std::string & value);
    void load_file(const std::string & fn, bool read_only = false,
                   bool merge = false, bool overwrite = false);
    void load_string(const std::string & data, bool merge);
    void load_file(TempPath path);
    void merge_file(const std::string & fn, bool overwrite);
    void get_data(std::stringstream & out);
    void save_file(const std::string & fn, bool force = true);
    void set_encryption_key(const std::string & key);
    void set_compression(bool value);
    std::string as_string();
    void save_file(bool force = true);
    void save_auto();
    void close();
    int get_item_count(const std::string & section);
    int get_item_count();
    int get_group_count();
    bool has_group(const std::string & group);
    bool has_item(const std::string & group, const std::string & option);
    bool has_item(const std::string & option);
    void search(const std::string & group, const std::string & item,
                const std::string & value);
    void delete_pattern(const std::string & group, const std::string & item,
                        const std::string & value);
    void sort_group_by_name(const std::string & group);
    void sort_group_by_value(const std::string & group);
    void reset(bool save = true);
    void delete_group(const std::string & group);
    void delete_group();
    void delete_item(const std::string & group, const std::string & item);
    void delete_item(const std::string & item);
    void set_global_data(const std::string & key);
    void merge_object(INI * other, bool overwrite);
    void merge_group(INI * other, const std::string & src_group,
                     const std::string & dst_group, bool overwrite);
    void merge_map(const SectionMap & data2, bool overwrite);
    void merge_map(SectionMap & data2, const std::string & src_group,
                   const std::string & dst_group, bool overwrite);
    bool has_search_results();
    size_t get_search_count();
    const std::string & get_search_result_group(int index);
    const std::string & get_search_result_item(int index);
    std::string get_item_part(const std::string & group,
                              const std::string & item, int index,
                              const std::string & def);
    void set_auto(bool save, bool load);
    ~INI();
};

#endif // CHOWDREN_INI_H
