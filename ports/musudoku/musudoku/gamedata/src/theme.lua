-- Color themes. Cyanotype is the default: Prussian-blue paper with white
-- givens and mustard player digits (a nod to MustardOS). Paper is a light
-- theme for bright rooms. Chalkboard is green slate with chalk dust, chalk
-- digits and a wooden frame around the board.

local theme = {}

local function hex(s)
    s = s:gsub("#", "")
    return {
        tonumber(s:sub(1, 2), 16) / 255,
        tonumber(s:sub(3, 4), 16) / 255,
        tonumber(s:sub(5, 6), 16) / 255,
    }
end

local PALETTES = {
    cyanotype = {
        name = "Cyanotype",
        bg = "#13274A",        -- screen background
        board = "#1A3361",     -- cell surface
        peer = "#21407A",      -- row, column and box of the cursor
        same = "#2C5597",      -- cells holding the same digit as the cursor
        line = "#2E4C82",      -- thin cell lines
        boxLine = "#A9C0E6",   -- thick box lines
        given = "#F4F7FB",     -- puzzle digits
        user = "#F2C14E",      -- player digits
        note = "#9DB4DB",      -- pencil marks
        error = "#FF7B6B",
        accent = "#F2C14E",    -- cursor, selections
        accentText = "#13274A",
        text = "#F4F7FB",
        muted = "#8FA6CF",
        panel = "#1A3361",
        chip = "#2C4A80",      -- button glyph fill
        chipText = "#F4F7FB",
        scrim = "#0A1630",
    },
    paper = {
        name = "Paper",
        bg = "#D9E0E8",
        board = "#F7F9FB",
        peer = "#E6ECF4",
        same = "#C9D9F1",
        line = "#C3CCD8",
        boxLine = "#2A3442",
        given = "#1E2733",
        user = "#2B57CF",
        note = "#5E6B7C",
        error = "#D23C3C",
        accent = "#2B57CF",
        accentText = "#F7F9FB",
        text = "#1E2733",
        muted = "#5E6B7C",
        panel = "#F7F9FB",
        chip = "#C3CCD8",
        chipText = "#1E2733",
        scrim = "#7D8896",
    },
    sakura = {
        name = "Sakura",
        bg = "#FBEFF2",
        board = "#FFFAFB",
        peer = "#FBE6EC",
        same = "#F7DBE4",
        line = "#E8C6D2",
        boxLine = "#8E4A63",
        given = "#3B2830",     -- bark brown
        user = "#C2477A",      -- deep blossom pink
        note = "#8C6B78",
        error = "#D9480F",
        accent = "#F29BB8",    -- blossom pink
        accentText = "#3B2830",
        mark = "#B83D6E",
        text = "#3B2830",
        muted = "#8C6B78",
        panel = "#FFFAFB",
        chip = "#F2CDD9",
        chipText = "#3B2830",
        scrim = "#7A5A66",
    },
    frankfurt = {
        name = "Frankfurt",
        bg = "#E9EDF3",
        board = "#FFFFFF",
        peer = "#E8EDF6",
        same = "#FFE9B8",      -- light Lufthansa yellow
        line = "#CDD5E2",
        boxLine = "#05164D",   -- Lufthansa blue
        given = "#05164D",
        user = "#1F5BB5",
        note = "#5B6785",
        error = "#D0202E",
        accent = "#FFAD00",    -- Lufthansa yellow
        accentText = "#05164D",
        mark = "#05164D",
        text = "#05164D",
        muted = "#5B6785",
        panel = "#FFFFFF",
        chip = "#05164D",
        chipText = "#FFFFFF",
        scrim = "#3B4560",
    },
    solarizedLight = {
        name = "Solarized Light",
        bg = "#EEE8D5",
        board = "#FDF6E3",
        peer = "#F3ECD6",
        same = "#EBE2C8",
        line = "#D8CDAF",
        boxLine = "#586E75",
        given = "#586E75",
        user = "#268BD2",
        note = "#657B83",
        error = "#DC322F",
        accent = "#B58900",
        accentText = "#002B36",
        mark = "#CB4B16",
        text = "#073642",
        muted = "#657B83",
        panel = "#FDF6E3",
        chip = "#E4DCC4",
        chipText = "#073642",
        scrim = "#93A1A1",
    },
    solarizedDark = {
        name = "Solarized Dark",
        bg = "#002B36",
        board = "#073642",
        peer = "#0B3F4C",
        same = "#124B59",
        line = "#1D4F5C",
        boxLine = "#93A1A1",
        given = "#EEE8D5",
        user = "#2AA198",
        note = "#839496",
        error = "#F05D5A",
        accent = "#B58900",
        accentText = "#002B36",
        text = "#EEE8D5",
        muted = "#839496",
        panel = "#073642",
        chip = "#0E4A58",
        chipText = "#EEE8D5",
        scrim = "#001A21",
    },
    nord = {
        name = "Nord",
        bg = "#2E3440",
        board = "#3B4252",
        peer = "#434C5E",
        same = "#4C566A",
        line = "#525C70",
        boxLine = "#81A1C1",
        given = "#ECEFF4",
        user = "#EBCB8B",
        note = "#9AA5B8",
        error = "#D9737C",
        accent = "#88C0D0",
        accentText = "#2E3440",
        text = "#ECEFF4",
        muted = "#A0AABB",
        panel = "#3B4252",
        chip = "#4C566A",
        chipText = "#ECEFF4",
        scrim = "#1B1F27",
    },
    gruvbox = {
        name = "Gruvbox",
        bg = "#1D2021",
        board = "#282828",
        peer = "#32302F",
        same = "#45403D",
        line = "#3C3836",
        boxLine = "#A89984",
        given = "#EBDBB2",
        user = "#FABD2F",
        note = "#A89984",
        error = "#FB4934",
        accent = "#FE8019",
        accentText = "#1D2021",
        text = "#EBDBB2",
        muted = "#A89984",
        panel = "#282828",
        chip = "#504945",
        chipText = "#EBDBB2",
        scrim = "#0D0E0E",
    },
    chalkboard = {
        name = "Chalkboard",
        bg = "#1D3027",
        board = "#233A2F",
        peer = "#2C4739",
        same = "#3A5C49",
        line = "#4D6E5C",
        boxLine = "#D8DFD3",   -- chalk lines
        given = "#F1EFE6",     -- white chalk
        user = "#F5D76E",      -- yellow chalk
        note = "#A9C2B3",
        error = "#FF8F80",
        accent = "#F4A3BC",    -- pink chalk
        accentText = "#1D3027",
        text = "#F1EFE6",
        muted = "#9DB5A7",
        panel = "#263F33",
        chip = "#3A5747",
        chipText = "#F1EFE6",
        scrim = "#0C1611",
        frame = "#8A5A36",     -- wood around the board
        grain = "#5E3B21",
        dust = true,           -- chalk dust on slate surfaces
    },
}

