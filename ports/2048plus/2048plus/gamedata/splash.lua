-- 2048 Splash Screen
-- A slick, tile-themed intro animation with the 2048 logo

local timer = require("timer")

local splash = {
    finished = false,
    is_revealing = false
}

-- ============================================================================
-- Color helpers
-- ============================================================================
local function hex(h)
    h = h:gsub("#", "")
    return tonumber(h:sub(1, 2), 16) / 255,
           tonumber(h:sub(3, 4), 16) / 255,
           tonumber(h:sub(5, 6), 16) / 255
end

-- 2048 color palette
local colors = {
    bg        = {hex("#faf8ef")},
    board     = {hex("#bbada0")},
    empty     = {hex("#cdc1b4")},
    gold      = {hex("#edc22e")},  -- logo background / 2048 tile
    orange    = {hex("#f2b179")},  -- 8 tile
    red       = {hex("#f65e3b")},  -- 64 tile
    dark_text = {hex("#776e65")},
    light     = {hex("#f9f6f2")},
    tile_2    = {hex("#eee4da")},
    tile_4    = {hex("#ede0c8")},
    tile_16   = {hex("#f59563")},
    tile_32   = {hex("#f67c5f")},
    tile_128  = {hex("#edcf72")},
    tile_512  = {hex("#edc850")},
    super     = {hex("#3c3a32")},
}

-- ============================================================================
-- Animation state
-- ============================================================================
local logo

local anim = {
    -- Phase 1: Background tiles cascade in
    tiles_progress = 0,
    tile_data = {},

    -- Phase 2: Logo pops in
    logo_scale = 0,
    logo_alpha = 0,



    -- Phase 5: Exit — tiles merge into golden explosion
    exit_progress = 0,
    exit_particles = {},
    exit_ring_r = 0,
    exit_flash = 0,

    -- Screen shake
    shake_x = 0,
    shake_y = 0,
}

-- Pre-defined tile colors for the background cascade
local cascade_tile_colors = {
    colors.tile_2, colors.tile_4, colors.orange, colors.tile_16,
    colors.tile_32, colors.red, colors.tile_128, colors.tile_512,
    colors.gold, colors.super
}

