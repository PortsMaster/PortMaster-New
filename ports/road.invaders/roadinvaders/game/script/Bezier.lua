-- Bezier

local Bezier = {}

local newLoveBezier = love.math.newBezierCurve
local loveLine = love.graphics.line
local loveCircle = love.graphics.circle
local radius = 80
local curveMap = {}
local bezierTimer

function Bezier:init()
    bezierTimer = Timer.new()
end

function Bezier:reset()
    bezierTimer:clear()
    curveMap = {}
end

function Bezier:draw()
    resetColor()
    for idx, curveInfo in pairs(curveMap) do
        love.graphics.setLineWidth(curveInfo.width)
        love.graphics.setColor(curveInfo.color)
        loveLine(curveInfo.tb)
    end
end
  
function Bezier:spawn(duration, startPt, endPt, callback)
    for i = 1, 10 do
        self:spawnCurve(duration, startPt,endPt)
    end
    if callback then
        bezierTimer:after(duration,callback)
    end
end
  
function Bezier:shift(duration, startPt, endPt)
    for i = 1, 15 do
        self:shiftCurve(duration, startPt,endPt)
    end
end

function Bezier:spawnCurve(duration, startPt,endPt)
    local uid = getUID()
    local controlPt = self:getRandomControlPoint(startPt)
    local delay = math.random() * 0.16
    local curve = self:newCurve(startPt, endPt, controlPt)
    local curveInfo = {
        t1 = 0.1,
        t2 = 0.1,
        width = 2,
        color = PCOLOR.YELLOW,
        uid = uid,
        curve = curve,
    }
    bezierTimer:script(function(wait)
        wait(delay)
        bezierTimer:tween(duration, curveInfo, {t2=1}, 'out-in-quad')
        wait(duration * 0.1)
        bezierTimer:tween(duration, curveInfo, {t1=1}, 'out-in-quad')
        wait(duration)
        self:disposeCurve(curveInfo.uid)
        Signal.emit(SG.GET_ENERGY)
    end)
    curveMap[uid] = curveInfo
end

function Bezier:shiftCurve(duration, startPt, endPt)
    local uid = getUID()
    local controlPt = self:getRandomControlPoint(startPt)
    local delay = math.random() * 0.36
    local curve = self:newCurve(startPt, endPt, controlPt)
    local curveInfo = {
        t1 = 0.1,
        t2 = 0.1,
        width = 2,
        color = PCOLOR.GREEN,
        uid = uid,
        curve = curve,
    }
    bezierTimer:script(function(wait)
        wait(delay)
        bezierTimer:tween(duration, curveInfo, {t2=1}, 'out-quad')
        wait(duration * 0.1)
        bezierTimer:tween(duration, curveInfo, {t1=1}, 'out-quad')
        wait(duration)
        self:disposeCurve(curveInfo.uid)
    end)
    curveMap[uid] = curveInfo
end

function Bezier:getRandomControlPoint(pt)
    local randomAngle = randi(radius)
    return {
        radius * math.sin(randomAngle) + pt[1],
        radius * math.cos(randomAngle) + pt[2],
    }
end

function Bezier:disposeCurve(uid)
    local curveInfo = curveMap[uid]
    if not curveInfo then return end
    curveInfo.curve:release()
    curveMap[uid] = nil
end

local NO_LINE_TB = {0,0,0,0}
function Bezier:update(dt)
    bezierTimer:update(dt)
    local tb
    for idx, curveInfo in pairs(curveMap) do
        tb = curveInfo.curve:renderSegment(curveInfo.t1, curveInfo.t2, 5)
        -- -- set linewidth
        -- curveInfo.width = curveInfo.t1*5
        -- set table
        if #tb <= 2 then
            tb = NO_LINE_TB
        end
        curveInfo.tb = tb
    end
end

function Bezier:newCurve(startPt, endPt, controlPt)
    return newLoveBezier{
        startPt[1], startPt[2], 
        controlPt[1], controlPt[2], 
        controlPt[1], controlPt[2], 
        endPt[1], endPt[2]}
end

return Bezier