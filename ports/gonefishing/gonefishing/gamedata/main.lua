-- Gone Fishing: a quiet pixel fishing game for the TrimUI Brick (LÖVE 11.5).
local U = require("util")
local Wd = require("world")
local FISH = require("fishdata")
local FD = require("fishdraw")
local L = require("look")
local UI = require("ui")
local TB = require("tackle")
local Audio = require("audio")
local Rope = require("rope")
local GR = require("gear")
local GO = require("goals")

local lg = love.graphics
local W, H, CUT_Y, WORLD_W = U.W, U.H, U.CUT_Y, U.WORLD_W
local fl, rr, rnd, lerp, clamp, mix, setc, wander, sign = U.fl, U.rr, U.rnd, U.lerp, U.clamp, U.mix, U.setc, U.wander, U.sign

local args = {}
G.VERSION = "1.3"
local canvas, scale, offX, offY = nil, 1, 0, 0
local game, st

G.LOCS, G.LOCBY = Wd.LOCS, Wd.byId
G.fishAt = Wd.fishAt
G.FISHBY = {}
for _, f in ipairs(FISH) do G.FISHBY[f.id] = f end
G.BOATS = nil

---------------------------------------------------------------- saving
local function defaults()
  return { coins = 0, rod = 1, line = 1, lure = 1, boat = "rowboat", boats = { rowboat = true }, coolerLvl = 1,
           cooler = {}, log = {}, clock = 0.27, idle = false, mute = false, catches = 0, playTime = 0,
           loc = "lake", unlocked = { lake = true }, look = L.defaultLook(), boatX = 520, face = 1,
           binds = { cast = "a", fast = "b", pet = "x", box = "start", motor = "y" }, dayN = 0 }
end

