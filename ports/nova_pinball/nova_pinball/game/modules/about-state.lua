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

local about = {}
local sprites = {}
local scrollManager = require("modules.line-scroller")
local aboutHeading = scrollManager:new()
local aboutDetail = scrollManager:new()
local aboutLineIndex = 1
local aboutLines = {
    {"NOVA PINBALL", "VERSION " .. VERSION},
    {"CREATED BY", "Wesley \"Keyboard Monkey\" Werner"},
    {"MADE WITH LÖVE", "love2d.org"},
    {"COPYLEFT", "GNU General Public License"},
    {"YOU ARE FREE TO", "Copy, Study, Modify the game"},

    {"THANKS", "TO", 0},
    {"Music", "Beyond"},
    {"LED Board-7 Font", "Sizenko Alexander"},
    {"Erbos Draco NBP Font", "Nate Halley"},
    {"SFXR SOUND GENERATOR", "Tomas Pettersson"},

    {"SPECIAL THANKS", "JADE :]"},
    
    {"POWERED BY", "Kittens", 0},
    {"WWW", "wesleywerner.github.io/nova-pinball", 10},
    }

function about:load()
    -- Position where the about text heading and detail will move towards
    aboutDetail.y = aboutDetail.y + 60
    aboutDetail.startX = scrWidth * 1.4
    aboutDetail.goalX = scrWidth / 10
    aboutHeading.startX = -scrWidth * 0.6
    aboutHeading.goalX = scrWidth / 3
end

function about:update(dt)
    aboutHeading:update(dt)
    aboutDetail:update(dt)
    -- Display the next information line
    if (not aboutHeading:busy() and not aboutDetail:busy()) then
        local line = aboutLines[aboutLineIndex]
        aboutHeading:go(line[1], line[3])   -- Heading & pause time
        aboutDetail:go(line[2], line[3])    -- Detail & pause time
        aboutLineIndex = aboutLineIndex + 1
        if (aboutLineIndex > #aboutLines) then aboutLineIndex = 1 end
    end
end

function about:draw()
    -- texts
    love.graphics.setColor(0.5, 1, 1, 1)
    aboutHeading:draw()
    love.graphics.setColor(1, 1, 0.5, 1)
    aboutDetail:draw()
end

function about:forward()
    aboutDetail:out()
    aboutHeading:out()
end

return about
