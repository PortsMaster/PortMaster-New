-- Everything the port does for frame rate, and nothing else.
--
-- Two kinds of thing live here. The first is the effects: CRT, bloom, shadows,
-- screen shake and continuous motion are turned off, the two full-screen
-- shaders are trimmed, and the small texture sheets are used. The second is the
-- work behind an unchanged frame: caches for results that cannot have changed,
-- and garbage collection paced against what the frame actually allocated.
--
-- None of it depends on the room the game is drawn into, which is why it is
-- here rather than in the layout: choosing the original Balatro layout is a
-- choice about how the screen is arranged, and choosing this is a choice about
-- what that screen costs. Either answer goes with either layout.
--
-- The launcher's display setup decides whether this is taken. Answering "off"
-- also leaves the game's own source and shaders unpatched, so both halves of
-- the change come and go together. This file is loaded either way: with the
-- answer "off" its only job is to hand back the settings the other answer took.
local PERF_OPTIMIZATIONS = G.BALATRO_PM_PERF_OPTIMIZATIONS
if PERF_OPTIMIZATIONS == nil then
    PERF_OPTIMIZATIONS = os.getenv('BALATRO_PM_PERF_OPTIMIZATIONS') ~= '0'
end

-- Balatro keeps its graphics settings in the profile, so the ones this turns
-- down outlive the answer that asked for them: a player who later says "off"
-- would still have reduced motion and no CRT, and no reason to think the port
-- had done it. So record that the port set them, and hand them back on the
-- first launch after the answer changes. Cleared once returned, which is what
-- keeps this from overriding a player who then turns them down themselves.
local LITE_GRAPHICS = 'pm_lite_graphics'

-- Balatro's own defaults, from globals.lua. Reduced motion has none there --
-- absent is off.
local STOCK_GRAPHICS = {crt = 70, bloom = 1, shadows = 'On', texture_scaling = 2}

if not PERF_OPTIMIZATIONS then
local original_start_up_restore = Game.start_up
function Game:start_up(...)
    local result = original_start_up_restore(self, ...)
    if self.SETTINGS[LITE_GRAPHICS] then
        self.SETTINGS[LITE_GRAPHICS] = nil
        for key, value in pairs(STOCK_GRAPHICS) do
            self.SETTINGS.GRAPHICS[key] = value
        end
        self.SETTINGS.screenshake = true
        self.SETTINGS.reduced_motion = false
        self:set_render_settings()
        self:save_settings()
    end
    return result
end
end

if PERF_OPTIMIZATIONS then
-- Skips drawing the playfield behind an open overlay menu, which is a whole
-- frame's worth of card and UI drawing that nothing can be seen of. Stock turns
-- this on for its own small-screen platforms.
G.F_HIDE_BG = true
-- Stock leaves this at 500. Frames a handheld panel cannot show are frames its
-- battery paid for.
G.FPS_CAP = 60

-- Stock ties the texture filter to the atlas choice: asking for the 1x sheets
-- also switches sampling to nearest, and asking for 2x switches it to linear
-- (Game:set_render_settings). That pairing assumes the small sheets are drawn at
-- their own size. On a 480p panel they are not: the room puts 37.5 pixels in a
-- tile, so a 71 pixel card sprite is drawn at about 77, and a card in the hand
-- at 96. Nearest-neighbour magnification of a sprite that is both upscaled and
-- rotated -- the hand fans its cards -- is what turns every edge into stairs. A
-- 768p panel takes the 2x sheets, samples them down, and never shows it, which
-- is why the same build looks clean on one device and ragged on another.
--
-- Keep the memory the small sheets save and take the smoothing back. Fonts get
-- it too: they are built from the same default, one call later in Game:init.
local function use_smooth_filtering()
    love.graphics.setDefaultFilter('linear', 'linear', 1)
    for _, set in ipairs({G.ASSET_ATLAS, G.ANIMATION_ATLAS}) do
        for _, atlas in pairs(set or {}) do
            if atlas.image then atlas.image:setFilter('linear', 'linear') end
        end
    end
    for _, font in ipairs(G.FONTS or {}) do
        if font.FONT then font.FONT:setFilter('linear', 'linear') end
    end
end

local original_set_render_settings = Game.set_render_settings
function Game:set_render_settings(...)
    local result = original_set_render_settings(self, ...)
    use_smooth_filtering()
    return result
end

