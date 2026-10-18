-- The Hood River Bridge (Hood River, Oregon to White Salmon, Washington), drawn in true perspective from its
-- recorded structure: 19 steel truss spans of 208 ft over the road, on concrete piers, a 262 ft Pennsylvania (Petit)
-- through-truss vertical lift span between lattice towers (about 72 ft clearance closed), a narrow 18 ft 9 in
-- open-grate deck, and a tollbooth on the Oregon approach. It leaves the Oregon
-- shore east of the Hood River's mouth and runs away across the river to the east, seen at a distance.
-- Also the kiteboarders and windsurfers the town is famous for.
local U = require("util")
local lg = love.graphics
local fl, rr, rnd, clamp, mix = U.fl, U.rr, U.rnd, U.clamp, U.mix
local B = {}

local YH, CUT_Y = U.YH, U.CUT_Y
local HC, F, D0 = 10.0, 60.0, 10.0          -- the scenery's projection (art2/common.py)
local K = 0.6                                -- metres to scene height units (the deck clears the camera's eye)
local X0 = 1290                              -- world x of the Oregon end, by the port east of the Hood River
local SIN = 0.24                             -- the bridge runs north-north-east, angled across our view
local DA, DLANE = 0.6, -6.0                  -- depth of the Oregon end, and of the boat's lane
local LIFT_A, LIFT_B = 610, 690              -- the 262 ft lift span (79.4 m)
local CROSS = 650                            -- the boat's lane passes under the middle of the lift span
local LEN = 760                              -- how much of the bridge we ever see before it passes overhead
local ROAD = 23                              -- roadway height (m): about 72 ft of clearance under the lift span
local DECK_DEPTH = 0.8                       -- the piers carry the road directly
local TRUSS_H = 7                            -- the 208 ft trusses rise about 23 ft above the road

-- the road climbs from the Oregon abutment (where the tollbooth is) and then runs level
local function deckZ(m) return 8 + (ROAD - 8) * clamp(m / 140, 0, 1) end
local function depthAt(m) return DA + (DLANE - DA) * (m / CROSS) end
local function pxPerM(m) return F / math.max(0.3, depthAt(m) + D0) * K end

-- true perspective along the bridge: each metre moves sideways on screen by SIN times its scale,
-- so nearer spans are wider as well as taller
local LAT = {}
do
  local acc = 0
  for m = 0, LEN + 1 do LAT[m] = acc; acc = acc + SIN * pxPerM(m + 0.5) end
end
local function lateral(m)
  local i = math.max(0, math.min(LEN, math.floor(m)))
  return LAT[i] + (LAT[i + 1] - LAT[i]) * (m - i)
end
B.XC = X0 - lateral(CROSS)                   -- where the boat passes under

-- a point on the bridge: m metres from the Oregon end, z metres above the water -> screen x, y and px per metre
local function P(m, z, cam)
  local D = depthAt(m)
  local s = F / math.max(0.3, D + D0)
  return X0 - lateral(m) - cam.x, YH + (HC - z * K) * s - cam.y, s * K
end

local spans
local function layout()
  spans = {}
  -- plain approach spans off the Oregon abutment (just the road and its guardrail on piers),
  -- then the 208 ft (63.4 m) truss spans out to the lift span
  local tr0 = 610 - 9 * 63.4
  spans[1] = { a = 0, b = tr0 / 2, approach = true }
  spans[2] = { a = tr0 / 2, b = tr0, approach = true }
  for i = 1, 9 do spans[#spans + 1] = { a = spans[#spans].b, b = spans[#spans].b + 63.4 } end
  spans[#spans + 1] = { a = LIFT_A, b = LIFT_B, lift = true }
  spans[#spans + 1] = { a = LIFT_B, b = LIFT_B + 63.4 }
end

local function line(ax, ay, bx, by) lg.line(fl(ax) + 0.5, fl(ay) + 0.5, fl(bx) + 0.5, fl(by) + 0.5) end

B.cars = {}
function B.update(dt, t)
  if rnd() < dt * 0.25 then
    local dir = rnd() < 0.5 and 1 or -1
    B.cars[#B.cars + 1] = { m = dir > 0 and 0 or LEN, v = dir * rr(14, 20), c = ({ { .9, .2, .2 }, { .9, .9, .92 }, { .2, .3, .6 }, { .2, .2, .22 }, { .9, .7, .2 } })[rnd(1, 5)] }
  end
  for i = #B.cars, 1, -1 do
    local c = B.cars[i]
    c.m = c.m + c.v * dt
    if c.m < -10 or c.m > LEN + 10 then table.remove(B.cars, i) end
  end
end

-- the piers' reflections in the water
function B.drawReflection(sky, cam)
  if not spans then layout() end
  local l = sky.spr
  for _, sp in ipairs(spans) do
    local m = sp.a
    if m > 0 and m < CROSS then
      local x, yw, s = P(m, 0, cam)
      local _, ytop = P(m, deckZ(m) - DECK_DEPTH, cam)
      local h = (yw - ytop) * 0.8
      if x > -40 and x < U.W + 40 and yw < CUT_Y - cam.y then
        lg.setColor(0.42 * l[1], 0.42 * l[2], 0.42 * l[3], 0.25)
        lg.rectangle("fill", fl(x - s * 1.75), fl(yw), math.max(1, fl(s * 3.5)), fl(math.min(h, CUT_Y - cam.y - yw)))
      end
    end
  end
end

function B.draw(sky, cam, t)
  if not spans then layout() end
  local l = sky.spr
  local night = sky.night
  local steel = { 0.50 * l[1], 0.55 * l[2], 0.54 * l[3] }
  local steelD = { 0.32 * l[1], 0.36 * l[2], 0.36 * l[3] }
  local conc = { 0.66 * l[1], 0.64 * l[2], 0.60 * l[3] }
  local deckC = { 0.24 * l[1], 0.24 * l[2], 0.26 * l[3] }
  lg.setLineStyle("rough")
  -- the tollbooth on the Oregon approach
  do
    local x, y, s = P(0, 8, cam)
    lg.setColor(0.86 * l[1], 0.84 * l[2], 0.78 * l[3])
    lg.rectangle("fill", fl(x - s * 3), fl(y - s * 3.5), math.max(2, fl(s * 4)), math.max(2, fl(s * 3.5)))
    lg.setColor(0.42 * l[1], 0.24 * l[2], 0.2 * l[3])
    lg.rectangle("fill", fl(x - s * 3.5), fl(y - s * 4.2), math.max(2, fl(s * 5)), math.max(1, fl(s * 0.8)))
  end
  for _, sp in ipairs(spans) do
    local a, b = sp.a, sp.b
    local xa = P(a, 0, cam)
    local xb = P(b, 0, cam)
    if math.max(xa, xb) > -80 and math.min(xa, xb) < U.W + 80 then
      local za, zb = deckZ(a), deckZ(b)
      -- the concrete pier at the Oregon-side end of the span, standing in the water
      if a > 0 and a < CROSS then
        local px, pyw, ps = P(a, 0, cam)
        local _, pyt = P(a, za - DECK_DEPTH, cam)
        local pw = math.max(1, ps * 3.5)
        lg.setColor(conc)
        lg.rectangle("fill", fl(px - pw / 2), fl(pyt), math.max(1, fl(pw)), fl(pyw - pyt) + 1)
        lg.setColor(conc[1] * 0.78, conc[2] * 0.78, conc[3] * 0.78)
        lg.rectangle("fill", fl(px + pw * 0.2), fl(pyt), math.max(1, fl(pw * 0.3)), fl(pyw - pyt) + 1)
        lg.rectangle("fill", fl(px - pw / 2 - ps), fl(pyw - ps * 2.5), math.max(1, fl(pw + ps * 2)), math.max(1, fl(ps * 2.5)))
        lg.setColor(conc[1] * 1.1, conc[2] * 1.1, conc[3] * 1.1)
        lg.rectangle("fill", fl(px - pw / 2 - ps * 0.5), fl(pyt), math.max(1, fl(pw + ps)), math.max(1, fl(ps)))
      end
      if sp.lift then
        -- the Pennsylvania (Petit) through truss: a many-sided top chord rising to the middle,
        -- verticals, diagonals sloping down toward the centre, and half-height sub-struts in each panel
        local n = 8
        local function topZ(k) return za + 8 + 5 * math.sin(math.pi * k / n) end
        lg.setColor(steel)
        lg.setLineWidth(math.max(1, fl(pxPerM(a) * 0.9)))
        local bx0, by0 = P(a, za, cam)
        local bx1, by1 = P(b, zb, cam)
        line(bx0, by0, bx1, by1)
        local px1, py1 = P(a, za, cam)
        for k = 1, n - 1 do
          local m = a + (b - a) * k / n
          local tx, ty = P(m, topZ(k), cam)
          line(px1, py1, tx, ty)
          px1, py1 = tx, ty
        end
        line(px1, py1, bx1, by1)
        lg.setLineWidth(1)
        for k = 1, n - 1 do
          local m = a + (b - a) * k / n
          local bx, by = P(m, za, cam)
          local tx, ty = P(m, topZ(k), cam)
          lg.setColor(steelD)
          line(bx, by, tx, ty)
          -- the diagonal falls toward the middle of the span
          local toward = k < n / 2 and 1 or -1
          local m2 = m + toward * (b - a) / n
          local k2 = k + toward
          if k2 > 0 and k2 < n then
            local b2x, b2y = P(m2, za, cam)
            lg.setColor(steel)
            line(tx, ty, b2x, b2y)
            -- sub-strut from the middle of the diagonal down to the bottom chord
            local mx, my = (tx + b2x) / 2, (ty + b2y) / 2
            local smx, smy = P((m + m2) / 2, za, cam)
            lg.setColor(steelD)
            line(mx, my, smx, smy)
          end
        end
        -- the lift tower on the near pier of the span: lattice legs climbing out of view, sheaves on top
        do
          local tx, tyw, ts = P(a, 0, cam)
          local _, tyb = P(a, za, cam)
          local _, tyt = P(a, 62, cam)
          local hw = math.max(2, ts * 4.5)
          lg.setColor(steel)
          lg.setLineWidth(math.max(1, fl(ts * 0.8)))
          line(tx - hw, tyb, tx - hw * 0.8, tyt); line(tx + hw, tyb, tx + hw * 0.8, tyt)
          lg.setLineWidth(1)
          lg.setColor(steelD)
          local nseg = math.max(3, fl((tyb - tyt) / math.max(4, hw * 1.8)))
          for k = 0, nseg - 1 do
            local y1b = tyb + (tyt - tyb) * k / nseg
            local y2b = tyb + (tyt - tyb) * (k + 1) / nseg
            line(tx - hw, y1b, tx + hw, y2b); line(tx + hw, y1b, tx - hw, y2b)
          end
          lg.setColor(steel)
          lg.rectangle("fill", fl(tx - hw * 1.2), fl(tyt - ts * 4), math.max(2, fl(hw * 2.4)), math.max(1, fl(ts * 4)))
          if night > 0.3 and (t % 1.6) < 0.8 then
            lg.setColor(1, 0.2, 0.15, night)
            lg.circle("fill", fl(tx), fl(tyt - ts * 4) - 1, 2)
          end
        end
      elseif sp.approach then
        -- an approach span: a plain steel girder under the road, guardrail only
        local x1, y1, sa = P(a, za, cam)
        local x2, y2 = P(b, zb, cam)
        lg.setColor(steelD)
        lg.setLineWidth(math.max(1, fl(sa * 1.4)))
        line(x1, y1, x2, y2)
        lg.setLineWidth(1)
      else
        -- a through truss over the road (Pratt pattern), the road resting on the concrete piers
        local x1, y1, sa = P(a, za + TRUSS_H, cam)
        local x2, y2 = P(b, zb + TRUSS_H, cam)
        local x3, y3 = P(a, za, cam)
        local x4, y4 = P(b, zb, cam)
        lg.setColor(steel)
        lg.setLineWidth(math.max(1, fl(sa * 0.8)))
        line(x1, y1, x2, y2); line(x3, y3, x4, y4)
        line(x1, y1, x3, y3); line(x2, y2, x4, y4)
        lg.setLineWidth(1)
        local np = math.max(2, math.min(8, fl(math.abs(x2 - x1) / 5)))
        for k = 1, np - 1 do
          local m1 = a + (b - a) * k / np
          local tx1, ty1 = P(m1, deckZ(m1) + TRUSS_H, cam)
          local bx1, by1 = P(m1, deckZ(m1), cam)
          lg.setColor(steelD)
          line(tx1, ty1, bx1, by1)
        end
        for k = 0, np - 1 do
          local m1, m2 = a + (b - a) * k / np, a + (b - a) * (k + 1) / np
          local toward = (k < np / 2) and 1 or -1
          lg.setColor(steel)
          if toward > 0 then
            local tx1, ty1 = P(m1, deckZ(m1) + TRUSS_H, cam)
            local bx2, by2 = P(m2, deckZ(m2), cam)
            line(tx1, ty1, bx2, by2)
          else
            local bx1, by1 = P(m1, deckZ(m1), cam)
            local tx2, ty2 = P(m2, deckZ(m2) + TRUSS_H, cam)
            line(bx1, by1, tx2, ty2)
          end
        end
      end
      -- the open-grate deck and its railing
      local d1x, d1y, ds = P(a, za + 0.4, cam)
      local d2x, d2y = P(b, zb + 0.4, cam)
      lg.setColor(deckC)
      lg.setLineWidth(math.max(1, fl(ds * 1.0)))
      line(d1x, d1y, d2x, d2y)
      lg.setLineWidth(1)
      local r1x, r1y = P(a, za + 1.4, cam)
      local r2x, r2y = P(b, zb + 1.4, cam)
      lg.setColor(steel[1] * 1.2, steel[2] * 1.2, steel[3] * 1.2)
      line(r1x, r1y, r2x, r2y)
      if night > 0.3 then
        local lx, ly = P((a + b) / 2, deckZ(a) + TRUSS_H, cam)
        lg.setColor(1, 0.85, 0.5, 0.8 * night)
        lg.rectangle("fill", fl(lx), fl(ly), 1, 1)
      end
    end
  end
  -- traffic on the narrow deck
  for _, c in ipairs(B.cars) do
    local x, y, s = P(c.m, deckZ(c.m) + 1.2, cam)
    if x > -20 and x < U.W + 20 then
      local w = math.max(1, fl(s * 4.5))
      lg.setColor(c.c[1] * l[1], c.c[2] * l[2], c.c[3] * l[3])
      lg.rectangle("fill", fl(x - w / 2), fl(y - math.max(1, s * 1.5)), w, math.max(1, fl(s * 1.5)))
      if night > 0.3 then
        lg.setColor(1, 0.95, 0.7, night)
        lg.rectangle("fill", fl(x + (c.v > 0 and -w / 2 or w / 2)), fl(y - 1), 1, 1)
      end
    end
  end
end

---------------------------------------------------------------- kiteboarders and windsurfers
B.riders = nil
local KITE = { { .95, .3, .25 }, { .2, .7, .9 }, { .98, .8, .2 }, { .4, .9, .4 }, { .9, .4, .8 }, { 1, .55, .15 } }
local function newRider(i)
  return { x = rr(1300, 3200), D = rr(-4.8, -0.8), v = (rnd() < 0.5 and -1 or 1) * rr(35, 60), kite = rnd() < 0.65,
           c = KITE[(i % #KITE) + 1], c2 = KITE[((i + 2) % #KITE) + 1], ph = rr(0, 6), jump = 0 }
end

function B.updateRiders(dt, t, windy)
  if not B.riders then
    B.riders = {}
    for i = 1, 9 do B.riders[i] = newRider(i) end
  end
  for _, r in ipairs(B.riders) do
    r.x = r.x + r.v * dt * (0.6 + 0.4 * windy)
    -- reach across the river and turn back, the way they work the swell off the Event Site
    if r.x < 1150 or r.x > 3400 then r.v = -r.v; r.x = clamp(r.x, 1150, 3400) end
    if r.kite and r.jump <= 0 and rnd() < dt * 0.06 then r.jump = 1.6 end
    if r.jump > 0 then r.jump = r.jump - dt end
  end
end

function B.drawRiders(sky, cam, t, windy)
  if not B.riders or sky.night > 0.6 then return end
  local l = sky.spr
  for _, r in ipairs(B.riders) do
    local s = F / (r.D + D0) * K
    local x = r.x - cam.x
    local yw = YH + HC * F / (r.D + D0) - cam.y
    if x > -40 and x < U.W + 40 then
      local dir = r.v > 0 and 1 or -1
      local hop = r.jump > 0 and math.sin((1.6 - r.jump) / 1.6 * math.pi) * s * 8 or 0
      local y = yw - hop
      -- spray behind the board
      lg.setColor(1, 1, 1, 0.5)
      lg.rectangle("fill", fl(x - dir * s * 3), fl(yw), math.max(1, fl(s * 2.5)), 1)
      -- board and rider
      lg.setColor(0.15 * l[1], 0.15 * l[2], 0.18 * l[3])
      lg.rectangle("fill", fl(x - s), fl(y), math.max(2, fl(s * 2.2)), 1)
      lg.rectangle("fill", fl(x), fl(y - s * 1.7), 1, math.max(2, fl(s * 1.7)))
      if r.kite then
        -- the kite: a curved canopy high up-wind, with lines down to the rider
        local kx, ky = x + dir * s * 14 + math.sin(t * 0.7 + r.ph) * s * 3, y - s * 22
        lg.setColor(1, 1, 1, 0.35)
        lg.line(fl(x) + 0.5, fl(y - s * 1.2) + 0.5, fl(kx) + 0.5, fl(ky) + 0.5)
        lg.setColor(r.c[1] * l[1], r.c[2] * l[2], r.c[3] * l[3])
        local kw = math.max(3, s * 6)
        lg.setLineWidth(math.max(1, fl(s * 1.2)))
        lg.arc("line", "open", fl(kx), fl(ky + kw * 0.6), kw, math.pi * 1.15, math.pi * 1.85)
        lg.setLineWidth(1)
      else
        -- a windsurfer's sail: a tall coloured triangle on the mast
        local sh = math.max(4, s * 5)
        lg.setColor(r.c[1] * l[1], r.c[2] * l[2], r.c[3] * l[3])
        lg.polygon("fill", fl(x), fl(y - sh), fl(x), fl(y), fl(x + dir * sh * 0.55), fl(y - sh * 0.15))
        lg.setColor(r.c2[1] * l[1], r.c2[2] * l[2], r.c2[3] * l[3])
        lg.line(fl(x) + 0.5, fl(y - sh * 0.5) + 0.5, fl(x + dir * sh * 0.4) + 0.5, fl(y - sh * 0.25) + 0.5)
      end
    end
  end
end

return B
