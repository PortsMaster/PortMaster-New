local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local bg = require 'src.shaders.menu_bg'
local titleFontFile = 'assets/fonts/ease.ttf'
local asyncHttp = require "src.utils.asyncHttp"
local titleFont = love.graphics.newFont(titleFontFile, 64)
local signal = require 'libs.signal'
local push = require "libs.push"

local menuState = {}

local function triggerTransition(targetState)
    if menuState.isTransitioning then return end
    menuState.isTransitioning = true
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

local function recalculateLayout()
    local centerX = GameConfig.VIRTUAL_WIDTH / 2
    local centerY = GameConfig.VIRTUAL_HEIGHT / 2

    buttons = {}

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        centerY - GameConfig.MENU.BUTTON_SPACING * 2 - GameConfig.MENU.BUTTON_HEIGHT * 2,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("play"),
        function()
            menuState.playButtonClicked = true
            soundManager.playSound("confirm")
        end,
        GameConfig.SCALE,
        true
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        centerY - GameConfig.MENU.BUTTON_SPACING - GameConfig.MENU.BUTTON_HEIGHT,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("settings"),
        function()
            triggerTransition("settings")
            soundManager.playSound("confirm")
        end,
        GameConfig.SCALE,
        true
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        centerY,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("leaderboard"),
        function()
            triggerTransition("leaderboard")
            soundManager.playSound("confirm")
        end,
        GameConfig.SCALE,
        true
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        centerY + GameConfig.MENU.BUTTON_HEIGHT + GameConfig.MENU.BUTTON_SPACING,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("quit"),
        function()
            love.event.quit()
        end,
        GameConfig.SCALE,
        true
    ))
end

function menuState.init()
    bg.init()
    recalculateLayout()
    soundManager.playMusic("menu")
    menuState.selectedButton = 1
    menuState.leaderboardRequest = nil
    menuState.leaderboardData = nil
    menuState.showLeaderboard = false
end

function menuState.resize()
    recalculateLayout()
end

function menuState.enter()
    menuState.playButtonClicked = false
    menuState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        menuState.isTransitioning = false
    end)
end

function menuState.update(dt)
    bg.update(dt)
    inputManager.update(dt)
    soundManager.update(dt)
    asyncHttp.update()

    local hoveredButton = nil
    for i, button in ipairs(buttons) do
        button:update(dt)
    end

    if hoveredButton ~= nil then
        if menuState.selectedButton ~= hoveredButton then
            menuState.selectedButton = hoveredButton
        end
    end

    if menuState.selectedButton == nil then
        if inputManager.isActionJustPressed("up") or inputManager.isActionJustPressed("down") or inputManager.isActionJustPressed("select") then
            menuState.selectedButton = 1
        end
    end

    local selectedButtonChanged = false
    if inputManager.isActionJustPressed("up") then
        if menuState.selectedButton == nil then
            menuState.selectedButton = 1
        else
            menuState.selectedButton = menuState.selectedButton - 1
        end
        selectedButtonChanged = true
    elseif inputManager.isActionJustPressed("down") then
        if menuState.selectedButton == nil then
            menuState.selectedButton = 1
        else
            menuState.selectedButton = menuState.selectedButton + 1
        end
        selectedButtonChanged = true
    end

    if menuState.selectedButton ~= nil then
        if menuState.selectedButton < 1 then
            menuState.selectedButton = #buttons
        elseif menuState.selectedButton > #buttons then
            menuState.selectedButton = 1
        end
    end

    if selectedButtonChanged then
        soundManager.playSound("select")
        if buttons[menuState.selectedButton] then
            buttons[menuState.selectedButton]:pulse()
        end
    end

    if inputManager.isActionJustPressed("select") and menuState.selectedButton ~= nil then
        if buttons[menuState.selectedButton] and buttons[menuState.selectedButton].callback then
            buttons[menuState.selectedButton].callback()
        end
    end

    if menuState.playButtonClicked then
        soundManager.stopMusic()
        triggerTransition("choose")
    end
end

function menuState.draw()
    bg.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(titleFont)
    love.graphics.printf(gameState.getText("title"), 0, GameConfig.VIRTUAL_HEIGHT * GameConfig.CONTROLS.TITLE_Y_OFFSET,
                         GameConfig.VIRTUAL_WIDTH, "center")
    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.BUTTON))

    for i, button in ipairs(buttons) do
        if menuState.selectedButton ~= nil and i == menuState.selectedButton then
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
end


return menuState
