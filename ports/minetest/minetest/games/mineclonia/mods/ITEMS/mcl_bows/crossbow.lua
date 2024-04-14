local S = minetest.get_translator(minetest.get_current_modname())

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

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_CROSSBOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

-- TODO: Use Minecraft speed (ca. 53 m/s)
-- Currently nerfed because at full speed the arrow would easily get out of the range of the loaded map.
local BOW_MAX_SPEED = 68

local function play_load_sound(id, pos)
	minetest.sound_play("mcl_bows_crossbow_drawback_"..id, {pos=pos, max_hear_distance=12}, true)
end

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

function mcl_bows.shoot_arrow_crossbow(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, crossbow_stack, collectable)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item.."_entity")
	if not obj or not obj:get_pos() then return end
	if power == nil then
		power = BOW_MAX_SPEED --19
	end
	if damage == nil then
		damage = 3
	end
	if crossbow_stack then
		local enchantments = mcl_enchanting.get_enchantments(crossbow_stack)
		if enchantments.piercing then
			obj:get_luaentity()._piercing = 1 * enchantments.piercing
		else
			obj:get_luaentity()._piercing = 0
		end
	end
	obj:set_velocity({x=dir.x*power, y=dir.y*power, z=dir.z*power})
	obj:set_acceleration({x=0, y=-GRAVITY, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._source_object = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._collectable = collectable
	minetest.sound_play("mcl_bows_crossbow_shoot", {pos=pos, max_hear_distance=16}, true)
	if shooter and shooter:is_player() then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local function get_arrow(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "ammo_crossbow") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

local function player_shoot_arrow(wielditem, player, power, damage, is_critical)
	local has_multishot_enchantment = mcl_enchanting.has_enchantment(player:get_wielded_item(), "multishot")
	local arrow_itemstring = wielditem:get_meta():get("arrow")

	if not arrow_itemstring or minetest.get_item_group(arrow_itemstring, "ammo_crossbow") == 0 then
		return false
	end

	local playerpos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	if has_multishot_enchantment then
		-- calculate rotation by 10 degrees 'left' and 'right' of facing direction
		local pitch = player:get_look_vertical()
		local pitch_c = math.cos(pitch)
		local pitch_s = math.sin(pitch)
		local yaw_c = math.cos(yaw + math.pi / 2)
		local yaw_s = math.sin(yaw + math.pi / 2)

		local rot_left =  {x =   yaw_c * pitch_s * math.pi / 18, y =   pitch_c * math.pi / 18, z =   yaw_s * pitch_s * math.pi / 18}
		local rot_right = {x = - yaw_c * pitch_s * math.pi / 18, y = - pitch_c * math.pi / 18, z = - yaw_s * pitch_s * math.pi / 18}
		local dir_left = vector.rotate(dir, rot_left)
		local dir_right = vector.rotate(dir, rot_right)

		mcl_bows.shoot_arrow_crossbow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, {x=dir_left.x, y=dir_left.y, z=dir_left.z}, yaw, player, power, damage, is_critical, player:get_wielded_item(), false)
		mcl_bows.shoot_arrow_crossbow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, {x=dir_right.x, y=dir_right.y, z=dir_right.z}, yaw, player, power, damage, is_critical, player:get_wielded_item(), false)
		mcl_bows.shoot_arrow_crossbow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), true)
	else
		mcl_bows.shoot_arrow_crossbow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), true)
	end
	return true
end

-- Bow item, uncharged state
minetest.register_tool("mcl_bows:crossbow", {
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
	on_use = function() return end,
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
	groups = {weapon=1,weapon_ranged=1,crossbow=1,enchantability=1},
	_mcl_uses = 326,
})

