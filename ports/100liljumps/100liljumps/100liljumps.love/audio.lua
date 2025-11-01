Audio = {} 
Audio.sounds = {}
Audio.fade_in_sounds = {}
Audio.fade_out_sounds = {}

Audio.songs = {}
Audio.fade_in_songs = {}
Audio.fade_out_songs = {}

Audio.music_volume = 0.5 
Audio.sounds_volume = 0.5 

Audio.FadeState = {
    IDLE     = 0,
    FADE_IN  = 1,
    FADE_OUT = 2,
}

Audio.music_fade_enabled = true

Audio.reset_state = function()
    Audio.music_fade_enabled = true
    Audio.stop_song("glitch_break")

    for key, song in pairs(Audio.songs) do
        if song.src:isPlaying() then
            local should_reset_after_stop = true
            Audio.fade_out_song(key, should_reset_after_stop)
        else
            song.src:stop()
        end
    end
end

Audio.create_song = function(filename, key)
    local type = "stream"
    local source = love.audio.newSource(filename, type)
    local song_struct = {
        src = source,
        fade_state = Audio.FadeState.IDLE,
        fade_factor = 0,
        low_pass_factor = 0,
        volume = 1,
        src_volume = 1,
        reset_after_stop = false
    }
    source:setLooping(true)
    source:setVolume(0)

    Audio.songs[key] = song_struct
end

local LOW_PASS_HIGHGAIN = 0.01

Audio.create_song("sounds/MAIN MENU.ogg", "lobby")

--Audio.create_song("sounds/caves.wav", "cave")
Audio.create_song("sounds/CAVE.ogg", "cave")
Audio.create_song("sounds/CAVE.ogg", "cave_low_pass")
local cave_low_pass_src = Audio.songs["cave_low_pass"].src
cave_low_pass_src:setFilter( {
    type = "lowpass",
    highgain = LOW_PASS_HIGHGAIN
} )
Audio.create_song("sounds/CAVE CHALLENGE.ogg", "cave_challenge")

Audio.create_song("sounds/JUNGLE.ogg", "jungle")
Audio.create_song("sounds/JUNGLE.ogg", "jungle_low_pass")
local jungle_low_pass_src = Audio.songs["jungle_low_pass"].src
jungle_low_pass_src:setFilter( {
    type = "lowpass",
    highgain = LOW_PASS_HIGHGAIN
} )
Audio.create_song("sounds/JUNGLE CHALLENGE.ogg", "jungle_challenge")

Audio.create_song("sounds/TEMPLE.ogg", "temple")
Audio.create_song("sounds/TEMPLE.ogg", "temple_low_pass")
local temple_low_pass_src = Audio.songs["temple_low_pass"].src
temple_low_pass_src:setFilter( {
    type = "lowpass",
    highgain = LOW_PASS_HIGHGAIN
} )
Audio.create_song("sounds/TEMPLE CHALLENGE.ogg", "temple_challenge")
Audio.create_song("sounds/TEMPLE CHALLENGE.ogg", "temple_challenge_low_pass")
local temple_challenge_low_pass_src = Audio.songs["temple_challenge_low_pass"].src
temple_challenge_low_pass_src :setFilter( {
    type = "lowpass",
    highgain = LOW_PASS_HIGHGAIN
} )

Audio.create_song("sounds/MUSEUM.ogg", "gallery")
Audio.create_song("sounds/DARK CAVE.ogg", "dark_ambience")

Audio.create_song("sounds/PUZZLE.ogg", "puzzle")

Audio.create_song("sounds/GLITCH INTRO.ogg", "glitch_start")
Audio.create_song("sounds/GLITCH BREAK.ogg", "glitch_break")

Audio.create_song("sounds/JungleSFXLoop.ogg", "forest_ambiance")

Audio.play_song = function(key)
    local song = Audio.songs[key]
    song.src:setPitch(1)
    song.fade_factor = 1

    song.src:play()
end

Audio.create_sound = function(filename, key, type, amount, volume, loop)
    local volume = volume or 1
    local type = type or "static"
    local s1 = love.audio.newSource(filename, type)
    if(loop) then
        s1:setLooping(true)
    end
    s1:setVolume(volume)
    local sources = {s1}
    local amount = amount or 1
    for i = 2, amount do
        local new_source = s1:clone()
        if(loop) then
            new_source:setLooping(true)
        end
        table.insert(sources, new_source)
    end

    Audio.sounds[key] = sources