-- Once for what already exists: globals.lua builds G, and so loads every atlas
-- before this file is read.
use_smooth_filtering()

-- Saved desktop graphics settings otherwise override the launcher's defaults.
-- Each of these is a per-frame cost on a handheld GPU: crt and bloom are
-- full-screen shader work, shadows double every card's draw calls, and reduced
-- motion drops the per-letter and per-card wobble -- and holds the table
-- background still, which is what lets it be drawn once and reused below.
local original_start_up = Game.start_up
function Game:start_up(...)
    local result = original_start_up(self, ...)
    self.SETTINGS.GRAPHICS.crt = 0
    self.SETTINGS.GRAPHICS.bloom = 0
    self.SETTINGS.GRAPHICS.shadows = 'Off'
    self.SETTINGS.screenshake = false
    self.SETTINGS.reduced_motion = true

    -- The small sheets on every panel, not just the small ones: 26MB of texture
    -- against 105MB, and the sampling bandwidth that goes with it. That is the
    -- largest single saving available here, and on these GPUs it buys more than
    -- the sharper art costs.
    --
    -- It is a real cost, though. A 768p panel draws a card about 123 pixels wide
    -- against the 1x sheet's 71, and a card in the hand about 154 -- so the art
    -- is magnified rather than sampled down, and the linear filtering above
    -- smooths that rather than sharpening it. Saved so the reload happens once,
    -- not per boot, and alongside the note that the port is what set it.
    local atlas = 1
    if self.SETTINGS.GRAPHICS.texture_scaling ~= atlas or
       not self.SETTINGS[LITE_GRAPHICS] then
        self.SETTINGS.GRAPHICS.texture_scaling = atlas
        self.SETTINGS[LITE_GRAPHICS] = true
        self:set_render_settings()
        self:save_settings()
    end
    return result
end

-- A DynaText normally walks and realigns every glyph on every update. Reduced
-- motion suppresses all continuous glyph animation, so static strings only need
-- alignment on their first update or after their text changes. Pop timing and
-- multi-string cycles keep the original per-frame path until they settle.
local original_dyna_text_update = DynaText.update
function DynaText:update(dt)
    if not G.SETTINGS.reduced_motion then
        return original_dyna_text_update(self, dt)
    end

    local focused = self.strings[self.focused_string]
    local previous_string = focused and focused.string
    self:update_text()
    focused = self.strings[self.focused_string]
    local current_string = focused and focused.string
    if not self.pm_perf_letters_aligned or
       previous_string ~= current_string or self.config.pop_in or
       self.config.pop_out or self.pop_cycle then
        self:align_letters()
        self.pm_perf_letters_aligned = true
    else
        self.string = current_string
    end
end

-- UI object nodes force their DynaText child to recalculate movement every
-- frame. Once the node has updated, release that force: normal parent movement,
-- text-size changes, alignment changes, and juice still wake Moveable itself.
local original_ui_element_update_object = UIElement.update_object
function UIElement:update_object(...)
    local result = original_ui_element_update_object(self, ...)
    local object = self.config.object
    if G.SETTINGS.reduced_motion and object and
       getmetatable(object) == DynaText then
        object.config.refresh_movement = false
    end
    return result
end

-- Settled face-down cards in the live draw pile need no per-card tooltip or
-- status maintenance. Resume the full update immediately for a flip, deck
-- inspection, focus, or as soon as a card moves to any other area. Permanent
-- debuffs remain enforced; deck/card-area input handling is unchanged.
local original_card_update = Card.update
function Card:update(dt)
    if G.SETTINGS.reduced_motion and self.area == G.deck and
       not G.VIEWING_DECK and self.facing == 'back' and
       self.sprite_facing == 'back' and not self.pinch.x and
       not self.states.focus.is and not self.children.focused_ui then
        if self.ability and self.ability.perma_debuff then self.debuff = true end
        return
    end
    return original_card_update(self, dt)
end

