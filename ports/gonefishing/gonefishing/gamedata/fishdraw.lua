-- Fish are drawn as bending meshes: the body flexes in a travelling wave that grows
-- toward the tail, and turning around squashes the fish edge-on before it flips.
local U = require("util")
local lg = love.graphics
local FD = {}

local SEG = 16
local meta, meshes = {}, {}

function FD.load(FISH)
  meta = love.filesystem.load("gfx/fish/meta.lua")()
  for _, f in ipairs(FISH) do
    local m = meta[f.id]
    f.fw, f.fh = m.w, m.h
    f.meta = m
  end
end

local function mesh(id)
  local m = meshes[id]
  if m then return m end
  local im = U.img("gfx/fish/" .. id .. ".png")
  local verts = {}
  for i = 0, SEG do
    local u = i / SEG
    verts[#verts + 1] = { 0, 0, u, 0 }
    verts[#verts + 1] = { 0, 0, u, 1 }
  end
  m = lg.newMesh(verts, "strip", "stream")
  m:setTexture(im)
  meshes[id] = m
  return m
end

-- x, y: body centre on screen. face: the head's turn (-1..1, from a spring); tail: the tail's
-- turn, lagging behind the head. While turning, the head swings round first and the body
-- follows, so the fish curls through the turn instead of mirroring flat.
-- phase: tail beat; amp: swimming effort; curl: a steady bend (a hooked fish fighting).
function FD.draw(f, x, y, face, phase, amp, tint, alpha, curl, scale, tail, pitch)
  local mt = f.meta
  local w, h = mt.w, mt.h
  scale = scale or 1
  local m = mesh(f.id)
  amp = amp or 0.4
  curl = curl or 0
  tint = tint or { 1, 1, 1 }
  alpha = alpha or 1
  local th = math.acos(math.max(-1, math.min(1, face)))
  local tt = math.acos(math.max(-1, math.min(1, tail or face)))
  -- lay the slices out along the bending body
  local px = { [0] = 0 }
  local ds = w / SEG * scale
  for i = 1, SEG do
    local a = tt + (th - tt) * ((i - 0.5) / SEG)
    px[i] = px[i - 1] + math.cos(a) * ds
  end
  local uc = mt.cx / w * SEG
  local i0 = math.floor(uc)
  local cxo = px[i0] + (px[math.min(SEG, i0 + 1)] - px[i0]) * (uc - i0)
  local verts = {}
  for i = 0, SEG do
    local u = i / SEG                     -- 0 = tail end of the image, 1 = head
    local k = (1 - u)
    local wave = math.sin(phase * 2 - u * 4.2) * k ^ 1.8
    local dy = (wave * (0.9 + amp * 1.6) + curl * k * k * 6) * h / 22
    local a = tt + (th - tt) * u
    local edge = math.abs(math.cos(a))
    -- the tail foreshortens as it sweeps toward and away from us
    local squash = 1 - 0.18 * k ^ 2 * math.abs(math.cos(phase * 2 - u * 4.2)) * math.min(1, amp + 0.3)
    local vx = x + (px[i] - cxo) * (u < 0.5 and squash or 1)
    local top = y - mt.cy * scale + dy * scale
    local sh = 0.72 + 0.28 * edge          -- seen edge-on, the body is in its own shadow
    local r, g, b = tint[1] * sh, tint[2] * sh, tint[3] * sh
    verts[#verts + 1] = { vx, top, u, 0, r, g, b, alpha }
    verts[#verts + 1] = { vx, top + h * scale, u, 1, r, g, b, alpha }
  end
  -- pitch: nose up (positive) or down, about the body's centre, for climbs, dives and looping turns
  if pitch and pitch ~= 0 then
    local ang = -pitch * (math.cos(th) >= 0 and 1 or -1)
    local c, sn = math.cos(ang), math.sin(ang)
    for _, v in ipairs(verts) do
      local dx, dy = v[1] - x, v[2] - y
      v[1], v[2] = x + dx * c - dy * sn, y + dx * sn + dy * c
    end
  end
  m:setVertices(verts)
  lg.setColor(1, 1, 1, 1)
  lg.draw(m)
end

-- where the mouth is, for a fish drawn at x, y facing `face`
function FD.mouth(f, x, y, face)
  local mt = f.meta
  return x + (mt.mx - mt.cx) * U.sign(face), y + (mt.my - mt.cy)
end

-- a flat sprite for menus (no bending)
function FD.icon(f, x, y, scale, tint, alpha)
  local im = U.img("gfx/fish/" .. f.id .. ".png")
  tint = tint or { 1, 1, 1 }
  lg.setColor(tint[1], tint[2], tint[3], alpha or 1)
  lg.draw(im, U.fl(x), U.fl(y), 0, scale or 1, scale or 1)
end

return FD
