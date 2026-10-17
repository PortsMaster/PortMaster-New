local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local gameState = require "src.states.gameState"
local signal = require 'libs.signal'
local Button = require "src.ui.button"
local Slider = require "src.ui.slider"
local push = require "libs.push"

local pause = {}
local PendingState = nil

local function triggerTransition(targetState)
    if pause.isTransitioning then return end
    pause.isTransitioning = true
    PendingState = targetState

    Transition.play(0.5)

    signal.register('Transition_finished', function()
        signal.remove('Transition_finished')
        if PendingState then
            love.SwitchState(PendingState)
            PendingState = nil
        end
    end)
end

pause.buttons = {}
pause.sliders = {}
pause.tempSettings = {}
pause.originalSettings = {}
pause.selectedElement = {type = "slider", index = 1}

local function deepcopy(orig)
    local origType = type(orig)
    local copy
    if origType == 'table' then
        copy = {}
        for origKey, origValue in pairs(orig) do
            copy[deepcopy(origKey)] = deepcopy(origValue)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local virtW, virtH = push:getDimensions()
    GameConfig.VIRTUAL_WIDTH = virtW or vWidth or GameConfig.VIRTUAL_WIDTH
    GameConfig.VIRTUAL_HEIGHT = virtH or vHeight or GameConfig.VIRTUAL_HEIGHT
    GameConfig.SCALE = guiScale or 1

    local centerX = GameConfig.VIRTUAL_WIDTH / 2
    local startY = GameConfig.VIRTUAL_HEIGHT * GameConfig.SETTINGS.START_Y_OFFSET + (GameConfig.VIRTUAL_HEIGHT / 5)
    local spacing = GameConfig.VIRTUAL_HEIGHT * GameConfig.SETTINGS.SPACING_OFFSET

    local controlWidth = GameConfig.VIRTUAL_WIDTH * GameConfig.SETTINGS.CONTROL_WIDTH_RATIO
    local buttonSpacing = GameConfig.MENU.BUTTON_SPACING * 1.25

    pause.buttons = {}
    pause.sliders = {}

    table.insert(pause.sliders, Slider.new(
        centerX - controlWidth / 2,
        startY + (GameConfig.VIRTUAL_WIDTH * 0.04),
        controlWidth,
        10,
        0, 1,
        pause.tempSettings.musicVolume,
        gameState.getText("musicVolume"),
        function(value)
            pause.tempSettings.musicVolume = value
        end,
        GameConfig.SCALE
    ))

    table.insert(pause.sliders, Slider.new(
        centerX - controlWidth / 2,
        startY + spacing,
        controlWidth,
        10,
        0, 1,
        pause.tempSettings.effectsVolume,
        gameState.getText("effectsVolume"),
        function(value)
            pause.tempSettings.effectsVolume = value
        end,
        GameConfig.SCALE
    ))

    table.insert(pause.buttons, Button.new(
        centerX - (GameConfig.MENU.BUTTON_WIDTH * 1.5) - buttonSpacing * 2,
        GameConfig.VIRTUAL_HEIGHT * 0.8,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("apply"),
        function()
            soundManager.playSound('confirm')
            gameState.settings = deepcopy(pause.tempSettings)
            gameState.applyPauseSettings()
            soundManager.updateVolumes()
            pause.originalSettings = deepcopy(gameState.settings)
        end,
        GameConfig.SCALE,
        true
    ))

    table.insert(pause.buttons, Button.new(
        centerX + (GameConfig.MENU.BUTTON_WIDTH / 2) + buttonSpacing * 2,
        GameConfig.VIRTUAL_HEIGHT * 0.8,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("mainMenu"),
        function()
        		soundManager.stopMusic()
            triggerTransition("menu")
            soundManager.playSound('back')
        end,
        GameConfig.SCALE,
        true
    ))
end

