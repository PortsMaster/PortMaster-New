local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local spawnon = {"mcl_core:stripped_oak","mcl_stairs:slab_birchwood_top"}

mcl_structures.register_structure("pillager_outpost",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass","group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	sidelen = 32,
	y_offset = 0,
	chunk_probability = 600,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert", "Plains", "Savanna", "IcePlains", "Taiga" },
	construct_nodes = {"mcl_anvils:anvil_damage_2"},
	filenames = {
		modpath.."/schematics/mcl_structures_pillager_outpost.mts",
		modpath.."/schematics/mcl_structures_pillager_outpost_2.mts"
	},
	loot = {
		["mcl_chests:chest_small" ] ={
		{
			stacks_min = 2,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 3, amount_max=5 },
				{ itemstring = "mcl_farming:carrot_item", weight = 5, amount_min = 3, amount_max=5 },
				{ itemstring = "mcl_farming:potato_item", weight = 5, amount_min = 2, amount_max=5 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_experience:bottle", weight = 6, amount_min = 0, amount_max=1 },
				{ itemstring = "mcl_bows:arrow", weight = 4, amount_min = 2, amount_max=7 },
				{ itemstring = "mcl_mobitems:string", weight = 4, amount_min = 1, amount_max=6 },
				{ itemstring = "mcl_core:iron_ingot", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_books:book", weight = 1, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_armor:sentry"},
			}
		},
		{
			stacks_min = 1,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_trees:tree_dark_oak", amount_min = 2, amount_max=3 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_bows:crossbow" },
			}
		}}
	},
	after_place = function(p,def,pr)
		local p1 = vector.offset(p,-9,0,-9)
		local p2 = vector.offset(p,9,32,9)
		mcl_structures.spawn_mobs("mobs_mc:pillager",spawnon,p1,p2,pr,5)
		mcl_structures.spawn_mobs("mobs_mc:parrot",{"mesecons_pressureplates:pressure_plate_stone_off"},p1,p2,pr,3)
		mcl_structures.spawn_mobs("mobs_mc:iron_golem",{"mesecons_button:button_stone_off"},p1,p2,pr,1)
		for _,n in pairs(minetest.find_nodes_in_area(p1,p2,{"group:wall"})) do
			mcl_walls.update_wall(n)
		end
	end
})

mcl_structures.register_structure_spawn({
	name = "mobs_mc:pillager",
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_vars.mg_overworld_max,
	chance = 10,
	interval = 60,
	limit = 9,
	spawnon = spawnon,
})
