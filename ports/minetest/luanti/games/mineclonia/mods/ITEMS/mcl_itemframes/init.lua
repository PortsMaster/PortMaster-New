mcl_itemframes = {}
mcl_itemframes.registered_nodes = {}
mcl_itemframes.registered_itemframes = {}

local fbox = {
	type = "fixed",
	fixed = {-6/16, -1/2, -6/16, 6/16, -7/16, 6/16}
}

local base_props = {
	visual = "wielditem",
	visual_size = {x = 0.3, y = 0.3},
	physical = false,
	pointable = false,
	textures = {"blank.png"},
}

local map_props = {
	visual = "upright_sprite",
	visual_size = {x = 1, y = 1},
	collide_with_objects = false,
	textures = {"blank.png"},
	_mcl_pistons_unmovable = true
}

mcl_itemframes.tpl_node = {
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "mcl_itemframes_frame.obj",
	selection_box = fbox,
	collision_box = fbox,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	sounds = mcl_sounds.node_sound_defaults(),
	node_placement_prediction = "",
	_mcl_hardness = 0.5,
	allow_metadata_inventory_move = function() return 0 end,
	allow_metadata_inventory_put = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
}

local tpl_groups = {
	dig_immediate = 3, deco_block = 1, dig_by_piston = 1,
	handy = 1, axey = 1, itemframe = 1, unsticky = 1,
	supported_node_wallmounted = 1
}

mcl_itemframes.tpl_entity = {
	initial_properties = base_props,
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = false,
	_mcl_pistons_unmovable = true,
}

-- Utility functions
local function find_entity(pos)
	for o in core.objects_inside_radius(pos, 0.45) do
		local l = o:get_luaentity()
		if l and l.name == "mcl_itemframes:item" then
			return l
		end
	end
end

local function find_or_create_entity(pos)
	local l = find_entity(pos)
	if not l then
		l = core.add_entity(pos, "mcl_itemframes:item"):get_luaentity()
	end
	return l
end

local function remove_entity(pos)
	local l = find_entity(pos)
	if l then
		l.object:remove()
	end
end
mcl_itemframes.remove_entity = remove_entity

local function drop_item(pos)
	local inv = core.get_meta(pos):get_inventory()
	core.add_item(pos, inv:get_stack("main", 1))
	inv:set_stack("main", 1, ItemStack(""))
	remove_entity(pos)
end

local function get_map_id(itemstack)
	local map_id = itemstack:get_meta():get_string("mcl_maps:id")
	if map_id == "" then map_id = nil end
	return map_id
end

local function rotate_entity(pos, rot)
	local l = find_entity(pos)
	local meta = core.get_meta(pos)
	local itemstack = meta:get_inventory():get_stack("main", 1)
	local is_map = (get_map_id(itemstack) and 1 or 0)
	if l then
		l.object:set_rotation(vector.add(l.object:get_rotation(), vector.new(0, 0, 0.25 * math.pi * (rot or 1) * (is_map + 1))))
		meta:set_int("mcl_item_rotation", (meta:get_int("mcl_item_rotation") + (rot == nil and 1 or 0)) % 8)
		mcl_redstone.update_comparators(pos)
	end
end

local function update_entity(pos)
	if not pos then return end
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local itemstack = inv:get_stack("main", 1)
	if not itemstack then
		remove_entity(pos)
		return
	end
	local itemstring = itemstack:get_name()
	local l = find_or_create_entity(pos)
	if not itemstring or itemstring == "" then
		remove_entity(pos)
		return
	end
	l:set_item(itemstack, pos)
	rotate_entity(pos, meta:get_int("mcl_item_rotation"))
	return l
end
mcl_itemframes.update_entity = update_entity

-- Node functions
function mcl_itemframes.tpl_node.on_rightclick(pos, _, clicker, ostack, _)
	local inv = core.get_meta(pos):get_inventory()
	if not inv:get_stack("main", 1):is_empty() then
		rotate_entity(pos)
		return ostack
	end
	local name = clicker:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return ostack
	end
	local pstack = ItemStack(ostack)
	local imeta = ostack:get_meta()
	local nmeta = core.get_meta(pos)
	nmeta:set_string("infotext", imeta:get_string("name"))
	local itemstack = pstack:take_item()
	drop_item(pos)
	inv:set_stack("main", 1, itemstack)
	update_entity(pos)
	if not core.is_creative_enabled(clicker:get_player_name()) then
		return pstack
	end
	return ostack
end

mcl_itemframes.tpl_node.on_destruct = drop_item

