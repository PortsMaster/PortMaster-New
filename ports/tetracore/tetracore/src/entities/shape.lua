local GameConfig = require 'src.constants.gameConfig'
local class = require 'libs.class'

local img = love.graphics.newImage('assets/ui/blocks.png')

local function getTileOffsets(ii)
    if ii == 1 then
        return {{x=0, y=0}, {x=1, y=0}, {x=2, y=0}, {x=3, y=0}}
    elseif ii == 2 then
        return {{x=0, y=0}, {x=1, y=0}, {x=2, y=0}, {x=0, y=1}}
    elseif ii == 3 then
        return {{x=0, y=0}, {x=1, y=0}, {x=2, y=0}, {x=2, y=1}}
    elseif ii == 4 then
        return {{x=0, y=0}, {x=1, y=0}, {x=1, y=1}, {x=2, y=1}}
    elseif ii == 5 then
        return {{x=0, y=1}, {x=1, y=1}, {x=1, y=0}, {x=2, y=0}}
    elseif ii == 6 then
        return {{x=1, y=0}, {x=0, y=1}, {x=1, y=1}, {x=2, y=1}}
    elseif ii == 7 then
        return {{x=0, y=0}, {x=1, y=0}, {x=0, y=1}, {x=1, y=1}}
    end
    return {}
end

