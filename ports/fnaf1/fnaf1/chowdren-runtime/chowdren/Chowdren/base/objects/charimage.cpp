#include "objects/charimage.h"
#include "include_gl.h"
#include "collision.h"
#include <ctype.h>
#include <string.h>
#include "font.h"
#include <algorithm>
#include <stddef.h>

enum Attributes
{
    ALIAS_ATTRIB = 0,
    TRACKING_ATTRIB = 1,
    TRANSPARENT_ATTRIB = 2
};

CharacterImageObject::CharacterImageObject(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
    collision = new InstanceBox(this);
}

CharacterImageObject::~CharacterImageObject()
{
    delete collision;
}

inline int get_vertical_index(const CharacterImageLine & l)
{
    if (l.y_align & ALIGN_TOP)
        return 0;
    if (l.y_align & ALIGN_VCENTER)
        return 1;
    if (l.y_align & ALIGN_BOTTOM)
        return 2;
    return 0;
}

void CharacterImageObject::draw()
{
    int xx, yy;

    int y_offsets[3] = {
        y,
        y + total_height[0] + (height - total_height[0] - total_height[1]) / 2,
        y
    };

    vector<CharacterImageBlock>::const_iterator it;
    int line = -1;
    for (it = blocks.begin(); it != blocks.end(); it++) {
        const CharacterImageBlock & block = *it;

        if (block.line != line) {
            if (line != -1) {
                CharacterImageLine & l = lines[line];
                yy += l.height;
                y_offsets[get_vertical_index(l)] = yy;
            }
            line = block.line;

            CharacterImageLine & ll = lines[line];

            // update x
            xx = x;
            if (ll.x_align & ALIGN_HCENTER)
                xx += (width - ll.width) / 2;
            else if (ll.x_align & ALIGN_RIGHT)
                xx += width - ll.width;

            yy = y_offsets[get_vertical_index(ll)];
        }

        int transparency = block.attribs.values[TRANSPARENT_ATTRIB];
        transparency = ((128 - transparency) * 255) / 128;
        Color color(255, 255, 255, transparency);

        int alias_index = block.attribs.values[ALIAS_ATTRIB];
        CharacterImageAlias & alias = aliases[alias_index];

        for (int i = 0; i < int(block.text.size()); i++) {
            unsigned char c = (unsigned char)block.text[i];
            CharacterImage & img = alias.charmap[c];
            if (img.image != NULL) {
                img.image->draw(xx, yy, color);
            }
            xx += img.width + block.attribs.values[TRACKING_ATTRIB];
        }
    }
}

void CharacterImageObject::set_text(const std::string & text)
{
    this->text = text;
    update_text();
}

static int is_space(unsigned char c)
{
    return isspace(c);
}

static char* lskip(const char* s, const char * end)
{
    while (s < end && is_space(*s))
        s++;
    return (char*)s;
}

static char* find_char_or_newline(const char * s, const char * end, char c)
{
    while (s < end && *s != c && *s != '\n' && *s != '\r')
        s++;
    return (char*)s;
}

static char* find_char(const char * s, const char * end, char c)
{
    while (s < end && *s != c)
        s++;
    return (char*)s;
}

static char* find_tag_end(const char * s, const char * end)
{
    while (s < end && *s != ' ' && *s != ']' && *s != '=')
        s++;
    return (char*)s;
}

template <std::size_t N>
inline bool test_str(const char * start, const char * end,
                     const char (&other)[N])
{
    int size = N - 1;
    if (end - start != size)
        return false;
    return strncmp(start, other, size) == 0;
}

#define ATTRIBUTE_STACK_SIZE 10

struct AttributeStack
{
    int offset;
    int pos;
    int stack[ATTRIBUTE_STACK_SIZE];

    AttributeStack(int offset)
    : offset(offset), pos(0)
    {
    }

    void push(int value, CharacterImageAttributes & attribs)
    {
        stack[pos] = attribs.values[offset];
        // better than crashing
        pos = std::min(pos+1, ATTRIBUTE_STACK_SIZE-1);
        attribs.values[offset] = value;
    }

    void pop(CharacterImageAttributes & attribs)
    {
        attribs.values[offset] = stack[--pos];
    }
};

