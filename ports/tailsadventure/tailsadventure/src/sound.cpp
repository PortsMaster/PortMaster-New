#include "sound.h"
#include "error.h"
#include "resource_manager.h"
#include "save.h"
#include "error.h"

void TA::sound::update()
{
    Mix_Volume(-1, TA::save::getParameter("main_volume") * 16);
    Mix_Volume(TA_SOUND_CHANNEL_MUSIC, TA::save::getParameter("music_volume") * 16);
    Mix_Volume(TA_SOUND_CHANNEL_SFX1, TA::save::getParameter("sfx_volume") * 16);
    Mix_Volume(TA_SOUND_CHANNEL_SFX2, TA::save::getParameter("sfx_volume") * 16);
    Mix_Volume(TA_SOUND_CHANNEL_SFX3, TA::save::getParameter("sfx_volume") * 16);
}

bool TA::sound::isPlaying(TA_SoundChannel channel)
{
    return Mix_Playing(channel);
}

void TA::sound::fadeOut(int time)
{
    for(int channel = 0; channel < TA_SOUND_CHANNEL_MAX; channel ++) {
        fadeOutChannel(TA_SoundChannel(channel), time);
    }
}

void TA::sound::fadeOutChannel(TA_SoundChannel channel, int time)
{
    Mix_FadeOutChannel(channel, time * 1000 / 60);
}

void TA_Sound::load(std::string filename, TA_SoundChannel newChannel, bool newLoop)
{
    chunk = TA::resmgr::loadChunk(filename);
    channel = newChannel;
    loop = newLoop;
}

void TA_Sound::play()
{
    if(chunk == nullptr) {
        return;
    }
    if(channel == TA_SOUND_CHANNEL_MUSIC) {
        Mix_Volume(TA_SOUND_CHANNEL_MUSIC, TA::save::getParameter("music_volume"));
    }
    Mix_PlayChannel(channel, chunk, loop);
}

void TA_Sound::fadeOut(int time)
{
    Mix_FadeOutChannel(channel, time * 1000 / 60);
}
