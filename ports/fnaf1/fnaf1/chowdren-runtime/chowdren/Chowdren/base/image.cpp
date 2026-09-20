#include <string>
#include "image.h"
#include "string.h"
#include "color.h"
#include <iostream>
#include <stdio.h>
#include "datastream.h"
#include "chowconfig.h"
#include "types.h"
#include "mathcommon.h"
#include "assetfile.h"
#include "render.h"

#define STBI_NO_STDIO
#define STBI_NO_HDR
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
#define STBI_ONLY_BMP
#define STBI_ONLY_GIF
#include "stb_image.h"

inline unsigned char * load_image(unsigned char * data, int size,
                                  int * w, int * h, int * channels)
{

    return stbi_load_from_memory(data, size, w, h, channels, 4);
}

inline unsigned char * load_image(FSFile & image_file, int size,
                                  int * w, int * h, int * channels)
{
    unsigned char * buf = new unsigned char[size];
    image_file.read(buf, size);
    unsigned char * out = load_image(buf, size, w, h, channels);
    delete[] buf;
    return out;
}

typedef vector<Image*> ImageList;

static AssetFile image_file;

void open_image_file()
{
    if (image_file.is_open())
        return;
    image_file.open();
}

// dummy constructor
Image::Image()
: handle(0), flags(DEFAULT_FLAGS), tex(0), image(NULL), width(0), height(0),
  hotspot_x(0), hotspot_y(0), action_x(0), action_y(0)
{
}

Image::Image(int hot_x, int hot_y, int act_x, int act_y)
: handle(0), flags(DEFAULT_FLAGS), tex(0), image(NULL), width(0), height(0),
  hotspot_x(hot_x), hotspot_y(hot_y), action_x(act_x), action_y(act_y)
{
}

Image::Image(int handle)
: handle(handle), tex(0), image(NULL), flags(DEFAULT_FLAGS)
{
}

Image::~Image()
{
    unload();
}

void Image::destroy()
{
    if (flags & CACHED)
        return;
    delete this;
}

Image * Image::copy()
{
    Image * new_image;
    if (image == NULL) {
        if (flags & FILE) {
            FileImage * image = (FileImage*)this;
            new_image = new FileImage(image->filename,
                                      image->hotspot_x, image->hotspot_y,
                                      image->action_x, image->action_y,
                                      image->transparent);
        } else {
            new_image = new Image(handle);
        }
        new_image->load();
        return new_image;
    }
    new_image = new Image();
    new_image->width = width;
    new_image->height = height;
    new_image->handle = handle;
    int size = width*height*4;
    new_image->image = (unsigned char*)malloc(size);
    memcpy(new_image->image, image, size);
    return new_image;
}

void Image::set_static()
{
    flags |= STATIC;
}

