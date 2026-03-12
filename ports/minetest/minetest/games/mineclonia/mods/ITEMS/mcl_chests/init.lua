mcl_chests = {}

local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local C = core.colorize

local sf = string.format

local shulker_num_tt_stacks = 5

local tiles_chest_normal_small = { "mcl_chests_normal.png" }
local tiles_chest_normal_double = { "mcl_chests_normal_double.png" }

local tiles_chest_normal_small_present
	= { "mcl_chests_normal_present.png^mcl_chests_noise.png" }
local tiles_chest_normal_double_present
	= { "mcl_chests_normal_double_present.png^mcl_chests_noise_double.png" }

local tiles_chest_trapped_small = { "mcl_chests_trapped.png" }
local tiles_chest_trapped_double = { "mcl_chests_trapped_double.png" }

local tiles_chest_trapped_small_present
	= { "mcl_chests_trapped_present.png^mcl_chests_noise.png" }
local tiles_chest_trapped_double_present
	= { "mcl_chests_trapped_double_present.png^mcl_chests_noise_double.png" }

local tiles_chest_ender_small = { "mcl_chests_ender.png" }

local tiles_chest_ender_small_present
	= { "mcl_chests_ender_present.png^mcl_chests_noise.png" }

local is_christmas = mcl_util.is_christmas

local function select_texture_maybe_present (textures)
	if textures.present and is_christmas () then
		return textures.present
	else
		return textures.default
	end
end

local shulker_box_rotations = {
	[0] = {x = 0, y = 0},                  -- ceiling
	[1] = {x = -math.pi, y = 0},           -- floor
	[2] = {x = math.pi/2, y = math.pi/2},  -- x+
	[3] = {x = math.pi/2, y = -math.pi/2}, -- x-
	[4] = {x = math.pi/2, y = math.pi},    -- z-
	[5] = {x = math.pi/2, y = 0},          -- z+
}

-- Chest Entity
local animate_chests = (core.settings:get_bool("animated_chests") ~= false)
local entity_animations = {
	shulker = {
		speed = 50,
		open = { x = 45, y = 95 },
		close = { x = 95, y = 145 },
	},
	chest = {
		speed = 25,
		open = { x = 0, y = 7 },
		close = { x = 13, y = 20 },
	},
}

core.register_entity("mcl_chests:chest", {
	initial_properties = {
		visual = "mesh",
		pointable = false,
		physical = false,
		static_save = false,
	},

	set_animation = function(self, animname)
		local anim_table = entity_animations[self.animation_type]
		local anim = anim_table[animname]
		if not anim then return end
		self.object:set_animation(anim, anim_table.speed, 0, false)
	end,

	open = function(self, playername)
		self.players[playername] = true
		if not self.is_open then
			self:set_animation("open")
			core.sound_play(self.sound_prefix .. "_open", { pos = self.node_pos, gain = 0.5, max_hear_distance = 16 },
				true)
			self.is_open = true
		end
	end,

	close = function(self, playername)
		local playerlist = self.players
		playerlist[playername] = nil
		if self.is_open then
			if next(playerlist) then
				return
			end
			self:set_animation("close")
			core.sound_play(self.sound_prefix .. "_close",
				{ pos = self.node_pos, gain = 0.3, max_hear_distance = 16 },
				true)
			self.is_open = false
		end
	end,

	initialize = function(self, node_pos, node_name, textures, dir, double, sound_prefix, mesh_prefix, animation_type, node_param2)
		self.node_pos = node_pos
		self.node_name = node_name
		self.node_param2 = node_param2
		self.sound_prefix = sound_prefix
		self.animation_type = animation_type
		local obj = self.object
		obj:set_armor_groups({ immortal = 1 })
		obj:set_properties({
			textures = select_texture_maybe_present (textures),
			mesh = mesh_prefix .. (double and "_double" or "") .. ".b3d",
		})
		self._texture_list = textures
		self._present_texture = is_christmas ()
		self:set_yaw(dir)
		self.players = {}
	end,

	reinitialize = function(self, node_name)
		self.node_name = node_name
	end,

	set_yaw = function(self, dir)
		self.object:set_yaw(core.dir_to_yaw(dir))
	end,

	check = function(self)
		local node_pos, node_name = self.node_pos, self.node_name
		if not node_pos or not node_name then
			return false
		end
		local node = core.get_node(node_pos)
		if node.name ~= node_name then
			return false
		end
		return true
	end,

	on_activate = function(self, initialization_data)
		if initialization_data and initialization_data:find("\"###mcl_chests:chest###\"") then
			self:initialize(unpack(core.deserialize(initialization_data)))
			if self.animation_type == "shulker" and shulker_box_rotations[self.node_param2] then
				local rot = {x = shulker_box_rotations[self.node_param2].x, y = shulker_box_rotations[self.node_param2].y, z = 0}
				self.object:set_rotation(rot)
			end
		else
			core.log("warning", "[mcl_chests] on_activate called without proper initialization_data ... removing entity")
			self.object:remove()
		end
	end,

	on_step = function(self)
		if not self:check() then
			self.object:remove()
		elseif is_christmas () ~= self._present_texture
			and self._texture_list then
			self.object:set_properties ({
				textures = select_texture_maybe_present (self._texture_list),
			})
			self._present_texture = is_christmas ()
		end
	end,
	_mcl_pistons_unmovable = true,
	_present_texture = false,
	_texture_list = nil,
})

local function get_entity_pos(pos, dir, double)
	pos = vector.copy(pos)
	if double then
		local add, mul, vec, cross = vector.add, vector.multiply, vector.new, vector.cross
		pos = add(pos, mul(cross(dir, vec(0, 1, 0)), -0.5))
	end
	return pos
end

local function find_entity(pos)
	for obj in core.objects_inside_radius(pos, 0) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_chests:chest" then
			return luaentity
		end
	end
end

local function get_entity_info(pos, param2, double, dir, _)
	dir = dir or core.facedir_to_dir(param2)
	return dir, get_entity_pos(pos, dir, double)
end

local function create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix, animation_type, dir, entity_pos)
	if animate_chests then
		dir, entity_pos = get_entity_info(pos, param2, double, dir, entity_pos)
		local initialization_data = core.serialize({pos, node_name, textures, dir, double, sound_prefix, mesh_prefix, animation_type, param2, "###mcl_chests:chest###"})
		local obj = core.add_entity(entity_pos, "mcl_chests:chest", initialization_data)
		if obj and obj:get_pos() then
			local luaentity = obj:get_luaentity()
			return luaentity
		else
			core.log("warning", "[mcl_chests] Failed to create entity at " .. (entity_pos and core.pos_to_string(entity_pos, 1) or "nil"))
		end
	end
end

local function find_or_create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix, animation_type
	, dir, entity_pos)
	dir, entity_pos = get_entity_info(pos, param2, double, dir, entity_pos)
	return find_entity(entity_pos) or
		create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix, animation_type, dir, entity_pos)
end

