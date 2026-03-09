local S = core.get_translator(core.get_current_modname())

local function newline(str)
	if str ~= "" then str = str .. "\n" end

	return str
end

-- Capabilities for tools and melee weapon
tt.register_snippet(function(itemstring, toolcaps, _)
	local final_result = ""
	local defs = core.registered_items[itemstring]
	local tool = core.get_item_group(itemstring, "tool") == 1
	local weapon = core.get_item_group(itemstring, "weapon") == 1

	if not (tool or weapon) or not toolcaps then return end

	local caplines = 0
	local mining_caps = ""
	local attack_caps = ""

	for _, v in pairs(toolcaps.groupcaps or {}) do
		caplines = caplines + 1

		local max_level = v.maxlevel or 1
		local base_uses = v.uses or 20

		if defs and defs._doc_items_durability == nil and base_uses > 0 then
			local dur_str
			local real_uses = base_uses * math.pow(3, max_level)

			if weapon and toolcaps.punch_attack_uses then real_uses = toolcaps.punch_attack_uses end

			if real_uses < 65535 then
				dur_str = S("@1 uses", real_uses)
			else
				dur_str = S("Unlimited uses")
			end

			final_result = final_result .. S("Durability: @1", dur_str)
			newline(final_result)
		end

		local speed_class = core.get_item_group(itemstring, "dig_speed_class")
		local speed_classes = {
			S("Painfully slow"),
			S("Very slow"),
			S("Slow"),
			S("Fast"),
			S("Very fast"),
			S("Extremely fast"),
			S("Instantaneous")
		}

		if not speed_classes[speed_class] then
			if speed_class == 0 then
				speed_class = 1
			elseif speed_class > 7 then
				speed_class = 7
			end
		end

		mining_caps = mining_caps .. S("Mining speed: @1", speed_classes[speed_class])

		break
	end

	if caplines > 0 then
		local mdl = toolcaps.max_drop_level or 0

		if core.get_item_group(itemstring, "pickaxe") > 0 then
			mining_caps = newline(mining_caps) .. S("Block breaking strength: @1", mdl)
		end
	end

	if toolcaps.damage_groups then
		for group, damage in pairs(toolcaps.damage_groups) do
			if group == "fleshy" and damage >= 0 then
				attack_caps = attack_caps .. S("Damage: @1", damage)
			end
		end

		local fpi = math.floor(toolcaps.full_punch_interval * 100 + 0.5) / 100

		attack_caps = newline(attack_caps) .. S("Full punch interval: @1s", fpi)
	end

	if tool then
		final_result = newline(final_result) .. mining_caps

		if attack_caps ~= "" then final_result = newline(final_result) .. attack_caps end
	elseif weapon then
		final_result = newline(final_result) .. attack_caps

		if mining_caps ~= "" then final_result = newline(final_result) .. mining_caps end
	end

	return final_result
end)
-- Why that code still here? MCLA does not use it.
-- Food
tt.register_snippet(function(itemstring)
	local def = core.registered_items[itemstring]
	local desc
	if def and def._tt_food then
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
	local def = core.registered_items[itemstring]
	local desc = ""

	-- Health-related node facts
	if def and def.damage_per_second then
		if def.damage_per_second > 0 then
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DANGER, S("Contact damage: @1 per second", def.damage_per_second))
		elseif def.damage_per_second < 0 then
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_GOOD, S("Contact healing: @1 per second", math.abs(def.damage_per_second)))
		end
	end
	if def and def.drowning and def.drowning ~= 0 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DANGER, S("Drowning damage: @1", def.drowning))
	end
	local tmp = core.get_item_group(itemstring, "fall_damage_add_percent")
	if tmp > 0 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DANGER, S("Fall damage: +@1%", tmp))
	elseif tmp == -100 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_GOOD, S("No fall damage"))
	elseif tmp < 0 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Fall damage: @1%", tmp))
	end

	-- Movement-related node facts
	if def and core.get_item_group(itemstring, "disable_jump") == 1 and not def.climbable then
		if def.liquidtype == "none" then
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("No jumping"))
		elseif core.get_item_group(itemstring, "fake_liquid") == 0 then
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("No swimming upwards"))
		else
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("No rising"))
		end
	end
	if def and def.climbable then
		if core.get_item_group(itemstring, "disable_jump") == 1 then
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Climbable (only downwards)"))
		else
			desc = newline(desc)
			desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Climbable"))
		end
	end
	if core.get_item_group(itemstring, "slippery") >= 1 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Slippery"))
	end
	local tmp = core.get_item_group(itemstring, "bouncy")
	if tmp >= 1 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Bouncy (@1%)", tmp))
	end

	-- Node appearance
	tmp = def and def.light_source
	if tmp and tmp >= 1 then
		desc = newline(desc)
		desc = desc .. core.colorize(tt.COLOR_DEFAULT, S("Luminance: @1", tmp))
	end

	return desc ~= "" and desc or nil, false
end)

