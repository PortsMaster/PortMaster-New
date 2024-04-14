local S = minetest.get_translator(minetest.get_current_modname())

-- Spawn a stand entity
local function spawn_stand_entity(pos, node)
	local luaentity = minetest.add_entity(pos, "mcl_armor_stand:armor_entity"):get_luaentity()
	if luaentity then
		luaentity:update_rotation(node or minetest.get_node(pos))
		return luaentity
	end
end

-- Find a stand entity or spawn one
local function get_stand_entity(pos, node)
	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0)) do
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
	local inv = minetest.get_meta(pos):get_inventory()
	for _, stack in pairs(inv:get_list("armor")) do
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end

-- TODO: The armor stand should be an entity
minetest.register_node("mcl_armor_stand:armor_stand", {
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
		fixed = {-0.5,-0.5,-0.5, 0.5,1.4,0.5}
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

		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return itemstack
		end

		return mcl_armor.equip(itemstack, get_stand_entity(pos, node).object, true)
	end,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_FACE then
			node.param2 = (node.param2 + 1) % 4
			minetest.swap_node(pos, node)
			get_stand_entity(pos, node):update_rotation(node)
			return true
		end
		return false
	end,
})

minetest.register_entity("mcl_armor_stand:armor_entity", {
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
	},
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	on_activate = function(self)
		self.object:set_armor_groups({immortal = 1})
		self.node_pos = vector.round(self.object:get_pos())
		self.inventory = minetest.get_meta(self.node_pos):get_inventory()
		migrate_inventory(self.inventory)
		mcl_armor.update(self.object)
	end,
	on_step = function(self, dtime)
		if minetest.get_node(self.node_pos).name ~= "mcl_armor_stand:armor_stand" then
			self.object:remove()
		end
	end,
	update_armor = function(self, info)
		self.object:set_properties({textures = {info.texture}})
	end,
	update_rotation = function(self, node)
		self.object:set_yaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)))
	end,
})

minetest.register_lbm({
	label = "Respawn armor stand entities",
	name = "mcl_armor_stand:respawn_entities",
	nodenames = {"mcl_armor_stand:armor_stand"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_stand_entity(pos, node)
	end,
})

minetest.register_craft({
	output = "mcl_armor_stand:armor_stand",
	recipe = {
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"", "mcl_core:stick", ""},
		{"mcl_core:stick", "mcl_stairs:slab_stone", "mcl_core:stick"},
	}
})

-- Legacy handling
minetest.register_alias("3d_armor_stand:armor_stand", "mcl_armor_stand:armor_stand")
minetest.register_entity(":3d_armor_stand:armor_entity", {
	on_activate = function(self)
		minetest.log("action", "[mcl_armor_stand] Removing legacy entity: 3d_armor_stand:armor_entity")
		self.object:remove()
	end,
	static_save = false,
})
