------------------------------------------------------------------------
-- Async huge mushroom feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/HugeMushroomFeature.html
------------------------------------------------------------------------

-- local huge_mushroom_cfg = {
-- 	foliage_radius = nil,
--	stem_content = nil,
-- }

local mushroom_grow_blocks = mcl_levelgen.construct_cid_list ({
	"group:dirt",
	"mcl_core:mycelium",
	"mcl_core:podzol",
	"mcl_crimson:crimson_nylium",
	"mcl_crimson:warped_nylium",
	"mcl_mangrove:mangrove_mud_roots",
	"mcl_mud:mud",
})
local is_solid = {}

for _, cid in ipairs (mcl_levelgen.construct_cid_list ({"group:solid",})) do
	is_solid[cid] = true
end

local DOUBLEHIGH_CHANCE = 12
local MIN_HEIGHT = 4

local function get_height (rng)
	local base = MIN_HEIGHT + rng:next_within (3)
	if rng:next_within (DOUBLEHIGH_CHANCE) == 0 then
		return base * 2
	else
		return base
	end
end

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block

local function place_stem (x, y, z, height, cfg, rng)
	local stem_content = cfg.stem_content
	for i = 0, height - 1 do
		local y = y + i
		local cid, _ = get_block (x, y, z)
		if not is_solid[cid] then
			local cid, param2 = stem_content (x, y, z, rng)
			set_block (x, y, z, cid, param2)
		end
	end
end

local indexof = table.indexof
local is_leaf_or_air = mcl_levelgen.is_leaf_or_air

local function can_generate (self, x, y, z, height, cfg)
	local level_min = mcl_levelgen.placement_level_min
	local level_max = level_min + mcl_levelgen.placement_level_height -1
	if y <= level_min or y + height >= level_max then
		return false
	else
		local cid, _ = get_block (x, y - 1, z)
		if indexof (mushroom_grow_blocks, cid) == -1 then
			return false
		end

		local foliage = cfg.foliage_radius
		for i = 0, height do
			local r = self:cap_radius_at_height (foliage, i)
			for dx = -r, r do
				for dz = -r, r do
					if not is_leaf_or_air (x + dx, y, z + dz) then
						return false
					end
				end
			end
		end

		return true
	end
end

local ull = mcl_levelgen.ull
local mushroom_rng = mcl_levelgen.jvm_random (ull (0, 0))
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local fix_lighting = mcl_levelgen.fix_lighting

local function huge_mushroom_place (self, x, y, z, cfg, rng)
	mushroom_rng:reseed (rng:next_long ())
	if y < run_minp.y or y > run_maxp.y then
		return false
	end

	local height = get_height (rng)
	if not can_generate (self, x, y, z, height, cfg) then
		return false
	else
		local r = cfg.foliage_radius
		self:place_cap (x, y, z, height, cfg, rng)
		place_stem (x, y, z, height, cfg, rng)
		fix_lighting (x - r, y - 1, z - r, x + r, y + height, z + r)
		return true
	end
end

local SKIN_UP = 0x20
local SKIN_DOWN = 0x10
local SKIN_EAST = 0x08
local SKIN_WEST = 0x04
local SKIN_NORTH = 0x02
local SKIN_SOUTH = 0x01
local bor = bit.bor

local function mushroom_faces_to_idx (skin_north, skin_west,
				      skin_south, skin_east,
				      skin_up, skin_down)
	return bor (skin_north and SKIN_NORTH or 0,
		    skin_west and SKIN_WEST or 0,
		    skin_south and SKIN_SOUTH or 0,
		    skin_east and SKIN_EAST or 0,
		    skin_up and SKIN_UP or 0,
		    skin_down and SKIN_DOWN or 0) + 1
end

-- XXX: find some means of merging this with huge.lua.
local function to_binary (num)
	local binary = ""
	while (num > 0) do
		local remainder_binary = (num % 2) > 0 and 1 or 0
		binary = binary .. remainder_binary
		num = math.floor (num / 2)
	end
	binary = string.reverse (binary)
	while (string.len (binary) < 6) do
		binary = "0" .. binary
	end
	return binary
