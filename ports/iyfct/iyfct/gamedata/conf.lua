function love.conf(t)
    t.identity = "iyfct"
    t.version = "11.1"
    t.console = false

    t.window.title = "In Your Face City Trains"
    t.window.icon = nil
    t.window.width = 900
    t.window.height = 300
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.vsync = true

    t.modules.joystick = false
    t.modules.mouse = false
    t.modules.physics = false
end
