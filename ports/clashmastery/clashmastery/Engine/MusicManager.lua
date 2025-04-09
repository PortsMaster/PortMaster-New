local MusicManager = {}

function MusicManager.initialize(musicDirectory, musicFileNames, extension)
    MusicManager.allTracks = {}
    MusicManager.currentTrack = ""
    MusicManager.volumeScale = 0.5
    MusicManager.currentTrackVolume = 1
    local status = web and "static" or "stream" -- switch based on web version or not
    for index,value in ipairs(musicFileNames) do
        MusicManager.allTracks[value] = love.audio.newSource(musicDirectory.."/"..value..extension, status)
        MusicManager.allTracks[value]:setLooping(true)
    end
end

-- Coroutine version of the above function that allows for loading bar
-- Make sure to set these 3 properties first
-- MusicManager.musicDirectory, MusicManager.musicFileNames, MusicManager.extension
function MusicManager.initializeRoutine()
    local musicDirectory, musicFileNames, extension = MusicManager.musicDirectory, MusicManager.musicFileNames, MusicManager.extension
    MusicManager.currentTrackVolume = 1
    local status = web and "static" or "stream" -- switch based on web version or not
    local numFiles = #musicFileNames
    coroutine.yield(0)
    for index,value in ipairs(musicFileNames) do
        MusicManager.allTracks[value] = love.audio.newSource(musicDirectory.."/"..value..extension, status)
        MusicManager.allTracks[value]:setLooping(true)
        coroutine.yield(index/numFiles)
    end
end

function MusicManager.initializePropsPreload()
    MusicManager.allTracks = {}
    MusicManager.currentTrack = ""
    MusicManager.volumeScale = 0.5
end

function MusicManager.playSynchronizedTracks(musicFiles, volumes)
    for k = 1,#musicFiles do
        MusicManager.allTracks[musicFiles[k]]:setVolume(volumes[k] * MusicManager.volumeScale)
        MusicManager.allTracks[musicFiles[k]]:play()
        if volumes[k] > 0 then
            MusicManager.currentTrack = musicFiles[k]
            MusicManager.currentTrackVolume = volumes[k]
        end
    end
end

function MusicManager.stopAllTracks()
    for key, value in pairs(MusicManager.allTracks) do
        MusicManager.allTracks[key]:stop()
    end
end

function MusicManager.fadeSynchronizedTracks(musicFiles, volumes)
    if MusicManager.volumeScale == 0 then
        return
    end
    local faderObj = GameObjects.newGameObject(-1,0,0,0,true)
    delay = delay or 0.5
    local yieldTime = delay / 20
    faderObj.fade =
        function()
            local startingVolumes = {}
            local targetVolumes = {}
            for k = 1,#musicFiles do
                if MusicManager.volumeScale == 0 then
                    startingVolumes[k] = 0
                else
                    startingVolumes[k] = MusicManager.allTracks[musicFiles[k]]:getVolume()
                end
                targetVolumes[k] = volumes[k] * MusicManager.volumeScale
                if volumes[k] > 0 then
                    MusicManager.currentTrack = musicFiles[k]
                    MusicManager.currentTrackVolume = volumes[k]
                end
                
            end
            for k2 = 1,20 do
                for k = 1,#musicFiles do
                    MusicManager.allTracks[musicFiles[k]]:setVolume(startingVolumes[k] + k2 * (targetVolumes[k] - startingVolumes[k]) / 20)
                end
                coroutine.yield(yieldTime)
            end
            faderObj:setInactive()
        end
    faderObj:startCoroutine(faderObj.fade, "fade")
end

function MusicManager.playTrack(musicFileName, volume)
    -- If a track that isn't this one is already playing, then stop it
    if MusicManager.currentTrack ~= "" and musicFileName ~= MusicManager.currentTrack then
        MusicManager.allTracks[MusicManager.currentTrack]:stop()
    end

    -- If this specific track is already playing, then just do nothing
    if not MusicManager.allTracks[musicFileName]:isPlaying() then
        volume = volume or 1
        MusicManager.currentTrackVolume = volume
        MusicManager.allTracks[musicFileName]:setVolume(volume * MusicManager.volumeScale)
        MusicManager.allTracks[musicFileName]:play()
        MusicManager.currentTrack = musicFileName 
    end
end

function MusicManager.setVolume(volume)
    MusicManager.currentTrackVolume = volume
    if MusicManager.allTracks[MusicManager.currentTrack] then
        MusicManager.allTracks[MusicManager.currentTrack]:setVolume(volume * MusicManager.volumeScale)
    end
end

function MusicManager.getVolume()
    if MusicManager.allTracks[MusicManager.currentTrack] then
        return MusicManager.allTracks[MusicManager.currentTrack]:getVolume()
    else
        print("possible music bug. returning 0 just in case")
        return 0
    end
end

function MusicManager.setVolumeScale(scale)
    MusicManager.volumeScale = scale
    MusicManager.setVolume(MusicManager.currentTrackVolume)
end

function MusicManager.stop()
    if MusicManager.currentTrack ~= "" then
        MusicManager.allTracks[MusicManager.currentTrack]:stop()
    end
end

function MusicManager.fadeOut(delay)
    local faderObj = GameObjects.newGameObject(-1,0,0,0,true)
    delay = delay or 0.5
    local yieldTime = delay / 10
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