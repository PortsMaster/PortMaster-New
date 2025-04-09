local SoundManager = {}

function SoundManager.initialize(soundDirectory, soundFileNames, extension)
    SoundManager.allSounds = {}
    for index,value in ipairs(soundFileNames) do
        SoundManager.allSounds[value] = love.audio.newSource(soundDirectory.."/"..value..extension, "static")
    end
end

function SoundManager.playSound(soundFileName, volume)
    if SoundManager.allSounds[soundFileName]:isPlaying() then
        SoundManager.allSounds[soundFileName]:stop()
    end
    volume = volume or 1
    SoundManager.allSounds[soundFileName]:setVolume(volume)
    SoundManager.allSounds[soundFileName]:play()
end

return SoundManager