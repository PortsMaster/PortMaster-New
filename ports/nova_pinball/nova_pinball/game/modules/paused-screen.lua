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

local screen = {}

function screen:load()

--  [pauseBox]
--  +-----------------------+
--  |      [titleBox]       |
--  +                       |
--  |      [trackBox]       |
--  +                       |
--  |      [hintBoX]   [vol]|
--  +-----------------------+
    
    local cutter = require("modules.cutter") 
    screen.pauseBox = cutter.cut(0.9, 0.5)
    screen.titleBox = cutter.cut(1, 0.1, "top", screen.pauseBox)
    screen.trackBox = cutter.cut(0.9, 0.5, "center", screen.pauseBox)
    screen.hintBox = cutter.cut(1, 0.1, "bottom", screen.pauseBox)
    screen.volumeBox = cutter.cut(0.05, 0.1, "bottom right", screen.pauseBox)
    -- adjusted a little up
    screen.volumeBox.y = screen.volumeBox.y - 10
    local W, H = love.graphics.getDimensions()
    screen.width = W
    screen.height = H
end

function screen:update(dt)
    
end

function screen:draw()
    
    love.graphics.setLineWidth(6)
    
    -- Full screen overlay
    love.graphics.setColor(0, 0, 0, 200/256)
    love.graphics.rectangle(
        "fill", 0 , 0, 
        screen.width, 
        screen.height)
    
    -- Box Fill
    love.graphics.setColor(0, 0.5, 0.5, 200/256)
    love.graphics.rectangle(
        "fill",
        screen.pauseBox.x, 
        screen.pauseBox.y, 
        screen.pauseBox.width, 
        screen.pauseBox.height)
    
    -- Box Outline
    love.graphics.setColor(200/256, 1, 200/256, 200/256)
    love.graphics.rectangle(
        "line",
        screen.pauseBox.x, 
        screen.pauseBox.y, 
        screen.pauseBox.width, 
        screen.pauseBox.height)
    
    -- Box Title
    printShadowText("PAUSED", 
        screen.titleBox.center.y,
        {200/256, 1, 200/256, 1})
    
    if screen:drawNowPlayingTrack() then
        screen:drawVolumeBar()
    end
    
end

function screen:keypressed(key)
    if key == "left" then
        playlist:prevTrack()
    elseif key == "right" then
        playlist:nextTrack()
    elseif key == "up" then
        playlist:volumeUp()
    elseif key == "down" then
        playlist:volumeDown()
    end
end

function screen:drawVolumeBar()
    -- Volume Bar
    love.graphics.setLineWidth(2)
    -- (fill)
    love.graphics.setColor(0, 200/256, 0, 200/256)
    love.graphics.rectangle(
        "fill",
        screen.volumeBox.x, 
        screen.volumeBox.y, 
        20, 
        screen.volumeBox.height)
    -- (outline)
    love.graphics.setColor(0, 0, 0, 100/256)
    love.graphics.rectangle(
        "line",
        screen.volumeBox.x, 
        screen.volumeBox.y,
        20, 
        screen.volumeBox.height)
    -- (green bar)
    love.graphics.setColor(0, 0, 0, 200/256)
    love.graphics.rectangle(
        "fill",
        screen.volumeBox.x,
        screen.volumeBox.y,
        20,
        screen.volumeBox.height - (screen.volumeBox.height * playlist:volumeDecimal()))
end

function screen:drawNowPlayingTrack()
    -- Now Playing
    local track = playlist:nowplaying()
    
    -- There is a track playing
    if track then
        
        -- Format the track artist & title
        local title = string.format("Now Playing Track %s\n\n%q by %s\n\n%s", 
                        playlist.trackIndex, track.title, track.artist, track.nfo)
        
        -- Calculate the width and line count of the track title
        love.graphics.setFont(smallFont)
        local titleWidth, titleLines = smallFont:getWrap(
            title, screen.trackBox.width)
        local titleHeight = smallFont:getHeight()
        
        love.graphics.setLineWidth(1)
        
        -- Draw an insert box for the title
        -- (Fill)
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("fill", 
            screen.trackBox.x, 
            screen.trackBox.y,
            screen.trackBox.width,
            screen.trackBox.height)
        -- (Lines)
        love.graphics.setColor(1, 1, 1, 100/256)
        love.graphics.rectangle("line", 
            screen.trackBox.x - 0,
            screen.trackBox.y - 0,
            screen.trackBox.width - 2,
            screen.trackBox.height - 2)
        
        -- Print the track title (inside the inset box)
        love.graphics.setColor(1, 1, 200/256, 1)
        love.graphics.printf(title, 
            screen.trackBox.x + 6,
            screen.trackBox.y + 6,
            screen.trackBox.width,
            "left")

        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.printf("Arrows - Skip + Volume",
            screen.hintBox.x,
            screen.hintBox.y,
            screen.hintBox.width,
            "center")
        
        -- Signal there is a track playing
        return true
    end
end

screen:load()

return screen