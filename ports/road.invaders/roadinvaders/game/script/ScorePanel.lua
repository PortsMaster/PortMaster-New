local ScorePanel = {}
local printf = love.graphics.printf

local score = 0
local targetScore = 0
local factor = 1
local mania = 1
local scoreString = ""
local sColor = PCOLOR.WHITE
local scoreTimer, maniaTimer

function ScorePanel:init()
    scoreTimer = Timer.new()
    maniaTimer = Timer.new()
end

function ScorePanel:setFactor(num)
    factor = (1 + (math.abs(num) - 1)/3 * 2) * 6
end

function ScorePanel:enter()
    targetScore = 0
    mania = 1
    self:setNum(0)
    self:setFactor(1)
    scoreTimer:clear()
    maniaTimer:clear()
end

function ScorePanel:draw()
    resetColor()
    setFont(1)
    printf({sColor, "score"}, -20, 8, 320, "right")
    setFont(2)
    printf({sColor, scoreString}, -2, 22, 320, "right")
end

function ScorePanel:addCubeScore(delta)
    delta = delta * mania
    self:addScore(delta)
    mania = math.min(mania + 0.1, 2.5)
    maniaTimer:clear()
    maniaTimer:after(1.2, function()
        mania = 1
    end)
end

function ScorePanel:addScore(delta)
    delta = math.ceil(delta * factor)
    targetScore = delta + score
    scoreTimer:clear()
    scoreTimer:every(FRM, function()
        self:setNum(score + delta/8)
        return score < targetScore
    end)
end

function ScorePanel:getScore()
    return targetScore
end

function ScorePanel:setNum(num)
    score = num
    scoreString = string.format("%05d", num)
end

function ScorePanel:update(dt)
    scoreTimer:update(dt)
    maniaTimer:update(dt)
end

return ScorePanel