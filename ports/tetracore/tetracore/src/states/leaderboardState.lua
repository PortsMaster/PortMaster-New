local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local GameConfig = require "src.constants.gameConfig"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local asyncHttp = require "src.utils.asyncHttp"
local leaderboard = require "src.utils.leaderboard"
local json = require "libs.json"
local signal = require 'libs.signal'
local bg = require 'src.shaders.menu_bg'
local centerX = GameConfig.VIRTUAL_WIDTH / 2
local push = require "libs.push"

local keyboardText = "keyboard"
local gamepadText = "gamepad"
local labelFont = fontManager.getFont(GameConfig.FONTS.LABEL)
local keyboardTextLen = labelFont:getWidth(keyboardText)
local gamepadTextLen = labelFont:getWidth(gamepadText)

local leaderboardState = {}

local PendingState = nil

local function triggerTransition(targetState)
    if leaderboardState.isTransitioning then return end
    leaderboardState.isTransitioning = true
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
local selectedButtonIndex = 1

local scoresList = {}
local isLoading = false
local fetchError = false

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    buttons = {}

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        GameConfig.VIRTUAL_HEIGHT * 0.95,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("back"),
        function()
            soundManager.playSound("back")
            triggerTransition("menu")
        end,
        GameConfig.SCALE
    ))
    selectedButtonIndex = 1
end

function leaderboardState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    bg.init()
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    selectedButtonIndex = 1
end

function leaderboardState.enter()
    scoresList = {}
    isLoading = true
    fetchError = false

    leaderboard.fetch(function(data)
        isLoading = false
        if data then
            local decoded = json.decode(data)
            local rawList = decoded and decoded.result or decoded

            if type(rawList) == "table" then
                for i = 1, #rawList, 2 do
                    table.insert(scoresList, {
                        name = rawList[i] or "---",
                        score = rawList[i + 1] or "0"
                    })
                end
            else
                fetchError = true
            end
        else
            fetchError = true
        end
    end)

    leaderboardState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        leaderboardState.isTransitioning = false
    end)
end

function leaderboardState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local baseWidth, baseHeight = push:getDimensions()
    vWidth = baseWidth
    vHeight = baseHeight
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function leaderboardState.update(dt, guiScale)
    bg.update(dt)
    inputManager.update(dt)
    asyncHttp.update()

    local isSelectJustPressed = inputManager.isActionJustPressed("select")
    local isBackJustPressed   = inputManager.isActionJustPressed("back")

    local hoveredButton = nil
    for i, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end

    if hoveredButton ~= nil then
        selectedButtonIndex = hoveredButton
    end

    if isSelectJustPressed then
        if buttons[selectedButtonIndex] then
            buttons[selectedButtonIndex]:click()
        end
    elseif isBackJustPressed then
        soundManager.playSound("back")
        triggerTransition("menu")
    end
end

function leaderboardState.draw()
    bg.draw()
    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE))
    local title = gameState.getText("leaderboard")
    local titleW = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE) and
                        fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE):getWidth(title) or 0
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title,
        GameConfig.VIRTUAL_WIDTH / 2 - titleW / 2,
        GameConfig.VIRTUAL_HEIGHT * 0.01
    )

    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.LABEL))

    local startY = GameConfig.VIRTUAL_HEIGHT * 0.07
    local rowSpacing = 21

    if isLoading then
        love.graphics.printf("Loading...", 0, startY + 40, GameConfig.VIRTUAL_WIDTH, "center")
    elseif fetchError then
        love.graphics.printf("Failed to load scores.", 0, startY + 40, GameConfig.VIRTUAL_WIDTH, "center")
    else
        for i, entry in ipairs(scoresList) do
            local y = startY + (i - 1) * rowSpacing

            love.graphics.print(
                tostring(i) .. ".",
                GameConfig.VIRTUAL_WIDTH * 0.2,
                y
            )

            love.graphics.print(
                entry.name,
                GameConfig.VIRTUAL_WIDTH * 0.33 - keyboardTextLen / 2,
                y
            )

            love.graphics.print(
                tostring(entry.score),
                GameConfig.VIRTUAL_WIDTH * 0.66 - gamepadTextLen / 4,
                y
            )
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

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
end


return leaderboardState