theme.ORDER = {
    "cyanotype", "paper", "sakura", "frankfurt", "solarizedLight", "solarizedDark",
    "nord", "gruvbox", "chalkboard",
}

-- `mark` is the accent for text and thin outlines (cursor, matching notes,
-- selected values). It defaults to `accent`; themes whose accent is too pale
-- for that on a light board set their own.
local compiled = {}
for key, palette in pairs(PALETTES) do
    local c = {}
    for k, v in pairs(palette) do
        c[k] = (type(v) == "string" and v:sub(1, 1) == "#") and hex(v) or v
    end
    c.mark = c.mark or c.accent
    compiled[key] = c
end

theme.current = compiled.cyanotype
theme.key = "cyanotype"

function theme.use(key)
    if compiled[key] then
        theme.current = compiled[key]
        theme.key = key
    end
end

function theme.name(key)
    return compiled[key] and compiled[key].name or key
end

-- Set the draw color from a theme slot, with optional alpha.
function theme.set(slot, alpha)
    local c = theme.current[slot]
    love.graphics.setColor(c[1], c[2], c[3], alpha or 1)
end

-- Blend two theme slots (t = 0 gives a, 1 gives b).
function theme.mix(a, b, t, alpha)
    local ca, cb = theme.current[a], theme.current[b]
    love.graphics.setColor(
        ca[1] + (cb[1] - ca[1]) * t,
        ca[2] + (cb[2] - ca[2]) * t,
        ca[3] + (cb[3] - ca[3]) * t,
        alpha or 1)
end

function theme.get(slot)
    return theme.current[slot]
end

-- Chalkboard extras -----------------------------------------------------------
-- Themes with `dust` get a chalk dust texture on slate surfaces, and themes
-- with `frame` a wooden frame around the board. For other themes these draw
-- nothing. Both are made in code, so there are no image files.

