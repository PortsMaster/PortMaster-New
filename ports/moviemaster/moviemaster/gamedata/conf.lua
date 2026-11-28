function love.conf(t)
  t.identity = "moviemaster"
  t.version = "11.5"
  t.console = false
  t.accelerometerjoystick = false
  t.gammacorrect = false

  t.window.title = "Movie Master vs Garbage"
  t.window.width = 640
  t.window.height = 480
  t.window.resizable = false
  t.window.vsync = 1
  -- On the handheld the game always fills the screen. Set MM_WINDOWED=1 to
  -- run it in a 640x480 window on a computer.
  t.window.fullscreen = os.getenv("MM_WINDOWED") == nil
  t.window.fullscreentype = "desktop"

  t.modules.physics = false
  t.modules.video = false
  t.modules.touch = false
end
