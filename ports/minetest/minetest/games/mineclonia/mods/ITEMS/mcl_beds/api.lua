local S = minetest.get_translator(minetest.get_current_modname())

local function get_bed_next_node(pos, node)
	local node = node or minetest.get_node_or_nil(pos)
	if not node then return end

	local dir = minetest.facedir_to_dir(node.param2)

	local pos2, bottom
	if string.sub(node.name, -4) == "_top" then
		pos2 = vector.subtract(pos, dir)
	else
		pos2 = vector.add(pos, dir)
		bottom = true
	end

	local node2 = minetest.get_node(pos2)
	return pos2, node2, bottom, dir
end

local function rotate(pos, node, user, mode, new_param2)
	if mode ~= screwdriver.ROTATE_FACE then
		return false
	end

	local p, node2, bottom = get_bed_next_node(pos, node)
	if not node2 then return end

	local name = node2.name
	if minetest.get_item_group(name, "bed") ~= 2 or node.param2 ~= node2.param2 then return false end

	if bottom then
		name = string.sub(name, 1, -5)
	else
		name = string.sub(name, 1, -8)
	end

	if minetest.is_protected(p, user:get_player_name()) then
		minetest.record_protection_violation(p, user:get_player_name())
		return false
	end

	local newp
	local new_dir = minetest.facedir_to_dir(new_param2)

	if bottom then
		 newp = vector.add(pos, new_dir)
	else
		 newp = vector.subtract(pos, new_dir)
	end

	local node3 = minetest.get_node_or_nil(newp)
	if not node3 then return false end

	local node_def = minetest.registered_nodes[node3.name]
	if not node_def or not node_def.buildable_to then return false end

	if minetest.is_protected(newp, user:get_player_name()) then
		minetest.record_protection_violation(newp, user:get_player_name())
		return false
	end

	node.param2 = new_param2
	-- do not remove_node here - it will trigger destroy_bed()
	minetest.swap_node(p, {name = "air"})
	minetest.swap_node(pos, node)
	minetest.swap_node(newp, {name = name .. (bottom and "_top" or "_bottom"), param2 = new_param2})

	return true
end


local function destruct_bed(pos, oldnode)
	local node = oldnode or minetest.get_node_or_nil(pos)
	if not node then return end

	local pos2, node2, bottom = get_bed_next_node(pos, oldnode)

	if bottom then
		if node2 and string.sub(node2.name, -4) == "_top" then
			minetest.remove_node(pos2)
		end
	else
		if node2 and string.sub(node2.name, -7) == "_bottom" then
			minetest.remove_node(pos2)
		end
	end
end

local function kick_player_after_destruct(destruct_pos)
	for name, player_bed_pos in pairs(mcl_beds.bed_pos) do
		if vector.distance(destruct_pos, player_bed_pos) < 0.1 then
			local player = minetest.get_player_by_name(name)
			if player and player:is_player() then
				mcl_beds.kick_player(player)
				break
			end
		end
	end
end

local beddesc = S("Beds allow you to sleep at night and make the time pass faster.")
local beduse = S("To use a bed, stand close to it and right-click the bed to sleep in it. Sleeping only works when the sun sets, at night or during a thunderstorm. The bed must also be clear of any danger.")
if minetest.settings:get_bool("enable_bed_respawn") == false then
	beddesc = beddesc .. "\n" .. S("You have heard of other worlds in which a bed would set the start point for your next life. But this world is not one of them.")
else
	beddesc = beddesc .. "\n" .. S("By using a bed, you set the starting point for your next life. If you die, you will start your next life at this bed, unless it is obstructed or destroyed.")
end
if minetest.settings:get_bool("enable_bed_night_skip") == false then
	beddesc = beddesc .. "\n" .. S("In this world, going to bed won't skip the night, but it will skip thunderstorms.")
else
	beddesc = beddesc .. "\n" .. S("Sleeping allows you to skip the night. The night is skipped when all players in this world went to sleep. The night is skipped after sleeping for a few seconds. Thunderstorms can be skipped in the same manner.")
