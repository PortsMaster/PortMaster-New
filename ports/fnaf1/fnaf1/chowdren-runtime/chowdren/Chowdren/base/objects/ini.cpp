// INI

#include "objects/ini.h"
#include "objects/iniparser.cpp"
#include "stringcommon.h"
#include "huffman.h"
#include "fileio.h"
#include "frame.h"
#include "path.h"

#ifdef CHOWDREN_CACHE_INI
#include "types.h"

typedef hash_map<std::string, SectionMap> INICache;
static INICache ini_cache;
#endif

#ifdef CHOWDREN_USE_BLOWFISH_CACHE
#include "objects/blowfishext.h"
#endif

inline bool match_wildcard(const std::string & pattern,
                           const std::string & value)
{
    if (pattern.empty() || value.empty())
        return pattern == value;
    if (pattern == "*")
        return true;
    else if (pattern[0] == '*') {
        size_t size = pattern.size() - 1;
        if (size > value.size())
            return false;
        return pattern.compare(1, size, value, value.size() - size, size) == 0;
    } else if (pattern[pattern.size() - 1] == '*') {
        size_t size = pattern.size() - 1;
        if (size > value.size())
            return false;
        return pattern.compare(0, size, value, 0, size) == 0;
    } else if (std::count(pattern.begin(), pattern.end(), '*') > 0) {
        std::cout << "Generic wildcard not implemented yet: " << pattern
            << std::endl;
        return false;
    }
    return value == pattern;
}

static void encrypt_ini_data(std::string & data, const std::string & key)
{
    char v5[256];
    char v10[256];
    unsigned int v6 = 0;
    char v9 = 0;

    for (int i = 0; i < 256; i++) {
        v10[i] = i;
        v5[i] = 0;
    }

    v6 = 0;
    if (!key.empty()) {
        for (int i = 0; i < 256; i++) {
            if (v6 == key.size())
                v6 = 0;
            v5[i] = key[v6++];
        }
    }

    v6 = 0;
    for (int i = 0; i < 256; i++) {
        v6 = (v10[i] + v6 + v5[i]) % 256;
        v9 = v10[i];
        v10[i] = v10[v6];
        v10[v6] = v9;
    }

    v6 = 0;
    int i = 0;

    for (unsigned int j = 0; j < data.size(); j++) {
        i = (i + 1) % 256;
        v6 = (v6 + v10[i]) % 256;
        v9 = v10[i];
        v10[i] = v10[v6];
        v10[v6] = v9;
        unsigned int v11 = (v10[v6] + v10[i]) % 256u;
        data[j] ^= v10[v11];
    }
}

INI::INI(int x, int y, int type_id)
: FrameObject(x, y, type_id), overwrite(false), auto_save(false),
  use_compression(false), changed(false)
{
}

void INI::reset_global_data()
{
    global_data.clear();
}

#ifdef CHOWDREN_CACHE_INI
void INI::reset_cache()
{
    INICache::iterator it;
    for (it = ini_cache.begin(); it != ini_cache.end(); ++it) {
        it->second.clear();
    }
}
#endif

int INI::_parse_handler(void* user, const char* section, const char* name,
                        const char* value)
{
    INI * reader = (INI*)user;
    reader->parse_handler(section, name, value);
    return 1;
}

void INI::parse_handler(const std::string & section, const std::string & name,
                        const std::string & value)
{
    if (!overwrite && has_item(section, name))
        return;
#ifdef CHOWDREN_INI_FILTER_QUOTES
    if (value[0] == '"' && *value.rbegin() == '"') {
        (*data)[section][name] = value.substr(1, value.size() - 2);
        return;
    }
#endif
    (*data)[section][name] = value;
}

void INI::set_group(const std::string & name)
{
    set_group(name, true);
}

void INI::set_group(const std::string & name, bool new_group)
{
    current_group = name;
}

void INI::set_item(const std::string & name)
{
    current_item = name;
}

inline std::string trim_spaces(const std::string & value)
{
    int i;
    for (i = 0; i < int(value.size()); ++i) {
        if (value[i] != ' ')
            break;
    }
    return value.substr(i);
}

inline bool can_trim(const std::string & value)
{
    return !value.empty() && value[0] == ' ';
}

const std::string & INI::get_string_default(const std::string & group,
                                            const std::string & item,
                                            const std::string & def)
{
    if (can_trim(group) || can_trim(item))
        return get_string_default(trim_spaces(group), trim_spaces(item), def);
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return def;
    OptionMap::const_iterator new_it = (*it).second.find(item);
    if (new_it == (*it).second.end())
        return def;
    return (*new_it).second;
}

