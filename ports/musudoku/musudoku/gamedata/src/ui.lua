-- Layout is designed on a 720x480 canvas (the RG34XXSP's native screen) and
-- scaled to fit any other resolution. Fonts are rasterized at the real pixel
-- size and drawn with the inverse scale, so text stays sharp when scaled.

local theme = require("src.theme")

local ui = { W = 720, H = 480, s = 1, ox = 0, oy = 0 }

local FONT_FILES = {
    regular = "assets/fonts/AtkinsonHyperlegible-Regular.ttf",
    bold = "assets/fonts/AtkinsonHyperlegible-Bold.ttf",
}
local CAP_HEIGHT = 0.70 -- Atkinson's cap/figure height as a fraction of the size

local cache = {}

function ui.resize(w, h)
    ui.s = math.min(w / ui.W, h / ui.H)
    ui.ox = math.floor((w - ui.W * ui.s) / 2)
    ui.oy = math.floor((h - ui.H * ui.s) / 2)
    cache = {}
end

function ui.font(size, weight)
    weight = weight or "regular"
    local px = math.max(6, math.floor(size * ui.s + 0.5))
    local key = weight .. px
    local f = cache[key]
    if not f then
        local ok, loaded = pcall(love.graphics.newFont, FONT_FILES[weight], px)
        f = ok and loaded or love.graphics.newFont(px)
        cache[key] = f
    end
    return f
end

function ui.begin()
    love.graphics.push()
    love.graphics.translate(ui.ox, ui.oy)
    love.graphics.scale(ui.s)
end

function ui.finish()
    love.graphics.pop()
end

function ui.width(str, size, weight)
    return ui.font(size, weight):getWidth(str) / ui.s
end

-- Round a canvas coordinate to a whole screen pixel. Glyphs drawn between
-- pixels get smeared by linear filtering, so text always starts on one.
local function snap(v)
    return math.floor(v * ui.s + 0.5) / ui.s
end

-- Draw text with its top-left at (x, y). With `align` ("left", "center",
-- "right") the text is laid out inside `width`.
function ui.text(str, x, y, size, weight, align, width)
    local f = ui.font(size, weight)
    love.graphics.setFont(f)
    local inv = 1 / ui.s
    if align then
        love.graphics.printf(str, snap(x), snap(y), width * ui.s, align, 0, inv, inv)
    else
        love.graphics.print(str, snap(x), snap(y), 0, inv, inv)
    end
end

-- Height of `str` wrapped to `width`.
function ui.wrapHeight(str, size, weight, width)
    local f = ui.font(size, weight)
    local _, lines = f:getWrap(str, width * ui.s)
    return #lines * f:getHeight() / ui.s
end

-- Draw text so its figures/capitals are vertically centered on cy.
-- align: "left" (x is the left edge), "center" (x is the middle), "right".
function ui.centered(str, x, cy, size, weight, align)
    local f = ui.font(size, weight)
    love.graphics.setFont(f)
    local inv = 1 / ui.s
    local w = f:getWidth(str) * inv
    local top = cy + (size * CAP_HEIGHT) / 2 - f:getBaseline() * inv
    local left = x
    if align == "center" or align == nil then left = x - w / 2
    elseif align == "right" then left = x - w end
    love.graphics.print(str, snap(left), snap(top), 0, inv, inv)
    return w
end

-- Like ui.centered, but the text sits on baseline y, so text in different
-- sizes lines up.
function ui.onBaseline(str, x, y, size, weight, align)
    return ui.centered(str, x, y - size * CAP_HEIGHT / 2, size, weight, align)
end

-- Controller button glyphs ---------------------------------------------------
-- k scales a glyph (default 1).

local ROUND = { A = true, B = true, X = true, Y = true }

function ui.glyphWidth(label, k)
    k = k or 1
    if ROUND[label] then return 20 * k end
    return ui.width(label, 11 * k, "bold") + 14 * k
end

-- Draws a button glyph with its left edge at x, centered on cy. Returns width.
function ui.glyph(label, x, cy, alpha, k)
    k = k or 1
    local w = ui.glyphWidth(label, k)
    theme.set("chip", alpha)
    if ROUND[label] then
        love.graphics.circle("fill", x + w / 2, cy, w / 2)
        theme.set("chipText", alpha)
        ui.centered(label, x + w / 2, cy, 12 * k, "bold", "center")
    else
        local h = 18 * k
        love.graphics.rectangle("fill", x, cy - h / 2, w, h, h / 2, h / 2)
        theme.set("chipText", alpha)
        ui.centered(label, x + w / 2, cy, 11 * k, "bold", "center")
    end
    return w
end

-- A row of {button, label} pairs. align "left" starts at x, "right" ends at x.
-- size is the label size (default 15), k the glyph scale (default 1).
function ui.hints(list, x, cy, align, alpha, size, k)
    size = size or 15
    local gap, inner = 18, 6 * (k or 1)
    local total = 0
    for n, item in ipairs(list) do
        total = total + ui.glyphWidth(item[1], k) + inner + ui.width(item[2], size)
        if n < #list then total = total + gap end
    end
    local cx = (align == "right") and (x - total) or (align == "center" and x - total / 2 or x)
    for _, item in ipairs(list) do
        cx = cx + ui.glyph(item[1], cx, cy, alpha, k) + inner
        theme.set("muted", alpha)
        cx = cx + ui.centered(item[2], cx, cy, size, "regular", "left") + gap
    end
end

-- A grid of {button, label} pairs: rows[r] = { left, right (optional) },
-- cols = the x of each column, the first row centered on cy. In each column
-- every glyph is centered in a slot as wide as the column's widest glyph, so
-- glyphs and labels line up down the column. size and k as in ui.hints.
function ui.legend(rows, cols, cy, step, alpha, size, k)
    local slots = {}
    for _, row in ipairs(rows) do
        for c, item in ipairs(row) do
            slots[c] = math.max(slots[c] or 0, math.ceil(ui.glyphWidth(item[1], k)))
        end
    end
    for r, row in ipairs(rows) do
        local y = cy + (r - 1) * step
        for c, item in ipairs(row) do
            local offset = math.floor((slots[c] - ui.glyphWidth(item[1], k)) / 2 + 0.5)
            ui.glyph(item[1], cols[c] + offset, y, alpha, k)
            theme.set("muted", alpha)
            ui.centered(item[2], cols[c] + slots[c] + 6 * (k or 1), y, size or 15, "regular", "left")
        end
    end
end

-- Shapes ---------------------------------------------------------------------

function ui.rect(mode, x, y, w, h, r)
    love.graphics.rectangle(mode, x, y, w, h, r or 0, r or 0)
end

-- Dim the screen and draw a centered card for menus and dialogs.
function ui.card(w, h, p)
    p = p or 1
    theme.set("scrim", 0.72 * p)
    love.graphics.rectangle("fill", 0, 0, ui.W, ui.H)
    local x, y = (ui.W - w) / 2, (ui.H - h) / 2 + (1 - p) * 12
    theme.set("bg", p)
    ui.rect("fill", x, y, w, h, 14)
    theme.texture(x, y, w, h, p, 14)
    theme.set("boxLine", 0.6 * p)
    love.graphics.setLineWidth(2)
    ui.rect("line", x, y, w, h, 14)
    return x, y
end

function ui.ease(t)
    t = math.max(0, math.min(1, t))
    return 1 - (1 - t) ^ 3
end

-- 49151 -> "49,151"
-- `str`, shortened with "..." if needed to fit `width` at this size.
function ui.fit(str, width, size, weight)
    if ui.width(str, size, weight) <= width then return str end
    local utf8 = require("utf8")
    local s = str
    while #s > 0 and ui.width(s .. "...", size, weight) > width do
        s = s:sub(1, (utf8.offset(s, -1) or #s) - 1)
    end
    return s .. "..."
end

function ui.number(n)
    local s = tostring(math.floor(n))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

function ui.formatTime(seconds)
    seconds = math.floor(seconds or 0)
    local h = math.floor(seconds / 3600)
    local m = math.floor(seconds / 60) % 60
    local s = seconds % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
    return string.format("%d:%02d", m, s)
end

return ui