local no_rotate = screwdriver.disallow
local function simple_rotate(pos, node, user, mode, new_param2)
	if screwdriver.rotate_simple(pos, node, user, mode, new_param2) ~= false then
		local nodename = node.name
		local nodedef = core.registered_nodes[nodename]
		local dir = core.facedir_to_dir(new_param2)
		if animate_chests then
			find_or_create_entity(pos, nodename, nodedef._chest_entity_textures, new_param2, false, nodedef._chest_entity_sound, nodedef._chest_entity_mesh, nodedef._chest_entity_animation_type, dir):set_yaw(dir)
		end
	else
		return false
	end
end

--[[ List of open chests.
Key: Player name
Value:
	If player is using a chest: { pos = <chest node position> }
	Otherwise: nil ]]
local open_chests = {}

local function back_is_blocked(pos, dir)
	pos = vector.add(pos, dir)
	local def = core.registered_nodes[core.get_node(pos).name]
	pos.y = pos.y + 1
	local def2 = core.registered_nodes[core.get_node(pos).name]
	return not def or def.groups.opaque == 1 or not def2 or def2.groups.opaque == 1
end

-- To be called if a player opened a chest
local function player_chest_open(player, pos, node_name, textures, param2, double, sound, mesh, shulker)
	local name = player:get_player_name()
	open_chests[name] = {
		pos = pos,
		node_name = node_name,
		textures = textures,
		param2 = param2,
		double = double,
		sound = sound,
		mesh = mesh,
		shulker = shulker
	}
	if animate_chests then
		local dir = core.facedir_to_dir(param2)
		local blocked = not shulker and (back_is_blocked(pos, dir) or double and back_is_blocked(mcl_util.get_double_container_neighbor_pos(pos, param2, node_name:sub(-4)), dir))
		find_or_create_entity(pos, node_name, textures, param2, double, sound, mesh, shulker and "shulker" or "chest", dir):open(name, blocked)
	else
		core.sound_play(sound .. "_open", { pos = pos, gain = 0.5, max_hear_distance = 16 }, true)
	end
	mobs_mc.enrage_piglins (player, true)
end

