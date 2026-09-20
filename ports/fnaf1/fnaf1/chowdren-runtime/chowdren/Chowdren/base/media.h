#ifndef CHOWDREN_MEDIA_H
#define CHOWDREN_MEDIA_H

#include "assetfile.h"

void set_sounds_path(const std::string & path);

class SoundData;

namespace ChowdrenAudio
{
    class SoundBase;
}

class Channel
{
public:
    unsigned int id;
    bool locked;
    ChowdrenAudio::SoundBase * sound;
    double volume, frequency, pan;

    Channel();
    void play(SoundData * data, int loop);
    void resume();
    void pause();
    void stop();
    void set_volume(double value);
    void set_frequency(double value);
    void set_position(double value);
    double get_position();
    double get_frequency();
    double get_duration();
    void set_pan(double value);
    bool is_invalid();
    bool is_stopped();
};

class Media
{
public:
    SoundData * sounds[SOUND_ARRAY_SIZE];
    Channel channels[32];

    enum AudioType
    {
        NONE = 0,
        WAV,
        OGG,
        NATIVE
    };

    void init();
    void stop();
    void play(SoundData * data, int channel = -1, int loop = 1);
    void play(const std::string & filename, int channel = -1, int loop = 1);
    void play_id(unsigned int id, int channel = -1, int loop = 1);
    void lock(unsigned int channel);
    void unlock(unsigned int channel);
    void set_channel_volume(unsigned int channel, double volume);
    void set_channel_frequency(unsigned int channel, double freq);
    void set_channel_pan(unsigned int channel, double pan);
    void resume_channel(unsigned int channel);
    void pause_channel(unsigned int channel);
    void stop_channel(unsigned int channel);
    Channel * get_sample(unsigned int id);
    void set_sample_volume(unsigned int id, double volume);
    void set_sample_pan(unsigned int id, double pan);
    void set_sample_position(unsigned int id, double pos);
    void set_sample_frequency(unsigned int id, double freq);
    double get_sample_volume(unsigned int id);
    double get_sample_position(unsigned int id);
    double get_sample_duration(unsigned int id);
    void stop_sample(unsigned int id);
    void stop_samples();
    void pause_samples();
    void resume_samples();
    double get_channel_position(unsigned int channel);
    void set_channel_position(unsigned int channel, double pos);
    double get_channel_volume(unsigned int channel);
    double get_channel_duration(unsigned int channel);
    double get_channel_frequency(unsigned int channel);
    double get_channel_pan(unsigned int channel);
    bool is_sample_playing(unsigned int id);
    bool is_channel_playing(unsigned int channel);
    bool is_channel_valid(unsigned int channel);
    void add_file(unsigned int id, const std::string & fn);
    void add_cache(unsigned int id, FSFile & fp);
    void add_data(unsigned int id, FSFile & fp, size_t size, AudioType type);
    double get_main_volume();
    void set_main_volume(double volume);
};

extern Media media;

#endif // CHOWDREN_MEDIA_H
