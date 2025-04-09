local soundmanager = {}

-- Local variables for sound effects
local sounds = {}

-- Volume settings
local volumes = {
    up = 0.4,
    down = 0.4,
    left = 0.2,
    right = 0.2,
    intro = 1
}

-- Function to load sounds
function soundmanager.load()
    -- Load sound effects
    sounds.up = love.audio.newSource("assets/sounds/JDSherbert - Pixel UI SFX Pack - Cursor 2 (Square).ogg", "static")
    sounds.down = love.audio.newSource("assets/sounds/JDSherbert - Pixel UI SFX Pack - Cursor 2 (Square).ogg", "static")
    sounds.left = love.audio.newSource("assets/sounds/JDSherbert - Pixel UI SFX Pack - Cursor 3 (Square).ogg", "static")
    sounds.right = love.audio.newSource("assets/sounds/JDSherbert - Pixel UI SFX Pack - Cursor 3 (Square).ogg", "static")
    sounds.intro = love.audio.newSource("assets/sounds/JDSherbert - Pixel UI SFX Pack - Select 2 (Square).ogg", "static")

    -- Set volumes for each sound
    for key, sound in pairs(sounds) do
        if volumes[key] then
            sound:setVolume(volumes[key])
        end
    end
end

-- Function to play the 'up' sound
function soundmanager.playUp()
    if sounds.up then
        sounds.up:play()
    end
end

-- Function to play the 'down' sound
function soundmanager.playDown()
    if sounds.down then
        sounds.down:play()
    end
end

-- Function to play the 'left' sound
function soundmanager.playLeft()
    if sounds.left then
        sounds.left:play()
    end
end

-- Function to play the 'right' sound
function soundmanager.playRight()
    if sounds.right then
        sounds.right:play()
    end
end

-- Function to play the 'intro' sound
function soundmanager.playIntro()
    if sounds.intro then
        sounds.intro:play()
    end
end

return soundmanager