-- Simple protection checking functions
local function protection_check_move(pos, _, _, _, _, count, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end

local function protection_check_put_take(pos, _, _, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

-- To be called when a chest is closed (only relevant for trapped chest atm)
local function chest_update_after_close(pos)
	local node = core.get_node(pos)
	if animate_chests then
		if node.name == "mcl_chests:trapped_chest_on_small" then
			mcl_redstone.swap_node(pos, {name="mcl_chests:trapped_chest_small", param2 = node.param2})
			find_or_create_entity(pos, "mcl_chests:trapped_chest_small", {"mcl_chests_trapped.png"}, node.param2, false, "default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_small")
		elseif node.name == "mcl_chests:trapped_chest_on_left" then
			mcl_redstone.swap_node(pos, { name = "mcl_chests:trapped_chest_left", param2 = node.param2 })
			find_or_create_entity(pos, "mcl_chests:trapped_chest_left", tiles_chest_trapped_double, node.param2, true,
				"default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_left")

			local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
			core.swap_node(pos_other, { name = "mcl_chests:trapped_chest_right", param2 = node.param2 })
		elseif node.name == "mcl_chests:trapped_chest_on_right" then
			mcl_redstone.swap_node(pos, { name = "mcl_chests:trapped_chest_right", param2 = node.param2 })

			local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
			mcl_redstone.swap_node(pos_other, { name = "mcl_chests:trapped_chest_left", param2 = node.param2 })
			find_or_create_entity(pos_other, "mcl_chests:trapped_chest_left", tiles_chest_trapped_double, node.param2, true,
				"default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_left")
		end
	end
end

-- To be called if a player closed a chest
local function player_chest_close(player)
	local name = player:get_player_name()
	local open_chest = open_chests[name]
	if open_chest == nil then
		return
	end
	if animate_chests then
		find_or_create_entity(open_chest.pos, open_chest.node_name, open_chest.textures, open_chest.param2, open_chest.double, open_chest.sound, open_chest.mesh, open_chest.shulker and "shulker" or "chest"):close(name)
	else
		core.sound_play(open_chest.sound .. "_close", { pos = open_chest.pos, gain = 0.5, max_hear_distance = 16 }, true)
	end
	chest_update_after_close(open_chest.pos)

	open_chests[name] = nil
end

-- This is a helper function to register both chests and trapped chests. Trapped chests will make use of the additional parameters
local function register_chest(basename, desc, longdesc, usagehelp, tt_help, tiles_table, hidden, redstone,
							  on_rightclick_addendum, on_rightclick_addendum_left, on_rightclick_addendum_right, drop,
							  canonical_basename)
	-- START OF register_chest FUNCTION BODY
	if not drop then
		drop = "mcl_chests:" .. basename
	else
		drop = "mcl_chests:" .. drop
	end
	-- The basename of the "canonical" version of the node, if set (e.g.: trapped_chest_on → trapped_chest).
	-- Used to get a shared formspec ID and to swap the node back to the canonical version in on_construct.
	if not canonical_basename then
		canonical_basename = basename
	end

	local function double_chest_add_item(top_inv, bottom_inv, listname, stack)
		if not stack or stack:is_empty() then
			return
		end

		local name = stack:get_name()

		local function top_off(inv, stack)
			for c, chest_stack in ipairs(inv:get_list(listname)) do
				if stack:is_empty() then
					break
				end

				if chest_stack:get_name() == name and chest_stack:get_free_space() > 0 then
					stack = chest_stack:add_item(stack)
					inv:set_stack(listname, c, chest_stack)
				end
			end

			return stack
		end

		stack = top_off(top_inv, stack)
		stack = top_off(bottom_inv, stack)

		if not stack:is_empty() then
			stack = top_inv:add_item(listname, stack)
			if not stack:is_empty() then
				bottom_inv:add_item(listname, stack)
			end
		end
	end

	local drop_items_chest = mcl_util.drop_items_from_meta_container("main")

	local function on_chest_blast(pos)
		local node = core.get_node(pos)
		drop_items_chest(pos, node)
		core.remove_node(pos)
	end

	local function limit_put_list(stack, list)
		for _, other in ipairs(list) do
			stack = other:add_item(stack)
			if stack:is_empty() then
				break
			end
		end
		return stack
	end

	local function limit_put(stack, inv1, inv2)
		local leftover = ItemStack(stack)
		leftover = limit_put_list(leftover, inv1:get_list("main"))
		leftover = limit_put_list(leftover, inv2:get_list("main"))
		return stack:get_count() - leftover:get_count()
	end

	local small_name = "mcl_chests:" .. basename .. "_small"
	local small_textures = {
		default = tiles_table.small,
		present = tiles_table.small_present,
	}
	local left_name = "mcl_chests:" .. basename .. "_left"
	local left_textures = {
		default = tiles_table.double,
		present = tiles_table.double_present,
	}

	core.register_node("mcl_chests:" .. basename, {
		description = desc,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		_doc_items_hidden = hidden,
		drawtype = "mesh",
		mesh = "mcl_chests_chest.obj",
		tiles = select_texture_maybe_present (small_textures),
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		sounds = mcl_sounds.node_sound_wood_defaults(),
		groups = {
			deco_block = 1,
			features_cannot_replace
				= basename == "chest" and 1 or 0,
		},
		on_construct = function(pos, _)
			local node = core.get_node(pos)
			node.name = small_name
			core.set_node(pos, node)
		end,
		after_place_node = function(pos, _, itemstack, _)
			core.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		_mcl_burntime = 15
	})

	local function close_forms(canonical_basename, pos)
		for pl in mcl_util.connected_players(pos, 30) do
			core.close_formspec(pl:get_player_name(), "mcl_chests:" .. canonical_basename .. "_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z)
		end
	end

	core.register_node(small_name, {
		description = desc,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		_doc_items_hidden = hidden,
		drawtype = animate_chests and "nodebox" or "mesh",
		mesh = not animate_chests and "mcl_chests_chest.obj" or nil,
		node_box = animate_chests and {
			type = "fixed",
			fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
		} or nil,
		collision_box = {
			type = "fixed",
			fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
		},
		tiles = animate_chests and {"blank.png^[resize:16x16"}
			or select_texture_maybe_present (small_textures),
		use_texture_alpha = "clip",
		_chest_entity_textures = small_textures,
		_chest_entity_sound = "default_chest",
		_chest_entity_mesh = "mcl_chests_chest",
		_chest_entity_animation_type = "chest",
		paramtype = "light",
		paramtype2 = "facedir",
		drop = drop,
		_mcl_baseitem = "mcl_chests:"..basename,
		groups = {
			handy = 1,
			axey = 1,
			container = 2,
			deco_block = 1,
			material_wood = 1,
			flammable = -1,
			chest_entity = 1,
			not_in_creative_inventory = 1,
			pathfinder_partial = 2,
			piglin_protected = 1,
			features_cannot_replace
				= basename == "chest" and 1 or 0,
		},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_construct = function(pos)
			local param2 = core.get_node(pos).param2
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("main", 9 * 3)
			--[[ The "input" list is *another* workaround (hahahaha!) around the fact that Minetest
			does not support listrings to put items into an alternative list if the first one
			happens to be full. See <https://github.com/minetest/minetest/issues/5343>.
			This list is a hidden input-only list and immediately puts items into the appropriate chest.
			It is only used for listrings and hoppers. This workaround is not that bad because it only
			requires a simple “inventory allows” check for large chests.]]
			-- FIXME: Refactor the listrings as soon Minetest supports alternative listrings
			-- BEGIN OF LISTRING WORKAROUND
			inv:set_size("input", 1)
			-- END OF LISTRING WORKAROUND
			if core.get_node(mcl_util.get_double_container_neighbor_pos(pos, param2, "right")).name ==
				"mcl_chests:" .. canonical_basename .. "_small" then
				core.swap_node(pos, { name = "mcl_chests:" .. canonical_basename .. "_right", param2 = param2 })
				local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
				core.swap_node(p, { name = "mcl_chests:" .. canonical_basename .. "_left", param2 = param2 })
				create_entity(p, "mcl_chests:" .. canonical_basename .. "_left", left_textures, param2, true,
					"default_chest",
					"mcl_chests_chest", "chest")
			elseif core.get_node(mcl_util.get_double_container_neighbor_pos(pos, param2, "left")).name ==
				"mcl_chests:" .. canonical_basename .. "_small" then
				core.swap_node(pos, { name = "mcl_chests:" .. canonical_basename .. "_left", param2 = param2 })
				create_entity(pos, "mcl_chests:" .. canonical_basename .. "_left", left_textures, param2, true,
					"default_chest",
					"mcl_chests_chest", "chest")
				local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
				core.swap_node(p, { name = "mcl_chests:" .. canonical_basename .. "_right", param2 = param2 })
			else
				core.swap_node(pos, { name = "mcl_chests:" .. canonical_basename .. "_small", param2 = param2 })
				create_entity(pos, small_name, small_textures, param2, false, "default_chest", "mcl_chests_chest",
					"chest")
			end
		end,
		after_place_node = function(pos, _, itemstack,  _)
			core.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = protection_check_put_take,
		on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. core.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, _, stack, player)
			core.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. core.pos_to_string(pos))
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local inv = core.get_inventory({ type = "node", pos = pos })
				inv:add_item("main", stack)
			end
			-- END OF LISTRING WORKAROUND
			mcl_redstone.update_comparators(pos)
		end,
		on_metadata_inventory_take = function(pos, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. core.pos_to_string(pos))
			mcl_redstone.update_comparators(pos)
		end,
		_mcl_hardness = 2.5,

		on_rightclick = function(pos, node, clicker)
			local def = core.registered_nodes[core.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name]
			if not def or def.groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
			end
			local name = core.get_meta(pos):get_string("name")
			if name == "" then
				name = S("Chest")
			end

			core.show_formspec(clicker:get_player_name(),
				sf("mcl_chests:%s_%s_%s_%s", canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,10.425]",

					"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos.x, pos.y, pos.z),
					"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
					"list[current_player;main;0.375,5.1;9,3;9]",

					mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
					"list[current_player;main;0.375,9.05;9,1;]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
					"listring[current_player;main]",
				})
			)

			if on_rightclick_addendum then
				on_rightclick_addendum(pos, node, clicker)
			end

			player_chest_open(clicker, pos, small_name, small_textures, node.param2, false, "default_chest",
				"mcl_chests_chest")
		end,

		on_destruct = function(pos)
			close_forms(canonical_basename, pos)
		end,
		_mcl_redstone = redstone,
		on_rotate = simple_rotate,
	})

	core.register_node(left_name, {
		drawtype = animate_chests and "nodebox" or "mesh",
		nodebox = animate_chests and {
			type = "fixed",
			fixed = { -0.4375, -0.5, -0.4375, 0.5, 0.375, 0.4375 },
		} or nil,
		selection_box = {
			type = "fixed",
			fixed = { -0.4375, -0.5, -0.4375, 0.5, 0.375, 0.4375 },
		},
		use_texture_alpha = "clip",
		_chest_entity_textures = left_textures,
		_chest_entity_sound = "default_chest",
		_chest_entity_mesh = "mcl_chests_chest",
		_chest_entity_animation_type = "chest",
		mesh = not animate_chests and "mcl_chests_chest_double_static.obj" or nil,
		tiles = not animate_chests
			and select_texture_maybe_present (left_textures)
			or { "blank.png^[resize:16x16" },
		paramtype = "light",
		paramtype2 = "facedir",
		_mcl_baseitem = "mcl_chests:"..basename,
		groups = {
			handy = 1,
			axey = 1,
			container = 5,
			not_in_creative_inventory = 1,
			material_wood = 1,
			flammable = -1,
			chest_entity = 1,
			double_chest = 1,
			pathfinder_partial = 2,
			piglin_protected = 1,
			features_cannot_replace
				= basename == "chest" and 1 or 0,
		},
		drop = drop,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_construct = function(pos)
			local n = core.get_node(pos)
			local param2 = n.param2
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
			if not p or core.get_node(p).name ~= "mcl_chests:" .. canonical_basename .. "_right" then
				n.name = "mcl_chests:" .. canonical_basename .. "_small"
				core.swap_node(pos, n)
			end
			create_entity(pos, left_name, left_textures, param2, true, "default_chest", "mcl_chests_chest", "chest")
		end,
		after_place_node = function(pos, _, itemstack, _)
			core.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		on_destruct = function(pos)
			local n = core.get_node(pos)
			if n.name == small_name then
				return
			end

			close_forms(canonical_basename, pos)

			local param2 = n.param2
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
			if not p or core.get_node(p).name ~= "mcl_chests:" .. basename .. "_right" then
				return
			end
			close_forms(canonical_basename, p)

			core.swap_node(p, { name = small_name, param2 = param2 })
			create_entity(p, small_name, small_textures, param2, false, "default_chest", "mcl_chests_chest", "chest")
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		_mcl_allow_hopper_in = function(hopper_pos, pos)
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "left")
			return core.get_item_group(core.get_node(other_pos).name, "double_chest") ~= 0
		end,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, _, stack, player)
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "left")
			if core.get_item_group(core.get_node(other_pos).name, "double_chest") == 0 then
				return 0
			end
			local name = player:get_player_name()
			if core.is_protected(pos, name) then
				core.record_protection_violation(pos, name)
				return 0
				-- BEGIN OF LISTRING WORKAROUND
			elseif listname == "input" then
				local inv = core.get_inventory({ type = "node", pos = pos })
				local other_inv = core.get_inventory({ type = "node", pos = other_pos })
				return limit_put(stack, inv, other_inv)
				-- END OF LISTRING WORKAROUND
			else
				return stack:get_count()
			end
		end,
		on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. core.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, _, stack, player)
			core.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. core.pos_to_string(pos))
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "left")
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local inv = core.get_inventory({ type = "node", pos = pos })
				local other_inv = core.get_inventory({ type = "node", pos = other_pos })

				inv:set_stack("input", 1, nil)

				double_chest_add_item(inv, other_inv, "main", stack)
			end
			-- END OF LISTRING WORKAROUND
			mcl_redstone.update_comparators(pos)
			mcl_redstone.update_comparators(other_pos)
		end,
		on_metadata_inventory_take = function(pos, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. core.pos_to_string(pos))
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "left")
			mcl_redstone.update_comparators(pos)
			mcl_redstone.update_comparators(other_pos)
		end,
		_mcl_hardness = 2.5,

		on_rightclick = function(pos, node, clicker)
			local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
			local above_def = core.registered_nodes[core.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name]
			local above_def_other = core.registered_nodes[
			core.get_node({ x = pos_other.x, y = pos_other.y + 1, z = pos_other.z }).name]

			if not above_def or above_def.groups.opaque == 1 or not above_def_other or above_def_other.groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
			end

			local name = core.get_meta(pos):get_string("name")
			if name == "" then
				name = core.get_meta(pos_other):get_string("name")
			end
			if name == "" then
				name = S("Large Chest")
			end

			core.show_formspec(clicker:get_player_name(),
				sf("mcl_chests:%s_%s_%s_%s", canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,14.15]",

					"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos.x, pos.y, pos.z),
					mcl_formspec.get_itemslot_bg_v4(0.375, 4.5, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,4.5;9,3;]", pos_other.x, pos_other.y, pos_other.z),
					"label[0.375,8.45;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 8.825, 9, 3),
					"list[current_player;main;0.375,8.825;9,3;9]",

					mcl_formspec.get_itemslot_bg_v4(0.375, 12.775, 9, 1),
					"list[current_player;main;0.375,12.775;9,1;]",

					--BEGIN OF LISTRING WORKAROUND
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;input]", pos.x, pos.y, pos.z),
					--END OF LISTRING WORKAROUND
					"listring[current_player;main]" ..
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos_other.x, pos_other.y, pos_other.z),
				})
			)

			if on_rightclick_addendum_left then
				on_rightclick_addendum_left(pos, node, clicker)
			end

			player_chest_open(clicker, pos, left_name, left_textures, node.param2, true, "default_chest",
				"mcl_chests_chest")
		end,
		_mcl_redstone = redstone,
		on_rotate = no_rotate,
	})

	core.register_node("mcl_chests:" .. basename .. "_right", {
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		_mcl_baseitem = "mcl_chests:"..basename,
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.4375, 0.4375, 0.375, 0.4375 },
		},
		tiles = { "blank.png^[resize:16x16" },
		use_texture_alpha = "clip",
		groups = {
			handy = 1,
			axey = 1,
			container = 6,
			not_in_creative_inventory = 1,
			material_wood = 1,
			flammable = -1,
			double_chest = 2,
			pathfinder_partial = 2,
			piglin_protected = 1,
			features_cannot_replace
				= basename == "chest" and 1 or 0,
		},
		drop = drop,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_construct = function(pos)
			local n = core.get_node(pos)
			local param2 = n.param2
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
			if not p or core.get_node(p).name ~= "mcl_chests:" .. canonical_basename .. "_left" then
				n.name = "mcl_chests:" .. canonical_basename .. "_small"
				core.swap_node(pos, n)
			end
		end,
		after_place_node = function(pos, _, itemstack, _)
			core.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		on_destruct = function(pos)
			local n = core.get_node(pos)
			if n.name == small_name then
				return
			end

			close_forms(canonical_basename, pos)

			local param2 = n.param2
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
			if not p or core.get_node(p).name ~= "mcl_chests:" .. basename .. "_left" then
				return
			end
			close_forms(canonical_basename, p)

			core.swap_node(p, { name = small_name, param2 = param2 })
			create_entity(p, small_name, small_textures, param2, false, "default_chest", "mcl_chests_chest", "chest")
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		_mcl_allow_hopper_in = function(_, pos)
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "left")
			return core.get_item_group(core.get_node(other_pos).name, "double_chest") ~= 0
		end,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, _, stack, player)
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "right")
			if core.get_item_group(core.get_node(other_pos).name, "double_chest") == 0 then
				return 0
			end
			local name = player:get_player_name()
			if core.is_protected(pos, name) then
				core.record_protection_violation(pos, name)
				return 0
				-- BEGIN OF LISTRING WORKAROUND
			elseif listname == "input" then
				local other_inv = core.get_inventory({ type = "node", pos = other_pos })
				local inv = core.get_inventory({ type = "node", pos = pos })
				return limit_put(stack, other_inv, inv)
				-- END OF LISTRING WORKAROUND
			else
				return stack:get_count()
			end
		end,
		on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. core.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, _, stack, player)
			core.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. core.pos_to_string(pos))
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "right")
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local other_inv = core.get_inventory({ type = "node", pos = other_pos })
				local inv = core.get_inventory({ type = "node", pos = pos })

				inv:set_stack("input", 1, nil)

				double_chest_add_item(other_inv, inv, "main", stack)
			end
			-- END OF LISTRING WORKAROUND
			mcl_redstone.update_comparators(pos)
			mcl_redstone.update_comparators(other_pos)
		end,
		on_metadata_inventory_take = function(pos, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. core.pos_to_string(pos))
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, core.get_node(pos).param2, "right")
			mcl_redstone.update_comparators(pos)
			mcl_redstone.update_comparators(other_pos)
		end,
		_mcl_hardness = 2.5,

		on_rightclick = function(pos, node, clicker)
			local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
			local def =  core.registered_nodes[core.get_node(vector.offset(pos, 0, 1, 0)).name]
			local def_other = core.registered_nodes[core.get_node(vector.offset(pos_other, 0, 1, 0)).name]
			if not def or def.groups.opaque == 1
				or not def_other or def_other.groups.opaque
				== 1 then
				-- won't open if there is no space from the top
				return false
			end

			local name = core.get_meta(pos_other):get_string("name")
			if name == "" then
				name = core.get_meta(pos):get_string("name")
			end
			if name == "" then
				name = S("Large Chest")
			end

			core.show_formspec(clicker:get_player_name(),
				sf("mcl_chests:%s_%s_%s_%s", canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,14.15]",

					"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos_other.x, pos_other.y, pos_other.z),
					mcl_formspec.get_itemslot_bg_v4(0.375, 4.5, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,4.5;9,3;]", pos.x, pos.y, pos.z),
					"label[0.375,8.45;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
					mcl_formspec.get_itemslot_bg_v4(0.375, 8.825, 9, 3),
					"list[current_player;main;0.375,8.825;9,3;9]",

					mcl_formspec.get_itemslot_bg_v4(0.375, 12.775, 9, 1),
					"list[current_player;main;0.375,12.775;9,1;]",

					--BEGIN OF LISTRING WORKAROUND
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;input]", pos.x, pos.y, pos.z),
					--END OF LISTRING WORKAROUND
					"listring[current_player;main]" ..
					sf("listring[nodemeta:%s,%s,%s;main]", pos_other.x, pos_other.y, pos_other.z),
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
				})
			)

			if on_rightclick_addendum_right then
				on_rightclick_addendum_right(pos, node, clicker)
			end

			player_chest_open(clicker, pos_other, left_name, left_textures, node.param2, true, "default_chest",
				"mcl_chests_chest")
		end,
		_mcl_redstone = redstone,
		on_rotate = no_rotate,
	})

	doc.add_entry_alias("nodes", small_name, "nodes", "mcl_chests:" .. basename .. "_left")
	doc.add_entry_alias("nodes", small_name, "nodes", "mcl_chests:" .. basename .. "_right")

	-- END OF register_chest FUNCTION BODY
