local collision = require 'libs.collision'
local Shape = require 'src.entities.shape'
local parts = require 'src.entities.particles'
local soundManager = require 'src.utils.soundManager'
local GameConfig = require 'src.constants.gameConfig'
local blocksImg = love.graphics.newImage('assets/ui/blocks.png')

local play = {}


local function getCoreBounds(core)
    return {left = core.x, right = core.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE * 2,
        top = core.y, bottom = core.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE * 2}
end


local function getGlobalTilePos(shape)
    local tile = shape.tiles[1]
    local gx = shape.x + (tile and tile.localX or 0)
    local gy = shape.y + (tile and tile.localY or 0)
    return gx, gy
end


local function isTileLocationOccupied(game, targetGx, targetGy)
    for _, other in ipairs(game.centerShape) do
        for _, otherTile in ipairs(other.tiles) do
            local ogx = other.x + otherTile.localX
            local ogy = other.y + otherTile.localY
            if ogx == targetGx and ogy == targetGy then
                return true
            end
        end
    end
    return false
end


local function getRingLayer(gx, gy, coreBounds)
    local gridDx = 0
    if gx < coreBounds.left then
        gridDx = (coreBounds.left - gx) / GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif gx >= coreBounds.right then
        gridDx = (gx - coreBounds.right) / GameConfig.PLAY_CONSTANTS.TILE_SIZE + 1
    end

    local gridDy = 0
    if gy < coreBounds.top then
        gridDy = (coreBounds.top - gy) / GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif gy >= coreBounds.bottom then
        gridDy = (gy - coreBounds.bottom) / GameConfig.PLAY_CONSTANTS.TILE_SIZE + 1
    end

    return math.floor(math.max(gridDx, gridDy) + 0.5)
end


local function applyInwardGravity(game)
    local core = game.centerShape[1]
    local centerX = core.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE
    local centerY = core.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE
    local movedAny = true

    while movedAny do
        movedAny = false
        local allTiles = {}

        for sIdx = 2, #game.centerShape do
            local shape = game.centerShape[sIdx]
            for _, tile in ipairs(shape.tiles) do
                local gx = shape.x + tile.localX
                local gy = shape.y + tile.localY
                local dist = math.abs(gx - centerX) + math.abs(gy - centerY)
                table.insert(allTiles, {
                    tile = tile, gx = gx, gy = gy, dist = dist
                })
            end
        end

        table.sort(allTiles, function(a, b) return a.dist < b.dist end)

        for _, item in ipairs(allTiles) do
            local dx, dy = 0, 0
            if item.gx < centerX then dx = GameConfig.PLAY_CONSTANTS.TILE_SIZE
            elseif item.gx > centerX then dx = -GameConfig.PLAY_CONSTANTS.TILE_SIZE
            elseif item.gy < centerY then dy = GameConfig.PLAY_CONSTANTS.TILE_SIZE
            elseif item.gy > centerY then dy = -GameConfig.PLAY_CONSTANTS.TILE_SIZE
            end

            if dx ~= 0 or dy ~= 0 then
                local targetGx = item.gx + dx
                local targetGy = item.gy + dy

                if not isTileLocationOccupied(game, targetGx, targetGy) then
                    item.tile.localX = item.tile.localX + dx
                    item.tile.localY = item.tile.localY + dy
                    movedAny = true
                end
            end
        end
    end
end


local function checkAndClearTiles(game)
    if #game.clearingQueue > 0 then return end

    local coreBounds = getCoreBounds(game.centerShape[1])
    local ringCounts = {}

    for i = 2, #game.centerShape do
        local shape = game.centerShape[i]
        local gx, gy = getGlobalTilePos(shape)
        local ringLayer = getRingLayer(gx, gy, coreBounds)
        shape.currentLayer = ringLayer

        if ringLayer > 0 then
            ringCounts[ringLayer] = (ringCounts[ringLayer] or 0) + 1
        end
    end

    local clearedLayers = {}
    local numLayersCleared = 0

    for layer, count in pairs(ringCounts) do
        local requiredTiles = (layer * 8) + 4
        if count >= requiredTiles then
            clearedLayers[layer] = true
            numLayersCleared = numLayersCleared + 1
        end
    end

    for i = #game.centerShape, 2, -1 do
        local shape = game.centerShape[i]
        local layer = shape.currentLayer or 0

        if clearedLayers[layer] then
            shape.isClearing = true
            table.insert(game.clearingQueue, {shape = shape, indexInCenter = i})
        end
    end

	if #game.clearingQueue > 0 then
        soundManager.playSound('clear')

        for k = 1, numLayersCleared do
            game.ringsCleared = game.ringsCleared + 1
            game.multiplier = game.multiplier + 1
            game.roundScore = game.roundScore + (100 * game.multiplier)
        end

        game.multiplierTimer = game.multiplierTimerMax
        game.flashTimer = 0.15
        game.lastRingsCleared = numLayersCleared

        if type(game.triggerBark) == "function" then
            game.triggerBark(numLayersCleared)
        end
    end
end


