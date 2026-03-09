local S = core.get_translator(core.get_current_modname())

function mcl_doors.is_open(pos)
	local meta = core.get_meta(pos)
	return meta:get_int("is_open") == 1
end

-- This helper function calls on_place_node callbacks.
local function on_place_node(place_defs, placer, itemstack)
	-- Run script hook
	for _, callback in pairs(core.registered_on_placenodes) do
		-- Deep-copy pos, node and pointed_thing because callback can modify them
		local place_to_copy = vector.copy(place_defs.place_to)
		local newnode_copy = table.copy(place_defs.newnode)
		local oldnode_copy = table.copy(place_defs.oldnode)
		local pointed_thing_copy = table.copy(place_defs.pointed_thing)

		callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy)
	end
end

function mcl_doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	def.groups.dig_by_piston = 1
	def.groups.unsticky = 1
	def.groups.door = 1

	if not def.sound_open then def.sound_open = "doors_door_open" end
	if not def.sound_close then def.sound_close = "doors_door_close" end

	local box = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.3125}}

	if not def.node_box_bottom then def.node_box_bottom = box end
	if not def.node_box_top then def.node_box_top = box end
	if not def.selection_box_bottom then def.selection_box_bottom= box end
	if not def.selection_box_top then def.selection_box_top = box end

	local longdesc, usagehelp, tt_help
	tt_help = def._tt_help
	longdesc = def._doc_items_longdesc
	usagehelp = def._doc_items_usagehelp

	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = S("This door is a 2-block high barrier which can be opened or closed by hand or by redstone power.")
		else
			longdesc = S("This door is a 2-block high barrier which can only be opened by redstone power, not by hand.")
		end
	end

	if not usagehelp then
		if def.only_redstone_can_open then
			usagehelp = S("To open or close this door, send a redstone signal to its bottom half.")
		else
			usagehelp = S("To open or close this door, rightclick it or send a redstone signal to its bottom half.")
		end
	end

	if not tt_help then
		if def.only_redstone_can_open then
			tt_help = S("Openable by redstone power")
		else
			tt_help = S("Openable by players and redstone power")
		end
	end

	local craftitem_groups = {deco_block = 1}
	if def.groups and def.groups.flammable then
		craftitem_groups.flammable = def.groups.flammable
	end

	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then return true end

		local meta = core.get_meta(pos)
		local pn = player:get_player_name()

		return meta:get_string("doors_owner") == pn
	end

	local function on_open_close(pos, dir, check_name, replace, replace_dir)
		local meta1 = core.get_meta(pos)
		pos.y = pos.y + dir
		local meta2 = core.get_meta(pos)

		-- if name of other door is not the same as check_name -> return
		if core.get_node(pos).name ~= check_name  then return end
		-- swap directions if mirrored
		local params = {3,0,1,2}
		if meta1:get_int("is_open") == 0 and meta2:get_int("is_mirrored") == 0 or meta1:get_int("is_open") == 1 and meta2:get_int("is_mirrored") == 1 then
			params = {1,2,3,0}
		end

		local p2 = core.get_node(pos).param2
		local np2 = params[p2 + 1]

		core.swap_node(pos, {name = replace_dir, param2 = np2})
		pos.y = pos.y - dir
		core.swap_node(pos, {name = replace, param2 = np2})

		local door_switching_sound
		if meta1:get_int("is_open") == 1 then
			door_switching_sound = def.sound_close
			meta1:set_int("is_open", 0)
			meta2:set_int("is_open", 0)
		else
			door_switching_sound = def.sound_open
			meta1:set_int("is_open", 1)
			meta2:set_int("is_open", 1)
		end

		core.sound_play(door_switching_sound, {pos = pos, gain = 0.5, max_hear_distance = 16}, true)
	end

	local function swap_door (pos)
		local node = core.get_node (pos)
		if node.name:find ("_1") then
			on_open_close(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2")
		else
			on_open_close(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1")
		end
	end

	local function open(pos)
		if not mcl_doors.is_open (pos) then
			swap_door (pos)
		end
	end

	local function close(pos)
		if mcl_doors.is_open (pos) then
			swap_door (pos)
		end
	end

	local function redstone_connects_to(_, _) return true end

	local function redstone_update(pos_bottom, pos_top)
		local power_top = mcl_redstone.get_power(pos_top)
		local power_bottom = mcl_redstone.get_power(pos_bottom)
		local meta_top = core.get_meta(pos_top)
		local meta_bottom = core.get_meta(pos_bottom)

		local power = math.max(power_top, power_bottom)
		local previous_power = math.max(meta_top:get_int("redstone_power"), meta_bottom:get_int("redstone_power"))

		if power ~= previous_power then
			if power ~= 0 then
				open(pos_bottom)
			else
				close(pos_bottom)
			end
		end

		meta_top:set_int("redstone_power", power)
		meta_bottom:set_int("redstone_power", power)
	end

	local function get_other_half(node_name)
		if node_name:find("_t_") then
			return node_name:gsub("_t_", "_b_")
		else
			return node_name:gsub("_b_", "_t_")
		end
	end

	local rightclick = function(pos, node, clicker)
		if check_player_priv(pos, clicker) then
			local name = node.name
			local dir = name:find("_t_") and -1 or 1
			local other_half = get_other_half(name)
			local r_name = name:find("_1") and name:gsub("_1", "_2") or name:gsub("_2", "_1")
			local r_dir = get_other_half(r_name)

			on_open_close(pos, dir, other_half, r_name, r_dir)
		end
	end

	local tpl_doors = {
		_mcl_baseitem = name,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		_mcl_hardness = def._mcl_hardness,
		can_dig = check_player_priv,
		drawtype = "nodebox",
		drop = "",
		groups = def.groups,
		is_ground_content = false,
		on_rightclick = not def.only_redstone_can_open and rightclick or nil,
		on_rotate = function(pos, node, _, mode, _)
			if mode == screwdriver.ROTATE_FACE then
				local meta1 = core.get_meta(pos)
				local dir = node.name:find("_b_") and 1 or -1
				local pos2 = vector.offset(pos, 0, dir, 0)
				local meta2 = core.get_meta(pos2)

				meta1:set_int("rotation", 1)
				node.param2 = screwdriver.rotate.facedir(pos, node, mode)
				core.swap_node(pos, node)

				meta2:set_int("rotation", 1)
				node.name = get_other_half(node.name)
				core.swap_node(pos2, node)

				return true
			end
			return false
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local dir = oldnode.name:find("_t_") and -1 or 1
			if oldmetadata.fields["rotation"] == 1 then
				oldmetadata.fields["rotation"] = 0
			else
				if not digger or (digger and not core.is_creative_enabled(digger:get_player_name())) then
					core.add_item(pos, name)
				end
				core.remove_node(vector.offset(pos, 0, dir, 0))
			end
		end,
		paramtype = "light",
		paramtype2 = "facedir",
		sounds = def.sounds,
		sunlight_propagates = true,
		use_texture_alpha = "clip"
	}

	local tpl_bottom = {
		_mcl_redstone = {
			connects_to = redstone_connects_to,
			init = function() end,
			update = function(pos)
				redstone_update(pos, pos:offset(0, 1, 0))
			end
		},
		_on_wind_charge_hit = function(pos)
			if mcl_doors.is_open(pos) then close(pos) else open(pos) end
			return true
		end,
		node_box = {
			fixed = def.node_box_bottom,
			type = "fixed"
		},
		selection_box = {
			fixed = def.selection_box_bottom,
			type = "fixed"
		}
	}

	local tpl_top = {
		_mcl_redstone = {
			connects_to = redstone_connects_to,
			init = function() end,
			update = function(pos)
				redstone_update(pos:offset(0, -1, 0), pos)
			end
		},
		_on_wind_charge_hit = function(pos)
			pos.y = pos.y - 1
			if mcl_doors.is_open(pos) then close(pos) else open(pos) end
			return true
		end,
		node_box = {
			fixed = def.node_box_top,
			type = "fixed"
		},
		selection_box = {
			fixed = def.selection_box_top,
			type = "fixed"
		}
	}

	core.register_node(":"..name, {
		description = def.description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		_mcl_burntime = def._mcl_burntime,
		tiles = {"blank.png"},
		wield_image = def.inventory_image,
		inventory_image = def.inventory_image,
		groups = craftitem_groups,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
				return itemstack
			end

			local name = itemstack:get_name()
			local pn = placer:get_player_name()
			local pt = pointed_thing.above
			local ptu = pointed_thing.under

			if core.is_protected(pt, pn) and core.is_protected(ptu, pn) then return itemstack end

			local ptunode = core.get_node(ptu)
			local ptudefs = core.registered_nodes[ptunode.name]
			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)

			if rc then return rc end

			if ptudefs and ptudefs.buildable_to then pt = pointed_thing.under end

			local pt2 = vector.offset(pt, 0, 1, 0)
			local ptname = core.get_node(pt).name
			local pt2name = core.get_node(pt2).name
			local ptdefs = core.registered_nodes[ptname]
			local pt2defs = core.registered_nodes[pt2name]

			if (ptdefs and not ptdefs.buildable_to) or (pt2defs and not pt2defs.buildable_to) then
				return itemstack
			end
			-- get left coordinate for checking if another door is there
			local p2 = core.dir_to_facedir(placer:get_look_dir())
			local offset_x = p2 % 2 == 0 and p2 -1 or 0
			local offset_z = p2 % 2 ~= 0 and 2 - p2 or 0
			local pt_left = vector.offset(pt, offset_x, 0, offset_z)
			local left_node = core.get_node(pt_left)
			local mirrored = false
			local door_dir = 1

			if left_node.name:sub(1, #name) == name then
				mirrored = true
				door_dir = 2
				p2 = left_node.param2
			end
			-- Set door nodes
			core.set_node(pt, {name = name.."_b_"..door_dir, param2 = p2})
			core.set_node(pt2, {name = name.."_t_"..door_dir, param2 = p2})

			if def.sounds and def.sounds.place then
				core.sound_play(def.sounds.place, {pos = pt}, true)
			end

			if def.only_placer_can_open then
				local meta = core.get_meta(pt)
				meta:set_string("doors_owner", "")
				meta = core.get_meta(pt2)
				meta:set_string("doors_owner", "")
			end

			local meta1 = core.get_meta(pt)
			local meta2 = core.get_meta(pt2)
			-- save mirror state for the correct door
			if mirrored then
				meta1:set_int("is_mirrored", 1)
				meta2:set_int("is_mirrored", 1)
			end
			-- Save open state. 1 = open. 0 = closed
			meta1:set_int("is_open", 0)
			meta2:set_int("is_open", 0)

			if not core.is_creative_enabled(pn) then itemstack:take_item() end

			local place_defs_pt = {
				newnode = core.get_node(pt),
				oldnode = ptunode,
				place_to = pt,
				pointed_thing = pointed_thing
			}

			local place_defs_pt2 = {
				newnode = core.get_node(pt2),
				oldnode = core.get_node(vector.offset(ptu, 0, 1, 0)),
				place_to = pt2,
				pointed_thing = pointed_thing
			}

			on_place_node(place_defs_pt, placer, itemstack)
			on_place_node(place_defs_pt2, placer, itemstack)

			return itemstack
		end,
	})

	local tt = def.tiles_top
	local tb = def.tiles_bottom

	core.register_node(":"..name.."_b_1", table.merge({
		tiles = {
			"blank.png", tt[2].."^[transformFXR90", tb[2],
			tb[2].."^[transformFX", tb[1], tb[1].."^[transformFX"
		}
	}, tpl_doors, tpl_bottom))

	core.register_node(":"..name.."_t_1", table.merge({
		tiles = {
			tt[2].."^[transformR90", "blank.png", tt[2],
			tt[2].."^[transformFX", tt[1], tt[1].."^[transformFX"
		}
	}, tpl_doors, tpl_top))

	core.register_node(":"..name.."_b_2", table.merge({
		tiles = {
			"blank.png", tt[2].."^[transformFXR90", tb[2].."^[transformI",
			tb[2].."^[transformFX", tb[1].."^[transformFX", tb[1]
		}
	}, tpl_doors, tpl_bottom))

	core.register_node(":"..name.."_t_2", table.merge({
		tiles = {
			tt[2].."^[transformR90", "blank.png", tt[2].."^[transformI",
			tt[2].."^[transformFX", tt[1].."^[transformFX", tt[1]
		}
	}, tpl_doors, tpl_top))
	doc.add_entry_alias("craftitems", name, "nodes", name.."_b_1")
	doc.add_entry_alias("craftitems", name, "nodes", name.."_b_2")
	doc.add_entry_alias("craftitems", name, "nodes", name.."_t_1")
	doc.add_entry_alias("craftitems", name, "nodes", name.."_t_2")
end
