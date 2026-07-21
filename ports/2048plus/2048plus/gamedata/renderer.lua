-- 2048 Renderer
-- All drawing logic — board, tiles, score, overlays, controls help
-- Colors extracted from the original Android XML drawables

local Game = require("game")
local save = require("save")

local renderer = {}

-- Theme transition animation state
local transition_canvas = nil
local transition_timer = 0
local transition_duration = 0.5
local transition_center_x = 0
local transition_center_y = 0
renderer.theme_button_x = nil
renderer.theme_button_y = nil

-- Menu selection animation state
local menu_anim_y = nil
local menu_anim_target_y = nil
local menu_anim_x = nil
local menu_anim_target_x = nil
local menu_anim_w = nil
local menu_anim_target_w = nil
local tutorial_old_canvas = nil
local tutorial_new_canvas = nil
local achievements_old_canvas = nil
local achievements_new_canvas = nil
local logo_2048 = nil
local font_bgm = nil

local badge_canvas = nil
local badge_quad = nil
local menu_logo_canvas = nil
local menu_logo_quad = nil
local selection_canvas = nil
local selection_quad = nil

-- Win animation state
local win_timer = 0

-- Text size flash animation state (triggered when text size is toggled)
local text_size_flash_timer = 0
local TEXT_SIZE_FLASH_DURATION = 0.4

-- Arcade Menu animation state
local arcade_panel_y_offset = 9999  -- starts fully hidden (off screen below)
local arcade_panel_target = 9999    -- target offset
local arcade_menu_bg_alpha = 0      -- dim overlay alpha (0..0.75)
local panel_page_target = 0         -- 0 for Play Selection, 1 for Arcade modes
local panel_page_current = 0

local play_select_sel_current = nil
local arcade_sel_col_current = nil
local arcade_sel_row_current = nil

function renderer.setArcadeMenuOpen(open)
    local scale = _G.scale or 1
    local card_h = math.floor((_G.text_size == "large" and 124 or 120) * scale)
    local card_gap = math.floor(12 * scale)
    local panel_pad_y = math.floor(16 * scale)
    local header_h = math.floor(74 * scale)
    local footer_h = math.floor(44 * scale)
    local num_rows = 2
    local panel_h = header_h + panel_pad_y + num_rows * card_h + (num_rows - 1) * card_gap + panel_pad_y + footer_h

    if open then
        arcade_panel_target = 0
        play_select_sel_current = nil
        arcade_sel_col_current = nil
        arcade_sel_row_current = nil
        if _G.appState == "PLAY_SELECT" then
            panel_page_current = 0
        elseif _G.appState == "ARCADE_MENU" then
            panel_page_current = 1
        end
    else
        arcade_panel_target = panel_h
    end
end

function renderer.flashTextSize()
    text_size_flash_timer = TEXT_SIZE_FLASH_DURATION
end

function renderer.resetMenuAnimation()
    menu_anim_y = nil
    menu_anim_target_y = nil
    menu_anim_x = nil
    menu_anim_target_x = nil
    menu_anim_w = nil
    menu_anim_target_w = nil
    tutorial_old_canvas = nil
    tutorial_new_canvas = nil
    achievements_old_canvas = nil
    achievements_new_canvas = nil
    _G.achievements_slide_timer = 0
end

function renderer.captureOldTutorialSlide(page)
    local w, h = love.graphics.getDimensions()
    if not tutorial_old_canvas then
        tutorial_old_canvas = love.graphics.newCanvas(w, h)
    end
    love.graphics.setCanvas({tutorial_old_canvas, stencil = true})
    love.graphics.clear()
    renderer.drawTutorial(page, true, true)
    love.graphics.setCanvas()
end

function renderer.captureOldAchievementsSlide(tab)
    local w, h = love.graphics.getDimensions()
    if not achievements_old_canvas then
        achievements_old_canvas = love.graphics.newCanvas(w, h)
    end
    love.graphics.setCanvas({achievements_old_canvas, stencil = true})
    love.graphics.clear()
    renderer.drawAchievements(0, true, true, tab)
    love.graphics.setCanvas()
end

-- Toast state
local toast_message = nil
local toast_timer = 0
local toast_queue = {}
local toast_max_duration = 1.5
local TOAST_DURATION = 1.5
local toast_particles = {}

