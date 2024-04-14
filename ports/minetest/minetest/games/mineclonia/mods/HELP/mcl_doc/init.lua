local S = minetest.get_translator(minetest.get_current_modname())

-- Disable built-in factoids; it is planned to add custom ones as replacements
doc.sub.items.disable_core_factoid("node_mining")
doc.sub.items.disable_core_factoid("tool_capabilities")

-- Help button callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_doc then
		doc.show_doc(player:get_player_name())
	end
end)

-- doc_items factoids

-- dig_by_water
doc.sub.items.register_factoid("nodes", "drop_destroy", function(itemstring, def)
	if def.groups.dig_by_water then
		return S("Water can flow into this block and cause it to drop as an item.")
	end
	return ""
end)

-- usable by hoes
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.cultivatable == 1 then
		return S("This block can be turned into dirt with a hoe.")
	elseif def.groups.cultivatable == 2 then
		return S("This block can be turned into farmland with a hoe.")
	end
	return ""
end)

-- usable by shovels
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.path_creation_possible then
		return S("This block can be turned into grass path with a shovel.")
	end
	return ""
end)

-- soil
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	local datastring = ""
	if def.groups.soil_sapling == 2 then
		datastring = datastring .. S("This block acts as a soil for all saplings.") .. "\n"
	elseif def.groups.soil_sapling == 1 then
		datastring = datastring .. S("This block acts as a soil for some saplings.") .. "\n"
	end
	if def.groups.soil_sugarcane then
		datastring = datastring .. S("Sugar canes will grow on this block.") .. "\n"
	end
	if def.groups.soil_nether_wart then
		datastring = datastring .. S("Nether wart will grow on this block.") .. "\n"
	end
	return datastring
end)

doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	local formstring = ""
	if def.groups.leafdecay then
		if def.drop ~= "" and def.drop and def.drop ~= itemstring then
			formstring = S("This block quickly decays when there is no wood block of any species within a distance of @1. When decaying, it disappears and may drop one of its regular drops. The block does not decay when the block has been placed by a player.", def.groups.leafdecay)
		else
			formstring = S("This block quickly decays and disappears when there is no wood block of any species within a distance of @1. The block does not decay when the block has been placed by a player.", def.groups.leafdecay)
		end
	end
	return formstring
end)

-- nodes which have flower placement rules
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.place_flowerlike == 1 then
		return S("This plant can only grow on grass blocks and dirt. To survive, it needs to have an unobstructed view to the sky above or be exposed to a light level of 8 or higher.")
	elseif def.groups.place_flowerlike == 2 then
		return S("This plant can grow on grass blocks, podzol, dirt and coarse dirt. To survive, it needs to have an unobstructed view to the sky above or be exposed to a light level of 8 or higher.")
	end
	return ""
end)

-- flammable
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.flammable then
		return S("This block is flammable.")
	end
	return ""
end)

-- destroys_items
doc.sub.items.register_factoid("nodes", "groups", function(itemstring, def)
	if def.groups.destroys_items then
		return S("This block destroys any item it touches.")
	end
	return ""
end)


-- Comestibles
doc.sub.items.register_factoid(nil, "use", function(itemstring, def)
	local s = ""
	if def.groups.eatable and not def._doc_items_usagehelp then
		if def.groups.food == 2 then
			s = s .. S("To eat it, wield it, then rightclick.")
			if def.groups.can_eat_when_full == 1 then
				s = s .. "\n" .. S("You can eat this even when your hunger bar is full.")
			else
				s = s .. "\n" .. S("You cannot eat this when your hunger bar is full.")
			end
		elseif def.groups.food == 3 then
			s = s .. S("To drink it, wield it, then rightclick.")
			if def.groups.can_eat_when_full ~= 1 then
				s = s .. "\n" .. S("You cannot drink this when your hunger bar is full.")
			end
		else
			s = s .. S("To consume it, wield it, then rightclick.")
			if def.groups.can_eat_when_full ~= 1 then
				s = s .. "\n" .. S("You cannot consume this when your hunger bar is full.")
			end
		end
		if def.groups.no_eat_delay ~= 1 then
			s = s .. "\n" .. S("You have to wait for about 2 seconds before you can eat or drink again.")
		end
	end
	return s
end)

