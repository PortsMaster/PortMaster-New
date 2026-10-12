local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local bg = require 'src.shaders.menu_bg'
local centerX = GameConfig.VIRTUAL_WIDTH / 2
local signal = require 'libs.signal'
local push = require "libs.push"

local controlsState = {}

local PendingState = nil

local function triggerTransition(targetState)
    if controlsState.isTransitioning then return end
    controlsState.isTransitioning = true
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
local controlButtons = {}

local waitingForInput = false
local currentBindingDevice = nil
local currentBindingAction = nil

local remappingCooldown = 0
local remappingCooldownTime = 0.25

local bindableActions = {
    "up",
    "down",
    "left",
    "right",
    "pause",
    "rotateCore",
    "rotateShape",
    "speedUp",
}

local selectedButtonIndex = 1

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local startY = GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.START_Y_OFFSET + 32
    local spacing = GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.SPACING_OFFSET

    buttons = {}
    controlButtons = {}

    -- Gamepad buttons column
    for i, action in ipairs(bindableActions) do
        local padBtn = Button.new(
            centerX + 16,
            startY + spacing * i,
            GameConfig.MENU.BUTTON_WIDTH,
            GameConfig.MENU.BUTTON_HEIGHT,
            inputManager.getBindingText("gamepad", action),
            function()
                waitingForInput = true
                currentBindingDevice = "gamepad"
                currentBindingAction = action
                soundManager.playSound("confirm")
            end,
            GameConfig.SCALE
        )
        padBtn.actionType = action
        padBtn.deviceType = "gamepad"
        table.insert(controlButtons, padBtn)
    end

    local utilityButtons = {}

    -- Back button aligned with bindable actions column
    table.insert(utilityButtons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH - 16,
        GameConfig.VIRTUAL_HEIGHT * 0.88,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("back"),
        function()
            soundManager.playSound("back")
            triggerTransition("settings")
        end,
        GameConfig.SCALE
    ))

    -- Reset button aligned with gamepad buttons column
    table.insert(utilityButtons, Button.new(
        centerX + 16,
        GameConfig.VIRTUAL_HEIGHT * 0.88,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("reset"),
        function()
            soundManager.playSound("confirm")
            inputManager.resetToDefaults()
            for _, btn in ipairs(controlButtons) do
                if btn.deviceType and btn.actionType then
                    btn.text = inputManager.getBindingText(btn.deviceType, btn.actionType)
                end
            end
            love.graphics.present()
        end,
        GameConfig.SCALE
    ))

    for _, btn in ipairs(controlButtons) do
        table.insert(buttons, btn)
    end
    for _, btn in ipairs(utilityButtons) do
        table.insert(buttons, btn)
    end

    if selectedButtonIndex > #buttons then
        selectedButtonIndex = 1
    end
end

function controlsState.enter()
    controlsState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        controlsState.isTransitioning = false
    end)
end

function controlsState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    bg.init()
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    waitingForInput = false
    currentBindingDevice = nil
    currentBindingAction = nil
    selectedButtonIndex = 1
    remappingCooldown = 0
end

