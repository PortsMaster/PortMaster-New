------------------------------------------------------------------------
-- Async amethyst geodes.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/GeodeFeature.html
-- https://learn.microsoft.com/en-us/minecraft/creator/reference/content/featuresreference/examples/features/minecraftgeode_feature?view=minecraft-bedrock-stable
------------------------------------------------------------------------

-- local geode_block_cfg = {
-- 	filling_content = nil,
-- 	inner_layer_content = nil,
-- 	alternate_inner_layer_content = nil,
-- 	middle_layer_content = nil,
-- 	outer_layer_content = nil,
-- 	inner_placements = nil,
-- 	cannot_replace = nil,
-- 	invalid_blocks = nil,
-- }

-- local geode_layer_cfg = {
-- 	filling = nil,
-- 	inner_layer = nil,
-- 	middle_layer = nil,
-- 	outer_layer = nil,
-- }

-- local geode_crack_cfg = {
-- 	generate_crack_chance = nil,
-- 	base_crack_size = nil,
-- 	crack_point_offset = nil,
-- }

-- local geode_cfg = {
-- 	blocks = nil,
-- 	layers = nil,
-- 	crack = nil,
-- 	use_potential_placements_chance = nil,
-- 	use_alternate_layer0_chance = nil,
-- 	placements_require_layer0_alternate = nil,
-- 	outer_wall_distance = nil,
-- 	outer_wall_distance_max = nil,
-- 	distribution_points = nil,
-- 	point_offset = nil,
-- 	invalid_blocks_threshold = nil,
-- 	noise_multiplier = nil,
-- }

local overworld = mcl_levelgen.overworld_preset
local overworld_seed = overworld.seed
local geode_noise_rng = mcl_levelgen.jvm_random (overworld_seed)
local GEODE_LAYER_NOISE = mcl_levelgen.make_normal_noise (geode_noise_rng, -4, { 1.0, })
local factory = overworld.factory ("mcl_amethyst:amethyst_geode"):fork_positional ()
local geode_rng = factory:create_reseedable ()

local mathsqrt = math.sqrt
local ipos3 = mcl_levelgen.ipos3
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp

local geode_malus = mcl_levelgen.construct_cid_list ({
	"air",
	"group:lava",
	"group:water",
	"mcl_core:bedrock",
	"mcl_core:blue_ice",
	"mcl_core:ice",
	"mcl_core:packed_ice",
})

local cid_air = core.CONTENT_AIR

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local indexof = table.indexof

local function distsqr (x, y, z, x1, y1, z1)
	local dx = x1 - x
	local dy = y1 - y
	local dz = z1 - z
	return dx * dx + dy * dy + dz * dz
end

local function set_block_protected (x, y, z, cid, param2, cannot_replace)
	local cid_old, _ = get_block (x, y, z)
	if indexof (cannot_replace, cid_old) == -1 then
		set_block (x, y, z, cid, param2)
	end
end

local insert = table.insert
local fix_lighting = mcl_levelgen.fix_lighting

