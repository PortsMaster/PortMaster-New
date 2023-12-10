-- Making a shortcut so I don't have to write the full path every time.
resource.pathToImages = 'res/sprite/'
resource.pathToFonts  = 'res/font/'
resource.pathToAudio  = 'res/audio/'

-- Setting game rooms path
room.setRooms('res/room/')

graphics.setDefaultFilter('nearest', 'nearest')
graphics.setLineStyle("rough")
graphics.setLineWidth(1)

color.white    = color('ffffff')
color.black    = color('181425')
color.grey     = color('5a6988')
color.light_grey = color('c0cbdc')
color.dark_grey  = color('262b44')
color.red = color('e43b44')
color.green = color('63c74d')

color.black:setBackground()
color.white:set()

-- loading all objects (you can manage this however you like)
---@diagnostic disable-next-line: lowercase-global
objects = require.all('res/object')

-- Custom font
font.main = resource.imageFont('main-font.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\':"()[] !,-|_+/*\\?.%@')
graphics.setFont(font.main)

-- Input profile. Static for now.
input.action('up')
    :bindKey('w', 'up', 'z', 'b')
    --:bindGamepad('dpup', 'a')

input.action('down')
    :bindKey('s', 'down')
    --:bindGamepad('dpdown')

input.action('left')
    :bindKey('a', 'left')
    --:bindGamepad('dpleft')

input.action('right')
    :bindKey('d', 'right')
    --:bindGamepad('dpright')

input.action('jump')
    :bindKeyPressed('w', 'up', 'z')
    --:bindGamepadPressed('dpup', 'a')

input.action('fall')
    :bindKeyPressed('s', 'down')
    --:bindGamepadPressed('dpdown')

input.action('action')
    :bindKeyPressed('return', 'space', 'x', 'n')
    --:bindGamepadPressed('b')

input.action('pause')
    :bindKeyPressed('escape', 'p')
    --:bindGamepadPressed('start')

input.action('reload')
    :bindKeyPressed('r')
    --:bindGamepadAxis('triggerleft')


-- ui
input.action('ui_up')
    :bindKeyPressed('w', 'up')
    --:bindGamepadPressed('dpup')

input.action('ui_down')
    :bindKeyPressed('s', 'down')
    --:bindGamepadPressed('dpdown')

input.action('ui_left')
    :bindKeyPressed('a', 'left')
    --:bindGamepadPressed('dpleft')

input.action('ui_right')
    :bindKeyPressed('d', 'right')
    --:bindGamepadPressed('dpright')

input.action('ui_action')
    :bindKeyPressed('return', 'space', 'x')
    --:bindGamepadPressed('a', 'b')

-- Loading settings and data
global.isWeb = system.getOS() == 'Web'

global.settings = {
    fullscreen = gamedata.get('fullscreen') or false,
    sound = gamedata.get('sound') or 6,
    music = gamedata.get('music') or 7,
    screenShakes = gamedata.get('screenShakes') or 0.75,
}

TEsound.volume('sound', global.settings.sound / 10)
TEsound.volume('music', global.settings.music / 10)

function global.setSound(sound)
    if sound > 10 then
        sound = 0
    end

    if sound < 0 then
        sound = 10
    end

    gamedata.set('sound', sound)
    global.settings.sound = sound
    TEsound.volume('sound', sound / 10)
end

function global.setMusic(music)
    if music > 10 then
        music = 0
    end

    if music < 0 then
        music = 10
    end

    gamedata.set('music', music)
    global.settings.music = music
    TEsound.volume('music', music / 10)
end

function global.setScreenShakes(power)
    gamedata.set('screenShakes', power)
    global.settings.screenShakes = power
    camera.setShakePower(global.settings.screenShakes)
end

function global.setFullscreen(fullscreen)
    gamedata.set('fullscreen', fullscreen)
    global.settings.fullscreen = fullscreen
    window.setFullscreen(fullscreen)
    camera.updateWindowSize(4, 1)
    if (not fullscreen) and global.isWeb then
        if love.resize then love.resize() end
    end
end


global.setScreenShakes(global.settings.screenShakes)

if global.isWeb then
    -- The game should never start in fullscreen on web
    global.setFullscreen(false)
else 
    global.setFullscreen(global.settings.fullscreen)
end

function global.playSound(sound)
    TEsound.play(resource.pathToAudio .. 'sound/' .. sound, 'static', 'sound')
end

function global.playMusic(music)
    TEsound.playLooping(resource.pathToAudio .. 'music/'.. music, 'stream', 'music')
end

function global.stopMusic()
    TEsound.stop('music')
end

-- Globals
global.game = {

}

global.game.collisions = {
    characters = {},
    blocks = {},
    jumpThrough = {},
    boxes = {},
    kill = {},
    air = {},
    ids = {}
}

global.game.level = {
    funcs = {},
}


-- Game Language (not used)
--language = require 'res.script.language'
--language:searchFolder('res/language/')
--language:setLanguage('English')
