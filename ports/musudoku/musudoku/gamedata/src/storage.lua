-- Saves settings, statistics and the puzzle in progress with love.filesystem.
-- Files are plain Lua table literals, loaded in an empty sandbox.

local theme = require("src.theme")

local storage = {}

local SETTINGS_FILE, STATS_FILE, GAME_FILE = "settings.lua", "stats.lua", "game.lua"
local PACKS_FILE = "packs.lua"
local DAILY_FILE = "daily.lua"
local HISTORY_FILE = "history.lua"

local function serialize(value, out)
    local t = type(value)
    if t == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            out[#out + 1] = "0"
        elseif value == math.floor(value) then
            out[#out + 1] = string.format("%d", value)
        else
            out[#out + 1] = string.format("%.17g", value)
        end
    elseif t == "string" then
        out[#out + 1] = string.format("%q", value)
    elseif t == "boolean" then
        out[#out + 1] = value and "true" or "false"
    elseif t == "table" then
        out[#out + 1] = "{"
        local n = #value
        for i = 1, n do
            serialize(value[i], out)
            out[#out + 1] = ","
        end
        local keys = {}
        for k in pairs(value) do
            if not (type(k) == "number" and k >= 1 and k <= n and k == math.floor(k)) then
                keys[#keys + 1] = k
            end
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, k in ipairs(keys) do
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                out[#out + 1] = k .. "="
            else
                out[#out + 1] = "["
                serialize(k, out)
                out[#out + 1] = "]="
            end
            serialize(value[k], out)
            out[#out + 1] = ","
        end
        out[#out + 1] = "}"
    else
        out[#out + 1] = "nil"
    end
end

function storage.encode(value)
    local out = { "return " }
    serialize(value, out)
    return table.concat(out)
end

function storage.decode(text)
    if type(text) ~= "string" then return nil end
    local chunk = loadstring(text)
    if not chunk then return nil end
    setfenv(chunk, {})
    local ok, result = pcall(chunk)
    if ok and type(result) == "table" then return result end
    return nil
end

local function read(name)
    if not love.filesystem.getInfo(name) then return nil end
    local text = love.filesystem.read(name)
    return storage.decode(text)
end

local function write(name, value)
    -- Write to a temporary file first so a power-off mid-write can't
    -- leave a half-written save behind.
    local tmp = name .. ".tmp"
    local ok = love.filesystem.write(tmp, storage.encode(value))
    if not ok then return false end
    local dir = love.filesystem.getSaveDirectory()
    local renamed = os.rename(dir .. "/" .. tmp, dir .. "/" .. name)
    if not renamed then
        love.filesystem.remove(tmp)
        return love.filesystem.write(name, storage.encode(value))
    end
    return true
end

-- Settings ------------------------------------------------------------------

storage.DEFAULT_SETTINGS = {
    theme = "cyanotype",
    mistakes = true,
    matching = true,
    autoclear = true,
    largeNotes = false,
    timer = true,
    sound = true,
    hints = "off", -- "off" | "explained" | "instant"
    boardOnly = false, -- distraction-free: just the board, centered
    generator = "classic", -- "classic" | "dlx" (Dancing Links)
    input = "cell", -- "cell" (pick a cell, then its number) | "number" (the other way round)
    pad = "panel", -- cell first: "panel" (the side panel's number tiles) | "popup" (a 3x3 pad by the cell)
    shoulders = "move", -- "move" (L1 / R1 move, L2 / R2 undo) | "undo" (swapped, the layout before 1.3.3)
}

local CHOICES = {
    hints = { off = true, explained = true, instant = true },
    theme = {},
    generator = { classic = true, dlx = true },
    input = { cell = true, number = true },
    pad = { panel = true, popup = true },
    shoulders = { move = true, undo = true },
}
for _, key in ipairs(theme.ORDER) do CHOICES.theme[key] = true end

function storage.loadSettings()
    local saved = read(SETTINGS_FILE) or {}
    local settings = {}
    for k, v in pairs(storage.DEFAULT_SETTINGS) do
        if type(saved[k]) == type(v) then settings[k] = saved[k] else settings[k] = v end
        if CHOICES[k] and not CHOICES[k][settings[k]] then settings[k] = v end
    end
    return settings
end

function storage.saveSettings(settings)
    return write(SETTINGS_FILE, settings)
end

-- Statistics ----------------------------------------------------------------

local function emptyStats()
    local stats = {}
    for _, d in ipairs({ "easy", "medium", "hard", "expert", "master" }) do
        stats[d] = require("src.records").empty()
    end
    return stats
end
storage.emptyStats = emptyStats

function storage.loadStats()
    local saved = read(STATS_FILE)
    local stats = emptyStats()
    if saved then
        for d, entry in pairs(stats) do
            local s = saved[d]
            if type(s) == "table" then
                for k in pairs(entry) do entry[k] = tonumber(s[k]) or 0 end
            end
        end
    end
    return stats
end

function storage.saveStats(stats)
    return write(STATS_FILE, stats)
end

-- Puzzle pack progress ---------------------------------------------------------

function storage.loadPackProgress()
    return read(PACKS_FILE) or {}
end

function storage.savePackProgress(data)
    return write(PACKS_FILE, data)
end

-- Daily puzzles ---------------------------------------------------------------
-- days["YYYY-MM-DD"] = seconds taken, for every day whose puzzle was solved.

function storage.loadDaily()
    local saved = read(DAILY_FILE)
    local days = {}
    if saved and type(saved.days) == "table" then
        for k, v in pairs(saved.days) do
            if type(k) == "string" and tonumber(v) then days[k] = tonumber(v) end
        end
    end
    return { days = days }
end

function storage.saveDaily(data)
    return write(DAILY_FILE, data)
end

-- Recent solves ---------------------------------------------------------------

function storage.loadHistory()
    return require("src.history").clean(read(HISTORY_FILE))
end

function storage.saveHistory(list)
    return write(HISTORY_FILE, list)
end

-- Game in progress ----------------------------------------------------------

function storage.loadGame()
    return read(GAME_FILE)
end

function storage.saveGame(data)
    return write(GAME_FILE, data)
end

function storage.clearGame()
    if love.filesystem.getInfo(GAME_FILE) then love.filesystem.remove(GAME_FILE) end
end

function storage.hasGame()
    return love.filesystem.getInfo(GAME_FILE) ~= nil
end

return storage
