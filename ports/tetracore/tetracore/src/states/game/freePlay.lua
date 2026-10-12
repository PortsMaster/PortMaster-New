local signal = require 'libs.signal'
local Shape = require 'src.entities.shape'
local collision = require 'libs.collision'
local input = require 'src.states.game.input'
local play = require 'src.states.game.play'
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

local freePlay = {}

local function triggerTransition(targetState)
	if freePlay.isTransitioning then return end
	freePlay.isTransitioning = true
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

freePlay.initialized = false
freePlay.activeBarks = {}


function freePlay.init()
freePlay.spawnBoxes = {
    {x = 80, y = 220, w = 40, h = 40}, -- left
    {x = 520, y = 220, w = 40, h = 40}, -- right
    {x = 300, y = 0, w = 40, h = 40}, -- top
    {x = 300, y = 440, w = 40, h = 40}, -- bottom
}

freePlay.initialized = true
end


function freePlay.enter()
    freePlay.bg = require 'src.shaders.bg1'
    freePlay.bg.init()

    fireflies.init()
    freePlay.stop = false
    freePlay.roundLost = false
    freePlay.roundTimer = 0
    freePlay.roundScore = 0
    freePlay.overSfxPlayed = false
    freePlay.paused = false
    freePlay.lostTimer = 3.0
    freePlay.shaderTime = 0
    freePlay.spawnTimer = 0
    freePlay.moveTimer = 0.6
    freePlay.speedLevel = 1
    freePlay.levelTimer = 60
    freePlay.maxLevel = 15
    freePlay.spawnInterval = 6.0
    freePlay.speedUpTimer = 0
    freePlay.ringsCleared = 0
    freePlay.fallSpeedUp = false
    freePlay.fallSpeedModifier = 10
    freePlay.multiplier = 1
    freePlay.multiplierTimer = 10.0
    freePlay.multiplierTimerMax = 10.0

    freePlay.centerShape = {}
    freePlay.movingShapes = {}
    freePlay.nextShape = nil
    freePlay.clearingQueue = {}
    freePlay.clearTimer = 0
    freePlay.clearDelay = 0.02
    freePlay.flashTimer = 0
    freePlay.activeBarks = {}
    freePlay.pushTimer = 0
    freePlay.pushDuration = 0.6
    freePlay.pushMaxDistance = 8
    freePlay.pushDirX = 0
    freePlay.pushDirY = 0
    freePlay.coreBounceTimer = 0
    freePlay.coreBounceScale = 1.0
    freePlay.coreBounceMaxScale = 1.0

    soundManager.startGameplayPlaylist(freePlay.speedLevel)

    local ts = GameConfig.PLAY_CONSTANTS.TILE_SIZE
    local startX = math.floor((GameConfig.PLAY_CONSTANTS.CENTER_X - ts / 2) / ts) * ts
    local startY = math.floor((GameConfig.PLAY_CONSTANTS.CENTER_Y - ts / 2) / ts) * ts

    local firstShape = Shape({x = startX, y = startY}, 0, 7)
    table.insert(freePlay.centerShape, firstShape)
    freePlay.prepareNextShape(freePlay)
    freePlay.spawnNewShape(freePlay, true)

	freePlay.isTransitioning = true
    Transition.fadeIn(0.5, function()
        freePlay.isTransitioning = false
    end)

end


function freePlay.triggerImpact(direction, movingShape)
    freePlay.pushTimer = freePlay.pushDuration
	local center = freePlay.centerShape[1]

	freePlay.coreBounceTimer = 0.2
	freePlay.coreBounceMaxScale = 1.0 + (0.02 * freePlay.speedLevel)
	freePlay.coreBounceScale = 1.0

	if movingShape then
		movingShape.bounceTimer = 0.2
		movingShape.bounceMaxScale = 1.0 + (0.02 * freePlay.speedLevel)
		movingShape.bounceScale = 1.0
	end

    if direction == 1 then
        freePlay.pushDirX, freePlay.pushDirY = 1, 0
    elseif direction == 2 then
        freePlay.pushDirX, freePlay.pushDirY = -1, 0
    elseif direction == 3 then
        freePlay.pushDirX, freePlay.pushDirY = 0, 1
    elseif direction == 4 then
        freePlay.pushDirX, freePlay.pushDirY = 0, -1
    else
        freePlay.pushDirX, freePlay.pushDirY = 0, 0
    end
end


function freePlay.prepareNextShape(g)
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


function freePlay.spawnNewShape(g, isInitialSpawn)
    if g.nextShapeData then
        local data = g.nextShapeData
        local newShape = Shape({x = data.x, y = data.y, direction = data.direction}, g.moveTimer, data.ii)
        table.insert(g.movingShapes, newShape)
    end

    g.prepareNextShape(g)

    if not isInitialSpawn then
        g.spawnTimer = g.spawnTimer - freePlay.spawnInterval
    end
