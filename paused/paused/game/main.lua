-- Loading all required libraries
require 'lib'

-- Globals
global.BASE_WIDTH   = 128
global.BASE_HEIGHT  = 128

global.showLinks = true

-- Setting up game
require 'setup'

function love.load()
    -- loading the game.
    game.load()

    -- set resolution
    camera.setBaseResolution(global.BASE_WIDTH, global.BASE_HEIGHT, false)

    -- loading the first/default room.
    room.goTo('loader')

end

function love.update(dt)
    -- Only update if the fps is good enough
    -- A simple workaround to stop the game while moving the window
    if dt < 0.05 then
        -- update the game.
        game.update(dt)
    end
end

function love.draw()
    -- Draw the game to the screen.
    game.draw()
end

function love.resize()
    -- Updates the camera whenever the window is resized.
    camera.updateWindowSize(4, 1)
    
    -- updating fullscreen state on web
    if global.isWeb then
        global.settings.fullscreen = window.getFullscreen()
    end
end