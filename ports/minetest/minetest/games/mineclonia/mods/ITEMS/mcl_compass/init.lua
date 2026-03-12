local S = core.get_translator(core.get_current_modname())

mcl_compass = {}

-- Number of dynamic compass images (and items registered.)
local compass_frames = 32

-- The image/item that is craftable and shown in inventories.
local stereotype_frame = 18

-- random compass spinning tick in seconds.
-- Increase if there are performance problems.
local spin_timer_tick = 0.5
local spin_timer = 0

-- Initialize random compass frame for spinning compass.  It is updated in
-- the compass globalstep function.
local random_frame = math.random(0, compass_frames-1)

local function get_far_node(pos, itemstack) --code from minetest dev wiki: https://dev.luanti.org, some edits have been made to add a cooldown for force loads
	local node = core.get_node(pos)
	if node.name == "ignore" then
		local tstamp = tonumber(itemstack:get_meta():get_string("last_forceload"))
		if tstamp == nil then --this is only relevant for new lodestone compasses, the ones that have never performes a forceload yet
			itemstack:get_meta():set_string("last_forceload", tostring(os.time(os.date("!*t")))) ---@diagnostic disable-line: param-type-mismatch
			tstamp = tonumber(os.time(os.date("!*t"))) ---@diagnostic disable-line: param-type-mismatch
		end
		if tonumber(os.time(os.date("!*t"))) - tstamp > 180 then ---@diagnostic disable-line: param-type-mismatch
			itemstack:get_meta():set_string("last_forceload", tostring(os.time(os.date("!*t")))) ---@diagnostic disable-line: param-type-mismatch
			core.get_voxel_manip():read_from_map(pos, pos)
			node = core.get_node(pos)
		else
			node = {name="mcl_compass:lodestone"} --cooldown not over yet, pretend like there is something...
		end
	end
	return node
end

--- Get compass needle angle.
-- Returns the angle that the compass needle should point at expressed in
-- 360 degrees divided by the number of possible compass image frames..
--
-- pos: position of the compass;
-- target: position that the needle points towards;
-- dir: rotational direction of the compass.
--
local function get_compass_angle(pos, target, dir)
	local angle_north = math.deg(math.atan2(target.x - pos.x, target.z - pos.z))
	if angle_north < 0 then angle_north = angle_north + 360 end
	local angle_dir = -math.deg(dir)
	local angle_relative = (angle_north - angle_dir + 180) % 360
	return math.floor((angle_relative/11.25) + 0.5) % compass_frames
end
mcl_compass.get_compass_angle = get_compass_angle

--- Get compass image frame.
-- Returns the compass image frame with the needle direction matching the
-- compass' current position.
--
-- pos: position of the compass;
-- dir: rotational direction of the compass.
-- itemstack: the compass including its optional lodestone metadata.
--
local function get_compass_frame(pos, dir, itemstack)
	if not string.find(itemstack:get_name(), "_lodestone") then -- normal compass
		-- Compasses only work in the overworld
		if mcl_worlds.compass_works(pos) then
			local spawn_pos = core.setting_get_pos("static_spawnpoint")
				or vector.new(0, 0, 0)
			return get_compass_angle(pos, spawn_pos, dir)
		else
			return random_frame
		end
	else -- lodestone compass
		local lpos_str = itemstack:get_meta():get_string("pointsto")
		local lpos = core.string_to_pos(lpos_str)
		if not lpos then
			core.log("warning", "mcl_compass: invalid lodestone position!")
			return random_frame
		end
		local _, l_dim = mcl_worlds.y_to_layer(lpos.y)
		local _, p_dim = mcl_worlds.y_to_layer(pos.y)
		-- compass and lodestone must be in the same dimension
		if l_dim == p_dim then
			--check if lodestone still exists
			if get_far_node(lpos, itemstack).name == "mcl_compass:lodestone" then
				return get_compass_angle(pos, lpos, dir)
			else -- lodestone got destroyed
				return random_frame
			end
		else
			return random_frame
		end
	end
end

-- Export stereotype item for other mods to use

