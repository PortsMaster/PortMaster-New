-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- This is a very basic line scroller:
-- Words move in, pause, and move out.
-- Call new() to create new scrollers, and set startX and goalX.
-- Works going both directions.

local scroll = {pauseTime=3}

function scroll:new()

    local T = {}

    -- Initial values
    T.startX = scrWidth
    T.goalX = 0
    T.x = scrWidth
    T.y = scrHeight / 2
    T.alpha = 1
    T.color = {1, 1, 1, 1}
    T.text = ""
    T.pauseTimer = scroll.pauseTime
    -- Modes can be: IN, PAUSE, OUT, NONE
    T.mode = "NONE"

    function T:update(dt)
        if (self.mode == "IN") then
            -- A very basic easing function that is bi-directional
            local dir = (self.goalX - self.x < 0) and -1 or 1
            self.x = self.x + (dt * dir * math.max(100, math.abs(self.goalX - self.x)))
            if math.abs(self.goalX - self.x) < 10 then
                self.mode = "PAUSE"
            end
        elseif (self.mode == "OUT") then
            -- A very basic easing function that is bi-directional
            local dir = (self.startX - self.x < 0) and -1 or 1
            self.x = self.x + (dt * 800 * dir)
            if math.abs(self.startX - self.x) < 10 then
                self.mode = "NONE"
            end
        elseif (self.mode == "PAUSE") then
            self.pauseTimer = self.pauseTimer - dt
            if (self.pauseTimer < 0) then
                self.mode = "OUT"
            end
        end
    end

    function T:draw()
        love.graphics.print(self.text, self.x, self.y)
    end

    -- Set the text value and reset the positions to the start
    function T:go(value, optionalPauseTime)
        self.text = value
        self.x = self.startX
        self.mode = "IN"
        self.pauseTimer = optionalPauseTime or scroll.pauseTime
    end

    -- Forcibly remove this scroller
    function T:out()
        self.mode = "OUT"
    end

    -- Checks if the scroller is busy displaying
    function T:busy()
        return self.mode ~= "NONE"
    end

    return T

end

return scroll
