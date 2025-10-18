-- Config manager for Max Payne settings
local config = {}

-- Default settings
local settings = {
    use_bloom = 1,
    trilinear_filter = 1,
    disable_mipmaps = 0,
    language = 0,
    crouch_toggle = 1,
    character_shadows = 1,
    drop_highest_lod = 0,
    show_weapon_menu = 0,
    vsync_enabled = 1,
    decal_limit = 0.5,
    debris_limit = 1.0,
    mod_file = "",
    force_widescreen = 0,
    stick_deadzone = 0.1,
    aspect_ratio_x_mult = 1.18,
    aspect_ratio_y_mult = 0.84
}

local defaultSettings = {}
for k, v in pairs(settings) do
    defaultSettings[k] = v
end

-- Metadata for settings
local meta = {
    use_bloom = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Bloom"
    },
    trilinear_filter = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Trilinear Filter"
    },
    disable_mipmaps = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Disable Mipmaps"
    },
    language = {
        type = "int",
        min = 0,
        max = 6,
        step = 1,
        label = "Language"
    },
    crouch_toggle = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Crouch Toggle"
    },
    character_shadows = {
        type = "int",
        min = 0,
        max = 2,
        step = 1,
        label = "Character Shadows"
    },
    drop_highest_lod = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Drop Highest LOD"
    },
    show_weapon_menu = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Show Weapon Menu"
    },
    vsync_enabled = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "VSync"
    },
    decal_limit = {
        type = "float",
        min = 0.0,
        max = 1.0,
        step = 0.01,
        label = "Decal Limit"
    },
    debris_limit = {
        type = "float",
        min = 0.0,
        max = 3.0,
        step = 0.01,
        label = "Debris Limit"
    },
    mod_file = {
        type = "string",
        maxlen = 255,
        label = "Mod File"
    },
    force_widescreen = {
        type = "int",
        min = 0,
        max = 1,
        step = 1,
        label = "Force Widescreen"
    },
    stick_deadzone = {
        type = "float",
        min = 0.0,
        max = 1.0,
        step = 0.01,
        label = "Stick Deadzone"
    },
    aspect_ratio_x_mult = {
        type = "float",
        min = 0.5,
        max = 2.0,
        step = 0.01,
        label = "Aspect X Mult"
    },
    aspect_ratio_y_mult = {
        type = "float",
        min = 0.5,
        max = 2.0,
        step = 0.01,
        label = "Aspect Y Mult"
    }
}

-- Display order for settings
local order = {"stick_deadzone", "force_widescreen", "use_bloom", "trilinear_filter", "disable_mipmaps", "language",
               "character_shadows", "drop_highest_lod", "vsync_enabled", "decal_limit", "debris_limit",
               "aspect_ratio_x_mult", "aspect_ratio_y_mult"}

-- Language names
local languageNames = {
    [0] = "English",
    [1] = "French",
    [2] = "Spanish",
    [3] = "Italian",
    [4] = "Russian",
    [5] = "Japanese",
    [6] = "German"
}

local shadowNames = {
    [0] = "OFF",
    [1] = "Blob",
    [2] = "Foot"
}

local FILE_PATH = "conf/config.txt"

-- Utility functions
local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function roundToStep(v, step)
    return math.floor((v / step) + 0.5) * step
end

-- Parse config text
local function parseConfigText(text)
    for line in (text or ""):gmatch("[^\r\n]+") do
        local s = line:gsub("^%s+", ""):gsub("%s+$", "")
        if s ~= "" and not s:match("^//") then
            s = s:gsub("//.*$", "")
            local key, val = s:match("^(%S+)%s+(.+)$")
            if key and val and settings[key] ~= nil then
                if meta[key].type == "int" then
                    settings[key] = tonumber(val) or settings[key]
                elseif meta[key].type == "float" then
                    settings[key] = tonumber(val) or settings[key]
                elseif meta[key].type == "string" then
                    val = val:gsub('^"(.*)"$', '%1')
                    settings[key] = val
                end
            end
        end
    end
