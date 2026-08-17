-- Always-on CPU opts that do not change stock desktop visuals.
-- Disable with BALATRO_PM_SKIP_CPU_OPT=1 (or G.BALATRO_PM_SKIP_CPU_OPT).
--
-- Performance On still owns CRT/bloom/shadows, reduced motion, particle
-- thinning, background cache, and DynaText shortcuts.
--
-- Frame rate: BALATRO_PM_FPS_CAP=60|40|30 (also Settings → Video, and display setup).

local SKIP = G.BALATRO_PM_SKIP_CPU_OPT
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_CPU_OPT') == '1'
end
if SKIP then return end

local SETUP_FILE = os.getenv('BALATRO_PM_SETUP_FILE')
local FPS_OPTIONS = {60, 40, 30}

local function normalize_fps(raw)
    local n = tonumber(raw)
    if n == 30 or n == 40 or n == 60 then return n end
    return 60
end

local function fps_option_index(cap)
    for i = 1, #FPS_OPTIONS do
        if FPS_OPTIONS[i] == cap then return i end
    end
    return 1
end

local function upsert_setup_key(key, value)
    if not SETUP_FILE then return end
    local lines, found = {}, false
    local file = io.open(SETUP_FILE, 'r')
    if file then
        for line in file:lines() do
            if line:match('^%s*' .. key .. '%s*=') then
                lines[#lines + 1] = key .. '=' .. value
                found = true
            else
                lines[#lines + 1] = line
            end
        end
        file:close()
    end
    if not found then lines[#lines + 1] = key .. '=' .. value end
    file = io.open(SETUP_FILE, 'w')
    if not file then return end
    for i = 1, #lines do file:write(lines[i], '\n') end
    file:close()
end

local function apply_fps_cap(cap)
    cap = normalize_fps(cap)
    G.FPS_CAP = cap
    return cap
end

apply_fps_cap(os.getenv('BALATRO_PM_FPS_CAP'))

local gc_previous_heap = collectgarbage('count')

-- Stock Card creates children.shadow as a Moveable that is never read for
-- drawing (shadows use G.shared_shadow from center/back). Each one still sits
-- in G.MOVEABLES and gets move/update every frame — ~1 dead entry per card.
local function drop_unused_card_shadow(card)
    local shadow = card and card.children and card.children.shadow
    if not shadow then return end
    pcall(function() shadow:remove() end)
    card.children.shadow = nil
end

local original_card_init = Card.init
function Card:init(...)
    original_card_init(self, ...)
    drop_unused_card_shadow(self)
end

local original_card_load = Card.load
function Card:load(...)
    local result = original_card_load(self, ...)
    drop_unused_card_shadow(self)
    return result
end

-- Recreating a legendary floating_sprite without removing the old Sprite
-- leaves the previous one in G.MOVEABLES forever.
local original_card_set_sprites = Card.set_sprites
function Card:set_sprites(_center, _front, ...)
    if _center and _center.soul_pos and self.children and self.children.floating_sprite then
        pcall(function() self.children.floating_sprite:remove() end)
        self.children.floating_sprite = nil
    end
    return original_card_set_sprites(self, _center, _front, ...)
end

-- Periodic full GC: stock nuGC stops the collector every frame after a small
-- step, so native Text leaks / Lua garbage can pile up across a long run.
local FULL_GC_INTERVAL = 30
local next_full_gc_at = 0
local original_game_update_gc = Game.update
function Game:update(dt, ...)
    local result = original_game_update_gc(self, dt, ...)
    local now = (G.TIMERS and G.TIMERS.REAL) or 0
    if now >= next_full_gc_at then
        next_full_gc_at = now + FULL_GC_INTERVAL
        collectgarbage('collect')
        gc_previous_heap = collectgarbage('count')
    end
    return result
end

G.FUNCS.pm_change_fps_cap = function(args)
    local cap = apply_fps_cap(args and args.to_val)
    upsert_setup_key('fps', tostring(cap))
end

if G.UIDEF and type(G.UIDEF.settings_tab) == 'function' then
    local original_settings_tab = G.UIDEF.settings_tab
    function G.UIDEF.settings_tab(tab, ...)
        local definition = original_settings_tab(tab, ...)
        if tab == 'Video' and type(definition) == 'table' and
           type(definition.nodes) == 'table' then
            table.insert(definition.nodes, create_option_cycle({
                label = 'Frame rate',
                scale = 0.8,
                w = 4,
                options = FPS_OPTIONS,
                opt_callback = 'pm_change_fps_cap',
                current_option = fps_option_index(normalize_fps(G.FPS_CAP)),
            }))
        end
        return definition
    end
end

local function is_idle_pile_card(card)
    local area = card.area
    if not area then return false end

    -- Deck browser copies live in temporary CardAreas (config.view_deck).
    if area.config and area.config.view_deck then
        return not card.states.focus.is and not card.children.focused_ui and
            not card.states.drag.is and card.STATIONARY
    end

    -- Face-down deck/discard pile. Keep skipping while the deck overlay is
    -- open: view_deck draws copies, not these cards.
    if area ~= G.deck and area ~= G.discard then return false end
    return card.facing == 'back' and card.sprite_facing == 'back' and
        not card.pinch.x and not card.states.focus.is and
        not card.children.focused_ui
end

local original_card_update = Card.update
function Card:update(dt)
    -- Settled deck/discard cards are not drawn; skip their per-frame Lua work.
    -- Mid-flight discard still moves via Moveable.move; flips keep pinch.x set.
    if is_idle_pile_card(self) then
        if self.ability and self.ability.perma_debuff then self.debuff = true end
        return
    end
    return original_card_update(self, dt)
end

-- Deck/discard align has no sin-wave sway (unlike hand/jokers), so caching when
-- the pile is stable is safe with Performance Off.
local original_cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards(...)
    local pile = (self == G.deck or self == G.discard) and
        (self.shuffle_amt or 0) == 0
    if not pile then
        return original_cardarea_align_cards(self, ...)
    end

    local cache = self.pm_cpu_pile_alignment
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
    self.pm_cpu_pile_alignment = cache or {}
    cache = self.pm_cpu_pile_alignment
    cache.count, cache.x, cache.y = #self.cards, self.T.x, self.T.y
    cache.w, cache.h = self.T.w, self.T.h
    return result
end

local GC_MIN_STEP_KB = 16
local GC_MAX_STEP_KB = 1024
local GC_SOFT_CEILING_KB = 48*1024
local GC_HARD_CEILING_KB = 96*1024

-- Stock nuGC stops the collector every frame. Unreleased Love Text objects
-- then sit until a rare full collect, and FPS sags with a flat mv count.
-- Keep incremental GC running and full-collect sooner.
function nuGC(_, memory_ceiling, disable_otherwise)
    collectgarbage('restart')
    local heap = collectgarbage('count')

    local allocated = heap - gc_previous_heap
    local step = allocated > GC_MIN_STEP_KB and allocated or GC_MIN_STEP_KB
    if heap > GC_SOFT_CEILING_KB then step = step*3 end
    if step > GC_MAX_STEP_KB then step = GC_MAX_STEP_KB end
    collectgarbage('step', step)

    if heap > (memory_ceiling and memory_ceiling*1024 or GC_HARD_CEILING_KB) then
        collectgarbage('collect')
    end

    gc_previous_heap = collectgarbage('count')
end