-- Once the draw pile and all of its cards have settled, its absolute target
-- positions are unchanged. Avoid rewriting every buried card's target each
-- frame, but invalidate immediately for pile motion, shuffling, count changes,
-- dragging, a face-up card, or deck inspection.
local original_cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards(...)
    if not (G.SETTINGS.reduced_motion and self == G.deck and
            not G.VIEWING_DECK and (self.shuffle_amt or 0) == 0) then
        return original_cardarea_align_cards(self, ...)
    end

    local cache = self.pm_perf_deck_alignment
    local stable = cache and cache.count == #self.cards and
        cache.x == self.T.x and cache.y == self.T.y and
        cache.w == self.T.w and cache.h == self.T.h
    if stable then
        for i = 1, #self.cards do
            local card = self.cards[i]
            if card.states.drag.is or card.facing == 'front' or
               not card.STATIONARY then
                stable = false
                break
            end
        end
    end
    if stable then return end

    local result = original_cardarea_align_cards(self, ...)
    self.pm_perf_deck_alignment = cache or {}
    cache = self.pm_perf_deck_alignment
    cache.count, cache.x, cache.y = #self.cards, self.T.x, self.T.y
    cache.w, cache.h = self.T.w, self.T.h
    return result
end

-- Keep the RNG stream and the particle system's logical capacity exactly as the
-- stock game expects, but make every third visual particle a lightweight ghost.
-- Creation still consumes every random value; ghosts age out on the same frame,
-- while avoiding movement math and draw calls for one third of the density.
local original_particles_update = Particles.update
function Particles:update(dt)
    local old_count = #self.particles
    local result = original_particles_update(self, dt)
    for i = old_count + 1, #self.particles do
        self.pm_perf_particle_sequence =
            (self.pm_perf_particle_sequence or 0) + 1
        if self.pm_perf_particle_sequence % 3 == 0 then
            self.particles[i].pm_perf_ghost = true
            self.particles[i].draw = false
        end
    end
    return result
end

function Particles:move(dt)
    if G.SETTINGS.paused and not self.created_on_pause then return end

    Moveable.move(self, dt)
    if self.timer_type ~= 'REAL' then dt = dt*G.SPEEDFACTOR end

    for i = #self.particles, 1, -1 do
        local particle = self.particles[i]
        particle.age = particle.age + dt

        if particle.pm_perf_ghost then
            particle.draw = false
            if particle.age > self.lifespan then
                table.remove(self.particles, i)
            end
        else
            particle.draw = true
            particle.e_vel = particle.e_vel or dt*self.scale
            particle.e_prev = particle.e_curr
            particle.e_curr = math.min(2*math.min(
                (particle.age/self.lifespan)*self.scale,
                self.scale*((self.lifespan - particle.age)/self.lifespan)),
                self.scale)
            particle.e_vel = (particle.e_curr - particle.e_prev)*self.scale*dt +
                (1-self.scale*dt)*particle.e_vel
            particle.scale = particle.scale + particle.e_vel
            particle.scale = math.min(2*math.min(
                (particle.age/self.lifespan)*self.scale,
                self.scale*((self.lifespan - particle.age)/self.lifespan)),
                self.scale)

            if particle.scale < 0 then
                table.remove(self.particles, i)
            else
                particle.offset.x = particle.offset.x +
                    particle.velocity*math.sin(particle.dir)*dt
                particle.offset.y = particle.offset.y +
                    particle.velocity*math.cos(particle.dir)*dt
                particle.facing = particle.facing + particle.r_vel*dt
                particle.velocity = math.max(0,
                    particle.velocity - particle.velocity*0.07*dt)
            end
        end
    end
end
end

-- With reduced motion, REAL_SHADER is fixed at 300 and the background's spin
-- settles to a constant. Render that stable two-iteration shader once and reuse
-- one normal-format framebuffer until any shader input changes. Palette eases
-- still render live into the cache on every changed frame, then settle again.
local background_cache = {
    canvas = nil,
    width = 0,
    height = 0,
    disabled_width = 0,
    disabled_height = 0,
    key = {},
}

local function release_background_cache()
    if background_cache.canvas then
        background_cache.canvas:release()
        background_cache.canvas = nil
    end
    background_cache.width = 0
    background_cache.height = 0
    background_cache.key[1] = nil
end

local function background_values_match(width, height)
    local key = background_cache.key
    local colours = G.C.BACKGROUND
    return key[1] == width and key[2] == height and
        key[3] == G.TIMERS.REAL_SHADER and key[4] == G.TIMERS.BACKGROUND and
        key[5] == colours.contrast and key[6] == G.ARGS.spin.amount and
        key[7] == colours.C[1] and key[8] == colours.C[2] and
        key[9] == colours.C[3] and key[10] == colours.C[4] and
        key[11] == colours.L[1] and key[12] == colours.L[2] and
        key[13] == colours.L[3] and key[14] == colours.L[4] and
        key[15] == colours.D[1] and key[16] == colours.D[2] and
        key[17] == colours.D[3] and key[18] == colours.D[4]
