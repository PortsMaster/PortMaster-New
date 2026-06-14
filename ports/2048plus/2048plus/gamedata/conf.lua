function love.conf(t)
    t.version = "11.5"
    t.console = false

    t.window.title = "2048 Plus"
    t.window.icon = nil
    t.window.width = 640
    t.window.height = 480
    t.window.borderless = false
    t.window.resizable = false
    t.window.vsync = 1
    t.window.display = 1
    t.window.highdpi = true
    t.window.x = nil
    t.window.y = nil

    t.modules.thread = false
    t.modules.audio = true
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = true
    t.modules.touch = true
    t.modules.video = false
end