doc.sub.items.register_factoid(nil, "groups", function(itemstring, def)
	local s = ""
	if def.groups.eatable and def.groups.eatable > 0 then
		s = s .. S("Hunger points restored: @1", def.groups.eatable)
	end
	if def._mcl_saturation and def._mcl_saturation > 0 then
		s = s .. "\n" .. S("Saturation points restored: @1%", string.format("%.1f", def._mcl_saturation))
	end
	return s
end)

-- Armor
doc.sub.items.register_factoid(nil, "use", function(itemstring, def)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local head = minetest.get_item_group(itemstring, "armor_head")
	local torso = minetest.get_item_group(itemstring, "armor_torso")
	local legs = minetest.get_item_group(itemstring, "armor_legs")
	local feet = minetest.get_item_group(itemstring, "armor_feet")
	if head > 0 then
		s = s .. S("It can be worn on the head.")
		s = s .. "\n"
	end
	if torso > 0 then
		s = s .. S("It can be worn on the torso.")
		s = s .. "\n"
	end
	if legs > 0 then
		s = s .. S("It can be worn on the legs.")
		s = s .. "\n"
	end
	if feet > 0 then
		s = s .. S("It can be worn on the feet.")
		s = s .. "\n"
	end
	return s
end)
doc.sub.items.register_factoid(nil, "groups", function(itemstring, def)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local use = minetest.get_item_group(itemstring, "mcl_armor_uses")
	local pts = minetest.get_item_group(itemstring, "mcl_armor_points")
	if pts > 0 then
		s = s .. S("Armor points: @1", pts)
		s = s .. "\n"
	end
	if use > 0 then
		s = s .. S("Armor durability: @1", use)
	end
	return s
end)

doc.sub.items.register_factoid(nil, "groups", function(itemstring, def)
	if minetest.get_item_group(itemstring, "no_rename") == 1 then
		return S("This item cannot be renamed at an anvil.")
	else
		return ""
	end
end)

doc.sub.items.register_factoid("nodes", "gravity", function(itemstring, def)
	local s = ""
	if minetest.get_item_group(itemstring, "crush_after_fall") == 1 then
		s = s .. S("This block crushes any block it falls into.")
	end
	return s
end)

doc.sub.items.register_factoid("nodes", "gravity", function(itemstring, def)
	local s = ""
	if minetest.get_item_group(itemstring, "crush_after_fall") == 1 then
		s = s .. S("When this block falls deeper than 1 block, it causes damage to any player it hits. The damage dealt is B×2−2 hit points with B = number of blocks fallen. The damage can never be more than 40 HP.")
	end
	return s
end)

