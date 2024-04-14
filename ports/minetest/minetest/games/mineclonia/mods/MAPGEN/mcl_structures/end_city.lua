local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local spawnon = {"mcl_end:purpur_block"}

local function spawn_shulkers(pos,def,pr)
	local p1 = vector.offset(pos,-def.sidelen/2,-1,-def.sidelen/2)
	local p2 = vector.offset(pos,def.sidelen/2,def.sidelen,def.sidelen/2)
	mcl_structures.spawn_mobs("mobs_mc:shulker",spawnon,p1,p2,pr,1)

	local guard = minetest.find_node_near(pos,def.sidelen,{"mcl_itemframes:frame"})
	if guard then
		minetest.add_entity(vector.offset(guard,0,-1.5,0),"mobs_mc:shulker")
	end
end

mcl_structures.register_structure("end_shipwreck",{
	place_on = {"mcl_end:end_stone"},
	fill_ratio = 0.001,
	flags = "place_center_x, place_center_z, all_floors",
	y_offset = function(pr) return pr:next(-50,-20) end,
	chunk_probability = 800,
	--y_max = mcl_vars.mg_end_max,
	--y_min = mcl_vars.mg_end_min -100,
	biomes = { "End", "EndHighlands", "EndMidlands", "EndBarrens", "EndSmallIslands" },
	sidelen = 32,
	filenames = {
		modpath.."/schematics/mcl_structures_end_shipwreck_1.mts",
	},
	construct_nodes = {"mcl_chests:ender_chest_small","mcl_chests:ender_chest","mcl_brewing:stand_000","mcl_chests:violet_shulker_box_small"},
	after_place = function(pos,def,pr)
		local fr = minetest.find_node_near(pos,def.sidelen,{"mcl_itemframes:frame"})
		if fr then
			if mcl_itemframes then
				mcl_itemframes.update_entity(fr)
			end
		end
		return spawn_shulkers(pos,def,pr)
	end,
	loot = {
		[ "mcl_itemframes:frame" ] ={{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_armor:elytra", weight = 100 },
			},
		}},
		[ "mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_farming:beetroot_seeds", weight = 16, amount_min = 1, amount_max=10 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_bamboo:bamboo", weight = 15, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 4, amount_max = 8 },
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3, },
				{ itemstring = "mcl_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_armor:spire", amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_books:book", weight = 1, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_tools:pick_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:shovel_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:sword_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:helmet_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:chestplate_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:boots_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:pick_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:shovel_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:sword_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:helmet_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:chestplate_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:boots_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		}}
	}
})

mcl_structures.register_structure("end_boat",{
	place_on = {"mcl_end:end_stone"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, all_floors",
	y_offset = function(pr) return pr:next(15,30) end,
	chunk_probability = 900,
	--y_max = mcl_vars.mg_end_max,
	--y_min = mcl_vars.mg_end_min -100,
	biomes = { "End", "EndHighlands", "EndMidlands", "EndBarrens", "EndSmallIslands" },
	sidelen = 20,
	filenames = {
		modpath.."/schematics/mcl_structures_end_boat.mts",
	},
	after_place = spawn_shulkers,
	construct_nodes = {"mcl_chests:ender_chest_small","mcl_chests:ender_chest","mcl_brewing:stand_000","mcl_chests:violet_shulker_box_small"},
	loot = {
		[ "mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_farming:beetroot_seeds", weight = 16, amount_min = 1, amount_max=10 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 4, amount_max = 8 },
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3, },
				{ itemstring = "mcl_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:pick_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:shovel_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:sword_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:helmet_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:chestplate_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:boots_iron_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:pick_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_tools:shovel_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:helmet_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:boots_diamond_enchanted", weight = 3,func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		}}
	}
})

mcl_structures.register_structure_spawn({
	name = "mobs_mc:shulker",
	y_min = mcl_vars.mg_end_min,
	y_max = mcl_vars.mg_end_max,
	chance = 10,
	interval = 60,
	limit = 6,
	spawnon = spawnon,
})