-- ============================================================================
-- Initialization
-- ============================================================================
function splash.load()
    local w, h = love.graphics.getDimensions()

    local renderer = require("renderer")
    local tile_colors_t, super_color = renderer.getThemeTileColors()
    local theme_gold, theme_super = renderer.getThemeHighlightColors()

    -- Dynamically update standard flash, ring, and particle colors based on active theme
    colors.gold = theme_gold
    colors.super = theme_super

    -- Dynamically build background cascade tile color list from theme
    cascade_tile_colors = {}
    local values = {2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048}
    for _, v in ipairs(values) do
        if tile_colors_t[v] then
            table.insert(cascade_tile_colors, tile_colors_t[v])
        end
    end
    if super_color then
        table.insert(cascade_tile_colors, super_color)
    end
    if #cascade_tile_colors == 0 then
        cascade_tile_colors = {colors.tile_2, colors.tile_4, colors.orange, colors.tile_16, colors.tile_32, colors.red, colors.tile_128, colors.tile_512, colors.gold, colors.super}
    end

    -- Load assets
    logo = love.graphics.newImage("assets/logo_2048.png")
    logo:setFilter("linear", "linear")

    -- Reset state
    anim.tiles_progress = 0
    anim.logo_scale = 0
    anim.logo_alpha = 0
    anim.exit_progress = 0
    anim.exit_particles = {}
    anim.exit_ring_r = 0
    anim.exit_flash = 0
    anim.shake_x = 0
    anim.shake_y = 0
    splash.finished = false
    splash.is_revealing = false

    -- Generate background tile grid data
    -- Create a larger-than-screen grid of tiles with random values
    local cell_size = math.floor(math.max(w, h) * 0.12)
    local gap = math.floor(cell_size * 0.08)
    local cols = math.ceil(w / (cell_size + gap)) + 1
    local rows = math.ceil(h / (cell_size + gap)) + 1

    local grid_w = cols * cell_size + (cols - 1) * gap
    local grid_h = rows * cell_size + (rows - 1) * gap
    local start_x = (w - grid_w) / 2
    local start_y = (h - grid_h) / 2

    anim.tile_data = {}

    for col = 1, cols do
        for row = 1, rows do
            local tx = start_x + (col - 1) * (cell_size + gap)
            local ty = start_y + (row - 1) * (cell_size + gap)
            local color_idx = math.random(#cascade_tile_colors)
            local delay = (col + row) * 0.04 + math.random() * 0.06  -- diagonal cascade

            table.insert(anim.tile_data, {
                x = tx, y = ty,
                size = cell_size,
                color = cascade_tile_colors[color_idx],
                delay = delay,
                scale = 0,           -- current scale (animated)
                target_scale = 1,
                rotation = 0,
                corner_r = math.floor(cell_size * 0.08),
                alpha = 1,
            })
        end
    end

    -- =============================================
    -- PHASE 1: Background tiles cascade in (staggered pop-in)
    -- =============================================
    for _, tile in ipairs(anim.tile_data) do
        timer.after(tile.delay, function()
            timer.tween(0.4, tile, {scale = 1}, 'out-back')
        end)
    end

    -- =============================================
    -- PHASE 2: Logo pops in with elastic bounce
    -- =============================================
    timer.after(0.6, function()
        local sound = require("sound")
        sound.playSplash()
        timer.tween(0.1, anim, {logo_alpha = 1}, 'linear')
        timer.tween(0.7, anim, {logo_scale = 1.0}, 'out-elastic')
    end)



    -- =============================================
    -- PHASE 5: Exit — Radiant Ripple Sweep
    -- =============================================
    timer.after(2.3, function()
        splash.is_revealing = true
        local cx, cy = w / 2, h / 2

        -- Tiles shrink to 0 in a ripple radiating from the center
        local max_delay = 0
        for _, tile in ipairs(anim.tile_data) do
            local tcx, tcy = tile.x + tile.size / 2, tile.y + tile.size / 2
            local dist = math.sqrt((tcx - cx)^2 + (tcy - cy)^2)
            local delay = dist * 0.0012 -- adjust speed of ripple

            if delay > max_delay then max_delay = delay end

            timer.after(delay, function()
                timer.tween(0.3, tile, { scale = 0 }, 'in-back')
            end)
        end

        -- Logo does a satisfying pop after the ripple reaches the edges
        timer.after(max_delay + 0.1, function()
            timer.tween(0.3, anim, { logo_scale = 0 }, 'in-back')
        end)

        -- Finish when everything is done
        timer.after(max_delay + 0.45, function()
            splash.finished = true
            splash.is_revealing = false
        end)
    end)
end

-- ============================================================================
-- Helper: draw a rounded rect (with optional rotation)
-- ============================================================================
local function roundedRect(mode, x, y, w, h, r)
    r = r or 0
    love.graphics.rectangle(mode, x, y, w, h, r, r)
end

-- ============================================================================
-- Draw
-- ============================================================================
function splash.draw()
    if splash.finished then return end

    local w, h = love.graphics.getDimensions()
    local scale = _G.scale

    love.graphics.push()
    love.graphics.translate(anim.shake_x, anim.shake_y)

    -- Background — adapts to current theme
    local renderer = require("renderer")
    local theme_bg = renderer.getThemeBgColor()
    if theme_bg then
        love.graphics.setColor(theme_bg)
    else
        love.graphics.setColor(colors.bg)
    end
    love.graphics.rectangle("fill", -10, -10, w + 20, h + 20)

    -- Draw background tile grid
    for _, tile in ipairs(anim.tile_data) do
        if tile.scale > 0.01 then
            love.graphics.push()
            local cx = tile.x + tile.size / 2
            local cy = tile.y + tile.size / 2
            love.graphics.translate(cx, cy)
            love.graphics.rotate(tile.rotation)
            love.graphics.scale(tile.scale, tile.scale)

            love.graphics.setColor(tile.color[1], tile.color[2], tile.color[3], 0.6 * (tile.alpha or 1))
            roundedRect("fill", -tile.size / 2, -tile.size / 2, tile.size, tile.size, tile.corner_r)

            love.graphics.pop()
        end
    end

    -- Draw logo
    if anim.logo_scale > 0.01 and anim.logo_alpha > 0 then
        love.graphics.setColor(1, 1, 1, anim.logo_alpha)
        local logo_w, logo_h = logo:getWidth(), logo:getHeight()
        local logo_display_size = math.min(w, h) * 0.35
        local logo_sx = (logo_display_size / logo_w) * anim.logo_scale
        local logo_sy = (logo_display_size / logo_h) * anim.logo_scale

        -- Subtle floating bob
        local bob = math.sin(love.timer.getTime() * 2.5) * 3 * scale

        love.graphics.draw(logo,
            w / 2, h / 2 + bob,
            0,
            logo_sx, logo_sy,
            logo_w / 2, logo_h / 2)
    end

    -- Draw exit particles
    -- Using normal alpha blending so they are beautifully visible on the light background!
    local dt = love.timer.getDelta()
    for i = #anim.exit_particles, 1, -1 do
        local p = anim.exit_particles[i]

        -- Physics update
        p.vx = p.vx * p.drag
        p.vy = p.vy * p.drag
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 250 * dt  -- gravity
        p.life = p.life - dt * (p.type == "spark" and 1.1 or 1.4)
        p.rotation = p.rotation + p.rot_speed * dt

        if p.life <= 0 then
            table.remove(anim.exit_particles, i)
        else
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)

            -- Smooth fade out
            local alpha = math.min(1, p.life * 2)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)

            if p.type == "chunk" then
                -- Spinning tile chunks shrink as they die
                local s = p.size * math.min(1, p.life)
                roundedRect("fill", -s / 2, -s / 2, s, s, s * 0.15)
            else
                -- Sparks stretch dynamically based on their speed for motion blur effect
                local speed = math.sqrt(p.vx * p.vx + p.vy * p.vy)
                local stretch = math.max(1, speed / 50)
                love.graphics.rotate(-p.rotation) -- undo previous arbitrary rotation
                love.graphics.rotate(math.atan2(p.vy, p.vx)) -- perfectly align with velocity
                love.graphics.rectangle("fill", -p.size * stretch / 2, -p.size / 2, p.size * stretch, p.size, p.size / 2, p.size / 2)
            end

            love.graphics.pop()
        end
    end

    -- Draw thick double golden shockwave rings
    if anim.exit_ring_r > 0 then
        local ring_alpha = math.max(0, 1 - anim.exit_ring_r / (math.max(w, h) * 1.2))
        love.graphics.setColor(colors.gold[1], colors.gold[2], colors.gold[3], ring_alpha * 0.8)
        love.graphics.setLineWidth(math.max(2, 20 * ring_alpha))
        love.graphics.circle("line", w / 2, h / 2, anim.exit_ring_r)

        -- Inner secondary shockwave for depth
        if anim.exit_ring_r > 50 then
            love.graphics.setColor(colors.super[1], colors.super[2], colors.super[3], ring_alpha * 0.5)
            love.graphics.setLineWidth(math.max(1, 10 * ring_alpha))
            love.graphics.circle("line", w / 2, h / 2, anim.exit_ring_r * 0.8)
        end
    end

    -- Intense screen flash overlay
    if anim.exit_flash > 0 then
        love.graphics.setColor(colors.gold[1], colors.gold[2], colors.gold[3], anim.exit_flash * 0.4)
        love.graphics.rectangle("fill", -10, -10, w + 20, h + 20)
    end

    love.graphics.pop()
end

function splash.skip()
    if not splash.finished then
        local sound = require("sound")
        sound.stopSplash()
        splash.finished = true
        splash.is_revealing = false
        timer.clear()
    end
end

return splash
