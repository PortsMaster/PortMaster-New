-- Movie Master vs Garbage
-- Handheld (LÖVE 11.5) port of the web game in game/game.js.
-- Gameplay numbers, timings and rules are carried over from the web version;
-- the web-only parts (store, leaderboards, sharing, analytics) are left out.

local lg = love.graphics
local utf8 = require("utf8")
local K = {} -- constants
local D = {} -- drawing functions
local floor, sqrt, sin, cos, abs, exp = math.floor, math.sqrt, math.sin, math.cos, math.abs, math.exp
local min, max, pi, huge = math.min, math.max, math.pi, math.huge
local random = love.math.random
K.TAU = pi * 2

local function clamp(v, a, b) if v < a then return a elseif v > b then return b end return v end
local function rb(a, b) return a + random() * (b - a) end
local function mag(x, y) return sqrt(x * x + y * y) end

local function hex(h, a)
  h = h:gsub("#", "")
  return { tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255, a or 1 }
end
local function rgba(r, g, b, a) return { r / 255, g / 255, b / 255, a or 1 } end
local function setc(c, a) lg.setColor(c[1], c[2], c[3], (c[4] or 1) * (a or 1)) end

----------------------------------------------------------------------------
-- Constants (from game.js)
----------------------------------------------------------------------------
local C = {
  ink = hex("#120c08"), paper = hex("#d8c5a1"), paperLight = hex("#f4e8d2"), cream = hex("#fff0c4"),
  gold = hex("#e5a408"), goldBright = hex("#ffd360"), goldLight = hex("#ffe7a2"), goldDark = hex("#914800"),
  purple = hex("#5b3370"), red = hex("#d24b35"), shield = hex("#75dcff"), speed = hex("#fff07e"),
  super = hex("#e5a7ff"), magnet = hex("#ff806b"),
}

K.MAX_LIVES = 5
K.POWERUP_DURATION = 15
K.SHIELD_HITS = 3
K.MAGNET_RADIUS = 600
K.CLOSE_THREAT_RADIUS = 150
K.GAMEPAD_DEAD_ZONE = 0.18
K.RESUME_COUNTDOWN_DURATION = 2.0
K.POPCORN_LIFETIME_MULTIPLIER = 1.25
K.MAX_PURSUIT_LEAD_FRACTION = 0.42
K.MAX_RECOMMENDATION_LEAD_FRACTION = 0.55
K.DUAL_BLAST_STREAK = 500
K.POPCORN_SAFE_BORDER = 26
K.POPCORN_GLOW_RADIUS = 95
K.POWERUP_GLOW_RADIUS = 108
K.COLLECTIBLE_GLOW_GAP = 8
K.POPCORN_DANGER_PROGRESS = 0.34
K.POPCORN_BLINK_DURATION = 2.1
K.POPCORN_BLINK_START_RATE = 1.05
K.POPCORN_BLINK_END_RATE = 2.5
K.POPCORN_BLINK_MIN_OPACITY = 0.74
K.REFERENCE_PLAYER_HEIGHT = 168
K.REFERENCE_PLAYER_SPEED = 365
K.REFERENCE_ENEMY_SPEED = 126.8
K.STAR_ROTATION_PERIOD = K.TAU / 5
K.FAST_THREAT_SCORE_FACTOR = 1 / (1.35 * 1.35)
K.RUSH_THREAT_SCORE_FACTOR = 1 / (1.12 * 1.12)
K.FAST_RUSH_THREAT_SCORE_FACTOR = K.FAST_THREAT_SCORE_FACTOR * K.RUSH_THREAT_SCORE_FACTOR

K.POWERUP_TYPES = {
  shield = { label = "SHIELD", icon = "shield", color = C.shield },
  speed = { label = "SUPER SPEED", icon = "speed", color = C.speed },
  super = { label = "SUPER STARS", icon = nil, color = C.super },
  magnet = { label = "MAGNET", icon = "magnet", color = C.magnet },
}
K.POWERUP_TYPE_KEYS = { "shield", "speed", "super", "magnet" }

K.ENEMY_DEFINITIONS = {
  standard = { radius = 23, speed = 1, hp = 1, color = hex("#6d5747"), score = 34 },
  fast = { radius = 18, speed = 1.56, hp = 1, color = hex("#a53a29"), score = 52 },
  heavy = { radius = 31, speed = 0.72, hp = 3, color = hex("#513660"), score = 105 },
}

