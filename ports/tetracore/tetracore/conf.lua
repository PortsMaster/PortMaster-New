local GameConfig = require("src.constants.gameConfig")

function love.conf(t)
    t.title = GameConfig.WINDOW.TITLE                  	-- The title of the window the game is in
    t.version = "11.5"                               	-- The LÖVE version this game was made for
    t.window.width = GameConfig.WINDOW.DEFAULT_WIDTH   	-- Game's default window width
    t.window.height = GameConfig.WINDOW.DEFAULT_HEIGHT 	-- Game's default window height
    t.window.resizable = GameConfig.WINDOW.RESIZABLE   	-- Let the user resize the window
    t.console = GameConfig.DEBUG.ENABLE_CONSOLE        	-- Enable console output for debugging
    t.window.fullscreen = GameConfig.WINDOW.FULLSCREEN  -- Enable fullscreen (boolean)
    t.identity = "TetraCore"                           	-- The name of the save directory (string)
    t.appendidentity = true                            	-- Search files in source directory before save directory
    t.icon = "assets/icon.png"
    t.modules.joystick = GameConfig.MODULES.JOYSTICK   	-- Enable joystick module
    t.modules.physics = GameConfig.MODULES.PHYSICS     	-- Disable the physics module
    t.modules.video = false
    t.modules.touch = false
    t.modules.mouse = false
end
