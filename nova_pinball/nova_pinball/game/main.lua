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

VERSION = "11.2"
DEBUG = false
spriteManager = require("modules.sprite-state-manager")
stateManager = require ("modules.states")
playstate = nil
mainstate = nil
menu = nil
scores = nil
cfg = nil
playlist = nil
largeFont = love.graphics.newFont("fonts/advanced_led_board-7.ttf", 37)
smallFont = love.graphics.newFont("fonts/erbos_draco_1st_open_nbp.ttf", 20)
local splash = nil

function love.load(arg)

    if arg[#arg] == "-debug" then require("mobdebug").start() end
    math.randomseed(os.time())
    love.mouse.setVisible(false)
    scrWidth, scrHeight = love.graphics.getDimensions()

    -- Set up main states
    mainstate = stateManager:new()
    mainstate:add("splash", 2, "menu")
    mainstate:add("menu")
    mainstate:add("play")
    mainstate:set("splash")
    --loadAllModules()
    --mainstate:set("menu")

    splash = require("modules.splash")
    splash:load()

    love.graphics.setFont(largeFont)

end

function love.update(dt)
    dt = math.min(1/60, dt)
    mainstate:update(dt)
    if (mainstate:on("play")) then
        playstate:update(dt)
        playlist:update(dt)
    elseif (mainstate:on("splash")) then
        splash:update(dt)
    elseif (mainstate:on("menu")) then
        menu:update(dt)
        playlist:update(dt)
    end
end

function love.keypressed(key, isrepeat)
    if (mainstate:on("play")) then
        playstate:keypressed(key)
    elseif (mainstate:on("splash")) then
        splash:keypressed(key)
    elseif (mainstate:on("menu")) then
        menu:keypressed(key)
    end
end

function love.keyreleased(key)
    if (mainstate:on("play")) then
        playstate:keyreleased(key)
    elseif (mainstate:on("menu")) then
        menu:keyreleased(key)
    end
end

function love.draw()
    if (mainstate:on("play")) then
        playstate:draw()
    elseif (mainstate:on("splash")) then
        splash:draw()
    elseif (mainstate:on("menu")) then
        menu:draw()
    end
end

function love.resize(w, h)
    scrWidth, scrHeight = w, h
    playstate:resize(w, h)
end

function loadAllModules()
    if (not playstate) then
        menu = require("modules.menu-state")
        playstate = require("modules.play-state")
        scores = require("modules.scores")
        cfg = require("modules.game-config")
        playlist = require("modules.playlist")
        cfg:load()
        playlist:load()
        menu:load()
        playstate:load()
        scores:load()
    end
end

-- A global function to draw better readable words
function printShadowText(text, y, color)
    -- Shadow
    love.graphics.setColor(0, 0, 0, 200/256)
    love.graphics.printf (text, 2, y+2, scrWidth, "center")
    -- Text
    love.graphics.setColor(unpack(color))
    love.graphics.printf (text, 0, y, scrWidth, "center")
end

-- A global function to load a sprite and calculate the center point.
function loadSprite(path)
    -- Store sprites as
    --      sprite.image
    --      sprite.size     (width, height)
    --      sprite.ox       draw offset x
    --      sprite.oy       draw offset y
    local sprite = { }
    sprite.image = love.graphics.newImage (path)
    sprite.size = { sprite.image:getDimensions () }
    sprite.ox = sprite.size[1] / 2
    sprite.oy = sprite.size[2] / 2
    sprite.angle = 0
    sprite.scale = 1
    function sprite:draw()
        love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.ox, self.oy)
    end
    return sprite
end

-- Plays an audio source considering the config sound setting
function aplay(source)
    if (cfg:get("sfx") == 1) then
        love.audio.play(source)
    end
end
