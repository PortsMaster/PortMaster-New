local FlashText = {}

local printf = love.graphics.printf
local textMap = {}
local fColor = {}
fColor.A = PCOLOR.BLACK
fColor.B = PCOLOR.WHITE

function FlashText:init()
    timer = Timer.new()
end

function FlashText:enter()
    timer:clear()
    textMap = {}
end

function FlashText:draw()
    resetColor()
    setFont(2)
    for _, info in pairs(textMap) do
        printf({info.color, info.string}, info.x, info.y, 320, info.align)
    end
end

function FlashText:delete(text)
    textMap[text] = nil
end

function FlashText:center(text)
    local info = {
        color = fColor.A,
        string = text,
        x = 0,
        y = 240/2-16- 20,
        align = "center",
    }
    textMap[text] = info
    timer:every(FRM*5, function()
        info.color = Flip.get(text.."flash") and fColor.A or fColor.B 
        return textMap[text] and true or false
    end)
end

function FlashText:update(dt)
    timer:update(dt)
end

return FlashText