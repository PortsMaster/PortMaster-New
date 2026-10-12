GameConfig = require "src.constants.gameConfig"
Socket = require "socket"
Transition = require "src.entities.transition"

local push = require "libs.push"
local crt = require 'src.shaders.crt'
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

local currentState = nil
local states = {}
local isWindowFocused = true
local skipNextFrameTime = false

function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    love.window.setTitle(GameConfig.WINDOW.TITLE)
    math.randomseed(os.time())

    gameState.load()

    push:setupScreen(
        GameConfig.VIRTUAL_WIDTH,
        GameConfig.VIRTUAL_HEIGHT,
        gameState.settings.screenSize.width,
        gameState.settings.screenSize.height,
        {
            fullscreen = false,
            resizable = GameConfig.WINDOW.RESIZABLE,
            canvas = GameConfig.CRT_ON,
            pixelperfect = false
        }
    )

    fontManager.init()
    soundManager.load()

    states.menu = require "src.states.menuState"
    states.freePlay = require "src.states.game.freePlay"
    states.over = require "src.states.gameOverState"
    states.settings = require "src.states.settingsState"
    states.controls = require "src.states.controlsState"
    states.leaderboard = require "src.states.leaderboardState"
    states.choose = require "src.states.chooseState"
    states.customPlay = require "src.states.custom.customPlay"
    states.customize = require "src.states.customizeState"

    local inputManager = require "src.utils.inputManager"
    inputManager.init()

    crt.init()

    SwitchState("menu")
end

function love.resize(w, h)
    push:resize(w, h)

    if currentState and currentState.resize then
        currentState.resize(GameConfig.VIRTUAL_WIDTH, GameConfig.VIRTUAL_HEIGHT)
    end
end

function love.update(dt)
    if not isWindowFocused then skipNextFrameTime = true return end

    if skipNextFrameTime then
        skipNextFrameTime = false
        return
    end

    if currentState and currentState.update then
        currentState.update(dt)
    end

    Transition.update(dt)

    if GameConfig.CRT_ON then
        crt.update(dt)
    end
end

function love.draw()
    if GameConfig.CRT_ON and crt and crt.draw then
        crt.draw(function()
            push:start()
                if currentState and currentState.draw then
                    currentState.draw()
                end

                Transition.draw()
            push:finish()
        end)
    else
        -- Standard rendering without shader
        push:start()
            if currentState and currentState.draw then
                currentState.draw()
            end

            Transition.draw()
        push:finish()
    end
end

function love.focus(f)
    isWindowFocused = f
end

local currentStateName = "menu"

function love.textinput(t)
    if currentState and currentState.textinput then
        currentState.textinput(t)
    end
end

function love.keypressed(key)
    if currentState and currentState.keypressed then
        currentState.keypressed(key)
    end
end

function love.keyreleased(key)
    if currentState and currentState.keyreleased then
        currentState.keyreleased(key)
    end
end

function love.gamepadpressed(joystick, button)
    if currentState and currentState.gamepadpressed then
        currentState.gamepadpressed(joystick, button)
    end
end

function love.gamepadreleased(joystick, button)
    if currentState and currentState.gamepadreleased then
        currentState.gamepadreleased(joystick, button)
    end
end


function SwitchState(stateName)
    local oldStateName = currentStateName
    local oldState = currentState

    if states[stateName] then
        if oldState and oldState.exit then
            oldState.exit()
        end

        if (stateName == "menu" or stateName == "settings") and (oldStateName ~= "menu" and oldStateName ~= "settings") then
            soundManager.playMusic("menu")
        elseif stateName == "freePlay" and (oldStateName == "menu" or oldStateName == "settings") then
            soundManager.stopMusic()
        end

        local targetState = states[stateName]
        currentState = targetState
        currentStateName = stateName

        if targetState.init and not targetState.initialized then
            targetState.init(GameConfig.VIRTUAL_WIDTH, GameConfig.VIRTUAL_HEIGHT)
            targetState.initialized = true
        end

        if targetState.enter then
            targetState.enter()
        end
    else
        error("No state with name: " .. stateName)
    end
end

function GetCurrentStateName()
    return currentStateName
end

love.SwitchState = SwitchState
love.getCurrentStateName = GetCurrentStateName
