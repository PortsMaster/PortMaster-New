local GameConfig = require 'src.constants.gameConfig'

local collision = {}

-- Simple AABB box collision
function collision.check(a, b)
    return a.x < b.x + b.w and
           b.x < a.x + a.w and
           a.y < b.y + b.h and
           b.y < a.y + a.h
end


function collision.resolve(a, b, direction)
    if direction == 1 then return -GameConfig.PLAY_CONSTANTS.TILE_SIZE, 0
    elseif direction == 2 then return GameConfig.PLAY_CONSTANTS.TILE_SIZE, 0
    elseif direction == 3 then return 0, -GameConfig.PLAY_CONSTANTS.TILE_SIZE
    elseif direction == 4 then return 0, GameConfig.PLAY_CONSTANTS.TILE_SIZE
    end
    return 0, 0
end


function collision.checkBounds(centerShapes)
    if not centerShapes then return false end
    for _, shape in ipairs(centerShapes) do
        local boxes = shape:getCollisionBoxes()
        for _, box in ipairs(boxes) do
            if box.x < GameConfig.PLAY_CONSTANTS.BOARD_LEFT then return true end
            if (box.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE) > GameConfig.PLAY_CONSTANTS.BOARD_RIGHT then return true end
            if box.y < GameConfig.PLAY_CONSTANTS.BOARD_TOP then return true end
            if (box.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE - 32) > GameConfig.PLAY_CONSTANTS.BOARD_BOTTOM then return true end
        end
    end
    return false
end

function collision.P1CheckBounds(centerShapes)
    if not centerShapes then return false end
    for _, shape in ipairs(centerShapes) do
        local boxes = shape:getCollisionBoxes()
        for _, box in ipairs(boxes) do
            if box.x < GameConfig.PLAY_CONSTANTS.P1_BOARD_LEFT then return true end
            if (box.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE) > GameConfig.PLAY_CONSTANTS.P1_BOARD_RIGHT then return true end
            if box.y < GameConfig.PLAY_CONSTANTS.BOARD_TOP then return true end
            if (box.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE - 32) > GameConfig.PLAY_CONSTANTS.BOARD_BOTTOM then return true end
        end
    end
    return false
end

function collision.P2CheckBounds(centerShapes)
    if not centerShapes then return false end
    for _, shape in ipairs(centerShapes) do
        local boxes = shape:getCollisionBoxes()
        for _, box in ipairs(boxes) do
            if box.x < GameConfig.PLAY_CONSTANTS.P2_BOARD_LEFT then return true end
            if (box.x + GameConfig.PLAY_CONSTANTS.TILE_SIZE) > GameConfig.PLAY_CONSTANTS.P2_BOARD_RIGHT then return true end
            if box.y < GameConfig.PLAY_CONSTANTS.BOARD_TOP then return true end
            if (box.y + GameConfig.PLAY_CONSTANTS.TILE_SIZE - 32) > GameConfig.PLAY_CONSTANTS.BOARD_BOTTOM then return true end
        end
    end
    return false
end

function collision.distanceBetween(obj1, obj2)
    return math.sqrt((obj2.x - obj1.x)^2 + (obj2.y - obj1.y)^2)
end

return collision
