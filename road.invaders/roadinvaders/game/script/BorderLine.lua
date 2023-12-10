local BorderLine = {}

local line = love.graphics.line
local setLineWidth = love.graphics.setLineWidth
local timer
local rays = {}

function BorderLine:init()
    timer = Timer.new()
    Signal.register(SG.CAR_LOOP, self.crossSide)
end

local leftX = 50
local rightX = 320-50
local midPt = 240/2
local offsetY = 50
function BorderLine:draw()
    resetColor()
    -- line(leftX, 0, leftX, 240)
    for _, info in pairs(rays) do
        setLineWidth(info.width)
        line(info.x1, info.y1, info.x2, info.y2)
    end
end

local pts = {
    [1] = {stX = leftX, stY = midPt, tarX = leftX, tarY = 0 + offsetY},
    [2] = {stX = leftX, stY = midPt, tarX = leftX, tarY = 240 - offsetY},
    [3] = {stX = rightX, stY = midPt, tarX = rightX, tarY = 0 + offsetY},
    [4] = {stX = rightX, stY = midPt, tarX = rightX, tarY = 240 - offsetY},
}

function BorderLine.crossSide(side)
    local self = BorderLine
    if side == -1 then
        self:addRay(1,0.07)
        self:addRay(2,0.07)
        self:addRay(3,0.27)
        self:addRay(4,0.27)
    elseif side == 1 then
        self:addRay(3,0.07)
        self:addRay(4,0.07)
        self:addRay(1,0.27)
        self:addRay(2,0.27)
    end
end

function BorderLine:addRay(idx, delay)
    local uid = getUID()
    local info = {
        x1 = pts[idx].stX,
        y1 = midPt,
        x2 = pts[idx].tarX,
        y2 = midPt,
        uid = uid,
        width = 2,
    }
    rays[uid] = info
    timer:tween(0.1, info, {x1 = pts[idx].tarX, y1 = pts[idx].tarY}, "out-expo")
    timer:after(delay or 0.1, function()
        timer:tween(0.5, info, {width = 1, x2 = pts[idx].tarX, y2 = pts[idx].tarY}, "out-expo")
    end)
end

function BorderLine:update(dt)
    timer:update(dt)
end

return BorderLine