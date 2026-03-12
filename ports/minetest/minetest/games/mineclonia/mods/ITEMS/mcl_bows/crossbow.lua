local S = core.get_translator(core.get_current_modname())

-- local arrows = {
-- 	["mcl_bows:arrow"] = "mcl_bows:arrow_entity",
-- }

local GRAVITY = 9.81
local BOW_DURABILITY = 385

-- Charging time in microseconds
local _BOW_CHARGE_TIME_HALF = 350000 -- bow level 1
local _BOW_CHARGE_TIME_FULL = 900000 -- bow level 2 (full charge)

local BOW_CHARGE_TIME_HALF = 350000 -- bow level 1
local BOW_CHARGE_TIME_FULL = 900000 -- bow level 2 (full charge)
mcl_bows.CROSSBOW_CHARGE_TIME_HALF = BOW_CHARGE_TIME_HALF / 1e+6
mcl_bows.CROSSBOW_CHARGE_TIME_FULL = BOW_CHARGE_TIME_FULL / 1e+6

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_CROSSBOW_SPEED = tonumber(core.settings:get("movement_speed_crouch")) / tonumber(core.settings:get("movement_speed_walk"))

local BOW_MAX_SPEED = 3.15 * 20

local function play_load_sound(id, object)
	core.sound_play({name = "mcl_bows_crossbow_drawback_"..id, gain=0.3}, {object=object, max_hear_distance=16}, true)
end

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from core.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

