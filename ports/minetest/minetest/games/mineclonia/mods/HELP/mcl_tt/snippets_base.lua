local S = minetest.get_translator(minetest.get_current_modname())

--[[local function get_min_digtime(caps)
	local mintime
	local unique = true
	local maxlevel = caps.maxlevel
	if not maxlevel then
		maxlevel = 1
	end
	if maxlevel > 1 then
		unique = false
	end
	if caps.times then
		for r=1,3 do
			local time = caps.times[r]
			if time and maxlevel > 1 then
				time = time / maxlevel
			end
			if time and ((not mintime) or (time < mintime)) then
				if mintime and (time < mintime) then
					unique = false
				end
				mintime = time
			end
		end
	end
	return mintime, unique
end]]

local function newline(str)
	if str ~= "" then
		str = str .. "\n"
	end
	return str
end

-- Digging capabilities of tool
tt.register_snippet(function(itemstring, toolcaps)
	local def = minetest.registered_items[itemstring]
	if not toolcaps then
		return
	end
	local groupcaps = toolcaps.groupcaps
	if not groupcaps then
		return
	end
	local minestring = ""
	local capstr = ""
	local caplines = 0
	for _,v in pairs(groupcaps) do
		local speedstr = ""
		local miningusesstr = ""
		-- Mining capabilities
		caplines = caplines + 1
		local maxlevel = v.maxlevel
		if not maxlevel then
			-- Default from tool.h
			maxlevel = 1
		end

		-- Digging speed
		local speed_class = def.groups and def.groups.dig_speed_class
		if speed_class == 1 then
			speedstr = S("Painfully slow")
		elseif speed_class == 2 then
			speedstr = S("Very slow")
		elseif speed_class == 3 then
			speedstr = S("Slow")
		elseif speed_class == 4 then
			speedstr = S("Fast")
		elseif speed_class == 5 then
			speedstr = S("Very fast")
		elseif speed_class == 6 then
			speedstr = S("Extremely fast")
		elseif speed_class == 7 then
			speedstr = S("Instantaneous")
		end

		-- Number of mining uses
		local base_uses = v.uses
		if not base_uses then
			-- Default from tool.h
			base_uses = 20
		end
		if def._doc_items_durability == nil and base_uses > 0 then
			local real_uses = base_uses * math.pow(3, maxlevel)
			if real_uses < 65535 then
				miningusesstr = S("@1 uses", real_uses)
			else
				miningusesstr = S("Unlimited uses")
			end
		end

		if speedstr ~= "" then
			capstr = capstr .. S("Mining speed: @1", speedstr) .. "\n"
		end
		if miningusesstr ~= "" then
			capstr = capstr .. S("Mining durability: @1", miningusesstr) .. "\n"
		end

		-- Only show one group at max
		break
	end
	if caplines > 0 then
		-- Capabilities
		minestring = minestring .. capstr
		-- Max. drop level
		local mdl = toolcaps.max_drop_level
		if not toolcaps.max_drop_level then
			mdl = 0
		end
		minestring = minestring .. S("Block breaking strength: @1", mdl)
	end

	local weaponstring = ""
	-- Weapon stats
	if toolcaps.damage_groups then
		for group, damage in pairs(toolcaps.damage_groups) do
			local msg = ""
			if group == "fleshy" then
				if damage >= 0 then
					msg = S("Damage: @1", damage)
				else
					msg = S("Healing: @1", math.abs(damage))
				end
			end
			weaponstring = newline(weaponstring)
			weaponstring = weaponstring .. msg
		end
		local full_punch_interval = toolcaps.full_punch_interval
		if not full_punch_interval then
			full_punch_interval = 1
		end
		weaponstring = newline(weaponstring)
		weaponstring = weaponstring .. S("Full punch interval: @1s", string.format("%.2f", full_punch_interval))
	end

	local ret
	if minetest.get_item_group(itemstring, "weapon") == 1 then
		ret = weaponstring
		ret = newline(ret)
		ret = ret .. minestring
	else
		ret = minestring
		ret = newline(ret)
		ret = ret .. weaponstring
	end

	if ret == "" then
		ret = nil
	end
	return ret
end)

-- Weapon stats
--[[tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
end)]]

-- Food
tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	local desc
	if def._tt_food then
		desc = S("Food item")
		if def._tt_food_hp then
			local msg = S("+@1 food points", def._tt_food_hp)
			desc = desc .. "\n" .. msg
		end
	end
	return desc
end)

-- Node info
tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	local desc = ""

	-- Health-related node facts
	if def.damage_per_second then
		if def.damage_per_second > 0 then
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DANGER, S("Contact damage: @1 per second", def.damage_per_second))
		elseif def.damage_per_second < 0 then
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_GOOD, S("Contact healing: @1 per second", math.abs(def.damage_per_second)))
		end
	end
	if def.drowning and def.drowning ~= 0 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DANGER, S("Drowning damage: @1", def.drowning))
	end
	local tmp = minetest.get_item_group(itemstring, "fall_damage_add_percent")
	if tmp > 0 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DANGER, S("Fall damage: +@1%", tmp))
	elseif tmp == -100 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_GOOD, S("No fall damage"))
	elseif tmp < 0 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Fall damage: @1%", tmp))
	end

	-- Movement-related node facts
	if minetest.get_item_group(itemstring, "disable_jump") == 1 and not def.climbable then
		if def.liquidtype == "none" then
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("No jumping"))
		elseif minetest.get_item_group(itemstring, "fake_liquid") == 0 then
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("No swimming upwards"))
		else
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("No rising"))
		end
	end
	if def.climbable then
		if minetest.get_item_group(itemstring, "disable_jump") == 1 then
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Climbable (only downwards)"))
		else
			desc = newline(desc)
			desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Climbable"))
		end
	end
	if minetest.get_item_group(itemstring, "slippery") >= 1 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Slippery"))
	end
	local tmp = minetest.get_item_group(itemstring, "bouncy")
	if tmp >= 1 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Bouncy (@1%)", tmp))
	end

	-- Node appearance
	tmp = def.light_source
	if tmp and tmp >= 1 then
		desc = newline(desc)
		desc = desc .. minetest.colorize(tt.COLOR_DEFAULT, S("Luminance: @1", tmp))
	end


	if desc == "" then
		desc = nil
	end
	return desc, false
end)

