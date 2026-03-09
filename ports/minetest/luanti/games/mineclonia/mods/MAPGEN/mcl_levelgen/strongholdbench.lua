dofile ("init.lua")

mcl_levelgen.assign_biome_ids ({})

local stronghold_biased_to_biomes = {
	"BambooJungle",
	"BirchForest",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenPeaks",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LushCaves",
	"Meadow",
	"Mesa",
	"MushroomIslands",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"Savannah",
	"SavannahPlateau",
	"SnowyPlains",
	"SnowySlopes",
	"SnowyTaiga",
	"SparseJungle",
	"StonyPeaks",
	"SunflowerPlains",
	"Taiga",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

mcl_levelgen.modify_biome_groups (stronghold_biased_to_biomes, {
	stronghold_biased_to = true,
})

local seed = mcl_levelgen.ull (0, 3228473)
local level = mcl_levelgen.make_overworld_preset (seed)

local clock = os.clock ()
mcl_levelgen.generate_stronghold_positions (level, {
	count = 128,
	distance = 32,
	spread = 3,
	preferred_biomes = mcl_levelgen.build_biome_list ({"#stronghold_biased_to",}),
})
print (string.format ("%.2f ms", (os.clock () - clock) * 1000))
