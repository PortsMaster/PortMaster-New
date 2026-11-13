-- Shared copy: recipes/templates/includes/extract/

function love.conf(t)
    t.identity = "pm-extract"
    t.version = "11.4"
    t.console = false

    t.window.title = "Extracting"
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1

    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
    t.modules.video = false
    t.modules.touch = false
end
