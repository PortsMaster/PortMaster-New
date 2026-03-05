function love.conf(t)
    t.window.title = "Jam Anywhere"
    t.window.width = 640
    t.window.height = 480
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop" -- Automatycznie rozciągnie grę na pełny ekran konsoli
    t.window.vsync = 1                  -- Zapobiega "rwie" ekranu (tearing)
    t.console = false
end