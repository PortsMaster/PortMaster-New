local fireflies = require 'src.entities.fireflies'
local parts = require 'src.entities.particles'
local board = love.graphics.newImage('assets/ui/board.png')
local ui = love.graphics.newImage('assets/ui/ui.png')
local draw = {}

local currentWarningDir = nil
local warningBlendAlpha = 0.0
local previousWarningDir = nil
local previousBlendAlpha = 0.0

local function getWarningScaleForLevel(level)
    level = math.max(1, math.min(10, level or 1))
    local progress = (level - 1) / 9

    local minScale = 1.0
    local maxScale = 2.5

    return minScale + (maxScale - minScale) * progress
end

local function drawWarning(dir, alpha, level)
    local screenW = GameConfig.VIRTUAL_WIDTH
    local screenH = GameConfig.VIRTUAL_HEIGHT

    local scale = getWarningScaleForLevel(level)
    local edgeThickness = math.floor(12 * scale)

    love.graphics.setLineWidth(edgeThickness)

    local steps = 8
    for i = 0, steps - 1 do
        local stepAlpha = alpha * (1 - (i / steps))
        love.graphics.setColor(1, 0, 0, stepAlpha)
        local offset = math.floor(i * (3 * scale))

        if dir == 1 then
            love.graphics.line(offset, 0, offset, screenH)
        elseif dir == 2 then
            love.graphics.line(screenW - offset, 0, screenW - offset, screenH)
        elseif dir == 3 then
            love.graphics.line(0, offset, screenW, offset)
        elseif dir == 4 then
            love.graphics.line(0, screenH - offset, screenW, screenH - offset)
        end
    end
end

