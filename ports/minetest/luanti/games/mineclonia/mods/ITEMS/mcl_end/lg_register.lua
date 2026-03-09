local ipairs = ipairs
local mcl_levelgen = mcl_levelgen
local W = mcl_levelgen.build_weighted_list

------------------------------------------------------------------------
-- End Spike.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/EndSpikeFeature.html
------------------------------------------------------------------------

-- local end_spike_cfg = {
-- 	crystal_invulnerable = nil,
-- 	spikes = {
-- 		{
-- 			center_x = ...,
-- 			center_z = ...,
-- 			radius = ...,
-- 			height = ...,
-- 			guarded = ...,

-- 		},
-- 		...
-- 	},
-- 	crystal_beam_target = ...,
-- }

local insert = table.insert
local band = bit.band

local floor = math.floor
local mathmax = math.max
local mathmin = math.min

local ull = mcl_levelgen.ull
local spike_rng = mcl_levelgen.jvm_random (ull (0, 0))
local ipos3 = mcl_levelgen.ipos3
local set_block = mcl_levelgen.set_block
local notify_generated = mcl_levelgen.notify_generated
local uniform_height = mcl_levelgen.uniform_height
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp

local get_spikes = mcl_end.get_spikes

local function mapblock_distance (x1, z1, x2, z2)
	local bx1 = band (x1, -16)
	local bz1 = band (z1, -16)
	local dx = mathmax (0, x2 - (bx1 + 15), bx1 - x2)
	local dz = mathmax (0, z2 - (bz1 + 15), bz1 - z2)
	return dx * dx + dz * dz
end

local cid_obsidian = core.get_content_id ("mcl_core:obsidian")
local cid_iron_bars = core.get_content_id ("mcl_panes:bar")
local cid_eternal_fire = core.get_content_id ("mcl_fire:eternal_fire")
local cid_bedrock = core.get_content_id ("mcl_core:bedrock")

local cid_air = core.CONTENT_AIR

local function end_spike_place_1 (preset, spike, r, run_min_y, run_max_y)
	local cx, cz = spike.center_x, spike.center_z
	local height = spike.height
	for x, y, z in ipos3 (cx - r,
			      mathmax (preset.min_y, run_min_y),
			      cz - r,
			      cx + r,
			      mathmin (height + 10, run_max_y),
			      cz + r) do
		local d_sqr
			= ((x - cx) * (x - cx) + (z - cz) * (z - cz))
		if d_sqr <= r * r + 1 and y < height then
			set_block (x, y, z, cid_obsidian, 0)
		elseif y > 65 then
			set_block (x, y, z, cid_air, 0)
		end
	end

	-- Cage.

	if spike.guarded then
		for dx, y, dz in ipos3 (-2, mathmax (height, run_min_y), -2,
					2, mathmin (height + 3, run_max_y), 2) do
			local at_corner = dx == -2 or dx == 2
				or dz == -2 or dz == 2
				or y == height + 3
			if at_corner then
				set_block (cx + dx, y, cz + dz, cid_iron_bars, 0)
			end
		end
	end

	-- Fire & bedrock.
	if height + 1 >= run_min_y and height + 1 <= run_max_y then
		set_block (cx, height + 1, cz, cid_eternal_fire, 0)
	end
	if height >= run_min_y and height <= run_max_y then
		set_block (cx, height, cz, cid_bedrock, 0)
	end

	-- End Crystal.
	local minp = run_minp
	local maxp = run_maxp
	if height >= run_min_y
		and height <= run_max_y
		and cx >= minp.x and cx <= maxp.x
		and cz >= minp.z and cz <= maxp.z then
		notify_generated ("mcl_end:spawn_end_crystal", {
			cx, height, cz,
		})
	end
end

local function end_spike_place (_, x, y, z, cfg, rng)
	local preset = mcl_levelgen.placement_level
	local spikes = #cfg.spikes > 0 and cfg.spikes
		or get_spikes (preset)
	local run_min_y = run_minp.y
	local run_max_y = run_maxp.y

	for _, spike in ipairs (spikes) do
		local cx, cz = spike.center_x, spike.center_z
		local r = spike.radius
		if mapblock_distance (x, z, cx, cz) < r * r then
			end_spike_place_1 (preset, spike, r, run_min_y,
					   run_max_y)
		end
	end

	return true
end

mcl_levelgen.register_feature ("mcl_end:end_spike", {
	place = end_spike_place,
})

