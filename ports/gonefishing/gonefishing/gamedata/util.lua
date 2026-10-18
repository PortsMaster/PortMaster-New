-- Shared constants, helpers and runtime state for Gone Fishing.
local U = {}
local lg = love.graphics

U.W, U.H = 512, 384          -- the canvas (2x on the Brick's 1024x768 screen)
U.WORLD_W = 4096             -- each place is eight screens wide
U.YH = 150                   -- horizon line with the camera at rest
U.SHORE_Y = 210              -- nearest shore meets the water
U.CUT_Y = 300                -- front water surface: the boat's waterline
U.UW_BOT = 560               -- bottom of the underwater view
U.CAM_FISH = 176             -- how far the camera dips when you fish
U.DAY_LENGTH = 720           -- real seconds per in-game day

G = G or {}

U.rnd = love.math.random
function U.clamp(v, a, b) if v < a then return a elseif v > b then return b end return v end
function U.lerp(a, b, t) return a + (b - a) * t end
function U.mix(a, b, t)
  return { U.lerp(a[1], b[1], t), U.lerp(a[2], b[2], t), U.lerp(a[3], b[3], t), (a[4] or 1) + ((b[4] or 1) - (a[4] or 1)) * t }
end
function U.mul(a, b) return { a[1] * b[1], a[2] * b[2], a[3] * b[3], a[4] } end
function U.rr(a, b) return a + U.rnd() * (b - a) end
function U.fl(v) return math.floor(v + 0.5) end
function U.sign(v) return v < 0 and -1 or 1 end

function U.easeOutQuad(t) t = U.clamp(t, 0, 1); return 1 - (1 - t) * (1 - t) end
function U.easeInOutSine(t) t = U.clamp(t, 0, 1); return -(math.cos(math.pi * t) - 1) / 2 end
function U.easeOutBack(t)
  t = U.clamp(t, 0, 1)
  local c1, c3 = 1.70158, 2.70158
  return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end
function U.easeOutCubic(t) t = U.clamp(t, 0, 1); return 1 - (1 - t) ^ 3 end
-- smooth wandering value in about -1..1 made of waves that never line up
function U.wander(t, seed)
  seed = seed or 0
  return math.sin(t * 0.73 + seed) * 0.5 + math.sin(t * 1.31 + seed * 2.1) * 0.3 + math.sin(t * 2.17 + seed * 3.7) * 0.2
end
-- damped springs: pulled toward a target, they overshoot and settle
function U.spring(x) return { x = x or 0, v = 0 } end
function U.stepSpring(sp, target, k, c, dt)
  local n = math.max(1, math.ceil(dt / 0.008))
  local h = dt / n
  for _ = 1, n do
    local a = k * (target - sp.x) - c * sp.v
    sp.v = sp.v + a * h
    sp.x = sp.x + sp.v * h
  end
end

-- images
U.IMG = {}
function U.img(path)
  local im = U.IMG[path]
  if not im then
    im = lg.newImage(path)
    U.IMG[path] = im
  end
  return im
end
function U.drop(path)
  if U.IMG[path] then U.IMG[path]:release(); U.IMG[path] = nil end
end

-- a strip of equal frames
U.STRIP = {}
function U.strip(path, frames)
  local s = U.STRIP[path]
  if s then return s end
  local im = U.img(path)
  local iw, ih = im:getDimensions()
  s = { img = im, w = iw / frames, h = ih, n = frames, q = {} }
  for i = 1, frames do s.q[i] = lg.newQuad((i - 1) * s.w, 0, s.w, ih, iw, ih) end
  U.STRIP[path] = s
  return s
end
-- frames laid out in a grid (cols across), read left-to-right, top-to-bottom
function U.grid(path, fw, fh, cols, n)
  local s = U.STRIP[path]
  if s then return s end
  local im = U.img(path)
  local iw, ih = im:getDimensions()
  s = { img = im, w = fw, h = fh, n = n, q = {} }
  for i = 1, n do
    local c, r = (i - 1) % cols, math.floor((i - 1) / cols)
    s.q[i] = lg.newQuad(c * fw, r * fh, fw, fh, iw, ih)
  end
  U.STRIP[path] = s
  return s
end

function U.drawStrip(s, frame, x, y, flip, sx, sy, ox, oy)
  local q = s.q[((frame or 1) - 1) % s.n + 1]
  sx, sy = sx or 1, sy or 1
  ox, oy = ox or 0, oy or 0
  if flip then
    lg.draw(s.img, q, U.fl(x), U.fl(y), 0, -sx, sy, s.w - ox, oy)
  else
    lg.draw(s.img, q, U.fl(x), U.fl(y), 0, sx, sy, ox, oy)
  end
end

function U.setc(c, a) lg.setColor(c[1], c[2], c[3], a or c[4] or 1) end

-- a vertical gradient as a mesh (top colour, bottom colour)
function U.vgrad(x, y, w, h, c1, c2)
  local m = U._grad
  if not m then
    m = lg.newMesh(4, "fan", "stream")
    U._grad = m
  end
  m:setVertices({
    { x, y, 0, 0, c1[1], c1[2], c1[3], c1[4] or 1 },
    { x + w, y, 1, 0, c1[1], c1[2], c1[3], c1[4] or 1 },
    { x + w, y + h, 1, 1, c2[1], c2[2], c2[3], c2[4] or 1 },
    { x, y + h, 0, 1, c2[1], c2[2], c2[3], c2[4] or 1 },
  })
  lg.setColor(1, 1, 1, 1)
  lg.draw(m)
end

return U
