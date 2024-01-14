local SceneWormHole = {}

local drawList = {
    
}
local startPT = 60
local endPT = 320-60
local step = 1
local lineStep = 20
lineList = {}
function SceneWormHole:init()
    -- love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")
    local factorList = {}
    for i = 0, 2, 0.1 do
        factorList[#factorList+1] = {
            math.pi * i, math.pi * i
            -- math.pi * i, math.pi * (1 + (1-i))
        }
    end
    for i = 1, #factorList do
        factor = factorList[i]
        upperX = 110 * math.cos(factor[1])
        upperY = 20 * math.sin(factor[1])
        lowerX = 110 * math.cos(factor[2])
        lowerY = 20 * math.sin(factor[2])
        drawList[#drawList+1] = love.math.newBezierCurve{
            upperX + 160, upperY + 10,
            320/2, upperY + 30,
            320/2, 240/2-50,
            320/2, 240/2+50,
            320/2, lowerY + 210,
            lowerX + 160, lowerY + 230}
    end

    local startValue = 0
    local newValue = 0
    for i = 1, (lineStep - 1) do
        newValue = newValue + startValue + 1/(lineStep-1)
        if newValue > 1 then
            newValue = newValue - 1
        end
        lineList[i] = newValue
    end
end

lineTb = {}
function SceneWormHole:update(dt)
    for idx, value in pairs(lineList) do
        lineList[idx] = lineList[idx] + 0.001
        if lineList[idx] >= 1 then
            lineList[idx] = 0
        end
    end
    table.sort(lineList)

    lineTb = {}
    for xx = 1, #lineList do
        tempTB = {}
        for i = 1, #drawList do
            x, y = drawList[i]:evaluate(lineList[xx])
            tempTB[#tempTB+1] = x
            tempTB[#tempTB+1] = y
        end
        tempTB[#tempTB+1] = tempTB[1]
        tempTB[#tempTB+1] = tempTB[2]
        lineTb[#lineTb+1] = tempTB
    end

    rectTB = {}
    for i = 1, #drawList-1 do
        for j = 1, #lineList-1 do
            x1, y1 = drawList[i]:evaluate(lineList[j])
            x2, y2 = drawList[i+1]:evaluate(lineList[j])
            x3, y3 = drawList[i+1]:evaluate(lineList[j+1])
            x4, y4 = drawList[i]:evaluate(lineList[j+1])
            rectTB[#rectTB+1] = {
                x1, y1,
                x2, y2,
                x3, y3,
                x4, y4,
            }
        end
    end
end

function SceneWormHole:keyreleased()
end

function SceneWormHole:draw()
    resetColor(PCOLOR.WHITE)
    for _, newCurve in pairs(drawList) do
        love.graphics.line(newCurve:render())
    end
    for i, tempTB in pairs(lineTb) do
        -- if (i%2 == 0) then
        --     resetColor(PCOLOR.WHITE)
        -- else
        --     resetColor(PCOLOR.GREEN)
        -- end
        love.graphics.line(tempTB)
    end
    resetColor(PCOLOR.WHITE)
    love.graphics.ellipse("line", 160, 10, 110, 20 )
    -- for _, rect in pairs(rectTB) do
    --     resetColor(PCOLOR.WHITE)
    --     love.graphics.polygon('line', rect)
    --     resetColor(PCOLOR.BLACK)
    --     love.graphics.polygon('fill', rect)
    -- end
    resetColor(PCOLOR.WHITE)
    love.graphics.ellipse("line", 160, 230, 110, 20 )
end

function SceneWormHole:enter(from)
    self.from = from
end

return SceneWormHole