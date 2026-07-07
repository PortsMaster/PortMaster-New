-- 2048 Plus — Global constants and scaling helpers

_G.timer = require("timer")

local sem_ver = {
    major = 5,
    minor = 0,
    patch = 1,
    extra = ""
}

_G.version = (function()
    local version = string.format("v%d.%d.%d", sem_ver.major, sem_ver.minor, sem_ver.patch)
    if sem_ver.extra ~= "" then
        version = version .. "-" .. sem_ver.extra
    end
    return version
end)()

_G.resolution = "640x480"
_G.design_w = 640
_G.design_h = 480
_G.sx = 1
_G.sy = 1
_G.scale = 1

function _G.update_ui_scale()
    local w, h = love.graphics.getDimensions()
    _G.sx = w / _G.design_w
    _G.sy = h / _G.design_h
    _G.scale = math.min(_G.sx, _G.sy)

    -- Snap to 1.0 if very close (prevents tiny rounding errors on 640x480)
    if math.abs(_G.scale - 1) < 0.01 then
        _G.scale = 1
        _G.sx = 1
        _G.sy = 1
    end
end

-- Global scaling helper — multiply any design-space value by current scale
function _G.g(val)
    return val * _G.scale
end

-- Working directory (set after love.load)
_G.WORK_DIR = ""

-- Current visual theme (light / dark / oled / neon / retro / peach / ocean / forest / sunset / candy)
_G.theme = "light"
_G.text_size = "normal"
_G.animation_speed = "normal"
_G.screen_transitions = true
_G.undo_mode = "classic"
_G.time_attack_time = 60
_G.vibration = true

-- Achievements and Unlockables
_G.achievements = {
    -- Simple achievements (color-only themes, no custom tiles)
    ach_first_game = false,  -- First Steps -> unlocks 'ocean'
    ach_score_1k = false,    -- Getting Started -> unlocks 'forest'
    ach_score_5k = false,    -- Rising Star -> unlocks 'sunset'
    ach_merge_512 = false,   -- Half Way There -> unlocks 'candy'

    -- Premium achievements (full custom tile themes)
    ach_2048 = false,        -- 2048 Master -> unlocks 'oled'
    ach_score_10k = false,   -- High Roller -> unlocks 'neon'
    ach_demolition = false,  -- Demolition Expert (10 bombs used) -> unlocks 'retro'
    ach_untouchable = false, -- Untouchable (1024 without powerups) -> unlocks 'peach'
    ach_2048_plus = false,   -- Plus Mode Master -> unlocks 'cyberpunk'
    ach_4096 = false,        -- The One -> unlocks 'glitch'
    ach_score_25k = false,   -- Aesthetic -> unlocks 'vaporwave'
    ach_score_50k = false,   -- Vampire Lord -> unlocks 'dracula'
    ach_score_100k = false,  -- Midas Touch -> unlocks 'gold'
    ach_untouchable_2048 = false, -- Zen Master (2048 without powerups) -> unlocks 'matcha'

    -- Dark simple achievements (color-only dark themes)
    ach_merge_1024 = false,  -- Almost There -> unlocks 'midnight'
    ach_score_2k = false,    -- Gaining Momentum -> unlocks 'volcano'
    ach_score_7k = false,    -- High Scorer -> unlocks 'abyss'
    ach_first_bomb = false,  -- Boom! -> unlocks 'eclipse'

    -- Secret tracking stats
    ach_secret_menu = false, -- Secret Discovery -> unlocks 'matrix'

    -- Arcade Mode achievements
    ach_timeattack_2048 = false, -- Aurora -- Reach 2048 in Time Attack -> unlocks 'aurora'
    ach_huge_2048 = false,       -- Spacious Giant -- Reach 2048 in Huge Mode -> unlocks 'nebula'
    ach_nomercy_512 = false,      -- No Escape -- Reach 512 in No Mercy Mode -> unlocks 'inferno'
    ach_goose_2048 = false,      -- Honk Honk! -- Reach 2048 in Goose Mode -> unlocks 'honk'

    -- High-Tier Challenges
    ach_merge_8192 = false,      -- The Chosen One -> unlocks 'quantum'
    ach_score_250k = false,      -- Infinity Legend -> unlocks 'hyperdrive'
    ach_speedrun_2048 = false,   -- Speed Demon -> unlocks 'retrogold'
    ach_hardcore_2048 = false,   -- Hardcore Gamer -> unlocks 'spectrum'
    ach_tactician = false,       -- Tactician -> unlocks 'steel'

    -- Hidden tracking stats
    bombs_used = 0,
    powerups_used_this_run = 0
}

_G.unlocked_themes = {"light", "dark"}