local function ser(v)
  local t = type(v)
  if t == "number" then return string.format("%.10g", v)
  elseif t == "boolean" then return tostring(v)
  elseif t == "string" then return string.format("%q", v)
  elseif t == "table" then
    local parts = {}
    for k, val in pairs(v) do parts[#parts + 1] = "[" .. ser(k) .. "]=" .. ser(val) end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  return "nil"
end

-- three save slots: save1.lua .. save3.lua, plus slot.txt remembering the last one played
G.slot = nil                       -- the slot being played (nil on the title screen, before one is picked)
local function slotFile(i) return "save" .. i .. ".lua" end

local function saveGame()
  if (args.test and not args.slottest) or not game or not G.slot then return true end
  if st and st.boat then game.boatX, game.face = st.boat.x, st.boat.face end
  return love.filesystem.write(slotFile(G.slot), "return " .. ser(game))
end

-- read a save file into a table, or nil
local function readSave(path)
  if not love.filesystem.getInfo(path) then return nil end
  local ok, chunk = pcall(love.filesystem.load, path)
  if not (ok and chunk) then return nil end
  local ok2, data = pcall(chunk)
  if ok2 and type(data) == "table" then return data end
  return nil
end

-- saves from before slots existed become slot 1
local function migrateSlots()
  if love.filesystem.getInfo("save.lua") and not love.filesystem.getInfo(slotFile(1)) then
    local data = love.filesystem.read("save.lua")
    if data and love.filesystem.write(slotFile(1), data) then love.filesystem.remove("save.lua") end
  end
end

local function loadGame(slot)
  local g = defaults()
  local path = slotFile(slot or 1)
  if love.filesystem.getInfo(path) then
    local ok, chunk = pcall(love.filesystem.load, path)
    if ok and chunk then
      local ok2, data = pcall(chunk)
      if ok2 and type(data) == "table" then
        for k, v in pairs(data) do
          if type(v) == "table" and type(g[k]) == "table" and k ~= "log" and k ~= "cooler" then
            for k2, v2 in pairs(v) do g[k][k2] = v2 end
          else
            g[k] = v
          end
        end
      end
    end
  end
  if not Wd.byId[g.loc] then g.loc = "lake" end
  if not g.vol then g.vol = { master = g.mute and 0 or 10, music = g.music == false and 0 or 10, sfx = 10, amb = 10 } end
  g.look = L.normalize(g.look)
  GR.migrate(g)
  GR.sync(g)
  GO.init(g)
  return g
end

---------------------------------------------------------------- input
local pressed = {}
local keymap = {
  z = "a", space = "a", x = "b", backspace = "b", c = "x", v = "y",
  ["return"] = "start", escape = "start", tab = "select", rshift = "select",
  up = "up", down = "down", left = "left", right = "right", q = "l", e = "r",
}
local padmap = {
  a = "a", b = "b", x = "x", y = "y", start = "start", back = "select", guide = "start",
  dpup = "up", dpdown = "down", dpleft = "left", dpright = "right", leftshoulder = "l", rightshoulder = "r",
}
local lastInput = 0
-- Button layout: some devices print A/B (and X/Y) the other way round. One device-wide setting swaps them right
-- where buttons come in, so gameplay, menus and the keyboard all follow it. It lives in prefs.lua, outside the
-- save slots (it's about the hardware, and it applies on the title screen before a save is loaded).
G.prefs = { swapButtons = false }
local SWAP = { a = "b", b = "a", x = "y", y = "x" }
local function mapButton(b) if b and G.prefs.swapButtons and SWAP[b] then return SWAP[b] end return b end
G.loadPrefs = function()
  if args.test then return end
  local ok, chunk = pcall(love.filesystem.load, "prefs.lua")
  if ok and chunk then
    local ok2, t = pcall(chunk)
    if ok2 and type(t) == "table" then G.prefs.swapButtons = t.swapButtons == true end
  end
end
G.savePrefs = function()
  if args.test then return end
  love.filesystem.write("prefs.lua", "return { swapButtons = " .. tostring(G.prefs.swapButtons == true) .. " }")
end
function love.keypressed(k) if keymap[k] then pressed[mapButton(keymap[k])] = true; lastInput = 0 end end
-- Under PortMaster (launched with --fullscreen) the buttons come in only as keys from gptokeyb, which follows each
-- device's printed button labels. Reading the controller directly as well would double every press, and SDL names
-- buttons by position, so on Nintendo-style layouts A and B would be swapped. Direct controller input is for
-- running on a computer (or pass --gamepad to force it on).
local function padOn() return not args.fullscreen or args.gamepad end
function love.gamepadpressed(_, b) if padOn() and padmap[b] then pressed[mapButton(padmap[b])] = true; lastInput = 0 end end

local testHold = {}
local function isDown(action)
  if testHold[action] then return true end
  for k, a in pairs(keymap) do if mapButton(a) == action and love.keyboard.isDown(k) then return true end end
  for _, j in ipairs(padOn() and love.joystick.getJoysticks() or {}) do
    if j:isGamepad() then
      for b, a in pairs(padmap) do if mapButton(a) == action and j:isGamepadDown(b) then return true end end
      local ax = j:getGamepadAxis("leftx")
      if action == "left" and ax < -0.5 then return true end
      if action == "right" and ax > 0.5 then return true end
      local ay = j:getGamepadAxis("lefty")
      if action == "up" and ay < -0.5 then return true end
      if action == "down" and ay > 0.5 then return true end
    end
  end
  return false
end

-- remappable actions (cast/reel, fast reel, pet, tackle box) go through the player's bindings
local function act(name) return pressed[(game.binds or {})[name] or name] end
local function actDown(name) return isDown((game.binds or {})[name] or name) end
G.pressedRaw = function() return pressed end

---------------------------------------------------------------- sound
-- Settings volume levels, 0..10 each: master, music, sound effects, nature sounds
local function applyVolume()
  local v = game.vol
  game.mute, game.music = v.master == 0, v.music > 0
  love.audio.setVolume(v.master / 10)
  Audio.musicVol, Audio.sfxVol, Audio.ambVol = v.music / 10, v.sfx / 10, v.amb / 10
end

local function play(name, pitch)
  if game and game.mute then return end
  Audio.play(name, pitch)
end
G.play = play

local function toast(msg)
  st.toast, st.toastT = msg, 3.2
end
G.toast = function(m) if st then toast(m) end end

---------------------------------------------------------------- fish picking
local function isNight() return (G.sky and G.sky.night or 0) > 0.5 end

local function pickFish(visitor)
  local list, total = {}, 0
  local lure = game.equip.lure
  for _, f in ipairs(FISH) do
    if f.loc == game.loc and (f.time == "any" or (f.time == "night") == isNight()) then
      local aff = GR.affinity(f.id, lure)
      local w = f.weight * (0.6 + 0.4 * aff)
      if f.legend then w = f.weight * (aff > 0 and 1.6 or 0.5) end
      if visitor then w = f.tier >= 3 and w * 3 or w * 0.25 end
      total = total + w
      list[#list + 1] = { f, w }
    end
  end
  if total <= 0 then return nil end
  local r = rnd() * total
  for _, e in ipairs(list) do
    r = r - e[2]
    if r <= 0 then return e[1] end
  end
  return list[#list][1]
end

local function fishValue(c)
  local f = G.FISHBY[c.id]
  local q = (c.size - f.min) / math.max(1, f.max - f.min)
  return math.floor(f.value * (0.75 + 0.6 * q) + 0.5)
end

---------------------------------------------------------------- state
local function newState()
  return {
    mode = "title", phase = "idle", time = 0, titleT = 0,
    power = 0, pdir = 1, throwT = 0,
    lure = { x = 0, y = 0, vx = 0, vy = 0, state = "hang", fly = nil, spin = 0 },
    reeling = false, letting = false,
    biter = nil, interestT = 0.5, window = 0, alertT = 0,
    T = 0, thrash = false, thrashT = 1, stamina = 1, landed = nil,
    card = nil, toast = nil, toastT = 0,
    rod = U.spring(0), rodAng = U.spring(-1.0), twitch = 0,
    pose = "idle", poseT = 0, blinkT = rr(1.5, 4), breathT = 0,
    boat = { x = game.boatX or 520, v = 0, face = game.face or 1, yaw = U.spring((game.face or 1) > 0 and 0 or 180),
             rowT = 0, rowing = false, wakeT = 0, strokeHit = false },
    pet = { blinkT = 2, blink = 0, speak = 0, happy = 0, wagT = 4, wag = 0, hearts = {}, zz = {}, sleepy = 0, chatT = rr(30, 70) },
    petting = 0,
    fade = nil, hintT = 0,
    idle = { t = 1.5, casts = 0, wait = 0, depth = 0.5, moveTo = nil },
    camY = 0,
  }
end

local function boatMeta() return G.BOATS[game.boat] end
local function boatSpeed()
  for _, b in ipairs(GR.BOATS) do if b.key == game.boat then return b.speed end end
  return 44
end
-- a trolling motor: on the rowboat it drives the boat in place of the oars
local function hasTroll() return GR.hasMotor(game) end
local function trollDrive() return game.boat == "rowboat" and hasTroll() end
local function coolerCap() return GR.COOLERS[game.equip.cooler].cap end
local function curLure() return GR.LURE[game.equip.lure] or GR.LURE.worm end
local function hasBobber() return GR.hasBobber(game) end
local PX_PER_FT = 8                     -- depth readout: about 8 pixels to a foot
local GRAV = 320                        -- gravity in pixels per second squared

---------------------------------------------------------------- geometry
local function yawRad() return math.rad(st.boat.yaw.x) end
local function freeboard() return boatMeta().depth * 0.5 end
local function boatY() return CUT_Y + wander(st.time * 0.9, 3) * 0.9 end
-- where an oar blade is through one rowing stroke (relative to the oarlock): it swings forward clear of
-- the water, dips in at the catch, sweeps back through the water to drive the boat, then lifts out
local OAR_REACH, OAR_DEPTH, OAR_AIR = 22, 13, 1
local function oarBlade(ph)
  if ph < 0.45 then
    local u = U.easeInOutSine(ph / 0.45)
    return lerp(-OAR_REACH, OAR_REACH, u), OAR_AIR - math.sin(math.pi * u) * 3
  elseif ph < 0.52 then
    return OAR_REACH, lerp(OAR_AIR, OAR_DEPTH, (ph - 0.45) / 0.07)
  elseif ph < 0.85 then
    local u = U.easeInOutSine((ph - 0.52) / 0.33)
    return lerp(OAR_REACH, -OAR_REACH, u), OAR_DEPTH
  end
  return -OAR_REACH, lerp(OAR_DEPTH, OAR_AIR, (ph - 0.85) / 0.15)
end
-- the oar pivots on its oarlock, so the handle moves opposite the blade: blade forward = hands pulled
-- in to the chest, blade back = arms reaching out. Pick the arm pose whose hands are nearest the handle.
local function rowPose(ph)
  local bx = oarBlade(ph)
  local h = bx / OAR_REACH                 -- +1 blade forward (hands in) .. -1 blade back (arms out)
  if h > 0.33 then return "row_pull" elseif h < -0.33 then return "row_reach" end
  return "row_mid"
end

local function anglerPos()
  local b = st.boat
  local c = math.cos(yawRad())
  local ax = b.x - 0.10 * boatMeta().len * c
  local oy = boatY() - freeboard()
  return ax, oy - 34
end
local function facingRight() return math.cos(yawRad()) >= 0 end
local function handPos()
  local ax, ay = anglerPos()
  local p = L.POSE[st.pose] or L.POSE.idle
  local hx = facingRight() and p.hx or (L.FW - 1 - p.hx)
  return ax - L.FW / 2 + hx + 0.5, ay + p.hy + 0.5
end
local ROD_LEN = 52
local drawReel
-- the rod as a list of points that bend toward the line under strain
local function rodPoints()
  local hx, hy = handPos()
  local dir = facingRight() and 1 or -1
  local pts = { { hx, hy } }
  local ang = st.rodAng.x
  local bend = st.rod.x
  local x, y = hx, hy
  local n = 7
  for i = 1, n do
    local f = i / n
    local a = ang + bend * f * f * 1.6
    x = x + math.cos(a) * dir * ROD_LEN / n
    y = y + math.sin(a) * ROD_LEN / n
    pts[#pts + 1] = { x, y }
  end
  return pts
end
local function rodTip()
  local p = rodPoints()
  return p[#p][1], p[#p][2]
end

local function lureDepthY(d) return Wd.depthToY(d) end

---------------------------------------------------------------- pet
local function petKind() return L.value(game.look, "pet") or "none" end
local function petEvent(kind)
  local pk = petKind()
  if pk == "none" then return end
  local p = st.pet
  p.sleepy = 0
  if kind == "catch" or kind == "hello" then
    p.speak = 0.5
    local dog = L.species(pk) == "dog"
    play(dog and "bark" or "purr", dog and rr(0.95, 1.1) * (pk == "spitz" and 1.15 or 1) or 1)
  elseif kind == "pet" then
    game.stats.pats = game.stats.pats + 1
    p.happy = 1.6
    local dog = L.species(pk) == "dog"
    play(dog and "bark" or "purr", dog and rr(1.04, 1.14) * (pk == "spitz" and 1.15 or 1) or 1)
    for i = 1, 3 do p.hearts[#p.hearts + 1] = { x = rr(-4, 4), y = 0, t = -i * 0.25 } end
  end
end

---------------------------------------------------------------- the api the tackle box uses
local function spend(cost)
  if game.coins < cost then play("nope"); TB.flash("Not enough coins."); return false end
  game.coins = game.coins - cost
  play("buy")
  return true
end

G.api = {
  value = fishValue,
  sell = function(i)
    local c = table.remove(game.cooler, i)
    if c then
      local v = fishValue(c)
      game.coins = game.coins + v; game.stats.earned = game.stats.earned + v
      play("coin"); saveGame()
    end
  end,
  sellAll = function()
    local sum = 0
    for _, c in ipairs(game.cooler) do sum = sum + fishValue(c) end
    game.cooler = {}
    if sum > 0 then
      game.coins = game.coins + sum; game.stats.earned = game.stats.earned + sum
      play("coin"); TB.flash("Sold for " .. sum .. " coins."); saveGame()
    end
  end,
  -- the shop and the gear locker: kind is "rod", "line", "lure", "cooler" or "boat"
  buy = function(kind, key)
    if game.owned[kind][key] then play("nope"); TB.flash("You already own that."); return end
    local item = G.api.item(kind, key)
    if spend(item.cost) then
      game.owned[kind][key] = true
      G.api.equip(kind, key, true)
      TB.flash(item.name .. (kind == "lure" and " added to your tackle." or " is yours!"))
      saveGame()
    end
  end,
  equip = function(kind, key, quiet)
    if not game.owned[kind][key] then play("nope"); return end
    if kind == "boat" then game.boat = key else game.equip[kind] = key end
    GR.sync(game)
    if not quiet then play("click"); TB.flash("Now using: " .. G.api.item(kind, key).name) end
  end,
  item = function(kind, key)
    if kind == "rod" then return GR.RODS[key] elseif kind == "line" then return GR.LINES[key]
    elseif kind == "cooler" then return GR.COOLERS[key] elseif kind == "lure" then return GR.LURE[key]
    elseif kind == "motor" then return GR.MOTORS[key]
    elseif kind == "bobber" then return GR.BOBBERS[key] end
    for _, b in ipairs(GR.BOATS) do if b.key == key then return b end end
  end,
  claim = function(kind, id)
    local reward
    if kind == "ach" then
      for _, a in ipairs(GO.LIST) do if a.id == id and game.ach[id] == "done" then game.ach[id] = "claimed"; reward = a.reward end end
    elseif game.daily then
      local r = game.daily.list[id]
      if r and r.done and not r.claimed then r.claimed = true; reward = r.reward end
    end
    if reward then
      game.coins = game.coins + reward
      play("coin"); play("catch")
      TB.flash("+" .. reward .. " coins!")
      saveGame()
    else
      play("nope")
    end
  end,
  travel = function(id)
    local l = Wd.byId[id]
    if game.loc == id then play("nope"); TB.flash("You are already here."); return end
    if not game.unlocked[id] then
      if not spend(l.cost) then return end
      game.unlocked[id] = true
    end
    TB.close()
    st.fade = { t = 0, dir = 1, go = id }
    play("oar")
  end,
  save = function() saveGame(); play("buy") end,
  -- the saving popup: "Saving..." then "Saved!", then the chosen action ("save" stays, "title" or "quit")
  saveFlow = function(kind)
    if st.saving then return end
    st.saving = { t = 0, kind = kind }
  end,
  -- save, close the tackle box and fade back to the title screen, where another save can be picked
  toTitle = function()
    saveGame()
    TB.close()
    st.fade = { t = 0, dir = 1, title = true }
    play("latch")
  end,
  petHello = function() petEvent("hello") end,
  applyVolume = function() applyVolume() end,
}

---------------------------------------------------------------- places
local function enterPlace(id)
  game.loc = id
  game.unlocked[id] = true
  game.stats.visited[id] = true
  Wd.build(id)
  Audio.setLocation(id)
  st.phase = "idle"
  st.lure.state = "hang"
  st.biter = nil
  st.boat.x = clamp(st.boat.x, 80, WORLD_W - 80)
  if st.mode ~= "title" then toast(Wd.byId[id].name) end
end

---------------------------------------------------------------- fishing
local function startCast(power)
  -- always start from the lure hanging under the rod tip, whatever happened before
  st.lure.state, st.lure.fly, st.biter, st.bob = "hang", nil, nil, nil
  st.phase = "throw"
  st.throwT = 0
  st.power = power
  play("click")
end

local function releaseLure()
  -- The cast, as physics: the rod flings the lure at a speed set by how hard you cast and how well the lure
  -- loads the rod (a very light bait can't bend it, so it leaves slower). In the air the lure is slowed by drag
  -- on its own shape (and a bobber's) and by line peeling off the spool and through the guides, so heavy,
  -- compact lures carry farthest and light or bulky ones fall short. A better rod flings a little faster;
  -- thicker line drags a little more.
  local tx, ty = rodTip()
  local dir = facingRight() and 1 or -1
  local L = curLure()
  local m, area = L.oz or 0.25, L.area or 1
  if hasBobber() then m, area = m + 0.15, area + 1.6 end
  local p = st.power
  local vt = 300 * (1 + 0.03 * ((game.rod or 1) - 1))
  local load = math.min(1, (m / 0.15) ^ 0.35)
  local v0 = vt * (0.18 + 0.82 * p) * load * (1 - 0.15 * m)
  local ang = math.rad(15 + 25 * p)
  local x0, y0 = tx + dir * 2, ty - 2
  st.lure.state = "fly"
  st.lure.fly = { vx = dir * v0 * math.cos(ang), vy = -v0 * math.sin(ang), m = m,
                  kd = 0.0003 * area, kl = 0.015 * (1 + 0.18 * ((game.line or 1) - 1)), t = 0 }
  st.lure.x, st.lure.y = x0, y0
  st.phase = "line"
  st.lineOut = 3
  st.bob = nil
  if st.rope then Rope.launch(st.rope, x0, y0, st.lure.fly.vx, st.lure.fly.vy) end
  play("cast")
end

local function retrieve()
  if st.biter and not st.biter.hooked then
    st.biter.controlled = false; st.biter.state = "cruise"; st.biter.cool = 4
    Wd.pickTarget(st.biter)
  end
  st.biter = nil
  st.phase = "idle"
  st.lure.state = "hang"
  st.bob = nil
  st.T = 0
end

local function loseFish(msg)
  if args.idletest then print("  lost:", msg, st.phase, st.T) end
  local a = st.biter
  if a then
    a.hooked, a.controlled, a.airborne = false, false, false
    a.state, a.t, a.cool = "flee", 1.2, 10
    a.tx, a.ty = a.x + (a.x < st.boat.x and -160 or 160), a.y + 20
  end
  st.biter = nil
  st.phase = "line"
  st.lure.state = "sink"
  st.T = 0
  if msg then toast(msg) end
end

local function landFish()
  local a = st.biter
  local f = a.f
  local size = a.size or clamp(fl(lerp(f.min, f.max, rnd() ^ 1.6)), f.min, f.max)
  local e = game.log[f.id]
  local isNew = not e
  local best = e and size > e.best
  if not e then e = { n = 0, best = 0 }; game.log[f.id] = e end
  e.n = e.n + 1
  e.best = math.max(e.best, size)
  game.catches = (game.catches or 0) + 1
  local _, _, rainA = Wd.weatherAmounts()
  GO.onCatch(game, f, size, { night = isNight(), rain = rainA > 0.3, jumped = a.jumped })
  for i, x in ipairs(Wd.fish) do if x == a then table.remove(Wd.fish, i); break end end
  local hx, hy = handPos()
  st.landed = { f = f, x = a.x, y = a.y, x0 = a.x, y0 = a.y, x1 = hx + (facingRight() and 8 or -8), y1 = hy + 4, t = 0, face = a.turn.x, phase = a.phase }
  st.card = { f = f, size = size, isNew = isNew, best = best and not isNew, t = 0 }
  st.biter = nil
  st.phase = "landed"
  st.lure.state = "hang"
  st.bob = nil
  st.T = 0
  Wd.addSplash(a.x, CUT_Y, 14, 1.3)
  Wd.addRipple(a.x, CUT_Y, 22)
  play("splash")
  play("catch")
  petEvent("catch")
  saveGame()
end

local function keepFish()
  local c = st.card
  if #game.cooler >= coolerCap() then
    if game.idle then G.api.sellAll() else play("nope"); toast("The cooler is full! Sell fish in the tackle box."); return end
  end
  game.cooler[#game.cooler + 1] = { id = c.f.id, size = c.size }
  play("click")
  st.card, st.landed = nil, nil
  st.phase = "idle"
  saveGame()
end

local function releaseFish()
  local c = st.card
  st.card = nil
  if st.landed then
    Wd.addSplash(st.landed.x0, CUT_Y, 6, 0.7)
    Wd.addRipple(st.landed.x0, CUT_Y, 14)
    play("splash", 1.4)
  end
  st.landed = nil
  st.phase = "idle"
  if c then toast("Back you go, " .. c.f.name .. ".") end
end

-- the lure moving through the water, and fish deciding whether they care
local function updateLine(dt, reel, letOut, fast)
  local lu = st.lure
  st.lettingOut = letOut
  local tx = rodTip()
  local ex, ey = tx + (facingRight() and 6 or -6), CUT_Y + 4
  local L = curLure()
  local bobbing = hasBobber()
  local tipx, tipy = rodTip()
  if lu.state == "fly" then
    -- in the air: drag on the lure (quadratic in speed) and on the line leaving the spool (linear)
    local fz = lu.fly
    local n = math.max(1, math.ceil(dt * 240))
    local h = dt / n
    for _ = 1, n do
      local v = math.sqrt(fz.vx * fz.vx + fz.vy * fz.vy)
      local k = (fz.kd * v + fz.kl) / fz.m
      fz.vx = fz.vx - k * fz.vx * h
      fz.vy = fz.vy + (GRAV - k * fz.vy) * h
      lu.x, lu.y = lu.x + fz.vx * h, lu.y + fz.vy * h
    end
    fz.t = fz.t + dt
    if lu.x < 16 or lu.x > WORLD_W - 16 then lu.x = clamp(lu.x, 16, WORLD_W - 16); fz.vx = 0 end
    if (fz.vy > 0 and lu.y >= CUT_Y) or fz.t > 4 then
      lu.state, lu.y = "sink", CUT_Y + 3
      Wd.addRipple(lu.x, CUT_Y, bobbing and 14 or 12)
      Wd.addSplash(lu.x, CUT_Y, bobbing and 6 or 5, 0.6)
      Wd.spook(lu.x, CUT_Y + 20, 22)
      play("plop", rr(0.9, 1.1))
      play("bail", rr(0.95, 1.05))
      st.interestT = 1.0
      -- the bail snaps shut: whatever line is out stays out, plus the little slack the arc left on the water,
      -- so the lure sinks freely for a moment before the line comes tight
      local d = math.sqrt((lu.x - tipx) ^ 2 + (lu.y - tipy) ^ 2)
      st.lineOut = d + (bobbing and 3 or (12 + d * 0.06))
      st.anchorX = lu.x
      if bobbing then st.bob = { x = lu.x, dip = 0, dipV = 0 } end
    end
    return
  end
  local bed = Wd.bedY(clamp(lu.x, 0, WORLD_W - 1)) - 3
  local moving = 0
  local sp = (24 + 5 * game.rod) * (fast and 2.6 or 1)
  local sinkMul = 1 - 0.05 * ((game.line or 1) - 1)          -- thicker line slows the fall a little
  if bobbing and st.bob then
    -- A slip bobber: the float rides the surface; the bait hangs below it at the depth set by the stop.
    -- Up and Down move the stop (shallower / deeper); A reels the whole rig in across the surface.
    local b = st.bob
    local upOnly = isDown("up") and not actDown("cast") and not fast
    if upOnly then reel = false end
    game.bobDepth = game.bobDepth or 40
    if letOut then game.bobDepth = math.min(game.bobDepth + 28 * dt, 220); st.depthT = 1.5 end
    if upOnly then game.bobDepth = math.max(game.bobDepth - 28 * dt, 8); st.depthT = 1.5 end
    local bx0 = b.x
    if reel then
      st.lineOut = math.max(8, st.lineOut - sp * dt)
      st.reelSpeed = sp
      st.reelV, st.reelRate = fast and 1 or 0.7, fast and 1.7 or 1
      lu.spin = lu.spin + dt * 14
    end
    -- the main line can't be longer than what's out: a tight line drags the float toward the boat
    local hy = CUT_Y - tipy
    local reach = math.sqrt(math.max(0, st.lineOut * st.lineOut - hy * hy))
    if math.abs(b.x - tipx) > reach then b.x = tipx + (b.x > tipx and 1 or -1) * reach end
    b.x = b.x + Wd.flow() * dt * 5
    if reel and math.abs(b.x - tipx) < 14 then retrieve(); play("click"); return end
    local bv = math.abs(b.x - bx0) / math.max(dt, 1e-3)
    moving = bv > 4 and bv or 0
    -- the bait swings in under the float and sinks to the stop; a moving float lifts it a little
    local held = st.biter and st.biter.struck
    if not held then
      local want = math.min(CUT_Y + game.bobDepth * (1 - math.min(0.4, bv / 80)), bed)
      local fall = math.max(L.sink, 10) * sinkMul
      if lu.y < want then lu.y = math.min(want, lu.y + fall * dt) else lu.y = math.max(want, lu.y - 30 * dt) end
      lu.x = lu.x + (b.x - lu.x) * math.min(1, dt * 1.6)
      lu.state = lu.y >= bed - 0.5 and "rest" or "sink"
    end
    -- the float's bob: settles after landing, twitches on nibbles, goes under on a take (set in the bite code)
    b.dipV = b.dipV + (-b.dip * 60 - b.dipV * 9) * dt
    b.dip = b.dip + b.dipV * dt
    st.lureSpeed = moving
  else
    -- Most of the line lies on the water between the boat and the lure; the lure hangs below the point where the
    -- line leaves the surface (the anchor), on whatever slack is left: slack = line out minus the line lying from
    -- the rod tip to that point. So after the splash it sinks only by the slack the cast left, then holds.
    -- Down feeds out line (more slack: it sinks deeper). Up or A winds in: first the slack goes and the lure lifts,
    -- then the line comes tight and the lure is drawn toward the boat. A moving boat (trolling) pulls the same way.
    st.anchorX = st.anchorX or lu.x
    local hy = CUT_Y - tipy
    local function lying() local dx = st.anchorX - tipx; return math.sqrt(dx * dx + hy * hy) end
    if reel then
      st.reelSpeed = sp
      st.reelV, st.reelRate = fast and 1 or 0.7, fast and 1.7 or 1
      lu.spin = lu.spin + dt * 14
      local slack = st.lineOut - lying()
      if slack > 3 and not L.float then
        st.lineOut = st.lineOut - sp * 1.2 * dt
        moving = sp * 0.5
      else
        local dx, dy = ex - lu.x, ey - lu.y
        local dd = math.sqrt(dx * dx + dy * dy)
        if dd < 10 or (L.float and math.abs(dx) < 10) then retrieve(); play("click"); return end
        if L.float then
          -- skitters along the surface
          lu.x = lu.x + (dx > 0 and 1 or -1) * sp * dt
          if L.id == "popper" and rnd() < dt * 3 then Wd.addSplash(lu.x, CUT_Y, 2, 0.4); Wd.addRipple(lu.x, CUT_Y, 6) end
        elseif L.dive and math.abs(dx) > 30 then
          -- the lip makes it dive while it's pulled along
          lu.x = lu.x + (dx > 0 and 1 or -1) * sp * dt
          local want = math.min(CUT_Y + L.dive, Wd.bedY(clamp(lu.x, 0, WORLD_W - 1)) - 6)
          lu.y = lu.y + clamp(want - lu.y, -sp * dt, sp * dt * 0.7)
        else
          lu.x, lu.y = lu.x + dx / dd * sp * dt, lu.y + dy / dd * sp * dt * 1.15
        end
        moving = sp
        lu.state = "sink"
        -- the line now runs along the surface to above the lure, then down to it
        st.anchorX = lu.x
        st.lineOut = lying() + math.max(0, lu.y - CUT_Y)
        if fast and rnd() < dt * 2 then Wd.spook(lu.x, lu.y, 30) end
      end
    else
      if letOut and not L.float then st.lineOut = st.lineOut + 30 * dt; moving = 6 end
      if L.float then
        lu.y = CUT_Y + 2
      elseif L.sink < 0 then
        lu.y = lu.y + L.sink * dt                                  -- a floating crankbait drifts back up
      elseif lu.state ~= "rest" then
        lu.y = lu.y + L.sink * sinkMul * dt
        if L.id == "spoon" then lu.x = lu.x + math.sin(st.time * 7) * 6 * dt end   -- a spoon flutters as it falls
      end
    end
    local drift = Wd.flow() * dt * 5
    lu.x, st.anchorX = lu.x + drift, st.anchorX + drift
    -- if the boat has moved away (trolling, drifting) the line drags the anchor and the lure toward it
    local slack = st.lineOut - lying()
    if slack < 1 then
      local need = math.max(0, st.lineOut - 1)
      local reach = math.sqrt(math.max(0, need * need - hy * hy))
      st.anchorX = tipx + (st.anchorX >= tipx and 1 or -1) * reach
      slack = 1
      if st.trolling then
        moving = math.max(moving, math.abs(st.boat.v) * 2)
        if L.dive then lu.y = lu.y + L.dive * 0.5 * dt end
      end
    end
    -- the lure hangs on the slack below the anchor: it can't be farther from that point than the slack allows
    local ax, ay = st.anchorX, CUT_Y
    local dx, dy = lu.x - ax, lu.y - ay
    local dd = math.sqrt(dx * dx + dy * dy)
    if dd > slack and dd > 0 then
      lu.x, lu.y = ax + dx / dd * slack, ay + dy / dd * slack
      if lu.state == "rest" then lu.state = "sink" end
    end
    -- with no tension the anchor settles over the lure (the line lies straight to it)
    if not reel then st.anchorX = st.anchorX + (lu.x - st.anchorX) * math.min(1, dt * 0.6) end
    if lu.y >= bed then lu.y = bed; lu.state = "rest" elseif not reel and lu.state == "rest" then lu.state = "sink" end
    if lu.y > bed then lu.y = bed end
    if lu.y < CUT_Y + 2 then lu.y = CUT_Y + 2 end
  end
  st.lureSpeed = moving
  -- interest
  local a = st.biter
  if not a then
    st.interestT = st.interestT - dt
    if st.interestT <= 0 then
      st.interestT = rr(0.6, 1.0)
      local L = curLure()
      local R = 85 + 45 * L.attract * ((L.glow and isNight()) and 1.4 or 1)
      local best, bd
      for _, f in ipairs(Wd.fish) do
        if not f.controlled and f.cool <= 0 and f.state ~= "flee" and GR.affinity(f.f.id, L.id) > 0 then
          -- a fish only notices a lure that is in front of it
          local ahead = (lu.x - f.x) * (f.turn and f.turn.x or f.face) > 4
          local dx, dy = math.abs(f.x - lu.x), math.abs(f.y - lu.y) * 1.3
          if not ahead then dx = 1e9 end
          local d = math.sqrt(dx * dx + dy * dy)
          if d < R and (not bd or d < bd) then best, bd = f, d end
        end
      end
      if best then
        local chance = 0.2 * (G.biteMult or 1) * GR.affinity(best.f.id, L.id)
          * ((moving > 30) and (L.flash and 1.3 or 0.6) or 1)
        if rnd() < chance then
          st.biter = best
          best.controlled = true
          best.bstate, best.bt = "approach", 0
          best.nibbles = rnd(2, 4)
        else
          best.cool = rr(1, 3)
        end
      end
    end
    return
  end
  -- a fish has noticed
  a.bt = a.bt + dt
  local face = lu.x >= a.x and 1 or -1
  local mo = (a.f.meta.mx - a.f.meta.cx)
  local tx2, ty2 = lu.x - face * (mo + 2), lu.y - (a.f.meta.my - a.f.meta.cy)
  ty2 = math.min(ty2, Wd.bedY(clamp(tx2, 0, WORLD_W - 1)) - 5, Wd.bedY(clamp(a.x, 0, WORLD_W - 1)) - 5)
  if a.bstate == "approach" then
    Wd.steer(a, tx2 - face * 6, ty2, moving > 0 and 26 or 16, 30, dt, 1)
    if math.abs(a.x - (tx2 - face * 6)) < 8 and math.abs(a.y - ty2) < 9 then a.bstate, a.bt, a.wait = "inspect", 0, rr(1.0, 2.6) end
    if a.bt > 9 then a.controlled = false; a.cool = 6; st.biter = nil end
  elseif a.bstate == "inspect" then
    Wd.steer(a, tx2 - face * (5 + math.sin(a.bt * 2) * 2), ty2, 10, 24, dt, 1)
    if moving > 30 then
      if rnd() < 0.5 then a.bstate, a.bt = "strike", 0 else loseFish(); return end
    elseif a.bt > a.wait then
      if not a.forced and rnd() < 0.12 then
        -- loses interest and wanders off
        a.controlled, a.cool, a.state = false, rr(8, 16), "cruise"
        Wd.pickTarget(a)
        st.biter = nil
        return
      end
      if a.nibbles > 0 then a.bstate, a.bt = "nibble", 0 else a.bstate, a.bt = "strike", 0 end
    end
  elseif a.bstate == "nibble" then
    local u = a.bt / 0.35
    local x = u < 0.5 and tx2 or tx2 - face * 5
    Wd.steer(a, x, ty2, 40, 200, dt, 1)
    if u >= 0.4 and not a.nibbled then
      a.nibbled = true
      st.twitch = 1
      play("nibble", rr(0.9, 1.1))
      if st.bob then st.bob.dipV = st.bob.dipV + 28 end
      Wd.addRipple(ex + (lu.x - ex) * 0.15, CUT_Y, 6)
    end
    if u >= 1 then a.nibbled = false; a.nibbles = a.nibbles - 1; a.bstate, a.bt, a.wait = "inspect", 0, rr(0.7, 1.8) end
  elseif a.bstate == "strike" then
    Wd.steer(a, tx2, ty2, 60, 400, dt, 1)
    if a.bt > 0.12 and not a.struck then
      a.struck = true
      st.window = game.idle and 0.25 or 0.95
      st.alertT = 0
      st.twitch = 2
      play("strike", rr(0.92, 1.05))
      Wd.addRipple(lu.x, CUT_Y, 10)
    end
    if a.struck then
      st.window = st.window - dt
      if st.bob then
        -- the take: the float is pulled under and away
        st.bob.dip = math.max(st.bob.dip, 7)
        st.bob.x = st.bob.x + (lu.x - st.bob.x) * math.min(1, dt * 3)
      end
      -- the fish holds the lure in its mouth and tugs
      lu.x = a.x + face * mo
      lu.y = a.y + (a.f.meta.my - a.f.meta.cy)
      if st.window <= 0 and not game.idle then
        a.struck = false
        loseFish("It got away...")
        return
      end
    end
  end
  Wd.move(a, dt, a.bstate == "strike" and 6 or 0)
  a.face = face
end

-- how each species fights: runners strip line, divers bore for the bottom, jumpers leap
local STYLE = {
  trout = "jump", bass = "jump", steelhead = "jump", mahi = "jump", marlin = "jump", salmon = "run",
  brooktrout = "jump", grayling = "jump", pike = "run", laketrout = "run", char = "run", frostfin = "run",
  riverghost = "run", mackerel = "run", snapper = "dive", rockfish = "dive", flounder = "dive",
  catfish = "dive", carp = "dive", burbot = "dive", oldwhiskers = "dive", walleye = "dive", whitefish = "run",
  c_smallmouth = "jump", shad = "jump", coho = "jump", c_steelhead = "jump", chinook = "run", sturgeon = "dive",
  gorgegiant = "dive", c_walleye = "dive", c_catfish = "dive", pikeminnow = "run",
}
local AREA = { lake = 1.0, river = 1.12, coast = 1.25, frost = 1.3, columbia = 1.28 }

local function hookFish()
  local a = st.biter
  local f = a.f
  a.hooked = true
  a.bstate = nil
  a.struck = false
  -- this fish's size decides a lot about the fight
  a.size = clamp(fl(lerp(f.min, f.max, rnd() ^ 1.6)), f.min, f.max)
  local q = (a.size - f.min) / math.max(1, f.max - f.min)
  st.fpow = clamp(f.str / 1.1, 0.25, 1.5) * (0.75 + 0.5 * q) * (AREA[game.loc] or 1)
  st.style = STYLE[f.id] or "tug"
  st.phase = "fight"
  st.T = 0.2
  st.stamina = 1
  st.move, st.moveT = "tug", rr(0.4, 0.8)
  st.thrash = true
  st.rod.v = st.rod.v + 4
  st.prevD = nil
  play("hookset")
  play("splash", 1.3)
  Wd.addSplash(st.lure.x, CUT_Y, 4, 0.5)
end

-- pick the fish's next move
local function nextMove(a)
  local p, sta = st.fpow, st.stamina
  local r = rnd()
  local m
  if r < 0.3 + 0.4 * (1 - sta) then m = "rest"
  elseif st.style == "run" and r < 0.75 then m = "run"
  elseif st.style == "dive" and r < 0.75 then m = "dive"
  elseif st.style == "jump" and r < 0.55 and a.y < CUT_Y + 90 and sta > 0.25 then m = "jump"
  else m = "tug" end
  local t = ({ rest = rr(0.9, 2.2) * (1.4 - sta), run = rr(1.2, 2.6) * (0.5 + p * 0.5) * (0.4 + sta),
               dive = rr(1.2, 2.4) * (0.4 + sta), tug = rr(0.6, 1.4), jump = 1.6 })[m]
  st.move, st.moveT = m, t
  st.thrash = m ~= "rest"
  if m == "jump" then
    a.jump = { t = 0, x0 = a.x, y0 = a.y, vx = (a.x >= st.boat.x and 1 or -1) * rr(20, 40), out = false }
  end
end

local function updateFight(dt, reel)
  local a = st.biter
  local f = a.f
  local tx = rodTip()
  local ex, ey = tx + (facingRight() and 6 or -6), CUT_Y + 6
  st.moveT = st.moveT - dt
  if st.moveT <= 0 and st.move ~= "jump" then nextMove(a) end
  local P = st.fpow * (0.35 + 0.65 * st.stamina)
  local mv = st.move
  local away = a.x >= st.boat.x and 1 or -1
  local bed = Wd.bedY(clamp(a.x, 0, WORLD_W - 1))
  local lineF = 1 + 0.22 * (game.line - 1)
  -- strain on the line: how hard the fish pulls against you right now
  local pull = ({ rest = 0.2, tug = 0.7, run = 1.25, dive = 1.0, jump = 0.15 })[mv] * P
  local target = reel and (0.25 + 0.8 * pull) / lineF or (0.1 + 0.25 * pull) / lineF
  local rate = (mv == "run" and reel) and 5 or 3
  st.T = st.T + (target - st.T) * math.min(1, dt * rate)
  st.stamina = math.max(0, st.stamina - dt * (0.035 + (reel and 0.06 or 0.015) + (mv ~= "rest" and 0.02 or 0)) / math.max(0.6, st.fpow))
  local rs = reel and (20 + 5 * game.rod) * (1 - 0.5 * clamp(pull, 0, 1)) or 0
  local dx, dy = ex - a.x, ey - a.y
  local d = math.sqrt(dx * dx + dy * dy)
  local vx, vy = 0, 0
  if mv == "jump" then
    -- out of the water in an arc, shaking, then back in with a splash
    local j = a.jump
    j.t = j.t + dt
    local u = j.t / 0.9
    if u < 0.25 then
      vx, vy = j.vx, -90
    elseif not j.out then
      j.out, j.vy, j.yy = true, -110 * (0.7 + 0.3 * st.stamina), CUT_Y - 2
      a.airborne, a.jumped = true, true
      Wd.addSplash(a.x, CUT_Y, 12, 1.1); Wd.addRipple(a.x, CUT_Y, 20)
      play("splash", 1.2)
    end
    if j.out then
      j.vy = j.vy + 300 * dt
      j.yy = j.yy + j.vy * dt
      a.x = a.x + j.vx * dt
      a.y = j.yy
      a.phase = a.phase + dt * 30
      if j.vy > 0 and j.yy > CUT_Y + 4 then
        a.airborne = false
        Wd.addSplash(a.x, CUT_Y, 10, 0.9); Wd.addRipple(a.x, CUT_Y, 18)
        play("splash", 0.9)
        st.move, st.moveT = "tug", rr(0.4, 0.9)
      end
      st.lure.x, st.lure.y = FD.mouth(f, a.x, a.y, a.face)
      a.face = j.vx > 0 and 1 or -1
      U.stepSpring(a.turn, a.face, 60, 10, dt)
      U.stepSpring(a.turnT, a.turn.x, 50, 10, dt)
      return
    end
  elseif mv == "run" then
    vx, vy = away * (45 + 40 * P), (rnd() - 0.4) * 10
  elseif mv == "dive" then
    vx, vy = away * 8 * P, 40 * P
  elseif mv == "tug" then
    vx, vy = away * 22 * P + math.sin(st.time * 9) * 14, math.sin(st.time * 5) * 10
  else
    vx, vy = away * 4 * P, -2
  end
  if d > 0 then vx, vy = vx + dx / d * rs, vy + dy / d * rs end
  a.vx = a.vx + (vx - a.vx) * math.min(1, dt * 4)
  a.vy = a.vy + (vy - a.vy) * math.min(1, dt * 4)
  a.x = clamp(a.x + a.vx * dt, 4, WORLD_W - 4)
  a.y = clamp(a.y + a.vy * dt, CUT_Y + 6, bed - 4)
  a.face = (mv == "rest" or (reel and mv ~= "run")) and -away or away
  U.stepSpring(a.turn, a.face, 30, 9, dt)
  U.stepSpring(a.turnT, a.turn.x, 36, 10, dt)
  a.phase = a.phase + dt * (mv == "rest" and 4 or mv == "run" and 16 or 11)
  st.lure.x, st.lure.y = FD.mouth(f, a.x, a.y, a.face)
  if mv ~= "rest" and rnd() < dt * 3 and a.y < CUT_Y + 30 then
    Wd.addSplash(a.x, CUT_Y, 3, 0.6); Wd.addRipple(a.x, CUT_Y, 10)
  end
  -- the reel: you wind (slower against a hard pull), and the drag clicks whenever the fish takes line
  local nd = math.sqrt((ex - a.x) ^ 2 + (ey - a.y) ^ 2)
  local out = st.prevD and (nd - st.prevD) / math.max(dt, 1e-4) or 0
  st.prevD = nd
  if reel then st.reelV, st.reelRate = 0.8, 1.15 - 0.6 * clamp(pull, 0, 1) end
  local giving = clamp((out - 4) / 40, 0, 1)
  if reel and st.T > 0.75 then giving = math.max(giving, (st.T - 0.75) * 3) end   -- winding against the drag
  if giving > 0 then
    st.dragV, st.dragSpeed = 0.35 + 0.65 * giving, 0.5 + giving
    if reel and out > 4 then st.reelV = st.reelV * 0.5 end
  end
  if st.T >= 1 then
    play("snap")
    game.stats.streak = 0
    loseFish("The line snapped!")
    st.lure.state = "hang"
    st.phase = "idle"
    st.rod.v = -6
    return
  end
  if d < 14 then landFish() end
end

---------------------------------------------------------------- the idle angler
local function idleBrain(dt)
  local I = st.idle
  if TB.isOpen() or st.fade then return {} end
  local act = {}
  if st.phase == "idle" then
    if I.moveTo then
      if math.abs(st.boat.x - I.moveTo) < 12 then I.moveTo = nil; I.t = 1.2
      else act[I.moveTo > st.boat.x and "right" or "left"] = true end
      return act
    end
    I.t = I.t - dt
    if I.t <= 0 then
      if I.casts >= 4 then
        I.casts = 0
        I.moveTo = clamp(st.boat.x + rr(-400, 400), 200, WORLD_W - 200)
        return act
      end
      I.casts = I.casts + 1
      local dir = st.boat.x > WORLD_W / 2 and -1 or 1
      if rnd() < 0.3 then dir = -dir end
      if (dir > 0) ~= facingRight() then act[dir > 0 and "right" or "left"] = true; return act end
      startCast(rr(0.25, 0.9))
      I.depth = rr(0.15, 0.95)
      I.wait = 0
      I.t = 1.5
    end
  elseif st.phase == "line" then
    I.wait = I.wait + dt
    if st.lure.state ~= "fly" and st.lure.y < Wd.depthToY(I.depth) and not st.biter then act.down = true end
    if I.wait > 40 and not st.biter then act.reel = true end
  elseif st.phase == "fight" then
    act.reel = st.T < 0.66
  elseif st.phase == "landed" and st.card and st.card.t > 2.2 then
    act.keep = true
  end
  return act
end

---------------------------------------------------------------- update

---------------------------------------------------------------- save slots
-- After A on the title screen: pick one of three slots. An empty slot asks for a name on an on-screen keyboard
-- and starts a new game; X on a used slot deletes it, after two confirmations.
local KEYS = { "ABCDEFGHIJ", "KLMNOPQRST", "UVWXYZ0123", "456789 -.'" }
local NAME_MAX = 10

local function slotInfo(i)
  local d = readSave(slotFile(i))
  if not d then return nil end
  local caught = (d.stats and d.stats.catches) or d.catches or 0
  return { name = d.name or ("Angler " .. i), coins = d.coins or 0, loc = d.loc or "lake", caught = caught,
           mins = math.floor((d.playTime or 0) / 60) }
end

local function openSlots()
  local info = {}
  for i = 1, 3 do info[i] = slotInfo(i) or false end
  st.slots = { sel = G.lastSlot or 1, mode = "list", info = info }
  play("blip")
end

-- load (or create) a slot and start playing it
local function startSlot(i, newName)
  if newName then
    game = defaults()
    game.name = newName
    game.vol = { master = 10, music = 10, sfx = 10, amb = 10 }
    GR.migrate(game); GR.sync(game); GO.init(game)
  elseif i ~= G.lastSlot or not st.slots.info[i] then
    game = loadGame(i)
  end
  G.game, G.slot, G.lastSlot = game, i, i
  love.filesystem.write("slot.txt", tostring(i))
  if newName or i ~= (st.slots.backdrop or G.lastSlot) then
    local t = st.titleT
    st = newState()
    st.titleT = t
    G.cam.x = clamp(st.boat.x - W / 2, 0, WORLD_W - W)
    enterPlace(game.loc)
  end
  applyVolume()
  saveGame()
  st.slots = nil
  st.fade = { t = 0, dir = 1, start = true }
  play("latch")
end

local function slotMenuUpdate()
  local m = st.slots
  if m.mode == "list" then
    if pressed.up then m.sel = (m.sel - 2) % 3 + 1; play("blip") end
    if pressed.down then m.sel = m.sel % 3 + 1; play("blip") end
    if pressed.a or pressed.start then
      if m.info[m.sel] then
        m.backdrop = G.lastSlot
        startSlot(m.sel)
      else
        m.mode, m.name, m.kx, m.ky = "name", "", 1, 1
        play("click")
      end
    elseif pressed.x and m.info[m.sel] then
      m.mode, m.confirm = "del1", 1
      play("nope")
    elseif pressed.b then
      st.slots = nil; play("blip")
    end
  elseif m.mode == "name" then
    -- the keyboard: four rows of characters and a row of SPACE / DELETE / DONE
    local rows = #KEYS + 1
    if pressed.up then m.ky = (m.ky - 2) % rows + 1; play("blip") end
    if pressed.down then m.ky = m.ky % rows + 1; play("blip") end
    local cols = m.ky <= #KEYS and #KEYS[m.ky] or 3
    if m.ky > #KEYS then m.kx = math.min(m.kx, 3) end
    if pressed.left then m.kx = (m.kx - 2) % cols + 1; play("blip") end
    if pressed.right then m.kx = m.kx % cols + 1; play("blip") end
    m.kx = math.min(m.kx, cols)
    local function done()
      local nm = m.name:gsub("^%s+", ""):gsub("%s+$", "")
      if nm == "" then play("nope"); return end
      m.backdrop = G.lastSlot
      startSlot(m.sel, nm)
    end
    if pressed.a then
      if m.ky <= #KEYS then
        if #m.name < NAME_MAX then m.name = m.name .. KEYS[m.ky]:sub(m.kx, m.kx); play("click") else play("nope") end
      elseif m.kx == 1 then
        if #m.name < NAME_MAX and #m.name > 0 then m.name = m.name .. " "; play("click") end
      elseif m.kx == 2 then
        m.name = m.name:sub(1, -2); play("blip")
      else
        done()
      end
    elseif pressed.start then
      done()
    elseif pressed.b then
      if #m.name > 0 then m.name = m.name:sub(1, -2); play("blip") else m.mode = "list"; play("blip") end
    end
  elseif m.mode == "del1" or m.mode == "del2" then
    -- two confirmations; the second one starts on "Keep" so a double press can't delete by accident
    if pressed.up or pressed.down then m.confirm = 3 - m.confirm; play("blip") end
    if pressed.b then m.mode = "list"; play("blip")
    elseif pressed.a then
      if m.confirm == 2 then m.mode = "list"; play("blip")
      elseif m.mode == "del1" then m.mode, m.confirm = "del2", 2; play("nope")
      else
        love.filesystem.remove(slotFile(m.sel))
        m.info[m.sel] = false
        m.mode = "list"
        play("splash")
      end
    end
  end
  pressed = {}
end

G.drawSlots = function()
  local m = st.slots
  local pw, ph = 300, 178
  local x, y = fl(W / 2 - pw / 2), 58
  local INK, INKL, GREEN = { 0.25, 0.18, 0.12 }, { 0.48, 0.40, 0.30 }, { 0.16, 0.38, 0.26 }
  lg.setColor(0.06, 0.08, 0.10, 0.6); lg.rectangle("fill", x + 3, y + 4, pw, ph, 8, 8)
  lg.setColor(0.13, 0.28, 0.21); lg.rectangle("fill", x - 2, y - 2, pw + 4, ph + 4, 9, 9)
  lg.setColor(0.90, 0.86, 0.74); lg.rectangle("fill", x + 2, y + 2, pw - 4, ph - 4, 6, 6)
  local function sel(rx, ry, rw, rh) lg.setColor(0.95, 0.80, 0.42, 0.75); lg.rectangle("fill", rx, ry, rw, rh, 3, 3) end
  if m.mode == "list" then
    UI.text("Choose a save", W / 2, y + 8, GREEN, 2, "center")
    for i = 1, 3 do
      local ry = y + 24 + (i - 1) * 40
      if i == m.sel then sel(x + 8, ry - 2, pw - 16, 38) end
      lg.setColor(0.80, 0.75, 0.62); lg.rectangle("line", x + 8.5, ry - 1.5, pw - 17, 37, 3, 3)
      local inf = m.info[i]
      UI.text(tostring(i), x + 18, ry + 10, INKL, 3)
      if inf then
        UI.text(inf.name, x + 40, ry + 3, INK, 2)
        UI.text((Wd.byId[inf.loc] and Wd.byId[inf.loc].name or ""), x + 40, ry + 18, INKL, 2)
        UI.coin(x + pw - 92, ry + 4)
        UI.text(inf.coins, x + pw - 80, ry + 3, INK, 2)
        UI.text(inf.caught .. " fish  " .. inf.mins .. " min", x + pw - 16, ry + 18, INKL, 2, "right")
      else
        UI.text("Empty - new game", x + 40, ry + 10, INKL, 2)
      end
    end
    local hints = { { "A", m.info[m.sel] and "Play" or "New game" }, { "B", "Back" } }
    if m.info[m.sel] then hints[#hints + 1] = { "X", "Delete" } end
    UI.hints(hints, W / 2, y + ph - 16, INK, "center")
  elseif m.mode == "name" then
    UI.text("Name for save " .. m.sel, W / 2, y + 8, GREEN, 2, "center")
    lg.setColor(0.98, 0.96, 0.90); lg.rectangle("fill", x + 60, y + 22, pw - 120, 16, 3, 3)
    local cur = (math.floor(st.titleT * 2) % 2 == 0) and "_" or " "
    UI.text(m.name .. (#m.name < NAME_MAX and cur or ""), W / 2, y + 26, INK, 2, "center")
    for r, row in ipairs(KEYS) do
      for c = 1, #row do
        local kx, ky = x + 30 + (c - 1) * 24, y + 46 + (r - 1) * 18
        if r == m.ky and c == m.kx then sel(kx - 2, ky - 3, 20, 15) end
        local ch = row:sub(c, c)
        UI.text(ch == " " and "_" or ch, kx + 8, ky, ch == " " and INKL or INK, 2, "center")
      end
    end
    local labels = { "Space", "Delete", "Done" }
    for c = 1, 3 do
      local kx, ky = x + 30 + (c - 1) * 80, y + 46 + #KEYS * 18 + 2
      if m.ky == #KEYS + 1 and m.kx == c then sel(kx - 4, ky - 3, 72, 15) end
      UI.text(labels[c], kx + 32, ky, c == 3 and GREEN or INK, 2, "center")
    end
    UI.hints({ { "A", "Type" }, { "B", "Erase" }, { "START", "Done" } }, W / 2, y + ph - 16, INK, "center")
  else
    local inf = m.info[m.sel]
    local name = inf and inf.name or ""
    if m.mode == "del1" then
      UI.text("Delete save " .. m.sel .. "?", W / 2, y + 30, { 0.66, 0.22, 0.16 }, 3, "center")
      UI.text(name, W / 2, y + 58, INK, 2, "center")
    else
      UI.text("Are you sure?", W / 2, y + 30, { 0.66, 0.22, 0.16 }, 3, "center")
      UI.text(name .. " will be gone for good.", W / 2, y + 58, INK, 2, "center")
    end
    local opts = { m.mode == "del1" and "Yes, delete" or "Delete forever", "No, keep it" }
    for k = 1, 2 do
      local ry = y + 84 + (k - 1) * 20
      if k == m.confirm then sel(x + 70, ry - 3, pw - 140, 16) end
      UI.text(opts[k], W / 2, ry, k == 1 and { 0.66, 0.22, 0.16 } or INK, 2, "center")
    end
    UI.hints({ { "A", "Choose" }, { "B", "Back" } }, W / 2, y + ph - 16, INK, "center")
  end
end

local function update(dt)
  -- the saving popup holds the buttons until it's done
  if st.saving then
    local sv = st.saving
    sv.t = sv.t + dt
    if not sv.done and sv.t >= 0.45 then saveGame(); sv.done = true; play("click") end
    if sv.t >= 1.05 then
      st.saving = nil
      if sv.kind == "title" then G.api.toTitle()
      elseif sv.kind == "quit" then love.event.quit() end
    end
    pressed = {}
  end
  st.time = st.time + dt
  lastInput = lastInput + dt
  local before = game.clock
  game.clock = (game.clock + dt / U.DAY_LENGTH) % 1
  if game.clock < before then game.dayN = (game.dayN or 0) + 1 end
  -- a fresh set of requests each morning (and when you arrive somewhere new before starting them)
  local d = game.daily
  local untouched = d and d.loc ~= game.loc and not (function() for _, r in ipairs(d.list) do if r.have > 0 or r.claimed then return true end end end)()
  if st.mode == "play" and (not d or d.day ~= (game.dayN or 0) or untouched) then GO.newDay(game, game.dayN or 0) end
  st.goalT = (st.goalT or 0) - dt
  if st.goalT <= 0 then
    st.goalT = 1
    for _, name in ipairs(GO.check(game)) do
      toast("Goal complete: " .. name .. "! Claim it in the tackle box.")
      play("catch", 1.2)
    end
  end
  game.playTime = (game.playTime or 0) + dt
  G.sky = Wd.sky(game.clock)
  G.boatX = st.boat.x
  G.lureInWater = (st.phase == "line" and st.lure.state ~= "fly") and st.lure or nil
  Wd.update(dt, st.time)
  TB.update(dt, (st.mode == "play" and not st.fade) and pressed or {})

  if st.fade then
    local fd = st.fade
    fd.t = fd.t + dt * 1.6 * fd.dir
    if fd.dir > 0 and fd.t >= 1 then
      if fd.go then enterPlace(fd.go); fd.go = nil end
      if fd.start then st.mode = "play"; fd.start = nil; toast(Wd.byId[game.loc].name) end
      if fd.title then
        -- back on the title: the save just left stays loaded behind it, ready to be picked again
        fd.title = nil
        G.lastSlot, G.slot = G.slot or G.lastSlot, nil
        st = newState()
        st.fade = fd
        G.cam.x = clamp(st.boat.x - W / 2, 0, WORLD_W - W)
        Audio.setMotor(0)
      end
      fd.dir = -1
    elseif fd.dir < 0 and fd.t <= 0 then
      st.fade = nil
    end
  end

  if st.mode == "title" then
    st.titleT = st.titleT + dt
    if st.slots then
      slotMenuUpdate()
    elseif (pressed.a or pressed.start) and not st.fade then
      if args.test and not args.slottest then
        st.fade = { t = 0, dir = 1, start = true }
        play("latch")
      else
        openSlots()
      end
    end
  end

  -- the trolling motor menu (on its own button, only with a motor fitted)
  if st.motorMenu then
    local m = st.motorMenu
    if pressed.up then m.sel = (m.sel - 2) % 3 + 1; play("blip") end
    if pressed.down then m.sel = m.sel % 3 + 1; play("blip") end
    if m.sel == 3 and (pressed.left or pressed.right) then
      -- trolling speed, five steps
      game.trollLvl = clamp((game.trollLvl or 3) + (pressed.left and -1 or 1), 1, 5)
      play("click")
    end
    if m.sel == 3 then
      if act("fast") or act("motor") or pressed.b or pressed.start or act("cast") or pressed.a then st.motorMenu = nil; play("blip") end
    elseif act("cast") or pressed.a then
      local on = m.sel == 1
      if on ~= (st.trolling or false) then
        st.trolling = on
        play("click")
        toast(on and "Trolling motor on. Your lure trails behind the boat." or "Trolling motor off.")
      end
      st.motorMenu = nil
    elseif act("fast") or act("motor") or pressed.b or pressed.start then st.motorMenu = nil; play("blip") end
    pressed = {}
  elseif st.mode == "play" and not TB.isOpen() and not st.fade and act("motor") then
    if GR.canTroll(game) then st.motorMenu = { sel = st.trolling and 2 or 1 }; play("blip")
    elseif hasTroll() then toast("This motor is steered by hand only.")
    else toast("Auto trolling needs the Auto Trolling Motor.") end
  end
  if TB.isOpen() and st.motorMenu then st.motorMenu = nil end
  local playing = st.mode == "play" and not TB.isOpen() and not st.fade and not st.motorMenu
  local ai = (playing and game.idle) and idleBrain(dt) or {}
  local inLeft = playing and (isDown("left") or ai.left)
  local inRight = playing and (isDown("right") or ai.right)
  local reel = playing and (isDown("up") or actDown("cast") or ai.reel)
  st.reeling = reel
  local fastReel = playing and actDown("fast")
  local letOut = playing and (isDown("down") or ai.down)

  if playing and (act("box") or pressed.start) then TB.open() end

  -- boat
  local b = st.boat
  local canMove = st.phase == "idle" and st.petting <= 0
  local dir = 0
  if canMove then
    if inLeft then dir = -1 elseif inRight then dir = 1 end
  end
  if dir ~= 0 and dir ~= b.face then b.face = dir end
  U.stepSpring(b.yaw, b.face > 0 and 0 or 180, 11, 6.2, dt)
  local aligned = math.abs(b.yaw.x - (b.face > 0 and 0 or 180)) < 25
  local spd = trollDrive() and GR.motor(game).speed or boatSpeed()
  local motor = game.boat ~= "rowboat" or trollDrive()
  if not GR.canTroll(game) then st.trolling = false end
  if dir ~= 0 and aligned then
    if motor then
      b.v = b.v + (dir * spd - b.v) * math.min(1, dt * 1.2)
    else
      b.rowT = b.rowT + dt * 1.25
      local ph = b.rowT % 1
      local thrust = ph > 0.45 and ph < 0.85 and math.sin((ph - 0.45) / 0.4 * math.pi) or 0
      b.v = b.v + dir * thrust * spd * 2.4 * dt
      if ph > 0.45 and not b.strokeHit then
        b.strokeHit = true
        play("oar", rr(0.9, 1.1))
        local ox = anglerPos() + (facingRight() and 1 or -1) * 16
        Wd.addRipple(ox, CUT_Y + 2, 10)
      elseif ph < 0.45 then b.strokeHit = false end
    end
    b.rowing = true
  else
    b.rowing = false
    b.rowT = 0
    if st.trolling then
      -- trolling: the motor pushes the boat along slowly the way it faces, even while you fish
      local ts = GR.motor(game).troll * (0.4 + 0.2 * (game.trollLvl or 3))
      if aligned then b.v = b.v + (b.face * ts - b.v) * math.min(1, dt * 0.8) end
    end
  end
  if not (st.trolling and dir == 0) then
    -- no thrust: the boat glides on and eases to a stop
    b.v = b.v * math.exp(-dt * (motor and (dir ~= 0 and 0.2 or 0.9) or 0.75))
    if math.abs(b.v) < 0.5 and dir == 0 then b.v = 0 end
  end
  b.x = b.x + b.v * dt
  if b.x < 70 then b.x = 70; b.v = 0 elseif b.x > WORLD_W - 70 then b.x = WORLD_W - 70; b.v = 0 end
  if st.trolling and (b.x <= 70 or b.x >= WORLD_W - 70) then
    st.trolling = false; toast("Trolling motor off: that's the end of the water.")
  end
  if (b.x <= 70 or b.x >= WORLD_W - 70) and dir ~= 0 and not st.edgeHint then
    st.edgeHint = true; toast("Open the map in your tackle box to travel.")
  elseif b.x > 120 and b.x < WORLD_W - 120 then st.edgeHint = false end
  local electric = trollDrive() or (st.trolling and dir == 0)
  if game.mute or st.mode ~= "play" then Audio.setMotor(0)
  elseif electric then
    -- an electric trolling motor: a soft, high hum
    local on = (b.rowing or st.trolling) and 1 or 0
    Audio.setMotor(on * (0.10 + math.abs(b.v) / 64 * 0.22), 1.7 + math.abs(b.v) / 64 * 0.5)
  elseif motor then Audio.setMotor(0.3 + math.abs(b.v) / spd, 0.8 + math.abs(b.v) / spd * 0.6)
  else Audio.setMotor(0) end
  b.wakeT = b.wakeT - dt
  if math.abs(b.v) > 6 and b.wakeT <= 0 then
    b.wakeT = motor and 0.12 or 0.25
    local stern = b.x - sign(b.v) * boatMeta().len * 0.45
    Wd.addRipple(stern, CUT_Y + rr(-2, 2), math.min(28, 8 + math.abs(b.v) * 0.25))
    if motor and math.abs(b.v) > 30 then Wd.addSplash(stern, CUT_Y, 2, 0.5) end
  end
  if math.abs(b.v) > 15 then Wd.spook(b.x, CUT_Y + 30, 70) end

  -- camera follows the boat, leading a little, and dips under water when fishing
  local cam = G.cam
  local lead = (facingRight() and 1 or -1) * 70
  if st.phase == "line" or st.phase == "fight" then lead = clamp(((st.lure.x + b.x) / 2 - b.x), -180, 180) end
  local tx = clamp(b.x + lead - W / 2, 0, WORLD_W - W)
  cam.x = cam.x + (tx - cam.x) * math.min(1, dt * 1.8)
  local wantY = 0
  if (st.phase == "line" and st.lure.state ~= "fly") or st.phase == "fight" then
    wantY = clamp(st.lure.y - CUT_Y + 60, 60, U.CAM_FISH)
    if st.phase == "fight" then wantY = clamp(st.lure.y - CUT_Y + 40, 30, U.CAM_FISH) end
  end
  if st.mode == "title" then wantY = 0 end
  st.camY = st.camY + (wantY - st.camY) * math.min(1, dt * 1.4)
  cam.y = fl(st.camY)

  -- fishing (the reel and drag sounds are set fresh each frame by whatever is happening)
  st.reelV, st.reelRate, st.dragV, st.dragSpeed = 0, 1, 0, 1
  if playing then
    if st.phase == "idle" and canMove and (math.abs(b.v) < 8 or (st.trolling and not b.rowing)) and aligned then
      if act("cast") then st.phase = "charge"; st.power, st.pdir = 0, 1 end
      if act("pet") then
        if petKind() ~= "none" then st.petting = 1.3; petEvent("pet") end
      end
    elseif st.phase == "charge" then
      st.power = st.power + st.pdir * dt * 1.1
      if st.power >= 1 then st.power, st.pdir = 1, -1 elseif st.power <= 0 then st.power, st.pdir = 0, 1 end
      if not actDown("cast") then startCast(st.power) end
      if act("fast") then st.phase = "idle" end
    elseif st.phase == "line" then
      local a = st.biter
      if a and a.bstate == "strike" and a.struck and (act("cast") or pressed.up or (game.idle and st.window <= 0)) then
        hookFish()
      else
        updateLine(dt, reel or fastReel, letOut, fastReel)
      end
    elseif st.phase == "fight" then
      updateFight(dt, reel)
    elseif st.phase == "landed" then
      if st.card and st.card.t > 0.6 then
        if act("cast") or ai.keep then keepFish()
        elseif act("fast") then releaseFish() end
      end
    end
  elseif st.phase == "line" and st.lure.state == "fly" then
    updateLine(dt, false, false, false)
  end
  Audio.setReel(game.mute and 0 or st.reelV, st.reelRate, dt)
  Audio.setDrag(game.mute and 0 or st.dragV, st.dragSpeed, dt)
  -- the reel handle turns as you wind; the spool turns back as the drag gives line
  st.reelSpin = (st.reelSpin or 0) + dt * 14 * st.reelV * st.reelRate
  st.spool = (st.spool or 0) - dt * 30 * st.dragV * st.dragSpeed
  if st.phase == "throw" or st.lure.state == "fly" then
    st.throwT = st.throwT + dt
    -- let go as the rod sweeps up past the vertical, so the lure sails up and out
    if st.lure.state == "hang" and (st.rodAng.x > -1.35 or st.throwT > 0.3) then releaseLure() end
  end
  if st.landed then
    local l = st.landed
    l.t = math.min(1, l.t + dt / 0.7)
    local u = U.easeOutCubic(l.t)
    l.x = lerp(l.x0, l.x1, u)
    l.y = lerp(l.y0, l.y1, u) - math.sin(math.pi * u) * 26
    l.phase = l.phase + dt * 10
  end
  if st.card then st.card.t = st.card.t + dt end

  -- rod: angle follows the pose, bend follows the strain
  local wantAng = -1.0
  if st.phase == "charge" then wantAng = -2.3 - st.power * 0.4
  elseif st.phase == "throw" then wantAng = -0.25
  elseif st.phase == "line" then wantAng = st.lure.state == "fly" and -0.5 or -0.7
  elseif st.phase == "fight" then wantAng = -1.15 + st.T * 0.35 end
  if st.phase == "landed" then wantAng = -1.3 end
  st.unstowT = math.max(0, (st.unstowT or 0) - dt)
  if st.unstowT > 0 then U.stepSpring(st.rodAng, wantAng, 260, 30, dt)
  else U.stepSpring(st.rodAng, wantAng, st.phase == "throw" and 260 or 60, st.phase == "throw" and 18 or 12, dt) end
  local wantBend = 0.12
  if st.phase == "fight" then wantBend = 0.35 + st.T * 0.9 + (st.thrash and math.sin(st.time * 22) * 0.06 or 0)
  elseif st.phase == "line" and st.lure.state ~= "fly" then wantBend = 0.2 + (reel and 0.12 or 0) end
  if st.twitch > 0 then st.rod.v = st.rod.v + st.twitch * 3; st.twitch = 0 end
  U.stepSpring(st.rod, wantBend, 120, 9, dt)
  -- the line
  do
    local tx, ty = rodTip()
    local lu = st.lure
    if not st.rope then st.rope = Rope.new(tx, ty, tx, ty + 18) end
    local wind = (G.wind or 1) * 6 + st.boat.v * -0.5
    local function surf(x) return Wd.surfaceY(x, st.time) end
    local current = Wd.flow()
    if lu.state == "hang" or st.phase == "landed" then
      -- reeled in: the lure sits snug under the rod tip
      lu.x, lu.y = tx, ty + 3
      st.lineOut = 3
      Rope.reset(st.rope, tx, ty, lu.x, lu.y)
    else
      -- how much line is out: it peels off during the cast, is taken up by reeling, let out with Down,
      -- and stays put otherwise, so slack forms and lies on the water just as it would
      local ax2, ay2 = lu.x, lu.y
      if st.bob and st.phase == "line" then ax2, ay2 = st.bob.x, CUT_Y + 1 + st.bob.dip end
      if st.bob and st.phase == "fight" then
        -- a hooked fish drags the float along, and pulls it under when it runs deeper than the stop
        local b = st.bob
        b.x = b.x + (lu.x - b.x) * math.min(1, dt * 4)
        b.y = math.max(CUT_Y + 1, lu.y - (game.bobDepth or 40))
        ax2, ay2 = b.x, b.y
      end
      local d = math.sqrt((ax2 - tx) ^ 2 + (ay2 - ty) ^ 2)
      local out = st.lineOut or d
      if lu.state == "fly" then
        out = math.max(out, d * 1.03 + 2)
      elseif st.phase == "fight" then
        local want = d * (st.reeling and (1 - 0.012 * st.T) or (1.0 + 0.04 * (1 - st.T)))
        out = out + (want - out) * math.min(1, dt * 6)
      else
        out = math.max(out, d)            -- the line's length is set in updateLine; it can't be shorter than the gap
      end
      st.lineOut = out
      Rope.update(st.rope, dt, tx, ty, ax2, ay2, out, surf, wind, st.time, current, st.phase == "fight" and st.T or 0)
    end
  end
  if st.phase == "throw" and st.throwT > 0.45 then st.phase = "line" end

  -- pose
  st.blinkT = st.blinkT - dt
  if st.blinkT <= 0 then st.blinkT = rr(2, 5.5) end
  local blink = st.blinkT < 0.13
  st.breathT = st.breathT + dt
  local breathe = (st.breathT % 3.2) > 1.6
  local pose = (breathe and "breathe" or "idle") .. (blink and "_blink" or "")
  if st.phase == "idle" and b.rowing and not motor then
    -- the arms follow the oar handles
    pose = rowPose(b.rowT % 1)
  elseif st.phase == "idle" and b.rowing and motor then pose = "steer"
  elseif st.phase == "charge" then pose = "windup"
  elseif st.phase == "throw" then pose = st.throwT < 0.3 and "throw" or "idle"
  elseif st.phase == "line" and st.lure.state == "fly" then pose = st.throwT < 0.35 and "throw" or "idle"
  elseif st.phase == "line" and reel then pose = (math.floor(st.time * 8) % 2 == 0) and "reel2" or "reel3"
  elseif st.phase == "line" and st.biter and st.biter.bstate then pose = "lean" .. (blink and "_blink" or "")
  elseif st.phase == "fight" then
    if reel then pose = (math.floor(st.time * 10) % 2 == 0) and "reel2" or "reel3" else pose = "lean" end
  elseif st.phase == "landed" then pose = (st.card and st.card.t > 0.5) and ("cheer" .. (blink and "_blink" or "")) or "throw"
  end
  if st.petting > 0 then st.petting = st.petting - dt; pose = "pet" end
  if not L.POSE[pose] then pose = "idle" end
  st.pose = pose
  -- the moment the oars or the tiller are let go, they're put away and the rod is pulled back up out of the
  -- boat in a quick sweep (quick enough that a cast straight after isn't held up)
  local stowedNow = pose:sub(1, 4) == "row_" or pose == "steer"
  if st.wasStowed and not stowedNow then st.rodAng.x, st.rodAng.v = -0.1, 0; st.unstowT = 0.25 end
  st.wasStowed = stowedNow

  -- pet
  local p = st.pet
  p.blinkT = p.blinkT - dt
  if p.blinkT <= 0 then p.blinkT = rr(2, 6); p.blink = 0.14 end
  p.blink = math.max(0, p.blink - dt)
  p.speak = math.max(0, p.speak - dt)
  p.happy = math.max(0, p.happy - dt)
  p.wagT = p.wagT - dt
  if p.wagT <= 0 then p.wagT = rr(3, 8); p.wag = rr(0.8, 1.6) end
  p.wag = math.max(0, p.wag - dt)
  local still = st.phase == "line" and not st.biter and math.abs(b.v) < 1
  p.sleepy = still and p.sleepy + dt or math.max(0, p.sleepy - dt * 4)
  if G.sky.night > 0.6 and math.abs(b.v) < 1 then p.sleepy = math.max(p.sleepy, 30) end
  p.chatT = p.chatT - dt
  if p.chatT <= 0 then
    p.chatT = rr(40, 90)
    if p.sleepy < 25 and st.mode == "play" then petEvent("hello") end
  end
  for i = #p.hearts, 1, -1 do
    local hh = p.hearts[i]
    hh.t = hh.t + dt
    if hh.t > 0 then hh.y = hh.y - dt * 12 end
    if hh.t > 1.2 then table.remove(p.hearts, i) end
  end
  if p.sleepy > 25 then
    st.zzT = (st.zzT or 0) - dt
    if st.zzT <= 0 then st.zzT = 1.4; p.zz[#p.zz + 1] = { x = 0, y = 0, t = 0 } end
  elseif #p.zz > 0 and p.sleepy < 20 then
    p.zz = {}          -- awake again: no stray Zs left floating
  end
  for i = #p.zz, 1, -1 do
    local z = p.zz[i]
    z.t = z.t + dt
    z.y = z.y - dt * 6
    z.x = math.sin(z.t * 2) * 2
    if z.t > 2 then table.remove(p.zz, i) end
  end

  st.toastT = math.max(0, st.toastT - dt)
  if st.depthT then st.depthT = math.max(0, st.depthT - dt) end
  Audio.musicOn = game.vol.music > 0
  Audio.setNight(G.sky.night, dt)
  local _, _, rainA = Wd.weatherAmounts()
  Audio.setWeather(rainA, Wd.loc == "frost", Wd.weather.storm)
end

---------------------------------------------------------------- drawing the boat, angler, pet, rod, line
-- a spinning reel under the rod, just ahead of the hand: cork grip, foot, body, spool, bail and a handle
-- that turns as you wind (st.reelSpin) and a spool that slips back as the drag gives line (st.spool)
drawReel = function(pts, cam, light)
  local hx, hy = pts[1][1] - cam.x, pts[1][2] - cam.y
  local ux, uy = pts[2][1] - pts[1][1], pts[2][2] - pts[1][2]
  local ul = math.sqrt(ux * ux + uy * uy) + 1e-6
  ux, uy = ux / ul, uy / ul
  local nx, ny = -uy, ux
  if ny < 0 then nx, ny = -nx, -ny end            -- the side of the rod that faces down
  local function C(r, g, b) lg.setColor(r * light[1], g * light[2], b * light[3]) end
  local function px(x, y) lg.rectangle("fill", fl(x), fl(y), 1, 1) end
  -- cork grip behind the hand and a little in front
  C(0.78, 0.62, 0.42)
  for k = -6, 1 do px(hx + ux * k, hy + uy * k) end
  C(0.18, 0.18, 0.20)
  px(hx - ux * 7, hy - uy * 7)                     -- butt cap
  -- reel seat and foot
  local sx, sy = hx + ux * 3, hy + uy * 3
  C(0.30, 0.30, 0.34)
  px(sx, sy); px(sx + ux, sy + uy)
  local bx, by = sx + nx * 2.2, sy + ny * 2.2      -- reel body centre, hanging under the rod
  px(sx + nx, sy + ny)
  -- body
  C(0.22, 0.23, 0.27)
  for i = -1, 1 do for j = -1, 1 do px(bx + ux * i + nx * j * 0.8, by + uy * i + ny * j * 0.8) end end
  -- spool (toward the tip) with a glint that shifts as it turns
  local spx, spy = bx + ux * 2.2, by + uy * 2.2
  C(0.68, 0.70, 0.74)
  for j = -1, 1 do px(spx + nx * j, spy + ny * j) end
  C(0.95, 0.96, 0.98)
  local g = math.floor((st.spool or 0) * 0.5) % 3 - 1
  px(spx + nx * g, spy + ny * g)
  -- bail arm over the spool
  C(0.82, 0.84, 0.88)
  px(spx + ux * 1 - nx * 1.4, spy + uy * 1 - ny * 1.4)
  -- the handle on the near side: an arm that sweeps round as you wind, with a knob
  local a = st.reelSpin or 0
  local ax, ay = bx - ux * 0.4, by - uy * 0.4
  local ex2 = ax + (ux * math.sin(a) * 0.6 + nx * math.cos(a)) * 2.6
  local ey2 = ay + (uy * math.sin(a) * 0.6 + ny * math.cos(a)) * 2.6
  C(0.55, 0.56, 0.60)
  lg.setLineWidth(1)
  lg.line(fl(ax) + 0.5, fl(ay) + 0.5, fl(ex2) + 0.5, fl(ey2) + 0.5)
  C(0.12, 0.12, 0.14)
  px(ex2, ey2)
  -- the line runs from the spool up along the rod to the tip
  lg.setColor(0.88, 0.90, 0.86, 0.35)
  local tip = pts[#pts]
  lg.line(fl(spx) + 0.5, fl(spy) + 0.5, fl(pts[3][1] - cam.x + nx * 0.6) + 0.5, fl(pts[3][2] - cam.y + ny * 0.6) + 0.5)
end

local function petFrame()
  local p = st.pet
  if p.sleepy > 25 then return (math.floor(st.time * 0.8) % 2 == 0) and 6 or 7 end
  if p.happy > 0 then return 5 end
  if p.speak > 0 then return 4 end
  if p.blink > 0 then return 3 end
  if p.wag > 0 then return (math.floor(st.time * 8) % 2 == 0) and 2 or 1 end
  return 1
end

local function drawOars(cam, light, front)
  local b = st.boat
  local c = math.cos(yawRad())
  if math.abs(c) < 0.5 or not b.rowing then return end   -- the oars are only out while rowing
  local dir = c > 0 and 1 or -1
  local baseY = boatY() - freeboard() - cam.y
  local ax = anglerPos()
  local lx, ly = ax - cam.x + 6 * dir, baseY - 1 + (front and 1 or -1)
  local x0, y0, x1, y1
  if b.rowing or math.abs(b.v) > 3 then
    -- a real stroke: the blade follows its path, and the handle sits in the rower's hands
    local ph = b.rowT % 1
    local bx, by = oarBlade(ph)
    x1, y1 = lx + dir * bx, ly + by
    local hx, hy = handPos()
    x0, y0 = hx - cam.x, hy - cam.y + (front and 0 or -1)
    if not front then x1 = x1 + dir * 2; y1 = y1 - 1 end
  else
    -- shipped: resting along the gunwale
    x0, y0 = lx + 14 * dir, ly - 3
    x1, y1 = lx - 36 * dir, ly + 4
  end
  local k = front and 1 or 0.7
  lg.setColor(0.20 * light[1] * k, 0.14 * light[2] * k, 0.10 * light[3] * k)
  lg.setLineWidth(1)
  lg.line(fl(x0) + 1.5, fl(y0) + 1.5, fl(x1) + 1.5, fl(y1) + 1.5)
  lg.line(fl(x0) + 0.5, fl(y0) + 1.5, fl(x1) + 0.5, fl(y1) + 1.5)
  lg.setColor(0.78 * light[1] * k, 0.60 * light[2] * k, 0.38 * light[3] * k)
  lg.line(fl(x0) + 0.5, fl(y0) + 0.5, fl(x1) + 0.5, fl(y1) + 0.5)
  lg.setColor(0.70 * light[1] * k, 0.52 * light[2] * k, 0.32 * light[3] * k)
  lg.rectangle("fill", fl(x1) - 3, fl(y1) - 1, 7, 3)
  local ph = b.rowT % 1
  if b.rowing and front and ph > 0.5 and ph < 0.85 and rnd() < 0.35 then
    Wd.addSplash(x1 + cam.x, CUT_Y, 1, 0.35)
  end
end

local function drawMotor(cam, light)
  local b = st.boat
  local c = math.cos(yawRad())
  if math.abs(c) < 0.25 then return end
  local dir = c > 0 and 1 or -1
  local bm = boatMeta()
  local sx = b.x - cam.x - bm.len * 0.43 * c - dir * 3
  local sy = boatY() - freeboard() - cam.y
  lg.setColor(0.18 * light[1], 0.19 * light[2], 0.22 * light[3])
  lg.rectangle("fill", fl(sx) - 5, fl(sy) - 15, 11, 13, 3, 3)
  lg.setColor(0.70 * light[1], 0.24 * light[2], 0.20 * light[3])
  lg.rectangle("fill", fl(sx) - 4, fl(sy) - 14, 9, 5, 2, 2)
  lg.setColor(0.30 * light[1], 0.31 * light[2], 0.34 * light[3])
  lg.rectangle("fill", fl(sx), fl(sy) - 2, 2, 18)
  if math.abs(b.v) > 8 then
    lg.setColor(1, 1, 1, 0.6)
    for i = 1, 4 do
      local bx = sx - dir * (2 + i * 3 + (st.time * 30 % 3))
      lg.rectangle("fill", fl(bx), fl(sy + 9 + math.sin(st.time * 20 + i) * 1.5), 1, 1)
    end
  end
end

-- an electric trolling motor: clamped to the rowboat's transom and steered by its tiller with one hand,
-- or on the bow of the bigger boats; a slim shaft down to a pod and prop under the water
local function drawTrollMotor(cam, light)
  local b = st.boat
  local c = math.cos(yawRad())
  if math.abs(c) < 0.25 then return end
  local dir = c > 0 and 1 or -1
  local bm = boatMeta()
  local transom = game.boat == "rowboat"
  local sx = b.x - cam.x + (transom and -bm.len * 0.45 * c - dir * 2 or bm.len * 0.42 * c)
  local sy = boatY() - freeboard() - cam.y
  local running = math.abs(b.v) > 2 and ((transom and b.rowing) or st.trolling)
  -- shaft and pod
  lg.setColor(0.14 * light[1], 0.14 * light[2], 0.15 * light[3])
  lg.rectangle("fill", fl(sx), fl(sy) - 8, 1, 22)
  lg.rectangle("fill", fl(sx) - 3, fl(sy) + 13, 7, 3, 1, 1)
  lg.setColor(0.30 * light[1], 0.30 * light[2], 0.32 * light[3])
  local blade = running and (math.floor(st.time * 24) % 2) or 0
  lg.rectangle("fill", fl(sx) - dir * 4 - (dir < 0 and 0 or 1), fl(sy) + 12 + blade, 1, 4 - blade * 2)
  -- the motor head, with the clamp on the gunwale
  lg.setColor(0.12 * light[1], 0.12 * light[2], 0.13 * light[3])
  lg.rectangle("fill", fl(sx) - 2, fl(sy) - 12, 5, 4, 1, 1)
  lg.setColor(0.36 * light[1], 0.36 * light[2], 0.38 * light[3])
  lg.rectangle("fill", fl(sx) - 1, fl(sy) - 3, 3, 2)
  if transom then
    -- the tiller handle: in the angler's hand while driving, otherwise tipped up out of the way
    local hx, hy
    if st.pose == "steer" then hx, hy = handPos(); hx = hx - cam.x; hy = hy - cam.y
    else hx, hy = sx + dir * 7, sy - 18 end
    lg.setColor(0.14 * light[1], 0.14 * light[2], 0.15 * light[3])
    lg.line(fl(sx) + 0.5, fl(sy) - 10 + 0.5, fl(hx) + 0.5, fl(hy) + 0.5)
    lg.setColor(0.30 * light[1], 0.30 * light[2], 0.32 * light[3])
    lg.rectangle("fill", fl(hx) - 1, fl(hy) - 1, 2, 2)
  end
  if running then
    lg.setColor(1, 1, 1, 0.5)
    for i = 1, 3 do
      local bx = sx - dir * (3 + i * 3 + (st.time * 20 % 3))
      lg.rectangle("fill", fl(bx), fl(sy + 14 + math.sin(st.time * 16 + i) * 1.2), 1, 1)
    end
  end
end

-- whatever is driving the boat
local function drawPower(cam, light)
  if game.boat ~= "rowboat" then drawMotor(cam, light) end
  if hasTroll() then drawTrollMotor(cam, light) else
    if game.boat == "rowboat" then drawOars(cam, light, true) end
  end
end

local function drawBoatSprite(cam, tint, alpha)
  local b = st.boat
  local bm = boatMeta()
  local frame = clamp(math.floor(b.yaw.x / 3.75 + 0.5), 0, 48) + 1
  local strip = U.grid("gfx/boat/" .. game.boat .. ".png", bm.w, bm.h, bm.cols, bm.frames)
  lg.setColor(tint[1], tint[2], tint[3], alpha or 1)
  U.drawStrip(strip, frame, b.x - cam.x - bm.ox, boatY() - freeboard() - cam.y - bm.oy)
end

local function drawLine(cam)
  if not st.rope then return end
  local sky = G.sky
  local lc = mix({ 0.92, 0.94, 0.96 }, { 1, 0.45, 0.35 }, clamp((st.T - 0.6) / 0.4, 0, 1))
  local light = math.max(0.5, sky.light)
  local above = { lc[1] * light, lc[2] * light, lc[3] * light, 0.75 }
  local below = { lc[1] * 0.8, lc[2] * 0.9, lc[3] * 0.95, 0.35 * math.max(0.6, sky.light) }
  Rope.draw(st.rope, cam, above, below, function(x) return Wd.surfaceY(x, st.time) end)
end

-- the bobber: a red-and-white float riding the surface, with the leader down to the bait below it
local function drawBobber(cam)
  if not hasBobber() then return end
  local lu = st.lure
  local light = G.sky.spr
  local bx, by, under
  if st.bob and (st.phase == "line" or st.phase == "fight") and lu.state ~= "fly" and lu.state ~= "hang" then
    local b = st.bob
    bx = b.x
    by = (st.phase == "fight" and b.y) or (Wd.surfaceY(b.x, st.time) + b.dip)
    -- leader from the float down to the bait
    lg.setColor(0.8 * light[1], 0.88 * light[2], 0.92 * light[3], 0.4)
    lg.line(fl(bx - cam.x) + 0.5, fl(by - cam.y + 3) + 0.5, fl(lu.x - cam.x) + 0.5, fl(lu.y - cam.y) + 0.5)
    under = by > Wd.surfaceY(b.x, st.time) + 3
    if st.depthT and st.depthT > 0 and st.phase == "line" then
      local ft = math.max(1, math.floor((game.bobDepth or 40) / PX_PER_FT + 0.5))
      UI.text("Depth " .. ft .. " ft", bx - cam.x, by - cam.y - 16, { 1, 1, 0.92, math.min(1, st.depthT * 2) }, 2, "center", { 0, 0, 0, 0.5 })
    end
  elseif lu.state == "fly" or lu.state == "hang" then
    bx, by = lu.x, lu.y - 7                        -- in the air the float rides just above the bait
  else
    return
  end
  local x, y = fl(bx - cam.x), fl(by - cam.y)
  local k = under and 0.55 or 1
  lg.setColor(0.97 * light[1] * k, 0.96 * light[2] * k, 0.92 * light[3] * k)
  lg.rectangle("fill", x - 2, y, 5, 3)
  lg.setColor(0.86 * light[1] * k, 0.18 * light[2] * k, 0.14 * light[3] * k)
  lg.rectangle("fill", x - 2, y - 3, 5, 3)
  lg.rectangle("fill", x - 1, y - 4, 3, 1)
  lg.setColor(0.2 * light[1], 0.2 * light[2], 0.2 * light[3])
  lg.rectangle("fill", x, y - 6, 1, 2)
  if not under and st.bob and lu.state ~= "fly" then
    lg.setColor(1, 1, 1, 0.25)
    lg.rectangle("fill", x - 4, y + 3, 9, 1)
  end
end

local function drawUnderLine(cam)
  local lu = st.lure
  if not (st.phase == "line" or st.phase == "fight") or lu.state == "fly" or lu.state == "hang" then return end
  local x1, y1 = lu.x - cam.x, lu.y - cam.y
  -- the lure
  if st.phase ~= "fight" or not st.biter then
    local tint = Wd.underTint(lu.y)
    lg.setColor(tint[1], tint[2], tint[3])
    local im = U.img("gfx/items/lure_" .. game.equip.lure .. ".png")
    if curLure().glow then
      lg.setColor(0.5, 1, 0.6, 0.25 + 0.15 * math.sin(st.time * 3))
      lg.circle("fill", fl(x1), fl(y1 + 6), 7)
      lg.setColor(1, 1, 1)
    end
    lg.draw(im, fl(x1 - 6), fl(y1))
    if st.lureSpeed and st.lureSpeed > 0 and math.sin(lu.spin * 2) > 0.3 then
      lg.setColor(1, 1, 0.9, 0.8)
      lg.rectangle("fill", fl(x1 - 2), fl(y1 + 2), 1, 1)
    end
  end
end

local function drawFish(cam)
  local tlist = {}
  for _, a in ipairs(Wd.fish) do tlist[#tlist + 1] = a end
  table.sort(tlist, function(p, q) return p.y > q.y end)
  for _, a in ipairs(tlist) do
    local sx, sy = a.x - cam.x, a.y - cam.y
    if not a.airborne and sx > -80 and sx < W + 80 and sy > CUT_Y - cam.y - 10 and sy < H + 40 then
      local tint = Wd.underTint(a.y)
      local amp = clamp((a.speed or 0) / 30, 0, 1.2)
      if a.hooked then amp = st.thrash and 1.4 or 0.6 end
      local curl = a.hooked and (st.thrash and math.sin(st.time * 7) * 0.6 or 0.2) or 0
      FD.draw(a.f, sx, sy, a.turn.x, a.phase, amp, tint, 1, curl, 1, a.turnT and a.turnT.x, not a.hooked and a.pitch or 0)
    end
  end
end

local function drawAnglerAndBoat(cam)
  local sky = G.sky
  local light = sky.spr
  local b = st.boat
  local bm = boatMeta()
  local c = math.cos(yawRad())
  local right = c >= 0
  local motor = game.boat ~= "rowboat" or hasTroll()
  local baseY = boatY() - freeboard() - cam.y
  if not motor then drawOars(cam, light, false) end
  drawBoatSprite(cam, light)
  do
    local cutS = CUT_Y - cam.y
    lg.push("all")
    lg.setScissor(0, math.max(0, cutS + 1), W, H)
    drawBoatSprite(cam, sky.uwTop, 0.55)
    lg.pop()
  end
  -- a lantern on a short pole at the stern, lit from dusk to dawn
  do
    local lx = fl(b.x - cam.x - 0.36 * bm.len * c)
    local ly = fl(baseY - 22)
    local glow = clamp((sky.night - 0.25) / 0.4, 0, 1)
    local flick = 0.9 + 0.1 * math.sin(st.time * 13) * math.sin(st.time * 7.3)
    if glow > 0 then
      -- warm light on the water around the boat and a shimmering reflection under it
      lg.setColor(1, 0.75, 0.4, 0.10 * glow * flick)
      lg.ellipse("fill", lx, CUT_Y - cam.y, 46, 6)
      for k = 0, 6 do
        local ry = CUT_Y - cam.y + 1 + k * 2
        lg.setColor(1, 0.78, 0.42, (0.45 - k * 0.06) * glow * flick)
        lg.rectangle("fill", fl(lx + math.sin(st.time * 3 + k * 1.7) * (1 + k * 0.6)) - 1, ry, 2 + (k % 2), 1)
      end
      lg.setColor(1, 0.8, 0.45, 0.16 * glow * flick)
      lg.circle("fill", lx, ly + 3, 16)
      lg.setColor(1, 0.85, 0.5, 0.28 * glow * flick)
      lg.circle("fill", lx, ly + 3, 7)
    end
    -- pole, hook and lantern
    lg.setColor(0.32 * light[1], 0.24 * light[2], 0.16 * light[3])
    lg.rectangle("fill", lx - 1, ly - 2, 1, baseY - ly + 4)
    lg.rectangle("fill", lx - 1, ly - 2, 3, 1)
    lg.setColor(0.18 * light[1], 0.18 * light[2], 0.2 * light[3])
    lg.rectangle("fill", lx, ly + 1, 3, 1)
    lg.rectangle("fill", lx, ly + 5, 3, 1)
    if glow > 0 then lg.setColor(1, 0.86 * flick, 0.5, 1) else lg.setColor(0.70 * light[1], 0.62 * light[2], 0.40 * light[3]) end
    lg.rectangle("fill", lx, ly + 2, 3, 3)
  end
  -- the pet sits at the bow
  local pk = petKind()
  local petx = b.x - cam.x + 0.2 * bm.len * c
  local function drawPet()
    if pk == "none" then return end
    local hop = st.pet.happy > 0 and -math.abs(math.sin(st.time * 9)) * 2 or 0
    -- sitting down inside the hull: the near gunwale hides its legs, like the angler's
    lg.push("all")
    lg.setScissor(0, 0, W, math.max(0, fl(baseY + 2)))
    L.drawPet(pk, game.look.coat, fl(petx - 16), fl(baseY - 20 + hop * 2), petFrame(), light, not right, 1, game.look.mark)
    lg.pop()
  end
  -- the angler sits low in the boat; the near gunwale hides their legs
  local ax, ay = anglerPos()
  local function drawAngler()
    lg.push("all")
    lg.setScissor(0, 0, W, math.max(0, fl(baseY + 1)))
    L.drawAngler(game.look, fl(ax - cam.x - L.FW / 2), fl(ay - cam.y), st.pose, light, not right)
    lg.pop()
  end
  if math.abs(c) < 0.4 then
    -- side-on to us during a turn: draw back to front by depth
    drawAngler(); drawPet()
  else
    drawPet(); drawAngler()
  end
  local stowed = st.pose:sub(1, 4) == "row_" or st.pose == "steer"
  st.stowed = stowed
  if stowed then
    local dir = right and 1 or -1
    local x0, y0 = ax - cam.x - 14 * dir, baseY - 2
    lg.setColor(0.36 * light[1], 0.26 * light[2], 0.17 * light[3])
    lg.line(fl(x0) + 0.5, fl(y0) + 0.5, fl(x0 + 34 * dir) + 0.5, fl(y0 - 6) + 0.5)
    drawPower(cam, light)
  else
  -- the rod
  local pts = rodPoints()
  lg.setLineWidth(1)
  for i = 1, #pts - 1 do
    local f = i / #pts
    local col = mix({ 0.32, 0.22, 0.14 }, { 0.62, 0.58, 0.50 }, f)
    lg.setColor(col[1] * light[1], col[2] * light[2], col[3] * light[3])
    lg.line(fl(pts[i][1] - cam.x) + 0.5, fl(pts[i][2] - cam.y) + 0.5, fl(pts[i + 1][1] - cam.x) + 0.5, fl(pts[i + 1][2] - cam.y) + 0.5)
  end
  drawReel(pts, cam, light)
  drawPower(cam, light)
  drawLine(cam)
  drawBobber(cam)
  -- lure hanging above water / in flight
  local lu = st.lure
  if lu.state == "hang" or lu.state == "fly" then
    lg.setColor(light[1], light[2], light[3])
    lg.draw(U.img("gfx/items/lure_" .. game.equip.lure .. ".png"), fl(lu.x - cam.x - 6), fl(lu.y - cam.y))
  end
  end
  -- a hooked fish leaping clear of the water
  local jb = st.biter
  if jb and jb.airborne then
    FD.draw(jb.f, jb.x - cam.x, jb.y - cam.y, jb.turn.x, jb.phase, 1.4, light, 1, math.sin(st.time * 18) * 0.8, 1, jb.turnT.x)
  end
  -- a landed fish swings up into the boat
  if st.landed then
    local l = st.landed
    FD.draw(l.f, l.x - cam.x, l.y - cam.y, right and -1 or 1, l.phase, 1.2, light, 1, math.sin(st.time * 12) * 0.5)
  end
  -- pet effects
  local p = st.pet
  for _, hh in ipairs(p.hearts) do
    if hh.t > 0 then
      local x, y = fl(petx + hh.x + math.sin(hh.t * 5) * 2), fl(baseY - 30 + hh.y)
      lg.setColor(0.95, 0.40, 0.48, 1 - hh.t / 1.2)
      lg.rectangle("fill", x, y, 2, 2); lg.rectangle("fill", x + 3, y, 2, 2); lg.rectangle("fill", x, y + 1, 5, 2); lg.rectangle("fill", x + 1, y + 3, 3, 1); lg.rectangle("fill", x + 2, y + 4, 1, 1)
    end
  end
  for _, z in ipairs(p.zz) do
    local hd = right and 1 or -1
    UI.text("z", petx + hd * 6 + z.x, baseY - 26 + z.y, { 1, 1, 1, math.min(1, 2 - z.t) * 0.8 }, z.t > 1 and 2 or 1)
  end
  -- the bite alert
  if st.biter and st.biter.struck and not game.idle then
    local tx2, ty2 = ax - cam.x, ay - cam.y - 16 - math.abs(math.sin(st.time * 12)) * 3
    UI.text("!", tx2, ty2, { 1, 0.95, 0.4 }, 3, "center", { 0.2, 0.1, 0, 0.8 })
  end
end

-- the hull below the waterline is seen through the water
local function drawHullUnderwater(cam)
  local cutS = CUT_Y - cam.y
  local sky = G.sky
  lg.push("all")
  lg.setScissor(0, math.max(0, cutS + 1), W, H)
  drawBoatSprite(cam, sky.uwTop, 0.55)
  lg.pop()
end

---------------------------------------------------------------- HUD
local function drawCard()
  local c = st.card
  if not c then return end
  local a = U.easeOutBack(clamp(c.t / 0.4, 0, 1))
  local cw, ch = 300, 150
  local x, y = W / 2 - cw / 2, 24 - (1 - a) * 200
  lg.setColor(0.06, 0.08, 0.10, 0.6); lg.rectangle("fill", x + 3, y + 4, cw, ch, 8, 8)
  lg.setColor(0.13, 0.28, 0.21); lg.rectangle("fill", x - 2, y - 2, cw + 4, ch + 4, 9, 9)
  lg.setColor(0.90, 0.86, 0.74); lg.rectangle("fill", x + 4, y + 4, cw - 8, ch - 8, 6, 6)
  local f = c.f
  local sc = math.min(2, 130 / f.fw, 70 / f.fh)
  sc = sc >= 1 and math.floor(sc) or sc
  local fx, fy = x + cw / 2 - f.fw * sc / 2, y + 52 - f.fh * sc / 2
  FD.icon(f, fx, fy, sc)
  UI.text(f.name, x + cw / 2, y + 12, { 0.16, 0.38, 0.26 }, 3, "center")
  UI.text(c.size .. " cm", x + 20, y + 94, { 0.25, 0.18, 0.12 }, 2)
  UI.coin(x + cw - 70, y + 95)
  UI.text(fishValue({ id = f.id, size = c.size }), x + cw - 58, y + 94, { 0.25, 0.18, 0.12 }, 2)
  if c.isNew then UI.text("New species!", x + cw / 2, y + 94, { 0.66, 0.22, 0.16 }, 2, "center")
  elseif c.best then UI.text("Personal best!", x + cw / 2, y + 94, { 0.66, 0.22, 0.16 }, 2, "center") end
  if c.t > 0.6 and not game.idle then
    local full = #game.cooler >= coolerCap()
    UI.hints({ { "A", full and "Cooler full" or "Keep" }, { "B", "Release" } }, x + cw / 2, y + ch - 26, { 0.25, 0.18, 0.12 }, "center")
  end
end

local function drawHUD()
  if st.mode ~= "play" then return end
  local open = TB.isOpen()
  if not open then
    UI.coin(10, 10)
    UI.text(game.coins, 22, 9, { 1, 0.95, 0.75 }, 2, nil, { 0, 0, 0, 0.55 })
    local cap = coolerCap()
    UI.text(#game.cooler .. "/" .. cap, W - 10, 9, #game.cooler >= cap and { 1, 0.6, 0.5 } or { 0.92, 0.96, 1 }, 2, "right", { 0, 0, 0, 0.55 })
    lg.setColor(0.9, 0.95, 1, 0.9)
    local w = UI.width(#game.cooler .. "/" .. cap, 2)
    lg.rectangle("fill", W - 10 - w - 16, 10, 12, 8, 2, 2)
    lg.setColor(0.35, 0.55, 0.75, 0.9)
    lg.rectangle("fill", W - 10 - w - 16, 10, 12, 3, 2, 2)
    if game.idle then UI.text("Idle fishing", W / 2, 9, { 0.9, 0.95, 1, 0.7 }, 2, "center", { 0, 0, 0, 0.4 }) end
  end
  -- charge meter
  if st.phase == "charge" then
    local ax, ay = anglerPos()
    local x, y = fl(ax - G.cam.x - 20), fl(ay - G.cam.y - 12)
    lg.setColor(0.05, 0.06, 0.08, 0.7); lg.rectangle("fill", x - 1, y - 1, 42, 6, 2, 2)
    local c = mix({ 0.5, 0.85, 0.5 }, { 1, 0.75, 0.3 }, st.power)
    lg.setColor(c); lg.rectangle("fill", x, y, fl(40 * st.power), 4, 2, 2)
  end
  -- tension: the line itself turns red, and a small gauge sits by the reel
  if st.phase == "fight" then
    local x, y = W / 2 - 60, H - 30
    lg.setColor(0.05, 0.06, 0.08, 0.6); lg.rectangle("fill", x - 2, y - 2, 124, 10, 3, 3)
    local c = mix({ 0.55, 0.85, 0.55 }, { 1, 0.35, 0.25 }, clamp(st.T, 0, 1))
    lg.setColor(c); lg.rectangle("fill", x, y, fl(120 * clamp(st.T, 0, 1)), 6, 2, 2)
    lg.setColor(1, 1, 1, 0.4); lg.rectangle("fill", x + 96, y - 1, 1, 8)
  end
  if st.trolling and not open then
    UI.text("Trolling", W / 2, game.idle and 21 or 9, { 0.75, 0.95, 0.85, 0.85 }, 2, "center", { 0, 0, 0, 0.45 })
  end
  -- the trolling motor menu
  if st.motorMenu and not open then
    local m = st.motorMenu
    local pw, ph = 196, 92
    local x, y = fl(W / 2 - pw / 2), 54
    lg.setColor(0.06, 0.08, 0.10, 0.6); lg.rectangle("fill", x + 3, y + 4, pw, ph, 8, 8)
    lg.setColor(0.13, 0.28, 0.21); lg.rectangle("fill", x - 2, y - 2, pw + 4, ph + 4, 9, 9)
    lg.setColor(0.90, 0.86, 0.74); lg.rectangle("fill", x + 2, y + 2, pw - 4, ph - 4, 6, 6)
    UI.text("Trolling motor", W / 2, y + 7, { 0.16, 0.38, 0.26 }, 2, "center")
    local rows = { "On - troll slowly", "Off" }
    for k, r in ipairs(rows) do
      local ry = y + 22 + (k - 1) * 15
      if k == m.sel then lg.setColor(0.95, 0.80, 0.42, 0.7); lg.rectangle("fill", x + 10, ry - 2, pw - 20, 14, 3, 3) end
      UI.text(r, W / 2, ry, { 0.25, 0.18, 0.12 }, 2, "center")
    end
    -- the speed setting: five steps, left and right to change
    do
      local ry = y + 54
      if m.sel == 3 then lg.setColor(0.95, 0.80, 0.42, 0.7); lg.rectangle("fill", x + 10, ry - 2, pw - 20, 14, 3, 3) end
      UI.text("Speed", x + 18, ry, { 0.25, 0.18, 0.12 }, 2)
      local lvl = game.trollLvl or 3
      local bx = x + 84
      if m.sel == 3 then UI.text("<", bx - 10, ry, { 0.25, 0.18, 0.12 }, 2); UI.text(">", bx + 78, ry, { 0.25, 0.18, 0.12 }, 2) end
      for n = 1, 5 do
        local on = n <= lvl
        if on then lg.setColor(0.16, 0.38, 0.26) else lg.setColor(0.48, 0.40, 0.30, 0.3) end
        local bh = 4 + n * 1.2
        lg.rectangle("fill", bx + (n - 1) * 14, ry + 10 - bh, 10, bh, 1, 1)
      end
    end
    UI.hints({ { "A", "Choose" }, { "B", "Back" } }, W / 2, y + ph - 16, { 0.25, 0.18, 0.12 }, "center")
  end
  if st.toastT > 0 and st.toast then
    local a = math.min(1, st.toastT * 2, (3.2 - st.toastT) * 4)
    local yy = open and H - 12 or 30
    UI.text(st.toast, W / 2, yy, { 1, 1, 0.92, a }, 2, "center", { 0, 0, 0, a * 0.6 })
  end
  -- quiet hints that fade after a while without input
  if not open and not st.card and not game.idle then
    local hints
    if st.phase == "idle" then
      hints = { { "A", "Cast" }, { "<>", "Move" }, { "START", "Tackle box" } }
      if petKind() ~= "none" then table.insert(hints, 3, { "X", "Pet" }) end
    elseif st.phase == "charge" then hints = { { "A", "Release to cast" } }
    elseif st.phase == "line" then
      hints = st.biter and st.biter.struck and { { "A", "Strike!" } } or
        (st.bob and { { "A", "Reel" }, { "UP/DOWN", "Depth" }, { "B", "Reel fast" } }) or { { "A", "Reel" }, { "DOWN", "Let out" }, { "B", "Reel fast" } }
      if hints[2] and GR.canTroll(game) then hints[#hints + 1] = { string.upper(game.binds.motor or "y"), "Motor" } end
    elseif st.phase == "fight" then hints = { { "A", "Reel - ease off when it pulls" } } end
    local a = clamp(1 - (lastInput - 6) / 2, 0.0, 1)
    if st.phase == "fight" or (st.biter and st.biter.struck) then a = 1 end
    if hints and a > 0 then
      lg.push("all")
      UI.hints(hints, W / 2, H - 16, { 1, 1, 1, a }, "center")
      lg.pop()
    end
  end
end

local function drawTitle()
  if st.mode ~= "title" then return end
  if st.slots then
    local t = st.titleT
    local a = clamp(t / 1.2, 0, 1)
    UI.text("Gone Fishing", W / 2, 22, { 1, 0.97, 0.88, a }, 5, "center", { 0.18, 0.12, 0.22, a })
    G.drawSlots()
    return
  end
  local t = st.titleT
  local a = clamp(t / 1.2, 0, 1)
  local y = 70 + math.sin(t * 0.9) * 2
  UI.text("Gone Fishing", W / 2 + 2, y + 3, { 0.05, 0.08, 0.12, 0.5 * a }, 8, "center")
  UI.text("Gone Fishing", W / 2, y, { 1, 0.97, 0.88, a }, 8, "center", { 0.18, 0.12, 0.22, a })
  if t > 1.2 and (t % 1.4) < 1.0 and not args.covers then
    UI.text("Press A", W / 2, 150, { 1, 1, 1, 0.9 }, 2, "center", { 0, 0, 0, 0.5 })
  end
  if not args.covers then UI.text("v" .. G.VERSION, W - 6, H - 14, { 1, 1, 1, 0.55 * a }, 2, "right", { 0, 0, 0, 0.35 * a }) end
end

---------------------------------------------------------------- render
local function render()
  lg.setCanvas(canvas)
  lg.clear(0, 0, 0, 1)
  local cam = G.cam
  local t = st.time
  Wd.drawBack(t, game.clock, cam)
  Wd.drawUnder(t, cam)
  Wd.drawWildlife(cam, t)
  drawFish(cam)
  drawUnderLine(cam)
  Wd.drawMurk(cam)
  drawAnglerAndBoat(cam)
  Wd.drawSurface(t, cam)
  Wd.drawFront(t, cam)
  drawCard()
  drawHUD()
  drawTitle()
  TB.draw(t)
  if st.saving then
    -- a small card with a bobbing float: "Saving..." then "Saved!"
    local sv = st.saving
    local a = math.min(1, sv.t / 0.12, (1.05 - sv.t) / 0.12)
    local pw, ph = 150, 44
    local x, y = fl(W / 2 - pw / 2), fl(H / 2 - ph / 2)
    lg.setColor(0.06, 0.08, 0.10, 0.6 * a); lg.rectangle("fill", x + 3, y + 4, pw, ph, 8, 8)
    lg.setColor(0.13, 0.28, 0.21, a); lg.rectangle("fill", x - 2, y - 2, pw + 4, ph + 4, 9, 9)
    lg.setColor(0.90, 0.86, 0.74, a); lg.rectangle("fill", x + 2, y + 2, pw - 4, ph - 4, 6, 6)
    local bx, by = x + 26, y + 22 + (sv.done and 0 or math.sin(sv.t * 14) * 2)
    lg.setColor(0.45, 0.62, 0.78, 0.5 * a); lg.ellipse("line", bx, y + 30, 9 + (sv.t * 10 % 4), 2)
    lg.setColor(0.25, 0.18, 0.12, a); lg.rectangle("fill", bx - 0.5, by - 12, 1, 5)
    lg.setColor(0.86, 0.22, 0.18, a); lg.circle("fill", bx, by - 3, 5)
    lg.setColor(0.97, 0.95, 0.90, a); lg.arc("fill", bx, by - 3, 5, 0, math.pi)
    local label = sv.done and "Saved!" or ("Saving" .. string.rep(".", 1 + math.floor(sv.t * 8) % 3))
    UI.text(label, x + 44, y + 16, sv.done and { 0.16, 0.38, 0.26, a } or { 0.25, 0.18, 0.12, a }, 2)
  end
  if st.fade then
    lg.setColor(0.02, 0.02, 0.04, clamp(st.fade.t, 0, 1))
    lg.rectangle("fill", 0, 0, W, H)
  end
  lg.setCanvas()
end

---------------------------------------------------------------- love callbacks
-- Fit the 512x384 picture to any screen. Exact multiples (like the Brick's 2x) are drawn
-- pixel for pixel; other sizes use "sharp bilinear": scale up by a whole number with crisp
-- pixels, then smoothly down to the exact fit, so pixels stay sharp without uneven rows.
local bigCanvas, bigK, exact
local function computeScale()
  local ww, wh = lg.getDimensions()
  local s = math.min(ww / W, wh / H)
  exact = math.abs(s - math.floor(s + 0.5)) < 0.01 and s >= 1
  if exact then s = math.floor(s + 0.5) end
  scale = s
  offX, offY = math.floor((ww - W * s) / 2 + 0.5), math.floor((wh - H * s) / 2 + 0.5)
  bigK = math.max(1, math.ceil(s))
  if bigCanvas then bigCanvas:release(); bigCanvas = nil end
  if not exact then
    bigCanvas = lg.newCanvas(W * bigK, H * bigK, { dpiscale = 1 })
    bigCanvas:setFilter("linear", "linear")
  end
end

local runTest

function love.load(a)
  for _, v in ipairs(a or {}) do
    if v == "--fullscreen" then args.fullscreen = true end
    if v == "--gamepad" then args.gamepad = true end
    if v == "--test" then args.test = true end
    local sw, sh = v:match("^%-%-size=(%d+)x(%d+)$")
    if sw then args.size = { tonumber(sw), tonumber(sh) } end
    if v == "--snap" then args.snap = 2.5 end
    if v == "--covers" then args.test, args.covers = true, true end
    if v == "--features" then args.test, args.features = true, true end
    if v == "--slottest" then args.test, args.slottest = true, true end
    if v == "--casttest" then args.test, args.casttest = true, true end
    if v == "--phystest" then args.test, args.phystest = true, true end
    if v == "--idletest" then args.test, args.idletest = true, true end
    if v == "--compattest" then args.test, args.slottest, args.compattest = true, true, true end
    local sl, sc, sx = v:match("^%-%-scene=(%a+),([%d.]+),(%d+)$")
    if sl then args.test, args.scene = true, { sl, tonumber(sc), tonumber(sx) } end
    if v == "--video" then args.test, args.video = true, true end
  end
  lg.setDefaultFilter("nearest", "nearest")
  lg.setLineStyle("rough")
  if args.fullscreen then love.window.setFullscreen(true, "desktop") end
  if args.size then love.window.setMode(args.size[1], args.size[2], { resizable = true }) end
  pcall(love.mouse.setVisible, false)
  computeScale()
  canvas = lg.newCanvas(W, H, { dpiscale = 1 })
  UI.load()
  L.load()
  FD.load(FISH)
  G.BOATS = love.filesystem.load("gfx/boat/boats.lua")()
  Audio.load()
  Audio.loadRecorded()
  if not args.test or args.slottest then migrateSlots() end
  G.loadPrefs()
  -- the title screen shows the place from the last slot played
  local last = tonumber(love.filesystem.read("slot.txt") or "") or 1
  G.lastSlot = clamp(last, 1, 3)
  game = (args.test and not args.slottest) and defaults() or loadGame(G.lastSlot)
  if not game.vol then game.vol = { master = game.mute and 0 or 10, music = game.music == false and 0 or 10, sfx = 10, amb = 10 } end
  GR.migrate(game); GR.sync(game); GO.init(game)
  G.game = game
  G.cam = { x = 0, y = 0 }
  st = newState()
  G.cam.x = clamp(st.boat.x - W / 2, 0, WORLD_W - W)
  Wd.picker = pickFish
  enterPlace(game.loc)
  applyVolume()
  if args.test then return runTest() end
  Audio.start()
end

function love.resize() computeScale() end

local saveT = 0
function love.update(dt)
  if args.snap then
    args.snap = args.snap - dt
    if args.snap <= 0 then
      args.snap = nil
      lg.captureScreenshot(function(img)
        img:encode("png", "snap_" .. lg.getWidth() .. "x" .. lg.getHeight() .. ".png")
        love.event.quit()
      end)
    end
  end
  update(math.min(dt, 0.1))
  pressed = {}
  saveT = saveT + dt
  if saveT > 30 and st.mode == "play" then saveT = 0; saveGame() end
end

function love.draw()
  render()
  lg.clear(0, 0, 0, 1)
  lg.setColor(1, 1, 1)
  if exact or not bigCanvas then
    lg.draw(canvas, offX, offY, 0, scale, scale)
  else
    lg.setCanvas(bigCanvas)
    lg.clear(0, 0, 0, 1)
    lg.draw(canvas, 0, 0, 0, bigK, bigK)
    lg.setCanvas()
    lg.draw(bigCanvas, offX, offY, 0, scale / bigK, scale / bigK)
  end
end

function love.focus(f) if not f then saveGame() end end
function love.quit() saveGame() end

---------------------------------------------------------------- self-test (--test)
function runTest()
  io.stdout:setvbuf("no")
  local big = lg.newCanvas(W * 2, H * 2, { dpiscale = 1 })
  local function shot(name)
    render()
    lg.setCanvas(big)
    lg.clear(0, 0, 0, 1)
    lg.setColor(1, 1, 1)
    lg.draw(canvas, 0, 0, 0, 2, 2)
    lg.setCanvas()
    big:newImageData():encode("png", name .. ".png")
  end
  local function sim(seconds, each)
    for _ = 1, math.floor(seconds * 30) do
      if each then each() end
      update(1 / 30); pressed = {}
    end
  end
  local function go(loc, clock, weather)
    game.loc = loc; game.unlocked[loc] = true
    st = newState()
    st.mode = "play"
    game.clock = clock
    G.sky = Wd.sky(clock)
    enterPlace(loc)
    Wd.setWeather(weather or "clear", true)
    Wd.weather.timer = 9999
    G.sky = Wd.sky(clock)
    G.cam.x = clamp(st.boat.x + 70 - W / 2, 0, WORLD_W - W)
    st.toastT = 0
  end
  local function forceBiter()
    local a
    for _, f in ipairs(Wd.fish) do if not f.controlled then a = f; break end end
    if not a then return end
    a.x, a.y = st.lure.x - 60, clamp(st.lure.y + 10, CUT_Y + 12, Wd.bedY(st.lure.x) - 10)
    st.biter = a
    a.controlled = true
    a.bstate, a.bt, a.nibbles, a.forced = "approach", 0, 1, true
  end
  local function castOut(power, sinkSecs)
    startCast(power); sim(1.4)
    testHold.down = true; sim(sinkSecs or 1.5); testHold.down = false
  end

  if args.video then
    -- a trailer: every frame saved as a PNG, every sound logged so it can be mixed in sync afterwards
    love.filesystem.createDirectory("vid")
    local n, fadeLen = 0, 10
    local log = {}
    Audio.trace = {}
    local function rec(seconds, each, fin, fout)
      local frames = math.floor(seconds * 30 + 0.5)
      for i = 1, frames do
        if each then each() end
        Audio.frame = n + 1
        update(1 / 30); pressed = {}
        render()
        local fade = 1
        if fin then fade = math.min(fade, i / fadeLen) end
        if fout then fade = math.min(fade, (frames - i) / fadeLen) end
        if fade < 1 then
          lg.setCanvas(canvas); lg.setColor(0, 0, 0, 1 - math.max(0, fade)); lg.rectangle("fill", 0, 0, W, H); lg.setCanvas()
        end
        n = n + 1
        canvas:newImageData():encode("png", string.format("vid/f%05d.png", n))
        if os.getenv("VDBG") and n % 15 == 0 then print(n, st.mode, st.phase, fl(st.boat.x), st.fade and "fade" or "-", TB.isOpen(), st.petting, testHold.right) end
        local snap = Audio.snapshot()
        snap.fade = math.max(0, fade)
        log[n] = snap
      end
    end
    local function waitBite(each)
      forceBiter()
      local guard = 0
      while not (st.biter and st.biter.struck) and guard < 120 do rec(1 / 15, each); guard = guard + 1 end
      rec(0.25); pressed.a = true; rec(1 / 30)
    end
    local function fight(maxs)
      local t = 0
      rec(maxs, function() t = t + 1 / 30; testHold.a = (st.phase == "fight") and st.T < 0.6 end)
      testHold.a = false
    end
    local function settle()
      local g = 0
      while math.abs(st.boat.v) >= 7 and g < 150 do rec(1 / 30); g = g + 1 end
      rec(0.3)
    end
    local function scene(loc, clock, weather)
      go(loc, clock, weather)
      sim(0.6)
    end
    game.look = L.normalize({ hat = 2, hatc = 4, hair = 2, hairc = 2, face = 2, skin = 2, top = 2, topc = 2, pants = 1, pet = 2, coat = 1 })
    game.rod, game.line = 3, 3
    GR.sync(game)
    game.coins = 1460

    -- 1. title
    game.loc = "lake"; st = newState(); game.clock = 0.42
    enterPlace("lake"); Wd.setWeather("clear", true); Wd.weather.timer = 9999; G.sky = Wd.sky(0.42)
    sim(0.3)
    rec(4.0, nil, true)
    pressed.a = true; rec(2.0)
    -- 2. row out, let go (the oars go away, the rod comes back out), cast, a bite, the fight, the catch
    testHold.right = true; rec(2.6); testHold.right = false
    settle()
    pressed.a = true; testHold.a = true; rec(0.7); testHold.a = false
    rec(1.3)
    testHold.down = true; rec(1.4); testHold.down = false
    rec(0.4)
    waitBite()
    fight(9)
    rec(2.4)
    pressed.a = true; rec(0.8)
    pressed.x = true; rec(1.8)
    -- 3. the tackle box: buy the Auto Trolling Motor, dress up (the preview zooms in), the new sound settings
    game.coins = 2460
    game.cooler = { { id = "trout", size = 52 }, { id = "bluegill", size = 18 }, { id = "pike", size = 96 }, { id = "perch", size = 22 }, { id = "bass", size = 41 } }
    game.owned.lure.spinner = true; game.owned.lure.spoon = true; game.owned.lure.plug = true; game.owned.rod[2] = true
    game.ach.first = "done"
    pressed.start = true; rec(2.2)
    pressed.a = true; rec(0.6)                              -- the cooler
    pressed.x = true; rec(1.0)                              -- sell everything
    TB.setTab(2); rec(0.8)                                  -- the shop
    pressed.a = true; rec(0.3)
    for _ = 1, 6 do pressed.right = true; rec(0.45) end    -- through to Motors
    rec(0.6)
    pressed.down = true; rec(0.5); pressed.down = true; rec(0.9)
    pressed.a = true; rec(1.6)                              -- buy the Auto Trolling Motor
    TB.setTab(7); rec(0.8)                                  -- Look
    pressed.a = true; rec(0.8)
    for _ = 1, 3 do pressed.down = true; rec(0.25) end     -- hair: zooms to the head
    rec(0.4)
    for _ = 1, 4 do pressed.right = true; rec(0.45) end
    for _ = 1, 3 do pressed.down = true; rec(0.25) end     -- headwear
    rec(0.3)
    for _ = 1, 3 do pressed.right = true; rec(0.45) end
    for _ = 1, 9 do pressed.down = true; rec(0.18) end     -- boots: zooms to the feet
    rec(0.6)
    pressed.down = true; rec(0.6)                           -- companion: zooms to the dog
    for _ = 1, 2 do pressed.right = true; rec(0.8) end
    pressed.left = true; rec(0.3); pressed.left = true; rec(0.8)
    TB.setTab(8); rec(0.6)                                  -- Settings
    pressed.a = true; rec(0.3)
    for _ = 1, 3 do pressed.down = true; rec(0.35) end
    rec(0.8)
    pressed.start = true; rec(1.2, nil, nil, true)
    TB.close()
    -- 4. the Columbia at Hood River: Mt. Hood, the bridge, driving with the trolling motor, then trolling
    scene("columbia", 0.40, "clear")
    st.boat.x = 1330; st.boat.face = -1; st.boat.yaw.x = 180; G.cam.x = clamp(st.boat.x - 70 - W / 2, 0, WORLD_W - W)
    sim(1.0)
    rec(2.6, nil, true)
    testHold.left = true; rec(8.5); testHold.left = false
    settle()
    pressed.y = true; rec(0.8)                              -- the trolling menu
    pressed.down = true; rec(0.3); pressed.down = true; rec(0.5)
    pressed.right = true; rec(0.5)
    pressed.up = true; rec(0.3); pressed.up = true; rec(0.5)
    pressed.a = true; rec(1.2)                              -- trolling on
    pressed.a = true; testHold.a = true; rec(0.6); testHold.a = false
    rec(1.2)
    testHold.down = true; rec(1.8); testHold.down = false
    rec(3.0)
    waitBite()
    fight(8)
    rec(2.0)
    pressed.a = true; rec(0.8, nil, nil, true)
    scene("columbia", 0.74, "clear")
    st.boat.x = 760; G.cam.x = clamp(st.boat.x + 70 - W / 2, 0, WORLD_W - W); sim(1)
    rec(3.5, nil, true, true)
    scene("columbia", 0.96, "clear")
    st.boat.x = 700; G.cam.x = clamp(st.boat.x + 70 - W / 2, 0, WORLD_W - W); sim(1)
    rec(3.0, nil, true, true)
    -- 5. the other places
    scene("river", 0.45, "rain")
    rec(3.0, nil, true, true)
    scene("coast", 0.74, "clear")
    rec(3.0, nil, true, true)
    scene("frost", 0.04, "clear")
    rec(3.0, nil, true, true)
    scene("lake", 0.95, "clear")
    game.look.pet = 3; game.look.coat = 5
    rec(1.2, nil, true); pressed.x = true; rec(2.8, nil, nil, true)
    -- 6. back to the title at sunset
    game.loc = "lake"; st = newState(); game.clock = 0.75
    enterPlace("lake"); Wd.setWeather("clear", true); Wd.weather.timer = 9999; G.sky = Wd.sky(0.75)
    sim(2)
    rec(5, nil, true, true)

    -- the sound log as a Lua table, plus the synthesized sounds as raw 16-bit mono at 22050 Hz
    local out = { "return { frames = " .. n .. ", events = {" }
    for _, e in ipairs(Audio.trace) do
      out[#out + 1] = string.format("{f=%d,name=%q,idx=%s,pitch=%.3f,vol=%.3f},", e.f or 0, e.name, tostring(e.idx or "nil"), e.pitch, e.vol)
    end
    out[#out + 1] = "}, loops = {"
    for i = 1, n do
      local l = log[i]
      out[#out + 1] = string.format("{place=%q,water=%.3f,amb=%.3f,crickets=%.3f,wind=%.3f,rainLight=%.3f,rainStorm=%.3f,motor=%.3f,mp=%.3f,sw=%.3f,crank=%.3f,cp=%.3f,drag=%.3f,dp=%.3f,fade=%.3f},",
        l.place or "lake", l.water, l.amb, l.crickets, l.wind, l.rainLight, l.rainStorm, l.motor, l.motorPitch, l.synthWater,
        l.crank, l.crankPitch, l.drag, l.dragPitch, l.fade)
    end
    out[#out + 1] = "} }"
    love.filesystem.write("vid/sound.lua", table.concat(out, "\n"))
    love.filesystem.createDirectory("vid/raw")
    for name, src in pairs(Audio.sfx) do
      local sd = Audio.sdOf[src]
      if sd then love.filesystem.write("vid/raw/" .. name .. ".raw", sd:getString()) end
    end
    for _, k in ipairs({ "crickets", "wind", "motor", "water" }) do
      local sd = Audio.sdOf[Audio[k]]
      if sd then love.filesystem.write("vid/raw/loop_" .. k .. ".raw", sd:getString()) end
    end
    print("VIDEO frames: " .. n)
    love.event.quit(); return
  end
  if args.scene then
    local l, c, x = args.scene[1], args.scene[2], args.scene[3]
    go(l, c, "clear")
    st.boat.x = x
    G.cam.x = clamp(x + 70 - W / 2, 0, WORLD_W - W)
    sim(2)
    shot(string.format("scene_%s_%d_%d", l, math.floor(c * 100), x))
    love.event.quit(); return
  end
  if args.idletest then
    for _, loc in ipairs({ "lake", "river", "coast", "frost", "columbia" }) do
      go(loc, 0.45, "clear"); game.idle = true; game.cooler = {}
      local c0 = game.catches or 0
      local bites, wasStruck = 0, false
      sim(120, function()
        local s2 = st.biter and st.biter.struck
        if s2 and not wasStruck then bites = bites + 1 end
        wasStruck = s2
      end)
      print(string.format("IDLE %-9s 120s: bites %d, catches %d", loc, bites, (game.catches or 0) - c0))
    end
    love.event.quit(); return
  end
  if args.compattest then
    -- an old save (v1.0: one save.lua, no motors, bobbers, volumes or slots) must load and play
    game = loadGame(1); G.game = game; G.slot = 1
    print("COMPAT coins", game.coins, "loc", game.loc, "rod", game.equip.rod, "lure", game.equip.lure,
      "motor", game.equip.motor, "bobber", game.equip.bobber, "owned.bobber", game.owned.bobber and "yes" or "no",
      "vol", game.vol and game.vol.master or "nil", "binds.motor", game.binds.motor, "name", tostring(game.name))
    st = newState(); st.mode = "play"; enterPlace(game.loc); applyVolume()
    sim(1)
    pressed.start = true; sim(1.4)
    for tab = 1, 8 do TB.setTab(tab); sim(0.2); pressed.a = true; sim(0.1)
      for _ = 1, 8 do pressed.right = true; sim(0.05) end
      pressed.b = true; sim(0.1)
    end
    TB.close(); sim(1)
    startCast(0.6); sim(3); testHold.down = true; sim(1); testHold.down = false
    testHold.a = true; sim(2); testHold.a = false
    saveGame()
    print("COMPAT ok; saved slot 1:", love.filesystem.getInfo("save1.lua") and "yes" or "no")
    love.event.quit(); return
  end
  if args.phystest then
    go("lake", 0.45, "clear")
    local function castWith(pw)
      st.phase = "idle"; st.lure.state = "hang"; st.biter = nil; st.bob = nil
      st.boat.x, st.boat.v = 900, 0; sim(0.4)
      startCast(pw)
      local t = 0
      while st.lure.state == "fly" or st.lure.state == "hang" do
        sim(1 / 30); t = t + 1 / 30
        if os.getenv("PDBG") and math.floor(t * 30) % 5 == 0 then print(string.format("t=%.2f phase=%s state=%s x=%d y=%d throwT=%.2f ang=%.2f mode=%s", t, st.phase, st.lure.state, st.lure.x - st.boat.x, st.lure.y - CUT_Y, st.throwT or -1, st.rodAng.x, st.mode)) end
        if t > 6 then break end
      end
      return math.abs(st.lure.x - st.boat.x), t
    end
    for _, id in ipairs({ "worm", "spinner", "jig", "popper", "fly", "plug" }) do
      game.owned.lure[id] = true; game.equip.lure = id
      local r = {}
      for _, pw in ipairs({ 0, 0.5, 1 }) do local d = castWith(pw); r[#r + 1] = math.floor(d) end
      print(string.format("CAST %-8s power 0/0.5/1 -> %d / %d / %d px", id, r[1], r[2], r[3]))
    end
    -- sinking: a jig with the line held, then letting out, then reeling a little
    game.equip.lure = "jig"
    castWith(0.6)
    local function depth() return math.floor(st.lure.y - CUT_Y) end
    local log = {}
    for k = 1, 8 do sim(0.5); log[#log + 1] = depth() .. "@" .. math.floor(st.lure.x - st.boat.x) end
    print("HOLD  depth@x every 0.5s: " .. table.concat(log, " "))
    shot("p01_jig_held")
    testHold.down = true; sim(1.5); testHold.down = false; sim(1.0)
    print("LET OUT 1.5s -> depth " .. depth() .. "  lineOut " .. math.floor(st.lineOut))
    shot("p02_jig_let_out")
    local d0 = depth(); sim(2); print("held 2s more -> depth " .. depth() .. " (was " .. d0 .. ")")
    testHold.up = true; sim(0.4); testHold.up = false; sim(0.2)
    print("REEL 0.4s -> depth " .. depth())
    -- the bobber rig
    game.owned.bobber[2] = true; game.equip.bobber = 2; game.equip.lure = "worm"; game.bobDepth = 40
    castWith(0.7); sim(3)
    print(string.format("BOBBER float x %d, bait depth %d (stop %d)", math.floor(st.bob.x - st.boat.x), depth(), game.bobDepth))
    shot("p03_bobber")
    testHold.down = true; sim(1.2); testHold.down = false; sim(2.5)
    print(string.format("BOBBER deeper: bait depth %d (stop %d)", depth(), math.floor(game.bobDepth)))
    shot("p04_bobber_deeper")
    testHold.a = true; sim(1.0); testHold.a = false; sim(0.3)
    print(string.format("BOBBER reeled 1s: float at %d", math.floor(st.bob and (st.bob.x - st.boat.x) or -1)))
    shot("p05_bobber_reeling")
    love.event.quit(); return
  end
  if args.casttest then
    -- many casts at random power: flag lures that fly off, never land, or a line that stretches apart
    go("lake", 0.45, "clear")
    local bad = 0
    for n = 1, 300 do
      st.phase = "idle"; st.lure.state = "hang"; st.biter = nil
      st.boat.x = 600 + (n % 7) * 300; st.boat.v = 0
      sim(0.3)
      local pw = rnd()
      pressed.a = true; testHold.a = true; sim(0.05 + pw * 0.9); testHold.a = false
      local t, maxd, maxseg, landed = 0, 0, 0, false
      while t < 3 do
        sim(1 / 30); t = t + 1 / 30
        maxd = math.max(maxd, math.abs(st.lure.x - st.boat.x))
        if st.rope then
          local seg = (st.lineOut or 1) / 32
          for i = 0, 31 do
            local a2, b2 = st.rope.pts[i], st.rope.pts[i + 1]
            maxseg = math.max(maxseg, math.sqrt((a2.x - b2.x) ^ 2 + (a2.y - b2.y) ^ 2) / math.max(seg, 0.1))
          end
        end
        if st.lure.state ~= "fly" and st.lure.state ~= "hang" then landed = true; break end
      end
      if not landed or maxd > 400 or maxseg > 3 then
        bad = bad + 1
        print(string.format("CAST %d power=%.2f landed=%s maxdist=%d stretch=%.1f phase=%s state=%s lure=(%d,%d) boat=%d T=%.2f", n, st.power or -1, tostring(landed), maxd, maxseg, st.phase, st.lure.state, st.lure.x, st.lure.y, st.boat.x, st.T or 0))
        if bad <= 3 then shot("cast_bad_" .. n) end
      end
      retrieve()
    end
    print("CASTTEST bad", bad)
    love.event.quit(); return
  end
  if args.slottest then
    -- save slots: the old single save became slot 1; make a new game in slot 3, then delete slot 1
    sim(1.5); pressed.a = true; sim(0.4); shot("v01_slots")
    pressed.down = true; sim(0.1); pressed.down = true; sim(0.1); pressed.a = true; sim(0.3)
    for _, k in ipairs({ "right", "right", "a", "down", "a", "down", "down", "right", "a" }) do pressed[k] = true; sim(0.12) end
    shot("v02_keyboard")
    pressed.start = true; sim(2.5); shot("v03_playing")
    print("SLOT", G.slot, game.name, love.filesystem.getInfo("save3.lua") and "save3 written" or "no save3")
    pressed.start = true; sim(1.4); TB.setTab(8); sim(0.3); pressed.a = true; sim(0.2)
    for _ = 1, 6 do pressed.down = true; sim(0.08) end
    sim(0.3); shot("v03b_settings"); pressed.a = true; sim(0.4); shot("v03c_exit_menu")
    pressed.down = true; sim(0.1); pressed.a = true; sim(0.25); shot("v03d_saving"); sim(0.45); shot("v03e_saved"); sim(1.4)
    print("after exit:", st.mode, G.slot, G.lastSlot)
    pressed.a = true; sim(0.4); shot("v04_slots_again")
    pressed.up = true; sim(0.1); pressed.up = true; sim(0.1)
    pressed.x = true; sim(0.3); shot("v05_delete1")
    pressed.a = true; sim(0.3); shot("v06_delete2")
    pressed.a = true; sim(0.3); print("after A on Keep:", st.slots and st.slots.mode, love.filesystem.getInfo("save1.lua") and "save1 kept" or "save1 gone")
    pressed.x = true; sim(0.1); pressed.a = true; sim(0.1); pressed.down = true; sim(0.1); pressed.a = true; sim(0.3)
    shot("v07_deleted"); print("after delete:", love.filesystem.getInfo("save1.lua") and "save1 kept" or "save1 gone")
    love.event.quit(); return
  end
  if args.features then
    -- the newest features, one picture each
    go("lake", 0.45, "clear")
    game.coins = 5000
    pressed.start = true; sim(1.4)
    for _ = 1, 6 do pressed.r = true; sim(0.15) end
    pressed.a = true; sim(0.6); shot("f01_look_build")
    for _, k in ipairs({ { 3, "f02_look_hair" }, { 5, "f03_look_glasses" }, { 7, "f04_look_pants" }, { 2, "f05_look_pet" } }) do
      for _ = 1, k[1] do pressed.down = true; sim(0.05) end
      sim(0.6); shot(k[2])
    end
    pressed.b = true; sim(0.1); pressed.r = true; sim(0.4)
    pressed.a = true; sim(0.1); pressed.down = true; sim(0.1); pressed.down = true; sim(0.1); pressed.left = true; sim(0.1)
    pressed.left = true; sim(0.3); shot("f06_settings_volume")
    for _ = 1, 4 do pressed.down = true; sim(0.05) end
    pressed.a = true; sim(0.3); shot("f07_controls")
    TB.close(); sim(1)
    -- rowing, then letting go: the oars vanish and the rod comes straight back out
    testHold.right = true; sim(1.6)
    for k = 1, 8 do sim(0.1); shot(string.format("f08_row%d", k)) end
    testHold.right = false
    sim(0.06); shot("f09_stop_006"); sim(0.1); shot("f10_stop_016"); sim(0.25); shot("f11_stop_041")
    -- buy and fit a trolling motor: driving with the tiller, then trolling a lure
    G.api.buy("motor", 2); sim(0.1)
    pressed.y = true; sim(0.4); shot("f11b_manual_motor_y")
    pressed.start = true; sim(1.4); TB.setTab(2); sim(0.2); pressed.a = true; sim(0.1)
    for _ = 1, 6 do pressed.right = true; sim(0.1) end
    sim(0.3); shot("f11c_shop_motors"); TB.close(); sim(1)
    G.api.buy("motor", 3); sim(0.1)
    testHold.right = true; sim(1.6); shot("f12_motor_drive"); testHold.right = false; sim(1.5)
    pressed.y = true; sim(0.3)
    pressed.down = true; sim(0.1); pressed.down = true; sim(0.1); pressed.right = true; sim(0.2); shot("f13_motor_menu")
    pressed.up = true; sim(0.1); pressed.up = true; sim(0.1)
    pressed.a = true; sim(0.5)
    castOut(0.5, 2.0); sim(3); shot("f14_trolling")
    game.boat = "skiff"; game.owned.boat.skiff = true; sim(2); shot("f15_skiff_trolling")
    love.event.quit(); return
  end
  if args.covers then
    -- title screens for store art: every place at a few times of day
    for _, l in ipairs(Wd.LOCS) do
      for _, c in ipairs({ 0.3, 0.45, 0.7, 0.76 }) do
        game.loc = l.id; st = newState(); game.clock = c
        enterPlace(l.id); Wd.setWeather("clear", true); Wd.weather.timer = 9999
        G.sky = Wd.sky(c); sim(3)
        shot(string.format("cover_%s_%02d", l.id, math.floor(c * 100)))
      end
    end
    love.event.quit(); return
  end
  -- the title screen at dawn
  game.clock = 0.262
  G.sky = Wd.sky(game.clock)
  sim(2.4)
  shot("s00_title")

  -- a long idle stretch in every location to exercise the logic
  game.idle, game.rod, game.line, game.lure = true, 4, 4, 3
  for _, l in ipairs(Wd.LOCS) do
    go(l.id, 0.3)
    Wd.weather.timer = 30
    sim(U.DAY_LENGTH * 0.35)
    local got = 0
    for _, f in ipairs(Wd.fishAt(l.id)) do if game.log[f.id] then got = got + 1 end end
    print(string.format("TEST %s: catches=%d coins=%d cooler=%d species=%d weather=%s", l.id, game.catches, game.coins, #game.cooler, got, Wd.weather.kind))
  end
  game.idle = false
  game.cooler = {}

  local function scene(name, loc, clock, weather, setup, secs)
    go(loc, clock, weather)
    if setup then setup() end
    sim(secs or 1.0)
    shot(name)
  end
  scene("s01_lake_day", "lake", 0.42, "clear")
  scene("s02_lake_dawn", "lake", 0.255, "clear")
  scene("s03_lake_sunset", "lake", 0.75, "clear")
  scene("s04_lake_night", "lake", 0.95, "clear")
  scene("s05_lake_fishing", "lake", 0.45, "clear", function() castOut(0.7, 2.0) end, 0.5)
  scene("s06_river_rain", "river", 0.45, "rain", function() castOut(0.5, 1.2) end, 1.5)
  scene("s07_river_golden", "river", 0.70, "clear")
  scene("s08_coast_fog", "coast", 0.36, "fog", nil, 2)
  scene("s09_coast_day", "coast", 0.5, "clear", function() castOut(0.8, 3) end, 0.5)
  scene("s10_coast_sunset", "coast", 0.76, "clear")
  scene("s11_frost_night", "frost", 0.04, "clear", nil, 1.5)
  scene("s12_frost_storm", "frost", 0.45, "rain", nil, 1)
  scene("s13_lake_overcast", "lake", 0.55, "overcast", nil, 1)
  scene("s14_lake_skiff", "lake", 0.5, "clear", function() game.boat = "skiff"; game.boats.skiff = true; testHold.left = true; sim(1.0); testHold.left = false end, 0.1)
  scene("s15_lake_rowing", "lake", 0.33, "clear", function() game.boat = "rowboat"; testHold.right = true end, 1.2)
  testHold.right = false
  local function at(x) return function() st.boat.x = x; G.cam.x = clamp(x + 70 - W / 2, 0, WORLD_W - W) end end
  scene("s16_columbia_hood", "columbia", 0.42, "clear", at(1560), 2)
  scene("s17_columbia_bridge", "columbia", 0.50, "clear", at(900), 2)
  scene("s18_columbia_bridge_sunset", "columbia", 0.75, "clear", at(760), 2)
  scene("s19_columbia_eventsite", "columbia", 0.55, "clear", at(2000), 3)
  scene("s20_columbia_night", "columbia", 0.95, "clear", at(1000), 2)
  scene("s21_lake_marsh", "lake", 0.45, "clear", at(1800), 2)
  scene("s22_lake_beach_dusk", "lake", 0.72, "clear", at(3300), 2)
  scene("s23_river_meadow", "river", 0.5, "clear", at(1150), 2)
  scene("s24_coast_driftwood", "coast", 0.45, "clear", at(1300), 2)
  scene("s25_frost_cabin", "frost", 0.40, "clear", at(1950), 2)
  -- the tackle box
  go("lake", 0.5, "clear")
  game.coins = 1240
  game.cooler = { { id = "trout", size = 52 }, { id = "bluegill", size = 18 }, { id = "pike", size = 96 }, { id = "perch", size = 22 } }
  pressed.start = true; sim(0.2); shot("t01_box_opening")
  sim(0.25); shot("t02_box_lid")
  sim(1.0); shot("t03_cooler")
  game.owned.lure.spinner = true; game.owned.lure.spoon = true; game.owned.rod[2] = true
  game.ach.first = "done"; game.ach.ten = "claimed"
  local tabs = { "t04_shop", "t05_gear", "t06_goals", "t07_log", "t08_map", "t09_look", "t10_settings" }
  for _, n in ipairs(tabs) do pressed.r = true; sim(0.4); shot(n) end
  -- shop sections
  pressed.r = true; sim(0.3); pressed.r = true; sim(0.3)          -- back round to the shop
  pressed.a = true; sim(0.2)
  for k, n in ipairs({ "t11_shop_lines", "t12_shop_lures", "t13_shop_coolers", "t14_shop_boats" }) do
    pressed.right = true; sim(0.3); shot(n)
  end
  pressed.down = true; sim(0.2); shot("t15_shop_boats_sel")
  -- gear lures, controls
  pressed.r = true; sim(0.2); pressed.a = true; sim(0.1); pressed.left = true; sim(0.1); pressed.left = true; sim(0.1); pressed.left = true; sim(0.3)
  shot("t16_gear_lures")
  for _ = 1, 5 do pressed.r = true; sim(0.15) end
  pressed.a = true; sim(0.1)
  for _ = 1, 5 do pressed.down = true; sim(0.1) end
  pressed.a = true; sim(0.3); shot("t17_controls")
  -- the button layout swap: keys from gptokeyb turn into the other button
  pressed.a = true; sim(0.2)
  love.keypressed("z"); local swappedA = pressed.b; pressed = {}
  love.keypressed("c"); local swappedX = pressed.y; pressed = {}
  shot("t17b_controls_swapped")
  print("SWAP z->b " .. tostring(swappedA) .. ", c->y " .. tostring(swappedX))
  pressed.a = true; sim(0.2)
  love.keypressed("z"); print("UNSWAP z->a " .. tostring(pressed.a)); pressed = {}
  pressed.down = true; sim(0.1)
  pressed.a = true; sim(0.2); shot("t18_controls_wait")
  pressed.y = true; sim(0.3); shot("t19_controls_set")
  game.binds = { cast = "a", fast = "b", pet = "x", box = "start", motor = "y" }
  TB.close(); sim(1)
  -- a catch card
  go("lake", 0.45, "clear")
  castOut(0.6, 1.5)
  forceBiter()
  local guard = 0
  while not (st.biter and st.biter.struck) and guard < 300 do
    sim(1 / 15); guard = guard + 1
  end
  shot("c01_bite")
  pressed.a = true; sim(0.1)
  sim(1.5, function() testHold.a = st.T < 0.6 end)
  shot("c02_fight")
  sim(20, function()
    testHold.a = st.T < 0.6; if st.phase ~= "fight" then testHold.a = false end end)
  testHold.a = false
  sim(1.2)
  shot("c03_card")
  -- pets
  go("lake", 0.45, "clear"); game.look.pet = 2; pressed.x = true; sim(0.4); shot("p01_dog_pet")
  game.look.pet = 3; game.look.coat = 5; petEvent("hello"); sim(0.2); shot("p02_cat_meow")

  -- a recorded run: row, turn, cast, sink, bite, fight, catch
  love.filesystem.createDirectory("gif")
  go("lake", 0.70, "clear")
  game.look = L.normalize({ hat = 2, hatc = 4, hair = 2, hairc = 2, face = 2, skin = 2, top = 2, topc = 2, pants = 1, pet = 2, coat = 1 })
  local n = 0
  local function rec(seconds, each)
    for i = 1, math.floor(seconds * 30) do
      if each then each() end
      update(1 / 30); pressed = {}
      if i % 2 == 0 then
        render()
        n = n + 1
        canvas:newImageData():encode("png", string.format("gif/f%04d.png", n))
      end
    end
  end
  rec(0.8)
  testHold.right = true; rec(2.6); testHold.right = false
  rec(0.8)
  testHold.left = true; rec(0.6); testHold.left = false
  rec(0.8)
  testHold.right = true; rec(0.5); testHold.right = false
  rec(0.6)
  pressed.a = true; testHold.a = true; rec(0.8); testHold.a = false
  rec(1.2)
  testHold.down = true; rec(1.6); testHold.down = false
  rec(0.4)
  forceBiter()
  guard = 0
  while not (st.biter and st.biter.struck) and guard < 200 do rec(1 / 15); guard = guard + 1 end
  rec(0.2); pressed.a = true; rec(1 / 15)
  rec(14, function() testHold.a = (st.phase == "fight") and st.T < 0.6 end)
  testHold.a = false
  rec(1.5)
  pressed.a = true; rec(0.6)
  pressed.start = true; rec(1.6)
  pressed.right = true; rec(0.6)
  pressed.start = true; rec(1)
  print("GIF frames: " .. n .. ", phase at end: " .. st.phase)
  print("TEST done, saved to " .. love.filesystem.getSaveDirectory())
  love.event.quit()
end