--- Get partial compass itemname.
-- Returns partial itemname of a compass with needle direction matching compass position.
-- Legacy compatibility function for mods using older api.
--
function mcl_compass.get_compass_image(pos, dir)
	core.log("warning", "mcl_compass: deprecated function " ..
		"get_compass_image() called, use get_compass_itemname().")
	local itemstack = ItemStack(mcl_compass.stereotype)
	return get_compass_frame(pos, dir, itemstack)
end

--compat: compasses used to consist of many different items
function mcl_compass.get_compass_itemname() return "mcl_compass:compass" end
mcl_compass.stereotype = "mcl_compass:compass"


local function update_compass_img(stack, img)
	local m = stack:get_meta()
	m:set_string("inventory_image", img)
	m:set_string("wield_image", img)
	return stack
end

local function update_compass(stack, player)
	local pos = player:get_pos()
	local dir = player:get_look_horizontal()
	local def = stack:get_definition()
	return update_compass_img(stack, string.format(def._mcl_compass_img_fmt, get_compass_frame(pos, dir, stack)))
end

local function update_recovery_compass(stack, player)
	local meta = player:get_meta()
	local posstring =  meta:get_string("mcl_compass:recovery_pos")
	local targetpos = core.string_to_pos(posstring)
	if not targetpos then return stack end

	local def = stack:get_definition()
	local pos = player:get_pos()
	local dir = player:get_look_horizontal()

	local _, target_dim = mcl_worlds.y_to_layer(targetpos.y)
	local _, p_dim = mcl_worlds.y_to_layer(pos.y)
	local img
	if p_dim ~= target_dim then
		img = string.format(def._mcl_compass_img_fmt, random_frame)
	else
		img = string.format(def._mcl_compass_img_fmt, get_compass_angle(pos, targetpos, dir))
	end
	return update_compass_img(stack, img)
end

core.register_globalstep(function(dtime)
	spin_timer = spin_timer + dtime
	if spin_timer >= spin_timer_tick then
		random_frame = (random_frame + math.random(-1, 1)) % compass_frames
		spin_timer = 0
	end

	for player in mcl_util.connected_players() do
		local inv = player:get_inventory()
		for j, stack in pairs(inv:get_list("main")) do
			local compass_group = core.get_item_group(stack:get_name(), "compass")
			if compass_group > 0 then
				local def = stack:get_definition()
				if def._mcl_compass_update then
					inv:set_stack("main", j, def._mcl_compass_update(stack, player))
				end
			end
		end
	end
end)

--
-- Node and craftitem definitions
--
mcl_compass.registered_compasses = {}
function mcl_compass.register_compass(name, def)
	mcl_compass.registered_compasses[name] = def
	core.register_craftitem(":mcl_compass:"..(def.name or name), table.merge({}, def.overrides or {}, {
		groups = table.merge({tool = 1, disable_repair = 1, compass = 1}, def.overrides.groups)
	}))
	if def.name_fmt then
		for i = 0, compass_frames - 1 do
			core.register_alias(string.format(def.name_fmt, i), "mcl_compass:"..(def.name or name))
		end
	end
end

