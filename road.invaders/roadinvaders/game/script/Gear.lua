local Gear = {}

Gear.matchedCount = 0
Gear.num = 1
Gear.max = 5

local timer, gearBG

function Gear:init()
    timer = Timer.new()
    gearBG = love.graphics.newImage("image/car_gear.png")
    Signal.register(SG.CUBE_MATCH, self.onCubeMatched)
end

function Gear:enter()
    -- timer
    self:resetGear()
end

function Gear.onCubeMatched()
    if Gear.num < 0 then return end
    Gear.matchedCount = Gear.matchedCount + 1
    Gear:checkShiftGear()
end

function Gear:reverseGear()
    Gear.num = -1
    Gear.matchedCount = 0
end

function Gear:resetGear()
    Gear.num = 1
    Gear.matchedCount = 0
end

function Gear:checkShiftGear()
    if Gear.num == Gear.max then return end
    if Gear.matchedCount >= 6 then
        Gear.num = math.min(5,Gear.num + 1)
        Gear.matchedCount = 0
        Signal.emit(SG.SHIFT_UP_GEAR)
    end
end

local DOT_POS = {
    [1] = {x = 261, y = 123},
    [2] = {x = 261, y = 145},
    [3] = {x = 279, y = 123},
    [4] = {x = 279, y = 145},
    [5] = {x = 297, y = 123},
    [-1] = {x = 297, y = 145},
}
function Gear:draw()
    local idx = Gear.num
    love.graphics.draw(gearBG,256,110,0,2,2)
    love.graphics.setColor(PCOLOR.WHITE)
    love.graphics.circle("fill", DOT_POS[idx].x, DOT_POS[idx].y, 4)
end

function Gear:update(dt)
    timer:update(dt)
end

return Gear