function draw.draw(freePlay, fontManager, gameState, barkFont, Shape, pause, bg)
    love.graphics.clear(0,0,0)

    fireflies.draw()
    freePlay.bg.draw(freePlay.speedLevel)

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.push()
        love.graphics.translate(freePlay.pushX or 0, freePlay.pushY or 0)
        love.graphics.draw(board, 0, 0)

        if freePlay.coreBounceScale and freePlay.coreBounceScale ~= 1.0 then
            love.graphics.push()
            local centerX = GameConfig.PLAY_CONSTANTS.CENTER_X
            local centerY = GameConfig.PLAY_CONSTANTS.CENTER_Y
            love.graphics.translate(centerX, centerY)
            love.graphics.scale(freePlay.coreBounceScale, freePlay.coreBounceScale)
            love.graphics.translate(-centerX, -centerY)
        end

        for _, shapeInstance in ipairs(freePlay.centerShape) do
            shapeInstance:draw()
        end

        if freePlay.coreBounceScale and freePlay.coreBounceScale ~= 1.0 then
            love.graphics.pop()
        end
        if freePlay.phantomShape then
            love.graphics.setColor(1, 1, 1, 0.6)
            freePlay.phantomShape:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    love.graphics.pop()

    local pulseSpeed = 2.0 + ((freePlay.speedLevel or 1) - 1)
    local baseAlpha = 0.6 + 0.4 * math.sin(love.timer.getTime() * pulseSpeed)

    if freePlay.nextShapeData and not freePlay.stop and not freePlay.roundLost then
        local targetDir = freePlay.nextShapeData.direction
        local dt = love.timer.getDelta()

        if currentWarningDir ~= targetDir then
            if currentWarningDir ~= nil then
                previousWarningDir = currentWarningDir
                previousBlendAlpha = warningBlendAlpha
            end
            currentWarningDir = targetDir
            warningBlendAlpha = 0.0
        end

        warningBlendAlpha = math.min(1.0, warningBlendAlpha + dt * 2.0)

        if previousWarningDir and previousWarningDir ~= currentWarningDir then
            previousBlendAlpha = math.max(0.0, previousBlendAlpha - dt * 2.0)
            if previousBlendAlpha <= 0.0 then
                previousWarningDir = nil
            end
        end

        if previousWarningDir then
            drawWarning(previousWarningDir, baseAlpha * previousBlendAlpha, freePlay.speedLevel)
        end

        drawWarning(currentWarningDir, baseAlpha * warningBlendAlpha, freePlay.speedLevel)
    else
        currentWarningDir = nil
        previousWarningDir = nil
        warningBlendAlpha = 0.0
        previousBlendAlpha = 0.0
    end

    parts.draw()
    love.graphics.draw(ui, 0, 0)

    local textCleared = gameState.getText("cleared") or "Cleared"
    local textLevel   = gameState.getText("level") or "Level"
    local textScore   = gameState.getText("score") or "Score"
    local textMulti   = gameState.getText("multiplier") or "Multi"

    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.LABEL))
    love.graphics.printf(textCleared.." "..freePlay.ringsCleared, 5, 5, 124, "center")
    love.graphics.printf(textLevel.." "..freePlay.speedLevel, 5, 33, 124, "center")
    love.graphics.printf(textScore.." "..freePlay.roundScore, 511, 5, 124, "center")
    love.graphics.printf(textMulti.." "..freePlay.multiplier, 511, 33, 124, "center")

    love.graphics.setFont(barkFont)
    for _, b in ipairs(freePlay.activeBarks) do
        local alphaBark = math.min(1, b.timer / 0.5)
        love.graphics.setColor(1, 1, 1, alphaBark)

        local textW = barkFont:getWidth(b.text or "")
        local textH = barkFont:getHeight()

        local bx = math.max(450, math.min(639 - textW, b.x))
        local by = math.max(110, math.min(369 - textH, b.y))

        love.graphics.print(b.text, bx, by)
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontManager.getFont(GameConfig.FONTS.LABEL))

    if freePlay.nextShapeData and not freePlay.stop and not freePlay.roundLost then
        local dir = freePlay.nextShapeData.direction
        local box = freePlay.spawnBoxes[dir]
        local ts = GameConfig.PLAY_CONSTANTS.TILE_SIZE

        local tempShape = Shape({x = 0, y = 0, direction = 0}, 0, freePlay.nextShapeData.ii)
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

        local shapeOffsetX = box.x + (box.w - shapeW) / 2
        local shapeOffsetY = box.y + (box.h - shapeH) / 2

        if tempShape.ii == 1 and tempShape.dir == 4 then 
            shapeOffsetY = shapeOffsetY - GameConfig.PLAY_CONSTANTS.TILE_SIZE 
        end

        tempShape.x = math.floor((shapeOffsetX / ts) + 0.5) * ts
        tempShape.y = math.floor((shapeOffsetY / ts) + 0.5) * ts

        local shapeAlpha = baseAlpha * warningBlendAlpha
        love.graphics.setColor(1, 1, 1, shapeAlpha)
        tempShape:draw()
        love.graphics.setColor(1, 1, 1, 1)
    end

    for _, shapeInstance in ipairs(freePlay.movingShapes) do
        shapeInstance:draw()
    end

    if freePlay.multiplierTimer > 8 then love.graphics.setColor(1, 1, 1) end
    if freePlay.multiplierTimer > 6 and freePlay.multiplierTimer <= 8 then love.graphics.setColor(1, 1, 0) end
    if freePlay.multiplierTimer > 3 and freePlay.multiplierTimer <= 6 then love.graphics.setColor(1, 0.5, 0) end
    if freePlay.multiplierTimer <= 3 then love.graphics.setColor(1, 0, 0) end
    local rectCount = math.min(10, math.max(0, math.ceil(freePlay.multiplierTimer)))
    for i = 0, rectCount - 1 do
        local rectX = 512 + (i * 12)
        love.graphics.rectangle("fill", rectX, 62, 14, 20)
    end
    love.graphics.setColor(1, 1, 1, 1)

    if freePlay.paused then
        pause.draw()
    end
end

return draw
