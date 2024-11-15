
dir_no = 0
dir_up = 1
dir_down = 2
dir_left = 3
dir_right = 4

-- -----------------------------------------------------------------
function getDirShift(dir)
    local shiftX, shiftY = 0, 0
    if dir == dir_left then
        shiftX = -1
    elseif dir == dir_right then
        shiftX = 1
    elseif dir == dir_up then
        shiftY = -1
    elseif dir == dir_down then
        shiftY = 1
    end
    return shiftX, shiftY
end

-- -----------------------------------------------------------------
local function isFreePlace(model, locX, locY)
    for x = locX, locX + model:getW() - 1 do
        for y = locY, locY + model:getH() - 1 do
            if not model_equals(-1, x, y) and not model_equals(model.index, x, y) then
                return false
            end
        end
    end
    return true
end

-- -----------------------------------------------------------------
local function tryPlace(data, place)
    local locX = place.x
    local locY = place.y

    result = false
    if nil == data.closed[locX] then
        data.closed[locX] = {}
    end
    if not data.closed[locX][locY] then
        data.closed[locX][locY] = true
        if isFreePlace(data.model, locX, locY) then
            result = true
        end
    end
    return result
end

-- -----------------------------------------------------------------
local function isInRect(x, y, w, h, destX, destY)
    return x <= destX and destX < x + w and y <= destY and destY < y + h
end
-- -----------------------------------------------------------------
function findDir(model, destX, destY)
    -- Breadth-first search
    -- Find starting dir to the destination
    -- Return dir_no when there is no free path
    local locX, locY = model:getLoc()
    local w = model:getW()
    local h = model:getH()

    if isInRect(locX, locY, w, h, destX, destY) then
        return dir_no
    end
    if not model_equals(-1, destX, destY) then
        return dir_no
    end

    local data = {}
    data.closed = {}
    data.closed[locX] = {}
    data.closed[locX][locY] = true
    data.model = model

    local fifo = {}
    table.insert(fifo, {dir=dir_left, x=locX - 1, y=locY})
    table.insert(fifo, {dir=dir_right, x=locX + 1, y=locY})
    table.insert(fifo, {dir=dir_up, x=locX, y=locY - 1})
    table.insert(fifo, {dir=dir_down, x=locX, y=locY + 1})

    while table.getn(fifo) > 0 do
        local place = table.remove(fifo, 1)
        if tryPlace(data, place) then
            if isInRect(place.x, place.y, w, h, destX, destY) then
                return place.dir
            end

            table.insert(fifo, {dir=place.dir, x=place.x - 1, y=place.y})
            table.insert(fifo, {dir=place.dir, x=place.x + 1, y=place.y})
            table.insert(fifo, {dir=place.dir, x=place.x, y=place.y - 1})
            table.insert(fifo, {dir=place.dir, x=place.x, y=place.y + 1})
        end
    end
    return dir_no
end