local function place_geode_in_cube (x, y, z, dist_points, n_dist_points, crack_points,
				    make_crack,
				    cfg, rng, layer, block, crack, blocks_to_decorate)
	local min = cfg.min_gen_offset
	local max = cfg.max_gen_offset
	local multiplier = cfg.noise_multiplier
	-- Average contribution of a distribution point to a distance
	-- from the outer wall.
	local d_avg = cfg.outer_wall_distance_max / n_dist_points
	local d_contrib = 1.0 / d_avg
	local r_filling = 1.0 / mathsqrt (layer.filling)
	local r_inner = 1.0 / mathsqrt (layer.inner_layer + d_contrib)
	local r_middle = 1.0 / mathsqrt (layer.middle_layer + d_contrib)
	local r_outer = 1.0 / mathsqrt (layer.outer_layer + d_contrib)
	local cracksize = crack.base_crack_size + rng:next_double () * 0.5
	if n_dist_points > 3 then
		cracksize = cracksize + d_contrib
	end
	local r_crack = 1.0 / mathsqrt (cracksize)
	local block = cfg.block
	local cannot_replace = block.cannot_replace

	for x, y, z in ipos3 (x + min, y + min, z + min,
			      x + max, y + max, z + max) do
		local noiseval = GEODE_LAYER_NOISE (x, y, z) * multiplier
		local d_to_dist_points = 0.0
		local d_to_crack_points = 0.0

		do
			for _, dist_point in ipairs (dist_points) do
				local x1, y1, z1
					= dist_point[1], dist_point[2], dist_point[3]
				local offset = dist_point[4]
				local inv_d
					= 1.0 / mathsqrt (distsqr (x, y, z, x1, y1, z1)
							  + offset) + noiseval
				d_to_dist_points = d_to_dist_points + inv_d
			end

			local crack_offset = crack.crack_point_offset
			for _, crack_point in ipairs (crack_points) do
				local x1, y1, z1
					= crack_point[1], crack_point[2], crack_point[3]
				local inv_d
					= 1.0 / mathsqrt (distsqr (x, y, z, x1, y1, z1)
							  + crack_offset) + noiseval
				d_to_crack_points = d_to_crack_points + inv_d
			end
		end

		if d_to_dist_points >= r_outer then
			if make_crack
				and d_to_crack_points >= r_crack
				and d_to_dist_points < r_filling then
				set_block_protected (x, y, z, cid_air, 0,
						     cannot_replace)
			elseif d_to_dist_points >= r_filling then
				local cid, param2
					= block.filling_content (x, y, z, rng)
				set_block_protected (x, y, z, cid, param2,
						     cannot_replace)
			elseif d_to_dist_points >= r_inner then
				local alternate, cid, param2 = false
				if rng:next_float () <= cfg.use_alternate_layer0_chance then
					alternate = true
					cid, param2
						= block.alternate_inner_layer_content (x, y, z, rng)
				else
					cid, param2
						= block.inner_layer_content (x, y, z, rng)
				end

				set_block_protected (x, y, z, cid, param2, cannot_replace)
				if (not cfg.placements_require_layer0_alternate or alternate)
					and rng:next_float () < cfg.use_potential_placements_chance then
					insert (blocks_to_decorate, { x, y, z, })
				end
			elseif d_to_dist_points >= r_middle then
				local cid, param2
					= block.middle_layer_content (x, y, z, rng)
				set_block_protected (x, y, z, cid, param2, cannot_replace)
			elseif d_to_dist_points >= r_outer then
				local cid, param2
					= block.outer_layer_content (x, y, z, rng)
				set_block_protected (x, y, z, cid, param2, cannot_replace)
			end
		end
	end
	fix_lighting (x + min, y + min, z + min, x + max, y + max, z + max)
end

local dirs = {
	{"y", -1, 0, 1, 0,},
	{"y", 1, 0, -1, 0,},
	{"x", -1, 1, 0, 0,},
	{"x", 1, -1, 0, 0,},
	{"z", -1, 0, 0, 1,},
	{"z", 1, 0, 0, -1,},
}

local facedir_to_wallmounted = mcl_levelgen.facedir_to_wallmounted
local is_water_or_air = mcl_levelgen.is_water_or_air

local function place_budding_amethyst (blocks, cfg, rng)
	local block = cfg.block
	local inner_placements = block.inner_placements
	local cannot_replace = block.cannot_replace
	local n = #inner_placements
	for _, block in ipairs (blocks) do
		local cid = inner_placements[1 + rng:next_within (n)]
		local x, y, z = block[1], block[2], block[3]

		for _, dir in ipairs (dirs) do
			local dx, dy, dz = dir[3], dir[4], dir[5]

			if is_water_or_air (x + dx, y + dy, z + dz) then
				local param2 = facedir_to_wallmounted (dir[1], dir[2])
				set_block_protected (x + dx, y + dy, z + dz,
						     cid, param2, cannot_replace)
			end
		end
	end
end

