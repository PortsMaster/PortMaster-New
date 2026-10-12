local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local bg = require 'src.shaders.menu_bg'
local signal = require "libs.signal"
local chooseText = gameState.getText("mode")
local titleFont = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE)

local chooseState = {}

local PendingState = nil

local function triggerTransition(targetState)
    if chooseState.isTransitioning then return end
    chooseState.isTransitioning = true
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
local virtualWidth = GameConfig.VIRTUAL_WIDTH
local virtualHeight = GameConfig.VIRTUAL_HEIGHT
local currentGuiScale = 1

function chooseState.recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    virtualWidth = vWidth or GameConfig.VIRTUAL_WIDTH
    virtualHeight = vHeight or GameConfig.VIRTUAL_HEIGHT
    currentGuiScale = guiScale or 1

    local centerX = virtualWidth / 2
    local buttonWidth = GameConfig.MENU.BUTTON_WIDTH
    local buttonHeight = GameConfig.MENU.BUTTON_HEIGHT
    local spacing = GameConfig.MENU.BUTTON_SPACING or (buttonHeight + 20)

    local totalButtons = 3 
    local totalHeight = (totalButtons * buttonHeight) + ((totalButtons - 1) * spacing)
    local startY = (virtualHeight - totalHeight) / 2

    buttons = {}

    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        startY,
        buttonWidth,
        buttonHeight,
        gameState.getText("marathon"),
        function()
            triggerTransition("freePlay")
            soundManager.playSound("confirm")
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        startY + buttonHeight + spacing,
        buttonWidth,
        buttonHeight,
        gameState.getText("custom"),
        function()
            if chooseState.isTransitioning then return end
            soundManager.playSound('confirm')
            triggerTransition("customize")
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        startY + (buttonHeight + spacing) * 2,
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            if chooseState.isTransitioning then return end
            soundManager.playSound('back')
            triggerTransition("menu")
        end,
        currentGuiScale
    ))
end

function chooseState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    bg.init()
    chooseState.recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    chooseState.selectedElement = {type = "button", index = 1}
end

function chooseState.enter()
    chooseState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        chooseState.isTransitioning = false
    end)
end

function chooseState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    virtualWidth = vWidth or GameConfig.VIRTUAL_WIDTH
    virtualHeight = vHeight or GameConfig.VIRTUAL_HEIGHT
    chooseState.recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

function chooseState.update(dt, guiScale)
    bg.update(dt)
    inputManager.update(dt)

    for _, button in ipairs(buttons) do
        button.hovered = false
        button:update(dt, guiScale)
    end

    local selectedChanged = false

    if inputManager.isActionJustPressed("up") then
        chooseState.selectedElement.index = chooseState.selectedElement.index - 1
        if chooseState.selectedElement.index < 1 then
            chooseState.selectedElement.index = #buttons
        end
        selectedChanged = true

    elseif inputManager.isActionJustPressed("down") then
        chooseState.selectedElement.index = chooseState.selectedElement.index + 1
        if chooseState.selectedElement.index > #buttons then
            chooseState.selectedElement.index = 1
        end
        selectedChanged = true

    elseif inputManager.isActionJustPressed("select") then
        if chooseState.selectedElement.type == "button" then
            buttons[chooseState.selectedElement.index]:click()
        end
    elseif inputManager.isActionJustPressed("back") then
        if not chooseState.isTransitioning then
            soundManager.playSound("back")
            triggerTransition("menu")
        end
    end

    if selectedChanged then
        soundManager.playSound("select")
        if chooseState.selectedElement.type == "button" then
            local targetButton = buttons[chooseState.selectedElement.index]
            if targetButton then
                targetButton:pulse()
            end
        end
    end
end

function chooseState.draw()
    bg.draw()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)

	local titleW = titleFont and titleFont:getWidth(chooseText) or 0
    love.graphics.print(chooseText, virtualWidth / 2 - titleW / 2,
                        GameConfig.VIRTUAL_HEIGHT * 0.01)

    for i, button in ipairs(buttons) do
        if chooseState.selectedElement and chooseState.selectedElement.type == "button" and chooseState.selectedElement.index == i then
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


return chooseState
