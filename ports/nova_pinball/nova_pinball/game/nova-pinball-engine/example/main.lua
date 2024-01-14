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

-- Nova pinball engine example
-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- The pinball table editor was used to create the table layout.
-- The table file is nothing more than a pickled lua table.
-- You are free to deconstruct the table format, or look at the editor code.

-- This example shows the bare minimum to get a pinball game up and running.

-- Requiring "." loads init.lua from this example directory.
-- For better organization you can place the engine in `nova-pinball-engine\init.lua`
-- and require("nova-pinball-engine").
local pinball = require(".")

function love.load()

    love.graphics.setBackgroundColor(0, 0, 0)

    -- Load the table layout into the pinball engine

    local pickledData, size = love.filesystem.read("example.pinball", nil)
    local pickle = require("pickle")
    local unpickledData = pickle.unpickle(pickledData)
    
    if (type(unpickledData) == "table" and unpickledData.identifier == "nova pinball table layout") then
        pinball:loadTable(unpickledData)
        pinball:newBall()
    else
        error("Not a valid pinball layout file")
    end

end

function love.update(dt)
    -- Update the pinball simulation
    pinball:update(dt)
end

function love.keypressed(key, isrepeat)
    if (key == "escape") then
        love.event.quit()
    elseif (key == "space") then
        pinball:newBall()
    end
    if (key == "lshift") then pinball:moveLeftFlippers() end
    if (key == "rshift") then pinball:moveRightFlippers() end
end

function love.keyreleased(key)
    if (key == "lshift") then pinball:releaseLeftFlippers() end
    if (key == "rshift") then pinball:releaseRightFlippers() end
end

function love.draw()
    pinball:setCamera()
    pinball:draw()
end

function love.resize(w, h)
    -- Recalculate positions and draw scale
    pinball:resize(w, h)
end

function pinball.drawWall(points)
    love.graphics.setLineWidth(6)
    love.graphics.setColor(92/256, 201/256, 201/256)
    love.graphics.line(points)
end

function pinball.drawBumper(tag, x, y, r)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(42/256, 161/256, 152/256)
    love.graphics.circle("fill", x, y, r * 0.8)
    love.graphics.setColor(108/256, 113/256, 196/256)
    love.graphics.circle("line", x, y, r)
end

function pinball.drawKicker(tag, x, y, points)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(108/256, 196/256, 113/256)
    love.graphics.polygon("fill", points)
end

function pinball.drawTrigger(tag, points)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(32/256, 32/256, 32/256)
    love.graphics.polygon("fill", points)
end

function pinball.drawFlipper(orientation, position, angle, origin, points)
    -- orientation is "left" or "right"
    -- position {x,y}
    -- angle is in radians
    -- origin {x,y} is offset from the physics body center
    -- points {} are polygon vertices

    love.graphics.setColor(108/256, 113/256, 196/256)
    love.graphics.polygon("fill", points)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(68/256, 73/256, 156/256)
    love.graphics.polygon("line", points)
end

function pinball.drawBall(x, y, radius)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(238/256, 232/256, 213/256)
    love.graphics.circle("fill", x, y, radius)
    love.graphics.setColor(147/256, 161/256, 161/256)
    love.graphics.circle("line", x, y, radius)
end

-- Called when a ball has drained out of play.
function pinball.ballDrained(ballsInPlay)
    if (ballsInPlay == 0) then
        pinball:newBall()
    end
end

function pinball.tagContact(tag, id)
    print("tag hit:", tag, "id:", id)

    -- Demonstrates locking the ball in place for a short period
    -- before ejecting it back into play.
    if (tag == "black hole") then
        local x, y = pinball:getObjectXY("black hole")
        local secondsDelay = 1
        local releaseXVelocity = 500
        local releaseYVelocity = 500
        pinball:lockBall(id, x, y, secondsDelay, releaseXVelocity, releaseYVelocity)
    end
end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
end
