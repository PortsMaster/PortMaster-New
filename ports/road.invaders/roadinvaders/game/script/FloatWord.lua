local FloatWord = {}
local printf = love.graphics.printf
local wordMap = {}

function FloatWord:init()
    timer = Timer.new()
    -- Signal.register(SG.CAR_MOVE, self.onCarMove)
    Signal.register(SG.PUNCH_CUBE, self.onPunchCube)
    Signal.register(SG.CUBE_MATCH, self.onCubeMatched)
    Signal.register(SG.HIT_MONSTER, self.onHitMonster)
    Signal.register(SG.TRI_EXPLODE, self.onHitMonster)
end

function FloatWord:enter()
    timer:clear()
    wordMap = {}
end

function FloatWord.onPunchCube(posX, posY)
    local uid = getUID()
    local info = {
        posX = posX,
        posY = posY,
        string = "PUNCH",
    }
    timer:tween(0.4, info, {posY = posY - 30}, "out-back")
    timer:after(0.5, function()
        wordMap[uid] = nil    
    end)
    wordMap[uid] = info
end

function FloatWord:onCarCrash(posX, posY)
    local uid = getUID()
    local info = {
        posX = posX,
        posY = posY,
        string = "BOOOM",
    }
    timer:tween(0.8, info, {posY = posY - 40}, "out-expo")
    timer:after(0.9, function()
        wordMap[uid] = nil    
    end)
    wordMap[uid] = info
end

function FloatWord.onHitMonster(posX, posY)
    local uid = getUID()
    local info = {
        posX = posX,
        posY = posY,
        string = "HIT",
    }
    timer:tween(0.4, info, {posY = posY - 20}, "out-expo")
    timer:after(0.5, function()
        wordMap[uid] = nil    
    end)
    wordMap[uid] = info
end

function FloatWord.onCubeMatched(posX, posY)
    local uid = getUID()
    local info = {
        posX = posX,
        posY = posY,
        string = "BOOM",
    }
    timer:tween(0.4, info, {posY = posY - 30}, "out-elastic")
    timer:after(0.5, function()
        wordMap[uid] = nil    
    end)
    wordMap[uid] = info
end

function FloatWord.onCarMove(posX, posY)
    local uid = getUID()
    local info = {
        posX = posX,
        posY = posY,
        string = "SHIFT",
    }
    timer:tween(0.4, info, {posY = posY - 30}, "out-back")
    timer:after(0.5, function()
        wordMap[uid] = nil    
    end)
    wordMap[uid] = info
end

function FloatWord:draw()
    resetColor()
    setFont(1)
    for _, word in pairs(wordMap) do
        printf({PCOLOR.BLACK, word.string}, word.posX, word.posY+2, 320)
        printf({PCOLOR.WHITE, word.string}, word.posX, word.posY, 320)
    end
end

function FloatWord:update(dt)
    timer:update(dt)
end

return FloatWord