end

local function remember_background_values(width, height)
    local key = background_cache.key
    local colours = G.C.BACKGROUND
    key[1], key[2] = width, height
    key[3], key[4] = G.TIMERS.REAL_SHADER, G.TIMERS.BACKGROUND
    key[5], key[6] = colours.contrast, G.ARGS.spin.amount
    key[7], key[8], key[9], key[10] =
        colours.C[1], colours.C[2], colours.C[3], colours.C[4]
    key[11], key[12], key[13], key[14] =
        colours.L[1], colours.L[2], colours.L[3], colours.L[4]
    key[15], key[16], key[17], key[18] =
        colours.D[1], colours.D[2], colours.D[3], colours.D[4]
end

local function ensure_background_canvas(width, height)
    if background_cache.canvas and
       (background_cache.width ~= width or background_cache.height ~= height) then
        release_background_cache()
    end
    if background_cache.canvas then return true end
    if background_cache.disabled_width == width and
       background_cache.disabled_height == height then return false end

    local ok, canvas = pcall(love.graphics.newCanvas, width, height, {
        format = 'normal', readable = true, msaa = 0, dpiscale = 1
    })
    if not ok or not canvas then
        background_cache.disabled_width = width
        background_cache.disabled_height = height
        return false
    end
    canvas:setFilter('nearest', 'nearest')
    background_cache.canvas = canvas
    background_cache.width = width
    background_cache.height = height
    background_cache.disabled_width = 0
    background_cache.disabled_height = 0
    return true
end

local function render_background_cache(sprite, width, height)
    local previous_canvas = love.graphics.getCanvas()
    love.graphics.push('all')
    love.graphics.setCanvas(background_cache.canvas)
    love.graphics.origin()
    love.graphics.clear(0, 0, 0, 0)

    local ok, message = pcall(function()
        local step = sprite.draw_steps[1]
        local shader = G.SHADERS.background
        for _, uniform in ipairs(step.send) do
            local value = uniform.val
            if value == nil then
                value = uniform.func and uniform.func() or
                    uniform.ref_table[uniform.ref_value]
            end
            shader:send(uniform.name, value)
        end
        love.graphics.setShader(shader)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', 0, 0, width, height)
        love.graphics.setShader()
    end)
    love.graphics.setCanvas(previous_canvas)
    love.graphics.pop()
    if not ok then error(message) end
end

local function draw_cached_background(sprite)
    love.graphics.push('all')
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(background_cache.canvas, 0, 0)
    love.graphics.pop()

    add_to_drawhash(sprite)
    for key, child in pairs(sprite.children) do
        if key ~= 'h_popup' then child:draw() end
    end
    add_to_drawhash(sprite)
    sprite:draw_boundingrect()
end

if PERF_OPTIMIZATIONS then
local original_sprite_draw = Sprite.draw
function Sprite:draw(overlay)
    local is_background = self == G.SPLASH_BACK and self.draw_steps and
        self.draw_steps[1] and self.draw_steps[1].shader == 'background'
    if not (is_background and G.SETTINGS.reduced_motion and G.CANVAS and
            G.C.BACKGROUND and G.ARGS.spin) then
        return original_sprite_draw(self, overlay)
    end

    local width, height = G.CANVAS:getDimensions()
    if not ensure_background_canvas(width, height) then
        return original_sprite_draw(self, overlay)
    end

    if not background_values_match(width, height) then
        local ok = pcall(render_background_cache, self, width, height)
        if not ok then
            release_background_cache()
            background_cache.disabled_width = width
            background_cache.disabled_height = height
            return original_sprite_draw(self, overlay)
        end
        remember_background_values(width, height)
    end
    return draw_cached_background(self)
end
end

