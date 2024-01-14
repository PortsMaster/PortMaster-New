--[[
Copyright (c) 2016 George Prosser

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local slider = {}
slider.__index = slider

function newSlider(x, y, length, value, min, max, setter, style)
    local s = {}
    s.value = (value - min) / (max - min)
    s.min = min
    s.max = max
    s.setter = setter
    s.x = x
    s.y = y
    s.length = length

    local p = style or {}
    s.width = p.width or length * 0.1
    s.orientation = p.orientation or 'horizontal'
    s.track = p.track or 'line'
    s.knob = p.knob or 'circle'

    s.grabbed = false
    s.wasDown = true
    s.ox = 0
    s.oy = 0

    return setmetatable(s, slider)
end

function slider:update()
    local x = mx
    local y = my
    local down = love.mouse.isDown(1)


    local knobX = self.x
    local knobY = self.y
    if self.orientation == 'horizontal' then
        knobX = self.x - self.length/2 + self.length * self.value
    elseif self.orientation == 'vertical' then
        knobY = self.y + self.length/2 - self.length * self.value
    end

    local ox = x - knobX
    local oy = y - knobY

    local dx = ox - self.ox
    local dy = oy - self.oy

    if down then
        if self.grabbed then
            if self.orientation == 'horizontal' then
                self.value = self.value + dx / self.length
            elseif self.orientation == 'vertical' then
                self.value = self.value - dy / self.length
            end
        elseif (x > knobX - self.width/2 and x < knobX + self.width/2 and y > knobY - self.width/2 and y < knobY + self.width/2) and not self.wasDown then
            self.ox = ox
            self.oy = oy
            self.grabbed = true
        end
    else
        self.grabbed = false
    end

    self.value = math.max(0, math.min(1, self.value))

    if self.setter ~= nil then
        self.setter(self.min + self.value * (self.max - self.min))
    end

    self.wasDown = down
end

function slider:draw()
    if self.track == 'rectangle' then
        if self.orientation == 'horizontal' then
            love.graphics.rectangle('line', self.x - self.length/2 - self.width/2, self.y - self.width/2, self.length + self.width, self.width)
        elseif self.orientation == 'vertical' then
            love.graphics.rectangle('line', self.x - self.width/2, self.y - self.length/2 - self.width/2, self.width, self.length + self.width)
        end
    elseif self.track == 'line' then
        if self.orientation == 'horizontal' then
            love.graphics.line(self.x - self.length/2, self.y, self.x + self.length/2, self.y)
        elseif self.orientation == 'vertical' then
            love.graphics.line(self.x, self.y - self.length/2, self.x, self.y + self.length/2)
        end
    elseif self.track == 'roundrect' then
        if self.orientation == 'horizontal' then
            love.graphics.rectangle('line', self.x - self.length/2 - self.width/2, self.y - self.width/2, self.length + self.width, self.width, self.width/2, self.width)
        elseif self.orientation == 'vertical' then
            love.graphics.rectangle('line', self.x - self.width/2, self.y - self.length/2 - self.width/2, self.width, self.length + self.width, self.width, self.width/2)
        end
    end

    local knobX = self.x
    local knobY = self.y
    if self.orientation == 'horizontal' then
        knobX = self.x - self.length/2 + self.length * self.value
    elseif self.orientation == 'vertical' then
        knobY = self.y + self.length/2 - self.length * self.value
    end

    if self.knob == 'rectangle' then
        love.graphics.rectangle('fill', knobX - self.width/2, knobY - self.width/2, self.width, self.width)
    elseif self.knob == 'circle' then
        love.graphics.circle('fill', knobX, knobY, self.width/2, 4)
        love.graphics.setColor(0, 184 / 255, 148 / 255, 1)
        love.graphics.circle('fill', knobX, knobY, self.width/4, 4)
        love.graphics.setColor(1,1,1,1)
    end
end

function slider:getValue()
    return self.min + self.value * (self.max - self.min)
end