-- Mining, hardness and all that
doc.sub.items.register_factoid("nodes", "mining", function(itemstring, def)
	local pickaxey = { S("Diamond Pickaxe"), S("Iron Pickaxe"), S("Stone Pickaxe"), S("Golden Pickaxe"), S("Wooden Pickaxe") }
	local axey = { S("Diamond Axe"), S("Iron Axe"), S("Stone Axe"), S("Golden Axe"), S("Wooden Axe") }
	local shovely = { S("Diamond Shovel"), S("Iron Shovel"), S("Stone Shovel"), S("Golden Shovel"), S("Wooden Shovel") }

	local datastring = ""
	local groups = def.groups
	if groups then
		if groups.dig_immediate == 3 then
			datastring = datastring .. S("This block can be mined by any tool instantly.") .. "\n"
		else
			local tool_minable = false

			if groups.pickaxey then
				for g=1, 6-groups.pickaxey do
					datastring = datastring .. "• " .. pickaxey[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.axey then
				for g=1, 6-groups.axey do
					datastring = datastring .. "• " .. axey[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.shovely then
				for g=1, 6-groups.shovely do
					datastring = datastring .. "• " .. shovely[g] .. "\n"
				end
				tool_minable = true
			end
			if groups.shearsy or groups.shearsy_wool then
				datastring = datastring .. S("• Shears") .. "\n"
				tool_minable = true
			end
			if groups.swordy or groups.swordy_cobweb then
				datastring = datastring .. S("• Sword") .. "\n"
				tool_minable = true
			end
			if groups.handy then
				datastring = datastring .. S("• Hand") .. "\n"
				tool_minable = true
			end

			if tool_minable then
				datastring = S("This block can be mined by:") .. "\n" .. datastring .. "\n"
			end
		end
	end
	local hardness = def._mcl_hardness
	if not hardness then
		hardness = 0
	end
	if hardness == -1 then
		datastring = datastring .. S("Hardness: ∞")
	else
		datastring = datastring .. S("Hardness: @1", string.format("%.2f", hardness))
	end
	local blast = def._mcl_blast_resistance
	if not blast then
		blast = 0
	end
	datastring = datastring .. "\n" .. S("Blast Resistance: @1", string.format("%.2f", blast))
	if blast >= 1000 then
		datastring = datastring .. "\n" .. S("This block will not be destroyed by TNT explosions.")
	end
	return datastring
end)

-- Special drops when mined by shears
doc.sub.items.register_factoid("nodes", "drops", function(itemstring, def)
	if def._mcl_shears_drop == true then
		return S("This block drops itself when mined by shears.")
	elseif type(def._mcl_shears_drop) == "table" then
		local drops = {}
		for d=1, #def._mcl_shears_drop do
			local item = ItemStack(def._mcl_shears_drop[d])
			local itemname = item:get_name()
			local itemcount = item:get_count()
			local idef = minetest.registered_items[itemname]
			local text
			if idef.description and idef.description ~= "" then
				text = idef.description
			else
				text = itemname
			end
			if itemcount > 1 then
				text = S("@1×@2", itemcount, text)
			end
			table.insert(drops, text)
		end
		local ret = S("This blocks drops the following when mined by shears: @1", table.concat(drops, S(", ")))
		return ret
	end
	return ""
end)

-- Digging capabilities of tool
doc.sub.items.register_factoid("tools", "misc", function(itemstring, def)
	if not def.tool_capabilities then
		return ""
	end
	local groupcaps = def.tool_capabilities.groupcaps
	if not groupcaps then
		return ""
	end
	local formstring = ""
	local capstr = ""
	local caplines = 0
	for k,v in pairs(groupcaps) do
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
		formstring = formstring .. S("This tool is capable of mining.") .. "\n"
		-- Capabilities
		formstring = formstring .. capstr
		-- Max. drop level
		local mdl = def.tool_capabilities.max_drop_level
		if not def.tool_capabilities.max_drop_level then
			mdl = 0
		end
		formstring = formstring .. S("Block breaking strength: @1", mdl) .. "\n"
	end
	if caplines > 0 then
		formstring = formstring .. "\n\n"
	end
	return formstring
end)

-- Melee damage
doc.sub.items.register_factoid("tools", "misc", function(itemstring, def)
	local tool_capabilities = def.tool_capabilities
	if not tool_capabilities then
		return ""
	end

	local formstring = ""
	-- Weapon data
	local damage_groups = tool_capabilities.damage_groups
	if damage_groups and damage_groups.fleshy then
		formstring = formstring .. S("This is a melee weapon which deals damage by punching.") .. "\n"

		-- Damage groups
		local dmg = damage_groups.fleshy
		formstring = formstring .. S("Maximum damage: @1 HP", dmg) .. "\n"

		-- Full punch interval
		local punch = 1.0
		if tool_capabilities.full_punch_interval then
			punch = tool_capabilities.full_punch_interval
		end
		formstring = formstring .. S("Full punch interval: @1 s", string.format("%.1f", punch))
		formstring = formstring .. "\n"
	end
	return formstring
end)