void CharacterImageObject::update_text()
{
    lines.clear();
    blocks.clear();
    total_height[0] = total_height[1] = total_height[2] = 0;

    if (text.empty())
        return;

    char * data = &text[0];
    char * end = data + text.size();

    char * start_text = NULL;
    char * tag_start = NULL;

    AttributeStack alias_stack(ALIAS_ATTRIB);
    AttributeStack tracking_stack(TRACKING_ATTRIB);
    AttributeStack transparent_stack(TRANSPARENT_ATTRIB);

    lines.resize(1);

    CharacterImageAttributes attribs;

    int line = 0;
    int line_height = 0;
    int line_width = 0;
    int leading = 0;

    while (true) {
        // read text
        char * text_start = data;
        char * wrap_point = data;
        int test_width = line_width;
        bool wrap_newline = false;
        bool has_newline = false;

        // scan for newline, tag start or wrap point
        while (true) {
            if (data >= end)
                break;
            unsigned char c = (unsigned char)*data;
            if (c == '\n') {
                data++;
                has_newline = true;
                break;
            } else if (c == '\r') {
                data++;
                continue;
            } else if (c == '[')
                break;
            if (c == ' ')
                wrap_point = data+1;

            int alias_index = attribs.values[ALIAS_ATTRIB];
            CharacterImageAlias & alias = aliases[alias_index];
            CharacterImage & img = alias.charmap[c];
            test_width += img.width + attribs.values[TRACKING_ATTRIB];
            if (c != ' ' && (test_width+1) >= width) {
                data = wrap_point;
                has_newline = true;
                wrap_newline = true;
                break;
            }
            data++;
        }

        char * text_end = data;

        bool at_end = data >= end;

        if (text_start != text_end) {
            int alias_index = attribs.values[ALIAS_ATTRIB];
            CharacterImageAlias & alias = aliases[alias_index];
            std::string new_text(text_start, text_end - text_start);

            for (int i = 0; i < int(new_text.size()); i++) {
                unsigned char c = (unsigned char)new_text[i];
                CharacterImage & img = alias.charmap[c];
                line_height = std::max(img.height, line_height);
                if (c == '\n' || c == '\r')
                    continue;
                line_width += img.width + attribs.values[TRACKING_ATTRIB];
            }

            if (line_height == 0)
                line_height = alias.charmap[' '].height;

            unformatted += new_text;
            blocks.push_back(CharacterImageBlock(line, attribs, new_text));
        }

        if (has_newline || at_end) {
            CharacterImageLine & l = lines[line];
            l.width = line_width;
            line_height += (line_height * leading) / 100;
            total_height[get_vertical_index(l)] += line_height;
            l.height = line_height;
            line_width = line_height = 0;
            if (!wrap_newline)
                leading = 0;
            line++;
        }

        if (at_end)
            return;

        if (has_newline) {
            lines.resize(line+1);
            if (wrap_newline) {
                // inherit line config
                lines[line].x_align = lines[line-1].x_align;
                lines[line].y_align = lines[line-1].y_align;
            }
        }

        if (has_newline)
            continue;

        // read tag
        data++; // skip '[''
        data = lskip(data, end);
        bool is_end_tag = *data == '/';
        if (is_end_tag) {
            data++;
            data = lskip(data, end);
        }
        char * tag_start = data;
        data = find_tag_end(data, end);
        char * tag_end = data;

        // read tag value
        data = lskip(data, end);
        bool has_value = *data == '=';
        char * value_start;
        char * value_end;

        if (*data == '=') {
            data++;
            data = lskip(data, end);
            value_start = data;
            data = find_tag_end(data, end);
            value_end = data;
        }
        data = find_char(data, end, ']');
        data++;

        // convert value to integer
        int value;
        if (has_value) {
            bool is_alignment = true;
            switch (value_start[0]) {
                case 'l': // left
                    value = ALIGN_LEFT;
                    break;
                case 'r': // right
                    value = ALIGN_RIGHT;
                    break;
                case 'c': // centre
                    value = ALIGN_HCENTER | ALIGN_VCENTER;
                    break;
                case 'j': // justify
                    value = ALIGN_JUSTIFY;
                    break;
                case 't': // top
                    value = ALIGN_TOP;
                    break;
                case 'b': // bottom
                    value = ALIGN_BOTTOM;
                    break;
                default:
                    is_alignment = false;
                    break;
            }

            if (!is_alignment) {
                std::string value_str(value_start, value_end-value_start);
                value = string_to_int(value_str);
            }
        }

        // test attributes
        AttributeStack * stack_ref;

        if (test_str(tag_start, tag_end, "alias")) {
            stack_ref = &alias_stack;
        } else if (test_str(tag_start, tag_end, "tracking")) {
            stack_ref = &tracking_stack;
        } else if (test_str(tag_start, tag_end, "transparent")) {
            stack_ref = &transparent_stack;
        } else if (test_str(tag_start, tag_end, "veralign")) {
            lines[line].y_align = value;
            continue;
        } else if (test_str(tag_start, tag_end, "horalign")) {
            lines[line].x_align = value;
            continue;
        } else if (test_str(tag_start, tag_end, "leading")) {
            leading = value;
            continue;
        } else {
            std::string tag(tag_start, tag_end - tag_start);
            std::cout << "Unknown tag: " << tag << std::endl;
            continue;
        }

        if (is_end_tag) {
            stack_ref->pop(attribs);
            continue;
        }

        stack_ref->push(value, attribs);
    }
}

std::string CharacterImageObject::get_char(int index)
{
    if (index < 0 || index >= int(unformatted.size()))
        return empty_string;
    return std::string(&unformatted[index], 1);
}

int CharacterImageObject::get_char_width(int alias, const std::string & c)
{
    CharacterImageAlias & a = aliases[alias];
    unsigned char cc = (unsigned char)c[0];
    return a.charmap[cc].width;
}

void CharacterImageObject::set_char_width(int alias, const std::string & c,
                                          int width)
{
    CharacterImageAlias & a = aliases[alias];
    unsigned char cc = (unsigned char)c[0];
    a.charmap[cc].width = width;
}

void CharacterImageObject::set_clipping_width(int alias, const std::string & c,
                                              int width)
{
    std::cout << "Set clip width: " << alias << " " << c << " " << width
        << std::endl;
}

inline int get_load_point(int value, int max)
{
    if (value == 100000) {
        return max / 2;
    } else if (value == 110000) {
        return max;
    }
    return value;
}

void CharacterImageObject::load(int alias, const std::string & c,
                                const std::string & path,
                                int x_hotspot, int y_hotspot)
{
    Image * new_image = get_image_cache(convert_path(path), 0, 0, 0, 0,
                                        TransparentColor());

    if (new_image == NULL) {
        std::cout << "Could not load image " << path << std::endl;
        return;
    }

    new_image->hotspot_x = get_load_point(x_hotspot, new_image->width);
    new_image->hotspot_y = get_load_point(y_hotspot, new_image->height);

    CharacterImageAlias & a = aliases[alias];
    unsigned char cc = (unsigned char)c[0];
    a.charmap[cc].image = new_image;
}