K.SUPER_STAR_DIRECTIONS = {}
for i = 0, 9 do
  local a = -pi / 2 + (i / 10) * K.TAU
  K.SUPER_STAR_DIRECTIONS[#K.SUPER_STAR_DIRECTIONS + 1] = { x = cos(a), y = sin(a) }
end

K.INFO_PAGES = {
  { title = "THE BASICS", items = {
    { head = "KEEP MOVING", text = "The Movie Master fires his recommendation stars automatically while he moves. Standing still, he only defends himself against very close garbage." },
    { head = "COLLECT THE POPCORN", text = "Popcorn scores points and charges the Blockbuster Blast. Don't let it expire: in Normal Mode, a missed popcorn summons more garbage." },
    { head = "AVOID GARBAGE", text = "Each unshielded hit costs a rating star. Lose them all and the run ends. Garbage gets faster the longer you last." },
  } },
  { title = "POWER-UPS", items = {
    { icon = "shield", head = "SHIELD", text = "Blocks up to three hits." },
    { icon = "speed", head = "SUPER SPEED", text = "Makes the Movie Master much faster." },
    { icon = "super", head = "SUPER STARS", text = "Stars fire in every direction." },
    { icon = "magnet", head = "MAGNET", text = "Pulls nearby popcorn and power-ups toward you." },
  } },
  { title = "BLAST AND STREAKS", items = {
    { head = "BLOCKBUSTER BLAST", text = "Popcorn and destroyed garbage fill the meter. At 100%, press A, B, X, Y, L1 or R1 to clear the screen." },
    { head = "POPCORN STREAKS", text = "Every 10 popcorn in a row upgrades the stars, and every 20 also speeds up the Movie Master. At 100, 200, 300 and 400 in a row, every shot gains another star. At 500, a second Blast bar unlocks." },
  } },
  { title = "MODES AND CONTROLS", items = {
    { head = "HARDCORE MODE", text = "One unshielded hit or one missed popcorn ends the game." },
    { key = "MOVE", text = "D-pad or left stick" },
    { key = "BLAST", text = "A, B, X, Y, L1, R1, L2 or R2" },
    { key = "PAUSE", text = "Start or Select" },
    { key = "EXIT", text = "Select + Start" },
  } },
}
K.INFO_PAGE_COUNT = #K.INFO_PAGES
-- Speed-boost streaks: how much of the recent path they cover, how long a
-- point lingers once he stops, and the most points kept.
K.TRAIL_LENGTH, K.TRAIL_LIFE, K.TRAIL_POINTS = 92, 0.2, 40
-- Every font size the game draws with, built at startup (see D.prewarm).
K.FONT_SIZES = { alfa = { 13, 16, 24, 28, 34, 38, 46, 48 }, j400 = { 16 }, j700 = { 11, 13 },
  j800 = { 8, 9, 10, 11, 12, 13, 14, 15, 17, 22 } }
K.BLAST_GLOW_PASSES = { { 1.5, 0.05 }, { 1.2, 0.07 }, { 0.9, 0.09 }, { 0.65, 0.12 }, { 0.4, 0.16 }, { 0.2, 0.22 } }

----------------------------------------------------------------------------
-- Screen layout. The game draws into a fixed 640x480 canvas (the RG35XX
-- Plus screen) which is scaled to whatever the real screen is.
----------------------------------------------------------------------------
local W, H = 640, 480
local HUD = { x = 6, y = 5, w = 628, h = 44 }
local bounds = { left = 12, right = 628, top = 56, bottom = 474 }
-- The web game sets its scale from the playable height (height / 1231).
-- A little larger here so everything reads well on a 3.5 inch screen.
local S = 0.44
local function sw(v) return v * S end

local player = {
  x = 0, y = 0, vx = 0, vy = 0, lives = K.MAX_LIVES, invulnerable = 0, bob = 0, moving = false, stationaryTime = 0,
  trail = {},
}
player.drawHeight = sw(K.REFERENCE_PLAYER_HEIGHT)
player.drawWidth = player.drawHeight * (705 / 2048)
player.radius = sw(27)
player.speed = sw(K.REFERENCE_PLAYER_SPEED)

local playerBounds
do
  local hi = max(player.radius, player.drawWidth * 0.52)
  playerBounds = {
    left = bounds.left + hi, right = bounds.right - hi,
    top = bounds.top + player.drawHeight * 0.56, bottom = bounds.bottom - player.drawHeight * 0.46,
  }
end

----------------------------------------------------------------------------
-- State
----------------------------------------------------------------------------
local gameState = "ready" -- ready, running, paused, resuming, reset-confirm, end-confirm, quit-confirm, gameover
local overlay = nil       -- nil, "info", "stats"
local hardcoreMode = false
local soundOn = true
local records = { normal = { score = 0, streak = 0 }, hardcore = { score = 0, streak = 0 } }

local elapsed, score, difficultyLevel, mastery = 0, 0, 1, 0
local spawnTimer, shotTimer, popcornSpawnTimer, powerupSpawnTimer = 0, 0, 0, 0
local popcornCollected, popcornChain, longestStreak = 0, 0, 0
local recommendationPower, movementPower, starRowSize, dualBlastUnlocked = 0, 0, 1, false
local shieldTime, shieldHits, speedTime, superStarsTime, magnetTime, superVolleyAngle = 0, 0, 0, 0, 0, 0
local killCombo, comboTimer, rushTimer, rushWarning = 0, 0, 0, nil
local shakeTime, shakePower, blast = 0, 0, nil
local bannerMessage, bannerTime, bannerDanger = "", 0, false
local blastReadyAnnounced = false
local runStats
local runStartingBestScore, runStartingBestStreak = 0, 0
local gameoverTitle, finalScore = "", 0
local resumeStartedAt = 0
local backgroundAnimationTime = 0
local clock = 0
local flashTime = 0
local combo = { text = "", t = 99 }
local bannerVisible = { text = "", danger = false, alpha = 0 }
local inputGuard = 0

local enemies, projectiles, pickups, powerups, particles, floatingTexts = {}, {}, {}, {}, {}, {}

local function bestFor(mode) return records[mode or (hardcoreMode and "hardcore" or "normal")] end
local function maximumLives() return hardcoreMode and 1 or K.MAX_LIVES end
local function maximumBlastCharge() return dualBlastUnlocked and 2 or 1 end
local function addBlastCharge(amount) mastery = clamp(mastery + amount, 0, maximumBlastCharge()) end

----------------------------------------------------------------------------
-- Save data
----------------------------------------------------------------------------
K.SAVE_FILE = "save.txt"
local function saveData()
  local lines = {
    "normalScore=" .. floor(records.normal.score), "normalStreak=" .. floor(records.normal.streak),
    "hardcoreScore=" .. floor(records.hardcore.score), "hardcoreStreak=" .. floor(records.hardcore.streak),
    "sound=" .. (soundOn and "1" or "0"), "hardcore=" .. (hardcoreMode and "1" or "0"),
  }
  pcall(love.filesystem.write, K.SAVE_FILE, table.concat(lines, "\n") .. "\n")
end
local function loadData()
  if not love.filesystem.getInfo(K.SAVE_FILE) then return end
  local ok, text = pcall(love.filesystem.read, K.SAVE_FILE)
  if not ok or not text then return end
  local v = {}
  for k, val in text:gmatch("(%w+)=([%w%.]+)") do v[k] = val end
  records.normal.score = tonumber(v.normalScore) or 0
  records.normal.streak = tonumber(v.normalStreak) or 0
  records.hardcore.score = tonumber(v.hardcoreScore) or 0
  records.hardcore.streak = tonumber(v.hardcoreStreak) or 0
  soundOn = v.sound ~= "0"
  hardcoreMode = v.hardcore == "1"
end

local function trackRunRecords(finalValue, streak)
  local rec = bestFor()
  local changed = false
  if finalValue > rec.score then rec.score = finalValue; changed = true end
  if streak > rec.streak then rec.streak = streak; changed = true end
  return changed
end

----------------------------------------------------------------------------
-- Assets
----------------------------------------------------------------------------
local fonts = {}
local fontFiles = { alfa = "assets/alfa.ttf", j400 = "assets/jost400.ttf", j700 = "assets/jost700.ttf", j800 = "assets/jost800.ttf" }
local starFallback = {}
local function F(kind, size)
  size = max(6, floor(size + 0.5))
  local key = kind .. size
  local f = fonts[key]
  if not f then
    f = lg.newFont(fontFiles[kind], size, "normal")
    local fb = starFallback[size]
    if not fb then fb = lg.newFont("assets/stars.ttf", size, "normal"); starFallback[size] = fb end
    f:setFallbacks(fb)
    fonts[key] = f
  end
  return f
end

-- Letter-spaced text, cached as Text objects.
local trackedCache, trackedCount = {}, 0
local function tracked(font, text, spacing)
  local key = tostring(font) .. "\0" .. text .. "\0" .. spacing
  local entry = trackedCache[key]
  if entry then return entry end
  if trackedCount > 400 then trackedCache, trackedCount = {}, 0 end
  trackedCount = trackedCount + 1
  local t = lg.newText(font)
  local x = 0
  for _, code in utf8.codes(text) do
    local ch = utf8.char(code)
    t:add(ch, floor(x + 0.5), 0)
    x = x + font:getWidth(ch) + spacing
  end
  entry = { text = t, width = max(0, x - spacing), height = font:getHeight() }
  trackedCache[key] = entry
  return entry
end
local function printTracked(font, text, x, y, spacing, align)
  local e = tracked(font, text, spacing or 0)
  if align == "center" then x = x - e.width / 2 elseif align == "right" then x = x - e.width end
  lg.draw(e.text, floor(x + 0.5), floor(y + 0.5))
  return e.width
end
local function textWidth(font, text, spacing) return tracked(font, text, spacing or 0).width end

local images = {}
local playerQuad

local function lerpStops(stops, t)
  for i = 1, #stops - 1 do
    local a, b = stops[i], stops[i + 1]
    if t <= b[1] then
      local u = (b[1] - a[1]) > 0 and (t - a[1]) / (b[1] - a[1]) or 0
      local aa = a[5] * (1 - u) + b[5] * u
      if aa <= 0 then return 0, 0, 0, 0 end
      local r = (a[2] * a[5] * (1 - u) + b[2] * b[5] * u) / aa
      local g = (a[3] * a[5] * (1 - u) + b[3] * b[5] * u) / aa
      local bl = (a[4] * a[5] * (1 - u) + b[4] * b[5] * u) / aa
      return r, g, bl, aa
    end
  end
  local l = stops[#stops]
  return l[2], l[3], l[4], l[5]
end

-- Radial gradient sprite: stops are {t, r, g, b, a} with 0-1 channels.
local function makeRadial(inner, outer, stops)
  local R = math.ceil(outer) + 1
  local d = R * 2
  local id = love.image.newImageData(d, d)
  id:mapPixel(function(x, y)
    local dist = mag(x + 0.5 - R, y + 0.5 - R)
    local t = (dist - inner) / (outer - inner)
    if t > 1 then return 0, 0, 0, 0 end
    if t < 0 then t = 0 end
    return lerpStops(stops, t)
  end)
  local img = lg.newImage(id)
  img:setFilter("linear", "linear")
  return { img = img, half = R }
end

local function colorStop(t, c, a) return { t, c[1], c[2], c[3], a } end

-- Ring or disc with a soft glow, standing in for canvas shadowBlur.
local function makeGlowShape(radius, width, blur, color, filled)
  local sigma = max(0.5, blur / 2)
  local R = math.ceil(radius + width + blur * 1.6 + 2)
  local d = R * 2
  local id = love.image.newImageData(d, d)
  local ringPeak = min(1, width / (sigma * 2.5066))
  id:mapPixel(function(x, y)
    local dist = mag(x + 0.5 - R, y + 0.5 - R)
    local coverage, edge, g
    if filled then
      coverage = clamp(radius - dist + 0.5, 0, 1)
      edge = max(0, dist - radius)
      g = 0.5 * exp(-(edge * edge) / (2 * sigma * sigma))
    else
      coverage = clamp(width / 2 - abs(dist - radius) + 0.5, 0, 1)
      edge = max(0, abs(dist - radius) - width / 2)
      g = ringPeak * exp(-(edge * edge) / (2 * sigma * sigma))
    end
    local a = coverage + (1 - coverage) * g
    if a <= 0.002 then return 0, 0, 0, 0 end
    return color[1], color[2], color[3], a
  end)
  local img = lg.newImage(id)
  img:setFilter("linear", "linear")
  return { img = img, half = R }
end
function D.drawCentered(sprite, x, y, scale)
  scale = scale or 1
  lg.draw(sprite.img, x, y, 0, scale, scale, sprite.half, sprite.half)
end

-- Unit five-point star as a triangle fan (the shape is star-convex around its centre).
local starMeshes = {}
local function starMesh(innerRatio)
  local key = floor(innerRatio * 1000 + 0.5)
  local m = starMeshes[key]
  if m then return m end
  local verts = { { 0, 0 } }
  for i = 0, 10 do
    local r = (i % 2 == 0) and 1 or innerRatio
    local a = -pi / 2 + (i * pi) / 5
    verts[#verts + 1] = { cos(a) * r, sin(a) * r }
  end
  m = lg.newMesh(verts, "fan", "static")
  starMeshes[key] = m
  return m
end
function D.drawStar(x, y, outer, inner, angle)
  lg.draw(starMesh(inner / outer), x, y, angle or 0, outer, outer)
end

-- Renders something at 4x and shrinks it in two exact 2:1 steps, which gives
-- smooth edges even where the GPU offers no multisampling. Result is a
-- premultiplied-alpha canvas.
local function supersampled(w, h, draw)
  w, h = math.ceil(w), math.ceil(h)
  lg.push("all")
  local big = lg.newCanvas(w * 4, h * 4)
  lg.setCanvas(big)
  lg.clear(0, 0, 0, 0)
  lg.origin()
  lg.setBlendMode("alpha", "alphamultiply")
  lg.setScissor()
  lg.setColor(1, 1, 1, 1)
  lg.scale(4, 4)
  draw()
  lg.origin()
  lg.setBlendMode("alpha", "premultiplied")
  lg.setColor(1, 1, 1, 1)
  local mid = lg.newCanvas(w * 2, h * 2)
  lg.setCanvas(mid)
  lg.clear(0, 0, 0, 0)
  big:setFilter("linear", "linear")
  lg.draw(big, 0, 0, 0, 0.5, 0.5)
  local fin = lg.newCanvas(w, h)
  lg.setCanvas(fin)
  lg.clear(0, 0, 0, 0)
  mid:setFilter("linear", "linear")
  lg.draw(mid, 0, 0, 0, 0.5, 0.5)
  lg.pop()
  big:release()
  mid:release()
  fin:setFilter("linear", "linear")
  return fin
end

-- Glowing star sprites (white; tinted when drawn), cached per size.
local starSprites = {}
local softDot
local function getStarSprite(outer, innerRatio, glow)
  local key = string.format("%.2f:%.3f:%.2f", outer, innerRatio, glow)
  local s = starSprites[key]
  if s then return s end
  local half = math.ceil(outer + glow * 2 + 3)
  local size = half * 2
  local canvas = supersampled(size, size, function()
    if glow > 0.3 then
      lg.setColor(1, 1, 1, 0.45)
      local scale = (outer + glow) / softDot.half
      D.drawCentered(softDot, half, half, scale)
    end
    lg.setColor(1, 1, 1, 1)
    D.drawStar(half, half, outer, outer * innerRatio, 0)
  end)
  s = { canvas = canvas, half = size / 2 }
  starSprites[key] = s
  return s
end
function D.drawTintedPM(sprite, x, y, angle, c, alpha)
  local a = (c[4] or 1) * (alpha or 1)
  lg.setColor(c[1] * a, c[2] * a, c[3] * a, a)
  lg.draw(sprite.canvas, x, y, angle or 0, 1, 1, sprite.half, sprite.half)
end

-- Garbage can sprites, cached per kind / mode / hp / hit flash.
local enemySprites = {}
local function getEnemySprite(enemy)
  local hit = enemy.hitFlash > 0
  local key = enemy.kind .. enemy.mode .. enemy.hp .. (hit and "h" or "")
  local s = enemySprites[key]
  if s then return s end
  local fill = hit and C.goldBright or enemy.color
  local outline = enemy.mode == "rush" and hex("#ff6f55")
    or enemy.kind == "fast" and hex("#ff8b72")
    or enemy.kind == "heavy" and hex("#c99cdc")
    or hex("#ad8b72")
  local r = enemy.radius
  local half = math.ceil(r + sw(48))
  local size = half * 2
  local canvas = supersampled(size, size, function()
    setc(fill, 0.72)
    lg.circle("fill", half, half, r + sw(7), 48)
    setc(outline)
    lg.setLineWidth(sw(enemy.kind == "heavy" and 4 or 2))
    lg.circle("line", half, half, r + sw(3), 48)
    local n = floor(r * 1.68 + 0.5)
    lg.setColor(1, 1, 1, 1)
    lg.draw(images.garbage, half, half, 0, n / 128, n / 128, 64, 64)
    if enemy.maxHp > 1 then
      local barWidth = r * 1.6
      lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.82)
      lg.rectangle("fill", half - barWidth / 2, half + r + sw(10), barWidth, sw(5))
      setc(C.goldBright)
      lg.rectangle("fill", half - barWidth / 2, half + r + sw(10), barWidth * (enemy.hp / enemy.maxHp), sw(5))
    end
  end)
  s = { canvas = canvas, half = size / 2 }
  enemySprites[key] = s
  return s
end

local sprites = {}
local mainCanvas
local bgImage, textureImage, raysMesh, filmMesh
local backgroundStars = {}

local function buildBackground()
  -- Radial gradient: centre (0.5w, 0.52h) r=10 to (0.5w, 0.54h) r=0.72*max(w,h).
  local id = love.image.newImageData(W, H)
  local stops = {
    { 0, 0x44 / 255, 0x29 / 255, 0x13 / 255, 1 },
    { 0.42, 0x25 / 255, 0x15 / 255, 0x0b / 255, 1 },
    { 1, 0x09 / 255, 0x06 / 255, 0x04 / 255, 1 },
  }
  local cx, cy, outer = W * 0.5, H * 0.53, max(W, H) * 0.72
  id:mapPixel(function(x, y)
    local t = clamp((mag(x + 0.5 - cx, y + 0.5 - cy) - 10) / (outer - 10), 0, 1)
    return lerpStops(stops, t)
  end)
  bgImage = lg.newImage(id)

  -- Scanlines and vignette (the .screen-texture layer).
  local tid = love.image.newImageData(W, H)
  local vx, vy = W / 2, H / 2
  local farthest = mag(vx, vy)
  tid:mapPixel(function(x, y)
    local d = mag(x + 0.5 - vx, y + 0.5 - vy) / farthest
    local v = 0
    if d > 0.46 then v = (d - 0.46) / 0.54 * 0.45 end
    local line = (y % 4 == 0) and 0.018 or 0
    local a = v + line * (1 - v)
    if a <= 0 then return 0, 0, 0, 0 end
    local r = (line * (1 - v) * 1 + v * 4 / 255) / a
    local g = (line * (1 - v) * 1 + v * 2 / 255) / a
    local b = (line * (1 - v) * 1 + v * 1 / 255) / a
    return r, g, b, a
  end)
  textureImage = lg.newImage(tid)

  -- Rotating rays: 16 wedges out of 32 slices.
  local radius = mag(W, H)
  local verts = {}
  for i = 0, 31, 2 do
    local a0 = (i / 32) * K.TAU
    local a1 = ((i + 1) / 32) * K.TAU
    local steps = 4
    for s = 0, steps - 1 do
      local b0 = a0 + (a1 - a0) * s / steps
      local b1 = a0 + (a1 - a0) * (s + 1) / steps
      verts[#verts + 1] = { 0, 0 }
      verts[#verts + 1] = { cos(b0) * radius, sin(b0) * radius }
      verts[#verts + 1] = { cos(b1) * radius, sin(b1) * radius }
    end
  end
  raysMesh = lg.newMesh(verts, "triangles", "static")

  local stars = {}
  local count = min(58, max(8, floor(clamp(W / 28, 18, 58) + 0.5)))
  for i = 1, count do
    stars[i] = { x = random() * W, y = random() * H, size = rb(0.7, 2.1), phase = random() * K.TAU }
  end
  backgroundStars = stars
end

local function buildSprites()
  softDot = makeRadial(0, 64, { { 0, 1, 1, 1, 1 }, { 0.35, 1, 1, 1, 0.55 }, { 1, 1, 1, 1, 0 } })
  sprites.auraNormal = makeRadial(sw(4), player.drawHeight * 0.5, {
    colorStop(0, rgba(255, 218, 107), 0.58), colorStop(0.42, C.gold, 0.25), colorStop(1, C.gold, 0) })
  sprites.auraReady = makeRadial(sw(4), player.drawHeight * 0.62, {
    colorStop(0, rgba(255, 244, 185), 0.92), colorStop(0.42, rgba(255, 196, 41), 0.54), colorStop(1, C.gold, 0) })
  sprites.beamNormal = makeRadial(sw(5), sw(K.POPCORN_GLOW_RADIUS), {
    colorStop(0, rgba(255, 211, 96), 0.27), colorStop(1, C.gold, 0) })
  sprites.beamDanger = makeRadial(sw(5), sw(K.POPCORN_GLOW_RADIUS), {
    colorStop(0, rgba(255, 105, 72), 0.27), colorStop(1, C.gold, 0) })
  for _, key in ipairs(K.POWERUP_TYPE_KEYS) do
    local c = K.POWERUP_TYPES[key].color
    sprites["beam_" .. key] = makeRadial(sw(5), sw(K.POWERUP_GLOW_RADIUS), {
      colorStop(0, c, 0x55 / 255), colorStop(1, c, 0) })
    sprites["glow_" .. key] = makeGlowShape(10, 0, sw(24), c, true)
  end
  sprites.readyRing = makeGlowShape(player.drawHeight * 0.52, sw(4), sw(24), C.goldBright, false)
  sprites.shieldRing = makeGlowShape(player.drawHeight * 0.54, sw(4), sw(22), C.shield, false)
  sprites.shieldDisc = makeGlowShape(player.drawHeight * 0.54, 0, sw(22), C.shield, true)
  sprites.pickupGlow = makeGlowShape(10, 0, sw(22), C.goldBright, true)
  sprites.pickupGlowDanger = makeGlowShape(10, 0, sw(22), hex("#ff5a3b"), true)
end

----------------------------------------------------------------------------
-- Sound: the web game's oscillator tones, rendered once at start-up.
----------------------------------------------------------------------------
local cues = {}
K.CUE_DEFS = {
  start = { { 220, 0.16, "triangle", 0.055 }, { 330, 0.18, "triangle", 0.055, 0.1 }, { 440, 0.24, "triangle", 0.06, 0.2 } },
  destroy = { { 520, 0.08, "square", 0.025 }, { 720, 0.1, "triangle", 0.025, 0.045 } },
  popcorn = { { 660, 0.09, "sine", 0.05 }, { 880, 0.14, "sine", 0.04, 0.07 } },
  miss = { { 145, 0.2, "sawtooth", 0.055 }, { 105, 0.28, "square", 0.035, 0.08 } },
  hit = { { 95, 0.22, "sawtooth", 0.075 }, { 66, 0.28, "square", 0.035, 0.04 } },
  blast = { { 110, 0.45, "sawtooth", 0.055 }, { 330, 0.5, "triangle", 0.05, 0.03 }, { 660, 0.42, "sine", 0.045, 0.12 } },
  advance = { { 410, 0.12, "square", 0.035 }, { 520, 0.16, "square", 0.035, 0.1 } },
  gameover = { { 230, 0.25, "triangle", 0.05 }, { 170, 0.32, "triangle", 0.05, 0.18 }, { 110, 0.5, "triangle", 0.055, 0.38 } },
}
K.MASTER_GAIN = 3.2

local function wave(kind, phase)
  local p = phase - floor(phase)
  if kind == "sine" then return sin(p * K.TAU)
  elseif kind == "square" then return p < 0.5 and 1 or -1
  elseif kind == "triangle" then return 1 - 4 * abs(p - 0.5)
  else return 2 * p - 1 end -- sawtooth
end

local function renderCue(def)
  local rate = 44100
  local length = 0
  for _, t in ipairs(def) do length = max(length, (t[5] or 0) + t[2] + 0.03) end
  local n = floor(length * rate)
  local data = love.sound.newSoundData(n, rate, 16, 1)
  local buffer = {}
  for i = 0, n - 1 do buffer[i] = 0 end
  for _, t in ipairs(def) do
    local freq, dur, kind, vol, delay = t[1], t[2], t[3], t[4], t[5] or 0
    local start = floor(delay * rate)
    local attack = 0.012
    local stop = dur + 0.02
    local floorGain = 0.0001
    local riseRate = math.log(vol / floorGain) / attack
    local fallRate = math.log(floorGain / vol) / (dur - attack)
    -- A gentle one-pole low-pass keeps square/saw tones closer to the
    -- band-limited oscillators the browser uses.
    local lp, alpha = 0, kind == "sine" and 1 or 0.55
    for i = 0, floor(stop * rate) do
      local tt = i / rate
      local gain
      if tt < attack then gain = floorGain * exp(riseRate * tt)
      elseif tt < dur then gain = vol * exp(fallRate * (tt - attack))
      else gain = 0 end
      local s = wave(kind, freq * tt)
      lp = lp + alpha * (s - lp)
      local idx = start + i
      if idx < n then buffer[idx] = buffer[idx] + lp * gain end
    end
  end
  for i = 0, n - 1 do data:setSample(i, clamp(buffer[i] * K.MASTER_GAIN, -1, 1)) end
  return data
end

local function buildSounds()
  for name, def in pairs(K.CUE_DEFS) do
    local data = renderCue(def)
    local pool = {}
    for i = 1, 4 do pool[i] = love.audio.newSource(data, "static") end
    cues[name] = { pool = pool, next = 1 }
  end
end

local function playCue(name)
  if not soundOn then return end
  local cue = cues[name]
  if not cue then return end
  local src = cue.pool[cue.next]
  cue.next = cue.next % #cue.pool + 1
  src:stop()
  src:play()
end

----------------------------------------------------------------------------
-- Controller
----------------------------------------------------------------------------
local activeJoystick = nil
local function vibrate(cue)
  if not activeJoystick then return end
  local settings = ({ blast = { 0.3, 0.5, 0.13 }, hit = { 0.3, 0.5, 0.13 }, shield = { 0.28, 0.46, 0.11 } })[cue]
  if settings then pcall(activeJoystick.setVibration, activeJoystick, settings[1], settings[2], settings[3]) end
end

----------------------------------------------------------------------------
-- Messages
----------------------------------------------------------------------------
local function setBanner(message, duration, danger)
  bannerMessage = message
  bannerTime = duration or 2
  bannerDanger = danger or false
end
local function showCombo(message)
  combo.text = message
  combo.t = 0
end
local function triggerFlash() flashTime = 0.5 end

local function formatScore(value)
  local s = tostring(floor(max(0, value)))
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  if out:sub(1, 1) == "," then out = out:sub(2) end
  return out
end
local function formatDuration(seconds)
  local total = max(0, floor(seconds))
  local h, m, s = floor(total / 3600), floor((total % 3600) / 60), total % 60
  if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
  return string.format("%d:%02d", m, s)
end

----------------------------------------------------------------------------
-- Game logic (ported from game.js)
----------------------------------------------------------------------------
local function createRunStats()
  return {
    mode = hardcoreMode and "HARDCORE" or "NORMAL",
    popcornMissed = 0, garbageDestroyed = 0, destroyedByStars = 0, destroyedByBlasts = 0,
    starsFired = 0, starsHit = 0, hitsTaken = 0, shieldBlocks = 0, blastsUsed = 0, bestCombo = 0,
    powerups = { shield = 0, speed = 0, super = 0, magnet = 0 },
  }
end

local function resetGame()
  elapsed, score, difficultyLevel, mastery = 0, 0, 1, 0
  spawnTimer, shotTimer, popcornSpawnTimer, powerupSpawnTimer = 0.55, 0.05, 0.3, 6.5
  popcornCollected, popcornChain, longestStreak = 0, 0, 0
  recommendationPower, movementPower, starRowSize, dualBlastUnlocked = 0, 0, 1, false
  shieldTime, shieldHits, speedTime, superStarsTime, magnetTime, superVolleyAngle = 0, 0, 0, 0, 0, 0
  killCombo, comboTimer, rushTimer, rushWarning = 0, 0, 11.5, nil
  shakeTime, shakePower, blast = 0, 0, nil
  bannerMessage, bannerTime, bannerDanger = "", 0, false
  blastReadyAnnounced = false
  local rec = bestFor()
  runStartingBestScore, runStartingBestStreak = rec.score, rec.streak
  runStats = createRunStats()
  enemies, projectiles, pickups, powerups, particles, floatingTexts = {}, {}, {}, {}, {}, {}
  player.x = (bounds.left + bounds.right) / 2
  player.y = (bounds.top + bounds.bottom) / 2
  player.vx, player.vy = 0, 0
  player.lives = maximumLives()
  player.invulnerable, player.bob, player.moving, player.stationaryTime = 0, 0, false, 0
  player.trail = {}
  combo.t = 99
  flashTime = 0
end

local function enemyDefinition(kind) return K.ENEMY_DEFINITIONS[kind] end

local function chooseEnemyKind(forceKind)
  if forceKind then return forceKind end
  local roll = random()
  if difficultyLevel >= 3 and roll > 0.82 then return "heavy" end
  if difficultyLevel >= 2 and roll < min(0.2 + difficultyLevel * 0.025, 0.38) then return "fast" end
  return "standard"
end

local function addEnemy(x, y, kind, mode, vx, vy)
  local resolvedKind = chooseEnemyKind(kind)
  local def = enemyDefinition(resolvedKind)
  local speedScale = 1 + elapsed * 0.004 + max(0, difficultyLevel - 1) * 0.045
  enemies[#enemies + 1] = {
    x = x, y = y, vx = vx or 0, vy = vy or 0,
    radius = sw(def.radius), speed = sw(K.REFERENCE_ENEMY_SPEED) * def.speed * speedScale,
    hp = def.hp, maxHp = def.hp, color = def.color, scoreValue = def.score,
    kind = resolvedKind, mode = mode or "chase", phase = random() * K.TAU, hitFlash = 0,
    blastMarked = false, destroyed = false,
  }
end

local function spawnEnemy(forceKind)
  local kind = chooseEnemyKind(forceKind)
  local def = enemyDefinition(kind)
  local edge = floor(random() * 4)
  local margin = sw(def.radius + 28)
  local x, y
  if edge == 0 then x, y = rb(bounds.left, bounds.right), bounds.top - margin
  elseif edge == 1 then x, y = bounds.right + margin, rb(bounds.top, bounds.bottom)
  elseif edge == 2 then x, y = rb(bounds.left, bounds.right), bounds.bottom + margin
  else x, y = bounds.left - margin, rb(bounds.top, bounds.bottom) end
  addEnemy(x, y, kind)
end

local function queueGarbageRush()
  local horizontal = random() < 0.5
  local edge = horizontal and (random() < 0.5 and "top" or "bottom") or (random() < 0.5 and "left" or "right")
  local spanStart = horizontal and bounds.left or bounds.top
  local spanEnd = horizontal and bounds.right or bounds.bottom
  local span = spanEnd - spanStart
  local gapSize = clamp(span * 0.23, sw(86), sw(158))
  local gapCenter = rb(spanStart + gapSize * 0.65, spanEnd - gapSize * 0.65)
  rushWarning = { edge = edge, gapCenter = gapCenter, gapSize = gapSize, life = 1.15, totalLife = 1.15 }
  setBanner("GARBAGE RUSH — FIND THE OPENING", 1.5, true)
  playCue("miss")
end

local function launchGarbageRush(warning)
  local horizontal = warning.edge == "top" or warning.edge == "bottom"
  local spanStart = horizontal and bounds.left or bounds.top
  local spanEnd = horizontal and bounds.right or bounds.bottom
  local spacing = clamp((spanEnd - spanStart) / 7, sw(54), sw(88))
  local direction = (warning.edge == "top" or warning.edge == "left") and 1 or -1
  local rushSpeed = sw(150 + difficultyLevel * 11)
  local rushOffset = sw(42)
  local position = spanStart + spacing * 0.45
  while position < spanEnd do
    if abs(position - warning.gapCenter) >= warning.gapSize / 2 then
      local fast = random() < min(0.18 + difficultyLevel * 0.025, 0.34)
      local kind = fast and "fast" or "standard"
      if horizontal then
        addEnemy(position, warning.edge == "top" and bounds.top - rushOffset or bounds.bottom + rushOffset,
          kind, "rush", 0, rushSpeed * direction)
      else
        addEnemy(warning.edge == "left" and bounds.left - rushOffset or bounds.right + rushOffset, position,
          kind, "rush", rushSpeed * direction, 0)
      end
    end
    position = position + spacing
  end
  shakeTime, shakePower = 0.22, 5
  showCombo("GARBAGE RUSH")
end

local function isCollectibleGlowBlocked(x, y, others)
  if #others == 0 then return false end
  local clearance = sw(K.POPCORN_GLOW_RADIUS + K.POWERUP_GLOW_RADIUS + K.COLLECTIBLE_GLOW_GAP)
  local c2 = clearance * clearance
  for i = 1, #others do
    local o = others[i]
    local dx, dy = x - o.x, y - o.y
    if dx * dx + dy * dy < c2 then return true end
  end
  return false
end

local function choosePopcornPosition(radius)
  local pb = playerBounds
  local width, height = pb.right - pb.left, pb.bottom - pb.top
  local requiredDistance = min(mag(width, height) * 0.33, sw(280))
  local required2 = requiredDistance * requiredDistance
  local inset = sw(K.POPCORN_SAFE_BORDER)
  local cx, cy = (pb.left + pb.right) / 2, (pb.top + pb.bottom) / 2
  local minX, maxX = min(cx, pb.left + inset), max(cx, pb.right - inset)
  local minY, maxY = min(cy, pb.top + inset), max(cy, pb.bottom - inset)
  local enemyClearance = sw(70)
  local ec2 = enemyClearance * enemyClearance
  local hasBest, bestX, bestY, bestClear = false, 0, 0, -huge
  for candidate = 0, 94 do
    local x, y
    if candidate < 32 then
      x, y = rb(minX, maxX), rb(minY, maxY)
    else
      local g = candidate - 32
      local row, column = floor(g / 9), g % 9
      x = minX + ((maxX - minX) * (column + 0.5)) / 9
      y = minY + ((maxY - minY) * (row + 0.5)) / 7
    end
    if not isCollectibleGlowBlocked(x, y, powerups) then
      local pdx, pdy = x - player.x, y - player.y
      local pd2 = pdx * pdx + pdy * pdy
      local nearest = pd2
      local clearsEnemies = true
      for i = 1, #enemies do
        local e = enemies[i]
        local ex, ey = x - e.x, y - e.y
        local ed2 = ex * ex + ey * ey
        if ed2 < nearest then nearest = ed2 end
        if ed2 < ec2 then clearsEnemies = false end
      end
      if pd2 >= required2 and clearsEnemies then return x, y end
      if nearest > bestClear then bestClear, hasBest, bestX, bestY = nearest, true, x, y end
    end
  end
  if hasBest then return bestX, bestY end
  return nil
end

local function spawnPopcorn()
  if #pickups > 0 then return end
  local radius = sw(21)
  local x, y = choosePopcornPosition(radius)
  if not x then popcornSpawnTimer = 0.35; return end
  local totalTtl = clamp(8.8 - difficultyLevel * 0.18, 5.7, 8.6) * K.POPCORN_LIFETIME_MULTIPLIER
  pickups[#pickups + 1] = { x = x, y = y, radius = radius, ttl = totalTtl, totalTtl = totalTtl, phase = random() * K.TAU }
end

local function spawnPowerup()
  if #powerups > 0 then return end
  local ptype = K.POWERUP_TYPE_KEYS[floor(random() * #K.POWERUP_TYPE_KEYS) + 1]
  local hInset, topInset, bottomInset = sw(62), sw(55), sw(72)
  local x, y = (bounds.left + bounds.right) / 2, (bounds.top + bounds.bottom) / 2
  local attempts, blocked = 0, false
  local pc2 = sw(170) ^ 2
  local ec2 = sw(75) ^ 2
  repeat
    x = rb(bounds.left + hInset, bounds.right - hInset)
    y = rb(bounds.top + topInset, bounds.bottom - bottomInset)
    attempts = attempts + 1
    local pdx, pdy = x - player.x, y - player.y
    blocked = pdx * pdx + pdy * pdy < pc2
    local i = 1
    while not blocked and i <= #enemies do
      local e = enemies[i]
      local dx, dy = x - e.x, y - e.y
      blocked = dx * dx + dy * dy < ec2
      i = i + 1
    end
    if not blocked then blocked = isCollectibleGlowBlocked(x, y, pickups) end
  until attempts >= 18 or not blocked
  if isCollectibleGlowBlocked(x, y, pickups) then powerupSpawnTimer = 0.5; return end
  powerups[#powerups + 1] = { type = ptype, x = x, y = y, radius = sw(23), ttl = 11, totalTtl = 11, phase = random() * K.TAU }
end

local function addParticles(x, y, color, count, speed)
  count, speed = count or 10, speed or 120
  local speedMinimum = speed * 0.35
  local range = speed - speedMinimum
  for _ = 1, count do
    if #particles >= 420 then break end
    local a = random() * K.TAU
    local velocity = (speedMinimum + random() * range) * S
    local maxLife = 0.34 + random() * (0.78 - 0.34)
    particles[#particles + 1] = {
      x = x, y = y, vx = cos(a) * velocity, vy = sin(a) * velocity, life = maxLife, maxLife = maxLife,
      size = (2 + random() * 4) * S, color = color, star = random() < 0.24,
    }
  end
end

local function addFloatingText(x, y, text, color, large)
  local maxLife = large and 1.25 or 0.85
  floatingTexts[#floatingTexts + 1] = {
    x = x, y = y, text = text, color = color or C.goldBright, life = maxLife, maxLife = maxLife,
    size = max(10, sw(large and 28 or 18)),
  }
  local t = floatingTexts[#floatingTexts]
  t.sprite = D.getTextSprite(text, floor(t.size + 0.5), t.color)
end

local endGame -- forward

local function collectPowerup(index)
  local p = powerups[index]
  local def = K.POWERUP_TYPES[p.type]
  table.remove(powerups, index)
  powerupSpawnTimer = rb(8, 13)
  runStats.powerups[p.type] = runStats.powerups[p.type] + 1
  local message
  if p.type == "shield" then
    shieldTime, shieldHits = K.POWERUP_DURATION, K.SHIELD_HITS
    message = "SHIELD — " .. K.SHIELD_HITS .. " HITS / " .. K.POWERUP_DURATION .. " SECONDS"
  elseif p.type == "speed" then
    speedTime = K.POWERUP_DURATION
    message = "SUPER SPEED — " .. K.POWERUP_DURATION .. " SECONDS"
  elseif p.type == "super" then
    superStarsTime, shotTimer = K.POWERUP_DURATION, 0
    message = "SUPER STARS — " .. (10 * starRowSize) .. " AT A TIME / " .. K.POWERUP_DURATION .. " SECONDS"
  else
    magnetTime = K.POWERUP_DURATION
    message = "MAGNET — NEARBY COLLECTIBLES / " .. K.POWERUP_DURATION .. " SECONDS"
  end
  addParticles(p.x, p.y, def.color, 26, 210)
  addFloatingText(p.x, p.y - sw(34), def.label, def.color, true)
  showCombo(def.label .. " ACTIVATED")
  setBanner(message, 2.2, false)
  playCue("advance")
end

local function missPopcorn()
  popcornChain = 0
  mastery = max(0, mastery - 0.1)
  runStats.popcornMissed = runStats.popcornMissed + 1
  if hardcoreMode then endGame("missed-popcorn"); return end
  popcornSpawnTimer = 0.55
  local surgeCount = min(9, 3 + math.ceil(difficultyLevel * 0.75))
  for i = 0, surgeCount - 1 do
    spawnEnemy((i % 4 == 0 and difficultyLevel >= 2) and "fast" or nil)
  end
  setBanner("POPCORN MISSED — MORE GARBAGE HAS ARRIVED", 2.2, true)
  showCombo("GARBAGE SURGE")
  shakeTime, shakePower = 0.28, 6
  playCue("miss")
end

local function emitRecommendationRow(dx, dy, color, speed, projectileRadius)
  local startX = player.x
  local startY = player.y - player.drawHeight * 0.08
  local px, py = -dy, dx
  local rowSpacing = projectileRadius * 1.8
  local rowCenter = (starRowSize - 1) / 2
  for index = 0, starRowSize - 1 do
    local offset = (index - rowCenter) * rowSpacing
    projectiles[#projectiles + 1] = {
      x = startX + px * offset, y = startY + py * offset, vx = dx * speed, vy = dy * speed,
      radius = projectileRadius, color = color, rotation = random() * K.STAR_ROTATION_PERIOD,
    }
    runStats.starsFired = runStats.starsFired + 1
  end
end

local function currentShotInterval()
  local base = max(0.24, 0.36 - difficultyLevel * 0.008)
  return max(0.105, base * (0.88 ^ recommendationPower))
end
local function currentProjectileSpeed() return sw(690) * (1 + min(0.8, recommendationPower * 0.12)) end
local function currentProjectileRadius() return sw(min(20, 7 + recommendationPower * 1.4)) end

local function launchRecommendation(aimX, aimY, color)
  local startX = player.x
  local startY = player.y - player.drawHeight * 0.08
  local dx, dy = aimX - startX, aimY - startY
  local length = mag(dx, dy)
  if length < 1 then return false end
  emitRecommendationRow(dx / length, dy / length, color or C.goldBright, currentProjectileSpeed(), currentProjectileRadius())
  return true
end

local function fireSuperStars()
  local rc, rs = cos(superVolleyAngle), sin(superVolleyAngle)
  local speed, radius = currentProjectileSpeed(), currentProjectileRadius()
  for _, d in ipairs(K.SUPER_STAR_DIRECTIONS) do
    emitRecommendationRow(d.x * rc - d.y * rs, d.x * rs + d.y * rc, C.super, speed, radius)
  end
  superVolleyAngle = (superVolleyAngle + pi / 10) % K.TAU
end

local function cappedLeadTime(ox, oy, tx, ty, vx, vy, preferredLead, maxLeadFraction)
  local distance = mag(tx - ox, ty - oy)
  local targetSpeed = mag(vx or 0, vy or 0)
  if distance < 1 or targetSpeed < 1 then return 0 end
  return min(preferredLead, (distance * maxLeadFraction) / targetSpeed)
end

local function fireAutomaticRecommendation()
  if #enemies == 0 then return false end
  local rangeUpgrade = 1 + min(0.65, recommendationPower * 0.07)
  local maxRange = sw(560) * rangeUpgrade
  local maxRange2 = maxRange * maxRange
  local target, targetDistance2, bestThreat = nil, maxRange2, maxRange2
  for i = 1, #enemies do
    local e = enemies[i]
    if not e.destroyed then
      local dx, dy = player.x - e.x, player.y - e.y
      local d2 = dx * dx + dy * dy
      if d2 <= maxRange2 then
        local factor
        if e.kind == "fast" then factor = e.mode == "rush" and K.FAST_RUSH_THREAT_SCORE_FACTOR or K.FAST_THREAT_SCORE_FACTOR
        else factor = e.mode == "rush" and K.RUSH_THREAT_SCORE_FACTOR or 1 end
        local threat = d2 * factor
        if threat < bestThreat then bestThreat, targetDistance2, target = threat, d2, e end
      end
    end
  end
  if not target then return false end
  local close = sw(K.CLOSE_THREAT_RADIUS)
  local closeThreat = targetDistance2 <= close * close
  if not player.moving and not closeThreat then return false end
  local preferredLead = target.mode == "rush" and 0.11 or (target.kind == "fast" and 0.18 or 0.08)
  local lead = closeThreat and 0 or cappedLeadTime(player.x, player.y, target.x, target.y, target.vx, target.vy,
    preferredLead, K.MAX_RECOMMENDATION_LEAD_FRACTION)
  return launchRecommendation(target.x + (target.vx or 0) * lead, target.y + (target.vy or 0) * lead)
end

local function registerDestroy(enemy, fromBlast)
  enemy.destroyed = true
  killCombo = comboTimer > 0 and killCombo + 1 or 1
  comboTimer = 1.65
  local comboMultiplier = 1 + min(1.5, floor(killCombo / 6) * 0.5)
  local points = floor(enemy.scoreValue * comboMultiplier * (fromBlast and 0.64 or 1) + 0.5)
  score = score + points
  addBlastCharge(fromBlast and 0.006 or 0.018)
  runStats.garbageDestroyed = runStats.garbageDestroyed + 1
  runStats.bestCombo = max(runStats.bestCombo, killCombo)
  if fromBlast then runStats.destroyedByBlasts = runStats.destroyedByBlasts + 1
  else runStats.destroyedByStars = runStats.destroyedByStars + 1 end
  addParticles(enemy.x, enemy.y, C.goldBright, enemy.kind == "heavy" and 20 or 11, 165)
  addParticles(enemy.x, enemy.y, enemy.color, 7, 105)
  addFloatingText(enemy.x, enemy.y - enemy.radius, "+" .. points, C.goldLight)
  if not fromBlast then playCue("destroy") end
end

local function awardRecommendationUpgrade(pickup)
  recommendationPower = recommendationPower + 1
  local movementUpgraded = popcornChain % 20 == 0
  if movementUpgraded then movementPower = movementPower + 1 end
  local unlockedRowSize = min(5, 1 + floor(popcornChain / 100))
  local rowUpgraded = unlockedRowSize > starRowSize
  if rowUpgraded then starRowSize = unlockedRowSize end
  local dualUpgraded = not dualBlastUnlocked and popcornChain >= K.DUAL_BLAST_STREAK
  if dualUpgraded then dualBlastUnlocked = true end
  local n = popcornChain
  local message, comboText, floatText
  if dualUpgraded then
    message, comboText, floatText = n .. " POPCORNS IN A ROW — SECOND BLAST BAR UNLOCKED", "SECOND BLAST BAR UNLOCKED", "BLAST × 2"
  elseif rowUpgraded then
    message, comboText, floatText = n .. " POPCORNS IN A ROW — " .. starRowSize .. "-STAR ROWS UNLOCKED",
      starRowSize .. "-STAR ROWS UNLOCKED", "★ × " .. starRowSize
  elseif movementUpgraded then
    message, comboText, floatText = n .. " POPCORNS IN A ROW — STARS + MOVEMENT FASTER", "STARS + MOVEMENT UPGRADED", "★ + SPEED ★"
  else
    message, comboText, floatText = n .. " POPCORNS IN A ROW — FASTER, LARGER STARS", "RECOMMENDATION STARS UPGRADED", "★ UPGRADE ★"
  end
  showCombo(comboText)
  setBanner(message, 2.4, false)
  addFloatingText(pickup.x, pickup.y - sw(38), floatText, C.goldBright, true)
  playCue("advance")
end

local function collectPopcorn(index)
  local pickup = pickups[index]
  table.remove(pickups, index)
  popcornCollected = popcornCollected + 1
  popcornChain = popcornChain + 1
  longestStreak = max(longestStreak, popcornChain)
  popcornSpawnTimer = 0.65
  local points = 300 + min(500, max(0, popcornChain - 1) * 75)
  score = score + points
  addBlastCharge(0.22)
  local restored = not hardcoreMode and popcornCollected % 6 == 0 and player.lives < maximumLives()
  if restored then player.lives = player.lives + 1 end
  addParticles(pickup.x, pickup.y, C.cream, 18, 165)
  addFloatingText(pickup.x, pickup.y - sw(20), restored and ("+" .. points .. "  ★ RESTORED") or ("+" .. points .. "  POPCORN"), C.cream, true)
  if popcornChain % 10 == 0 then
    awardRecommendationUpgrade(pickup)
  else
    showCombo(popcornChain > 1 and (popcornChain .. " POPCORNS IN A ROW") or "POPCORN COLLECTED")
  end
  playCue("popcorn")
end

local function damagePlayer(enemyIndex)
  if gameState ~= "running" then return end
  local enemy = enemies[enemyIndex]
  if player.invulnerable > 0 then
    if enemy then
      enemy.destroyed = true
      table.remove(enemies, enemyIndex)
      addParticles(enemy.x, enemy.y, enemy.color, 5, 90)
    end
    return
  end
  if enemy then enemy.destroyed = true end
  table.remove(enemies, enemyIndex)

  if shieldTime > 0 and shieldHits > 0 then
    shieldHits = shieldHits - 1
    runStats.shieldBlocks = runStats.shieldBlocks + 1
    player.invulnerable = 0.24
    shakeTime, shakePower = 0.15, 4
    addParticles(player.x, player.y, C.shield, 20, 180)
    addFloatingText(player.x, player.y - sw(54), "SHIELD BLOCKED IT", C.shield, true)
    if shieldHits > 0 then
      setBanner("SHIELD BLOCKED GARBAGE — " .. shieldHits .. " HITS LEFT", 1.6, false)
    else
      shieldTime = 0
      setBanner("SHIELD BLOCKED GARBAGE — SHIELD BROKEN", 1.8, true)
    end
    playCue("destroy")
    vibrate("shield")
    return
  end

  player.lives = max(0, player.lives - 1)
  runStats.hitsTaken = runStats.hitsTaken + 1
  player.invulnerable = 1.18
  player.stationaryTime = 0
  mastery = max(0, mastery - 0.18)
  popcornChain, killCombo, comboTimer = 0, 0, 0
  shakeTime, shakePower = 0.42, 11
  addParticles(player.x, player.y, C.red, 22, 210)
  addFloatingText(player.x, player.y - sw(54), "GARBAGE!", hex("#ff806b"), true)
  setBanner("GARBAGE TOUCHED THE MOVIE MASTER", 1.7, true)
  playCue("hit")
  vibrate("hit")
  if enemy then
    local dx, dy = player.x - enemy.x, player.y - enemy.y
    local length = mag(dx, dy)
    if length == 0 then length = 1 end
    local knock = sw(34)
    player.x = clamp(player.x + dx / length * knock, playerBounds.left, playerBounds.right)
    player.y = clamp(player.y + dy / length * knock, playerBounds.top, playerBounds.bottom)
  end
  if player.lives <= 0 then endGame("garbage") end
end

local function activateBlast()
  if gameState ~= "running" or mastery < 0.999 or blast then return end
  mastery = max(0, mastery - 1)
  local another = mastery >= 0.999
  blastReadyAnnounced = another
  runStats.blastsUsed = runStats.blastsUsed + 1
  blast = { x = player.x, y = player.y, radius = 0, maxRadius = mag(W, H) * 1.06, life = 0, duration = 0.72 }
  for _, e in ipairs(enemies) do e.blastMarked = false end
  shakeTime, shakePower = 0.56, 9
  triggerFlash()
  showCombo("BLOCKBUSTER BLAST")
  setBanner(another and "BLOCKBUSTER BLAST — ANOTHER BLAST READY" or "BLOCKBUSTER BLAST", 1.15, false)
  playCue("blast")
  vibrate("blast")
end

-- Movement input (filled by the input code each frame).
local moveInput = { x = 0, y = 0 }

local function updateMovement(dt)
  local dx, dy = moveInput.x, moveInput.y
  local l2 = dx * dx + dy * dy
  if l2 > 1 then local l = sqrt(l2); dx, dy = dx / l, dy / l end
  if dx == 0 and dy == 0 then
    player.moving = false
    player.stationaryTime = player.stationaryTime + dt
    player.vx, player.vy = 0, 0
    return
  end
  local px, py = player.x, player.y
  local speed = player.speed * (1 + min(0.6, movementPower * 0.1)) * (speedTime > 0 and 1.85 or 1)
  local nx = clamp(player.x + dx * speed * dt, playerBounds.left, playerBounds.right)
  local ny = clamp(player.y + dy * speed * dt, playerBounds.top, playerBounds.bottom)
  local adx, ady = nx - px, ny - py
  player.moving = adx * adx + ady * ady > 0.01
  if player.moving then player.stationaryTime = 0 else player.stationaryTime = player.stationaryTime + dt end
  player.vx = dt > 0 and adx / dt or 0
  player.vy = dt > 0 and ady / dt or 0
  player.x, player.y = nx, ny
end

-- The speed-boost streaks follow the path the Movie Master actually took, so
-- they bend smoothly behind him when he changes direction instead of snapping
-- to the new one. When he stops or the boost ends, the streaks shrink away.
function D.updateTrail(dt)
  local trail = player.trail
  for i = 1, #trail do trail[i].age = trail[i].age + dt end
  if speedTime > 0 and player.moving then
    table.insert(trail, 1, { x = player.x, y = player.y - sw(8), age = 0 })
  end
  local maxLength, length, keep = sw(K.TRAIL_LENGTH), 0, min(#trail, K.TRAIL_POINTS)
  for i = 2, keep do
    length = length + mag(trail[i].x - trail[i - 1].x, trail[i].y - trail[i - 1].y)
    if length >= maxLength then keep = i; break end
  end
  for i = #trail, keep + 1, -1 do trail[i] = nil end
  while #trail > 0 and trail[#trail].age > K.TRAIL_LIFE do trail[#trail] = nil end
end

local function updateEnemies(dt)
  if #enemies == 0 then return end
  local rushMargin = sw(90)
  local close = sw(K.CLOSE_THREAT_RADIUS)
  local close2 = close * close
  local pxp, pyp, pvx, pvy = player.x, player.y, player.vx, player.vy
  local pspeed2 = pvx * pvx + pvy * pvy
  local canPredict = pspeed2 >= 1
  local pspeed = canPredict and sqrt(pspeed2) or 0
  local maxPredScale = canPredict and K.MAX_PURSUIT_LEAD_FRACTION / pspeed or 0
  local capScale = canPredict and pspeed / K.MAX_PURSUIT_LEAD_FRACTION or 0
  local caps = { fast = (0.23 * capScale) ^ 2, heavy = (0.04 * capScale) ^ 2, standard = (0.11 * capScale) ^ 2 }
  local preferred = { fast = 0.23, heavy = 0.04, standard = 0.11 }
  local rl, rr = bounds.left - rushMargin, bounds.right + rushMargin
  local rt, rbm = bounds.top - rushMargin, bounds.bottom + rushMargin
  local i = #enemies
  while i >= 1 do
    local e = enemies[i]
    local removed = false
    e.phase = e.phase + dt * (e.kind == "fast" and 8 or 4.5)
    if e.hitFlash > 0 then e.hitFlash = max(0, e.hitFlash - dt) end
    if e.mode == "rush" then
      e.x = e.x + e.vx * dt
      e.y = e.y + e.vy * dt
      if e.x < rl or e.x > rr or e.y < rt or e.y > rbm then
        e.destroyed = true
        table.remove(enemies, i)
        removed = true
      end
    else
      local ddx, ddy = pxp - e.x, pyp - e.y
      local dd2 = ddx * ddx + ddy * ddy
      local isClose = dd2 <= close2
      local prediction
      if isClose or not canPredict then prediction = 0
      elseif dd2 >= caps[e.kind] then prediction = preferred[e.kind]
      else prediction = sqrt(dd2) * maxPredScale end
      local tx, ty = pxp + pvx * prediction, pyp + pvy * prediction
      local dx, dy = tx - e.x, ty - e.y
      local length = sqrt(dx * dx + dy * dy)
      if length == 0 then length = 1 end
      e.vx, e.vy = dx / length * e.speed, dy / length * e.speed
      e.x = e.x + e.vx * dt
      e.y = e.y + e.vy * dt
    end
    if not removed then
      local hx, hy = e.x - pxp, e.y - pyp
      local hit = e.radius + player.radius
      if hx * hx + hy * hy < hit * hit then
        damagePlayer(i)
        if gameState ~= "running" then return end
      end
    end
    i = i - 1
  end
end

local function updateProjectiles(dt)
  if #projectiles == 0 then return end
  local margin = sw(30)
  local maxX, maxY = W + margin, H + margin
  local rotationStep = dt * 10
  local destroyedAny = false
  local i = #projectiles
  while i >= 1 do
    local p = projectiles[i]
    local ox, oy = p.x, p.y
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.rotation = (p.rotation + rotationStep) % K.STAR_ROTATION_PERIOD
    local cx, cy = p.x, p.y
    local removed = false
    if cx < -margin or cx > maxX or cy < -margin or cy > maxY then
      projectiles[i] = projectiles[#projectiles]
      projectiles[#projectiles] = nil
      removed = true
    else
      local sx, sy = cx - ox, cy - oy
      local sl2 = sx * sx + sy * sy
      local minX, maxX2 = min(ox, cx), max(ox, cx)
      local minY, maxY2 = min(oy, cy), max(oy, cy)
      for j = 1, #enemies do
        local e = enemies[j]
        if not e.destroyed then
          local hd = p.radius + e.radius
          if not (e.x + hd < minX or e.x - hd > maxX2 or e.y + hd < minY or e.y - hd > maxY2) then
            local proj = 0
            if sl2 > 0 then proj = clamp(((e.x - ox) * sx + (e.y - oy) * sy) / sl2, 0, 1) end
            local qx, qy = e.x - (ox + sx * proj), e.y - (oy + sy * proj)
            if qx * qx + qy * qy <= hd * hd then
              projectiles[i] = projectiles[#projectiles]
              projectiles[#projectiles] = nil
              removed = true
              runStats.starsHit = runStats.starsHit + 1
              e.hp = e.hp - 1
              e.hitFlash = 0.12
              addParticles(cx, cy, p.color, 6, 90)
              if e.hp <= 0 then
                e.destroyed = true
                destroyedAny = true
                registerDestroy(e, false)
              end
              break
            end
          end
        end
      end
    end
    i = i - 1
  end
  if destroyedAny then
    local w = 0
    for r = 1, #enemies do
      local e = enemies[r]
      if not e.destroyed then w = w + 1; enemies[w] = e end
    end
    for r = #enemies, w + 1, -1 do enemies[r] = nil end
  end
end

local function applyMagnet(c, dt)
  if magnetTime <= 0 then return end
  local dx, dy = player.x - c.x, player.y - c.y
  local d2 = dx * dx + dy * dy
  local maxD = sw(K.MAGNET_RADIUS)
  if d2 < 1 or d2 > maxD * maxD then return end
  local d = sqrt(d2)
  local pull = min(sw(900), sw(320) + d * 0.7)
  local step = min(d, pull * dt)
  c.x = c.x + dx / d * step
  c.y = c.y + dy / d * step
end

local function updatePickups(dt)
  for i = #pickups, 1, -1 do
    local p = pickups[i]
    applyMagnet(p, dt)
    p.ttl = p.ttl - dt
    p.phase = p.phase + dt * 5
    if p.ttl <= 0 then
      table.remove(pickups, i)
      missPopcorn()
      if gameState ~= "running" then return end
    else
      local reach = p.radius + player.radius + sw(7)
      local dx, dy = p.x - player.x, p.y - player.y
      if dx * dx + dy * dy <= reach * reach then collectPopcorn(i) end
    end
  end
end

local function updatePowerups(dt)
  for i = #powerups, 1, -1 do
    local p = powerups[i]
    applyMagnet(p, dt)
    p.ttl = p.ttl - dt
    p.phase = p.phase + dt * 4.2
    if p.ttl <= 0 then
      table.remove(powerups, i)
      powerupSpawnTimer = rb(5.5, 9)
    else
      local reach = p.radius + player.radius + sw(8)
      local dx, dy = p.x - player.x, p.y - player.y
      if dx * dx + dy * dy <= reach * reach then collectPowerup(i) end
    end
  end
end

local function updateBlast(dt)
  if not blast then return end
  blast.life = blast.life + dt
  local progress = clamp(blast.life / blast.duration, 0, 1)
  blast.radius = blast.maxRadius * (1 - (1 - progress) ^ 3)
  for i = #enemies, 1, -1 do
    local e = enemies[i]
    if not e.blastMarked then
      local range = blast.radius + e.radius
      local dx, dy = blast.x - e.x, blast.y - e.y
      if dx * dx + dy * dy <= range * range then
        e.blastMarked = true
        table.remove(enemies, i)
        registerDestroy(e, true)
      end
    end
  end
  if progress >= 1 then blast = nil end
end

local function updateParticles(dt)
  local hd, vd = 0.08 ^ dt, 0.12 ^ dt
  local gravity = sw(45) * dt
  local i = #particles
  while i >= 1 do
    local p = particles[i]
    p.life = p.life - dt
    if p.life <= 0 then
      particles[i] = particles[#particles]
      particles[#particles] = nil
    else
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      p.vx = p.vx * hd
      p.vy = p.vy * vd + gravity
    end
    i = i - 1
  end
end

local function updateFloatingTexts(dt)
  local rise = sw(29) * dt
  for i = #floatingTexts, 1, -1 do
    local t = floatingTexts[i]
    t.life = t.life - dt
    t.y = t.y - rise
    if t.life <= 0 then table.remove(floatingTexts, i) end
  end
end

local function updateInterfaceState()
  trackRunRecords(floor(score), longestStreak)
  local fullyCharged = mastery >= 0.999
  if fullyCharged and not blastReadyAnnounced and gameState == "running" then
    blastReadyAnnounced = true
    setBanner("BLOCKBUSTER BLAST READY — PRESS A, B, X OR Y", 2.2, false)
    showCombo("BLOCKBUSTER BLAST READY")
  elseif not fullyCharged then
    blastReadyAnnounced = false
  end
end

local function update(dt)
  elapsed = elapsed + dt
  if player.invulnerable > 0 then player.invulnerable = max(0, player.invulnerable - dt) end
  if shieldTime > 0 then
    shieldTime = max(0, shieldTime - dt)
    if shieldTime == 0 then shieldHits = 0 end
  elseif shieldHits ~= 0 then shieldHits = 0 end
  if speedTime > 0 then speedTime = max(0, speedTime - dt) end
  if superStarsTime > 0 then superStarsTime = max(0, superStarsTime - dt) end
  if magnetTime > 0 then magnetTime = max(0, magnetTime - dt) end
  player.bob = player.bob + dt * (player.moving and 8 or 3)
  if bannerTime > 0 then bannerTime = max(0, bannerTime - dt) end

  local nextDifficulty = 1 + floor(elapsed / 27)
  if nextDifficulty > difficultyLevel then
    difficultyLevel = nextDifficulty
    setBanner("MORE GARBAGE IS APPROACHING", 2, true)
    playCue("advance")
  end

  updateMovement(dt)
  D.updateTrail(dt)
  spawnTimer = spawnTimer - dt
  if spawnTimer <= 0 then
    spawnEnemy()
    if difficultyLevel >= 4 and random() < min(0.1 + difficultyLevel * 0.018, 0.28) then spawnEnemy() end
    spawnTimer = max(0.34, 1.05 - elapsed * 0.0085) * rb(0.78, 1.15)
  end

  if shotTimer > 0 then shotTimer = max(0, shotTimer - dt) end
  if superStarsTime > 0 and shotTimer <= 0 then
    fireSuperStars()
    shotTimer = currentShotInterval()
  elseif shotTimer <= 0 then
    local fired = fireAutomaticRecommendation()
    shotTimer = (fired or player.moving) and currentShotInterval() or 0.08
  end

  if #pickups == 0 then
    popcornSpawnTimer = popcornSpawnTimer - dt
    if popcornSpawnTimer <= 0 then spawnPopcorn() end
  end
  if #powerups == 0 then
    powerupSpawnTimer = powerupSpawnTimer - dt
    if powerupSpawnTimer <= 0 then spawnPowerup() end
  end

  rushTimer = rushTimer - dt
  if rushTimer <= 0 and not rushWarning then
    queueGarbageRush()
    rushTimer = rb(13.5, 17) - min(3, difficultyLevel * 0.3)
  end
  if rushWarning then
    rushWarning.life = rushWarning.life - dt
    if rushWarning.life <= 0 then
      local w = rushWarning
      rushWarning = nil
      launchGarbageRush(w)
    end
  end

  if comboTimer > 0 then
    comboTimer = max(0, comboTimer - dt)
    if comboTimer == 0 then killCombo = 0 end
  elseif killCombo ~= 0 then killCombo = 0 end

  updatePowerups(dt)
  updatePickups(dt)
  if gameState ~= "running" then return end
  updateEnemies(dt)
  if gameState ~= "running" then return end
  updateProjectiles(dt)
  updateBlast(dt)
  updateParticles(dt)
  updateFloatingTexts(dt)
  if shakeTime > 0 then shakeTime = max(0, shakeTime - dt) end
  updateInterfaceState()
end

----------------------------------------------------------------------------
-- Menus
----------------------------------------------------------------------------
local menu = { buttons = {}, selected = 1, context = "", infoPage = 1 }
local setState -- forward

local function startGame()
  resetGame()
  gameState = "running"
  overlay = nil
  setBanner("KEEP MOVING. COLLECT THE POPCORN.", 2.8, false)
  playCue("start")
  inputGuard = 0.15
end

local function pauseGame()
  gameState = "paused"
  inputGuard = 0.1
end

local function beginResume()
  gameState = "resuming"
  resumeStartedAt = clock
end

endGame = function(reason)
  if gameState == "gameover" then return end
  finalScore = floor(score)
  local scoreRecord = finalScore > runStartingBestScore
  local streakRecord = longestStreak > runStartingBestStreak
  trackRunRecords(finalScore, longestStreak)
  saveData()
  gameState = "gameover"
  overlay = nil
  if reason == "manual" then gameoverTitle = "RUN ENDED"
  elseif reason == "missed-popcorn" then gameoverTitle = "YOU MISSED A POPCORN"
  elseif scoreRecord then gameoverTitle = "NEW BEST SCORE"
  elseif streakRecord then gameoverTitle = "NEW BEST STREAK"
  else gameoverTitle = "OVERWHELMED BY GARBAGE" end
  playCue("gameover")
  inputGuard = 0.9
end

local function toggleHardcore()
  hardcoreMode = not hardcoreMode
  saveData()
end
local function toggleSound()
  soundOn = not soundOn
  if not soundOn then love.audio.stop() end
  saveData()
end
local function quitGame()
  saveData()
  love.event.quit()
end

-- Buttons: { label, x, y, w, h, kind = "primary"|"secondary"|"danger", action }
local function button(label, x, y, w, h, kind, action)
  return { label = label, x = x, y = y, w = w, h = h, kind = kind or "secondary", action = action }
end

local function buildMenu()
  local b = {}
  local ctx = overlay or gameState
  if overlay == "info" then
    local last = menu.infoPage >= K.INFO_PAGE_COUNT
    b[1] = button(last and "CLOSE" or "NEXT PAGE", 230, 420, 180, 38, "primary", function()
      if last then overlay = nil else menu.infoPage = menu.infoPage + 1 end
    end)
  elseif overlay == "stats" then
    b[1] = button("BACK", 240, 420, 160, 38, "primary", function() overlay = nil end)
  elseif gameState == "ready" then
    local x0, full = 186, 426
    local half = (full - 12) / 2
    b[#b + 1] = button("START THE GAME", x0, 228, full, 40, "primary", startGame)
    b[#b + 1] = button("HOW TO PLAY", x0, 280, half, 36, "secondary", function() overlay = "info"; menu.infoPage = 1 end)
    b[#b + 1] = button("HARDCORE: " .. (hardcoreMode and "ON" or "OFF"), x0 + half + 12, 280, half, 36, "secondary", toggleHardcore)
    b[#b + 1] = button("SOUND: " .. (soundOn and "ON" or "OFF"), x0, 326, half, 36, "secondary", toggleSound)
    b[#b + 1] = button("QUIT", x0 + half + 12, 326, half, 36, "secondary", quitGame)
  elseif gameState == "paused" then
    b[#b + 1] = button("CONTINUE", 170, 262, 300, 40, "primary", beginResume)
    b[#b + 1] = button("RESET", 170, 314, 144, 36, "secondary", function() gameState = "reset-confirm" end)
    b[#b + 1] = button("END GAME", 326, 314, 144, 36, "danger", function() gameState = "end-confirm" end)
    b[#b + 1] = button("SOUND: " .. (soundOn and "ON" or "OFF"), 170, 360, 144, 36, "secondary", toggleSound)
    b[#b + 1] = button("QUIT", 326, 360, 144, 36, "secondary", function() gameState = "quit-confirm" end)
  elseif gameState == "reset-confirm" then
    b[#b + 1] = button("CANCEL", 150, 262, 160, 40, "primary", function() gameState = "paused" end)
    b[#b + 1] = button("RESET GAME", 330, 262, 160, 40, "danger", startGame)
  elseif gameState == "end-confirm" then
    b[#b + 1] = button("CANCEL", 150, 262, 160, 40, "primary", function() gameState = "paused" end)
    b[#b + 1] = button("END GAME", 330, 262, 160, 40, "danger", function() endGame("manual") end)
  elseif gameState == "quit-confirm" then
    b[#b + 1] = button("CANCEL", 150, 262, 160, 40, "primary", function() gameState = "paused" end)
    b[#b + 1] = button("QUIT GAME", 330, 262, 160, 40, "danger", function() saveData(); quitGame() end)
  elseif gameState == "gameover" then
    b[#b + 1] = button("TRY AGAIN", 40, 306, 560, 42, "primary", startGame)
    b[#b + 1] = button("GAME STATS", 40, 360, 128, 36, "secondary", function() overlay = "stats" end)
    b[#b + 1] = button("HARDCORE: " .. (hardcoreMode and "ON" or "OFF"), 176, 360, 156, 36, "secondary", toggleHardcore)
    b[#b + 1] = button("TITLE SCREEN", 340, 360, 160, 36, "secondary", function() gameState = "ready" end)
    b[#b + 1] = button("QUIT", 508, 360, 92, 36, "secondary", quitGame)
  end
  if ctx ~= menu.context then
    menu.context = ctx
    menu.selected = 1
  end
  menu.buttons = b
  if menu.selected > #b then menu.selected = max(1, #b) end
end

-- D-pad navigation between buttons: left and right only move within a row,
-- up and down only to a button that lines up with the current one.
local function moveSelection(dx, dy)
  local b = menu.buttons
  if #b == 0 then return end
  local cur = b[menu.selected]
  local cx, cy = cur.x + cur.w / 2, cur.y + cur.h / 2
  local winner, winnerScore = nil, huge
  for i, cand in ipairs(b) do
    if i ~= menu.selected then
      local ddx = cand.x + cand.w / 2 - cx
      local ddy = cand.y + cand.h / 2 - cy
      local forward = ddx * dx + ddy * dy
      if forward > 2 then
        local overlap
        if dx ~= 0 then overlap = min(cur.y + cur.h, cand.y + cand.h) - max(cur.y, cand.y)
        else overlap = min(cur.x + cur.w, cand.x + cand.w) - max(cur.x, cand.x) end
        local s = forward + abs(ddx * dy - ddy * dx) * 2
        if overlap > 0 and s < winnerScore then winner, winnerScore = i, s end
      end
    end
  end
  if winner then menu.selected = winner end
end

-- On the How to Play pages, left and right turn the page.
function menu.navigate(dx, dy)
  if overlay == "info" then
    if dx ~= 0 then menu.infoPage = clamp(menu.infoPage + dx, 1, K.INFO_PAGE_COUNT) end
    return
  end
  moveSelection(dx, dy)
end

local function activateSelected()
  local btn = menu.buttons[menu.selected]
  if btn and btn.action then btn.action() end
end

local function menuActive()
  return overlay ~= nil or gameState == "ready" or gameState == "paused" or gameState == "reset-confirm"
    or gameState == "end-confirm" or gameState == "quit-confirm" or gameState == "gameover"
end

local function menuBack()
  if overlay then overlay = nil
  elseif gameState == "reset-confirm" or gameState == "end-confirm" or gameState == "quit-confirm" then gameState = "paused"
  elseif gameState == "paused" then beginResume() end
end

----------------------------------------------------------------------------
-- Input
----------------------------------------------------------------------------
K.BLAST_BUTTONS = { a = true, b = true, x = true, y = true, rightshoulder = true, leftshoulder = true }
K.CONFIRM_BUTTONS = { a = true, b = true }
local navRepeat = { dir = nil, timer = 0 }

local function readDirection()
  local x, y = 0, 0
  -- Keyboard
  if love.keyboard.isDown("left", "a") then x = x - 1 end
  if love.keyboard.isDown("right", "d") then x = x + 1 end
  if love.keyboard.isDown("up", "w") then y = y - 1 end
  if love.keyboard.isDown("down", "s") then y = y + 1 end
  local digital = x ~= 0 or y ~= 0
  local js = activeJoystick
  if js and js:isGamepad() then
    -- D-pad first (the RG35XX Plus has no sticks), then the left stick.
    local dx, dy = 0, 0
    if js:isGamepadDown("dpleft") then dx = dx - 1 end
    if js:isGamepadDown("dpright") then dx = dx + 1 end
    if js:isGamepadDown("dpup") then dy = dy - 1 end
    if js:isGamepadDown("dpdown") then dy = dy + 1 end
    if dx ~= 0 or dy ~= 0 then
      x, y, digital = x + dx, y + dy, true
    elseif not digital then
      local ax, ay = clamp(js:getGamepadAxis("leftx"), -1, 1), clamp(js:getGamepadAxis("lefty"), -1, 1)
      local m2 = ax * ax + ay * ay
      if m2 > K.GAMEPAD_DEAD_ZONE * K.GAMEPAD_DEAD_ZONE then
        local m = sqrt(m2)
        local scaled = min(1, (m - K.GAMEPAD_DEAD_ZONE) / (1 - K.GAMEPAD_DEAD_ZONE))
        x, y = ax / m * scaled, ay / m * scaled
      end
    end
  end
  return clamp(x, -1, 1), clamp(y, -1, 1)
end

local function updateMenuNavigation(dt)
  local x, y = readDirection()
  local dir = nil
  if abs(x) > 0.5 or abs(y) > 0.5 then
    if abs(x) >= abs(y) then dir = x > 0 and "right" or "left" else dir = y > 0 and "down" or "up" end
  end
  if dir ~= navRepeat.dir then
    navRepeat.dir = dir
    navRepeat.timer = 0.32
    if dir then
      local v = ({ left = { -1, 0 }, right = { 1, 0 }, up = { 0, -1 }, down = { 0, 1 } })[dir]
      menu.navigate(v[1], v[2])
    end
  elseif dir then
    navRepeat.timer = navRepeat.timer - dt
    if navRepeat.timer <= 0 then
      navRepeat.timer = 0.13
      local v = ({ left = { -1, 0 }, right = { 1, 0 }, up = { 0, -1 }, down = { 0, 1 } })[dir]
      menu.navigate(v[1], v[2])
    end
  end
end

local function onConfirm()
  if inputGuard > 0 then return end
  if menuActive() then activateSelected() end
end

local function onPause()
  if inputGuard > 0 and gameState ~= "running" then return end
  if overlay then overlay = nil; return end
  if gameState == "running" then pauseGame()
  elseif gameState == "paused" then beginResume()
  elseif gameState == "resuming" then pauseGame()
  elseif gameState == "ready" or gameState == "gameover" then startGame()
  elseif gameState == "reset-confirm" or gameState == "end-confirm" or gameState == "quit-confirm" then gameState = "paused" end
end

function love.gamepadpressed(joystick, buttonName)
  activeJoystick = joystick
  if buttonName == "start" then onPause(); return end
  if buttonName == "back" then
    if overlay then overlay = nil elseif gameState == "running" then pauseGame() end
    return
  end
  if overlay == "info" and (buttonName == "leftshoulder" or buttonName == "rightshoulder") then
    menu.navigate(buttonName == "leftshoulder" and -1 or 1, 0)
    return
  end
  if gameState == "running" then
    if K.BLAST_BUTTONS[buttonName] then activateBlast() end
    return
  end
  if K.CONFIRM_BUTTONS[buttonName] then onConfirm() end
end

-- L2 and R2 are analog triggers: fire once each time one is pressed past halfway.
-- (A Joystick can't hold extra fields, so the pressed state is kept here.)
local triggersDown = {}
function love.gamepadaxis(joystick, axis, value)
  if axis == "triggerright" or axis == "triggerleft" then
    local key = joystick:getID() .. axis
    local down = value > 0.5
    if down and not triggersDown[key] and gameState == "running" then activateBlast() end
    triggersDown[key] = down
  end
end

function love.joystickadded(joystick)
  if not activeJoystick or not activeJoystick:isConnected() then activeJoystick = joystick end
end
function love.joystickremoved(joystick)
  if activeJoystick == joystick then
    activeJoystick = nil
    for _, js in ipairs(love.joystick.getJoysticks()) do
      if js:isConnected() then activeJoystick = js; break end
    end
  end
end

function love.keypressed(key)
  if key == "space" or key == "return" or key == "kpenter" then
    if gameState == "running" then
      if key == "space" then activateBlast() end
    else
      onConfirm()
    end
  elseif key == "escape" or key == "backspace" then
    if overlay or gameState:find("confirm") then menuBack()
    elseif gameState == "running" or gameState == "paused" or gameState == "resuming" then onPause()
    elseif key == "escape" and gameState == "ready" then quitGame() end
  elseif key == "p" then
    if gameState == "running" or gameState == "paused" or gameState == "resuming" then onPause() end
  end
end

function love.focus(focused)
  if not focused and (gameState == "running" or gameState == "resuming") then pauseGame() end
end

----------------------------------------------------------------------------
-- Drawing helpers
----------------------------------------------------------------------------
function D.popcornWarningOpacity(p)
  if p.ttl >= K.POPCORN_BLINK_DURATION then return 1 end
  local e = K.POPCORN_BLINK_DURATION - max(0, p.ttl)
  local urgency = clamp(e / K.POPCORN_BLINK_DURATION, 0, 1)
  local el = K.POPCORN_BLINK_DURATION * urgency
  local cycles = K.POPCORN_BLINK_START_RATE * el + (K.POPCORN_BLINK_END_RATE - K.POPCORN_BLINK_START_RATE) * el * urgency * 0.5
  local w = 0.5 + cos(cycles * K.TAU) * 0.5
  return K.POPCORN_BLINK_MIN_OPACITY + (1 - K.POPCORN_BLINK_MIN_OPACITY) * w
end

function D.drawEmoji(img, x, y, size, alpha)
  lg.setColor(1, 1, 1, alpha or 1)
  lg.draw(img, x, y, 0, size / 128, size / 128, 64, 64)
end

-- Text with a dark outline (canvas strokeText + fillText).
function D.outlinedText(font, text, x, y, color, alpha, outline)
  lg.setFont(font)
  local w = font:getWidth(text)
  local h = font:getHeight()
  local tx, ty = floor(x - w / 2 + 0.5), floor(y - h / 2 + 0.5)
  local o = outline or 1
  lg.setColor(C.ink[1], C.ink[2], C.ink[3], alpha)
  for ox = -o, o do
    for oy = -o, o do
      if ox ~= 0 or oy ~= 0 then lg.print(text, tx + ox, ty + oy) end
    end
  end
  setc(color, alpha)
  lg.print(text, tx, ty)
end

function D.drawBackground(time)
  lg.setColor(1, 1, 1, 1)
  lg.draw(bgImage, 0, 0)
  lg.setColor(229 / 255, 164 / 255, 8 / 255, 0.062)
  lg.draw(raysMesh, W / 2, H * 0.56, time * 0.016)
  local ts = time * 1.7
  for _, s in ipairs(backgroundStars) do
    setc(C.goldLight, 0.25 + sin(ts + s.phase) * 0.11)
    lg.rectangle("fill", s.x, s.y, s.size, s.size)
  end
  lg.setColor(229 / 255, 164 / 255, 8 / 255, 0.13)
  lg.setLineWidth(1)
  local y = bounds.top + 28
  while y < bounds.bottom do
    lg.line(bounds.left, floor(y) + 0.5, bounds.right, floor(y) + 0.5)
    y = y + 64
  end
  lg.setColor(4 / 255, 2 / 255, 1 / 255, 0.38)
  local x = 12
  while x < W do
    lg.rectangle("fill", x, bounds.top + 3, 21, 6)
    lg.rectangle("fill", x, bounds.bottom - 9, 21, 6)
    x = x + 38
  end
end

function D.glowLine(points, width, color, alpha, blur)
  lg.setLineJoin("none")
  for _, pass in ipairs(K.BLAST_GLOW_PASSES) do
    setc(color, alpha * pass[2] * 1.4)
    lg.setLineWidth(width + blur * pass[1])
    lg.line(points)
  end
  setc(color, alpha)
  lg.setLineWidth(width)
  lg.line(points)
end

function D.drawRushWarning(time)
  if not rushWarning then return end
  local w = rushWarning
  local pulse = 0.52 + (sin(time * 18) + 1) * 0.22
  local gs, ge = w.gapCenter - w.gapSize / 2, w.gapCenter + w.gapSize / 2
  local inset = sw(4)
  local red, glowRed = hex("#ff6d52"), hex("#ff3f24")
  local lines = {}
  if w.edge == "top" or w.edge == "bottom" then
    local y = w.edge == "top" and bounds.top + inset or bounds.bottom - inset
    lines = { { bounds.left, y, gs, y }, { ge, y, bounds.right, y } }
  else
    local x = w.edge == "left" and bounds.left + inset or bounds.right - inset
    lines = { { x, bounds.top, x, gs }, { x, ge, x, bounds.bottom } }
  end
  for _, l in ipairs(lines) do
    for _, pass in ipairs(K.BLAST_GLOW_PASSES) do
      setc(glowRed, pulse * pass[2] * 1.5)
      lg.setLineWidth(sw(7) + sw(16) * pass[1])
      lg.line(l)
    end
    setc(red, pulse)
    lg.setLineWidth(sw(7))
    lg.line(l)
  end
end

function D.drawPickups(time)
  for _, p in ipairs(pickups) do
    local pulse = 1 + sin(time * 5 + p.phase) * 0.09
    local progress = clamp(p.ttl / p.totalTtl, 0, 1)
    local danger = progress < K.POPCORN_DANGER_PROGRESS
    local alpha = p.ttl < K.POPCORN_BLINK_DURATION and D.popcornWarningOpacity(p) or 1
    lg.setColor(1, 1, 1, alpha)
    D.drawCentered(danger and sprites.beamDanger or sprites.beamNormal, p.x, p.y)
    lg.push()
    lg.translate(p.x, p.y)
    lg.scale(pulse, pulse)
    local discR = p.radius + sw(10)
    lg.setColor(1, 1, 1, alpha)
    D.drawCentered(danger and sprites.pickupGlowDanger or sprites.pickupGlow, 0, 0, discR / 10)
    if danger then lg.setColor(210 / 255, 75 / 255, 53 / 255, 0.42 * alpha) else lg.setColor(229 / 255, 164 / 255, 8 / 255, 0.4 * alpha) end
    lg.circle("fill", 0, 0, discR, 40)
    setc(danger and hex("#ff806b") or C.goldBright, alpha)
    lg.setLineWidth(sw(4))
    if progress > 0.001 then
      lg.arc("line", "open", 0, 0, p.radius + sw(15), -pi / 2, -pi / 2 + K.TAU * progress, 48)
    end
    D.drawEmoji(images.popcorn, 0, 0, floor(p.radius * 1.8 + 0.5), alpha)
    lg.pop()
  end
end

function D.drawPowerups(time)
  for _, p in ipairs(powerups) do
    local def = K.POWERUP_TYPES[p.type]
    local pulse = 1 + sin(time * 5.8 + p.phase) * 0.08
    local progress = clamp(p.ttl / p.totalTtl, 0, 1)
    lg.setColor(1, 1, 1, 1)
    D.drawCentered(sprites["beam_" .. p.type], p.x, p.y)
    lg.push()
    lg.translate(p.x, p.y)
    lg.scale(pulse, pulse)
    local discR = p.radius + sw(8)
    lg.setColor(1, 1, 1, 1)
    D.drawCentered(sprites["glow_" .. p.type], 0, 0, discR / 10)
    lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.92)
    lg.circle("fill", 0, 0, discR, 40)
    setc(def.color)
    lg.setLineWidth(sw(4))
    if progress > 0.001 then
      lg.arc("line", "open", 0, 0, p.radius + sw(14), -pi / 2, -pi / 2 + K.TAU * progress, 48)
    end
    lg.setLineWidth(sw(2))
    lg.circle("line", 0, 0, p.radius + sw(7), 40)
    if p.type == "super" then
      local f = F("j800", max(9, sw(20)))
      lg.setFont(f)
      setc(def.color)
      local text = "★" .. (10 * starRowSize)
      lg.print(text, floor(-f:getWidth(text) / 2 + 0.5), floor(-f:getHeight() / 2 + 1.5))
    else
      D.drawEmoji(images[def.icon], 0, 0, max(12, sw(28)))
    end
    local lf = F("j800", 8)
    local lw = textWidth(lf, def.label, 0.6) + sw(16) + 4
    local top = p.radius + sw(20)
    local lh = 13
    lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.92)
    lg.rectangle("fill", -lw / 2, top, lw, lh)
    setc(def.color)
    lg.setLineWidth(1)
    lg.rectangle("line", floor(-lw / 2) + 0.5, floor(top) + 0.5, floor(lw), lh)
    printTracked(lf, def.label, 0, top + (lh - lf:getHeight()) / 2 + 0.5, 0.6, "center")
    lg.pop()
  end
end

function D.drawProjectiles()
  lg.setBlendMode("alpha", "premultiplied")
  local margin = sw(30)
  for _, p in ipairs(projectiles) do
    if p.x > -margin and p.x < W + margin and p.y > -margin and p.y < H + margin then
      local outer = p.radius + sw(2)
      local sprite = getStarSprite(outer, p.radius * 0.44 / outer, sw(12))
      D.drawTintedPM(sprite, p.x, p.y, p.rotation, p.color)
    end
  end
  lg.setBlendMode("alpha", "alphamultiply")
end

function D.drawEnemies()
  lg.setBlendMode("alpha", "premultiplied")
  lg.setColor(1, 1, 1, 1)
  local bobDistance = sw(2.4)
  for _, e in ipairs(enemies) do
    local m = e.radius + sw(45)
    if e.x > -m and e.x < W + m and e.y > -m and e.y < H + m then
      local s = getEnemySprite(e)
      local tilt = e.mode == "rush" and 0 or sin(e.phase * 0.7) * 0.07
      lg.draw(s.canvas, e.x, e.y + sin(e.phase) * bobDistance, tilt, 1, 1, s.half, s.half)
    end
  end
  lg.setBlendMode("alpha", "alphamultiply")
end

function D.drawBlast()
  if not blast then return end
  local progress = clamp(blast.life / blast.duration, 0, 1)
  local fade = 1 - progress
  local outerWidth = max(sw(4), sw(18) * fade)
  local innerWidth = max(sw(2), sw(6) * fade)
  local innerRadius = max(0, blast.radius - sw(18))
  local glow = sw(28)
  local segs = 96
  for _, pass in ipairs(K.BLAST_GLOW_PASSES) do
    setc(C.goldBright, fade * pass[2])
    lg.setLineWidth(outerWidth + glow * pass[1])
    lg.circle("line", blast.x, blast.y, blast.radius, segs)
  end
  setc(C.goldBright, fade)
  lg.setLineWidth(outerWidth)
  lg.circle("line", blast.x, blast.y, blast.radius, segs)
  if innerRadius > 0 then
    setc(C.goldBright, fade * 0.14)
    lg.setLineWidth(innerWidth + glow * 0.7)
    lg.circle("line", blast.x, blast.y, innerRadius, segs)
    setc(C.cream, fade)
    lg.setLineWidth(innerWidth)
    lg.circle("line", blast.x, blast.y, innerRadius, segs)
  end
end

-- Five streaks drawn as one mesh along the recorded path: each fades in just
-- behind him and out toward the tail, with a soft glow under a bright core.
D.trail = { nx = {}, ny = {}, dist = {} }
function D.drawSpeedTrail()
  local TR = D.trail
  local trail = player.trail
  local n = #trail
  if n < 2 then return end
  local trailNx, trailNy, trailDist = TR.nx, TR.ny, TR.dist
  if not TR.mesh then
    local maxVerts = (K.TRAIL_POINTS - 1) * 6 * 10
    TR.verts = {}
    for v = 1, maxVerts do TR.verts[v] = { 0, 0, 0, 0, 1, 1, 1, 0 } end
    TR.mesh = lg.newMesh(maxVerts, "triangles", "stream")
  end
  local trailVerts = TR.verts
  -- Distance along the path and a smoothed sideways direction at each point.
  trailDist[1] = 0
  for k = 1, n do
    local a, b = trail[max(1, k - 1)], trail[min(n, k + 1)]
    local tx, ty = b.x - a.x, b.y - a.y
    local len = mag(tx, ty)
    if len > 0.001 then
      trailNx[k], trailNy[k] = -ty / len, tx / len
    else
      trailNx[k], trailNy[k] = trailNx[k - 1] or 0, trailNy[k - 1] or 1
    end
    if k > 1 then trailDist[k] = trailDist[k - 1] + mag(trail[k].x - trail[k - 1].x, trail[k].y - trail[k - 1].y) end
  end
  local total = max(trailDist[n], 1)
  local fadeIn = sw(18)
  local r, g, b = C.speed[1], C.speed[2], C.speed[3]
  local count = 0
  local function vertex(x, y, a)
    count = count + 1
    local v = trailVerts[count]
    v[1], v[2], v[5], v[6], v[7], v[8] = x, y, r, g, b, a
  end
  for layer = 1, 2 do
    for i = -2, 2 do
      local off = i * sw(9)
      local core = sw(i == 0 and 4 or 2)
      local half = (layer == 1 and core + sw(8) or core) / 2
      local strength = (0.58 - abs(i) * 0.08) * (layer == 1 and 0.25 or 1)
      for k = 1, n - 1 do
        local x1, y1, x2, y2, a1, a2
        for e = 0, 1 do
          local q = k + e
          local d = trailDist[q]
          local alpha = strength * min(1, d / fadeIn) * clamp((total - d) / (total * 0.45), 0, 1)
            * (1 - trail[q].age / K.TRAIL_LIFE)
          local cx, cy = trail[q].x + trailNx[q] * off, trail[q].y + trailNy[q] * off
          if e == 0 then x1, y1, a1 = cx, cy, max(0, alpha) else x2, y2, a2 = cx, cy, max(0, alpha) end
        end
        local n1x, n1y, n2x, n2y = trailNx[k] * half, trailNy[k] * half, trailNx[k + 1] * half, trailNy[k + 1] * half
        vertex(x1 + n1x, y1 + n1y, a1); vertex(x1 - n1x, y1 - n1y, a1); vertex(x2 + n2x, y2 + n2y, a2)
        vertex(x1 - n1x, y1 - n1y, a1); vertex(x2 - n2x, y2 - n2y, a2); vertex(x2 + n2x, y2 + n2y, a2)
      end
    end
  end
  TR.mesh:setVertices(trailVerts, 1, count)
  TR.mesh:setDrawRange(1, count)
  lg.setColor(1, 1, 1, 1)
  lg.draw(TR.mesh)
end

function D.drawPlayer(time)
  local tilt = clamp(player.vx / max(1, player.speed), -1, 1) * 0.055
  local bob = player.moving and sin(player.bob) * sw(2.6) or sin(player.bob * 0.42) * sw(1.1)
  local blastReady = mastery >= 0.999 and gameState ~= "ready" and gameState ~= "gameover"
  local readyPulse = blastReady and (1 + sin(time * 7.2) * 0.055) or 1
  local vo = sw(8)

  D.drawSpeedTrail()

  lg.push()
  lg.translate(player.x, player.y + bob)
  lg.rotate(tilt)
  lg.scale(readyPulse, readyPulse)

  lg.setColor(1, 1, 1, 1)
  D.drawCentered(blastReady and sprites.auraReady or sprites.auraNormal, 0, -vo)

  if blastReady then
    lg.setColor(1, 1, 1, 0.62 + (sin(time * 9) + 1) * 0.16)
    D.drawCentered(sprites.readyRing, 0, -vo)
  end

  local blink = player.invulnerable > 0 and floor(player.invulnerable * 14) % 2 == 0
  lg.setColor(1, 1, 1, blink and 0.33 or 1)
  local scale = player.drawHeight / 512
  lg.draw(images.player, playerQuad, -player.drawWidth / 2, -player.drawHeight * 0.55, 0, scale, scale)

  if shieldTime > 0 and shieldHits > 0 then
    local radius = player.drawHeight * 0.54
    local fade = 1
    if shieldTime < 3 then fade = clamp(shieldTime / 3, 0, 1) * (0.35 + (sin(time * 18) + 1) * 0.325) end
    lg.setColor(1, 1, 1, (0.76 + (sin(time * 8) + 1) * 0.1) * fade)
    D.drawCentered(sprites.shieldRing, 0, -vo)
    lg.setColor(1, 1, 1, 0.12 * fade)
    D.drawCentered(sprites.shieldDisc, 0, -vo)
    for i = 0, shieldHits - 1 do
      local a = -pi * 0.74 + i * 0.2
      setc(C.shield, fade * 0.35)
      lg.circle("fill", cos(a) * radius, -vo + sin(a) * radius, sw(5.5) + 2, 16)
      setc(C.shield, fade)
      lg.circle("fill", cos(a) * radius, -vo + sin(a) * radius, sw(5.5), 16)
    end
  end

  if superStarsTime > 0 then
    local orbit = player.drawHeight * 0.61
    local alpha = 0.5 + (sin(time * 9) + 1) * 0.14
    lg.setBlendMode("alpha", "premultiplied")
    local sprite = getStarSprite(sw(5.5), 2.4 / 5.5, sw(12))
    for i = 0, 9 do
      local a = time * 1.8 + (i / 10) * K.TAU
      D.drawTintedPM(sprite, cos(a) * orbit, -vo + sin(a) * orbit, 0, C.super, alpha)
    end
    lg.setBlendMode("alpha", "alphamultiply")
  end

  if magnetTime > 0 then
    local alpha = 0.82 + (sin(time * 7) + 1) * 0.08
    setc(C.magnet, alpha * 0.4)
    lg.draw(softDot.img, -player.drawWidth * 0.86, -player.drawHeight * 0.43, 0, sw(18) / 64, sw(18) / 64, 64, 64)
    D.drawEmoji(images.magnet, -player.drawWidth * 0.86, -player.drawHeight * 0.43, max(11, sw(25)), alpha)
  end
  lg.pop()

  if gameState == "running" and superStarsTime <= 0 and player.stationaryTime > 0.5 and #enemies > 0 then
    local alpha = 0.72 + (sin(time * 7) + 1) * 0.12
    local f = F("j800", 10)
    local text = "KEEP MOVING"
    local w = textWidth(f, text, 0.8) + 14
    local h = 16
    local y = player.y + player.drawHeight * 0.55
    lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.9 * alpha)
    lg.rectangle("fill", player.x - w / 2, y - h / 2, w, h)
    setc(C.gold, alpha)
    lg.setLineWidth(1)
    lg.rectangle("line", floor(player.x - w / 2) + 0.5, floor(y - h / 2) + 0.5, floor(w), h)
    setc(C.goldLight, alpha)
    printTracked(f, text, player.x, y - f:getHeight() / 2, 0.8, "center")
  end
end

function D.drawParticles()
  for _, p in ipairs(particles) do
    local a = clamp(p.life / p.maxLife, 0, 1)
    setc(p.color, a)
    if p.star then
      local outer = p.size + sw(1.5)
      D.drawStar(p.x, p.y, outer, outer * 0.36, 0)
    else
      lg.circle("fill", p.x, p.y, p.size, 10)
    end
  end
end

-- Outlined texts are rendered once so they can fade as a whole (drawing the
-- outline and fill separately at partial alpha looks muddy). They share one
-- large canvas instead of a new canvas each, which is slow to create on the
-- handheld's GPU; a fresh sheet is started when one fills up.
local textSheet = { w = 1024, h = 512, sprites = {} }
function D.getTextSprite(text, size, color)
  local key = text .. "\0" .. size .. "\0" .. color[1] .. color[2] .. color[3]
  local sprite = textSheet.sprites[key]
  if sprite then return sprite end
  local font = F("j800", size)
  local w, h = font:getWidth(text) + 4, font:getHeight() + 4
  local S = textSheet
  if S.canvas and S.x + w > S.w then S.x, S.y, S.rowH = 0, S.y + S.rowH, 0 end
  if not S.canvas or S.y + h > S.h then
    S.canvas = lg.newCanvas(S.w, S.h)
    S.x, S.y, S.rowH = 0, 0, 0
    S.sprites = {}
    lg.push("all")
    lg.setCanvas(S.canvas)
    lg.clear(0, 0, 0, 0)
    lg.pop()
  end
  lg.push("all")
  lg.setCanvas(S.canvas)
  lg.origin()
  lg.setScissor()
  lg.setBlendMode("alpha", "alphamultiply")
  lg.setFont(font)
  lg.setColor(C.ink[1], C.ink[2], C.ink[3], 1)
  for ox = -1, 1 do
    for oy = -1, 1 do
      if ox ~= 0 or oy ~= 0 then lg.print(text, S.x + 2 + ox, S.y + 2 + oy) end
    end
  end
  setc(color)
  lg.print(text, S.x + 2, S.y + 2)
  lg.pop()
  sprite = { canvas = S.canvas, quad = lg.newQuad(S.x, S.y, w, h, S.w, S.h), w = w, h = h }
  S.x, S.rowH = S.x + w + 2, max(S.rowH, h + 2)
  S.sprites[key] = sprite
  return sprite
end

function D.drawFloatingTexts()
  lg.setBlendMode("alpha", "premultiplied")
  for _, t in ipairs(floatingTexts) do
    local a = clamp(t.life / t.maxLife, 0, 1)
    local sprite = t.sprite
    lg.setColor(a, a, a, a)
    local x = clamp(t.x - sprite.w / 2, 2, W - 2 - sprite.w)
    lg.draw(sprite.canvas, sprite.quad, floor(x + 0.5), t.y - sprite.h / 2)
  end
  lg.setBlendMode("alpha", "alphamultiply")
end

-- Power-up status icons (drawn shapes, like the web game).
function D.drawStatusIcon(ptype, x, y, size, color)
  local r = size / 2
  lg.push()
  lg.translate(x, y)
  setc(color)
  if ptype == "shield" then
    local pts = { 0, -r * 0.92, r * 0.72, -r * 0.58, r * 0.58, r * 0.2, r * 0.3, r * 0.68, 0, r * 0.94,
      -r * 0.3, r * 0.68, -r * 0.58, r * 0.2, -r * 0.72, -r * 0.58 }
    setc(color, 0.22)
    lg.polygon("fill", pts)
    setc(color)
    lg.setLineWidth(max(1.2, size * 0.12))
    lg.setLineJoin("bevel")
    lg.polygon("line", pts)
  elseif ptype == "speed" then
    local pts = { r * 0.08, -r, -r * 0.68, r * 0.12, -r * 0.12, r * 0.06, -r * 0.28, r, r * 0.72, -r * 0.22, r * 0.13, -r * 0.12 }
    local tris = love.math.triangulate(pts)
    for _, t in ipairs(tris) do lg.polygon("fill", t) end
  elseif ptype == "super" then
    D.drawStar(0, 0, r, r * 0.44, 0)
  else
    lg.setLineWidth(max(1.7, size * 0.19))
    lg.line(-r * 0.72, -r * 0.52, -r * 0.72, r * 0.08)
    lg.arc("line", "open", 0, r * 0.08, r * 0.72, pi, 0, 16)
    lg.line(r * 0.72, r * 0.08, r * 0.72, -r * 0.52)
    lg.setLineWidth(max(2.2, size * 0.25))
    lg.line(-r * 0.72, -r * 0.68, -r * 0.72, -r * 0.42)
    lg.line(r * 0.72, -r * 0.68, r * 0.72, -r * 0.42)
  end
  lg.pop()
end

function D.drawPowerupStatus()
  local items = {}
  if shieldTime > 0 and shieldHits > 0 then
    items[#items + 1] = { "shield", string.format("SHIELD %d · %.1fs", shieldHits, floor(shieldTime * 10 + 0.5) / 10), C.shield }
  end
  if speedTime > 0 then items[#items + 1] = { "speed", string.format("SUPER SPEED · %.1fs", floor(speedTime * 10 + 0.5) / 10), C.speed } end
  if superStarsTime > 0 then items[#items + 1] = { "super", string.format("SUPER STARS · %.1fs", floor(superStarsTime * 10 + 0.5) / 10), C.super } end
  if magnetTime > 0 then items[#items + 1] = { "magnet", string.format("MAGNET · %.1fs", floor(magnetTime * 10 + 0.5) / 10), C.magnet } end
  if #items == 0 then return end
  local f = F("j800", 10)
  lg.setFont(f)
  local iconSize, iconGap, pad, h, gap = 12, 5, 7, 20, 4
  local y = bounds.bottom - 14 - h
  for i = #items, 1, -1 do
    local it = items[i]
    local tw = f:getWidth(it[2])
    local w = pad * 2 + iconSize + iconGap + tw
    local x = bounds.right - 8 - w
    lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.9)
    lg.rectangle("fill", x, y, w, h)
    setc(it[3])
    lg.setLineWidth(1.5)
    lg.rectangle("line", x + 0.75, y + 0.75, w - 1.5, h - 1.5)
    D.drawStatusIcon(it[1], x + pad + iconSize / 2, y + h / 2, iconSize, it[3])
    setc(it[3])
    lg.print(it[2], floor(x + pad + iconSize + iconGap), floor(y + (h - f:getHeight()) / 2 + 0.5))
    y = y - h - gap
  end
end

----------------------------------------------------------------------------
-- HUD
----------------------------------------------------------------------------
function D.fitFont(kind, size, text, maxWidth)
  local f = F(kind, size)
  while f:getWidth(text) > maxWidth and size > 8 do
    size = size - 1
    f = F(kind, size)
  end
  return f
end

function D.drawRatingStars(x, y, lives, maxLives, size, danger)
  local spacing = size * 2.15
  for i = 1, maxLives do
    local cx = x + (i - 1) * spacing + size
    if i <= lives then
      setc(danger and C.red or C.goldBright)
      D.drawStar(cx, y, size, size * 0.45, 0)
    else
      setc(C.goldBright, 0.9)
      lg.setLineWidth(1)
      local pts = {}
      for k = 0, 9 do
        local r = (k % 2 == 0) and size or size * 0.45
        local a = -pi / 2 + k * pi / 5
        pts[#pts + 1] = cx + cos(a) * r
        pts[#pts + 1] = y + sin(a) * r
      end
      lg.polygon("line", pts)
    end
  end
end

function D.drawHud(time)
  local x, y, w, h = HUD.x, HUD.y, HUD.w, HUD.h
  lg.setColor(14 / 255, 9 / 255, 6 / 255, 0.94)
  lg.rectangle("fill", x, y, w, h)
  setc(C.gold)
  lg.setLineWidth(2)
  lg.rectangle("line", x + 1, y + 1, w - 2, h - 2)

  local labelFont = F("j800", 9)
  local cells = {
    { "SCORE", 80 }, { "BEST", 80 }, { "RATING", 96 }, { "STREAK", 64 }, { "BEST STREAK", 92 }, { "BLOCKBUSTER BLAST", 0 },
  }
  local roundedScore = floor(score)
  local rec = bestFor()
  local values = {
    formatScore(roundedScore),
    formatScore(max(rec.score, roundedScore)),
    nil,
    tostring(popcornChain),
    tostring(max(rec.streak, longestStreak)),
  }
  local cx = x + 2
  for i, cell in ipairs(cells) do
    local cw = cell[2] > 0 and cell[2] or (x + w - 2 - cx)
    if i > 1 then
      lg.setColor(229 / 255, 164 / 255, 8 / 255, 0.35)
      lg.setLineWidth(1)
      lg.line(floor(cx) + 0.5, y + 6, floor(cx) + 0.5, y + h - 6)
    end
    setc(C.goldLight, 0.85)
    printTracked(labelFont, cell[1], cx + 9, y + 7, 0.9)
    if i == 3 then
      local ml = maximumLives()
      D.drawRatingStars(cx + 9, y + 30, player.lives, ml, 6.2, ml > 1 and player.lives == 1)
    elseif i <= 5 then
      local f = D.fitFont("j800", 17, values[i], cw - 16)
      lg.setFont(f)
      setc(C.goldBright)
      lg.print(values[i], floor(cx + 9), floor(y + 30 - f:getHeight() / 2 + 0.5))
    else
      -- Blast meter
      local mp = floor(min(1, mastery) * 100 + 0.5)
      local rp = dualBlastUnlocked and floor(clamp(mastery - 1, 0, 1) * 100 + 0.5) or 0
      local pctText = dualBlastUnlocked and (mp .. "% + " .. rp .. "%") or (mp .. "%")
      local pf = F("j800", 10)
      lg.setFont(pf)
      setc(C.goldBright)
      lg.print(pctText, floor(cx + cw - 9 - pf:getWidth(pctText)), y + 5)
      local ready = mastery >= 0.999 and gameState ~= "ready" and gameState ~= "gameover"
      local tracks = dualBlastUnlocked and 2 or 1
      local tw = cw - 18
      local th = dualBlastUnlocked and 6 or 9
      local ty = y + (dualBlastUnlocked and 22 or 26)
      for t = 1, tracks do
        local fill = t == 1 and mp / 100 or rp / 100
        local trackReady = t == 1 and ready or (rp >= 100)
        lg.setColor(5 / 255, 3 / 255, 2 / 255, 1)
        lg.rectangle("fill", cx + 9, ty, tw, th)
        if fill > 0 then
          local bright = trackReady and (0.85 + (sin(time * 6) + 1) * 0.075) or 1
          lg.setColor(C.gold[1] * bright, C.gold[2] * bright, C.gold[3] * bright, 1)
          lg.rectangle("fill", cx + 9, ty, tw * fill, th)
          setc(C.goldBright, trackReady and (0.6 + sin(time * 6) * 0.3) or 0.55)
          lg.rectangle("fill", cx + 9, ty, tw * fill, max(1, th * 0.35))
        end
        setc(trackReady and C.goldBright or C.goldDark)
        lg.setLineWidth(1)
        lg.rectangle("line", floor(cx + 9) + 0.5, floor(ty) + 0.5, floor(tw), th)
        ty = ty + th + 3
      end
    end
    cx = cx + cw
  end
end

function D.drawBannerAndCombo(dt)
  -- Mission banner (the DOM banner in the web game).
  local message, danger = "", false
  local pickup = pickups[1]
  if bannerTime > 0 then
    message, danger = bannerMessage, bannerDanger
  elseif gameState == "running" and pickup and pickup.ttl < 3 then
    message = string.format("POPCORN EXPIRES IN %.1f SECONDS", max(0, floor(pickup.ttl * 10 + 0.5)) / 10)
    danger = true
  elseif gameState == "running" and superStarsTime <= 0 and player.stationaryTime > 0.48 and #enemies > 0 then
    message = "KEEP MOVING TO CONTINUE SHOOTING"
  end
  if gameState ~= "running" and gameState ~= "paused" and gameState ~= "resuming" then message = "" end
  if message ~= "" then
    bannerVisible.text, bannerVisible.danger = message, danger
    bannerVisible.alpha = min(1, bannerVisible.alpha + dt / 0.18)
  else
    bannerVisible.alpha = max(0, bannerVisible.alpha - dt / 0.18)
  end
  if bannerVisible.alpha > 0 and bannerVisible.text ~= "" then
    local a = bannerVisible.alpha
    local f = F("j800", 10)
    local tw = textWidth(f, bannerVisible.text, 1.2)
    local bw, bh = tw + 26, 20
    local bx = floor(W / 2 - bw / 2)
    local by = floor(bounds.top + 4)
    lg.push()
    lg.translate(0, -(1 - a) * 7)
    if bannerVisible.danger then lg.setColor(82 / 255, 20 / 255, 12 / 255, 0.92 * a) else lg.setColor(18 / 255, 10 / 255, 6 / 255, 0.82 * a) end
    lg.rectangle("fill", bx, by, bw, bh)
    if bannerVisible.danger then setc(C.red, a) else setc(C.gold, 0.65 * a) end
    lg.setLineWidth(1)
    lg.rectangle("line", bx + 0.5, by + 0.5, bw - 1, bh - 1)
    if bannerVisible.danger then setc(hex("#ffd8cb"), a) else setc(C.goldLight, a) end
    printTracked(f, bannerVisible.text, W / 2, by + (bh - f:getHeight()) / 2 + 0.5, 1.2, "center")
    lg.pop()
  end

  -- Combo callout (1.2 s animation).
  if combo.t < 1.2 then
    local p = combo.t / 1.2
    local alpha, dy, sc
    if p < 0.18 then
      local u = p / 0.18
      alpha, dy, sc = u, -18 * (1 - u), 0.9 + 0.1 * u
    elseif p < 0.72 then
      alpha, dy, sc = 1, 0, 1
    else
      local u = (p - 0.72) / 0.28
      alpha, dy, sc = 1 - u, -7 * u, 1 - 0.04 * u
    end
    local f = F("alfa", 13)
    local tw = textWidth(f, combo.text, 0.7)
    local bw, bh = tw + 28, 26
    lg.push()
    lg.translate(W / 2, bounds.top + 44 + dy)
    lg.scale(sc, sc)
    setc(C.goldDark, alpha)
    lg.rectangle("fill", -bw / 2 + 4, -bh / 2 + 4, bw, bh)
    setc(C.goldBright, alpha)
    lg.rectangle("fill", -bw / 2, -bh / 2, bw, bh)
    setc(C.ink, alpha)
    lg.setLineWidth(2)
    lg.rectangle("line", -bw / 2 + 1, -bh / 2 + 1, bw - 2, bh - 2)
    printTracked(f, combo.text, 0, -f:getHeight() / 2, 0.7, "center")
    lg.pop()
  end
end

----------------------------------------------------------------------------
-- Menu drawing
----------------------------------------------------------------------------
function D.drawButton(btn, selected)
  local x, y, w, h = btn.x, btn.y, btn.w, btn.h
  local f = F("j800", 13)
  if textWidth(f, btn.label, 1) > w - 16 then f = F("j800", 12) end
  local fill, border, textColor
  if btn.kind == "primary" then
    fill, border, textColor = C.goldBright, C.goldBright, C.ink
  elseif btn.kind == "danger" then
    fill, border, textColor = hex("#1a0d08"), hex("#ff806b"), hex("#ff9f8c")
  else
    fill, border, textColor = hex("#1a110b"), C.gold, C.goldLight
  end
  if selected then
    lg.setColor(C.paperLight[1], C.paperLight[2], C.paperLight[3], 0.95)
    lg.setLineWidth(2)
    lg.rectangle("line", x - 4, y - 4, w + 8, h + 8)
  end
  setc(C.goldDark)
  lg.rectangle("fill", x + 4, y + 4, w, h)
  setc(fill)
  lg.rectangle("fill", x, y, w, h)
  setc(border)
  lg.setLineWidth(2)
  lg.rectangle("line", x + 1, y + 1, w - 2, h - 2)
  setc(textColor)
  local tw = textWidth(f, btn.label, 1)
  local tx = x + w / 2
  local ty = y + (h - f:getHeight()) / 2
  printTracked(f, btn.label, tx, ty, 1, "center")
  if selected then
    lg.setLineWidth(2)
    setc(btn.kind == "primary" and C.ink or C.paperLight)
    lg.line(tx - tw / 2, ty + f:getHeight() + 1, tx + tw / 2, ty + f:getHeight() + 1)
  end
end

function D.drawButtons()
  for i, btn in ipairs(menu.buttons) do D.drawButton(btn, i == menu.selected) end
end

function D.dim(alpha)
  lg.setColor(10 / 255, 6 / 255, 4 / 255, alpha)
  lg.rectangle("fill", 0, 0, W, H)
end

function D.drawOverlayRays(time, cx, cy, alpha)
  lg.setColor(229 / 255, 164 / 255, 8 / 255, alpha)
  lg.draw(raysMesh, cx, cy, time * 0.05)
end

function D.drawPanelTitle(text, y, size, color)
  local f = F("alfa", size)
  setc(C.goldDark)
  printTracked(f, text, W / 2 + 3, y + 3, 1, "center")
  setc(color or C.goldBright)
  printTracked(f, text, W / 2, y, 1, "center")
end

function D.drawTitleScreen(time)
  -- Dark frame with a cream poster, like the web start screen.
  lg.setColor(C.ink[1], C.ink[2], C.ink[3], 0.96)
  lg.rectangle("fill", 0, 0, W, H)
  local px, py, pw, ph = 12, 12, 616, 456
  setc(C.paperLight)
  lg.rectangle("fill", px, py, pw, ph)
  lg.setColor(0.55, 0.42, 0.25, 0.07)
  for yy = py + 3, py + ph, 4 do lg.rectangle("fill", px, yy, pw, 1) end
  -- Left column: Movie Master on spinning rays.
  local colW = 150
  lg.setScissor(px, py, colW, ph)
  setc(hex("#f0c55a"))
  lg.rectangle("fill", px, py, colW, ph)
  lg.setColor(1, 0.94, 0.77, 0.75)
  lg.draw(raysMesh, px + colW / 2, py + ph * 0.45, time * 0.25, 0.9, 0.9)
  local imgH = ph - 28
  local scale = imgH / 512
  lg.setColor(0, 0, 0, 0.18)
  lg.draw(images.player, playerQuad, px + colW / 2 - 88 * scale + 4, py + 20, 0, scale, scale)
  lg.setColor(1, 1, 1, 1)
  lg.draw(images.player, playerQuad, px + colW / 2 - 88 * scale, py + 16, 0, scale, scale)
  lg.setScissor()
  setc(C.goldDark, 0.6)
  lg.setLineWidth(2)
  lg.line(px + colW, py, px + colW, py + ph)
  setc(C.gold)
  lg.setLineWidth(4)
  lg.rectangle("line", px - 2, py - 2, pw + 4, ph + 4)

  local tx = px + colW + 24
  local right = 612
  local brown = hex("#8a4a0b")
  local deep = hex("#3d230f")
  local fTitle = F("alfa", 38)
  local fVs = F("alfa", 24)
  setc(brown)
  lg.setFont(fTitle)
  lg.print("MOVIE MASTER", tx, 30)
  lg.setFont(fVs)
  lg.print("vs", tx + fTitle:getWidth("MOVIE MASTER") + 10, 42)
  lg.setFont(fTitle)
  lg.print("GARBAGE", tx, 72)

  setc(deep)
  local tagW = printTracked(F("j800", 14), "COLLECT POPCORN. AVOID GARBAGE.", tx, 128, 0.6)
  D.drawEmoji(images.garbage, tx + tagW + 14, 128 + 10, 16)
  setc(C.gold)
  lg.rectangle("fill", tx, 154, right - tx, 2)

  -- Controls boxes
  local boxes = { { "MOVE", "D-PAD / STICK" }, { "SHOOT", "KEEP MOVING" }, { "BLAST", "A B X Y AT 100%" } }
  local bx = tx
  local bwid = (right - tx - 16) / 3
  for _, b in ipairs(boxes) do
    lg.setColor(1, 1, 1, 0.35)
    lg.rectangle("fill", bx, 164, bwid, 52)
    setc(hex("#c9a46a"))
    lg.setLineWidth(1)
    lg.rectangle("line", bx + 0.5, 164.5, bwid - 1, 51)
    setc(brown)
    printTracked(F("j800", 12), b[1], bx + bwid / 2, 170, 1, "center")
    setc(deep)
    printTracked(F("j700", 13), b[2], bx + bwid / 2, 190, 0.3, "center")
    bx = bx + bwid + 8
  end

  D.drawButtons()

  -- Best score and best streak, each in its own column so long numbers never collide.
  local rec = bestFor()
  local colX = { tx, tx + (right - tx) / 2 + 6 }
  local labels = { (hardcoreMode and "HARDCORE " or "") .. "BEST SCORE", (hardcoreMode and "HARDCORE " or "") .. "BEST STREAK" }
  local nums = { formatScore(rec.score), tostring(rec.streak) }
  for k = 1, 2 do
    setc(brown)
    printTracked(F("j800", 11), labels[k], colX[k], 374, 1)
    setc(C.goldDark)
    lg.setFont(F("j800", 22))
    lg.print(nums[k], floor(colX[k]), 387)
  end
  if hardcoreMode then
    setc(C.red)
    printTracked(F("j800", 11), "ONE HIT OR ONE MISSED POPCORN ENDS THE GAME.", tx, 423, 0.4)
  end
  setc(deep, 0.65)
  printTracked(F("j700", 11), "START: PLAY   ·   SELECT + START: EXIT", tx, 447, 0.8)
end

function D.wrapText(font, text, width)
  local _, lines = font:getWrap(text, width)
  return lines
end

function D.drawInfo()
  D.dim(0.94)
  local px, py, pw, ph = 14, 10, 612, 460
  lg.setColor(14 / 255, 9 / 255, 6 / 255, 0.98)
  lg.rectangle("fill", px, py, pw, ph)
  setc(C.gold)
  lg.setLineWidth(2)
  lg.rectangle("line", px + 1, py + 1, pw - 2, ph - 2)
  D.drawPanelTitle("HOW TO PLAY", 22, 28)
  local page = K.INFO_PAGES[menu.infoPage]
  setc(C.goldLight, 0.85)
  printTracked(F("j800", 13), string.format("PAGE %d OF %d  ·  %s", menu.infoPage, K.INFO_PAGE_COUNT, page.title),
    W / 2, 64, 1.4, "center")
  setc(C.gold, 0.4)
  lg.setLineWidth(1)
  lg.line(40, 92.5, 600, 92.5)

  local head, body = F("j800", 15), F("j400", 16)
  local y = 106
  for _, item in ipairs(page.items) do
    local x, width = 44, 552
    if item.icon then
      D.drawStatusIcon(item.icon, 58, y + 11, 22, C[item.icon])
      x, width = 82, 514
    end
    if item.key then
      -- Controls table row
      setc(C.goldBright)
      printTracked(head, item.key, x, y, 0.8)
      setc(C.paperLight)
      lg.setFont(body)
      lg.print(item.text, 230, y - 1)
      y = y + 34
    else
      setc(item.icon and C[item.icon] or C.goldBright)
      printTracked(head, item.head, x, y, 0.8)
      y = y + head:getHeight() + 2
      setc(C.paperLight)
      lg.setFont(body)
      for _, line in ipairs(D.wrapText(body, item.text, width)) do
        lg.print(line, x, y)
        y = y + body:getHeight() - 1
      end
      y = y + 12
    end
  end

  -- Page arrows either side of the button, and page dots above it.
  local n, cur = K.INFO_PAGE_COUNT, menu.infoPage
  for k = 1, n do
    setc(C.goldBright, k == cur and 1 or 0.3)
    lg.circle("fill", W / 2 + (k - (n + 1) / 2) * 16, 406, 4, 16)
  end
  local ay = 439
  setc(C.goldBright, cur > 1 and 1 or 0.25)
  lg.polygon("fill", 192, ay - 9, 192, ay + 9, 180, ay)
  setc(C.goldBright, cur < n and 1 or 0.25)
  lg.polygon("fill", 448, ay - 9, 448, ay + 9, 460, ay)
  setc(C.goldLight, 0.7)
  printTracked(F("j700", 11), "D-PAD: TURN PAGE", 44, ay - 7, 0.8)
  printTracked(F("j700", 11), "SELECT: CLOSE", 596, ay - 7, 0.8, "right")
  D.drawButtons()
end

function D.drawPaused(time, title, kicker, sub)
  D.dim(0.88)
  D.drawOverlayRays(time, W / 2, H * 0.62, 0.035)
  setc(C.goldLight, 0.9)
  printTracked(F("j800", 13), kicker, W / 2, 130, 1.6, "center")
  D.drawPanelTitle(title, 152, 48)
  setc(C.goldLight, 0.9)
  printTracked(F("j800", 13), sub, W / 2, 222, 1.2, "center")
  D.drawButtons()
end

function D.drawResumeCountdown()
  local progress = clamp((clock - resumeStartedAt) / K.RESUME_COUNTDOWN_DURATION, 0, 1)
  local e = (clock - resumeStartedAt)
  local step = e < 0.55 and "3" or e < 1.1 and "2" or e < 1.65 and "1" or "GO"
  local cx, cy, r = W / 2, H / 2 + 20, 58
  lg.setColor(18 / 255, 12 / 255, 8 / 255, 0.78)
  lg.circle("fill", cx, cy, r + 5, 64)
  setc(C.goldBright)
  lg.circle("fill", cx, cy, r, 64)
  lg.setColor(1, 211 / 255, 96 / 255, 0.18)
  if progress > 0 then
    lg.setColor(0.35, 0.25, 0.1, 1)
    lg.arc("fill", cx, cy, r, -pi / 2, -pi / 2 + K.TAU * progress, 64)
  end
  setc(C.goldLight)
  lg.setLineWidth(3)
  lg.circle("line", cx, cy, r, 64)
  lg.setColor(12 / 255, 7 / 255, 4 / 255, 0.94)
  lg.circle("fill", cx, cy, r - 8, 64)
  lg.setColor(1, 231 / 255, 162 / 255, 0.25)
  lg.setLineWidth(1)
  lg.line(cx - r + 8, cy, cx + r - 8, cy)
  lg.line(cx, cy - r + 8, cx, cy + r - 8)
  local f = F("alfa", step == "GO" and 34 or 44)
  lg.setFont(f)
  setc(C.goldBright)
  lg.print(step, floor(cx - f:getWidth(step) / 2), floor(cy - f:getHeight() / 2))
end

function D.drawGameOver(time)
  D.dim(0.9)
  local px, py, pw, ph = 20, 20, 600, 440
  lg.setColor(14 / 255, 9 / 255, 6 / 255, 0.97)
  lg.rectangle("fill", px, py, pw, ph)
  setc(C.gold)
  lg.setLineWidth(3)
  lg.rectangle("line", px + 1.5, py + 1.5, pw - 3, ph - 3)
  setc(C.goldLight, 0.9)
  printTracked(F("j800", 13), "THE END", W / 2, 40, 1.8, "center")
  local titleFont = D.fitFont("alfa", 34, gameoverTitle, pw - 60)
  setc(C.goldDark)
  printTracked(titleFont, gameoverTitle, W / 2 + 3, 66, 1, "center")
  setc(C.goldBright)
  printTracked(titleFont, gameoverTitle, W / 2, 63, 1, "center")
  setc(C.gold, 0.4)
  lg.setLineWidth(1)
  lg.line(40, 124.5, 600, 124.5)
  lg.line(W / 2 + 0.5, 124, W / 2 + 0.5, 216)
  lg.line(40, 216.5, 600, 216.5)
  local stats = { { "FINAL SCORE", formatScore(finalScore) }, { "LONGEST STREAK", tostring(longestStreak) } }
  for i, s in ipairs(stats) do
    local cx = i == 1 and W / 4 + 10 or W * 3 / 4 - 10
    setc(C.goldLight, 0.85)
    printTracked(F("j800", 13), s[1], cx, 134, 1.4, "center")
    local nf = D.fitFont("alfa", 46, s[2], 260)
    setc(C.goldBright)
    printTracked(nf, s[2], cx, 156, 1, "center")
  end
  local rec = bestFor()
  setc(C.goldLight, 0.8)
  printTracked(F("j800", 13), string.format("%s BEST: %s   ·   BEST STREAK: %d",
    hardcoreMode and "HARDCORE" or "NORMAL", formatScore(rec.score), rec.streak), W / 2, 230, 1, "center")
  if runStats then
    setc(C.goldLight, 0.65)
    printTracked(F("j700", 13), string.format("TIME %s   ·   GARBAGE DESTROYED %s   ·   POPCORN %s",
      formatDuration(elapsed), formatScore(runStats.garbageDestroyed), formatScore(popcornCollected)), W / 2, 254, 0.6, "center")
  end
  D.drawButtons()
  if hardcoreMode then
    setc(C.red)
    printTracked(F("j800", 12), "HARDCORE: ONE HIT OR ONE MISSED POPCORN ENDS THE GAME.", W / 2, 418, 0.6, "center")
  end
end

function D.drawStats()
  D.dim(0.95)
  local px, py, pw, ph = 20, 10, 600, 460
  lg.setColor(14 / 255, 9 / 255, 6 / 255, 0.98)
  lg.rectangle("fill", px, py, pw, ph)
  setc(C.gold)
  lg.setLineWidth(2)
  lg.rectangle("line", px + 1, py + 1, pw - 2, ph - 2)
  D.drawPanelTitle("GAME STATS", 22, 28)
  local rs = runStats or createRunStats()
  local accuracy = rs.starsFired > 0 and floor((rs.starsHit / rs.starsFired) * 1000 + 0.5) / 10 or 0
  local rows = {
    { "MODE", rs.mode }, { "GAME TIME", formatDuration(elapsed) }, { "FINAL SCORE", formatScore(finalScore) },
    { "LONGEST STREAK", formatScore(longestStreak) }, { "POPCORN COLLECTED", formatScore(popcornCollected) },
    { "POPCORN MISSED", formatScore(rs.popcornMissed) }, { "GARBAGE DESTROYED", formatScore(rs.garbageDestroyed) },
    { "DESTROYED BY STARS", formatScore(rs.destroyedByStars) }, { "DESTROYED BY BLASTS", formatScore(rs.destroyedByBlasts) },
    { "STARS FIRED", formatScore(rs.starsFired) }, { "STARS HIT", formatScore(rs.starsHit) },
    { "STAR ACCURACY", (accuracy % 1 == 0 and string.format("%d", accuracy) or string.format("%.1f", accuracy)) .. "%" },
    { "HITS TAKEN", formatScore(rs.hitsTaken) }, { "SHIELD BLOCKS", formatScore(rs.shieldBlocks) },
    { "BLASTS USED", formatScore(rs.blastsUsed) },
  }
  local function grid(list, y0, columns)
    local cw = (pw - 40) / columns
    for i, r in ipairs(list) do
      local col = (i - 1) % columns
      local row = floor((i - 1) / columns)
      local x = px + 20 + col * cw
      local y = y0 + row * 48
      lg.setColor(1, 231 / 255, 162 / 255, 0.05)
      lg.rectangle("fill", x + 2, y, cw - 4, 42)
      setc(C.gold, 0.45)
      lg.setLineWidth(1)
      lg.rectangle("line", x + 2.5, y + 0.5, cw - 5, 41)
      setc(C.goldLight, 0.8)
      printTracked(F("j800", 11), r[1], x + 10, y + 4, 0.6)
      setc(C.goldBright)
      lg.setFont(F("j800", 17))
      lg.print(r[2], floor(x + 10), y + 17)
    end
  end
  grid(rows, 64, 3)
  setc(C.goldBright)
  printTracked(F("alfa", 16), "POWER-UPS USED", W / 2, 306, 0.8, "center")
  grid({ { "SHIELD", tostring(rs.powerups.shield) }, { "SUPER SPEED", tostring(rs.powerups.speed) },
    { "SUPER STARS", tostring(rs.powerups.super) }, { "MAGNET", tostring(rs.powerups.magnet) } }, 332, 4)
  D.drawButtons()
end

-- Builds every font size and sprite the game uses up front. Creating them the
-- first time they appear (the first Blockbuster Blast, the first hit on each
-- kind of garbage, each star upgrade) caused visible hitches on the handheld.
function D.prewarm()
  local glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 +-%.,:;!?'&/()·—★☆"
  for kind, sizes in pairs(K.FONT_SIZES) do
    for _, size in ipairs(sizes) do F(kind, size):getWidth(glyphs) end
  end
  for _, size in ipairs({ 18, 28 }) do F("j800", max(10, sw(size))):getWidth(glyphs) end
  for kind, def in pairs(K.ENEMY_DEFINITIONS) do
    for _, mode in ipairs({ "chase", "rush" }) do
      for hp = 1, def.hp do
        for _, flash in ipairs({ 0, 1 }) do
          getEnemySprite({ kind = kind, mode = mode, hp = hp, maxHp = def.hp, hitFlash = flash,
            radius = sw(def.radius), color = def.color })
        end
      end
    end
  end
  for power = 0, 10 do
    local radius = sw(min(20, 7 + power * 1.4))
    local outer = radius + sw(2)
    getStarSprite(outer, radius * 0.44 / outer, sw(12))
  end
  getStarSprite(sw(5.5), 2.4 / 5.5, sw(12))
  starMesh(0.36)
  starMesh(0.45)
  for _, def in pairs(K.ENEMY_DEFINITIONS) do D.getTextSprite("+" .. def.score, floor(max(10, sw(18)) + 0.5), C.goldLight) end
end

-- Plays a few silent, invisible frames of a Blockbuster Blast with every
-- power-up active, and starts each sound muted, then resets. The handheld's
-- graphics and audio drivers prepare some work the first time it is used,
-- which otherwise lands on the first real Blast as a hitch. Records and
-- settings are put back afterwards.
function D.rehearse()
  local saved = {}
  for mode, rec in pairs(records) do saved[mode] = { score = rec.score, streak = rec.streak } end
  local wasSound, wasHardcore = soundOn, hardcoreMode
  soundOn, hardcoreMode = false, false
  resetGame()
  gameState = "running"
  player.invulnerable = 99
  speedTime, shieldTime, shieldHits, superStarsTime, magnetTime = 5, 5, 3, 5, 5
  for _, kind in ipairs({ "standard", "fast", "heavy", "standard" }) do
    addEnemy(player.x + sw(rb(-160, 160)), player.y + sw(rb(-120, 120)), kind)
  end
  spawnPopcorn()
  spawnPowerup()
  for frame = 1, 20 do
    moveInput.x, moveInput.y = frame < 10 and 1 or 0.7, frame < 10 and 0 or -0.7
    if frame == 5 then mastery = 1; activateBlast() end
    update(1 / 60)
    if flashTime > 0 then flashTime = max(0, flashTime - 1 / 60) end
    if combo.t < 2 then combo.t = combo.t + 1 / 60 end
    love.draw()
  end
  moveInput.x, moveInput.y = 0, 0
  for _, cue in pairs(cues) do
    for _, src in ipairs(cue.pool) do
      local volume = src:getVolume()
      src:setVolume(0)
      src:play()
      src:stop()
      src:setVolume(volume)
    end
  end
  for mode, rec in pairs(saved) do records[mode].score, records[mode].streak = rec.score, rec.streak end
  soundOn, hardcoreMode = wasSound, wasHardcore
  lg.setCanvas()
  lg.clear(0, 0, 0, 1)
end

----------------------------------------------------------------------------
-- LÖVE callbacks
----------------------------------------------------------------------------
function love.load()
  lg.setDefaultFilter("linear", "linear")
  love.mouse.setVisible(false)
  loadData()

  images.player = lg.newImage("assets/player.png", { mipmaps = true })
  images.player:setFilter("linear", "linear")
  pcall(images.player.setMipmapFilter, images.player, "linear")
  playerQuad = lg.newQuad(0, 0, 176, 512, 256, 512)
  for _, name in ipairs({ "popcorn", "garbage", "shield", "speed", "magnet" }) do
    local img = lg.newImage("assets/" .. name .. ".png", { mipmaps = true })
    img:setFilter("linear", "linear")
    pcall(img.setMipmapFilter, img, "linear")
    images[name] = img
  end

  local limits = lg.getSystemLimits()
  local msaa = min(4, limits.canvasmsaa or 0)
  local ok, canvas = pcall(lg.newCanvas, W, H, { msaa = msaa })
  if not ok then canvas = lg.newCanvas(W, H) end
  mainCanvas = canvas
  mainCanvas:setFilter("linear", "linear")

  buildBackground()
  buildSprites()
  buildSounds()
  D.prewarm()
  D.rehearse()

  for _, js in ipairs(love.joystick.getJoysticks()) do
    if js:isGamepad() then activeJoystick = js; break end
  end
  if not activeJoystick then activeJoystick = love.joystick.getJoysticks()[1] end

  resetGame()
  gameState = "ready"
  buildMenu()
end

function love.update(dt)
  dt = min(dt, 0.034)
  clock = clock + dt
  if inputGuard > 0 then inputGuard = max(0, inputGuard - dt) end
  if gameState == "running" or gameState == "resuming" or gameState == "ready" or gameState == "gameover" then
    backgroundAnimationTime = backgroundAnimationTime + dt
  end
  if combo.t < 2 then combo.t = combo.t + dt end
  if flashTime > 0 then flashTime = max(0, flashTime - dt) end

  if gameState == "running" then
    moveInput.x, moveInput.y = readDirection()
    update(dt)
  elseif gameState == "resuming" then
    if clock - resumeStartedAt >= K.RESUME_COUNTDOWN_DURATION then gameState = "running" end
  elseif gameState == "ready" or gameState == "gameover" then
    player.bob = player.bob + dt * 2
  end

  buildMenu()
  if menuActive() then updateMenuNavigation(dt) else navRepeat.dir = nil end
end

function D.drawWorld(time)
  lg.push()
  if shakeTime > 0 then
    local strength = sw(shakePower) * clamp(shakeTime / 0.42, 0, 1)
    lg.translate(rb(-strength, strength), rb(-strength, strength))
  end
  D.drawBackground(backgroundAnimationTime)
  D.drawRushWarning(time)
  D.drawPickups(time)
  D.drawPowerups(time)
  D.drawProjectiles()
  D.drawEnemies()
  D.drawBlast()
  D.drawPlayer(time)
  D.drawParticles()
  D.drawFloatingTexts()
  D.drawPowerupStatus()
  lg.pop()
  lg.setColor(1, 1, 1, 1)
  lg.draw(textureImage, 0, 0)
end

function love.draw()
  local dt = love.timer.getDelta()
  lg.setCanvas(mainCanvas)
  lg.clear(C.ink[1], C.ink[2], C.ink[3], 1)
  lg.setLineStyle("smooth")
  local time = clock

  if gameState == "ready" then
    D.drawTitleScreen(time)
    if overlay == "info" then D.drawInfo() end
  else
    D.drawWorld(time)
    D.drawHud(time)
    D.drawBannerAndCombo(min(dt, 0.05))
    if flashTime > 0 then
      local p = 1 - flashTime / 0.5
      local a = p < 0.14 and (p / 0.14) * 0.86 or 0.86 * (1 - (p - 0.14) / 0.86) ^ 1.6
      lg.setColor(1, 240 / 255, 179 / 255, a)
      lg.rectangle("fill", 0, 0, W, H)
    end
    if gameState == "paused" then
      D.drawPaused(time, "INTERMISSION", "YOU HAVE PAUSED THE MOVIE", "PRESS START TO RESUME")
    elseif gameState == "reset-confirm" then
      D.drawPaused(time, "ARE YOU SURE?", "RESET CURRENT GAME", "YOUR CURRENT GAME WILL END.")
    elseif gameState == "end-confirm" then
      D.drawPaused(time, "ARE YOU SURE?", "END CURRENT RUN", "YOUR RUN WILL END AND RESULTS WILL BE SHOWN.")
    elseif gameState == "quit-confirm" then
      D.drawPaused(time, "ARE YOU SURE?", "LEAVE THE MOVIE?", "YOUR CURRENT GAME WILL END.")
    elseif gameState == "resuming" then
      D.drawResumeCountdown()
    elseif gameState == "gameover" then
      if overlay == "stats" then D.drawStats() else D.drawGameOver(time) end
    end
  end

  lg.setCanvas()
  lg.clear(0, 0, 0, 1)
  local sw2, sh2 = lg.getDimensions()
  local scale = min(sw2 / W, sh2 / H)
  if scale >= 1 then scale = floor(scale * 100) / 100 end
  lg.setColor(1, 1, 1, 1)
  lg.setBlendMode("alpha", "premultiplied")
  lg.draw(mainCanvas, floor((sw2 - W * scale) / 2), floor((sh2 - H * scale) / 2), 0, scale, scale)
  lg.setBlendMode("alpha", "alphamultiply")
end

function love.quit()
  saveData()
  return false
end
