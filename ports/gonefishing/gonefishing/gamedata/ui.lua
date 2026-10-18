-- Small drawing helpers for text and HUD bits. The bitmap font is 3x5, drawn at 2x.
local U = require("util")
local lg = love.graphics
local UI = {}

local makeFont = require("font")
UI.font = nil

function UI.load()
  UI.font = makeFont()
  lg.setFont(UI.font)
end

function UI.width(s, sc) return UI.font:getWidth(tostring(s):upper()) * (sc or 2) end

-- text with an optional 1-unit drop shadow
function UI.text(s, x, y, c, sc, align, shadow)
  s = tostring(s):upper()
  sc = sc or 2
  local w = UI.font:getWidth(s) * sc
  if align == "center" then x = x - math.floor(w / 2) elseif align == "right" then x = x - w end
  x, y = U.fl(x), U.fl(y)
  if shadow then
    lg.setColor(shadow[1], shadow[2], shadow[3], shadow[4] or 1)
    local o = math.max(1, math.floor(sc / 2))
    lg.print(s, x + o, y + o, 0, sc, sc)
  end
  c = c or { 1, 1, 1 }
  lg.setColor(c[1], c[2], c[3], c[4] or 1)
  lg.print(s, x, y, 0, sc, sc)
  return w
end

function UI.coin(x, y)
  x, y = U.fl(x), U.fl(y)
  lg.setColor(0.45, 0.30, 0.08); lg.circle("fill", x + 4, y + 4, 4.5)
  lg.setColor(0.98, 0.78, 0.30); lg.circle("fill", x + 4, y + 4, 3.6)
  lg.setColor(1, 0.94, 0.62); lg.rectangle("fill", x + 2, y + 2, 2, 2)
  lg.setColor(0.78, 0.55, 0.16); lg.rectangle("fill", x + 4, y + 3, 1, 3)
end

-- a round controller button glyph with a letter
local BTN = { A = { 0.86, 0.36, 0.30 }, B = { 0.96, 0.78, 0.30 }, X = { 0.34, 0.56, 0.88 }, Y = { 0.40, 0.72, 0.40 } }
function UI.button(label, x, y)
  x, y = U.fl(x), U.fl(y)
  local c = BTN[label]
  if c then
    lg.setColor(0.08, 0.08, 0.1, 0.8); lg.circle("fill", x + 6, y + 7, 6.5)
    lg.setColor(c); lg.circle("fill", x + 6, y + 6, 6)
    UI.text(label, x + 6, y + 1, { 1, 1, 1 }, 2, "center")
    return 14
  end
  local w = UI.width(label, 2) + 8
  lg.setColor(0.08, 0.08, 0.1, 0.8); lg.rectangle("fill", x, y + 1, w, 13, 3, 3)
  lg.setColor(0.86, 0.86, 0.82); lg.rectangle("fill", x, y, w, 12, 3, 3)
  UI.text(label, x + 4, y + 1, { 0.15, 0.15, 0.18 }, 2)
  return w + 2
end

-- a row of hints: { {"A","CAST"}, {"START","TACKLE BOX"} }
function UI.hints(list, x, y, c, align)
  local total = 0
  for _, h in ipairs(list) do total = total + (UI.width(h[1], 2) > 8 and UI.width(h[1], 2) + 10 or 14) + 4 + UI.width(h[2], 2) + 12 end
  if align == "right" then x = x - total elseif align == "center" then x = x - total / 2 end
  for _, h in ipairs(list) do
    x = x + UI.button(h[1], x, y) + 4
    x = x + UI.text(h[2], x, y + 1, c or { 1, 1, 1 }, 2, nil, { 0, 0, 0, 0.5 }) + 12
  end
end

return UI