local function dissolveMovingShapeToCenter(game, movingShape)
    local coreBounds = getCoreBounds(game.centerShape[1])

    for _, tile in ipairs(movingShape.tiles) do
        local globalX = movingShape.x + tile.localX
        local globalY = movingShape.y + tile.localY

        local ringLayer = getRingLayer(globalX, globalY, coreBounds)

        local targetIi = movingShape.ii
        if ringLayer > 0 then
            local colors = { [0] = 7, [1] = 8, [2] = 9 }
            targetIi = colors[ringLayer % 3]
        end

        local singleTileCoords = {
            x = globalX,
            y = globalY,
            direction = 0
        }

        local singleShape = Shape(singleTileCoords, movingShape.timerLength, targetIi)
        singleShape.tiles = {{ localX = 0, localY = 0 }}
        singleShape.quad = love.graphics.newQuad((targetIi - 1) * GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                 0, GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                 GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                 blocksImg)
        table.insert(game.centerShape, singleShape)
    end
end


local function checkShapeCollision(movingShape, centerShapeList)
    local movingBoxes = movingShape:getCollisionBoxes()

    for _, centerShape in ipairs(centerShapeList) do
        local centerBoxes = centerShape:getCollisionBoxes()

        for _, movingBox in ipairs(movingBoxes) do
            for _, centerBox in ipairs(centerBoxes) do
                if collision.check(centerBox, movingBox) then
                    return true
                end
            end
        end
    end
    return false
end


function play.update(game, dt)

    for i = 1, #game.centerShape do
        game.centerShape[i]:update(dt)
    end

    if game.flashTimer and game.flashTimer > 0 then
        game.flashTimer = game.flashTimer - dt
    end

    if game.clearingQueue and #game.clearingQueue > 0 then
        game.clearTimer = (game.clearTimer or 0) + dt
        if game.clearTimer >= (game.clearDelay or 0.04) then
            game.clearTimer = 0
            local item = table.remove(game.clearingQueue)

            local tileSize = GameConfig.PLAY_CONSTANTS.TILE_SIZE
            for _, tile in ipairs(item.shape.tiles) do
                local tileCenterX = item.shape.x + tile.localX + tileSize / 2
                local tileCenterY = item.shape.y + tile.localY + tileSize / 2
                parts.spawn(tileCenterX, tileCenterY, game.lastRingsCleared or 1)
            end

            for idx, shape in ipairs(game.centerShape) do
                if shape == item.shape then
                    table.remove(game.centerShape, idx)
                    break
                end
            end

            if #game.clearingQueue == 0 then
                applyInwardGravity(game)
                local coreBounds = getCoreBounds(game.centerShape[1])
                for i = 2, #game.centerShape do
                    local shape = game.centerShape[i]
                    local gx, gy = getGlobalTilePos(shape)
                    local currentLayer = getRingLayer(gx, gy, coreBounds)
                    shape.currentLayer = currentLayer
                    if currentLayer > 0 then
                        local colors = { [0] = 7, [1] = 8, [2] = 9 }
                        local newIi = colors[currentLayer % 3]
                        if shape.ii ~= newIi then
                            shape.ii = newIi
                            shape.quad = love.graphics.newQuad((newIi - 1) * GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                               0, GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                               GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                                               blocksImg)
                        end
                    end
                end
            end
        end
        return
    end

    game.spawnTimer = game.spawnTimer + dt
    game.speedUpTimer = game.speedUpTimer + dt
    game.roundTimer = game.roundTimer + dt
    game.globalMoveTimer = (game.globalMoveTimer or 0) + dt

    local globalStepTriggered = false
    if game.globalMoveTimer >= game.moveTimer then
        game.globalMoveTimer = game.globalMoveTimer - game.moveTimer
        globalStepTriggered = true
    end

    if game.spawnTimer >= game.spawnInterval then
        game.spawnNewShape(game)
    end

    if game.multiplier > 1 then
        if game.multiplierTimer <= 0 then
            game.multiplier = game.multiplier - 1
            game.multiplierTimer = game.multiplierTimerMax
        else
            game.multiplierTimer = game.multiplierTimer - dt
        end
    else
        game.multiplierTimer = game.multiplierTimerMax
    end

    if game.speedUpTimer >= game.levelTimer and game.speedLevel < game.maxLevel
    and game.speedUpEnabled then
        if game.moveTimer > 0.20 then
            game.moveTimer = game.moveTimer - 0.05
        end
        if game.spawnInterval > 2.0 then
            game.spawnInterval = game.spawnInterval - 0.5
        end
        game.speedLevel = game.speedLevel + 1
        game.speedUpTimer = 0
        soundManager.playSound('level_up')
    end

    local activeDt = game.fallSpeedUp and (dt * game.fallSpeedModifier) or dt

    for i = #game.movingShapes, 1, -1 do
        local movingShape = game.movingShapes[i]

        if i == 1 and game.fallSpeedUp then
            movingShape.timer = (movingShape.timer or 0) + activeDt
            if movingShape.timer >= game.moveTimer then
                movingShape.timer = movingShape.timer - game.moveTimer
                movingShape:stepForward()
            end
        elseif globalStepTriggered then
            movingShape:stepForward()
        end

        movingShape:update(dt)

		if checkShapeCollision(movingShape, game.centerShape) then
			local shiftX, shiftY = collision.resolve(nil, nil, movingShape.direction)
			movingShape.x = movingShape.x + shiftX
			movingShape.y = movingShape.y + shiftY

			if type(game.triggerImpact) == "function" then
				game.triggerImpact(movingShape.direction, movingShape)
			end

			soundManager.playSound('drop')
			dissolveMovingShapeToCenter(game, movingShape)
			table.remove(game.movingShapes, i)
			checkAndClearTiles(game)
        else
            if movingShape.remove then
                table.remove(game.movingShapes, i)
            end
        end
    end

    checkAndClearTiles(game)
end

return play
