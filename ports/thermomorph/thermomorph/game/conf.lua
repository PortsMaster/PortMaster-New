function love.conf(t)
  t.version = "11.1"
  t.window.resizable = true
  t.window.highdpi = true

  t.window.title = "Thermomorph"
  t.window.icon = 'assets/ui/icon.png'

  t.identity = "thermomorph"

  t.window.width = 1280
  t.window.height = 720
  t.window.vsync = true

  t.window.minwidth = 100
  t.window.minheight = 100

  t.modules.joystick = false
end