end

local default_sounds
if minetest.get_modpath("mcl_sounds") then
	default_sounds = mcl_sounds.node_sound_wood_defaults({
		footstep = mcl_sounds.node_sound_wool_defaults().footstep,
	})
end

function mcl_beds.register_bed(name, def)
	local common_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		}

	minetest.register_node(name .. "_bottom", {
		description = def.description,
		_tt_help = S("Allows you to sleep"),

		_doc_items_longdesc = def._doc_items_longdesc or beddesc,
		_doc_items_usagehelp = def._doc_items_usagehelp or beduse,
		_doc_items_create_entry = def._doc_items_create_entry,
		_doc_items_entry_name = def._doc_items_entry_name,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drawtype = "mesh",
		mesh = "mcl_beds_bed_bottom.obj",
		tiles = def.tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		stack_max = 1,
		groups = {handy=1, bed = 1, dig_by_piston=1, bouncy=66, fall_damage_add_percent=-50, deco_block = 1, flammable=-1},
		_mcl_hardness = 0.2,
		_mcl_blast_resistance = 1,
		sounds = def.sounds or default_sounds,
		selection_box = common_box,
		collision_box = common_box,
		drop = def.recipe and name or "",
		node_placement_prediction = "",

		on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under
			local player_name = placer and placer:get_player_name() or ""

			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			local pos
			local undername = minetest.get_node(under).name
			if minetest.registered_items[undername] and minetest.registered_items[undername].buildable_to then
				pos = under
			else
				pos = pointed_thing.above
			end

			if minetest.is_protected(pos, player_name) and
					not minetest.check_player_privs(player_name, "protection_bypass") then
				minetest.record_protection_violation(pos, player_name)
				return itemstack
			end

			local node_def = minetest.registered_nodes[minetest.get_node(pos).name]
			if not node_def or not node_def.buildable_to then
				return itemstack
			end

			local dir = placer and placer:is_player() and placer:get_look_dir() and
				minetest.dir_to_facedir(placer:get_look_dir()) or 0
			local botpos = vector.add(pos, minetest.facedir_to_dir(dir))

			if minetest.is_protected(botpos, player_name) and
					not minetest.check_player_privs(player_name, "protection_bypass") then
				minetest.record_protection_violation(botpos, player_name)
				return itemstack
			end

			local botdef = minetest.registered_nodes[minetest.get_node(botpos).name]
			if not botdef or not botdef.buildable_to then
				return itemstack
			end

			minetest.set_node(pos, {name = name .. "_bottom", param2 = dir})
			minetest.set_node(botpos, {name = name .. "_top", param2 = dir})

			if not minetest.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
			return itemstack
		end,

		after_destruct = destruct_bed,

		on_destruct = kick_player_after_destruct,

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			mcl_beds.on_rightclick(pos, clicker, false)
			return itemstack
		end,

		on_rotate = rotate,
	})



	minetest.register_node(name .. "_top", {
		drawtype = "mesh",
		mesh = "mcl_beds_bed_top.obj",
		tiles = def.tiles,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		-- FIXME: Should be bouncy=66, but this would be a higher bounciness than slime blocks!
		groups = {handy = 1, flammable = -1, bed = 2, dig_by_piston=1, bouncy=33, fall_damage_add_percent=-50, not_in_creative_inventory = 1},
		_mcl_hardness = 0.2,
		_mcl_blast_resistance = 1,
		sounds = def.sounds or default_sounds,
		drop = def.recipe and name or "",
		selection_box = common_box,
		collision_box = common_box,

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			mcl_beds.on_rightclick(pos, clicker, true)
			return itemstack
		end,

		on_rotate = rotate,
		after_destruct = destruct_bed,
	})

	minetest.register_alias(name, name .. "_bottom")

	if def.recipe then
		minetest.register_craft({
			output = name,
			recipe = def.recipe
		})
	end

	doc.add_entry_alias("nodes", name.."_bottom", "nodes", name.."_top")
end


