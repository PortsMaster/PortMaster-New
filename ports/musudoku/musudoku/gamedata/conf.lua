-- The saved Sound effects setting, read before the modules load. Anything
-- unexpected counts as on.
local function soundOn(identity)
    local ok, settings = pcall(function()
        love.filesystem.setIdentity(identity)
        return require("src.storage").loadSettings()
    end)
    return not (ok and settings.sound == false)
end

function love.conf(t)
    t.version = "11.5"
    t.identity = "musudoku"
    t.console = false

    t.window.title = "muSudoku"
    t.window.width = 720
    t.window.height = 480
    t.window.resizable = false
    t.window.vsync = 1
    t.window.highdpi = true -- sharp text on Retina Macs; no effect on handhelds

    -- With sound effects off, the audio modules stay out: their mixer runs
    -- all the time, even when silent. sound.lua loads them if sound is
    -- turned on later.
    t.modules.audio = soundOn(t.identity)
    t.modules.sound = t.modules.audio
    t.modules.joystick = true
    t.modules.mouse = false
    t.modules.touch = false
    t.modules.physics = false
    t.modules.video = false
    t.modules.thread = false
end
