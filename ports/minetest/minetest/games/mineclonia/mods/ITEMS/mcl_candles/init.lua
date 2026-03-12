mcl_candles = {}

local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator(core.get_current_modname())

local candle_boxes = {
	{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
	{-0.1875, -0.5, -0.0625, 0.1875, -0.125, 0.125},
	{-0.1875, -0.5, -0.1875, 0.125, -0.125, 0.125},
	{-0.1875, -0.5, -0.125, 0.1875, -0.125, 0.1875}
}

local function set_candle_properties(stack, color)
	if type(color) ~= "string" and color == "" then return end

	local color_defs = mcl_dyes.colors[color]
	local image = "mcl_candles_item_".. color .. ".png"

	if color_defs then
		stack:get_meta():set_int("palette_index", color_defs.palette_index + 1)
		stack:get_meta():set_string("inventory_overlay", image)
		stack:get_meta():set_string("wield_overlay", image)
	end
end
mcl_candles.set_candle_properties = set_candle_properties

local function drop_candles(pos, node, _, digger)
	if digger and digger:is_player() and core.is_creative_enabled(digger:get_player_name()) then return end

	if not node then node = core.get_node(pos) end

	local group = core.get_item_group(node.name, "candles")

	if node.name:find("mcl_candles:candle_cake") then group = 1 end

	local item = ItemStack("mcl_candles:candle_1 " .. group)
	local color_index = node.param2 > 0 and node.param2
	local color = color_index and mcl_dyes.palette_index_to_color(color_index - 1)

	if color then set_candle_properties(item, color) end

	tt.reload_itemstack_description(item)

	return core.add_item(pos, item)
end

local function ignite_candle(pos)
	local n = core.get_node(pos)
	local g = core.get_item_group(n.name, "candles")
	if g > 0 then
		n.name = "mcl_candles:candle_lit_"..tostring(g)
		core.swap_node(pos, n)
		return true
	end
end

local function get_candle_item(pos)
	local stack = ItemStack("mcl_candles:candle_1")
	local node = core.get_node(pos)
	local color_index = node.param2 > 0 and node.param2
	local color = color_index and mcl_dyes.palette_index_to_color(color_index - 1)

	if color then set_candle_properties(stack, color) end

	tt.reload_itemstack_description(stack)

	return stack
end

local tpl_candle = {
	_doc_items_longdesc = S("A candle is a block that emits light when lit with a flint and steel. It comes in the sixteen dye colors. Up to four of the same color of candle can be placed in one block space, which affects the amount of light produced."),
	_mcl_baseitem = get_candle_item,
	_mcl_hardness = 0.1,
	_on_dye_place = function(pos, color)
		local node = core.get_node(pos)
		node.param2 = mcl_dyes.colors[color].palette_index
		core.swap_node(pos, node)
	end,
	_on_ignite = function(_, pointed_thing)
		return ignite_candle(pointed_thing.under)
	end,
	_on_arrow_hit = function(pos, arrow_luaentity)
		if not mcl_burning.is_burning(arrow_luaentity.object) then return end
		return ignite_candle(pos)
	end,
	_on_set_item_entity = function (stack)
		return stack, {wield_item = stack:to_string()}
	end,
	_mcl_generate_description = function(itemstack)
		local m = itemstack:get_meta()
		local color = mcl_dyes.palette_index_to_color(m:get_int("palette_index") - 1)
		local c = ""
		if mcl_dyes.colors[color] then
			c = mcl_dyes.colors[color].readable_name .. " "
		end
		m:set_string("description", D(c.. "Candle"))
	end,
	on_destruct = drop_candles,
	description = S("Candle"),
	drawtype = "mesh",
	drop = "",
	groups = {
		axey = 1, candles = 1, deco_block = 1, dig_by_piston = 1, handy = 1, not_solid = 1,
		pickaxey = 1, shearsy = 1, shovely = 1, swordy = 1, unlit_candles = 1
	},
	inventory_image = "mcl_candles_item.png",
	is_ground_content = false,
	node_placement_prediction = "",
	palette = "mcl_candles_palette.png",
	paramtype = "light",
	paramtype2 = "color",
	sounds = mcl_sounds.node_sound_defaults(),
	sunlight_propagates = true,
	tiles = {"mcl_candles_candle.png", "blank.png"},
	use_texture_alpha = "clip",
	wield_image = "mcl_candles_item.png"
}

local tpl_lit_candle = {
	_doc_items_create_entry = false,
	description = S("Lit Candle"),
	groups = {
		axey = 1, candles = 1, dig_by_piston = 1, handy = 1, lit_candles = 1,
		not_in_creative_inventory = 1, not_solid = 1, pickaxey = 1, shearsy = 1,
		shovely = 1, swordy = 1
	},
    tiles = {
        "mcl_candles_candle.png",
        {
            animation = {
                aspect_h = 16,
				aspect_w = 16,
				length = 1,
				type = "vertical_frames"
            },
			color = "white",
			name = "mcl_candles_flames.png"
        }
    }
}

function tpl_candle.on_place(itemstack, placer, pointed_thing)
	if not placer then return end

	if mcl_util.check_position_protection(pointed_thing.under, placer) then return end

	local unode = core.get_node(pointed_thing.under)
	local group = core.get_item_group(unode.name, "candles")
	local param2 = tonumber(itemstack:get_meta():get("palette_index")) or 0

	if unode.name == "mcl_cake:cake" then
		core.swap_node(pointed_thing.under, {name = "mcl_candles:candle_cake", param2 = param2})

		if not core.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end

		return itemstack
	end

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)

	if rc ~= nil then return rc end

	if group > 0 then
		if group < #candle_boxes then
			unode.name = "mcl_candles:candle_" .. math.min(4, group + 1)
			if param2 == unode.param2 then
				core.swap_node(pointed_thing.under, unode)
			end

			if not core.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
		end
	else
		return core.item_place_node(itemstack, placer, pointed_thing)
	end

	return itemstack
