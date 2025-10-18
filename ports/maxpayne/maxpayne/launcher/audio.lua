-- Audio manager for Max Payne launcher
local audio = {}

local MSFParser = require("msf_parser")

-- Audio configuration
local menuSounds = {
    move = 915, -- menu/move.mp3
    select = 916, -- menu/select.mp3
    slider = 917 -- menu/slidermove.mp3
}
local backgroundMusicIndex = 1359 -- wavs/max_theme_short.mp3

-- Audio state
local menuAudioSources = {}
local sharedArchive = nil
local backgroundMusic = nil

-- Ducking system
local duckingActive = false
local duckingTimer = 0
local normalVolume = 0.5
local duckedVolume = 0.2
local duckDuration = 0.8
local fadeSpeed = 2.0

-- Load shared archive once
local function loadSharedArchive()
    if not sharedArchive then
        local error
        sharedArchive, error = MSFParser.loadArchive()
    end
    return sharedArchive
end

-- Update ducking system
local function updateDucking(dt)
    if backgroundMusic then
        local targetVolume = duckingActive and duckedVolume or normalVolume
        local currentVolume = backgroundMusic:getVolume()

        if math.abs(currentVolume - targetVolume) > 0.01 then
            local newVolume = currentVolume + (targetVolume - currentVolume) * fadeSpeed * dt
            backgroundMusic:setVolume(newVolume)
        end

        if duckingActive then
            duckingTimer = duckingTimer - dt
            if duckingTimer <= 0 then
                duckingActive = false
            end
        end
    end
end

-- Duck background music temporarily
local function duckBackgroundMusic()
    duckingActive = true
    duckingTimer = duckDuration
end

-- Preload menu sounds
local function preloadMenuSounds()
    local archive = loadSharedArchive()
    if not archive then
        return
    end

    for soundType, fileIndex in pairs(menuSounds) do
        local audioSource, tempPath = MSFParser.loadAudioSource(fileIndex, "static", archive)
        if audioSource then
            menuAudioSources[soundType] = audioSource
        end
        if tempPath then
            love.filesystem.remove(tempPath)
        end
    end
end

-- Public API
function audio.initialize()
    preloadMenuSounds()
    audio.startBackgroundMusic()
end

function audio.update(dt)
    updateDucking(dt)
end

function audio.playMenuSound(soundType)
    local audioSource = menuAudioSources[soundType]
    if audioSource then
        duckBackgroundMusic()
        audioSource:stop()
        audioSource:play()
    end
end

function audio.startBackgroundMusic()
    if not backgroundMusic or not backgroundMusic:isPlaying() then
        local archive = loadSharedArchive()
        if archive then
            local tempFile = MSFParser.extractFileSimple(backgroundMusicIndex, archive)
            if tempFile then
                backgroundMusic = love.audio.newSource(tempFile, "stream")
                backgroundMusic:setLooping(true)
                backgroundMusic:setVolume(normalVolume)
                backgroundMusic:play()
            end
        end
    end
end

function audio.stopBackgroundMusic()
    if backgroundMusic then
        backgroundMusic:stop()
        backgroundMusic = nil
    end
end

function audio.cleanup()
    audio.stopBackgroundMusic()
end

return audio