void Image::load()
{
    flags |= USED;

    if (tex != 0 || image != NULL)
        return;

    if (flags & FILE) {
        ((FileImage*)this)->load_file();
        return;
    }

    open_image_file();
    image_file.set_item(handle, AssetFile::IMAGE_DATA);
    FileStream stream(image_file);

    width = stream.read_uint16();
    height = stream.read_uint16();
    hotspot_x = stream.read_int16();
    hotspot_y = stream.read_int16();
    action_x = stream.read_int16();
    action_y = stream.read_int16();

    int size = stream.read_uint32();
    unsigned char * buf = new unsigned char[size];
    image_file.read(buf, size);
    if (size > 0 && buf[0] == 0x01) {
        // ASTC compressed data (GL_KHR_texture_compression_astc_ldr,
        // written against GLES 3.0).
        //
        // CHOWDREN_USE_GL alone is not a reliable gate here: on desktop
        // Mesa/Intel, glCompressedTexImage2D for this format has been
        // confirmed to return no GL error at all while still producing a
        // texture that samples as solid black - i.e. Mesa can silently
        // accept a call it doesn't actually support correctly.
        //
        // We therefore always query GL_EXTENSIONS at runtime and only take
        // the ASTC path if the extension string is genuinely present.
        // On Mesa/Intel desktop GPU the extension may be advertised yet
        // the texture still samples as black; that is a known limitation
        // of those specific drivers, not of this code path.
        // On ARM/gl4es the extension is properly supported when present.
        static int astc_supported = -1;
        if (astc_supported == -1) {
            const char * ext = (const char*)glGetString(GL_EXTENSIONS);
            astc_supported = (ext != NULL &&
                strstr(ext, "GL_KHR_texture_compression_astc_ldr") != NULL)
                ? 1 : 0;
            if (!astc_supported) {
                std::cout << "ASTC extension GL_KHR_texture_compression_"
                    << "astc_ldr not present on this driver; ASTC images "
                    << "will be reported as errors instead of uploaded."
                    << std::endl;
            }
        }
        if (astc_supported) {
            std::cout << "Loading ASTC image " << handle << std::endl;
            GLuint astc_tex;
            glGenTextures(1, &astc_tex);
            glBindTexture(GL_TEXTURE_2D, astc_tex);
            glCompressedTexImage2D(GL_TEXTURE_2D, 0, 0x93B7,
                                   width, height, 0, size - 17, buf + 17);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            // Only level 0 is uploaded (no mipmap chain generated), so the
            // min filter must not require mipmaps - the GL default,
            // GL_NEAREST_MIPMAP_LINEAR, needs a complete mipmap chain and
            // an incomplete texture samples as solid black. GL_LINEAR only
            // needs level 0.
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            tex = astc_tex;
            delete[] buf;
            return;
        }
#ifdef CHOWDREN_USE_GL
        std::cout << "ERROR: image " << handle << " is ASTC-compressed but "
            << "this is a desktop GL build (ASTC is not reliably supported "
            << "on desktop OpenGL). Re-run the .exe -> C++ conversion step "
            << "with the astcenc-native tool removed/renamed so "
            << "imageworker.py's USE_ASTC check is False, producing a "
            << "zlib-compressed Assets.dat instead." << std::endl;
#else
        std::cout << "ERROR: image " << handle << " is ASTC-compressed but "
            << "this driver does not advertise "
            << "GL_KHR_texture_compression_astc_ldr. Re-run the .exe -> "
            << "C++ conversion step with the astcenc-native tool "
            << "removed/renamed so imageworker.py's USE_ASTC check is "
            << "False, producing a zlib-compressed Assets.dat instead."
            << std::endl;
#endif
        delete[] buf;
        return;
    }
    int out_size = width*height*4;
    image = (unsigned char*)STBI_MALLOC(out_size);
    if (stbi_zlib_decode_buffer((char*)image, out_size, (const char*)buf + 1,
                                 size - 1) < 0)
    {
        std::cout << "Could not load image " << handle << std::endl;
        std::cout << stbi_failure_reason() << std::endl;
        stbi_image_free(image);
        image = NULL;
    }
    delete[] buf;
}

void Image::unload()
{
    if (image != NULL)
        stbi_image_free(image);
    if (tex != 0)
        Render::delete_tex(tex);
    image = NULL;
    tex = 0;

#ifndef CHOWDREN_IS_WIIU
    free(alpha.data);
    alpha.data = NULL;
#endif
}

void Image::replace(const Color & from, const Color & to)
{
    if (image == NULL) {
        std::cout << "Could not replace color in unloaded image" << std::endl;
        return;
    }
    for (int i = 0; i < width * height; i++) {
        unsigned char * c = &image[i*4];
        if (c[0] != from.r || c[1] != from.g || c[2] != from.b)
            continue;
        c[0] = to.r;
        c[1] = to.g;
        c[2] = to.b;
    }
}

