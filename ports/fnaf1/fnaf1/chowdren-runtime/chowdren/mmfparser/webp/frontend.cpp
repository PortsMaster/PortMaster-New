#include "webp/encode.h"

static size_t encode(const uint8_t* rgba, int width, int height,
                     uint8_t** output)
{
    WebPPicture pic;
    WebPConfig config;
    WebPMemoryWriter wrt;
    int ok;

    if (!WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, 100) ||
        !WebPPictureInit(&pic))
    {
        return 0;
    }

    config.lossless = true;
    config.method = 6;
    pic.use_argb = true;
    pic.width = width;
    pic.height = height;
    pic.writer = WebPMemoryWrite;
    pic.custom_ptr = &wrt;
    WebPMemoryWriterInit(&wrt);

    ok = WebPPictureImportRGBA(&pic, rgba, width * 4) &&
         WebPEncode(&config, &pic);
    WebPPictureFree(&pic);
    if (!ok)
        return 0;
    *output = wrt.mem;
    return wrt.size;
}

PyObject * encode_webp(char * rgba, int width, int height)
{
    uint8_t * output;
    size_t size = encode((const uint8_t*)rgba, width, height, &output);
    PyObject * ret = PyString_FromStringAndSize((const char*)output, size);
    free(output);
    return ret;
}