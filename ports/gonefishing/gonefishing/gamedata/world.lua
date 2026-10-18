-- The scene: sky, painted layers, reflections, the underwater cutaway, weather and wildlife.
local U = require("util")
local FISH = require("fishdata")
local WL = require("wildlife")
local lg = love.graphics
local W, H, YH, CUT_Y, UW_BOT, WORLD_W = U.W, U.H, U.YH, U.CUT_Y, U.UW_BOT, U.WORLD_W
local fl, rr, rnd, lerp, mix, clamp, setc, wander = U.fl, U.rr, U.rnd, U.lerp, U.mix, U.clamp, U.setc, U.wander

local Wd = {}
local BR = require("bridge")

Wd.LOCS = {
  { id = "lake",  name = "Pine Lake",     cost = 0,    blurb = "Calm water under snowy peaks.",
    tint = { 0.30, 0.50, 0.58 }, uw = { 0.20, 0.36, 0.38 } },
  { id = "river", name = "Willow River",  cost = 600,  blurb = "Quick water, stony runs, willows.",
    tint = { 0.32, 0.48, 0.40 }, uw = { 0.22, 0.36, 0.28 } },
  { id = "coast", name = "Driftwood Bay", cost = 1800, blurb = "Open sea, a lighthouse, big fish.",
    tint = { 0.18, 0.46, 0.58 }, uw = { 0.10, 0.34, 0.44 } },
  { id = "columbia", name = "Columbia River", cost = 3000, blurb = "Hood River, Oregon. Wind, Mt. Hood.",
    tint = { 0.24, 0.44, 0.52 }, uw = { 0.16, 0.30, 0.32 } },
  { id = "frost", name = "Frost Lake",    cost = 4000, blurb = "Snow, ice floes, northern lights.",
    tint = { 0.34, 0.52, 0.66 }, uw = { 0.20, 0.32, 0.44 } },
}
Wd.byId = {}
-- which way and how strongly the water flows in each place (negative = to the left)
Wd.CURRENT = { river = -1, columbia = 0.6 }
function Wd.flow() return Wd.CURRENT[Wd.loc] or 0 end
for i, l in ipairs(Wd.LOCS) do l.index = i; Wd.byId[l.id] = l end