-- Garbage collection paced against allocation rather than against the clock.
--
-- Balatro drives the collector by hand: every frame Game:update calls
-- nuGC(nil, nil, true), which spends a fixed 0.3ms of wall clock taking
-- collectgarbage('step', 1) increments, switches automatic collection off, and
-- forces a full collect only once the heap passes 300MB.
--
-- The slice is the problem. 0.3ms buys hundreds of steps on the desktop the
-- number was chosen on and a small fraction of that on a handheld CPU, while
-- the allocation behind it does not shrink to match: DynaText builds a fresh
-- love.graphics.newText for every letter each time its string changes, and in
-- a run the score, the chips, the mult and the money change constantly. Once a
-- frame allocates more than its slice can collect, the shortfall carries to the
-- next frame and never comes back. The heap climbs for the rest of the run,
-- every collection step has more to walk, and the frame rate sags with it --
-- until the 300MB net finally trips and stops the game dead for a moment, or
-- the player returns to the main menu, where delete_run drops the run's objects
-- in one go and the collector catches up. That the menu fixes it is the tell.
--
-- Sizing the step to what the frame actually allocated keeps the heap level on
-- any CPU: a slow device simply asks for a larger step. Automatic collection
-- stays off, so collection still happens at one predictable point in the frame
-- rather than wherever an allocation trips it, which is what the stock design
-- wanted. The ceilings below are only backstops now that the pacing does the
-- work, and they sit low enough that hitting one is not a visible stall on a
-- device with a handheld's memory.
if PERF_OPTIMIZATIONS then
-- Enough of a step that an idle frame still makes progress, and a cap so one
-- spike -- loading a run, opening the collection -- is caught up over several
-- frames instead of stalling the frame it happened on.
local GC_MIN_STEP_KB = 16
local GC_MAX_STEP_KB = 1024
-- Above this the collector is told to outpace allocation and bring the heap
-- back down; above the hard one it gives up on incremental and sweeps.
local GC_SOFT_CEILING_KB = 128*1024
local GC_HARD_CEILING_KB = 224*1024

local gc_previous_heap = collectgarbage('count')

function nuGC(_, memory_ceiling, disable_otherwise)
    local heap = collectgarbage('count')

    -- What this frame added. Negative when the last step collected more than
    -- was allocated, which is the state worth staying in.
    local allocated = heap - gc_previous_heap
    local step = allocated > GC_MIN_STEP_KB and allocated or GC_MIN_STEP_KB
    if heap > GC_SOFT_CEILING_KB then step = step*3 end
    if step > GC_MAX_STEP_KB then step = GC_MAX_STEP_KB end
    collectgarbage('step', step)

    if heap > (memory_ceiling and memory_ceiling*1024 or GC_HARD_CEILING_KB) then
        collectgarbage('collect')
    end
    if disable_otherwise then collectgarbage('stop') end

    -- Read back after collecting, so next frame measures allocation and not
    -- what this one just reclaimed.
    gc_previous_heap = collectgarbage('count')
end
end

-- Optional readout for diagnosing a slowdown, off unless the launcher asks for
-- it. The two numbers that matter sit side by side: heap is what the collector
-- is keeping up with, and objects is how many live things every frame has to
-- walk -- Game:update iterates G.MOVEABLES twice and the stage's object list
-- once. A heap that climbs while objects holds steady is collection falling
-- behind; objects climbing is something being created during the run and never
-- removed, which is a different bug in a different place.
if os.getenv('BALATRO_PM_PERF_HUD') == '1' then
local hud_font
local hud_frames, hud_elapsed, hud_fps = 0, 0, 0
local hud_line = ''

local original_game_draw_hud = Game.draw
function Game:draw(...)
    local result = original_game_draw_hud(self, ...)

    hud_frames = hud_frames + 1
    hud_elapsed = hud_elapsed + (G.real_dt or 0)
    if hud_elapsed >= 0.5 then
        hud_fps = hud_frames/hud_elapsed
        hud_frames, hud_elapsed = 0, 0
        hud_line = string.format(
            'fps %.0f  heap %.0fMB  moveables %d  stage %d  cards %d',
            hud_fps, collectgarbage('count')/1024, #G.MOVEABLES,
            #(G.STAGE_OBJECTS[G.STAGE] or {}), #(G.I.CARD or {}))
    end
    if hud_line == '' then return result end

    -- Drawn after the frame has been presented, where the canvas and shader are
    -- already cleared, so this cannot disturb anything the game drew.
    hud_font = hud_font or love.graphics.newFont(12)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setShader()
    love.graphics.setFont(hud_font)
    local w = hud_font:getWidth(hud_line) + 8
    local h = hud_font:getHeight() + 4
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle('fill', 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(hud_line, 4, 2)
    love.graphics.pop()
    return result
end
end
