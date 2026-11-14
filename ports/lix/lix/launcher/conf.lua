-- Shared copy: recipes/templates/includes/launcher/

-- Start the game after this many seconds unless a button is pressed (0 = off)
LAUNCHER_AUTOSTART = 3

function love.conf(t)
    t.identity = "pm-launcher"
    t.version = "11.4"
    t.console = false

    t.window.title = "Setup"
    t.window.width = 640
    t.window.height = 480
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1

    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
    t.modules.video = false
    t.modules.touch = false
end