end

Audio.get_sound = function(key)
    return Audio.sounds[key]
end

Audio.play_sound = function(key, min_offset, max_offset, _volume)
    local volume = Audio.sound_volumes[key] or _volume or 1
    local sources = Audio.sounds[key]
    if not sources then
        error("[ERROR]: sources not found for key: " .. key)
    end

    local i = 1
    while(i <= #sources and sources[i]:isPlaying()) do
        i = i + 1
    end
    if i <= #sources then
        local src = sources[i]
        src:setPitch(1)
        local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
        src:setVolume((volume) * corrected_volume)
        if min_offset and max_offset then
            src:setPitch(lume.lerp(min_offset, max_offset, math.random()))
        end

        love.audio.play(src)
    end
end

Audio.fade_in_sound = function(key, target_time, volume)
    assert(target_time, "[ERROR]: No target time provided")
    local srcs = Audio.sounds[key]
    table.insert(Audio.fade_in_sounds, {
        key = key,
        time = 0,
        target_time = target_time,
        volume = volume or srcs[1]:getVolume()
    })
    for _, src in pairs(srcs) do
        src:setVolume(0)
        love.audio.play(src)
    end
end

Audio.fade_out_sound = function(key, target_time)
    assert(target_time, "[ERROR]: No target time provided")
    local srcs = Audio.sounds[key]
    table.insert(Audio.fade_out_sounds, {
        key = key,
        time = 0,
        target_time = target_time,
        volume = srcs[1]:getVolume()
    })
end

Audio.low_pass_key_for_song = function(key)
    return key .. "_low_pass"
end

Audio.fade_in_song = function(key)
    if not Audio.music_fade_enabled then return end

    local song = Audio.songs[key]
    local src = song.src
    local low_pass_key = Audio.low_pass_key_for_song(key)
    local low_pass_song = Audio.songs[low_pass_key]

    song.fade_state = Audio.FadeState.FADE_IN 
    song.low_pass_factor = 1

    local corrected_volume = Audio.corrected_factor_from_linear(Audio.music_volume)
    local corrected_factor = Audio.corrected_factor_from_linear(song.fade_factor)
    song.src_volume = song.volume * corrected_factor * corrected_volume
    src:setVolume(song.volume * corrected_factor * corrected_volume)
    src:play()
    if low_pass_song then
        low_pass_song.fade_state = Audio.FadeState.FADE_IN 
        low_pass_song.low_pass_factor = 0
        low_pass_song.src:setVolume(0)
        low_pass_song.src_volume = 0
        low_pass_song.src:play()
    end
end

Audio.fade_out_song = function(key, should_reset_after_stop)
    if not Audio.music_fade_enabled then return end
    local should_reset_after_stop = should_reset_after_stop or false

    local low_pass_key = Audio.low_pass_key_for_song(key)
    local low_pass_song = Audio.songs[low_pass_key]
    Audio.songs[key].fade_state = Audio.FadeState.FADE_OUT
    Audio.songs[key].reset_after_stop = should_reset_after_stop
    if low_pass_song then
	    low_pass_song.fade_state = Audio.FadeState.FADE_OUT
	    low_pass_song.reset_after_stop = should_reset_after_stop
	    low_pass_song.src:setVolume(0)
	    low_pass_song.src_volume = 0
    end
end

Audio.stop_sound = function(key)
    local sources = Audio.sounds[key]
    for _, src in pairs(sources) do
        love.audio.stop(src)
    end
end

Audio.stop_song = function(key)
    local song = Audio.songs[key]
    local low_pass_key = Audio.low_pass_key_for_song(key)
    local low_pass = Audio.songs[low_pass_key]

    song.src:stop()
    song.fade_factor = 0
    song.fade_state = Audio.FadeState.IDLE
    if(low_pass) then
        low_pass.src:stop()
        low_pass.fade_factor = 0
    end
end

Audio.update_sounds_timer = 0
Audio.update = function(dt)
    if(dev_mode) then
        Audio.update_sounds_timer = Audio.update_sounds_timer + dt
        if(Audio.update_sounds_timer > 1) then
            Audio.update_sounds_timer = 0
            Audio.reload_sounds_volume()
        end
    end

    for i, sound in pairs(Audio.fade_in_sounds) do
        sound.time = sound.time + dt
        local t = sound.time / sound.target_time
        local volume = lume.lerp(0, sound.volume, t)
        local srcs = Audio.sounds[sound.key]

        if(t >= 1) then
            for _, src in pairs(srcs) do
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
                src:setVolume(sound.volume * corrected_volume)
            end
            table.remove(Audio.fade_in_sounds, i)
        else
            for _, src in pairs(srcs) do
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
                src:setVolume(volume * corrected_volume)
            end
        end
    end

    for i, sound in pairs(Audio.fade_out_sounds) do
        sound.time = sound.time + dt
        local t = sound.time / sound.target_time
        local volume = lume.lerp(sound.volume, 0, t)
        local srcs = Audio.sounds[sound.key]

        if(t >= 1) then
            for _, src in pairs(srcs) do
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
                src:setVolume(sound.volume * corrected_volume)

                love.audio.stop(src)
            end
            table.remove(Audio.fade_out_sounds, i)
        else
            for _, src in pairs(srcs) do
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
                src:setVolume(volume * corrected_volume)
            end
        end
    end

    local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
    for _, playing_sound in pairs(game_state.tile_map.playing_sounds) do
        local audio_found = false
        for _, audio in pairs(Audio.fade_in_sounds) do
            if audio.key == playing_sound.key then
                audio_found = true
            end
        end
        for _, audio in pairs(Audio.fade_out_sounds) do
            if audio.key == playing_sound.key then
                audio_found = true
            end
        end

        if not audio_found then
            local sounds = Audio.get_sound(playing_sound.key)
            if sounds then
                for _, sound in pairs(sounds) do
                    sound:setVolume(playing_sound.volume * corrected_volume)
                end
            end
        end
    end

    local FADE_IN_TARGET_TIME_IN_SECONDS = 4
    local FADE_OUT_TARGET_TIME_IN_SECONDS = 2
    for _, song in pairs(Audio.songs) do
        local pause_factor = 1
        if game_state.game_mode == GameMode.PAUSE then
            pause_factor = 0.5
        end

        local corrected_factor = Audio.corrected_factor_from_linear(song.fade_factor)
        local corrected_volume = Audio.corrected_factor_from_linear(Audio.music_volume)
        song.src_volume = song.volume * corrected_factor * corrected_volume * pause_factor

        if song.fade_state == Audio.FadeState.FADE_IN then
            song.fade_factor = song.fade_factor + dt/FADE_IN_TARGET_TIME_IN_SECONDS
            song.fade_factor = math.min(song.fade_factor, 1)

            song.src:play()

            if(song.fade_factor >= 1) then
                song.fade_factor = 1
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.music_volume)
                local corrected_factor = Audio.corrected_factor_from_linear(song.fade_factor)
                song.src_volume = song.volume * corrected_factor * corrected_volume
                song.fade_state = Audio.FadeState.IDLE
            end

        elseif song.fade_state == Audio.FadeState.FADE_OUT then
            song.fade_factor = song.fade_factor - dt/FADE_OUT_TARGET_TIME_IN_SECONDS
            song.fade_factor = math.max(song.fade_factor, 0)
            song.src:play()

            if(song.fade_factor <= 0) then
                song.fade_factor = 0
                song.fade_state = Audio.FadeState.IDLE
                local corrected_volume = Audio.corrected_factor_from_linear(Audio.music_volume)
                local corrected_factor = Audio.corrected_factor_from_linear(song.fade_factor)
                song.src_volume = song.volume * corrected_factor * corrected_volume

                if song.reset_after_stop then
                    song.src:stop()
                else
                    song.src:pause()
                end
            end
        end
    end

    local flies_sound = Audio.get_sound("flies")[1]
    local flies_volume = game_state.tile_map:flies_volume()
    local corrected_volume = Audio.corrected_factor_from_linear(Audio.sounds_volume)
    if flies_volume == 0 then
        flies_sound:stop()
    else
        flies_sound:play()
    end

    flies_sound:setVolume(flies_volume * corrected_volume)

    Audio.handle_low_pass_fade(dt)

    for _, song in pairs(Audio.songs) do
        song.src:setVolume(song.src_volume)
    end