mcl_compass.register_compass("compass", {
	name = "compass",
	name_fmt = "mcl_compass:%d",
	overrides = {
		description = S("Compass"),
		_tt_help = S("Points to the world origin"),
		_doc_items_longdesc = S("Compasses are tools which point to the world origin (X=0, Z=0) or the spawn point in the Overworld."),
		_doc_items_usagehelp = S("A Compass always points to the world spawn point when the player is in the overworld.  In other dimensions, it spins randomly."),
		inventory_image = "mcl_compass_compass_01.png",
		wield_image = "mcl_compass_compass_01.png",
		groups = { compass = 1 },
		_mcl_compass_update = update_compass,
		_mcl_compass_img_fmt = "mcl_compass_compass_%02d.png",
	}
})
mcl_compass.register_compass("lodestone_compass", {
	name = "compass_lodestone",
	name_fmt = "mcl_compass:%d_lodestone",
	overrides = {
		description = S("Lodestone Compass"),
		_tt_help = S("Points to a lodestone"),
		_doc_items_longdesc = S("Lodestone compasses resemble regular compasses, but they point to a specific lodestone."),
		_doc_items_usagehelp = S("A Lodestone compass can be made from an ordinary compass by using it on a lodestone.  After becoming a lodestone compass, it always points to its linked lodestone, provided that they are in the same dimension.  If not in the same dimension, the lodestone compass spins randomly, similarly to a regular compass when outside the overworld.  A lodestone compass can be relinked with another lodestone."),
		inventory_image = "mcl_compass_compass_01.png^[colorize:purple:50",
		wield_image = "mcl_compass_compass_01.png^[colorize:purple:50",
		groups = { compass = 2, not_in_creative_inventory = 1 },
		_mcl_compass_update = update_compass,
		_mcl_compass_img_fmt = "mcl_compass_compass_%02d.png^[colorize:purple:50",
	}
})
mcl_compass.register_compass("recovery_compass", {
	name = "compass_recovery",
	name_fmt = "mcl_compass:%d_recovery",
	overrides = {
		description = S("Recovery Compass"),
		_tt_help = S("Points to your last death location"),
		_doc_items_longdesc = S("Recovery Compasses are compasses that point to your last death location"),
		_doc_items_usagehelp = S("Recovery Compasses always point to the location of your last death, in case you haven't died yet, it will just randomly spin around"),
		inventory_image = "mcl_compass_recovery_compass_01.png",
		wield_image = "mcl_compass_recovery_compass_01.png",
		groups = { compass = 3, rarity = 1 },
		_mcl_compass_update = update_recovery_compass,
		_mcl_compass_img_fmt = "mcl_compass_recovery_compass_%02d.png",
	}
})

core.register_craft({
	output = "mcl_compass:" .. stereotype_frame,
	recipe = {
		{"", "mcl_core:iron_ingot", ""},
		{"mcl_core:iron_ingot", "mcl_redstone:redstone", "mcl_core:iron_ingot"},
		{"", "mcl_core:iron_ingot", ""}
	}
})

core.register_craft({
	output = "mcl_compass:" .. random_frame .. "_recovery",
	recipe = {
		{"mcl_sculk:echo_shard","mcl_sculk:echo_shard", "mcl_sculk:echo_shard"},
		{"mcl_sculk:echo_shard", "mcl_compass:" .. stereotype_frame , "mcl_sculk:echo_shard"},
		{"mcl_sculk:echo_shard", "mcl_sculk:echo_shard", "mcl_sculk:echo_shard"}
	}
})

core.register_node("mcl_compass:lodestone",{
	description=S("Lodestone"),
	on_rightclick = function(pos, _, clicker, itemstack)
		if itemstack:get_name() == "mcl_compass:compass_lodestone" or itemstack:get_name() == "mcl_compass:compass" then
			itemstack:get_meta():set_string("pointsto", core.pos_to_string(pos))
			itemstack:set_name("mcl_compass:compass_lodestone")
			awards.unlock(clicker:get_player_name(), "mcl:countryLode")
		end
		return itemstack
	end,
	tiles = {
		"lodestone_top.png",
		"lodestone_bottom.png",
		"lodestone_side1.png",
		"lodestone_side2.png",
		"lodestone_side3.png",
		"lodestone_side4.png"
	},
	groups = {pickaxey=1, material_stone=1, deco_block=1, unmovable_by_piston = 1},
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults()
})

core.register_craft({
	output = "mcl_compass:lodestone",
	recipe = {
		{"mcl_core:stonebrickcarved","mcl_core:stonebrickcarved","mcl_core:stonebrickcarved"},
		{"mcl_core:stonebrickcarved", "mcl_core:iron_ingot", "mcl_core:stonebrickcarved"},
		{"mcl_core:stonebrickcarved", "mcl_core:stonebrickcarved", "mcl_core:stonebrickcarved"}
	}
})

--set recovery meta
core.register_on_dieplayer(function(player)
	local meta = player:get_meta();
	meta:set_string("mcl_compass:recovery_pos",core.pos_to_string(player:get_pos()))
end)
