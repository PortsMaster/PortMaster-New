local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_nether:nether_wart_0", {
	description = S("Premature Nether Wart (Stage 1)"),
	_doc_items_longdesc = S("A premature nether wart has just recently been planted on soul sand. Nether wart slowly grows on soul sand in 4 stages (the second and third stages look identical). Although nether wart is home to the Nether, it grows in any dimension."),
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_0.png"},
	wield_image = "mcl_nether_nether_wart_stage_0.png",
	inventory_image = "mcl_nether_nether_wart_stage_0.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart_1", {
	description = S("Premature Nether Wart (Stage 2)"),
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_1.png"},
	wield_image = "mcl_nether_nether_wart_stage_1.png",
	inventory_image = "mcl_nether_nether_wart_stage_1.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.15, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart_2", {
	description = S("Premature Nether Wart (Stage 3)"),
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_1.png"},
	wield_image = "mcl_nether_nether_wart_stage_1.png",
	inventory_image = "mcl_nether_nether_wart_stage_1.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.15, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart", {
	description = S("Mature Nether Wart"),
	_doc_items_longdesc = S("The mature nether wart is a plant from the Nether and reached its full size and won't grow any further. It is ready to be harvested for its items."),
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = {
		max_items = 2,
		items = {
			{ items = {"mcl_nether:nether_wart_item 2"}, rarity = 1 },
			{ items = {"mcl_nether:nether_wart_item 2"}, rarity = 3 },
			{ items = {"mcl_nether:nether_wart_item 1"}, rarity = 3 },
		},
	},
	tiles = {"mcl_nether_nether_wart_stage_2.png"},
	wield_image = "mcl_nether_nether_wart_stage_2.png",
	inventory_image = "mcl_nether_nether_wart_stage_2.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.45, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mcl_nether:nether_wart_item"},
		min_count = 2,
		max_count = 4,
	}
})

minetest.register_craftitem("mcl_nether:nether_wart_item", {
	description = S("Nether Wart"),
	_tt_help = S("Grows on soul sand"),
	_doc_items_longdesc = S("Nether warts are plants home to the Nether. They can be planted on soul sand and grow in 4 stages."),
	_doc_items_usagehelp = S("Place this item on soul sand to plant it and watch it grow."),
	inventory_image = "mcl_nether_nether_wart.png",
	wield_image = "mcl_nether_nether_wart.png",
	groups = {craftitem = 1, brewitem = 1, compostability = 30},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local placepos = pointed_thing.above
		local soilpos = table.copy(placepos)
		soilpos.y = soilpos.y - 1

		-- Check for correct soil type
		local chk = minetest.get_item_group(minetest.get_node(soilpos).name, "soil_nether_wart")
		if chk and chk ~= 0 then
			-- Check if node above soil node allows placement
			if minetest.registered_items[minetest.get_node(placepos).name].buildable_to then
				-- Place nether wart
				minetest.sound_play({name="default_place_node", gain=1.0}, {pos=placepos}, true)
				minetest.set_node(placepos, {name="mcl_nether:nether_wart_0", param2 = 3})

				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end
	end,
})

local names = {"mcl_nether:nether_wart_0", "mcl_nether:nether_wart_1", "mcl_nether:nether_wart_2"}

minetest.register_abm({
	label = "Nether wart growth",
	nodenames = {"mcl_nether:nether_wart_0", "mcl_nether:nether_wart_1", "mcl_nether:nether_wart_2"},
	neighbors = {"group:soil_nether_wart"},
	interval = 35,
	chance = 11,
	action = function(pos, node)
		pos.y = pos.y-1
		if minetest.get_item_group(minetest.get_node(pos).name, "soil_nether_wart") == 0 then
			return
		end
		pos.y = pos.y+1
		local step = nil
		for i,name in ipairs(names) do
			if name == node.name then
				step = i
				break
			end
		end
		if step == nil then
			return
		end
		local new_node = {name=names[step+1]}
		if new_node.name == nil then
			new_node.name = "mcl_nether:nether_wart"
		end
		new_node.param = node.param
		new_node.param2 = node.param2
		minetest.set_node(pos, new_node)
	end
})

if minetest.get_modpath("doc") then
	for i=1,2 do
		doc.add_entry_alias("nodes", "mcl_nether:nether_wart_0", "nodes", "mcl_nether:nether_wart_"..i)
	end
end
