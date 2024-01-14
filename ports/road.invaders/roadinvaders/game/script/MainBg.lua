local MainBg = {}

MainBg.data = {
    y1 = 0,
    y2 = -240,
    speed = 3,
    targetSpeed = 3,
}

local bgIMG, timer
function MainBg:init()
    bgIMG = love.graphics.newImage("image/rolling_bg.png")
    timer = Timer.new()
end

function MainBg:enter()
    timer:clear()
    self:setSpeedByGear(1)
end

local GEAR = {
    [-1] = -3,
    [0] = 0,
    [1] = 3,
    [2] = 6,
    [3] = 9,
    [4] = 12,
}
function MainBg:setSpeedByGear(num)
    MainBg.data.targetSpeed = GEAR[num] or GEAR[4]
    timer:tween(1, MainBg.data, {speed = MainBg.data.targetSpeed}, "in-out-cubic")
end

function MainBg:draw()
    resetColor()
    love.graphics.draw(bgIMG, 0, self.data.y1, 0, 2, 2)
    love.graphics.draw(bgIMG, 0, self.data.y2, 0, 2, 2)
end

function MainBg:update(dt)
    timer:update(dt)
    local data = self.data
    local speed = data.speed
    data.y1 = data.y1 + speed
    data.y2 = data.y2 + speed
    if speed > 0 then
        if data.y1 >= 240 then
            data.y1 = 0
            data.y2 = -240
        end
    else
        if data.y2 <= -240 then
            data.y1 = 240
            data.y2 = 0
        end
    end
end

return MainBg