-- Small sound effects synthesized at startup, so the game ships no audio
-- files. If audio isn't available the game stays silent.

local sound = { enabled = true }

local RATE = 22050
local sources = {}

-- Build a sound from a list of tones: { freq, start, length, volume, shape }.
local function synth(tones, length)
    local samples = math.floor(length * RATE)
    local data = love.sound.newSoundData(samples, RATE, 16, 1)
    local buffer = {}
    for n = 0, samples - 1 do buffer[n] = 0 end
    for _, tone in ipairs(tones) do
        local freq, start, len, vol, shape = tone[1], tone[2], tone[3], tone[4], tone[5] or "sine"
        local s0 = math.floor(start * RATE)
        local count = math.floor(len * RATE)
        local attack = math.max(1, math.floor(0.004 * RATE))
        for k = 0, count - 1 do
            local n = s0 + k
            if n >= samples then break end
            local t = k / RATE
            local env = math.exp(-t * (5.5 / len))
            if k < attack then env = env * (k / attack) end
            local phase = 2 * math.pi * freq * t
            local v
            if shape == "soft" then
                v = math.sin(phase) * 0.8 + math.sin(phase * 2) * 0.2
            elseif shape == "tri" then
                v = (2 / math.pi) * math.asin(math.sin(phase))
            else
                v = math.sin(phase)
            end
            buffer[n] = buffer[n] + v * env * vol
        end
    end
    for n = 0, samples - 1 do
        data:setSample(n, math.max(-1, math.min(1, buffer[n])))
    end
    return data
end

local DEFS = {
    move   = function() return synth({ { 1320, 0, 0.025, 0.10 } }, 0.03) end,
    menu   = function() return synth({ { 990, 0, 0.035, 0.14 } }, 0.04) end,
    open   = function() return synth({ { 740, 0, 0.05, 0.16, "soft" }, { 1110, 0.025, 0.05, 0.10 } }, 0.08) end,
    close  = function() return synth({ { 1110, 0, 0.05, 0.10 }, { 740, 0.025, 0.05, 0.14, "soft" } }, 0.08) end,
    place  = function() return synth({ { 587, 0, 0.09, 0.30, "soft" }, { 1175, 0, 0.05, 0.08 } }, 0.10) end,
    note   = function() return synth({ { 1568, 0, 0.04, 0.12 } }, 0.05) end,
    erase  = function() return synth({ { 660, 0, 0.05, 0.16, "soft" }, { 440, 0.03, 0.06, 0.14, "soft" } }, 0.10) end,
    wrong  = function() return synth({ { 196, 0, 0.16, 0.26, "tri" }, { 185, 0.07, 0.16, 0.20, "tri" } }, 0.24) end,
    blocked = function() return synth({ { 247, 0, 0.07, 0.18, "tri" } }, 0.08) end,
    unit   = function()
        return synth({ { 1047, 0, 0.22, 0.14 }, { 1319, 0.06, 0.22, 0.12 }, { 1568, 0.12, 0.26, 0.12 } }, 0.40)
    end,
    unitBig = function()
        return synth({
            { 1047, 0, 0.26, 0.13 }, { 1319, 0.05, 0.26, 0.12 },
            { 1568, 0.10, 0.28, 0.12 }, { 2093, 0.15, 0.36, 0.11 },
            { 523, 0, 0.40, 0.10, "soft" },
        }, 0.55)
    end,
    hint   = function() return synth({ { 880, 0, 0.12, 0.16 }, { 1319, 0.05, 0.16, 0.12 } }, 0.22) end,
    win    = function()
        return synth({
            { 523, 0.00, 0.30, 0.18, "soft" }, { 659, 0.11, 0.30, 0.18, "soft" },
            { 784, 0.22, 0.30, 0.18, "soft" }, { 1047, 0.33, 0.60, 0.20, "soft" },
            { 1319, 0.33, 0.60, 0.08 },
        }, 1.0)
    end,
}

-- Builds the sounds the first time it's called. conf.lua leaves the audio
-- modules out when sound effects were off at launch (their mixer runs even
-- when silent), so they're loaded here if sound is turned on later.
local loaded = false

function sound.load()
    if loaded then return end
    loaded = true
    local ok = pcall(function()
        if not love.audio then require("love.audio") end
        if not love.sound then require("love.sound") end
        for name, make in pairs(DEFS) do
            sources[name] = love.audio.newSource(make(), "static")
        end
    end)
    if not ok then sources = {} end
end

function sound.play(name)
    if not sound.enabled then return end
    local src = sources[name]
    if not src then return end
    pcall(function()
        if src:isPlaying() then
            src:clone():play()
        else
            src:play()
        end
    end)
end

return sound