mcl_levelgen.register_configured_feature ("mcl_end:end_spike", {
	feature = "mcl_end:end_spike",
	crystal_invulnerable = false,
	spikes = {},
})

mcl_levelgen.register_placed_feature ("mcl_end:end_spike", {
	configured_feature = "mcl_end:end_spike",
	placement_modifiers = {
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- End Island.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/EndIslandFeature.html
------------------------------------------------------------------------

local ceil = math.ceil
local cid_end_stone = core.get_content_id ("mcl_end:end_stone")

local function small_end_island_place (_, x, y, z, cfg, rng)
	spike_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end
	local rng = spike_rng
	local r = rng:next_within (3) + 4.0
	local dy = 0
	while r > 0.5 do
		for x1, y1, z1 in ipos3 (x + floor (-r),
					 y + dy,
					 z + floor (-r),
					 x + ceil (r),
					 y + dy,
					 z + ceil (r)) do
			local d = (x1 - x) * (x1 - x)
				+ (z1 - z) * (z1 - z)
			if d <= (r + 1.0) * (r + 1.0) then
				set_block (x1, y1, z1, cid_end_stone, 0)
			end
		end
		dy = dy - 1
		r = r - (rng:next_within (2) + 0.5)
	end
	return true
end

mcl_levelgen.register_feature ("mcl_end:end_island", {
	place = small_end_island_place,
})

mcl_levelgen.register_configured_feature ("mcl_end:end_island", {
	feature = "mcl_end:end_island",
})

mcl_levelgen.register_placed_feature ("mcl_end:end_island_decorated", {
	configured_feature = "mcl_end:end_island",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (14),
		mcl_levelgen.build_count (W ({
			{
				weight = 3,
				data = 1,
			},
			{
				weight = 1,
				data = 2,
			},
		})),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (55, 70)),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Chorus Plant feature.
------------------------------------------------------------------------

local chorus_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

local cid_chorus_plant
	= core.get_content_id ("mcl_end:chorus_plant")
local cid_chorus_flower
	= core.get_content_id ("mcl_end:chorus_flower")
local cid_chorus_flower_dead
	= core.get_content_id ("mcl_end:chorus_flower_dead")

local is_air = mcl_levelgen.is_air
local get_block = mcl_levelgen.get_block

local function is_end_stone (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_end_stone
end

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local band = bit.band

local function unhash (pos)
	return floor (pos / (65536 * 65536)) - 32768,
		band (floor (pos / 65536), 0xffff) - 32768,
		pos % 65536 - 32768
end

local count_adjoining_non_air = mcl_levelgen.count_adjoining_non_air

local function is_chorus_plant (x, y, z)
	local cid, _ = get_block (x, y, z)
	return cid == cid_chorus_plant
end

local MAX_FLOWER_AGE = 5 -- Maximum age of chorus flower before it dies

local dirs = {
	{ -1, 0, },
	{ 1, 0, },
	{ 0, -1, },
	{ 0, 1, },
}

local function grow_chorous_flowers (flowers, out, rng)
	for _, flower in ipairs (flowers) do
		local x, y, z = unhash (flower)
		local solids, _, _ = count_adjoining_non_air (x, y, z)
		local branching = false
		local h = 0
		if solids == 0 then
			for dy = 1, 4 do
				if is_chorus_plant (x, y - dy, z) then
					h = dy
				else
					break
				end
			end
		end

		local grow_chance
		if h <= 1 then
			grow_chance = 1.0
		else
			grow_chance = 0.15
		end

		if grow_chance then
			local inpos = #out + 1
			local written = false
			local _, param2 = get_block (x, y, z)
			local age = param2
			if (grow_chance == 1.0
			    or rng:next_double () < grow_chance) then
				local grow = rng:next_within (4) + 1
				local i_max
				for i = 1, grow do
					if not is_air (x, y + i, z)
						or count_adjoining_non_air (x, y + i, z) > 1 then
						break
					end

					if i > 1 then
						set_block (x, y + i - 1, z, cid_chorus_plant, 0)
					end
					i_max = i
				end
				if i_max then
					insert (out, longhash (x, y + i_max, z))
					written = true
				end
			else
				local branches

				if not branching then
					branches = 1 + rng:next_within (4)
				else
					branches = rng:next_within (4)
				end

				for i = 1, branches do
					local dir = dirs[1 + rng:next_within (4)]
					local x1, z1 = x + dir[1], z + dir[2]
					if is_air (x1, y, z1)
						and count_adjoining_non_air (x1, y, z1) == 1 then
						insert (out, longhash (x1, y, z1))
						written = true
					end
				end
			end

			local i1 = inpos
			for i = inpos, #out do
				local x, y, z = unhash (out[i])
				local cid, _ = get_block (x, y, z)
				if cid ~= cid_chorus_flower
					and cid ~= cid_chorus_flower_dead then
					set_block (x, y, z, cid_chorus_flower_dead, age + 1)
					if age + 1 < MAX_FLOWER_AGE then
						out[i1] = out[i]
						i1 = i1 + 1
					end
				end
			end

			if written then
				set_block (x, y, z, cid_chorus_plant, 0)
			end

			for i = i1, #out do
				out[i] = nil
			end
		end
	end
end

local function grow_chorus_plant (x, y, z, rng)
	set_block (x, y, z, cid_chorus_flower, 0)
	local flowers = {
		longhash (x, y, z),
	}
	local flowers_next = {}
	for i = 1, 45 do
		grow_chorous_flowers (flowers, flowers_next, rng)
		flowers, flowers_next = flowers_next, flowers
		if #flowers == 0 then
			return
		end
		for i = 1, #flowers_next do
			flowers_next[i] = nil
		end
	end
end

local function chorus_plant_place (_, x, y, z, cfg, rng)
	chorus_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end
	local rng = chorus_rng
	if is_air (x, y, z) and is_end_stone (x, y - 1, z) then
		grow_chorus_plant (x, y, z, rng)
		return true
	end
	return false
end

mcl_levelgen.register_feature ("mcl_end:chorus_plant", {
	place = chorus_plant_place,
})

mcl_levelgen.register_configured_feature ("mcl_end:chorus_plant", {
	feature = "mcl_end:chorus_plant",
})

mcl_levelgen.register_placed_feature ("mcl_end:chorus_plant", {
	configured_feature = "mcl_end:chorus_plant",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (0, 4)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- End Gateway feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/EndGatewayFeature.html
------------------------------------------------------------------------

-- local end_gateway_cfg = {
-- 	exact = ...,
-- 	exit_x = ...,
-- 	exit_y = ...,
-- 	exit_z = ...,
-- }

local cid_portal_gateway
	= core.get_content_id ("mcl_portals:portal_gateway")
local cid_bedrock
	= core.get_content_id ("mcl_core:bedrock")
local fix_lighting = mcl_levelgen.fix_lighting

local function end_gateway_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end
	set_block (x, y, z, cid_portal_gateway, 0)
	set_block (x, y + 1, z, cid_bedrock, 0)
	set_block (x - 1, y + 1, z, cid_bedrock, 0)
	set_block (x + 1, y + 1, z, cid_bedrock, 0)
	set_block (x, y + 1, z - 1, cid_bedrock, 0)
	set_block (x, y + 1, z + 1, cid_bedrock, 0)
	set_block (x, y + 2, z, cid_bedrock, 0)
	set_block (x, y - 1, z, cid_bedrock, 0)
	set_block (x - 1, y - 1, z, cid_bedrock, 0)
	set_block (x + 1, y - 1, z, cid_bedrock, 0)
	set_block (x, y - 1, z - 1, cid_bedrock, 0)
	set_block (x, y - 1, z + 1, cid_bedrock, 0)
	set_block (x, y - 2, z, cid_bedrock, 0)
	notify_generated ("mcl_end:end_gateway", {
		x, y, z, cfg.exact, cfg.exit_x,
		cfg.exit_y, cfg.exit_z,
	})
	fix_lighting (x, y, z, x, y, z)
	return true
end

mcl_levelgen.register_feature ("mcl_end:end_gateway", {
	place = end_gateway_place,
})

mcl_levelgen.register_configured_feature ("mcl_end:end_gateway_return", {
	feature = "mcl_end:end_gateway",
	exact = true,
	exit_x = 100,
	exit_y = 50,
	exit_z = 0,
})

local ZERO = function (_) return 0 end

mcl_levelgen.register_placed_feature ("mcl_end:end_gateway_return", {
	configured_feature = "mcl_end:end_gateway_return",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (700),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_random_offset (ZERO, uniform_height (3, 9)),
		mcl_levelgen.build_in_biome (),
	},
})