end

local red_mushroom_cap_cids = {}
local brown_mushroom_cap_cids = {}

for i = 0, 63 do
	local name_red
		= "mcl_mushrooms:red_mushroom_block_cap_" .. to_binary (i)
	local name_brown
		= "mcl_mushrooms:brown_mushroom_block_cap_" .. to_binary (i)
	red_mushroom_cap_cids[i + 1]
		= core.get_content_id (name_red)
	brown_mushroom_cap_cids[i + 1]
		= core.get_content_id (name_brown)
end

------------------------------------------------------------------------
-- Huge Red Mushroom feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/HugeRedMushroomFeature.html
------------------------------------------------------------------------

local function huge_red_mushroom_cap_radius_at_height (self, foliage_radius, height)
	-- jdb reveals that this function always returns 0 in
	-- Minecraft...
	return 0
end

local mathabs = math.abs

local function huge_red_mushroom_place_cap (self, x, y, z, height, cfg, rng)
	local default_radius = cfg.foliage_radius
	for dy = height - 3, height do
		local r = dy < height and default_radius or default_radius - 1
		local exterior = dy < height and r - 2 or r - 1

		for dx = -r, r do
			for dz = -r, r do
				local edges_not_corner
					= (mathabs (dx) ~= r or mathabs (dz) ~= r)
					and (mathabs (dx) == r or mathabs (dz) == r)

				if dy >= height or edges_not_corner then
					local x, y, z = x + dx, y + dy, z + dz
					local skin_up = y >= height
					local skin_north = dz < -exterior
					local skin_south = dz > exterior
					local skin_west = dx < -exterior
					local skin_east = dx > exterior
					local idx = mushroom_faces_to_idx (skin_north, skin_west,
									   skin_south, skin_east,
									   skin_up, false)
					local cid = red_mushroom_cap_cids[idx]
					set_block (x, y, z, cid, 0)
				end
			end
		end
	end
end

mcl_levelgen.register_feature ("mcl_mushrooms:huge_red_mushroom", {
	place = huge_mushroom_place,
	cap_radius_at_height = huge_red_mushroom_cap_radius_at_height,
	place_cap = huge_red_mushroom_place_cap,
})

local cid_huge_red_mushroom_stem
	= core.get_content_id ("mcl_mushrooms:red_mushroom_block_stem")

mcl_levelgen.register_configured_feature ("mcl_mushrooms:huge_red_mushroom", {
	feature = "mcl_mushrooms:huge_red_mushroom",
	foliage_radius = 2,
	stem_content = function (x, y, z, rng)
		return cid_huge_red_mushroom_stem, 0
	end,
})

------------------------------------------------------------------------
-- Huge Brown Mushroom feature.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/HugeBrownMushroomFeature.html
------------------------------------------------------------------------

local function huge_brown_mushroom_cap_radius_at_height (self, foliage_radius, height)
	return height <= 3 and 0 or foliage_radius
end

local function huge_brown_mushroom_place_cap (self, x, y, z, height, cfg, rng)
	local r = cfg.foliage_radius
	local y = y + height
	local exterior = r - 1

	for dx = -r, r do
		for dz = -r, r do
			local corner = (mathabs (dx) == r and mathabs (dz) == r)

			if not corner then
				local exterior_x
					= mathabs (dz) == r and exterior - 1 or exterior
				local exterior_z
					= mathabs (dx) == r and exterior - 1 or exterior

				local x, z = x + dx, z + dz
				local skin_north = dz < -exterior_z
				local skin_south = dz > exterior_z
				local skin_west = dx < -exterior_x
				local skin_east = dx > exterior_x
				local idx = mushroom_faces_to_idx (skin_north, skin_west,
								   skin_south, skin_east,
								   true, false)
				local cid = brown_mushroom_cap_cids[idx]
				set_block (x, y, z, cid, 0)
			end
		end
	end
end

