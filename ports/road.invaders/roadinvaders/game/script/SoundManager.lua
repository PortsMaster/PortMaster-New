local SoundManager = {}
local ripple = require("helper/ripple")
local cubeExplodeSFX, punchSFX, incommingSFX, cubeStaticSFX, reverseSFX
local shiftSFX, pressSFX, carExplodeSFX, music
local timer
local boomPitch = 1

function SoundManager:init()
    -- Signal.register(SG.CUBE_MATCH, self.onCubeMatch)
    Signal.register(SG.PUNCH_CUBE, self.onPunchCube)
    Signal.register(SG.CUBE_STATIC, self.onCubeGetStatic)
    Signal.register(SG.CUBE_EXPLODE, self.onCubeExplode)
    Signal.register(SG.CAR_CRASH, self.onCarCrash)
    Signal.register(SG.SHIFT_UP_GEAR, self.onShiftGear)
    timer = Timer.new()
    cubeExplodeSFX = self:newSource("boom_2")
    punchSFX = self:newSource("cube_static")
    incommingSFX = self:newSource("incomming")
    cubeStaticSFX = self:newSource("cube_collide_2")
    reverseSFX = self:newSource("car_reverse_gear")
    reverseSFX:setLooping(true)
    shiftSFX = self:newSource("shift_gear")
    pressSFX = self:newSource("button_press")
    carExplodeSFX = self:newSource("car_crash")
    -- 
    music = love.audio.newSource("audio/bgm_2.mp3", "stream")
    music:setLooping( true ) --so it doesnt stop
    music:setVolume( 0.5 ) --so it doesnt stop
end

function SoundManager:stopBgm()
    music:stop()
end

function SoundManager:playBgm()
    music:stop()
    music:play()
end

function SoundManager:update(dt)
    timer:update(dt)
end

function SoundManager:new(filename)
    return ripple.newSound(self:newSource(filename))
end

function SoundManager:newSource(filename)
    return love.audio.newSource(
        string.format("audio/%s.wav",filename), "static")
end

function SoundManager:playPressBtn()
    pressSFX:stop()
    pressSFX:play()
end

function SoundManager:onPunchCube()
    punchSFX:stop()
    punchSFX:play()
end

function SoundManager:onCarCrash()
    carExplodeSFX:stop()
    carExplodeSFX:play()
end

function SoundManager:onCubeMatch()
    -- cubeExplodeSFX:play()
end

function SoundManager:onShiftGear()
    shiftSFX:stop()
    shiftSFX:play()
end

function SoundManager:onCubeExplode()
    cubeExplodeSFX:stop()
    cubeExplodeSFX:setPitch(boomPitch)
    boomPitch = math.min(boomPitch + 0.1, 2.5)
    cubeExplodeSFX:play()
    timer:clear()
    timer:after(1.2, function()
        boomPitch = 1
    end)
end

local staticList = {}
function SoundManager:onCubeGetStatic()
    for k, sound in pairs(staticList) do
        if not sound:isPlaying() then
            sound:setPitch(1 + love.math.random(-0.12, 0))
            sound:play()
            return
        end
    end
    local newSound = cubeStaticSFX:clone()
    newSound:setPitch(1 + love.math.random(0, 0.08))
    newSound:play()
    staticList[#staticList+1] = newSound
end

function SoundManager:playIncommingSFX()
    incommingSFX:play()
end

function SoundManager:onStopReverseSFX()
    reverseSFX:stop()
end

function SoundManager:onPlayReverseSFX()
    reverseSFX:play()
    Timer.after(5, function()
        reverseSFX:stop()
    end)
end


return SoundManager