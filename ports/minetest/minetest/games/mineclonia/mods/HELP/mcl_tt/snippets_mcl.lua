local S = core.get_translator(core.get_current_modname())
-- Armor
tt.register_snippet(function(itemstring, _, itemstack)
	if core.get_item_group(itemstring, "armor") < 1 then return end

	local final_result = ""
	local head = core.get_item_group(itemstring, "armor_head")
	local torso = core.get_item_group(itemstring, "armor_torso")
	local legs = core.get_item_group(itemstring, "armor_legs")
	local feet = core.get_item_group(itemstring, "armor_feet")
	local use = core.get_item_group(itemstring, "mcl_armor_uses")
	local pts = core.get_item_group(itemstring, "mcl_armor_points")

	if head > 0 then final_result = final_result .. S("Head armor") end
	if torso > 0 then final_result = final_result .. S("Torso armor") end
	if legs > 0 then final_result = final_result .. S("Legs armor") end
	if feet > 0 then final_result = final_result .. S("Feet armor") end

	final_result = final_result .. "\n"

	if pts > 0 then final_result = final_result .. S("Armor points: @1", pts) .. "\n" end

	if itemstack then
		local unbreaking = mcl_enchanting.get_enchantment(itemstack, "unbreaking")

		if unbreaking > 0 then
			local elytra = core.get_item_group(itemstring, "elytra")

			if elytra > 0 then
				use = math.floor(use * (unbreaking + 1))
			else
				use = math.floor(use / (0.6 + 0.4 / (unbreaking + 1)))
			end
		end
	end

	if use > 0 then
		final_result = final_result .. S("Armor durability: @1", use)
	end

	return final_result ~= "" and final_result or nil
end)
-- Horse armor
tt.register_snippet(function(itemstring)
	local armor_g = core.get_item_group(itemstring, "horse_armor")
	if armor_g and armor_g > 0 then
		return S("Protection: @1%", 100 - armor_g)
	end
end)

tt.register_snippet(function(itemstring)
	local def = core.registered_items[itemstring]
	local s = ""
	if core.get_item_group(itemstring, "eatable") > 0 then
		s = s .. S("Hunger points: +@1", def.groups.eatable)
	end
	if def and def._mcl_saturation and def._mcl_saturation > 0 then
		if s ~= "" then
			s = s .. "\n"
		end
		s = s .. S("Saturation points: +@1", string.format("%.1f", def._mcl_saturation))
	end
	return s ~= "" and s or nil
end)

tt.register_snippet(function(itemstring)
	if core.get_item_group(itemstring, "crush_after_fall") == 1 then
		return S("Deals damage when falling"), mcl_colors.YELLOW
	end
end)

tt.register_snippet(function(itemstring)
	local place_flowerlike = core.get_item_group(itemstring, "place_flowerlike")
	if place_flowerlike == 1 then
		return S("Grows on grass blocks or dirt")
	elseif place_flowerlike == 2 then
		return S("Grows on grass blocks, podzol, dirt or coarse dirt")
	end
end)

tt.register_snippet(function(itemstring)
	if core.get_item_group(itemstring, "flammable") ~= 0 then
		return S("Flammable")
	end
end)

tt.register_snippet(function(itemstring)
	if itemstring == "mcl_heads:zombie" then
		return S("Zombie view range: -50%")
	elseif itemstring == "mcl_heads:skeleton" then
		return S("Skeleton view range: -50%")
	elseif itemstring == "mcl_heads:creeper" then
		return S("Creeper view range: -50%")
	end
end)

-- Other tools and weapon
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then itemstack = ItemStack(itemstring) end

	if core.get_item_group(itemstring, "tool") == 2 or core.get_item_group(itemstring, "weapon") == 2 then
		local uses = mcl_util.calculate_durability(itemstack)

		return S("Durability: @1", S("@1 uses", uses))
	end
end)

-- Potions info
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then return end
	local def = itemstack:get_definition()
	if core.get_item_group(itemstring, "_mcl_potion") ~= 1 then return end

	local s = ""
	local meta = itemstack:get_meta()
	local potency = meta:get_int("mcl_potions:potion_potent")
	local plus = meta:get_int("mcl_potions:potion_plus")
	local sl_factor = 1
	if core.get_item_group(itemstring, "ling_potion") == 1 then
		sl_factor = mcl_potions.LINGERING_FACTOR
	elseif core.get_item_group(itemstring, "tipped_arrow") == 1 then
		sl_factor = mcl_potions.TIPPED_FACTOR
	end
	if def and def._dynamic_tt then s = s.. def._dynamic_tt((potency+1)*sl_factor).. "\n" end
	local effects = def and def._effect_list
	if effects then
		local effect
		local dur
		local timestamp
		local ef_level
		local roman_lvl
		local factor
		local ef_tt
		for name, details in pairs(effects) do
			effect = mcl_potions.registered_effects[name]
			dur = mcl_potions.duration_from_details (details, potency,
								 plus, sl_factor)
			timestamp = math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
			ef_level = mcl_potions.level_from_details (details, potency)
			if ef_level > 1 then roman_lvl = " ".. mcl_util.to_roman(ef_level)
			else roman_lvl = "" end
			s = s.. effect.description.. roman_lvl.. " (".. timestamp.. ")\n"
			if effect.uses_factor then factor = effect.level_to_factor(ef_level) end
			if effect.get_tt then ef_tt = core.colorize("grey", effect.get_tt(factor)) else ef_tt = "" end
			if ef_tt ~= "" then s = s.. ef_tt.. "\n" end
		end
	end
	return s:trim()
end)
