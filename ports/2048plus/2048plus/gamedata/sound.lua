local sound = {}
local save = require("save")

local enabled = true
local achSource = nil
local splashSource = nil
local victorySource = nil
local gameOverSource = nil
local menuMoveSource = nil
local menuSelectSource = nil
local menuBackSource = nil
local toastSource = nil

local activeJoystick = nil
local joystickInitialized = false

local function getJoystick()
    if joystickInitialized then
        return activeJoystick
    end
    if love.joystick then
        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            activeJoystick = joysticks[1]
            joystickInitialized = true
        end
    end
    return activeJoystick
end

local function triangle(phase)
    local p = phase - math.floor(phase)
    if p < 0.25 then
        return 4 * p
    elseif p < 0.75 then
        return 2 - 4 * p
    else
        return 4 * p - 4
    end
end

function sound.init()
    enabled = save.loadSound()
    pcall(getJoystick)

    -- Pre-generate the sounds so they are ready to play instantly
    if love.sound and love.audio then
        local sampleRate = 44100

        -- 1. Achievement Sound (Retro Arpeggio)
        local achDuration = 0.6
        local achLength = math.floor(sampleRate * achDuration)
        local achSoundData = love.sound.newSoundData(achLength, sampleRate, 16, 1)
        local phase = 0
        for i = 0, achLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.08 then
                freq = 523.25 -- C5
                env = math.exp(-15 * t)
            elseif t < 0.16 then
                freq = 659.25 -- E5
                env = math.exp(-15 * (t - 0.08))
            elseif t < 0.24 then
                freq = 783.99 -- G5
                env = math.exp(-15 * (t - 0.16))
            else
                freq = 1046.50 -- C6
                env = math.exp(-6 * (t - 0.24))
            end
            phase = phase + freq / sampleRate
            local val = triangle(phase) * env * 0.95
            achSoundData:setSample(i, val)
        end
        achSource = love.audio.newSource(achSoundData)
        achSource:setVolume(0.60)

        -- 2. Splash Sound (Logo Pop WAV File)
        local success, src = pcall(love.audio.newSource, "assets/sfx/logo_pop.wav", "static")
        if success then
            splashSource = src
            splashSource:setVolume(1.0)
        end

        -- 3. Victory Sound (Triumphant Ascending Fanfare)
        local victoryDuration = 1.0
        local victoryLength = math.floor(sampleRate * victoryDuration)
        local victorySoundData = love.sound.newSoundData(victoryLength, sampleRate, 16, 1)
        local vPhase = 0
        for i = 0, victoryLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.07 then
                freq = 523.25 -- C5
                env = math.exp(-15 * t)
            elseif t < 0.14 then
                freq = 659.25 -- E5
                env = math.exp(-15 * (t - 0.07))
            elseif t < 0.21 then
                freq = 783.99 -- G5
                env = math.exp(-15 * (t - 0.14))
            elseif t < 0.28 then
                freq = 1046.50 -- C6
                env = math.exp(-15 * (t - 0.21))
            elseif t < 0.35 then
                freq = 1318.51 -- E6
                env = math.exp(-15 * (t - 0.28))
            elseif t < 0.42 then
                freq = 1567.98 -- G6
                env = math.exp(-15 * (t - 0.35))
            else
                freq = 2093.00 -- C7
                env = math.exp(-5 * (t - 0.42))
            end
            vPhase = vPhase + freq / sampleRate
            local val = triangle(vPhase) * env * 0.95
            victorySoundData:setSample(i, val)
        end
        victorySource = love.audio.newSource(victorySoundData)
        victorySource:setVolume(0.60)

        -- 4. Game Over Sound (Melancholic Descending Cadence)
        local gameOverDuration = 0.8
        local gameOverLength = math.floor(sampleRate * gameOverDuration)
        local gameOverSoundData = love.sound.newSoundData(gameOverLength, sampleRate, 16, 1)
        local goPhase = 0
        for i = 0, gameOverLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.2 then
                freq = 130.81 -- C3
                env = math.exp(-8 * t)
            elseif t < 0.4 then
                freq = 103.83 -- Ab2
                env = math.exp(-8 * (t - 0.2))
            else
                freq = 87.31 -- F2
                env = math.exp(-4 * (t - 0.4))
            end
            goPhase = goPhase + freq / sampleRate
            local val = triangle(goPhase) * env * 0.95
            gameOverSoundData:setSample(i, val)
        end
        gameOverSource = love.audio.newSource(gameOverSoundData)
        gameOverSource:setVolume(0.60)

        -- 5. Menu Hover (Move) Sound (Soft Retro Tick)
        local menuMoveDuration = 0.04
        local menuMoveLength = math.floor(sampleRate * menuMoveDuration)
        local menuMoveSoundData = love.sound.newSoundData(menuMoveLength, sampleRate, 16, 1)
        local mmPhase = 0
        for i = 0, menuMoveLength - 1 do
            local t = i / sampleRate
            local freq = 600
            local env = math.exp(-75 * t)
            mmPhase = mmPhase + freq / sampleRate
            local val = triangle(mmPhase) * env * 0.95
            menuMoveSoundData:setSample(i, val)
        end
        menuMoveSource = love.audio.newSource(menuMoveSoundData)
        menuMoveSource:setVolume(1.0)

        -- 6. Menu Select (Confirm) Sound (Bright Double Beep)
        local menuSelectDuration = 0.13
        local menuSelectLength = math.floor(sampleRate * menuSelectDuration)
        local menuSelectSoundData = love.sound.newSoundData(menuSelectLength, sampleRate, 16, 1)
        local msPhase = 0
        for i = 0, menuSelectLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.05 then
                freq = 1318.51 -- E6
                env = math.exp(-40 * t)
            else
                freq = 1760.00 -- A6
                env = math.exp(-25 * (t - 0.05))
            end
            msPhase = msPhase + freq / sampleRate
            local val = triangle(msPhase) * env * 0.95
            menuSelectSoundData:setSample(i, val)
        end
        menuSelectSource = love.audio.newSource(menuSelectSoundData)
        menuSelectSource:setVolume(0.40)

        -- 7. Menu Back (Cancel) Sound (Descending Retro Double Beep)
        local menuBackDuration = 0.13
        local menuBackLength = math.floor(sampleRate * menuBackDuration)
        local menuBackSoundData = love.sound.newSoundData(menuBackLength, sampleRate, 16, 1)
        local mbPhase = 0
        for i = 0, menuBackLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.05 then
                freq = 1567.98 -- G6
                env = math.exp(-40 * t)
            else
                freq = 1174.66 -- D6
                env = math.exp(-25 * (t - 0.05))
            end
            mbPhase = mbPhase + freq / sampleRate
            local val = triangle(mbPhase) * env * 0.95
            menuBackSoundData:setSample(i, val)
        end
        menuBackSource = love.audio.newSource(menuBackSoundData)
        menuBackSource:setVolume(0.40)

        -- 8. Toast Sound (High Chime Beep)
        local toastDuration = 0.15
        local toastLength = math.floor(sampleRate * toastDuration)
        local toastSoundData = love.sound.newSoundData(toastLength, sampleRate, 16, 1)
        local toastPhase = 0
        for i = 0, toastLength - 1 do
            local t = i / sampleRate
            local freq, env
            if t < 0.05 then
                freq = 1760.00 -- A6
                env = math.exp(-40 * t)
            else
                freq = 2093.00 -- C7
                env = math.exp(-25 * (t - 0.05))
            end
            toastPhase = toastPhase + freq / sampleRate
            local val = triangle(toastPhase) * env * 0.95
            toastSoundData:setSample(i, val)
        end
        toastSource = love.audio.newSource(toastSoundData)
        toastSource:setVolume(0.40)
    end
