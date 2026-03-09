local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Buried Treasure.
------------------------------------------------------------------------

mcl_levelgen.register_loot_table ("mcl_levelgen:buried_treasure", {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_mobitems:heart_of_the_sea", weight = 100, amount_min = 1, amount_max = 1 },
		}
	},
	{
		stacks_min = 5,
		stacks_max = 8,
		items = {
			{ itemstring = "mcl_core:iron_ingot", weight = 20, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 2,
		items = {
			{ itemstring = "mcl_fishing:fish_cooked", weight = 1, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_fishing:salmon_cooked", weight = 1, amount_min = 2, amount_max = 4 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_core:emerald", weight = 5, amount_min = 4, amount_max = 8 },
			{ itemstring = "mcl_ocean:prismarine_crystals", weight = 5, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 0,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_armor:chestplate_leather", weight = 1, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_tools:sword_iron", weight = 1, amount_min = 1, amount_max = 1 },
		}
	},
})


local function getcid (name)
	if core and mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		-- Content IDs are not required outside level
		-- generation environments.
		return nil
	end
end

local cid_chest_small = getcid ("mcl_chests:chest_small")

local cid_andesite = getcid ("mcl_core:andesite")
local cid_diorite = getcid ("mcl_core:diorite")
local cid_granite = getcid ("mcl_core:granite")
local cid_sandstone = getcid ("mcl_core:sandstone")
local cid_stone = getcid ("mcl_core:stone")

local cid_sand = getcid ("mcl_core:sand")

local structure_biome_test = mcl_levelgen.structure_biome_test
local index_heightmap = mcl_levelgen.index_heightmap
local is_water_or_air = mcl_levelgen.is_water_or_air

local function is_chest_surface (cid)
	return cid == cid_andesite
		or cid == cid_diorite
		or cid == cid_granite
		or cid == cid_sandstone
		or cid == cid_stone
end

local dirs = {
	{ -1, 0, 0, },
	{ 1, 0, 0, },
	{ 0, 0, -1, },
	{ 0, 0, 1, },
	{ 0, -1, 0, },
	{ 0, 1, 0, },
}

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local air_water_or_lava_p = mcl_levelgen.air_water_or_lava_p
local set_loot_table = mcl_levelgen.set_loot_table

local function buried_treasure_place (self, level, terrain, rng, x1, z1, x2, z2)
	local x, z = self.bbox[1], self.bbox[3]
	local surface, _ = index_heightmap (x, z, true)
	local level_min = level.preset.min_y

	while surface > level_min do
		local cid_surface, param2_surface = get_block (x, surface - 1, z)
		local cid_replacement, param2_replacement = get_block (x, surface, z)

		if air_water_or_lava_p (cid_replacement, param2_replacement) then
			cid_replacement = cid_sand
			param2_replacement = 0
		end

		if is_chest_surface (cid_surface) then
			set_block (x, surface, z, cid_chest_small, 0)
			set_loot_table (x, surface, z, rng, "mcl_levelgen:buried_treasure")

			for _, dir in ipairs (dirs) do
				local x, y, z = x + dir[1], surface + dir[2],
					z + dir[3]

				-- Seal this chest's surroundings.
				if is_water_or_air (x, y, z) then
					if dir[2] ~= 1 and is_water_or_air (x, y - 1, z) then
						-- Guarantee the presence of a stable node
						-- so that the walls may not collapse.
						set_block (x, y, z, cid_surface,
							   param2_surface)
					else
						-- Otherwise fill with the material
						-- replaced by the chest.
						set_block (x, y, z, cid_replacement,
							   param2_replacement)
					end
				end
			end
			break
		end
		surface = surface - 1
	end
end

local create_structure_start = mcl_levelgen.create_structure_start
local enable_ersatz = mcl_levelgen.enable_ersatz
local mathmin = math.min

local function ersatz_is_beach (terrain, x, z, y)
	local y1 = terrain:get_one_height (x + 10, z + 10)
	local y2 = terrain:get_one_height (x - 10, z - 10)
	local y3 = terrain:get_one_height (x + 10, z - 10)
	local y4 = terrain:get_one_height (x - 10, z + 10)
	local sea_level = terrain.preset.sea_level
	return mathmin (y1, y2, y3, y4) < sea_level
		and y - sea_level > 1 and y - sea_level <= 4
end

local function buried_treasure_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + 8, cz * 16 + 8
	local y = terrain:get_one_height (x, z)

	-- The built-in biome system cannot distinguish between
	-- beaches and ordinary terrain.
	if enable_ersatz and not ersatz_is_beach (terrain, x, z, y) then
		return false
	end

	if structure_biome_test (level, self, x, y, z) then
		local pieces = {
			{
				bbox = {
					x + 1, y, z + 1,
					x + 1, y, z + 1,
				},
				place = buried_treasure_place,
			},
		}
		return create_structure_start (self, pieces)
	end
	return nil
end

------------------------------------------------------------------------
-- Buried Treasure registration.
------------------------------------------------------------------------

local buried_treasure_biomes = enable_ersatz and {
	"#is_overworld",
} or {
	"#is_beach",
}

mcl_levelgen.modify_biome_groups (buried_treasure_biomes, {
	has_buried_treasure = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:buried_treasure", {
	biomes = mcl_levelgen.build_biome_list ({"#has_buried_treasure",}),
	create_start = buried_treasure_create_start,
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	terrain_adaptation = "none",
})

mcl_levelgen.register_structure_set ("mcl_levelgen:buried_treasures", {
	structures = {
		"mcl_levelgen:buried_treasure",
	},
	placement = R (0.01, "legacy_type_2", 1, 0, 0, "linear",
		       { 9, 0, 9, }, nil),
})
