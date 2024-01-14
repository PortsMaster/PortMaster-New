-- Loading all required libraries
require 'lib'

DEBUG = false

-- loading game options
game.paused = false
game.subpixel = (gamedata.get("subpixel", "settings.sav") == nil) and false or gamedata.get("subpixel", "settings.sav")
game.options = {
    fullscreen = gamedata.get("fullscreen", "settings.sav") or false,
    music = gamedata.get("music", "settings.sav") or 0.6,
    sfx = gamedata.get("sfx", "settings.sav") or 0.7
}

game.stats = {
    deaths = gamedata.get("deaths", "stats.sav") or 0,
    time = gamedata.get("time", "stats.sav") or 0,
    jumps = gamedata.get("jumps", "stats.sav") or 0,
}

game.playing = false
game.selectStage = nil

if love.system.getOS() == "Web" then
    game.options.fullscreen = false
end

if game.options.fullscreen then
    love.window.setFullscreen(game.options.fullscreen)
end

-- Making a shortcut so I don't have to write the full path every time.
resource.pathToImages = 'res/sprite/'
resource.pathToFonts  = 'res/font/'

-- Setting game rooms path
room.setRooms('res/room/')

-- default graphic settings for pixel art
local WIDTH, HEIGHT = 64, 64

graphics.setDefaultFilter('nearest', 'nearest')
graphics.setLineStyle("rough")
graphics.setLineWidth(1)

color.white    = color('ffffff')
color.black    = color('000000')
color.brown    = color('743f39')
color.yellow   = color('ffe762')
color.gray     = color('afbfd2')

color.white:set()
color.brown:setBackground()


-- Custom scripts
game.level   = require 'res.script.level'

-- loading all objects (you can manage this however you like)
---@diagnostic disable-next-line: lowercase-global
objects = require.tree('res/object')

-- Custom font
font.main = resource.imageFont('main-font.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\':"()[] !,-|_+/*\\?.%@><')
graphics.setFont(font.main)




-- Input profile 
input.action("left")
    :bindKey("left")
    :bindKey("a")
    :bindGamepad("dpleft")

input.action("right")
    :bindKey("right")
    :bindKey("d")
    :bindGamepad("dpright")

input.action("ui_up")
    :bindKeyPressed("up")
    :bindKeyPressed("w")
    :bindGamepadPressed("dpup")

input.action("ui_down")
    :bindKeyPressed("down")
    :bindKeyPressed("s")
    :bindGamepadPressed("dpdown")

input.action("ui_left")
    :bindKeyPressed("left")
    :bindKeyPressed("a")
    :bindGamepadPressed("dpleft")

input.action("ui_right")
    :bindKeyPressed("right")
    :bindKeyPressed("d")
    :bindGamepadPressed("dpright")

input.action("ui_select")
    :bindKeyPressed("return")
    :bindKeyPressed("space")
    :bindKeyPressed("z")
    :bindGamepadPressed("a")
    :bindGamepadPressed("b")

input.action("ui_pause")
    :bindKeyPressed("escape")
    :bindKeyPressed("p")
    :bindGamepadPressed("start")
    :bindGamepadPressed("back")

input.action("jump")
    :bindKeyPressed("up")
    :bindKeyPressed("w")
    :bindKeyPressed("space")
    :bindKeyPressed("z")
    :bindGamepadPressed("a")
    :bindGamepadPressed("y")
    :bindGamepadPressed("dpup")

input.action("restart")
    :bindKeyPressed("r")


-- input.action("hold_jump")
--     :bindKey("up")
--     :bindKey("w")
--     :bindKey("space")
--     :bindKey("z")
--     :bindGamepadPressed("a")
--     :bindGamepadPressed("y")
--     :bindGamepadPressed("dpup")

input.action("action")
    :bindKey("x")
    :bindKey("return")
    :bindKey("lalt")
    :bindGamepadPressed("x")
    :bindGamepadPressed("b")

-- LDTK setup
ldtk:load("res/ldtk/game.ldtk")
ldtk:setFlipped(true)

-- Sound on web browser is way louder than on system
local SOUND_ENHANCEMENT = love.system.getOS() == "Web" and 1 or 3
function game.playSound(sound)
    TEsound.play("res/audio/" .. sound, 'static', "sfx", 1)
    TEsound.volume("sfx", game.options.sfx * SOUND_ENHANCEMENT)
end

TEsound.playLooping("res/audio/music/floating-cat.mp3", "stream", "music")
TEsound.volume("music", game.options.music * 0.5)

function ldtk.onLevelLoaded(levelData)
    -- Free up memory
    collectgarbage()

    -- Set the camera offset
    camera.x = levelData.props.x
    camera.y = levelData.props.y

    -- Remove all objects from the world
    room.clear()

    -- Reset the level events and listeners
    game.level:resetListeners()
    game.level:resetEvents()

    -- Set the background color
    graphics.setBackgroundColor(levelData.backgroundColor)

    game.level.data = levelData
    game.paused = false
    game.player = nil

    game.timeScale = 1
    game.crown = nil
    game.won = false
    game.saveStats = true

    if levelData.props.save then
        gamedata.set(ldtk:getCurrentName(), true, "game.sav")
    end
    
end

function ldtk.onLevelCreated(levelData)
    if levelData.props.create then
        loadstring(levelData.props.create)()
    end


    objects.splash_out(32, 32)

end

function ldtk.onEntity(entity)
    local obj = objects[entity.props._id]
    if obj then
        obj(entity)
    end
end

function ldtk.onLayer(layer)
    objects.ldtk_layer(layer):setLayer(ldtk.countOfLayers - layer.order + 1)
end


function love.load()
    -- loading the game.
    game.load()

    -- set resolution
    camera.setBaseResolution(WIDTH, HEIGHT, true)
    
    -- loading the first/default room.
    room.goTo('main')
    
    -- load shadows
    game.shadows = (require 'res.script.shadows')()
end

-- Pause the game while moving the window.
local cap = 0.1

-- Set custom fps
local rate = 1 / 40
local timer = 0

local isWeb = love.system.getOS() == "Web"

function love.update(dt)
    -- cap fps to 30 if subpixel is disabled
    if not game.subpixel then
        timer = timer - dt
        if timer <= 0 then
            dt = rate
            timer = rate + timer
        else
            return
        end
    end

    -- fullscreen is forced to false on web on escape
    if isWeb and input.keyPressed("escape") then
        game.options.fullscreen = false
    end
    
    if dt < cap then
        -- update the game.
        game.update(dt)

        -- update game events
        game.level:updateEvents()

    end
end

function love.draw()
    -- Draw the game to the screen.
    game.draw()
end

function love.resize()
    -- Updates the camera when the window is resized.
    camera.updateWindowSize()

end
