local S = core.get_translator(core.get_current_modname())

mcl_cocoas = {}

local function cocoa_place(itemstack, placer, pt, plantname)
	if not pt or pt.type ~= "node" then	return end
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pt)
	if rc then return rc end
	local under = core.get_node(pt.under)
	if under.name ~= "mcl_trees:tree_jungle"
	or core.get_node(pt.above).name ~= "air" then
		return
	end

	local clickdir = vector.subtract(pt.under, pt.above)
	if clickdir.y ~= 0 then return end
	-- Add the node, set facedir and remove 1 item from the itemstack
	core.set_node(pt.above, {name = plantname, param2 = core.dir_to_facedir(clickdir)})
	core.sound_play("default_place_node", {pos = pt.above, gain = 1.0}, true)
	if not core.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end

-- Attempts to grow a cocoa at pos, returns true when grown, returns false if there's no cocoa
-- or it is already at full size
function mcl_cocoas.grow(pos)
	local node = core.get_node(pos)
	if node.name == "mcl_cocoas:cocoa_1" then
		core.set_node(pos, {name = "mcl_cocoas:cocoa_2", param2 = node.param2})
	elseif node.name == "mcl_cocoas:cocoa_2" then
		core.set_node(pos, {name = "mcl_cocoas:cocoa_3", param2 = node.param2})
		return true
	end
	return false
end

local tpl_cocoa = {
	_doc_items_create_entry = true,
	_doc_items_longdesc = S("Cocoa pods grow on the side of jungle trees in 3 stages."),
	drawtype = "mesh",
	mesh = "mcl_cocoas_cocoa_stage_0.obj",
	tiles = {"mcl_cocoas_cocoa_stage_0.png"},
	use_texture_alpha = "clip",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {
		handy = 1, axey = 1,
		dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1,
		attached_node_facedir=1,
		not_in_creative_inventory=1,
		cocoa=1, unsticky = 1
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.2,
	_mcl_baseitem = "mcl_cocoas:cocoa_beans",
	_on_bone_meal = function(_, _, _, pos, n)
		if n.name == "mcl_cocoas:cocoa_1" or n.name == "mcl_cocoas:cocoa_2" then
			return mcl_cocoas.grow(pos)
		end
		return false
	end,
}

local boxes = {
	{-0.125, -0.0625, 0.1875, 0.125, 0.25, 0.4375},
	{-0.1875, -0.1875, 0.0625, 0.1875, 0.25, 0.4375},
	{-0.25, -0.3125, -0.0625, 0.25, 0.25, 0.4375},
}

local descs = {
	S("Premature Cocoa Pod"),
	S("Medium Cocoa Pod"),
	S("Mature Cocoa Pod")
}

for i=1,3 do
	local drop = "mcl_cocoas:cocoa_beans"
	if i == 3 then drop =  "mcl_cocoas:cocoa_beans 3" end
	core.register_node("mcl_cocoas:cocoa_"..i, table.merge(tpl_cocoa, {
		description = descs[i],
		_doc_items_create_entry = false,
		groups = table.merge(tpl_cocoa.groups, { cocoa = i }),
		mesh = "mcl_cocoas_cocoa_stage_"..(i - 1)..".obj",
		tiles = {"mcl_cocoas_cocoa_stage_"..(i - 1)..".png"},
		collision_box = {
			type = "fixed",
			fixed = { boxes[i] },
		},
		selection_box = {
			type = "fixed",
			fixed = { boxes[i] },
		},
		drop = drop,
	}))
end

core.register_craftitem("mcl_cocoas:cocoa_beans", {
	description = S("Cocoa Beans"),
	_tt_help = S("Grows at the side of jungle trees"),
	_doc_items_longdesc = S("Cocoa beans can be used to plant cocoa, bake cookies or craft brown dye."),
	_doc_items_usagehelp = S("Right click on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa."),
	inventory_image = "mcl_cocoas_cocoa_beans.png",
	groups = {craftitem = 1, compostability = 65},
	on_place = function(itemstack, placer, pointed_thing)
		return cocoa_place(itemstack, placer, pointed_thing, "mcl_cocoas:cocoa_1")
	end,
	_mcl_crafting_output = {single = {output = "mcl_dyes:brown"}}
})

core.register_abm({
		label = "Cocoa pod growth",
		nodenames = {"mcl_cocoas:cocoa_1", "mcl_cocoas:cocoa_2"},
		-- TODO: Tweak/balance the growth speed
		interval = 50,
		chance = 20,
		action = function(pos)
			mcl_cocoas.grow(pos)
		end
})

doc.add_entry_alias("nodes", "mcl_cocoas:cocoa_1", "nodes", "mcl_cocoas:cocoa_2")
