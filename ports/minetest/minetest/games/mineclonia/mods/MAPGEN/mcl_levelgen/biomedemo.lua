------------------------------------------------------------------------
-- Overworld / Nether noise-based biome demonstration program.
------------------------------------------------------------------------

local biome_colors = {
	DeepDark = "#000000",
	WarmOcean = "#0000ac",
	DeepFrozenOcean = "#404090",
	LushCaves = "#9acd32",
	MushroomIslands = "#ff00ff",
	DeepOcean = "#000030",
	DeepLukewarmOcean = "#000040",
	DripstoneCaves = "#8b636c",
	Desert = "#fa9418",
	DeepColdOcean = "#202038",
	Taiga = "#0b6659",
	FrozenOcean = "#7070d6",
	SnowyPlains = "#ffffff",
	Plains = "#8db360",
	WoodedMesa = "#b09765",
	Savannah = "#bdb25f",
	SavannahPlateau = "#a79d64",
	DarkForest = "#40511a",
	MangroveSwamp = "#6b8e23",
	Grove = "#eeeee0",
	LukewarmOcean = "#000090",
	Ocean = "#000070",
	Mesa = "#d94515",
	SnowyTaiga = "#31554a",
	ColdOcean = "#202070",
	SnowySlopes = "#f5f5f5",
	Swamp = "#07f9b2",
	Jungle = "#537b09",
	Forest = "#056621",
	IceSpikes = "#b4dcdc",
	FrozenPeaks = "#6495ed",
	JaggedPeaks = "#708090",
	ErodedMesa = "#ff6d3d",
	River = "#0000ff",
	BambooJungle = "#768e14",
	OldGrowthPineTaiga = "#00cd00",
	OldGrowthSpruceTaiga = "#818e79",
	SunflowerPlains = "#b5db88",
	FlowerForest = "#2d8e49",
	StonyPeaks = "#8b7d6b",
	StonyShore = "#a2a284",
	FrozenRiver = "#a0a0ff",
	Meadow = "#00cd66",
	WindsweptForest = "#008b45",
	WindsweptHills = "#696969",
	WindsweptGravellyHills = "#a9a9a9",
	Beach = "#fade55",
	BirchForest = "#307444",
	CherryGrove = "#ffc0cb",
	OldGrowthBirchForest = "#29730f",
	SparseJungle = "#7ba331",
	SnowyBeach = "#faf0c0",
	WindsweptSavannah = "#e5da87",

	-- Nether biomes.
	BasaltDeltas = "#403636",
	CrimsonForest = "#dd0808",
	NetherWastes = "#bf3b3b",
	SoulSandValley = "#5e3830",
	WarpedForest = "#49907b",

	-- End biomes.
	TheEnd = "#8080ff",
	SmallEndIslands = "#bdb25f",
	EndMidlands = "#a79d64",
	EndHighlands = "#b09765",
	EndBarrens = "#ca8c65",
}

------------------------------------------------------------------------
-- Main section of program.
------------------------------------------------------------------------

dofile ("init.lua")

local WIDTH, HEIGHT = 1024, 1024
local seed = mcl_levelgen.ull (0, 0)
mcl_levelgen.stringtoull (seed, "9238542514368619060")
mcl_levelgen.assign_biome_ids ({})
local level = mcl_levelgen.make_overworld_preset (seed)

local next_color = 35
local last_color = 126
local color_allocations = {}
local colordefs = {}
local n_colors = 0

local function alloc_color (biome)
	local color = color_allocations[biome]
	if color then
		return color
	end
	local value = biome_colors[biome]
	if not value then
		error ("No color is defined for biome `" .. biome .. "'")
	end
	n_colors = n_colors + 1
	if next_color == last_color then
		error ("Colormap exhausted")
	end
	local char = string.char (next_color)
	color_allocations[biome] = char
	table.insert (colordefs, string.format ("\"%s c %s\",", char, value))
	next_color = next_color + 1
	return char
end

local print_xpm = true

if print_xpm then
	print ("/* XPM */")
	print ("static char *map[] = {")

	local rows = {}
	local floor = math.floor

	for z = floor (-WIDTH / 2), floor (WIDTH / 2) do
		local row = {}
		for x = floor (-WIDTH / 2), floor (WIDTH / 2) do
			local sample = level:index_biomes (x, 64, z)
			table.insert (row, alloc_color (sample))
		end
		table.insert (rows, "\"" .. table.concat (row) .. "\",")
	end

	print (string.format ("\"%d %d %d 1\",", WIDTH, HEIGHT, n_colors))
	print (table.concat (colordefs, "\n"))
	print (table.concat (rows, "\n"))
	print ("\n}\n")
else
	local floor = math.floor
	for z = floor (-WIDTH / 2), floor (WIDTH / 2) do
		for x = floor (-WIDTH / 2), floor (WIDTH / 2) do
			local sample = level:index_biomes (x, 64, z)
			print (x, 64, z, sample)
		end
	end
end
