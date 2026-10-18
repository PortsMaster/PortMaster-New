-- All sounds are synthesized at startup, so the game ships with no audio files.
local A = { sfx = {} }
-- volume levels from Settings (0..1): sound effects, nature sounds and music; the master level is LÖVE's own
A.sfxVol, A.ambVol, A.musicVol = 1, 1, 1
local RATE = 22050
local TAU = math.pi * 2

local function make(seconds, fn)
  local n = math.floor(seconds * RATE)
  local sd = love.sound.newSoundData(n, RATE, 16, 1)
  local state = {}
  for i = 0, n - 1 do
    local v = fn(i / RATE, i, n, state)
    if v > 1 then v = 1 elseif v < -1 then v = -1 end
    sd:setSample(i, v)
  end
  return sd
end

local function noise() return love.math.random() * 2 - 1 end
local function lerpf(a, b, t) return a + (b - a) * t end

function A.load()
  -- remember which SoundData each synthesized source came from (used by the video recorder)
  local NS = love.audio.newSource
  A.sdOf = {}
  love.audio.newSource = function(x, k) local src = NS(x, k); if type(x) == "userdata" then A.sdOf[src] = x end; return src end
  -- lapping water: low-passed noise with a slow swell that loops cleanly over 6s
  local water = make(6, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * 0.06
    s.lp2 = (s.lp2 or 0) + (s.lp - (s.lp2 or 0)) * 0.2
    local swell = 0.55 + 0.30 * math.sin(TAU * t / 3) + 0.15 * math.sin(TAU * t / 2 + 1)
    local fade = math.min(1, i / 2000, (n - i) / 2000) -- hide the loop seam
    return s.lp2 * 2.2 * swell * (0.6 + 0.4 * fade)
  end)
  A.water = love.audio.newSource(water, "static")
  A.water:setLooping(true)
  A.water:setVolume(0.35)

  -- crickets: pulsed high chirps, faded in at night
  local crickets = make(4, function(t)
    local v = 0
    for k, off in ipairs({ 0, 1.3, 2.6 }) do
      local tt = (t + off) % 4
      local chirp = (tt % 0.9) < 0.18 and math.sin(TAU * 18 * tt) > 0 and 1 or 0
      v = v + chirp * math.sin(TAU * (4200 + k * 300) * t) * 0.10
    end
    return v
  end)
  A.crickets = love.audio.newSource(crickets, "static")
  A.crickets:setLooping(true)
  A.crickets:setVolume(0)

  local function src(sd, vol)
    local s = love.audio.newSource(sd, "static")
    s:setVolume(vol or 1)
    return s
  end

  A.sfx.splash = src(make(0.45, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * (0.35 - t * 0.6)
    return s.lp * math.exp(-t * 9) * 1.6
  end), 0.7)

  A.sfx.plop = src(make(0.16, function(t)
    local f = 650 - t * 2800
    return math.sin(TAU * f * t) * math.exp(-t * 22) * 0.8
  end), 0.8)

  A.sfx.click = src(make(0.02, function(t) return noise() * math.exp(-t * 300) * 0.6 end), 0.35)

  A.sfx.catch = src(make(0.7, function(t)
    local notes = { 523.25, 659.25, 783.99, 1046.5 }
    local idx = math.min(4, math.floor(t / 0.11) + 1)
    local lt = t - (idx - 1) * 0.11
    local v = math.sin(TAU * notes[idx] * t)
    v = v + 0.3 * math.sin(TAU * notes[idx] * 2 * t)
    return v * math.exp(-lt * (idx == 4 and 5 or 14)) * 0.45
  end), 0.8)

  A.sfx.snap = src(make(0.4, function(t)
    local tone = math.sin(TAU * (900 - t * 1800) * t) * math.exp(-t * 10) * 0.4
    return tone + noise() * math.exp(-t * 40) * 0.6
  end), 0.7)

  A.sfx.blip = src(make(0.05, function(t) return (math.sin(TAU * 880 * t) > 0 and 0.25 or -0.25) * (1 - t / 0.05) end), 0.5)
  A.sfx.buy = src(make(0.25, function(t)
    local f = t < 0.08 and 988 or 1319
    return (math.sin(TAU * f * t) > 0 and 0.22 or -0.22) * math.exp(-t * 8)
  end), 0.6)
  A.sfx.nope = src(make(0.18, function(t) return (math.sin(TAU * 140 * t) > 0 and 0.25 or -0.25) * (1 - t / 0.18) end), 0.5)

  -- pets
  A.sfx.bark = src(make(0.42, function(t)
    local function yap(t0)
      local lt = t - t0
      if lt < 0 or lt > 0.13 then return 0 end
      local f = 520 - lt * 1900
      local env = math.sin(lt / 0.13 * math.pi)
      return (math.sin(TAU * f * lt) * 0.6 + math.sin(TAU * f * 2.02 * lt) * 0.25 + noise() * 0.25) * env
    end
    return (yap(0) + yap(0.2)) * 0.7
  end), 0.55)
  A.sfx.meow = src(make(0.62, function(t)
    local d = 0.62
    local u = t / d
    local f = (u < 0.35) and lerpf(480, 820, u / 0.35) or lerpf(820, 430, (u - 0.35) / 0.65)
    f = f * (1 + 0.02 * math.sin(TAU * 7 * t))
    local env = math.min(1, t / 0.05) * math.min(1, (d - t) / 0.18)
    local v = math.sin(TAU * f * t) * 0.55 + math.sin(TAU * f * 2 * t) * 0.25 + math.sin(TAU * f * 3 * t) * 0.12
    return v * env * 0.6
  end), 0.5)
  A.sfx.purr = src(make(0.9, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * 0.05
    local pulse = 0.5 + 0.5 * math.sin(TAU * 26 * t)
    local env = math.sin(t / 0.9 * math.pi)
    return s.lp * 3 * pulse * env
  end), 0.6)
  A.sfx.whine = src(make(0.35, function(t)
    local f = 900 + 300 * math.sin(t * 9)
    return math.sin(TAU * f * t) * math.sin(t / 0.35 * math.pi) * 0.3
  end), 0.4)
  A.sfx.gull = src(make(0.5, function(t)
    local f = 1400 - t * 900 + 120 * math.sin(TAU * 18 * t)
    return (math.sin(TAU * f * t) * 0.5 + noise() * 0.06) * math.sin(t / 0.5 * math.pi) * 0.5
  end), 0.25)


  -- oar stroke: a soft watery swish
  A.sfx.oar = src(make(0.35, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * (0.12 + 0.2 * math.sin(math.pi * t / 0.35))
    return s.lp * math.sin(math.pi * t / 0.35) * 1.4
  end), 0.35)
  -- tackle box: a latch clack and a lid creak
  A.sfx.latch = src(make(0.12, function(t)
    return (noise() * 0.5 + math.sin(TAU * 1900 * t) * 0.5) * math.exp(-t * 60)
  end), 0.5)
  A.sfx.lid = src(make(0.3, function(t, i, n, s)
    local f = 260 + t * 500
    return (math.sin(TAU * f * t) > 0 and 0.12 or -0.12) * math.sin(math.pi * t / 0.3) * (0.5 + 0.5 * math.sin(TAU * 31 * t))
  end), 0.35)
  A.sfx.reel = src(make(0.03, function(t) return noise() * math.exp(-t * 200) * 0.5 + (math.sin(TAU * 2600 * t) * 0.2) * (1 - t / 0.03) end), 0.25)
  A.sfx.coin = src(make(0.22, function(t)
    local f = t < 0.07 and 1320 or 1760
    return (math.sin(TAU * f * t) > 0 and 0.2 or -0.2) * (1 - t / 0.22)
  end), 0.4)
  -- outboard motor: a low buzzing loop
  A.motor = love.audio.newSource(make(1, function(t, i, n, s)
    local f = 48
    local v = (math.sin(TAU * f * t) > 0 and 0.4 or -0.4) + math.sin(TAU * f * 3 * t) * 0.2
    s.lp = (s.lp or 0) + (v + noise() * 0.3 - (s.lp or 0)) * 0.18
    return s.lp * 0.8
  end), "static")
  A.motor:setLooping(true); A.motor:setVolume(0)

  -- location ambiences
  A.river = love.audio.newSource(make(5, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * 0.25
    local fade = math.min(1, i / 2000, (n - i) / 2000)
    return s.lp * (0.7 + 0.2 * math.sin(TAU * t * 2.2) + 0.1 * math.sin(TAU * t * 3.4)) * (0.6 + 0.4 * fade)
  end), "static")
  A.surf = love.audio.newSource(make(8, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * 0.08
    local wave = math.max(0, math.sin(TAU * t / 4)) ^ 2
    local fade = math.min(1, i / 3000, (n - i) / 3000)
    return s.lp * 2.4 * (0.25 + 0.75 * wave) * (0.6 + 0.4 * fade)
  end), "static")
  A.wind = love.audio.newSource(make(8, function(t, i, n, s)
    s.lp = (s.lp or 0) + (noise() - (s.lp or 0)) * 0.02
    s.lp2 = (s.lp2 or 0) + (s.lp - (s.lp2 or 0)) * 0.05
    local gust = 0.5 + 0.5 * math.sin(TAU * t / 8 * 2) * math.sin(TAU * t / 8)
    local fade = math.min(1, i / 3000, (n - i) / 3000)
    return s.lp2 * 9 * (0.35 + 0.65 * gust) * (0.6 + 0.4 * fade)
  end), "static")
  A.rain = love.audio.newSource(make(4, function(t, i, n, s)
    local v = noise()
    s.hp = (s.hp or 0) * 0.5 + v * 0.5
    local patter = (love.math.random() < 0.004) and noise() * 1.5 or 0
    local fade = math.min(1, i / 2000, (n - i) / 2000)
    return (s.hp * 0.5 + patter) * (0.6 + 0.4 * fade)
  end), "static")
  for _, src2 in ipairs({ A.river, A.surf, A.wind, A.rain }) do src2:setLooping(true); src2:setVolume(0) end
  love.audio.newSource = NS