const std::string & INI::get_string_default(const std::string & item,
                                            const std::string & def)
{
    return get_string_default(current_group, item, def);
}

const std::string & INI::get_string(const std::string & item)
{
    return get_string_default(item, empty_string);
}

const std::string & INI::get_string(const std::string & group,
                                    const std::string & item)
{
    return get_string_default(group, item, empty_string);
}

const std::string & INI::get_string_index(const std::string & group,
                                          unsigned int index)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return empty_string;
    OptionMap::const_iterator new_it = (*it).second.begin();
    int current_index = 0;
    while (new_it != (*it).second.end()) {
        if (current_index == index)
            return (*new_it).second;
        ++new_it;
        current_index++;
    }
    return empty_string;
}

const std::string & INI::get_string_index(unsigned int index)
{
    return get_string_index(current_group, index);
}

const std::string & INI::get_item_name(const std::string & group,
                                       unsigned int index)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return empty_string;
    OptionMap::const_iterator new_it = (*it).second.begin();
    int current_index = 0;
    while (new_it != (*it).second.end()) {
        if (current_index == index)
            return (*new_it).first;
        ++new_it;
        current_index++;
    }
    return empty_string;
}

const std::string & INI::get_item_name(unsigned int index)
{
    return get_item_name(current_group, index);
}

const std::string & INI::get_group_name(unsigned int index)
{
    SectionMap::const_iterator it = data->begin();
    int current_index = 0;
    while (it != data->end()) {
        if (current_index == index)
            return (*it).first;
        ++it;
        current_index++;
    }
    return empty_string;
}

double INI::get_value(const std::string & group, const std::string & item,
                      double def)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return def;
    OptionMap::const_iterator new_it = (*it).second.find(item);
    if (new_it == (*it).second.end())
        return def;
    return string_to_double((*new_it).second);
}

double INI::get_value(const std::string & item, double def)
{
    return get_value(current_group, item, def);
}

int INI::get_value_int(const std::string & group, const std::string & item,
                       int def)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return def;
    OptionMap::const_iterator new_it = (*it).second.find(item);
    if (new_it == (*it).second.end())
        return def;
    return string_to_int((*new_it).second);
}

int INI::get_value_int(const std::string & item, int def)
{
    return get_value_int(current_group, item, def);
}

double INI::get_value_index(const std::string & group, unsigned int index)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return 0.0;
    OptionMap::const_iterator new_it = (*it).second.begin();
    int current_index = 0;
    while (new_it != (*it).second.end()) {
        if (current_index == index)
            return string_to_double((*new_it).second);
        ++new_it;
        current_index++;
    }
    return 0.0;
}

double INI::get_value_index(unsigned int index)
{
    return get_value_index(current_group, index);
}

void INI::set_value(const std::string & group, const std::string & item,
                    double value)
{
    set_string(group, item, number_to_string(value));
}

void INI::set_value(const std::string & item, double value)
{
    set_value(current_group, item, value);
}

void INI::set_value_int(const std::string & group, const std::string & item,
                        int value)
{
    set_string(group, item, number_to_string(value));
}

void INI::set_value_int(const std::string & item, int value)
{
    set_value_int(current_group, item, value);
}

void INI::set_string(const std::string & group, const std::string & item,
                     const std::string & value)
{
    (*data)[group][item] = value;
    save_auto();
}

void INI::set_string(const std::string & item, const std::string & value)
{
    set_string(current_group, item, value);
}