end

Audio.is_playing = function(key)
    local sources = Audio.sounds[key]
    if(not sources) then
        print("[ERROR]: source not found for key: " .. key)
    end

    local src = sources[1]

    return src:isPlaying()
end


local s = love.audio.setEffect("subwater_effect", {
    type = "reverb",
    volume = 1,
})

Audio.update_playing_songs_filter = function(filter)
    for _, song in pairs(Audio.songs) do
        local src = song.src
        if(filter == "remove_filter") then
            src:setFilter(nil)
        elseif(filter ~= nil) then
            src:setFilter(filter)
        end
    end
end

Audio.update_playing_songs_audio = function()
    for _, song in pairs(Audio.songs) do
        local src = song.src
        local corrected_volume = Audio.corrected_factor_from_linear(Audio.music_volume)
        song.src_volume = corrected_volume
    end
end

Audio.increase_music_volume_pressed = function()
    Audio.music_volume = math.min(Audio.music_volume + 0.1, 1)
end

Audio.increase_sounds_volume_pressed = function()
    Audio.sounds_volume = math.min(Audio.sounds_volume + 0.1, 1)
end

Audio.decrease_music_volume_pressed = function()
    Audio.music_volume = math.max(Audio.music_volume - 0.1, 0)
end

Audio.decrease_sounds_volume_pressed = function()
    Audio.sounds_volume = math.max(Audio.sounds_volume - 0.1, 0)
