local function use_durability(obj, inv, index, stack, uses)
	local def = stack:get_definition()
	mcl_util.use_item_durability(stack, uses)
	if stack:is_empty() and def and def._on_break then
		stack = def._on_break(obj) or stack
	end
	inv:set_stack("armor", index, stack)
end

mcl_damage.register_modifier(function(obj, damage, reason)
	local flags = reason.flags

	if flags.bypasses_armor and flags.bypasses_magic then
		return damage
	end

	local uses = math.max(1, math.floor(damage / 4))

	local points = 0
	local toughness = 0
	local enchantment_protection_factor = 0

	local thorns_damage_regular = 0
	local thorns_damage_irregular = 0
	local thorns_pieces = {}

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for name, element in pairs(mcl_armor.elements) do
			local itemstack = inv:get_stack("armor", element.index)
			if not itemstack:is_empty() then
				local itemname = itemstack:get_name()
				local enchantments = mcl_enchanting.get_enchantments(itemstack)

				if not flags.bypasses_armor and minetest.get_item_group(itemname, "non_combat_armor") == 0 then
					points = points + minetest.get_item_group(itemname, "mcl_armor_points")
					toughness = toughness + minetest.get_item_group(itemname, "mcl_armor_toughness")

					use_durability(obj, inv, element.index, itemstack, uses)
				end

				if not flags.bypasses_magic then
					local function add_enchantments(tbl)
						if tbl then
							for _, enchantment in pairs(tbl) do
								local level = enchantments[enchantment.id]

								if level and level > 0 then
									enchantment_protection_factor = enchantment_protection_factor + level * enchantment.factor
								end
							end
						end
					end

					add_enchantments(mcl_armor.protection_enchantments.wildcard)
					add_enchantments(mcl_armor.protection_enchantments.types[reason.type])

					for flag, value in pairs(flags) do
						if value then
							add_enchantments(mcl_armor.protection_enchantments.flags[flag])
						end
					end
				end

				if reason.source and enchantments.thorns and enchantments.thorns > 0 then
					local do_irregular_damage = enchantments.thorns > 10

					if do_irregular_damage or thorns_damage_regular < 4 and math.random() < enchantments.thorns * 0.15 then
						if do_irregular_damage then
							thorns_damage_irregular = thorns_damage_irregular + enchantments.thorns - 10
						else
							thorns_damage_regular = math.min(4, thorns_damage_regular + math.random(4))
						end
					end

					table.insert(thorns_pieces, {index = element.index, itemstack = itemstack})
				end
			end
		end
	end

	-- https://minecraft.gamepedia.com/Armor#Damage_protection
	damage = damage * (1 - math.min(20, math.max((points / 5), points - damage / (2 + (toughness / 4)))) / 25)

	-- https://minecraft.gamepedia.com/Armor#Enchantments
	damage = damage * (1 - math.min(20, enchantment_protection_factor) / 25)

	local thorns_damage = thorns_damage_regular + thorns_damage_irregular

	if thorns_damage > 0 and reason.type ~= "thorns" and reason.source ~= obj then
		mcl_util.deal_damage(reason.source, thorns_damage, {type = "thorns", direct = obj})
		-- mcl_util.deal_damage may remove object immediately
		if not reason.source:get_pos() then return end

		local thorns_item = thorns_pieces[math.random(#thorns_pieces)]

		use_durability(obj, inv, thorns_item.index, thorns_item.itemstack, 2)
	end

	mcl_armor.update(obj)

	return math.floor(damage + 0.5)
end, 0)