end

-- Save default settings to config.txt
function config.returnDefaults()
    settings = {}
    for k, v in pairs(defaultSettings) do
        settings[k] = v
    end
end

-- Serialize settings to string
local function serialize()
    local out = {}
    local function push(k, v, hint)
        if type(v) == "string" and v:find("%s") then
            v = '"' .. v .. '"'
        end
        table.insert(out, string.format("%s %s%s", k, tostring(v), hint and (" // " .. hint) or ""))
    end
    push("use_bloom", settings.use_bloom)
    push("trilinear_filter", settings.trilinear_filter)
    push("disable_mipmaps", settings.disable_mipmaps)
    push("language", settings.language)
    push("crouch_toggle", settings.crouch_toggle)
    push("character_shadows", settings.character_shadows, "1 - one blob; 2 - foot shadows")
    push("drop_highest_lod", settings.drop_highest_lod)
    push("show_weapon_menu", settings.show_weapon_menu)
    push("vsync_enabled", settings.vsync_enabled, "Enable VSync (1=on,0=off)")
    push("decal_limit", settings.decal_limit)
    push("debris_limit", settings.debris_limit)
    if settings.mod_file ~= "" then
        push("mod_file", settings.mod_file)
    end
    push("force_widescreen", settings.force_widescreen, "0=disabled,1=enabled")
    push("stick_deadzone", settings.stick_deadzone, "0.0-1.0")
    push("aspect_ratio_x_mult", settings.aspect_ratio_x_mult)
    push("aspect_ratio_y_mult", settings.aspect_ratio_y_mult)
    return table.concat(out, "\n") .. "\n"
end

-- Public API
function config.getSettings()
    return settings
end

function config.getMeta()
    return meta
end

function config.getOrder()
    return order
end

function config.getLanguageNames()
    return languageNames
end

function config.getShadowNames()
    return shadowNames
end

function config.load()
    local file = io.open(FILE_PATH, "r")
    if file then
        local data = file:read("*a")
        file:close()
        parseConfigText(data)
        return "Loaded config.txt", 1.5
    else
        local file = io.open(FILE_PATH, "w")
        if file then
            file:write(serialize())
            file:close()
            return "Created config.txt with defaults", 2.0
        else
            return "Failed to create config.txt", 2.0
        end
    end
end

function config.save()
    local file = io.open(FILE_PATH, "w")
    if file then
        file:write(serialize())
        file:close()
        return "Saved", 1.5
    else
        return "Failed to save config.txt", 2.0
    end
end

function config.adjustValue(key, dir)
    local m = meta[key]
    if not m then
        return false
    end

    if m.type == "int" then
        settings[key] = clamp(settings[key] + (dir * m.step), m.min, m.max)
        return true
    elseif m.type == "float" then
        local v = settings[key] + (dir * m.step)
        v = clamp(v, m.min, m.max)
        settings[key] = tonumber(string.format("%.3f", v))
        return true
    elseif m.type == "string" then
        return "edit"
    end
    return false
end

function config.toggleValue(key)
    local m = meta[key]
    if m and m.type == "int" and m.min == 0 and m.max == 1 then
        settings[key] = 1 - settings[key]
        return true
    end
    return false
end

function config.formatValue(key)
    local m = meta[key]
    local val = settings[key]

    if m.type == "int" then
        if m.min == 0 and m.max == 1 then
            return (val == 1) and "ON" or "OFF"
        elseif key == "language" then
            return languageNames[val] or ("Unknown (" .. tostring(val) .. ")")
        elseif key == "character_shadows" then
            return shadowNames[val] or ("Unknown (" .. tostring(val) .. ")")
        else
            return tostring(val)
        end
    elseif m.type == "float" then
        return string.format("%.2f", val)
    else
        return val
    end
end

return config