end

Audio.load_data = function(save_data)
    Audio.music_volume = save_data.music_volume or 0.5
    Audio.sounds_volume = save_data.sounds_volume or 0.5
end

Audio.create_effect = function(time, type, data)
    local effect = {
        target_time = time,
        type = type,
        current_time = 0,
        data = data,
    }

    table.insert(Audio.effects, effect)
end


local EffectType = {
    LowPassIn  = 0,
    LowPassOut = 1
}

Audio.low_pass_t = 0
Audio.low_pass_time = 0
local LOW_PASS_TRANSITION_TIME = 0.2
Audio.handle_low_pass_fade = function(dt)
    if(Audio.should_apply_underwater) then
        Audio.low_pass_time = math.min(Audio.low_pass_time + dt, LOW_PASS_TRANSITION_TIME)
    else
        Audio.low_pass_time = math.max(Audio.low_pass_time - dt, 0)
    end

    Audio.low_pass_t = Audio.low_pass_time / LOW_PASS_TRANSITION_TIME

    local song_key = game_state.tile_map:song_key()
    local song = Audio.songs[song_key]
    local low_pass_song_key = Audio.low_pass_key_for_song(song_key)
    local low_pass_song = Audio.songs[low_pass_song_key]

    if(low_pass_song) then
        local low_pass_volume = low_pass_song.src:getVolume()
        low_pass_song.src_volume = low_pass_song.src_volume * Audio.low_pass_t

        local regular_song_volume = song.src:getVolume()
        song.src_volume = song.src_volume * (1 - Audio.low_pass_t)
    end
end

Audio.should_apply_underwater = false
Audio.set_underwater_filter = function()
    Audio.should_apply_underwater = true 
end

Audio.remove_underwater_filter = function()
    Audio.should_apply_underwater = false 
end

Audio.reload_sounds_volume = function()
    local path = "./sound_volumes.lua"
    local file, open_err = io.open(path, "r")
    if(not file) then
        print("[ERROR] Couldn't reload sound volumes file", open_err)
        return
    end
    local contents, read_err = file:read("a")
    if(not contents) then
        print("[ERROR] Couldn't read sound volumes file", open_err)
        return
    end

    local sound_volumes_map = lume.deserialize(contents)
    for key, value in pairs(sound_volumes_map) do
        Audio.sound_volumes[key] = value
    end

    file:close()
end

Audio.stop_all_songs = function()
    for key, _ in pairs(Audio.songs) do
        Audio.stop_song(key)
    end
end

Audio.sound_volumes = {
    splash = 0.4,
    bounce1 = 0.6,
    jump1 = 1.0,
    land_1 = 0.5,
    died_1 = 1.0,

    cave_step_1 = 1.0,
    jungle_step_1 = 1.0,
    temple_step_1 = 1.0,
    trees_step_1 = 1.0,

    jump_cave = 1.0,
    jump_jungle = 1.0,
    jump_temple = 1.0,
    jump_trees = 1.0,

    falling_platform_step = 1.0,
}

Audio.corrected_factor_from_linear = function(linear_factor)
    if linear_factor == 0 then
        return 0
    end

    local exponent = 10 * (1 - linear_factor)
    local corrected_factor = 1 / math.pow(1.5, exponent)

    return corrected_factor
end

Audio.update_fly_cluster_sounds = function(fly_cluster)

end
