local DotTransition = {}
local circle = love.graphics.circle

local timer
local dotList = {}
local dotCount = 0

function DotTransition:init()
    timer = Timer.new()
end

function DotTransition:show()
    local countV = 6
    local countH = 8
    local gapV = 240/countV
    local gapH = 320/countH
    timer:script(function(wait)
        for idxH = 1, (countH+1) do
            for idxV = 1, (countV+1) do
                self:insertDot((idxH-1) * gapH, (idxV-1) * gapV)
            end
            wait(FRM)
        end
    end)
end

local delay = 0.4
function DotTransition:insertDot(x, y)
    local uid = getUID()
    local info = {
        uid = uid,
        posX = x,
        posY = y,
        radius = 10,
    }
    dotList[uid] = info
    dotCount = dotCount + 1
    timer:tween(0.3, info, {radius = 30}, "out-quint")
    timer:after(delay, function()
        timer:tween(0.3, info, {radius = 0}, "out-quint")
        timer:after(delay, function()
            dotCount = dotCount - 1
            dotList[info.uid] = nil
            DotTransition:checkComplete()
        end)
    end)
end

function DotTransition:checkComplete()
    if dotCount <= 0 then
        Signal.emit(SG.DOT_COMPLETE)
    end
end

function DotTransition:draw()
    love.graphics.setColor(PCOLOR.BLACK)
    for _, dot in pairs(dotList) do
        circle("fill", dot.posX, dot.posY, dot.radius)
    end
end

function DotTransition:update(dt)
    timer:update(dt)
end

return DotTransition