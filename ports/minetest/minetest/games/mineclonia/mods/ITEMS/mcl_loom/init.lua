local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

local dyerecipes = {}
local preview_item_prefix = "mcl_banners:banner_preview_"

for name,pattern in pairs(mcl_banners.patterns) do
	for i=1,3 do for j = 1,3 do
		if pattern[i] and pattern[i][j] == "group:dye" and table.indexof(dyerecipes,name) == -1 and pattern.type ~= "shapeless" then
			table.insert(dyerecipes,name)
			break
		end
	end	end
end

local function get_formspec(pos)
	local patterns = {}
	local count = 0
	if pos then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local color
		local def = minetest.registered_items[inv:get_stack("dye", 1):get_name()]
		local pitem = inv:get_stack("pattern", 1):get_name()
		local pdef = minetest.registered_items[pitem]
		if def and def.groups.dye and def._color then color = def._color end
		local x_len = 0.1
		local y_len = 0.1
		if not inv:is_empty("banner") then
			if color and pdef and pdef._pattern then
				local it = preview_item_prefix .. pdef._pattern .. "_" .. color
				local name = preview_item_prefix .. pdef._pattern .. "-" .. color
				table.insert(patterns,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",0.1,0.1,1,1, it, "item_button_"..name, ""))
			elseif dyerecipes and color then
				for k,v in pairs(dyerecipes) do
					if x_len > 5 then
						y_len = y_len + 1
						x_len = 0.1
					end
					local it = preview_item_prefix .. v .. "_" .. color
					local name = preview_item_prefix .. v .. "-" .. color
					table.insert(patterns,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",x_len,y_len,1,1, it, "item_button_"..name, ""))
					x_len = x_len + 1
					count = count + 1
				end
			end
		end
	end

	local formspec = "formspec_version[4]"..
	"size[11.75,10.425]"..
	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Loom"))) .. "]"..

	mcl_formspec.get_itemslot_bg_v4(0.5,1,1,1,0)..
	mcl_formspec.get_itemslot_bg_v4(0.5,1,1,1,0,"mcl_loom_itemslot_bg_banner.png")..
	"list[context;banner;0.5,1;1,1;]"..
	mcl_formspec.get_itemslot_bg_v4(1.75,1,1,1)..
	mcl_formspec.get_itemslot_bg_v4(1.75,1,1,1,0,"mcl_loom_itemslot_bg_dye.png")..
	"list[context;dye;1.75,1;1,1;]"..
	mcl_formspec.get_itemslot_bg_v4(0.5,2.25,1,1)..
	mcl_formspec.get_itemslot_bg_v4(0.5,2.25,1,1,0,"mcl_loom_itemslot_bg_pattern.png")..
	"list[context;pattern;0.5,2.25;1,1;]"..

	"box[3.275,0.75;5.2,3.5;"..mcl_colors.DARK_GRAY.."]"..
	"scroll_container[3.275,0.75;5.5,3.5;pattern_scroll;vertical;0.1]"..
	table.concat(patterns)..
	"scroll_container_end[]"..
	"scrollbaroptions[arrows=show;thumbsize=30;min=0;max="..(count + 5).."]"..
	"scrollbar[8.5,0.75;0.4,3.5;vertical;pattern_scroll;]"..

	mcl_formspec.get_itemslot_bg_v4(9.5,1.5,1,1)..
	"list[context;output;9.5,1.5;1,1;]"..

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]"..
	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3)..
	"list[current_player;main;0.375,5.1;9,3;9]"..

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1)..
	"list[current_player;main;0.375,9.05;9,1;]"..

	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;sorter]"..
	"listring[current_player;main]"..
	"listring[context;banner]"..
	"listring[current_player;main]"..
	"listring[context;dye]"..
	"listring[current_player;main]"..
	"listring[context;pattern]"..
	"listring[current_player;main]"
	return formspec
end

