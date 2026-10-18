-- A fishing line with real physics: a chain of points (Verlet) pinned at the rod tip.
-- The far end is either pinned to the lure (cast, in the water, fighting a fish) or free,
-- so the lure dangles and swings from the tip as the boat moves.
local U = require("util")
local R = {}

local N = 32

function R.new(x0, y0, x1, y1)
  local r = { pts = {}, len = 12, free = true }
  for i = 0, N do
    local u = i / N
    local x, y = U.lerp(x0, x1, u), U.lerp(y0, y1, u)
    r.pts[i] = { x = x, y = y, px = x, py = y }
  end
  return r
end

function R.reset(r, x0, y0, x1, y1)
  for i = 0, N do
    local u = i / N
    local p = r.pts[i]
    p.x, p.y = U.lerp(x0, x1, u), U.lerp(y0, y1, u)
    p.px, p.py = p.x, p.y
  end
end

-- tip: the rod tip; endx/endy: where the lure is when pinned (nil = free dangling end)
-- surfaceY(x): the water surface; wind: horizontal push above the water
-- current: sideways drift of the water (river flow); strain: 0..1, how hard the line is pulled (it hums)
function R.update(r, dt, tx, ty, endx, endy, len, surfaceY, wind, t, current, strain)
  current, strain = current or 0, strain or 0
  local pts = r.pts
  r.free = endx == nil
  r.len = len
  local seg = len / N
  local steps = math.max(1, math.ceil(dt / (1 / 60)))
  local h = dt / steps
  for _ = 1, steps do
    for i = 1, N do
      local p = pts[i]
      local under = p.y > surfaceY(p.x)
      -- in the air: gravity and a little wind; in the water: heavy drag, nearly neutral buoyancy, the current
      local damp = under and 0.80 or 0.985
      local g = under and 10 or 260
      local ax = under and current * 9 or (wind * (0.6 + 0.4 * math.sin(t * 1.7 + i * 0.4)))
      if i == N and r.free then g = g * 1.6 end          -- the lure is heavier than the line
      local vx, vy = (p.x - p.px) * damp, (p.y - p.py) * damp
      p.px, p.py = p.x, p.y
      p.x = p.x + vx + ax * h * h
      p.y = p.y + vy + g * h * h
    end
    pts[0].x, pts[0].y = tx, ty
    if not r.free then pts[N].x, pts[N].y = endx, endy end
    for _ = 1, 10 do
      for i = 0, N - 1 do
        local a, b = pts[i], pts[i + 1]
        local dx, dy = b.x - a.x, b.y - a.y
        local d = math.sqrt(dx * dx + dy * dy)
        if d > seg then                     -- line only resists stretching; it can go slack
          local diff = (d - seg) / d
          local wa = (i == 0) and 0 or 0.5
          local wb = (i + 1 == N and not r.free) and 0 or 0.5
          if wa + wb > 0 then
            local k = diff / (wa + wb)
            a.x, a.y = a.x + dx * k * wa, a.y + dy * k * wa
            b.x, b.y = b.x - dx * k * wb, b.y - dy * k * wb
          end
        end
      end
      pts[0].x, pts[0].y = tx, ty
      if not r.free then pts[N].x, pts[N].y = endx, endy end
    end
    -- monofilament is a little stiff: it bends in smooth curves rather than sharp kinks
    for i = 1, N - 1 do
      local a, p, b = pts[i - 1], pts[i], pts[i + 1]
      local mx, my = (a.x + b.x) * 0.5, (a.y + b.y) * 0.5
      p.x, p.y = p.x + (mx - p.x) * 0.04, p.y + (my - p.y) * 0.04
    end
    -- a line under heavy strain hums: a fine shiver along its length
    if strain > 0.5 then
      local amp = (strain - 0.5) * 0.5
      for i = 2, N - 2 do
        local p = pts[i]
        p.y = p.y + math.sin(t * 90 + i * 1.7) * amp * h * 30
      end
    end
    -- line floating on the surface doesn't sink straight through: it rests a moment
    for i = 1, N - 1 do
      local p = pts[i]
      local sy = surfaceY(p.x)
      if p.y > sy and p.y < sy + 1.5 then p.py = p.py + (p.y - p.py) * 0.3 end
    end
  end
end

-- the cast: line leaves the tip with the lure, each point carrying a share of its speed, so it unrolls behind it
function R.launch(r, x0, y0, vx, vy)
  for i = 0, N do
    local p = r.pts[i]
    local u = i / N
    p.x, p.y = x0, y0
    p.px, p.py = x0 - vx * u / 60, y0 - vy * u / 60
  end
end

function R.endPoint(r) local p = r.pts[N]; return p.x, p.y end

function R.draw(r, cam, colorAbove, colorBelow, surfaceY)
  local lg = love.graphics
  local pts = r.pts
  lg.setLineWidth(1)
  for i = 0, N - 1 do
    local a, b = pts[i], pts[i + 1]
    local under = (a.y + b.y) / 2 > surfaceY((a.x + b.x) / 2)
    local c = under and colorBelow or colorAbove
    lg.setColor(c[1], c[2], c[3], c[4] or 1)
    lg.line(U.fl(a.x - cam.x) + 0.5, U.fl(a.y - cam.y) + 0.5, U.fl(b.x - cam.x) + 0.5, U.fl(b.y - cam.y) + 0.5)
  end
end

return R