end

function extinguish(pos, node, clicker, _, _)
	if not clicker then
		return
	end

	if mcl_util.check_position_protection(pos, clicker) then
		return
	end

	local group = core.get_item_group(node.name, "lit_candles")
	if group > 0 then
		node.name = "mcl_candles:candle_" .. group
		core.swap_node(pos, node)
	end
end

for i = 1, #candle_boxes do
	local creative_group
	local candle_n = {
		collision_box = {fixed = candle_boxes[i], type = "fixed"},
		selection_box = {fixed = candle_boxes[i], type = "fixed"}
	}

	if i ~= 1 then
		tpl_candle._doc_items_create_entry = false
		creative_group = {not_in_creative_inventory = 1}
	end

	core.register_node("mcl_candles:candle_" .. i, table.merge(tpl_candle, candle_n, {
		_get_all_virtual_items = function ()
			local output = {deco = {}}

			if i == 1 then
				for color, _ in pairs(mcl_dyes.colors) do
					local stack = ItemStack("mcl_candles:candle_1")

					set_candle_properties(stack, color)

					tt.reload_itemstack_description(stack)

					table.insert(output.deco, stack:to_string())
				end
			end

			return output
		end,
		groups = table.merge(tpl_candle.groups, {candles = i, unlit_candles = i}, creative_group),
		mesh = "mcl_candles_candle_" .. i .. ".obj",
	}))
	local lit_candle = table.merge(tpl_candle, tpl_lit_candle, candle_n, {
		_on_wind_charge_hit = function (pos)
			local node = core.get_node(pos)
			local group = core.get_item_group(node.name, "lit_candles")
			node.name = "mcl_candles:candle_" .. group
			core.swap_node(pos, node)
		end,
		groups = table.merge(tpl_lit_candle.groups, {candles = i, lit_candles = i}),
		light_source = 3 * i,
		mesh = "mcl_candles_candle_lit_" .. i .. ".obj",
		on_rightclick = extinguish
	})
	lit_candle._on_ignite = nil
	lit_candle._on_arrow_hit = nil
	core.register_node("mcl_candles:candle_lit_" .. i, lit_candle)

	doc.add_entry_alias("nodes", "mcl_candles:candle_1", "nodes", "mcl_candles:candle_" .. i)
	doc.add_entry_alias("nodes", "mcl_candles:candle_1", "nodes", "mcl_candles:candle_lit_" .. i)
end

local function candle_craft(output, _, old_craft_grid, _)
	if not (output and output:get_name() == "mcl_candles:candle_1") then return end

	local i = 0
	local dye, candle

	for _, stack in pairs(old_craft_grid) do
		if core.get_item_group(stack:get_name(), "candles") > 0 then
			candle = stack
			i = i + 1
		elseif core.get_item_group(stack:get_name(), "dye") > 0 then
			dye = stack
			i = i + 1
		end
	end

	if dye and candle and i == 2 then
		local color = dye:get_definition()._color
		local cdef = mcl_dyes.colors[color]
		local result = ItemStack(core.itemstring_with_palette(candle, cdef.palette_index + 1))

		result:set_count(1)

		set_candle_properties(result, color)

		tt.reload_itemstack_description(result)

		return result
	end
end

core.register_craft_predict(candle_craft)
core.register_on_craft(candle_craft)

