local gameState = require "src.states.gameState"
local GameConfig = require "src.constants.gameConfig"

local soundManager = {}

local musicOther = {}
local musicL1 = {}
local musicL2 = {}
local musicL3 = {}
local sounds = {}

-- Map level strings to their tables
local musicLevelTables = {
    L1 = musicL1,
    L2 = musicL2,
    L3 = musicL3,
    Other = musicOther
}

local currentMusicSource = nil
local fadingOutSource = nil
local fadeDuration = 0.8

local currentLevel = 1
local shuffleQueue = {}
local isPlaylistActive = false

-- Music track configuration with actual filenames
local musicTracks = {
    L1 = {
        g1 = "assets/music/L1/game-90.ogg",
        g2 = "assets/music/L1/game-96.ogg",
        g3 = "assets/music/L1/game-100.ogg",
        g4 = "assets/music/L1/game-104.ogg",
        g5 = "assets/music/L1/game-118.ogg",
        g6 = "assets/music/L1/game-145.ogg"
    },
    L2 = {
        g1 = "assets/music/L2/game-84.ogg",
        g2 = "assets/music/L2/game-100.ogg",
        g3 = "assets/music/L2/game-130.ogg",
        g4 = "assets/music/L2/game-142.ogg",
        g5 = "assets/music/L2/game-154.ogg"
    },
    L3 = {
        g1 = "assets/music/L3/game-110.ogg",
        g2 = "assets/music/L3/game-142.ogg",
        g3 = "assets/music/L3/game-155.ogg"
    },
    Other = {
        menu = "assets/music/menu.ogg",
        over = "assets/music/over.ogg"
    }
}

-- Sound effect configuration
local soundEffects = {
    drop = "assets/sounds/drop.ogg",
    game_over = "assets/sounds/game_over.ogg",
    hold = "assets/sounds/hold.mp3",
    clear = "assets/sounds/line_clear.wav",
    no_hold = "assets/sounds/no_hold.mp3",
    rotation = "assets/sounds/rotation.ogg",
    rotation_low = "assets/sounds/rotation_low.ogg",
    game_clear = "assets/sounds/tetris_clear.ogg",
    confirm = "assets/sounds/confirm.wav",
    back = "assets/sounds/back.wav",
    select = "assets/sounds/select.wav",
    level_up = "assets/sounds/level_up.wav"
}


-- Helper to safely get current music volume from settings or config fallback
local function getTargetMusicVolume()
    if gameState.settings and gameState.settings.musicVolume then
        return gameState.settings.musicVolume
    end
    if GameConfig.DEFAULT_SETTINGS and GameConfig.DEFAULT_SETTINGS.musicVolume then
        return GameConfig.DEFAULT_SETTINGS.musicVolume
    end
    if GameConfig.AUDIO and GameConfig.AUDIO.DEFAULT_MUSIC_VOLUME then
        return GameConfig.AUDIO.DEFAULT_MUSIC_VOLUME
    end
    return 0.7
end

-- Helper to safely get current effects volume from settings or config fallback
local function getTargetEffectsVolume()
    if gameState.settings and gameState.settings.effectsVolume then
        return gameState.settings.effectsVolume
    end
    if GameConfig.DEFAULT_SETTINGS and GameConfig.DEFAULT_SETTINGS.effectsVolume then
        return GameConfig.DEFAULT_SETTINGS.effectsVolume
    end
    if GameConfig.AUDIO and GameConfig.AUDIO.DEFAULT_EFFECTS_VOLUME then
        return GameConfig.AUDIO.DEFAULT_EFFECTS_VOLUME
    end
    return 1.0
end


function soundManager.load()
    -- Load music tracks with error handling
    for level, tracks in pairs(musicTracks) do
        local target = musicLevelTables[level]
        for trackName, filePath in pairs(tracks) do
            local source = love.audio.newSource(filePath, 'stream')
            if source then
                target[trackName] = source
            else
                if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
                    print("Warning: Failed to load music file: " .. filePath)
                end
            end
        end
    end

    -- Set looping for menu and over music
    if musicOther.menu then musicOther.menu:setLooping(true) end
    if musicOther.over then musicOther.over:setLooping(true) end

    -- Load sound effects
    for name, path in pairs(soundEffects) do
        local source = love.audio.newSource(path, 'static')
        if source then
            sounds[name] = source
        else
            if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
                print("Warning: Failed to load sound effect: " .. path)
            end
        end
    end
