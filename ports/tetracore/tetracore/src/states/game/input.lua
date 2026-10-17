local signal = require 'libs.signal'
local collision = require 'libs.collision'
local Shape = require 'src.entities.shape'
local soundManager = require 'src.utils.soundManager'
local inputManager = require 'src.utils.inputManager'
local blocksImg = love.graphics.newImage('assets/ui/blocks.png')

local input = {}

local TILE = GameConfig.PLAY_CONSTANTS.TILE_SIZE
local BOARD_LEFT = GameConfig.PLAY_CONSTANTS.BOARD_LEFT
local BOARD_RIGHT = GameConfig.PLAY_CONSTANTS.BOARD_RIGHT
local BOARD_TOP = GameConfig.PLAY_CONSTANTS.BOARD_TOP
local BOARD_BOTTOM = GameConfig.PLAY_CONSTANTS.BOARD_BOTTOM

local function handleMovement(game, dx, dy)
    if dx == 0 and dy == 0 then return end

    for _, shape in ipairs(game.centerShape) do
        shape.x = shape.x + dx
        shape.y = shape.y + dy
    end

    for i = #game.movingShapes, 1, -1 do
        local movingShape = game.movingShapes[i]
        local hit = false
        local movingBoxes = movingShape:getCollisionBoxes()

        for _, centerShape in ipairs(game.centerShape) do
            local centerBoxes = centerShape:getCollisionBoxes()

            for _, mb in ipairs(movingBoxes) do
                for _, cb in ipairs(centerBoxes) do
                    if collision.check(cb, mb) then
                        hit = true
                        break
                    end
                end
                if hit then break end
            end
            if hit then break end
        end

        if hit then
            movingShape.x = movingShape.x + dx
            movingShape.y = movingShape.y + dy

            local coreBounds = {
                left = game.centerShape[1].x,
                right = game.centerShape[1].x + TILE,
                top = game.centerShape[1].y,
                bottom = game.centerShape[1].y + TILE,
            }

            for _, tile in ipairs(movingShape.tiles) do
                local globalX = movingShape.x + tile.localX
                local globalY = movingShape.y + tile.localY

                local gridDx = 0
                if globalX < coreBounds.left then gridDx = (coreBounds.left - globalX) / TILE
                elseif globalX >= coreBounds.right then gridDx = (globalX - coreBounds.right) / TILE + 1 end

                local gridDy = 0
                if globalY < coreBounds.top then gridDy = (coreBounds.top - globalY) / TILE
                elseif globalY >= coreBounds.bottom then gridDy = (globalY - coreBounds.bottom) / TILE + 1 end

                local ringLayer = math.floor(math.max(gridDx, gridDy) + 0.5)

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
                singleShape.quad = love.graphics.newQuad((targetIi - 1) * TILE, 0,
                                                         TILE,
                                                         TILE, blocksImg)

                table.insert(game.centerShape, singleShape)
            end

            table.remove(game.movingShapes, i)
            soundManager.playSound('drop')
        end
    end
end

local function rotateActiveShape(game)
    if #game.movingShapes > 0 then
        soundManager.playSound('rotation')
        local active = game.movingShapes[1]

        active.targetAngle = (active.targetAngle or 0) + math.pi / 2
        active.visualAngle = active.visualAngle or 0

        active:rotateClockwiseSelf()
    end
end

local function rotateCenterCluster(game)
    if #game.centerShape > 0 then
        soundManager.playSound('rotation_low')

        local core = game.centerShape[1]

        local pivotX = math.floor(core.x + TILE)
        local pivotY = math.floor(core.y + TILE)

        core.pivotCx = pivotX
        core.pivotCy = pivotY
        core.rotOffset = (core.rotOffset or 0) - math.pi / 2

        if core.direction == 1 then core.direction = 3
        elseif core.direction == 3 then core.direction = 2
        elseif core.direction == 2 then core.direction = 4
        elseif core.direction == 4 then core.direction = 1
        end

        for i = 2, #game.centerShape do
            local outerShape = game.centerShape[i]
            outerShape:rotateClockwiseAround(pivotX, pivotY)
        end
    end
end

function input.update(game, dt)
    inputManager.update(dt)

    local core = game.centerShape[1]
    if not core then return end

    local dx, dy = 0, 0
    if inputManager.isActionJustPressed("up") then
        if core.y > BOARD_TOP then
            dy = -TILE
        end
    elseif inputManager.isActionJustPressed("down") then
        if core.y + TILE < BOARD_BOTTOM then
            dy = TILE
        end
    elseif inputManager.isActionJustPressed("left") then
        if core.x > BOARD_LEFT then
            dx = -TILE
        end
    elseif inputManager.isActionJustPressed("right") then
        if core.x + TILE * 2 < BOARD_RIGHT then
            dx = TILE
        end
    elseif inputManager.isActionJustPressed("pause") then
        game.paused = true
        signal.emit("pause_enter")
    end

    if inputManager.isActionDown("speedUp") then
        game.fallSpeedUp = true
    else
        game.fallSpeedUp = false
    end

    handleMovement(game, dx, dy)

    if inputManager.isActionJustPressed("rotateShape") then
        rotateActiveShape(game)
    end

    if inputManager.isActionJustPressed("rotateCore") then
        rotateCenterCluster(game)
    end
end

return input
