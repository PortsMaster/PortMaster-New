#include "zopfli/zopfli.h"

static ZopfliOptions options;

void init_zopfli()
{
    ZopfliInitOptions(&options);
}

PyObject * compress_zopfli(char * data, size_t size)
{
    unsigned char* out = 0;
    size_t outsize = 0;
    ZopfliCompress(&options, ZOPFLI_FORMAT_ZLIB,
                   (const unsigned char*)data, size, &out, &outsize);
    PyObject * ret = PyString_FromStringAndSize((const char*)out, outsize);
    free(out);
    return ret;
}
