local S = minetest.get_translator(minetest.get_current_modname())

local PRESSURE_PLATE_INTERVAL = 0.25

local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}

local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

local function pp_on_timer(pos, elapsed)
	local node = minetest.get_node(pos)
	local basename = minetest.registered_nodes[node.name].pressureplate_basename
	local activated_by = minetest.registered_nodes[node.name].pressureplate_activated_by

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not basename then return end

	if activated_by == nil then
		activated_by = { any = true }
	end

	local obj_does_activate = function(obj, activated_by)
		if activated_by.any then
			return true
		elseif activated_by.mob and obj:get_luaentity() and obj:get_luaentity().is_mob == true then
			return true
		elseif activated_by.player and obj:is_player() then
			return true
		else
			return false
		end
	end

	local function obj_touching_plate_pos(obj_ref, plate_pos)
		local obj_pos = obj_ref:get_pos()
		local props = obj_ref:get_properties()
		local parent = obj_ref:get_attach()
		if props and obj_pos and not parent then
			local collisionbox = props.collisionbox
			local physical = props.physical
			local is_player = obj_ref:is_player()
			local luaentity = obj_ref:get_luaentity()
			local is_item = luaentity and luaentity.name == "__builtin:item"
			if collisionbox and physical or is_player or is_item then
				local plate_x_min = plate_pos.x - 7 / 16
				local plate_x_max = plate_pos.x + 7 / 16
				local plate_z_min = plate_pos.z - 7 / 16
				local plate_z_max = plate_pos.z + 7 / 16
				local plate_y_max = plate_pos.y - 7 / 16

				local obj_x_min = obj_pos.x + collisionbox[1]
				local obj_x_max = obj_pos.x + collisionbox[4]
				local obj_z_min = obj_pos.z + collisionbox[3]
				local obj_z_max = obj_pos.z + collisionbox[6]
				local obj_y_min = obj_pos.y + collisionbox[2]

				if
					obj_y_min <= plate_y_max and
					(obj_x_min < plate_x_max) and
					(obj_x_max > plate_x_min) and
					(obj_z_min < plate_z_max) and
					(obj_z_max > plate_z_min)
				then
					return true
				end
			end
		end
		return false
	end

	local objs = minetest.get_objects_inside_radius(pos, 1)

	if node.name == basename .. "_on" then
		local disable = true
		for k, obj in pairs(objs) do
			if
				obj_does_activate(obj, activated_by) and
				obj_touching_plate_pos(obj, pos)
			then
				disable = false
				minetest.get_meta(pos):set_string("deact_time", "")
				break
			end
		end
		if disable then
			local meta = minetest.get_meta(pos)
			local deact_time = meta:get_float("deact_time")
			local current_time = minetest.get_us_time()
			if deact_time == 0 then
				deact_time = current_time + 1 * 1000 * 1000
				meta:set_float("deact_time", deact_time)
			end
			if deact_time <= current_time then
				minetest.set_node(pos, { name = basename .. "_off" })
				mesecon.receptor_off(pos, mesecon.rules.pplate)
				meta:set_string("deact_time", "")
			end
		end
	elseif node.name == basename .. "_off" then
		for k, obj in pairs(objs) do
			if
				obj_does_activate(obj, activated_by) and
				obj_touching_plate_pos(obj, pos)
			then
				minetest.set_node(pos, { name = basename .. "_on" })
				mesecon.receptor_on(pos, mesecon.rules.pplate)
				break
			end
		end
	end
	return true
end

-- Register a Pressure Plate
-- basename:    base name of the pressure plate
-- description:	description displayed in the player's inventory
-- textures_off:textures of the pressure plate when inactive
-- textures_on:	textures of the pressure plate when active
-- image_w:	wield image of the pressure plate
-- image_i:	inventory image of the pressure plate
-- recipe:	crafting recipe of the pressure plate
-- sounds:	sound table (like in minetest.register_node)
-- plusgroups:	group memberships (attached_node=1 and not_in_creative_inventory=1 are already used)
-- activated_by: optinal table with elements denoting by which entities this pressure plate is triggered
--		Possible table fields:
--		* player=true: Player
--		* mob=true: Mob
--		By default, is triggered by all entities
-- longdesc:	Customized long description for the in-game help (if omitted, a dummy text is used)

function mesecon.register_pressure_plate(basename, description, textures_off, textures_on, image_w, image_i, recipe, sounds, plusgroups, activated_by, longdesc)
	local groups_off = table.copy(plusgroups)
	groups_off.attached_node = 1
	groups_off.dig_by_piston = 1
	groups_off.pressure_plate = 1
	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory = 1
	groups_on.pressure_plate = 2
	if not longdesc then
		longdesc = S("A pressure plate is a redstone component which supplies its surrounding blocks with redstone power while someone or something rests on top of it.")
	end
	local tt = S("Provides redstone power when pushed")
	if not activated_by then
		tt = tt .. "\n" .. S("Pushable by players, mobs and objects")
	elseif activated_by.mob and activated_by.player then
		tt = tt .. "\n" .. S("Pushable by players and mobs")
	elseif activated_by.mob then
		tt = tt .. "\n" .. S("Pushable by mobs")
	elseif activated_by.player then
		tt = tt .. "\n" .. S("Pushable by players")
	end

	mesecon.register_node(":"..basename, {
		drawtype = "nodebox",
		inventory_image = image_i,
		wield_image = image_w,
		paramtype = "light",
		walkable = false,
		description = description,
		drop = basename .. "_off",
		on_timer = pp_on_timer,
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		sounds = sounds,
		is_ground_content = false,
		pressureplate_basename = basename,
		pressureplate_activated_by = activated_by,
		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
	},{
		node_box = pp_box_off,
		selection_box = pp_box_off,
		groups = groups_off,
		tiles = textures_off,

		mesecons = {receptor = { state = mesecon.state.off, rules = mesecon.rules.pplate }},
		_doc_items_longdesc = longdesc,
		_tt_help = tt,
	},{
		node_box = pp_box_on,
		selection_box = pp_box_on,
		groups = groups_on,
		tiles = textures_on,
		description = "",

		mesecons = {receptor = { state = mesecon.state.on, rules = mesecon.rules.pplate }},
		_doc_items_create_entry = false,
	})

	minetest.register_craft({
		output = basename .. "_off",
		recipe = recipe,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", basename .. "_off", "nodes", basename .. "_on")
	end
end

mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_stone",
	S("Stone Pressure Plate"),
	{"default_stone.png"},
	{"default_stone.png"},
	"default_stone.png",
	nil,
	{{"mcl_core:stone", "mcl_core:stone"}},
	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1},
	{ player = true, mob = true },
	S("A stone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."))

mesecon.register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_polished_blackstone",
	S("Polished Blackstone Pressure Plate"),
	{"mcl_blackstone_polished.png"},
	{"mcl_blackstone_polished.png"},
	"mcl_blackstone_polished.png",
	nil,
	{{"mcl_blackstone:blackstone_polished", "mcl_blackstone:blackstone_polished"}},
	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1},
	{ player = true, mob = true },
	S("A polished blackstone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."))