mcl_levelgen.register_feature ("mcl_mushrooms:huge_brown_mushroom", {
	place = huge_mushroom_place,
	cap_radius_at_height = huge_brown_mushroom_cap_radius_at_height,
	place_cap = huge_brown_mushroom_place_cap,
})

local cid_huge_brown_mushroom_stem
	= core.get_content_id ("mcl_mushrooms:brown_mushroom_block_stem")

mcl_levelgen.register_configured_feature ("mcl_mushrooms:huge_brown_mushroom", {
	feature = "mcl_mushrooms:huge_brown_mushroom",
	foliage_radius = 3,
	stem_content = function (x, y, z, rng)
		return cid_huge_brown_mushroom_stem, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_mushrooms:mushroom_island_vegetation", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_mushrooms:huge_red_mushroom",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_mushrooms:huge_brown_mushroom",
			placement_modifiers = {},
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:mushroom_island_vegetation", {
	configured_feature = "mcl_mushrooms:mushroom_island_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Little Mushrooms.
------------------------------------------------------------------------

local is_air = mcl_levelgen.is_air

local function require_air (x, y, z, rng)
	if is_air (x, y, z) then
		return { x, y, z, }
	else
		return nil
	end
end

local cid_brown_mushroom
	= core.get_content_id ("mcl_mushrooms:mushroom_brown")
local cid_red_mushroom
	= core.get_content_id ("mcl_mushrooms:mushroom_red")

mcl_levelgen.register_configured_feature ("mcl_mushrooms:brown_mushroom_block", {
	feature = "mcl_levelgen:simple_block",
	content = function (x, y, z, rng)
		return cid_brown_mushroom, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_mushrooms:red_mushroom_block", {
	feature = "mcl_levelgen:simple_block",
	content = function (x, y, z, rng)
		return cid_red_mushroom, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_mushrooms:patch_brown_mushroom", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_mushrooms:brown_mushroom_block",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_configured_feature ("mcl_mushrooms:patch_red_mushroom", {
	feature = "mcl_levelgen:random_patch",
	placed_feature = {
		configured_feature = "mcl_mushrooms:red_mushroom_block",
		placement_modifiers = {
			require_air,
		},
	},
	tries = 96,
	xz_spread = 7,
	y_spread = 3,
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:brown_mushroom_normal", {
	configured_feature = "mcl_mushrooms:patch_brown_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (256),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local THREE = function (_) return 3 end
local TWO = function (_) return 2 end

mcl_levelgen.register_placed_feature ("mcl_mushrooms:brown_mushroom_old_growth", {
	configured_feature = "mcl_mushrooms:patch_brown_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_count (THREE),
		mcl_levelgen.build_rarity_filter (4),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:brown_mushroom_swamp", {
	configured_feature = "mcl_mushrooms:patch_brown_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO),
		mcl_levelgen.build_rarity_filter (4),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:brown_mushroom_taiga", {
	configured_feature = "mcl_mushrooms:patch_brown_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (4),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:red_mushroom_normal", {
	configured_feature = "mcl_mushrooms:patch_red_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (512),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:red_mushroom_old_growth", {
	configured_feature = "mcl_mushrooms:patch_red_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (171),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:red_mushroom_swamp", {
	configured_feature = "mcl_mushrooms:patch_red_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (64),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:red_mushroom_taiga", {
	configured_feature = "mcl_mushrooms:patch_red_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (256),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

local uniform_height = mcl_levelgen.uniform_height

local nether_preset = mcl_levelgen.get_dimension ("mcl_levelgen:nether").preset
local NETHER_MIN = nether_preset.min_y
local NETHER_TOP = NETHER_MIN + nether_preset.height - 1

mcl_levelgen.register_placed_feature ("mcl_mushrooms:brown_mushroom_nether", {
	configured_feature = "mcl_mushrooms:patch_brown_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (2),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mushrooms:red_mushroom_nether", {
	configured_feature = "mcl_mushrooms:patch_red_mushroom",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (2),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (NETHER_MIN,
								 NETHER_TOP)),
		mcl_levelgen.build_in_biome (),
	},
})
