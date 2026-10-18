-- Underwater wildlife that lives in each place but can't be caught: crayfish and crabs on
-- the bottom, turtles, frogs, otters, seals and loons swimming, water snakes at the surface,
-- jellyfish drifting, and little schools of baitfish.
local U = require("util")
local FD = require("fishdraw")
local lg = love.graphics
local fl, rr, rnd, clamp, lerp = U.fl, U.rr, U.rnd, U.clamp, U.lerp
local CUT_Y, WORLD_W = U.CUT_Y, U.WORLD_W

local WL = {}
local META
local critters = {}

local PLACES = {
  lake  = { crayfish = 10, turtle = 3, snake = 2, frog = 5, school = 5 },
  river = { crayfish = 12, otter = 2, snake = 2, frog = 3, school = 8 },
  coast = { crab = 12, jelly = 12, seal = 2, school = 8 },
  frost = { loon = 3, school = 5, crayfish = 3 },
  columbia = { crayfish = 10, otter = 2, snake = 1, school = 9 },
}

local function swimmer(id)
  return { id = id, meta = META[id] }
end

local function new(kind)
  local c = { kind = kind, x = rr(40, WORLD_W - 40), t = rr(0, 10), phase = rr(0, 6), face = rnd() < 0.5 and 1 or -1, seed = rr(0, 50) }
  c.turn, c.turnT = U.spring(c.face), U.spring(c.face)
  local Wd = WL.Wd
  if kind == "crayfish" or kind == "crab" then
    c.y = Wd.bedY(c.x) - 4
    c.state, c.timer = "walk", rr(1, 4)
  elseif kind == "jelly" then
    c.y = rr(CUT_Y + 30, Wd.bedY(c.x) - 30)
    c.vy, c.pulse = 0, rr(0, 6)
  elseif kind == "school" then
    c.y = rr(CUT_Y + 20, Wd.bedY(c.x) - 30)
    c.fish = {}
    for i = 1, rnd(9, 15) do c.fish[i] = { dx = rr(-14, 14), dy = rr(-6, 6), ph = rr(0, 6) } end
    c.tx, c.ty = c.x, c.y
  elseif kind == "snake" then
    c.y = CUT_Y + 2
  else
    c.f = swimmer("w_" .. kind)
    c.y = rr(CUT_Y + 10, math.max(CUT_Y + 12, Wd.bedY(c.x) - 20))
    c.tx, c.ty = c.x, c.y
    c.speed = ({ turtle = 9, frog = 14, otter = 38, seal = 44, loon = 36 })[kind]
  end
  return c
end

