local Button = require "src.ui.button"
local Slider = require "src.ui.slider"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local bg = require 'src.shaders.menu_bg'
local signal = require "libs.signal"
local push = require "libs.push"
local settingsText = gameState.getText("customize")
local titleFont = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE)

local customizeState = {}
local speedUpEnabled = true

local PendingState = nil

local function triggerTransition(targetState)
    if customizeState.isTransitioning then return end
    customizeState.isTransitioning = true
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

local buttons = {}
local sliders = {}
local virtualWidth = GameConfig.VIRTUAL_WIDTH
local virtualHeight = GameConfig.VIRTUAL_HEIGHT
local currentGuiScale = 1

function customizeState.recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local baseWidth, baseHeight = push:getDimensions()
    virtualWidth = baseWidth or vWidth
    virtualHeight = baseHeight or vHeight
    currentGuiScale = guiScale

    local centerX = virtualWidth / 2
    local buttonWidth = GameConfig.MENU.BUTTON_WIDTH
    local buttonHeight = GameConfig.MENU.BUTTON_HEIGHT
    local sliderWidth = GameConfig.MENU.BUTTON_WIDTH * 1.5
    local sliderHeight = GameConfig.UI.SLIDER.TRACK_HEIGHT or 20

    buttons = {}
    sliders = {}

    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2 - 50,
        virtualHeight / 2 - 120 - buttonHeight / 2,
        buttonWidth + 100,
        buttonHeight,
        gameState.getText(speedUpEnabled and "Speed Up On" or "Speed Up Off"),
        function()
            speedUpEnabled = not speedUpEnabled
            buttons[1].text = gameState.getText(speedUpEnabled and "Speed Up On" or "Speed Up Off")
            sliders[2].disabled = not speedUpEnabled

            if not speedUpEnabled and customizeState.selectedElement 
               and customizeState.selectedElement.type == "slider" 
               and customizeState.selectedElement.index == 2 then
                customizeState.selectedElement = {type = "slider", index = 1}
            end

            soundManager.playSound("confirm")
        end,
        currentGuiScale
    ))

    table.insert(sliders, Slider.new(
        centerX - sliderWidth / 2,
        virtualHeight / 2 - 60,
        sliderWidth,
        sliderHeight,
        1, --min
        15, --max
        1, --default value
        "Speed Level Start:",
        function(newValue)
            newValue = math.floor(newValue + 0.5)
        end,
        currentGuiScale,
        false
    ))

    table.insert(sliders, Slider.new(
        centerX - sliderWidth / 2,
        virtualHeight / 2,
        sliderWidth,
        sliderHeight,
        1, --min
        120, --max
        60, --default value
        "Speed Level Length:",
        function(newValue)
            newValue = math.floor(newValue + 0.5)
        end,
        currentGuiScale,
        false
    ))
    sliders[2].disabled = not speedUpEnabled

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH - GameConfig.MENU.BUTTON_SPACING * 3,
        virtualHeight - GameConfig.MENU.BUTTON_HEIGHT * 4,
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            if customizeState.isTransitioning then return end
            soundManager.playSound("back")
            triggerTransition("menu")
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX + GameConfig.MENU.BUTTON_SPACING * 3,
        virtualHeight - GameConfig.MENU.BUTTON_HEIGHT * 4,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("play"),
        function()
            local speedLevelStart = sliders[1].value
            local speedLevelLength = sliders[2].value

            signal.emit("speed_up_toggled", speedUpEnabled)
            signal.emit("speed_level_start_changed", speedLevelStart)
            signal.emit("speed_level_length_changed", speedLevelLength)

            triggerTransition("customPlay")
        end,
        currentGuiScale
    ))
end

function customizeState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    bg.init()
    customizeState.recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    customizeState.selectedElement = {type = "button", index = 1}
end

function customizeState.enter()
    customizeState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        customizeState.isTransitioning = false
    end)
end

function customizeState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local baseWidth, baseHeight = push:getDimensions()
    virtualWidth = baseWidth
    virtualHeight = baseHeight
    customizeState.recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

