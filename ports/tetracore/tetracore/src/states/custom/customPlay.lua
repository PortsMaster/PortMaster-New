local signal = require 'libs.signal'
local Shape = require 'src.entities.shape'
local collision = require 'libs.collision'
local input = require 'src.states.game.input'
local play = require 'src.states.custom.play'
local pause = require 'src.states.game.pause'
local draw = require 'src.states.game.draw'
local soundManager = require 'src.utils.soundManager'
local fontManager = require 'src.utils.fontManager'
local gameState = require 'src.states.gameState'
local fireflies = require 'src.entities.fireflies'
local parts = require 'src.entities.particles'
local barkFontFile = 'assets/fonts/ease.ttf'
local barkFont = love.graphics.newFont(barkFontFile, 24)
local barkChance = 1.0
local Transition = require "src.entities.transition"

local customPlay = {}

local pendingSettings = {
    speedUpEnabled = false,
    speedLevelStart = 1,
    speedLevelLength = 60
}

local function triggerTransition(targetState)
    if customPlay.isTransitioning then return end
    customPlay.isTransitioning = true
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

customPlay.initialized = false
customPlay.activeBarks = {}


function customPlay.init()
	customPlay.spawnBoxes = {
		{x = 80, y = 220, w = 40, h = 40}, -- left
		{x = 520, y = 220, w = 40, h = 40}, -- right
		{x = 300, y = 0, w = 40, h = 40}, -- top
		{x = 300, y = 440, w = 40, h = 40}, -- bottom
	}

    customPlay.initialized = true
end


function customPlay.enter()
    customPlay.bg = require 'src.shaders.bg1'
    customPlay.bg.init()

    customPlay.speedUpEnabled = pendingSettings.speedUpEnabled
    customPlay.speedLevelStart = pendingSettings.speedLevelStart
    customPlay.speedLevelLength = pendingSettings.speedLevelLength

    customPlay.speedLevel = customPlay.speedLevelStart
    customPlay.levelTimer = customPlay.speedLevelLength

    fireflies.init()
    customPlay.stop = false
    customPlay.roundLost = false
    customPlay.roundTimer = 0
    customPlay.roundScore = 0
    customPlay.overSfxPlayed = false
    customPlay.paused = false
    customPlay.lostTimer = 3.0
    customPlay.shaderTime = 0
    customPlay.spawnTimer = 0
    customPlay.moveTimer = 0.6
    customPlay.spawnInterval = 6.0
    customPlay.maxLevel = 15

    for i = 2, customPlay.speedLevel do
        if customPlay.moveTimer > 0.20 then
            customPlay.moveTimer = customPlay.moveTimer - 0.05
        end
        if customPlay.spawnInterval > 2.0 then
            customPlay.spawnInterval = customPlay.spawnInterval - 0.5
        end
    end

    customPlay.speedUpTimer = 0
    customPlay.ringsCleared = 0
    customPlay.fallSpeedUp = false
    customPlay.fallSpeedModifier = 10
    customPlay.multiplier = 1
    customPlay.multiplierTimer = 10.0
    customPlay.multiplierTimerMax = 10.0

    customPlay.centerShape = {}
    customPlay.movingShapes = {}
    customPlay.nextShape = nil
    customPlay.clearingQueue = {}
    customPlay.clearTimer = 0
    customPlay.clearDelay = 0.02
    customPlay.flashTimer = 0
    customPlay.activeBarks = {}
    customPlay.pushTimer = 0
    customPlay.pushDuration = 0.6
    customPlay.pushMaxDistance = 8
    customPlay.pushDirX = 0
    customPlay.pushDirY = 0
    customPlay.coreBounceTimer = 0
    customPlay.coreBounceScale = 1.0
    customPlay.coreBounceMaxScale = 1.0

    soundManager.startGameplayPlaylist(customPlay.speedLevel)

    local ts = GameConfig.PLAY_CONSTANTS.TILE_SIZE
    local startX = math.floor((GameConfig.PLAY_CONSTANTS.CENTER_X - ts / 2) / ts) * ts
    local startY = math.floor((GameConfig.PLAY_CONSTANTS.CENTER_Y - ts / 2) / ts) * ts

    local firstShape = Shape({x = startX, y = startY}, 0, 7)
    table.insert(customPlay.centerShape, firstShape)
    customPlay.prepareNextShape(customPlay)
    customPlay.spawnNewShape(customPlay, true)

    customPlay.isTransitioning = true
    Transition.fadeIn(0.5, function()
        customPlay.isTransitioning = false
    end)
end