function WL.build(loc, Wd)
  WL.Wd = Wd
  META = META or love.filesystem.load("gfx/wild/meta.lua")()
  critters = {}
  for kind, n in pairs(PLACES[loc] or {}) do
    for _ = 1, n do critters[#critters + 1] = new(kind) end
  end
end

-- pick somewhere new to swim: divers go deep and come back up; frogs stay in the shallows
local function retarget(c)
  local Wd = WL.Wd
  local x = clamp(c.x + rr(-260, 260), 30, WORLD_W - 30)
  local bed = Wd.bedY(x)
  local y
  if c.kind == "frog" then y = CUT_Y + rr(3, 14)
  elseif c.kind == "turtle" then y = (rnd() < 0.3) and CUT_Y + 6 or rr(CUT_Y + 30, bed - 14)
  else y = (rnd() < 0.35) and CUT_Y + rr(4, 10) or rr(CUT_Y + 40, bed - 16) end
  c.tx, c.ty = x, y
end

function WL.update(dt, t, night, lure)
  local Wd = WL.Wd
  for _, c in ipairs(critters) do
    c.t = c.t + dt
    if c.kind == "crayfish" or c.kind == "crab" then
      c.timer = c.timer - dt
      if c.timer <= 0 then
        if c.state == "walk" then c.state, c.timer = "rest", rr(1.5, 5)
        else c.state, c.timer = "walk", rr(1, 4); if rnd() < 0.4 then c.face = -c.face end end
      end
      -- a lure close by sends them scuttling backwards
      if lure and math.abs(lure.x - c.x) < 24 and math.abs(lure.y - c.y) < 18 then
        c.state, c.timer = "flee", 0.8
        c.face = lure.x > c.x and -1 or 1
      end
      local sp = c.state == "flee" and 26 or (c.state == "walk" and 6 or 0)
      c.x = clamp(c.x + c.face * sp * dt, 10, WORLD_W - 10)
      c.y = Wd.bedY(c.x) - 4
      if c.state ~= "rest" then c.phase = c.phase + dt * (c.state == "flee" and 18 or 7) end
    elseif c.kind == "jelly" then
      c.pulse = c.pulse + dt * 1.6
      local p = math.max(0, math.sin(c.pulse))
      c.vy = c.vy * (1 - dt * 0.8) - p * dt * 9 + dt * 3
      c.y = clamp(c.y + c.vy * dt, CUT_Y + 16, Wd.bedY(c.x) - 20)
      c.x = c.x + math.sin(t * 0.1 + c.seed) * dt * 3
    elseif c.kind == "school" then
      if math.abs(c.x - c.tx) < 10 then
        c.tx = clamp(c.x + rr(-300, 300), 30, WORLD_W - 30)
        c.ty = rr(CUT_Y + 16, Wd.bedY(c.tx) - 24)
      end
      local dx = c.tx - c.x
      c.face = dx > 0 and 1 or -1
      c.x = c.x + c.face * 20 * dt
      c.y = c.y + (c.ty - c.y) * dt * 0.5
      for _, f in ipairs(c.fish) do
        f.dx = f.dx + math.sin(t * 1.3 + f.ph) * dt * 4
        f.dy = f.dy + math.cos(t * 1.1 + f.ph) * dt * 2
        f.dx, f.dy = clamp(f.dx, -18, 18), clamp(f.dy, -8, 8)
      end
      c.x = c.x + Wd.flow() * dt * 4
    elseif c.kind == "snake" then
      -- water snakes swim with their head up at the surface, mostly by day
      if not c.tx or math.abs(c.x - c.tx) < 8 then c.tx = clamp(c.x + rr(-400, 400), 40, WORLD_W - 40) end
      c.face = c.tx > c.x and 1 or -1
      c.x = c.x + c.face * (night > 0.6 and 0 or 16) * dt
      c.phase = c.phase + dt * 4
    else
      if math.abs(c.x - c.tx) < 8 and math.abs(c.y - c.ty) < 6 then retarget(c) end
      local dx, dy = c.tx - c.x, c.ty - c.y
      local d = math.sqrt(dx * dx + dy * dy) + 1e-6
      local sp = c.speed * (night > 0.6 and c.kind ~= "seal" and 0.4 or 1)
      if c.kind == "frog" then sp = sp * (0.3 + math.max(0, math.sin(c.t * 3)) * 1.6) end   -- kick and glide
      c.x = c.x + dx / d * sp * dt
      c.y = c.y + dy / d * sp * dt * 0.8
      if math.abs(dx) > 4 then c.face = dx > 0 and 1 or -1 end
      U.stepSpring(c.turn, c.face, 10, 6, dt)
      U.stepSpring(c.turnT, c.turn.x, 16, 8, dt)
      c.phase = c.phase + dt * (2 + sp * 0.12)
      local bed = Wd.bedY(clamp(c.x, 0, WORLD_W - 1))
      c.y = clamp(c.y, CUT_Y + 4, bed - 8)
    end
  end
end

local function walkerFrame(c) return (math.floor(c.phase) % 2) + 1 end

function WL.draw(cam, t, tintAt)
  for _, c in ipairs(critters) do
    local sx, sy = c.x - cam.x, c.y - cam.y
    if sx > -60 and sx < U.W + 60 and sy > CUT_Y - cam.y - 20 and sy < U.H + 20 then
      local tint = tintAt(c.y)
      if c.kind == "crayfish" or c.kind == "crab" then
        local im = U.img("gfx/wild/" .. c.kind .. walkerFrame(c) .. ".png")
        lg.setColor(tint[1], tint[2], tint[3])
        local w = im:getWidth()
        if c.face > 0 or c.kind == "crab" then lg.draw(im, fl(sx - w / 2), fl(sy - im:getHeight() + 4))
        else lg.draw(im, fl(sx + w / 2), fl(sy - im:getHeight() + 4), 0, -1, 1) end
      elseif c.kind == "jelly" then
        local p = math.max(0, math.sin(c.pulse))
        local w, h = 7 + p * 2, 5 - p * 1.5
        lg.setColor(0.95 * tint[1], 0.85 * tint[2], 0.95 * tint[3], 0.55)
        lg.arc("fill", fl(sx), fl(sy), w, math.pi, 2 * math.pi)
        lg.setColor(1, 0.8, 0.95, 0.35)
        lg.ellipse("fill", fl(sx), fl(sy - h * 0.4), w * 0.5, h * 0.4)
        lg.setColor(0.95 * tint[1], 0.85 * tint[2], 0.95 * tint[3], 0.4)
        for k = -2, 2 do
          local px, py = sx + k * 2.4, sy
          for s = 1, 6 do
            local nx = px + math.sin(t * 2 + s * 0.6 + k) * 0.8
            local ny = py + 2.5
            lg.line(fl(px) + 0.5, fl(py) + 0.5, fl(nx) + 0.5, fl(ny) + 0.5)
            px, py = nx, ny
          end
        end
      elseif c.kind == "school" then
        for _, f in ipairs(c.fish) do
          local fx, fy = sx + f.dx, sy + f.dy
          local glint = math.sin(t * 3 + f.ph) > 0.7
          lg.setColor(tint[1] * (glint and 1 or 0.75), tint[2] * (glint and 1 or 0.8), tint[3] * (glint and 1 or 0.85), 0.9)
          lg.rectangle("fill", fl(fx), fl(fy), 3, 1)
          lg.rectangle("fill", fl(fx) + (c.face > 0 and -1 or 3), fl(fy), 1, 1)
        end
      elseif c.kind == "snake" then
        -- a slim dark body snaking along just under the surface, head raised
        local px, py
        for k = 0, 22 do
          local x = sx - c.face * k * 1.6
          local y = sy + math.sin(c.phase - k * 0.45) * 2 * math.min(1, k / 4)
          if px then
            lg.setColor(0.24 * tint[1], 0.22 * tint[2], 0.16 * tint[3])
            lg.setLineWidth(k < 16 and 2 or 1)
            lg.line(fl(px) + 0.5, fl(py) + 0.5, fl(x) + 0.5, fl(y) + 0.5)
          end
          px, py = x, y
        end
        lg.setLineWidth(1)
        lg.setColor(0.30 * tint[1], 0.28 * tint[2], 0.2 * tint[3])
        lg.rectangle("fill", fl(sx) - 1, fl(sy) - 2, 4, 3)
        lg.setColor(0.8, 0.7, 0.3); lg.rectangle("fill", fl(sx) + (c.face > 0 and 1 or 0), fl(sy) - 2, 1, 1)
      elseif c.f then
        FD.draw(c.f, sx, sy, c.turn.x, c.phase, 0.6, tint, 1, 0, 1, c.turnT.x)
      end
    end
  end
end

-- creatures near the lure for spook/visuals elsewhere
function WL.all() return critters end

return WL
