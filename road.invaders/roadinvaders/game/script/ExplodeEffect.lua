local ExplodeEffect = {}

local mainList = {}
local timer

function ExplodeEffect:init()
    timer = Timer.new()
end

function ExplodeEffect:reset()
    mainList = {}
    timer:clear()
end

function ExplodeEffect:carExplode(posX, posY)
    local duration = 0.6
    local uid = getUID()
    local newInfo = {
        posX = posX,
        posY = posY,
        startArc = 0,
        endArc = math.pi*2,
        width = 20,
        radius = 10,
        uid = uid,
    }
    local result = {
        width = 0, 
        radius = 200,
    }
    table.insert(mainList, 1, newInfo)
    timer:tween(duration, newInfo, result,"out-expo")
    timer:after(duration, function()
        self:remove(newInfo.uid)
    end)
end

function ExplodeEffect:triExplode(posX, posY)
    local duration = 0.6
    local uid = getUID()
    local newInfo = {
        posX = posX,
        posY = posY,
        startArc = 0,
        endArc = math.pi*2,
        width = 20,
        radius = 10,
        uid = uid,
    }
    local result = {
        width = 0, 
        radius = 200,
    }
    table.insert(mainList, 1, newInfo)
    timer:tween(duration, newInfo, result,"out-expo")
    timer:after(duration, function()
        self:remove(newInfo.uid)
    end)
end

function ExplodeEffect:cubeExplode(posX, posY)
    local duration = 0.3
    local uid = getUID()
    local newInfo = {
        posX = posX,
        posY = posY,
        startArc = math.pi/2,
        endArc = math.pi/2+math.pi*2,
        width = 20,
        radius = 10,
        uid = uid,
    }
    local result = {
        width = 0, 
        radius = 40,
        startArc = math.pi/2 + math.pi/3, 
        endArc = math.pi/2+math.pi*2 - math.pi/3
    }
    table.insert(mainList, 1, newInfo)
    timer:tween(duration, newInfo, result,"out-expo")
    timer:after(duration, function()
        self:remove(newInfo.uid)
    end)
end

function ExplodeEffect:remove(uid)
    for idx, info in pairs(mainList) do
        if info.uid == uid then
            table.remove(mainList, idx)
            return
        end
    end
end

local circle = love.graphics.circle
local arc = love.graphics.arc
local setLineWidth = love.graphics.setLineWidth
function ExplodeEffect:draw()
    resetColor()
    for _, info in ipairs(mainList) do
        setLineWidth(info.width)
        arc("line", "open", info.posX, info.posY, info.radius, info.startArc, info.endArc)
        -- circle("line", info.posX, info.posY, info.radius)
    end
end

function ExplodeEffect:update(dt)
    timer:update(dt)
end

return ExplodeEffect