local Shape = class{
    init = function(self, coordinates, spd, ii, maxLimit)
        self.direction = coordinates.direction or 0
        self.x = coordinates.x
        self.y = coordinates.y
        self.ii = ii
        self.remove = false
        self.maxLimit = maxLimit
        self.timer = 0
        self.timerLength = spd
        self.quad = love.graphics.newQuad((ii - 1) * GameConfig.PLAY_CONSTANTS.TILE_SIZE, 0,
                                          GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                                          GameConfig.PLAY_CONSTANTS.TILE_SIZE, img)
        self.tiles = {}

        self.rotOffset = 0
        self.pivotCx = 0
        self.pivotCy = 0

        -- Bounce animation properties
        self.bounceTimer = 0
        self.bounceScale = 1.0
        self.bounceMaxScale = 1.0

        if ii == 1 then     self.pivotIndex = 2
        elseif ii == 3 or ii == 4 or ii == 5 then self.pivotIndex = 3
        else self.pivotIndex = 1
        end

        local offsets = getTileOffsets(ii)
        for _, offset in ipairs(offsets) do
            table.insert(self.tiles, {
                localX = offset.x * GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                localY = offset.y * GameConfig.PLAY_CONSTANTS.TILE_SIZE,
            })
        end
    end,

	update = function(self, dt)
        local lerpSpeed = 18

        if math.abs(self.rotOffset) > 0.001 then
            self.rotOffset = self.rotOffset * math.exp(-lerpSpeed * dt)
        else
            self.rotOffset = 0
        end

        if self.bounceTimer > 0 then
            self.bounceTimer = self.bounceTimer - dt
            local totalDuration = 0.2
            local progress = 1 - (self.bounceTimer / totalDuration)
            local scaleAmount = (self.bounceMaxScale - 1.0)
            if progress < 0.5 then
                self.bounceScale = 1.0 + progress * 2 * scaleAmount
            else
                self.bounceScale = self.bounceMaxScale - (progress - 0.5) * 2 * scaleAmount
            end
            if self.bounceTimer <= 0 then
                self.bounceScale = 1.0
            end
        end

        if #self.tiles == 0 then
            self.remove = true
        end

        if self.maxLimit then
            for _, tile in ipairs(self.tiles) do
                local globalX = self.x + tile.localX
                if self.maxLimit == 1280 and globalX >= 1280 then
                    self.remove = true
                    break
                elseif self.maxLimit == 2560 and globalX < 1280 then
                    self.remove = true
                    break
                end
            end
        end

        local padding = 100
        if self.x < -padding or self.x > GameConfig.VIRTUAL_WIDTH + padding or
           self.y < -padding or self.y > GameConfig.VIRTUAL_HEIGHT + padding then
            self.remove = true
        end
    end,

    getCollisionBoxes = function(self)
        local boxes = {}
        for i, tile in ipairs(self.tiles) do
            table.insert(boxes, {
                id = i,
                x = self.x + tile.localX,
                y = self.y + tile.localY,
                w = GameConfig.PLAY_CONSTANTS.TILE_SIZE,
                h = GameConfig.PLAY_CONSTANTS.TILE_SIZE
            })
        end
        return boxes
    end,

rotateClockwiseAround = function(self, pivotX, pivotY)
        self.pivotCx = pivotX
        self.pivotCy = pivotY
        self.rotOffset = self.rotOffset - math.pi / 2

        local oldX = self.x
        local oldY = self.y

        local pcX = oldX + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2
        local pcY = oldY + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2

        self.x = math.floor((pivotX - (pcY - pivotY)) - GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2 + 0.5)
        self.y = math.floor((pivotY + (pcX - pivotX)) - GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2 + 0.5)

        for _, tile in ipairs(self.tiles) do
            local oldTileCenterX = oldX + tile.localX + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2
            local oldTileCenterY = oldY + tile.localY + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2
            local newTileCenterX = pivotX - (oldTileCenterY - pivotY)
            local newTileCenterY = pivotY + (oldTileCenterX - pivotX)

            tile.localX = math.floor(((newTileCenterX - GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2) - self.x) + 0.5)
            tile.localY = math.floor(((newTileCenterY - GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2) - self.y) + 0.5)
        end

        if self.direction == 1 then self.direction = 3
        elseif self.direction == 3 then self.direction = 2
        elseif self.direction == 2 then self.direction = 4
        elseif self.direction == 4 then self.direction = 1
        end
    end,

    rotateClockwiseSelf = function(self)
        if #self.tiles == 0 then return end

        local pivotTile = self.tiles[self.pivotIndex] or self.tiles[1]

        self.pivotCx = self.x + pivotTile.localX + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)
        self.pivotCy = self.y + pivotTile.localY + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)
        self.rotOffset = self.rotOffset - math.pi / 2

        local anchorLocalCenterX = pivotTile.localX + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)
        local anchorLocalCenterY = pivotTile.localY + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)

        for _, tile in ipairs(self.tiles) do
            local tcX = tile.localX + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2) - anchorLocalCenterX
            local tcY = tile.localY + (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2) - anchorLocalCenterY

            local rotatedX = -tcY
            local rotatedY = tcX

            tile.localX = math.floor(
                (rotatedX + anchorLocalCenterX - (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)) / GameConfig.PLAY_CONSTANTS.TILE_SIZE + 0.5) * GameConfig.PLAY_CONSTANTS.TILE_SIZE
            tile.localY = math.floor((
                rotatedY + anchorLocalCenterY - (GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2)) / GameConfig.PLAY_CONSTANTS.TILE_SIZE + 0.5) * GameConfig.PLAY_CONSTANTS.TILE_SIZE
        end
    end,

    destroyTile = function(self, index)
        table.remove(self.tiles, index)
    end,

    stepForward = function(self)
        if self.direction == 1 then self.x = self.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE
        elseif self.direction == 2 then self.x = self.x - GameConfig.PLAY_CONSTANTS.TILE_SIZE
        elseif self.direction == 3 then self.y = self.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE
        elseif self.direction == 4 then self.y = self.y - GameConfig.PLAY_CONSTANTS.TILE_SIZE
        end
    end,

    draw = function(self)
        if self.isClearing then
            love.graphics.setColor(2, 2, 2, 0.7)
        end

        local applyTransform = math.abs(self.rotOffset) > 0.001 or self.bounceScale ~= 1.0
        if applyTransform then
            love.graphics.push()
            if self.rotOffset and math.abs(self.rotOffset) > 0.001 then
                love.graphics.translate(self.pivotCx, self.pivotCy)
                love.graphics.rotate(self.rotOffset)
                love.graphics.translate(-self.pivotCx, -self.pivotCy)
            end
            if self.bounceScale ~= 1.0 then
                local centerX = self.x + (self.tiles[1].localX or 0) + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2
                local centerY = self.y + (self.tiles[1].localY or 0) + GameConfig.PLAY_CONSTANTS.TILE_SIZE / 2
                love.graphics.translate(centerX, centerY)
                love.graphics.scale(self.bounceScale, self.bounceScale)
                love.graphics.translate(-centerX, -centerY)
            end
        end

        for _, tile in ipairs(self.tiles) do
            love.graphics.draw(img, self.quad, self.x + tile.localX, self.y + tile.localY)
        end

        if applyTransform then
            love.graphics.pop()
        end

        love.graphics.setColor(1, 1, 1, 1)
    end,
}

return Shape