end

local chestusage = S("To access its inventory, rightclick it. When broken, the items will drop out.")

register_chest("chest",
	S("Chest"),
	S("Chests are containers which provide 27 inventory slots. Chests can be turned into large chests with double the capacity by placing two chests next to each other."),
	chestusage,
	S("27 inventory slots") .. "\n" .. S("Can be combined to a large chest"),
	{
		small = tiles_chest_normal_small,
		double = tiles_chest_normal_double,
		small_present = tiles_chest_normal_small_present,
		double_present = tiles_chest_normal_double_present,
		inv = { "default_chest_top.png", "mcl_chests_chest_bottom.png",
			"mcl_chests_chest_right.png", "mcl_chests_chest_left.png",
			"mcl_chests_chest_back.png", "default_chest_front.png" },
	},
	false
)

local traptiles = {
	small = tiles_chest_trapped_small,
	double = tiles_chest_trapped_double,
	small_present = tiles_chest_trapped_small_present,
	double_present = tiles_chest_trapped_double_present,
}

register_chest("trapped_chest",
	S("Trapped Chest"),
	S("A trapped chest is a container which provides 27 inventory slots. When it is opened, it sends a redstone signal to its adjacent blocks as long it stays open. Trapped chests can be turned into large trapped chests with double the capacity by placing two trapped chests next to each other."),
	chestusage,
	S("27 inventory slots") ..
	"\n" .. S("Can be combined to a large chest") .. "\n" .. S("Emits a redstone signal when opened"),
	traptiles,
	nil,
	{
		connects_to = function(node, dir) return true end,
	},
	function(pos, node, _)
		mcl_redstone.swap_node(pos, {name="mcl_chests:trapped_chest_on_small", param2 = node.param2})
		if animate_chests then
			find_or_create_entity(pos, "mcl_chests:trapped_chest_on_small", {default = {"mcl_chests_trapped.png",}, present = {"mcl_chests_trapped_present.png",},}, node.param2, false, "default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_on_small")
		end
	end,
	function(pos, node, _)
		local meta = core.get_meta(pos)
		meta:set_int("players", 1)

		mcl_redstone.swap_node(pos, { name = "mcl_chests:trapped_chest_on_left", param2 = node.param2 })
		if animate_chests then
			find_or_create_entity(pos, "mcl_chests:trapped_chest_on_left", {
					default = tiles_chest_trapped_double,
					present = tiles_chest_trapped_double_present,
				}, node.param2, true,
				"default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_on_left")
		end

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		mcl_redstone.swap_node(pos_other, { name = "mcl_chests:trapped_chest_on_right", param2 = node.param2 })
	end,
	function(pos, node, _)
		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")

		mcl_redstone.swap_node(pos, { name = "mcl_chests:trapped_chest_on_right", param2 = node.param2 })
		mcl_redstone.swap_node(pos_other, { name = "mcl_chests:trapped_chest_on_left", param2 = node.param2 })
		if animate_chests then
			find_or_create_entity(pos_other, "mcl_chests:trapped_chest_on_left", {
					default = tiles_chest_trapped_double,
					present = tiles_chest_trapped_double_present,
				}, node.param2,
				true,
				"default_chest", "mcl_chests_chest", "chest"):reinitialize("mcl_chests:trapped_chest_on_left")
		end
	end
)