end


function freePlay.triggerBark(linesCleared)
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

        table.insert(freePlay.activeBarks, {
            text = text,
            x = startX,
            y = startY,
            dirY = directionY,
            timer = 2.5
        })
    end
end


function freePlay.update(dt)
    freePlay.bg.update(dt)
    soundManager.update(dt)
    fireflies.update(dt, freePlay.speedLevel)
    parts.update(dt)
    soundManager.updatePlaylistLevel(freePlay.speedLevel)
    soundManager.updatePlaylist(freePlay.stop)

    if freePlay.isTransitioning then return end

    if freePlay.paused then
        pause.update(dt)
        freePlay.updatePhantom()
        return
    end

    if freePlay.pushTimer > 0 then
        freePlay.pushTimer = freePlay.pushTimer - dt

        local t = 1 - (freePlay.pushTimer / freePlay.pushDuration)
        local easeOut = 1 - ((1 - t) ^ 3)
        local currentDistance = math.sin(easeOut * math.pi) * freePlay.pushMaxDistance

        freePlay.pushX = freePlay.pushDirX * currentDistance
        freePlay.pushY = freePlay.pushDirY * currentDistance

        if freePlay.pushTimer <= 0 then
            freePlay.pushX = 0
            freePlay.pushY = 0
            freePlay.pushDirX = 0
            freePlay.pushDirY = 0
        end
    else
        freePlay.pushX = 0
        freePlay.pushY = 0
    end

    if freePlay.coreBounceTimer > 0 then
        freePlay.coreBounceTimer = freePlay.coreBounceTimer - dt
        local totalDuration = 0.2
        local progress = 1 - (freePlay.coreBounceTimer / totalDuration)
        local scaleAmount = (freePlay.coreBounceMaxScale - 1.0)
        if progress < 0.5 then
            freePlay.coreBounceScale = 1.0 + progress * 2 * scaleAmount
        else
            freePlay.coreBounceScale = freePlay.coreBounceMaxScale - (progress - 0.5) * 2 * scaleAmount
        end
        if freePlay.coreBounceTimer <= 0 then
            freePlay.coreBounceScale = 1.0
        end
    end

    if freePlay.roundLost then
        freePlay.updatePhantom()
        return
    end

    if not freePlay.stop then
        local activeDt = freePlay.fallSpeedUp and (dt * freePlay.fallSpeedModifier) or dt
        play.update(freePlay, dt)
        if #freePlay.movingShapes > 0 then
            freePlay.movingShapes[1]:update(activeDt)
        end

        for i = #freePlay.activeBarks, 1, -1 do
            local b = freePlay.activeBarks[i]
            b.timer = b.timer - dt
            b.y = b.y + (b.dirY * 40 * dt)
            if b.timer <= 0 then
                table.remove(freePlay.activeBarks, i)
            end
        end
    end

    if not freePlay.stop and collision.checkBounds(freePlay.centerShape) then
        freePlay.failingBounds = true
    end

    if not freePlay.stop and not freePlay.failingBounds then
        input.update(freePlay, dt)
    end

    if freePlay.failingBounds then
        local core = freePlay.centerShape[1]
        local isRotating = core and math.abs(core.rotOffset or 0) > 0.001

        if not isRotating then
            freePlay.stop = true
            soundManager.stopMusic()

            if not freePlay.overSfxPlayed then
                soundManager.playSound('game_over')
                freePlay.overSfxPlayed = true
            end

            signal.emit('ringsCleared', freePlay.ringsCleared)
            signal.emit('Level', freePlay.speedLevel)
            signal.emit('roundScore', freePlay.roundScore)

            freePlay.lostTimer = freePlay.lostTimer - dt
            if freePlay.lostTimer <= 0 then
                freePlay.roundLost = true
                triggerTransition("over")
                freePlay.initialized = false
                freePlay.failingBounds = false
            end
        end
    end

    freePlay.updatePhantom()
end


function freePlay.updatePhantom()
    freePlay.phantomShape = nil
    if #freePlay.movingShapes == 0 or freePlay.stop or freePlay.roundLost then return end

    local active = freePlay.movingShapes[1]
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

        for _, centerShape in ipairs(freePlay.centerShape) do
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
            freePlay.phantomShape = phantom
            break
        end
    end
end


function freePlay.draw()
    draw.draw(freePlay, fontManager, gameState, barkFont, Shape, pause)
end


function freePlay.exit()
    soundManager.stopMusic()
    freePlay.centerShape = {}
    freePlay.movingShapes = {}
    freePlay.nextShapeData = nil
    freePlay.spawnTimer = 0
    freePlay.roundLost = false
    freePlay.activeBarks = {}
    collectgarbage("collect")
end


signal.register("pause_enter", function() pause.enter() end)
signal.register("pause_exit", function() freePlay.paused = false end)


return freePlay
