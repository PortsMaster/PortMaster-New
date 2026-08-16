-- Enable controller rumble on Linux/PortMaster (stock only sets F_RUMBLE on consoles).
-- Shows Settings → Game → Controller Vibration and drives setVibration.
-- Disable with BALATRO_PM_SKIP_RUMBLE=1 (or G.BALATRO_PM_SKIP_RUMBLE).
-- Optional intensity: BALATRO_PM_RUMBLE=0.7 (Switch default); must be > 0.
--
-- Note: globals.lua does `G = Game()` (and set_globals) before portmaster modules
-- load, so we must patch G immediately and again at start_up — not only hook
-- set_globals after the fact.

local SKIP = G.BALATRO_PM_SKIP_RUMBLE
if SKIP == nil then
    SKIP = os.getenv('BALATRO_PM_SKIP_RUMBLE') == '1'
end
if SKIP then return end

local intensity = tonumber(os.getenv('BALATRO_PM_RUMBLE') or '') or 0.7
if intensity <= 0 then return end

local function enable_rumble(game)
    if not game then return end
    game.F_RUMBLE = intensity
    if game.SETTINGS and game.SETTINGS.rumble == nil then
        game.SETTINGS.rumble = true
    end
end

-- Already constructed in globals.lua before this require.
enable_rumble(G)

local original_set_globals = Game.set_globals
function Game:set_globals(...)
    local result = original_set_globals(self, ...)
    enable_rumble(self)
    return result
end

local original_start_up = Game.start_up
function Game:start_up(...)
    -- Must be set before stock start_up binds the gamepad when F_RUMBLE is set.
    enable_rumble(self)
    local result = original_start_up(self, ...)
    if self.SETTINGS.rumble == nil then
        self.SETTINGS.rumble = true
    end
    return result
end
