---------------
---- Honey ----
---------------

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())
local alldirs = {{x=0,y=0,z=1}, {x=1,y=0,z=0}, {x=0,y=0,z=-1}, {x=-1,y=0,z=0}, {x=0,y=-1,z=0}, {x=0,y=1,z=0}}

-- Honeycomb
minetest.register_craftitem("mcl_honey:honeycomb", {
	description = S("Honeycomb"),
	_doc_items_longdesc = S("Used to craft beehives and protect copper blocks from further oxidation."),
	_doc_items_usagehelp = S("Use on copper blocks to prevent further oxidation."),
	inventory_image = "mcl_honey_honeycomb.png",
	groups = { craftitem = 1, preserves_copper = 1 },
})

minetest.register_node("mcl_honey:honeycomb_block", {
	description = S("Honeycomb Block"),
	_doc_items_longdesc = S("Honeycomb Block. Used as a decoration."),
	tiles = {
		"mcl_honey_honeycomb_block.png"
	},
	is_ground_content = false,
	groups = { handy = 1, deco_block = 1 },
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

-- Honey
minetest.register_craftitem("mcl_honey:honey_bottle", {
	description = S("Honey Bottle"),
	_doc_items_longdesc = S("Honey Bottle is used to craft honey blocks and to restore hunger points."),
	_doc_items_usagehelp = S("Drinking will restore 6 hunger points. Can also be used to craft honey blocks."),
	inventory_image = "mcl_honey_honey_bottle.png",
	groups = { craftitem = 1, food = 3, eatable = 6, can_eat_when_full=1 },
	on_place = minetest.item_eat(6, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(6, "mcl_potions:glass_bottle"),
	_mcl_saturation = 1.2,
	stack_max = 16,
})

minetest.register_node("mcl_honey:honey_block", {
	description = S("Honey Block"),
	_doc_items_longdesc = S("Honey Block. Used as a decoration and in redstone. Is sticky on some sides."),
	tiles = {"mcl_honey_block_side.png"},
	is_ground_content = false,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	groups = { handy = 1, deco_block = 1, fall_damage_add_percent = -80 },
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, -0.4, 0.4, 0.4, 0.4},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "regular",
	},
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	mvps_sticky = function(pos, node, piston_pos)
		local connected = {}
		for n, v in ipairs(alldirs) do
			local neighbor_pos = vector.add(pos, v)
			local neighbor_node = minetest.get_node(neighbor_pos)
			if neighbor_node then
				if neighbor_node.name == "ignore" then
					minetest.get_voxel_manip():read_from_map(neighbor_pos, neighbor_pos)
					neighbor_node = minetest.get_node(neighbor_pos)
				end
				local name = neighbor_node.name
				if name ~= "air" and name ~= "ignore" and name ~= "mcl_core:slimeblock" and not mesecon.mvps_unsticky[name] then
					local piston, piston_side, piston_up, piston_down = false, false, false, false
					if name == "mesecons_pistons:piston_sticky_off" or name == "mesecons_pistons:piston_normal_off" then
						piston, piston_side = true, true
					elseif name == "mesecons_pistons:piston_up_sticky_off" or name == "mesecons_pistons:piston_up_normal_off" then
						piston, piston_up = true, true
					elseif name == "mesecons_pistons:piston_down_sticky_off" or name == "mesecons_pistons:piston_down_normal_off" then
						piston, piston_down = true, true
					end
					if not(   (piston_side and (n-1==neighbor_node.param2))  or  (piston_up and (n==5))  or  (piston_down and (n==6))   ) then
						if piston and piston_pos then
							if piston_pos.x == neighbor_pos.x and piston_pos.y == neighbor_pos.y and piston_pos.z == neighbor_pos.z then
								-- Loopback to the same piston! Preventing unwanted behavior:
								return {}, true
							end
						end
						table.insert(connected, neighbor_pos)
					end
				end
			end
		end
		return connected, false
	end,
})

-- Crafting
minetest.register_craft({
	output = "mcl_honey:honeycomb_block",
	recipe = {
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
	},
})

minetest.register_craft({
	output = "mcl_honey:honey_block",
	recipe = {
		{ "mcl_honey:honey_bottle", "mcl_honey:honey_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_honey:honey_bottle" },
	},
	replacements = {
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
	},
})

minetest.register_craft({
	output = "mcl_honey:honey_bottle 4",
	recipe = {
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "mcl_honey:honey_block" },
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "" },
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:sugar 3",
	recipe = { "mcl_honey:honey_bottle" },
	replacements = {
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
	},
})
