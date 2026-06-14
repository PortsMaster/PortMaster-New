-- Tile data structure
-- Ported from Tile.java / Cell.java

local Tile = {}
Tile.__index = Tile

function Tile.new(x, y, value)
    local self = setmetatable({}, Tile)
    self.x = x
    self.y = y
    self.value = value or 2
    self.mergedFrom = nil  -- {tile1, tile2} when this tile was created by a merge

    -- Animation state
    self.previousPosition = nil  -- {x, y} before the last move
    self.undoSourcePosition = nil -- {x, y} source position for undo slide animation
    self.isNew = false           -- true when just spawned
    self.isMerged = false        -- true when just merged

    return self
end

function Tile:getPosition()
    return self.x, self.y
end

function Tile:setPosition(x, y)
    self.x = x
    self.y = y
end

function Tile:savePosition()
    self.previousPosition = {x = self.x, y = self.y}
end

function Tile:clone()
    return Tile.new(self.x, self.y, self.value)
end

return Tile
