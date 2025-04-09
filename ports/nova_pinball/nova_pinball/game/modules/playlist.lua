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

-- This music playlist controls song looping, volume and queuing.

local playlist = {}

playlist.turnedOn = false

playlist.trackIndex = 1

playlist.source = nil

playlist.playedCount = 0

playlist.tracks = {}

playlist.random = false

playlist.isFadingOut = false

-- Adjust all tracks by this volume amount
playlist.volumeAdjust = 0

-- The time current track has been playing
playlist.playedTime = 0

-- The maximum number of seconds a track can play for (looped)
playlist.maxPlayTime = 180

function playlist:load()
    self:refreshTracks()
    if playlist.random then
        playlist.trackIndex = math.random(1, #playlist.tracks)
    end
end

function playlist:refreshTracks()
    playlist.tracks = {}
    local files = love.filesystem.getDirectoryItems("music")
    for i, file in pairs(files) do
        -- skip nfo files at this time
        if not string.find(file, ".nfo$") then
            self:addTrack("music", file)
        end
    end
end

-- Add a track and read an optional nfo file.
-- nfo format:
-- Lines with the format key=value are stored on the track object
-- as track[key] = value.
-- All other lines are stored on the track.nfo value.
-- Possible keys:
--      title, loop, volume
function playlist:addTrack(path, filename)
    local nfopath = path .. "/" .. filename .. ".nfo"
    local infoExists = love.filesystem.getInfo(nfopath)
    local track = {}
    track.file = path .. "/" .. filename
    track.volume = 1
    track.nfo=""
    track.loop = 1
    track.title = filename
    track.artist = ""
    
    -- Extract the track nfo file
    if infoExists then
        
        for line in love.filesystem.lines(nfopath) do
            
            -- check for loop setting lines
            local i, j = string.find(line, "=")
            
            if i and j then
                -- map the key-value pair to the track table
                local k = line:sub(1, i-1)
                local v = line:sub(j+1, line:len())
                -- attempt cast to number
                local vi = tonumber(v)
                track[k] = vi or v
            else
                track.nfo = track.nfo .. line .. "\n"
            end
        end
    end
    table.insert(playlist.tracks, track)
end

-- Plays the track set in trackIndex
function playlist:_play()
    -- Reset played count
    playlist.playedCount = 1
    -- Reset play time
    playlist.playedTime = 0
    local track = playlist.tracks[playlist.trackIndex]
    playlist.source = love.audio.newSource(track.file, "stream")
    playlist.source:setLooping(true)
    playlist.source:setVolume(track.volume + playlist.volumeAdjust)
    love.audio.play(playlist.source)
end
        
-- Start playing music. The optional title of a track can be given to play.
function playlist:play(title)
    playlist.turnedOn = true
    if title then
        for i, track in pairs(playlist.tracks) do
            if track.title == title then
                playlist.trackIndex = i
                playlist:_play()
                break
            end
        end
    end
end

function playlist:pauseUnpause()
    if (playlist.turnedOn and playlist.source) then
        if (not playlist.source:isPlaying()) then
            playlist.source:play()
        else
            playlist.source:pause()
        end
    end
end

function playlist:stop()
    playlist.turnedOn = false
    playlist.isFadingOut = true
    -- Fade faster than default
    playlist.fadeSpeed = 2
end

function playlist:update(dt)
    
    -- Fade out
    if (playlist.source and playlist.isFadingOut) then
        local v = playlist.source:getVolume()
        v = v - dt*(playlist.fadeSpeed or 0.05)
        if v < 0 then
            love.audio.stop(playlist.source)
            playlist.source = nil
            playlist.isFadingOut = false
            playlist.fadeSpeed = nil
        else
            playlist.source:setVolume(v)
        end
    end

    -- The playlist is on
    if (playlist.turnedOn) then
        
        -- There is nothing playing
        if (not playlist.source) then
                        
            -- Find the last track played
            local track = playlist.tracks[playlist.trackIndex]
            
            -- Up the track play count
            playlist.playedCount = playlist.playedCount + 1
            
            -- This track is done looping
            if (playlist.playedCount > track.loop) then
                
                -- Next track or randomize
                if playlist.random then
                    playlist.trackIndex = math.random(1, #playlist.tracks)
                else
                    playlist.trackIndex = playlist.trackIndex + (playlist.skipOffset or 1)
                    playlist.skipOffset = nil
                end
                
                -- Cycle back to the beginning of the playlist
                if (playlist.trackIndex > #playlist.tracks) then
                    playlist.trackIndex = 1
                elseif (playlist.trackIndex < 1) then
                    playlist.trackIndex = #playlist.tracks
                end
            end
            
            -- Start playing
            self:_play()
            
        else
            -- Track is finished playing
            if (not playlist.source:isPlaying()) then
                playlist.source = nil
            elseif (playlist.playedTime > playlist.maxPlayTime) then
                playlist.isFadingOut = true
            else
                playlist.playedTime = playlist.playedTime + dt
            end        
        end
    end
end

-- Gets the track playing
function playlist:nowplaying()
    if (not playlist.isFadingOut and playlist.turnedOn) then
        return playlist.tracks[playlist.trackIndex]
    end
end

function playlist:prevTrack()
    playlist.isFadingOut = true
    -- Skip the loop count too
    playlist.playedCount = playlist.tracks[playlist.trackIndex].loop
    -- Cycle around
    playlist.skipOffset = -1
    -- Fade faster than default
    playlist.fadeSpeed = 2
end

function playlist:nextTrack()
    playlist.isFadingOut = true
    -- Skip the loop count too
    playlist.playedCount = playlist.tracks[playlist.trackIndex].loop
    -- Fade faster than default
    playlist.fadeSpeed = 2
end

function playlist:volumeUp()
    local track = self:nowplaying()
    if track and playlist.source then
        playlist.volumeAdjust = math.max(-1, math.min(0, playlist.volumeAdjust + 0.1))
        playlist.source:setVolume(track.volume + playlist.volumeAdjust)
    end
end

function playlist:volumeDown()
    local track = self:nowplaying()
    if track and playlist.source then
        playlist.volumeAdjust = math.max(-1, math.min(0, playlist.volumeAdjust - 0.1))
        playlist.source:setVolume(track.volume + playlist.volumeAdjust)
    end
end

-- Returns the music volume
function playlist:volumePercentage()
    return (1 + playlist.volumeAdjust) * 100
end

function playlist:volumeDecimal()
   return (1 + playlist.volumeAdjust) 
end

return playlist
