local color = class:extend()

color._factor = 1/255

-- Hex to RGB
function color.toRGB(hex)
    hex = hex:replace('#', '')
    local r, g, b, a
    if string.len(hex) == 6 then
        r, g, b = hex:match('(%x%x)(%x%x)(%x%x)')
        a = 1
    else
        r, g, b, a = hex:match('(%x%x)(%x%x)(%x%x)(%x%x)')
        a = tonumber(a, 16) * color._factor
    end

    return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), a
end

-- RGB to Hex
function color.toHex(r, g, b, a)
    local hex

    if a then
        hex = string.format('%02x%02x%02x%02x', r, g, b, a * 255)
    else
        hex = string.format('%02x%02x%02x', r, g, b)
    end

    return '#' .. hex
end

-- Create a new color (RGB or Hex)
function color:new(r, g, b, a)
    if r == nil or (type(r) == "number") then
        self.red = r or 0
        self.green = g or 0
        self.blue = b or 0
        self.alpha = a or 1
    else
        self.red, self.green, self.blue, self.alpha = color.toRGB(r)
    end
    return self
end

-- gets the color (from a scale of 0 to 255)
function color:get()
    return self.red, self.green, self.blue, self.alpha
end

-- gets the color (from a scale of 0 to 1)
function color:get01()
    return self.red * color._factor, self.green * color._factor, self.blue * color._factor, self.alpha
end

-- gets the color as a hex string
function color:getHex()
    return color.toHex(self.red, self.green, self.blue, self.alpha)
end

-- reset the drawing color to white.
function color.reset(alpha)
    love.graphics.setColor(1, 1, 1, alpha or 1)
end



-- sets the color
function color:set(alpha)
    local r, g, b, a
    r, g, b, a = self:get01()
    graphics.setColor(r, g, b, alpha or a)
    return self
end

-- sets the color as a background color
function color:setBackground()
    graphics.setBackgroundColor(self:get01())
    return self
end

-- sets the color to a random color
function color:random()
    self.red, self.green, self.blue = math.random(0, 255), math.random(0, 255), math.random(0, 255)
    return self
end

-- returns a blended color
function color.blend(a, b, amount)
    amount = amount or 0.5
    return color(a.red + (b.red - a.red) * amount, a.green + (b.green - a.green) * amount, a.blue + (b.blue - a.blue) * amount, a.alpha + (b.alpha - a.alpha) * amount)
end

return color