void Image::upload_texture()
{
    if (tex != 0 || image == NULL)
        return;

#ifndef CHOWDREN_IS_WIIU
    // create alpha mask
    int size = width * height;
    BaseBitArray::word_t * data;
    data = (BaseBitArray::word_t*)malloc(GET_BITARRAY_SIZE(size));
    int i = 0;
    int ii = 0;
    unsigned char c;

    while (i < size) {
        BaseBitArray::word_t word = 0;
        for (BaseBitArray::word_t m = 1UL; m != 0UL; m <<= 1UL) {
            c = ((unsigned char*)(((unsigned int*)image) + i))[3];
            if (c != 0)
                word |= m;
            ++i;
            if (i >= size)
                break;
        }
        data[ii++] = word;
    }

    alpha.data = data;
#endif
    int gl_width, gl_height;

    gl_width = width;
    gl_height = height;

    tex = Render::create_tex(image, Render::RGBA, gl_width, gl_height);
    Render::set_filter(tex, (flags & LINEAR_FILTER) != 0);

    if (flags & KEEP)
        return;

    // for memory reasons, we delete the image and access the alpha or
    // the texture directly
    stbi_image_free(image);
    image = NULL;
}

void Image::set_filter(bool linear)
{
    if (((flags & LINEAR_FILTER) != 0) == linear)
        return;
    if (linear)
        flags |= LINEAR_FILTER;
    else
        flags &= ~LINEAR_FILTER;
    if (tex == 0)
        return;

    Render::set_filter(tex, linear);
}

#if !defined(CHOWDREN_IS_WIIU)
// XXX change glc_copy_color_buffer_rect so this isn't necessary

const float back_texcoords[4] = {
    0.0f, 1.0f,
    1.0f, 0.0f
};
#else
const float back_texcoords[4] = {
    0.0f, 0.0f,
    1.0f, 1.0f
};
#endif

const float fbo_texcoords[4] = {
#ifdef CHOWDREN_FBO_FLIP
    back_texcoords[0], back_texcoords[3],
    back_texcoords[2], back_texcoords[1]
#else
    back_texcoords[0], back_texcoords[1],
    back_texcoords[2], back_texcoords[3]
#endif
};

void Image::draw(int x, int y, Color color,
                 float angle, float scale_x, float scale_y)
{
    if (tex == 0) {
        upload_texture();

        if (tex == 0)
            return;
    }

    if (angle == 0.0f && scale_x == 1.0f && scale_y == 1.0f) {
        int xx = x - hotspot_x;
        int yy = y - hotspot_y;
        Render::draw_tex(xx, yy, xx + width, yy + height, color, tex);
        return;
    }

    float r = rad(angle);
    float c = cos(r);
    float s = sin(r);

    float x1 = -hotspot_x * scale_x;
    float y1 = -hotspot_y * scale_y;
    float x2 = (-hotspot_x + width) * scale_x;
    float y2 = (-hotspot_y + height) * scale_y;
    
    float x1c = x1 * c;
    float x1s = -x1 * s;
    float y1c = y1 * c;
    float y1s = y1 * s;
    float x2c = x2 * c;
    float x2s = -x2 * s;
    float y2c = y2 * c;
    float y2s = y2 * s;

    float p[8] = {
        x1c + y1s + x, x1s + y1c + y,
        x2c + y1s + x, x2s + y1c + y,
        x2c + y2s + x, x2s + y2c + y,
        x1c + y2s + x, x1s + y2c + y
    };
    Render::draw_tex(&p[0], color, tex);
}

void Image::draw_flip_x(int x, int y, Color color,
                        float angle, float scale_x, float scale_y)
{
    if (tex == 0) {
        upload_texture();

        if (tex == 0)
            return;
    }

    if (angle == 0.0f && scale_x == 1.0f && scale_y == 1.0f) {
        int xx = x - hotspot_x;
        int yy = y - hotspot_y;
        Render::draw_tex(xx + width, yy, xx, yy + height, color, tex);
        return;
    }

    float r = rad(angle);
    float c = cos(r);
    float s = sin(r);

    float x2 = -hotspot_x * scale_x;
    float y1 = -hotspot_y * scale_y;
    float x1 = (-hotspot_x + width) * scale_x;
    float y2 = (-hotspot_y + height) * scale_y;
    
    float x1c = x1 * c;
    float x1s = -x1 * s;
    float y1c = y1 * c;
    float y1s = y1 * s;
    float x2c = x2 * c;
    float x2s = -x2 * s;
    float y2c = y2 * c;
    float y2s = y2 * s;

    float p[8] = {
        x1c + y1s + x, x1s + y1c + y,
        x2c + y1s + x, x2s + y1c + y,
        x2c + y2s + x, x2s + y2c + y,
        x1c + y2s + x, x1s + y2c + y
    };
    Render::draw_tex(&p[0], color, tex);
}