local function update_formspec(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", get_formspec(pos))
end

local function create_banner(stack, pattern, color)
	local im = stack:get_meta()
	local layers = {}
	local old_layers = im:get_string("layers")
	if old_layers ~= "" then
		layers = minetest.deserialize(old_layers)
	end
	table.insert(layers,{
		pattern = pattern,
		color = "unicolor_"..mcl_dyes.colors[color].unicolor
	})
	im:set_string("description", mcl_banners.make_advanced_banner_description(stack:get_definition().description, layers))
	im:set_string("layers", minetest.serialize(layers))
	return stack
end

local function sort_stack(stack)
	for group, list in pairs({ banner = "banner", dye = "dye", banner_pattern = "pattern" }) do
		if minetest.get_item_group(stack:get_name(), group) > 0 then return list end
	end
end

local function allow_put(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	elseif listname == "output" then return 0
	elseif listname == "banner" and minetest.get_item_group(stack:get_name(),"banner") == 0 then return 0
	elseif listname == "dye" and minetest.get_item_group(stack:get_name(),"dye") == 0 then return 0
	elseif listname == "pattern" and minetest.get_item_group(stack:get_name(),"banner_pattern") == 0 then return 0
	elseif listname == "sorter" then
		local inv = minetest.get_meta(pos):get_inventory()
		local trg = sort_stack(stack, pos)
		if trg then
			local stack1 = ItemStack(stack):take_item()
			if inv:room_for_item(trg, stack) then
				return stack:get_count()
			elseif inv:room_for_item(trg, stack1) then
				return stack:get_stack_max() - inv:get_stack(trg, 1):get_count()
			end
		end
		return 0
	else
		return stack:get_count()
	end
end

minetest.register_node("mcl_loom:loom", {
	description = S("Loom"),
	_tt_help = S("Used to create banner designs"),
	_doc_items_longdesc = S("This is the shepherd villager's work station. It is used to create banner designs."),
	tiles = {
		"loom_top.png", "loom_bottom.png",
		"loom_side.png", "loom_side.png",
		"loom_side.png", "loom_front.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("sorter", 1)
		inv:set_size("banner", 1)
		inv:set_size("dye", 1)
		inv:set_size("pattern", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec", get_formspec(pos))
	end,
	after_dig_node = mcl_util.drop_items_from_meta_container({"banner", "dye", "pattern", "output"}),
	on_rightclick = update_formspec,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end

		if fields then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			for k,v in pairs(fields) do
				if tostring(k) and k:find("^item_button_"..preview_item_prefix) and
				not inv:is_empty("banner") and not inv:is_empty("dye") and inv:is_empty("output") then
					local str = k:gsub("^item_button_","")
					str = str:gsub("^"..preview_item_prefix,"")
					str = str:split("-")
					local pattern = str[1]
					local cdef = minetest.registered_items[inv:get_stack("dye",1):get_name()]
					if not inv:is_empty("pattern") then
						local pdef = minetest.registered_items[inv:get_stack("pattern",1):get_name()]
						pattern = pdef._pattern
						local pattern = inv:get_stack("pattern",1)
						pattern:take_item()
						inv:set_stack("pattern", 1, pattern)
					elseif not mcl_dyes.colors[cdef._color] or table.indexof(dyerecipes,pattern) == -1 then
						pattern = nil
					end
					if pattern then
						local banner = inv:get_stack("banner",1)
						local dye = inv:get_stack("dye",1)
						dye:take_item()
						local cbanner = banner:take_item()
						inv:set_stack("dye", 1, dye)
						inv:set_stack("banner", 1, banner)
						inv:set_stack("output", 1, create_banner(cbanner,pattern,cdef._color))
					end
				end
			end
		end
		update_formspec(pos)
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "sorter" then return 0 end
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if from_list == "sorter" or to_list == "sorter" then return 0 end
		local inv = minetest.get_meta(pos):get_inventory()
		local stack = inv:get_stack(from_list,from_index)
		return allow_put(pos, to_list, to_index, stack, player)
	end,
	allow_metadata_inventory_put = allow_put,
	on_metadata_inventory_move = update_formspec,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "sorter" then
			local inv = minetest.get_meta(pos):get_inventory()
			inv:add_item(sort_stack(stack, pos), stack)
			inv:set_stack("sorter", 1, ItemStack(""))
		end
		update_formspec(pos)
	end,
	on_metadata_inventory_take = update_formspec,
})

minetest.register_craft({
	output = "mcl_loom:loom",
	recipe = {
		{ "", "", "" },
		{ "mcl_mobitems:string", "mcl_mobitems:string", "" },
		{ "group:wood", "group:wood", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_loom:loom",
	burntime = 15,
})

minetest.register_lbm({
	label = "Update Loom formspecs and invs to allow new sneak+click behavior",
	name = "mcl_loom:update_coolsneak",
	nodenames = { "mcl_loom:loom" },
	run_at_every_load = false,
	action = function(pos, node)
		minetest.get_meta(pos):get_inventory():set_size("sorter", 1)
		update_formspec(pos)
	end,
})