register_chest("trapped_chest_on",
	nil, nil, nil, nil, traptiles, true,
	{
		connects_to = function(node, dir) return true end,
		-- TODO: Trapped chests should return a power level equal to
		-- the number of players accessing the chest. Just return 15
		-- until that has been implemented.
		get_power = function(node, dir) return 15, dir.y < 0 end,
	},
	nil, nil, nil,
	"trapped_chest",
	"trapped_chest"
)

-- Disable chest when it has been closed
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_chests:") == 1 then
		if fields.quit then
			player_chest_close(player)
		end
	end
end)

core.register_on_leaveplayer(function(player)
	player_chest_close(player)
end)

core.register_craft({
	output = "mcl_chests:chest",
	recipe = {
		{ "group:wood", "group:wood", "group:wood" },
		{ "group:wood", "",           "group:wood" },
		{ "group:wood", "group:wood", "group:wood" },
	},
})

core.register_node("mcl_chests:ender_chest", {
	description = S("Ender Chest"),
	_tt_help = S("27 interdimensional inventory slots") ..
		"\n" .. S("Put items inside, retrieve them from any ender chest"),
	_doc_items_longdesc = S(
		"Ender chests grant you access to a single personal interdimensional inventory with 27 slots. This inventory is the same no matter from which ender chest you access it from. If you put one item into one ender chest, you will find it in all other ender chests. Each player will only see their own items, but not the items of other players."),
	_doc_items_usagehelp = S("Rightclick the ender chest to access your personal interdimensional inventory."),
	drawtype = "mesh",
	mesh = "mcl_chests_chest.obj",
	tiles = select_texture_maybe_present ({
		default = tiles_chest_ender_small,
		present = tiles_chest_ender_small_present,
	}),
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { deco_block = 1, unmovable_by_piston = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_construct = function(pos)
		local node = core.get_node(pos)
		node.name = "mcl_chests:ender_chest_small"
		core.set_node(pos, node)
	end,
})

local formspec_ender_chest = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Ender Chest"))) .. "]",
	mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
	"list[current_player;enderchest;0.375,0.75;9,3;]",
	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;enderchest]",
	"listring[current_player;main]",
})


