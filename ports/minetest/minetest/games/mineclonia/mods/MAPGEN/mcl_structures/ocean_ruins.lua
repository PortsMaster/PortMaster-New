local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local cold_oceans = {
	"RoofedForest_ocean",
	"BirchForestM_ocean",
	"BirchForest_ocean",
	"IcePlains_deep_ocean",
	"ExtremeHillsM_deep_ocean",
	"SunflowerPlains_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"ExtremeHillsM_ocean",
	"SunflowerPlains_deep_ocean",
	"BirchForest_deep_ocean",
	"IcePlainsSpikes_ocean",
	"StoneBeach_ocean",
	"ColdTaiga_deep_ocean",
	"Forest_deep_ocean",
	"FlowerForest_deep_ocean",
	"MegaTaiga_ocean",
	"StoneBeach_deep_ocean",
	"IcePlainsSpikes_deep_ocean",
	"ColdTaiga_ocean",
	"ExtremeHills+_deep_ocean",
	"ExtremeHills_ocean",
	"Forest_ocean",
	"MegaTaiga_deep_ocean",
	"MegaSpruceTaiga_ocean",
	"ExtremeHills+_ocean",
	"RoofedForest_deep_ocean",
	"IcePlains_ocean",
	"FlowerForest_ocean",
	"ExtremeHills_deep_ocean",
	"Taiga_ocean",
	"BirchForestM_deep_ocean",
	"Taiga_deep_ocean",
}

local warm_oceans = {
	"JungleEdgeM_ocean",
	"Jungle_deep_ocean",
	"Savanna_ocean",
	"MesaPlateauF_ocean",
	"Swampland_ocean",
	"Mesa_ocean",
	"Plains_ocean",
	"MesaPlateauFM_ocean",
	"MushroomIsland_ocean",
	"SavannaM_ocean",
	"JungleEdge_ocean",
	"MesaBryce_ocean",
	"Jungle_ocean",
	"Desert_ocean",
	"JungleM_ocean",
	"JungleEdgeM_deep_ocean",
	"Jungle_deep_ocean",
	"Savanna_deep_ocean",
	"MesaPlateauF_deep_ocean",
	"Swampland_deep_ocean",
	"Mesa_deep_ocean",
	"Plains_deep_ocean",
	"MesaPlateauFM_deep_ocean",
	"MushroomIsland_deep_ocean",
	"SavannaM_deep_ocean",
	"JungleEdge_deep_ocean",
	"MesaBryce_deep_ocean",
	"Jungle_deep_ocean",
	"Desert_deep_ocean",
	"JungleM_deep_ocean",
}

local function place_sus_nodes(pos,def,pr,susnode,replace_nodes)
	local hl = def.sidelen / 2
	local p1 = vector.offset(pos,-hl,-hl,-hl)
	local p2 = vector.offset(pos,hl,hl,hl)
	if minetest.registered_nodes["mcl_sus_nodes:"..susnode] then
		local sus_poss = minetest.find_nodes_in_area(vector.offset(p1,0,-3,0), vector.offset(p2,0,-hl+2,0), replace_nodes)
		if #sus_poss > 0 then
			table.shuffle(sus_poss)
			for i = 1,pr:next(1,math.min(250,#sus_poss)) do
				minetest.set_node(sus_poss[i],{name="mcl_sus_nodes:"..susnode})
				local meta = minetest.get_meta(sus_poss[i])
				meta:set_string("structure", def.name)
			end
		end
	end
end

local cold = {
	place_on = {"group:sand","mcl_core:gravel","mcl_core:dirt","mcl_core:clay","group:material_stone"},
	spawn_by = {"mcl_core:water_source"},
	num_spawn_by = 2,
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, force_placement",
	solid_ground = true,
	make_foundation = true,
	y_offset = -1,
	y_min = mcl_vars.mg_overworld_min,
	y_max = -2,
	biomes = cold_oceans,
	chunk_probability = 400,
	sidelen = 10,
	filenames = {
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_1.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_2.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_3.mts",
	},
	after_place = function(pos,def,pr)
		place_sus_nodes(pos,def,pr,"gravel",{"mcl_core:gravel","mcl_core:sand","mcl_core:stone"})
	end,
	loot = {
		["mcl_chests:chest_small" ] = {
			{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 25, amount_min = 1, amount_max=4 },
				{ itemstring = "mcl_farming:wheat_item", weight = 25, amount_min = 2, amount_max=3 },
				{ itemstring = "mcl_core:gold_nugget", weight = 25, amount_min = 1, amount_max=3 },
				--{ itemstring = "mcl_maps:treasure_map", weight = 20, }, --FIXME Treasure map

				{ itemstring = "mcl_books:book", weight = 10, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_fishing:fishing_rod_enchanted", weight = 20, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end  },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_armor:chestplate_leather", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_armor:helmet_gold", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
				}
			}
		},
		["SUS"] = {
			{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 2 },
				{ itemstring = "mcl_core:emerald", weight = 2 },
				{ itemstring = "mcl_farming:wheat_item", weight = 2 },
				{ itemstring = "mcl_farming:hoe_wood", weight = 2 },
				{ itemstring = "mcl_core:gold_nugget", weight = 2 },
				{ itemstring = "mcl_pottery_sherds:blade", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:explorer", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:mourner", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:plenty", weight = 1, },
				{ itemstring = "mcl_tools:axe_iron", weight = 1 },
				}
			}
		},
	},
}

local warm = table.merge(cold,{
	after_place = function(pos,def,pr)
		place_sus_nodes(pos,def,pr,"sand",{"mcl_core:sand","mcl_core:gravel","mcl_core:stone","mcl_core:sandstone"})
	end,
	biomes = warm_oceans,
	filenames = {
		modpath.."/schematics/mcl_structures_ocean_ruins_warm_1.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_warm_2.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_warm_3.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_warm_4.mts",
	},
	loot = table.merge(cold.loot,{
		["SUS"] = {
			{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 2 },
				{ itemstring = "mcl_core:emerald", weight = 2 },
				{ itemstring = "mcl_farming:wheat_item", weight = 2 },
				{ itemstring = "mcl_farming:hoe_wood", weight = 2 },
				{ itemstring = "mcl_core:gold_nugget", weight = 2 },
				{ itemstring = "mcl_pottery_sherds:angler", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:shelter", weight = 1, },
				--FIXME: add sniffer egg { itemstring = "mobs_mc:SNIFFER", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:snort", weight = 1, },
				{ itemstring = "mcl_tools:axe_iron", weight = 1 },
				}
			}
		},
	}),
})

mcl_structures.register_structure("cold_ocean_ruins",cold)
mcl_structures.register_structure("warm_ocean_ruins",warm)
