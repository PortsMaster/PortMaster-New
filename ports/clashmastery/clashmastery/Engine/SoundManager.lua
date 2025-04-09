local SoundManager = {}

function SoundManager.initialize(soundDirectory, extension)
    -- Get all the files in the Sounds directory
    local soundFiles = love.filesystem.getDirectoryItems(soundDirectory)
    local soundFileNames = {}
    for k = 1,#soundFiles do
        local ind = string.find(soundFiles[k], "%.")
        soundFileNames[k] = string.sub(soundFiles[k], 1, ind-1)
    end
    SoundManager.allSounds = {}
    SoundManager.volumeScale = 0.5
    for index,value in ipairs(soundFileNames) do
        SoundManager.allSounds[value] = love.audio.newSource(soundDirectory.."/"..value..extension, "static")
    end
end

-- Coroutine version of the above function that allows for loading bar
function SoundManager.initializeRoutine()
    -- Get all the files in the Sounds directory
    local soundFiles = love.filesystem.getDirectoryItems("Sounds")
    local soundFileNames = {}
    for k = 1,#soundFiles do
        local ind = string.find(soundFiles[k], "%.")
        soundFileNames[k] = string.sub(soundFiles[k], 1, ind-1)
    end
    local numSounds = #soundFileNames
    coroutine.yield(0)
    for index,value in ipairs(soundFileNames) do
        SoundManager.allSounds[value] = love.audio.newSource("Sounds".."/"..value..".wav", "static")
        coroutine.yield(index/numSounds)
    end
end

function SoundManager.initializePropsPreload()
    SoundManager.allSounds = {}
    SoundManager.volumeScale = 0.5
end

function SoundManager.playSound(soundFileName, volume)
    if SoundManager.allSounds[soundFileName]:isPlaying() then
        SoundManager.allSounds[soundFileName]:stop()
    end
    volume = volume or 1
    SoundManager.allSounds[soundFileName]:setVolume(volume * SoundManager.volumeScale)
    SoundManager.allSounds[soundFileName]:play()
end

function SoundManager.playSoundRandomizedPitch(soundFileName, minPitch, maxPitch, volume)
    SoundManager.allSounds[soundFileName]:setPitch(minPitch + (maxPitch - minPitch) * math.random())
    SoundManager.playSound(soundFileName, volume)
end

function SoundManager.stopSound(soundFileName)
    if SoundManager.allSounds[soundFileName]:isPlaying() then
        SoundManager.allSounds[soundFileName]:stop()
    end
end

function SoundManager.setVolumeScale(scale)
    SoundManager.volumeScale = scale
end

return SoundManager