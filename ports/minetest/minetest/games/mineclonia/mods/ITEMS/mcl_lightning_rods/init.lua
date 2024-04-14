local S = minetest.get_translator("mcl_lightning_rods")

local cbox = {
	type = "fixed",
	fixed = {
		{ -0.0625, -0.5, -0.0625, 0.0625, 0.25, 0.0625 },
		{ -0.125, 0.25, -0.125, 0.125, 0.5, 0.125 },
	},
}

local rod_def = {
	description = S("Lightning Rod"),
	_doc_items_longdesc = S("A block that attracts lightning"),
	tiles = { "mcl_lightning_rods_rod.png" },
	drawtype = "mesh",
	mesh = "mcl_lightning_rods_rod.obj",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "opaque",
	groups = { pickaxey = 2, attracts_lightning = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	selection_box = cbox,
	collision_box = cbox,
	node_placement_prediction = "",
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.alldirs,
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,

	_mcl_blast_resistance = 0,
}

minetest.register_node("mcl_lightning_rods:rod", rod_def)

local rod_def_a = table.copy(rod_def)

rod_def_a.tiles = { "mcl_lightning_rods_rod.png^[brighten" }

rod_def_a.groups.not_in_creative_inventory = 1

rod_def_a.mesecons = {
	receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.alldirs,
	},
}

rod_def_a.on_timer = function(pos, elapsed)
	local node = minetest.get_node(pos)

	if node.name == "mcl_lightning_rods:rod_powered" then --has not been dug
		node.name = "mcl_lightning_rods:rod"
		minetest.set_node(pos, node)
		mesecon.receptor_off(pos, mesecon.rules.alldirs)
	end

	return false
end

minetest.register_node("mcl_lightning_rods:rod_powered", rod_def_a)

mcl_lightning.register_on_strike(function(pos, pos2, objects)
	local lr = minetest.find_nodes_in_area_under_air(vector.offset(pos, -64, -32, -64), vector.offset(pos, 64, 64, 64), { "group:attracts_lightning" }, true)
	lr = (lr and #lr > 0 and lr[1]) or false
	if lr then
		local node = minetest.get_node(lr)

		if node.name == "mcl_lightning_rods:rod" then
			node.name = "mcl_lightning_rods:rod_powered"
			minetest.set_node(lr, node)
			mesecon.receptor_on(lr, mesecon.rules.alldirs)
			minetest.get_node_timer(lr):start(0.4)
		end
	end

	return lr, nil
end)

minetest.register_craft({
	output = "mcl_lightning_rods:rod",
	recipe = {
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
		{ "", "mcl_copper:copper_ingot", "" },
	},
})
