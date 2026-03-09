local R = mcl_levelgen.build_random_spread_placement

local schematics = {
	"nether_fossil_1",
	"nether_fossil_2",
	"nether_fossil_3",
	"nether_fossil_4",
}

if not mcl_levelgen.is_levelgen_environment then
	for _, schem in ipairs (schematics) do
		local name = "mcl_levelgen:" .. schem
		local file = mcl_levelgen.prefix
			.. "/schematics/mcl_levelgen_"
			.. schem .. ".mts"
		mcl_levelgen.register_portable_schematic (name, file, true)
	end
	return
end

------------------------------------------------------------------------
-- Nether Fossil.
------------------------------------------------------------------------

local column = {}
local air_water_or_lava_p = mcl_levelgen.air_water_or_lava_p
local decode_node = mcl_levelgen.decode_node
local cid_air = core.CONTENT_AIR
local structure_biome_test = mcl_levelgen.structure_biome_test
local make_schematic_piece = mcl_levelgen.make_schematic_piece
local create_structure_start = mcl_levelgen.create_structure_start

local function discard_air (x, y, z, rng, cid_current,
			    param2_current, cid, param2)
	if cid == cid_air then
		return nil, nil
	end
	return cid, param2
end

local discard_air_processors = {
	discard_air,
}

local function nether_fossil_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + rng:next_within (16),
		cz * 16 + rng:next_within (16)
	local sea_level = level.preset.sea_level
	local level_min = level.preset.min_y
	local height = self.height (rng)

	if structure_biome_test (level, self, x, 32, z) then
		terrain:get_one_column (x, z, column)

		for y = height, sea_level + 1, -1 do
			local cid_above, _ = decode_node (column[y - level_min])
			local cid_below, _ = decode_node (column[y - 1 - level_min])

			if cid_above == cid_air
				and not air_water_or_lava_p (cid_below) then
				local schematic
					= schematics[1 + rng:next_within (#schematics)]
				return create_structure_start (self, {
					make_schematic_piece ("mcl_levelgen:" .. schematic,
							      x, y - 1, z, "random", rng, true,
							      true, discard_air_processors,
							      nil, 1),
				})

			end
		end
	end
	return nil
end

------------------------------------------------------------------------
-- Nether Fossil registration.
------------------------------------------------------------------------

local nether_fossil_biomes = {
	"SoulSandValley",
}

mcl_levelgen.modify_biome_groups (nether_fossil_biomes, {
	has_nether_fossil = true,
})

local function uniform_height (min_inclusive, max_inclusive)
	local diff = max_inclusive - min_inclusive + 1
	return function (rng)
		return rng:next_within (diff) + min_inclusive
	end
end

mcl_levelgen.register_structure ("mcl_levelgen:nether_fossil", {
	create_start = nether_fossil_create_start,
	biomes = mcl_levelgen.build_biome_list ({"#has_nether_fossil",}),
	height = uniform_height (32, 125),
	step = mcl_levelgen.UNDERGROUND_DECORATION,
	terrain_adaptation = "beard_thin",
})

mcl_levelgen.register_structure_set ("mcl_levelgen:nether_fossils", {
	structures = {
		"mcl_levelgen:nether_fossil",
	},
	placement = R (1.0, "default", 2, 1, 14357921, "linear", nil, nil),
})
