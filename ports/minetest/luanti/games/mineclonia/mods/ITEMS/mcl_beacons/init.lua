local S = core.get_translator(core.get_current_modname())
local C = core.colorize
local F = core.formspec_escape

mcl_beacons = {}

local beacon_sounds = {}

local function start_beacon_sound(pos)
	local hash = core.hash_node_position(pos)
	if beacon_sounds[hash] then
		core.sound_stop(beacon_sounds[hash])
	else
		core.sound_play("mcl_beacons_activate", {pos=pos, gain=1.0, max_hear_distance=7})
	end
	beacon_sounds[hash] = core.sound_play("mcl_beacons_beam_idle", {
		pos = pos,
		gain = 0.1,
		max_hear_distance = 7,
		loop = true
	})
end

local function stop_beacon_sound(pos)
	local hash = core.hash_node_position(pos)
	if beacon_sounds[hash] then
		core.sound_play("mcl_beacons_deactivate", {pos=pos, gain=1.0, max_hear_distance=7})
		core.sound_stop(beacon_sounds[hash])
		beacon_sounds[hash] = nil
	end
end

local function get_beacon_beam(glass_nodename)
	if glass_nodename == "air" then return 0 end
	local def = core.registered_nodes[glass_nodename]
	if def and def._color then
		return mcl_dyes.colors[def._color].palette_index
	end
end

local function set_node_if_clear(pos,node)
	local tn = core.get_node(pos)
	local def = core.registered_nodes[tn.name]
	if tn.name == "air" or (def and def.buildable_to) then
		core.set_node(pos,node)
	end
end

local function remove_beacon_beam(pos)
	stop_beacon_sound(pos)
	for y=pos.y, pos.y+301 do
		local node = core.get_node({x=pos.x,y=y,z=pos.z})
		if node.name ~= "air" and node.name ~= "mcl_core:bedrock" and node.name ~= "mcl_core:void" then
			if node.name == "ignore" then
				core.get_voxel_manip():read_from_map({x=pos.x,y=y,z=pos.z}, {x=pos.x,y=y,z=pos.z})
				node = core.get_node({x=pos.x,y=y,z=pos.z})
			end

			if node.name == "mcl_beacons:beacon_beam" then
				core.remove_node({x=pos.x,y=y,z=pos.z})
			end
		end
	end
end

local function create_beacon_beam(pos)
	local meta = core.get_meta(pos)
	if meta:get_int("power_level") == 0 then
		remove_beacon_beam(pos)
		return
	end

	start_beacon_sound(pos)

	for y = pos.y +1, pos.y + 300 do
		local node = core.get_node({x=pos.x,y=y,z=pos.z})
		local node_below = core.get_node({x=pos.x,y=y-1,z=pos.z})
		local node_above = core.get_node({x=pos.x,y=y+1,z=pos.z})

		if node_below.name ~= "mcl_beacons:beacon" and core.get_item_group(node_below.name,"material_glass") == 0 and node_below.name ~= "mcl_beacons:beacon_beam" then
			if core.get_node({x=pos.x,y=y-2,z=pos.z}).name == "mcl_beacons:beacon" then
				set_node_if_clear({x=pos.x,y=y-1,z=pos.z},{name="mcl_beacons:beacon_beam",param2=0})
			end
		end

		if node_above.name == "air" or (node_above.name == "mcl_beacons:beacon_beam" and node_above.param2 ~= node.param2) then
			set_node_if_clear({x=pos.x,y=y+1,z=pos.z},{name="mcl_beacons:beacon_beam",param2=node.param2})
		end

		if core.get_item_group(node_below.name, "glass") ~= 0 or core.get_item_group(node_below.name,"material_glass") ~= 0 then
			set_node_if_clear({x=pos.x,y=y,z=pos.z},{name="mcl_beacons:beacon_beam",param2=get_beacon_beam(node_below.name)})
			set_node_if_clear({x=pos.x,y=y+1,z=pos.z},{name="mcl_beacons:beacon_beam",param2=get_beacon_beam(node_below.name)})
		end
	end
end

local function check_pyramid(pos)
	local m = core.get_meta(pos)
	for y_offset = 1,4 do
		local block_y = pos.y - y_offset
		for block_x = (pos.x-y_offset),(pos.x+y_offset) do
			for block_z = (pos.z-y_offset),(pos.z+y_offset) do
				if core.get_item_group(core.get_node(vector.new(block_x, block_y, block_z)).name, "beacon_block") == 0 then
					m:set_int("power_level", y_offset -1)
					return y_offset - 1
				end
			end
		end
		if y_offset == 4 then --all checks are done, beacon is maxed
			m:set_int("power_level", 4)
			return 4
		end
	end