function customPlay.triggerImpact(direction, movingShape)
    customPlay.pushTimer = customPlay.pushDuration
    local center = customPlay.centerShape[1]

    customPlay.coreBounceTimer = 0.2
    customPlay.coreBounceMaxScale = 1.0 + (0.02 * customPlay.speedLevel)
    customPlay.coreBounceScale = 1.0

    if movingShape then
        movingShape.bounceTimer = 0.2
        movingShape.bounceMaxScale = 1.0 + (0.02 * customPlay.speedLevel)
        movingShape.bounceScale = 1.0
    end

    if direction == 1 then
        customPlay.pushDirX, customPlay.pushDirY = 1, 0
    elseif direction == 2 then
        customPlay.pushDirX, customPlay.pushDirY = -1, 0
    elseif direction == 3 then
        customPlay.pushDirX, customPlay.pushDirY = 0, 1
    elseif direction == 4 then
        customPlay.pushDirX, customPlay.pushDirY = 0, -1
    else
        customPlay.pushDirX, customPlay.pushDirY = 0, 0
    end
end


function customPlay.prepareNextShape(g)
    local randIndex = math.random(1, 4)
    local box = g.spawnBoxes[randIndex]
    local randImgInd = math.random(1, 6)
    local ts = GameConfig.PLAY_CONSTANTS.TILE_SIZE

    local tempShape = Shape({x = 0, y = 0, direction = 0}, 0, randImgInd)
    local minX, maxX, minY, maxY = 0, 0, 0, 0
    if tempShape.tiles and #tempShape.tiles > 0 then
        minX, minY = tempShape.tiles[1].localX, tempShape.tiles[1].localY
        maxX, maxY = minX + ts, minY + ts

        for i = 2, #tempShape.tiles do
            local tx = tempShape.tiles[i].localX
            local ty = tempShape.tiles[i].localY
            if tx < minX then minX = tx end
            if tx + ts > maxX then maxX = tx + ts end
            if ty < minY then minY = ty end
            if ty + ts > maxY then maxY = ty + ts end
        end
    end

    local shapeW = maxX - minX
    local shapeH = maxY - minY

    local centerX = box.x + (box.w - shapeW) / 2
    local centerY = box.y + (box.h - shapeH) / 2

    local snappedX = math.floor((centerX / ts) + 0.5) * ts
    local snappedY = math.floor((centerY / ts) + 0.5) * ts

    g.nextShapeData = {
        x = snappedX,
        y = snappedY,
        direction = randIndex,
        ii = randImgInd
    }
end


function customPlay.spawnNewShape(g, isInitialSpawn)
    if g.nextShapeData then
        local data = g.nextShapeData
        local newShape = Shape({x = data.x, y = data.y, direction = data.direction}, g.moveTimer, data.ii)
        table.insert(g.movingShapes, newShape)
    end

    g.prepareNextShape(g)

    if not isInitialSpawn then
        g.spawnTimer = g.spawnTimer - customPlay.spawnInterval
    end
end


function customPlay.triggerBark(linesCleared)
    if not linesCleared or linesCleared <= 1 then return end

    local text = ""
    if linesCleared == 2 then
        text = "NICE!"
    elseif linesCleared == 3 then
        text = "INSANE!"
    elseif linesCleared >= 4 then
        text = "KILLER!"
    end

    if math.random() <= barkChance then
        local directionY = math.random() > 0.5 and -1 or 1
        local panelX = 1984
        local panelWidth = 2560 - 1984
        local textWidth = barkFont:getWidth(text)
        local startX = panelX + (panelWidth - textWidth) / 2
        local startY = (GameConfig.VIRTUAL_HEIGHT or 1440) / 2 - (barkFont:getHeight() / 2)

        table.insert(customPlay.activeBarks, {
            text = text,
            x = startX,
            y = startY,
            dirY = directionY,
            timer = 2.5
        })
    end
end


