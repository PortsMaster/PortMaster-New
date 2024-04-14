local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function temple_placement_callback(pos,def, pr)
	local hl = def.sidelen / 2
	local p1 = vector.offset(pos,-hl,-hl,-hl)
	local p2 = vector.offset(pos,hl,hl,hl)
	-- Delete cacti leftovers:
	local cactus_nodes = minetest.find_nodes_in_area_under_air(p1, p2, "mcl_core:cactus")
	if cactus_nodes and #cactus_nodes > 0 then
		for _, pos in pairs(cactus_nodes) do
			local node_below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
			if node_below and node_below.name == "mcl_core:sandstone" then
				minetest.swap_node(pos, {name="air"})
			end
		end
	end

	-- Initialize pressure plates and randomly remove up to 5 plates
	local pplates = minetest.find_nodes_in_area(p1, p2, "mesecons_pressureplates:pressure_plate_stone_off")
	local pplates_remove = 5
	for p=1, #pplates do
		if pplates_remove > 0 and pr:next(1, 100) >= 50 then
			-- Remove plate
			minetest.remove_node(pplates[p])
			pplates_remove = pplates_remove - 1
		else
			-- Initialize plate
			minetest.registered_nodes["mesecons_pressureplates:pressure_plate_stone_off"].on_construct(pplates[p])
		end
	end
	if minetest.registered_nodes["mcl_sus_nodes:sand"] then
		local sus_poss = minetest.find_nodes_in_area(vector.offset(p1,0,-5,0), vector.offset(p2,0,-hl+5,0), {"mcl_core:sand","mcl_core:sandstone","mcl_core:redsand","mcl_core:redsandstone"})
		if #sus_poss > 0 then
			table.shuffle(sus_poss)
			for i = 1,pr:next(1,math.min(250,#sus_poss)) do
				minetest.set_node(sus_poss[i],{name="mcl_sus_nodes:sand"})
				local meta = minetest.get_meta(sus_poss[i])
				meta:set_string("structure","desert_temple")
			end
		end
	end
end

mcl_structures.register_structure("desert_temple",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	sidelen = 18,
	y_offset = -12,
	chunk_probability = 300,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_temple.mts" },
	after_place = temple_placement_callback,
	loot = {
		["mcl_chests:chest" ] ={
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 25, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 25, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_mobitems:spider_eye", weight = 25, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_books:book", weight = 20, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_mobitems:saddle", weight = 20, },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "", weight = 15, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 15, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 10, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 5, },
				{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
				{ itemstring = "mcl_armor:dune", weight = 20, amount_min = 2, amount_max = 2},
			}
		},
		{
			stacks_min = 4,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:sand", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
			}
		}},
		["SUS"] = {
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_pottery_sherds:archer", weight = 21, },
				{ itemstring = "mcl_core:emerald", weight = 1 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 1 },
				{ itemstring = "mcl_pottery_sherds:miner", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:prize", weight = 1, },
				{ itemstring = "mcl_pottery_sherds:skull", weight = 1, },
				{ itemstring = "mcl_tnt:tnt", weight = 1 },
				{ itemstring = "mcl_core:diamond", weight = 1 },
			}
		}},
	},
})
