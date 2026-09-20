/* inih -- simple .INI file parser

inih is released under the New BSD license (see LICENSE.txt). Go to the project
home page for more info:

http://code.google.com/p/inih/

*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <string>
#include <sstream>
#include <istream>
#include "platform.h"
#include "utf16to8.h"

inline int is_space(unsigned char c)
{
    return isspace(c);
}

/* Strip whitespace chars off end of given string, in place. Return s. */
static char* rstrip(char* s)
{
    char* p = s + strlen(s);
    while (p > s && is_space(*--p))
        *p = '\0';
    return s;
}

/* Return pointer to first non-whitespace char in given string. */
static char* lskip(const char* s)
{
    while (*s && is_space(*s))
        s++;
    return (char*)s;
}

/* Return pointer to first char c or ';' comment in given string, or pointer to
   null at end of string if neither found. ';' must be prefixed by a whitespace
   character to register as a comment. */
static char* find_char_or_comment(const char* s, char c)
{
    int was_whitespace = 0;
    while (*s && *s != c && !(was_whitespace && *s == ';')) {
        was_whitespace = is_space(*s);
        s++;
    }
    return (char*)s;
}

/* Version of strncpy that ensures dest (size bytes) is null-terminated. */
static char* strncpy0(char* dest, const char* src, size_t size)
{
    strncpy(dest, src, size);
    dest[size - 1] = '\0';
    return dest;
}

static void get_line(std::istream & input, std::string & line)
{
    std::getline(input, line);
}

static bool at_end(std::istream & input)
{
    return !input;
}

#define MAX_INI_STRING 50

int ini_parse_string(const std::string & s,
                     int (*handler)(void*, const char*, const char*,
                                    const char*),
                     void* user)
{
    if (s.size() >= 2 && (unsigned char)s[0] == 0xFF
        && (unsigned char)s[1] == 0xFE)
    {
        std::string out;
        convert_utf16_to_utf8(s, out);
        return ini_parse_string(out, handler, user);
    }
    std::istringstream input(s);

    /* Uses a fair bit of stack (use heap instead if you need to) */
    char section[MAX_INI_STRING] = "";

    bool has_group = false;
    int lineno = 0;
    int error = 0;

    /* Scan through file line by line */
    while (!at_end(input)) {
        std::string newline;
        get_line(input, newline);
        char * line = (char*)newline.c_str();
        lineno++;

        char * start = line;
        char * end;

        // UTF-8 BOM
        if (lineno == 1 && (unsigned char)start[0] == 0xEF &&
                           (unsigned char)start[1] == 0xBB &&
                           (unsigned char)start[2] == 0xBF) {
            start += 3;
        }

        start = lskip(rstrip(start));

        char c = *start;

        if (c == ';' || c == '#' || (c == '/' && start[1] == '/')) {
            /* Per Python ConfigParser, allow '#' comments at start of line */
        } else if (c == '[') {
            /* A "[section]" line */
            end = find_char_or_comment(start + 1, ']');
            if (*end == ']') {
                *end = '\0';
                strncpy0(section, start + 1, sizeof(section));
                has_group = true;
            } else if (!error) {
                /* No ']' found on section line */
                error = lineno;
            }
        } else if (c && c != ';' && has_group) {
            /* Not a comment, must be a name[=:]value pair */
            end = find_char_or_comment(start, '=');
            if (*end != '=') {
                end = find_char_or_comment(start, ':');
            }
            if (*end == '=' || *end == ':') {
                *end = '\0';
                char * name = rstrip(start);
                char * value = lskip(end + 1);
                end = find_char_or_comment(value, '\0');
                if (*end == ';')
                    *end = '\0';
                rstrip(value);

                /* Valid name[=:]value pair found, call handler */
                if (!handler(user, section, name, value) && !error)
                    error = lineno;
            } else if (!error) {
                /* No '=' or ':' found on name[=:]value line */
                error = lineno;
            }
        }
    }

    return error;
}
