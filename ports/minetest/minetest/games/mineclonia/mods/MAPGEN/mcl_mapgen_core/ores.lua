
local deepslate_max = mcl_worlds.layer_to_y(16)
local deepslate_min = mcl_vars.mg_overworld_min

local copper_mod = minetest.get_modpath("mcl_copper")

local mountains = {
	"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
	"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
	"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
}

--Clay
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:clay",
	wherein        = {"mcl_core:sand","mcl_core:stone","mcl_core:gravel"},
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = -5,
	y_max          = 0,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 34843,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Diorite, andesite and granite
local specialstones = { "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_core:stone"},
		clust_scarcity = 15*15*15,
		clust_num_ores = 33,
		clust_size     = 5,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_core:stone"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 58,
		clust_size     = 7,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
end

local stonelike = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite"}

-- Dirt
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:dirt",
	wherein        = stonelike,
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_vars.mg_overworld_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        = stonelike,
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_deepslate:deepslate",
	wherein        = { "mcl_core:stone" },
	clust_scarcity = 200,
	clust_num_ores = 100,
	clust_size     = 10,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = { x = 250, y = 250, z = 250 },
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_deepslate:tuff",
	wherein        = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_deepslate:deepslate" },
	clust_scarcity = 10*10*10,
	clust_num_ores = 58,
	clust_size     = 7,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_deepslate:infested_deepslate",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 26 * 26 * 26,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	biomes         = mountains,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = deepslate_max,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = deepslate_max,
})

if minetest.settings:get_bool("mcl_generate_ores", true) then
	--
	-- Coal
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 510*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 12,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})

	-- Medium-rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 600*3,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})

	--
	-- Iron
	--
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 830,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(39),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 1660,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(40),
		y_max          = mcl_worlds.layer_to_y(63),
	})

	--
	-- Gold
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 4775,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(30),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 6560,
		clust_num_ores = 7,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(30),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 13000,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(31),
		y_max          = mcl_worlds.layer_to_y(33),
	})

	--
	-- Diamond
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 5000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

		--
	-- Ancient debris
	--
	local ancient_debris_wherein = {"mcl_nether:netherrack","mcl_blackstone:blackstone","mcl_blackstone:basalt"}
	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 25000, -- 0.004% chance
		clust_num_ores = 3,
		clust_size     = 3,
		y_min = mcl_vars.mg_nether_min + 8,
		y_max = mcl_vars.mg_nether_min + 22,
	})

		-- Rare spawn (below)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 32000,
		clust_num_ores = 2,
		clust_size     = 3,
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_min + 8,
	})

	-- Rare spawn (above)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 32000,
		clust_num_ores = 2,
		clust_size     = 3,
		y_min = mcl_vars.mg_nether_min + 22,
		y_max = mcl_vars.mg_nether_min + 119,
	})

	--
	-- Redstone
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 500,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 800,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(13),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1600,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

	--
	-- Lapis Lazuli
	--

	-- Common spawn (in the center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 7000,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_worlds.layer_to_y(14),
		y_max          = mcl_worlds.layer_to_y(16),
	})

	-- Rare spawn (below center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(10),
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 12000,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(6),
		y_max          = mcl_worlds.layer_to_y(9),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 16000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(2),
		y_max          = mcl_worlds.layer_to_y(5),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 18000,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(0),
		y_max          = mcl_worlds.layer_to_y(2),
	})

	-- Rare spawn (above center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(17),
		y_max          = mcl_worlds.layer_to_y(20),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 12000,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(21),
		y_max          = mcl_worlds.layer_to_y(24),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 14000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(25),
		y_max          = mcl_worlds.layer_to_y(28),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 18000,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(29),
		y_max          = mcl_worlds.layer_to_y(32),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 28000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = mcl_worlds.layer_to_y(31),
		y_max          = mcl_worlds.layer_to_y(32),
	})

	local stonelike = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" }
	local function register_ore_mg(ore, scarcity, num, size, y_min, y_max, biomes)
		biomes = biomes or ""
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = ore,
			wherein        = { "mcl_deepslate:deepslate", "mcl_deepslate:tuff" },
			clust_scarcity = scarcity,
			clust_num_ores = num,
			clust_size     = size,
			y_min          = y_min,
			y_max          = y_max,
			biomes		   = biomes,
		})
	end
	local ore_mapgen = {
		{ "coal", 1575, 5, 3, deepslate_min, deepslate_max },
		{ "coal", 1530, 8, 3, deepslate_min, deepslate_max },
		{ "coal", 1500, 12, 3, deepslate_min, deepslate_max },
		{ "iron", 830, 5, 3, deepslate_min, deepslate_max },
		{ "gold", 4775, 5, 3, deepslate_min, deepslate_max },
		{ "gold", 6560, 7, 3, deepslate_min, deepslate_max },
		{ "diamond", 10000, 4, 3, deepslate_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 5000, 2, 3, deepslate_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 10000, 8, 3, deepslate_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 20000, 1, 1, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "diamond", 20000, 2, 2, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "redstone", 500, 4, 3, deepslate_min, mcl_worlds.layer_to_y(13) },
		{ "redstone", 800, 7, 4, deepslate_min, mcl_worlds.layer_to_y(13) },
		{ "redstone", 1000, 4, 3, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "redstone", 1600, 7, 4, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "lapis", 10000, 7, 4, mcl_worlds.layer_to_y(14), deepslate_max },
		{ "lapis", 12000, 6, 3, mcl_worlds.layer_to_y(10), mcl_worlds.layer_to_y(13) },
		{ "lapis", 14000, 5, 3, mcl_worlds.layer_to_y(6), mcl_worlds.layer_to_y(9) },
		{ "lapis", 16000, 4, 3, mcl_worlds.layer_to_y(2), mcl_worlds.layer_to_y(5) },
		{ "lapis", 18000, 3, 2, mcl_worlds.layer_to_y(0), mcl_worlds.layer_to_y(2) },
	}
	for _, o in pairs(ore_mapgen) do
		register_ore_mg("mcl_deepslate:deepslate_with_"..o[1], o[2], o[3], o[4], o[5], o[6])
	end

	register_ore_mg("mcl_deepslate:deepslate_with_emerald", 16384, 1, 1, mcl_worlds.layer_to_y(4), deepslate_max, mountains)

	if copper_mod then
		register_ore_mg("mcl_deepslate:deepslate_with_copper", 830, 5, 3, deepslate_min, deepslate_max)
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 830,
			clust_num_ores = 5,
			clust_size     = 3,
			y_min          = mcl_vars.mg_overworld_min,
			y_max          = mcl_worlds.layer_to_y(39),
		})
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 1660,
			clust_num_ores = 4,
			clust_size     = 2,
			y_min          = mcl_worlds.layer_to_y(40),
			y_max          = mcl_worlds.layer_to_y(63),
		})
	end
end

if not mcl_vars.superflat then
-- Water and lava springs (single blocks of lava/water source)
-- Water appears at nearly every height, but not near the bottom
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein         = {"mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:dirt"},
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = mcl_worlds.layer_to_y(128),
})

-- Lava springs are rather common at -31 and below
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = mcl_worlds.layer_to_y(31),
})

-- Lava springs will become gradually rarer with increasing height
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 32000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(32),
	y_max          = mcl_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 72000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(48),
	y_max          = mcl_worlds.layer_to_y(61),
})

-- Lava may even appear above surface, but this is very rare
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 96000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(62),
	y_max          = mcl_worlds.layer_to_y(127),
})
end
