local MOON_PHASES = 8
local MOON_PHASES_HALF = MOON_PHASES / 2
local SHEET_W = 4
local SHEET_H = 2

-- Randomize initial moon phase, based on map seed
local mg_seed = core.get_mapgen_setting("seed")
local rand = PcgRandom(mg_seed)
local phase_offset = rand:next(0, MOON_PHASES - 1)

core.log("info", "[mcl_moon] Moon phase offset of this world: "..phase_offset)

mcl_moon = {}
mcl_moon.MOON_PHASES = MOON_PHASES

function mcl_moon.get_moon_phase()
	local after_midday = 0
	-- Moon phase changes after midday
	local tod = core.get_timeofday()
	if tod > 0.5 then
		after_midday = 1
	end
	return (core.get_day_count() + phase_offset + after_midday) % MOON_PHASES
end

local function get_moon_texture()
	local phase = mcl_moon.get_moon_phase()
	local x = phase % MOON_PHASES_HALF
	local y
	if phase >= MOON_PHASES_HALF then
		y = 1
	else
		y = 0
	end
	return "mcl_moon_moon_phases.png^[sheet:"..SHEET_W.."x"..SHEET_H..":"..x..","..y
end

mcl_moon.get_moon_texture = get_moon_texture

function mcl_moon.get_moon_brightness ()
	local phase = mcl_moon.get_moon_phase ()
	return math.abs (phase - 4) / 4
end

local timer = 0
local last_reported_phase = nil
core.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 8 then
		return
	end
	timer = 0
	local phase = mcl_moon.get_moon_phase()
	-- No-op when moon phase didn't change yet
	if last_reported_phase == phase then
		return
	end
	core.log("info", "[mcl_moon] New moon phase: "..phase)
	last_reported_phase = phase
	local texture = get_moon_texture ()
	local moon_arg = {
		texture = texture,
	}
	local tbl = {
		moon_texture = texture,
	}
	for pl in mcl_util.connected_players() do
		if mcl_serverplayer.is_csm_at_least (pl, 3) then
			mcl_serverplayer.send_effect_ctrl (pl, tbl)
		else
			pl:set_moon(moon_arg)
		end
	end
end)

core.register_on_joinplayer(function(player)
	player:set_moon({texture = get_moon_texture(), scale=3.75})
end)