function customPlay.update(dt)
    customPlay.bg.update(dt)
    soundManager.update(dt)
    fireflies.update(dt, customPlay.speedLevel)
    parts.update(dt)
    soundManager.updatePlaylistLevel(customPlay.speedLevel)
    soundManager.updatePlaylist(customPlay.stop)

    if customPlay.isTransitioning then return end

    if customPlay.paused then
        pause.update(dt)
        customPlay.updatePhantom()
        return
    end

    if customPlay.pushTimer > 0 then
        customPlay.pushTimer = customPlay.pushTimer - dt

        local t = 1 - (customPlay.pushTimer / customPlay.pushDuration)
        local easeOut = 1 - ((1 - t) ^ 3)
        local currentDistance = math.sin(easeOut * math.pi) * customPlay.pushMaxDistance

        customPlay.pushX = customPlay.pushDirX * currentDistance
        customPlay.pushY = customPlay.pushDirY * currentDistance

        if customPlay.pushTimer <= 0 then
            customPlay.pushX = 0
            customPlay.pushY = 0
            customPlay.pushDirX = 0
            customPlay.pushDirY = 0
        end
    else
        customPlay.pushX = 0
        customPlay.pushY = 0
    end

    if customPlay.coreBounceTimer > 0 then
        customPlay.coreBounceTimer = customPlay.coreBounceTimer - dt
        local totalDuration = 0.2
        local progress = 1 - (customPlay.coreBounceTimer / totalDuration)
        local scaleAmount = (customPlay.coreBounceMaxScale - 1.0)
        if progress < 0.5 then
            customPlay.coreBounceScale = 1.0 + progress * 2 * scaleAmount
        else
            customPlay.coreBounceScale = customPlay.coreBounceMaxScale - (progress - 0.5) * 2 * scaleAmount
        end
        if customPlay.coreBounceTimer <= 0 then
            customPlay.coreBounceScale = 1.0
        end
    end

    if customPlay.roundLost then
        customPlay.updatePhantom()
        return
    end

    if not customPlay.stop then
        local activeDt = customPlay.fallSpeedUp and (dt * customPlay.fallSpeedModifier) or dt
        play.update(customPlay, dt)
        if #customPlay.movingShapes > 0 then
            customPlay.movingShapes[1]:update(activeDt)
        end

        for i = #customPlay.activeBarks, 1, -1 do
            local b = customPlay.activeBarks[i]
            b.timer = b.timer - dt
            b.y = b.y + (b.dirY * 40 * dt)
            if b.timer <= 0 then
                table.remove(customPlay.activeBarks, i)
            end
        end
    end

    if not customPlay.stop and collision.checkBounds(customPlay.centerShape) then
        customPlay.failingBounds = true
    end

    if not customPlay.stop and not customPlay.failingBounds then
        input.update(customPlay, dt)
    end

    if customPlay.failingBounds then
        local core = customPlay.centerShape[1]
        local isRotating = core and math.abs(core.rotOffset or 0) > 0.001

        if not isRotating then
            customPlay.stop = true
            soundManager.stopMusic()

            if not customPlay.overSfxPlayed then
                soundManager.playSound('game_over')
                customPlay.overSfxPlayed = true
            end

            signal.emit('ringsCleared', customPlay.ringsCleared)
            signal.emit('Level', customPlay.speedLevel)
            signal.emit('roundScore', customPlay.roundScore)

            customPlay.lostTimer = customPlay.lostTimer - dt
            if customPlay.lostTimer <= 0 then
                customPlay.roundLost = true
                triggerTransition("over")
                customPlay.initialized = false
                customPlay.failingBounds = false
            end
        end
    end

    customPlay.updatePhantom()
end


function customPlay.updatePhantom()
    customPlay.phantomShape = nil
    if #customPlay.movingShapes == 0 or customPlay.stop or customPlay.roundLost then return end

    local active = customPlay.movingShapes[1]
    local phantom = Shape({x = active.x, y = active.y, direction = active.direction}, 0, 10)

    phantom.tiles = {}
    for _, tile in ipairs(active.tiles) do
        table.insert(phantom.tiles, { localX = tile.localX, localY = tile.localY })
    end

    local stepX, stepY = 0, 0
    if phantom.direction == 1 then stepX = GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif phantom.direction == 2 then stepX = -GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif phantom.direction == 3 then stepY = GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif phantom.direction == 4 then stepY = -GameConfig.PLAY_CONSTANTS.TILE_SIZE
    end

    local maxSteps = 30
    for _ = 1, maxSteps do
        phantom.x = phantom.x + stepX
        phantom.y = phantom.y + stepY

        local hit = false
        local phantomBoxes = phantom:getCollisionBoxes()

        for _, centerShape in ipairs(customPlay.centerShape) do
            local centerBoxes = centerShape:getCollisionBoxes()
            for _, pBox in ipairs(phantomBoxes) do
                for _, cBox in ipairs(centerBoxes) do
                    if collision.check(cBox, pBox) then
                        hit = true
                        break
                    end
                end
                if hit then break end
            end
            if hit then break end
        end

        if hit then
            phantom.x = phantom.x - stepX
            phantom.y = phantom.y - stepY
            customPlay.phantomShape = phantom
            break
        end
    end
end


function customPlay.draw()
    draw.draw(customPlay, fontManager, gameState, barkFont, Shape, pause)
end


function customPlay.exit()
    soundManager.stopMusic()
    customPlay.centerShape = {}
    customPlay.movingShapes = {}
    customPlay.nextShapeData = nil
    customPlay.spawnTimer = 0
    customPlay.roundLost = false
    customPlay.activeBarks = {}
    collectgarbage("collect")
end


signal.register("pause_enter", function() pause.enter() end)
signal.register("pause_exit", function() customPlay.paused = false end)
    signal.register("speed_up_toggled", function(enabled)
        pendingSettings.speedUpEnabled = enabled
    end)
    signal.register("speed_level_start_changed", function(value)
        pendingSettings.speedLevelStart = value
    end)
    signal.register("speed_level_length_changed", function(value)
        pendingSettings.speedLevelLength = value
    end)
return customPlay