function shoot_arrow_crossbow_1(arrow_item, pos, dir, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
	local obj = core.add_entity({x=pos.x,y=pos.y,z=pos.z}, ItemStack(arrow_item):get_name().."_entity")
	if not obj or not obj:get_pos() then return end
	if damage == nil then
		damage = 2
	end
	if crossbow_stack then
		local enchantments = mcl_enchanting.get_enchantments(crossbow_stack)
		if enchantments.piercing then
			obj:get_luaentity()._piercing = 1 * enchantments.piercing
		else
			obj:get_luaentity()._piercing = 0
		end
	end
	obj:set_velocity({x=dir.x*speed, y=dir.y*speed, z=dir.z*speed})
	obj:set_acceleration({x=0, y=-GRAVITY, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._source_object = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._collectable = collectable
	le._itemstring = arrow_item
	if shooter and shooter:is_player() then
		if le.player == "" then
			le.player = shooter
		end
		le.node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local function get_pitch (dir)
	return math.atan2 (-dir.y, math.sqrt (dir.x * dir.x + dir.z * dir.z))
end

function mcl_bows.shoot_arrow_crossbow (arrow_item, pos, dir, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
	local has_multishot_enchantment
		= crossbow_stack and mcl_enchanting.has_enchantment (crossbow_stack, "multishot")
	core.sound_play({name="mcl_bows_crossbow_shoot", gain=0.035}, {pos=pos, max_hear_distance=32}, true)
	local inaccuracy = (shooter and shooter:is_player() and 1) or nil -- No dispenser; that use mcl_bows.shoot_arrow
	dir = mcl_bows.add_inaccuracy(dir, inaccuracy)
	if has_multishot_enchantment then
		-- calculate rotation by 10 degrees 'left' and 'right' of facing direction
		local pitch = get_pitch (dir)
		local pitch_c = math.cos(pitch)
		local pitch_s = math.sin(pitch)
		local yaw_c = math.cos(yaw + math.pi / 2)
		local yaw_s = math.sin(yaw + math.pi / 2)

		local rot_left =  {x =   yaw_c * pitch_s * math.pi / 18, y =   pitch_c * math.pi / 18, z =   yaw_s * pitch_s * math.pi / 18}
		local rot_right = {x = - yaw_c * pitch_s * math.pi / 18, y = - pitch_c * math.pi / 18, z = - yaw_s * pitch_s * math.pi / 18}
		local dir_left = vector.rotate(dir, rot_left)
		local dir_right = vector.rotate(dir, rot_right)

		shoot_arrow_crossbow_1 (arrow_item, pos, {x=dir_left.x, y=dir_left.y, z=dir_left.z}, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
		shoot_arrow_crossbow_1 (arrow_item, pos, {x=dir_right.x, y=dir_right.y, z=dir_right.z}, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
		shoot_arrow_crossbow_1 (arrow_item, pos, dir, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
	else
		shoot_arrow_crossbow_1 (arrow_item, pos, dir, yaw, shooter, speed, damage, is_critical, crossbow_stack, collectable)
	end
end

local function get_arrow(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and core.get_item_group(it:get_name(), "ammo_crossbow") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

function mcl_bows.get_arrow_stack_for_crossbow (player)
	return get_arrow (player)
end

local function player_shoot_arrow(wielditem, player, is_critical)
	local arrow_itemstring = wielditem:get_meta():get("arrow")
	local arrow_item_name = ItemStack(arrow_itemstring):get_name()
	if not arrow_itemstring or core.get_item_group(arrow_item_name, "ammo_crossbow") == 0 then
		return false
	end

	local playerpos = mcl_util.target_eye_pos (player)
	playerpos.y = playerpos.y - 0.1
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	mcl_bows.shoot_arrow_crossbow (arrow_itemstring, playerpos, dir, yaw, player, BOW_MAX_SPEED, nil, is_critical, player:get_wielded_item(), true)
	return true
end

-- Bow item, uncharged state
core.register_tool("mcl_bows:crossbow", {
	description = S("Crossbow"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Crossbows are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the crossbow, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button (or zoom key) to charge, release to load an arrow into the chamber, then to shoot press left mouse."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "mcl_bows_crossbow.png",
	wield_scale = mcl_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() end,
	on_place = function(itemstack, player, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	touch_interaction = "short_dig_long_place",
	groups = {weapon = 1, weapon_ranged = 1, crossbow = 1, enchantability = 1, offhand_item = 1},
	_mcl_uses = 326,
	_mcl_burntime = 15
})

core.register_tool("mcl_bows:crossbow_loaded", {
	description = S("Crossbow"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Crossbows are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the crossbow, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button to charge, release to load an arrow into the chamber, then to shoot press left mouse."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "mcl_bows_crossbow_3.png",
	wield_scale = mcl_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() end,
	on_place = function(itemstack, player, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	touch_interaction = "short_dig_long_place",
	groups = {weapon = 2, weapon_ranged = 1, crossbow = 5, enchantability = 1, not_in_creative_inventory = 1, offhand_item = 1},
	_mcl_uses = 326,
	_mcl_burntime = 15
})

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local function reset_bows(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == "mcl_bows:crossbow" or stack:get_name() == "mcl_bows:crossbow_enchanted" then
			stack:get_meta():set_string("active", "")
		elseif stack:get_name()=="mcl_bows:crossbow_0" or stack:get_name()=="mcl_bows:crossbow_1" or stack:get_name()=="mcl_bows:crossbow_2" then
			stack:set_name("mcl_bows:crossbow")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		elseif stack:get_name()=="mcl_bows:crossbow_0_enchanted" or stack:get_name()=="mcl_bows:crossbow_1_enchanted" or stack:get_name()=="mcl_bows:crossbow_2_enchanted" then
			stack:set_name("mcl_bows:crossbow_enchanted")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local function reset_bow_state(player, also_reset_bows)
	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil

	playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_crossbow")
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Bow in charging state
for level=0, 2 do
	core.register_tool("mcl_bows:crossbow_"..level, {
		description = S("Crossbow"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_bows_crossbow_"..level..".png",
		wield_scale = mcl_vars.tool_wield_scale,
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, enchantability=1, crossbow=2+level},
		-- Trick to disable digging as well
		on_use = function() end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			if mcl_enchanting.is_enchanted(itemstack:get_name()) then
				itemstack:set_name("mcl_bows:crossbow_enchanted")
			else
				itemstack:set_name("mcl_bows:crossbow")
			end
			core.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack)
			return itemstack
		end,
		touch_interaction = "short_dig_long_place",
		_mcl_uses = 385,
	})
end

local function get_crossbow_charge_time (wielditem)
	local enchantments = mcl_enchanting.get_enchantments (wielditem)
	if enchantments.quick_charge then
		return _BOW_CHARGE_TIME_FULL
			- (enchantments.quick_charge * 0.13 * 1.0e+6)
	end
	return _BOW_CHARGE_TIME_FULL
end

function mcl_bows.crossbow_charge_time_multiplier (quick_charge)
	local time = _BOW_CHARGE_TIME_FULL - (quick_charge * 0.13 * 1.0e+6)
	return math.max (0.0, time / _BOW_CHARGE_TIME_FULL)
end

function mcl_bows.load_crossbow (player, wielditem, usetime)
	local arrow_stack, arrow_stack_id = get_arrow(player)
	local arrow_itemstring

	if not arrow_stack or usetime < get_crossbow_charge_time (wielditem) then
		return
	end

	if core.is_creative_enabled(player:get_player_name()) then
		if arrow_stack then
			arrow_itemstring = arrow_stack:get_name()
		else
			arrow_itemstring = "mcl_bows:arrow"
		end
	else
		arrow_itemstring = arrow_stack:get_name()
		arrow_stack:take_item()
		player:get_inventory():set_stack("main", arrow_stack_id, arrow_stack)
	end

	wielditem:get_meta():set_string("arrow", arrow_itemstring)

	if not mcl_enchanting.is_enchanted (wielditem:get_name ()) then
		wielditem:set_name("mcl_bows:crossbow_loaded")
	else
		wielditem:set_name("mcl_bows:crossbow_loaded_enchanted")
	end
	player:set_wielded_item(wielditem)
end

local function fully_drawn(name)
	return core.get_item_group(name, "crossbow") == 4
end

controls.register_on_release(function(player, key)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	if key~="RMB" and key~="zoom" then return end
	--local inv = core.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	local creative = core.is_creative_enabled(player:get_player_name())
	local arrow_stack, arrow_stack_id = get_arrow(player)

	if fully_drawn(wielditem:get_name()) and (creative or arrow_stack) then
		local arrow_itemstring
		if core.is_creative_enabled(player:get_player_name()) then
			if arrow_stack then
				arrow_itemstring = arrow_stack:to_string()
			else
				arrow_itemstring = "mcl_bows:arrow"
			end
		else
			arrow_itemstring = arrow_stack:to_string()
			arrow_stack:take_item()
			player:get_inventory():set_stack("main", arrow_stack_id, arrow_stack)
		end

		arrow_itemstring = ItemStack(arrow_itemstring)
		arrow_itemstring:set_count(1)
		arrow_itemstring = arrow_itemstring:to_string()

		wielditem:get_meta():set_string("arrow", arrow_itemstring)

		if wielditem:get_name()=="mcl_bows:crossbow_2" then
			wielditem:set_name("mcl_bows:crossbow_loaded")
		else
			wielditem:set_name("mcl_bows:crossbow_loaded_enchanted")
		end
		player:set_wielded_item(wielditem)
		core.sound_play({name="mcl_bows_crossbow_load", gain=0.3}, {object=player, max_hear_distance=16}, true)
	else
		reset_bow_state(player, true)
	end
end)

controls.register_on_press(function(player, key)
	if key~="LMB" then return end
		local wielditem = player:get_wielded_item()
		if wielditem:get_name()=="mcl_bows:crossbow_loaded" or wielditem:get_name()=="mcl_bows:crossbow_loaded_enchanted" then
		local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
		local has_shot = player_shoot_arrow (wielditem, player, true)

		if enchanted then
			wielditem:set_name("mcl_bows:crossbow_enchanted")
		else
			wielditem:set_name("mcl_bows:crossbow")
		end

		if has_shot and not core.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			local unbreaking = mcl_enchanting.get_enchantment(wielditem, "unbreaking")
			local multishot = mcl_enchanting.get_enchantment(wielditem, "multishot")
			if unbreaking > 0 then
				durability = durability * (unbreaking + 1)
			end
			if multishot then
				durability = durability / 3
			end
			wielditem:add_wear(65535/durability)
		end
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
	end
end)

controls.register_on_hold(function(player, key)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	local name = player:get_player_name()
	local creative = core.is_creative_enabled(name)
	if key ~= "RMB" and key ~= "zoom" then
		return
	end
	--local inv = core.get_inventory({type="player", name=name})
	local wielditem = player:get_wielded_item()
	local enchantments = mcl_enchanting.get_enchantments(wielditem)
	if enchantments.quick_charge then
		BOW_CHARGE_TIME_HALF = _BOW_CHARGE_TIME_HALF - (enchantments.quick_charge * 0.13 * 1000000 * .5)
		BOW_CHARGE_TIME_FULL = _BOW_CHARGE_TIME_FULL - (enchantments.quick_charge * 0.13 * 1000000)
	else
		BOW_CHARGE_TIME_HALF = _BOW_CHARGE_TIME_HALF
		BOW_CHARGE_TIME_FULL = _BOW_CHARGE_TIME_FULL
	end

	if bow_load[name] == nil
		and (wielditem:get_name()=="mcl_bows:crossbow" or wielditem:get_name()=="mcl_bows:crossbow_enchanted")
		and (wielditem:get_meta():get("active") or key=="zoom") and (creative or get_arrow(player)) then
			local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
			if enchanted then
				wielditem:set_name("mcl_bows:crossbow_0_enchanted")
				play_load_sound(0, player)
			else
				wielditem:set_name("mcl_bows:crossbow_0")
				play_load_sound(0, player)
			end
			player:set_wielded_item(wielditem)
			-- Slow player down when using bow
			playerphysics.add_physics_factor(player, "speed", "mcl_bows:use_crossbow", PLAYER_USE_CROSSBOW_SPEED)
			bow_load[name] = core.get_us_time()
			bow_index[name] = player:get_wield_index()
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				if wielditem:get_name() == "mcl_bows:crossbow_0" and core.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("mcl_bows:crossbow_1")
					play_load_sound(1, player)
				elseif wielditem:get_name() == "mcl_bows:crossbow_0_enchanted" and core.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("mcl_bows:crossbow_1_enchanted")
					play_load_sound(1, player)
				elseif wielditem:get_name() == "mcl_bows:crossbow_1" and core.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("mcl_bows:crossbow_2")
					play_load_sound(2, player)
				elseif wielditem:get_name() == "mcl_bows:crossbow_1_enchanted" and core.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("mcl_bows:crossbow_2_enchanted")
					play_load_sound(2, player)
				end
			else
				if wielditem:get_name() == "mcl_bows:crossbow_0" or wielditem:get_name() == "mcl_bows:crossbow_1" or wielditem:get_name() == "mcl_bows:crossbow_2" then
					wielditem:set_name("mcl_bows:crossbow")
					play_load_sound(1, player)
				elseif wielditem:get_name() == "mcl_bows:crossbow_0_enchanted" or wielditem:get_name() == "mcl_bows:crossbow_1_enchanted" or wielditem:get_name() == "mcl_bows:crossbow_2_enchanted" then
					wielditem:set_name("mcl_bows:crossbow_enchanted")
					play_load_sound(1, player)
				end
			end
			player:set_wielded_item(wielditem)
		else
			reset_bow_state(player, true)
		end
	end
end)

mcl_player.register_globalstep(function(player)
	if not mcl_serverplayer.is_csm_capable (player) then
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		--local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~="mcl_bows:crossbow_0" and wielditem:get_name()~="mcl_bows:crossbow_1" and wielditem:get_name()~="mcl_bows:crossbow_2" and wielditem:get_name()~="mcl_bows:crossbow_0_enchanted" and wielditem:get_name()~="mcl_bows:crossbow_1_enchanted" and wielditem:get_name()~="mcl_bows:crossbow_2_enchanted") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

core.register_on_joinplayer(function(player)
	reset_bows(player)
end)

core.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)

core.register_craft({
	output = "mcl_bows:crossbow",
	recipe = {
		{"mcl_core:stick", "mcl_core:iron_ingot", "mcl_core:stick"},
		{"mcl_mobitems:string", "mcl_bows:arrow", "mcl_mobitems:string"},
		{"", "mcl_core:stick", ""},
	}
})

doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_0")
doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_1")
doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_2")
