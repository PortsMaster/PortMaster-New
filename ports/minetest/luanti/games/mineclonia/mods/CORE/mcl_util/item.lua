local fuel_cache = {}

-- Returns the burntime of an item
-- Returns false otherwise
function mcl_util.get_burntime(item)
	assert(core.get_current_modname() == nil, "mcl_util.is_fuel and mcl_util.get_burntime cannot be called when loading mods")
	if fuel_cache[item] == nil then
		fuel_cache[item] = core.get_craft_result({method = "fuel", width = 1, items = {item}}).time
	end

	return fuel_cache[item]
end

-- Returns true if item (itemstring or ItemStack) can be used as a furnace fuel.
-- Returns false otherwise
function mcl_util.is_fuel(item)
	return mcl_util.get_burntime(item) ~= 0
end

function mcl_util.calculate_durability(itemstack)
	local name = itemstack:get_name()
	local unbreaking_level = mcl_enchanting.get_enchantment(itemstack, "unbreaking")
	local armor_uses = core.get_item_group(name, "mcl_armor_uses")
	local elytra = core.get_item_group(name, "elytra")

	local uses

	if armor_uses > 0 then
		uses = armor_uses
		if unbreaking_level > 0 then
			if elytra <= 0 then
				uses = uses / (0.6 + 0.4 / (unbreaking_level + 1))
			else
				uses = uses * (unbreaking_level + 1)
			end
		end
	else
		local def = itemstack:get_definition()
		if def then
			local fixed_uses = def._mcl_uses
			if fixed_uses then
				uses = fixed_uses
				if unbreaking_level > 0 then
					uses = uses * (unbreaking_level + 1)
				end
			end
		end

		local _, groupcap = next(itemstack:get_tool_capabilities().groupcaps)
		uses = uses or (groupcap or {}).uses
	end

	return uses or 0
end

function mcl_util.use_item_durability(itemstack, n)
	local uses = mcl_util.calculate_durability(itemstack)
	itemstack:add_wear_by_uses(uses * n)
end

function mcl_util.is_item_or_in_group(itemname, group_or_item)
	if group_or_item:sub(1,6) == "group:" then
		local g = core.get_item_group(itemname, group_or_item:sub(7))
		return g ~= 0 and g or false
	end
	return itemname == group_or_item
end