core.register_craft({
	output = "mcl_candles:candle_1",
	recipe = {
		{"mcl_mobitems:string"},
		{"mcl_honey:honeycomb"}
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_candles:candle_1",
	recipe = {
		"group:candles",
		"group:dye",
	}
})

local cake_box = {
	fixed = {
		{-0.4375, -0.5, -0.4375, 0.4375, 0, 0.4375},
		{-0.0625, 0, -0.0625, 0.0625, 0.375, 0.0625}
	},
	type = "fixed"
}

local function looking_at_candle(pointer, pointed_thing)
	if not pointer then return end

	local pt_above = pointed_thing.above
	local pt_under = pointed_thing.under

	if pt_above.y > pt_under.y then
		local f_pos_x = core.pointed_thing_to_face_pos(pointer, pointed_thing).x - pt_above.x
		local f_pos_z = core.pointed_thing_to_face_pos(pointer, pointed_thing).z - pt_above.z

		if f_pos_x * f_pos_x + f_pos_z * f_pos_z < 0.0062 then
			return true
		end
	end

	local f_pos = core.pointed_thing_to_face_pos(pointer, pointed_thing).y - pt_above.y

	return (f_pos > 0.05)
end

local tpl_cake = {
	_mcl_spawn_food_particles = false,
	_mcl_baseitem = get_candle_item,
	on_destruct = drop_candles,
	collision_box = cake_box,
	description = S("Cake"),
	drawtype = "mesh",
	drop = "",
	groups = {
		attached_node = 1, dig_by_piston = 1, food = 2, handy = 1, no_eat_delay = 1,
		not_in_creative_inventory = 1, unsticky = 1
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not looking_at_candle(clicker, pointed_thing) then
			drop_candles(pos, node, nil, clicker)
			core.do_item_eat(2, ItemStack(), ItemStack("mcl_cake:cake"), clicker, {type = "nothing"})
			core.swap_node(pos, {name = "mcl_cake:cake_6"})
		else
			if core.get_item_group(node.name, "lit_cake") > 0 then
				core.swap_node(pos, {name = node.name:gsub("_lit", ""), param2 = node.param2})
			else
				if core.get_item_group(itemstack:get_name(), "flint_and_steel") > 0 then
					core.swap_node(pos, {name = node.name .. "_lit", param2 = node.param2})
					if not core.is_creative_enabled(clicker:get_player_name()) then
						itemstack:add_wear()
					end
				end
			end
		end
	end,
	palette = "mcl_candles_palette.png",
	paramtype = "light",
	paramtype2 = "color",
	selection_box = cake_box,
	tiles = {
		{
			color = "white",
			name = "[combine:32x32:0,0=cake_top.png:16,0=cake_bottom.png:0,16=cake_side.png"
		},
		"mcl_candles_candle.png",
		"blank.png"
	},
	use_texture_alpha = "clip"
}

core.register_node("mcl_candles:candle_cake", table.merge(tpl_cake, {
	mesh = "mcl_candles_cake.obj",
	tiles = {
		{
			color = "white",
			name = "cake_top.png"
		},
		{
			color = "white",
			name = "cake_bottom.png"
		},
		{
			color = "white",
			name = "cake_side.png"
		},
		"mcl_candles_candle.png"
	}
}))
core.register_node("mcl_candles:candle_cake_lit", table.merge(tpl_cake, {
	_on_wind_charge_hit = function (pos)
		local node = core.get_node(pos)
		node.name = "mcl_candles:candle_cake"
		core.swap_node(pos, node)
	end,
	_on_bottle_place = function(itemstack, placer, pointed_thing)
		local def = itemstack:get_definition()
		if def._mcl_cauldrons_liquid then
			local node = core.get_node(pointed_thing.under)
			mcl_potions.set_node_empty_bottle(itemstack, placer, pointed_thing, "mcl_candles:candle_cake", node.param2)
			core.sound_play("fire_extinguish_flame", {gain = 0.1, max_hear_distance = 16, pos = pointed_thing.under}, true)
		end
	end,
	light_source = 3,
	groups = table.merge(tpl_cake.groups, {lit_cake = 1}),
	mesh = "mcl_candles_cake_lit.obj",
	tiles = {
		{
			color = "white",
			name = "cake_top.png"
		},
		{
			color = "white",
			name = "cake_bottom.png"
		},
		{
			color = "white",
			name = "cake_side.png"
		},
		"mcl_candles_candle.png",
		{
            animation = {
                aspect_h = 16,
				aspect_w = 16,
				length = 1,
				type = "vertical_frames"
            },
			color = "white",
			name = "mcl_candles_flames.png"
        }
	}
}))