local function geode_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	geode_rng:reseed_positional (x, y, z)

	-- The essence of this code is to distribute a number of
	-- points around the origin of the feature, creating one or
	-- more "distance fields" representing the body of the geode
	-- and the crack running along one of its sides, so as to
	-- measure the distance of each position in a 16x16x16 cube
	-- round the origin from these points collectively, offset
	-- slightly by a noise, to decide whether to and with what to
	-- replace it.

	local rng = geode_rng
	local dist_points = {}
	local n_dist_points = cfg.distribution_points (rng)
	local crack_points = {}
	local crack = cfg.crack
	local layer = cfg.layer
	local make_crack = rng:next_float () < crack.generate_crack_chance
	local cnt_malus = 0
	local maluses = cfg.block.invalid_blocks

	do
		local offset = cfg.point_offset
		local d = cfg.outer_wall_distance
		local max_malus = cfg.invalid_blocks_threshold
		for i = 1, n_dist_points do
			local dx = d (rng)
			local dy = d (rng)
			local dz = d (rng)

			local cid, _ = get_block (x + dx, y + dy, z + dz)
			if indexof (maluses, cid) ~= -1 then
				cnt_malus = cnt_malus + 1
				if cnt_malus > max_malus then
					return false
				end
			end
			dist_points[i] = {
				x + dx, y + dy, z + dz,
				offset (rng),
			}
		end
	end

	if make_crack then
		local dir = rng:next_within (4)
		local offset = n_dist_points * 2 + 1

		if dir == 0 then
			crack_points = {
				{ x + offset, y + 7, z, },
				{ x + offset, y + 5, 0, },
				{ x + offset, y + 1, 0, },
			}
		elseif dir == 1 then
			crack_points = {
				{ x, y + 7, z + offset, },
				{ x, y + 5, z + offset, },
				{ x, y + 1, z + offset, },
			}
		elseif dir == 2 then
			crack_points = {
				{ x + offset, y + 7, z + offset, },
				{ x + offset, y + 5, z + offset, },
				{ x + offset, y + 1, z + offset, },
			}
		else
			crack_points = {
				{ x + 0, y + 7, z + 0, },
				{ x + 0, y + 5, z + 0, },
				{ x + 0, y + 1, z + 0, },
			}
		end
	end

	local blocks_to_decorate = {}
	place_geode_in_cube (x, y, z, dist_points, n_dist_points,
			     crack_points, make_crack, cfg, rng, layer,
			     cfg.block, crack, blocks_to_decorate)

	-- Place decorations.
	place_budding_amethyst (blocks_to_decorate, cfg, rng)
	return true
end

mcl_levelgen.register_feature ("mcl_amethyst:geode", {
	place = geode_place,
})

local cid_amethyst_block
	= core.get_content_id ("mcl_amethyst:amethyst_block")
local cid_budding_amethyst_block
	= core.get_content_id ("mcl_amethyst:budding_amethyst_block")
local cid_small_amethyst_bud
	= core.get_content_id ("mcl_amethyst:small_amethyst_bud")
local cid_medium_amethyst_bud
	= core.get_content_id ("mcl_amethyst:medium_amethyst_bud")
local cid_large_amethyst_bud
	= core.get_content_id ("mcl_amethyst:large_amethyst_bud")
local cid_amethyst_cluster
	= core.get_content_id ("mcl_amethyst:amethyst_cluster")
local cid_calcite
	= core.get_content_id ("mcl_amethyst:calcite")
local cid_smooth_basalt
	= core.get_content_id ("mcl_blackstone:basalt_smooth")

local uniform_height = mcl_levelgen.uniform_height

mcl_levelgen.register_configured_feature ("mcl_amethyst:amethyst_geode", {
	feature = "mcl_amethyst:geode",
	block = {
		filling_content = function (_, _, _, _)
			return cid_air, 0
		end,
		inner_layer_content = function (_, _, _, _)
			return cid_amethyst_block, 0
		end,
		alternate_inner_layer_content = function (_, _, _, _)
			return cid_budding_amethyst_block, 0
		end,
		inner_placements = {
			cid_small_amethyst_bud,
			cid_medium_amethyst_bud,
			cid_large_amethyst_bud,
			cid_amethyst_cluster,
		},
		invalid_blocks = geode_malus,
		middle_layer_content = function (_, _, _, _)
			return cid_calcite, 0
		end,
		outer_layer_content = function (_, _, _, _)
			return cid_smooth_basalt, 0
		end,
		cannot_replace
			= mcl_levelgen.construct_cid_list ({"group:features_cannot_replace",}),
	},
	crack = {
		base_crack_size = 2.0,
		crack_point_offset = 2,
		generate_crack_chance = 0.95,
	},
	layer = {
		filling = 1.7,
		inner_layer = 2.2,
		middle_layer = 3.2,
		outer_layer = 4.2,
	},
	min_gen_offset = -16,
	max_gen_offset = 16,
	noise_multiplier = 0.05,
	outer_wall_distance = uniform_height (4, 6),
	outer_wall_distance_max = 6,
	placements_require_layer0_alternate = true,
	point_offset = uniform_height (1, 2),
	use_alternate_layer0_chance = 0.083,
	use_potential_placements_chance = 0.35,
	distribution_points = uniform_height (3, 4),
	invalid_blocks_threshold = 1,
})

local overworld = mcl_levelgen.overworld_preset
local OVERWORLD_MIN = overworld.min_y

mcl_levelgen.register_placed_feature ("mcl_amethyst:amethyst_geode", {
	configured_feature = "mcl_amethyst:amethyst_geode",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (24),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN + 6, 30)),
		mcl_levelgen.build_in_biome (),
	},
})