end

local effect_level = {
	swiftness = 1,
	haste = 1,
	resistance = 2,
	leaping = 2,
	strength = 3,
	regeneration = 4,
}

local function get_effect_button(effect, img, bdata, x, y)
	local pdef = mcl_potions.registered_effects[effect] or { }
	if bdata.power_level < effect_level[effect] then
		local tt = "tooltip["..x..","..y..";1,1;".. ( pdef.description or "???" ).."("..S("Unavailable")..")]"
		return "image["..x..","..y..";1,1;"..img.."^[colorize:"..mcl_colors.GRAY..":128;".."]"..tt
	elseif (bdata.secondary_effect == "regeneration" and effect == "regeneration") or bdata.effect == effect then
		local tt = "tooltip["..x..","..y..";1,1;".. ( pdef.description or "???" ).."("..S("Active")..")]"
		return "image["..x..","..y..";1,1;"..img.."]"..tt
	else
		return "image_button["..x..","..y..";1,1;"..img..";"..effect..";]"
	end
end

local function get_effect_level_button(bdata)
	if bdata.effect and bdata.effect ~= "" then
		local geo = "8.5,3.5;1,1;"
		local texmod = ""
		local pdef = mcl_potions.registered_effects[bdata.effect] or { }
		if bdata.power_level < 4 then
			local tt = " tooltip["..geo..( pdef.description or "???" ).." II ("..S("Unavailable")..")]"
			return "image[".. geo .. (pdef.icon or "unknown.png").. "^[colorize:"..mcl_colors.GRAY..":128] "..tt
		elseif bdata.effect_level > 1 then
			local tt = "tooltip["..geo..( pdef.description or "???" ).." II ("..S("Active")..")]"
			return "image[".. geo .. (pdef.icon or "unknown.png").. "] "..tt
		end
		return ("image_button[".. geo .. (pdef.icon or "unknown.png")..texmod .. ";upgrade_ii;] ".. " tooltip["..geo..(pdef.description or "???") .." II]")
	else
		return ""
	end
end

local function generate_beacon_formspec (meta, pos)
	local bdata = {
		power_level = check_pyramid(pos),
		effect = meta:get_string("effect"),
		secondary_effect = meta:get_string("secondary_effect"),
		effect_level = meta:get_int("effect_level")
	}
	local fs = {
		"formspec_version[4]",
		"size[11.75,14.425]",
		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Beacon"))) .. "]",
		"label[0.5,1;"..core.formspec_escape(S("Primary Power:")).."]",
		"label[5.5,1;"..core.formspec_escape(S("Secondary Power:")).."]",
		"image[1,1.5;1,1;custom_beacon_symbol_4.png]",
		"image[1,3;1,1;custom_beacon_symbol_3.png]",
		"image[1,4.5;1,1;custom_beacon_symbol_2.png]",
		"image[6,3.5;1,1;custom_beacon_symbol_1.png]",
		get_effect_button("swiftness", "mcl_potions_effect_swift.png", bdata, 2.5, 1.5),
		get_effect_button("haste", "mcl_potions_effect_haste.png", bdata, 3.5, 1.5),
		get_effect_button("resistance", "mcl_potions_effect_resistance.png", bdata, 2.5, 3),
		get_effect_button("leaping", "mcl_potions_effect_leaping.png", bdata, 3.5, 3),
		get_effect_button("strength", "mcl_potions_effect_strong.png", bdata, 3.0, 4.5),
		get_effect_button("regeneration", "mcl_potions_effect_regenerating.png", bdata, 7.5, 3.5),
		"tooltip[swiftness;"..S("Swiftness").."]",
		"tooltip[haste;"..S("Haste").."]",
		"tooltip[resistance;"..S("Resistance").."]",
		"tooltip[leaping;"..S("Leaping").."]",
		"tooltip[strength;"..S("Strength").."]",
		"tooltip[regeneration;"..S("Regeneration").."]",
		get_effect_level_button(bdata),
		"item_image[1,7;1,1;mcl_core:diamond]",
		"item_image[2.2,7;1,1;mcl_core:emerald]",
		"item_image[3.4,7;1,1;mcl_core:iron_ingot]",
		"item_image[4.6,7;1,1;mcl_core:gold_ingot]",
		"item_image[5.8,7;1,1;mcl_nether:netherite_ingot]",
		mcl_formspec.get_itemslot_bg_v4(7.2,7,1,1),
		"list[context;input;7.2,7;1,1;]",

		"label[0.375,8.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 9.1, 9, 3),
		"list[current_player;main;0.375,9.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 13.05, 9, 1),
		"list[current_player;main;0.375,13.05;9,1;]",

		"listring[context;input]",
		"listring[current_player;main]"
	}
	return table.concat(fs)
