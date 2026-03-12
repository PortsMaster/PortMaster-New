if not core.global_exists ("mcl_end") then
	mcl_end = {}
end

------------------------------------------------------------------------
-- Routines common to map generation and main environments.
------------------------------------------------------------------------

local insert = table.insert
local band = bit.band

local floor = math.floor
local mathcos = math.cos
local mathsin = math.sin
local pi = math.pi

local ull = mcl_levelgen.ull
local extull = mcl_levelgen.extull
local spike_rng = mcl_levelgen.jvm_random (ull (0, 0))
local fisher_yates = mcl_levelgen.fisher_yates

function mcl_end.get_spikes (preset)
	if preset.end_spikes then
		return preset.end_spikes
	end

	spike_rng:reseed (preset.seed)
	local value = band (spike_rng:next_long ()[1], 0xffff)
	local sizes = {
		0,
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
	}
	spike_rng:reseed (extull (value))
	fisher_yates (sizes, spike_rng)

	local spikes = {}
	for i = 0, 9 do
		-- https://minecraft.wiki/w/End_spike#Construction
		local angle = 2.0 * (-pi + (pi / 10) * i)
		local x = floor (42.0 * mathcos (angle))
		local z = floor (42.0 * mathsin (angle))
		local size = sizes[i + 1]
		local radius = floor (2 + size / 3)
		local height = 76 + size * 3
		local guarded = size == 1 or size == 2

		insert (spikes, {
			center_x = x,
			center_z = z,
			radius = radius,
			height = height,
			guarded = guarded,
		})
	end
	preset.end_spikes = spikes
	return spikes
end
