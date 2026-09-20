#ifndef CHOWDREN_DATASTREAM_H
#define CHOWDREN_DATASTREAM_H

#include <sstream>
#include "platform.h"
#include <string.h>
#include <algorithm>

class BaseStream
{
public:
    BaseStream()
    {
    }

    // read

    void read_string(std::string & str, size_t len)
    {
        str.resize(len, 0);
        read(&str[0], len);
    }

    void read(std::stringstream & out, size_t len)
    {
        std::string data;
        read_string(data, len);
        out << data;
    }

    char read_int8()
    {
        char v;
        if (!read(&v, 1))
            return 0;
        return v;
    }

    unsigned char read_uint8()
    {
        return (unsigned char)read_int8();
    }

    short read_int16()
    {
        unsigned char data[2];
        if (!read((char*)data, 2))
            return 0;
        return data[0] | (data[1] << 8);
    }

    unsigned short read_uint16()
    {
        return (unsigned short)read_int16();
    }

    int read_int32()
    {
        unsigned char data[4];
        if (!read((char*)data, 4))
            return 0;
        return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
    }

    unsigned int read_uint32()
    {
        return (unsigned int)read_int32();
    }

    float read_float()
    {
        float f;
        int i = read_int32();
        memcpy(&f, &i, sizeof(float));
        return f;
    }

    void read_c_string(std::string & str)
    {
        read_delim(str, '\0');
    }

    // write

    void write_int8(char v)
    {
        write(&v, 1);
    }

    void write_uint8(unsigned char v)
    {
        write_int8(char(v));
    }

    void write_int16(short v)
    {
        unsigned char data[2];
        data[0] = v & 0xFF;
        data[1] = (v >> 8) & 0xFF;
        write((char*)&data[0], 2);
    }

    void write_uint16(unsigned short v)
    {
        write_int16(short(v));
    }

    void write_int32(int v)
    {
        unsigned char data[4];
        data[0] = v & 0xFF;
        data[1] = (v >> 8) & 0xFF;
        data[2] = (v >> 16) & 0xFF;
        data[3] = (v >> 24) & 0xFF;
        write((char*)&data[0], 4);
    }

    void write_uint32(unsigned int v)
    {
        write_int32(int(v));
    }


    void write_string(const std::string & str)
    {
        write(&str[0], str.size());
    }

    void read_delim(std::string & line, char delim)
    {
        while (true) {
            char c;
            if (!read(&c, 1))
                break;
            if (c == delim)
                break;
            line += c;
        }
    }

    void read_line(std::string & str)
    {
        read_delim(str, '\n');
    }

    // subclasses implements this

    virtual void write(const char * data, size_t len) = 0;
    virtual bool read(char * data, size_t len) = 0;
    virtual void seek(size_t pos) = 0;
    virtual bool at_end() = 0;
};

class FileStream : public BaseStream
{
public:
    FSFile & fp;

    FileStream(FSFile & fp)
    : BaseStream(), fp(fp)
    {
    }

    bool read(char * data, size_t len)
    {
        return fp.read(data, len) == len;
    }

    void seek(size_t pos)
    {
        fp.seek(pos);
    }

    bool at_end()
    {
        return fp.at_end();
    }

    void write(const char * data, size_t len)
    {
        fp.write(data, len);
    }
};

class DataStream : public BaseStream
{
public:
    std::stringstream & stream;

    DataStream(std::stringstream & stream)
    : stream(stream)
    {
    }

    bool read(char * data, size_t len)
    {
        return !stream.read(data, len).eof();
    }

    void seek(size_t pos)
    {
        stream.seekg(pos);
    }

    bool at_end()
    {
        return stream.peek() == EOF;
    }

    void write(const char * data, size_t len)
    {
        stream.write(data, len);
    }
};

class WriteStream : public DataStream
{
public:
    std::stringstream stream;

    WriteStream()
    : DataStream(stream)
    {
    }

    ~WriteStream()
    {
    }

    std::string get_string()
    {
        return stream.str();
    }

    void save(FSFile & fp)
    {
        std::string data = stream.str();
        if (data.empty())
            return;
        fp.write(&data[0], data.size());
    }
};

class StringStream : public BaseStream
{
public:
    const std::string & str;
    size_t pos;

    StringStream(const std::string & str)
    : str(str), pos(0)
    {
    }

    bool read(char * data, size_t len)
    {
        if (str.size() - pos < len)
            return false;
        memcpy(data, &str[pos], len);
        pos += len;
        return true;
    }

    void seek(size_t p)
    {
        pos = std::max(size_t(0), std::min(p, str.size()));
    }

    bool at_end()
    {
        return pos == str.size();
    }

    void write(const char * data, size_t len)
    {
    }
};

class ArrayStream : public BaseStream
{
public:
    char * array;
    size_t size;
    size_t pos;

    ArrayStream(char * array, size_t size)
    : array(array), size(size), pos(0)
    {
    }

    bool read(char * data, size_t len)
    {
        if (size - pos < len)
            return false;
        memcpy(data, &array[pos], len);
        pos += len;
        return true;
    }

    void seek(size_t p)
    {
        pos = std::max(size_t(0), std::min(p, size));
    }

    bool at_end()
    {
        return pos == size;
    }

    void write(const char * data, size_t len)
    {
    }
};

#endif // CHOWDREN_DATASTREAM_H
