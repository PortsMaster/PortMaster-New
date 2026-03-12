local C = core.colorize
local S = core.get_translator(core.get_current_modname())

local base_color = "#794100"

local function color_string_to_table(colorstring)
	return {
		r = tonumber(colorstring:sub(2,3), 16), -- 16 as second parameter allows hexadecimal
		g = tonumber(colorstring:sub(4,5), 16),
		b = tonumber(colorstring:sub(6,7), 16),
	}
end

local function av(a, b)
	return (a + b)/2
end

local function calculate_color(first, last)
	return {
		r = av(first.r, last.r),
		g = av(first.g, last.g),
		b = av(first.b, last.b),
	}
end

function mcl_armor.colorize_leather_armor(itemstack, colorstring)
	if not itemstack or core.get_item_group(itemstack:get_name(), "armor_leather") == 0 then
		return itemstack
	end
	local color = color_string_to_table(colorstring)
	colorstring = core.colorspec_to_colorstring(color)
	local meta = itemstack:get_meta()
	local old_color = meta:get_string("mcl_armor:color")
	if old_color == colorstring then return itemstack
	elseif old_color ~= "" then
		color = calculate_color(
			color_string_to_table(core.colorspec_to_colorstring(old_color)),
			color
		)
		colorstring = core.colorspec_to_colorstring(color)
	end
	meta:set_string("mcl_armor:color", colorstring)
	meta:set_string("inventory_image",
		itemstack:get_definition().inventory_image:gsub(".png$", "_desat.png") .. "^[multiply:" .. colorstring
	)
	tt.reload_itemstack_description(itemstack)
	return itemstack
end


function mcl_armor.wash_leather_armor(itemstack)
	if not itemstack or itemstack:get_definition().groups.armor_leather ~= 1 then
		return
	end
	local meta = itemstack:get_meta()
	meta:set_string("mcl_armor:color", "")
	meta:set_string("inventory_image", "")
	tt.reload_itemstack_description(itemstack)
	return itemstack
end

mcl_armor.register_set({
	name = "leather",
	color = base_color,
	descriptions = {
		head = S("Leather Cap"),
		torso = S("Leather Tunic"),
		legs = S("Leather Pants"),
		feet = S("Leather Boots"),
	},
	durability = 80,
	enchantability = 15,
	points = {
		head = 1,
		torso = 3,
		legs = 2,
		feet = 1,
	},
	craft_material = "mcl_mobitems:leather",
	on_place = function(itemstack, placer, pointed_thing)
		if mcl_util.check_position_protection(pointed_thing.under, placer) then return itemstack end
		if core.get_item_group(core.get_node(pointed_thing.under).name, "cauldron_water") <= 0 then return end
		if mcl_cauldrons.add_level(pointed_thing.under, -1) then
			local outcome = mcl_armor.wash_leather_armor(itemstack)
			if outcome then
				core.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
				return outcome
			end
		end
	end,
})

tt.register_priority_snippet(function(_, _, itemstack)
	if not itemstack or itemstack:get_definition().groups.armor_leather ~= 1 then
		return
	end
	local color = itemstack:get_meta():get_string("mcl_armor:color")
	if color and color ~= "" then
		local text = C(mcl_colors.GRAY, "Dyed: "..color)
		return text, false
	end
end)

for _, element in pairs(mcl_armor.elements) do
	local modname = core.get_current_modname()
	local itemname = modname .. ":" .. element.name .. "_leather"
	core.register_craft({
		type = "shapeless",
		output = itemname,
		recipe = {
			itemname,
			"group:dye",
		},
	})
	local ench_itemname = itemname .. "_enchanted"
	core.register_craft({
		type = "shapeless",
		output = ench_itemname,
		recipe = {
			ench_itemname,
			"group:dye",
		},
	})
end

local function colorizing_crafting(itemstack, _, old_craft_grid, _)
	if core.get_item_group(itemstack:get_name(), "armor_leather") == 0 then
		return
	end

	local found_la
	local dye_color
	for _, item in pairs(old_craft_grid) do
		local name = item:get_name()
		if name ~= "" then
			if core.get_item_group(name, "armor_leather") > 0 then
				if found_la then return end
				found_la = item
			elseif core.get_item_group(name, "dye") > 0 then
				if dye_color then return end
				dye_color = mcl_dyes.colors[core.registered_items[name]._color].rgb
			else return end
		end
	end
	return mcl_armor.colorize_leather_armor(found_la, dye_color) or ItemStack()
end

core.register_craft_predict(colorizing_crafting)
core.register_on_craft(colorizing_crafting)

core.register_chatcommand("color_leather", {
	params = "<color>",
	description = S("Colorize a piece of leather armor, or wash it"),
	privs = { debug = true, },
	func = function(name, param)
		local player = core.get_player_by_name(name)
		if player then
			local item = player:get_wielded_item()
			if not item or  core.get_item_group(item:get_name(), "armor_leather") == 0 then
				return false, S("Not leather armor.")
			end
			if param == "wash" then
				player:set_wielded_item(mcl_armor.wash_leather_armor(item))
				return true, S("Washed.")
			end
			local colorstring = core.colorspec_to_colorstring(param)
			if not colorstring then return false, "Invalid color" end
			player:set_wielded_item(mcl_armor.colorize_leather_armor(item, colorstring))
			return true, S("Done: @1", colorstring)
		else
			return false, S("Player isn't online")
		end
	end,
})
