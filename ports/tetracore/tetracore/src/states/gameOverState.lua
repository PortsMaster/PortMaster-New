local signal = require 'libs.signal'
local soundManager = require "src.utils.soundManager"
local fontManager = require "src.utils.fontManager"
local textFont = fontManager.getFont(32)
local inputManager = require "src.utils.inputManager"
local gameState = require "src.states.gameState"
local Button = require "src.ui.button"
local highScoreFontFile = 'assets/fonts/ease.ttf'
local highScoreFont = love.graphics.newFont(highScoreFontFile, 48)
local asyncHttp = require "src.utils.asyncHttp"
local leaderboard = require "src.utils.leaderboard"
local fireflies = require 'src.entities.fireflies'
local push = require "libs.push"

local game_over = {}

local PendingState = nil

local function triggerTransition(targetState)
    if game_over.isTransitioning then return end
    game_over.isTransitioning = true
    PendingState = targetState

    soundManager.playSound('confirm')
    Transition.play(0.5)

    signal.register('Transition_finished', function()
        signal.remove('Transition_finished')
        if PendingState then
            love.SwitchState(PendingState)
            PendingState = nil
        end
    end)
end

game_over.initialized = false
game_over.ringsCleared = 0
game_over.level = 1
game_over.score = 0
game_over.buttons = {}
game_over.selectedButton = 1
game_over.submissionStatus = ""

game_over.isEnteringName = false
game_over.playerName = "PLAYER"
game_over.maxNameLen = 12
game_over.keyboardRow = 1
game_over.keyboardCol = 1

game_over.inputCooldown = 0
local currentGuiScale = 1
local virtualWidth = GameConfig.VIRTUAL_WIDTH
local virtualHeight = GameConfig.VIRTUAL_HEIGHT

local virtualKeys = {
    { "A", "B", "C", "D", "E", "F", "G" },
    { "H", "I", "J", "K", "L", "M", "N" },
    { "O", "P", "Q", "R", "S", "T", "U" },
    { "V", "W", "X", "Y", "Z", "0", "1" },
    { "2", "3", "4", "5", "6", "7", "8" },
    { "9", "DEL" }
}

local function handleNameKeyInput(key)
    if key == "DEL" or key == "backspace" then
        if #game_over.playerName > 0 then
            game_over.playerName = game_over.playerName:sub(1, -2)
            soundManager.playSound("select")
        end
    else
        if #game_over.playerName < game_over.maxNameLen then
            game_over.playerName = game_over.playerName .. key
            soundManager.playSound("select")
        end
    end
end

local function submitScoreAction()
    soundManager.playSound("confirm")
    gameState.settings.playerName = game_over.playerName
    gameState.saveSettings()
    game_over.processScoreSubmission()
end

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local baseWidth, baseHeight = push:getDimensions()
    virtualWidth = baseWidth or vWidth or GameConfig.VIRTUAL_WIDTH
    virtualHeight = baseHeight or vHeight or GameConfig.VIRTUAL_HEIGHT
    currentGuiScale = guiScale or 1

    game_over.buttons = {}
    table.insert(game_over.buttons, Button.new(
        virtualWidth * 0.5 - (GameConfig.MENU.BUTTON_WIDTH * 1.5),
        virtualHeight * 0.8,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("tryAgain") or "Try Again",
        function()
            triggerTransition("freePlay")
        end,
        currentGuiScale,
        true
    ))
    table.insert(game_over.buttons, Button.new(
        virtualWidth * 0.5 + (GameConfig.MENU.BUTTON_WIDTH / 2),
        virtualHeight * 0.8,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("mainMenu") or "Main Menu",
        function()
            triggerTransition("menu")
        end,
        currentGuiScale,
        true
    ))
end

