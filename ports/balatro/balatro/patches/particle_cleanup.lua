-- Always-on fix for Blind:defeat leaving Particles in G.MOVEABLES.
-- Disable with BALATRO_PM_SKIP_PARTICLE_CLEANUP=1 (or G.BALATRO_PM_SKIP_PARTICLE_CLEANUP).
--
-- Scope is intentionally narrow: only Blind hooks. A global Particles auto-reap
-- would be unsafe because attention_text cover emitters are created with max = 0
-- and pulse_max > 0 on purpose.

local SKIP = G.BALATRO_PM_SKIP_PARTICLE_CLEANUP
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_PARTICLE_CLEANUP') == '1'
end
if SKIP then return end

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
        -- Same API the game already uses in Card:start_materialize.
        pcall(function() found[i]:remove() end)
    end
    node.children.particles = nil
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
    -- Drop leftovers from a previous blind before stock creates a new emitter.
    remove_particles_from(self)
    return original_defeat(self, ...)
end
