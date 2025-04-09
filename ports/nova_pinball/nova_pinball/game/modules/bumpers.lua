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

-- Manages bumpers.
-- Tracks bumper states when hit to draw at varying scales.
-- Add bumpers with :add(tag)
-- Update their status with :update(dt)
-- Call :hit(tag) when hit.

local manager = { }
manager.bumpers = { }

function manager:add(tag, image, flipX, flipY)
    local s = loadSprite(image)
    s.hitCooldown = 0
    s.flipX = flipX or 1
    s.flipY = flipY or 1
    self.bumpers[tag] = s
end

function manager:draw(tag, x, y)
    love.graphics.setColor(1, 1, 1, 1)
    local bumper = self.bumpers[tag]
    if (bumper) then
        local scaleX = bumper.flipX
        local scaleY = bumper.flipY
        -- draw larger after a hit
        if (bumper.hitCooldown > 0) then
            scaleX = bumper.flipX * 1.1
            scaleY = bumper.flipY * 1.1
        end
        love.graphics.draw(bumper.image, x, y, 0, scaleX, scaleY, bumper.ox, bumper.oy)
    end
end

function manager:hit(tag)
    local bumper = self.bumpers[tag]
    if (bumper) then
        bumper.hitCooldown = 0.1
    end
end

function manager:update(dt)
    for _, v in pairs(self.bumpers) do
        if (v.hitCooldown > 0) then
            v.hitCooldown = v.hitCooldown - dt
        end
    end
end
        
return manager