function game_over.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    game_over.initialized = true
    fireflies.init()
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function game_over.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function game_over.enter()
    GameConfig.PLAY_CONSTANTS.SCORE = game_over.score
    game_over.isNewHighScore = false
    game_over.isNewRingsCleared = false
    game_over.submissionStatus = ""
    game_over.inputCooldown = 0
    soundManager.playMusic('over')
    game_over.selectedButton = 1

    game_over.playerName = gameState.settings.playerName or "PLAYER"

    if game_over.score > GameConfig.PLAY_CONSTANTS.HIGH_SCORE then
        game_over.isNewHighScore = true
        GameConfig.PLAY_CONSTANTS.HIGH_SCORE = game_over.score
        gameState.settings.highScore = game_over.score
        gameState.saveSettings()
    end

    if game_over.ringsCleared > GameConfig.PLAY_CONSTANTS.RINGS_CLEARED then
        game_over.isNewRingsCleared = true
        GameConfig.PLAY_CONSTANTS.RINGS_CLEARED = game_over.ringsCleared
        gameState.settings.ringsCleared = game_over.ringsCleared
        gameState.saveSettings()
    end

    if game_over.score > 0 then
        game_over.submissionStatus = "Checking leaderboard..."
        leaderboard.count(function(totalEntries)
            if totalEntries < 20 then
                game_over.isEnteringName = true
                inputManager.setEnabled(false)
                game_over.submissionStatus = "Enter Your Name!"
            else
                leaderboard.getLowestScore(function(minScore)
                    if game_over.score > minScore then
                        game_over.isEnteringName = true
                        inputManager.setEnabled(false)
                        game_over.submissionStatus = "New High Score! Enter Name"
                    else
                        game_over.submissionStatus = "Score Did Not Qualify for Top 20"
                    end
                end)
            end
        end)
    end
    game_over.isTransitioning = true
    Transition.fadeIn(0.5, function()
        game_over.isTransitioning = false
    end)
end

function game_over.processScoreSubmission()
    game_over.isEnteringName = false
    inputManager.setEnabled(true)
    game_over.inputCooldown = 0.3

    game_over.submissionStatus = "Submitting score..."
    local finalName = game_over.playerName
    if finalName == "" then finalName = "ANONYMOUS" end

    leaderboard.submit(finalName, game_over.score, false, function(success)
        if success then
            game_over.submissionStatus = "Score Leaderboard Sync: OK"
        else
            game_over.submissionStatus = "Leaderboard Sync Failed"
        end
    end)
end