end


local function getPlaylistTier(level)
    if level <= 3 then
        return 1
    elseif level <= 6 then
        return 2
    else
        return 3
    end
end


local function getMusicSource(musicName)
    if musicOther[musicName] then
        return musicOther[musicName]
    end

    local tier = getPlaylistTier(currentLevel)
    if tier == 1 and musicL1[musicName] then
        return musicL1[musicName]
    elseif tier == 2 and musicL2[musicName] then
        return musicL2[musicName]
    elseif tier >= 3 and musicL3[musicName] then
        return musicL3[musicName]
    end
    return nil
end


local function replenishShuffleQueue()
    shuffleQueue = {}
    local currentLevelTracks = {}
    local tier = getPlaylistTier(currentLevel)

    if tier == 1 then
        currentLevelTracks = { "g1", "g2", "g3", "g4", "g5", "g6" }
    elseif tier == 2 then
        currentLevelTracks = { "g1", "g2", "g3", "g4", "g5" }
    else
        currentLevelTracks = { "g1", "g2", "g3" }
    end

    for _, track in ipairs(currentLevelTracks) do
        table.insert(shuffleQueue, track)
    end

    for i = #shuffleQueue, 2, -1 do
        local j = math.random(i)
        shuffleQueue[i], shuffleQueue[j] = shuffleQueue[j], shuffleQueue[i]
    end
end


function soundManager.startGameplayPlaylist(level)
    currentLevel = level or 1
    isPlaylistActive = true
    replenishShuffleQueue()

    soundManager.advancePlaylist()
end


function soundManager.advancePlaylist()
    if not isPlaylistActive then return end

    if #shuffleQueue == 0 then
        replenishShuffleQueue()
    end

    local nextTrack = table.remove(shuffleQueue)
    soundManager.playMusic(nextTrack)
end


function soundManager.updatePlaylistLevel(level)
    if currentLevel ~= level then
        currentLevel = level
    end
end


function soundManager.update(dt)
    local targetVol = getTargetMusicVolume()

    if fadingOutSource then
        local currentVol = fadingOutSource:getVolume()
        currentVol = currentVol - (targetVol / fadeDuration) * dt
        if currentVol <= 0 then
            fadingOutSource:stop()
            fadingOutSource:setVolume(targetVol)
            fadingOutSource = nil
        else
            fadingOutSource:setVolume(currentVol)
        end
    end

    if currentMusicSource and currentMusicSource:isPlaying() then
        local currentVol = currentMusicSource:getVolume()
        if currentVol < targetVol then
            currentVol = currentVol + (targetVol / fadeDuration) * dt
            if currentVol > targetVol then currentVol = targetVol end
            currentMusicSource:setVolume(currentVol)
        end
    end
end


function soundManager.updatePlaylist(gameStopped)
    if gameStopped or not isPlaylistActive then return end

    if currentMusicSource and not currentMusicSource:isLooping() and not currentMusicSource:isPlaying() and not fadingOutSource then
        soundManager.advancePlaylist()
    end
end


function soundManager.playMusic(musicName)
    local source = getMusicSource(musicName)
    if not source then return end

    if currentMusicSource == source then
        return
    end

    if currentMusicSource and currentMusicSource ~= source then
        fadingOutSource = currentMusicSource
    end

    currentMusicSource = source
    source:setVolume(0)
    source:play()
end


function soundManager.stopMusic()
    isPlaylistActive = false
    if currentMusicSource then
        fadingOutSource = currentMusicSource
        currentMusicSource = nil
    end
end


function soundManager.playSound(soundName)
    if sounds[soundName] then
        local sound = sounds[soundName]:clone()
        if sound then
            sound:setVolume(getTargetEffectsVolume())
            sound:play()
        end
    elseif GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
        print("Warning: Attempted to play unknown sound: " .. tostring(soundName))
    end
end


function soundManager.updateVolumes()
    if currentMusicSource then
        currentMusicSource:setVolume(getTargetMusicVolume())
    end
end


function soundManager.updateVolumesNow(musicVolume, effectsVolume)
    local mVol = musicVolume or getTargetMusicVolume()
    local eVol = effectsVolume or getTargetEffectsVolume()

    if currentMusicSource then
        currentMusicSource:setVolume(mVol)
    end

    for _, sound in pairs(sounds) do
        sound:setVolume(eVol)
    end
end


return soundManager
