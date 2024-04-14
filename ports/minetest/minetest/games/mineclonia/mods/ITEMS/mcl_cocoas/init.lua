local S = minetest.get_translator(minetest.get_current_modname())

mcl_cocoas = {}

-- Place cocoa
local function cocoa_place(itemstack, placer, pt, plantname)
	-- check if pointing at a node
	if not pt or pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)

	-- return if any of the nodes are not registered
	if not minetest.registered_nodes[under.name] then
		return
	end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pt)
	if rc then return rc end

	-- Check if pointing at jungle tree
	if under.name ~= "mcl_trees:tree_jungle"
	or minetest.get_node(pt.above).name ~= "air" then
		return
	end

	-- Determine cocoa direction
	local clickdir = vector.subtract(pt.under, pt.above)

	-- Did user click on the SIDE of a jungle tree?
	if clickdir.y ~= 0 then
		return
	end

	-- Add the node, set facedir and remove 1 item from the itemstack
	minetest.set_node(pt.above, {name = plantname, param2 = minetest.dir_to_facedir(clickdir)})

	minetest.sound_play("default_place_node", {pos = pt.above, gain = 1.0}, true)

	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end

	return itemstack
end

-- Attempts to grow a cocoa at pos, returns true when grown, returns false if there's no cocoa
-- or it is already at full size
function mcl_cocoas.grow(pos)
	local node = minetest.get_node(pos)
	if node.name == "mcl_cocoas:cocoa_1" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_2", param2 = node.param2})
	elseif node.name == "mcl_cocoas:cocoa_2" then
		minetest.set_node(pos, {name = "mcl_cocoas:cocoa_3", param2 = node.param2})
		return true
	end
	return false
end

-- Cocoa definition
-- 1st stage
local crop_def = {
	description = S("Premature Cocoa Pod"),
	_doc_items_create_entry = true,
	_doc_items_longdesc = S("Cocoa pods grow on the side of jungle trees in 3 stages."),
	drawtype = "mesh",
	mesh = "mcl_cocoas_cocoa_stage_0.obj",
	tiles = {"mcl_cocoas_cocoa_stage_0.png"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	walkable = true,
	drop = "mcl_cocoas:cocoa_beans",
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.0625, 0.1875, 0.125, 0.25, 0.4375},  -- Pod
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.0625, 0.1875, 0.125, 0.5, 0.5},  -- Pod
		},
	},
	groups = {
		handy = 1, axey = 1,
		dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1,
		attached_node_facedir=1,
		not_in_creative_inventory=1,
		cocoa=1
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.2,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,n)
		if n.name == "mcl_cocoas:cocoa_1" or n.name == "mcl_cocoas:cocoa_2" then
			return mcl_cocoas.grow(pos)
		end
		return false
	end,
}

-- 2nd stage
minetest.register_node("mcl_cocoas:cocoa_1", table.copy(crop_def))

crop_def.description = S("Medium Cocoa Pod")
crop_def._doc_items_create_entry = false
crop_def.groups.cocoa = 2
crop_def.mesh = "mcl_cocoas_cocoa_stage_1.obj"
crop_def.tiles = {"mcl_cocoas_cocoa_stage_1.png"}
crop_def.collision_box = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.1875, 0.0625, 0.1875, 0.25, 0.4375},  -- Pod
	},
}
crop_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.1875, -0.1875, 0.0625, 0.1875, 0.5, 0.5},
	},
}

minetest.register_node("mcl_cocoas:cocoa_2", table.copy(crop_def))

-- Final stage
crop_def.description = S("Mature Cocoa Pod")
crop_def._doc_items_longdesc = S("A mature cocoa pod grew on a jungle tree to its full size and it is ready to be harvested for cocoa beans. It won't grow any further.")
crop_def._doc_items_create_entry = true
crop_def.groups.cocoa = 3
crop_def.mesh = "mcl_cocoas_cocoa_stage_2.obj"
crop_def.tiles = {"mcl_cocoas_cocoa_stage_2.png"}
crop_def.collision_box = {
	type = "fixed",
	fixed = {
		{-0.25, -0.3125, -0.0625, 0.25, 0.25, 0.4375},  -- Pod
	},
}
crop_def.selection_box = {
	type = "fixed",
	fixed = {
		{-0.25, -0.3125, -0.0625, 0.25, 0.5, 0.5},
	},
}
crop_def.drop = "mcl_cocoas:cocoa_beans 3"
minetest.register_node("mcl_cocoas:cocoa_3", table.copy(crop_def))

minetest.register_craftitem("mcl_cocoas:cocoa_beans", {
	description = S("Cocoa Beans"),
	_tt_help = S("Grows at the side of jungle trees"),
	_doc_items_longdesc = S("Cocoa beans can be used to plant cocoa, bake cookies or craft brown dye."),
	_doc_items_usagehelp = S("Right click on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa."),
	inventory_image = "mcl_cocoas_cocoa_beans.png",
	groups = {craftitem = 1, compostability = 65},
	on_place = function(itemstack, placer, pointed_thing)
		return cocoa_place(itemstack, placer, pointed_thing, "mcl_cocoas:cocoa_1")
	end,
})

minetest.register_abm({
		label = "Cocoa pod growth",
		nodenames = {"mcl_cocoas:cocoa_1", "mcl_cocoas:cocoa_2"},
		-- Same as potatoes
		-- TODO: Tweak/balance the growth speed
		interval = 50,
		chance = 20,
		action = function(pos, node)
			mcl_cocoas.grow(pos)
		end
}	)

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_cocoas:cocoa_1", "nodes", "mcl_cocoas:cocoa_2")
end