void INI::load_file(const std::string & fn, bool read_only, bool merge,
                    bool overwrite)
{
    std::string new_filename = convert_path(fn);
#ifdef CHOWDREN_CACHE_INI
    if (new_filename == filename)
        return;
#endif

#ifndef CHOWDREN_AUTOSAVE_ON_CHANGE
    if (auto_save && changed)
        save_file(false);
#endif

    this->read_only = read_only;
    filename = new_filename;

#ifdef CHOWDREN_USE_BLOWFISH_CACHE
    const std::string & cache = BlowfishObject::get_cache(filename);
    if (!cache.empty()) {
        std::cout << "Using Blowfish cache for " << filename << std::endl;
        load_string(cache, merge);
        return;
    }
#endif

#ifdef CHOWDREN_CACHE_INI
    std::string cache_key = filename;
    to_lower(cache_key);
    data = &ini_cache[cache_key];
    is_global = true;
    if (!data->empty())
        return;
#else
    if (!merge)
        reset(false);
#endif

    std::cout << "Loading " << filename << " (" << get_name() << ")"
        << std::endl;
    platform_create_directories(get_path_dirname(filename));

    std::string new_data;
    if (!encrypt_key.empty() || use_compression) {
        bool decompressed = false;

        if (use_compression) {
            if (decompress_huffman(filename.c_str(), new_data))
                decompressed = true;
        }

        if (!use_compression || !decompressed) {
            if (!read_file(filename.c_str(), new_data))
                return;
        }

        if (!encrypt_key.empty()) {
            encrypt_ini_data(new_data, encrypt_key);
        }
    } else {
        if (!read_file(filename.c_str(), new_data))
            return;
    }

    int e = ini_parse_string(new_data, _parse_handler, this);
    if (e != 0) {
        std::cout << "INI load failed (" << filename << ") with code " << e
            << std::endl;
    }
}

void INI::load_file(TempPath path)
{
    std::string data;
    path.read(data);
    load_string(data, false);
}

void INI::load_string(const std::string & data, bool merge)
{
#ifndef CHOWDREN_AUTOSAVE_ON_CHANGE
    if (auto_save && changed)
        save_file(false);
#endif
    if (!merge)
        reset(false);

    int e = ini_parse_string(data, _parse_handler, this);
    if (e != 0) {
        std::cout << "INI load failed with code " << e << std::endl;
    }
}

void INI::merge_file(const std::string & fn, bool overwrite)
{
    load_file(fn, false, true, overwrite);
}

void INI::get_data(std::stringstream & out)
{
    SectionMap::const_iterator it1;
    OptionMap::const_iterator it2;
    for (it1 = data->begin(); it1 != data->end(); ++it1) {
        out << "[" << (*it1).first << "]" << std::endl;
        for (it2 = (*it1).second.begin(); it2 != (*it1).second.end();
             ++it2) {
            out << (*it2).first << "=" << (*it2).second << std::endl;
        }
        out << std::endl;
    }
}

void INI::set_encryption_key(const std::string & key)
{
    encrypt_key = key;
}

void INI::set_compression(bool value)
{
    use_compression = value;
}

void INI::save_file(const std::string & fn, bool force)
{
    if (fn.empty() || (read_only && !force))
        return;
    changed = false;
    filename = convert_path(fn);
    std::cout << "Saving: " << filename << std::endl;
    platform_create_directories(get_path_dirname(filename));
    std::stringstream out;
    get_data(out);
    std::string outs = out.str();

    if (!encrypt_key.empty())
        encrypt_ini_data(outs, encrypt_key);

    if (use_compression) {
        compress_huffman(outs, filename.c_str());
        return;
    }

#ifdef CHOWDREN_USE_BLOWFISH_CACHE
    if (BlowfishObject::set_cache(filename, outs))
        return;
#endif

    FSFile fp(filename.c_str(), "w");
    if (!fp.is_open()) {
        std::cout << "Could not save INI file: " << filename << std::endl;
        return;
    }
	if (!outs.empty())
        fp.write(&outs[0], outs.size());
    fp.close();
}

std::string INI::as_string()
{
    std::stringstream out;
    get_data(out);
    return out.str();
}

void INI::save_file(bool force)
{
    save_file(filename, force);
}

void INI::save_auto()
{
#ifdef CHOWDREN_AUTOSAVE_ON_CHANGE
    if (!auto_save)
        return;
    save_file(false);
#else
    changed = true;
#endif
}

int INI::get_item_count(const std::string & section)
{
    return (*data)[section].size();
}

int INI::get_item_count()
{
    return get_item_count(current_group);
}

int INI::get_group_count()
{
    return data->size();
}

bool INI::has_group(const std::string & group)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return false;
    return true;
}

bool INI::has_item(const std::string & group, const std::string & option)
{
    SectionMap::const_iterator it = data->find(group);
    if (it == data->end())
        return false;
    OptionMap::const_iterator new_it = (*it).second.find(option);
    if (new_it == (*it).second.end())
        return false;
    return true;
}

bool INI::has_item(const std::string & option)
{
    return has_item(current_group, option);
}