core.register_node("mcl_chests:ender_chest_small", {
	description = S("Ender Chest"),
	_tt_help = S("27 interdimensional inventory slots") ..
		"\n" .. S("Put items inside, retrieve them from any ender chest"),
	_doc_items_longdesc = S(
		"Ender chests grant you access to a single personal interdimensional inventory with 27 slots. This inventory is the same no matter from which ender chest you access it from. If you put one item into one ender chest, you will find it in all other ender chests. Each player will only see their own items, but not the items of other players."),
	_doc_items_usagehelp = S("Rightclick the ender chest to access your personal interdimensional inventory."),
	drawtype = animate_chests and "nodebox" or "mesh",
	mesh = not animate_chests and "mcl_chests_chest.obj" or nil,
	_mcl_baseitem = "mcl_chests:ender_chest",
	node_box = animate_chests and {
		type = "fixed",
        fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
	} or nil,
	collision_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375},
	},
	tiles = animate_chests and {"blank.png"}
		or select_texture_maybe_present ({
		default = tiles_chest_ender_small,
		present = tiles_chest_ender_small_present,
	}),
	_chest_entity_textures = {
		default = tiles_chest_ender_small,
		present = tiles_chest_ender_small_present,
	},
	_chest_entity_sound = "mcl_chests_enderchest",
	_chest_entity_mesh = "mcl_chests_chest",
	_chest_entity_animation_type = "chest",
	use_texture_alpha = "clip",
	-- Note: The “container” group is missing here because the ender chest does not
	-- have an inventory on its own
	groups = {
		pickaxey = 1,
		deco_block = 1,
		material_stone = 1,
		chest_entity = 1,
		not_in_creative_inventory = 1,
		pathfinder_partial = 2,
		piglin_protected = 1,
		unmovable_by_piston = 1,
	},
	is_ground_content = false,
	paramtype = "light",
	light_source = 7,
	paramtype2 = "facedir",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	drop = "mcl_core:obsidian 8",
	on_construct = function(pos)
		create_entity(pos, "mcl_chests:ender_chest_small", {
			default = tiles_chest_ender_small,
			present = tiles_chest_ender_small_present,
		}, core.get_node(pos).param2, false, "mcl_chests_enderchest", "mcl_chests_chest", "chest")
	end,
	on_rightclick = function(pos, node, clicker)
		local def = core.registered_nodes[core.get_node(vector.offset(pos, 0, 1, 0)).name]
		if not def or def.groups.opaque == 1 then
			-- won't open if there is no space from the top
			return false
		end
		core.show_formspec(clicker:get_player_name(), "mcl_chests:ender_chest_" .. clicker:get_player_name(),
			formspec_ender_chest)
		local textures = {
			default = tiles_chest_ender_small,
			present = tiles_chest_ender_small_present,
		}
		player_chest_open(clicker, pos, "mcl_chests:ender_chest_small", textures, node.param2, false,
			"mcl_chests_enderchest", "mcl_chests_chest")
	end,
	on_receive_fields = function(_, _, fields, sender)
		if fields.quit then
			player_chest_close(sender)
		end
	end,
	_mcl_blast_resistance = 3000,
	_mcl_hardness = 22.5,
	_mcl_silk_touch_drop = { "mcl_chests:ender_chest" },
	on_rotate = simple_rotate,
})

core.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 9 * 3)
end)

core.register_allow_player_inventory_action(function(player, action, inv, info)
	if inv:get_location().type == "player" and (
			action == "move" and (info.from_list == "enderchest" or info.to_list == "enderchest")
			or action == "put" and info.listname == "enderchest"
			or action == "take" and info.listname == "enderchest"
		) then
		local def = player:get_wielded_item():get_definition()

		if not core.find_node_near(player:get_pos(), def and def.range or ItemStack():get_definition().range or tonumber(core.settings:get("mcl_hand_range")) or 4.5, "mcl_chests:ender_chest_small", true) then
			return 0
		end
	end
end)

core.register_craft({
	output = "mcl_chests:ender_chest",
	recipe = {
		{ "mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian" },
		{ "mcl_core:obsidian", "mcl_end:ender_eye", "mcl_core:obsidian" },
		{ "mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian" },
	},
})

-- Shulker boxes
local boxtypes = {
	white = S("White Shulker Box"),
	grey = S("Light Grey Shulker Box"),
	orange = S("Orange Shulker Box"),
	cyan = S("Cyan Shulker Box"),
	magenta = S("Magenta Shulker Box"),
	violet = S("Purple Shulker Box"),
	lightblue = S("Light Blue Shulker Box"),
	blue = S("Blue Shulker Box"),
	yellow = S("Yellow Shulker Box"),
	brown = S("Brown Shulker Box"),
	green = S("Lime Shulker Box"),
	dark_green = S("Green Shulker Box"),
	pink = S("Pink Shulker Box"),
	red = S("Red Shulker Box"),
	dark_grey = S("Grey Shulker Box"),
	black = S("Black Shulker Box"),
}

local shulker_mob_textures = {
	white = "mobs_mc_shulker_white.png",
	grey = "mobs_mc_shulker_silver.png",
	orange = "mobs_mc_shulker_orange.png",
	cyan = "mobs_mc_shulker_cyan.png",
	magenta = "mobs_mc_shulker_magenta.png",
	violet = "mobs_mc_shulker_purple.png",
	lightblue = "mobs_mc_shulker_light_blue.png",
	blue = "mobs_mc_shulker_blue.png",
	yellow = "mobs_mc_shulker_yellow.png",
	brown = "mobs_mc_shulker_brown.png",
	green = "mobs_mc_shulker_lime.png",
	dark_green = "mobs_mc_shulker_green.png",
	pink = "mobs_mc_shulker_pink.png",
	red = "mobs_mc_shulker_red.png",
	dark_grey = "mobs_mc_shulker_gray.png",
	black = "mobs_mc_shulker_black.png",
}
local canonical_shulker_color = "violet"

