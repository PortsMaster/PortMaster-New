local SaveLoad = {}
local json = require("ThirdParty.json.json")
-- Preferences like screenshake, volume, etc
local preferencesFileName = "preferences.json"
local controlsPreferencesFileName = "controlsPreferences.json"
-- All machine-specific perferences
local videoPreferencesFileName = "videoPreferences.json"
-- Actual game-related data
local gameDataFileName = "savedGameData.json"
function SaveLoad.savePreferences()
    if web then
        return
    end
    -- Save all persistent preferences like screenshake, etc
    local preferences = {
        soundVolumeScale = SoundManager.volumeScale,
        musicVolumeScale = MusicManager.volumeScale,
        gamePreferences = gamePreferences
    }
    local prefJson = json.encode(preferences)
    love.filesystem.write(preferencesFileName, prefJson)
    -- Save controls
    local controlsPreferences = {
        currentMapping = Input.mappings,
        numInConfig = #Input.currentConfig,
        allKeys = Input.allKeys,
        allGamepadButtons = Input.allGamepadButtons
    }
    local controlsPrefJson = json.encode(controlsPreferences)
    love.filesystem.write(controlsPreferencesFileName, controlsPrefJson)
    -- Save preferences that only persist on this machine
    local isFullScreen, fullscreenMode = love.window.getFullscreen()
    local videoPreferences = {
        isFullScreen = isFullScreen,
        fullscreenMode = fullscreenMode,
        vsync = love.window.getVSync(),
        resizeMode = resizeMode
    }
    local videoPrefJson = json.encode(videoPreferences)
    love.filesystem.write(videoPreferencesFileName, videoPrefJson)
end

function SaveLoad.loadPreferences()
    if web then
        return
    end
    if love.filesystem.getInfo(preferencesFileName) then
        local prefJson = love.filesystem.read(preferencesFileName)
        local prefDeserialized = json.decode(prefJson)
        -- set globals
        if prefDeserialized.soundVolumeScale then
            SoundManager.setVolumeScale(prefDeserialized.soundVolumeScale)
        end
        if prefDeserialized.musicVolumeScale then
            MusicManager.setVolumeScale(prefDeserialized.musicVolumeScale)
        end
        if prefDeserialized.gamePreferences then
            for key,value in pairs(gamePreferences) do
                if prefDeserialized.gamePreferences[key] ~= nil then
                    gamePreferences[key] = prefDeserialized.gamePreferences[key]
                end
            end
        end
    end

    if love.filesystem.getInfo(controlsPreferencesFileName) then
        local prefJson = love.filesystem.read(controlsPreferencesFileName)
        local prefDeserialized = json.decode(prefJson)
        if prefDeserialized.currentMapping and prefDeserialized.numInConfig and prefDeserialized.allKeys and prefDeserialized.allGamepadButtons then
            -- Add a key mapping for any keys that were saved but not mapped by default
            for k = 1,#prefDeserialized.allKeys do
                if not Input.isKeyMapped(prefDeserialized.allKeys[k], false) then
                    Input.addKeyMapping(prefDeserialized.allKeys[k], false)
                end
            end
            for k = 1,#prefDeserialized.allGamepadButtons do
                if not Input.isKeyMapped(prefDeserialized.allGamepadButtons[k], true) then
                    Input.addKeyMapping(prefDeserialized.allGamepadButtons[k], true)
                end
            end
            -- Build up a mapping of keys from the saved mappings
            local loadedMappings = {}
            local kInd = 1
            for buttonName,buttonContents in pairs(prefDeserialized.currentMapping) do
                loadedMappings[kInd] = {}
                loadedMappings[kInd].buttonName = buttonName
                loadedMappings[kInd].keyboard = buttonContents.keyboard
                loadedMappings[kInd].gamepad = buttonContents.gamepad
                kInd = kInd + 1
            end
            -- Map the loaded inputs
            Input.map(loadedMappings, false)
        end
    end

    if love.filesystem.getInfo(videoPreferencesFileName) then
        local prefJson = love.filesystem.read(videoPreferencesFileName)
        local prefDeserialized = json.decode(prefJson)
        if prefDeserialized.resizeMode then
            resizeMode = prefDeserialized.resizeMode
        end
        if prefDeserialized.isFullScreen ~= false then
            if prefDeserialized.fullscreenMode then
                setFullscreen(true, prefDeserialized.fullscreenMode)
            else
                setFullscreen(true)
            end
        else
            resizeWindow(windowWidth, windowHeight)
        end
        if prefDeserialized.vsync then
            love.window.setVSync(prefDeserialized.vsync)
        end
    else
        setFullscreen(true)
    end
end

function SaveLoad.saveGameData()
    if web then
        return
    end
    local gameData = {
        gameSaveData = gameSaveData
    }
    local gameDataJSON = json.encode(gameData)
    love.filesystem.write(gameDataFileName, gameDataJSON)
end

function SaveLoad.loadGameData()
    if web then
        return
    end
    if love.filesystem.getInfo(gameDataFileName) then
        local gameDataRaw = love.filesystem.read(gameDataFileName)
        local gameData = json.decode(gameDataRaw)
        if gameData.gameSaveData then
            for key,value in pairs(gameSaveData) do
                if gameData.gameSaveData[key] ~= nil then
                    gameSaveData[key] = gameData.gameSaveData[key]
                end
            end
        end
    end
end

return SaveLoad