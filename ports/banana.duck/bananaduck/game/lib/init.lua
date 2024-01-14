---@diagnostic disable: lowercase-global
-- You have entered the fobidden land of the dark code.
-- Filled with globals and possibly bad habits, it kindly asks you to leave.
-- Its quality is not meant to be anywhere professional, yet it's filled with
-- love (quite literally), passion, and drugs.
-- You have been warned.

--------- [LIBRARIES] ---------

-- /Third-Party
class       = require 'lib.third-party.class'
vector      = require 'lib.third-party.vector'
lume        = require 'lib.third-party.lume'
tick        = require 'lib.third-party.tick'
json        = require 'lib.third-party.json'
TEsound     = require 'lib.third-party.tesound'
bump        = require 'lib.third-party.bump'
require 'lib.third-party.require'


-- /main
resource    = require 'lib.resource'
object      = require 'lib.object'
room        = require 'lib.room'
gamedata    = require 'lib.gamedata'
color       = require 'lib.color'
sprite      = require 'lib.sprite'
input       = require 'lib.input'
camera      = require 'lib.camera'
collision   = require 'lib.collision'
ldtk        = require 'lib.ldtk'
physics     = require 'lib.physics'
global      = {}

-- /LÖVE modules
audio       = love.audio
data        = love.data
event       = love.event
filesystem  = love.filesystem
font        = love.font
graphics    = love.graphics
image       = love.image
joystick    = love.joystick
keyboard    = love.keyboard
mouse       = love.mouse
--physics     = love.physics
sound       = love.sound
system      = love.system
thread      = love.thread
timer       = love.timer
touch       = love.touch
video       = love.video
window      = love.window

-- loads the default 'data' save file.
gamedata.load()

--------- [Functions] ---------
game = {
    timeScale = 1,
}

function game.load()
    -- load input (this overwrites default love input callbacks)
    input.setup()

    game.world = bump.newWorld(8)
end

function game.update(dt)
    dt = dt * game.timeScale

    -- main game update loop
    room.update(dt)

    -- update tick/timer library
    tick.update(dt)

    -- update the save files (only if changed).
    gamedata.update()

    -- update the camera (used for screen shakes)
    camera.update(dt)

    -- update input
    input.update(dt)

    -- cleanup sound
    TEsound.cleanup()
end

function game.draw()
    -- sets the camera
    camera.set()
    
    -- main game draw loop
    room.draw()

    if DEBUG then
        -- draws the FPS counter
        color.white:set()
        graphics.print("FPS: " .. tostring(love.timer.getFPS()), camera.x + 2, camera.y + 2)
    end

    -- unsets the camera
    camera.unset()

    -- draws borders if needed
    camera.drawBorders()
end

-- /Extra functionality for math, table, and string.
require 'lib.custom'