function pause.enter()
    pause.isTransitioning = false
    pause.originalSettings = deepcopy(gameState.settings)
    pause.tempSettings = deepcopy(gameState.settings)
    pause.selectedElement = {type = "slider", index = 1}
    recalculateLayout(GameConfig.VIRTUAL_WIDTH, GameConfig.VIRTUAL_HEIGHT, GameConfig.SCALE, 0, 0)
end

function pause.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function pause.update(dt)
    inputManager.update(dt)

    if pause.selectedElement.type == "slider" then
        local slider = pause.sliders[pause.selectedElement.index]
        if slider then
            local range = (slider.max or 1) - (slider.min or 0)
            local step = range / GameConfig.SETTINGS.SLIDER_STEP_DIVISOR
            if inputManager.isActionPressedForMenu("left") or inputManager.isActionJustPressed("left") then
                slider:setValue(slider.value - step)
            elseif inputManager.isActionPressedForMenu("right") or inputManager.isActionJustPressed("right") then
                slider:setValue(slider.value + step)
            end
        end
    end

    for i, button in ipairs(pause.buttons) do
        button:update(dt, GameConfig.SCALE)
    end
    for _, slider in ipairs(pause.sliders) do
        slider:update(dt, GameConfig.SCALE)
    end

    local selectedChanged = false

    if inputManager.isActionJustPressed("up") then
        if pause.selectedElement.type == "slider" then
            if pause.selectedElement.index == 2 then
                pause.selectedElement.index = 1
                selectedChanged = true
            elseif pause.selectedElement.index == 1 then
                pause.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            end
        elseif pause.selectedElement.type == "button" then
            pause.selectedElement = {type = "slider", index = 2}
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("down") then
        if pause.selectedElement.type == "slider" then
            if pause.selectedElement.index == 1 then
                pause.selectedElement.index = 2
                selectedChanged = true
            elseif pause.selectedElement.index == 2 then
                pause.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            end
        elseif pause.selectedElement.type == "button" then
            pause.selectedElement = {type = "slider", index = 1}
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("left") then
        if pause.selectedElement.type == "button" then
            if pause.selectedElement.index == 2 then
                pause.selectedElement.index = 1
                selectedChanged = true
            end
        end

    elseif inputManager.isActionJustPressed("right") then
        if pause.selectedElement.type == "button" then
            if pause.selectedElement.index == 1 then
                pause.selectedElement.index = 2
                selectedChanged = true
            end
        end

    elseif inputManager.isActionJustPressed("pause") then
        soundManager.updateVolumesNow(pause.originalSettings.musicVolume, pause.originalSettings.effectsVolume)
        signal.emit("pause_exit")

    elseif inputManager.isActionJustPressed("select") then
        if pause.selectedElement.type == "button" and pause.buttons[pause.selectedElement.index] then
            pause.buttons[pause.selectedElement.index].callback()
        end
    end

    if selectedChanged then
        soundManager.playSound("select")
        if pause.selectedElement.type == "button" then
            pause.buttons[pause.selectedElement.index]:pulse()
        end
    end
end

function pause.draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, GameConfig.VIRTUAL_WIDTH, GameConfig.VIRTUAL_HEIGHT)

    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Paused", 0, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.TITLE_Y_OFFSET, GameConfig.VIRTUAL_WIDTH, "center")

    for i, slider in ipairs(pause.sliders) do
        if pause.selectedElement and pause.selectedElement.type == "slider" and pause.selectedElement.index == i then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("fill", slider.x - 32, slider.y + 2, 18, 4)
        end
        slider:draw()
    end

    for i, button in ipairs(pause.buttons) do
        if pause.selectedElement and pause.selectedElement.type == "button" and pause.selectedElement.index == i then
            button.hovered = true
        end

        button:draw()

        if pause.selectedElement and pause.selectedElement.type == "button" and pause.selectedElement.index == i then
            button.hovered = false
        end
    end
end


return pause
