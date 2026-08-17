-- Always-on fix for particle emitters / dead Moveables left in G.MOVEABLES.
-- Disable with BALATRO_PM_SKIP_PARTICLE_CLEANUP=1 (or G.BALATRO_PM_SKIP_PARTICLE_CLEANUP).
--
-- 1) Blind:defeat creates Particles and only sets max=0 — never :remove()'s them.
-- 2) Other max=0 emitters can finish pulsing and sit empty forever in MOVEABLES.
-- 3) Faded emitters (fade_alpha >= 1) often keep spawning until explicitly removed.
-- 4) REMOVED objects can linger in G.MOVEABLES if remove paths race.
--
-- Attention-text cover emitters use max=0 + pulse_max on purpose while pulsing;
-- we only reap when pulsing is done and no particles remain.

local SKIP = G.BALATRO_PM_SKIP_PARTICLE_CLEANUP
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_PARTICLE_CLEANUP') == '1'
end
if SKIP then return end

local REAP_INTERVAL = 1.5
local next_reap_at = 0

local function is_particles(obj)
    return obj and getmetatable(obj) == Particles
end

local function remove_particles_from(node)
    if not node or type(node.children) ~= 'table' then return end

    local found = {}
    for _, child in pairs(node.children) do
        if is_particles(child) and not child.REMOVED then
            found[#found + 1] = child
        end
    end
    for i = 1, #found do
        pcall(function() found[i]:remove() end)
    end
    node.children.particles = nil
end

-- Empty emitters that have stopped spawning and finished any pulse/fade burst.
-- Note: booster sparkles start at fade_alpha=1 and fade *in* to 0 — do not
-- treat fade_alpha alone as spent.
local function is_spent_emitter(obj)
    if not is_particles(obj) or obj.REMOVED then return false end
    if obj.max ~= 0 then return false end
    if (obj.pulsed or 0) < (obj.pulse_max or 0) then return false end
    if obj.particles and #obj.particles > 0 then return false end
    return true
end

local function is_orphan_emitter(obj)
    if not is_particles(obj) or obj.REMOVED then return false end
    local major = obj.role and obj.role.major
    if major and major.REMOVED then return true end
    return false
end

local function strip_from_list(list, obj)
    if type(list) ~= 'table' then return end
    for k, v in pairs(list) do
        if v == obj then
            if type(k) == 'number' then
                table.remove(list, k)
            else
                list[k] = nil
            end
            return
        end
    end
end

local PARTICLE_CAP = 48

local function trim_emitter_particles(obj)
    if not is_particles(obj) or obj.REMOVED then return end
    local particles = obj.particles
    if type(particles) ~= 'table' then return end
    local extra = #particles - PARTICLE_CAP
    if extra <= 0 then return end
    for i = 1, PARTICLE_CAP do
        particles[i] = particles[i + extra]
    end
    for i = PARTICLE_CAP + 1, #particles do
        particles[i] = nil
    end
end

local function compact_removed(list)
    if type(list) ~= 'table' then return end
    for i = #list, 1, -1 do
        local obj = list[i]
        if not obj or obj.REMOVED then
            table.remove(list, i)
        end
    end
    for k, obj in pairs(list) do
        if type(k) ~= 'number' and (not obj or obj.REMOVED) then
            list[k] = nil
        end
    end
end

local function reap_moveable_garbage()
    if type(G.MOVEABLES) ~= 'table' then return end
    local doomed = {}
    for _, obj in pairs(G.MOVEABLES) do
        if not obj then
            -- skip
        elseif obj.REMOVED then
            doomed[#doomed + 1] = obj
        elseif is_spent_emitter(obj) or is_orphan_emitter(obj) then
            doomed[#doomed + 1] = obj
        else
            trim_emitter_particles(obj)
        end
    end
    for i = 1, #doomed do
        local obj = doomed[i]
        if obj.REMOVED then
            -- Already torn down; only drop list membership.
            strip_from_list(G.MOVEABLES, obj)
            strip_from_list(G.I and G.I.MOVEABLE, obj)
            strip_from_list(G.I and G.I.SPRITE, obj)
            strip_from_list(G.I and G.I.CARD, obj)
        else
            pcall(function() obj:remove() end)
        end
    end
    if G.I then
        compact_removed(G.I.MOVEABLE)
        compact_removed(G.I.SPRITE)
        compact_removed(G.I.CARD)
        compact_removed(G.I.UIBOX)
        compact_removed(G.I.NODE)
    end
    if G.STAGE_OBJECTS and G.STAGE then
        compact_removed(G.STAGE_OBJECTS[G.STAGE])
    end
end

-- Fading out should stop spawning; otherwise emitters attached to ROOM/cards
-- keep allocating particle tables until something finally :remove()'s them.
local original_particles_fade = Particles.fade
function Particles:fade(delay, to)
    if (to or 1) >= 1 then
        self.max = 0
    end
    return original_particles_fade(self, delay, to)
end

local original_set_blind = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    -- Stock defeat ends with set_blind(nil) after the dissolve; clean there so
    -- the burst can finish first. Also clears orphans when a new blind starts.
    if not reset then
        remove_particles_from(self)
    end
    return original_set_blind(self, blind, reset, silent)
end

local original_defeat = Blind.defeat
function Blind:defeat(...)
    remove_particles_from(self)
    local result = original_defeat(self, ...)
    -- Same timing as Card:start_materialize's particle teardown.
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 1.3,
        func = function()
            remove_particles_from(self)
            return true
        end,
    }))
    return result
end

local original_game_update = Game.update
function Game:update(dt, ...)
    local result = original_game_update(self, dt, ...)
    local now = (G.TIMERS and G.TIMERS.REAL) or 0
    if now >= next_reap_at then
        next_reap_at = now + REAP_INTERVAL
        pcall(reap_moveable_garbage)
    end
    return result
end
