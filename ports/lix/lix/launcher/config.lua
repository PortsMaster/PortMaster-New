-- Lix launcher settings, saved as shell variables in lix.cfg (sourced by Lix.sh).
-- The player name goes into Lix's own user/options.sdl: without one Lix asks for it
-- on first start, which needs a keyboard.

local config = {
    title = "Lix",
    subtitle = "Lemmings-like puzzle game",
    help = "Left stick moves the mouse, A clicks.",
    items = {
        { id = "USER_NAME", label = "Player name", kind = "text", maxlen = 20,
          help = "Shown on replays, levels you make and network games." },
        { id = "LIX_CURSOR_MIN_SCALE", label = "Mouse cursor size", kind = "choice",
          choices = { { 1, "Normal" }, { 2, "2x" }, { 3, "3x" }, { 4, "4x" } },
          help = "Minimum cursor scale. Bigger is easier to see on small screens." },
        { id = "MOUSE_SCALE", label = "Mouse speed", kind = "choice",
          choices = { { 8192, "Slow" }, { 6144, "Normal" }, { 4096, "Fast" }, { 3072, "Faster" } },
          help = "How fast the left stick moves the cursor." },
        { id = "SCREEN_MODE", label = "Fullscreen", kind = "choice",
          choices = { { 2, "Hardware" }, { 1, "Software" } },
          help = "Hardware runs at the device resolution. Try Software if the picture is wrong." },
    },
}

local DEFAULTS = { USER_NAME = "Player", LIX_CURSOR_MIN_SCALE = 2, MOUSE_SCALE = 6144, SCREEN_MODE = 2 }

-- user/options.sdl next to lix.cfg
local function optionsPath(path) return (path:match("^(.*)/") or ".") .. "/user/options.sdl" end

local function readLines(path)
    local lines, f = {}, io.open(path, "r")
    if f then
        for l in f:lines() do lines[#lines + 1] = l end
        f:close()
    end
    return lines
end

function config.load(path)
    local v = {}
    for k, d in pairs(DEFAULTS) do v[k] = d end
    for _, l in ipairs(readLines(path)) do
        local k, n = l:match("^([%w_]+)=(%d+)$")
        if k and v[k] then v[k] = tonumber(n) end
    end
    for _, l in ipairs(readLines(optionsPath(path))) do
        local name = l:match('^userName "(.*)"$')
        if name and name ~= "" then v.USER_NAME = name end
    end
    return v
end

-- Sets userName in user/options.sdl and keeps Lix's other options. A new file also
-- gets screenMode 1 (fullscreen at the device's resolution).
local function saveUserName(path, name)
    local opts = optionsPath(path)
    os.execute("mkdir -p '" .. opts:match("^(.*)/") .. "'")
    local lines, found = readLines(opts), false
    if #lines == 0 then lines[1] = "screenMode 1" end
    for i, l in ipairs(lines) do
        if l:match("^userName ") then lines[i], found = 'userName "' .. name .. '"', true end
    end
    if not found then table.insert(lines, 1, 'userName "' .. name .. '"') end
    local f, err = io.open(opts, "w")
    if not f then return false, err end
    f:write(table.concat(lines, "\n"), "\n")
    f:close()
    return true
end

function config.save(path, v)
    local ok, err = saveUserName(path, v.USER_NAME ~= "" and v.USER_NAME or DEFAULTS.USER_NAME)
    if not ok then return false, err end
    local f
    f, err = io.open(path, "w")
    if not f then return false, err end
    for _, it in ipairs(config.items) do
        if it.kind ~= "text" then f:write(it.id, "=", v[it.id], "\n") end
    end
    f:close()
    return true
end

return config
