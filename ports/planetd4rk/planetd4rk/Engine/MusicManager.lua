local MusicManager = {}

function MusicManager.initialize(musicDirectory, musicFileNames, extension)
    MusicManager.allTracks = {}
    MusicManager.currentTrack = ""
    local status = web and "static" or "stream" -- switch based on web version or not
    for index,value in ipairs(musicFileNames) do
        MusicManager.allTracks[value] = love.audio.newSource(musicDirectory.."/"..value..extension, status)
        MusicManager.allTracks[value]:setLooping(true)
    end
end

function MusicManager.playTrack(musicFileName, volume)
    -- If a track that isn't this one is already playing, then stop it
    if MusicManager.currentTrack ~= "" and musicFileName ~= MusicManager.currentTrack then
        MusicManager.allTracks[MusicManager.currentTrack]:stop()
    end

    -- If this specific track is already playing, then just do nothing
    if not MusicManager.allTracks[musicFileName]:isPlaying() then
        volume = volume or 1
        MusicManager.allTracks[musicFileName]:setVolume(volume)
        MusicManager.allTracks[musicFileName]:play()
        MusicManager.currentTrack = musicFileName 
    end
end

function MusicManager.setVolume(volume)
    if MusicManager.currentTrack ~= "" then
        MusicManager.allTracks[MusicManager.currentTrack]:setVolume(volume)
    end
end

function MusicManager.getVolume()
    return MusicManager.allTracks[MusicManager.currentTrack]:getVolume()
end

function MusicManager.stop()
    if MusicManager.currentTrack ~= "" then
        MusicManager.allTracks[MusicManager.currentTrack]:stop()
    end
end

function MusicManager.fadeOut(delay)
    local faderObj = GameObjects.newGameObject(-1,0,0,0,true)
    delay = delay or 0.5
    local yieldTime = delay / 5
    faderObj.fade = 
        function()
            local diff = MusicManager.getVolume() / 5
            for k = 1,5 do
                MusicManager.setVolume(MusicManager.getVolume() - diff)
                coroutine.yield(yieldTime)
            end
            MusicManager.stop()
            faderObj:setInactive()
        end
    faderObj:startCoroutine(faderObj.fade, "fade")
end

return MusicManager