function controlsState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local baseWidth, baseHeight = push:getDimensions()
    vWidth = baseWidth
    vHeight = baseHeight
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function controlsState.update(dt, guiScale)
    bg.update(dt)
    inputManager.update(dt)

    local hoveredButton = nil
    for _, button in ipairs(buttons) do
        button.hovered = false
        button:update(dt, guiScale)
    end

    if hoveredButton ~= nil then
        selectedButtonIndex = hoveredButton
    end

    if remappingCooldown > 0 then
        remappingCooldown = remappingCooldown - dt
        if remappingCooldown <= 0 then
            remappingCooldown = 0
        end
        return
    end

    if waitingForInput then
        return
    end

    local selectedChanged = false
    
    if inputManager.isActionJustPressed("up") then
        if selectedButtonIndex > 1 and selectedButtonIndex <= 8 then
            selectedButtonIndex = selectedButtonIndex - 1
            selectedChanged = true
        elseif selectedButtonIndex == 1 then
            selectedButtonIndex = 9
            selectedChanged = true
        elseif selectedButtonIndex == 9 or selectedButtonIndex == 10 then
            selectedButtonIndex = 8
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("down") then
        if selectedButtonIndex >= 1 and selectedButtonIndex < 8 then
            selectedButtonIndex = selectedButtonIndex + 1
            selectedChanged = true
        elseif selectedButtonIndex == 8 then
            selectedButtonIndex = 9
            selectedChanged = true
        elseif selectedButtonIndex == 9 or selectedButtonIndex == 10 then
            selectedButtonIndex = 1
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("left") then
        if selectedButtonIndex == 10 then
            selectedButtonIndex = 9
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("right") then
        if selectedButtonIndex == 9 then
            selectedButtonIndex = 10
            selectedChanged = true
        end

    elseif inputManager.isActionJustPressed("select") then
        if buttons[selectedButtonIndex] then
            buttons[selectedButtonIndex]:click()
        end
    elseif inputManager.isActionJustPressed("back") then
        soundManager.playSound("back")
        triggerTransition("settings")
    end

    if selectedChanged then
        soundManager.playSound("select")
        buttons[selectedButtonIndex]:pulse()
    end
end

function controlsState.draw()
    bg.draw()
    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE))
    local title = gameState.getText("controls")
    local titleW = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE) and
                     fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE):getWidth(title) or 0
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title,
        GameConfig.VIRTUAL_WIDTH / 2 - titleW / 2,
        GameConfig.VIRTUAL_HEIGHT * 0.01
    )

    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.LABEL))

    local startY = GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.START_Y_OFFSET + 32
    local spacing = GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.SPACING_OFFSET

    love.graphics.setColor(1, 1, 1, 1)
    for i, action in ipairs(bindableActions) do
        local actionY = startY + spacing * i
        local actionText = gameState.getText(action)
        
        local font = fontManager.getFont(GameConfig.FONTS.LABEL)
        local fontHeight = font and font:getHeight() or 16
        local textY = actionY + (GameConfig.MENU.BUTTON_HEIGHT - fontHeight) / 2

        love.graphics.print(
            actionText,
            centerX - GameConfig.MENU.BUTTON_WIDTH - 16,
            textY
        )
    end

    for i, button in ipairs(buttons) do
        local isSelected = (i == selectedButtonIndex)

        if isSelected then
            button.hovered = true
        end

        button:draw()

        if isSelected then
            button.hovered = false
        end
    end

    if waitingForInput then
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", -8, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.MODAL_Y_RATIO, GameConfig.VIRTUAL_WIDTH + 8, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.MODAL_HEIGHT_RATIO)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", -8, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.MODAL_Y_RATIO, GameConfig.VIRTUAL_WIDTH + 16, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.MODAL_HEIGHT_RATIO)
        love.graphics.setLineWidth(1)

        love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.LABEL))
        local promptText = "Press any button on gamepad..."
        local promptHeight = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE) and fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE):getHeight() or 0

        love.graphics.printf(
            promptText,
            0,
            GameConfig.VIRTUAL_HEIGHT / 2 - promptHeight / 2,
            GameConfig.VIRTUAL_WIDTH, "center"
        )
    end
end

function controlsState.gamepadpressed(joystick, button)
    if waitingForInput and currentBindingDevice == "gamepad" then
        inputManager.setBinding("gamepad", currentBindingAction, button)

        for _, btn in ipairs(controlButtons) do
            if btn.deviceType == "gamepad" and btn.actionType == currentBindingAction then
                btn.text = inputManager.getBindingText("gamepad", currentBindingAction)
            end
        end

        waitingForInput = false
        soundManager.playSound("confirm")
        remappingCooldown = remappingCooldownTime
    end
end

return controlsState