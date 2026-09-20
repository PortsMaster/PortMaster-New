#include <vorbis/vorbisfile.h>
#include <string>
#include "stringcommon.h"
#include "fileio.h"
#include "platform.h"
#include "path.h"
#include <string.h>
#include "media.h"

namespace ChowdrenAudio {

template <typename T>
void swap(T &val1, T &val2)
{
    val1 ^= val2;
    val2 ^= val1;
    val1 ^= val2;
}

class SoundDecoder
{
public:
    std::size_t samples;
    int channels;
    int sample_rate;

    virtual bool is_valid() = 0;
    virtual std::size_t read(signed short * data, std::size_t samples) = 0;
    virtual void seek(double value) = 0;
    virtual ~SoundDecoder() {};
    virtual void post_init() {};

    std::size_t get_samples()
    {
        if (samples == std::size_t(-1))
            post_init();
        return samples;
    }

};

static size_t read_func(void * ptr, size_t size, size_t nmemb, void *fp);
static int seek_func(void *fp, ogg_int64_t offset, int whence);
static long tell_func(void *fp);

ov_callbacks callbacks = {
    read_func,
    seek_func,
    NULL,
    tell_func
};

class OggDecoder : public SoundDecoder
{
public:
    FSFile & fp;
    size_t start;
    size_t pos;
    size_t size;
    OggVorbis_File ogg_file;
    vorbis_info * ogg_info;
    int ogg_bitstream;
    bool fully_open;

    OggDecoder(FSFile & fp, size_t size)
    : ogg_info(NULL), ogg_bitstream(0), size(size), fully_open(false), fp(fp)
    {
        start = fp.tell();
        pos = 0;

        if (ov_test_callbacks((void*)this, &ogg_file, NULL, 0, callbacks) != 0)
            return;

        ogg_info = ov_info(&ogg_file, -1);
        if (!ogg_info) {
            ov_clear(&ogg_file);
            return;
        }

        channels = ogg_info->channels;
        sample_rate = ogg_info->rate;
        samples = -1;
    }

    ~OggDecoder()
    {
        if (ogg_info)
            ov_clear(&ogg_file);
        ogg_info = NULL;
    }

    bool is_valid()
    {
        return ogg_info != NULL;
    }

    void post_init()
    {
        if (ogg_file.ready_state != PARTOPEN)
            return;
        ov_test_open(&ogg_file);
        samples = ov_pcm_total(&ogg_file, -1) * channels;
    }

    size_t read(signed short * sdata, std::size_t samples)
    {
        if (!(sdata && samples))
            return 0;
        if (ogg_file.ready_state == PARTOPEN)
            post_init();
        unsigned int got = 0;
        int bytes = samples * 2;
        char * data = (char*)sdata;
        while(bytes > 0) {
#ifdef IS_BIG_ENDIAN
            int big_endian = 1;
#else
            int big_endian = 0;
#endif
            int res = ov_read(&ogg_file, &data[got], bytes,
                              big_endian, 2, 1, &ogg_bitstream);
            if(res <= 0)
                break;
            bytes -= res;
            got += res;
        }
        // XXX support exotic channel formats?
        return got / 2;
    }