end

function sound.isEnabled()
    return enabled
end

function sound.toggle()
    enabled = not enabled
    save.saveSound(enabled)
end

function sound.playAchievement()
    if enabled and achSource then
        achSource:seek(0)
        achSource:play()
    end
    sound.vibrate(0.15)
end

function sound.playSplash()
    if enabled and splashSource then
        splashSource:seek(0)
        splashSource:play()
    end
end

function sound.stopSplash()
    if splashSource then
        splashSource:stop()
    end
end

function sound.playVictory()
    if enabled and victorySource then
        victorySource:seek(0)
        victorySource:play()
    end
    sound.vibrate(0.4)
end

function sound.playGameOver()
    if enabled and gameOverSource then
        gameOverSource:seek(0)
        gameOverSource:play()
    end
    sound.vibrate(0.5)
end

function sound.playMenuMove()
    if enabled and menuMoveSource then
        menuMoveSource:seek(0)
        menuMoveSource:play()
    end
end

function sound.playMenuSelect()
    if enabled and menuSelectSource then
        menuSelectSource:seek(0)
        menuSelectSource:play()
    end
end

function sound.playMenuBack()
    if enabled and menuBackSource then
        menuBackSource:seek(0)
        menuBackSource:play()
    end
end

function sound.playToast()
    if enabled and toastSource then
        toastSource:seek(0)
        toastSource:play()
    end
end

function sound.vibrate(duration)
    if not _G.vibration then return end
    local j = getJoystick()
    if j and j:isVibrationSupported() then
        j:setVibration(0.6, 0.6, duration or 0.1)
    end
end

return sound
