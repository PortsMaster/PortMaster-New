local water_villages = core.settings:get_bool("mcl_villages_allow_water_villages", false)

-- switch for debugging
function mcl_villages.debug(message)
	core.log("verbose", "[mcl_villages] "..message)
end

mcl_villages.surface_mat = {}

function mcl_villages.grundstellungen()
	mcl_villages.surface_mat = mcl_villages.Set {
		"mcl_core:dirt_with_grass",
		--"mcl_core:dry_dirt_with_grass",
		"mcl_core:dirt_with_grass_snow",
		--"mcl_core:dirt_with_dry_grass",
		"mcl_core:podzol",
		"mcl_core:sand",
		"mcl_core:redsand",
		--"mcl_core:silver_sand",
		--"mcl_core:snow"
	}

	-- allow villages on more surfaces
	mcl_villages.surface_mat["mcl_colorblocks:hardened_clay"] = true
	mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_orange"] = true
	mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_red"] = true
	mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_white"] = true
	mcl_villages.surface_mat["mcl_core:andesite"] = true
	mcl_villages.surface_mat["mcl_core:coarse_dirt"] = true
	mcl_villages.surface_mat["mcl_core:diorite"] = true
	mcl_villages.surface_mat["mcl_core:dirt"] = true
	mcl_villages.surface_mat["mcl_core:granite"] = true
	mcl_villages.surface_mat["mcl_core:grass_path"] = true
	mcl_villages.surface_mat["mcl_core:sandstone"] = true
	mcl_villages.surface_mat["mcl_core:sandstonesmooth"] = true
	mcl_villages.surface_mat["mcl_core:sandstonesmooth2"] = true
	mcl_villages.surface_mat["mcl_core:stone"] = true
	mcl_villages.surface_mat["mcl_core:stone_with_coal"] = true
	mcl_villages.surface_mat["mcl_core:stone_with_iron"] = true

	if water_villages then
		mcl_villages.surface_mat["mcl_core:water_source"] = true
		mcl_villages.surface_mat["mclx_core:river_water_source"] = true
		mcl_villages.surface_mat["mcl_core:water_flowing"] = true
		mcl_villages.surface_mat["mclx_core:river_water_flowing"] = true
	end
end

mcl_villages.half_map_chunk_size = 40

--
-- Biome based block substitutions
--
-- TODO maybe this should be in the biomes?
mcl_villages.biome_map = {
	BambooJungle = "bamboo",
	BambooJungleEdge = "bamboo",
	BambooJungleEdgeM = "bamboo",
	BambooJungleM = "bamboo",

	Jungle = "jungle",
	JungleEdge = "jungle",
	JungleEdgeM = "jungle",
	JungleM = "jungle",

	Desert = "desert",

	Savanna = "acacia",
	SavannaM = "acacia",

	Mesa = "hardened_clay",
	MesaBryce = "hardened_clay ",
	MesaPlateauF = "hardened_clay",
	MesaPlateauFM = "hardened_clay",

	MangroveSwamp = "mangrove",

	RoofedForest = "dark_oak",

	BirchForest = "birch",
	BirchForestM = "birch",

	ColdTaiga = "spruce",
	ExtremeHills = "spruce",
	ExtremeHillsM = "spruce",
	IcePlains = "spruce",
	IcePlainsSpikes = "spruce",
	MegaSpruceTaiga = "spruce",
	MegaTaiga = "spruce",
	Taiga = "spruce",
	["ExtremeHills+"] = "spruce",

	CherryGrove = "cherry",

	-- no change
	--FlowerForest = "oak",
	--Forest = "oak",
	--MushroomIsland = "",
	--Plains = "oak",
	--StoneBeach = "",
	--SunflowerPlains = "oak",
	--Swampland = "oak",
}

mcl_villages.material_substitions = {
	desert = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_sandstonesmooth%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_birch_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:birch_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:birch_door%1"' },

		{ "mcl_core:cobble", "mcl_core:sandstone" },
		{ '"mcl_stairs:stair_cobble([^"]*)"', '"mcl_stairs:stair_sandstone%1"' },
		{ '"mcl_walls:cobble([^"]*)"', '"mcl_walls:sandstone%1"' },
		{ '"mcl_stairs:slab_cobble([^"]*)"', '"mcl_stairs:slab_sandstone%1"' },

		{ '"mcl_core:stonebrick"', '"mcl_core:redsandstone"' },
		{ '"mcl_core:stonebrick_([^"]+)"', '"mcl_core:redsandstone_%1"' },
		{ '"mcl_walls:stonebrick([^"]*)"', '"mcl_walls:redsandstone%1"' },
		{ '"mcl_stairs:stair_stonebrick"', '"mcl_stairs:stair_redsandstone"' },
		{ '"mcl_stairs:stair_stonebrick_([^"]+)"', '"mcl_stairs:stair_redsandstone_%1"' },

		{ '"mcl_stairs:slab_brick_block([^"]*)"', '"mcl_core:redsandstonesmooth2%1"' },
		{ '"mcl_core:brick_block"', '"mcl_core:redsandstonesmooth2"' },

		{ "mcl_trees:tree_oak", "mcl_core:redsandstonecarved" },
		{ "mcl_trees:wood_oak", "mcl_core:redsandstonesmooth" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:birch_fence%1"' },
		{ '"mcl_stairs:stair_oak_bark([^"]*)"', '"mcl_stairs:stair_sandstonesmooth2%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_sandstonesmooth%1"' },
	},
	spruce = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_sprucewood%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_spruce_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:spruce_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:spruce_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_spruce" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_spruce" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:spruce_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_spruce%1"' },
	},
	birch = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_birchwood%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_birch_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:birch_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:birch_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_birch" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_birch" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:birch_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_birch%1"' },
	},
	acacia = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_acaciawood%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_acacia_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:acacia_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:acacia_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_acacia" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_acacia" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:acacia_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_acacia%1"' },
	},
	dark_oak = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_darkwood%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_dark_oak_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:dark_oak_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:dark_oak_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_dark_oak" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_dark_oak" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:dark_oak_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_dark_oak%1"' },
	},
	jungle = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_junglewood%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_jungle_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:jungle_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:jungle_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_jungle" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_jungle" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:jungle_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_jungle%1"' },
	},
	bamboo = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_bamboo_block%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_bamboo_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:trapdoor_bamboo%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:door_bamboo%1"' },

		{ "mcl_core:cobble", "mcl_core:andesite" },
		{ '"mcl_stairs:stair_cobble([^"]*)"', '"mcl_stairs:stair_andesite%1"' },
		{ '"mcl_walls:cobble([^"]*)"', '"mcl_walls:andesite%1"' },
		{ '"mcl_stairs:slab_cobble([^"]*)"', '"mcl_stairs:slab_andesite%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_bamboo" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_bamboo" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:bamboo_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_bamboo%1"' },
	},
	cherry = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_cherry_blossom%1"' },
		{
			'"mcl_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mcl_pressureplates:pressure_plate_cherry_blossom_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:trapdoor_cherry_blossom%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:door_cherry_blossom%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_cherry_blossom" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_cherry_blossom" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:cherry_blossom_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_cherry_blossom%1"' },
	},
}
