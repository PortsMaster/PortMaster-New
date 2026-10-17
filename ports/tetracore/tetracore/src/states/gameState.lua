local love = require("love")
local GameConfig = require("src.constants.gameConfig")
local localization = require("src.utils.localization")
local crt = require("src.shaders.crt")
local push = require("libs.push")

local gameState = {}

gameState.settings = GameConfig.DEFAULT_SETTINGS
gameState.screenSizes = GameConfig.SCREEN_SIZES


local function isPushInitialized()
    return push._WWIDTH ~= nil
end


function gameState.getAvailableLanguages()
    return localization.getAvailableLanguages()
end


function gameState.getText(key)
    return localization.getText(key, gameState.settings.language) or key
end


function gameState.isRTL()
    return localization.isRTL(gameState.settings.language)
end


function SerializeTable(val, indent)
    indent = indent or ""
    local result

    if type(val) == "table" then
        result = "{\n"
        for k, v in pairs(val) do
            local keyStr
            if type(k) == "string" then
                -- Escape quotes directly instead of calling SerializeTable recursively
                keyStr = "[\"" .. string.gsub(k, "\"", "\\\"") .. "\"]"
            elseif type(k) == "number" or type(k) == "boolean" then
                keyStr = "[" .. tostring(k) .. "]"
            else
                keyStr = "[\"" .. tostring(k) .. "\"]"
            end

            result = result .. indent .. "    " .. keyStr .. " = " .. SerializeTable(v, indent .. "    ") .. ",\n"
        end
        result = result .. indent .. "}"
    elseif type(val) == "string" then
        result = "\"" .. string.gsub(val, "\"", "\\\"") .. "\""
    elseif type(val) == "number" or type(val) == "boolean" then
        result = tostring(val)
    elseif val == nil then
        result = "nil"
    else
        result = "\"" .. tostring(val) .. "\""
    end

    return result
end


function gameState.save()
    local serialized = "return " .. SerializeTable(gameState.settings)

    local path = love.filesystem.getSaveDirectory()
    if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
        print("Saving settings to: " .. path .. "/settings.lua")
    end

    local success = love.filesystem.write("settings.lua", serialized)
    if not success then
        if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
            print("Error: Failed to write settings to file")
        end
    else
        if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
            print("Settings saved successfully!")
        end
    end
end


function gameState.saveSettings()
    gameState.save()
end


function gameState.load()
    if love.filesystem.getInfo("settings.lua") then
        local status, loadedSettings = pcall(function()
            local chunk = love.filesystem.load("settings.lua")
            if chunk then
                return chunk()
            end
            return nil
        end)

        if status and type(loadedSettings) == "table" then
            for k, v in pairs(loadedSettings) do
                if gameState.settings[k] ~= nil then
                    if k == "screenSize" and type(v) == "table" then
                        if v.width and v.height then
                            gameState.settings.screenSize.width = v.width
                            gameState.settings.screenSize.height = v.height
                        end
                    else
                        gameState.settings[k] = v
                    end
                end
            end

            if gameState.settings.crtOn ~= nil then
                GameConfig.CRT_ON = gameState.settings.crtOn
            end

            if not localization.languages[gameState.settings.language] then
                if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
                    print("Warning: Invalid language setting detected, resetting to English")
                end
                gameState.settings.language = "en"
            end

            gameState.applySettings()

        else
            local errorMsg = type(loadedSettings) == "string" and loadedSettings or "Unknown error"
            if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
                print("Error: Failed to load settings. " .. errorMsg)
            end
            love.filesystem.remove("settings.lua")
        end

        if gameState.settings.highScore then
            GameConfig.PLAY_CONSTANTS.HIGH_SCORE = gameState.settings.highScore
        end
        if gameState.settings.ringsCleared then
            GameConfig.PLAY_CONSTANTS.RINGS_CLEARED = gameState.settings.ringsCleared
        end

    elseif love.filesystem.getInfo("settings.json") then
        if GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
            print("Found legacy settings.json. Migrating to new format...")
        end
        love.filesystem.remove("settings.json")
    end
end

function gameState.applySettings(forceWindowRebuild)
    local w = gameState.settings.screenSize.width
    local h = gameState.settings.screenSize.height

    local currentW, currentH = love.graphics.getDimensions()
    local resChanged = (w ~= currentW or h ~= currentH)

    if forceWindowRebuild or resChanged then
        local desktopW, desktopH = love.window.getDesktopDimensions()
        local exceedsDesktop = (w > desktopW) or (h > desktopH)

        local isFullscreen = gameState.settings.fullscreen
        if exceedsDesktop then
            isFullscreen = true
        end

        push:setupScreen(
            GameConfig.VIRTUAL_WIDTH,
            GameConfig.VIRTUAL_HEIGHT,
            w,
            h,
            {
                fullscreen = isFullscreen,
                resizable = true,
                vsync = true
            }
        )

        if gameState.settings.crtOn ~= nil then
            GameConfig.CRT_ON = gameState.settings.crtOn
            if crt and crt.init then
                crt.init(gameState.settings.crtOn)
            end
        end

        if love.resize then
            love.resize(love.graphics.getWidth(), love.graphics.getHeight())
        end
    else
        if gameState.settings.crtOn ~= nil then
            GameConfig.CRT_ON = gameState.settings.crtOn
            if crt and crt.toggle then
                crt.toggle(gameState.settings.crtOn)
            end
        end
    end

    gameState.save()
end

function gameState.applyPauseSettings()
    local targetW = gameState.settings.screenSize.width
    local targetH = gameState.settings.screenSize.height

    if isPushInitialized() then
        push:resize(targetW, targetH)
    end

    if crt and crt.resize then
        crt.resize(targetW, targetH)
    end

    gameState.save()
end

return gameState