end

local function clear_obstructed_beam(pos)
	for y=pos.y+1, pos.y+100 do
		local nodename = core.get_node({x=pos.x,y=y, z = pos.z}).name
		local def = core.registered_nodes[nodename]
		if def and def.groups.opaque and nodename ~= "mcl_core:bedrock" and nodename ~= "mcl_core:void" and nodename ~= "ignore" then --ignore means not loaded, let's just assume that's air
			if nodename ~="mcl_beacons:beacon_beam" and nodename ~="mcl_beacons:beacon" then
				if core.get_item_group(nodename,"glass") == 0 and core.get_item_group(nodename,"material_glass") == 0  then
					remove_beacon_beam(pos)
					return true
				end
			end
		end
	end

	return false
end

local function effect_player(effect, pos, power_level, effect_level,player)
	local distance =  vector.distance(player:get_pos(), pos)
	if distance > (power_level+1)*10 then return end
	mcl_potions.give_effect_by_level (effect, player, effect_level, 16)
end

local function apply_effects_to_all_players(pos)
	local meta = core.get_meta(pos)
	local effect_string = meta:get_string("effect")
	local effect_level = meta:get_int("effect_level")
	local secondary = meta:get_string ("secondary_effect")
	local old_power_level = meta:get_int("power_level")

	local power_level = check_pyramid(pos)
	if power_level == 0 then return end
	if old_power_level ~= power_level then
		meta:set_string("formspec", generate_beacon_formspec(meta, pos))
	end

	if effect_level == 2 and power_level < 4 then --no need to run loops when beacon is in an invalid setup :P
		return
	end

	local beacon_distance = (power_level + 1) * 10

	for player in mcl_util.connected_players(pos, beacon_distance) do
		if vector.distance(pos, player:get_pos()) <= beacon_distance then
			if not clear_obstructed_beam (pos) then
				if effect_string and effect_string ~= "" then
					effect_player (effect_string, pos, power_level, effect_level, player)
				end
				if secondary and secondary ~= "" and power_level == 4 then
					effect_player (secondary, pos, power_level, 1, player)
				end
			end
		end
	end
end

