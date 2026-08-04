local PERF_OPTIMIZATIONS = G.BALATRO_PM_PERF_OPTIMIZATIONS
if PERF_OPTIMIZATIONS == nil then
    PERF_OPTIMIZATIONS = os.getenv('BALATRO_PM_PERF_OPTIMIZATIONS') ~= '0'
end

local LITE_GRAPHICS = 'pm_lite_graphics'

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
G.F_HIDE_BG = true
G.FPS_CAP = 60

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

use_smooth_filtering()

local original_start_up = Game.start_up
function Game:start_up(...)
    local result = original_start_up(self, ...)
    self.SETTINGS.GRAPHICS.crt = 0
    self.SETTINGS.GRAPHICS.bloom = 0
    self.SETTINGS.GRAPHICS.shadows = 'Off'
    self.SETTINGS.screenshake = false
    self.SETTINGS.reduced_motion = true

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

if PERF_OPTIMIZATIONS then
local GC_MIN_STEP_KB = 16
local GC_MAX_STEP_KB = 1024
local GC_SOFT_CEILING_KB = 128*1024
local GC_HARD_CEILING_KB = 224*1024

local gc_previous_heap = collectgarbage('count')

function nuGC(_, memory_ceiling, disable_otherwise)
    local heap = collectgarbage('count')

    local allocated = heap - gc_previous_heap
    local step = allocated > GC_MIN_STEP_KB and allocated or GC_MIN_STEP_KB
    if heap > GC_SOFT_CEILING_KB then step = step*3 end
    if step > GC_MAX_STEP_KB then step = GC_MAX_STEP_KB end
    collectgarbage('step', step)

    if heap > (memory_ceiling and memory_ceiling*1024 or GC_HARD_CEILING_KB) then
        collectgarbage('collect')
    end
    if disable_otherwise then collectgarbage('stop') end

    gc_previous_heap = collectgarbage('count')
end
end

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
