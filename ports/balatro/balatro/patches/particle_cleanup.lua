-- Always-on fix for particle emitters left in G.MOVEABLES.
-- Disable with BALATRO_PM_SKIP_PARTICLE_CLEANUP=1 (or G.BALATRO_PM_SKIP_PARTICLE_CLEANUP).
--
-- 1) Blind:defeat creates Particles and only sets max=0 — never :remove()'s them.
-- 2) Other max=0 emitters can finish pulsing and sit empty forever in MOVEABLES.
--
-- Attention-text cover emitters use max=0 + pulse_max on purpose while pulsing;
-- we only reap when pulsing is done and no particles remain.

local SKIP = G.BALATRO_PM_SKIP_PARTICLE_CLEANUP
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_PARTICLE_CLEANUP') == '1'
end
if SKIP then return end

local REAP_INTERVAL = 2.0
local next_reap_at = 0

local function is_particles(obj)
    return obj and not obj.REMOVED and getmetatable(obj) == Particles
end

local function remove_particles_from(node)
    if not node or type(node.children) ~= 'table' then return end

    local found = {}
    for _, child in pairs(node.children) do
        if is_particles(child) then
            found[#found + 1] = child
        end
    end
    for i = 1, #found do
        pcall(function() found[i]:remove() end)
    end
    node.children.particles = nil
end

-- Empty emitters that have stopped spawning (max=0) and finished any pulse burst.
local function is_spent_emitter(obj)
    if not is_particles(obj) then return false end
    if obj.max ~= 0 then return false end
    if (obj.pulsed or 0) < (obj.pulse_max or 0) then return false end
    if obj.particles and #obj.particles > 0 then return false end
    return true
end

local function reap_spent_particle_emitters()
    if type(G.MOVEABLES) ~= 'table' then return end
    local doomed = {}
    for _, obj in pairs(G.MOVEABLES) do
        if is_spent_emitter(obj) then
            doomed[#doomed + 1] = obj
        end
    end
    for i = 1, #doomed do
        pcall(function() doomed[i]:remove() end)
    end
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
        pcall(reap_spent_particle_emitters)
    end
    return result
end