--WARNING: after formspec v4 update, old shulker boxes will need to be placed again to get the new formspec
local function formspec_shulker_box(name)
	if not name or name == "" then
		name = S("Shulker Box")
	end

	return table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",

		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
		"list[context;main;0.375,0.75;9,3;]",
		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[context;main]",
		"listring[current_player;main]",
	})
end

local function set_shulkerbox_meta(nmeta, imeta)
	local name = imeta:get_string("name")
	nmeta:set_string("description", imeta:get_string("description"))
	nmeta:set_string("name", name)
	nmeta:set_string("formspec", formspec_shulker_box(name))
end

local shulker_tt_empty = S("27 inventory slots") .. "\n" .. S("Can be carried around with its contents")

tt.register_snippet(function(itemstring, _ , itemstack)
	if core.get_item_group(itemstring, "shulker_box") > 0 then
		if itemstack then
			local d = ""
			local i = 0
			local its = core.deserialize(itemstack:get_meta():get_string(""))
			if its then
				for _, v in ipairs(its) do
					local stack = ItemStack(v)
					if not stack:is_empty() then
						if i < shulker_num_tt_stacks then
							local newline = d ~= "" and "\n" or ""
							local item = core.strip_colors(stack:get_short_description() or stack:get_description())
							local count = (stack:get_count() > 1 and ("x"..stack:get_count()) or "")
							d = d..newline..item.." "..count
						end
						i = i + 1
					end
				end
			end
			if d ~= "" and i - shulker_num_tt_stacks > 0 then
				d = d .. "\n "..S("and @1 more",tostring(i - shulker_num_tt_stacks))
			end
			if i > 0 then
				return d, mcl_colors.GREEN
			end
		end
		return shulker_tt_empty, mcl_colors.GREEN
	end
end)

for color, desc in pairs(boxtypes) do
	local mob_texture = shulker_mob_textures[color]
	local is_canonical = color == canonical_shulker_color
	local longdesc, usagehelp, create_entry, entry_name
	if is_canonical then
		longdesc = S(
			"A shulker box is a portable container which provides 27 inventory slots for any item except shulker boxes. Shulker boxes keep their inventory when broken, so shulker boxes as well as their contents can be taken as a single item. Shulker boxes come in many different colors.")
		usagehelp = S(
			"To access the inventory of a shulker box, place and right-click it. To take a shulker box and its contents with you, just break and collect it, the items will not fall out. Place the shulker box again to be able to retrieve its contents.")
		entry_name = S("Shulker Box")
	else
		create_entry = false
	end

	local small_name = "mcl_chests:" .. color .. "_shulker_box_small"

	local function set_inventory_and_meta_from_stack(pos, stack)
		local stack_meta = stack:get_meta()
		local node_meta = core.get_meta(pos)
		local inv = node_meta:get_inventory()
		local main = core.deserialize(stack_meta:get_string("")) or {}
		inv:set_size("main", 9 * 3)
		inv:set_list("main", main)
		mcl_redstone.update_comparators(pos)
		set_shulkerbox_meta(node_meta, stack_meta)
	end

	local on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		if mcl_util.check_position_protection(pointed_thing.under, placer) then return itemstack end
		if color ~= canonical_shulker_color then
			if core.get_item_group(core.get_node(pointed_thing.under).name, "cauldron_water") > 0 then
				if mcl_cauldrons.add_level(pointed_thing.under, -1) then
					itemstack:set_name("mcl_chests:"..canonical_shulker_color.."_shulker_box")
					return itemstack
				end
			end
		end
		local dir = core.dir_to_wallmounted(vector.subtract(pointed_thing.above, pointed_thing.under))
		return core.item_place_node(itemstack, placer, pointed_thing, dir)
	end
	core.register_node("mcl_chests:" .. color .. "_shulker_box", {
		description = desc,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		tiles = { mob_texture },
		drawtype = "mesh",
		mesh = "mcl_chests_shulker.obj",
		use_texture_alpha = "clip",
		groups = {
			handy = 1,
			pickaxey = 1,
			container = 3,
			deco_block = 1,
			dig_by_piston = 1,
			unsticky = 1,
			shulker_box = 1,
			old_shulker_box_node = 1,
		},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		paramtype = "light",
		paramtype2 = "facedir",
		on_place = on_place,
		on_construct = function(pos)
			local node = core.get_node(pos)
			node.name = small_name
			-- set_node required to trigger on_construct of _small variant
			core.set_node(pos, node)
		end,
		after_place_node = function(pos, placer, itemstack, _)
			-- restore node inventory and meta data
			set_inventory_and_meta_from_stack(pos, itemstack)

			if core.is_creative_enabled(placer and placer:get_player_name() or "") then
				local ninv = core.get_meta(pos):get_inventory()
				if not ninv:is_empty("main") then
					return nil
				else
					return itemstack
				end
			else
				return nil
			end
		end,
		_on_dispense = function(stack, _, droppos, dropnode, dropdir)
			-- Place shulker box as node
			local def = core.registered_nodes[dropnode.name]
			if def and def.buildable_to then
				core.set_node(droppos, { name = small_name, param2 = core.dir_to_facedir(dropdir) })
				-- restore node inventory and meta data
				set_inventory_and_meta_from_stack(droppos, stack)
				stack:take_item()
			end
			return stack
		end,
	})
	local function get_shulker_stack(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		local items = {}
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			items[i] = stack:to_string()
		end
		local data = core.serialize(items)
		local boxitem = ItemStack("mcl_chests:" .. color .. "_shulker_box")
		local boxitem_meta = boxitem:get_meta()
		boxitem_meta:set_string("name", meta:get_string("name"))
		boxitem_meta:set_string("", data)
		tt.reload_itemstack_description(boxitem)
		return boxitem
	end

	core.register_node(small_name, {
		description = desc,
		_tt_help = S("27 inventory slots") .. "\n" .. S("Can be carried around with its contents"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = animate_chests and "nodebox" or "mesh",
		mesh = not animate_chests and "mcl_chests_shulker.obj" or nil,
		tiles = animate_chests and {"blank.png^[resize:16x16"} or {mob_texture},
		_chest_entity_textures = {
			default = {mob_texture,},
		},
		use_texture_alpha = "clip",
		_chest_entity_sound = "mcl_chests_shulker",
		_chest_entity_mesh = "mcl_chests_shulker",
		_chest_entity_animation_type = "shulker",
		_mcl_baseitem = get_shulker_stack,
		groups = {
			handy = 1,
			pickaxey = 1,
			container = 3,
			deco_block = 1,
			dig_by_piston = 1,
			shulker_box = 1,
			chest_entity = 1,
			not_in_creative_inventory = 1,
			piglin_protected = 1,
		},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		paramtype = "light",
		paramtype2 = "facedir",
		on_construct = function(pos)
			local param2 = core.get_node(pos).param2 or 1
			local rot = {x = shulker_box_rotations[param2].x, y = shulker_box_rotations[param2].y, z = 0}
			local entity = create_entity(pos, small_name, {default = {mob_texture},}, param2, false, "mcl_chests_shulker", "mcl_chests_shulker", "shulker")
			if entity and entity.object then
				entity.object:set_rotation(rot)
			end
		end,
		after_place_node = function(pos, placer, itemstack, _)
			-- normally not called (_small variant is never created as an item)
			-- keep it here to make sure inventory - if any - is not lost
			set_inventory_and_meta_from_stack(pos, itemstack)

			if core.is_creative_enabled(placer:get_player_name()) then
				local ninv = core.get_meta(pos):get_inventory()
				if not ninv:is_empty("main") then
					return nil
				else
					return itemstack
				end
			else
				return nil
			end
		end,
		on_rightclick = function(pos, node, clicker)
			player_chest_open(clicker, pos, small_name, {default = { mob_texture },}, node.param2, false, "mcl_chests_shulker",
				"mcl_chests_shulker", true)
		end,
		on_receive_fields = function(_, _, fields, sender)
			if fields.quit then
				player_chest_close(sender)
			end
		end,
		on_destruct = function(pos)
			local boxitem = get_shulker_stack(pos)
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			if core.is_creative_enabled("") then
				if not inv:is_empty("main") then
					core.add_item(pos, boxitem)
				end
			else
				core.add_item(pos, boxitem)
			end
		end,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, _, _, stack, player)
			local name = player:get_player_name()
			if core.is_protected(pos, name) then
				core.record_protection_violation(pos, name)
				return 0
			end
			-- Do not allow to place shulker boxes into shulker boxes
			local group = core.get_item_group(stack:get_name(), "shulker_box")
			if group == 0 or group == nil then
				return stack:get_count()
			else
				return 0
			end
		end,
		on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" moves stuff in shulker box at " .. core.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, _, stack, player)
			core.log("action", player:get_player_name() ..
				" moves stuff to shulker box at " .. core.pos_to_string(pos))
			mcl_redstone.update_comparators(pos)
		end,
		on_metadata_inventory_take = function(pos, _, _, _, player)
			core.log("action", player:get_player_name() ..
				" takes stuff from shulker box at " .. core.pos_to_string(pos))
			mcl_redstone.update_comparators(pos)
		end,
		_mcl_blast_resistance = 6,
		_mcl_hardness = 2,
	})

	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_chests:" .. canonical_shulker_color .. "_shulker_box", "nodes",
			"mcl_chests:" .. color .. "_shulker_box")
		doc.add_entry_alias("nodes", "mcl_chests:" .. canonical_shulker_color .. "_shulker_box_small", "nodes",
			"mcl_chests:" .. color .. "_shulker_box_small")
	end
	core.register_craft({
		type = "shapeless",
		output = "mcl_chests:"..color.."_shulker_box",
		recipe = { "group:shulker_box", "mcl_dyes:"..mcl_dyes.mcl2_to_color(color) }
	})