minetest.register_tool("mcl_bows:crossbow_loaded", {
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
	on_use = function() return end,
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
	groups = {weapon=1,weapon_ranged=1,crossbow=5,enchantability=1,not_in_creative_inventory=1},
	_mcl_uses = 326,
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
	if minetest.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_crossbow")
	end
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Bow in charging state
for level=0, 2 do
	minetest.register_tool("mcl_bows:crossbow_"..level, {
		description = S("Crossbow"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_bows_crossbow_"..level..".png",
		wield_scale = mcl_vars.tool_wield_scale,
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, enchantability=1, crossbow=2+level},
		-- Trick to disable digging as well
		on_use = function() return end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			if mcl_enchanting.is_enchanted(itemstack:get_name()) then
				itemstack:set_name("mcl_bows:crossbow_enchanted")
			else
				itemstack:set_name("mcl_bows:crossbow")
			end
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack)
			return itemstack
		end,
		_mcl_uses = 385,
	})
end


controls.register_on_release(function(player, key, time)
	if key~="RMB" and key~="zoom" then return end
	--local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if wielditem:get_name()=="mcl_bows:crossbow_2" and get_arrow(player) or wielditem:get_name()=="mcl_bows:crossbow_2" and minetest.is_creative_enabled(player:get_player_name()) or wielditem:get_name()=="mcl_bows:crossbow_2_enchanted" and get_arrow(player) or wielditem:get_name()=="mcl_bows:crossbow_2_enchanted" and minetest.is_creative_enabled(player:get_player_name()) then
		local arrow_stack, arrow_stack_id = get_arrow(player)
		local arrow_itemstring

		if minetest.is_creative_enabled(player:get_player_name()) then
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

		if wielditem:get_name()=="mcl_bows:crossbow_2" then
			wielditem:set_name("mcl_bows:crossbow_loaded")
		else
			wielditem:set_name("mcl_bows:crossbow_loaded_enchanted")
		end
		player:set_wielded_item(wielditem)
		minetest.sound_play("mcl_bows_crossbow_load", {pos=player:get_pos(), max_hear_distance=16}, true)
	else
		reset_bow_state(player, true)
	end
end)

controls.register_on_press(function(player, key, time)
	if key~="LMB" then return end
		local wielditem = player:get_wielded_item()
		if wielditem:get_name()=="mcl_bows:crossbow_loaded" or wielditem:get_name()=="mcl_bows:crossbow_loaded_enchanted" then
		local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
		local speed, damage
		local p_load = bow_load[player:get_player_name()]
		-- Type sanity check
		if type(p_load) ~= "number" then
			-- In case something goes wrong ...
			-- Just assume minimum charge.
			minetest.log("warning", "[mcl_bows] Player "..player:get_player_name().." fires arrow with non-numeric bow_load!")
		end

		-- Calculate damage and speed
		-- Fully charged
		local is_critical = false
		speed = BOW_MAX_SPEED
		local r = math.random(1,5)
		if r == 1 then
			-- 20% chance for critical hit
			damage = 10
			is_critical = true
		else
			damage = 9
		end

		local has_shot = player_shoot_arrow(wielditem, player, speed, damage, is_critical)

		if enchanted then
			wielditem:set_name("mcl_bows:crossbow_enchanted")
		else
			wielditem:set_name("mcl_bows:crossbow")
		end

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
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

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if key ~= "RMB" and key ~= "zoom" then
		return
	end
	--local inv = minetest.get_inventory({type="player", name=name})
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
				play_load_sound(0, player:get_pos())
			else
				wielditem:set_name("mcl_bows:crossbow_0")
				play_load_sound(0, player:get_pos())
			end
			player:set_wielded_item(wielditem)
			if minetest.get_modpath("playerphysics") then
				-- Slow player down when using bow
				playerphysics.add_physics_factor(player, "speed", "mcl_bows:use_crossbow", PLAYER_USE_CROSSBOW_SPEED)
			end
			bow_load[name] = minetest.get_us_time()
			bow_index[name] = player:get_wield_index()
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				if wielditem:get_name() == "mcl_bows:crossbow_0" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("mcl_bows:crossbow_1")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == "mcl_bows:crossbow_0_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("mcl_bows:crossbow_1_enchanted")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == "mcl_bows:crossbow_1" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("mcl_bows:crossbow_2")
					play_load_sound(2, player:get_pos())
				elseif wielditem:get_name() == "mcl_bows:crossbow_1_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("mcl_bows:crossbow_2_enchanted")
					play_load_sound(2, player:get_pos())
				end
			else
				if wielditem:get_name() == "mcl_bows:crossbow_0" or wielditem:get_name() == "mcl_bows:crossbow_1" or wielditem:get_name() == "mcl_bows:crossbow_2" then
					wielditem:set_name("mcl_bows:crossbow")
					play_load_sound(1, player:get_pos())
				elseif wielditem:get_name() == "mcl_bows:crossbow_0_enchanted" or wielditem:get_name() == "mcl_bows:crossbow_1_enchanted" or wielditem:get_name() == "mcl_bows:crossbow_2_enchanted" then
					wielditem:set_name("mcl_bows:crossbow_enchanted")
					play_load_sound(1, player:get_pos())
				end
			end
			player:set_wielded_item(wielditem)
		else
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		--local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~="mcl_bows:crossbow_0" and wielditem:get_name()~="mcl_bows:crossbow_1" and wielditem:get_name()~="mcl_bows:crossbow_2" and wielditem:get_name()~="mcl_bows:crossbow_0_enchanted" and wielditem:get_name()~="mcl_bows:crossbow_1_enchanted" and wielditem:get_name()~="mcl_bows:crossbow_2_enchanted") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		output = "mcl_bows:crossbow",
		recipe = {
			{"mcl_core:stick", "mcl_core:iron_ingot", "mcl_core:stick"},
			{"mcl_mobitems:string", "mcl_bows:arrow", "mcl_mobitems:string"},
			{"", "mcl_core:stick", ""},
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:crossbow",
	burntime = 15,
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_0")
	doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_1")
	doc.add_entry_alias("tools", "mcl_bows:crossbow", "tools", "mcl_bows:crossbow_2")
end
