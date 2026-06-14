-- Grid management
-- Ported from Grid.java

local Tile = require("tile")

local Grid = {}
Grid.__index = Grid

function Grid.new(sizeX, sizeY)
    local self = setmetatable({}, Grid)
    self.sizeX = sizeX or 4
    self.sizeY = sizeY or 4
    self.cells = {}
    self:clear()
    return self
end

function Grid:clear()
    self.cells = {}
    for x = 1, self.sizeX do
        self.cells[x] = {}
        for y = 1, self.sizeY do
            self.cells[x][y] = nil
        end
    end
end

function Grid:getAvailableCells()
    local available = {}
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            if self.cells[x][y] == nil then
                table.insert(available, {x = x, y = y})
            end
        end
    end
    return available
end

function Grid:randomAvailableCell()
    local cells = self:getAvailableCells()
    if #cells > 0 then
        return cells[love.math.random(#cells)]
    end
    return nil
end

function Grid:cellsAvailable()
    return #self:getAvailableCells() > 0
end

function Grid:cellAvailable(x, y)
    return self:withinBounds(x, y) and self.cells[x][y] == nil
end

function Grid:cellOccupied(x, y)
    return self:withinBounds(x, y) and self.cells[x][y] ~= nil
end

function Grid:cellContent(x, y)
    if self:withinBounds(x, y) then
        return self.cells[x][y]
    end
    return nil
end

function Grid:withinBounds(x, y)
    return x >= 1 and x <= self.sizeX and y >= 1 and y <= self.sizeY
end

function Grid:insertTile(tile)
    self.cells[tile.x][tile.y] = tile
end

function Grid:removeTile(tile)
    self.cells[tile.x][tile.y] = nil
end

-- Save current state for undo
function Grid:saveState()
    local state = {}
    for x = 1, self.sizeX do
        state[x] = {}
        for y = 1, self.sizeY do
            local tile = self.cells[x][y]
            if tile then
                local saved_tile = {
                    value = tile.value,
                    isNew = tile.isNew,
                    isMerged = tile.isMerged,
                    previousPosition = tile.previousPosition and {x = tile.previousPosition.x, y = tile.previousPosition.y} or nil
                }
                if tile.mergedFrom then
                    saved_tile.mergedFrom = {
                        { previousPosition = tile.mergedFrom[1].previousPosition and {x = tile.mergedFrom[1].previousPosition.x, y = tile.mergedFrom[1].previousPosition.y} or nil },
                        { previousPosition = tile.mergedFrom[2].previousPosition and {x = tile.mergedFrom[2].previousPosition.x, y = tile.mergedFrom[2].previousPosition.y} or nil }
                    }
                end
                state[x][y] = saved_tile
            else
                state[x][y] = nil
            end
        end
    end
    return state
end

-- Restore from saved state
function Grid:restoreState(state)
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            local s_tile = state[x][y]
            if s_tile then
                local tile = Tile.new(x, y, s_tile.value)
                tile.isNew = s_tile.isNew or false
                tile.isMerged = s_tile.isMerged or false
                tile.previousPosition = s_tile.previousPosition
                if s_tile.mergedFrom then
                    tile.mergedFrom = {
                        { previousPosition = s_tile.mergedFrom[1].previousPosition },
                        { previousPosition = s_tile.mergedFrom[2].previousPosition }
                    }
                end
                self.cells[x][y] = tile
            else
                self.cells[x][y] = nil
            end
        end
    end
end

-- Iterate over all tiles (for rendering)
function Grid:eachCell(callback)
    for x = 1, self.sizeX do
        for y = 1, self.sizeY do
            callback(x, y, self.cells[x][y])
        end
    end
end

return Grid