end

core.register_craft({
	output = "mcl_chests:violet_shulker_box",
	recipe = {
		{ "mcl_mobitems:shulker_shell" },
		{ "mcl_chests:chest" },
		{ "mcl_mobitems:shulker_shell" },
	},
})

-- Save metadata of shulker box when used in crafting
core.register_on_craft(function(itemstack, _, old_craft_grid, _)
	if core.get_item_group(itemstack:get_name(), "shulker_box") ~= 1 then
		return
	end
	local original
	for i = 1, #old_craft_grid do
		local item = old_craft_grid[i]:get_name()
		if core.get_item_group(item, "shulker_box") == 1 then
			original = old_craft_grid[i]
			break
		end
	end
	if original then
		local ometa = original:get_meta():to_table()
		local nmeta = itemstack:get_meta()
		nmeta:from_table(ometa)
		return itemstack
	end
end)

local function select_and_spawn_entity(pos, node)
	local node_name = node.name
	local node_def = core.registered_nodes[node_name]
	local double_chest = core.get_item_group(node_name, "double_chest") > 0
	if not animate_chests and not double_chest then
		return
	end

	find_or_create_entity(pos, node_name, node_def._chest_entity_textures, node.param2, double_chest, node_def._chest_entity_sound, node_def._chest_entity_mesh, node_def._chest_entity_animation_type)
end

function mcl_chests.is_opened (chest)
	for k, v in pairs (open_chests) do
		if vector.equals (v.pos, chest)
			and core.get_player_by_name (k) then
			return true
		end
	end
	return false
end

core.register_lbm({
	label = "Spawn Chest entities",
	name = "mcl_chests:spawn_chest_entities",
	nodenames = { "group:chest_entity" },
	run_at_every_load = true,
	action = select_and_spawn_entity,
})

core.register_lbm({
	label = "Replace old chest nodes",
	name = "mcl_chests:replace_old",
	nodenames = { "mcl_chests:chest", "mcl_chests:trapped_chest", "mcl_chests:trapped_chest_on",
		"mcl_chests:ender_chest",
		"group:old_shulker_box_node" },
	run_at_every_load = true,
	action = function(pos, node)
		local node_name = node.name
		node.name = node_name .. "_small"
		core.swap_node(pos, node)
		select_and_spawn_entity(pos, node)
		if node_name == "mcl_chests:trapped_chest_on" then
			core.log("action", "[mcl_chests] Disabled active trapped chest on load: " .. core.pos_to_string(pos))
			chest_update_after_close(pos)
		elseif node_name == "mcl_chests:ender_chest" then
			local meta = core.get_meta(pos)
			meta:set_string("formspec", formspec_ender_chest)
		end
	end
})

core.register_lbm({
	-- Disable active/open trapped chests when loaded because nobody could
	-- have them open at loading time.
	-- Fixes redstone weirdness.
	label = "Disable active trapped chests",
	name = "mcl_chests:reset_trapped_chests",
	nodenames = { "mcl_chests:trapped_chest_on_small", "mcl_chests:trapped_chest_on_left",
		"mcl_chests:trapped_chest_on_right" },
	run_at_every_load = true,
	action = function(pos)
		core.log("action", "[mcl_chests] Disabled active trapped chest on load: " .. core.pos_to_string(pos))
		chest_update_after_close(pos)
	end,
})

core.register_lbm({
	label = "Update shulker box formspecs (0.72.0)",
	name = "mcl_chests:update_shulker_box_formspecs_0_72_0",
	nodenames = { "group:shulker_box" },
	run_at_every_load = false,
	action = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("formspec", formspec_shulker_box(meta:get_string("name")))
	end,
})

core.register_lbm({
	label = "Upgrade old ender chest formspec",
	name = "mcl_chests:replace_old_ender_form",
	nodenames = { "mcl_chests:ender_chest_small" },
	run_at_every_load = false,
	action = function(pos)
		core.get_meta(pos):set_string("formspec", "")
	end,
})
