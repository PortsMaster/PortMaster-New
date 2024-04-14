local S = minetest.get_translator(minetest.get_current_modname())

-- Taken from https://minecraft.gamepedia.com/Enchanting

local function increase_damage(damage_group, factor)
	return function(itemstack, level)
		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.damage_groups[damage_group] = (tool_capabilities.damage_groups[damage_group] or 0) + level * factor
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end
end

-- implemented via on_enchant and additions in mobs_mc; Slowness IV part unimplemented
mcl_enchanting.enchantments.bane_of_arthropods = {
	name = S("Bane of Arthropods"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {smite = true, sharpness = true},
	weight = 5,
	description = S("Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites)."),
	curse = false,
	on_enchant = increase_damage("anthropod", 2.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 25}, {13, 33}, {21, 41}, {29, 49}, {37, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.channeling = {
	name = S("Channeling"),
	max_level = 1,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {riptide = true},
	weight = 1,
	description = S("Channels a bolt of lightning toward a target. Works only during thunderstorms and if target is unobstructed with opaque blocks."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}]]--

-- implemented in mcl_death_drop
mcl_enchanting.enchantments.curse_of_vanishing = {
	name = S("Curse of Vanishing"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Item destroyed on death."),
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented below
mcl_enchanting.enchantments.depth_strider = {
	name = S("Depth Strider"),
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = S("Increases underwater movement speed."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

mcl_player.register_globalstep_slow(function(player, dtime)
	if minetest.get_item_group(mcl_player.players[player].nodes.feet, "liquid") ~= 0 and mcl_enchanting.get_enchantment(player:get_inventory():get_stack("armor", 5), "depth_strider") then
		local boots = player:get_inventory():get_stack("armor", 5)
		local depth_strider = mcl_enchanting.get_enchantment(boots, "depth_strider")

		if depth_strider > 0 then
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:depth_strider", (depth_strider / 3) + 0.75)
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:depth_strider")
	end
end)

-- implemented via on_enchant
mcl_enchanting.enchantments.efficiency = {
	name = S("Efficiency"),
	max_level = 5,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = S("Increases mining speed."),
	curse = false,
	on_enchant = function()
		-- Updating digging speed is handled by update_groupcaps which
		-- is called from load_enchantments.
	end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 61}, {11, 71}, {21, 81}, {31, 91}, {41, 101}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_mobs and via register_on_punchplayer callback
mcl_enchanting.enchantments.fire_aspect = {
	name = S("Fire Aspect"),
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Sets target on fire."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 61}, {30, 71}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter and hitter:is_player() then
		local wielditem = hitter:get_wielded_item()
		if wielditem then
			local fire_aspect_level = mcl_enchanting.get_enchantment(wielditem, "fire_aspect")
			if fire_aspect_level > 0 then
				mcl_burning.set_on_fire(player, fire_aspect_level * 4)
			end
		end
	end
end)

mcl_enchanting.enchantments.flame = {
	name = S("Flame"),
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Arrows set target on fire."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.fortune = {
	name = S("Fortune"),
	max_level = 3,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {},
	disallow = {},
	incompatible = {silk_touch = true},
	weight = 2,
	description = S("Increases certain block drops."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented via walkover.register_global
mcl_enchanting.enchantments.frost_walker = {
	name = S("Frost Walker"),
	max_level = 2,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {depth_strider = true},
	weight = 2,
	description = S("Turns water beneath the player into frosted ice and prevents the damage from magma blocks."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

walkover.register_global(function(pos, _, player)
	local boots = player:get_inventory():get_stack("armor", 5)
	local frost_walker = mcl_enchanting.get_enchantment(boots, "frost_walker")
	if frost_walker <= 0 then
		return
	end
	local radius = frost_walker + 2
	local minp = {x = pos.x - radius, y = pos.y, z = pos.z - radius}
	local maxp = {x = pos.x + radius, y = pos.y, z = pos.z + radius}
	local positions = minetest.find_nodes_in_area_under_air(minp, maxp, "mcl_core:water_source")
	for _, p in ipairs(positions) do
		if vector.distance(pos, p) <= radius then
			minetest.set_node(p, {name = "mcl_core:frosted_ice_0"})
		end
	end
end)

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.impaling = {
	name = S("Impaling"),
	max_level = 5,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Trident deals additional damage to ocean mobs."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 21}, {9, 29}, {17, 37}, {25, 45}, {33, 53}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- implemented in mcl_bows
mcl_enchanting.enchantments.infinity = {
	name = S("Infinity"),
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {mending = true},
	weight = 1,
	description = S("Shooting consumes no regular arrows."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented via minetest.calculate_knockback
mcl_enchanting.enchantments.knockback = {
	name = S("Knockback"),
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 5,
	description = S("Increases knockback."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 61}, {25, 71}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local knockback = old_calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local luaentity
	local is_blocked = false
	if hitter then
		luaentity = hitter:get_luaentity()
		-- check if attack is blocked
		local shield_dot = vector.dot(player:get_look_dir(), vector.subtract(hitter:get_pos(), player:get_pos()))
		if mcl_shields.is_blocking(player) and shield_dot >= 0 then
			is_blocked = true
			knockback = knockback * 0.5
		end
	end
	if hitter and hitter:is_player() then
		local wielditem = hitter:get_wielded_item()
		--knockback = knockback + 3 * mcl_enchanting.get_enchantment(wielditem, "knockback")
		local enchant = mcl_enchanting.get_enchantment(wielditem, "knockback")
		knockback = knockback + 3.22 * enchant
		-- add vertical lift to knockback
		local v = player:get_velocity()
		local added_v = 0
		local invul = player:get_meta():get_int("mcl_damage:invulnerable")
		if v and v.y <= 0.01 and v.y >= -0.01 and invul == 0 and not is_blocked then
			local regular_v = 6.4
			local enchant_v = 7
			regular_v = regular_v * math.abs(dir.y - 1)
			enchant_v = enchant_v * math.abs(dir.y - 1)
			if enchant == 0 then
				player:add_velocity({x = 0, y = regular_v, z = 0})
				added_v = regular_v
			else
				player:add_velocity({x = 0, y = enchant_v, z = 0})
				added_v = enchant_v
			end
			-- add minimum knockback
			if knockback <= 1.5 then
				knockback = knockback + 4.875
			elseif knockback <= 6.19 then
				knockback = knockback + 0.609375
			end
		end
		-- counteract forward velocity when hit
		local self_dir_dot = (v.x * dir.x) + (v.z * dir.z)
		if self_dir_dot < 0 then
			player:add_velocity({x = v.x * -1, y = 0, z = v.z * -1})
		end
		-- add player velocity to knockback
		local h_name = hitter:get_player_name()
		local hv = hitter:get_velocity()
		local dir_dot = (hv.x * dir.x) + (hv.z * dir.z)
		local hitter_mag = math.sqrt((hv.x * hv.x) + (hv.z * hv.z))
		if dir_dot > 0 and mcl_sprint.is_sprinting(h_name) then
			knockback = knockback + hitter_mag * 0.6875
		elseif dir_dot > 0 then
			knockback = knockback + hitter_mag * 0.515625
		end
		-- reduce floatiness
		if added_v ~= 0 then
			minetest.after(0.25, function()
				player:add_velocity({x = 0, y = (v.y + added_v) * -0.375, z = 0})
			end)
		end
		-- reduce knockback when moving towards hitter while attacking
		local self_dir_dot = (v.x * dir.x) + (v.z * dir.z)
		local control = player:get_player_control()
		if self_dir_dot < -4.3 and control.up and control.LMB then
			knockback = knockback * 0.6
		end
		-- remove knockback if invulnerable
		if invul > 0 then
			knockback = 0
		end
		-- remove knockback if attack is blocked
		if is_blocked then
			knockback = 0
		end
	elseif hitter and hitter:is_player() and distance > 3 then
		knockback = 0
	elseif luaentity and luaentity._knockback then
		local kb = knockback + luaentity._knockback / 4
		local punch_dir = dir
		punch_dir.y = 0
		punch_dir = vector.normalize(punch_dir) * kb
		punch_dir.y = 4
		if not is_blocked then
			player:add_velocity(punch_dir)
		end
		knockback = 0
	end
	return knockback
end

-- implemented in mcl_mobs and mobs_mc
mcl_enchanting.enchantments.looting = {
	name = S("Looting"),
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases mob loot."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.loyalty = {
	name = S("Loyalty"),
	max_level = 3,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {riptide = true},
	weight = 5,
	description = S("Trident returns after being thrown. Higher levels reduce return time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 50}, {19, 50}, {26, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}]]--

-- implemented in mcl_fishing
mcl_enchanting.enchantments.luck_of_the_sea = {
	name = S("Luck of the Sea"),
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases rate of good loot (enchanting books, etc.)"),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_fishing
mcl_enchanting.enchantments.lure = {
	name = S("Lure"),
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Decreases time until rod catches something."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_experience
mcl_enchanting.enchantments.mending = {
	name = S("Mending"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {},
	incompatible = {infinity = true},
	weight = 2,
	description = S("Repair the item while gaining XP orbs."),
	curse = false,
	on_enchant = function() end,
	requires_tool = true,
	treasure = true,
	power_range_table = {{25, 75}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

mcl_experience.register_on_add_xp(function(player, xp)
	local inv = player:get_inventory()

	local candidates = {
		{list = "main", index = player:get_wield_index()},
		{list = "armor", index = 2},
		{list = "armor", index = 3},
		{list = "armor", index = 4},
		{list = "armor", index = 5},
		{list = "offhand", index = 1},
	}

	local final_candidates = {}
	for _, can in ipairs(candidates) do
		local stack = inv:get_stack(can.list, can.index)
		local wear = stack:get_wear()
		if mcl_enchanting.has_enchantment(stack, "mending") and wear > 0 then
			can.stack = stack
			can.wear = wear
			table.insert(final_candidates, can)
		end
	end

	if #final_candidates > 0 then
		local can = final_candidates[math.random(#final_candidates)]
		local stack, list, index, wear = can.stack, can.list, can.index, can.wear
		local uses = mcl_util.calculate_durability(stack)
		local multiplier = 2 * 65535 / uses
		local repair = xp * multiplier
		local new_wear = wear - repair

		if new_wear < 0 then
			xp = math.floor(-new_wear / multiplier + 0.5)
			new_wear = 0
		else
			xp = 0
		end

		stack:set_wear(math.floor(new_wear))
		inv:set_stack(list, index, stack)
	end

	return xp
end, 0)

mcl_enchanting.enchantments.multishot = {
	name = S("Multishot"),
	max_level = 1,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {piercing = true},
	weight = 2,
	description = S("Shoot 3 arrows at the cost of one."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
mcl_enchanting.enchantments.piercing = {
	name = S("Piercing"),
	max_level = 4,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {multishot = true},
	weight = 10,
	description = S("Arrows passes through multiple objects."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 50}, {11, 50}, {21, 50}, {31, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_bows
mcl_enchanting.enchantments.power = {
	name = S("Power"),
	max_level = 5,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = S("Increases arrow damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 16}, {11, 26}, {21, 36}, {31, 46}, {41, 56}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented via minetest.calculate_knockback (together with the Knockback enchantment) and mcl_bows
mcl_enchanting.enchantments.punch = {
	name = S("Punch"),
	max_level = 2,
	primary = {},
	secondary = {bow = true},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases arrow knockback."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 37}, {32, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
mcl_enchanting.enchantments.quick_charge = {
	name = S("Quick Charge"),
	max_level = 3,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 5,
	description = S("Decreases crossbow charging time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 50}, {32, 50}, {52, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- unimplemented
--[[mcl_enchanting.enchantments.respiration = {
	name = S("Respiration"),
	max_level = 3,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = S("Extends underwater breathing time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 40}, {20, 50}, {30, 60}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.riptide = {
	name = S("Riptide"),
	max_level = 3,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {channeling = true, loyalty = true},
	weight = 2,
	description = S("Trident launches player with itself when thrown. Works only in water or rain."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{17, 50}, {24, 50}, {31, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- implemented via on_enchant
mcl_enchanting.enchantments.sharpness = {
	name = S("Sharpness"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_arthropods = true, smite = true},
	weight = 5,
	description = S("Increases damage."),
	curse = false,
	on_enchant = increase_damage("fleshy", 0.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 21}, {12, 32}, {23, 43}, {34, 54}, {45, 65}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.silk_touch = {
	name = S("Silk Touch"),
	max_level = 1,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {fortune = true},
	weight = 1,
	description = S("Mined blocks drop themselves."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented via on_enchant and additions in mobs_mc
mcl_enchanting.enchantments.smite = {
	name = S("Smite"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_arthropods = true, sharpness = true},
	weight = 5,
	description = S("Increases damage to undead mobs."),
	curse = false,
	on_enchant = increase_damage("undead", 2.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 25}, {13, 33}, {21, 41}, {29, 49}, {37, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- implemented in mcl_playerplus
mcl_enchanting.enchantments.soul_speed = {
	name = S("Soul Speed"),
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = S("Increases walking speed on soul sand."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.sweeping_edge = {
	name = S("Sweeping Edge"),
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases sweeping attack damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 20}, {14, 29}, {23, 38}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- for tools & weapons implemented via on_enchant; for bows implemented in mcl_bows; for armor implemented in mcl_armor and mcl_tt; for fishing rods implemented in mcl_fishing
mcl_enchanting.enchantments.unbreaking = {
	name = S("Unbreaking"),
	max_level = 3,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, pickaxe = true, shovel = true, axe = true, hoe = true, sword = true, fishing_rod = true, bow = true, crossbow = true, },
	secondary = {tool = true},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 5,
	description = S("Increases item durability."),
	curse = false,
	on_enchant = function(itemstack, level)
		local name = itemstack:get_name()
		if not minetest.registered_tools[name].tool_capabilities then
			return
		end

		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.punch_attack_uses = tool_capabilities.punch_attack_uses * (1 + level)
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)

		-- Updating digging durability is handled by update_groupcaps
		-- which is called from load_enchantments.
	end,
	requires_tool = true,
	treasure = false,
	power_range_table = {{5, 61}, {13, 71}, {21, 81}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}
