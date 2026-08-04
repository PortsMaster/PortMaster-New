function love.conf(t)
    t.identity = 'balatro-buttonsetup'
    t.version = '11.5'
    t.console = false

    t.window.title = 'Balatro - Button Setup'
    t.window.width = 0
    t.window.height = 0
    t.window.fullscreen = true
    t.window.fullscreentype = 'desktop'
    t.window.borderless = true
    t.window.resizable = false
    t.window.vsync = 1

    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
    t.modules.video = false
    t.modules.thread = false
    t.modules.touch = false
end