local function allow_metadata_inventory_take_put(pos, _, _, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	end
	return stack:get_count()
end

local function add_group(item, group)
	local def = core.registered_items[item]
	if def then
		core.override_item(item, {
			groups = table.merge(def.groups or {}, { [group] = 1 })
		})
	end
end

function mcl_beacons.register_beaconblock (itemstring)
	core.log("warning", "[mcl_beacons] mcl_beacons.register_beaconblock is deprecated. Use the \"beacon_block\" item group instead!")
	add_group(itemstring, "beacon_block")
end

function mcl_beacons.register_beaconfuel(itemstring)
	core.log("warning", "[mcl_beacons] mcl_beacons.register_beaconfuel is deprecated. Use the \"beacon_fuel\" item group instead!")
	add_group(itemstring, "beacon_fuel")
end

local function set_effect(pos, effect)
	local meta = core.get_meta(pos)
	if meta:get_string("effect") == effect then return false end
	meta:set_string ("effect", effect)
	if meta:get_int ("effect_level") < 1 then
		meta:set_int ("effect_level", 1)
	end
	return true
end

local function apply_beacon_formspec (pos, _, fields, sender)
	local sender_name = sender:get_player_name ()
	-- Return if the node is no longer a beacon.
	if not pos or core.get_node (pos).name ~= "mcl_beacons:beacon" then
		return
	end

	if core.is_protected (pos, sender_name) then
		core.record_protection_violation (pos, sender_name)
		return
	end

	if (fields.swiftness or fields.regeneration or fields.leaping
	or fields.strength or fields.upgrade_ii or fields.resistance
	or fields.haste) then
		local power_level = check_pyramid(pos)

		if core.is_protected (pos, sender_name) then
			core.record_protection_violation(pos, sender_name)
			return
		elseif power_level == 0 then
			return
		end

		local meta = core.get_meta (pos)
		local inv = meta:get_inventory ()
		local input = inv:get_stack ("input", 1)

		if input:is_empty() then
			return
		end

		local valid_item = false

		if core.get_item_group(input:get_name(), "beacon_fuel") > 0 then
			valid_item = true
		end

		if not valid_item then
			return
		end

		local successful = false
		local apply_cost = true

		if fields.swiftness then
			successful = set_effect(pos, "swiftness")
		elseif fields.haste then
			successful = set_effect(pos, "haste")
		elseif fields.leaping and power_level >= 2 then
			successful = set_effect(pos, "leaping")
		elseif fields.resistance and power_level >= 2 then
			successful = set_effect(pos, "resistance")
		elseif fields.strength and power_level >= 3 then
			successful = set_effect(pos, "strength")
		elseif fields.regeneration and power_level == 4 then
			if meta:get_string("effect") ~= "" and meta:get_string("effect_level") == 1 then apply_cost = false end
			-- If a secondary effect is enabled, the effect level must
			-- be reset to 1.
			if meta:get_string("secondary_effect") ~= "regeneration" then
				meta:set_int ("effect_level", 1)
				meta:set_string ("secondary_effect", "regeneration")
				successful = true
			end
		elseif fields.upgrade_ii and power_level == 4 then
			if meta:get_string("effect") ~= "" and meta:get_string("secondary_effect") == "" then apply_cost = false end
			-- Upgrade the primary effect to II but cancel the
			-- secondary one.  Also verify that there is an effect to
			-- upgrade.
			if meta:get_string ("effect") ~= "" and meta:get_int ("effect_level") < 2 then
				meta:set_int ("effect_level", 2)
				meta:set_string ("secondary_effect", "")
				successful = true
			end
		end
		if successful then
			if power_level == 4 then
				awards.unlock(sender_name, "mcl:maxed_beacon")
			end
			awards.unlock(sender_name, "mcl:beacon")

			if apply_cost then
				input:take_item ()
				inv:set_stack("input",1,input)
			end

			remove_beacon_beam(pos)
			create_beacon_beam(pos)
			apply_effects_to_all_players(pos) --call it once outside the globalstep so the player gets the effect right after selecting it
			-- Redisplay the formspec.
			meta:set_string("formspec", generate_beacon_formspec(meta, pos))
		end
	end
end

core.register_node("mcl_beacons:beacon", {
	description = S("Beacon"),
	drawtype = "mesh",
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	mesh = "mcl_beacon.b3d",
	tiles = {"beacon_UV.png"},
	is_ground_content = false,
	use_texture_alpha = "clip",
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		meta:set_string("formspec", generate_beacon_formspec(meta, pos))
	end,
	after_dig_node = mcl_util.drop_items_from_meta_container({"input"}),
	on_destruct = remove_beacon_beam,
	on_receive_fields = apply_beacon_formspec,
	allow_metadata_inventory_put = allow_metadata_inventory_take_put,
	allow_metadata_inventory_move = function () return 0 end,
	allow_metadata_inventory_take = allow_metadata_inventory_take_put,
	light_source = 14,
	groups = {handy=1, deco_block=1},
	drop = "mcl_beacons:beacon",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_hardness = 3,
	_configures_formspec = true,
})

core.register_node("mcl_beacons:beacon_beam", {
	tiles = {"blank.png^[noalpha^[colorize:#b8bab9"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1250, -0.5000, -0.1250, 0.1250, 0.5000, 0.1250}
		}
	},
	pointable= false,
	light_source = core.LIGHT_MAX,
	walkable = false,
	groups = {not_in_creative_inventory=1},
	_mcl_hardness = 1200,
	paramtype2 = "color",
	palette = "mcl_dyes_palette.png",
	buildable_to = true,
})

core.register_craft({
	output = "mcl_beacons:beacon",
	recipe = {
		{"mcl_core:glass", "mcl_core:glass", "mcl_core:glass"},
		{"mcl_core:glass", "mcl_mobitems:nether_star", "mcl_core:glass"},
		{"mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian"}
	}
})

core.register_abm{
	label="apply beacon effects to players",
	nodenames = {"mcl_beacons:beacon"},
	interval = 3,
	chance = 1,
	action = function(pos)
		if not clear_obstructed_beam(pos) then
			apply_effects_to_all_players(pos)
			create_beacon_beam(pos)
		end
	end,
}

core.register_lbm({
	label = "Upgrade pre 106.1 beacons data",
	name = "mcl_beacons:upgrade_beacon_data",
	nodenames = {"mcl_beacons:beacon"},
	run_at_every_load = false,
	action = function(pos)
		local m = core.get_meta(pos)
		m:set_string("formspec", generate_beacon_formspec(m, pos))

		if m:get_string ("effect") == "regeneration" then
			m:set_string ("effect", "")
			m:set_string ("secondary_effect", "regeneration")
			m:set_string ("effect_level", 1)
		elseif m:get_string ("effect") == "strenght" then
			m:set_string ("effect", "strength")
		end
	end,
})
