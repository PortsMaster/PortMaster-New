-- Max Payne Launcher - Main Entry Point
local config = require("config")
local audio = require("audio")
local input = require("input")
local ui = require("ui")

-- Application state
local appState = {
    sel = 1,
    edit = false,
    message = "",
    message_t = 0,
    mode = "launcher"
}

local launcherOptions = {"Start Game", "Settings", "Controls"}

-- Utility functions
local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function setMessage(msg, time)
    appState.message = msg
    appState.message_t = time
end

-- Game control functions
local function launchGame()
    love.event.quit(0)
end

local function moveSel(delta)
    if appState.mode == "launcher" then
        appState.sel = clamp(appState.sel + delta, 1, #launcherOptions)
    elseif appState.mode == "config" then
        appState.sel = clamp(appState.sel + delta, 1, #config.getOrder())
    end
    audio.playMenuSound("move")
end

local function adjustValue(key, dir)
    local result = config.adjustValue(key, dir)
    if result == true then
        audio.playMenuSound("slider")
    elseif result == "edit" then
        appState.edit = true
    end
end

local function toggleValue(key)
    if config.toggleValue(key) then
        audio.playMenuSound("select")
    end
end

local function saveConfig()
    local msg, time = config.save()
    setMessage(msg, time)
end

local function loadConfig()
    local msg, time = config.load()
    setMessage(msg, time)
end

local function enterSettings()
    audio.playMenuSound("select")
    appState.mode = "config"
    appState.sel = 1
end

local function enterControls()
    audio.playMenuSound("select")
    appState.mode = "controls"
    appState.sel = 2
end

local function exitApp()
    love.event.quit(1)
end

local function saveAndExit()
    saveConfig()
    appState.mode = "launcher"
    appState.sel = 1
end

local function enterEdit()
    appState.edit = true
end

local function exitEdit()
    appState.edit = false
end

local function returnDefaultConfigs()
    config.returnDefaults()
    setMessage("Restored default settings", 2.0)
end

-- Love2D callbacks
function love.load()
    love.window.setTitle("Max Payne")
    love.window.setMode(640, 480, {
        resizable = true,
        vsync = 1
    })

    -- Initialize modules
    ui.initialize()
    audio.initialize()

    -- Setup input callbacks
    input.setCallbacks({
        moveSel = moveSel,
        adjustValue = adjustValue,
        launchGame = launchGame,
        enterSettings = enterSettings,
        enterControls = enterControls,
        exitApp = exitApp,
        saveAndExit = saveAndExit,
        toggleValue = toggleValue,
        saveConfig = saveConfig,
        loadConfig = loadConfig,
        enterEdit = enterEdit,
        returnDefaultConfigs = returnDefaultConfigs,
        exitEdit = exitEdit
    })

    -- Load initial config
    local msg, time = config.load()
    setMessage(msg, time)
end

function love.quit()
    audio.cleanup()
end

function love.update(dt)
    -- Store order in appState for input module
    appState.order = config.getOrder()

    input.update(dt, appState, config.getOrder())
    audio.update(dt)
    ui.updateMessage(appState, dt)
end

function love.gamepadpressed(joy, button)
    input.gamepadPressed(joy, button, appState, launcherOptions)
end

function love.gamepadreleased(joy, button)
    input.gamepadReleased(joy, button)
end

function love.keypressed(key)
    input.keyPressed(key, appState, launcherOptions)
end

function love.keyreleased(key)
    input.keyReleased(key)
end

function love.draw()
    ui.draw(appState, config, launcherOptions)
end
