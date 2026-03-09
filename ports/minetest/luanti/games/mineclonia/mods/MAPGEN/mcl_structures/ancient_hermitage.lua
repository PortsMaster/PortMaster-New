local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
-- Ancient Hermitage - mini ancient city

mcl_structures.register_structure("ancient_hermitage",{
	place_on = {"mcl_deepslate:deepslate","mcl_sculk:sculk"},
	flags = "all_floors",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 1, --high prob since placement underground is relatively unlikely
	y_max = mcl_vars.mg_overworld_min + 72,
	y_min = mcl_vars.mg_overworld_min + 12,
	biomes = { "DeepDark" },
	sidelen = 32,
	filenames = {
		modpath.."/schematics/mcl_structures_ancient_hermitage.mts",
		modpath.."/schematics/mcl_structures_ancient_hermitage_2.mts",
		modpath.."/schematics/mcl_structures_ancient_hermitage_3.mts",
		modpath.."/schematics/mcl_structures_ancient_hermitage_4.mts",
	},

	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 3,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 7, amount_min = 6, amount_max=15 },
				{ itemstring = "mcl_mobitems:bone", weight = 5, amount_min = 1, amount_max = 15 },
				{ itemstring = "mcl_blackstone:soul_torch", weight = 5, amount_min = 1, amount_max=15 },
				{ itemstring = "mcl_books:book", weight = 5, amount_min = 3, amount_max=10 },
				{ itemstring = "mcl_potions:regeneration", weight = 5, amount_min = 1, amount_max=1 },
				{ itemstring = "mcl_books:book", weight = 5, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },

				--{ itemstring = "mcl_jukebox:disc_fragment", weight = 4, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_amethyst:amethyst_shard", weight = 3, amount_min = 1, amount_max = 15 },
				{ itemstring = "mcl_lush_caves:glow_berry", weight = 3, amount_min = 1, amount_max = 15 },
				{ itemstring = "mcl_sculk:sculk", weight = 3, amount_min = 4, amount_max = 10 },
				{ itemstring = "mcl_sculk:echo_shard", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_candles:candle_1", weight = 3, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_experience:bottle", weight = 3, amount_min = 1, amount_max = 3 },
				--{ itemstring = "mcl_sculk:sensor", weight = 3, amount_min = 1, amount_max = 3 },
				--SWIFT SNEAK{ itemstring = "mcl_books:book", weight = 5, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },

				{ itemstring = "mcl_armor:leggings_iron", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:ward", weight = 1 },
				{ itemstring = "mcl_armor:silence", weight = 1 },

				{ itemstring = "mcl_sculk:catalyst", weight = 2, amount_min = 1, amount_max = 2 },
				{ itemstring = "mcl_compass:compass", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_jukebox:record_1", weight = 2 },
				{ itemstring = "mcl_jukebox:record_4", weight = 2 },

				--{ itemstring = "mcl_mobitems:LEAD", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_mobitems:nametag", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:leather", weight = 2, amount_min = 1, amount_max = 5 },

				{ itemstring = "mcl_farming:hoe_diamond", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 2 },

				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 1 },
				{ itemstring = "mcl_jukebox:record_8", weight = 2 },

			}},
		}
	}
})