function game_over.update(dt)
    inputManager.update(dt)
    soundManager.update(dt)
    asyncHttp.update()
    fireflies.update(dt, 1)

    if game_over.inputCooldown > 0 then
        game_over.inputCooldown = game_over.inputCooldown - dt
    end
    for i, button in ipairs(game_over.buttons) do
        button:update(dt, currentGuiScale)
    end
    if game_over.isEnteringName then
        if game_over.inputCooldown <= 0 then
            local maxRow = #virtualKeys

            if inputManager.isActionJustPressed("up") then
                game_over.keyboardRow = math.max(1, game_over.keyboardRow - 1)
                soundManager.playSound("select")
                game_over.inputCooldown = 0.15
            elseif inputManager.isActionJustPressed("down") then
                game_over.keyboardRow = math.min(maxRow, game_over.keyboardRow + 1)
                soundManager.playSound("select")
                game_over.inputCooldown = 0.15
            elseif inputManager.isActionJustPressed("left") then
                game_over.keyboardCol = math.max(1, game_over.keyboardCol - 1)
                soundManager.playSound("select")
                game_over.inputCooldown = 0.15
            elseif inputManager.isActionJustPressed("right") then
                game_over.keyboardCol = game_over.keyboardCol + 1
                soundManager.playSound("select")
                game_over.inputCooldown = 0.15
            elseif inputManager.isActionJustPressed("start") then
                submitScoreAction()
                game_over.inputCooldown = 0.2
            elseif inputManager.isActionJustPressed("select") then
                local selectedKey = virtualKeys[game_over.keyboardRow][game_over.keyboardCol]
                if selectedKey then
                    if selectedKey == "DEL" then
                        handleNameKeyInput("DEL")
                    else
                        handleNameKeyInput(selectedKey)
                    end
                end
                game_over.inputCooldown = 0.2
            elseif inputManager.isActionJustPressed("back") then
                handleNameKeyInput("DEL")
                game_over.inputCooldown = 0.2
            end

            game_over.keyboardCol = math.min(game_over.keyboardCol, #virtualKeys[game_over.keyboardRow])
        end
        return
    end

    local hoveredButton = nil

    if hoveredButton ~= nil then
        if game_over.selectedButton ~= hoveredButton then
            game_over.selectedButton = hoveredButton
        end
    end

    if game_over.inputCooldown <= 0 then
        local selectedChanged = false

        if inputManager.isActionJustPressed("left") or inputManager.isActionJustPressed("right") or inputManager.isActionJustPressed("up") or inputManager.isActionJustPressed("down") then
            game_over.selectedButton = game_over.selectedButton == 1 and 2 or 1
            selectedChanged = true
            game_over.inputCooldown = 0.15
        elseif inputManager.isActionJustPressed("select") then
            if game_over.buttons[game_over.selectedButton] then
                soundManager.playSound("confirm")
                game_over.buttons[game_over.selectedButton].callback()
            end
        end

        if selectedChanged then
            soundManager.playSound("select")
            game_over.buttons[game_over.selectedButton]:pulse()
        end
    end
end

function game_over.draw()
    love.graphics.setFont(textFont)
    fireflies.draw()

    local textRingsCleared = gameState.getText("ringsCleared") or "Rings Cleared"
    local textLevel = gameState.getText("level") or "Level"
    local textScore = gameState.getText("score") or "Score"

    love.graphics.setFont(highScoreFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("GAME OVER", 0, -5, virtualWidth, 'center')
    love.graphics.setFont(textFont)

    if game_over.isEnteringName then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("ENTER YOUR NAME:", 0, 47, virtualWidth, 'center')

        local boxWidth = virtualWidth * 0.5
        local boxHeight = 40
        local boxX = (virtualWidth - boxWidth) / 2
        local boxY = 85

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)

        love.graphics.printf(game_over.playerName .. "_", 0, boxY-1, virtualWidth, 'center')

        local keyW = 45
        local keyH = 35
        local gap = 6
        local startY = 135

        for r, row in ipairs(virtualKeys) do
            local totalRowWidth = 0
            for _, key in ipairs(row) do
                if key == "DEL" then
                    totalRowWidth = totalRowWidth + (keyW * 1.5 + gap)
                else
                    totalRowWidth = totalRowWidth + (keyW + gap)
                end
            end
            totalRowWidth = totalRowWidth - gap

            local currentX = (virtualWidth - totalRowWidth) / 2
            local y = startY + (r - 1) * (keyH + gap)

            for c, key in ipairs(row) do
                local isSelected = (r == game_over.keyboardRow and c == game_over.keyboardCol)

                local currentKeyW = keyW
                if key == "DEL" then
                    currentKeyW = keyW * 1.5
                end

                if isSelected then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.rectangle("fill", currentX, y, currentKeyW, keyH)
                    love.graphics.setColor(0, 0, 0, 1)
                else
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", currentX, y, currentKeyW, keyH)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", currentX, y, currentKeyW, keyH)
                end

                love.graphics.printf(key, currentX, y - 4, currentKeyW, "center")
                currentX = currentX + currentKeyW + gap
            end
        end

        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("PRESS START / ENTER TO SUBMIT", 0, 420, virtualWidth, 'center')

    else
        local scoreY = 100
        local ringsY = 150
        local levelY = 200
        local statusY = 250

        local scoreText = textScore .. ': ' .. game_over.score
        if game_over.isNewHighScore then
            scoreText = scoreText .. "    NEW BEST!"
            love.graphics.setColor(1, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.printf(scoreText, 0, scoreY, virtualWidth, 'center')

        local ringsText = textRingsCleared .. ': ' .. game_over.ringsCleared
        if game_over.isNewRingsCleared then
            ringsText = ringsText .. "    NEW BEST!"
            love.graphics.setColor(1, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.printf(ringsText, 0, ringsY, virtualWidth, 'center')

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(textLevel .. ': ' .. game_over.level, 0, levelY, virtualWidth, 'center')

        if game_over.submissionStatus ~= "" then
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.printf(game_over.submissionStatus, 0, statusY, virtualWidth, 'center')
        end

        love.graphics.setColor(1, 1, 1, 1)
        for i, button in ipairs(game_over.buttons) do
            if game_over.selectedButton ~= nil and i == game_over.selectedButton then
                button.hovered = true
            end

            button:draw()

            if game_over.selectedButton ~= nil and i == game_over.selectedButton then
                button.hovered = false
            end
        end
    end
end

function game_over.keypressed(key)
    if not game_over.isEnteringName then return end

    local maxRow = #virtualKeys

    if key == "up" then
        game_over.keyboardRow = math.max(1, game_over.keyboardRow - 1)
        soundManager.playSound("select")
    elseif key == "down" then
        game_over.keyboardRow = math.min(maxRow, game_over.keyboardRow + 1)
        soundManager.playSound("select")
    elseif key == "left" then
        game_over.keyboardCol = math.max(1, game_over.keyboardCol - 1)
        soundManager.playSound("select")
    elseif key == "right" then
        game_over.keyboardCol = game_over.keyboardCol + 1
        soundManager.playSound("select")
    elseif key == "return" then
        submitScoreAction()
    elseif key == "x" then
        local selectedKey = virtualKeys[game_over.keyboardRow][game_over.keyboardCol]
        if selectedKey then
            if selectedKey == "DEL" then
                handleNameKeyInput("DEL")
            else
                handleNameKeyInput(selectedKey)
            end
        end
    elseif key == "z" or key == "backspace" then
        handleNameKeyInput("DEL")
    end

    game_over.keyboardCol = math.min(game_over.keyboardCol, #virtualKeys[game_over.keyboardRow])
end

function game_over.gamepadpressed(joystick, button)
    if not game_over.isEnteringName then return end

    local maxRow = #virtualKeys

    if button == "dpup" then
        game_over.keyboardRow = math.max(1, game_over.keyboardRow - 1)
        soundManager.playSound("select")
    elseif button == "dpdown" then
        game_over.keyboardRow = math.min(maxRow, game_over.keyboardRow + 1)
        soundManager.playSound("select")
    elseif button == "dpleft" then
        game_over.keyboardCol = math.max(1, game_over.keyboardCol - 1)
        soundManager.playSound("select")
    elseif button == "dpright" then
        game_over.keyboardCol = game_over.keyboardCol + 1
        soundManager.playSound("select")
    elseif button == "start" then
        submitScoreAction()
    elseif button == "a" then
        local selectedKey = virtualKeys[game_over.keyboardRow][game_over.keyboardCol]
        if selectedKey then
            if selectedKey == "DEL" then
                handleNameKeyInput("DEL")
            else
                handleNameKeyInput(selectedKey)
            end
        end
    elseif button == "b" then
        handleNameKeyInput("DEL")
    end

    game_over.keyboardCol = math.min(game_over.keyboardCol, #virtualKeys[game_over.keyboardRow])
end

function game_over.exit()
    inputManager.setEnabled(true)
    soundManager.stopMusic()
end

signal.register('ringsCleared', function(ringsCleared)
    game_over.ringsCleared = ringsCleared
end)
signal.register('Level', function(level)
    game_over.level = level
end)
signal.register('roundScore', function(score)
    game_over.score = score
end)


return game_over
