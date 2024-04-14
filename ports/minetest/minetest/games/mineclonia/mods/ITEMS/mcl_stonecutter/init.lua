--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||

mcl_stonecutter = {}

local S = minetest.get_translator("mcl_stonecutter")
local C = minetest.colorize
local F = minetest.formspec_escape

local recipe_yield = { --maps itemgroup to the respective recipe yield, default is 1
	["slab"] = 2,
	["cut_copper"] = 4,
}

local recipes = {}
local yields = {}

function mcl_stonecutter.refresh_recipes()
	recipes = {}
	yields = {}
	for result,resultdef in pairs(minetest.registered_nodes) do
		if resultdef._mcl_stonecutter_recipes then
			local yield = 1
			for k,v in pairs(recipe_yield) do if minetest.get_item_group(result,k) > 0 then yield = yield * v end end
			for _,recipe in pairs(resultdef._mcl_stonecutter_recipes) do
				if minetest.get_item_group(recipe,"stonecuttable") > 0 and minetest.get_item_group(result,"not_in_creative_inventory") == 0 then
					if not recipes[recipe] then recipes[recipe] = {} end
					table.insert(recipes[recipe],result)
					yields[result] = yield
				end
			end
		end
	end
end

minetest.register_on_mods_loaded(mcl_stonecutter.refresh_recipes)

-- formspecs
local function show_stonecutter_formspec(input)
	local cut_items = {}
	local x_len = 0.1
	local y_len = 0.1
	local count = 0
	if recipes[input] then
		for k,v in pairs(recipes[input]) do
			if x_len > 5 then
				y_len = y_len + 1
				x_len = 0.1
			end
			table.insert(cut_items,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",x_len,y_len,1,1, v, "item_button_"..v, ""))
			x_len = x_len + 1
			count = count + 1
		end
	end

	local formspec = "formspec_version[4]"..
	"size[11.75,10.425]"..
	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Stonecutter"))) .. "]"..

	mcl_formspec.get_itemslot_bg_v4(1.375,1.5,1,1,0)..
	--mcl_formspec.get_itemslot_bg_v4(0.5,1,1,1,0,"mcl_loom_itemslot_bg_banner.png")..
	"list[context;input;1.375,1.5;1,1;]"..

	"box[3.275,0.75;5.2,3.5;"..mcl_colors.DARK_GRAY.."]"..
	"scroll_container[3.275,0.75;5.5,3.5;recipe_scroll;vertical;0.1]"..
	table.concat(cut_items)..
	"scroll_container_end[]"..
	"scrollbaroptions[arrows=show;thumbsize=30;min=0;max="..(count).."]"..
	"scrollbar[8.5,0.75;0.4,3.5;vertical;recipe_scroll;]"..

	mcl_formspec.get_itemslot_bg_v4(9.5,1.5,1,1)..
	"list[context;output;9.5,1.5;1,1;]"..

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]"..
	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3)..
	"list[current_player;main;0.375,5.1;9,3;9]"..

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1)..
	"list[current_player;main;0.375,9.05;9,1;]"..

	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

	return formspec
end

-- Updates the formspec
local function update_stonecutter_slots(pos,str)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local name = input:get_name()
	if minetest.get_item_group(name,"stonecuttable") > 0 then

		meta:set_string("formspec", show_stonecutter_formspec(name))
	else
		meta:set_string("formspec", show_stonecutter_formspec(nil))
	end

	if recipes[name] and table.indexof(recipes[name],str) ~= -1 and yields[str] then
		local cut_item = ItemStack(str)
		cut_item:set_count(yields[str])
		local output = inv:get_stack("output",1)
		local input = inv:get_stack("input",1)
		if output:get_name() == cut_item:get_name() then
			cut_item:set_count(math.min(output:get_count() + yields[output:get_name()],input:get_count() * yields[str],output:get_stack_max()))
		end
		inv:set_stack("output", 1, cut_item)
	else
		inv:set_stack("output", 1, "")
	end
end

minetest.register_node("mcl_stonecutter:stonecutter", {
	description = S("Stone Cutter"),
	_tt_help = S("Used to cut stone like materials."),
	_doc_items_longdesc = S("Stonecutters are used to create stairs and slabs from stone like materials. It is also the jobsite for the Stone Mason Villager."),
	tiles = {
		"mcl_stonecutter_top.png",
		"mcl_stonecutter_bottom.png",
		"mcl_stonecutter_side.png",
		"mcl_stonecutter_side.png",
		{name="mcl_stonecutter_saw.png",
		animation={
			type="vertical_frames",
			aspect_w=16,
			aspect_h=16,
			length=1
		}},
		{name="mcl_stonecutter_saw.png",
		animation={
			type="vertical_frames",
			aspect_w=16,
			aspect_h=16,
			length=1
		}}
	},
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey=1, material_stone=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5}, -- NodeBox1
			{-0.4375, 0.0625, 0, 0.4375, 0.5, 0}, -- NodeBox2
		}
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = mcl_util.drop_items_from_meta_container({"input"}),
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			if listname == "output" then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local input = inv:get_stack("input", 1)
				return math.min((input:get_count() * yields[stack:get_name()]),stack:get_stack_max())
			end
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif to_list == "output" then
			return 0
		elseif from_list == "output" and to_list == "input" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:get_stack(to_list, to_index):is_empty() then
				return count
			else
				return 0
			end
		else
			return count
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if from_list == "output" and to_list == "input" then
			local inv = meta:get_inventory()
			for i=1, inv:get_size("input") do
				if i ~= to_index then
					local istack = inv:get_stack("input", i)
					istack:set_count(math.max(0, istack:get_count() - count))
					inv:set_stack("input", i, istack)
				end
			end
		end
		update_stonecutter_slots(pos)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		update_stonecutter_slots(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local input = inv:get_stack("input", 1)
			input:take_item(math.ceil(stack:get_count() / yields[stack:get_name()]))
			inv:set_stack("input", 1, input)
		end
		update_stonecutter_slots(pos)
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
		local form = show_stonecutter_formspec()
		meta:set_string("formspec", form)
	end,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			update_stonecutter_slots(pos)
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields then
			for k,v in pairs(fields) do
				if tostring(k) then
					local str = k:gsub("^item_button_","")
					local def = minetest.registered_nodes[str]
					if def and def._mcl_stonecutter_recipes then
						update_stonecutter_slots(pos, str)
					end
				end
			end
		end
	end,
})

minetest.register_craft({
	output = "mcl_stonecutter:stonecutter",
	recipe = {
		{ "", "", "" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:stone", "mcl_core:stone", "mcl_core:stone" },
	}
})
