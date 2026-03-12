local S = core.get_translator(core.get_current_modname())

-- Spawn a stand entity
local function spawn_stand_entity(pos, node)
	local luaentity = core.add_entity(pos, "mcl_armor_stand:armor_entity"):get_luaentity()
	if luaentity then
		luaentity:update_rotation(node or core.get_node(pos))
		return luaentity
	end
end

-- Find a stand entity or spawn one
local function get_stand_entity(pos, node)
	for obj in core.objects_inside_radius(pos, 0) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_armor_stand:armor_entity" then
			return luaentity
		end
	end
	return spawn_stand_entity(pos, node)
end

-- Migrate the old inventory format
local function migrate_inventory(inv)
	inv:set_size("armor", 5)
	local lists = inv:get_lists()
	for name, element in pairs(mcl_armor.elements) do
		local listname = "armor_" .. name
		local list = lists[listname]
		if list then
			inv:set_stack("armor", element.index, list[1])
			inv:set_size(listname, 0)
		end
	end
end

-- Drop all armor on the ground when it got destroyed
local function drop_inventory(pos)
	local inv = core.get_meta(pos):get_inventory()
	local list = inv:get_list("armor")
	if list then
		for _, stack in pairs(list) do
			mcl_util.drop_item_stack(
				vector.offset(pos, mcl_util.float_random(-0.5, 0.5), 0, mcl_util.float_random(-0.5, 0.5)),
				stack
			)
		end
	end
end

-- TODO: The armor stand should be an entity
core.register_node("mcl_armor_stand:armor_stand", {
	description = S("Armor Stand"),
	_tt_help = S("Displays pieces of armor"),
	_doc_items_longdesc = S("An armor stand is a decorative object which can display different pieces of armor. Anything which players can wear as armor can also be put on an armor stand."),
	_doc_items_usagehelp = S("Just place an armor item on the armor stand. To take the top piece of armor from the armor stand, select your hand and use the place key on the armor stand."),
	drawtype = "mesh",
	mesh = "3d_armor_stand.obj",
	inventory_image = "3d_armor_stand_item.png",
	wield_image = "3d_armor_stand_item.png",
	tiles = {"default_wood.png", "mcl_stairs_stone_slab_top.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	is_ground_content = false,
	stack_max = 16,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5},
			{-6/16, -0.5, -2/16, 6/16, 22/16, 2/16},
		}
	},
	-- TODO: This should be breakable by 2 quick punches
	groups = {handy=1, deco_block=1, dig_by_piston=1, attached_node=1},
	_mcl_hardness = 2,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		spawn_stand_entity(pos)
	end,
	on_destruct = function(pos)
		drop_inventory(pos)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local protname = clicker:get_player_name()
		if core.is_protected(pos, protname) then
			core.record_protection_violation(pos, protname)
			return itemstack
		end

		local stand_entity = get_stand_entity(pos, node).object
		local px, py, pz, ax, az = pos.x, pos.y, pos.z, pointed_thing.above.x, pointed_thing.above.z
		-- try to take armor from armor stand if pointing at side face
		if clicker:get_wielded_item():get_name() == "" and (px ~= ax or pz ~= az) then
			-- try to determine pointed armor element by preparing
			-- pointed_thing for core.pointed_thing_to_face_pos:
			--
			-- 1. force y to node pos.y (works around unexpected
			--    pointed_thing.above.y values when pointing at the
			--    part of the armor stand extending above the node
			--    position)
			--
			-- 2. move intersection plane closer to the plane where
			--    the armor is visually located to make the computed
			--    position less dependent on distance of player to
			--    armor stand
			local above = vector.new(ax, py, az)
			pointed_thing = { type = "node", under = (pos - above) * 0.75 + pos, above = above}
			local pointed_fpos = core.pointed_thing_to_face_pos(clicker, pointed_thing).y - py
			local pointed_piece_index

			if pointed_fpos > 0.9375 then
				pointed_piece_index = mcl_armor.elements.head.index
			elseif pointed_fpos > 0.25 then
				pointed_piece_index = mcl_armor.elements.torso.index
			elseif pointed_fpos > -0.0625 then
				pointed_piece_index = mcl_armor.elements.legs.index
			else
				pointed_piece_index = mcl_armor.elements.feet.index
			end

			-- If pointed piece does not have an item we try again
			-- from bottom with more margins to find piece in a
			-- location that would otherwise be covered.
			if not mcl_armor.has_piece(stand_entity, pointed_piece_index) then
				if pointed_fpos > 0.9375 + 1/16 then
					pointed_piece_index = mcl_armor.elements.head.index
				elseif pointed_fpos > 0.3125 + 4/16 then
					pointed_piece_index = mcl_armor.elements.torso.index
				elseif pointed_fpos > -0.0625 + 2/16 then
					pointed_piece_index = mcl_armor.elements.legs.index
				else
					pointed_piece_index = mcl_armor.elements.feet.index
				end
			end

			if pointed_piece_index then
				return mcl_armor.unequip(stand_entity, pointed_piece_index)
			end
		end

		return mcl_armor.equip(itemstack, stand_entity, true)
	end,
	on_rotate = function(pos, node, _, mode)
		if mode == screwdriver.ROTATE_FACE then
			node.param2 = (node.param2 + 1) % 4
			core.swap_node(pos, node)
			get_stand_entity(pos, node):update_rotation(node)
			return true
		end
		return false
	end,
})

core.register_entity("mcl_armor_stand:armor_entity", {
	initial_properties = {
		physical = true,
		visual = "mesh",
		mesh = "3d_armor_entity.obj",
		visual_size = {x=1, y=1},
		collisionbox = {-0.1,-0.4,-0.1, 0.1,1.3,0.1},
		pointable = false,
		textures = {"blank.png"},
		timer = 0,
		static_save = false,
		_mcl_pistons_unmovable = true,
	},
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	on_activate = function(self)
		self.object:set_armor_groups({immortal = 1})
		self.node_pos = vector.round(self.object:get_pos())
		self.inventory = core.get_meta(self.node_pos):get_inventory()
		migrate_inventory(self.inventory)
		mcl_armor.head_entity_equip(self.object)
		mcl_armor.update(self.object)
	end,
	on_step = function(self)
		if core.get_node(self.node_pos).name ~= "mcl_armor_stand:armor_stand" then
			self.object:remove()
		end
	end,
	on_deactivate = function (self, _)
		mcl_armor.head_entity_unequip (self.object)
	end,
	update_armor = function(self, info)
		self.object:set_properties({textures = {info.texture}})
	end,
	update_rotation = function(self, node)
		self.object:set_yaw(core.dir_to_yaw(core.facedir_to_dir(node.param2)))
	end,
	_head_armor_bone = "",
	_head_armor_position = vector.new (0, 14, 0),
})

core.register_lbm({
	label = "Respawn armor stand entities",
	name = "mcl_armor_stand:respawn_entities",
	nodenames = {"mcl_armor_stand:armor_stand"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_stand_entity(pos, node)
	end,
})

core.register_craft({
	output = "mcl_armor_stand:armor_stand",
	recipe = {
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"", "mcl_core:stick", ""},
		{"mcl_core:stick", "mcl_stairs:slab_stone", "mcl_core:stick"},
	}
})

-- Legacy handling
core.register_alias("3d_armor_stand:armor_stand", "mcl_armor_stand:armor_stand")
core.register_entity(":3d_armor_stand:armor_entity", {
	on_activate = function(self)
		core.log("action", "[mcl_armor_stand] Removing legacy entity: 3d_armor_stand:armor_entity")
		self.object:remove()
	end,
	static_save = false,
})