void Image::draw(int x, int y, int src_x, int src_y, int w, int h, Color c)
{
    if (tex == 0) {
        upload_texture();

        if (tex == 0)
            return;
    }

    int x2 = x + w;
    int y2 = y + h;

    float t_x1 = float(src_x) / float(width);
    float t_x2 = t_x1 + float(w) / float(width);
    float t_y1 = float(src_y) / float(height);
    float t_y2 = t_y1 + float(h) / float(height);
    Render::draw_tex(x, y, x2, y2, c, tex, t_x1, t_y1, t_x2, t_y2);
}

bool Image::is_valid()
{
    return image != NULL || tex != 0;
}

#ifdef CHOWDREN_16BIT_IMAGE
inline unsigned char to_b5(unsigned char v)
{
    return v & 0xF8;
}

inline unsigned char to_b6(unsigned char v)
{
    return v & 0xFC;
}
#endif

void Image::set_transparent_color(TransparentColor color)
{
    if (image == NULL)
        return;

#ifdef CHOWDREN_16BIT_IMAGE
    unsigned char r = to_b5(color.r);
    unsigned char g = to_b6(color.g);
    unsigned char b = to_b5(color.b);
#endif

    for (int i = 0; i < width * height; i++) {
        unsigned char * c = &image[i*4];
#ifdef CHOWDREN_16BIT_IMAGE
        if (to_b5(c[0]) != r || to_b6(c[1]) != g || to_b5(c[2]) != b)
            continue;
#else
        if (c[0] != color.r || c[1] != color.g || c[2] != color.b)
            continue;
#endif
        c[3] = 0;
    }
}

// FileImage

FileImage::FileImage(const std::string & filename, int hot_x, int hot_y,
                     int act_x, int act_y, TransparentColor color)
: filename(filename), transparent(color), Image(hot_x, hot_y, act_x, act_y)
{
    flags |= FILE;
}

void FileImage::load_data(unsigned char * data, int size)
{
    int w, h, channels;
    image = load_image(data, size, &w, &h, &channels);

    width = w;
    height = h;

    if (image == NULL) {
        printf("Could not load image \"%s\": %s\n", filename.c_str(),
               stbi_failure_reason());
        return;
    }

    if (!transparent.is_enabled())
        return;

#ifndef CHOWDREN_FORCE_TRANSPARENT
    if (channels != 1 && channels != 3)
        return;
#endif

    set_transparent_color(transparent);
}

void FileImage::load_file()
{
    FSFile fp(filename.c_str(), "r");

    if (!fp.is_open()) {
        printf("Could not open image \"%s\"\n", filename.c_str());
        return;
    }

    int w, h, channels;
    image = load_image(fp, fp.get_size(), &w, &h, &channels);

    width = w;
    height = h;

    fp.close();

    if (image == NULL) {
        printf("Could not load image \"%s\": %s\n", filename.c_str(),
               stbi_failure_reason());
        return;
    }

    if (!transparent.is_enabled())
        return;

#ifndef CHOWDREN_FORCE_TRANSPARENT
    if (channels != 1 && channels != 3)
        return;
#endif

    set_transparent_color(transparent);
}

static Image * internal_images[IMAGE_COUNT];

typedef hash_map<std::string, FileImage*> ImageCache;
static ImageCache image_cache;

Image * get_internal_image(unsigned int i)
{
    if (internal_images[i] == NULL) {
        internal_images[i] = new Image(i);
        internal_images[i]->flags |= Image::CACHED;
    }

    Image * image = internal_images[i];
    image->load();

    return internal_images[i];
}

