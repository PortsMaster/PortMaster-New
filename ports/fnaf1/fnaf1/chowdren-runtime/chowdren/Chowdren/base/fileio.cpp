#include "fileio.h"

// BaseFile

BaseFile::BaseFile()
: handle(NULL), flags(CLOSED)
{
}

BaseFile::BaseFile(const char * filename, const char * mode)
: handle(NULL), flags(CLOSED)
{
    open(filename, mode);
}

BaseFile::~BaseFile()
{
    close();
}

size_t BaseFile::get_size()
{
    // XXX maybe make this platform-specific
    size_t pos = tell();
    seek(0, SEEK_END);
    size_t size = tell();
    seek(pos);
    return size;
}

// BufferedFile

#define READ_BUFFER_SIZE size_t(1024 * 4)

BufferedFile::BufferedFile()
: buffer(NULL)
{
}

BufferedFile::BufferedFile(const char * filename, const char * mode)
: buffer(NULL)
{
    open(filename, mode);
}

void BufferedFile::open(const char * filename, const char * mode)
{
    pos = buf_pos = buf_size = 0;
    fp.open(filename, mode);

    if (!fp.is_open() || *mode != 'r')
        return;

    buffer = malloc(READ_BUFFER_SIZE);

    fp.seek(0, SEEK_END);
    size = fp.tell();
    fp.seek(0);
}

bool BufferedFile::seek(size_t new_pos, int origin)
{
    if (origin == SEEK_CUR)
        pos += new_pos;
    else if (origin == SEEK_END)
        pos = size - new_pos;
    else
        pos = new_pos;

    if (pos > size) {
        pos = size;
        return false;
    }
    return true;
}

size_t BufferedFile::tell()
{
    return pos;
}

bool BufferedFile::is_open()
{
    return fp.is_open();
}

size_t BufferedFile::read(void * data, size_t need)
{
    size_t total_read = 0;

    if (pos >= buf_pos && pos < buf_pos + buf_size) {
        size_t buf_off = pos - buf_pos;
        total_read += std::min(need, buf_size - buf_off);
        pos += total_read;
        need -= total_read;
        // std::cout << "memcpy 1: " << buf_off << " " << total_read << std::endl;
        memcpy(data, (char*)buffer + buf_off, total_read);
        data = (char*)data + total_read;
    }
    if (need == 0)
        return total_read;
    if (buf_pos + buf_size != pos) {
        fp.seek(pos);
    }
    if (need < READ_BUFFER_SIZE) {
        buf_pos = pos;
        buf_size = fp.read(buffer, READ_BUFFER_SIZE);
        size_t read_size = std::min(buf_size, need);
        memcpy(data, buffer, read_size);
        // std::cout << "memcpy 2: " << read_size << std::endl;
        total_read += read_size;
        pos += read_size;
    } else {
        size_t read_size = fp.read(data, need);
        pos += read_size;
        buf_pos = pos;
        buf_size = 0;
        total_read += read_size;
    }
    return total_read;
}

size_t BufferedFile::write(const void * data, size_t size)
{
    return fp.write(data, size);
}

void BufferedFile::close()
{
    if (!fp.is_open())
        return;
    fp.close();
    free(buffer);
    buffer = NULL;
}

bool BufferedFile::at_end()
{
    return pos >= size;
}

BufferedFile::~BufferedFile()
{
    close();
}

size_t BufferedFile::get_size()
{
    return size;
}

// convenience functions

bool read_file(const char * filename, char ** data, size_t * ret_size,
               bool binary)
{
    BaseFile fp(filename, "r");
    if (!fp.is_open()) {
        std::cout << "Could not load file " << filename << std::endl;
        return false;
    }
    fp.seek(0, SEEK_END);
    size_t size = fp.tell();
    fp.seek(0, SEEK_SET);
    if (binary)
        *data = new char[size];
    else
        *data = new char[size + 1];
    fp.read(*data, size);
    fp.close();
    if (!binary)
        (*data)[size] = 0;
    *ret_size = size;
    return true;
}

bool read_file(const char * filename, std::string & dst, bool binary)
{
    BaseFile fp(filename, "r");
    if (!fp.is_open()) {
        std::cout << "Could not load file " << filename << std::endl;
        return false;
    }
    fp.seek(0, SEEK_END);
    size_t size = fp.tell();
    fp.seek(0, SEEK_SET);
    if (binary)
        dst.resize(size);
    else
        dst.resize(size + 1);
    if (size > 0)
        fp.read(&dst[0], size);
    fp.close();
    if (!binary)
        dst[size] = 0;
    return true;
}

bool read_file_c(const char * filename, char ** data, size_t * ret_size,
                 bool binary)
{
    BaseFile fp(filename, "r");
    if (!fp.is_open()) {
        std::cout << "Could not load file " << filename << std::endl;
        return false;
    }
    fp.seek(0, SEEK_END);
    size_t size = fp.tell();
    fp.seek(0, SEEK_SET);
    if (binary)
        *data = (char*)malloc(size);
    else
        *data = (char*)malloc(size+1);
    fp.read(*data, size);
    fp.close();
    if (!binary)
        (*data)[size] = 0;
    *ret_size = size;
    return true;
}