function Wd.fishAt(loc)
  local out = {}
  for _, f in ipairs(FISH) do if f.loc == loc then out[#out + 1] = f end end
  return out
end

---------------------------------------------------------------- time of day
local K = {
  night  = { top = { .03, .04, .11 }, mid = { .06, .08, .20 }, hor = { .14, .16, .31 }, sun = { .34, .40, .62 }, spr = { .42, .46, .64 },
             light = .34, cloud = { .22, .25, .38 } },
  dawn   = { top = { .20, .22, .48 }, mid = { .66, .50, .66 }, hor = { 1, .74, .56 }, sun = { 1, .64, .46 }, spr = { .94, .80, .80 },
             light = .76, cloud = { .92, .64, .62 } },
  day    = { top = { .24, .48, .85 }, mid = { .50, .72, .95 }, hor = { .84, .93, .99 }, sun = { 1, .96, .86 }, spr = { 1, 1, 1 },
             light = 1, cloud = { .93, .95, .98 } },
  golden = { top = { .30, .46, .78 }, mid = { .82, .76, .68 }, hor = { 1, .86, .58 }, sun = { 1, .80, .48 }, spr = { 1, .93, .82 },
             light = .93, cloud = { .98, .88, .70 } },
  sunset = { top = { .20, .18, .48 }, mid = { .90, .44, .48 }, hor = { 1, .62, .30 }, sun = { 1, .52, .28 }, spr = { 1, .78, .68 },
             light = .76, cloud = { .90, .46, .38 } },
}
local KEYTIMES = { { 0.00, "night" }, { 0.195, "night" }, { 0.245, "dawn" }, { 0.30, "day" }, { 0.665, "day" },
                   { 0.715, "golden" }, { 0.765, "sunset" }, { 0.83, "night" }, { 1.00, "night" } }
Wd.KEYS = { "night", "dawn", "day", "golden", "sunset" }

function Wd.keyPair(clock)
  for i = 1, #KEYTIMES - 1 do
    local a, b = KEYTIMES[i], KEYTIMES[i + 1]
    if clock >= a[1] and clock <= b[1] then
      local t = (clock - a[1]) / (b[1] - a[1])
      t = t * t * (3 - 2 * t)
      if a[2] == b[2] then t = 0 end
      return a[2], b[2], t
    end
  end
  return "night", "night", 0
end

local function blendKeys(ka, kb, t)
  local A, B = K[ka], K[kb]
  local s = {}
  for k, v in pairs(A) do
    if type(v) == "table" then s[k] = mix(v, B[k], t) else s[k] = lerp(v, B[k], t) end
  end
  return s
end

---------------------------------------------------------------- weather
Wd.weather = { kind = "clear", amt = 0, timer = 120, next = nil }
local WEIGHTS = {
  lake  = { clear = 5, overcast = 2, fog = 1.5, rain = 1.5 },
  river = { clear = 5, overcast = 2, fog = 1.2, rain = 1.8 },
  coast = { clear = 4, overcast = 2, fog = 2.5, rain = 1.5 },
  frost = { clear = 4, overcast = 2.5, fog = 1.5, rain = 2 },
  columbia = { clear = 6, overcast = 2, fog = 0.8, rain = 1.2 },
}
local WEATHER_TEXT = {
  lake = { overcast = "Clouds roll over the peaks.", fog = "Fog settles on the lake.", rain = "Rain! The fish are biting." },
  river = { overcast = "The sky greys over.", fog = "Mist rises off the river.", rain = "Rain! The fish are biting." },
  coast = { overcast = "Clouds blow in off the sea.", fog = "Sea fog rolls into the bay.", rain = "A squall! The fish are biting." },
  frost = { overcast = "Heavy clouds gather.", fog = "Ice fog drifts in.", rain = "A snowstorm blows in." },
  columbia = { overcast = "Clouds pour through the Gorge.", fog = "Mist hangs in the Gorge.", rain = "Rain sweeps up the river! The fish are biting." },
}
function Wd.weatherAmounts()
  local w = Wd.weather
  local a = w.amt
  local ov = (w.kind == "overcast" or w.kind == "rain") and a or (w.kind == "fog" and a * 0.5 or 0)
  local fog = w.kind == "fog" and a or (w.kind == "rain" and a * 0.25 or 0)
  local rain = w.kind == "rain" and a or 0
  return ov, fog, rain
end
function Wd.setWeather(kind, instant)
  local w = Wd.weather
  if instant then w.kind, w.amt, w.next = kind, kind == "clear" and 0 or 1, nil; w.storm = false
  else w.next = kind end
  w.timer = rr(90, 240)
end
local function updateWeather(dt)
  local w = Wd.weather
  w.timer = w.timer - dt
  if w.timer <= 0 and not w.next then
    local wt, total = WEIGHTS[Wd.loc], 0
    for _, v in pairs(wt) do total = total + v end
    local r = rnd() * total
    for _, k in ipairs({ "clear", "overcast", "fog", "rain" }) do
      r = r - wt[k]
      if r <= 0 then w.next = k; break end
    end
    if w.next == w.kind then w.next = nil end
    w.timer = rr(90, 240)
  end
  if w.next then
    w.amt = math.max(0, w.amt - dt / 12)
    if w.amt <= 0 then
      w.kind, w.next = w.next, nil
      w.storm = w.kind == "rain" and rnd() < 0.45
      local msg = WEATHER_TEXT[Wd.loc][w.kind]
      if msg and G.toast then G.toast(msg) end
    end
  elseif w.kind ~= "clear" then
    w.amt = math.min(1, w.amt + dt / 15)
  end
  local _, fogA, rainA = Wd.weatherAmounts()
  -- rain makes fish bolder; fog a little too
  G.biteMult = 1 + 0.35 * rainA + 0.1 * fogA
end

---------------------------------------------------------------- loading a place
local layers, bed = {}, {}
local cache = {}
local waterCanvas, stripBatch, rowQuads = nil, nil, {}

local function texture(loc, name)
  local path = "gfx/" .. loc .. "/" .. name .. ".png"
  local im = cache[path]
  if not im then
    im = lg.newImage(path)
    cache[path] = im
  end
  return im
end

function Wd.keyTextures(ka, kb)
  local keep = {}
  local function want(name) keep["gfx/" .. Wd.loc .. "/" .. name .. ".png"] = true; texture(Wd.loc, name) end
  for _, L in ipairs(layers) do
    for _, k in ipairs({ ka, kb }) do
      want(L.name .. "_" .. k); want(L.name .. "_" .. k .. "_r")
    end
  end
  want("uw_bed"); want("uw_back")
  for path, im in pairs(cache) do
    if not keep[path] then im:release(); cache[path] = nil end
  end
  Wd._keys = ka .. kb
end

function Wd.bedY(x)
  local i = clamp(math.floor(x / 4) + 1, 1, #bed)
  local j = math.min(#bed, i + 1)
  local f = (x / 4) % 1
  return lerp(bed[i], bed[j], f)
end

-- absolute depth bands: 0 just under the surface .. 1 near the deepest bottom
function Wd.depthToY(d) return CUT_Y + 10 + clamp(d, 0, 1) * (UW_BOT - 30 - CUT_Y - 10) end
function Wd.yToDepth(y) return clamp((y - CUT_Y - 10) / (UW_BOT - 30 - CUT_Y - 10), 0, 1) end

Wd.fish, Wd.ripples, Wd.drops, Wd.floaters, Wd.snow = {}, {}, {}, {}, {}
Wd.clouds, Wd.stars, Wd.shimmer, Wd.birds, Wd.fireflies, Wd.weeds, Wd.motes, Wd.reeds = {}, {}, {}, {}, {}, {}, {}, {}
Wd.picker = nil
Wd.AMBIENT = 44

local function canLive(f, x)
  return Wd.bedY(x) - 8 > Wd.depthToY(f.zone[1]) + 4
end
Wd.canLive = canLive

local function pickTarget(a)
  local tries = 0
  local x
  repeat
    x = a.visitor and a.exitX or clamp(a.x + rr(-220, 220), 20, WORLD_W - 20)
    tries = tries + 1
  until canLive(a.f, x) or tries > 8 or a.visitor
  local bx = clamp(x, 0, WORLD_W - 1)
  local y0 = Wd.depthToY(a.f.zone[1])
  local y1 = math.min(Wd.depthToY(a.f.zone[2]), Wd.bedY(bx) - 6 - a.f.fh * 0.4)
  a.tx, a.ty, a.sp = x, rr(y0, math.max(y0, y1)), a.visitor and rr(10, 16) or rr(7, 15)
end
Wd.pickTarget = pickTarget

function Wd.newAgent(f, x, y)
  local a = { f = f, x = x, vx = 0, vy = 0, face = rnd() < 0.5 and 1 or -1, state = "cruise", t = 0, phase = rr(0, 6.28),
              cool = 0, turn = U.spring(1), turnT = U.spring(1), seed = rr(0, 100), speed = 0 }
  a.turn.x, a.turnT.x = a.face, a.face
  local bx = clamp(x, 0, WORLD_W - 1)
  local y0 = Wd.depthToY(f.zone[1])
  a.y = y or rr(y0, math.max(y0, math.min(Wd.depthToY(f.zone[2]), Wd.bedY(bx) - 8)))
  pickTarget(a)
  return a
end

function Wd.spawnFish(f, visitor, near)
  local side = rnd() < 0.5 and -1 or 1
  local x
  if near then x = clamp(near + side * rr(280, 360), 0, WORLD_W)
  else x = side < 0 and -30 or WORLD_W + 30 end
  local a = Wd.newAgent(f, x)
  if visitor then
    a.visitor, a.exitX = true, side < 0 and WORLD_W + 60 or -60
    pickTarget(a)
  end
  a.face = -side; a.turn.x = a.face; a.turnT.x = a.face
  Wd.joinSchool(a)
  Wd.fish[#Wd.fish + 1] = a
  return a
end

-- small fish of the same kind swim together: the newcomer keeps station off an existing fish
function Wd.joinSchool(a)
  if (a.f.tier or 2) > 1 or rnd() < 0.3 then return end
  for _, o in ipairs(Wd.fish) do
    if o ~= a and o.f.id == a.f.id and not o.leader and not o.visitor and not o.hooked then
      a.leader, a.offx, a.offy = o, -rr(10, 26), rr(-8, 8)
      a.x, a.y = o.x - 20, o.y
      return
    end
  end
end

local REEDS = {
  lake = { { 30, 7 }, { 1540, 8 }, { 1680, 9 }, { 1820, 8 }, { 1990, 9 }, { 2120, 6 }, { 3990, 6 } },
  river = { { 40, 8 }, { 420, 7 }, { 640, 5 }, { 2560, 6 }, { 2980, 7 }, { 3500, 8 }, { 4040, 6 } },
  coast = { { 60, 4 }, { 3760, 5 } },
  frost = { { 40, 5 }, { 1000, 6 }, { 3420, 6 } },
  columbia = { { 980, 7 }, { 1260, 6 }, { 2700, 5 } },
}

function Wd.build(loc)
  Wd.loc = loc
  layers = love.filesystem.load("gfx/" .. loc .. "/layers.lua")()
  bed = love.filesystem.load("gfx/" .. loc .. "/bed.lua")()
  for _, im in pairs(cache) do im:release() end
  cache = {}
  if not waterCanvas then
    waterCanvas = lg.newCanvas(W, H, { dpiscale = 1 })
    stripBatch = lg.newSpriteBatch(waterCanvas, 9000, "stream")
    for i = 0, H do rowQuads[i] = lg.newQuad(0, i, W, 2, W, H) end
  end
  Wd.stars, Wd.clouds, Wd.shimmer, Wd.birds, Wd.fireflies = {}, {}, {}, {}, {}
  Wd.fish, Wd.ripples, Wd.drops, Wd.floaters, Wd.snow, Wd.weeds, Wd.motes, Wd.reeds = {}, {}, {}, {}, {}, {}, {}, {}
  for i = 1, 90 do Wd.stars[i] = { x = rnd(0, W - 1), y = rnd(0, 140), p = rr(0, 6.28), s = rr(0.8, 2.5), b = rnd() < 0.12 } end
  local nc = loc == "coast" and 18 or 16
  for i = 1, nc do
    local ks = { 1, 2, 3, 5, 8, 2, 4, 6, 7 }
    local k = ks[(i - 1) % #ks + 1]
    Wd.clouds[i] = { x = (i - 1) / nc * (WORLD_W * 0.6 + 400) - 200 + rr(-40, 40), y = rr(10, 80), k = k, v = rr(2, 5), depth = rr(0.08, 0.25) }
  end
  for i = 1, 46 do
    Wd.shimmer[i] = { x = rr(0, W), y = rr(0, 1), l = rnd(4, 14), v = (Wd.CURRENT[loc] or 0) ~= 0 and (Wd.CURRENT[loc] * rr(14, 26)) or rr(-4, 4), ph = rr(0, 6.28), f = rr(0.6, 1.8) }
  end
  for i = 1, 44 do Wd.fireflies[i] = { x = rr(0, WORLD_W), y = rr(175, 208), p = rr(0, 6.28), rate = rr(0.7, 1.7), seed = rr(0, 50) } end
  for i = 1, 70 do Wd.motes[i] = { x = rr(0, W), y = rr(CUT_Y, UW_BOT), v = rr(-2, 2), s = rr(0, 6.28) } end
  local wcfg = ({
    lake = { n = 210, h = { 10, 46 }, c1 = { .30, .48, .26 }, c2 = { .20, .36, .20 } },
    river = { n = 170, h = { 8, 26 }, c1 = { .34, .50, .28 }, c2 = { .24, .38, .22 } },
    coast = { n = 120, h = { 40, 130 }, c1 = { .50, .46, .20 }, c2 = { .36, .34, .14 }, kelp = true },
    frost = { n = 80, h = { 8, 22 }, c1 = { .44, .56, .56 }, c2 = { .32, .44, .46 } },
    columbia = { n = 110, h = { 8, 30 }, c1 = { .32, .44, .26 }, c2 = { .22, .32, .20 } },
  })[loc]
  for i = 1, wcfg.n do
    local x = rr(10, WORLD_W - 10)
    local by = Wd.bedY(x)
    local h = math.min(rr(wcfg.h[1], wcfg.h[2]) * (by < 420 and 1.2 or 0.8), by - CUT_Y - 12)
    if h > 4 then
      Wd.weeds[#Wd.weeds + 1] = { x = x, y = by - 1, h = h, ph = rr(0, 6.28), sp = rr(0.6, 1.4), c1 = wcfg.c1, c2 = wcfg.c2, kelp = wcfg.kelp, w = wcfg.kelp and 2 or 1 }
    end
  end
  if loc == "lake" then
    for _, x in ipairs({ 140, 175, 420, 1560, 1610, 1700, 1760, 1880, 1990, 2060, 2110, 3330, 3380 }) do Wd.floaters[#Wd.floaters + 1] = { x = x, y = rr(240, 292), k = rnd() < 0.3 and "lilyflower" or "lilypad" } end
  elseif loc == "river" then
    for _, x in ipairs({ 300, 900, 2700, 2760, 3600 }) do Wd.floaters[#Wd.floaters + 1] = { x = x, y = rr(250, 292), k = "lilypad" } end
  elseif loc == "coast" then
    for _, b in ipairs({ { 700, 262 }, { 1180, 280 }, { 2420, 270 }, { 3200, 258 } }) do
      Wd.floaters[#Wd.floaters + 1] = { x = b[1], y = b[2], k = "buoy", buoy = true }
    end
  elseif loc == "frost" then
    for i, x in ipairs({ 200, 520, 760, 1100, 1360, 1700, 2050, 2420, 2800, 3150, 3480, 3820 }) do
      Wd.floaters[#Wd.floaters + 1] = { x = x, y = rr(230, 290), k = ({ "floe_l", "floe_m", "floe_s" })[i % 3 + 1], v = rr(0.4, 1.2) }
    end
    for i = 1, 90 do Wd.snow[i] = { x = rr(0, W), y = rr(0, H), v = rr(9, 18), ph = rr(0, 6.28), big = rnd() < 0.2 } end
  end
  for _, p in ipairs(Wd.floaters) do p.seed = rr(0, 50) end
  table.sort(Wd.floaters, function(a, b) return a.y < b.y end)
  for _, r in ipairs(REEDS[loc]) do
    for _ = 1, r[2] do
      Wd.reeds[#Wd.reeds + 1] = { x = r[1] + rr(-26, 26), h = rr(18, 44), ph = rr(0, 6.28), cat = rnd() < 0.45 and loc ~= "coast", lean = rr(-0.25, 0.25) }
    end
  end
  Wd.rain = {}
  for i = 1, 260 do Wd.rain[i] = { x = rr(0, W), y = rr(-20, H), v = rr(300, 380), l = rnd(5, 9) } end
  Wd.wisps = {}
  for i = 1, 9 do Wd.wisps[i] = { x = rr(0, W + 200), y = rr(170, 290), w = rr(80, 180), v = rr(3, 7) } end
  Wd.extraSnow = {}
  for i = 1, 200 do Wd.extraSnow[i] = { x = rr(0, W), y = rr(0, H), v = rr(30, 52), ph = rr(0, 6.28), big = rnd() < 0.25 } end
  Wd.weather.timer = rr(60, 150)
  for _ = 1, Wd.AMBIENT do
    local f = Wd.picker and Wd.picker(false)
    if f then
      local x
      for _ = 1, 12 do
        x = rr(30, WORLD_W - 30)
        if canLive(f, x) then break end
      end
      local a = Wd.newAgent(f, x)
      Wd.joinSchool(a)
      Wd.fish[#Wd.fish + 1] = a
    end
  end
  Wd.respawnT = 3
  WL.build(loc, Wd)
  G.sky = Wd.sky(G.game.clock)
  local ka, kb = Wd.keyPair(G.game.clock)
  Wd.keyTextures(ka, kb)
end

function Wd.sky(clock)
  local ka, kb, t = Wd.keyPair(clock)
  local s = blendKeys(ka, kb, t)
  s.ka, s.kb, s.kt = ka, kb, t
  local ov, fog = Wd.weatherAmounts()
  local g = ov * 0.7 + fog * 0.3
  if g > 0 then
    s.spr = mix(s.spr, { s.light * 0.82, s.light * 0.84, s.light * 0.88 }, g * 0.6)
    s.cloud = mix(s.cloud, { 0.55 * s.light + 0.08, 0.57 * s.light + 0.08, 0.62 * s.light + 0.08 }, g)
  end
  s.night = clamp((0.6 - s.light) / 0.26, 0, 1)
  local loc = Wd.byId[Wd.loc or "lake"]
  s.water = U.mul(loc.tint, { s.light * 0.95 + 0.05, s.light * 0.95 + 0.05, s.light * 0.95 + 0.07 })
  s.uwTop = U.mul(loc.uw, { s.light * 0.9 + 0.1, s.light * 0.9 + 0.1, s.light * 0.9 + 0.12 })
  s.uwBot = U.mul(loc.uw, { 0.34 * s.light + 0.06, 0.38 * s.light + 0.06, 0.42 * s.light + 0.08 })
  s.sunAlpha = 1 - ov * 0.85
  s.ov, s.fog = ov, fog
  return s
end

---------------------------------------------------------------- fish movement
function Wd.steer(a, tx, ty, speed, accel, dt, vscale)
  local dx, dy = tx - a.x, ty - a.y
  local d = math.sqrt(dx * dx + dy * dy)
  local dvx, dvy = 0, 0
  if d > 0.01 then
    local sp = speed * math.min(1, d / 16)
    dvx, dvy = dx / d * sp, dy / d * sp * (vscale or 0.55)
  end
  local ax, ay = dvx - a.vx, dvy - a.vy
  local am = math.sqrt(ax * ax + ay * ay)
  local maxA = accel * dt
  if am > maxA then ax, ay = ax / am * maxA, ay / am * maxA end
  a.vx, a.vy = a.vx + ax, a.vy + ay
  return d
end

function Wd.move(a, dt, extra)
  local was = a.face
  if a.vx > 1.5 then a.face = 1 elseif a.vx < -1.5 then a.face = -1 end
  local tier = a.f.tier or 2
  if a.face ~= was then
    -- a new turn: arc down if near the surface, up if near the bottom, either way in open water
    local bed = Wd.bedY(clamp(a.x, 0, WORLD_W - 1))
    if a.y < CUT_Y + 24 then a.loop = 1 elseif a.y > bed - 24 then a.loop = -1 else a.loop = rnd() < 0.5 and 1 or -1 end
  end
  -- bigger fish swing round more slowly; the head leads and the tail follows, like the boat
  local k = 7.6 - tier * 0.9
  U.stepSpring(a.turn, a.face, k, 2 * math.sqrt(k) * 0.95, dt)
  U.stepSpring(a.turnT, a.turn.x, k * 1.5, 2 * math.sqrt(k * 1.5) * 0.95, dt)
  local mid = 1 - math.min(1, math.abs(a.turn.x))           -- 1 at the middle of a turn
  -- it slows through the turn and carries on round in a shallow loop
  local loopV = (a.loop or 0) * mid * (10 + 0.4 * math.abs(a.vx))
  a.x = a.x + a.vx * dt * (0.35 + 0.65 * (1 - mid))
  a.y = a.y + (a.vy + loopV) * dt
  -- the body pitches with the way it is travelling up or down
  local wantP = clamp(-(a.vy + loopV) / (math.abs(a.vx) + 10), -0.7, 0.7)
  a.pitch = (a.pitch or 0) + (wantP - (a.pitch or 0)) * math.min(1, dt * 4)
  local sp = math.sqrt(a.vx * a.vx + a.vy * a.vy)
  a.speed = sp
  a.phase = a.phase + dt * (2.2 + sp * 0.32 + (extra or 0) + mid * 2)  -- the tail beats faster when swimming hard
end

function Wd.spook(x, y, radius)
  for _, a in ipairs(Wd.fish) do
    if not a.hooked and math.abs(a.x - x) < radius and math.abs(a.y - y) < radius then
      local dir = a.x < x and -1 or 1
      a.state, a.t = "flee", rr(0.6, 1.1)
      a.interest = nil
      a.tx, a.ty = a.x + dir * rr(80, 140), clamp(a.y + rr(6, 24), CUT_Y + 10, Wd.bedY(clamp(a.x, 0, WORLD_W - 1)) - 8)
    end
  end
end

function Wd.addRipple(x, y, r) Wd.ripples[#Wd.ripples + 1] = { x = x, y = y, r = 1, max = r or 14, life = 1 } end
function Wd.addSplash(x, y, n, power)
  for _ = 1, n do
    Wd.drops[#Wd.drops + 1] = { x = x, y = y, vx = rr(-1, 1) * 30 * (power or 1), vy = -rr(30, 80) * (power or 1), life = rr(0.4, 0.9) }
  end
end

---------------------------------------------------------------- update
function Wd.update(dt, t)
  if Wd.loc == "columbia" then
    BR.update(dt, t)
    BR.updateRiders(dt, t, G.wind or 1)
  end
  updateWeather(dt)
  WL.update(dt, t, G.sky and G.sky.night or 0, G.lureInWater)
  local _, fogA, rainA = Wd.weatherAmounts()
  G.wind = 1 + 0.55 * wander(t * 0.08, 5) + rainA * 0.8 + (Wd.loc == "columbia" and 0.8 or 0)
  -- reeds and grass sway at a pace that follows the wind smoothly (the phase is accumulated, so a gust
  -- never makes them jump), and half as far as before at most
  Wd.reedPhase = (Wd.reedPhase or 0) + dt * 1.2 * (0.6 + 0.4 * math.min(G.wind, 2.5))
  for _, c in ipairs(Wd.clouds) do
    c.x = c.x + c.v * G.wind * dt
    if c.x > W + 300 + WORLD_W * c.depth then c.x = -260 end
  end
  for _, s in ipairs(Wd.shimmer) do
    s.x = s.x + s.v * (Wd.flow() ~= 0 and 1 or G.wind) * dt
    if s.x > W then s.x = -s.l elseif s.x < -s.l then s.x = W end
  end
  local residents = 0
  for i = #Wd.fish, 1, -1 do
    local a = Wd.fish[i]
    if a.visitor and not a.hooked and ((a.exitX > WORLD_W and a.x > WORLD_W + 40) or (a.exitX < 0 and a.x < -40)) then
      table.remove(Wd.fish, i)
    elseif not a.visitor then
      residents = residents + 1
    end
  end
  Wd.respawnT = (Wd.respawnT or 3) - dt
  if residents < Wd.AMBIENT and Wd.respawnT <= 0 and Wd.picker then
    Wd.respawnT = rr(2, 5)
    local f = Wd.picker(false)
    if f then Wd.spawnFish(f, false, G.boatX) end
  end
  for _, a in ipairs(Wd.fish) do
    if not a.controlled then
      a.t = a.t - dt
      a.cool = math.max(0, (a.cool or 0) - dt)
      local L = a.leader
      if L and (L.hooked or L.controlled or L.visitor or not L.x) then a.leader, L = nil, nil end
      local bedHere = Wd.bedY(clamp(a.x, 0, WORLD_W - 1))
      if a.state == "cruise" and L then
        -- schooling: keep station off the leader, matching its pace
        Wd.steer(a, L.x + a.offx * (L.face or 1), L.y + a.offy, (L.sp or 10) * 1.25, 14, dt)
      elseif a.state == "cruise" then
        local d = Wd.steer(a, a.tx, a.ty, a.sp, 9, dt)
        local bottomFish = a.f.zone[2] >= 0.9
        local surfaceFish = a.f.zone[1] <= 0.1
        local dusk = G.sky and G.sky.light < 0.75 and G.sky.night < 0.5
        if d < 6 then
          if bottomFish and rnd() < 0.5 and not a.visitor then
            a.state, a.t = "rest", rr(3, 8)                               -- settle on the bottom
            a.ty = bedHere - 4 - a.f.fh * 0.3
          elseif rnd() < 0.4 and not a.visitor then a.state, a.t = "pause", rr(1, 4) else pickTarget(a) end
        elseif surfaceFish and dusk and rnd() < dt * 0.06 and not a.visitor then
          a.state, a.t, a.tx, a.ty = "rise", 3, a.x + a.face * rr(20, 40), CUT_Y + 4   -- up to sip an insect
        elseif rnd() < dt * 0.05 and not a.visitor then
          a.state, a.t = "dart", rr(0.3, 0.6)
          a.tx, a.ty = a.x + rr(-80, 80), clamp(a.y + rr(-16, 16), CUT_Y + 10, bedHere - 8)
        end
        -- keep out from under the boat's shadow unless something has caught its eye
        if G.boatX and math.abs(a.x - G.boatX) < 36 and a.y < CUT_Y + 36 and not a.interest and rnd() < dt then
          a.tx = a.x + (a.x < G.boatX and -1 or 1) * rr(60, 120)
        end
      elseif a.state == "rest" then
        Wd.steer(a, a.x, a.ty, 3, 5, dt)
        if a.t <= 0 then a.state = "cruise"; pickTarget(a) end
      elseif a.state == "rise" then
        local d = Wd.steer(a, a.tx, a.ty, 22, 30, dt, 1)
        if d < 5 or a.t <= 0 then
          Wd.addRipple(a.x, CUT_Y, 10)
          if rnd() < 0.3 then Wd.addSplash(a.x, CUT_Y, 2, 0.3) end
          a.state = "cruise"; pickTarget(a); a.ty = math.max(a.ty, CUT_Y + 30)
        end
      elseif a.state == "pause" then
        Wd.steer(a, a.x, a.y, 0, 6, dt)
        a.y = a.y + math.sin(t * 1.2 + a.seed) * dt * 1.2
        if a.t <= 0 then a.state = "cruise"; pickTarget(a) end
      else
        Wd.steer(a, a.tx, a.ty, a.state == "flee" and 48 or 34, 70, dt)
        if a.t <= 0 then a.state = "cruise"; pickTarget(a) end
      end
      a.x = a.x + Wd.flow() * dt * 3
      Wd.move(a, dt, a.state == "dart" and 4 or 0)
    end
    local bx = clamp(a.x, 0, WORLD_W - 1)
    a.y = clamp(a.y, CUT_Y + 9, Wd.bedY(bx) - 5)
  end
  for i = #Wd.ripples, 1, -1 do
    local r = Wd.ripples[i]
    r.r = r.r + dt * 14
    r.life = 1 - r.r / r.max
    if r.life <= 0 then table.remove(Wd.ripples, i) end
  end
  for i = #Wd.drops, 1, -1 do
    local d = Wd.drops[i]
    d.vy = d.vy + 220 * dt
    d.x, d.y = d.x + d.vx * dt, d.y + d.vy * dt
    d.life = d.life - dt
    if d.life <= 0 or (d.vy > 0 and d.y > CUT_Y + 1) then table.remove(Wd.drops, i) end
  end
  local sky = G.sky
  if sky.night < 0.4 and Wd.loc ~= "frost" and rnd() < dt * (Wd.loc == "coast" and 0.1 or 0.07) and #Wd.birds < 4 then
    local gull = Wd.loc == "coast"
    local dir = rnd() < 0.5 and 1 or -1
    Wd.birds[#Wd.birds + 1] = { x = dir > 0 and -10 or W + 10, y = rr(20, 110), v = rr(18, 30) * dir, flapping = true,
                                t = rr(0.8, 1.6), anim = rr(0, 4), gull = gull }
    if gull and rnd() < 0.5 and G.play then G.play("gull", rr(0.9, 1.15)) end
  end
  for i = #Wd.birds, 1, -1 do
    local b = Wd.birds[i]
    b.t = b.t - dt
    if b.t <= 0 then b.flapping = not b.flapping; b.t = b.flapping and rr(0.7, 1.6) or rr(0.6, 1.5) end
    b.x = b.x + b.v * dt
    if b.flapping then b.anim = b.anim + dt * 10; b.y = b.y - dt * 3 else b.y = b.y + dt * 4 end
    if b.x > W + 20 or b.x < -20 then table.remove(Wd.birds, i) end
  end
  for _, p in ipairs(Wd.floaters) do
    if p.v and not p.leaf then
      p.x = p.x + p.v * G.wind * dt
      if p.x > WORLD_W + 40 then p.x = -40 end
    end
  end
  local camx = G.cam and G.cam.x or 0
  if Wd.loc == "river" and rnd() < dt * 0.7 then
    Wd.floaters[#Wd.floaters + 1] = { x = camx + W + 10, y = rr(232, 296), k = rnd() < 0.5 and "leaf_a" or "leaf_b", v = -rr(16, 26), leaf = true, seed = rr(0, 50) }
  end
  for i = #Wd.floaters, 1, -1 do
    local p = Wd.floaters[i]
    if p.leaf then
      p.x = p.x + p.v * dt
      if p.x < camx - 20 then table.remove(Wd.floaters, i) end
    end
  end
  for _, m in ipairs(Wd.motes) do
    m.x = m.x + (m.v + Wd.flow() * 6) * dt
    m.y = m.y + math.sin(t * 0.5 + m.s) * dt * 2
    if m.x < 0 then m.x = W elseif m.x > W then m.x = 0 end
  end
  if rainA > 0 then
    if Wd.loc == "frost" then
      for _, f in ipairs(Wd.extraSnow) do
        f.y = f.y + f.v * dt
        f.x = f.x + (math.sin(t * 1.3 + f.ph) * 8 + 26 * G.wind) * dt
        if f.y > H then f.y, f.x = -2, rr(-40, W) end
        if f.x > W then f.x = f.x - W end
      end
    else
      for _, r in ipairs(Wd.rain) do
        r.y = r.y + r.v * dt
        r.x = r.x - r.v * 0.16 * dt
        if r.y > H then r.y, r.x = rr(-40, -2), rr(0, W + 60) end
      end
      if rnd() < rainA * dt * 24 then
        Wd.addRipple(camx + rr(0, W), CUT_Y + rr(-40, 0), rnd(3, 6))
      end
    end
  end
  for _, wp in ipairs(Wd.wisps) do
    wp.x = wp.x + wp.v * G.wind * dt
    if wp.x - wp.w > W + 100 then wp.x = -wp.w end
  end
  for _, f in ipairs(Wd.snow) do
    f.y = f.y + f.v * dt
    f.x = f.x + (math.sin(t * 0.9 + f.ph) * 6 + 4 * G.wind) * dt
    if f.y > H then f.y, f.x = -2, rr(0, W) end
    if f.x > W then f.x = 0 end
  end
end

---------------------------------------------------------------- drawing
local function crossfade(drawFn, ka, kb, t, alpha)
  alpha = alpha or 1
  drawFn(ka, alpha)
  if kb ~= ka and t > 0.002 then drawFn(kb, alpha * t) end
end

local skyQuad
local function drawSkyTex(sky, oy)
  if not skyQuad then skyQuad = lg.newQuad(0, 0, W, 300, 64, 300) end
  -- fill above the top of the tile with its top colour
  setc(sky.top); lg.rectangle("fill", 0, oy - 200, W, 201)
  local function one(k, a)
    local im = U.img("gfx/sky/sky_" .. k .. ".png")
    im:setWrap("repeat", "clamp")
    lg.setColor(1, 1, 1, a)
    lg.draw(im, skyQuad, 0, fl(oy))
  end
  crossfade(one, sky.ka, sky.kb, sky.kt)
  if sky.ov > 0 or sky.fog > 0 then
    local g = sky.ov * 0.75 + sky.fog * 0.35
    lg.setColor(0.55 * sky.light + 0.06, 0.57 * sky.light + 0.06, 0.62 * sky.light + 0.08, g * 0.8)
    lg.rectangle("fill", 0, oy - 200, W, 500)
  end
end

local function sunPos(clock)
  local u = (clock - 0.22) / 0.62
  return 20 + u * (W - 40), 140 - math.sin(math.pi * clamp(u, 0, 1)) ^ 0.8 * 112, u
end

local function drawCelestial(sky, t, clock, oy, quiet)
  if sky.night > 0.05 then
    for _, s in ipairs(Wd.stars) do
      local a = sky.night * (0.45 + 0.55 * math.sin(t * s.s + s.p)) * (1 - sky.ov)
      lg.setColor(1, 1, 0.92, a)
      lg.rectangle("fill", s.x, fl(s.y + oy), 1, 1)
      if s.b and a > 0.6 then
        lg.setColor(1, 1, 0.92, a * 0.35)
        lg.rectangle("fill", s.x - 1, fl(s.y + oy), 3, 1); lg.rectangle("fill", s.x, fl(s.y + oy) - 1, 1, 3)
      end
    end
  end
  if Wd.loc == "frost" and sky.night > 0.3 then
    local cols = { { 0.3, 1, 0.6 }, { 0.3, 0.9, 0.9 }, { 0.7, 0.4, 1 } }
    for i = 1, 3 do
      local c = cols[i]
      for x = 0, W - 1, 2 do
        local y = 20 + i * 10 + math.sin(x * 0.015 + t * 0.2 + i * 1.7) * 12 + math.sin(x * 0.035 - t * 0.35) * 4
        local a = sky.night * 0.07 * (0.6 + 0.4 * math.sin(x * 0.025 + t * 0.5 + i)) * (1 - sky.ov)
        lg.setColor(c[1], c[2], c[3], a)
        lg.rectangle("fill", x, fl(y + oy), 2, 26)
        lg.setColor(c[1], c[2], c[3], a * 1.6)
        lg.rectangle("fill", x, fl(y + oy), 2, 3)
      end
    end
  end
  local x, y, u = sunPos(clock)
  if u > -0.06 and u < 1.06 then
    local low = 1 - math.min(1, math.sin(math.pi * clamp(u, 0, 1)) * 2.2)
    local sc = sky.sun
    if u < 0 or u > 1 then y = y + math.abs(u < 0 and u or u - 1) * 500 end
    if low > 0 and not quiet then
      for r = 6, 1, -1 do
        lg.setColor(sc[1], sc[2] * 0.85, sc[3] * 0.7, 0.045 * low * sky.sunAlpha)
        lg.ellipse("fill", fl(x), YH + oy - 4, 50 + r * 34, 8 + r * 9)
      end
    end
    lg.setColor(sc[1], sc[2], sc[3], (0.14 + 0.14 * low) * sky.sunAlpha)
    lg.circle("fill", fl(x), fl(y + oy), 20 + low * 14)
    lg.setColor(sc[1], sc[2], sc[3], (0.10 + 0.08 * low) * sky.sunAlpha)
    lg.circle("fill", fl(x), fl(y + oy), 34 + low * 20)
    lg.setColor(math.min(1, sc[1] + 0.1), math.min(1, sc[2] + 0.2), math.min(1, sc[3] + 0.35), sky.sunAlpha)
    lg.draw(U.img("gfx/sky/sun.png"), fl(x - 11), fl(y + oy - 11))
    Wd.sunX, Wd.sunY, Wd.sunLow = x, y + oy, low
  else
    Wd.sunX = nil
  end
  local mu = (((clock + 0.5) % 1) - 0.22) / 0.62
  if mu > 0 and mu < 1 then
    local mx, my = 20 + mu * (W - 40), 140 - math.sin(math.pi * mu) ^ 0.8 * 112
    lg.setColor(0.85, 0.9, 1, 0.08 * (1 - sky.ov))
    lg.circle("fill", fl(mx), fl(my + oy), 16)
    lg.setColor(1, 1, 1, 0.95 * (1 - sky.ov * 0.8))
    lg.draw(U.img("gfx/sky/moon.png"), fl(mx - 10), fl(my + oy - 10))
    Wd.moonX, Wd.moonY = mx, my + oy
  else
    Wd.moonX = nil
  end
end

local function drawClouds(sky, camx, oy)
  for _, c in ipairs(Wd.clouds) do
    local x = c.x - camx * c.depth
    if x > -260 and x < W + 20 then
      local function one(k, a)
        lg.setColor(1, 1, 1, a)
        lg.draw(U.img("gfx/sky/cloud" .. c.k .. "_" .. k .. ".png"), fl(x), fl(c.y + oy))
      end
      crossfade(one, sky.ka, sky.kb, sky.kt)
      if sky.ov > 0 then
        lg.setColor(sky.cloud[1], sky.cloud[2], sky.cloud[3], sky.ov * 0.85)
        lg.draw(U.img("gfx/sky/cloud" .. c.k .. "_day.png"), fl(x), fl(c.y + oy))
      end
    end
  end
end

local function drawLayers(sky, cam, refl)
  for _, L in ipairs(layers) do
    local x = -cam.x * L.px
    local y = -cam.y * L.py
    local suffix = refl and "_r" or ""
    local function one(k, a)
      lg.setColor(1, 1, 1, a)
      lg.draw(texture(Wd.loc, L.name .. "_" .. k .. suffix), fl(x), fl(y))
    end
    crossfade(one, sky.ka, sky.kb, sky.kt)
  end
end

function Wd.horizonY(cam) return YH - cam.y * 0.86 end

-- everything above the front waterline: sky, land, and the water with its faint, broken reflections
function Wd.drawBack(t, clock, cam)
  local sky = G.sky
  local skyOy = -cam.y * 0.5
  local horS = YH - cam.y * 0.86
  local cutS = CUT_Y - cam.y
  if (sky.ka .. sky.kb) ~= Wd._keys then Wd.keyTextures(sky.ka, sky.kb) end
  drawSkyTex(sky, skyOy)
  drawCelestial(sky, t, clock, skyOy)
  drawClouds(sky, cam.x, skyOy)
  for _, b in ipairs(Wd.birds) do
    local frame = b.flapping and (math.floor(b.anim) % 4 + 1) or 2
    local s = sky.spr
    if b.gull then
      lg.setColor(math.max(0.45, s[1]), math.max(0.45, s[2]), math.max(0.5, s[3]))
      U.drawStrip(U.strip("gfx/props/gull.png", 4), frame, b.x - 4, b.y + skyOy - 2, b.v < 0)
    else
      lg.setColor(s[1] * 0.3, s[2] * 0.3, s[3] * 0.38)
      U.drawStrip(U.strip("gfx/props/bird.png", 4), frame, b.x - 3, b.y + skyOy - 2, b.v < 0)
    end
  end
  if cutS <= 0 then return end
  -- reflections are composed off-screen, then laid onto the water in rippling, broken rows
  lg.push("all")
  lg.setCanvas(waterCanvas)
  lg.clear(0, 0, 0, 0)
  lg.push()
  lg.translate(0, 2 * horS)
  lg.scale(1, -1)
  drawSkyTex(sky, skyOy)
  drawCelestial(sky, t, clock, skyOy, true)
  drawClouds(sky, cam.x, skyOy)
  lg.pop()
  drawLayers(sky, cam, true)
  lg.pop()
  local wtop = mix(sky.hor, sky.water, 0.45)
  U.vgrad(0, horS, W, cutS - horS + 1, wtop, mix(sky.water, { 0, 0, 0 }, 0.25))
  local _, fogA, rainA = Wd.weatherAmounts()
  local rough = (0.6 + 0.6 * (G.wind - 1) + rainA * 2.2) * (Wd.loc == "river" and 1.6 or Wd.loc == "columbia" and 1.9 or 1)
  stripBatch:clear()
  -- a wind-driven sea surface: three wave trains crossing at slight angles, locked to the water and seen in
  -- perspective (waves shrink toward the horizon). Each little stretch of a row shifts the mirrored scene by
  -- the local wave slope, crests catch the sky and troughs go a little darker.
  local y0 = math.max(0, math.floor(horS))
  local span = math.max(1, cutS - horS)
  local crests = {}
  for y = y0, math.min(H - 2, math.floor(cutS)), 2 do
    local p = math.max(0.03, (y - horS) / span)          -- 0 at the horizon .. 1 right in front of us
    local Z = 1 / p
    local camx = cam.x * (0.4 + 0.6 * p)
    local amp = (0.6 + 3.2 * p) * rough
    -- Fresnel: far water mirrors the sky strongly, near water less so and shows its own depth
    local refl = (0.78 - 0.36 * p) * (1 - rainA * 0.4) * (1 - fogA * 0.5)
    stripBatch:setColor(1, 1, 1, refl)
    local seg = math.max(3, fl(4 + 10 * p))
    local x = -((fl(camx) % seg))
    while x < W do
      local wx = (x + seg * 0.5 + camx) / (p * 40)
      local p1 = wx * 1.0 + Z * 0.55 - t * 1.6
      local p2 = wx * 0.62 - Z * 0.35 - t * 1.1 + 1.7
      local p3 = wx * 2.3 + Z * 1.4 - t * 2.6 + 0.4
      local slope = math.cos(p1) * 1.0 + math.cos(p2) * 0.55 + math.cos(p3) * 0.28
      local hgt = math.sin(p1) * 1.0 + math.sin(p2) * 0.55 + math.sin(p3) * 0.28
      local off = slope * amp
      local q = rowQuads[y]
      local sx = math.max(0, x)
      local w = math.min(seg, W - sx)
      if w > 0 then
        q:setViewport(sx, y, w, 2, W, H)
        stripBatch:add(q, fl(sx + off), y)
        if hgt > 1.15 - 0.25 * rough then crests[#crests + 1] = { sx, y, w, p, hgt } end
      end
      x = x + seg
    end
  end
  lg.setColor(1, 1, 1, 1)
  lg.draw(stripBatch)
  -- crests catching the light of the sky
  local cc = mix(sky.hor, { 1, 1, 1 }, 0.35)
  for _, c in ipairs(crests) do
    lg.setColor(cc[1], cc[2], cc[3], (0.10 + 0.22 * (1 - c[4])) * (c[5] - 0.9) * (1 - fogA * 0.6))
    lg.rectangle("fill", c[1], c[2], c[3], 1)
  end
  U.vgrad(0, horS, W, cutS - horS + 1, { sky.water[1], sky.water[2], sky.water[3], 0.08 }, { sky.water[1] * 0.8, sky.water[2] * 0.85, sky.water[3] * 0.9, 0.5 })
  for _, s in ipairs(Wd.shimmer) do
    local y = horS + 3 + s.y * (cutS - horS - 6)
    local c = mix(sky.hor, { 1, 1, 1 }, 0.3)
    lg.setColor(c[1], c[2], c[3], (0.20 + 0.16 * math.sin(t * s.f + s.ph)) * (0.4 + 0.6 * (y - horS) / math.max(1, cutS - horS)))
    lg.rectangle("fill", fl(s.x), fl(y), s.l, 1)
  end
  local gx, gc, ga
  if Wd.sunX then gx, gc, ga = Wd.sunX, sky.sun, (0.25 + 0.5 * (Wd.sunLow or 0)) * sky.sunAlpha
  elseif sky.night > 0.5 and Wd.moonX then gx, gc, ga = Wd.moonX, { 0.85, 0.9, 1 }, 0.35 * sky.sunAlpha end
  if gx then
    for row = 0, 60 do
      local y = horS + 2 + row * 2
      if y > cutS - 2 then break end
      local spread = 4 + row * 2.4
      for k = 0, 2 do
        local x = gx + math.sin(t * 2.3 + row * 1.7 + k * 2.1) * spread
        if math.sin(t * 3.1 + row * 0.9 + k) > 0.15 then
          lg.setColor(gc[1], gc[2], gc[3], ga * (1 - row / 64))
          lg.rectangle("fill", fl(x), fl(y), rnd(2, 5), 1)
        end
      end
    end
  end
  if Wd.loc == "columbia" then BR.drawReflection(sky, cam) end
  drawLayers(sky, cam, false)
  if Wd.loc == "columbia" then
    BR.draw(sky, cam, t)
    BR.drawRiders(sky, cam, t, G.wind or 1)
  end
  local ov = sky.ov
  if ov > 0 then
    lg.setColor(0.5 * sky.light + 0.08, 0.52 * sky.light + 0.08, 0.56 * sky.light + 0.1, ov * 0.18)
    lg.rectangle("fill", 0, 0, W, cutS)
  end
  if fogA > 0 then
    local fc = mix(sky.hor, { 0.9, 0.92, 0.95 }, 0.45)
    fc = { fc[1] * math.max(0.4, sky.light), fc[2] * math.max(0.4, sky.light), fc[3] * math.max(0.45, sky.light) }
    local fy0 = 20 - cam.y * 0.8
    local n = math.ceil((cutS - fy0) / 12)
    for i = 0, n do
      local y = fy0 + i * 12
      local hz = 1 - math.abs((y - horS) / 90)
      setc(fc, fogA * clamp(0.25 + 0.6 * hz, 0.2, 0.85))
      lg.rectangle("fill", 0, fl(y), W, 12)
    end
  end
  for _, p in ipairs(Wd.floaters) do
    local x = p.x - cam.x
    if x > -40 and x < W + 40 then
      local dy = fl(wander(t * 0.6, p.seed) * (p.buoy and 1.4 or 0.7))
      setc(sky.spr)
      local im = U.img("gfx/props/" .. p.k .. ".png")
      local py = fl(p.y - cam.y - im:getHeight() + 2 + dy)
      lg.draw(im, fl(x - im:getWidth() / 2), py)
      if p.buoy and (t % 2.4) < 0.25 then
        lg.setColor(1, 0.9, 0.5, 0.9); lg.rectangle("fill", fl(x), py, 1, 1)
        lg.setColor(1, 0.9, 0.5, 0.25); lg.circle("fill", fl(x), py, 5)
      end
    end
  end
  if sky.night > 0.3 and (Wd.loc == "lake" or Wd.loc == "river") then
    for _, f in ipairs(Wd.fireflies) do
      local x = f.x - cam.x * 0.9 + wander(t * 0.25, f.seed) * 20
      local y = f.y - cam.y + wander(t * 0.4, f.seed + 7) * 6
      if x > -5 and x < W + 5 then
        local a = sky.night * math.max(0, math.sin(t * f.rate + f.p)) ^ 4
        lg.setColor(0.95, 1, 0.5, a)
        lg.rectangle("fill", fl(x), fl(y), 1, 1)
        if a > 0.6 then
          lg.setColor(0.95, 1, 0.5, a * 0.25)
          lg.rectangle("fill", fl(x) - 1, fl(y), 3, 1); lg.rectangle("fill", fl(x), fl(y) - 1, 1, 3)
        end
      end
    end
  end
end

-- the underwater cutaway behind the fish
function Wd.drawUnder(t, cam)
  local sky = G.sky
  local cutS = CUT_Y - cam.y
  if cutS >= H then return end
  U.vgrad(0, cutS, W, UW_BOT - CUT_Y + 40, sky.uwTop, sky.uwBot)
  local back = texture(Wd.loc, "uw_back")
  -- the back wall fades into the blue: hazy, not a solid dark mass
  local hz = mix(sky.uwTop, sky.uwBot, 0.4)
  lg.setColor(hz[1] * 1.6 + 0.04, hz[2] * 1.6 + 0.04, hz[3] * 1.6 + 0.05, 0.55)
  lg.draw(back, fl(-cam.x * 0.92), fl(cutS))
  -- shafts of light fan out under the water from wherever the sun (or a bright moon) is, bent a little
  -- steeper than in air as they enter the water (refraction)
  local srcX, srcY, strength, rc
  if Wd.sunX and sky.light > 0.5 then
    srcX, srcY, strength, rc = Wd.sunX, Wd.sunY or 40, (sky.light - 0.5) * 0.16, { 1, 1, 0.92 }
  elseif sky.night > 0.6 and Wd.moonX then
    srcX, srcY, strength, rc = Wd.moonX, Wd.moonY or 40, 0.035, { 0.75, 0.85, 1 }
  end
  if srcX and sky.ov < 0.7 then
    local depth = H - cutS
    for i = 0, 7 do
      local x0 = (i * 83 + t * 4 - cam.x * 0.3) % (W + 160) - 80
      local dx = x0 - srcX
      local dy = math.max(20, cutS - srcY)
      local slant = (dx / dy) * 0.75 * depth            -- the direction the light is travelling, refracted
      local a = strength * (0.6 + 0.4 * math.sin(t * 0.4 + i * 1.3)) * (1 - sky.ov)
      lg.setColor(rc[1], rc[2], rc[3], a)
      lg.polygon("fill", x0, cutS + 1, x0 + 12, cutS + 1, x0 + 12 + slant + 14, H, x0 + slant, H)
    end
  end
  local lv = sky.light * 0.85 + 0.15
  local bt = mix({ lv * 0.92, lv * 0.95, lv }, sky.uwTop, 0.25)
  lg.setColor(bt[1], bt[2], bt[3])
  lg.draw(texture(Wd.loc, "uw_bed"), fl(-cam.x), fl(cutS))
  for _, w in ipairs(Wd.weeds) do
    local sx = w.x - cam.x
    if sx > -20 and sx < W + 20 then
      local by = w.y - cam.y
      local px, py = sx, by
      local segs = math.max(3, math.floor(w.h / 3))
      lg.setLineWidth(w.w)
      for k = 1, segs do
        local f = k / segs
        local sway = math.sin(t * w.sp + k * 0.35 + w.ph) * (2.6 * f) * (w.kelp and 2 or 1)
        sway = sway + Wd.flow() * 5 * f * f
        local nx, ny = sx + sway, by - w.h * f
        local c = (k % 3 == 0) and w.c2 or w.c1
        lg.setColor(c[1] * lv, c[2] * lv, c[3] * lv)
        lg.line(fl(px) + 0.5, fl(py) + 0.5, fl(nx) + 0.5, fl(ny) + 0.5)
        if w.kelp and k % 4 == 2 then
          lg.rectangle("fill", fl(nx) + (k % 8 == 2 and -3 or 1), fl(ny), 3, 1)
        end
        px, py = nx, ny
      end
    end
  end
  lg.setLineWidth(1)
  for _, m in ipairs(Wd.motes) do
    local y = m.y - cam.y
    if y > cutS then
      lg.setColor(0.9, 0.95, 0.9, 0.14 + 0.1 * math.sin(t + m.s))
      lg.rectangle("fill", fl(m.x), fl(y), 1, 1)
    end
  end
end

-- murk over the fish, deepening with depth
function Wd.drawMurk(cam)
  local sky = G.sky
  local cutS = CUT_Y - cam.y
  if cutS >= H then return end
  U.vgrad(0, cutS, W, UW_BOT - CUT_Y + 40, { sky.uwTop[1], sky.uwTop[2], sky.uwTop[3], 0.10 }, { sky.uwBot[1] * 0.7, sky.uwBot[2] * 0.7, sky.uwBot[3] * 0.7, 0.42 })
end

function Wd.underTint(y)
  local sky = G.sky
  local d = clamp((y - CUT_Y) / (UW_BOT - CUT_Y), 0, 1)
  local c = mix({ 1, 1, 1 }, mix(sky.uwTop, sky.uwBot, 0.3), 0.1 + d * 0.35)
  local l = math.max(0.45, sky.light)
  return { c[1] * l, c[2] * l, c[3] * math.min(1, l + 0.1) }
end

function Wd.surfaceY(wx, t)
  return CUT_Y + math.sin(wx * 0.09 + t * 1.6) * 0.7 + math.sin(wx * 0.031 - t * 1.1) * 0.6
end

function Wd.drawSurface(t, cam)
  local sky = G.sky
  local cutS = CUT_Y - cam.y
  local c = mix(sky.hor, { 1, 1, 1 }, 0.35)
  for x = 0, W - 1, 2 do
    local y = fl(Wd.surfaceY(x + cam.x, t) - cam.y)
    lg.setColor(c[1], c[2], c[3], 0.85)
    lg.rectangle("fill", x, y, 2, 1)
    lg.setColor(sky.water[1] * 0.6, sky.water[2] * 0.6, sky.water[3] * 0.7, 0.6)
    lg.rectangle("fill", x, y + 1, 2, 1)
  end
  for _, r in ipairs(Wd.ripples) do
    setc(mix(sky.water, { 1, 1, 1 }, 0.55), r.life * 0.8)
    lg.ellipse("line", fl(r.x - cam.x) + 0.5, fl(r.y - cam.y) + 0.5, r.r, math.max(0.6, r.r * 0.24))
  end
  for _, d in ipairs(Wd.drops) do
    lg.setColor(0.9, 0.95, 1, math.min(1, d.life * 2))
    lg.rectangle("fill", fl(d.x - cam.x), fl(d.y - cam.y), 1, 1)
  end
  return cutS
end

function Wd.drawFront(t, cam)
  local sky = G.sky
  local s = sky.spr
  for _, r in ipairs(Wd.reeds) do
    local sx = (r.x - cam.x * 1.08) - 20
    if sx > -30 and sx < W + 30 then
      local by = CUT_Y + 6 - cam.y
      local tipx = sx + (r.lean * r.h) + math.sin((Wd.reedPhase or t) + r.ph) * 1.1 * G.wind
      local tipy = by - r.h
      lg.setColor(s[1] * 0.28 + 0.02, s[2] * 0.34 + 0.02, s[3] * 0.24 + 0.02)
      local px, py = sx, by
      for k = 1, 6 do
        local f = k / 6
        local nx = sx + (tipx - sx) * f * f
        local ny = by + (tipy - by) * f
        lg.line(fl(px) + 0.5, fl(py) + 0.5, fl(nx) + 0.5, fl(ny) + 0.5)
        px, py = nx, ny
      end
      if r.cat then
        lg.setColor(s[1] * 0.42, s[2] * 0.28, s[3] * 0.18)
        lg.rectangle("fill", fl(tipx) - 1, fl(tipy) + 3, 3, 7)
      end
    end
  end
  local _, fogA, rainA = Wd.weatherAmounts()
  if fogA > 0 then
    local fc = mix(sky.hor, { 0.9, 0.92, 0.95 }, 0.5)
    fc = { fc[1] * math.max(0.45, sky.light), fc[2] * math.max(0.45, sky.light), fc[3] * math.max(0.5, sky.light) }
    for _, wp in ipairs(Wd.wisps) do
      setc(fc, fogA * 0.28)
      lg.ellipse("fill", fl(wp.x), fl(wp.y - cam.y), wp.w, 8)
      setc(fc, fogA * 0.16)
      lg.ellipse("fill", fl(wp.x) + 20, fl(wp.y - cam.y) - 5, wp.w * 0.7, 6)
    end
  end
  -- rain and snow fall onto the water; nothing falls through it
  lg.push("all")
  lg.setScissor(0, 0, W, math.max(0, math.min(H, CUT_Y - cam.y)))
  if rainA > 0 then
    if Wd.loc == "frost" then
      lg.setColor(1, 1, 1, 0.8 * rainA)
      for _, f in ipairs(Wd.extraSnow) do lg.rectangle("fill", fl(f.x), fl(f.y), f.big and 2 or 1, f.big and 2 or 1) end
    else
      lg.setColor(0.76, 0.82, 0.92, 0.42 * rainA)
      for i, r in ipairs(Wd.rain) do
        if i <= #Wd.rain * rainA then lg.rectangle("fill", fl(r.x), fl(r.y), 1, r.l) end
      end
    end
  end
  if Wd.weather.storm and rainA > 0.6 and Wd.loc ~= "frost" then
    Wd.flashT = (Wd.flashT or 6) - love.timer.getDelta()
    if Wd.flashT <= 0 then Wd.flashT, Wd.flash = rr(6, 18), 0.35 end
    if (Wd.flash or 0) > 0 then
      Wd.flash = Wd.flash - love.timer.getDelta()
      local a = (Wd.flash > 0.2 or (Wd.flash < 0.12 and Wd.flash > 0.06)) and 0.22 or 0
      lg.setColor(0.9, 0.92, 1, a); lg.rectangle("fill", 0, 0, W, H)
    end
  end
  for _, f in ipairs(Wd.snow) do
    lg.setColor(1, 1, 1, 0.55 + 0.4 * math.max(0.3, sky.light))
    lg.rectangle("fill", fl(f.x), fl(f.y), f.big and 2 or 1, f.big and 2 or 1)
  end
  lg.pop()
end


function Wd.drawWildlife(cam, t) WL.draw(cam, t, Wd.underTint) end

return Wd