function mcl_itemframes.tpl_node.on_construct(pos)
	if not mcl_structures.is_structure_constructor () then
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	else
		update_entity (pos)
	end
end

function mcl_itemframes.tpl_node.on_rotate()
	return false
end

-- Entity functions
function mcl_itemframes.tpl_entity:set_item(itemstack, pos)
	if not itemstack or not itemstack.get_name then
		self.object:remove()
		update_entity(pos)
		return
	end
	if pos then
		self._itemframe_pos = pos
	else
		pos = self._itemframe_pos
	end
	local ndef = core.registered_nodes[core.get_node(pos).name]
	if not ndef._mcl_itemframe then
		self.object:remove()
		update_entity()
		return
	end
	local prop_overrides
	local stackdef = itemstack:get_definition ()
	if stackdef and stackdef._on_set_item_entity then
		local s
		s, prop_overrides = stackdef._on_set_item_entity (itemstack, self)
		if s then
			itemstack = s
		end
	end
	local def = mcl_itemframes.registered_itemframes[ndef._mcl_itemframe]
	self._item = itemstack:get_name()
	self._stack = itemstack
	self._map_id = get_map_id(itemstack)

	local dir = core.wallmounted_to_dir(core.get_node(pos).param2)
	self.object:set_pos(vector.add(self._itemframe_pos, dir * 0.42))
	self.object:set_rotation(vector.dir_to_rotation(dir))

	if self._map_id then
		local unran_callback = true
		mcl_maps.load_map(self._map_id, function(texture)
			unran_callback = false
			if self.object and self.object:get_pos() then
				self.object:set_properties(table.merge(map_props, {textures = {texture}}))
			end
		end)
		-- dirty recursive hack because dynamic_add_media is unreliable
		-- (and subsequently, mcl_maps.load_map is just as unreliable)
		core.after(0, function()
			if unran_callback then
				update_entity(pos)
			end
		end)
		return
	end
	local idef = itemstack:get_definition()
	local ws = idef.wield_scale
	self.object:set_properties(table.merge(base_props, {
		wield_item = self._item,
		visual_size = {x = base_props.visual_size.x / ws.x, y = base_props.visual_size.y / ws.y},
	}, prop_overrides or {}, def.object_properties or {}))
end

function mcl_itemframes.tpl_entity:get_staticdata()
	local s = {
		item = self._item,
		itemframe_pos = self._itemframe_pos,
		itemstack = self._itemstack,
		map_id = self._map_id
	}
	s.props = self.object:get_properties()
	return core.serialize(s)
end

function mcl_itemframes.tpl_entity:on_activate(staticdata, dtime_s)
	local s = core.deserialize(staticdata)
	if (type(staticdata) == "string" and dtime_s and dtime_s > 0) then
		-- try to re-initialize items without proper staticdata
		local p = core.find_node_near(self.object:get_pos(), 1, {"group:itemframe"})
		self.object:remove()
		if p then
			update_entity(p)
		end
		return
	elseif s then
		self._itemframe_pos = vector.copy (s.itemframe_pos)
		self._itemstack = s.itemstack
		self._item = s.item
		self._map_id = s.map_id
		update_entity(self._itemframe_pos)
		return
	end
end

function mcl_itemframes.tpl_entity:on_step(dtime)
	local def = core.registered_items[self._item]
	if def and def._on_entity_step then
		local r = def._on_entity_step(self, dtime, self._item)
		if type(r) == "string" then
			self._item = r
		end
	end
	self._timer = (self._timer and self._timer - dtime) or 1
	if self._timer > 0 then return end
	self._timer = 1
	if core.get_item_group(core.get_node(self._itemframe_pos).name, "itemframe") <= 0 then
		self.object:remove()
		return
	end
end

function mcl_itemframes.register_itemframe(name, def)
	if not def.node then return end
	local nodename = "mcl_itemframes:"..name
	table.insert(mcl_itemframes.registered_nodes, nodename)
	mcl_itemframes.registered_itemframes[name] = def
	core.register_node(":"..nodename, table.merge(mcl_itemframes.tpl_node, def.node, {
		_mcl_itemframe = name,
		groups = table.merge(tpl_groups, def.node.groups),
	}))
end

core.register_entity("mcl_itemframes:item", mcl_itemframes.tpl_entity)

core.register_lbm({
	label = "Respawn item frame item entities",
	name = "mcl_itemframes:respawn_entities",
	nodenames = {"group:itemframe"},
	run_at_every_load = true,
	action = update_entity,
})

local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath .. "/register.lua")