    void seek(double value)
    {
        if (ogg_file.ready_state == PARTOPEN)
            post_init();
        value = std::max(0.0, value);
        int ret = ov_time_seek(&ogg_file, value);
        if (ret == 0)
            return;
        std::cout << "Seek failed: " << ret << " with time " << value
            << std::endl;
    }
};

size_t read_func(void * ptr, size_t size, size_t nmemb, void *fp)
{
    OggDecoder * file = (OggDecoder*)fp;
    size *= nmemb;
    size = std::min(file->size - file->pos, size);
    file->pos += size;
    return file->fp.read(ptr, size);
}

int seek_func(void *fp, ogg_int64_t offset, int whence)
{
    OggDecoder * file = (OggDecoder*)fp;
    switch (whence) {
        case SEEK_SET:
            break;
        case SEEK_END:
            offset = file->size - offset;
            break;
        case SEEK_CUR:
            offset += file->pos;
            break;
    }
    offset = std::min<ogg_int64_t>(file->size, offset);
    offset = std::max<ogg_int64_t>(0, offset);
    file->pos = offset;
    file->fp.seek(offset + file->start, SEEK_SET);
    return 1;
}

long tell_func(void *fp)
{
    OggDecoder * file = (OggDecoder*)fp;
    return file->pos;
}

inline unsigned int read_le32(FSFile & file)
{
    unsigned char buffer[4];
    if (!file.read((char*)buffer, 4))
        return 0;
    return buffer[0] | (buffer[1]<<8) | (buffer[2]<<16) | (buffer[3]<<24);
}

inline unsigned short read_le16(FSFile & file)
{
    unsigned char buffer[2];
    if (!file.read((char*)buffer, 2))
        return 0;
    return buffer[0] | (buffer[1]<<8);
}

class WavDecoder : public SoundDecoder
{
private:
    FSFile & file;
    int sample_size;
    int block_align;
    long data_start;
    long data_len;
    size_t rem_len;

public:
    WavDecoder(FSFile & fp, size_t size)
    : file(fp), data_start(0)
    {
        unsigned char buffer[25];
        unsigned int length;
        if (!file.read(reinterpret_cast<char*>(buffer), 12) ||
            memcmp(buffer, "RIFF", 4) != 0 ||
            memcmp(buffer+8, "WAVE", 4) != 0)
        {
            std::cerr << "WAV: Invalid header" << std::endl;
            return;
        }

        while (!data_start) {
            char tag[4];
            if (!file.read(tag, 4))
                break;

            length = read_le32(file);

            if(memcmp(tag, "fmt ", 4) == 0 && length >= 16) {
                // data type (should be 1 for PCM data, 3 for float PCM data
                int type = read_le16(file);
                if(type != 0x0001 && type != 0x0003) {
                    std::cerr << "WAV: Invalid type" << std::endl;
                    break;
                }

                channels = read_le16(file);
                sample_rate = read_le32(file);
                file.seek(4, SEEK_CUR);
                block_align = read_le16(file);
                if(block_align == 0) {
                    std::cerr << "WAV: Invalid blockalign" << std::endl;
                    break;
                }
                sample_size = read_le16(file);
                if (sample_size != 16) {
                    std::cerr << "WAV: Invalid sample size" << std::endl;
                    break;
                }
                length -= 16;

            }
            else if(memcmp(tag, "data", 4) == 0) {
                data_start = file.tell();
                data_len = rem_len = length;
            }

            file.seek(length, SEEK_CUR);
        }

        if(data_start > 0) {
            samples = data_len / (sample_size / 8);
            file.seek(data_start);
        }
    }

    ~WavDecoder()
    {
    }

    bool is_valid()
    {
        return (data_start > 0);
    }

    size_t read(signed short * data, std::size_t samples)
    {
        unsigned int bytes = samples * (sample_size / 8);
        size_t rem;
        if (rem_len >= bytes)
            rem = bytes;
        else
            rem = rem_len;
        rem /= block_align;
        size_t got = file.read((char*)data, rem*block_align);
        got -= got%block_align;
        rem_len -= got;

#ifdef IS_BIG_ENDIAN
        unsigned char * datac = (unsigned char *)data;
        if (sample_size == 16) {
            for(std::streamsize i = 0; i < got; i+=2)
                swap(datac[i], datac[i+1]);
        } else if (sample_size == 32) {
            for(std::streamsize i = 0; i < got; i+=4) {
                swap(datac[i+0], datac[i+3]);
                swap(datac[i+1], datac[i+2]);
            }
        } else if (sample_size == 64) {
            for(std::streamsize i = 0; i < got; i+=8) {
                swap(datac[i+0], datac[i+7]);
                swap(datac[i+1], datac[i+6]);
                swap(datac[i+2], datac[i+5]);
                swap(datac[i+3], datac[i+4]);
            }
        }
#endif

        return got / (sample_size / 8);
    }

    void seek(double t)
    {
        long new_pos = t * sample_rate * (sample_size / 8) * channels;
        new_pos = std::max(0L, std::min(new_pos, data_len));
        if (file.seek(data_start + new_pos))
            rem_len = data_len - new_pos;
    }
};

SoundDecoder * create_decoder(FSFile & fp, Media::AudioType type, size_t size)
{
    SoundDecoder * decoder;
    if (type == Media::WAV)
        decoder = new WavDecoder(fp, size);
    else if (type == Media::OGG)
        decoder = new OggDecoder(fp, size);
    else
        return NULL;
    if (decoder->is_valid())
        return decoder;
    std::cout << "Could not load sound" << std::endl;
    return NULL;
}

} // namespace ChowdrenAudio