local function spawnToastParticles()
    local w, h = love.graphics.getDimensions()
    local theme_gold, theme_super = renderer.getThemeHighlightColors()
    local tile_colors_t = renderer.getThemeTileColors()
    
    local possible_colors = {theme_gold, theme_super}
    local values = {2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048}
    for _, v in ipairs(values) do
        if tile_colors_t[v] then
            table.insert(possible_colors, tile_colors_t[v])
        end
    end
    
    if #possible_colors < 2 then
        possible_colors = { {0.93, 0.76, 0.18}, {0.95, 0.69, 0.39}, {0.96, 0.49, 0.25}, {0.96, 0.37, 0.23} }
    end
    
    local cx = w / 2
    local cy = (10 + 20) * _G.scale
    
    for i = 1, 45 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(100, 400) * _G.scale
        local p_color = possible_colors[love.math.random(#possible_colors)]
        
        table.insert(toast_particles, {
            x = cx + (love.math.random() - 0.5) * 120 * _G.scale,
            y = cy + (love.math.random() - 0.5) * 20 * _G.scale,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - love.math.random(50, 150) * _G.scale,
            life = 0.6 + love.math.random() * 0.5,
            size = love.math.random(2, 6) * _G.scale,
            color = p_color,
            drag = 0.94 + love.math.random() * 0.04
        })
    end
end

function renderer.showToast(msg, custom_duration, is_achievement)
    local duration = custom_duration or TOAST_DURATION
    if toast_timer > 0 then
        table.insert(toast_queue, {msg = msg, duration = duration, is_achievement = is_achievement})
    else
        toast_message = msg
        toast_timer = duration
        toast_max_duration = duration
        if is_achievement then
            spawnToastParticles()
        end
    end
end

function renderer.getContrastTextColor(bg_col, desired_text_col, dark_fallback)
    if not bg_col then return desired_text_col end
    
    local r_bg, g_bg, b_bg = bg_col[1] or 0, bg_col[2] or 0, bg_col[3] or 0
    local bg_lum = 0.299 * r_bg + 0.587 * g_bg + 0.114 * b_bg
    
    if bg_lum > 0.65 then
        -- Light background: we want a dark text color.
        if desired_text_col then
            local r_tx, g_tx, b_tx = desired_text_col[1] or 0, desired_text_col[2] or 0, desired_text_col[3] or 0
            local tx_lum = 0.299 * r_tx + 0.587 * g_tx + 0.114 * b_tx
            if tx_lum < 0.45 then
                return desired_text_col
            end
        end
        return dark_fallback or {0.15, 0.15, 0.15, 1}
    else
        -- Dark background: we want a light text color.
        if desired_text_col then
            local r_tx, g_tx, b_tx = desired_text_col[1] or 0, desired_text_col[2] or 0, desired_text_col[3] or 0
            local tx_lum = 0.299 * r_tx + 0.587 * g_tx + 0.114 * b_tx
            if tx_lum > 0.45 then
                return desired_text_col
            end
        end
        return {0.95, 0.95, 0.95, 1}
    end
end

-- Color palette (from Android cell_rectangle_*.xml and colors.xml)
-- ============================================================================
local function hex(h)
    h = h:gsub("#", "")
    return tonumber(h:sub(1, 2), 16) / 255,
           tonumber(h:sub(3, 4), 16) / 255,
           tonumber(h:sub(5, 6), 16) / 255
end

local themes = {
    light = {
        tile_colors = {
            [0]    = {hex("#cdc1b4")},   -- empty cell
            [2]    = {hex("#eee4da")},
            [4]    = {hex("#ede0c8")},
            [8]    = {hex("#f2b179")},
            [16]   = {hex("#f59563")},
            [32]   = {hex("#f67c5f")},
            [64]   = {hex("#f65e3b")},
            [128]  = {hex("#edcf72")},
            [256]  = {hex("#edcc61")},
            [512]  = {hex("#edc850")},
            [1024] = {hex("#edc53f")},
            [2048] = {hex("#edc22e")},
        },
        super_tile_color = {hex("#3c3a32")},
        dark_text        = {hex("#776e65")},
        light_text       = {hex("#f9f6f2")},
        ui_text          = {hex("#776e65")},
        bg_color         = {hex("#faf8ef")},
        board_color      = {hex("#bbada0")},
        score_bg_color   = {hex("#bbada0")},
        score_label      = {hex("#eee4da")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#edc22e")},
        overlay_lose     = {hex("#eee4da")},
        help_bg_color    = {hex("#bbada0")},
        help_key_color   = {hex("#edc22e")},
        help_key_text    = {hex("#776e65")},
    },
    dark = {
        tile_colors = {
            [0]    = {hex("#3a3a3a")},   -- empty cell
            [2]    = {hex("#eee4da")},
            [4]    = {hex("#ede0c8")},
            [8]    = {hex("#f2b179")},
            [16]   = {hex("#f59563")},
            [32]   = {hex("#f67c5f")},
            [64]   = {hex("#f65e3b")},
            [128]  = {hex("#edcf72")},
            [256]  = {hex("#edcc61")},
            [512]  = {hex("#edc850")},
            [1024] = {hex("#edc53f")},
            [2048] = {hex("#edc22e")},
        },
        super_tile_color = {hex("#eee4da")},
        dark_text        = {hex("#776e65")},  -- Kept dark for light tiles
        light_text       = {hex("#f9f6f2")},
        ui_text          = {hex("#eee4da")},  -- Light color for UI text
        bg_color         = {hex("#121212")},
        board_color      = {hex("#2d2d2d")},
        score_bg_color   = {hex("#2d2d2d")},
        score_label      = {hex("#bbada0")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#edc22e")},
        overlay_lose     = {hex("#2d2d2d")},
        help_bg_color    = {hex("#2d2d2d")},
        help_key_color   = {hex("#4a4a4a")},
        help_key_text    = {hex("#eee4da")},
    },
    oled = {
        tile_colors = {
            [0]    = {hex("#1a1a1a")},   -- empty cell
            [2]    = {hex("#333333")},
            [4]    = {hex("#4d4d4d")},
            [8]    = {hex("#666666")},
            [16]   = {hex("#808080")},
            [32]   = {hex("#999999")},
            [64]   = {hex("#b3b3b3")},
            [128]  = {hex("#cccccc")},
            [256]  = {hex("#e6e6e6")},
            [512]  = {hex("#ffffff")},
            [1024] = {hex("#ffffff")},
            [2048] = {hex("#ffffff")},
        },
        super_tile_color = {hex("#ffffff")},
        dark_text        = {hex("#000000")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#ffffff")},
        bg_color         = {hex("#000000")},
        board_color      = {hex("#0f0f0f")},
        score_bg_color   = {hex("#0f0f0f")},
        score_label      = {hex("#888888")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#ffffff")},
        overlay_lose     = {hex("#0f0f0f")},
        help_bg_color    = {hex("#0f0f0f")},
        help_key_color   = {hex("#333333")},
        help_key_text    = {hex("#ffffff")},
    },
    neon = {
        tile_colors = {
            [0]    = {hex("#1f2833")},   -- empty cell
            [2]    = {hex("#0f172a")},
            [4]    = {hex("#23194d")},
            [8]    = {hex("#371b71")},
            [16]    = {hex("#4c1d95")},
            [32]    = {hex("#711b82")},
            [64]    = {hex("#97196f")},
            [128]    = {hex("#be185d")},
            [256]    = {hex("#cd454b")},
            [512]    = {hex("#dc7239")},
            [1024]    = {hex("#eb9f27")},
            [2048]    = {hex("#facc15")},
        },
        super_tile_color = {hex("#ff00ff")},
        dark_text        = {hex("#0b0c10")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#66fcf1")},
        bg_color         = {hex("#0b0c10")},
        board_color      = {hex("#1f2833")},
        score_bg_color   = {hex("#1f2833")},
        score_label      = {hex("#45a29e")},
        score_value      = {hex("#66fcf1")},
        overlay_win      = {hex("#ff00ff")},
        overlay_lose     = {hex("#1f2833")},
        help_bg_color    = {hex("#1f2833")},
        help_key_color   = {hex("#45a29e")},
        help_key_text    = {hex("#0b0c10")},
    },
    retro = {
        tile_colors = {
            [0]    = {hex("#306230")},   -- empty cell (mid-dark green so tiles pop)
            [2]    = {hex("#9bbc0f")},
            [4]    = {hex("#8fb00f")},
            [8]    = {hex("#83a40f")},
            [16]   = {hex("#77980f")},
            [32]   = {hex("#6b8c0f")},
            [64]   = {hex("#5f800f")},
            [128]  = {hex("#53740f")},
            [256]  = {hex("#47680f")},
            [512]  = {hex("#3b5c0f")},
            [1024] = {hex("#2f500f")},
            [2048] = {hex("#0f380f")},
        },
        super_tile_color = {hex("#0f380f")},
        dark_text        = {hex("#0f380f")},
        light_text       = {hex("#9bbc0f")},
        ui_text          = {hex("#0f380f")},
        bg_color         = {hex("#9bbc0f")},
        board_color      = {hex("#306230")},
        score_bg_color   = {hex("#306230")},
        score_label      = {hex("#0f380f")},
        score_value      = {hex("#9bbc0f")},
        overlay_win      = {hex("#306230")},
        overlay_lose     = {hex("#8bac0f")},
        help_bg_color    = {hex("#8bac0f")},
        help_key_color   = {hex("#0f380f")},
        help_key_text    = {hex("#9bbc0f")},
    },
    peach = {
        tile_colors = {
            [0]    = {hex("#ffdab9")},   -- empty cell
            [2]    = {hex("#ffe5b4")},
            [4]    = {hex("#f3cea2")},
            [8]    = {hex("#e7b790")},
            [16]    = {hex("#dca07e")},
            [32]    = {hex("#d0896c")},
            [64]    = {hex("#c5725a")},
            [128]    = {hex("#b95b48")},
            [256]    = {hex("#ad4436")},
            [512]    = {hex("#a22d24")},
            [1024]    = {hex("#961612")},
            [2048]    = {hex("#8b0000")},
        },
        super_tile_color = {hex("#c27a7e")},
        dark_text        = {hex("#783f44")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#783f44")},
        bg_color         = {hex("#ffe5b4")},
        board_color      = {hex("#ffdab9")},
        score_bg_color   = {hex("#ffdab9")},
        score_label      = {hex("#783f44")},
        score_value      = {hex("#541e22")},
        overlay_win      = {hex("#ff69b4")},
        overlay_lose     = {hex("#ffdab9")},
        help_bg_color    = {hex("#ffdab9")},
        help_key_color   = {hex("#9e5055")},
        help_key_text    = {hex("#ffffff")},
    },
    glitch = {
        tile_colors = {
            [0]    = {hex("#0d0e15")},
            [2]    = {hex("#0e1e38")},
            [4]    = {hex("#1e1b4b")},
            [8]    = {hex("#311042")},
            [16]   = {hex("#4d073b")},
            [32]   = {hex("#014751")},
            [64]   = {hex("#0f766e")},
            [128]  = {hex("#be185d")},
            [256]  = {hex("#a21caf")},
            [512]  = {hex("#6366f1")},
            [1024] = {hex("#06b6d4")},
            [2048] = {hex("#ec4899")},
        },
        super_tile_color = {hex("#f43f5e")},
        dark_text        = {hex("#0d0e15")},
        light_text       = {hex("#fdf4ff")},
        ui_text          = {hex("#06b6d4")},
        bg_color         = {hex("#090a0f")},
        board_color      = {hex("#161b26")},
        score_bg_color   = {hex("#161b26")},
        score_label      = {hex("#ec4899")},
        score_value      = {hex("#06b6d4")},
        overlay_win      = {hex("#ec4899")},
        overlay_lose     = {hex("#1e1b4b")},
        help_bg_color    = {hex("#161b26")},
        help_key_color   = {hex("#ec4899")},
        help_key_text    = {hex("#0d0e15")},
    },
    -- Simple themes (color-only, no custom tiles — use default light tile colors)
    ocean = {
        tile_colors = {
            [0]    = {hex("#b8d4e3")},
            [2]    = {hex("#eee4da")},
            [4]    = {hex("#ede0c8")},
            [8]    = {hex("#f2b179")},
            [16]   = {hex("#f59563")},
            [32]   = {hex("#f67c5f")},
            [64]   = {hex("#f65e3b")},
            [128]  = {hex("#edcf72")},
            [256]  = {hex("#edcc61")},
            [512]  = {hex("#edc850")},
            [1024] = {hex("#edc53f")},
            [2048] = {hex("#edc22e")},
        },
        super_tile_color = {hex("#1a5276")},
        dark_text        = {hex("#1a5276")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#1a5276")},
        bg_color         = {hex("#d6eaf8")},
        board_color      = {hex("#aed6f1")},
        score_bg_color   = {hex("#aed6f1")},
        score_label      = {hex("#2980b9")},
        score_value      = {hex("#1a5276")},
        overlay_win      = {hex("#2980b9")},
        overlay_lose     = {hex("#aed6f1")},
        help_bg_color    = {hex("#aed6f1")},
        help_key_color   = {hex("#2980b9")},
        help_key_text    = {hex("#ffffff")},
    },
    forest = {
        tile_colors = {
            [0]    = {hex("#c8dbbe")},
            [2]    = {hex("#eee4da")},
            [4]    = {hex("#ede0c8")},
            [8]    = {hex("#f2b179")},
            [16]   = {hex("#f59563")},
            [32]   = {hex("#f67c5f")},
            [64]   = {hex("#f65e3b")},
            [128]  = {hex("#edcf72")},
            [256]  = {hex("#edcc61")},
            [512]  = {hex("#edc850")},
            [1024] = {hex("#edc53f")},
            [2048] = {hex("#edc22e")},
        },
        super_tile_color = {hex("#1e6b3a")},
        dark_text        = {hex("#2d5016")},
        light_text       = {hex("#f9f6f2")},
        ui_text          = {hex("#2d5016")},
        bg_color         = {hex("#e8f5e9")},
        board_color      = {hex("#a5d6a7")},
        score_bg_color   = {hex("#a5d6a7")},
        score_label      = {hex("#388e3c")},
        score_value      = {hex("#1b5e20")},
        overlay_win      = {hex("#388e3c")},
        overlay_lose     = {hex("#a5d6a7")},
        help_bg_color    = {hex("#a5d6a7")},
        help_key_color   = {hex("#388e3c")},
        help_key_text    = {hex("#ffffff")},
    },
    sunset = {
        tile_colors = {
            [0]    = {hex("#f5cba7")},
            [2]    = {hex("#fadbd8")},
            [4]    = {hex("#f5b7b1")},
            [8]    = {hex("#f1948a")},
            [16]   = {hex("#ec7063")},
            [32]   = {hex("#e74c3c")},
            [64]   = {hex("#cb4335")},
            [128]  = {hex("#b03a2e")},
            [256]  = {hex("#f9e79f")},
            [512]  = {hex("#f7dc6f")},
            [1024] = {hex("#f4d03f")},
            [2048] = {hex("#f1c40f")},
        },
        super_tile_color = {hex("#922b21")},
        dark_text        = {hex("#784212")},
        light_text       = {hex("#fef9e7")},
        ui_text          = {hex("#922b21")},
        bg_color         = {hex("#fdebd0")},
        board_color      = {hex("#f0b27a")},
        score_bg_color   = {hex("#f0b27a")},
        score_label      = {hex("#d35400")},
        score_value      = {hex("#922b21")},
        overlay_win      = {hex("#e67e22")},
        overlay_lose     = {hex("#f0b27a")},
        help_bg_color    = {hex("#f0b27a")},
        help_key_color   = {hex("#d35400")},
        help_key_text    = {hex("#ffffff")},
    },
    candy = {
        tile_colors = {
            [0]    = {hex("#f8c8dc")},
            [2]    = {hex("#f5eef8")},
            [4]    = {hex("#ebdef0")},
            [8]    = {hex("#d7bde2")},
            [16]   = {hex("#c39bd3")},
            [32]   = {hex("#af7ac5")},
            [64]   = {hex("#9b59b6")},
            [128]  = {hex("#884ea0")},
            [256]  = {hex("#76448a")},
            [512]  = {hex("#f1948a")},
            [1024] = {hex("#ec7063")},
            [2048] = {hex("#e74c3c")},
        },
        super_tile_color = {hex("#9b2335")},
        dark_text        = {hex("#6c3483")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#9b2335")},
        bg_color         = {hex("#fdedec")},
        board_color      = {hex("#f5b7b1")},
        score_bg_color   = {hex("#f5b7b1")},
        score_label      = {hex("#c0392b")},
        score_value      = {hex("#9b2335")},
        overlay_win      = {hex("#e74c3c")},
        overlay_lose     = {hex("#f5b7b1")},
        help_bg_color    = {hex("#f5b7b1")},
        help_key_color   = {hex("#c0392b")},
        help_key_text    = {hex("#ffffff")},
    },
    midnight = {
        tile_colors = {
            [0]    = {hex("#334155")},
            [2]    = {hex("#2c3e50")},
            [4]    = {hex("#3f3f62")},
            [8]    = {hex("#534075")},
            [16]    = {hex("#664187")},
            [32]    = {hex("#7a429a")},
            [64]    = {hex("#8e44ad")},
            [128]    = {hex("#a15d8d")},
            [256]    = {hex("#b5776d")},
            [512]    = {hex("#c9904e")},
            [1024]    = {hex("#ddaa2e")},
            [2048]    = {hex("#f1c40f")},
        },
        super_tile_color = {hex("#818cf8")},
        dark_text        = {hex("#0f172a")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#cbd5e1")},
        bg_color         = {hex("#0f172a")},
        board_color      = {hex("#1e293b")},
        score_bg_color   = {hex("#1e293b")},
        score_label      = {hex("#cbd5e1")},
        score_value      = {hex("#f8fafc")},
        overlay_win      = {hex("#6366f1")},
        overlay_lose     = {hex("#1e293b")},
        help_bg_color    = {hex("#1e293b")},
        help_key_color   = {hex("#6366f1")},
        help_key_text    = {hex("#ffffff")},
    },
    volcano = {
        tile_colors = {
            [0]    = {hex("#404040")},
            [2]    = {hex("#d6dbdf")},
            [4]    = {hex("#aeb6bf")},
            [8]    = {hex("#85929e")},
            [16]   = {hex("#5d6d7e")},
            [32]   = {hex("#34495e")},
            [64]   = {hex("#2e4053")},
            [128]  = {hex("#f5b041")},
            [256]  = {hex("#f39c12")},
            [512]  = {hex("#e67e22")},
            [1024] = {hex("#d35400")},
            [2048] = {hex("#e74c3c")},
        },
        super_tile_color = {hex("#ef4444")},
        dark_text        = {hex("#1a1a1a")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#e5e5e5")},
        bg_color         = {hex("#1a1a1a")},
        board_color      = {hex("#2d2d2d")},
        score_bg_color   = {hex("#2d2d2d")},
        score_label      = {hex("#ef4444")},
        score_value      = {hex("#fca5a5")},
        overlay_win      = {hex("#dc2626")},
        overlay_lose     = {hex("#2d2d2d")},
        help_bg_color    = {hex("#2d2d2d")},
        help_key_color   = {hex("#dc2626")},
        help_key_text    = {hex("#ffffff")},
    },
    abyss = {
        tile_colors = {
            [0]    = {hex("#0f766e")},
            [2]    = {hex("#a3e4d7")},
            [4]    = {hex("#76d7c4")},
            [8]    = {hex("#48c9b0")},
            [16]   = {hex("#1abc9c")},
            [32]   = {hex("#17a589")},
            [64]   = {hex("#148f77")},
            [128]  = {hex("#094a40")},
            [256]  = {hex("#053029")},
            [512]  = {hex("#58d68d")},
            [1024] = {hex("#2ecc71")},
            [2048] = {hex("#27ae60")},
        },
        super_tile_color = {hex("#14b8a6")},
        dark_text        = {hex("#042f2e")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#ccfbf1")},
        bg_color         = {hex("#042f2e")},
        board_color      = {hex("#115e59")},
        score_bg_color   = {hex("#115e59")},
        score_label      = {hex("#ccfbf1")},
        score_value      = {hex("#5eead4")},
        overlay_win      = {hex("#0d9488")},
        overlay_lose     = {hex("#115e59")},
        help_bg_color    = {hex("#115e59")},
        help_key_color   = {hex("#0d9488")},
        help_key_text    = {hex("#ffffff")},
    },
    eclipse = {
        tile_colors = {
            [0]    = {hex("#3f3f46")},
            [2]    = {hex("#f2f3f4")},
            [4]    = {hex("#e5e7e9")},
            [8]    = {hex("#d7dbdd")},
            [16]   = {hex("#cacfd2")},
            [32]   = {hex("#bdc3c7")},
            [64]   = {hex("#a6acaf")},
            [128]  = {hex("#909497")},
            [256]  = {hex("#797d7f")},
            [512]  = {hex("#626567")},
            [1024] = {hex("#4d5656")},
            [2048] = {hex("#f1c40f")},
        },
        super_tile_color = {hex("#facc15")},
        dark_text        = {hex("#18181b")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#f4f4f5")},
        bg_color         = {hex("#18181b")},
        board_color      = {hex("#27272a")},
        score_bg_color   = {hex("#27272a")},
        score_label      = {hex("#fde047")},
        score_value      = {hex("#fef08a")},
        overlay_win      = {hex("#eab308")},
        overlay_lose     = {hex("#27272a")},
        help_bg_color    = {hex("#27272a")},
        help_key_color   = {hex("#eab308")},
        help_key_text    = {hex("#ffffff")},
    },
    cyberpunk = {
        tile_colors = {
            [0]    = {hex("#2d1b4e")},
            [2]    = {hex("#2d1b4e")},
            [4]    = {hex("#472583")},
            [8]    = {hex("#612fb8")},
            [16]    = {hex("#7c3aed")},
            [32]    = {hex("#a44cda")},
            [64]    = {hex("#cc5fc8")},
            [128]    = {hex("#f472b6")},
            [256]    = {hex("#8ba2d2")},
            [512]    = {hex("#22d3ee")},
            [1024]    = {hex("#8ecf81")},
            [2048]    = {hex("#facc15")},
        },
        super_tile_color = {hex("#facc15")},
        dark_text        = {hex("#0f172a")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#f472b6")},
        bg_color         = {hex("#0f172a")},
        board_color      = {hex("#1e1b4b")},
        score_bg_color   = {hex("#1e1b4b")},
        score_label      = {hex("#e879f9")},
        score_value      = {hex("#facc15")},
        overlay_win      = {hex("#f472b6")},
        overlay_lose     = {hex("#1e1b4b")},
        help_bg_color    = {hex("#1e1b4b")},
        help_key_color   = {hex("#f472b6")},
        help_key_text    = {hex("#ffffff")},
    },
    matrix = {
        tile_colors = {
            [0]    = {hex("#022c22")},
            [2]    = {hex("#064e3b")},
            [4]    = {hex("#065f46")},
            [8]    = {hex("#047857")},
            [16]   = {hex("#059669")},
            [32]   = {hex("#10b981")},
            [64]   = {hex("#34d399")},
            [128]  = {hex("#6ee7b7")},
            [256]  = {hex("#a7f3d0")},
            [512]  = {hex("#d1fae5")},
            [1024] = {hex("#ecfdf5")},
            [2048] = {hex("#ffffff")},
        },
        super_tile_color = {hex("#10b981")},
        dark_text        = {hex("#022c22")},
        light_text       = {hex("#a7f3d0")},
        ui_text          = {hex("#10b981")},
        bg_color         = {hex("#000000")},
        board_color      = {hex("#020617")},
        score_bg_color   = {hex("#020617")},
        score_label      = {hex("#059669")},
        score_value      = {hex("#10b981")},
        overlay_win      = {hex("#10b981")},
        overlay_lose     = {hex("#020617")},
        help_bg_color    = {hex("#020617")},
        help_key_color   = {hex("#10b981")},
        help_key_text    = {hex("#ffffff")},
    },
    vaporwave = {
        tile_colors = {
            [0]    = {hex("#312e81")},
            [2]    = {hex("#1e3a8a")},
            [4]    = {hex("#433c9e")},
            [8]    = {hex("#683eb2")},
            [16]    = {hex("#8e41c6")},
            [32]    = {hex("#b343da")},
            [64]    = {hex("#d946ef")},
            [128]    = {hex("#c366e3")},
            [256]    = {hex("#ae86d8")},
            [512]    = {hex("#98a6cd")},
            [1024]    = {hex("#83c6c2")},
            [2048]    = {hex("#6ee7b7")},
        },
        super_tile_color = {hex("#c084fc")},
        dark_text        = {hex("#1e1b4b")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#f472b6")},
        bg_color         = {hex("#172554")},
        board_color      = {hex("#1e1b4b")},
        score_bg_color   = {hex("#1e1b4b")},
        score_label      = {hex("#818cf8")},
        score_value      = {hex("#e879f9")},
        overlay_win      = {hex("#f472b6")},
        overlay_lose     = {hex("#1e1b4b")},
        help_bg_color    = {hex("#1e1b4b")},
        help_key_color   = {hex("#c084fc")},
        help_key_text    = {hex("#ffffff")},
    },
    dracula = {
        tile_colors = {
            [0]    = {hex("#44475a")},
            [2]    = {hex("#282a36")},
            [4]    = {hex("#3b425a")},
            [8]    = {hex("#4e597f")},
            [16]    = {hex("#6272a4")},
            [32]    = {hex("#9674af")},
            [64]    = {hex("#ca76ba")},
            [128]    = {hex("#ff79c6")},
            [256]    = {hex("#fb99b7")},
            [512]    = {hex("#f8b9a9")},
            [1024]    = {hex("#f4d99a")},
            [2048]    = {hex("#f1fa8c")},
        },
        super_tile_color = {hex("#ff79c6")},
        dark_text        = {hex("#282a36")},
        light_text       = {hex("#f8f8f2")},
        ui_text          = {hex("#ff79c6")},
        bg_color         = {hex("#282a36")},
        board_color      = {hex("#44475a")},
        score_bg_color   = {hex("#44475a")},
        score_label      = {hex("#6272a4")},
        score_value      = {hex("#f8f8f2")},
        overlay_win      = {hex("#ff79c6")},
        overlay_lose     = {hex("#44475a")},
        help_bg_color    = {hex("#44475a")},
        help_key_color   = {hex("#bd93f9")},
        help_key_text    = {hex("#f8f8f2")},
    },
    gold = {
        tile_colors = {
            [0]    = {hex("#262626")},
            [2]    = {hex("#78716c")},
            [4]    = {hex("#a8a29e")},
            [8]    = {hex("#d6d3d1")},
            [16]   = {hex("#f5f5f4")},
            [32]   = {hex("#d4a373")},
            [64]   = {hex("#dda15e")},
            [128]  = {hex("#e6ccb2")},
            [256]  = {hex("#ede0d4")},
            [512]  = {hex("#fcd5ce")},
            [1024] = {hex("#f8edeb")},
            [2048] = {hex("#ffd700")},
        },
        super_tile_color = {hex("#ffd700")},
        dark_text        = {hex("#171717")},
        light_text       = {hex("#f5f5f5")},
        ui_text          = {hex("#d4af37")},
        bg_color         = {hex("#0f0f0f")},
        board_color      = {hex("#171717")},
        score_bg_color   = {hex("#171717")},
        score_label      = {hex("#a8a29e")},
        score_value      = {hex("#ffd700")},
        overlay_win      = {hex("#ffd700")},
        overlay_lose     = {hex("#171717")},
        help_bg_color    = {hex("#171717")},
        help_key_color   = {hex("#d4af37")},
        help_key_text    = {hex("#171717")},
    },
    matcha = {
        tile_colors = {
            [0]    = {hex("#d7ccc8")},
            [2]    = {hex("#fff8e1")},
            [4]    = {hex("#ffecb3")},
            [8]    = {hex("#dce775")},
            [16]   = {hex("#cddc39")},
            [32]   = {hex("#aed581")},
            [64]   = {hex("#8bc34a")},
            [128]  = {hex("#689f38")},
            [256]  = {hex("#558b2f")},
            [512]  = {hex("#33691e")},
            [1024] = {hex("#8d6e63")},
            [2048] = {hex("#5d4037")},
        },
        super_tile_color = {hex("#5d4037")},
        dark_text        = {hex("#1b3a1f")},   -- deep forest green (was muddy brown)
        light_text       = {hex("#f9fbe7")},   -- pale lime white
        ui_text          = {hex("#2e7d32")},   -- rich green (was too muted)
        bg_color         = {hex("#efebe9")},
        board_color      = {hex("#bcaaa4")},
        score_bg_color   = {hex("#bcaaa4")},
        score_label      = {hex("#4e342e")},   -- warm brown label
        score_value      = {hex("#1b5e20")},   -- deep green value (was too dark and flat)
        overlay_win      = {hex("#558b2f")},
        overlay_lose     = {hex("#bcaaa4")},
        help_bg_color    = {hex("#bcaaa4")},
        help_key_color   = {hex("#8bc34a")},
        help_key_text    = {hex("#1b3a1f")},   -- consistent dark green
    },
    aurora = {
        -- Deep-space Northern Lights: pitch-black void, tiles shift from
        -- electric teal → violet → magenta → blinding white as they grow.
        -- UI text is a soft spectral cyan that pops against the darkness.
        tile_colors = {
            [0]    = {hex("#050d14")},   -- near-void dark
            [2]    = {hex("#062e2e")},   -- deep teal abyss
            [4]    = {hex("#0a3d3d")},   -- dark teal
            [8]    = {hex("#0e6666")},   -- glowing teal
            [16]   = {hex("#0aabb5")},   -- electric cyan
            [32]   = {hex("#0dd4e0")},   -- bright arctic
            [64]   = {hex("#2854a0")},   -- deep violet-blue
            [128]  = {hex("#5b2c8b")},   -- royal violet
            [256]  = {hex("#8b24a0")},   -- deep magenta-violet
            [512]  = {hex("#bf1ea8")},   -- vivid magenta
            [1024] = {hex("#e01d9e")},   -- hot pink-magenta
            [2048] = {hex("#ffffff")},   -- pure blinding white — the peak
        },
        super_tile_color = {hex("#ffffff")},
        dark_text        = {hex("#010810")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#5efcee")},   -- spectral aurora cyan
        bg_color         = {hex("#010810")},   -- deep space black
        board_color      = {hex("#050d14")},   -- near-void board
        score_bg_color   = {hex("#050d14")},
        score_label      = {hex("#2cd4c4")},   -- aurora teal label
        score_value      = {hex("#5efcee")},   -- spectral cyan value
        overlay_win      = {hex("#0dd4e0")},   -- arctic cyan win
        overlay_lose     = {hex("#050d14")},
        help_bg_color    = {hex("#050d14")},
        help_key_color   = {hex("#0aabb5")},   -- electric teal highlight
        help_key_text    = {hex("#ffffff")},
    },
    nebula = {
        -- Deep Space Nebula: dark indigo cosmic dust void, tiles shift from
        -- deep blue -> pink -> neon cyan -> white.
        tile_colors = {
            [0]    = {hex("#0b031a")},   -- near-black dark purple
            [2]    = {hex("#1d0e3a")},   -- deep violet
            [4]    = {hex("#2e114f")},   -- purple
            [8]    = {hex("#4d1b7d")},   -- rich magenta-purple
            [16]   = {hex("#7e1ba8")},   -- purple-pink
            [32]   = {hex("#b817b2")},   -- bright magenta
            [64]   = {hex("#d61596")},   -- neon pink
            [128]  = {hex("#00c5cd")},   -- cosmic cyan
            [256]  = {hex("#00e5ee")},   -- electric blue-cyan
            [512]  = {hex("#22ebc2")},   -- neon teal
            [1024] = {hex("#5efcee")},   -- neon cyan
            [2048] = {hex("#ffffff")},   -- white star
        },
        super_tile_color = {hex("#ffffff")},
        dark_text        = {hex("#090212")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#cc66ff")},   -- glowing pink-purple
        bg_color         = {hex("#05010d")},   -- pitch space black
        board_color      = {hex("#0b031a")},   -- board frame
        score_bg_color   = {hex("#0b031a")},
        score_label      = {hex("#a366ff")},
        score_value      = {hex("#cc66ff")},
        overlay_win      = {hex("#00e5ee")},
        overlay_lose     = {hex("#0b031a")},
        help_bg_color    = {hex("#0b031a")},
        help_key_color   = {hex("#7e1ba8")},
        help_key_text    = {hex("#ffffff")},
    },
    inferno = {
        -- Fire & Brimstone: ash black floor, fiery orange and glowing embers.
        tile_colors = {
            [0]    = {hex("#0e0404")},   -- deep ember ash
            [2]    = {hex("#2d0a0a")},   -- dark red ember
            [4]    = {hex("#4a1010")},   -- blood red
            [8]    = {hex("#7c1616")},   -- solid crimson
            [16]   = {hex("#b21f1f")},   -- glowing red
            [32]   = {hex("#d63e15")},   -- hot orange-red
            [64]   = {hex("#e65c00")},   -- fire orange
            [128]  = {hex("#ff7700")},   -- safety orange
            [256]  = {hex("#ff9900")},   -- gold-yellow flame
            [512]  = {hex("#ffcc00")},   -- bright yellow
            [1024] = {hex("#ffff66")},   -- sulfur yellow
            [2048] = {hex("#ffffff")},   -- white fire
        },
        super_tile_color = {hex("#ffffff")},
        dark_text        = {hex("#0d0303")},
        light_text       = {hex("#ffffff")},
        ui_text          = {hex("#ff4500")},   -- neon orangered
        bg_color         = {hex("#050101")},   -- pitch black coal
        board_color      = {hex("#0e0404")},   -- ash frame
        score_bg_color   = {hex("#0e0404")},
        score_label      = {hex("#cc3300")},
        score_value      = {hex("#ff4500")},
        overlay_win      = {hex("#ff7700")},
        overlay_lose     = {hex("#0e0404")},
        help_bg_color    = {hex("#0e0404")},
        help_key_color   = {hex("#b21f1f")},
        help_key_text    = {hex("#ffffff")},
    },
    honk = {
        -- Wetland Pond: soft swamp green and pond blue accents.
        tile_colors = {
            [0]    = {hex("#e2ece9")},   -- light green-gray water
            [2]    = {hex("#ffffff")},   -- clean white (goose color)
            [4]    = {hex("#f7f0e1")},   -- eggshell white
            [8]    = {hex("#fbdca4")},   -- orange beak yellow
            [16]   = {hex("#f9c264")},   -- dark orange
            [32]   = {hex("#dbecf5")},   -- sky blue
            [64]   = {hex("#b4d4e7")},   -- baby blue
            [128]  = {hex("#8ebbd9")},   -- soft blue
            [256]  = {hex("#5293c1")},   -- deep water blue
            [512]  = {hex("#2d71a1")},   -- lake blue
            [1024] = {hex("#164e75")},   -- deep navy
            [2048] = {hex("#ff8000")},   -- neon orange honk!
        },
        super_tile_color = {hex("#ff8000")},
        dark_text        = {hex("#1a3c34")},
        light_text       = {hex("#bfe4f4")},
        ui_text          = {hex("#1a6c5a")},   -- wetlands forest green
        bg_color         = {hex("#eef7f4")},   -- wetland water backdrop
        board_color      = {hex("#d2e4df")},   -- soft frame
        score_bg_color   = {hex("#d2e4df")},
        score_label      = {hex("#1a6c5a")},
        score_value      = {hex("#1a3c34")},
        overlay_win      = {hex("#5293c1")},
        overlay_lose     = {hex("#d2e4df")},
        help_bg_color    = {hex("#d2e4df")},
        help_key_color   = {hex("#1a6c5a")},
        help_key_text    = {hex("#ffffff")},
    },
    quantum = {
        -- Quantum Cyber: Deep cyber navy, glowing electric cyan and blue.
        tile_colors = {
            [0]    = {hex("#05162b")},
            [2]    = {hex("#ffffff")},
            [4]    = {hex("#e0f7fa")},
            [8]    = {hex("#80deea")},
            [16]   = {hex("#26c6da")},
            [32]   = {hex("#00bcd4")},
            [64]   = {hex("#00acc1")},
            [128]  = {hex("#00838f")},
            [256]  = {hex("#006064")},
            [512]  = {hex("#004d40")},
            [1024] = {hex("#009688")},
            [2048] = {hex("#00ffea")},
        },
        super_tile_color = {hex("#00ffea")},
        dark_text        = {hex("#011c3a")},
        light_text       = {hex("#e0ffff")},
        ui_text          = {hex("#00b0ff")},
        bg_color         = {hex("#020813")},
        board_color      = {hex("#051b3b")},
        score_bg_color   = {hex("#051b3b")},
        score_label      = {hex("#00b0ff")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#00b0ff")},
        overlay_lose     = {hex("#051b3b")},
        help_bg_color    = {hex("#051b3b")},
        help_key_color   = {hex("#00ffea")},
        help_key_text    = {hex("#020813")},
    },
    hyperdrive = {
        -- Hyperdrive Space: Dark indigo cosmos with neon magenta and white warp highlights.
        tile_colors = {
            [0]    = {hex("#140b24")},
            [2]    = {hex("#f3e5f5")},
            [4]    = {hex("#e1bee7")},
            [8]    = {hex("#ce93d8")},
            [16]   = {hex("#ba68c8")},
            [32]   = {hex("#ab47bc")},
            [64]   = {hex("#9c27b0")},
            [128]  = {hex("#8e24aa")},
            [256]  = {hex("#7b1fa2")},
            [512]  = {hex("#6a1b9a")},
            [1024] = {hex("#4a148c")},
            [2048] = {hex("#ff007f")},
        },
        super_tile_color = {hex("#ff007f")},
        dark_text        = {hex("#1d003b")},
        light_text       = {hex("#f5e6ff")},
        ui_text          = {hex("#ba68c8")},
        bg_color         = {hex("#090212")},
        board_color      = {hex("#22123b")},
        score_bg_color   = {hex("#22123b")},
        score_label      = {hex("#ba68c8")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#ff007f")},
        overlay_lose     = {hex("#22123b")},
        help_bg_color    = {hex("#22123b")},
        help_key_color   = {hex("#ff007f")},
        help_key_text    = {hex("#ffffff")},
    },
    retrogold = {
        -- Retro Gold: Rich amber yellows and deep gold textures on dark carbon.
        tile_colors = {
            [0]    = {hex("#24211b")},
            [2]    = {hex("#fffdf0")},
            [4]    = {hex("#fff9c4")},
            [8]    = {hex("#fff59d")},
            [16]   = {hex("#fff176")},
            [32]   = {hex("#ffee58")},
            [64]   = {hex("#ffeb3b")},
            [128]  = {hex("#fdd835")},
            [256]  = {hex("#fbc02d")},
            [512]  = {hex("#f9a825")},
            [1024] = {hex("#f57f17")},
            [2048] = {hex("#ffd700")},
        },
        super_tile_color = {hex("#ffd700")},
        dark_text        = {hex("#3e2723")},
        light_text       = {hex("#fffde7")},
        ui_text          = {hex("#f57f17")},
        bg_color         = {hex("#141310")},
        board_color      = {hex("#332e24")},
        score_bg_color   = {hex("#332e24")},
        score_label      = {hex("#fbc02d")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#ffd700")},
        overlay_lose     = {hex("#332e24")},
        help_bg_color    = {hex("#332e24")},
        help_key_color   = {hex("#ffd700")},
        help_key_text    = {hex("#141310")},
    },
    spectrum = {
        -- Spectrum: Neon rainbow colors on clean dark charcoal backdrop.
        tile_colors = {
            [0]    = {hex("#26262b")},
            [2]    = {hex("#f87171")},   -- red
            [4]    = {hex("#fb923c")},   -- orange
            [8]    = {hex("#fbbf24")},   -- yellow
            [16]   = {hex("#34d399")},   -- emerald
            [32]   = {hex("#2dd4bf")},   -- teal
            [64]   = {hex("#38bdf8")},   -- sky blue
            [128]  = {hex("#60a5fa")},   -- blue
            [256]  = {hex("#818cf8")},   -- indigo
            [512]  = {hex("#a78bfa")},   -- violet
            [1024] = {hex("#f472b6")},   -- pink
            [2048] = {hex("#ec4899")},   -- hot pink
        },
        super_tile_color = {hex("#ec4899")},
        dark_text        = {hex("#111116")},
        light_text       = {hex("#f3f4f6")},
        ui_text          = {hex("#a78bfa")},
        bg_color         = {hex("#121214")},
        board_color      = {hex("#26262c")},
        score_bg_color   = {hex("#26262c")},
        score_label      = {hex("#a78bfa")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#ec4899")},
        overlay_lose     = {hex("#26262c")},
        help_bg_color    = {hex("#26262c")},
        help_key_color   = {hex("#38bdf8")},
        help_key_text    = {hex("#121214")},
    },
    steel = {
        -- Steel Metallic: Polished industrial gray-blue tones.
        tile_colors = {
            [0]    = {hex("#cfd8dc")},
            [2]    = {hex("#eceff1")},
            [4]    = {hex("#b0bec5")},
            [8]    = {hex("#90a4ae")},
            [16]   = {hex("#78909c")},
            [32]   = {hex("#607d8b")},
            [64]   = {hex("#546e7a")},
            [128]  = {hex("#455a64")},
            [256]  = {hex("#37474f")},
            [512]  = {hex("#263238")},
            [1024] = {hex("#1a242f")},
            [2048] = {hex("#0d1218")},
        },
        super_tile_color = {hex("#0d1218")},
        dark_text        = {hex("#263238")},
        light_text       = {hex("#eceff1")},
        ui_text          = {hex("#37474f")},
        bg_color         = {hex("#e0e0e0")},
        board_color      = {hex("#9e9e9e")},
        score_bg_color   = {hex("#9e9e9e")},
        score_label      = {hex("#37474f")},
        score_value      = {hex("#ffffff")},
        overlay_win      = {hex("#37474f")},
        overlay_lose     = {hex("#9e9e9e")},
        help_bg_color    = {hex("#9e9e9e")},
        help_key_color   = {hex("#455a64")},
        help_key_text    = {hex("#ffffff")},
    }
}


-- Returns all theme names defined in the themes table, excluding always-unlocked ones.
-- Used by cheats to dynamically unlock everything without a hardcoded list.
function renderer.getAllThemeNames()
    -- "light" and "dark" are always unlocked
    local always_unlocked = { light = true, dark = true }
    local names = {}
    for name in pairs(themes) do
        if not always_unlocked[name] then
            table.insert(names, name)
        end
    end
    return names
end

-- Fonts
local font_tile_large
local font_tile_small
local font_tile_tiny   -- for 5+ digit numbers
local font_score
local font_title
local font_header_2048
local font_main_menu_title
local font_main_menu_plus
local font_header_plus
local font_cheats_title
local font_label
local font_message
local font_help_key
local font_help_label
local font_path = "assets/ClearSans-Bold.ttf"
local font_cache = {}

-- Current active colors (will be populated by applyTheme)
local tile_colors, super_tile_color, dark_text, light_text, ui_text
local bg_color, board_color, score_bg_color, score_label, score_value
local overlay_win, overlay_lose, help_bg_color, help_key_color, help_key_text

-- Now Playing BGM variables
local now_playing_timer = 0
local now_playing_track = nil
local last_track_path = nil

local theme_display_names = {
    light = "LIGHT",
    dark = "DARK",
    classic = "CLASSIC",
    ocean = "OCEAN",
    forest = "FOREST",
    volcano = "VOLCANO",
    quantum = "QUANTUM",
    dracula = "DRACULA",
    retrogold = "RETRO GOLD",
    hyperdrive = "HYPERDRIVE",
    honk = "HONK",
    matrix = "MATRIX",
    glitch = "GLITCH",
    vaporwave = "VAPORWAVE",
    cyberpunk = "CYBERPUNK",
    spectrum = "SPECTRUM",
    aurora = "AURORA",
    sakura = "SAKURA",
    matcha = "MATCHA",
    nebula = "NEBULA",
    inferno = "INFERNO"
}

function renderer.triggerThemeMorph(theme_id)
    if not theme_id then return end
    local name = theme_display_names[theme_id] or theme_id:upper()
    if _G.theme_morph_timer and _G.theme_morph_timer > 0 and _G.theme_morph_name then
        _G.theme_morph_prev_name = _G.theme_morph_name
    else
        _G.theme_morph_prev_name = "PLUS"
    end
    _G.theme_morph_name = name
    _G.theme_morph_timer = 4.0
end

function renderer.applyTheme(skip_morph)
    local t = themes[_G.theme] or themes.light
    tile_colors = t.tile_colors
    super_tile_color = t.super_tile_color
    dark_text = t.dark_text
    light_text = t.light_text
    ui_text = t.ui_text
    bg_color = t.bg_color
    board_color = t.board_color
    score_bg_color = t.score_bg_color
    score_label = t.score_label
    score_value = t.score_value
    overlay_win = t.overlay_win
    overlay_lose = t.overlay_lose
    help_bg_color = t.help_bg_color
    help_key_color = t.help_key_color
    help_key_text = t.help_key_text

    if not skip_morph and _G.theme then
        renderer.triggerThemeMorph(_G.theme)
    end
end

-- Initialize theme immediately (skip morph on startup)
renderer.applyTheme(true)
local matrix_cols = nil
local matrix_last_t = nil

function renderer.drawDynamicBackground(themeName)
    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    if themeName == "aurora" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Aurora palette: green, teal, purple, blue, pink bands
        local aurora_colors = {
            {0.0, 0.95, 0.60},  -- vivid green
            {0.0, 0.80, 0.90},  -- teal
            {0.45, 0.10, 0.95}, -- deep violet
            {0.0, 0.50, 1.0},   -- ice blue
            {0.85, 0.20, 0.75}, -- magenta
        }

        -- Layer 1: Wide layered curtain bands (tall vertical rectangles swept by sine waves)
        -- Each curtain spans nearly full screen height, anchored at top, waving at bottom
        local seg_count = 60
        for band = 1, 5 do
            local c = aurora_colors[band]
            local band_offset = (band - 1) * 0.18
            -- Each band sways at a slightly different frequency
            local sway_freq = 0.18 + band * 0.04
            local sway_amp = (55 + band * 18) * scale
            for seg = 0, seg_count do
                local frac = seg / seg_count
                local x = w * frac
                -- Top edge stays fixed near top, bottom edge waves dramatically
                local top_y = h * 0.0
                local bot_wave = math.sin(frac * math.pi * 2.5 + t * sway_freq + band * 1.3) * sway_amp
                             + math.sin(frac * math.pi * 4.0 + t * (sway_freq * 1.7) - band * 0.8) * (sway_amp * 0.5)
                local bot_y = h * (0.45 + band_offset) + bot_wave

                -- Brightness pulses along the length
                local brightness = 0.4 + 0.6 * math.sin(frac * math.pi * 3 + t * 0.25 + band * 0.7)
                local alpha = (0.05 + brightness * 0.09) * (1.0 - frac * 0.15)

                -- Draw tall thin rectangle for this segment
                local seg_w = (w / seg_count) + 1
                love.graphics.setColor(c[1], c[2], c[3], alpha)
                love.graphics.rectangle("fill", x, top_y, seg_w, bot_y - top_y)
            end
        end

        -- Layer 2: Soft glow fringe at curtain bottom edges
        for band = 1, 5 do
            local c = aurora_colors[band]
            local band_offset = (band - 1) * 0.18
            for glow = 1, 16 do
                local gx = w * (glow / 17)
                local sway = math.sin(gx / w * math.pi * 2.5 + t * (0.18 + band * 0.04) + band * 1.3) * (55 + band * 18) * scale
                local gy = h * (0.45 + band_offset) + sway
                local pulse = 0.5 + 0.5 * math.sin(t * 1.1 + glow * 0.5 + band)
                love.graphics.setColor(c[1], c[2], c[3], 0.12 + pulse * 0.10)
                love.graphics.circle("fill", gx, gy, (20 + pulse * 15) * scale)
            end
        end

        -- Layer 3: Drifting shimmer stars (small bright points)
        for i = 1, 35 do
            local golden = 0.6180339887
            local sx = ((i * golden) % 1.0) * w
            local sy = ((i * golden * 1.41) % 1.0) * (h * 0.55)
            local twinkle = math.sin(t * (1.5 + (i % 5) * 0.4) + i * 2.3) * 0.5 + 0.5
            local c = aurora_colors[(i % 5) + 1]
            love.graphics.setColor(c[1], c[2], c[3], twinkle * 0.4)
            love.graphics.circle("fill", sx + math.sin(t * 0.2 + i) * 8 * scale, sy, (0.8 + twinkle * 1.8) * scale)
        end

        love.graphics.pop()

    elseif themeName == "nebula" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Swirling dust clouds (large, slow, layered)
        local clouds = {
            {0.35, 0.25, 0.50, 0.12, 0.55, 280, 0.07},  -- deep purple
            {0.65, 0.55, 0.08, 0.15, 0.50, 300, 0.06},  -- deep blue
            {0.50, 0.70, 0.55, 0.05, 0.45, 240, 0.05},  -- teal accent
            {0.25, 0.65, 0.35, 0.25, 0.70, 200, 0.05},  -- pink nebula
        }
        for idx, cloud in ipairs(clouds) do
            local cx = w * cloud[1] + math.sin(t * 0.15 + idx * 1.5) * 90 * scale
            local cy = h * cloud[2] + math.cos(t * 0.12 + idx * 2.1) * 70 * scale
            -- Outer glow
            love.graphics.setColor(cloud[3], cloud[4], cloud[5], cloud[7] * 0.5)
            love.graphics.circle("fill", cx, cy, cloud[6] * 1.5 * scale)
            -- Inner core
            love.graphics.setColor(cloud[3] + 0.1, cloud[4] + 0.05, cloud[5] + 0.1, cloud[7])
            love.graphics.circle("fill", cx, cy, cloud[6] * scale)
        end

        -- Layer 2: Dense star field (50 stars with varied twinkle speeds)
        -- Restrict stars to the area above the help footer to keep the bottom clean and readable
        local star_pad = math.max(8 * scale, 8)
        local max_star_y = h - math.floor(75 * scale)
        for i = 1, 50 do
            -- Use golden-ratio-based distribution for even spread
            local golden = 0.6180339887
            local sx_pos = star_pad + (((i * golden * 1.0) % 1.0) * (w - star_pad * 2))
            local sy_pos = star_pad + (((i * golden * 1.41421356) % 1.0) * (max_star_y - star_pad * 2))
            local speed = 1.0 + (i % 7) * 0.4
            local twinkle = math.sin(t * speed + i * 3.14159) * 0.5 + 0.5
            local size_base = 0.6 + (i % 3) * 0.4
            -- Color variety: white, blue-white, pale yellow
            if i % 5 == 0 then
                love.graphics.setColor(0.8, 0.85, 1.0, twinkle * 0.55)
            elseif i % 5 == 1 then
                love.graphics.setColor(1.0, 1.0, 0.85, twinkle * 0.4)
            else
                love.graphics.setColor(1.0, 1.0, 1.0, twinkle * 0.45)
            end
            love.graphics.circle("fill", sx_pos, sy_pos, size_base * scale)
            -- Add small glow to brightest stars
            if twinkle > 0.8 and i % 4 == 0 then
                love.graphics.setColor(0.7, 0.8, 1.0, (twinkle - 0.8) * 0.3)
                love.graphics.circle("fill", sx_pos, sy_pos, size_base * 3.5 * scale)
            end
        end

        -- Layer 3: Shooting stars (2 at different phases)
        for s = 1, 2 do
            local cycle = 6.0 + s * 2.0
            local phase = (t + s * 3.7) % cycle
            local progress = phase / cycle
            if progress < 0.15 then  -- only visible during streak
                local streak_prog = progress / 0.15
                local sx_start = w * (0.1 + s * 0.35)
                local sy_start = h * (0.05 + s * 0.1)
                local sx_end = sx_start + w * 0.4
                local sy_end = sy_start + h * 0.25
                local cx = sx_start + (sx_end - sx_start) * streak_prog
                local cy = sy_start + (sy_end - sy_start) * streak_prog
                local tail_len = 35 * scale
                local dx = (sx_end - sx_start)
                local dy = (sy_end - sy_start)
                local mag = math.sqrt(dx * dx + dy * dy)
                dx, dy = dx / mag, dy / mag
                local alpha_head = 0.7 * (1.0 - streak_prog * 0.5)
                love.graphics.setColor(1.0, 1.0, 1.0, alpha_head)
                love.graphics.circle("fill", cx, cy, 1.5 * scale)
                -- Trail
                for trail = 1, 8 do
                    local tf = trail / 8
                    local tx = cx - dx * tail_len * tf
                    local ty = cy - dy * tail_len * tf
                    love.graphics.setColor(0.8, 0.85, 1.0, alpha_head * (1.0 - tf) * 0.6)
                    love.graphics.circle("fill", tx, ty, (1.5 - tf * 1.0) * scale)
                end
            end
        end

        love.graphics.pop()

    elseif themeName == "inferno" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Deep lava glow pools at bottom
        local pools = {
            {0.2, 0.9, 1.0, 0.15, 0.0},
            {0.5, 0.85, 1.0, 0.25, 0.0},
            {0.8, 0.92, 0.95, 0.10, 0.0},
        }
        for idx, p in ipairs(pools) do
            local px = w * p[1] + math.sin(t * 0.25 + idx * 2.0) * 40 * scale
            local py = h * p[2] + math.cos(t * 0.3 + idx) * 15 * scale
            local pulse = 0.7 + 0.3 * math.sin(t * 0.8 + idx * 1.5)
            -- Outer glow
            love.graphics.setColor(p[3], p[4], p[5], 0.04 * pulse)
            love.graphics.circle("fill", px, py, 200 * scale)
            -- Inner hot core
            love.graphics.setColor(1.0, 0.35, 0.0, 0.06 * pulse)
            love.graphics.circle("fill", px, py, 120 * scale)
            -- Brightest center
            love.graphics.setColor(1.0, 0.6, 0.1, 0.05 * pulse)
            love.graphics.circle("fill", px, py, 60 * scale)
        end

        -- Layer 2: Rising ember particles (40 particles)
        for i = 1, 40 do
            -- Distribute start positions evenly across width
            local start_x = w * ((i * 0.618 + 0.1) % 1.0)
            local rise_speed = 15 + (i % 7) * 8
            local sway_amount = 20 + (i % 5) * 8
            local sway_speed = 0.8 + (i % 4) * 0.3

            -- Y position: rises from bottom to top, wraps around
            local y_cycle = h + 40 * scale
            local y = h + 20 * scale - ((t * rise_speed + i * 73.7) % y_cycle)

            -- X position: sways side to side
            local x = start_x + math.sin(t * sway_speed + i * 2.3) * sway_amount * scale

            -- Life fraction (0 at bottom, 1 at top)
            local life = 1.0 - (y / h)
            life = math.max(0, math.min(1, life))

            -- Size decreases as it rises
            local size = (1.8 + (i % 3) * 0.6) * scale * (1.0 - life * 0.5)

            -- Flicker
            local flicker = 0.6 + 0.4 * math.sin(t * 5.0 + i * 4.1)

            -- Color shifts from bright yellow at bottom to dark red at top
            local r = 1.0
            local g = math.max(0, 0.7 - life * 0.6)
            local b = math.max(0, 0.1 - life * 0.1)
            local a = flicker * (0.5 - life * 0.35)

            if a > 0.01 then
                -- Ember glow
                love.graphics.setColor(r, g, b, a * 0.3)
                love.graphics.circle("fill", x, y, size * 3)
                -- Ember core
                love.graphics.setColor(r, g + 0.1, b, a)
                love.graphics.circle("fill", x, y, size)
            end
        end

        -- Layer 3: Heat distortion waves (horizontal shimmer lines)
        love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
        for i = 1, 6 do
            local wave_y = h * (0.4 + i * 0.08) + math.sin(t * 0.4 + i) * 20 * scale
            local segments = 20
            local alpha = 0.03 + 0.02 * math.sin(t * 0.6 + i * 1.2)
            love.graphics.setColor(1.0, 0.4, 0.0, alpha)
            for seg = 0, segments - 1 do
                local x1 = w * (seg / segments)
                local x2 = w * ((seg + 1) / segments)
                local y1 = wave_y + math.sin(t * 1.5 + seg * 0.5 + i * 2) * 4 * scale
                local y2 = wave_y + math.sin(t * 1.5 + (seg + 1) * 0.5 + i * 2) * 4 * scale
                love.graphics.line(x1, y1, x2, y2)
            end
        end

        love.graphics.pop()

    elseif themeName == "honk" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Ambient morning mist & sun glare on the pond (soft drifting glowing orbs)
        local cx, cy = w / 2, h / 2
        for i = 1, 3 do
            local mist_x = cx + math.sin(t * 0.2 + i) * 150 * scale
            local mist_y = cy + math.cos(t * 0.15 + i * 1.5) * 80 * scale
            local pulse = 0.5 + 0.5 * math.sin(t * 0.3 + i * 2)
            love.graphics.setColor(1.0, 0.95, 0.8, 0.08 * pulse) -- warm sun glow
            love.graphics.circle("fill", mist_x, mist_y, (180 + i * 40) * scale)
        end

        -- Layer 2: Distant water shimmer (horizontal streaks on the upper pond surface)
        local shimmer_rng = love.math.newRandomGenerator(88)
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        for i = 1, 15 do
            local sx = shimmer_rng:random() * w
            local sy = h * 0.05 + shimmer_rng:random() * (h * 0.55)
            local s_length = (20 + shimmer_rng:random() * 50) * scale
            local s_speed = 0.5 + shimmer_rng:random() * 0.5
            local offset_x = (sx + t * 15 * s_speed) % (w + s_length) - s_length
            
            local alpha = (0.05 + 0.05 * math.sin(t * (1.5 + shimmer_rng:random()) + i))
            if alpha > 0.01 then
                love.graphics.setColor(0.9, 0.95, 1.0, alpha)
                love.graphics.line(offset_x, sy, offset_x + s_length, sy)
            end
        end

        -- Layer 3: Elegant water surface (perspective elliptical ripples on the upper half)
        love.graphics.setLineWidth(math.max(1, math.floor(1.5 * scale)))
        local ripple_rng = love.math.newRandomGenerator(123)
        for i = 1, 12 do
            local rx = ripple_rng:random() * w
            local ry = h * 0.1 + ripple_rng:random() * (h * 0.6)
            local cycle = 3.0 + ripple_rng:random() * 2.5
            local progress = ((t + i * 1.7) % cycle) / cycle
            
            local radius = progress * 75 * scale
            -- Fade in quickly, then fade out slowly
            local alpha = (progress < 0.1) and (progress / 0.1) * 0.3 or (1.0 - progress) * 0.3
            
            if alpha > 0.01 then
                love.graphics.setColor(0.85, 0.95, 1.0, alpha)
                love.graphics.ellipse("line", rx, ry, radius, radius * 0.3)
                if radius > 12 * scale then
                    love.graphics.setColor(0.85, 0.95, 1.0, alpha * 0.4)
                    love.graphics.ellipse("line", rx, ry, radius - 8 * scale, (radius - 8 * scale) * 0.3)
                end
            end
        end

        -- Layer 4: Clean, smooth overlapping waves at the bottom (solid filled pastel colors)
        -- Added a subtle gradient effect by layering colors
        local wave_layers = {
            {y = 0.55, h = 12, c = {0.55, 0.78, 0.88, 0.35}},
            {y = 0.65, h = 15, c = {0.45, 0.72, 0.85, 0.50}},
            {y = 0.75, h = 18, c = {0.35, 0.65, 0.80, 0.70}},
            {y = 0.85, h = 22, c = {0.25, 0.58, 0.75, 0.85}},
        }
        
        for i, wl in ipairs(wave_layers) do
            love.graphics.setColor(wl.c)
            local points = {}
            table.insert(points, 0)
            table.insert(points, h)
            
            local segments = 45
            local wave_height = wl.h * scale
            local base_y = h * wl.y
            
            for s = 0, segments do
                local px = (s / segments) * w
                -- Combines two sine waves for a more organic, less uniform "sloshing" motion
                local wave1 = math.sin(t * (0.4 + i * 0.1) + s * 0.25 + i * 1.8)
                local wave2 = math.cos(t * (0.3 + i * 0.05) + s * 0.15 + i * 2.5) * 0.5
                local py = base_y + (wave1 + wave2) * wave_height
                table.insert(points, px)
                table.insert(points, py)
            end
            
            table.insert(points, w)
            table.insert(points, h)
            
            love.graphics.polygon("fill", points)
            
            -- Bright highlight line on the crest of each wave
            love.graphics.setLineWidth(math.max(1, math.floor(1.5 * scale)))
            love.graphics.setColor(1.0, 1.0, 1.0, 0.25)
            for s = 1, segments do
                local x1 = points[2 + (s-1)*2 + 1]
                local y1 = points[2 + (s-1)*2 + 2]
                local x2 = points[2 + s*2 + 1]
                local y2 = points[2 + s*2 + 2]
                love.graphics.line(x1, y1, x2, y2)
            end
        end


        love.graphics.pop()

    elseif themeName == "matrix" then
        local t = love.timer.getTime()
        if not matrix_last_t then matrix_last_t = t end
        local dt = math.min(t - matrix_last_t, 0.1)
        matrix_last_t = t

        local w, h = love.graphics.getDimensions()
        local scale = _G.scale
        local font = font_label or love.graphics.getFont()
        local char_h = math.floor(15 * scale)
        local col_w = math.floor(16 * scale)
        local num_cols = math.floor(w / col_w) + 1

        if not matrix_cols or #matrix_cols ~= num_cols then
            matrix_cols = {}
            for i = 1, num_cols do
                local col = {}
                col.x = (i - 1) * col_w + math.random(-2, 2)
                col.y = math.random(-h, 0)
                col.speed = math.random(50, 130) * scale
                col.length = math.random(8, 22)
                col.chars = {}
                for j = 1, col.length do
                    col.chars[j] = string.char(math.random(33, 126))
                end
                col.mut_timers = {}
                for j = 1, col.length do
                    col.mut_timers[j] = math.random() * 0.5
                end
                matrix_cols[i] = col
            end
        end

        love.graphics.push("all")
        love.graphics.setFont(font)

        local chars_pool = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$#@%&*+-=:<>?"

        for i = 1, num_cols do
            local col = matrix_cols[i]
            col.y = col.y + col.speed * dt
            if col.y > h then
                col.y = -col.length * char_h
                col.speed = math.random(50, 130) * scale
                col.x = (i - 1) * col_w + math.random(-2, 2)
            end

            for j = 1, col.length do
                col.mut_timers[j] = col.mut_timers[j] - dt
                if col.mut_timers[j] <= 0 then
                    col.mut_timers[j] = math.random(0.1, 0.6)
                    local rand_idx = math.random(1, #chars_pool)
                    col.chars[j] = chars_pool:sub(rand_idx, rand_idx)
                end
            end

            for j = 1, col.length do
                local cy = col.y + (j - 1) * char_h
                if cy >= -char_h and cy <= h then
                    local alpha = j / col.length

                    if j == col.length then
                        love.graphics.setColor(0.7, 1.0, 0.7, 0.95)
                        love.graphics.print(col.chars[j], col.x, cy)
                        love.graphics.setColor(0.0, 1.0, 0.0, 0.2)
                        love.graphics.circle("fill", col.x + col_w/2, cy + char_h/2, 6 * scale)
                    else
                        local r = 0.0
                        local g = 0.3 + 0.7 * alpha
                        local b = 0.0
                        love.graphics.setColor(r, g, b, alpha * 0.6)
                        love.graphics.print(col.chars[j], col.x, cy)
                    end
                end
            end
        end

        love.graphics.pop()

    elseif themeName == "glitch" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Seeded RNG for deterministic-but-changing chaos
        local time_step = math.floor(t * 12)
        local rng = love.math.newRandomGenerator(time_step * 17 + 31)
        local rng_slow = love.math.newRandomGenerator(math.floor(t * 4) * 53 + 19)

        -- Layer 1: Occasional scanline tears (sparse, not constant)
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        local num_tears = rng:random(1, 4)
        for i = 1, num_tears do
            local ty = rng:random(0, h)
            local tear_h = rng:random(1, 4) * scale
            local shift = rng:random(-20, 20) * scale
            local ct = rng:random(1, 3)
            if ct == 1 then love.graphics.setColor(0.0, 1.0, 0.95, 0.10)
            elseif ct == 2 then love.graphics.setColor(1.0, 0.05, 0.70, 0.10)
            else love.graphics.setColor(1.0, 1.0, 1.0, 0.08) end
            love.graphics.rectangle("fill", shift, ty, w + math.abs(shift), tear_h)
        end

        -- Layer 2: Subtle RGB channel-split bars (happens slowly)
        local num_splits = rng_slow:random(1, 2)
        for i = 1, num_splits do
            local sy = rng_slow:random(0, h - 30)
            local sh = rng_slow:random(3, 14) * scale
            local drift = rng_slow:random(4, 14) * scale
            love.graphics.setColor(1.0, 0.0, 0.0, 0.05)
            love.graphics.rectangle("fill", drift, sy, w, sh)
            love.graphics.setColor(0.0, 0.0, 1.0, 0.05)
            love.graphics.rectangle("fill", -drift, sy, w, sh)
        end

        -- Layer 3: Rare VHS block (only occasionally)
        if rng:random() > 0.85 then
            local bx = rng:random(0, w)
            local by = rng:random(0, h)
            local bw = rng:random(30, 120) * scale
            local bh = rng:random(2, 5) * scale
            if rng:random() > 0.5 then
                love.graphics.setColor(0.0, 1.0, 0.95, 0.14)
            else
                love.graphics.setColor(1.0, 0.0, 0.65, 0.13)
            end
            love.graphics.rectangle("fill", bx, by, bw, bh)
        end

        -- Layer 4: Faint scrolling grid substrate
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        local grid = 38 * scale
        local off_x = (t * 4 * scale) % grid
        local off_y = (t * 7 * scale) % grid
        love.graphics.setColor(0.0, 0.9, 0.8, 0.03)
        for x = -grid, w + grid, grid do
            love.graphics.line(x + off_x, 0, x + off_x, h)
        end
        for y = -grid, h + grid, grid do
            love.graphics.line(0, y + off_y, w, y + off_y)
        end

        love.graphics.pop()

    elseif themeName == "vaporwave" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        local horizon_y = h * 0.48
        local sun_x = w / 2
        local sun_r = 72 * scale

        -- Layer 1: Gradient sky (deep purple top → hot pink horizon)
        local sky_bands = 28
        for i = 0, sky_bands do
            local frac = i / sky_bands
            -- Top = deep indigo, horizon = vivid magenta
            local r = 0.10 + frac * 0.85
            local g = 0.02 + frac * 0.05
            local b = 0.35 - frac * 0.05
            local band_y = frac * horizon_y
            local band_h = (horizon_y / sky_bands) + 1
            love.graphics.setColor(r, g, b, 0.18)
            love.graphics.rectangle("fill", 0, band_y, w, band_h)
        end

        -- Layer 2: Twinkling retro stars in upper sky
        for i = 1, 40 do
            local golden = 0.6180339887
            local sx = ((i * golden) % 1.0) * w
            local sy = ((i * golden * 1.41) % 1.0) * horizon_y * 0.8
            local twinkle = math.sin(t * (1.0 + (i % 5) * 0.3) + i * 1.7) * 0.5 + 0.5
            love.graphics.setColor(1.0, 0.85, 1.0, twinkle * 0.35)
            love.graphics.circle("fill", sx, sy, (0.7 + twinkle * 1.0) * scale)
        end

        -- Layer 3: Glowing sun with hard horizontal stripe cuts
        -- Outer glow layers
        for r = sun_r * 1.8, sun_r, -4 * scale do
            local f = (r - sun_r) / (sun_r * 0.8)
            love.graphics.setColor(1.0, 0.30, 0.70, 0.04 * (1.0 - f))
            love.graphics.circle("fill", sun_x, horizon_y, r)
        end
        -- Main sun body gradient (hot pink top → orange bottom)
        local sun_segs = 20
        for s = 0, sun_segs do
            local f = s / sun_segs
            local r_c = 0.95
            local g_c = 0.10 + f * 0.50
            local b_c = 0.55 - f * 0.45
            local seg_r = sun_r * (1.0 - f * 0.0)
            local seg_h = (sun_r * 2) / sun_segs
            love.graphics.setColor(r_c, g_c, b_c, 0.22)
            love.graphics.rectangle("fill", sun_x - sun_r, horizon_y - sun_r + f * sun_r * 2, sun_r * 2, seg_h + 1)
        end
        -- Clip sun to circle using stencil-style overdraw with bg (bg_color mask)
        -- We draw horizontal stripe cuts across the lower half (vaporwave signature)
        local num_cuts = 8
        for i = 1, num_cuts do
            local cut_frac = i / (num_cuts + 1)
            local cut_y = horizon_y + cut_frac * sun_r - sun_r * 0.05
            -- Cuts get thicker toward horizon (perspective)
            local cut_h = (1.0 + cut_frac * cut_frac * 5.0) * scale
            love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], 1.0)
            love.graphics.rectangle("fill", sun_x - sun_r - 2 * scale, cut_y, sun_r * 2 + 4 * scale, cut_h)
        end

        -- Layer 4: 3D perspective grid on ground
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        -- Vertical vanishing lines (fan out from sun center)
        for i = -12, 12 do
            local spread = i * 42 * scale
            local alpha = 0.16 - math.abs(i) * 0.008
            love.graphics.setColor(0.95, 0.15, 0.70, math.max(0.03, alpha))
            love.graphics.line(sun_x, horizon_y, sun_x + spread * 2.2, h)
        end
        -- Scrolling horizontal ground lines (exponential spacing = perspective)
        local scroll = (t * 28 * scale)
        for i = 1, 12 do
            local spacing = math.pow(1.32, i) * 5 * scale
            local line_y = horizon_y + spacing + (scroll % (math.pow(1.32, i) * 2.5 * scale))
            if line_y < h then
                local fade = (line_y - horizon_y) / (h - horizon_y)
                love.graphics.setColor(0.05, 0.85, 1.0, 0.22 * fade)
                love.graphics.line(0, line_y, w, line_y)
            end
        end

        -- Layer 5: Floating retro geometric shapes in sky
        local shapes = {{0.15, 0.25}, {0.72, 0.18}, {0.88, 0.35}, {0.05, 0.38}}
        for idx, s in ipairs(shapes) do
            local sx2 = w * s[1] + math.sin(t * 0.2 + idx * 1.3) * 12 * scale
            local sy2 = h * s[2] + math.cos(t * 0.15 + idx * 2.1) * 8 * scale
            local sz = (12 + idx * 6) * scale
            local pulse = 0.5 + 0.5 * math.sin(t * 0.5 + idx)
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            love.graphics.setColor(0.95, 0.15, 0.70, 0.10 + pulse * 0.08)
            love.graphics.rectangle("line", sx2 - sz, sy2 - sz, sz * 2, sz * 2)
            love.graphics.setColor(0.05, 0.85, 1.0, 0.06 + pulse * 0.05)
            love.graphics.rectangle("line", sx2 - sz * 0.6, sy2 - sz * 0.6, sz * 1.2, sz * 1.2)
        end

        love.graphics.pop()

    elseif themeName == "cyberpunk" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Neon rain — vertical streaks of cyan/pink falling fast
        local rain_rng = love.math.newRandomGenerator(42)
        for i = 1, 28 do
            local rx = ((rain_rng:random() * 0.95 + 0.025) * w)
            local speed = 80 + rain_rng:random() * 120
            local length = (18 + rain_rng:random() * 40) * scale
            local ry = (t * speed * scale + i * 97.3) % (h + length)
            local alpha = 0.18 + rain_rng:random() * 0.14
            if i % 3 == 0 then
                love.graphics.setColor(0.0, 1.0, 0.9, alpha)   -- cyan
            elseif i % 3 == 1 then
                love.graphics.setColor(1.0, 0.05, 0.65, alpha) -- hot pink
            else
                love.graphics.setColor(0.6, 0.0, 1.0, alpha)   -- purple
            end
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            love.graphics.line(rx, ry - length, rx, ry)
            -- Bright head dot
            love.graphics.setColor(1.0, 1.0, 1.0, alpha * 0.7)
            love.graphics.circle("fill", rx, ry, 1.2 * scale)
        end

        -- Layer 2: Perspective neon grid (cyan horizontal, pink vertical)
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        local grid = 55 * scale
        for x = 0, w, grid do
            local alpha = 0.07 + 0.04 * math.sin(t * 0.8 + x / w * math.pi)
            love.graphics.setColor(0.95, 0.05, 0.55, alpha)
            love.graphics.line(x, 0, x, h)
        end
        for y = 0, h, grid do
            local alpha = 0.07 + 0.03 * math.sin(t * 0.6 + y / h * math.pi)
            love.graphics.setColor(0.0, 1.0, 0.90, alpha)
            love.graphics.line(0, y, w, y)
        end


        -- Layer 4: Scrolling scanlines (fast, thin, TV interference effect)
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        local scan_count = 20
        for i = 1, scan_count do
            local sy = ((t * 55 * scale + i * (h / scan_count)) % h)
            local alpha = 0.025 + 0.015 * math.sin(t * 8.0 + i * 0.7)
            love.graphics.setColor(0.0, 1.0, 0.9, alpha)
            love.graphics.line(0, sy, w, sy)
        end

        -- Layer 5: Flickering corner circuit traces
        local corners = {{0, 0}, {w, 0}, {0, h}, {w, h}}
        for ci, corner in ipairs(corners) do
            local cx2, cy2 = corner[1], corner[2]
            local flip_x = (ci == 1 or ci == 3) and 1 or -1
            local flip_y = (ci == 1 or ci == 2) and 1 or -1
            local flicker = 0.5 + 0.5 * math.sin(t * 3.5 + ci * 2.1)
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            love.graphics.setColor(0.0, 1.0, 0.9, 0.12 * flicker)
            -- L-shaped trace lines
            love.graphics.line(cx2, cy2, cx2 + flip_x * 60 * scale, cy2)
            love.graphics.line(cx2, cy2, cx2, cy2 + flip_y * 60 * scale)
            love.graphics.line(cx2 + flip_x * 60 * scale, cy2, cx2 + flip_x * 60 * scale, cy2 + flip_y * 20 * scale)
            love.graphics.line(cx2, cy2 + flip_y * 60 * scale, cx2 + flip_x * 20 * scale, cy2 + flip_y * 60 * scale)
            -- Node dots at joints
            love.graphics.setColor(1.0, 0.05, 0.65, 0.18 * flicker)
            love.graphics.circle("fill", cx2 + flip_x * 60 * scale, cy2 + flip_y * 20 * scale, 2.5 * scale)
            love.graphics.circle("fill", cx2 + flip_x * 20 * scale, cy2 + flip_y * 60 * scale, 2.5 * scale)
        end

        love.graphics.pop()

    elseif themeName == "ocean" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Rising bubbles
        love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
        for i = 1, 15 do
            local start_x = w * ((i * 0.72) % 1.0)
            local speed = 12 + (i % 5) * 6
            local y_cycle = h + 30 * scale
            local y = h + 15 * scale - ((t * speed + i * 29.3) % y_cycle)
            local x = start_x + math.sin(t * 0.7 + i) * 12 * scale
            local radius = (2.0 + (i % 3) * 1.5) * scale
            local alpha = 0.12 * (1.0 - (h - y) / h)
            
            love.graphics.setColor(0.55, 0.85, 1.0, alpha)
            love.graphics.circle("line", x, y, radius)
            -- Small reflection dot inside bubble
            love.graphics.setColor(1.0, 1.0, 1.0, alpha * 0.5)
            love.graphics.circle("fill", x - radius * 0.3, y - radius * 0.3, radius * 0.15)
        end

        love.graphics.pop()

    elseif themeName == "forest" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Ambient Forest Canopy Light (Wide spread)
        local pulse1 = 0.5 + 0.5 * math.sin(t * 0.25)
        local pulse2 = 0.5 + 0.5 * math.sin(t * 0.35 + 2.0)
        
        love.graphics.setColor(0.18, 0.45, 0.25, 0.12 * pulse1)
        love.graphics.circle("fill", w * 0.3, h * 0.2, 400 * scale)
        
        love.graphics.setColor(0.20, 0.50, 0.30, 0.10 * pulse2)
        love.graphics.circle("fill", w * 0.7, h * 0.3, 350 * scale)
        
        love.graphics.setColor(0.25, 0.60, 0.35, 0.08 * pulse1)
        love.graphics.circle("fill", w * 0.5, h * 0.1, 250 * scale)
        -- Layer 2: Subtle Ground Mist
        for mist = 1, 3 do
            local mx = w * (mist / 4) + math.sin(t * 0.08 + mist * 1.3) * 30 * scale
            local my = h - math.sin(t * 0.12 + mist) * 5 * scale
            local mr = (70 + mist * 15) * scale
            love.graphics.setColor(0.20, 0.45, 0.25, 0.06)
            love.graphics.circle("fill", mx, my, mr)
        end

        -- Layer 3: Tiny Gentle Fireflies
        local ff_rng = love.math.newRandomGenerator(321)
        for i = 1, 8 do
            local base_x = ff_rng:random() * w
            local speed = 0.2 + (i % 4) * 0.1
            local y_cycle = h * 1.2
            local fy = (h * 1.1) - ((t * speed * 30 + i * 117) % y_cycle)
            local fx = base_x + math.sin(t * speed + i * 1.7) * 25 * scale
            
            local f_pulse = 0.5 + 0.5 * math.sin(t * 1.5 + i * 1.3)
            local alpha = (0.1 + 0.3 * f_pulse) * math.min(1.0, fy / (h * 0.8))
            
            if alpha > 0.01 then
                local sz = (0.8 + (i % 3) * 0.3) * scale
                love.graphics.setColor(0.60, 0.98, 0.50, alpha * 0.3)
                love.graphics.circle("fill", fx, fy, sz * 2.5)
                love.graphics.setColor(0.80, 1.0, 0.60, alpha * 0.8)
                love.graphics.circle("fill", fx, fy, sz * 0.8)
            end
        end

        -- Layer 4: Elegant Falling Leaves (Minimalist Elongated Ellipses)
        for i = 1, 24 do
            local start_x = ((i * 0.6180339887) % 1.0) * w
            local speed_y = 12 + (i % 5) * 5
            local y_cycle = h + 60 * scale
            local y = -30 * scale + ((t * speed_y + i * 61.3) % y_cycle)
            local x = start_x + math.sin(t * (0.4 + (i % 3) * 0.2) + i * 1.7) * 25 * scale
            local size = (4.0 + (i % 4) * 2.0) * scale
            local rot = (t * 0.5 + i * 0.8) + math.sin(t * 0.8 + i) * 0.3
            local life = 1.0 - (y / h)
            local alpha = math.max(0, math.min(0.6, life * 0.8))

            if alpha > 0.01 then
                love.graphics.push()
                love.graphics.translate(x, y)
                love.graphics.rotate(rot)

                -- Curated forest green palette
                local greens = {
                    {0.15, 0.55, 0.18}, {0.30, 0.72, 0.20},
                    {0.08, 0.42, 0.12}, {0.45, 0.78, 0.22}
                }
                local c = greens[(i % 4) + 1]

                -- Leaf body
                love.graphics.setColor(c[1], c[2], c[3], alpha)
                love.graphics.ellipse("fill", 0, 0, size, size * 0.38)
                
                -- Leaf center vein
                love.graphics.setColor(c[1] * 0.6, c[2] * 0.6 + 0.1, c[3] * 0.6, alpha * 0.6)
                love.graphics.setLineWidth(math.max(1, math.floor(0.7 * scale)))
                love.graphics.line(-size * 0.8, 0, size * 0.8, 0)

                love.graphics.pop()
            end
        end

        love.graphics.pop()

    elseif themeName == "volcano" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Deep magma glow pools at the bottom (wide underground heat)
        local pools = {
            {0.18, 1.10, 240, 0.0},  -- left pool
            {0.50, 1.08, 300, 0.0},  -- center pool
            {0.82, 1.10, 210, 0.0},  -- right pool
        }
        for idx, p in ipairs(pools) do
            local px = w * p[1] + math.sin(t * 0.2 + idx * 1.7) * 22 * scale
            local py = h * p[2]
            local pulse = 0.6 + 0.4 * math.sin(t * 0.55 + idx * 2.1)
            local radius = p[3] * scale * pulse
            -- Deep red outer glow
            love.graphics.setColor(0.80, 0.08, 0.0, 0.06 * pulse)
            love.graphics.circle("fill", px, py, radius * 1.6)
            -- Orange mid glow
            love.graphics.setColor(1.0, 0.30, 0.0, 0.08 * pulse)
            love.graphics.circle("fill", px, py, radius)
            -- Bright yellow-white core
            love.graphics.setColor(1.0, 0.75, 0.1, 0.07 * pulse)
            love.graphics.circle("fill", px, py, radius * 0.45)
        end

        -- Layer 2: Lava burst jets — 3 eruption vents shooting arcs upward
        local vents = {0.20, 0.50, 0.80}
        for vi, vx_frac in ipairs(vents) do
            local vent_x = w * vx_frac
            local vent_y = h + 5 * scale
            -- Each vent fires multiple lava blobs in arcs
            for arc = 1, 7 do
                local arc_cycle = 2.8 + vi * 0.4 + arc * 0.15
                local arc_phase = (t * 0.85 + vi * 1.3 + arc * 0.7) % arc_cycle
                local arc_prog = arc_phase / arc_cycle

                if arc_prog < 0.55 then  -- blob only visible on the way up
                    local launch_angle = math.pi * (0.55 + (arc - 4) * 0.055)  -- fan upward
                    local launch_speed = (0.45 + arc * 0.06) * h
                    -- Parabolic arc: x linear, y with gravity
                    local blob_x = vent_x + math.cos(launch_angle) * launch_speed * arc_prog
                    local blob_y = vent_y + math.sin(launch_angle) * launch_speed * arc_prog
                                 + 0.5 * (9.8 * 15 * scale) * arc_prog * arc_prog  -- gravity

                    local life = 1.0 - arc_prog / 0.55
                    local size = (3.5 + arc * 1.2) * scale * life
                    -- Color: white-hot at launch → orange → red as it cools
                    local heat = life
                    local r_c = 1.0
                    local g_c = 0.30 + heat * 0.55
                    local b_c = heat * heat * 0.20
                    local alpha = life * 0.45

                    -- Glow aura
                    love.graphics.setColor(r_c, g_c * 0.6, 0.0, alpha * 0.35)
                    love.graphics.circle("fill", blob_x, blob_y, size * 2.2)
                    -- Main blob
                    love.graphics.setColor(r_c, g_c, b_c, alpha)
                    love.graphics.circle("fill", blob_x, blob_y, size)
                    -- Bright core
                    love.graphics.setColor(1.0, 1.0, 0.7, alpha * 0.6 * heat)
                    love.graphics.circle("fill", blob_x, blob_y, size * 0.4)
                end
            end
        end

        -- Layer 3: Dense rising ember particles (50 embers, varied speed/color/size)
        for i = 1, 50 do
            local golden = 0.6180339887
            local start_x = w * ((i * golden) % 1.0)
            local rise_speed = 20 + (i % 9) * 12
            local sway_speed = 0.6 + (i % 5) * 0.25
            local sway_amp = (10 + (i % 6) * 8) * scale

            local y_cycle = h + 60 * scale
            local y = h + 30 * scale - ((t * rise_speed + i * 71.3) % y_cycle)
            local x = start_x + math.sin(t * sway_speed + i * 2.1) * sway_amp

            -- Life: 0 at bottom, 1 at top
            local life = math.max(0, math.min(1, 1.0 - (y / h)))
            local size_base = (1.0 + (i % 4) * 0.7) * scale

            -- Color: white-hot near bottom (fresh), dims and reddens as rises
            local heat = 1.0 - life * 0.8
            local r_e = 1.0
            local g_e = math.max(0, heat * 0.7 - life * 0.3)
            local b_e = math.max(0, heat * 0.3 - life * 0.3)
            local alpha = (1.0 - life * 0.85) * 0.45

            -- Tiny glow halo
            love.graphics.setColor(r_e, g_e * 0.5, 0.0, alpha * 0.3)
            love.graphics.circle("fill", x, y, size_base * 2.8)
            -- Ember dot
            love.graphics.setColor(r_e, g_e, b_e, alpha)
            love.graphics.circle("fill", x, y, size_base)
        end

        -- Layer 4: Heat shimmer waves (horizontal distortion bands rising from bottom)
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        for wave = 1, 5 do
            local wave_y = h * (0.65 + wave * 0.06) + math.sin(t * 0.8 + wave) * 6 * scale
            local alpha = (0.04 - wave * 0.006) * (0.6 + 0.4 * math.sin(t * 1.5 + wave * 1.3))
            love.graphics.setColor(1.0, 0.45, 0.0, alpha)
            -- Wobbly horizontal line
            local segs = 20
            for s = 0, segs - 1 do
                local x1 = w * (s / segs)
                local x2 = w * ((s + 1) / segs)
                local y1 = wave_y + math.sin(t * 2.5 + s * 0.6 + wave) * 4 * scale
                local y2 = wave_y + math.sin(t * 2.5 + (s + 1) * 0.6 + wave) * 4 * scale
                love.graphics.line(x1, y1, x2, y2)
            end
        end

        love.graphics.pop()


    elseif themeName == "dracula" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Deep crimson moonlight bloom (large glow from top-right like a blood moon)
        local moon_x = w * 0.82 + math.sin(t * 0.05) * 12 * scale
        local moon_y = h * 0.12 + math.cos(t * 0.04) * 8 * scale
        for r = 5, 1, -1 do
            local radius = r * 55 * scale
            local alpha = (0.035 - r * 0.004) * (0.8 + 0.2 * math.sin(t * 0.3))
            love.graphics.setColor(0.75, 0.02, 0.08, alpha)
            love.graphics.circle("fill", moon_x, moon_y, radius)
        end
        -- Bright moon core
        love.graphics.setColor(0.95, 0.70, 0.72, 0.08)
        love.graphics.circle("fill", moon_x, moon_y, 28 * scale)

        -- Layer 2: Drifting purple-black mist pools
        local mists = {
            {0.22, 0.30, 0.11, 0.08},
            {0.78, 0.65, 0.09, 0.07},
            {0.45, 0.80, 0.13, 0.06},
            {0.10, 0.70, 0.10, 0.05},
        }
        for mi, m in ipairs(mists) do
            local mx = w * m[1] + math.sin(t * 0.08 + mi * 1.7) * 50 * scale
            local my = h * m[2] + math.cos(t * 0.06 + mi * 2.3) * 30 * scale
            local pulse = 0.7 + 0.3 * math.sin(t * 0.2 + mi)
            love.graphics.setColor(0.28, 0.02, 0.38, m[3] * pulse)
            love.graphics.circle("fill", mx, my, m[4] * 1000 * scale)
        end

        -- Layer 3: Castlevania bat swarms (enhanced alpha + purple tint)

        local cycle1 = 13.0
        local prog1 = (t % cycle1) / cycle1
        local s1_x = w * 1.3 - prog1 * (w * 1.7)
        local s1_y = h * 0.28 + math.sin(t * 0.6) * 35 * scale
        local alpha1 = 0.50 * math.max(0, 1.0 - prog1 * 1.4)

        for i = 1, 6 do
            local ox = math.sin(i * 1.9) * 50 * scale
            local oy = math.cos(i * 2.7) * 32 * scale
            local bx = s1_x + ox + math.sin(t * 1.8 + i) * 8 * scale
            local by = s1_y + oy + math.cos(t * 2.2 + i * 1.5) * 6 * scale
            local wing_span = (22 + (i % 3) * 7) * scale
            local flap = math.sin(t * 15 + i * 2) * (wing_span * 0.32)
            love.graphics.setColor(0.08, 0.0, 0.12, alpha1)
            love.graphics.polygon("fill",
                bx, by - 5 * scale,
                bx - 2 * scale, by - 8 * scale,
                bx - 3 * scale, by - 3 * scale,
                bx - 6 * scale, by - 4 * scale - flap * 0.3,
                bx - wing_span / 2, by - flap,
                bx - wing_span * 0.32, by - flap * 0.4 + 2 * scale,
                bx - wing_span * 0.16, by - flap * 0.2 + 3 * scale,
                bx, by + 4 * scale,
                bx + wing_span * 0.16, by - flap * 0.2 + 3 * scale,
                bx + wing_span * 0.32, by - flap * 0.4 + 2 * scale,
                bx + wing_span / 2, by - flap,
                bx + 6 * scale, by - 4 * scale - flap * 0.3,
                bx + 3 * scale, by - 3 * scale,
                bx + 2 * scale, by - 8 * scale
            )
        end

        local cycle2 = 17.0
        local prog2 = ((t + 9.0) % cycle2) / cycle2
        local s2_x = -w * 0.3 + prog2 * (w * 1.7)
        local s2_y = h * 0.58 + math.cos(t * 0.4) * 45 * scale
        local alpha2 = 0.45 * math.max(0, 1.0 - prog2 * 1.4)

        for i = 1, 4 do
            local ox = math.sin(i * 2.2 + 1) * 38 * scale
            local oy = math.cos(i * 3.1 + 2) * 25 * scale
            local bx = s2_x + ox + math.sin(t * 1.4 + i * 2) * 6 * scale
            local by = s2_y + oy + math.cos(t * 1.9 + i) * 5 * scale
            local wing_span = (18 + (i % 2) * 7) * scale
            local flap = math.sin(t * 14 + i * 3) * (wing_span * 0.30)
            love.graphics.setColor(0.08, 0.0, 0.12, alpha2)
            love.graphics.polygon("fill",
                bx, by - 5 * scale,
                bx - 2 * scale, by - 8 * scale,
                bx - 3 * scale, by - 3 * scale,
                bx - 6 * scale, by - 4 * scale - flap * 0.3,
                bx - wing_span / 2, by - flap,
                bx - wing_span * 0.32, by - flap * 0.4 + 2 * scale,
                bx - wing_span * 0.16, by - flap * 0.2 + 3 * scale,
                bx, by + 4 * scale,
                bx + wing_span * 0.16, by - flap * 0.2 + 3 * scale,
                bx + wing_span * 0.32, by - flap * 0.4 + 2 * scale,
                bx + wing_span / 2, by - flap,
                bx + 6 * scale, by - 4 * scale - flap * 0.3,
                bx + 3 * scale, by - 3 * scale,
                bx + 2 * scale, by - 8 * scale
            )
        end

        love.graphics.pop()

    elseif themeName == "retro" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Floating pixel stars (8-bit style)
        for i = 1, 10 do
            local sx = ((i * 137.5) % 1.0) * w
            local sy = ((i * 47.3 + t * 12) % h)
            local scale_factor = (1 + (i % 3)) * scale
            local alpha = 0.05 + 0.04 * math.sin(t * 2.5 + i)
            
            love.graphics.setColor(1.0, 1.0, 1.0, alpha)
            love.graphics.rectangle("fill", sx - scale_factor, sy, scale_factor * 2 + 1, 1)
            love.graphics.rectangle("fill", sx, sy - scale_factor, 1, scale_factor * 2 + 1)
        end

        love.graphics.pop()

    elseif themeName == "candy" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Rising sweet bubbles
        for i = 1, 12 do
            local start_x = w * ((i * 0.69) % 1.0)
            local speed = 15 + (i % 4) * 5
            local y_cycle = h + 40 * scale
            local y = h + 20 * scale - ((t * speed + i * 53.7) % y_cycle)
            local x = start_x + math.sin(t * 0.6 + i) * 10 * scale
            local size = (3.0 + (i % 3) * 1.5) * scale
            local alpha = 0.07 * (1.0 - y / h)
            
            if i % 2 == 0 then
                love.graphics.setColor(1.0, 0.7, 0.8, alpha) -- pink
            else
                love.graphics.setColor(1.0, 0.9, 0.6, alpha) -- yellow
            end
            love.graphics.circle("fill", x, y, size)
        end

        love.graphics.pop()

    elseif themeName == "quantum" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Entangled particle pairs connected by flickering energy threads
        -- Particles orbit fixed positions, threads flicker to show quantum entanglement
        local golden = 0.6180339887
        local pair_count = 10
        for p = 1, pair_count do
            -- Two entangled particles placed symmetrically
            local base_x1 = ((p * golden) % 1.0) * w
            local base_y1 = ((p * golden * 1.41) % 1.0) * h
            local base_x2 = w - base_x1 + math.sin(p * 2.3) * w * 0.2
            local base_y2 = h - base_y1 + math.cos(p * 1.7) * h * 0.2

            -- Each particle slowly orbits its base position
            local orbit_r = (8 + (p % 4) * 5) * scale
            local speed = 0.4 + (p % 5) * 0.12
            local px1 = base_x1 + math.cos(t * speed + p * 1.1) * orbit_r
            local py1 = base_y1 + math.sin(t * speed + p * 1.1) * orbit_r
            local px2 = base_x2 + math.cos(t * speed + p * 1.1 + math.pi) * orbit_r  -- anti-phase
            local py2 = base_y2 + math.sin(t * speed + p * 1.1 + math.pi) * orbit_r

            -- Entanglement thread (flickers between visible/invisible)
            local thread_alpha = (math.sin(t * (1.5 + p * 0.2) + p * 0.7) * 0.5 + 0.5) * 0.08
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            -- Color shifts between cyan and violet per pair
            if p % 2 == 0 then
                love.graphics.setColor(0.0, 0.94, 1.0, thread_alpha)
            else
                love.graphics.setColor(0.65, 0.0, 1.0, thread_alpha)
            end
            love.graphics.line(px1, py1, px2, py2)

            -- Particle glow + core
            local pulse = math.sin(t * (1.2 + p * 0.15) + p * 2.1) * 0.5 + 0.5
            local size = (2.0 + (p % 3) * 1.2) * scale
            local p_alpha = 0.10 + pulse * 0.15
            local r_c = p % 2 == 0 and 0.0 or 0.65
            local b_c = p % 2 == 0 and 1.0 or 1.0
            -- Outer glow
            love.graphics.setColor(r_c, 0.0, b_c, p_alpha * 0.4)
            love.graphics.circle("fill", px1, py1, size * 3.0)
            love.graphics.circle("fill", px2, py2, size * 3.0)
            -- Core
            love.graphics.setColor(r_c * 0.5 + 0.5, 0.85, b_c, p_alpha)
            love.graphics.circle("fill", px1, py1, size)
            love.graphics.circle("fill", px2, py2, size)
        end

        -- Layer 2: Probability wave rings expanding from random positions
        for w_idx = 1, 5 do
            local wx = ((w_idx * golden * 2.1) % 1.0) * w
            local wy = ((w_idx * golden * 3.3) % 1.0) * h
            local wave_cycle = 4.0 + w_idx * 0.6
            local wave_phase = (t * 0.8 + w_idx * 1.3) % wave_cycle
            local wave_r = (wave_phase / wave_cycle) * 120 * scale
            local wave_alpha = (1.0 - wave_phase / wave_cycle) * 0.08
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            love.graphics.setColor(0.0, 0.94, 1.0, wave_alpha)
            love.graphics.circle("line", wx, wy, wave_r)
            -- Second wave ring slightly offset
            if wave_r > 20 * scale then
                love.graphics.setColor(0.65, 0.0, 1.0, wave_alpha * 0.6)
                love.graphics.circle("line", wx, wy, wave_r * 0.65)
            end
        end

        -- Layer 3: Superposition ghost particles (same particle at multiple positions)
        for g = 1, 8 do
            local gx_base = ((g * golden * 1.9) % 1.0) * w
            local gy_base = ((g * golden * 2.7) % 1.0) * h
            local superpose_alpha = 0.07 + 0.04 * math.sin(t * 0.9 + g)
            -- Draw 3 ghost copies at slightly offset positions
            for ghost = 1, 3 do
                local offset_x = math.sin(t * 0.5 + g * 1.3 + ghost * 2.1) * 14 * scale
                local offset_y = math.cos(t * 0.6 + g * 1.7 + ghost * 1.4) * 10 * scale
                local gsize = (1.5 + ghost * 0.5) * scale
                love.graphics.setColor(0.4, 0.9, 1.0, superpose_alpha * (1.0 - ghost * 0.2))
                love.graphics.circle("fill", gx_base + offset_x, gy_base + offset_y, gsize)
            end
        end

        love.graphics.pop()

    elseif themeName == "hyperdrive" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        local cx = w / 2
        local cy = h / 2

        -- Layer 1: Central vortex core glow (pulsing energy source)
        local core_pulse = 0.5 + 0.5 * math.sin(t * 2.5)
        for ring = 1, 6 do
            local rr = ring * 8 * scale * (1.0 + core_pulse * 0.3)
            local alpha = (0.12 - ring * 0.015) * (0.7 + core_pulse * 0.3)
            -- Cycle core color: blue→cyan→white→cyan
            local core_hue = (math.sin(t * 1.2 + ring) * 0.5 + 0.5)
            love.graphics.setColor(core_hue * 0.3, 0.6 + core_hue * 0.4, 1.0, alpha)
            love.graphics.circle("fill", cx, cy, rr)
        end

        -- Layer 2: Warp star streaks (80 stars, multi-colored, accelerating)
        local star_colors = {
            {1.0, 1.0, 1.0},   -- white
            {0.5, 0.8, 1.0},   -- ice blue
            {0.8, 0.5, 1.0},   -- purple
            {0.5, 1.0, 0.9},   -- cyan
            {1.0, 0.85, 0.4},  -- warm gold
        }
        love.graphics.setLineWidth(math.max(1, math.floor(scale)))
        for i = 1, 80 do
            local golden = 0.6180339887
            local angle = ((i * golden) % 1.0) * math.pi * 2
            local cycle = 2.2 + (i % 5) * 0.18  -- varied cycle speeds
            local t_offset = (t * (0.9 + (i % 7) * 0.08) + i * 0.31) % cycle
            local progress = t_offset / cycle

            -- Stars accelerate as they go outward (ease-in)
            local eased = progress * progress * progress
            local distance = eased * (w * 0.72)

            local sx = cx + math.cos(angle) * distance
            local sy = cy + math.sin(angle) * distance

            -- Trail length grows massively as star accelerates
            local trail_len = (1.5 + eased * 55) * scale
            local tx = sx - math.cos(angle) * trail_len
            local ty = sy - math.sin(angle) * trail_len

            -- Color + alpha
            local c = star_colors[(i % 5) + 1]
            local alpha = math.min(0.85, progress * 1.2)
            -- Bright white head, colored trail
            love.graphics.setColor(c[1], c[2], c[3], alpha * 0.6)
            love.graphics.line(tx, ty, sx, sy)
            -- Bright head dot
            if progress > 0.3 then
                love.graphics.setColor(1.0, 1.0, 1.0, alpha * 0.9)
                love.graphics.circle("fill", sx, sy, (0.5 + eased * 1.5) * scale)
            end
        end


        love.graphics.pop()


    elseif themeName == "retrogold" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Layer 1: Warm golden ambient glow pulses (bottom corners, like torchlight)
        local torch_positions = {{0.0, 1.0}, {1.0, 1.0}, {0.5, 1.05}}
        for ti, tp in ipairs(torch_positions) do
            local tx = w * tp[1]
            local ty = h * tp[2]
            local flicker = 0.7 + 0.3 * math.sin(t * (2.1 + ti * 0.7) + ti * 1.3)
            love.graphics.setColor(1.0, 0.65, 0.05, 0.06 * flicker)
            love.graphics.circle("fill", tx, ty, 220 * scale * flicker)
            love.graphics.setColor(1.0, 0.85, 0.25, 0.05 * flicker)
            love.graphics.circle("fill", tx, ty, 120 * scale)
        end

        -- Layer 2: Rising gold coin flakes (spinning squares, shimmer on contact with light)
        for i = 1, 36 do
            local golden_r = 0.6180339887
            local gx_base = ((i * golden_r) % 1.0) * w
            local rise_speed = 12 + (i % 8) * 7
            local sway = math.sin(t * (0.5 + (i % 4) * 0.15) + i * 1.9) * 18 * scale
            local y_cycle = h + 50 * scale
            local gy = h + 25 * scale - ((t * rise_speed + i * 59.3) % y_cycle)
            local gx = gx_base + sway

            local life = math.max(0, 1.0 - gy / h)
            local size = (2.5 + (i % 4) * 1.2) * scale

            -- Sparkle pulse per coin (each on its own frequency)
            local sparkle = math.sin(t * (3.5 + (i % 5) * 0.6) + i * 2.1) * 0.5 + 0.5
            local alpha = sparkle * life * 0.42

            -- Color: pale gold → rich amber depending on sparkle
            local r_c = 1.0
            local g_c = 0.72 + sparkle * 0.18
            local b_c = 0.05 + sparkle * 0.15

            love.graphics.push()
            love.graphics.translate(gx, gy)
            love.graphics.rotate(t * (1.2 + (i % 3) * 0.4) + i)

            -- Outer glow
            love.graphics.setColor(r_c, g_c * 0.7, 0.0, alpha * 0.35)
            love.graphics.rectangle("fill", -size * 1.6, -size * 1.6, size * 3.2, size * 3.2)
            -- Main coin face
            love.graphics.setColor(r_c, g_c, b_c, alpha)
            love.graphics.rectangle("fill", -size, -size, size * 2, size * 2)
            -- Bright face highlight
            love.graphics.setColor(1.0, 1.0, 0.85, alpha * sparkle * 0.6)
            love.graphics.rectangle("fill", -size * 0.5, -size * 0.5, size, size)

            love.graphics.pop()
        end

        -- Layer 3: Gold lens flares (star-shaped cross glints at fixed positions)
        local flare_spots = {{0.15, 0.22}, {0.72, 0.18}, {0.88, 0.60}, {0.35, 0.75}, {0.58, 0.35}}
        for fi, fs in ipairs(flare_spots) do
            local fx = w * fs[1]
            local fy = h * fs[2]
            local flare_pulse = math.sin(t * (0.8 + fi * 0.25) + fi * 1.7) * 0.5 + 0.5
            local flare_alpha = flare_pulse * 0.18
            local flare_r = (18 + fi * 8) * scale * flare_pulse
            love.graphics.setLineWidth(math.max(1, math.floor(scale)))
            love.graphics.setColor(1.0, 0.90, 0.30, flare_alpha)
            -- Cross spokes
            love.graphics.line(fx - flare_r, fy, fx + flare_r, fy)
            love.graphics.line(fx, fy - flare_r, fx, fy + flare_r)
            -- Diagonal spokes (shorter)
            local d = flare_r * 0.6
            love.graphics.setColor(1.0, 0.85, 0.20, flare_alpha * 0.5)
            love.graphics.line(fx - d, fy - d, fx + d, fy + d)
            love.graphics.line(fx - d, fy + d, fx + d, fy - d)
            -- Bright center dot
            love.graphics.setColor(1.0, 1.0, 0.75, flare_pulse * 0.35)
            love.graphics.circle("fill", fx, fy, 2.5 * scale * flare_pulse)
        end

        love.graphics.pop()

    elseif themeName == "spectrum" then
        local t = love.timer.getTime()
        love.graphics.push("all")

        -- Spectrum: prismatic light rays, like sunlight split through a prism
        -- 7 ROYGBIV color beams fan out diagonally across the screen, slowly breathing

        local ray_colors = {
            {1.00, 0.15, 0.15},  -- red
            {1.00, 0.52, 0.05},  -- orange
            {1.00, 0.90, 0.05},  -- yellow
            {0.10, 0.85, 0.25},  -- green
            {0.05, 0.70, 1.00},  -- blue
            {0.35, 0.10, 0.95},  -- indigo
            {0.75, 0.05, 0.95},  -- violet
        }

        local num_rays = #ray_colors
        -- Origin point: top-left corner area (like prism emitting light)
        local origin_x = w * (-0.05)
        local origin_y = h * (-0.05)

        -- Fan spread: rays go from ~30° to ~80° (mostly rightward-downward)
        local angle_start = math.pi * 0.08   -- ~14 degrees
        local angle_end   = math.pi * 0.48   -- ~86 degrees

        for i = 1, num_rays do
            local frac = (i - 1) / (num_rays - 1)
            local base_angle = angle_start + frac * (angle_end - angle_start)

            -- Each ray slowly sways ±1.5 degrees
            local sway = math.sin(t * 0.25 + i * 1.1) * 0.026
            local angle = base_angle + sway

            -- Brightness pulses independently per ray
            local pulse = 0.55 + 0.45 * math.sin(t * (0.35 + i * 0.07) + i * 0.9)

            local c = ray_colors[i]

            -- Draw each ray as a wide soft trapezoid using overlapping circles along the beam
            -- Ray endpoint is always at screen edge or beyond
            local ray_len = math.sqrt(w * w + h * h) * 1.1
            local dx = math.cos(angle)
            local dy = math.sin(angle)

            -- Width of beam grows along its length (perspective)
            local seg_count = 18
            for s = 1, seg_count do
                local seg_frac = s / seg_count
                local sx = origin_x + dx * ray_len * seg_frac
                local sy = origin_y + dy * ray_len * seg_frac

                -- Beam starts narrow at origin, fans out toward edge
                local beam_w = (8 + seg_frac * seg_frac * 90) * scale

                -- Alpha: strong near origin, fades toward tip; also dimmer on edges of fan
                local edge_fade = 1.0 - math.abs(frac - 0.5) * 0.6
                local dist_fade = 1.0 - seg_frac * 0.55
                local alpha = pulse * 0.10 * edge_fade * dist_fade

                love.graphics.setColor(c[1], c[2], c[3], alpha)
                love.graphics.circle("fill", sx, sy, beam_w)
            end
        end

        -- Subtle sparkle dust along the rays
        for k = 1, 20 do
            local frac = (k * 0.618) % 1.0
            local base_angle = angle_start + frac * (angle_end - angle_start)
            local ray_len = math.sqrt(w * w + h * h) * 0.85
            local seg_f = ((k * 0.37 + t * 0.06) % 1.0)
            local sx = origin_x + math.cos(base_angle) * ray_len * seg_f
            local sy = origin_y + math.sin(base_angle) * ray_len * seg_f
            local twinkle = math.sin(t * 2.5 + k * 3.1) * 0.5 + 0.5
            local ci = ((k - 1) % num_rays) + 1
            local c = ray_colors[ci]
            love.graphics.setColor(c[1], c[2], c[3], twinkle * 0.30)
            love.graphics.circle("fill", sx, sy, (1.0 + twinkle * 1.5) * scale)
        end

        love.graphics.pop()
    end
end


function renderer.clearBackground()
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    renderer.drawDynamicBackground(_G.theme)
end

function renderer.getThemeBgColor()
    return bg_color
end

function renderer.getThemeTileColors()
    local t = themes[_G.theme] or themes.light
    return t.tile_colors, t.super_tile_color
end

function renderer.getThemeHighlightColors()
    local t = themes[_G.theme] or themes.light
    return t.super_tile_color or {hex("#edc22e")}, t.board_color or {hex("#bbada0")}
end

-- Fonts (moved to top of file)

-- ============================================================================
-- Layout
-- ============================================================================
local layout = {
    board_x = 0, board_y = 0,
    board_size = 0,
    cell_size = 0,
    cell_gap = 0,
    corner_radius = 0,
    -- Help section
    help_y = 0,
    help_h = 0,
}

-- ============================================================================
-- Layout Update
-- ============================================================================
function renderer.updateLayout(size)
    size = size or 4
    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    local header_h = math.floor(65 * scale)   -- title + score boxes
    local help_h   = math.floor(55 * scale)   -- controls help section
    local padding  = math.floor(10 * scale)

    -- Available height for the board
    local avail_h = h - header_h - help_h - padding * 2
    local avail_w = w - padding * 2

    -- Board is a square — fit to the smaller dimension
    local board_size = math.min(avail_w, avail_h)
    local cell_gap = math.floor(board_size * 0.022)
    local cell_size = math.floor((board_size - cell_gap * (size + 1)) / size)
    board_size = cell_size * size + cell_gap * (size + 1)

    layout.board_size = board_size
    layout.cell_size = cell_size
    layout.cell_gap = cell_gap
    layout.board_x = math.floor((w - board_size) / 2)
    layout.board_y = header_h + padding
    layout.corner_radius = math.floor(cell_size * 0.06)
    layout.help_y = layout.board_y + board_size + padding
    layout.help_h = help_h

    -- Re-load fonts relative to the new cell size — using cache to avoid recreation lag
    local text_scale = 1.0
    local tile_scale = 1.0
    if _G.text_size == "large" then
        text_scale = 1.15
        tile_scale = 1.05
    end

    local cache_key = tostring(size) .. "_" .. _G.text_size .. "_" .. tostring(cell_size)
    if not font_cache[cache_key] then
        local tile_font_size = math.floor(cell_size * 0.45 * tile_scale)
        local tile_small_size = math.floor(cell_size * 0.35 * tile_scale)
        local tile_tiny_size = math.floor(cell_size * 0.28 * tile_scale)
        font_cache[cache_key] = {
            large = love.graphics.newFont(font_path, tile_font_size),
            small = love.graphics.newFont(font_path, tile_small_size),
            tiny  = love.graphics.newFont(font_path, tile_tiny_size),
        }
    end

    font_tile_large = font_cache[cache_key].large
    font_tile_small = font_cache[cache_key].small
    font_tile_tiny  = font_cache[cache_key].tiny
end

-- ============================================================================
-- Initialization
-- ============================================================================
function renderer.init()
    local scale = _G.scale

    renderer.updateLayout(4)

    -- Load fonts — sizes relative to cell size for proper scaling
    local text_scale = 1.0
    if _G.text_size == "large" then
        text_scale = 1.15
    end

    font_score      = love.graphics.newFont(font_path, math.floor(20 * scale * text_scale))
    font_title      = love.graphics.newFont(font_path, math.floor(36 * scale * text_scale))

    local header_text_scale = (_G.text_size == "large") and 1.0 or 1.0
    font_header_2048 = love.graphics.newFont(font_path, math.floor(36 * scale * header_text_scale))
    font_main_menu_title = love.graphics.newFont(font_path, math.floor(72 * scale))
    font_main_menu_plus = love.graphics.newFont(font_path, math.floor(30 * scale))
    font_header_plus = love.graphics.newFont(font_path, math.floor(13 * scale))
    font_cheats_title = love.graphics.newFont(font_path, math.floor(56 * scale))
    font_label      = love.graphics.newFont(font_path, math.floor(16 * scale * text_scale))
    font_message    = love.graphics.newFont(font_path, math.floor(28 * scale * text_scale))
    font_help_key   = love.graphics.newFont(font_path, math.floor(16 * scale * text_scale))
    font_help_label = love.graphics.newFont(font_path, math.floor(16 * scale * text_scale))
    font_bgm        = love.graphics.newFont(font_path, math.floor(13 * scale))
    logo_2048 = love.graphics.newImage("assets/logo_2048.png")

    -- Set arcade panel to start fully closed
    local card_h = math.floor((_G.text_size == "large" and 124 or 120) * scale)
    local card_gap = math.floor(12 * scale)
    local panel_pad_y = math.floor(16 * scale)
    local header_h = math.floor(74 * scale)
    local footer_h = math.floor(44 * scale)
    local num_rows = 2
    local panel_h = header_h + panel_pad_y + num_rows * card_h + (num_rows - 1) * card_gap + panel_pad_y + footer_h
    arcade_panel_y_offset = panel_h
    arcade_panel_target = panel_h
end

-- ============================================================================
-- Helper: draw a rounded rectangle
-- ============================================================================
local function roundedRect(mode, x, y, w, h, r)
    if _G.theme == "matrix" then
        r = r or 0
        local lw = love.graphics.getLineWidth()
        if mode == "fill" then
            local cr, cg, cb, ca = love.graphics.getColor()
            love.graphics.setColor(0, 0, 0, ca * 0.8)
            love.graphics.rectangle("fill", x, y, w, h, r, r)
            love.graphics.setColor(cr, cg, cb, ca)
            love.graphics.setLineWidth(lw)
            love.graphics.rectangle("line", x, y, w, h, r, r)
        else
            love.graphics.setLineWidth(lw)
            love.graphics.rectangle("line", x, y, w, h, r, r)
        end
        return
    end

    r = r or 0
    if r <= 0 then
        love.graphics.rectangle(mode, x, y, w, h)
    else
        love.graphics.rectangle(mode, x, y, w, h, r, r)
    end
end

local function drawSelectionPill(x, y, w, h, cr)
    local scale = _G.scale or 1
    local pad = math.ceil(4 * scale)
    local canvas_w = math.ceil((w + pad * 2) * 2)
    local canvas_h = math.ceil((h + pad * 2) * 2)
    if not selection_canvas or selection_canvas:getWidth() < canvas_w or selection_canvas:getHeight() < canvas_h then
        local new_w = selection_canvas and math.max(selection_canvas:getWidth(), canvas_w) or canvas_w
        local new_h = selection_canvas and math.max(selection_canvas:getHeight(), canvas_h) or canvas_h
        selection_canvas = love.graphics.newCanvas(new_w, new_h)
        selection_canvas:setFilter("linear", "linear")
    end
    if not selection_quad then
        selection_quad = love.graphics.newQuad(0, 0, canvas_w, canvas_h, selection_canvas:getDimensions())
    else
        selection_quad:setViewport(0, 0, canvas_w, canvas_h, selection_canvas:getDimensions())
    end

    local r, g, b, a = love.graphics.getColor()
    local old_canvas = love.graphics.getCanvas()
    local sx, sy, sw, sh = love.graphics.getScissor()
    love.graphics.setScissor()

    love.graphics.setCanvas(selection_canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.push("all")
    love.graphics.scale(2, 2)
    love.graphics.translate(-x + pad, -y + pad)

    love.graphics.setColor(r, g, b, a)
    roundedRect("fill", x, y, w, h, cr)

    love.graphics.pop()
    if old_canvas then
        love.graphics.setCanvas({old_canvas, stencil = true})
    else
        love.graphics.setCanvas()
    end
    if sx then
        love.graphics.setScissor(sx, sy, sw, sh)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(selection_canvas, selection_quad, x - pad, y - pad, 0, 0.5, 0.5)
    love.graphics.setBlendMode("alpha", "alphamultiply")
end

-- ============================================================================
-- Get tile color / text color
-- ============================================================================
local function getTileColor(value)
    return tile_colors[value] or super_tile_color
end

local function getTileTextColor(value)
    -- For matrix theme, tile backgrounds are always black, so text must be high-contrast light green/white
    if _G.theme == "matrix" then
        return light_text
    end

    -- Preserve classic 2048 text colors for default themes
    if _G.theme == "light" or _G.theme == "dark" or _G.theme == "ocean" or _G.theme == "forest" then
        if value <= 4 then return dark_text end
        if value >= 4096 and _G.theme == "dark" then return dark_text end
        return light_text
    end

    -- Dynamic contrast for all other custom/premium themes
    local color = getTileColor(value)
    local luminance = 0.299 * color[1] + 0.587 * color[2] + 0.114 * color[3]
    if luminance > 0.5 then
        return dark_text
    else
        return light_text
    end
end

-- ============================================================================
-- Draw the board background (grid of empty cells)
-- ============================================================================
function renderer.drawBoard(game)
    local bx, by = layout.board_x, layout.board_y
    local bs = layout.board_size
    local cs = layout.cell_size
    local cg = layout.cell_gap
    local cr = layout.corner_radius
    local size = game and game.size or 4

    love.graphics.setColor(board_color)
    roundedRect("fill", bx, by, bs, bs, cr * 2)

    if _G.theme == "matrix" then
        love.graphics.setColor(board_color)
    else
        love.graphics.setColor(tile_colors[0])
    end
    for col = 1, size do
        for row = 1, size do
            local cx = bx + cg + (col - 1) * (cs + cg)
            local cy = by + cg + (row - 1) * (cs + cg)
            roundedRect("fill", cx, cy, cs, cs, cr)
        end
    end
end

local function drawGooseTile(cx, cy, size, scale, shouldWaddle)
    local time = love.timer.getTime()
    local waddleAngle = 0
    local waddleY = 0
    if shouldWaddle then
        waddleAngle = math.sin(time * 12) * 0.12
        waddleY = math.abs(math.cos(time * 12)) * 2 * scale
    end

    -- Body offset for waddling
    local bx = cx
    local by = cy + waddleY

    love.graphics.push("all")
    love.graphics.translate(bx, by)
    love.graphics.rotate(waddleAngle)

    -- Feet
    love.graphics.setColor(0.95, 0.5, 0.1, 1)
    love.graphics.setLineWidth(math.max(1, 3 * scale))
    local l_foot_osc = shouldWaddle and (math.sin(time * 12) * 4 * scale) or 0
    love.graphics.line(-10 * scale, 15 * scale, -12 * scale + l_foot_osc, 28 * scale)
    love.graphics.line(-12 * scale + l_foot_osc, 28 * scale, -17 * scale + l_foot_osc, 28 * scale)

    local r_foot_osc = shouldWaddle and (-math.sin(time * 12) * 4 * scale) or 0
    love.graphics.line(8 * scale, 15 * scale, 6 * scale + r_foot_osc, 28 * scale)
    love.graphics.line(6 * scale + r_foot_osc, 28 * scale, 1 * scale + r_foot_osc, 28 * scale)

    -- Body (white)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.ellipse("fill", -5 * scale, 5 * scale, 22 * scale, 15 * scale)

    -- Neck (white)
    love.graphics.setLineWidth(math.max(1, 10 * scale))
    love.graphics.line(8 * scale, 5 * scale, 14 * scale, -12 * scale)

    -- Head (white)
    love.graphics.ellipse("fill", 15 * scale, -15 * scale, 10 * scale, 10 * scale)

    -- Wing (light gray/off-white)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.ellipse("fill", -8 * scale, 5 * scale, 12 * scale, 8 * scale)

    -- Beak (orange triangle)
    love.graphics.setColor(0.95, 0.5, 0.1, 1)
    love.graphics.polygon("fill",
        23 * scale, -18 * scale,
        23 * scale, -12 * scale,
        33 * scale, -15 * scale
    )

    -- Eye (black dot)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.circle("fill", 17 * scale, -17 * scale, 1.8 * scale)

    love.graphics.pop()
end

local function drawGooseCardIcon(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    love.graphics.push("all")

    local target_r = r_acc or 0.15
    local target_g = g_acc or 0.55
    local target_b = b_acc or 0.75
    local color_r = 0.45 + (target_r - 0.45) * select_factor
    local color_g = 0.5  + (target_g - 0.5)  * select_factor
    local color_b = 0.58 + (target_b - 0.58) * select_factor
    local alpha = 0.7 + 0.3 * select_factor

    love.graphics.setColor(color_r, color_g, color_b, alpha)
    love.graphics.setLineWidth(math.floor(2 * scale))

    -- Ambient float animation for selection
    local float_y = 0
    if is_selected then
        float_y = math.sin(love.timer.getTime() * 4) * 2 * scale * select_factor
    end
    cy = cy + float_y

    -- Waddling/wiggle rotation when selected
    local time = love.timer.getTime()
    local waddleAngle = is_selected and (math.sin(time * 12) * 0.12 * select_factor) or 0
    local waddleY = is_selected and (math.abs(math.cos(time * 12)) * 1.5 * scale * select_factor) or 0

    love.graphics.translate(cx, cy + waddleY)
    love.graphics.rotate(waddleAngle)

    -- Feet
    love.graphics.line(-5.25 * scale, 7.5 * scale, -6.75 * scale, 15 * scale)
    love.graphics.line(-6.75 * scale, 15 * scale, -9.75 * scale, 15 * scale)
    love.graphics.line(3.75 * scale, 7.5 * scale, 2.25 * scale, 15 * scale)
    love.graphics.line(2.25 * scale, 15 * scale, -0.75 * scale, 15 * scale)

    -- Body outline
    love.graphics.ellipse("line", -3 * scale, 2.25 * scale, 12 * scale, 8.25 * scale)

    -- Neck lines
    love.graphics.line(2.25 * scale, 0.75 * scale, 6 * scale, -9 * scale)
    love.graphics.line(7.5 * scale, 4.5 * scale, 10.5 * scale, -6.75 * scale)

    -- Head outline
    love.graphics.ellipse("line", 8.25 * scale, -10.5 * scale, 5.25 * scale, 5.25 * scale)

    -- Beak outline
    love.graphics.polygon("line",
        12.75 * scale, -12 * scale,
        12.75 * scale, -9 * scale,
        18 * scale, -10.5 * scale
    )

    -- Wing outline
    love.graphics.ellipse("line", -4.5 * scale, 2.25 * scale, 6.75 * scale, 4.5 * scale)

    -- Eye (small filled dot)
    love.graphics.circle("fill", 9.375 * scale, -11.625 * scale, 0.9 * scale)

    love.graphics.pop()
end

-- ============================================================================
-- Draw a single tile
-- ============================================================================
function renderer.drawTile(tile, slideProgress, popProgress)
    popProgress = popProgress or slideProgress
    local bx, by = layout.board_x, layout.board_y
    local cs = layout.cell_size
    local cg = layout.cell_gap
    local cr = layout.corner_radius

    local tx = bx + cg + (tile.x - 1) * (cs + cg)
    local ty = by + cg + (tile.y - 1) * (cs + cg)

    -- Slide animation
    if tile.undoSourcePosition and slideProgress < 1 then
        local px = bx + cg + (tile.undoSourcePosition.x - 1) * (cs + cg)
        local py = by + cg + (tile.undoSourcePosition.y - 1) * (cs + cg)
        tx = px + (tx - px) * slideProgress
        ty = py + (ty - py) * slideProgress
    elseif tile.previousPosition and slideProgress < 1 then
        local px = bx + cg + (tile.previousPosition.x - 1) * (cs + cg)
        local py = by + cg + (tile.previousPosition.y - 1) * (cs + cg)
        tx = px + (tx - px) * slideProgress
        ty = py + (ty - py) * slideProgress
    end

    -- Scale for spawn / merge / bomb animation
    local tileScale = 1
    if tile.isBombing then
        tileScale = 1 - popProgress
    elseif tile.isNew and popProgress < 1 then
        tileScale = popProgress
    elseif tile.isMerged and popProgress < 1 then
        if popProgress < 0.5 then
            tileScale = 1 + 0.25 * (popProgress / 0.5)
        else
            tileScale = 1.25 - 0.25 * ((popProgress - 0.5) / 0.5)
        end
    end

    local cx = tx + cs / 2
    local cy = ty + cs / 2
    local scaledSize = cs * tileScale
    local sx = cx - scaledSize / 2
    local sy = cy - scaledSize / 2

    -- Tile background
    if tile.value == "goose" then
        love.graphics.setColor(0.15, 0.55, 0.75, 1)
        roundedRect("fill", sx, sy, scaledSize, scaledSize, cr * tileScale)
        drawGooseTile(cx, cy, cs, scale * tileScale, true)
        return
    end

    local color = getTileColor(tile.value)
    love.graphics.setColor(color)
    roundedRect("fill", sx, sy, scaledSize, scaledSize, cr * tileScale)

    -- Tile text
    local textColor = getTileTextColor(tile.value)
    love.graphics.setColor(textColor)

    local font
    if tile.value >= 10000 then
        font = font_tile_tiny
    elseif tile.value >= 1000 then
        font = font_tile_small
    else
        font = font_tile_large
    end
    love.graphics.setFont(font)

    local text = tostring(tile.value)
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, cx - tw / 2, cy - th / 2)
end

-- ============================================================================
-- Draw all tiles (layered: normal → merged → new)
-- ============================================================================
function renderer.drawTiles(game)
    local t = game.animationTimer
    local d = game.animationDuration
    local slideProgress, gooseProgress, spawnProgress, mergePopProgress

    if game.mode == "goose" then
        if t > d then
            slideProgress = (2 * d - t) / d
            gooseProgress = 0
            spawnProgress = 0
            mergePopProgress = 0
        else
            slideProgress = 1
            gooseProgress = 1 - (t / d)
            spawnProgress = 1 - (t / d)
            mergePopProgress = 1 - (t / d)
        end
    else
        local p = game:getAnimationProgress()
        slideProgress = p
        gooseProgress = p
        spawnProgress = p
        mergePopProgress = p
    end

    game.grid:eachCell(function(x, y, tile)
        if tile and not tile.isMerged and not tile.isNew and not tile.isSwapping then
            if tile.value == "goose" then
                renderer.drawTile(tile, gooseProgress, gooseProgress)
            else
                renderer.drawTile(tile, slideProgress, slideProgress)
            end
        end
    end)

    game.grid:eachCell(function(x, y, tile)
        if tile and tile.isMerged and not tile.isSwapping then
            renderer.drawTile(tile, slideProgress, mergePopProgress)
        end
    end)

    game.grid:eachCell(function(x, y, tile)
        if tile and tile.isNew and not tile.isSwapping then
            renderer.drawTile(tile, spawnProgress, spawnProgress)
        end
    end)

    if game.bombAnimation then
        local p = 1 - (game.bombAnimation.timer / game.bombAnimation.duration)
        local t = {
            x = game.bombAnimation.x,
            y = game.bombAnimation.y,
            value = game.bombAnimation.tileValue,
            isBombing = true
        }
        renderer.drawTile(t, p)
    end

    if game.swapAnimation then
        local p = 1 - (game.swapAnimation.timer / game.swapAnimation.duration)

        local drawSwapTile = function(s)
            if not s then return end
            local t = {
                x = s.endX,
                y = s.endY,
                value = s.val,
                previousPosition = {x = s.startX, y = s.startY}
            }
            renderer.drawTile(t, p)
        end

        drawSwapTile(game.swapAnimation.t1)
        drawSwapTile(game.swapAnimation.t2)
    end

    if game.floatingNotifications then
        local bx, by = layout.board_x, layout.board_y
        local cs = layout.cell_size
        local cg = layout.cell_gap
        for _, n in ipairs(game.floatingNotifications) do
            local cx = bx + cg + (n.col - 1) * (cs + cg) + cs / 2
            local cy = by + cg + (n.row - 1) * (cs + cg) + cs / 2

            -- Float upward based on elapsed life
            local elapsed = n.max_life - n.timer
            local float_y = cy - (elapsed * 55 * _G.scale)

            -- Fade out
            local alpha = math.min(1, n.timer / 0.3)

            love.graphics.setFont(font_help_key)

            -- Text shadow for legibility
            love.graphics.setColor(0, 0, 0, alpha * 0.75)
            love.graphics.printf(n.text, cx - 100 * _G.scale, float_y + 1, 200 * _G.scale, "center")

            -- Text fill (bold emerald green / neon green)
            if _G.theme == "matrix" then
                love.graphics.setColor(0, 1, 0, alpha)
            else
                love.graphics.setColor(0.18, 0.72, 0.35, alpha)
            end
            love.graphics.printf(n.text, cx - 100 * _G.scale, float_y, 200 * _G.scale, "center")
        end
    end
end

-- ============================================================================
-- Draw score boxes
-- ============================================================================
function renderer.drawScores(game)
    local bx = layout.board_x
    local bs = layout.board_size
    local scale = _G.scale

    local box_w = math.floor((_G.text_size == "large" and 115 or 105) * scale)
    local box_h = math.floor((_G.text_size == "large" and 56 or 48) * scale)
    local box_gap = math.floor(8 * scale)
    local cr = math.floor(6 * scale)

    local best_x = bx + bs - box_w
    local score_x = best_x - box_w - box_gap

    -- Center vertically in the header area (above the board)
    local box_y = math.floor((layout.board_y - box_h) / 2)

    -- Dynamic vertical centering of text inside score boxes
    local label_h = font_label:getHeight()
    local score_h = font_score:getHeight()
    local spacing = math.floor(1 * scale)
    local total_text_h = label_h + score_h + spacing
    local top_padding = math.floor((box_h - total_text_h) / 2)

    -- Subtract 1px visually to account for optical baseline offset of all-caps text
    local label_y = box_y + top_padding - math.floor(1 * scale)
    local score_y = box_y + top_padding + label_h + spacing

    -- SCORE box
    love.graphics.setColor(score_bg_color)
    roundedRect("fill", score_x, box_y, box_w, box_h, cr)

    love.graphics.setFont(font_label)
    love.graphics.setColor(score_label)
    love.graphics.printf("SCORE", score_x, label_y, box_w, "center")

    love.graphics.setFont(font_score)
    love.graphics.setColor(score_value)
    love.graphics.printf(tostring(game.score), score_x, score_y, box_w, "center")

    if game.mode == "timeattack" and game.timeLeft ~= nil then
        -- TIMER box (replaces BEST in Time Attack)
        local t = math.max(0, game.timeLeft)
        local mins = math.floor(t / 60)
        local secs = math.floor(t % 60)
        local timer_str = string.format("%d:%02d", mins, secs)

        -- Determine if score box background is a light color to adjust text contrast
        local is_light_bg = false
        if score_bg_color then
            local r = score_bg_color[1] or 1
            local g = score_bg_color[2] or 1
            local b = score_bg_color[3] or 1
            local brightness = 0.299 * r + 0.587 * g + 0.114 * b
            if brightness > 0.65 then
                is_light_bg = true
            end
        end

        -- Box background (subtly different tint when urgent or flashing)
        if game.timerFlashTimer and game.timerFlashTimer > 0 then
            local f = game.timerFlashTimer / 0.3
            local r_col = score_bg_color[1] * (1 - f) + 0.0 * f
            local g_col = score_bg_color[2] * (1 - f) + 0.8 * f
            local b_col = score_bg_color[3] * (1 - f) + 0.7 * f
            love.graphics.setColor(r_col, g_col, b_col, 0.95)
        else
            love.graphics.setColor(score_bg_color)
        end
        roundedRect("fill", best_x, box_y, box_w, box_h, cr)

        -- "TIME" label
        love.graphics.setFont(font_label)
        if t <= 10 then
            -- Pulsing red label
            local pulse = (math.sin(love.timer.getTime() * 8) * 0.5 + 0.5)
            if is_light_bg then
                love.graphics.setColor(0.75, 0.05 + pulse * 0.1, 0.05, 1.0)
            else
                love.graphics.setColor(1.0, 0.25 + pulse * 0.25, 0.2, 1.0)
            end
        elseif t <= 30 then
            if is_light_bg then
                love.graphics.setColor(0.8, 0.35, 0.0, 1.0)  -- dark orange/rust for light themes
            else
                love.graphics.setColor(1.0, 0.65, 0.1, 1.0)  -- warm orange for dark themes
            end
        else
            love.graphics.setColor(score_label)
        end
        love.graphics.printf("TIME", best_x, label_y, box_w, "center")

        -- Timer value
        love.graphics.setFont(font_score)
        if t <= 10 then
            local pulse = (math.sin(love.timer.getTime() * 8) * 0.5 + 0.5)
            if is_light_bg then
                love.graphics.setColor(0.75, 0.05 + pulse * 0.1, 0.05, 1.0)
            else
                love.graphics.setColor(1.0, 0.2 + pulse * 0.3, 0.2, 1.0)
            end
        elseif t <= 30 then
            if is_light_bg then
                love.graphics.setColor(0.8, 0.35, 0.0, 1.0)
            else
                love.graphics.setColor(1.0, 0.65, 0.1, 1.0)
            end
        else
            love.graphics.setColor(score_value)
        end
        love.graphics.printf(timer_str, best_x, score_y, box_w, "center")

        -- Draw floating time attack popups
        if game.timePopups then
            love.graphics.setFont(font_help_label)
            for _, p in ipairs(game.timePopups) do
                local p_str = p.text
                local p_w = font_help_label:getWidth(p_str)
                local px = best_x + (box_w - p_w) / 2
                local py = box_y + math.floor(box_h * 0.4) + p.y_offset

                -- Main text
                love.graphics.setColor(0.18, 0.85, 0.45, p.alpha)
                love.graphics.print(p_str, px, py)
            end
        end
    else
        -- Normal BEST box
        love.graphics.setColor(score_bg_color)
        roundedRect("fill", best_x, box_y, box_w, box_h, cr)

        love.graphics.setFont(font_label)
        love.graphics.setColor(score_label)
        love.graphics.printf("BEST", best_x, label_y, box_w, "center")

        love.graphics.setFont(font_score)
        love.graphics.setColor(score_value)
        love.graphics.printf(tostring(game.highScore), best_x, score_y, box_w, "center")
    end
end

-- ============================================================================
-- Draw header ("2048" title)
-- ============================================================================
function renderer.drawHeader(game)
    local bx = layout.board_x
    local scale = _G.scale

    love.graphics.setFont(font_header_2048)
    love.graphics.setColor(ui_text)

    local tw = font_header_2048:getWidth("2048")
    local th = font_header_2048:getHeight()
    
    local f_plus = font_header_plus or font_tile_small
    local pw = f_plus:getWidth("PLUS")
    local ph = f_plus:getHeight()

    -- Stacked title height: "2048" height + "PLUS" height - scaled vertical nesting offset
    local title_h = th + ph - math.floor(11 * scale)

    local function drawSubTitle(x_base, y_plus)
        local is_morphing = _G.theme_morph_timer and _G.theme_morph_timer > 0
        if is_morphing then
            local morph_name = _G.theme_morph_name or "PLUS"
            local prev_name = _G.theme_morph_prev_name or "PLUS"

            love.graphics.setFont(f_plus)
            
            -- Width & scale for target morph_name
            local mw = f_plus:getWidth(morph_name)
            local max_w = math.floor(130 * scale)
            local scale_x = 1.0
            if mw > max_w then scale_x = max_w / mw end

            -- Width & scale for prev_name
            local pw = f_plus:getWidth(prev_name)
            local scale_prev_x = 1.0
            if pw > max_w then scale_prev_x = max_w / pw end

            local t_rem = _G.theme_morph_timer
            local total_t = 4.0
            local fade_t = 0.4

            local r = ui_text[1] or 1
            local g = ui_text[2] or 1
            local b = ui_text[3] or 1
            local a = ui_text[4] or 1

            if t_rem > (total_t - fade_t) then
                -- Phase 1: Smooth fade IN from prev_name to morph_name with cubic easing & slide
                local raw_p = (total_t - t_rem) / fade_t -- 0 -> 1
                local p = raw_p * raw_p * (3 - 2 * raw_p) -- smooth cubic ease

                -- Prev name fading out & sliding up
                love.graphics.setColor(r, g, b, a * (1 - p))
                love.graphics.print(prev_name, x_base - pw * scale_prev_x - math.floor(2 * scale), y_plus - (p * 4 * scale), 0, scale_prev_x, scale_prev_x)

                -- Target morph_name fading in & sliding up into place
                love.graphics.setColor(r, g, b, a * p)
                love.graphics.print(morph_name, x_base - mw * scale_x - math.floor(2 * scale), y_plus + ((1 - p) * 4 * scale), 0, scale_x, scale_x)

            elseif t_rem < fade_t then
                -- Phase 3: Smooth fade OUT from morph_name back to PLUS
                local raw_p = t_rem / fade_t -- 1 -> 0
                local p = raw_p * raw_p * (3 - 2 * raw_p) -- smooth cubic ease

                local pw_plus = f_plus:getWidth("PLUS")

                -- PLUS fading in & sliding up into place
                love.graphics.setColor(r, g, b, a * (1 - p))
                love.graphics.print("PLUS", x_base - pw_plus - math.floor(2 * scale), y_plus + (p * 4 * scale))

                -- Target morph_name fading out & sliding up
                love.graphics.setColor(r, g, b, a * p)
                love.graphics.print(morph_name, x_base - mw * scale_x - math.floor(2 * scale), y_plus - ((1 - p) * 4 * scale), 0, scale_x, scale_x)

            else
                -- Phase 2: Steady hold of morph_name
                love.graphics.setColor(r, g, b, a)
                love.graphics.print(morph_name, x_base - mw * scale_x - math.floor(2 * scale), y_plus, 0, scale_x, scale_x)
            end
        else
            love.graphics.setFont(f_plus)
            love.graphics.setColor(ui_text)
            local pw_norm = f_plus:getWidth("PLUS")
            love.graphics.print("PLUS", x_base - pw_norm - math.floor(2 * scale), y_plus)
        end
    end

    if game and game.won then
        local eh = font_header_plus:getHeight()
        local total_h = title_h + eh - math.floor(2 * scale)
        
        local title_y = math.floor((layout.board_y - total_h) / 2)
        local y_2048 = title_y
        local y_plus = y_2048 + th - math.floor(11 * scale)

        -- Draw "2048"
        love.graphics.setFont(font_header_2048)
        love.graphics.setColor(ui_text)
        love.graphics.print("2048", bx, y_2048)

        -- Draw "PLUS" (or morph theme name)
        drawSubTitle(bx + tw, y_plus)

        -- Draw "Endless Mode" subtitle below "PLUS" with smaller font, shifted right and vertically closer
        local text = "Endless Mode"
        love.graphics.setFont(font_header_plus)
        love.graphics.setColor(ui_text)
        
        local box_w = math.floor((_G.text_size == "large" and 115 or 105) * scale)
        local box_gap = math.floor(8 * scale)
        local best_x = bx + layout.board_size - box_w
        local score_x = best_x - box_w - box_gap
        local avail_w = math.max(1, score_x - bx - math.floor(6 * scale))
        
        local text_s = 1.0
        local etw = font_header_plus:getWidth(text)
        if etw > avail_w then
            text_s = avail_w / etw
        end
        
        local x_endless = bx + tw - etw * text_s - math.floor(2 * scale)
        local y_endless = y_plus + ph - math.floor(2 * scale)
        love.graphics.print(text, x_endless, y_endless, 0, text_s, text_s)
    else
        -- Normal gameplay: center the stacked title block vertically in the header area
        local title_y = math.floor((layout.board_y - title_h) / 2)
        local y_2048 = title_y
        local y_plus = y_2048 + th - math.floor(11 * scale)

        -- Draw "2048"
        love.graphics.setFont(font_header_2048)
        love.graphics.setColor(ui_text)
        love.graphics.print("2048", bx, y_2048)

        -- Draw "PLUS" (or morph theme name)
        drawSubTitle(bx + tw, y_plus)
    end
end

-- ============================================================================
-- Get proper text for button prompts based on OS
-- ============================================================================
function renderer.getButtonPrompt(key)
    if love.system.getOS() == "Web" then
        local web_mapping = {
            A = "Enter",
            B = "Esc",
            X = "Space",
            Y = "C",
            L1 = "Z",
            R1 = "X",
            START = "Enter",
            SELECT = "Tab",
            DPAD = "Arrows"
        }
        return web_mapping[key] or key
    end
    return key
end

function renderer.formatText(text)
    if love.system.getOS() == "Web" then
        text = text:gsub("Press B", "Press Esc")
        text = text:gsub("%[B%]", "[Esc]")
        text = text:gsub("Press L1", "Press Z")
        text = text:gsub("%[L1%]", "[Z]")
        text = text:gsub("Press R1", "Press X")
        text = text:gsub("%[R1%]", "[X]")
        text = text:gsub("Press Y", "Press C")
        text = text:gsub("%[Y%]", "[C]")
        text = text:gsub("B button", "Esc key")
    end
    return text
end

-- ============================================================================
-- Draw a key badge (rounded rectangle with text inside)
-- ============================================================================
local function drawKeyBadge(text, x, y, w, h)
    local scale = _G.scale
    local visual_offset_y = -math.max(1, math.floor(1.5 * scale))
    local original_text = text
    text = renderer.getButtonPrompt(text)
    local letter_offset_y = (text == "Y" or text == "C") and visual_offset_y or (visual_offset_y - math.max(1, math.floor(1 * scale)))

    -- Save dynamically tracked coordinates for the Theme Y button
    if text == "Y" then
        renderer.theme_button_x = x + w / 2
        renderer.theme_button_y = y + h / 2
    end

    -- Determine if this button is currently pressed for visual feedback
    local is_pressed = false
    local is_left = false
    local is_right = false
    local is_up = false
    local is_down = false

    local success, Input = pcall(require, "input")
    if success and Input and Input.state then
        if original_text == "DPAD" then
            is_left = Input.state["left"] == true
            is_right = Input.state["right"] == true
            is_up = Input.state["up"] == true
            is_down = Input.state["down"] == true
            is_pressed = is_left or is_right or is_up or is_down
        elseif original_text == "L/R" then
            local l_mapped = love.system.getOS() == "Web" and "z" or "l1"
            local r_mapped = love.system.getOS() == "Web" and "x" or "r1"
            is_pressed = (Input.state[l_mapped] == true) or (Input.state[r_mapped] == true)
        else
            if original_text == "START" then
                is_pressed = (Input.state["space"] == true) or (Input.state["rshift"] == true) or (Input.state["return"] == true)
            else
                local mapping = {
                    A = "return",
                    B = "escape", -- updated mapping for web detection
                    X = "space",
                    Y = "c",
                    L1 = "z",
                    R1 = "x"
                }
                local fallback_mapping = {
                    A = "return", B = "backspace", X = "x", Y = "y", L1 = "l1", R1 = "r1"
                }
                local mapped = love.system.getOS() == "Web" and mapping[original_text] or fallback_mapping[original_text]
                if mapped then
                    is_pressed = Input.state[mapped] == true
                end
            end
        end
    end

    -- Apply tactile button depression shifts
    local press_shift_y = 0
    local shadow_shrink = 1.0
    if is_pressed then
        press_shift_y = math.max(1, math.floor(1.5 * scale))
        shadow_shrink = 0.3
    end

    local function draw()
        if original_text == "DPAD" then
            local aw = w * 0.32
            local cr = math.floor(aw * 0.25)

            if _G.theme == "matrix" then
                -- Black background cross (shifted by press_shift_y)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", x, y + (h - aw) / 2 + press_shift_y, w, aw)
                love.graphics.rectangle("fill", x + (w - aw) / 2, y + press_shift_y, aw, h)

                -- Green outline cross (shifted by press_shift_y)
                love.graphics.setColor(help_key_color)
                love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
                love.graphics.rectangle("line", x, y + (h - aw) / 2 + press_shift_y, w, aw)
                love.graphics.rectangle("line", x + (w - aw) / 2, y + press_shift_y, aw, h)

                -- Center core circle outline
                love.graphics.circle("line", x + w/2, y + h/2 + press_shift_y, aw * 0.7)

                -- Draw four small direction dots inside in help_key_text (press-feedback highlights)
                love.graphics.setColor(help_key_text)
                local dot_r = math.max(1.2 * scale, 1)
                local offset = w * 0.35

                local dot_l = is_left and math.max(2.5 * scale, 2) or dot_r
                local dot_r_active = is_right and math.max(2.5 * scale, 2) or dot_r
                local dot_u = is_up and math.max(2.5 * scale, 2) or dot_r
                local dot_d = is_down and math.max(2.5 * scale, 2) or dot_r

                love.graphics.circle("fill", x + w/2 - offset, y + h/2 + press_shift_y, dot_l) -- Left
                love.graphics.circle("fill", x + w/2 + offset, y + h/2 + press_shift_y, dot_r_active) -- Right
                love.graphics.circle("fill", x + w/2, y + h/2 - offset + press_shift_y, dot_u) -- Up
                love.graphics.circle("fill", x + w/2, y + h/2 + offset + press_shift_y, dot_d) -- Down
                return
            end

            -- D-Pad shadow (shrinks when depressed)
            love.graphics.setColor(0, 0, 0, 0.2)
            local sh = math.max(1, math.floor(1.5 * scale)) * shadow_shrink
            love.graphics.rectangle("fill", x, y + (h - aw) / 2 + sh, w, aw, cr)
            love.graphics.rectangle("fill", x + (w - aw) / 2, y + sh, aw, h, cr)

            -- D-Pad body (shifted by press_shift_y)
            love.graphics.setColor(help_key_color)
            love.graphics.rectangle("fill", x, y + (h - aw) / 2 + press_shift_y, w, aw, cr)
            love.graphics.rectangle("fill", x + (w - aw) / 2, y + press_shift_y, aw, h, cr)

            -- Center core circle to blend the intersection
            love.graphics.circle("fill", x + w/2, y + h/2 + press_shift_y, aw * 0.7)

            -- Draw four small direction dots inside in help_key_text (press-feedback highlights)
            love.graphics.setColor(help_key_text)
            local dot_r = math.max(1.2 * scale, 1)
            local offset = w * 0.35

            local dot_l = is_left and math.max(2.5 * scale, 2) or dot_r
            local dot_r_active = is_right and math.max(2.5 * scale, 2) or dot_r
            local dot_u = is_up and math.max(2.5 * scale, 2) or dot_r
            local dot_d = is_down and math.max(2.5 * scale, 2) or dot_r

            love.graphics.circle("fill", x + w/2 - offset, y + h/2 + press_shift_y, dot_l) -- Left
            love.graphics.circle("fill", x + w/2 + offset, y + h/2 + press_shift_y, dot_r_active) -- Right
            love.graphics.circle("fill", x + w/2, y + h/2 - offset + press_shift_y, dot_u) -- Up
            love.graphics.circle("fill", x + w/2, y + h/2 + offset + press_shift_y, dot_d) -- Down
            return
        end

        if text == "A" or text == "B" or text == "X" or text == "Y" then
            local cx, cy = x + w/2, y + h/2
            local r = h * 0.45

            if _G.theme == "matrix" then
                -- Black background circle
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.circle("fill", cx, cy + press_shift_y, r)

                -- Green outline circle
                love.graphics.setColor(help_key_color)
                love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
                love.graphics.circle("line", cx, cy + press_shift_y, r)

                -- Text letter
                love.graphics.setFont(font_help_key)
                love.graphics.setColor(help_key_text)
                local tw = font_help_key:getWidth(text)
                local th = font_help_key:getHeight()
                love.graphics.print(text, cx - tw/2, cy - th/2 + letter_offset_y + press_shift_y)
                return
            end

            -- Button shadow (shrinks when depressed)
            love.graphics.setColor(0, 0, 0, 0.25)
            local sh = math.max(1, math.floor(1.5 * scale)) * shadow_shrink
            love.graphics.circle("fill", cx, cy + sh, r)

            -- Button body (shifted by press_shift_y)
            love.graphics.setColor(help_key_color)
            love.graphics.circle("fill", cx, cy + press_shift_y, r)

            -- Button border
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
            love.graphics.circle("line", cx, cy + press_shift_y, r)

            -- Text letter
            love.graphics.setFont(font_help_key)
            love.graphics.setColor(help_key_text)
            local tw = font_help_key:getWidth(text)
            local th = font_help_key:getHeight()
            love.graphics.print(text, cx - tw/2, cy - th/2 + letter_offset_y + press_shift_y)
            return
        end

        if original_text == "L1" or original_text == "R1" or original_text == "L" or original_text == "R" or original_text == "START" or original_text == "SELECT" or (love.system.getOS() == "Web" and string.len(text) > 1) then
            local cr = math.floor(h * 0.4)

            if _G.theme == "matrix" then
                -- Black background capsule
                love.graphics.setColor(0, 0, 0, 1)
                roundedRect("fill", x, y + press_shift_y, w, h, cr)

                -- Green outline capsule
                love.graphics.setColor(help_key_color)
                love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
                roundedRect("line", x, y + press_shift_y, w, h, cr)

                -- Text
                love.graphics.setFont(font_help_key)
                love.graphics.setColor(help_key_text)
                local tw = font_help_key:getWidth(text)
                local th = font_help_key:getHeight()
                love.graphics.print(text, x + (w - tw) / 2, y + (h - th) / 2 + letter_offset_y + press_shift_y)
                return
            end

            -- Shadow (shrinks when depressed)
            love.graphics.setColor(0, 0, 0, 0.2)
            local sh = math.max(1, math.floor(1.5 * scale)) * shadow_shrink
            roundedRect("fill", x, y + sh, w, h, cr)

            -- Body (shifted by press_shift_y)
            love.graphics.setColor(help_key_color)
            roundedRect("fill", x, y + press_shift_y, w, h, cr)

            -- Border
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
            roundedRect("line", x, y + press_shift_y, w, h, cr)

            -- Text
            love.graphics.setFont(font_help_key)
            love.graphics.setColor(help_key_text)
            local tw = font_help_key:getWidth(text)
            local th = font_help_key:getHeight()
            love.graphics.print(text, x + (w - tw) / 2, y + (h - th) / 2 + letter_offset_y + press_shift_y)
            return
        end

        local cr = math.floor(h * 0.3)

        -- Badge shadow (smooth depth effect, shrinks when depressed)
        love.graphics.setColor(0, 0, 0, 0.2)
        local sh_off = math.max(1, math.floor(2 * scale)) * shadow_shrink
        roundedRect("fill", x, y + sh_off, w, h, cr)

        -- Badge background (shifted by press_shift_y)
        love.graphics.setColor(help_key_color)
        roundedRect("fill", x, y + press_shift_y, w, h, cr)

        -- Subtle border for a clean, premium feel
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.setLineWidth(math.max(1, math.floor(1 * scale)))
        roundedRect("line", x, y + press_shift_y, w, h, cr)

        -- Badge text
        love.graphics.setFont(font_help_key)
        love.graphics.setColor(help_key_text)
        local tw = font_help_key:getWidth(text)
        local th = font_help_key:getHeight()

        -- Visual alignment corrections for arrows in ClearSans
        local offset_x, offset_y = 0, letter_offset_y + press_shift_y
        if text == "←" then
            offset_y = offset_y - math.floor(2 * scale)
            offset_x = math.floor(1 * scale)
        elseif text == "→" then
            offset_y = offset_y - math.floor(2 * scale)
            offset_x = -math.floor(1 * scale)
        end

        love.graphics.print(text, x + (w - tw) / 2 + offset_x, y + (h - th) / 2 + offset_y)
    end

    -- Canvas supersampling wrapper:
    local pad = math.ceil(4 * scale)
    local canvas_w = math.ceil((w + pad * 2) * 2)
    local canvas_h = math.ceil((h + pad * 2) * 2)
    if not badge_canvas or badge_canvas:getWidth() < canvas_w or badge_canvas:getHeight() < canvas_h then
        local new_w = badge_canvas and math.max(badge_canvas:getWidth(), canvas_w) or canvas_w
        local new_h = badge_canvas and math.max(badge_canvas:getHeight(), canvas_h) or canvas_h
        badge_canvas = love.graphics.newCanvas(new_w, new_h)
        badge_canvas:setFilter("linear", "linear")
    end
    if not badge_quad then
        badge_quad = love.graphics.newQuad(0, 0, canvas_w, canvas_h, badge_canvas:getDimensions())
    else
        badge_quad:setViewport(0, 0, canvas_w, canvas_h, badge_canvas:getDimensions())
    end

    local old_canvas = love.graphics.getCanvas()
    local sx, sy, sw, sh = love.graphics.getScissor()
    love.graphics.setScissor()

    love.graphics.setCanvas(badge_canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.push("all")
    love.graphics.scale(2, 2)
    love.graphics.translate(-x + pad, -y + pad)

    draw()

    love.graphics.pop()
    if old_canvas then
        love.graphics.setCanvas({old_canvas, stencil = true})
    else
        love.graphics.setCanvas()
    end
    if sx then
        love.graphics.setScissor(sx, sy, sw, sh)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(badge_canvas, badge_quad, x - pad, y - pad, 0, 0.5, 0.5)
    love.graphics.setBlendMode("alpha", "alphamultiply")
end

-- ============================================================================
-- Draw controls help section
-- ============================================================================
function renderer.drawHelp(game)
    if love.system.getOS() == "Web" then return end

    local sound = require("sound")
    local w, h = love.graphics.getDimensions()
    local scale = _G.scale
    local padding = math.floor(10 * scale)
    local bar_x = padding
    local bar_w = w - padding * 2
    local hy = layout.help_y
    local hh = layout.help_h
    local cr = math.floor(8 * scale)



    local badge_h = math.floor(28 * scale)
    local badge_y = hy + (hh - badge_h) / 2
    local item_gap = math.floor(8 * scale)
    local label_gap = math.floor(4 * scale)

    -- --- D-PAD section (left side) ---
    local dpad_x = bar_x + math.floor(10 * scale)
    local dpad_size = math.floor(24 * scale)

    -- Draw unified vector D-pad icon
    drawKeyBadge("DPAD", dpad_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
    dpad_x = dpad_x + dpad_size + math.floor(6 * scale)

    -- D-pad Label
    love.graphics.setFont(font_help_label)
    love.graphics.setColor(ui_text)
    love.graphics.print("Move", dpad_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

    -- Action buttons (right side) ---
    local right_x = bar_x + bar_w - math.floor(10 * scale)

    -- Determine cross-fade alphas for BGM info and normal help prompts
    local is_active_gameplay = (game.state ~= Game.STATE_WON and game.state ~= Game.STATE_LOST and game.state ~= Game.STATE_PAUSED and not (game.state == Game.STATE_TARGETING_BOMB or game.state == Game.STATE_TARGETING_SWAP_1 or game.state == Game.STATE_TARGETING_SWAP_2))
    
    local help_alpha = 1.0
    local bgm_alpha = 0.0

    if is_active_gameplay and now_playing_timer > 0 then
        if now_playing_timer > 3.8 then
            help_alpha = (now_playing_timer - 3.8) / 0.2
            bgm_alpha = 0.0
        elseif now_playing_timer > 3.6 then
            help_alpha = 0.0
            bgm_alpha = (3.8 - now_playing_timer) / 0.2
        elseif now_playing_timer > 0.4 then
            help_alpha = 0.0
            bgm_alpha = 1.0
        elseif now_playing_timer > 0.2 then
            help_alpha = 0.0
            bgm_alpha = (now_playing_timer - 0.2) / 0.2
        else
            help_alpha = (0.2 - now_playing_timer) / 0.2
            bgm_alpha = 0.0
        end
    end

    -- Determine which actions to show based on game state
    local actions = {}

    if help_alpha > 0 then
        if game.state == Game.STATE_WON then
            table.insert(actions, 1, {key = "A", label = "Continue"})
            table.insert(actions, 1, {key = "X", label = "Quit"})
            table.insert(actions, 1, {key = "SELECT", label = "Restart"})
            if game.mode ~= "timeattack" and game.mode ~= "nomercy" and game.mode ~= "goose" and game.canUndo then
                if game.mode == "plus" and game.powerups.undo > 0 then
                    table.insert(actions, 1, {key = "B", label = "Undo:" .. game.powerups.undo})
                elseif game.mode ~= "plus" then
                    table.insert(actions, 1, {key = "B", label = "Undo"})
                end
            end
        elseif game.state == Game.STATE_LOST then
            table.insert(actions, 1, {key = "A", label = "New Game"})
            table.insert(actions, 1, {key = "X", label = "Quit"})
            if game.mode ~= "timeattack" and game.mode ~= "nomercy" and game.mode ~= "goose" and game.canUndo then
                if game.mode == "plus" and game.powerups.undo > 0 then
                    table.insert(actions, 1, {key = "B", label = "Undo:" .. game.powerups.undo})
                elseif game.mode ~= "plus" then
                    table.insert(actions, 1, {key = "B", label = "Undo"})
                end
            end
        elseif game.state == Game.STATE_PAUSED then
            table.insert(actions, 1, {key = "A", label = "Restart"})
            table.insert(actions, 1, {key = "X", label = "Quit"})
            if sound.isBgmEnabled() then
                table.insert(actions, 1, {key = "L1", label = "Skip Track"})
            end
            table.insert(actions, 1, {key = "START", label = "Resume"})
        elseif game.state == Game.STATE_TARGETING_BOMB or game.state == Game.STATE_TARGETING_SWAP_1 or game.state == Game.STATE_TARGETING_SWAP_2 then
            table.insert(actions, 1, {key = "A", label = "Confirm"})
            table.insert(actions, 1, {key = "B", label = "Cancel"})
        else
            if game.mode == "plus" then
                table.insert(actions, 1, {key = "START", label = "Pause"})
                table.insert(actions, 1, {key = "L1", label = "Swap:" .. game.powerups.swap})
                table.insert(actions, 1, {key = "R1", label = "Bomb:" .. game.powerups.bomb})
                table.insert(actions, 1, {key = "B", label = "Undo:" .. game.powerups.undo})
            elseif game.mode == "timeattack" or game.mode == "nomercy" or game.mode == "goose" then
                -- Time Attack / No Mercy / Goose: no undo, no powerups — keep it clean
                table.insert(actions, 1, {key = "START", label = "Pause"})
                table.insert(actions, 1, {key = "Y", label = "Switch Theme"})
            else
                table.insert(actions, 1, {key = "START", label = "Pause"})
                table.insert(actions, 1, {key = "Y", label = "Switch Theme"})
                if game.canUndo then
                    table.insert(actions, 1, {key = "B", label = "Undo"})
                end
            end
        end
    end

    -- Draw actions right-to-left with help_alpha transparency
    local orig_help_key_color = help_key_color
    local orig_help_key_text = help_key_text
    local orig_ui_text = ui_text

    if help_alpha < 1.0 then
        if type(orig_help_key_color) == "table" then
            help_key_color = {orig_help_key_color[1], orig_help_key_color[2], orig_help_key_color[3], (orig_help_key_color[4] or 1.0) * help_alpha}
        end
        if type(orig_help_key_text) == "table" then
            help_key_text = {orig_help_key_text[1], orig_help_key_text[2], orig_help_key_text[3], (orig_help_key_text[4] or 1.0) * help_alpha}
        end
        if type(orig_ui_text) == "table" then
            ui_text = {orig_ui_text[1], orig_ui_text[2], orig_ui_text[3], (orig_ui_text[4] or 1.0) * help_alpha}
        end
    end

    for _, action in ipairs(actions) do
        -- Label
        love.graphics.setFont(font_help_label)
        local lbl_w = font_help_label:getWidth(action.label)
        right_x = right_x - lbl_w
        love.graphics.setColor(ui_text)
        love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Badge
        right_x = right_x - label_gap
        local translated_key = renderer.getButtonPrompt(action.key)
        local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(translated_key) + math.floor(12 * scale))
        right_x = right_x - key_w
        drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

        right_x = right_x - item_gap
    end

    -- Restore original file-scope colors
    help_key_color = orig_help_key_color
    help_key_text = orig_help_key_text
    ui_text = orig_ui_text

    -- Draw BGM notification in the footer with bgm_alpha transparency
    if bgm_alpha > 0 and now_playing_track then
        local bgm_right_x = bar_x + bar_w - math.floor(10 * scale)
        love.graphics.setFont(font_help_label)
        local display_text = now_playing_track.title .. " - " .. now_playing_track.artist
        local text_w = font_help_label:getWidth(display_text)
        
        local viz_w = math.floor(14 * scale)
        local total_w = text_w + viz_w + math.floor(8 * scale)
        local start_x = bgm_right_x - total_w
        
        -- Draw animated visualizer
        if type(help_key_color) == "table" then
            love.graphics.setColor(help_key_color[1], help_key_color[2], help_key_color[3], (help_key_color[4] or 1.0) * bgm_alpha)
        else
            love.graphics.setColor(1.0, 1.0, 1.0, bgm_alpha)
        end
        
        local t = love.timer.getTime()
        local bar1_h = math.floor((6 + math.sin(t * 15) * 4) * scale)
        local bar2_h = math.floor((10 + math.sin(t * 22 + 1) * 6) * scale)
        local bar3_h = math.floor((5 + math.sin(t * 18 + 2) * 3) * scale)
        local bar_w = math.floor(3 * scale)
        local bar_gap = math.floor(2 * scale)
        local base_y = badge_y + badge_h - (badge_h - 12 * scale) / 2
        
        love.graphics.rectangle("fill", start_x, base_y - bar1_h, bar_w, bar1_h, 1 * scale, 1 * scale)
        love.graphics.rectangle("fill", start_x + bar_w + bar_gap, base_y - bar2_h, bar_w, bar2_h, 1 * scale, 1 * scale)
        love.graphics.rectangle("fill", start_x + (bar_w + bar_gap) * 2, base_y - bar3_h, bar_w, bar3_h, 1 * scale, 1 * scale)
        
        -- Draw text label
        if type(ui_text) == "table" then
            love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], (ui_text[4] or 1.0) * bgm_alpha)
        else
            love.graphics.setColor(1.0, 1.0, 1.0, bgm_alpha)
        end
        local text_x = start_x + viz_w + math.floor(8 * scale)
        love.graphics.print(display_text, text_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)
    end
end

-- ============================================================================
-- Draw game over / win / confirm restart overlay
-- ============================================================================
function renderer.drawOverlay(game)
    if game:isPlaying() then
        win_timer = 0
        return
    end
    if game:isAnimating() and game.state ~= Game.STATE_PAUSED then return end

    local bx, by = layout.board_x, layout.board_y
    local bs = layout.board_size
    local dt = love.timer.getDelta()

    if game.state == Game.STATE_WON then
        win_timer = win_timer + dt
        local fade_t = math.min(win_timer / 0.8, 1.0)
        -- Smooth ease out
        local ease_t = 1 - math.pow(1 - fade_t, 3)

        love.graphics.setColor(overlay_win[1], overlay_win[2], overlay_win[3], 0.6 * ease_t)
        roundedRect("fill", bx, by, bs, bs, layout.corner_radius * 2)

        local msg = "You Win!"
        love.graphics.setFont(font_message)
        local tw = font_message:getWidth(msg)
        local th = font_message:getHeight()
        local textX = bx + bs / 2
        local textY = by + bs / 2

        -- Pulsing golden glow behind the text
        local glow_alpha = (math.sin(win_timer * 3) * 0.5 + 0.5) * 0.4 * ease_t
        local glow_color = getTileColor(2048)
        love.graphics.setColor(glow_color[1], glow_color[2], glow_color[3], glow_alpha)

        -- Draw soft glow by drawing multiple scaled rounded rectangles
        for i = 1, 3 do
            local gw = tw + (40 * _G.scale * i)
            local gh = th + (40 * _G.scale * i)
            roundedRect("fill", textX - gw/2, textY - gh/2, gw, gh, layout.corner_radius * 2)
        end

        -- Draw the text
        local text_scale = 0.8 + (0.2 * ease_t)
        love.graphics.setColor(super_tile_color[1], super_tile_color[2], super_tile_color[3], ease_t)

        love.graphics.push()
        love.graphics.translate(textX, textY)
        love.graphics.scale(text_scale, text_scale)
        love.graphics.print(msg, -tw/2, -th/2)
        love.graphics.pop()
    else
        win_timer = 0

        if game.state == Game.STATE_PAUSED then
            love.graphics.setColor(0, 0, 0, 0.65)
        elseif game.mode == "timeattack" and game.timesUp then
            -- Urgent orange overlay for Time's Up
            love.graphics.setColor(0.85, 0.35, 0.1, 0.6)
        else
            love.graphics.setColor(overlay_lose[1], overlay_lose[2], overlay_lose[3], 0.5)
        end
        roundedRect("fill", bx, by, bs, bs, layout.corner_radius * 2)

        local msg
        if game.state == Game.STATE_PAUSED then
            msg = "Paused"
        elseif game.mode == "timeattack" and game.timesUp then
            msg = "Time's Up!"
        else
            msg = "Game Over!"
        end
        love.graphics.setFont(font_message)
        if game.state == Game.STATE_PAUSED then
            love.graphics.setColor(light_text)
        elseif game.mode == "timeattack" and game.timesUp then
            love.graphics.setColor(1.0, 0.95, 0.7, 1.0)   -- warm cream text
        else
            love.graphics.setColor(ui_text)
        end

        local tw = font_message:getWidth(msg)
        local th = font_message:getHeight()
        if game.state == Game.STATE_PAUSED then
            local sound = require("sound")
            local track = sound.getCurrentTrack()
            if track then
                local track_lbl = track.title .. " - " .. track.artist
                love.graphics.setFont(font_help_label)
                local tw_track = font_help_label:getWidth(track_lbl)
                
                -- Draw "Paused" slightly higher to balance the box layout
                love.graphics.setFont(font_message)
                love.graphics.setColor(light_text)
                love.graphics.print(msg, bx + (bs - tw) / 2, by + (bs - th) / 2 - math.floor(12 * scale))
                
                -- Draw track details centered below
                love.graphics.setFont(font_help_label)
                love.graphics.setColor(0.65, 0.65, 0.65, 0.9)
                love.graphics.print(track_lbl, bx + (bs - tw_track) / 2, by + (bs - th) / 2 + th - math.floor(6 * scale))
            else
                love.graphics.print(msg, bx + (bs - tw) / 2, by + (bs - th) / 2)
            end
        else
            love.graphics.print(msg, bx + (bs - tw) / 2, by + (bs - th) / 2)
        end
    end
end

-- ============================================================================
-- Main draw function
-- ============================================================================
local function drawStencilCircle()
    local progress = 1 - (transition_timer / transition_duration)
    -- Ease out cubic: 1 - (1 - t)^3
    local p = 1 - math.pow(1 - progress, 3)
    local w, h = love.graphics.getDimensions()
    -- Max radius needs to cover the entire screen from the bottom right
    local max_radius = math.sqrt(w*w + h*h)
    local radius = max_radius * p
    love.graphics.circle("fill", transition_center_x, transition_center_y, radius)
end

function renderer.startThemeTransition(drawTarget)
    if not _G.screen_transitions then
        return
    end
    local w, h = love.graphics.getDimensions()
    if not transition_canvas then
        transition_canvas = love.graphics.newCanvas(w, h)
    end
    -- Capture current screen to canvas
    love.graphics.setCanvas({transition_canvas, stencil = true})
    love.graphics.clear()
    if type(drawTarget) == "function" then
        drawTarget()
    else
        renderer.draw(drawTarget, true) -- Pass true to skip transition drawing inside
    end
    love.graphics.setCanvas()

    transition_timer = transition_duration
    -- The Y button coordinates are tracked dynamically!
    transition_center_x = renderer.theme_button_x or (w - math.floor(90 * _G.scale))
    transition_center_y = renderer.theme_button_y or (h - math.floor(30 * _G.scale))
end

function renderer.updateTransition(dt)
    -- Update now playing BGM notifications
    local sound = require("sound")
    local current_track = sound.getCurrentTrack()
    local path = current_track and current_track.path or nil
    if path ~= last_track_path then
        last_track_path = path
        if current_track then
            now_playing_track = current_track
            now_playing_timer = 4.0
        else
            now_playing_track = nil
            now_playing_timer = 0
        end
    end
    if now_playing_timer > 0 then
        now_playing_timer = math.max(0, now_playing_timer - dt)
    end
    if _G.theme_morph_timer and _G.theme_morph_timer > 0 then
        _G.theme_morph_timer = math.max(0, _G.theme_morph_timer - dt)
    end

    if transition_timer > 0 then
        transition_timer = math.max(0, transition_timer - dt)
    end
    if toast_timer > 0 then
        toast_timer = math.max(0, toast_timer - dt)
        if toast_timer == 0 and #toast_queue > 0 then
            local next_toast = table.remove(toast_queue, 1)
            toast_message = next_toast.msg
            toast_timer = next_toast.duration
            toast_max_duration = next_toast.duration
            if next_toast.is_achievement then
                spawnToastParticles()
            end
        end
    end

    if menu_anim_target_y then
        if not _G.screen_transitions then
            menu_anim_y = menu_anim_target_y
        else
            if not menu_anim_y then
                menu_anim_y = menu_anim_target_y
            end
            local lerp_factor = 1 - math.exp(-25 * dt)
            menu_anim_y = menu_anim_y + (menu_anim_target_y - menu_anim_y) * lerp_factor
            if math.abs(menu_anim_y - menu_anim_target_y) < 0.5 then
                menu_anim_y = menu_anim_target_y
            end
        end
    end

    if menu_anim_target_x then
        if not _G.screen_transitions then
            menu_anim_x = menu_anim_target_x
        else
            if not menu_anim_x then
                menu_anim_x = menu_anim_target_x
            end
            local lerp_factor = 1 - math.exp(-25 * dt)
            menu_anim_x = menu_anim_x + (menu_anim_target_x - menu_anim_x) * lerp_factor
            if math.abs(menu_anim_x - menu_anim_target_x) < 0.5 then
                menu_anim_x = menu_anim_target_x
            end
        end
    end

    if menu_anim_target_w then
        if not _G.screen_transitions then
            menu_anim_w = menu_anim_target_w
        else
            if not menu_anim_w then
                menu_anim_w = menu_anim_target_w
            end
            local lerp_factor = 1 - math.exp(-25 * dt)
            menu_anim_w = menu_anim_w + (menu_anim_target_w - menu_anim_w) * lerp_factor
            if math.abs(menu_anim_w - menu_anim_target_w) < 0.5 then
                menu_anim_w = menu_anim_target_w
            end
        end
    end

    -- Arcade panel slide animation
    if not _G.screen_transitions then
        arcade_panel_y_offset = arcade_panel_target
    else
        local panel_lerp = 1 - math.exp(-20 * dt)
        arcade_panel_y_offset = arcade_panel_y_offset + (arcade_panel_target - arcade_panel_y_offset) * panel_lerp
        if math.abs(arcade_panel_y_offset - arcade_panel_target) < 0.5 then
            arcade_panel_y_offset = arcade_panel_target
        end
    end
    -- Bg alpha: fully visible (0.75) when panel is near open (offset ~0), fades as panel closes
    local h = love.graphics.getHeight()
    local raw_t = 1 - math.min(1, arcade_panel_y_offset / math.max(1, h * 0.7))
    arcade_menu_bg_alpha = raw_t * 0.75

    -- Horizontal page transition logic
    if _G.appState == "PLAY_SELECT" then
        panel_page_target = 0
    elseif _G.appState == "ARCADE_MENU" then
        panel_page_target = 1
    end
    if not _G.screen_transitions then
        panel_page_current = panel_page_target
        play_select_sel_current = _G.play_select_selection or 1
        arcade_sel_col_current = ((_G.arcade_selection or 1) - 1) % 2 + 1
        arcade_sel_row_current = math.floor(((_G.arcade_selection or 1) - 1) / 2) + 1
    else
        local page_lerp = 1 - math.exp(-22 * dt)
        panel_page_current = panel_page_current + (panel_page_target - panel_page_current) * page_lerp
        if math.abs(panel_page_current - panel_page_target) < 0.001 then
            panel_page_current = panel_page_target
        end

        local sel_lerp = 1 - math.exp(-12 * dt)
        if not play_select_sel_current then
            play_select_sel_current = _G.play_select_selection or 1
        else
            play_select_sel_current = play_select_sel_current + ((_G.play_select_selection or 1) - play_select_sel_current) * sel_lerp
        end

        local target_col = ((_G.arcade_selection or 1) - 1) % 2 + 1
        local target_row = math.floor(((_G.arcade_selection or 1) - 1) / 2) + 1
        if not arcade_sel_col_current then
            arcade_sel_col_current = target_col
            arcade_sel_row_current = target_row
        else
            arcade_sel_col_current = arcade_sel_col_current + (target_col - arcade_sel_col_current) * sel_lerp
            arcade_sel_row_current = arcade_sel_row_current + (target_row - arcade_sel_row_current) * sel_lerp
        end
    end

    -- Text size flash timer
    if text_size_flash_timer > 0 then
        text_size_flash_timer = math.max(0, text_size_flash_timer - dt)
    end

    -- Update toast particles
    for i = #toast_particles, 1, -1 do
        local p = toast_particles[i]
        p.vx = p.vx * p.drag
        p.vy = p.vy * p.drag
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 200 * dt * _G.scale
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(toast_particles, i)
        end
    end
end

local function drawToast()
    if toast_timer <= 0 or not toast_message then return end

    local w, h = love.graphics.getDimensions()
    love.graphics.setFont(font_message)

    local tw = font_message:getWidth(toast_message)
    local th = font_message:getHeight()
    local padX = 20 * _G.scale
    local padY = 10 * _G.scale
    local max_text_w = w - (padX * 2) - (40 * _G.scale)

    local text_w, wrapped_lines = font_message:getWrap(toast_message, max_text_w)
    local th = font_message:getHeight() * #wrapped_lines

    local boxW = text_w + padX * 2
    local boxH = th + padY * 2

    -- Fade in/out
    local alpha = 1.0
    if toast_timer < 0.3 then
        alpha = toast_timer / 0.3
    elseif toast_timer > toast_max_duration - 0.3 then
        alpha = (toast_max_duration - toast_timer) / 0.3
    end

    -- Slide down from the top banner
    local target_y = 10 * _G.scale
    local y = target_y - (1.0 - alpha) * 20 * _G.scale

    love.graphics.setColor(0.1, 0.1, 0.1, 0.85 * alpha)
    roundedRect("fill", (w - boxW) / 2, y, boxW, boxH, 12 * _G.scale)

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.printf(toast_message, (w - text_w) / 2, y + padY, text_w, "center")

    -- Draw particles in front of toast
    for _, p in ipairs(toast_particles) do
        local alpha_p = math.min(1, p.life * 2) * alpha
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha_p)
        
        local speed = math.sqrt(p.vx * p.vx + p.vy * p.vy)
        if speed > 20 then
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(math.atan2(p.vy, p.vx))
            local stretch = math.max(1, speed / 80)
            love.graphics.rectangle("fill", -p.size * stretch / 2, -p.size / 2, p.size * stretch, p.size, p.size / 2, p.size / 2)
            love.graphics.pop()
        else
            love.graphics.circle("fill", p.x, p.y, p.size / 2)
        end
    end
end

-- Internal functions
-- ============================================================================
-- Draw targeting cursor
-- ============================================================================
function renderer.drawTargetingCursor(game)
    if game.state ~= Game.STATE_TARGETING_BOMB and
       game.state ~= Game.STATE_TARGETING_SWAP_1 and
       game.state ~= Game.STATE_TARGETING_SWAP_2 then
        return
    end

    local bx, by = layout.board_x, layout.board_y
    local cs = layout.cell_size
    local cg = layout.cell_gap
    local cr = layout.corner_radius

    -- Darken the board slightly
    love.graphics.setColor(0, 0, 0, 0.4)
    roundedRect("fill", bx, by, layout.board_size, layout.board_size, cr * 2)

    -- Draw swap target 1 if active
    if game.swapTarget then
        local stx = bx + cg + (game.swapTarget.x - 1) * (cs + cg)
        local sty = by + cg + (game.swapTarget.y - 1) * (cs + cg)
        love.graphics.setColor(0.3, 0.7, 1, 0.5)
        roundedRect("fill", stx, sty, cs, cs, cr)
        love.graphics.setLineWidth(4 * _G.scale)
        love.graphics.setColor(0.3, 0.7, 1, 1)
        roundedRect("line", stx, sty, cs, cs, cr)
    end

    -- Draw cursor
    local tx = bx + cg + (game.cursorX - 1) * (cs + cg)
    local ty = by + cg + (game.cursorY - 1) * (cs + cg)

    -- Blink effect
    local time = love.timer.getTime()
    local alpha = 0.5 + 0.5 * math.sin(time * 10)

    if game.state == Game.STATE_TARGETING_BOMB then
        love.graphics.setColor(1, 0.2, 0.2, alpha)
    else
        love.graphics.setColor(0.3, 1, 0.3, alpha)
    end

    love.graphics.setLineWidth(6 * _G.scale)
    roundedRect("line", tx, ty, cs, cs, cr)
end

-- ============================================================================
-- Tutorial
-- ============================================================================

-- Draw a mini 4x4 board at a given position with static tile data
-- tiles is a flat table: tiles[col][row] = value (or nil/0 for empty)
local mini_fonts_cache = {}

local function drawMiniBoard(bx, by, board_size, tiles, highlight, alpha_mod)
    local scale = _G.scale
    local cell_gap = math.floor(board_size * 0.022)
    local cell_size = math.floor((board_size - cell_gap * 5) / 4)
    local cr = math.floor(cell_size * 0.06)

    local am = alpha_mod or 1.0

    local function setColorWithAlpha(color, alpha_mult)
        local r, g, b, a = 1, 1, 1, 1
        if type(color) == "table" then
            r = color[1] or 1
            g = color[2] or 1
            b = color[3] or 1
            a = color[4] or 1
        end
        love.graphics.setColor(r, g, b, a * alpha_mult)
    end

    -- Create/cache mini fonts sized for this cell size
    local cached_fonts = mini_fonts_cache[cell_size]
    if not cached_fonts then
        cached_fonts = {
            large = love.graphics.newFont(font_path, math.max(8, math.floor(cell_size * 0.45))),
            small = love.graphics.newFont(font_path, math.max(7, math.floor(cell_size * 0.35))),
            tiny  = love.graphics.newFont(font_path, math.max(6, math.floor(cell_size * 0.28)))
        }
        mini_fonts_cache[cell_size] = cached_fonts
    end

    -- Board background
    setColorWithAlpha(board_color, am)
    roundedRect("fill", bx, by, board_size, board_size, cr * 2)

    -- Draw cells
    for col = 1, 4 do
        for row = 1, 4 do
            local cx = bx + cell_gap + (col - 1) * (cell_size + cell_gap)
            local cy = by + cell_gap + (row - 1) * (cell_size + cell_gap)
            local val = tiles and tiles[col] and tiles[col][row] or 0

            -- Tile background
            local color = getTileColor(val)
            if _G.theme == "matrix" and val == 0 then
                setColorWithAlpha(board_color, am)
            else
                setColorWithAlpha(color, am)
            end
            roundedRect("fill", cx, cy, cell_size, cell_size, cr)

            -- Tile text
            if val > 0 then
                local textColor = getTileTextColor(val)
                setColorWithAlpha(textColor, am)

                local font
                if val >= 10000 then
                    font = cached_fonts.tiny
                elseif val >= 1000 then
                    font = cached_fonts.small
                else
                    font = cached_fonts.large
                end
                love.graphics.setFont(font)

                local text = tostring(val)
                local tw = font:getWidth(text)
                local th = font:getHeight()
                love.graphics.print(text, cx + (cell_size - tw) / 2, cy + (cell_size - th) / 2)
            end

            -- Highlight specific cells
            if highlight then
                for _, h in ipairs(highlight) do
                    if h.col == col and h.row == row then
                        local time = love.timer.getTime()
                        local alpha = 0.3 + 0.3 * math.sin(time * 4)
                        love.graphics.setColor(h.r or 0.3, h.g or 1, h.b or 0.3, alpha * am)
                        love.graphics.setLineWidth(math.max(2, math.floor(3 * scale)))
                        roundedRect("line", cx, cy, cell_size, cell_size, cr)
                    end
                end
            end
        end
    end
end

function renderer.drawTutorial(page, skip_transition, static_only)
    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale
    local padding = math.floor(20 * scale)

    -- Slide animation state
    if not static_only and _G.tutorial_slide_timer and _G.tutorial_slide_timer > 0 then
        local dt = love.timer.getDelta()
        _G.tutorial_slide_timer = _G.tutorial_slide_timer - dt
        if _G.tutorial_slide_timer < 0 then _G.tutorial_slide_timer = 0 end
    end

    -- Tutorial slide data
    local slides = {
        {
            title = "HOW TO PLAY",
            lines = {
                "Use the D-Pad to slide all tiles.",
                "Tiles with the same number merge",
                "into one when they collide!",
                "Goal: Create the 2048 tile!"
            },
            tiles = {
                {0, 0, 0, 2},
                {0, 0, 0, 0},
                {0, 0, 0, 2},
                {0, 0, 4, 0}
            }
        },
        {
            title = "MERGING TILES",
            lines = {
                "When two tiles of the same value",
                "touch, they merge into one!",
                "2 + 2 = 4,  4 + 4 = 8,  8 + 8 = 16",
                "Keep merging to reach 2048!"
            },
            tiles = {
                {0, 0, 2, 0},
                {0, 0, 0, 0},
                {0, 2, 0, 4},
                {2, 0, 2, 8}
            },
            highlight = {
                {col = 1, row = 4, r = 0.3, g = 1, b = 0.3},
                {col = 3, row = 4, r = 0.3, g = 1, b = 0.3}
            }
        },
        {
            title = "GAME MODES",
            lines = {
                "Classic Mode:",
                "  Unlimited undo with B button.",
                "Plus Mode:",
                "  Limited powerups: Undo, Bomb, Swap.",
                "  Earn more at tile milestones!"
            },
            tiles = {
                {0, 0, 0, 0},
                {0, 128, 0, 0},
                {16, 64, 256, 0},
                {2, 8, 32, 512}
            }
        },
        {
            title = "ARCADE MODES",
            lines = {
                "Time Attack: Merge 32+ tiles to gain extra time!",
                "Huge Mode: Spacious 5x5 grid for relaxed play.",
                "No Mercy: Hardcore — no undos, 2 tiles per move.",
                "Goose Mode: A silly Goose tile blocks grid cells."
            },
            tiles = {
                {0, 0, 0, 0},
                {0, 32, 64, 0},
                {0, 128, 256, 0},
                {0, 0, 0, 0}
            }
        },
        {
            title = "UNDO  [B]",
            lines = {
                "Made a mistake? Press B to undo!",
                "",
                "Classic: Unlimited undos.",
                "Plus: Limited undo powerups.",
                "Using undo counts as a powerup."
            },
            tiles = {
                {0, 0, 0, 2},
                {0, 0, 0, 2},
                {0, 0, 2, 4},
                {0, 0, 0, 16}
            }
        },
        {
            title = "SWAP  [L1]  (Plus Mode)",
            lines = {
                "Press L1 to swap any two tiles!",
                "Select first tile, then second.",
                "",
                "Use it to rearrange your board",
                "and set up big merges!"
            },
            tiles = {
                {0, 0, 0, 0},
                {0, 0, 0, 0},
                {0, 0, 4, 0},
                {2, 0, 8, 16}
            },
            highlight = {
                {col = 3, row = 3, r = 0.3, g = 0.7, b = 1},
                {col = 3, row = 4, r = 0.3, g = 0.7, b = 1}
            }
        },
        {
            title = "BOMB  [R1]  (Plus Mode)",
            lines = {
                "Press R1 to enter bomb mode.",
                "Select any tile to destroy it!",
                "",
                "Great for clearing high tiles",
                "that are blocking your merges."
            },
            tiles = {
                {0, 0, 0, 0},
                {0, 0, 0, 0},
                {0, 0, 64, 0},
                {2, 4, 8, 16}
            },
            highlight = {
                {col = 3, row = 3, r = 1, g = 0.2, b = 0.2}
            }
        },
        {
            title = "THEMES  [Y]",
            lines = {
                "Press Y anytime to change theme!",
                "",
                "Unlock new themes by earning",
                "achievements. 30 themes total!"
            },

            tiles = {
                {2, 0, 0, 0},
                {4, 0, 0, 0},
                {8, 16, 0, 0},
                {32, 64, 128, 256}
            }
        },
        {
            title = "STRATEGY TIPS",
            lines = {
                "Keep your highest tile in a corner.",
                "Build a chain along one edge.",
                "Never push your big tile away!",
                "",
                "Plan ahead and don't fill the board."
            },
            tiles = {
                {0, 0, 0, 0},
                {0, 0, 0, 0},
                {4, 8, 16, 32},
                {256, 128, 64, 2048}
            },
            highlight = {
                {col = 4, row = 4, r = 1, g = 0.85, b = 0.2}
            }
        }
    }

    local total_pages = #slides

    local dot_r = math.floor(4 * scale)
    local dot_gap = math.floor(14 * scale)
    local dots_w = total_pages * (dot_r * 2 + dot_gap) - dot_gap
    local dots_y = padding + font_title:getHeight() + math.floor(8 * scale)

    local function drawSlide(slide_idx, offset_x, alpha_mod)
        local slide_data = slides[slide_idx]
        if not slide_data then return end

        love.graphics.push()
        love.graphics.translate(offset_x, 0)

        -- 1. Header: title
        love.graphics.setFont(font_title)
        local title_text = renderer.formatText(slide_data.title)
        local title_w = font_title:getWidth(title_text)

        local r, g, b, a = 1, 1, 1, 1
        if type(ui_text) == "table" then
            r = ui_text[1] or 1; g = ui_text[2] or 1; b = ui_text[3] or 1; a = ui_text[4] or 1
        end
        love.graphics.setColor(r, g, b, a * alpha_mod)
        love.graphics.print(title_text, (w - title_w) / 2, padding)

        -- 2. Message box area
        local msg_y = dots_y + dot_r * 2 + math.floor(12 * scale)
        local max_content_w = math.min(w - padding * 2, math.floor(480 * scale))
        local msg_pad = math.floor(15 * scale)

        love.graphics.setFont(font_help_label)
        local max_line_w = 0
        for _, line in ipairs(slide_data.lines) do
            local formatted_line = renderer.formatText(line)
            local lw = font_help_label:getWidth(formatted_line)
            if lw > max_line_w then max_line_w = lw end
        end
        local msg_box_w = math.min(max_content_w, max_line_w + msg_pad * 2)
        local msg_box_x = math.floor((w - msg_box_w) / 2)

        -- Calculate message box height from lines
        local line_h = font_help_label:getHeight()
        local line_spacing = math.floor(2 * scale)
        local paragraph_gap = math.floor(6 * scale)

        local content_h = 0
        for i, line in ipairs(slide_data.lines) do
            local formatted_line = renderer.formatText(line)
            if formatted_line == "" then
                content_h = content_h + paragraph_gap
            else
                content_h = content_h + line_h + (i < #slide_data.lines and line_spacing or 0)
            end
        end
        local msg_box_h = msg_pad * 2 + content_h

        -- Message box background
        local br, bg, bb, ba = 1, 1, 1, 1
        if type(board_color) == "table" then
            br = board_color[1] or 1; bg = board_color[2] or 1; bb = board_color[3] or 1; ba = board_color[4] or 1
        end
        love.graphics.setColor(br, bg, bb, 0.85 * alpha_mod)
        roundedRect("fill", msg_box_x, msg_y, msg_box_w, msg_box_h, math.floor(10 * scale))

        -- Message box border
        local hr, hg, hb, ha = 1, 1, 1, 1
        if type(help_key_color) == "table" then
            hr = help_key_color[1] or 1; hg = help_key_color[2] or 1; hb = help_key_color[3] or 1; ha = help_key_color[4] or 1
        end
        love.graphics.setColor(hr, hg, hb, 0.5 * alpha_mod)
        love.graphics.setLineWidth(math.max(1, math.floor(1.5 * scale)))
        roundedRect("line", msg_box_x, msg_y, msg_box_w, msg_box_h, math.floor(10 * scale))

        -- Message text
        local txt_col = renderer.getContrastTextColor(board_color, ui_text, dark_text)
        local tr, tg, tb, ta = 1, 1, 1, 1
        if type(txt_col) == "table" then
            tr = txt_col[1] or 1; tg = txt_col[2] or 1; tb = txt_col[3] or 1; ta = txt_col[4] or 1
        end
        love.graphics.setColor(tr, tg, tb, ta * alpha_mod)
        local text_y = msg_y + msg_pad
        for _, line in ipairs(slide_data.lines) do
            local formatted_line = renderer.formatText(line)
            if formatted_line == "" then
                text_y = text_y + paragraph_gap
            else
                love.graphics.print(formatted_line, msg_box_x + msg_pad, text_y)
                text_y = text_y + line_h + line_spacing
            end
        end

        -- 3. Mini board
        local board_top = msg_y + msg_box_h + math.floor(12 * scale)
        local footer_h = math.floor(55 * scale)
        local available_h = h - board_top - footer_h - math.floor(10 * scale)
        local available_w = max_content_w
        local board_size = math.min(available_w, available_h)

        -- Limit the mini-board size to keep it perfectly symmetrical and consistent
        local max_board_size = math.floor(204 * scale)
        if board_size > max_board_size then
            board_size = max_board_size
        end

        -- Snap board_size so cells fit perfectly with no floating point gaps
        local cell_gap = math.floor(board_size * 0.022)
        local cell_size = math.floor((board_size - cell_gap * 5) / 4)
        board_size = cell_size * 4 + cell_gap * 5

        -- Center the board vertically in the remaining space
        local extra_y = (available_h - board_size) / 2
        local board_y = board_top + math.floor(extra_y)
        local board_x = math.floor((w - board_size) / 2)

        drawMiniBoard(board_x, board_y, board_size, slide_data.tiles, slide_data.highlight, alpha_mod)

        love.graphics.pop()
    end

    if static_only then
        drawSlide(page, 0, 1.0)
        return
    end

    -- Draw slide content with iOS Push & Dim transition
    if _G.tutorial_slide_timer and _G.tutorial_slide_timer > 0 then
        local progress = 1 - (_G.tutorial_slide_timer / 0.20)
        local p = 1 - math.pow(1 - progress, 3) -- cubic ease-out

        local dir = _G.tutorial_slide_dir or 1
        local shadow_w = math.floor(20 * scale)

        -- Capture the new page to tutorial_new_canvas ONCE at the start of transition
        if not _G.tutorial_slide_ready then
            if not tutorial_new_canvas then
                tutorial_new_canvas = love.graphics.newCanvas(w, h)
            end
            love.graphics.setCanvas({tutorial_new_canvas, stencil = true})
            love.graphics.clear()
            renderer.drawTutorial(page, true, true) -- skip_transition=true, static_only=true
            love.graphics.setCanvas()
            _G.tutorial_slide_ready = true
        end

        if dir == 1 then
            -- Forward transition: New page slides in on top from right (w -> 0)
            -- Old page slides out underneath to the left at 30% speed (0 -> -0.3*w)
            local old_x = math.floor(-0.3 * w * p)
            local new_x = math.floor(w * (1 - p))

            -- 1. Draw old page (underneath)
            if tutorial_old_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(tutorial_old_canvas, old_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")

                -- Dim the old page
                love.graphics.setColor(0, 0, 0, 0.5 * p)
                love.graphics.rectangle("fill", old_x, 0, w, h)
            end

            -- 2. Draw shadow to the left of the new page
            for i = 0, shadow_w - 1 do
                local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                love.graphics.setColor(0, 0, 0, alpha)
                love.graphics.rectangle("fill", new_x - shadow_w + i, 0, 1, h)
            end

            -- 3. Draw new page (on top)
            if tutorial_new_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(tutorial_new_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end
        else
            -- Backward transition: Old page slides out on top to the right (0 -> w)
            -- New page slides in underneath from the left at 30% speed (-0.3*w -> 0)
            local new_x = math.floor(-0.3 * w * (1 - p))
            local old_x = math.floor(w * p)

            -- 1. Draw new page (underneath)
            if tutorial_new_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(tutorial_new_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end

            -- Dim the new page
            love.graphics.setColor(0, 0, 0, 0.5 * (1 - p))
            love.graphics.rectangle("fill", new_x, 0, w, h)

            -- 2. Draw shadow to the left of the old page (sliding on top)
            if tutorial_old_canvas then
                for i = 0, shadow_w - 1 do
                    local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                    love.graphics.setColor(0, 0, 0, alpha)
                    love.graphics.rectangle("fill", old_x - shadow_w + i, 0, 1, h)
                end

                -- 3. Draw old page (on top)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(tutorial_old_canvas, old_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end
        end
    else
        _G.tutorial_slide_ready = false
        -- Just draw the current page normally
        drawSlide(page, 0, 1.0)
    end

    -- Page indicator (dots) — NOT animated, stays fixed
    local dots_x = (w - dots_w) / 2
    for i = 1, total_pages do
        local dx = dots_x + (i - 1) * (dot_r * 2 + dot_gap) + dot_r
        if i == page then
            love.graphics.setColor(help_key_color)
            love.graphics.circle("fill", dx, dots_y, dot_r)
        else
            love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.3)
            love.graphics.circle("fill", dx, dots_y, dot_r)
        end
    end

    -- Footer: navigation hints — NOT animated, stays fixed
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- Build action list: B to exit, Y to switch theme
    local actions = {
        {key = "B", label = "Exit"},
        {key = "Y", label = "Switch Theme"}
    }

    -- Page counter on the left
    love.graphics.setFont(font_help_label)
    love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.6)
    local page_text = page .. "/" .. total_pages
    love.graphics.print(page_text, padding, badge_y + (badge_h - font_help_label:getHeight()) / 2)

    -- DPAD on the left
    if love.system.getOS() ~= "Web" then
        local dpad_x = padding + math.floor(45 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setColor(ui_text)
        love.graphics.print("Page", dpad_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Draw actions right-to-left
        local right_x = w - math.floor(10 * scale)
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end

-- ============================================================================
-- Main Menu
-- ============================================================================
function renderer.getMainMenuOptions()
    local theme_name = _G.theme:gsub("^%l", string.upper)
    local options = {}
    if save.hasLastActiveGame() then
        table.insert(options, "Continue")
    end
    table.insert(options, "Play Game")
    table.insert(options, "Select Theme: " .. theme_name)
    table.insert(options, "Achievements & Stats")
    table.insert(options, "Tutorial")
    if _G.cheats_unlocked then
        table.insert(options, "Secret Menu")
    end
    table.insert(options, "Settings")
    table.insert(options, "About")
    if love.system.getOS() == "Web" then
        table.insert(options, "Exit the Game")
    else
        table.insert(options, "Quit")
    end
    return options
end

function renderer.getSettingsOptions()
    local sound = require("sound")
    if _G.settings_page == "audio" then
        return {
            "Sound Effects: " .. (sound.isEnabled() and "On" or "Off"),
            "Music: " .. (sound.isBgmEnabled() and "On" or "Off"),
            "Vibration: " .. (_G.vibration and "On" or "Off"),
            "Back"
        }
    end

    local anim_speed_lbl = "Gameplay Animation Speed: " .. (_G.animation_speed:gsub("^%l", string.upper))
    local transitions_lbl = "Transitions: " .. (_G.screen_transitions and "On" or "Off")
    
    local undo_val = "1-Move"
    if _G.undo_mode == "unlimited" then
        undo_val = "Unlimited"
    elseif _G.undo_mode == "disabled" then
        undo_val = "Disabled"
    end
    local undo_lbl = "Undo Limit (Classic/Huge): " .. undo_val
    local ta_lbl = "Time Attack Max Limit: " .. _G.time_attack_time .. "s"
    local crt_lbl = "CRT Shader: " .. (_G.crt_filter and "On" or "Off")

    return {
        "Audio & Haptics",
        "Text Size: " .. (_G.text_size == "large" and "Large" or "Normal"),
        anim_speed_lbl,
        transitions_lbl,
        undo_lbl,
        ta_lbl,
        crt_lbl,
        "Back"
    }
end

function renderer.drawSettings(selection, skip_transition)
    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    local options = renderer.getSettingsOptions()
    selection = math.max(1, math.min(#options, selection or 1))
    love.graphics.setFont(font_message)
    -- Restore original main menu line spacing
    local gap = (_G.text_size == "large" and 37 or 34) * scale
    local menu_h = (#options - 1) * gap + font_message:getHeight()
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)

    -- Style the Settings title header (smaller than main menu to avoid squeezing options)
    local header_h = math.floor((_G.text_size == "large" and 70 or 85) * scale)
    local total_h = header_h + math.floor(12 * scale) + menu_h
    local available_h = badge_y - math.floor(10 * scale)
    local start_y = math.max(math.floor(10 * scale), math.floor(math.floor(10 * scale) + (available_h - total_h) / 2))

    local f_title = font_main_menu_title or font_tile_large
    local title_text = _G.settings_page == "audio" and "AUDIO & HAPTICS" or "SETTINGS"
    local tw = f_title:getWidth(title_text)
    local th = f_title:getHeight()
    local tx = (w - tw) / 2
    local ty = start_y + (header_h - th) / 2

    love.graphics.setColor(getTileColor(2048))
    love.graphics.setFont(f_title)
    love.graphics.print(title_text, tx, ty)

    -- Menu options start position
    local menu_start_y = start_y + header_h + math.floor(12 * scale)

    -- Calculate maximum option width using the longest possible states of each option to prevent shifting/jittering
    local max_options
    if _G.settings_page == "audio" then
        max_options = {
            "Sound Effects: Off",
            "Music: Off",
            "Vibration: Off",
            "Back"
        }
    else
        max_options = {
            "Audio & Haptics",
            "Text Size: Normal",
            "Gameplay Animation Speed: Instant",
            "Transitions: Off",
            "Undo Limit (Classic/Huge): Unlimited",
            "Time Attack Max Limit: 90s",
            "CRT Shader: Off",
            "Back"
        }
    end
    local max_ow = 0
    for _, opt in ipairs(max_options) do
        local ow = font_message:getWidth(opt)
        if ow > max_ow then
            max_ow = ow
        end
    end
    local block_x = (w - max_ow) / 2

    local target_oy = menu_start_y + (selection - 1) * gap
    local sel_opt = options[selection]
    local sel_ow = font_message:getWidth(sel_opt)

    local target_ox = block_x - 12 * scale
    local target_ow = sel_ow + 24 * scale

    menu_anim_target_y = target_oy
    menu_anim_target_x = target_ox
    menu_anim_target_w = target_ow

    if not menu_anim_y then menu_anim_y = target_oy end
    if not menu_anim_x then menu_anim_x = target_ox end
    if not menu_anim_w then menu_anim_w = target_ow end

    love.graphics.setColor(help_key_color)
    drawSelectionPill(menu_anim_x, menu_anim_y - 1 * scale, menu_anim_w, font_message:getHeight() + 2 * scale, 6 * scale)

    for i, opt in ipairs(options) do
        local oy = menu_start_y + (i - 1) * gap
        if i == selection then
            love.graphics.setColor(help_key_text)
        else
            love.graphics.setColor(ui_text)
        end
        love.graphics.setFont(font_message)
        love.graphics.print(opt, block_x, oy)
    end

    -- Draw footer bar for Settings Menu
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    if love.system.getOS() ~= "Web" then
        -- DPAD Navigate on the left
        local dpad_x = math.floor(20 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(ui_text)
        love.graphics.print("Navigate", dpad_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Right side actions: A (Select), B (Back), Y (Switch Theme)
        local right_x = w - math.floor(20 * scale)
        local actions = {
            {key = "A", label = "Select"},
            {key = "B", label = "Back"},
            {key = "Y", label = "Switch Theme"}
        }
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    -- Theme transition overlay
    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end

function renderer.drawMainMenu(selection, skip_transition)
    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    local options = renderer.getMainMenuOptions()
    love.graphics.setFont(font_message)
    local gap = (_G.text_size == "large" and 35 or 31) * scale
    local menu_h = (#options - 1) * gap + font_message:getHeight()
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)

    -- Dynamically space a beautiful theme-colored 2048 tile logo header
    local header_h = math.floor((_G.text_size == "large" and 100 or 120) * scale)

    local total_h = header_h + math.floor(8 * scale) + menu_h
    local available_h = badge_y - math.floor(10 * scale)
    local start_y = math.max(math.floor(12 * scale), math.floor((available_h - total_h) * 0.35))

    -- Draw beautifully stylized header
    local tile_size = math.floor(header_h - math.floor(10 * scale))
    if tile_size > 0 then
        local tile_x = math.floor((w - tile_size) / 2)
        local tile_y = math.floor(start_y + (header_h - tile_size) / 2)

        local canvas_w = math.ceil(tile_size * 2)
        local canvas_h = math.ceil(tile_size * 2)
        if not menu_logo_canvas or menu_logo_canvas:getWidth() < canvas_w or menu_logo_canvas:getHeight() < canvas_h then
            local new_w = menu_logo_canvas and math.max(menu_logo_canvas:getWidth(), canvas_w) or canvas_w
            local new_h = menu_logo_canvas and math.max(menu_logo_canvas:getHeight(), canvas_h) or canvas_h
            menu_logo_canvas = love.graphics.newCanvas(new_w, new_h)
            menu_logo_canvas:setFilter("linear", "linear")
        end
        if not menu_logo_quad then
            menu_logo_quad = love.graphics.newQuad(0, 0, canvas_w, canvas_h, menu_logo_canvas:getDimensions())
        else
            menu_logo_quad:setViewport(0, 0, canvas_w, canvas_h, menu_logo_canvas:getDimensions())
        end

        local old_canvas = love.graphics.getCanvas()
        love.graphics.setCanvas(menu_logo_canvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.push("all")
        love.graphics.scale(2, 2)
        love.graphics.translate(-tile_x, -tile_y)
        love.graphics.setLineWidth(math.max(2, math.floor((_G.scale or 1) * 2)))

        -- Draw tile background (using 2048 tile color from active theme!)
        love.graphics.setColor(getTileColor(2048))
        roundedRect("fill", tile_x, tile_y, tile_size, tile_size, tile_size * 0.12)

        -- Draw "2048" and "PLUS" text matching the new logo
        love.graphics.setColor(getTileTextColor(2048))
        local f_logo = font_main_menu_title or font_tile_large
        local f_plus = font_main_menu_plus or font_tile_small
        
        local tw = f_logo:getWidth("2048")
        local th = f_logo:getHeight()
        local pw = f_plus:getWidth("PLUS")
        local ph = f_plus:getHeight()

        local max_w = tile_size - math.floor(16 * scale)

        local logo_s = 1.0
        if tw > max_w then
            logo_s = max_w / tw
        end

        local tw_scaled = tw * logo_s
        local th_scaled = th * logo_s
        local pw_scaled = pw * logo_s
        local ph_scaled = ph * logo_s

        -- Center "2048" exactly in the box
        local x_2048 = tile_x + (tile_size - tw_scaled) / 2
        local y_2048 = tile_y + (tile_size - th_scaled) / 2

        love.graphics.setFont(f_logo)
        love.graphics.print("2048", x_2048, y_2048, 0, logo_s, logo_s)

        -- Position "PLUS" below "2048", with "P" horizontally aligned under the middle of "4"
        local x_plus = x_2048 + tw_scaled * 0.58
        local y_plus = y_2048 + th_scaled - math.floor(26 * scale * logo_s)

        love.graphics.setFont(f_plus)
        love.graphics.print("PLUS", x_plus, y_plus, 0, logo_s, logo_s)

        love.graphics.pop()
        if old_canvas then
            love.graphics.setCanvas({old_canvas, stencil = true})
        else
            love.graphics.setCanvas()
        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.draw(menu_logo_canvas, menu_logo_quad, tile_x, tile_y, 0, 0.5, 0.5)
        love.graphics.setBlendMode("alpha", "alphamultiply")
    end

    -- Menu options start position
    local menu_start_y = start_y + header_h + math.floor(8 * scale)

    local max_ow = 0
    for _, opt in ipairs(options) do
        local display_opt = opt
        if opt:find("^Select Theme:") then
            display_opt = "Select Theme: Cyberpunk"
        end
        local ow = font_message:getWidth(display_opt)
        if ow > max_ow then
            max_ow = ow
        end
    end
    local block_x = (w - max_ow) / 2

    local target_oy = menu_start_y + (selection - 1) * gap
    local sel_opt = options[selection]
    local display_sel_opt = sel_opt
    local sel_ow = font_message:getWidth(display_sel_opt)

    local target_ox = block_x - 12 * scale
    local target_ow = sel_ow + 24 * scale

    menu_anim_target_y = target_oy
    menu_anim_target_x = target_ox
    menu_anim_target_w = target_ow

    if not menu_anim_y then menu_anim_y = target_oy end
    if not menu_anim_x then menu_anim_x = target_ox end
    if not menu_anim_w then menu_anim_w = target_ow end

    love.graphics.setColor(help_key_color)
    drawSelectionPill(menu_anim_x, menu_anim_y - 1 * scale, menu_anim_w, font_message:getHeight() + 2 * scale, 6 * scale)

    for i, opt in ipairs(options) do
        local oy = menu_start_y + (i - 1) * gap
        if i == selection then
            love.graphics.setColor(help_key_text)
        else
            love.graphics.setColor(ui_text)
        end
        love.graphics.setFont(font_message)
        love.graphics.print(opt, block_x, oy)
    end

    -- Footer bar for Main Menu
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- DPAD on the left
    if love.system.getOS() ~= "Web" then
        local dpad_x = math.floor(20 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(ui_text)
        love.graphics.print("Navigate", dpad_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Right side actions: A (Select), Y (Theme)
        local right_x = w - math.floor(20 * scale)
        local actions = {
            {key = "A", label = "Select"},
            {key = "Y", label = "Switch Theme"}
        }
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    -- Text size toggle flash: brief full-screen white flash, fades out cleanly
    if text_size_flash_timer > 0 then
        local p = text_size_flash_timer / TEXT_SIZE_FLASH_DURATION  -- 1→0
        local alpha = p * p * 0.45  -- ease-out, max ~45% white overlay
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1, 1)
    end

    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end

-- ============================================================================
-- Arcade Menu
-- ============================================================================
-- Vector helper to draw an animated stopwatch
local function drawStopwatch(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    local t = love.timer.getTime()
    local r = 18 * scale

    love.graphics.push("all")
    love.graphics.setLineWidth(math.floor(2 * scale))

    local target_r = r_acc or 0.0
    local target_g = g_acc or 0.85
    local target_b = b_acc or 0.8
    local color_r = 0.45 + (target_r - 0.45) * select_factor
    local color_g = 0.5  + (target_g - 0.5)  * select_factor
    local color_b = 0.58 + (target_b - 0.58) * select_factor
    local alpha = 0.7 + 0.3 * select_factor

    love.graphics.setColor(color_r, color_g, color_b, alpha)

    -- Outer circle
    love.graphics.circle("line", cx, cy, r)

    -- Top crown
    love.graphics.rectangle("fill", cx - math.floor(3 * scale), cy - r - math.floor(4 * scale), math.floor(6 * scale), math.floor(3 * scale))
    -- Left button (rotated)
    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.rotate(-math.pi / 4)
    love.graphics.rectangle("fill", -math.floor(2 * scale), -r - math.floor(3 * scale), math.floor(4 * scale), math.floor(2 * scale))
    love.graphics.pop()

    -- Center pin
    love.graphics.circle("fill", cx, cy, math.floor(3 * scale))

    -- Clock hands
    -- Minute hand (pointing slightly offset)
    love.graphics.setLineWidth(math.floor(1.5 * scale))
    love.graphics.line(cx, cy, cx, cy - r + math.floor(6 * scale))

    -- Second hand (rotates full circle every 8 seconds when selected)
    local active_angle = -math.pi / 2 + (t % 8) * (2 * math.pi / 8)
    local angle = -math.pi / 2 + (active_angle - (-math.pi / 2)) * select_factor
    local hand_len = r - math.floor(4 * scale)
    love.graphics.setLineWidth(math.floor(1 * scale))

    local sh_target_r, sh_target_g, sh_target_b = 0.95, 0.15, 0.45
    if r_acc and r_acc > 0.8 and g_acc and g_acc < 0.3 then
        sh_target_r, sh_target_g, sh_target_b = 0.0, 0.85, 0.8
    end
    local sh_color_r = 0.45 + (sh_target_r - 0.45) * select_factor
    local sh_color_g = 0.5  + (sh_target_g - 0.5)  * select_factor
    local sh_color_b = 0.58 + (sh_target_b - 0.58) * select_factor
    local sh_alpha = 0.6 + 0.35 * select_factor
    love.graphics.setColor(sh_color_r, sh_color_g, sh_color_b, sh_alpha)

    love.graphics.line(cx, cy, cx + hand_len * math.cos(angle), cy + hand_len * math.sin(angle))

    love.graphics.pop()
end

-- Vector helper to draw a modern lock
local function drawLock(cx, cy, scale)
    local w = math.floor(24 * scale)
    local h = math.floor(18 * scale)
    local r = math.floor(7 * scale)

    love.graphics.push("all")
    love.graphics.setLineWidth(math.floor(2 * scale))
    love.graphics.setColor(0.35, 0.38, 0.45, 0.7)

    -- Lock shackle (top arch)
    love.graphics.arc("line", "open", cx, cy - h/2 + math.floor(3 * scale), r, math.pi, 2 * math.pi)
    love.graphics.line(cx - r, cy - h/2 + math.floor(3 * scale), cx - r, cy - h/2 + math.floor(6 * scale))
    love.graphics.line(cx + r, cy - h/2 + math.floor(3 * scale), cx + r, cy - h/2 + math.floor(6 * scale))

    -- Lock body
    love.graphics.rectangle("fill", cx - w/2, cy - h/2 + math.floor(5 * scale), w, h, math.floor(3 * scale))

    -- Keyhole
    love.graphics.setColor(0.08, 0.08, 0.12, 0.9)
    love.graphics.circle("fill", cx, cy + math.floor(2 * scale), math.floor(3 * scale))
    love.graphics.rectangle("fill", cx - math.floor(1 * scale), cy + math.floor(2 * scale), math.floor(2 * scale), math.floor(4 * scale))

    love.graphics.pop()
end

local function drawIconTile(cx, cy, r, step, grid_x, grid_y, val, scale, select_factor, r_acc, g_acc, b_acc, tile_scale)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0

    local tw = step - math.floor(2 * scale)
    local th = step - math.floor(2 * scale)
    if step > 8 * scale then
        tw = step - math.floor(4 * scale)
        th = step - math.floor(4 * scale)
    end

    local tx = cx - r + (grid_x - 1) * step + (step - tw) / 2
    local ty = cy - r + (grid_y - 1) * step + (step - th) / 2

    local alpha = 0.3
    local bright = 1.0
    if val == 2 then
        alpha = 0.25 + 0.25 * select_factor
    elseif val == 4 then
        alpha = 0.35 + 0.35 * select_factor
        bright = 1.0 + 0.2 * select_factor
    elseif val == 8 then
        alpha = 0.45 + 0.40 * select_factor
        bright = 1.0 + 0.4 * select_factor
    end

    love.graphics.push()
    love.graphics.translate(tx + tw/2, ty + th/2)
    love.graphics.scale(tile_scale or 1, tile_scale or 1)

    love.graphics.setColor(
        math.min(1.0, (r_acc or 0.5) * bright),
        math.min(1.0, (g_acc or 0.5) * bright),
        math.min(1.0, (b_acc or 0.5) * bright),
        alpha
    )
    roundedRect("fill", -tw/2, -th/2, tw, th, math.floor((step > 8 * scale and 2 or 1) * scale))
    love.graphics.pop()
end

-- Classic Mode icon
local function drawClassicIcon(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    local r = 14 * scale
    love.graphics.push("all")
    love.graphics.setLineWidth(math.floor(1.5 * scale))

    local r_base, g_base, b_base, a_base = 0.45, 0.5, 0.58, 0.7
    local r_target, g_target, b_target, a_target = r_acc or 0.1, g_acc or 0.75, b_acc or 0.45, 1.0
    love.graphics.setColor(
        r_base + (r_target - r_base) * select_factor,
        g_base + (g_target - g_base) * select_factor,
        b_base + (b_target - b_base) * select_factor,
        a_base + (a_target - a_base) * select_factor
    )

    -- Draw grid box
    love.graphics.rectangle("line", cx - r, cy - r, r * 2, r * 2, math.floor(3 * scale))

    -- Grid lines (4x4)
    local step = (r * 2) / 4
    for i = 1, 3 do
        love.graphics.line(cx - r + step * i, cy - r, cx - r + step * i, cy + r)
        love.graphics.line(cx - r, cy - r + step * i, cx + r, cy - r + step * i)
    end

    if is_selected then
        local t = love.timer.getTime()
        local time = t % 8
        local move_idx = math.floor(time / 2) + 1
        local move_t = time % 2

        -- Animation timings
        local slide_p = math.min(1.0, move_t / 0.3)
        local ease = 1 - math.pow(1 - slide_p, 3) -- Snappy cubic ease-out

        local pop_p = 0
        if move_t >= 0.3 and move_t < 0.6 then
            pop_p = math.sin((move_t - 0.3) / 0.3 * math.pi)
        end
        local pulse = 1.0 + 0.3 * pop_p

        local spawn_scale = 0
        if move_t >= 0.3 then
            spawn_scale = math.min(1.0, (move_t - 0.3) / 0.3)
            if spawn_scale < 1.0 then
                spawn_scale = spawn_scale + 0.2 * math.sin(spawn_scale * math.pi)
            end
        end

        if move_idx == 1 then
            -- Slide Right: (2,2)->(4,2), (3,2)->(4,2). Merge to 4.
            -- Spawn: 2 at (1,1)
            local ax, ay = 2 + ease * 2, 2
            local bx, by = 3 + ease * 1, 2

            drawIconTile(cx, cy, r, step, 4, 3, 4, scale, select_factor, r_acc, g_acc, b_acc)

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, ax, ay, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 2, scale, select_factor, r_acc, g_acc, b_acc)
            else
                drawIconTile(cx, cy, r, step, 4, 2, 4, scale, select_factor, r_acc, g_acc, b_acc, pulse)
            end

            if move_t >= 0.3 then
                drawIconTile(cx, cy, r, step, 1, 1, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
            end

        elseif move_idx == 2 then
            -- Slide Down: (4,2)->(4,4), (4,3)->(4,4). Merge to 8.
            -- Spawn: 2 at (2,1)
            local ax, ay = 4, 2 + ease * 2
            local bx, by = 4, 3 + ease * 1

            drawIconTile(cx, cy, r, step, 1, 1, 2, scale, select_factor, r_acc, g_acc, b_acc)

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, ax, ay, 4, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 4, scale, select_factor, r_acc, g_acc, b_acc)
            else
                drawIconTile(cx, cy, r, step, 4, 4, 8, scale, select_factor, r_acc, g_acc, b_acc, pulse)
            end

            if move_t >= 0.3 then
                drawIconTile(cx, cy, r, step, 2, 1, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
            end

        elseif move_idx == 3 then
            -- Slide Left: 8 at (4,4)->(1,4). 2 at (1,1)->(1,1). 2 at (2,1)->(1,1).
            local ax, ay = 4 - ease * 3, 4
            local bx, by = 1, 1
            local cx_tile, cy_tile = 2 - ease * 1, 1

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, ax, ay, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, cx_tile, cy_tile, 2, scale, select_factor, r_acc, g_acc, b_acc)
            else
                drawIconTile(cx, cy, r, step, 1, 4, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 1, 1, 4, scale, select_factor, r_acc, g_acc, b_acc, pulse)
            end

            if move_t >= 0.3 then
                drawIconTile(cx, cy, r, step, 4, 1, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
            end

        elseif move_idx == 4 then
            -- Slide Up: 8 at (1,4)->(1,2). 4 at (1,1) stays. 2 at (4,1) stays.
            local ax, ay = 1, 4 - ease * 2

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, 1, 1, 4, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, ax, ay, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 4, 1, 2, scale, select_factor, r_acc, g_acc, b_acc)
            else
                local bump = 0
                if move_t < 0.5 then
                    bump = math.sin((move_t - 0.3) / 0.2 * math.pi) * 0.1
                end
                drawIconTile(cx, cy, r, step, 1, 1 - bump, 4, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 1, 2 - bump, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 4, 1, 2, scale, select_factor, r_acc, g_acc, b_acc)
            end

            if move_t >= 0.3 then
                drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
            end
        end
    else
        -- Draw static grid tiles when unselected
        drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
        drawIconTile(cx, cy, r, step, 3, 3, 4, scale, select_factor, r_acc, g_acc, b_acc)
    end

    love.graphics.pop()
end

local function drawPlusIcon(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    local r = 14 * scale
    love.graphics.push("all")
    love.graphics.setLineWidth(math.floor(1.5 * scale))

    local r_base, g_base, b_base, a_base = 0.45, 0.5, 0.58, 0.7
    local r_target, g_target, b_target, a_target = r_acc or 0.95, g_acc or 0.60, b_acc or 0.10, 1.0
    love.graphics.setColor(
        r_base + (r_target - r_base) * select_factor,
        g_base + (g_target - g_base) * select_factor,
        b_base + (b_target - b_base) * select_factor,
        a_base + (a_target - a_base) * select_factor
    )

    -- Draw grid box
    love.graphics.rectangle("line", cx - r, cy - r, r * 2, r * 2, math.floor(3 * scale))

    -- Grid lines (4x4)
    local step = (r * 2) / 4
    for i = 1, 3 do
        love.graphics.line(cx - r + step * i, cy - r, cx - r + step * i, cy + r)
        love.graphics.line(cx - r, cy - r + step * i, cx + r, cy - r + step * i)
    end

    if is_selected then
        local t = love.timer.getTime()
        local time = t % 8
        local move_idx = math.floor(time / 2) + 1
        local move_t = time % 2

        local slide_p = math.min(1.0, move_t / 0.3)
        local ease = 1 - math.pow(1 - slide_p, 3)

        local spawn_scale = 0
        if move_t >= 0.3 then
            spawn_scale = math.min(1.0, (move_t - 0.3) / 0.3)
            if spawn_scale < 1.0 then
                spawn_scale = spawn_scale + 0.2 * math.sin(spawn_scale * math.pi)
            end
        end

        if move_idx == 1 then
            local ax, ay = 2 + ease * 1, 2
            local bx, by = 3 + ease * 1, 2

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, ax, ay, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 4, scale, select_factor, r_acc, g_acc, b_acc)
            else
                drawIconTile(cx, cy, r, step, 3, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 4, 2, 4, scale, select_factor, r_acc, g_acc, b_acc)
            end
            if move_t >= 0.3 then
                drawIconTile(cx, cy, r, step, 1, 1, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
            end

        elseif move_idx == 2 then
            local r_ease = 1 - ease
            local ax, ay = 2 + r_ease * 1, 2
            local bx, by = 3 + r_ease * 1, 2
            local shrink_scale = 1.0 - math.min(1.0, move_t / 0.3)

            if move_t < 0.3 then
                drawIconTile(cx, cy, r, step, ax, ay, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 4, scale, select_factor, r_acc, g_acc, b_acc)
                if shrink_scale > 0 then
                    drawIconTile(cx, cy, r, step, 1, 1, 2, scale, select_factor, r_acc, g_acc, b_acc, shrink_scale)
                end
            else
                drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 3, 2, 4, scale, select_factor, r_acc, g_acc, b_acc)
            end

            local arrow_alpha = math.max(0, 1.0 - move_t / 1.5)
            love.graphics.setColor(1.0, 0.7, 0.2, arrow_alpha * 0.8)
            love.graphics.setLineWidth(math.floor(2 * scale))
            love.graphics.arc("line", "open", cx, cy, 6 * scale, -math.pi * 0.5, math.pi * 0.8)
            love.graphics.polygon("fill", cx - 6 * scale, cy - 3 * scale, cx - 9 * scale, cy + 2 * scale, cx - 3 * scale, cy + 1 * scale)

        elseif move_idx == 3 then
            drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)

            if move_t < 0.4 then
                drawIconTile(cx, cy, r, step, 3, 2, 4, scale, select_factor, r_acc, g_acc, b_acc)

                local cross_p = move_t / 0.4
                local cross_size = (1.5 - 0.5 * cross_p) * step
                local tx = cx - r + 2 * step + step / 2
                local ty = cy - r + 1 * step + step / 2

                love.graphics.setColor(1.0, 0.2, 0.2, 0.8)
                love.graphics.setLineWidth(math.floor(1.5 * scale))
                love.graphics.circle("line", tx, ty, cross_size / 2)
                love.graphics.line(tx - cross_size/2, ty, tx + cross_size/2, ty)
                love.graphics.line(tx, ty - cross_size/2, tx, ty + cross_size/2)
            elseif move_t < 0.7 then
                local expl_p = (move_t - 0.4) / 0.3
                local expl_scale = 1.0 + expl_p * 1.0
                local expl_alpha = 1.0 - expl_p
                love.graphics.push("all")
                love.graphics.setColor(1.0, 0.5, 0.0, expl_alpha)
                local tx = cx - r + 2 * step + step / 2
                local ty = cy - r + 1 * step + step / 2
                love.graphics.circle("fill", tx, ty, step * expl_scale * 0.6)
                love.graphics.pop()
            end

            if move_t >= 0.8 then
                local bomb_spawn_scale = math.min(1.0, (move_t - 0.8) / 0.3)
                drawIconTile(cx, cy, r, step, 1, 4, 4, scale, select_factor, r_acc, g_acc, b_acc, bomb_spawn_scale)
            end

        elseif move_idx == 4 then
            local pos1_x, pos1_y = 2, 2
            local pos2_x, pos2_y = 1, 4

            if move_t < 0.4 then
                local shake_x = math.sin(move_t * 50) * 0.1
                local shake_y = math.cos(move_t * 60) * 0.1
                drawIconTile(cx, cy, r, step, pos1_x + shake_x, pos1_y + shake_y, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, pos2_x - shake_y, pos2_y + shake_x, 4, scale, select_factor, r_acc, g_acc, b_acc)

                love.graphics.setColor(1.0, 0.8, 0.2, 0.6)
                love.graphics.circle("fill", cx, cy, 6 * scale * math.sin(move_t * math.pi / 0.4))
            else
                drawIconTile(cx, cy, r, step, pos2_x, pos2_y, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, pos1_x, pos1_y, 4, scale, select_factor, r_acc, g_acc, b_acc)
            end
        end
    else
        -- Draw static grid tiles when unselected
        drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
        drawIconTile(cx, cy, r, step, 3, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)

        -- Simple central "+" sign
        love.graphics.setLineWidth(math.floor(2 * scale))
        love.graphics.setColor(0.45, 0.5, 0.58, 0.7)
        local plen = 5 * scale
        love.graphics.line(cx - plen, cy, cx + plen, cy)
        love.graphics.line(cx, cy - plen, cx, cy + plen)
    end

    love.graphics.pop()
end

-- Arcade Mode icon
local function drawArcadeIcon(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    love.graphics.push("all")
    local t = love.timer.getTime()

    -- Tilted stick animation when selected
    local tilt_angle = 0
    if is_selected then
        tilt_angle = 0.25 * math.sin(t * 8) * select_factor
    end

    -- Joystick Base (drawn with rounded rectangle outline and filled body)
    local rb_base, gb_base, bb_base, ab_base = 0.3, 0.35, 0.4, 0.6
    local rb_target, gb_target, bb_target, ab_target = 0.4, 0.45, 0.55, 0.85
    love.graphics.setColor(
        rb_base + (rb_target - rb_base) * select_factor,
        gb_base + (gb_target - gb_base) * select_factor,
        bb_base + (bb_target - bb_base) * select_factor,
        ab_base + (ab_target - ab_base) * select_factor
    )
    love.graphics.setLineWidth(math.floor(2 * scale))
    love.graphics.rectangle("line", cx - 18 * scale, cy + 6 * scale, 36 * scale, 10 * scale, 4 * scale)
    love.graphics.rectangle("fill", cx - 14 * scale, cy + 8 * scale, 28 * scale, 6 * scale, 2 * scale)

    -- Stick shaft
    love.graphics.push()
    love.graphics.translate(cx, cy + 6 * scale)
    love.graphics.rotate(tilt_angle)

    local rs_base, gs_base, bs_base, as_base = 0.55, 0.58, 0.62, 0.7
    local rs_target, gs_target, bs_target, as_target = 0.88, 0.92, 0.95, 1.0
    love.graphics.setColor(
        rs_base + (rs_target - rs_base) * select_factor,
        gs_base + (gs_target - gs_base) * select_factor,
        bs_base + (bs_target - bs_base) * select_factor,
        as_base + (as_target - as_base) * select_factor
    )
    love.graphics.setLineWidth(math.floor(3.5 * scale))
    love.graphics.line(0, 0, 0, -18 * scale)

    -- Ball top knob
    local rk_base, gk_base, bk_base, ak_base = 0.45, 0.5, 0.58, 0.7
    local rk_target, gk_target, bk_target, ak_target = r_acc or 0.90, g_acc or 0.15, b_acc or 0.55, 1.0
    love.graphics.setColor(
        rk_base + (rk_target - rk_base) * select_factor,
        gk_base + (gk_target - gk_base) * select_factor,
        bk_base + (bk_target - bk_base) * select_factor,
        ak_base + (ak_target - ak_base) * select_factor
    )
    love.graphics.circle("fill", 0, -18 * scale, 7 * scale)

    -- Pulsing highlight shine
    if is_selected then
        local pulse = 0.65 + 0.35 * math.sin(t * 10)
        love.graphics.setColor(1, 1, 1, pulse * select_factor)
        love.graphics.setLineWidth(math.floor(1 * scale))
        love.graphics.circle("line", 0, -18 * scale, 7 * scale)
    end

    love.graphics.pop()
    love.graphics.pop()
end

local function drawHugeGrid(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    local r = 14 * scale
    love.graphics.push("all")
    love.graphics.setLineWidth(math.floor(1.5 * scale))

    local r_base, g_base, b_base, a_base = 0.45, 0.5, 0.58, 0.7
    local r_target, g_target, b_target, a_target = r_acc or 0.58, g_acc or 0.25, b_acc or 0.95, 1.0
    love.graphics.setColor(
        r_base + (r_target - r_base) * select_factor,
        g_base + (g_target - g_base) * select_factor,
        b_base + (b_target - b_base) * select_factor,
        a_base + (a_target - a_base) * select_factor
    )

    -- Outer box
    love.graphics.rectangle("line", cx - r, cy - r, r * 2, r * 2, math.floor(3 * scale))

    -- Grid lines (5x5)
    local step = (r * 2) / 5
    for i = 1, 4 do
        love.graphics.line(cx - r + step * i, cy - r, cx - r + step * i, cy + r)
        love.graphics.line(cx - r, cy - r + step * i, cx + r, cy - r + step * i)
    end

    if is_selected then
        local t = love.timer.getTime()
        local time = (t + 0.5) % 6
        local move_idx = math.floor(time / 2) + 1
        local move_t = time % 2

        local p = math.min(1.0, move_t / 0.4)
        local ease = p * p * (3 - 2 * p)

        if move_idx == 1 then
            local ax, ay = 2 + ease * 3, 2
            local bx, by = 3 + ease * 2, 2
            local cx_tile, cy_tile = 4 + ease * 1, 4

            if move_t < 0.4 then
                drawIconTile(cx, cy, r, step, ax, ay, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, bx, by, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, cx_tile, cy_tile, 4, scale, select_factor, r_acc, g_acc, b_acc)
            else
                local pulse = 1.0
                if move_t < 0.8 then
                    pulse = 1.0 + 0.25 * math.sin((move_t - 0.4) * math.pi / 0.4)
                end
                drawIconTile(cx, cy, r, step, 5, 2, 4, scale, select_factor, r_acc, g_acc, b_acc, pulse)
                drawIconTile(cx, cy, r, step, 5, 4, 4, scale, select_factor, r_acc, g_acc, b_acc)

                if move_t >= 0.6 then
                    local spawn_scale = math.min(1.0, (move_t - 0.6) / 0.4)
                    drawIconTile(cx, cy, r, step, 2, 3, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
                end
            end

        elseif move_idx == 2 then
            local abx, aby = 5, 2 + ease * 3
            local cx_tile, cy_tile = 5, 4 + ease * 1
            local dx, dy = 2, 3 + ease * 2

            if move_t < 0.4 then
                drawIconTile(cx, cy, r, step, abx, aby, 4, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, cx_tile, cy_tile, 4, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, dx, dy, 2, scale, select_factor, r_acc, g_acc, b_acc)
            else
                local pulse = 1.0
                if move_t < 0.8 then
                    pulse = 1.0 + 0.25 * math.sin((move_t - 0.4) * math.pi / 0.4)
                end
                drawIconTile(cx, cy, r, step, 5, 5, 8, scale, select_factor, r_acc, g_acc, b_acc, pulse)
                drawIconTile(cx, cy, r, step, 2, 5, 2, scale, select_factor, r_acc, g_acc, b_acc)

                if move_t >= 0.6 then
                    local spawn_scale = math.min(1.0, (move_t - 0.6) / 0.4)
                    drawIconTile(cx, cy, r, step, 4, 2, 4, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
                end
            end

        elseif move_idx == 3 then
            local dx, dy = 2 - ease * 1, 5
            local abcx, abcy = 5 - ease * 3, 5
            local ex, ey = 4 - ease * 3, 2

            if move_t < 0.4 then
                drawIconTile(cx, cy, r, step, abcx, abcy, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 2, 5, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, ex, ey, 4, scale, select_factor, r_acc, g_acc, b_acc)
            else
                drawIconTile(cx, cy, r, step, 1, 5, 2, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 2, 5, 8, scale, select_factor, r_acc, g_acc, b_acc)
                drawIconTile(cx, cy, r, step, 1, 2, 4, scale, select_factor, r_acc, g_acc, b_acc)

                if move_t >= 0.6 then
                    local spawn_scale = math.min(1.0, (move_t - 0.6) / 0.4)
                    drawIconTile(cx, cy, r, step, 3, 3, 2, scale, select_factor, r_acc, g_acc, b_acc, spawn_scale)
                end
            end
        end
    else
        drawIconTile(cx, cy, r, step, 2, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
        drawIconTile(cx, cy, r, step, 3, 2, 2, scale, select_factor, r_acc, g_acc, b_acc)
        drawIconTile(cx, cy, r, step, 4, 4, 4, scale, select_factor, r_acc, g_acc, b_acc)
    end

    love.graphics.pop()
end

local function drawSkull(cx, cy, scale, select_factor, r_acc, g_acc, b_acc)
    if type(select_factor) == "boolean" then
        select_factor = select_factor and 1.0 or 0.0
    end
    select_factor = select_factor or 0.0
    local is_selected = select_factor > 0.5

    love.graphics.push("all")

    local r_base, g_base, b_base, a_base = 0.45, 0.5, 0.58, 0.7
    local r_target, g_target, b_target, a_target = r_acc or 0.85, g_acc or 0.10, b_acc or 0.10, 1.0
    local color_r = r_base + (r_target - r_base) * select_factor
    local color_g = g_base + (g_target - g_base) * select_factor
    local color_b = b_base + (b_target - b_base) * select_factor
    local alpha = a_base + (a_target - a_base) * select_factor

    love.graphics.setColor(color_r, color_g, color_b, alpha)
    love.graphics.setLineWidth(math.floor(1.5 * scale))

    -- Ambient float animation for selection
    local float_y = 0
    if is_selected then
        float_y = math.sin(love.timer.getTime() * 4) * 2 * scale * select_factor
    end
    cy = cy + float_y

    -- Draw crossbones underneath
    love.graphics.setLineWidth(math.floor(2 * scale))
    -- Bone 1: Top-Left to Bottom-Right
    love.graphics.line(cx - 10 * scale, cy - 10 * scale, cx + 10 * scale, cy + 10 * scale)
    love.graphics.circle("fill", cx - 10 * scale, cy - 9 * scale, 2 * scale)
    love.graphics.circle("fill", cx - 9 * scale, cy - 10 * scale, 2 * scale)
    love.graphics.circle("fill", cx + 10 * scale, cy + 9 * scale, 2 * scale)
    love.graphics.circle("fill", cx + 9 * scale, cy + 10 * scale, 2 * scale)

    -- Bone 2: Top-Right to Bottom-Left
    love.graphics.line(cx + 10 * scale, cy - 10 * scale, cx - 10 * scale, cy + 10 * scale)
    love.graphics.circle("fill", cx + 10 * scale, cy - 9 * scale, 2 * scale)
    love.graphics.circle("fill", cx + 9 * scale, cy - 10 * scale, 2 * scale)
    love.graphics.circle("fill", cx - 10 * scale, cy + 9 * scale, 2 * scale)
    love.graphics.circle("fill", cx - 9 * scale, cy + 10 * scale, 2 * scale)

    -- Skull main head (drawn on top to cover crossbones intersection)
    love.graphics.setColor(0.04, 0.04, 0.08, 1.0) -- background color to mask
    love.graphics.circle("fill", cx, cy - 2 * scale, 7 * scale)
    love.graphics.rectangle("fill", cx - 4 * scale, cy + 2 * scale, 8 * scale, 4 * scale)

    love.graphics.setColor(color_r, color_g, color_b, alpha)
    love.graphics.setLineWidth(math.floor(1.5 * scale))
    love.graphics.circle("line", cx, cy - 2 * scale, 7 * scale)

    -- Skull jaw outline
    roundedRect("line", cx - 3 * scale, cy + 3 * scale, 6 * scale, 5 * scale, 1.5 * scale)

    -- Eyes
    love.graphics.setColor(color_r, color_g, color_b, alpha)
    love.graphics.circle("fill", cx - 2.5 * scale, cy - 2 * scale, 1.8 * scale)
    love.graphics.circle("fill", cx + 2.5 * scale, cy - 2 * scale, 1.8 * scale)

    -- Nose (triangle)
    love.graphics.polygon("fill",
        cx, cy + 1 * scale,
        cx - 1.2 * scale, cy + 2.5 * scale,
        cx + 1.2 * scale, cy + 2.5 * scale
    )

    -- Teeth lines
    love.graphics.line(cx - 1.2 * scale, cy + 5 * scale, cx - 1.2 * scale, cy + 7.5 * scale)
    love.graphics.line(cx, cy + 5 * scale, cx, cy + 7.5 * scale)
    love.graphics.line(cx + 1.2 * scale, cy + 5 * scale, cx + 1.2 * scale, cy + 7.5 * scale)

    love.graphics.pop()
end

function renderer.drawPlaySelectMenu(play_select_selection, arcade_selection, skip_transition, current_menu_selection)
    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    -- 1. Draw the main menu underneath (dimmed)
    renderer.drawMainMenu(current_menu_selection or 1, true)

    -- 2. Dim overlay
    if arcade_menu_bg_alpha > 0 then
        love.graphics.setColor(0, 0, 0, arcade_menu_bg_alpha)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    -- 3. Panel geometry
    local panel_pad_x = math.floor(16 * scale)
    local panel_pad_y = math.floor(16 * scale)
    local card_gap    = math.floor(12 * scale)
    local card_h_arc  = math.floor((_G.text_size == "large" and 124 or 120) * scale)
    local num_rows    = 2
    local header_h    = math.floor(74 * scale)
    local footer_h    = math.floor(44 * scale)
    local panel_h     = header_h + panel_pad_y + num_rows * card_h_arc + (num_rows - 1) * card_gap + panel_pad_y + footer_h

    local panel_x = math.floor(panel_pad_x)
    local panel_w = w - panel_pad_x * 2

    -- 4. Animate sliding up from bottom
    local raw_offset = arcade_panel_y_offset
    if raw_offset > panel_h then raw_offset = panel_h end
    local panel_y_base = h - panel_h
    local panel_y = panel_y_base + raw_offset

    -- 5. Ambient floating light blobs inside the panel
    local t = love.timer.getTime()
    local alpha_mult = 1 - raw_offset / panel_h

    -- Glassy panel background
    love.graphics.setColor(0.04, 0.04, 0.08, 0.95)
    roundedRect("fill", panel_x, panel_y, panel_w, panel_h, math.floor(18 * scale))

    -- Draw aurora blobs
    love.graphics.push("all")
    love.graphics.setScissor(panel_x, panel_y, panel_w, panel_h)
    local b1x = panel_x + panel_w * 0.25 + math.sin(t * 0.6) * 50 * scale
    local b1y = panel_y + panel_h * 0.35 + math.cos(t * 0.5) * 30 * scale
    love.graphics.setColor(0.0, 0.78, 0.73, 0.12 * alpha_mult)
    love.graphics.circle("fill", b1x, b1y, 110 * scale)

    local b2x = panel_x + panel_w * 0.75 + math.cos(t * 0.7) * 60 * scale
    local b2y = panel_y + panel_h * 0.45 + math.sin(t * 0.8) * 25 * scale
    love.graphics.setColor(0.55, 0.20, 0.90, 0.10 * alpha_mult)
    love.graphics.circle("fill", b2x, b2y, 120 * scale)

    local b3x = panel_x + panel_w * 0.5 + math.sin(t * 0.4) * 70 * scale
    local b3y = panel_y + panel_h * 0.7 + math.sin(t * 0.7) * 35 * scale
    love.graphics.setColor(0.90, 0.05, 0.55, 0.08 * alpha_mult)
    love.graphics.circle("fill", b3x, b3y, 90 * scale)
    love.graphics.setScissor()
    love.graphics.pop()

    -- Glassy border highlight
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.setLineWidth(math.floor(1.5 * scale))
    roundedRect("line", panel_x, panel_y, panel_w, panel_h, math.floor(18 * scale))

    -- Footer badge dimensions defined globally for both pages
    local badge_h_foot = math.floor(28 * scale)
    local badge_y_foot = panel_y + panel_h - badge_h_foot - math.floor(8 * scale)

    -- 6. Horizontal sliding viewports using Scissor & Translate
    love.graphics.push("all")
    love.graphics.setScissor(panel_x, panel_y, panel_w, panel_h)

    local page_shift = (panel_w + math.floor(24 * scale)) * panel_page_current

    -- === DRAW PAGE 0: PLAY SELECTION ===
    love.graphics.push()
    love.graphics.translate(-page_shift, 0)

    -- Page 0 Header
    local header_y = panel_y + panel_pad_y
    love.graphics.setFont(font_title)
    local title0 = "Select Game Mode"
    local tw0 = font_title:getWidth(title0)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(title0, panel_x + (panel_w - tw0) / 2 + 1, header_y + 1)
    love.graphics.setColor(0.0, 0.9, 0.85, 1.0)
    love.graphics.print(title0, panel_x + (panel_w - tw0) / 2, header_y)



    -- Cards
    local cards_top = header_y + header_h
    local card_cr = math.floor(12 * scale)
    local card_w0 = math.floor((panel_w - math.floor(32 * scale) - 2 * card_gap) / 3)
    local card_h0 = math.floor((_G.text_size == "large" and 260 or 252) * scale)

    local play_modes = {
        {
            name      = "Classic Mode",
            desc      = "Standard rules. Strategic puzzle play.",
            icon      = "classic",
            bestScore = save.loadHighScore("classic"),
            accentR = 0.10, accentG = 0.75, accentB = 0.45,
        },
        {
            name      = "Plus Mode",
            desc      = "Adds powerups: Undo, Shuffle, and Block Cleanup.",
            icon      = "plus",
            bestScore = save.loadHighScore("plus"),
            accentR = 0.95, accentG = 0.60, accentB = 0.10,
        },
        {
            name      = "Arcade Mode",
            desc      = "Time Attack, 5x5, Goose, and No Mercy.",
            icon      = "arcade",
            bestScore = 0,
            accentR = 0.90, accentG = 0.15, accentB = 0.55,
        }
    }

    -- Loop 1: Draw unselected card backgrounds
    for i, pm in ipairs(play_modes) do
        local cx_pos = panel_x + math.floor(16 * scale) + (i - 1) * (card_w0 + card_gap)
        local cy = cards_top

        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (i - 1) * 0.05)
        local card_scale = 0.92 + slide_t * 0.08

        love.graphics.push()
        love.graphics.translate(cx_pos + card_w0 / 2, cy + card_h0 / 2)
        love.graphics.scale(card_scale, card_scale)
        love.graphics.translate(-(cx_pos + card_w0 / 2), -(cy + card_h0 / 2))

        love.graphics.setColor(0.08, 0.08, 0.12, 0.6)
        roundedRect("fill", cx_pos, cy, card_w0, card_h0, card_cr)
        love.graphics.setColor(0.2, 0.22, 0.28, 0.35)
        love.graphics.setLineWidth(math.floor(1 * scale))
        roundedRect("line", cx_pos, cy, card_w0, card_h0, card_cr)

        love.graphics.pop()
    end

    -- Phase 2: Draw the single sliding selection highlight box
    do
        local active_idx = play_select_selection or 1
        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (active_idx - 1) * 0.05)
        local hl_scale = 0.92 + slide_t * 0.08

        local sel_val = play_select_sel_current or play_select_selection or 1
        local hl_x = panel_x + math.floor(16 * scale) + (sel_val - 1) * (card_w0 + card_gap)
        local hl_y = cards_top

        love.graphics.push()
        love.graphics.translate(hl_x + card_w0 / 2, hl_y + card_h0 / 2)
        love.graphics.scale(hl_scale, hl_scale)
        love.graphics.translate(-(hl_x + card_w0 / 2), -(hl_y + card_h0 / 2))

        -- Active selection background fill
        love.graphics.setColor(0.04, 0.12, 0.16, 0.85)
        roundedRect("fill", hl_x, hl_y, card_w0, card_h0, card_cr)

        -- Active border with color morphing
        local r_hl, g_hl, b_hl
        if sel_val <= 1 then
            r_hl, g_hl, b_hl = play_modes[1].accentR, play_modes[1].accentG, play_modes[1].accentB
        elseif sel_val >= 3 then
            r_hl, g_hl, b_hl = play_modes[3].accentR, play_modes[3].accentG, play_modes[3].accentB
        elseif sel_val < 2 then
            local f = sel_val - 1
            r_hl = play_modes[1].accentR + (play_modes[2].accentR - play_modes[1].accentR) * f
            g_hl = play_modes[1].accentG + (play_modes[2].accentG - play_modes[1].accentG) * f
            b_hl = play_modes[1].accentB + (play_modes[2].accentB - play_modes[1].accentB) * f
        else
            local f = sel_val - 2
            r_hl = play_modes[2].accentR + (play_modes[3].accentR - play_modes[2].accentR) * f
            g_hl = play_modes[2].accentG + (play_modes[3].accentG - play_modes[2].accentG) * f
            b_hl = play_modes[2].accentB + (play_modes[3].accentB - play_modes[2].accentB) * f
        end

        local pulse = 0.65 + 0.25 * math.sin(t * 5)
        love.graphics.setLineWidth(math.floor(2 * scale))
        love.graphics.setColor(r_hl, g_hl, b_hl, pulse)
        roundedRect("line", hl_x, hl_y, card_w0, card_h0, card_cr)

        love.graphics.pop()
    end

    -- Loop 2: Draw card contents
    for i, pm in ipairs(play_modes) do
        local cx_pos = panel_x + math.floor(16 * scale) + (i - 1) * (card_w0 + card_gap)
        local cy = cards_top
        local sel_val = play_select_sel_current or play_select_selection or 1
        local select_factor = math.max(0, 1 - math.abs(i - sel_val))

        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (i - 1) * 0.05)
        local card_scale = 0.92 + slide_t * 0.08

        love.graphics.push()
        love.graphics.translate(cx_pos + card_w0 / 2, cy + card_h0 / 2)
        love.graphics.scale(card_scale, card_scale)
        love.graphics.translate(-(cx_pos + card_w0 / 2), -(cy + card_h0 / 2))

        local icon_cx = cx_pos + card_w0 / 2
        local icon_cy = cy + math.floor(42 * scale)
        if pm.icon == "classic" then
            drawClassicIcon(icon_cx, icon_cy, scale, select_factor, pm.accentR, pm.accentG, pm.accentB)
        elseif pm.icon == "plus" then
            drawPlusIcon(icon_cx, icon_cy, scale, select_factor, pm.accentR, pm.accentG, pm.accentB)
        elseif pm.icon == "arcade" then
            drawArcadeIcon(icon_cx, icon_cy, scale, select_factor, pm.accentR, pm.accentG, pm.accentB)
        end

        love.graphics.setFont(font_score)
        local name_r = 0.9 + (pm.accentR - 0.9) * select_factor
        local name_g = 0.92 + (pm.accentG - 0.92) * select_factor
        local name_b = 0.95 + (pm.accentB - 0.95) * select_factor
        love.graphics.setColor(name_r, name_g, name_b, 1.0)

        local tw_lbl = font_score:getWidth(pm.name)
        love.graphics.print(pm.name, cx_pos + (card_w0 - tw_lbl) / 2, cy + math.floor(76 * scale))

        local badge_y = cy + math.floor(76 * scale) + font_score:getHeight() + math.floor(4 * scale)
        local has_badge = false
        local badge_text = ""

        if pm.icon ~= "arcade" then
            local best = pm.bestScore or 0
            if best > 0 then
                has_badge = true
                badge_text = "BEST: " .. tostring(best)
            end
        else
            has_badge = true
            badge_text = "4 Modes Available"
        end

        local badge_h = 0
        if has_badge then
            love.graphics.setFont(font_help_label)
            local btw = font_help_label:getWidth(badge_text)
            local bth = font_help_label:getHeight()
            local badge_w = btw + math.floor(8 * scale)
            badge_h = bth + math.floor(3 * scale)
            local bx = cx_pos + (card_w0 - badge_w) / 2

            local bg_r = 0.12 + (pm.accentR * 0.15 - 0.12) * select_factor
            local bg_g = 0.12 + (pm.accentG * 0.15 - 0.12) * select_factor
            local bg_b = 0.18 + (pm.accentB * 0.15 - 0.18) * select_factor
            love.graphics.setColor(bg_r, bg_g, bg_b, 0.4)
            roundedRect("fill", bx, badge_y, badge_w, badge_h, math.floor(6 * scale))

            local ln_r = 0.3 + (pm.accentR - 0.3) * select_factor
            local ln_g = 0.32 + (pm.accentG - 0.32) * select_factor
            local ln_b = 0.38 + (pm.accentB - 0.38) * select_factor
            local ln_a = 0.4 + 0.05 * select_factor
            love.graphics.setColor(ln_r, ln_g, ln_b, ln_a)
            roundedRect("line", bx, badge_y, badge_w, badge_h, math.floor(6 * scale))

            local tx_r = 0.7 + (pm.accentR - 0.7) * select_factor
            local tx_g = 0.72 + (pm.accentG - 0.72) * select_factor
            local tx_b = 0.78 + (pm.accentB - 0.78) * select_factor
            local tx_a = 0.9 + 0.05 * select_factor
            love.graphics.setColor(tx_r, tx_g, tx_b, tx_a)

            love.graphics.print(badge_text, bx + math.floor(4 * scale), badge_y + math.floor(1.5 * scale))
        end

        local desc_y
        if has_badge then
            desc_y = badge_y + badge_h + math.floor(8 * scale)
        else
            desc_y = badge_y + math.floor(4 * scale)
        end

        love.graphics.setFont(font_help_label)
        love.graphics.setColor(0.65, 0.68, 0.75, 1.0)
        love.graphics.printf(pm.desc, cx_pos + math.floor(10 * scale), desc_y, card_w0 - math.floor(20 * scale), "center")

        love.graphics.pop()
    end

    -- Page 0 Footer
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- Left side DPAD badge
    if love.system.getOS() ~= "Web" then
        local dpad_x = panel_x + math.floor(12 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y_foot + (badge_h_foot - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(0.7, 0.75, 0.8, 1.0)
        love.graphics.print("Navigate", dpad_x, badge_y_foot + (badge_h_foot - font_help_label:getHeight()) / 2)

        -- Right side Select + Back badges
        local right_x0 = panel_x + panel_w - math.floor(12 * scale)
        local footer_actions = {
            {key = "A", label = "Select"},
            {key = "B", label = "Back"},
        }
        for _, action in ipairs(footer_actions) do
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x0 = right_x0 - lbl_w
            love.graphics.setColor(0.7, 0.75, 0.8, 1.0)
            love.graphics.print(action.label, right_x0, badge_y_foot + (badge_h_foot - font_help_label:getHeight()) / 2)
            right_x0 = right_x0 - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x0 = right_x0 - key_w
            drawKeyBadge(action.key, right_x0, badge_y_foot, key_w, badge_h_foot)
            right_x0 = right_x0 - item_gap
        end
    end

    love.graphics.pop()

    -- === DRAW PAGE 1: ARCADE MODES ===
    love.graphics.push()
    love.graphics.translate(panel_w + math.floor(24 * scale) - page_shift, 0)

    -- Page 1 Header
    love.graphics.setFont(font_title)
    local title1 = "Arcade Modes"
    local tw1 = font_title:getWidth(title1)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(title1, panel_x + (panel_w - tw1) / 2 + 1, header_y + 1)
    love.graphics.setColor(0.0, 0.9, 0.85, 1.0)
    love.graphics.print(title1, panel_x + (panel_w - tw1) / 2, header_y)



    -- Arcade Page Cards
    local card_w_arc = math.floor((panel_w - math.floor(32 * scale) - card_gap) / 2)
    local card_h_arc = math.floor((_G.text_size == "large" and 124 or 120) * scale)

    local arcade_modes = {
        {
            name        = "Time Attack",
            desc        = "Race the clock! Merge tiles to gain extra time.",
            icon        = "stopwatch",
            bestScore   = save.loadHighScore("timeattack"),
            available   = true,
            accentR = 0.95, accentG = 0.80, accentB = 0.10,
        },
        {
            name        = "Huge Mode (5x5)",
            desc        = "Achievements disabled except its own.",
            icon        = "huge",
            bestScore   = save.loadHighScore("huge"),
            available   = true,
            accentR = 0.58, accentG = 0.25, accentB = 0.95,
        },
        {
            name        = "No Mercy Mode",
            desc        = "No Undo. 2 tiles spawn per move.",
            icon        = "skull",
            bestScore   = save.loadHighScore("nomercy"),
            available   = true,
            accentR = 0.85, accentG = 0.10, accentB = 0.10,
        },
        {
            name        = "Goose Mode",
            desc        = "A Goose blocks random cells. Honk!",
            icon        = "goose",
            bestScore   = save.loadHighScore("goose"),
            available   = true,
            accentR = 0.15, accentG = 0.55, accentB = 0.75,
        }
    }

    -- Loop 1: Draw unselected card backgrounds
    for i, mode in ipairs(arcade_modes) do
        local col = (i - 1) % 2 + 1
        local row = math.floor((i - 1) / 2) + 1

        local cx_pos = panel_x + math.floor(16 * scale) + (col - 1) * (card_w_arc + card_gap)
        local cy = cards_top + (row - 1) * (card_h_arc + card_gap)

        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (i - 1) * 0.05)
        local card_scale = 0.92 + slide_t * 0.08

        love.graphics.push()
        love.graphics.translate(cx_pos + card_w_arc / 2, cy + card_h_arc / 2)
        love.graphics.scale(card_scale, card_scale)
        love.graphics.translate(-(cx_pos + card_w_arc / 2), -(cy + card_h_arc / 2))

        if mode.available then
            love.graphics.setColor(0.08, 0.08, 0.12, 0.6)
            roundedRect("fill", cx_pos, cy, card_w_arc, card_h_arc, card_cr)
            love.graphics.setColor(0.2, 0.22, 0.28, 0.35)
            love.graphics.setLineWidth(math.floor(1 * scale))
            roundedRect("line", cx_pos, cy, card_w_arc, card_h_arc, card_cr)
        else
            love.graphics.setColor(0.05, 0.05, 0.08, 0.5)
            roundedRect("fill", cx_pos, cy, card_w_arc, card_h_arc, card_cr)
            love.graphics.setColor(0.15, 0.16, 0.20, 0.2)
            love.graphics.setLineWidth(math.floor(1 * scale))
            roundedRect("line", cx_pos, cy, card_w_arc, card_h_arc, card_cr)
        end

        love.graphics.pop()
    end

    -- Phase 2: Draw the single sliding selection highlight box
    do
        local active_idx = arcade_selection or 1
        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (active_idx - 1) * 0.05)
        local hl_scale = 0.92 + slide_t * 0.08

        local col_val = arcade_sel_col_current or ((arcade_selection - 1) % 2 + 1)
        local row_val = arcade_sel_row_current or (math.floor((arcade_selection - 1) / 2) + 1)

        local hl_x = panel_x + math.floor(16 * scale) + (col_val - 1) * (card_w_arc + card_gap)
        local hl_y = cards_top + (row_val - 1) * (card_h_arc + card_gap)

        love.graphics.push()
        love.graphics.translate(hl_x + card_w_arc / 2, hl_y + card_h_arc / 2)
        love.graphics.scale(hl_scale, hl_scale)
        love.graphics.translate(-(hl_x + card_w_arc / 2), -(hl_y + card_h_arc / 2))

        -- Selection background fill
        love.graphics.setColor(0.04, 0.12, 0.16, 0.85)
        roundedRect("fill", hl_x, hl_y, card_w_arc, card_h_arc, card_cr)

        -- Bilinear color interpolation for Page 1 active border
        local c11 = {r = 0.95, g = 0.80, b = 0.10} -- Time Attack (1,1)
        local c21 = {r = 0.58, g = 0.25, b = 0.95} -- Huge Mode (2,1)
        local c12 = {r = 0.85, g = 0.10, b = 0.10} -- No Mercy Mode (1,2)
        local c22 = {r = 0.15, g = 0.55, b = 0.75} -- Goose Mode (2,2)

        local tx = math.max(0, math.min(1, col_val - 1))
        local ty = math.max(0, math.min(1, row_val - 1))

        local r_top = c11.r + (c21.r - c11.r) * tx
        local g_top = c11.g + (c21.g - c11.g) * tx
        local b_top = c11.b + (c21.b - c11.b) * tx

        local r_bot = c12.r + (c22.r - c12.r) * tx
        local g_bot = c12.g + (c22.g - c12.g) * tx
        local b_bot = c12.b + (c22.b - c12.b) * tx

        local r_hl = r_top + (r_bot - r_top) * ty
        local g_hl = g_top + (g_bot - g_top) * ty
        local b_hl = b_top + (b_bot - b_top) * ty

        local pulse = 0.65 + 0.25 * math.sin(t * 5)
        love.graphics.setLineWidth(math.floor(2 * scale))
        love.graphics.setColor(r_hl, g_hl, b_hl, pulse)
        roundedRect("line", hl_x, hl_y, card_w_arc, card_h_arc, card_cr)

        love.graphics.pop()
    end

    -- Loop 2: Draw card contents
    for i, mode in ipairs(arcade_modes) do
        local col = (i - 1) % 2 + 1
        local row = math.floor((i - 1) / 2) + 1

        local cx_pos = panel_x + math.floor(16 * scale) + (col - 1) * (card_w_arc + card_gap)
        local cy = cards_top + (row - 1) * (card_h_arc + card_gap)

        local col_val = arcade_sel_col_current or ((arcade_selection - 1) % 2 + 1)
        local row_val = arcade_sel_row_current or (math.floor((arcade_selection - 1) / 2) + 1)
        local dist_x = math.abs(col - col_val)
        local dist_y = math.abs(row - row_val)
        local select_factor = math.max(0, 1 - dist_x) * math.max(0, 1 - dist_y)

        local slide_t = math.max(0, 1 - raw_offset / math.max(1, panel_h * 0.5) - (i - 1) * 0.05)
        local card_scale = 0.92 + slide_t * 0.08

        love.graphics.push()
        love.graphics.translate(cx_pos + card_w_arc / 2, cy + card_h_arc / 2)
        love.graphics.scale(card_scale, card_scale)
        love.graphics.translate(-(cx_pos + card_w_arc / 2), -(cy + card_h_arc / 2))

        local icon_cx = cx_pos + math.floor(28 * scale)
        local icon_cy = cy + card_h_arc / 2
        if mode.icon == "stopwatch" then
            drawStopwatch(icon_cx, icon_cy, scale, select_factor, mode.accentR, mode.accentG, mode.accentB)
        elseif mode.icon == "huge" then
            drawHugeGrid(icon_cx, icon_cy, scale, select_factor, mode.accentR, mode.accentG, mode.accentB)
        elseif mode.icon == "skull" then
            drawSkull(icon_cx, icon_cy, scale, select_factor, mode.accentR, mode.accentG, mode.accentB)
        elseif mode.icon == "lock" then
            drawLock(icon_cx, icon_cy, scale)
        elseif mode.icon == "goose" then
            drawGooseCardIcon(icon_cx, icon_cy, scale, select_factor, mode.accentR, mode.accentG, mode.accentB)
        end

        local text_x = cx_pos + math.floor(52 * scale)
        local name_y = cy + math.floor(8 * scale)
        love.graphics.setFont(font_score)
        if mode.available then
            local name_r = 0.9 + (mode.accentR - 0.9) * select_factor
            local name_g = 0.92 + (mode.accentG - 0.92) * select_factor
            local name_b = 0.95 + (mode.accentB - 0.95) * select_factor
            love.graphics.setColor(name_r, name_g, name_b, 1.0)
        else
            love.graphics.setColor(0.4, 0.42, 0.48, 0.7)
        end
        love.graphics.print(mode.name, text_x, name_y)

        local has_best = mode.available and mode.bestScore and mode.bestScore > 0
        local badge_y = name_y + font_score:getHeight() + math.floor(1 * scale)
        local badge_h = 0
        if has_best then
            love.graphics.setFont(font_help_label)
            local best_text = "BEST: " .. tostring(mode.bestScore)
            local btw = font_help_label:getWidth(best_text)
            local bth = font_help_label:getHeight()
            local badge_w = btw + math.floor(8 * scale)
            badge_h = bth + math.floor(3 * scale)
            local bx = text_x
            local by = badge_y

            if mode.available then
                local bg_r = 0.12 + (mode.accentR * 0.15 - 0.12) * select_factor
                local bg_g = 0.12 + (mode.accentG * 0.15 - 0.12) * select_factor
                local bg_b = 0.18 + (mode.accentB * 0.15 - 0.18) * select_factor
                love.graphics.setColor(bg_r, bg_g, bg_b, 0.4)
                roundedRect("fill", bx, by, badge_w, badge_h, math.floor(6 * scale))

                local ln_r = 0.3 + (mode.accentR - 0.3) * select_factor
                local ln_g = 0.32 + (mode.accentG - 0.32) * select_factor
                local ln_b = 0.38 + (mode.accentB - 0.38) * select_factor
                local ln_a = 0.4 + 0.05 * select_factor
                love.graphics.setColor(ln_r, ln_g, ln_b, ln_a)
                roundedRect("line", bx, by, badge_w, badge_h, math.floor(6 * scale))

                local tx_r = 0.7 + (mode.accentR - 0.7) * select_factor
                local tx_g = 0.72 + (mode.accentG - 0.72) * select_factor
                local tx_b = 0.78 + (mode.accentB - 0.78) * select_factor
                local tx_a = 0.9 + 0.05 * select_factor
                love.graphics.setColor(tx_r, tx_g, tx_b, tx_a)
            else
                love.graphics.setColor(0.12, 0.12, 0.18, 0.4)
                roundedRect("fill", bx, by, badge_w, badge_h, math.floor(6 * scale))
                love.graphics.setColor(0.3, 0.32, 0.38, 0.4)
                roundedRect("line", bx, by, badge_w, badge_h, math.floor(6 * scale))
                love.graphics.setColor(0.7, 0.72, 0.78, 0.9)
            end
            love.graphics.print(best_text, bx + math.floor(4 * scale), by + math.floor(1.5 * scale))
        end

        local desc_y
        if has_best then
            desc_y = badge_y + badge_h + math.floor(3 * scale)
        else
            desc_y = name_y + font_score:getHeight() + math.floor(3 * scale)
        end
        love.graphics.setFont(font_help_label)
        if mode.available then
            love.graphics.setColor(0.65, 0.68, 0.75, 1.0)
        else
            love.graphics.setColor(0.3, 0.32, 0.38, 0.7)
        end
        love.graphics.printf(mode.desc, text_x, desc_y, card_w_arc - math.floor(52 * scale) - math.floor(6 * scale), "left")

        love.graphics.pop()
    end

    -- Page 1 Footer
    if love.system.getOS() ~= "Web" then
        local dpad_x = panel_x + math.floor(12 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y_foot + (badge_h_foot - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(0.7, 0.75, 0.8, 1.0)
        love.graphics.print("Navigate", dpad_x, badge_y_foot + (badge_h_foot - font_help_label:getHeight()) / 2)

        local right_x1 = panel_x + panel_w - math.floor(12 * scale)
        local footer_actions_arc = {
            {key = "A", label = "Play"},
            {key = "B", label = "Back"},
        }
        for _, action in ipairs(footer_actions_arc) do
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x1 = right_x1 - lbl_w
            love.graphics.setColor(0.7, 0.75, 0.8, 1.0)
            love.graphics.print(action.label, right_x1, badge_y_foot + (badge_h_foot - font_help_label:getHeight()) / 2)
            right_x1 = right_x1 - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x1 = right_x1 - key_w
            drawKeyBadge(action.key, right_x1, badge_y_foot, key_w, badge_h_foot)
            right_x1 = right_x1 - item_gap
        end
    end

    love.graphics.pop()

    love.graphics.pop() -- End content viewport scissor/push

    -- Transition Overlay if needed
    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end

-- ============================================================================
-- Secret Menu
-- ============================================================================
function renderer.drawSecretMenu(selection, skip_transition)
    renderer.clearBackground()
    selection = math.max(1, math.min(7, selection or 1))

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    love.graphics.setFont(font_title)
    love.graphics.setColor(ui_text)
    local title = "Secret Menu"
    local tw = font_title:getWidth(title)
    local title_y = math.floor(8 * scale)
    love.graphics.print(title, (w - tw) / 2, title_y)

    love.graphics.setFont(font_help_label)
    love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.7)
    local subtitle = "Secret Menu options reset when you quit"
    local sw = font_help_label:getWidth(subtitle)
    local subtitle_y = title_y + font_title:getHeight() - math.floor(2 * scale)
    love.graphics.print(subtitle, (w - sw) / 2, subtitle_y)

    local options = {
        "Unlock All Themes",
        "Max Powerups: " .. (_G.cheat_max_powerups and "ON" or "OFF"),
        "Start with 1024 (Classic Mode): " .. (_G.cheat_start_1024_classic and "ON" or "OFF"),
        "Start with 1024 (Plus Mode): " .. (_G.cheat_start_1024_plus and "ON" or "OFF"),
        "Debug Layout: " .. (_G.cheat_debug_layout or "None"),
    }
    table.insert(options, "Lock Secret Menu")
    table.insert(options, "Back")

    love.graphics.setFont(font_message)
    local gap = (_G.text_size == "large" and 40 or 36) * scale
    local menu_h = (#options - 1) * gap + font_message:getHeight()
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local subtitle_h = font_help_label:getHeight()
    local available_h = badge_y - subtitle_y - subtitle_h
    local start_y = math.floor(subtitle_y + subtitle_h + (available_h - menu_h) / 2)

    local margin = math.floor(20 * scale)
    local max_ow = 0
    for _, opt in ipairs(options) do
        local ow = font_message:getWidth(opt)
        if ow > max_ow then
            max_ow = ow
        end
    end
    -- Clamp block_x so menu never shifts past the left margin
    local block_x = math.max(margin, (w - max_ow) / 2)

    local target_oy = start_y + (selection - 1) * gap
    local sel_opt = options[selection]
    local sel_ow = font_message:getWidth(sel_opt)

    local target_ox = block_x - 12 * scale
    local target_ow = sel_ow + 24 * scale

    menu_anim_target_y = target_oy
    menu_anim_target_x = target_ox
    menu_anim_target_w = target_ow

    if not menu_anim_y then menu_anim_y = target_oy end
    if not menu_anim_x then menu_anim_x = target_ox end
    if not menu_anim_w then menu_anim_w = target_ow end

    love.graphics.setColor(help_key_color)
    drawSelectionPill(menu_anim_x, menu_anim_y - 1 * scale, menu_anim_w, font_message:getHeight() + 2 * scale, 6 * scale)

    local max_text_w = w - block_x - margin
    for i, opt in ipairs(options) do
        local oy = start_y + (i - 1) * gap
        if i == selection then
            love.graphics.setColor(help_key_text)
        else
            love.graphics.setColor(ui_text)
        end
        -- Truncate text that would overflow the right edge
        local display = opt
        if font_message:getWidth(display) > max_text_w then
            while #display > 1 and font_message:getWidth(display .. "...") > max_text_w do
                display = display:sub(1, -2)
            end
            display = display .. "..."
        end
        love.graphics.print(display, block_x, oy)
    end

    -- Footer bar for Secret Menu
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- DPAD on the left
    if love.system.getOS() ~= "Web" then
        local dpad_x = math.floor(20 * scale)
        local dpad_size = math.floor(24 * scale)
        drawKeyBadge("DPAD", dpad_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
        dpad_x = dpad_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(ui_text)
        love.graphics.print("Navigate", dpad_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Right side actions: B (Back), A (Toggle), Y (Theme)
        local right_x = w - math.floor(20 * scale)
        local actions = {
            {key = "B", label = "Back"},
            {key = "A", label = "Toggle"},
            {key = "Y", label = "Switch Theme"}
        }
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end


-- ============================================================================
-- Theme Selection / Preview Screen
-- ============================================================================
function renderer.drawThemeSelect(skip_transition)
    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    -- Title: "Select Theme"
    love.graphics.setFont(font_cheats_title)
    love.graphics.setColor(ui_text)
    local title = "Select Theme"
    local tw = font_cheats_title:getWidth(title)
    local title_y = h * 0.04
    love.graphics.print(title, (w - tw) / 2, title_y)

    -- Subtitle showing Theme Name (index/total)
    local theme_disp = _G.theme:gsub("^%l", string.upper)
    local current_idx = 1
    for i, t in ipairs(_G.unlocked_themes) do
        if t == _G.theme then current_idx = i break end
    end
    local subtitle = theme_disp .. " (" .. current_idx .. "/" .. #_G.unlocked_themes .. ")"

    love.graphics.setFont(font_help_label)
    love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.7)
    local sw = font_help_label:getWidth(subtitle)
    local subtitle_y = title_y + font_cheats_title:getHeight() + math.floor(5 * scale)
    love.graphics.print(subtitle, (w - sw) / 2, subtitle_y)

    -- Draw preview swatches (2x2 palette card) and horizontal color strip
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local board_top = subtitle_y + font_help_label:getHeight() + math.floor(10 * scale)
    local board_bottom = badge_y - math.floor(10 * scale)
    local avail_h = board_bottom - board_top

    -- Define palette strip height and padding
    local strip_h = math.floor(14 * scale)
    local pad_x = math.floor(6 * scale)
    local pad_y = math.floor(5 * scale)
    local panel_h = strip_h + pad_y * 2
    local strip_gap = math.floor(12 * scale)
    local avail_h_for_board = avail_h - (panel_h + strip_gap)

    -- Keep the palette card as a beautifully sized square/rect
    local board_size = math.min(math.floor(190 * scale), avail_h_for_board)
    local board_x = math.floor((w - board_size) / 2)

    -- Calculate vertical positions so everything is perfectly centered as a single block!
    local total_block_h = board_size + strip_gap + panel_h
    local block_y = board_top + (avail_h - total_block_h) / 2

    local board_y = block_y
    local strip_y = board_y + board_size + strip_gap
    local strip_x = board_x

    local cell_gap = math.floor(board_size * 0.05)
    local cell_size = math.floor((board_size - cell_gap * 3) / 2)
    local cr = math.floor(cell_size * 0.06)

    -- Draw board background (representing theme board_color)
    love.graphics.setColor(board_color)
    roundedRect("fill", board_x, board_y, board_size, board_size, cr * 2)

    -- Swatches to display
    local swatches = {
        { color = bg_color, label = "BG", textColor = ui_text, hasOutline = true },
        { color = board_color, label = "BOARD", textColor = ui_text, hasOutline = true },
        { color = tile_colors[2], label = "2", textColor = getTileTextColor(2) },
        { color = tile_colors[2048] or tile_colors[2], label = "2048", textColor = getTileTextColor(2048) }
    }

    local positions = {
        { x = board_x + cell_gap, y = board_y + cell_gap },
        { x = board_x + cell_gap * 2 + cell_size, y = board_y + cell_gap },
        { x = board_x + cell_gap, y = board_y + cell_gap * 2 + cell_size },
        { x = board_x + cell_gap * 2 + cell_size, y = board_y + cell_gap * 2 + cell_size }
    }

    -- Set up font for swatch labels
    local swatch_size = math.max(10, math.floor(cell_size * 0.20))
    local swatch_key = "swatch_" .. tostring(swatch_size)
    if not font_cache[swatch_key] then
        font_cache[swatch_key] = love.graphics.newFont(font_path, swatch_size)
    end
    local font_swatch = font_cache[swatch_key]

    for i, sw in ipairs(swatches) do
        local sx = positions[i].x
        local sy = positions[i].y

        -- Draw swatch color block
        love.graphics.setColor(sw.color)
        roundedRect("fill", sx, sy, cell_size, cell_size, cr)

        if sw.hasOutline then
            love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.2)
            love.graphics.setLineWidth(math.floor(1 * scale))
            roundedRect("line", sx, sy, cell_size, cell_size, cr)
        end

        -- Draw centered swatch label text
        love.graphics.setFont(font_swatch)
        love.graphics.setColor(sw.textColor)
        local th = font_swatch:getHeight()
        love.graphics.printf(sw.label, sx, sy + (cell_size - th) / 2, cell_size, "center")
    end

    -- Draw horizontal color palette strip representing all tile colors with a glassy background card
    -- Glassy dark backing card (0, 0, 0, 0.4) that provides gorgeous contrast against theme backgrounds
    love.graphics.setColor(0, 0, 0, 0.4)
    roundedRect("fill", strip_x, strip_y, board_size, panel_h, cr)
    -- Glassy light outline (ui_text with 0.15 opacity) for a clean, professional frosted look
    love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.15)
    love.graphics.setLineWidth(math.floor(1 * scale))
    roundedRect("line", strip_x, strip_y, board_size, panel_h, cr)

    -- Draw the 11 tile color blocks inside the glassy capsule
    local tile_values = {2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048}
    local bgap = math.max(1, math.floor(2 * scale))
    local avail_w = board_size - pad_x * 2
    local block_w = (avail_w - bgap * 10) / 11
    local bcr = math.max(2, math.floor(block_w * 0.20))

    for idx, val in ipairs(tile_values) do
        local color = tile_colors[val] or tile_colors[2]
        love.graphics.setColor(color)
        local bx = strip_x + pad_x + (idx - 1) * (block_w + bgap)
        roundedRect("fill", bx, strip_y + pad_y, block_w, strip_h, bcr)
    end

    -- Draw standardized help footer
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- Right side actions: B (Cancel), A (Select), Y (Switch Theme)
    local right_x = w - math.floor(20 * scale)
    local actions = {
        {key = "B", label = "Cancel"},
        {key = "A", label = "Select"},
        {key = "Y", label = "Switch Theme"}
    }
    for _, action in ipairs(actions) do
        -- Label
        love.graphics.setFont(font_help_label)
        local lbl_w = font_help_label:getWidth(action.label)
        right_x = right_x - lbl_w
        love.graphics.setColor(ui_text)
        love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Badge
        right_x = right_x - label_gap
        local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
        right_x = right_x - key_w
        drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

        right_x = right_x - item_gap
    end

    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end


local function drawBgmNowPlaying()
    if now_playing_timer <= 0 or not now_playing_track then return end

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    -- Card dimensions (increased to prevent text spill)
    local card_w = math.floor(230 * scale)
    local card_h = math.floor(66 * scale)
    local padding = math.floor(10 * scale)

    -- Slide/Fade logic
    local slide_progress = 1
    local alpha = 1.0

    if now_playing_timer > 3.6 then
        slide_progress = (4.0 - now_playing_timer) / 0.4
    elseif now_playing_timer < 0.4 then
        slide_progress = now_playing_timer / 0.4
        alpha = slide_progress
    end

    slide_progress = 1 - math.pow(1 - slide_progress, 3)

    local target_x = w - card_w - padding
    local start_x = w + 10 -- offscreen right
    local x = start_x + (target_x - start_x) * slide_progress
    -- Shift down to 65 to clear the scoreboard BEST box
    local y = padding + math.floor(65 * scale)

    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.12 * alpha)
    love.graphics.rectangle("fill", x + math.floor(2 * scale), y + math.floor(2 * scale), card_w, card_h, math.floor(6 * scale), math.floor(6 * scale))

    -- Draw container box using the theme's score box background color (with high opacity)
    local bg = score_bg_color or board_color or {0.18, 0.18, 0.22}
    love.graphics.setColor(bg[1], bg[2], bg[3], 0.94 * alpha)
    love.graphics.rectangle("fill", x, y, card_w, card_h, math.floor(6 * scale), math.floor(6 * scale))

    -- Add a subtle thin border using the theme's label color
    local lbl = score_label or ui_text or {0.8, 0.8, 0.8}
    love.graphics.setColor(lbl[1], lbl[2], lbl[3], 0.15 * alpha)
    love.graphics.rectangle("line", x, y, card_w, card_h, math.floor(6 * scale), math.floor(6 * scale))

    -- Draw animated equalizer visualizer (3 simple bouncing bars)
    local viz_w = math.floor(14 * scale)
    local viz_x = x + padding

    -- Draw visualizer using the theme's value color (high-contrast highlight)
    local val = score_value or ui_text or {1.0, 1.0, 1.0}
    love.graphics.setColor(val[1], val[2], val[3], 0.85 * alpha)

    local t = love.timer.getTime()
    local bar1_h = math.floor((8 + math.sin(t * 15) * 5) * scale)
    local bar2_h = math.floor((12 + math.sin(t * 22 + 1) * 7) * scale)
    local bar3_h = math.floor((7 + math.sin(t * 18 + 2) * 4) * scale)

    local bar_w = math.floor(3 * scale)
    local bar_gap = math.floor(2 * scale)
    local base_y = y + card_h - padding - math.floor(4 * scale)

    -- Draw rounded visualizer bars
    love.graphics.rectangle("fill", viz_x, base_y - bar1_h, bar_w, bar1_h, 1.5 * scale, 1.5 * scale)
    love.graphics.rectangle("fill", viz_x + bar_w + bar_gap, base_y - bar2_h, bar_w, bar2_h, 1.5 * scale, 1.5 * scale)
    love.graphics.rectangle("fill", viz_x + (bar_w + bar_gap) * 2, base_y - bar3_h, bar_w, bar3_h, 1.5 * scale, 1.5 * scale)

    -- Draw Text labels (Song Title and Artist Name)
    local text_x = viz_x + viz_w + math.floor(8 * scale)
    local text_y = y + padding - math.floor(2 * scale)

    local active_font = font_bgm or font_help_label

    -- "Now Playing" prefix label
    love.graphics.setFont(active_font)
    love.graphics.setColor(lbl[1], lbl[2], lbl[3], 0.70 * alpha)
    love.graphics.print("NOW PLAYING", text_x, text_y)

    -- Song Title
    local title_y = text_y + active_font:getHeight() + math.floor(2 * scale)
    love.graphics.setFont(active_font)
    love.graphics.setColor(val[1], val[2], val[3], 1.0 * alpha)
    local title_text = now_playing_track.title
    local max_txt_w = card_w - (text_x - x) - padding
    if active_font:getWidth(title_text) > max_txt_w then
        while #title_text > 4 and active_font:getWidth(title_text .. "...") > max_txt_w do
            title_text = title_text:sub(1, #title_text - 1)
        end
        title_text = title_text .. "..."
    end
    love.graphics.print(title_text, text_x, title_y)

    -- Artist Name
    local artist_y = title_y + active_font:getHeight() + math.floor(2 * scale)
    love.graphics.setFont(active_font)
    love.graphics.setColor(val[1], val[2], val[3], 0.70 * alpha)
    local artist_text = now_playing_track.artist
    if active_font:getWidth(artist_text) > max_txt_w then
        while #artist_text > 4 and active_font:getWidth(artist_text .. "...") > max_txt_w do
            artist_text = artist_text:sub(1, #artist_text - 1)
        end
        artist_text = artist_text .. "..."
    end
    love.graphics.print(artist_text, text_x, artist_y)

    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================================
-- Main draw function
-- ============================================================================
function renderer.draw(game, skip_transition)
    if game then
        renderer.updateLayout(game.size)
    end
    -- Fill background
    renderer.clearBackground()

    renderer.drawHeader(game)
    renderer.drawScores(game)
    renderer.drawBoard(game)
    renderer.drawTiles(game)
    renderer.drawTargetingCursor(game)
    renderer.drawOverlay(game)
    renderer.drawHelp(game)

    if not skip_transition and transition_timer > 0 and transition_canvas then
        -- We want to draw the OLD screen (transition_canvas) everywhere EXCEPT where the stencil is.
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0) -- Draw where stencil is 0
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest() -- Disable stencil
    end

    drawToast()
end

-- ============================================================================
-- Achievements Screen
-- ============================================================================
local achievementsList = {
    -- Score Milestones
    { id = "ach_score_1k", name = "Getting Started", desc = "Reach 1,000 points", reward = "Forest Theme" },
    { id = "ach_score_2k", name = "Gaining Momentum", desc = "Reach 2,000 points", reward = "Volcano Theme" },
    { id = "ach_score_5k", name = "Rising Star", desc = "Reach 5,000 points", reward = "Sunset Theme" },
    { id = "ach_score_7k", name = "High Scorer", desc = "Reach 7,500 points", reward = "Abyss Theme" },
    { id = "ach_score_10k", name = "High Roller", desc = "Reach 10,000 points", reward = "Neon Theme" },
    { id = "ach_score_25k", name = "Aesthetic", desc = "Reach 25,000 points", reward = "Vaporwave Theme" },
    { id = "ach_score_50k", name = "Vampire Lord", desc = "Reach 50,000 points", reward = "Dracula Theme" },
    { id = "ach_score_100k", name = "Midas Touch", desc = "Reach 100,000 points", reward = "Gold Theme" },
    { id = "ach_score_250k", name = "Infinity Legend", desc = "Reach 250,000 points", reward = "Hyperdrive Theme" },

    -- Tile Merges
    { id = "ach_merge_512", name = "Half Way There", desc = "Create a 512 tile", reward = "Candy Theme" },
    { id = "ach_merge_1024", name = "Almost There", desc = "Create a 1024 tile", reward = "Midnight Theme" },
    { id = "ach_2048", name = "2048 Master", desc = "Create a 2048 tile in Classic Mode", reward = "OLED Dark Theme" },
    { id = "ach_4096", name = "The One", desc = "Create a 4096 tile", reward = "Glitch Theme" },
    { id = "ach_merge_8192", name = "The Chosen One", desc = "Create an 8192 tile", reward = "Quantum Theme" },

    -- Plus Mode Milestones
    { id = "ach_first_bomb", name = "Boom!", desc = "Use your first bomb in Plus Mode", reward = "Eclipse Theme" },
    { id = "ach_demolition", name = "Demolition Expert", desc = "Use 10 bombs in total in Plus Mode", reward = "Retro Theme" },
    { id = "ach_2048_plus", name = "Plus Mode Master", desc = "Create a 2048 tile in Plus Mode", reward = "Cyberpunk Theme" },
    { id = "ach_tactician", name = "Tactician", desc = "Use 5 Undos and 5 Swaps in a single Plus Mode game", reward = "Steel Theme" },

    -- Alternative Modes
    { id = "ach_timeattack_2048", name = "Aurora", desc = "Create a 2048 tile in Time Attack mode", reward = "Aurora Theme" },
    { id = "ach_huge_2048", name = "Spacious Giant", desc = "Create a 2048 tile in Huge Mode", reward = "Nebula Theme" },
    { id = "ach_nomercy_512", name = "No Escape", desc = "Create a 512 tile in No Mercy Mode", reward = "Inferno Theme" },
    { id = "ach_goose_2048", name = "Honk Honk!", desc = "Create a 2048 tile in Goose Mode", reward = "Honk Theme" },

    -- Special Challenges & Secrets
    { id = "ach_first_game", name = "First Steps", desc = "Play your first game", reward = "Ocean Theme" },
    { id = "ach_secret_menu", name = "Secret Discovery", desc = "Access the Secret Menu for the first time", reward = "Matrix Theme" },
    { id = "ach_untouchable", name = "Untouchable", desc = "Create a 1024 tile without using undos or powerups", reward = "Peach Theme" },
    { id = "ach_untouchable_2048", name = "Zen Master", desc = "Create a 2048 tile without using undos or powerups", reward = "Matcha Theme" },
    { id = "ach_speedrun_2048", name = "Speed Demon", desc = "Create a 2048 tile in under 5 minutes", reward = "Retro Gold Theme" },
    { id = "ach_hardcore_2048", name = "Hardcore Gamer", desc = "Create 2048 in Plus Mode without powerups or undos", reward = "Spectrum Theme" }
}

function renderer.getAchievementsCount()
    return #achievementsList
end

function renderer.drawAchievements(scroll, skip_transition, static_only, override_tab)
    local w, h = love.graphics.getDimensions()
    local scale = _G.scale
    local padding = math.floor(20 * scale)
    local active_tab = override_tab or _G.achievements_tab

    -- Slide animation state
    if not static_only and _G.achievements_slide_timer and _G.achievements_slide_timer > 0 then
        local dt = love.timer.getDelta()
        _G.achievements_slide_timer = _G.achievements_slide_timer - dt
        if _G.achievements_slide_timer < 0 then _G.achievements_slide_timer = 0 end
    end

    -- Draw slide content with iOS Push & Dim transition
    if not static_only and _G.achievements_slide_timer and _G.achievements_slide_timer > 0 then
        local progress = 1 - (_G.achievements_slide_timer / 0.20)
        local p = 1 - math.pow(1 - progress, 3) -- cubic ease-out

        local dir = _G.achievements_slide_dir or 1
        local shadow_w = math.floor(20 * scale)

        -- Capture the new tab to achievements_new_canvas ONCE at the start of transition
        if not _G.achievements_slide_ready then
            if not achievements_new_canvas then
                achievements_new_canvas = love.graphics.newCanvas(w, h)
            end
            love.graphics.setCanvas({achievements_new_canvas, stencil = true})
            love.graphics.clear()
            renderer.drawAchievements(scroll, true, true, active_tab)
            love.graphics.setCanvas()
            _G.achievements_slide_ready = true
        end

        if dir == 1 then
            -- Forward transition (Tab 1 -> Tab 2): New page slides in on top from right (w -> 0)
            -- Old page slides out underneath to the left at 30% speed (0 -> -0.3*w)
            local old_x = math.floor(-0.3 * w * p)
            local new_x = math.floor(w * (1 - p))

            -- 1. Draw old page (underneath)
            if achievements_old_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(achievements_old_canvas, old_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")

                -- Dim the old page
                love.graphics.setColor(0, 0, 0, 0.5 * p)
                love.graphics.rectangle("fill", old_x, 0, w, h)
            end

            -- 2. Draw shadow to the left of the new page
            for i = 0, shadow_w - 1 do
                local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                love.graphics.setColor(0, 0, 0, alpha)
                love.graphics.rectangle("fill", new_x - shadow_w + i, 0, 1, h)
            end

            -- 3. Draw new page (on top)
            if achievements_new_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(achievements_new_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end
        else
            -- Backward transition (Tab 2 -> Tab 1): Old page slides out on top to the right (0 -> w)
            -- New page slides in underneath from the left at 30% speed (-0.3*w -> 0)
            local new_x = math.floor(-0.3 * w * (1 - p))
            local old_x = math.floor(w * p)

            -- 1. Draw new page (underneath)
            if achievements_new_canvas then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(achievements_new_canvas, new_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end

            -- Dim the new page
            love.graphics.setColor(0, 0, 0, 0.5 * (1 - p))
            love.graphics.rectangle("fill", new_x, 0, w, h)

            -- 2. Draw shadow to the left of the old page (sliding on top)
            if achievements_old_canvas then
                for i = 0, shadow_w - 1 do
                    local alpha = 0.35 * math.pow((shadow_w - i) / shadow_w, 2)
                    love.graphics.setColor(0, 0, 0, alpha)
                    love.graphics.rectangle("fill", old_x - shadow_w + i, 0, 1, h)
                end

                -- 3. Draw old page (on top)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("replace", "premultiplied")
                love.graphics.draw(achievements_old_canvas, old_x, 0)
                love.graphics.setBlendMode("alpha", "alphamultiply")
            end
        end

        -- Theme transition overlay
        if not skip_transition and transition_timer > 0 and transition_canvas then
            love.graphics.stencil(drawStencilCircle, "replace", 1)
            love.graphics.setStencilTest("equal", 0)
            love.graphics.draw(transition_canvas, 0, 0)
            love.graphics.setStencilTest()
        end
        return
    end

    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale
    local padding = math.floor(20 * scale)

    -- Header Title
    love.graphics.setFont(font_title)
    love.graphics.setColor(ui_text)
    local title = "Achievements & Stats"
    love.graphics.print(title, padding, padding)

    -- Tab selection bar
    local tab1_txt = "Achievements"
    local tab2_txt = "Statistics"
    local t1_w = font_score:getWidth(tab1_txt)
    local t2_w = font_score:getWidth(tab2_txt)
    local tab_gap = math.floor(40 * scale)

    local total_tab_w = t1_w + t2_w + tab_gap
    local start_tab_x = (w - total_tab_w) / 2
    local tab_y = padding + font_title:getHeight() + math.floor(10 * scale)

    -- Draw Tab 1 text
    local t1_x = start_tab_x
    if active_tab == 1 then
        love.graphics.setColor(ui_text) -- highlighted
    else
        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.5) -- muted
    end
    love.graphics.setFont(font_score)
    love.graphics.print(tab1_txt, t1_x, tab_y)

    -- Draw Tab 2 text
    local t2_x = t1_x + t1_w + tab_gap
    if active_tab == 2 then
        love.graphics.setColor(ui_text) -- highlighted
    else
        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.5) -- muted
    end
    love.graphics.print(tab2_txt, t2_x, tab_y)

    -- Underline for active tab
    local line_h = math.floor(3 * scale)
    local line_y = tab_y + font_score:getHeight() + math.floor(4 * scale)
    love.graphics.setColor(ui_text)
    if active_tab == 1 then
        love.graphics.rectangle("fill", t1_x, line_y, t1_w, line_h)
    else
        love.graphics.rectangle("fill", t2_x, line_y, t2_w, line_h)
    end

    local list_y = line_y + math.floor(12 * scale)
    local footer_h = math.floor(55 * scale)

    -- Helper to format numbers with commas
    local function formatNum(n)
        local formatted = tostring(math.floor(n or 0))
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end

    -- Helper to format time played
    local function formatTime(sec)
        sec = math.floor(sec or 0)
        local hours = math.floor(sec / 3600)
        local mins = math.floor((sec % 3600) / 60)
        local secs = sec % 60
        if hours > 0 then
            return string.format("%dh %dm %ds", hours, mins, secs)
        elseif mins > 0 then
            return string.format("%dm %ds", mins, secs)
        else
            return string.format("%ds", secs)
        end
    end

    if active_tab == 1 then
        -- Tab 1: Scrollable Achievements
        local item_h = math.floor(85 * scale)
        love.graphics.setScissor(0, list_y - math.floor(5 * scale), w, h - list_y - footer_h + math.floor(5 * scale))

        local current_y = list_y - (scroll * item_h)
        for i, ach in ipairs(achievementsList) do
            do
                local isUnlocked = _G.achievements[ach.id]

                -- Card background
                love.graphics.setColor(board_color[1], board_color[2], board_color[3], isUnlocked and 0.9 or 0.7)
                roundedRect("fill", padding, current_y, w - padding * 2, item_h - math.floor(10 * scale), math.floor(12 * scale))

                -- Card border
                if isUnlocked then
                    love.graphics.setColor(help_key_color)
                else
                    love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.4)
                end
                love.graphics.setLineWidth(math.floor(2 * scale))
                roundedRect("line", padding, current_y, w - padding * 2, item_h - math.floor(10 * scale), math.floor(12 * scale))

                -- Icon Area (centered vertically in card)
                local icon_s = math.floor(48 * scale)
                local card_h = item_h - math.floor(10 * scale)
                local icon_x = padding + math.floor(12 * scale)
                local icon_y = current_y + (card_h - icon_s) / 2

                if _G.theme == "matrix" then
                    local cx = icon_x + icon_s / 2
                    local cy = icon_y + icon_s / 2

                    -- Outer wireframe box for icon
                    love.graphics.setColor(ui_text)
                    love.graphics.setLineWidth(math.max(1, math.floor(1.5 * scale)))
                    roundedRect("line", icon_x, icon_y, icon_s, icon_s)

                    if isUnlocked then
                        -- Matrix checkmark [X]
                        love.graphics.setFont(font_message)
                        love.graphics.setColor(ui_text)
                        local txt = "X"
                        local tw = font_message:getWidth(txt)
                        local th = font_message:getHeight()
                        love.graphics.print(txt, cx - tw / 2, cy - th / 2)
                    else
                        -- Matrix Lock
                        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.7)
                        local lock_w = math.floor(20 * scale)
                        local lock_h = math.floor(15 * scale)
                        local lock_x = cx - lock_w / 2
                        local lock_y = cy - lock_h / 2 + math.floor(4 * scale)

                        -- Wireframe lock body
                        roundedRect("line", lock_x, lock_y, lock_w, lock_h)

                        -- Lock shackle
                        local shackle_r = math.floor(7 * scale)
                        local shackle_cy = lock_y - math.floor(1 * scale)
                        love.graphics.setLineWidth(math.max(2, math.floor(2.5 * scale)))
                        love.graphics.arc("line", "open", cx, shackle_cy, shackle_r, math.pi, math.pi*2, 12)
                        love.graphics.line(cx - shackle_r, shackle_cy, cx - shackle_r, lock_y)
                        love.graphics.line(cx + shackle_r, shackle_cy, cx + shackle_r, lock_y)
                    end
                else
                    if isUnlocked then
                        -- Solid green circle background
                        local cx = icon_x + icon_s / 2
                        local cy = icon_y + icon_s / 2
                        local r = icon_s / 2
                        love.graphics.setColor(0.18, 0.72, 0.35)
                        love.graphics.circle("fill", cx, cy, r)
                        -- Darker green border
                        love.graphics.setColor(0.12, 0.55, 0.25)
                        love.graphics.setLineWidth(math.max(1, math.floor(2 * scale)))
                        love.graphics.circle("line", cx, cy, r)

                        -- White checkmark drawn with thick lines
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.setLineWidth(math.max(2, math.floor(3 * scale)))
                        local check_s = icon_s * 0.3
                        love.graphics.line(
                            cx - check_s, cy,
                            cx - check_s * 0.3, cy + check_s * 0.7,
                            cx + check_s, cy - check_s * 0.6
                        )
                    else
                        -- Muted circle background using ui_text at low alpha
                        local cx = icon_x + icon_s / 2
                        local cy = icon_y + icon_s / 2
                        local r = icon_s / 2
                        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.15)
                        love.graphics.circle("fill", cx, cy, r)
                        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.3)
                        love.graphics.setLineWidth(math.max(1, math.floor(1.5 * scale)))
                        love.graphics.circle("line", cx, cy, r)

                        -- Draw Padlock using ui_text color (always visible)
                        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.7)
                        local lock_w = math.floor(20 * scale)
                        local lock_h = math.floor(15 * scale)
                        local lock_x = cx - lock_w / 2
                        local lock_y = cy - lock_h / 2 + math.floor(4 * scale)

                        -- Lock body
                        roundedRect("fill", lock_x, lock_y, lock_w, lock_h, math.floor(3 * scale))

                        -- Lock keyhole
                        love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], 0.8)
                        love.graphics.circle("fill", lock_x + lock_w/2, lock_y + lock_h * 0.4, math.max(1, math.floor(2 * scale)))
                        love.graphics.rectangle("fill", lock_x + lock_w/2 - math.floor(1 * scale), lock_y + lock_h * 0.4, math.floor(2 * scale), math.floor(5 * scale))

                        -- Lock shackle (arc + vertical lines)
                        love.graphics.setColor(ui_text[1], ui_text[2], ui_text[3], 0.7)
                        local shackle_r = math.floor(7 * scale)
                        local shackle_cy = lock_y - math.floor(1 * scale)
                        love.graphics.setLineWidth(math.max(2, math.floor(2.5 * scale)))
                        love.graphics.arc("line", "open", cx, shackle_cy, shackle_r, math.pi, math.pi*2, 12)
                        love.graphics.line(cx - shackle_r, shackle_cy, cx - shackle_r, lock_y)
                        love.graphics.line(cx + shackle_r, shackle_cy, cx + shackle_r, lock_y)
                    end
                end

                -- Name & Desc
                local text_x = icon_x + icon_s + math.floor(15 * scale)
                local base_text_col = renderer.getContrastTextColor(board_color, ui_text, dark_text)
                
                if isUnlocked then
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 1)
                else
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 0.75)
                end
                love.graphics.setFont(font_label)
                love.graphics.print(ach.name, text_x, current_y + math.floor(12 * scale))
 
                love.graphics.setFont(font_help_label)
                if isUnlocked then
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 0.8)
                else
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 0.65)
                end
                love.graphics.print(ach.desc, text_x, current_y + math.floor(42 * scale))
 
                -- Reward Tag
                love.graphics.setFont(font_help_label)
                local rew_text = "Unlocks: " .. ach.reward
                local rw = font_help_label:getWidth(rew_text)
                local tag_x = w - padding - rw - math.floor(25 * scale)
                local tag_y = current_y + math.floor(13 * scale)
 
                local tag_text_color = super_tile_color
                if isUnlocked then
                    local r_bg, g_bg, b_bg = board_color[1] or 0, board_color[2] or 0, board_color[3] or 0
                    local bg_lum = 0.299 * r_bg + 0.587 * g_bg + 0.114 * b_bg
                    if bg_lum > 0.65 then
                        local r_tx, g_tx, b_tx = super_tile_color[1] or 0, super_tile_color[2] or 0, super_tile_color[3] or 0
                        local tx_lum = 0.299 * r_tx + 0.587 * g_tx + 0.114 * b_tx
                        if tx_lum > 0.45 then
                            tag_text_color = dark_text
                        end
                    end
                end

                -- Tag background
                if isUnlocked then
                    love.graphics.setColor(tag_text_color[1], tag_text_color[2], tag_text_color[3], 0.2)
                else
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 0.18)
                end
                roundedRect("fill", tag_x - math.floor(8 * scale), tag_y - math.floor(4 * scale), rw + math.floor(16 * scale), font_help_label:getHeight() + math.floor(8 * scale), math.floor(6 * scale))
 
                if isUnlocked then
                    love.graphics.setColor(tag_text_color[1], tag_text_color[2], tag_text_color[3], 1)
                else
                    love.graphics.setColor(base_text_col[1], base_text_col[2], base_text_col[3], 0.7)
                end
                love.graphics.print(rew_text, tag_x, tag_y)

                current_y = current_y + item_h
            end
        end
        love.graphics.setScissor()
    elseif active_tab == 2 then
        -- Tab 2: Statistics Cards
        local avail_h = h - list_y - footer_h
        local col_w = math.floor((w - padding * 3) / 2)
        local row_h = math.floor(avail_h / 4)
        local card_gap = math.floor(8 * scale)

        local function drawStatCard(x, y, card_w, card_h, label, value)
            -- Card background
            love.graphics.setColor(board_color[1], board_color[2], board_color[3], 0.75)
            roundedRect("fill", x, y, card_w, card_h, math.floor(10 * scale))
 
            local border_color = ui_text
            local label_color = ui_text
            local val_color = ui_text
            
            local base_text_col = renderer.getContrastTextColor(board_color, ui_text, dark_text)
            border_color = base_text_col
            label_color = base_text_col
            val_color = base_text_col

            -- Card border
            love.graphics.setColor(border_color[1], border_color[2], border_color[3], 0.25)
            love.graphics.setLineWidth(math.floor(1.5 * scale))
            roundedRect("line", x, y, card_w, card_h, math.floor(10 * scale))
 
            -- Muted small label
            love.graphics.setFont(font_label)
            love.graphics.setColor(label_color[1], label_color[2], label_color[3], 0.7)
            love.graphics.print(label, x + math.floor(12 * scale), y + math.floor(8 * scale))
 
            -- Large value
            love.graphics.setFont(font_score)
            love.graphics.setColor(val_color[1], val_color[2], val_color[3], 1)
            love.graphics.print(value, x + math.floor(12 * scale), y + card_h - font_score:getHeight() - math.floor(8 * scale))
        end

        local s = _G.stats or {}
        local games_played = s.games_played or 0
        local classic = s.classic_games or 0
        local plus = s.plus_games or 0
        local arcade = s.arcade_games or 0
        local games_str = string.format("%s (C:%d P:%d A:%d)", formatNum(games_played), classic, plus, arcade)

        local highest_tile = s.highest_tile or 0
        local tile_str = highest_tile > 0 and tostring(highest_tile) or "None"

        local bombs = s.bombs_used or 0
        local swaps = s.swaps_used or 0
        local powerups_str = string.format("Bombs: %s | Swaps: %s", formatNum(bombs), formatNum(swaps))

        -- Left Column (Overall Profile)
        local x1 = padding
        drawStatCard(x1, list_y + row_h * 0, col_w, row_h - card_gap, "HIGHEST SCORE", formatNum(s.highest_score or 0))
        drawStatCard(x1, list_y + row_h * 1, col_w, row_h - card_gap, "HIGHEST TILE REACHED", tile_str)
        drawStatCard(x1, list_y + row_h * 2, col_w, row_h - card_gap, "TOTAL TIME PLAYED", formatTime(s.time_played or 0))
        drawStatCard(x1, list_y + row_h * 3, col_w, row_h - card_gap, "GAMES STARTED", games_str)

        -- Right Column (Gameplay & Powerups)
        local x2 = padding * 2 + col_w
        drawStatCard(x2, list_y + row_h * 0, col_w, row_h - card_gap, "TOTAL MOVES MADE", formatNum(s.moves_made or 0))
        drawStatCard(x2, list_y + row_h * 1, col_w, row_h - card_gap, "TOTAL TILES MERGED", formatNum(s.tiles_merged or 0))
        drawStatCard(x2, list_y + row_h * 2, col_w, row_h - card_gap, "POWERUPS USED", powerups_str)
        drawStatCard(x2, list_y + row_h * 3, col_w, row_h - card_gap, "UNDOS TRIGGERED", formatNum(s.undos_used or 0))
    end

    -- Footer bar for Achievements & Stats
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    if love.system.getOS() ~= "Web" then
        -- Left side: DPAD (Scroll / Switch Tab)
        local left_x = padding
        local dpad_size = math.floor(24 * scale)

        drawKeyBadge("DPAD", left_x, badge_y + (badge_h - dpad_size) / 2, dpad_size, dpad_size)
        left_x = left_x + dpad_size + math.floor(6 * scale)
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(ui_text)
        local label = (active_tab == 1) and "Scroll / Switch Tab" or "Switch Tab"
        love.graphics.print(label, left_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

        -- Right side actions: B (Back), Y (Theme)
        local right_x = w - padding
        local actions = {
            {key = "B", label = "Back"},
            {key = "Y", label = "Switch Theme"}
        }
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    -- Theme transition overlay
    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end
end

-- ============================================================================
-- About Screen
-- ============================================================================
local qr_image
function renderer.drawAbout(skip_transition)
    renderer.clearBackground()

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale
    local padding = math.floor(12 * scale)

    love.graphics.setFont(font_title)
    love.graphics.setColor(ui_text)
    local title = "About 2048 Plus"
    local tw = font_title:getWidth(title)
    love.graphics.print(title, (w - tw) / 2, padding)

    love.graphics.setFont(font_label)
    love.graphics.setColor(ui_text)
    local version_text = _G.version or "v2.0.1"
    local vw = font_label:getWidth(version_text)
    love.graphics.print(version_text, (w - vw) / 2, padding + font_title:getHeight() - math.floor(2 * scale))

    local start_y = padding + font_title:getHeight() + font_label:getHeight() - math.floor(4 * scale)
    love.graphics.setFont(font_help_label)
    love.graphics.setColor(ui_text)

    local section_gap = math.floor(8 * scale)
    local cur_y = start_y

    -- Section 1: Developer
    local s1 = "Developed by saitamasahil\nA feature-packed implementation of the classic 2048 puzzle game"
    love.graphics.printf(s1, 0, cur_y, w, "center")
    local _, lines1 = font_help_label:getWrap(s1, w)
    cur_y = cur_y + #lines1 * font_help_label:getHeight() + section_gap

    -- Section 2: Framework
    local s2 = "Original concept by Gabriele Cirulli\nBuilt using the LÖVE Framework"
    love.graphics.printf(s2, 0, cur_y, w, "center")
    local _, lines2 = font_help_label:getWrap(s2, w)
    cur_y = cur_y + #lines2 * font_help_label:getHeight() + section_gap

    -- Section 3: Music credits
    local s3 = "Music: AudioCoffee, Ghostrifter, Purrple Cat,\nRoa, Sakura Girl, Tokyo Music Walker via Chosic"
    love.graphics.printf(s3, 0, cur_y, w, "center")
    local _, lines3 = font_help_label:getWrap(s3, w)
    cur_y = cur_y + #lines3 * font_help_label:getHeight() + section_gap

    -- Section 4: Support Callout
    local s4 = "If you enjoy the game, consider supporting!"
    love.graphics.printf(s4, 0, cur_y, w, "center")

    if not qr_image then
        local success, img = pcall(love.graphics.newImage, "assets/kofi_qr.png")
        if success then qr_image = img end
    end

    if qr_image then
        local iw, ih = qr_image:getDimensions()
        local qr_size = math.floor(100 * scale)
        local qr_scale = qr_size / math.max(iw, ih)
        local scaled_w = iw * qr_scale
        local scaled_h = ih * qr_scale

        -- Calculate position relative to the footer badge (bottom-up layout)
        local badge_h = math.floor(28 * scale)
        local badge_y = h - badge_h - math.floor(15 * scale)
        local caption_y = badge_y - font_help_label:getHeight() - math.floor(4 * scale)
        local qr_y = caption_y - scaled_h - math.floor(6 * scale)
        local qr_x = (w - scaled_w) / 2

        -- Draw white background behind QR
        local bg_pad = math.floor(4 * scale)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", qr_x - bg_pad, qr_y - bg_pad, scaled_w + bg_pad * 2, scaled_h + bg_pad * 2, math.floor(4 * scale), math.floor(4 * scale))

        -- Draw QR
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(qr_image, qr_x, qr_y, 0, qr_scale, qr_scale)

        -- Caption
        love.graphics.setFont(font_help_label)
        love.graphics.setColor(ui_text)
        love.graphics.printf("Scan to support on Ko-fi", 0, caption_y, w, "center")
    end

    -- Footer bar for About
    local badge_h = math.floor(28 * scale)
    local badge_y = h - badge_h - math.floor(15 * scale)
    local item_gap = math.floor(10 * scale)
    local label_gap = math.floor(4 * scale)

    -- Right side actions: B (Back), Y (Theme)
    if love.system.getOS() ~= "Web" then
        local right_x = w - math.floor(20 * scale)
        local actions = {
            {key = "B", label = "Back"},
            {key = "Y", label = "Switch Theme"}
        }
        for _, action in ipairs(actions) do
            -- Label
            love.graphics.setFont(font_help_label)
            local lbl_w = font_help_label:getWidth(action.label)
            right_x = right_x - lbl_w
            love.graphics.setColor(ui_text)
            love.graphics.print(action.label, right_x, badge_y + (badge_h - font_help_label:getHeight()) / 2)

            -- Badge
            right_x = right_x - label_gap
            local key_w = math.max(math.floor(28 * scale), font_help_key:getWidth(action.key) + math.floor(12 * scale))
            right_x = right_x - key_w
            drawKeyBadge(action.key, right_x, badge_y, key_w, badge_h)

            right_x = right_x - item_gap
        end
    end

    if not skip_transition and transition_timer > 0 and transition_canvas then
        love.graphics.stencil(drawStencilCircle, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("replace", "premultiplied")
        love.graphics.draw(transition_canvas, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest()
    end

    drawToast()
end

function renderer.isArcadeMenuClosed()
    local scale = _G.scale or 1
    local card_h = math.floor((_G.text_size == "large" and 124 or 120) * scale)
    local card_gap = math.floor(12 * scale)
    local panel_pad_y = math.floor(16 * scale)
    local header_h = math.floor(74 * scale)
    local footer_h = math.floor(44 * scale)
    local num_rows = 2
    local panel_h = header_h + panel_pad_y + num_rows * card_h + (num_rows - 1) * card_gap + panel_pad_y + footer_h

    return (arcade_panel_target == panel_h) and (arcade_panel_y_offset >= panel_h - 1)
end
-- Play on Web Server Screen removed (server is now toggled inline inside the Secret Menu)

return renderer