end

-- recorded-style sounds rendered offline (art2/sound.py) and shipped as OGG
A.variants = {}
local function loadOgg(name, kind)
  local path = "sfx/" .. name .. ".ogg"
  if love.filesystem.getInfo(path) then return love.audio.newSource(path, kind or "static") end
end

function A.loadRecorded()
  for name, n in pairs({ oar = 3, bark = 5, purr = 1, nibble = 3, strike = 1, hookset = 1, cast = 1, bail = 1 }) do
    local list = {}
    for i = 1, n do
      local src = loadOgg(name .. i)
      if src then list[#list + 1] = src end
    end
    if #list > 0 then A.variants[name] = list end
  end
  -- paddle splashes are quiet and subtle; recorded barks and purrs sit just under the music
  if A.variants.oar then for _, v in ipairs(A.variants.oar) do v:setVolume(0.16) end end
  if A.variants.bark then for _, v in ipairs(A.variants.bark) do v:setVolume(0.6) end end
  if A.variants.purr then for _, v in ipairs(A.variants.purr) do v:setVolume(0.8) end end
  local vols = { nibble = 0.35, strike = 0.55, hookset = 0.4, cast = 0.4, bail = 0.35 }
  for name, vol in pairs(vols) do
    if A.variants[name] then for _, v in ipairs(A.variants[name]) do v:setVolume(vol) end end
  end
  -- the reel: winding in, and the drag clicking as a fish takes line
  for _, k in ipairs({ "crank", "drag" }) do
    local src = loadOgg(k .. "_loop")
    if src then src:setLooping(true); src:setVolume(0); A[k] = src end
  end
  A.musicOn = true
end

-- per place: synthesized water bed, recorded daytime ambience (birds, streams), wind, crickets
local LOC_MIX = {
  lake  = { water = 0.10, amb = 0.42, wind = 0,    crickets = 1 },
  river = { water = 0.08, amb = 0.40, wind = 0,    crickets = 0.8 },
  coast = { water = 0.20, amb = 0.14, wind = 0.06, crickets = 0 },
  frost = { water = 0.08, amb = 0.10, wind = 0.30, crickets = 0 },
  columbia = { water = 0.14, amb = 0.22, wind = 0.22, crickets = 0.7 },
}
local mix = LOC_MIX.lake
local started = false
local night, rainAmt = 0, 0

local function loopSrc(name)
  local src = loadOgg(name, "stream")
  if src then src:setLooping(true); src:setVolume(0) end
  return src
end

function A.setLocation(id)
  mix = LOC_MIX[id] or LOC_MIX.lake
  A.place = id
  for _, k in ipairs({ "placeWater", "placeAmb" }) do
    if A[k] then A[k]:stop(); A[k]:release(); A[k] = nil end
  end
  A.placeWater = loopSrc("water_" .. id)
  A.placeAmb = loopSrc("amb_" .. id)
  if started then
    if A.placeWater then A.placeWater:play() end
    if A.placeAmb then A.placeAmb:play() end
  end
  A.water:setVolume(0); A.river:setVolume(0); A.surf:setVolume(0)
  A.wind:setVolume(mix.wind * A.ambVol)
  A.nextTrack = 0
end

function A.setMotor(v, pitch)
  A.motor:setVolume(v * 0.22 * A.sfxVol)
  A.motor:setPitch(pitch or 1)
  if v > 0 and not A.motor:isPlaying() then A.motor:play() end
end

function A.start()
  started = true
  A.crickets:play()
  A.wind:play()
  A.rainLight = A.rainLight or loopSrc("rain_light")
  A.rainStorm = A.rainStorm or loopSrc("rain_storm")
  for _, src in ipairs({ A.rainLight, A.rainStorm, A.placeWater, A.placeAmb }) do src:play() end
  if A.rain then A.rain:stop() end
end

function A.play(name, pitch)
  local list = A.variants[name]
  local idx = list and love.math.random(#list)
  local s = list and list[idx] or A.sfx[name]
  if not s then return end
  if A.trace then A.trace[#A.trace + 1] = { f = A.frame, name = name, idx = idx, pitch = pitch or 1, vol = s:getVolume() } end
  local base = s:getVolume()
  s = s:clone()
  s:setVolume(base * A.sfxVol)
  s:setPitch(pitch or 1)
  s:play()
end

-- winding the reel: v is 0..1 (how hard), rate scales the handle speed
local reelV, dragV = { cur = 0 }, { cur = 0 }
local function drive(src, st, v, pitch, dt)
  if not src then return end
  st.cur = st.cur + (v - st.cur) * math.min(1, (dt or 0.016) * (v > st.cur and 30 or 14))
  if st.cur > 0.01 then
    src:setVolume(st.cur * A.sfxVol)
    src:setPitch(math.max(0.4, math.min(2.2, pitch)))
    if not src:isPlaying() then src:play() end
  elseif src:isPlaying() then
    src:pause()
  end
end
function A.setReel(v, rate, dt) drive(A.crank, reelV, v * 0.45, rate or 1, dt) end
-- the drag: v is 0..1, speed is how fast line is going out (scales the click rate)
function A.setDrag(v, speed, dt) drive(A.drag, dragV, v * 0.5, 0.55 + (speed or 1) * 0.6, dt) end

-- gentle rain, or a thunderstorm; snow at Frost Lake is just wind
function A.setWeather(rain, snowy, storm)
  rainAmt = rain
  if A.rainLight then A.rainLight:setVolume((snowy and 0 or (storm and 0.05 or 0.22) * rain) * A.ambVol) end
  if A.rainStorm then A.rainStorm:setVolume(((snowy or not storm) and 0 or 0.22 * rain) * A.ambVol) end
  A.wind:setVolume((mix.wind + (snowy and 0.25 * rain or 0)) * A.ambVol)
end

---------------------------------------------------------------- music: shuffled playlists for each place
A.PLAYLISTS = {
  lake  = { day = { "music_day", "music_lake1", "music_lake2" },   night = { "music_night", "music_night2" } },
  river = { day = { "music_river1", "music_river2", "music_day" }, night = { "music_night2", "music_night3" } },
  coast = { day = { "music_coast1", "music_coast2", "music_lake1" }, night = { "music_night3", "music_night" } },
  frost = { day = { "music_frost1", "music_frost2", "music_river2" }, night = { "music_night", "music_night3" } },
  columbia = { day = { "music_river1", "music_coast2", "music_lake2" }, night = { "music_night2", "music_night" } },
}
local cur = { src = nil, name = nil, vol = 0, isNight = false, fading = false }
local last = {}

local function startTrack(place, isNight)
  local pl = A.PLAYLISTS[place] or A.PLAYLISTS.lake
  local list = isNight and pl.night or pl.day
  local choices = {}
  for _, n in ipairs(list) do
    if n ~= last[place] and love.filesystem.getInfo("sfx/" .. n .. ".ogg") then choices[#choices + 1] = n end
  end
  if #choices == 0 then for _, n in ipairs(list) do if love.filesystem.getInfo("sfx/" .. n .. ".ogg") then choices[#choices + 1] = n end end end
  if #choices == 0 then return end
  local name = choices[love.math.random(#choices)]
  last[place] = name
  if cur.src then cur.src:stop(); cur.src:release() end
  cur.src = love.audio.newSource("sfx/" .. name .. ".ogg", "stream")
  cur.src:setLooping(false)
  cur.src:setVolume(0)
  cur.src:play()
  cur.name, cur.vol, cur.isNight, cur.fading, cur.place = name, 0, isNight, false, place
end

function A.setNight(level, dt) -- 0 day .. 1 night
  dt = dt or 0.016
  night = level
  A.crickets:setVolume(0.18 * level * mix.crickets * A.ambVol)
  -- birds and stream sounds go quiet after dark and in heavy rain; the water settles too
  if A.placeAmb then A.placeAmb:setVolume(mix.amb * (1 - level) ^ 1.6 * (1 - 0.6 * rainAmt) * A.ambVol) end
  if A.placeWater then A.placeWater:setVolume(mix.water * (1 - 0.35 * level) * A.ambVol) end
  if not started then return end
  local isNight = level > 0.5
  local on = A.musicOn and 0.3 * A.musicVol or 0
  if not cur.src or (not cur.src:isPlaying() and not cur.fading) then
    -- a short breath of silence between tracks
    A.nextTrack = (A.nextTrack or 0) - dt
    if A.nextTrack <= 0 then startTrack(A.place or "lake", isNight); A.nextTrack = love.math.random(4, 10) end
    return
  end
  if cur.isNight ~= isNight or cur.place ~= A.place then cur.fading = true end
  -- ease each track out over its last few seconds
  local dur = cur.src:getDuration()
  if dur and dur > 0 and dur - cur.src:tell() < 3.5 then cur.fading = true end
  local want = cur.fading and 0 or on
  cur.vol = cur.vol + (want - cur.vol) * math.min(1, dt * (cur.fading and 0.6 or 0.4))
  cur.src:setVolume(cur.vol)
  if cur.fading and cur.vol < 0.01 then
    cur.src:stop(); cur.src:release(); cur.src = nil
    A.nextTrack = 1
  end
end

-- the loudness of every looping sound right now (for the video recorder)
function A.snapshot()
  local function v(src) return src and src:isPlaying() and src:getVolume() or 0 end
  return { place = A.place, water = v(A.placeWater), amb = v(A.placeAmb), crickets = v(A.crickets), wind = v(A.wind),
    rainLight = v(A.rainLight), rainStorm = v(A.rainStorm), motor = v(A.motor), motorPitch = A.motor:getPitch(), synthWater = v(A.water),
    crank = v(A.crank), crankPitch = A.crank and A.crank:getPitch() or 1, drag = v(A.drag), dragPitch = A.drag and A.drag:getPitch() or 1 }
end

return A