void INI::search(const std::string & group, const std::string & item,
                 const std::string & value)
{
    search_results.clear();
    search_time = frame->loop_count;
    SectionMap::const_iterator it1;
    OptionMap::const_iterator it2;
    for (it1 = data->begin(); it1 != data->end(); ++it1) {
        if (!match_wildcard(group, (*it1).first))
            continue;
        for (it2 = (*it1).second.begin(); it2 != (*it1).second.end();
             ++it2) {
            if (!match_wildcard(item, (*it2).first))
                continue;
            if (!match_wildcard(value, (*it2).second))
                continue;
            search_results.push_back(
                std::pair<std::string, std::string>(
                    (*it1).first,
                    (*it2).first
                ));
        }
    }
}

void INI::delete_pattern(const std::string & group, const std::string & item,
                         const std::string & value)
{
    SectionMap::iterator it1;
    OptionMap::iterator it2;
    for (it1 = data->begin(); it1 != data->end(); ++it1) {
        if (!match_wildcard(group, (*it1).first))
            continue;
        OptionMap & option_map = (*it1).second;
        it2 = option_map.begin();
        while (it2 != option_map.end()) {
            if (!match_wildcard(item, (*it2).first) ||
                !match_wildcard(value, (*it2).second)) {
                ++it2;
                continue;
            }
            option_map.erase(it2++);
        }
    }
    save_auto();
}

void INI::sort_group_by_name(const std::string & group)
{
    std::cout << "Sort by name not implemented" << std::endl;
}

void INI::sort_group_by_value(const std::string & group)
{
    std::cout << "Sort by value not implemented" << std::endl;
}

void INI::close()
{
    data->clear();
    filename.clear();
}

void INI::reset(bool save)
{
    data->clear();
    if (save)
        save_auto();
}

void INI::delete_group(const std::string & group)
{
    data->erase(group);
    save_auto();
}

void INI::delete_group()
{
    delete_group(current_group);
}

void INI::delete_item(const std::string & group, const std::string & item)
{
    (*data)[group].erase(item);
    save_auto();
}

void INI::delete_item(const std::string & item)
{
    delete_item(current_group, item);
}

void INI::merge_object(INI * other, bool overwrite)
{
    merge_map(*other->data, overwrite);
}

void INI::merge_group(INI * other, const std::string & src_group,
                     const std::string & dst_group, bool overwrite)
{
    merge_map(*other->data, src_group, dst_group, overwrite);
}

void INI::merge_map(const SectionMap & data2, bool overwrite)
{
    SectionMap::const_iterator it1;
    OptionMap::const_iterator it2;
    for (it1 = data2.begin(); it1 != data2.end(); ++it1) {
        for (it2 = (*it1).second.begin(); it2 != (*it1).second.end();
             ++it2) {
            if (!overwrite && has_item((*it1).first, (*it2).first))
                continue;
            (*data)[(*it1).first][(*it2).first] = (*it2).second;
        }
    }
    save_auto();
}

void INI::merge_map(SectionMap & data2, const std::string & src_group,
                    const std::string & dst_group, bool overwrite)
{
    OptionMap & items = data2[src_group];
    OptionMap::const_iterator it;
    for (it = items.begin(); it != items.end(); ++it) {
        if (!overwrite && has_item(dst_group, (*it).first))
            continue;
        (*data)[dst_group][(*it).first] = (*it).second;
    }
    save_auto();
}

bool INI::has_search_results()
{
    if (search_results.empty())
        return false;
    return search_time == frame->loop_count;
}

size_t INI::get_search_count()
{
    return search_results.size();
}

const std::string & INI::get_search_result_group(int index)
{
    return search_results[index].first;
}

const std::string & INI::get_search_result_item(int index)
{
    return search_results[index].second;
}

std::string INI::get_item_part(const std::string & group,
                               const std::string & item, int index,
                               const std::string & def)
{
    if (index < 0)
        return def;
    const std::string & value = get_string_default(group, item, empty_string);
    vector<std::string> elem;
    split_string(value, ',', elem);
    if (index >= (int)elem.size())
        return def;
    return elem[index];
}

void INI::set_auto(bool save, bool load)
{
    if (load) {
        std::cout << "Autoload not supported" << std::endl;
    }

    auto_save = save;
}

INI::~INI()
{
#ifndef CHOWDREN_AUTOSAVE_ON_CHANGE
    if (auto_save && changed)
        save_file(false);
#endif
    if (!is_global)
        delete data;
}

hash_map<std::string, SectionMap> INI::global_data;