function customizeState.update(dt, guiScale)
    bg.update(dt)
    inputManager.update(dt)

    if not customizeState.selectedElement then
        customizeState.selectedElement = {type = "button", index = 1}
    end

    for i, slider in ipairs(sliders) do
        slider:update(dt, guiScale)
    end

    local hoveredButton = nil
    for i, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end

    if hoveredButton ~= nil then
        customizeState.selectedElement = {type = "button", index = hoveredButton}
    end

    if customizeState.selectedElement.type == "slider" then
        local slider = sliders[customizeState.selectedElement.index]
        if slider and not slider.disabled then
            if inputManager.isActionPressedForMenu("left") then
                local newValue = slider.value - 1
                if newValue < slider.min then newValue = slider.min end
                slider:setValue(newValue)
            elseif inputManager.isActionPressedForMenu("right") then
                local newValue = slider.value + 1
                if newValue > slider.max then newValue = slider.max end
                slider:setValue(newValue)
            end
        end
    end

    local selectedChanged = false

    if inputManager.isActionJustPressed("up") then
        if customizeState.selectedElement.type == "button" then
            if customizeState.selectedElement.index == 1 then
                customizeState.selectedElement = {type = "button", index = 2}
                selectedChanged = true
            elseif customizeState.selectedElement.index == 2 or customizeState.selectedElement.index == 3 then
                customizeState.selectedElement = {type = "slider", index = speedUpEnabled and 2 or 1}
                selectedChanged = true
            end
        elseif customizeState.selectedElement.type == "slider" then
            if customizeState.selectedElement.index == 1 then
                customizeState.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            elseif customizeState.selectedElement.index == 2 then
                customizeState.selectedElement = {type = "slider", index = 1}
                selectedChanged = true
            end
        end

    elseif inputManager.isActionJustPressed("down") then
        if customizeState.selectedElement.type == "button" then
            if customizeState.selectedElement.index == 1 then
                customizeState.selectedElement = {type = "slider", index = 1}
                selectedChanged = true
            elseif customizeState.selectedElement.index == 2 or customizeState.selectedElement.index == 3 then
                customizeState.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            end
        elseif customizeState.selectedElement.type == "slider" then
            if customizeState.selectedElement.index == 1 then
                if speedUpEnabled then
                    customizeState.selectedElement = {type = "slider", index = 2}
                else
                    customizeState.selectedElement = {type = "button", index = 2}
                end
                selectedChanged = true
            elseif customizeState.selectedElement.index == 2 then
                customizeState.selectedElement = {type = "button", index = 2}
                selectedChanged = true
            end
        end

    elseif inputManager.isActionJustPressed("left") then
        if customizeState.selectedElement.type == "button" and customizeState.selectedElement.index == 3 then
            customizeState.selectedElement = {type = "button", index = 2}
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("right") then
        if customizeState.selectedElement.type == "button" and customizeState.selectedElement.index == 2 then
            customizeState.selectedElement = {type = "button", index = 3}
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("select") then
        if customizeState.selectedElement.type == "button" then
            buttons[customizeState.selectedElement.index]:click()
        end
    elseif inputManager.isActionJustPressed("back") then
        if not customizeState.isTransitioning then
            soundManager.playSound("back")
            triggerTransition("menu")
        end
    end

    if selectedChanged then
        soundManager.playSound("select")
        if customizeState.selectedElement.type == "button" then
            local targetButton = buttons[customizeState.selectedElement.index]
            if targetButton then
                targetButton:pulse()
            end
        end
    end
end

function customizeState.draw()
    bg.draw()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)

    local titleW = titleFont and titleFont:getWidth(settingsText) or 0
    love.graphics.print(settingsText, virtualWidth / 2 - titleW / 2,
                        virtualHeight * 0.01)

    for i, slider in ipairs(sliders) do
        if customizeState.selectedElement and customizeState.selectedElement.type == "slider" and customizeState.selectedElement.index == i then
            slider.highlighted = true
        end
        slider:draw()
        if customizeState.selectedElement and customizeState.selectedElement.type == "slider" and customizeState.selectedElement.index == i then
            slider.highlighted = false
        end
    end

    for i, button in ipairs(buttons) do
        if customizeState.selectedElement and customizeState.selectedElement.type == "button" and customizeState.selectedElement.index == i then
            local originalHoverColor = button.hoverColor
            button.hoverColor = GameConfig.UI.BUTTON.HOVER_COLOR
            button.hovered = true
            button:draw()
            button.hoverColor = originalHoverColor
            button.hovered = false
        else
            button:draw()
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end


return customizeState
