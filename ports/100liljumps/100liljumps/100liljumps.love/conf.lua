function love.conf(t)
    t.identity = "100 lil jumps"        -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.version = "11.5"                  -- The LÖVE version this game was made for (string)
    t.console = false                   -- Attach a console (boolean, Windows only)

    t.window.title = "100 lil jumps"   -- The window title (string)
    t.window.resizable = true           -- Let the window be user-resizable (boolean)

    t.modules.physics = false           -- Enable the physics module (boolean)
    t.modules.thread = false            -- Enable the thread module (boolean)
    t.modules.touch = true             -- Enable the touch module (boolean)
    t.modules.video = false             -- Enable the video module (boolean)
end
