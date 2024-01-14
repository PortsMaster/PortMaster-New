local MainCountdown = {}
local timer, stringS
MainCountdown.leftTime = 60
MainCountdown.maxTime = 60

local endDrawX, endDrawY, endTitleY = 264, 68, 54
local startDrawX, startDrawY = 320/2-14, 240/2-10
local drawX, drawY
local drawPos = {x = 0, y = 0}

function MainCountdown:init()
    timer = Timer.new()
end

function MainCountdown:enter(time)
    drawPos.x, drawPos.y = startDrawX, startDrawY
    timer:clear()
    MainCountdown.maxTime = time
    MainCountdown.leftTime = time
    timer:every(1, self.countdown)
    self:countdown()
    timer:after(1, function()
        timer:tween(0.5, drawPos, {x = endDrawX, y = endDrawY}, "in-cubic")
    end)
end

function MainCountdown:stop()
    timer:clear()
end

function MainCountdown:countdown()
    local tt = MainCountdown.leftTime - 1
    MainCountdown.leftTime = tt
    stringS = string.format("%02d", MainCountdown.leftTime)
    if tt <= 0 then
        Signal.emit(SG.TIMES_UP)
        return false
    else
        return true
    end
end

function MainCountdown:update(dt)
    timer:update(dt)
end

function MainCountdown:draw()
    love.graphics.setLineWidth(2)
    resetColor(PCOLOR.BROWN)
    love.graphics.rectangle("line", endDrawX-6, endDrawY-18+2, 40, 46)
    resetColor(PCOLOR.YELLOW)
    love.graphics.rectangle("line", endDrawX-6, endDrawY-18, 40, 46)
    resetColor()
    setFont(1)
    love.graphics.printf({PCOLOR.D_PURPLE, "TIME"}, endDrawX-1, endTitleY+2, 320)
    love.graphics.printf({PCOLOR.WHITE, "TIME"}, endDrawX-1, endTitleY, 320)
    setFont(2)
    love.graphics.printf({PCOLOR.D_PURPLE, stringS}, drawPos.x, drawPos.y+4, 320)
    love.graphics.printf({PCOLOR.WHITE, stringS}, drawPos.x, drawPos.y, 320)
end

return MainCountdown