local DUST = 256 -- size of the repeating dust tile
local dustImage, dustQuad
local grainCache = {}

local function makeDust()
    local rng = love.math.newRandomGenerator(1729)
    local alpha = {}
    for i = 0, DUST * DUST - 1 do alpha[i] = 0 end
    local function add(x, y, a)
        local i = (y % DUST) * DUST + (x % DUST) -- wraps, so the tile repeats seamlessly
        alpha[i] = math.min(1, alpha[i] + a)
    end
    -- eraser smudges: wide, faint ellipses
    for _ = 1, 16 do
        local cx, cy = rng:random(0, DUST - 1), rng:random(0, DUST - 1)
        local rx, ry = rng:random(24, 70), rng:random(6, 18)
        local a = 0.015 + rng:random() * 0.03
        for dy = -ry, ry do
            for dx = -rx, rx do
                local d = (dx / rx) ^ 2 + (dy / ry) ^ 2
                if d < 1 then add(cx + dx, cy + dy, a * (1 - d)) end
            end
        end
    end
    -- specks of chalk
    for _ = 1, 1600 do
        add(rng:random(0, DUST - 1), rng:random(0, DUST - 1), 0.04 + rng:random() * 0.1)
    end
    local data = love.image.newImageData(DUST, DUST)
    data:mapPixel(function(x, y) return 1, 1, 1, alpha[y * DUST + x] end)
    dustImage = love.graphics.newImage(data)
    dustImage:setWrap("repeat", "repeat")
    dustQuad = love.graphics.newQuad(0, 0, DUST, DUST, DUST, DUST)
end

-- Chalk dust over the w x h area at (x, y). The pattern is fixed to the
-- screen, so neighbouring surfaces look like one slate. With r, it's clipped
-- to a rectangle with corners of radius r.
function theme.texture(x, y, w, h, alpha, r)
    if not theme.current.dust then return end
    if not dustImage then makeDust() end
    if r then
        love.graphics.stencil(function() love.graphics.rectangle("fill", x, y, w, h, r, r) end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
    end
    dustQuad:setViewport(x, y, w, h, DUST, DUST)
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(dustImage, dustQuad, x, y)
    if r then love.graphics.setStencilTest() end
end

-- Grain streaks for a frame: per side, a few thin lines along it, broken
-- into segments. Fixed per size, so the wood doesn't change between frames.
local function grainFor(w, h, t)
    local key = w .. "x" .. h
    if grainCache[key] then return grainCache[key] end
    local rng = love.math.newRandomGenerator(w * 7 + h)
    local lines = {}
    local function side(len, horizontal, fx, fy)
        for _ = 1, 3 do
            local off = rng:random(2, t - 2)
            local pos = rng:random(4, 30)
            while pos < len - 12 do
                local seg = rng:random(30, 110)
                local stop = math.min(len - 8, pos + seg)
                if horizontal then
                    lines[#lines + 1] = { fx + pos, fy + off, fx + stop, fy + off }
                else
                    lines[#lines + 1] = { fx + off, fy + pos, fx + off, fy + stop }
                end
                pos = stop + rng:random(10, 40)
            end
        end
    end
    side(w + 2 * t, true, -t, -t)     -- top rail
    side(w + 2 * t, true, -t, h)      -- bottom rail
    side(h, false, -t, 0)             -- left stile
    side(h, false, w, 0)              -- right stile
    grainCache[key] = lines
    return lines
end

-- Wooden frame around the w x h area at (x, y), drawn behind it.
function theme.frame(x, y, w, h, alpha)
    local wood, grain = theme.current.frame, theme.current.grain
    if not wood then return end
    alpha = alpha or 1
    local t = 9 -- thickness
    love.graphics.setColor(grain[1], grain[2], grain[3], alpha)
    love.graphics.rectangle("fill", x - t - 1, y - t - 1, w + 2 * t + 2, h + 2 * t + 2, 12, 12)
    love.graphics.setColor(wood[1], wood[2], wood[3], alpha)
    love.graphics.rectangle("fill", x - t, y - t, w + 2 * t, h + 2 * t, 11, 11)
    love.graphics.setColor(grain[1], grain[2], grain[3], 0.55 * alpha)
    love.graphics.setLineWidth(1)
    for _, l in ipairs(grainFor(w, h, t)) do
        love.graphics.line(x + l[1] + 0.5, y + l[2] + 0.5, x + l[3] + 0.5, y + l[4] + 0.5)
    end
end

return theme