Image * get_image_cache(const std::string & filename, int hot_x, int hot_y,
                        int act_x, int act_y, TransparentColor color)
{
    FileImage * image;
    ImageCache::const_iterator it = image_cache.find(filename);
    if (it == image_cache.end()) {
        image = new FileImage(filename, 0, 0, 0, 0, color);
        image->load();
        if (image->is_valid())
            image->flags |= Image::USED | Image::CACHED;
        else {
            std::cout << "Could not load image " << filename << std::endl;
            delete image;
            image = NULL;
        }
        image_cache[filename] = image;
    } else {
        image = it->second;
    }
    return image;
}

bool has_image_cache(const std::string & filename)
{
    return image_cache.find(filename) != image_cache.end();
}

void set_image_cache(const std::string & filename, FileImage * image)
{
    image_cache[filename] = image;
}

void reset_image_cache()
{
#ifdef CHOWDREN_TEXTURE_GC
    for (int i = 0; i < IMAGE_COUNT; i++) {
        Image * image = internal_images[i];
        if (image == NULL)
            continue;
        image->flags &= ~Image::USED;
    }
#endif
}

void flush_image_cache()
{
#ifdef CHOWDREN_TEXTURE_GC
    for (int i = 0; i < IMAGE_COUNT; i++) {
        Image * image = internal_images[i];
        if (image == NULL || image->flags & (Image::USED | Image::STATIC))
            continue;
        image->unload();
    }
#endif
}

void preload_images()
{
#ifndef CHOWDREN_IS_DESKTOP
#if defined(CHOWDREN_PRELOAD_IMAGES) || defined(CHOWDREN_PRELOAD_ALL)
    AssetFile fp;
    fp.open();
    FileStream stream(fp);

#ifdef CHOWDREN_IS_3DS
    Render::set_storage(true);
#endif

    for (int i = 0; i < IMAGE_COUNT; i++) {
        unsigned short handle = stream.read_uint16();
        Image * image = get_internal_image(handle);
        image->upload_texture();
#if !defined(CHOWDREN_PRELOAD_ALL) && defined(CHOWDREN_IS_3DS)
        if (Render::is_vram_full())
            break;
#endif
        image->set_static();
    }

#ifdef CHOWDREN_IS_3DS
    Render::set_storage(false);
#endif

#endif
#endif
}

Image dummy_image;

void ReplacedImages::replace(Color from, Color to)
{
    if (index >= MAX_COLOR_REPLACE) {
        std::cout << "Max color replacements reached" << std::endl;
        return;
    }
    from.disable();
    colors[index++] = Replacement(from, to);
}

void ReplacedImages::set_transparent(TransparentColor value)
{
    if (index >= MAX_COLOR_REPLACE) {
        std::cout << "Max color replacements reached" << std::endl;
        return;
    }
    Color c = Color(value);
    c.enable();
    colors[index++] = Replacement(c, Color(0, 0, 0, 0));
}

Image * ReplacedImages::apply(Image * image, Image * src_image)
{
    Image * ret = apply_direct(image, src_image);
    index = 0;
    return ret;
}

Image * ReplacedImages::apply_direct(Image * image, Image * src_image)
{
    int count = index;
    int hash = 0;
    int hash_index = 0;

    for (int i = 0; i < count; i++) {
        Color first = colors[i].first;
        Color second = colors[i].second;
        hash += first.r * (++hash_index);
        hash += first.g * (++hash_index);
        hash += first.b * (++hash_index);
        hash += second.r * (++hash_index);
        hash += second.g * (++hash_index);
        hash += second.b * (++hash_index);
    }

    vector<ReplacedImage>::const_iterator it2;
    for (it2 = images.begin(); it2 != images.end(); ++it2) {
        const ReplacedImage & img = *it2;
        if (img.hash == hash && img.src_image == src_image) {
            return img.image;
        }
    }

    Image * new_image = image->copy();
    for (int i = 0; i < count; i++) {
        Color first = colors[i].first;
        Color second = colors[i].second;
        if (first.is_enabled()) {
            new_image->set_transparent_color(first);
        } else
            new_image->replace(first, second);
    }

    images.push_back(ReplacedImage(src_image, new_image, hash));
    new_image->flags |= Image::KEEP;
    return new_image;
}

vector<ReplacedImage> ReplacedImages::images;
