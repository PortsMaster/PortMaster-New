mcl_craftguide = {}

local player_data = {}

-- Caches
local init_items    = {}
local searches      = {}
local usages_cache  = {}

local progressive_mode = core.settings:get_bool("mcl_craftguide_progressive_mode", true)
local strict_mode = progressive_mode or core.settings:get_bool("mcl_craftguide_strict_mode", true)
local tooltip_append_itemname = core.settings:get_bool("tooltip_append_itemname", false)

local C = core.colorize
local F = core.formspec_escape
local S = core.get_translator("mcl_craftguide")

local DEFAULT_SIZE = 10
local MIN_LIMIT, MAX_LIMIT = 10, 12
DEFAULT_SIZE = math.min(MAX_LIMIT, math.max(MIN_LIMIT, DEFAULT_SIZE))

local GRID_LIMIT = 5

local PLAYER_PROGRESS_KEY = "mcl_craftguide:progress"

local FMT = {
	box     = "box[%f,%f;%f,%f;%s]",
	label   = "label[%f,%f;%s]",
	image   = "image[%f,%f;%f,%f;%s]",
	button  = "button[%f,%f;%f,%f;%s;%s]",
	tooltip = "tooltip[%s;%s]",
	item_image = "item_image[%f,%f;%f,%f;%s]",
	image_button = "image_button[%f,%f;%f,%f;%s;%s;%s]",
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
}

local group_stereotypes = {
	wood         = "mcl_trees:wood_oak",
	stone        = "mcl_core:stone",
	sand         = "mcl_core:sand",
	wool         = "mcl_wool:white",
	carpet       = "mcl_wool:white_carpet",
	dye          = "mcl_dyes:red",
	water_bucket = "mcl_buckets:bucket_water",
	flower	     = "mcl_flowers:dandelion",
	mushroom     = "mcl_mushrooms:mushroom_brown",
	wood_slab    = "mcl_stairs:slab_wood",
	wood_stairs  = "mcl_stairs:stairs_wood",
	coal         = "mcl_core:coal_lump",
	shulker_box  = "mcl_chests:violet_shulker_box",
	quartz_block = "mcl_nether:quartz_block",
	banner       = "mcl_banners:banner_item_white",
	mesecon_conductor_craftable = "mesecons:wire_00000000_off",
	purpur_block = "mcl_end:purpur_block",
	normal_sandstone = "mcl_core:sandstone",
	red_sandstone = "mcl_core:redsandstone",
	compass      = mcl_compass.stereotype,
	clock        = mcl_clock.sterotype,
}

local group_names = {
	shulker_box = S("Any shulker box"),
	wool = S("Any wool"),
	wood = S("Any wood planks"),
	tree = S("Any wood"),
	sand = S("Any sand"),
	normal_sandstone = S("Any normal sandstone"),
	red_sandstone = S("Any red sandstone"),
	carpet = S("Any carpet"),
	dye = S("Any dye"),
	water_bucket = S("Any water bucket"),
	flower = S("Any flower"),
	mushroom = S("Any mushroom"),
	wood_slab = S("Any wooden slab"),
	wood_stairs = S("Any wooden stairs"),
	coal = S("Any coal"),
	quartz_block = S("Any kind of quartz block"),
	purpur_block = S("Any kind of purpur block"),
	stonebrick = S("Any stone bricks"),
	stick = S("Any stick"),
}

-- caches recipes using groups
--
-- key: group specification of the form `group:group1,group2,...`
-- value: a list of recipes
--
-- the progressive recipe unlocking assumes that this will not change after a player joins
local group_cache = {}

local custom_crafts, craft_types = {}, {}

function mcl_craftguide.register_craft_type(name, def)
	local func = "mcl_craftguide.register_craft_type(): "
	assert(name, func .. "'name' field missing")
	assert(def.description, func .. "'description' field missing")
	assert(def.icon, func .. "'icon' field missing")

	craft_types[name] = def
end

function mcl_craftguide.register_craft(def)
	local func = "mcl_craftguide.register_craft(): "
	assert(def.type, func .. "'type' field missing")
	assert(def.width, func .. "'width' field missing")
	assert(def.output, func .. "'output' field missing")
	assert(def.items, func .. "'items' field missing")

	local _, _, item_name = string.find(def.output, "^([^%s]+)")

	if custom_crafts[item_name] then
		table.insert(custom_crafts[item_name], def)
	else
		custom_crafts[item_name] = {def}
	end
end

local recipe_filters = {}

function mcl_craftguide.add_recipe_filter(name, f)
	local func = "mcl_craftguide.add_recipe_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	recipe_filters[name] = f
end

function mcl_craftguide.remove_recipe_filter(name)
	recipe_filters[name] = nil
end

function mcl_craftguide.set_recipe_filter(name, f)
	local func = "mcl_craftguide.set_recipe_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	recipe_filters = {[name] = f}
end

function mcl_craftguide.get_recipe_filters()
	return recipe_filters
end

local function apply_recipe_filters(recipes, player)
	for _, filter in pairs(recipe_filters) do
		recipes = filter(recipes, player)
	end

	return recipes
end

local search_filters = {}

function mcl_craftguide.add_search_filter(name, f)
	local func = "mcl_craftguide.add_search_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	search_filters[name] = f
end

function mcl_craftguide.remove_search_filter(name)
	search_filters[name] = nil
end

function mcl_craftguide.get_search_filters()
	return search_filters
end

local formspec_elements = {}

function mcl_craftguide.add_formspec_element(name, def)
	local func = "mcl_craftguide.add_formspec_element(): "
	assert(def.element, func .. "'element' field not defined")
	assert(def.type, func .. "'type' field not defined")
	assert(FMT[def.type], func .. "'" .. def.type .. "' type not supported by the API")

	formspec_elements[name] = {
		type    = def.type,
		element = def.element,
		action  = def.action,
	}
end

function mcl_craftguide.remove_formspec_element(name)
	formspec_elements[name] = nil
end

function mcl_craftguide.get_formspec_elements()
	return formspec_elements
end

local function item_has_groups(item_groups, groups)
	for i = 1, #groups do
		local group = groups[i]
		if not item_groups[group] or item_groups[group] == 0 then
			return
		end
	end

	return true
end

local function extract_groups(str)
	return string.split(string.sub(str, 7), ",")
end

local function get_player_data(name, init)
	if not player_data[name] and init ~= false then
		player_data[name] = {
			filter  = "",
			pagenum = 1,
			iX      = DEFAULT_SIZE,
			items   = init_items,
			items_raw = init_items,
			lang_code = core.get_player_information(name).lang_code or 'en',
		}
	end

	return player_data[name]
end

local function get_item_recipes(item_name)
	local recipes = core.get_all_craft_recipes(item_name) or {}
	if custom_crafts[item_name] then
		for _, v in pairs(custom_crafts[item_name]) do
			recipes[#recipes + 1] = v
		end
	end

	return recipes
end

local function get_filtered_items(player)
	local items, c = {}, 0

	for i = 1, #init_items do
		local item = init_items[i]
		local recipes = get_item_recipes(item)
		local usages = usages_cache[item]

		if recipes and #apply_recipe_filters(recipes, player) > 0 or
		   usages and #apply_recipe_filters(usages, player) > 0 then
			c = c + 1
			items[c] = item
		end
	end

	return items
end

local function get_recipes(item, data, player)
	item = core.registered_aliases[item] or item
	local recipes = get_item_recipes(item)
	local usages = usages_cache[item]

	if recipes then
		recipes = apply_recipe_filters(recipes, player)
	end

	local no_recipes = not recipes or #recipes == 0
	if no_recipes and not usages then
		return
	elseif usages and no_recipes then
		data.show_usages = true
	end

	if data.show_usages then
		recipes = usages_cache[item] and table.copy(usages_cache[item]) or {}

		local item_groups = core.registered_items[item].groups
		local required_groups
		for cache_group_name, group_cache in pairs(group_cache) do
			required_groups = extract_groups(cache_group_name)
			if item_has_groups(item_groups, required_groups) then
				recipes = table.insert_all(recipes, group_cache)
			end
		end

		if mcl_util.is_fuel(item) then
			table.insert(recipes, {type = "fuel", width = 1, items = {item}})
		end

		if recipes == nil or #recipes == 0 then
			return
		end

		recipes = apply_recipe_filters(recipes, player)
	end

	return recipes
end

local function groups_to_item(groups)
	if #groups == 1 then
		local group = groups[1]
		local def_gr = "mcl_core:" .. group

		if group_stereotypes[group] then
			return group_stereotypes[group]
		elseif core.registered_items[def_gr] then
			return def_gr
		end
	end

	for name, def in pairs(core.registered_items) do
		if item_has_groups(def.groups, groups) then
			return name
		end
	end

	return ""
end

local function get_tooltip(item, groups, cooktime, burntime, fs_name)
	local tooltip

	if groups then
		local gcol = mcl_colors.LIGHT_PURPLE
		if #groups == 1 and not tooltip_append_itemname then
			local g = group_names[groups[1]]
			local groupstr
			-- Treat the groups “compass” and “clock” as fake groups
			-- and just print the normal item name without special formatting
			if groups[1] == "compass" or groups[1] == "clock" then
				groupstr = core.registered_items[item].description
			elseif g then
				-- Use the special group name string
				groupstr = C(gcol, g)
			else
				--[[ Fallback: Generic group explanation: This always
				works, but the internally used group name (which
				looks ugly) is exposed to the user. ]]
				groupstr = C(gcol, groups[1])
				groupstr = S("Any item belonging to the @1 group", groupstr)
			end
			tooltip = groupstr
		else

			local groupstr, c = {}, 0
			for i = 1, #groups do
				c = c + 1
				groupstr[c] = C(gcol, groups[i])
			end

			tooltip = S("Any item belonging to the groups: @1", table.concat(groupstr, ", "))
		end
	else
		local def = core.registered_items[item]
		tooltip = def and def.description or "<unknown>"
	end

	if not groups and cooktime then
		tooltip = tooltip .. "\n" ..
			S("Cooking time: @1", C(mcl_colors.YELLOW, cooktime))
	end

	if not groups and burntime and burntime ~= 0 then
		tooltip = tooltip .. "\n" ..
			S("Burning time: @1", C(mcl_colors.YELLOW, burntime))
	end

	if tooltip_append_itemname and not groups then
		tooltip = tooltip .. "\n[" .. item .. "]"
	end

	return string.format(FMT.tooltip, fs_name or item, F(tooltip))
end

local function get_recipe_fs(data, iY, player)
	local fs = {}
	local recipe = data.recipes[data.rnum]
	local width = recipe.width
	local xoffset = data.iX / 2.15
	local cooktime, shapeless

	if recipe.type == "cooking" then
		cooktime, width = width, 1
	elseif width == 0 then
		shapeless = true
		width = #recipe.items <= 4 and 2 or 3
	end

	local rows = math.ceil(table.maxn(recipe.items) / width)
	local rightest, btn_size = 0, 1.1
	local s_btn_size
	local label1 = data.show_usages and S("Usages") or S("Recipes")
	local label2 = string.format("%u / %u", data.rnum, #data.recipes)
	local text_y = iY + 3.3 + (0.8 / 4)
	local arrow_btn_w = 0.8
	local arrow_btn2_x = data.iX - 2.6 + 1.5
	local label2_length = (#label2 + 2) * 0.11
	local label2_x = arrow_btn2_x - label2_length
	local arrow_btn1_x = label2_x - arrow_btn_w
	local label1_x = arrow_btn1_x - (data.show_usages and 0.8 or 1.20)

	if #data.recipes > 1 then
		fs[#fs + 1] = "label["..label1_x..",".. text_y ..";"..label1.."]"..
			"image_button["..arrow_btn1_x..","..iY + 3.3 ..";"..arrow_btn_w..","..arrow_btn_w..";craftguide_prev_icon.png;prev_alternate;]"..
			"label["..label2_x..",".. text_y ..";"..label2.."]" ..
			"image_button["..arrow_btn2_x..","..iY + 3.3 ..";"..arrow_btn_w..","..arrow_btn_w..";craftguide_next_icon.png;next_alternate;]"
	end

	if width > GRID_LIMIT or rows > GRID_LIMIT then
		fs[#fs + 1] = string.format(FMT.label,
			(data.iX / 2) - 2,
			iY + 2.2,
			F(S("Recipe is too big to be displayed (@1×@2)", width, rows)))

		return table.concat(fs)
	end

	for i, item in pairs(recipe.items) do
		local X = math.ceil((i - 1) % width + xoffset - width) - (0.2)
		local Y = math.ceil(i / width + (iY + 2) - math.min(2, rows))

		if width > 3 or rows > 3 then
			btn_size = width > 3 and 3 / width or 3 / rows
			s_btn_size = btn_size
			X = btn_size * (i % width) + xoffset - 2.65
			Y = btn_size * math.floor((i - 1) / width) + (iY + 3) - math.min(2, rows)
		end

		if X > rightest then
			rightest = X
		end

		local groups
		if string.sub(item, 1, 6) == "group:" then
			groups = extract_groups(item)
			item = groups_to_item(groups)
		end

		local label = ""
		if groups and (#groups >= 1 and groups[1] ~= "compass" and groups[1] ~= "clock") then
			label = "\nG"
		end

		fs[#fs + 1] = string.format(FMT.item_image_button,
			X,
			Y + (0.2),
			btn_size,
			btn_size,
			item,
			string.match(item, "%S*"),
			F(label))

		local burntime = mcl_util.get_burntime(item)

		if groups or cooktime or burntime ~= 0 or tooltip_append_itemname then
			fs[#fs + 1] = get_tooltip(item, groups, cooktime, burntime)
		end
	end

	local custom_recipe = craft_types[recipe.type]

	if custom_recipe or shapeless or recipe.type == "cooking" then
		local icon = custom_recipe and custom_recipe.icon or
				 shapeless and "shapeless" or "furnace"

		if recipe.type == "cooking" then
			icon = "craftguide_furnace.png"
		elseif not custom_recipe then
			icon = string.format("craftguide_%s.png", icon)
		end

		fs[#fs + 1] = string.format(FMT.image,
			rightest + 1.2,
			iY + 1.7,
			0.5,
			0.5,
			icon)

		local tooltip = custom_recipe and custom_recipe.description or
				shapeless and S("Shapeless") or S("Cooking")

		fs[#fs + 1] = string.format("tooltip[%f,%f;%f,%f;%s]",
			rightest + 1.2,
			iY + 1.7,
			0.5,
			0.5,
			F(tooltip))
	end

	local arrow_X  = rightest + (s_btn_size or 1.1)
	local output_X = arrow_X + 0.9

	fs[#fs + 1] = string.format(FMT.image,
		arrow_X,
		iY + 2.35,
		0.9,
		0.7,
		"craftguide_arrow.png")

	if recipe.type == "fuel" then
		fs[#fs + 1] = string.format(FMT.image,
			output_X,
			iY + 2.18,
			1.1,
			1.1,
			"mcl_craftguide_fuel.png")
	else
		local output_name = string.match(recipe.output, "%S+")
		local burntime = mcl_util.get_burntime(output_name)

		fs[#fs + 1] = string.format(FMT.item_image_button,
			output_X,
			iY + 2.2,
			1.1,
			1.1,
			recipe.output,
			F(output_name),
			"")

		if burntime ~= 0 or tooltip_append_itemname then
			fs[#fs + 1] = get_tooltip(output_name, nil, nil, burntime)
		end

		if burntime ~= 0 then
			fs[#fs + 1] = string.format(FMT.image,
				output_X + 1,
				iY + 2.33,
				0.6,
				0.4,
				"craftguide_arrow.png")

			fs[#fs + 1] = string.format(FMT.image,
				output_X + 1.6,
				iY + 2.18,
				0.6,
				0.6,
				"mcl_craftguide_fuel.png")
		end
		-- show the button crafting button if recipe items are in
		-- inventory and the recipe fits the available crafting grid
		--
		-- note that size of craft inv is only set when the
		-- corresponding formspec is opened, so it can't be used here
		--
		-- TODO: unhardcode craft grid sizes
		local has_table = mcl_crafting_table.has_crafting_table(player)
		local width = has_table and 3 or 2
		local height = has_table and 3 or 2
		if recipe.type == "normal" and mcl_inventory.get_recipe_groups(player, recipe, width, height) then
			fs[#fs + 1] = string.format("image_button[%f,%f;%f,%f;%s;%s_inv;%s]",
				output_X + 2.7,
				iY + 2.2,
				1.1,
				1.1,
				"mcl_crafting_guide_craft.png",
				"craft","craft")
			fs[#fs + 1] = "tooltip[craft;To crafting table]"
		end
	end

	return table.concat(fs)
end

local function make_formspec(name)
	local data = get_player_data(name)
	local iY = data.iX - 5
	local ipp = data.iX * iY

	data.pagemax = math.max(1, math.ceil(#data.items / ipp))

	local fs = {}

	fs[#fs + 1] = string.format("size[%f,%f;]", data.iX - 0.35, iY + 4)

	fs[#fs + 1] = "background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"

	fs[#fs + 1] = string.format([[ tooltip[size_inc;%s]
					tooltip[size_dec;%s] ]],
		F(S("Increase window size")),
		F(S("Decrease window size")))

	fs[#fs + 1] = string.format([[
		image_button[%f,0.12;0.8,0.8;craftguide_zoomin_icon.png;size_inc;]
		image_button[%f,0.12;0.8,0.8;craftguide_zoomout_icon.png;size_dec;] ]],
		data.iX * 0.47,
		data.iX * 0.47 + 0.6)

	fs[#fs + 1] = [[
		image_button[2.4,0.12;0.8,0.8;craftguide_search_icon.png;search;]
		image_button[3.05,0.12;0.8,0.8;craftguide_clear_icon.png;clear;]
		field_close_on_enter[filter;false]
	]]

	fs[#fs + 1] = string.format([[ tooltip[search;%s]
				 tooltip[clear;%s]
				 tooltip[prev;%s]
				 tooltip[next;%s] ]],
		F(S("Search")),
		F(S("Reset")),
		F(S("Previous page")),
		F(S("Next page")))

	fs[#fs + 1] = string.format("label[%f,%f;%s]",
		data.iX - 2.2,
		0.22,
		F(C("#383838", string.format("%s / %u", data.pagenum, data.pagemax))))

	fs[#fs + 1] = string.format([[
		image_button[%f,0.12;0.8,0.8;craftguide_prev_icon.png;prev;]
		image_button[%f,0.12;0.8,0.8;craftguide_next_icon.png;next;] ]],
		data.iX - 3.1,
		(data.iX - 1.2) - (data.iX >= 11 and 0.08 or 0))

	fs[#fs + 1] = string.format("field[0.3,0.32;2.5,1;filter;;%s]", F(data.filter))

	if #data.items == 0 then
		local no_item = S("No item to show")
		local pos = (data.iX / 2) - 1

		if next(recipe_filters) and #init_items > 0 and data.filter == "" then
			no_item = S("Collect items to reveal more recipes")
			pos = pos - 1
		end

		fs[#fs + 1] = string.format(FMT.label, pos, 2, F(no_item))
	end

	local first_item = (data.pagenum - 1) * ipp
	for i = first_item, first_item + ipp - 1 do
		local item = data.items[i + 1]
		if not item then
			break
		end

		local X = i % data.iX
		local Y = (i % ipp - X) / data.iX + 1

		fs[#fs + 1] = string.format("item_image_button[%f,%f;%f,%f;%s;%s_inv;]",
			X - ((X * 0.05)),
			Y,
			1.1,
			1.1,
			item,
			item)
		if tooltip_append_itemname then
			fs[#fs + 1] = get_tooltip(item, nil, nil, nil, item .. "_inv")
		end
	end

	if data.recipes and #data.recipes > 0 then
		fs[#fs + 1] = get_recipe_fs(data, iY, core.get_player_by_name(name))
	end

	for elem_name, def in pairs(formspec_elements) do
		local element = def.element(data)
		if element then
			if string.find(def.type, "button") then
				table.insert(element, #element, elem_name)
			end

			fs[#fs + 1] = string.format(FMT[def.type], unpack(element))
		end
	end
	return table.concat(fs)
end
mcl_craftguide.make_formspec = make_formspec

local function show_fs(_, name)
	core.show_formspec(name, "mcl_craftguide", make_formspec(name))
end

mcl_craftguide.add_search_filter("groups", function(item, groups)
	local itemdef = core.registered_items[item]

	for i = 1, #groups do
		local group = groups[i]
		if not itemdef.groups[group] then
			return
		end
	end

	return true
end)

local function search(data)
	local filter = data.filter

	if searches[filter] then
		data.items = searches[filter]
		return
	end

	local filtered_list, c = {}, 0
	local extras = "^(.-)%+([%w_]+)=([%w_,]+)"
	local search_filter = next(search_filters) and string.match(filter, extras)
	local filters = {}

	if search_filter then
		for filter_name, values in string.gmatch(filter, string.sub(extras, 6, -1)) do
			if search_filters[filter_name] then
				values = string.split(values, ",")
				filters[filter_name] = values
			end
		end
	end

	for i = 1, #data.items_raw do
		local item = data.items_raw[i]
		local def  = core.registered_items[item]
		if def then
			local desc = string.lower(core.get_translated_string(data.lang_code, def.description))
			local search_in = item .. desc
			local to_add

			if search_filter then
				for filter_name, values in pairs(filters) do
					local func = search_filters[filter_name]
					to_add = func(item, values) and (search_filter == "" or
						string.find(search_in, search_filter, 1, true))
				end
			else
				to_add = string.find(search_in, filter, 1, true)
			end

			if to_add then
				c = c + 1
				filtered_list[c] = item
			end
		end
	end

	if not next(recipe_filters) then
		-- Cache the results only if searched 2 times
		if searches[filter] == nil then
			searches[filter] = false
		else
			searches[filter] = filtered_list
		end
	end

	data.items = filtered_list
end

local function reset_data(data)
	data.filter      = ""
	data.pagenum     = 1
	data.rnum        = 1
	data.query_item  = nil
	data.show_usages = nil
	data.recipes     = nil
	data.items       = data.items_raw
end

local function get_init_items()
	local recipes
	local used_items
	for item_name, item in pairs(core.registered_items) do
		recipes = get_item_recipes(item_name)

		if #recipes > 0 and item_name ~= "" then
			table.insert(init_items, item_name)
			for _, recipe in pairs(recipes) do
				if recipe then
					used_items = {}
					for _, ingredient in pairs(recipe.items) do
						_, _, ingredient = string.find(ingredient, "^([^%s]+)") -- handles edge case where the igredient is an item string
						ingredient = core.registered_aliases[ingredient] or ingredient
						if not used_items[ingredient] then
							used_items[ingredient] = true

							if string.sub(ingredient, 1, 6) == "group:" then
								group_cache[ingredient] = group_cache[ingredient] or {}
								table.insert(group_cache[ingredient], recipe)
							elseif core.registered_items[ingredient] then
								usages_cache[ingredient] = usages_cache[ingredient] or {}
								table.insert(usages_cache[ingredient], recipe)
							else
								core.log("warning", "[mcl_craftguide] ingredient \"" .. ingredient .. "\" doesn't exist")
							end
						end
					end
				end
			end
		end
	end

	table.sort(init_items)

	for _, cache in pairs(usages_cache) do
		table.sort(cache,
		function(a, b)
			return a.output > b.output
		end)
	end
end

local function on_receive_fields(player, fields)
	local name = player:get_player_name()
	local data = get_player_data(name)

	for elem_name, def in pairs(formspec_elements) do
		if fields[elem_name] and def.action then
			return def.action(player, data)
		end
	end

	if fields.clear then
		reset_data(data)
		show_fs(player, name)

	elseif fields.prev_alternate then
		if not data.recipes or #data.recipes == 1 then
			return
		end

		local num_next = data.rnum - 1
		data.rnum = data.recipes[num_next] and num_next or #data.recipes
		show_fs(player, name)

	elseif fields.next_alternate then
		if not data.recipes or #data.recipes == 1 then
			return
		end

		local num_next = data.rnum + 1
		data.rnum = data.recipes[num_next] and num_next or 1
		show_fs(player, name)

	elseif (fields.key_enter_field == "filter" or fields.search) and
			fields.filter ~= "" then
		local fltr = string.lower(fields.filter)
		if data.filter == fltr then
			return
		end

		data.filter = fltr
		data.pagenum = 1
		search(data)
		show_fs(player, name)

	elseif fields.prev or fields.next then
		if data.pagemax == 1 then
			return
		end

		data.pagenum = data.pagenum - (fields.prev and 1 or -1)

		if data.pagenum > data.pagemax then
			data.pagenum = 1
		elseif data.pagenum == 0 then
			data.pagenum = data.pagemax
		end

		show_fs(player, name)

	elseif (fields.size_inc and data.iX < MAX_LIMIT) or
			(fields.size_dec and data.iX > MIN_LIMIT) then
		data.pagenum = 1
		data.iX = data.iX + (fields.size_inc and 1 or -1)
		show_fs(player, name)
	elseif fields.craft_inv and fields.craft_inv == "craft" then
		local recipe = data.recipes and data.recipes[data.rnum]
		if not recipe then
			return
		elseif mcl_crafting_table.has_crafting_table(player) then
			mcl_crafting_table.show_crafting_form(player)
		else
			local count = table.count(recipe.items, function(_,v) return not ItemStack(v):is_empty()  end)
			if recipe.width <= 2 and count <= 4 then
				mcl_inventory.show_inventory(player)
			else
				return
			end
		end
		mcl_inventory.to_craft_grid(player, recipe)
	else
		local item
		for field, _ in pairs(fields) do
			if string.find(field, ":") then
				item = field
				break
			end
		end

		if not item then
			return
		elseif string.sub(item, -4) == "_inv" then
			item = string.sub(item, 1, -5)
		end

		if item ~= data.query_item then
			data.show_usages = nil
		else
			data.show_usages = not data.show_usages
		end

		local recipes = get_recipes(item, data, player)
		if not recipes then
			return
		end

		data.query_item = item
		data.recipes    = recipes
		data.rnum       = 1

		show_fs(player, name)
	end
end

core.after(0, get_init_items)


core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mcl_craftguide" then
		on_receive_fields(player, fields)
	elseif fields.__mcl_craftguide then
		mcl_craftguide.show(player:get_player_name())
	end
end)

if progressive_mode then
	local function reveal_item(item, progress)
		item = item and core.registered_aliases[item] or item
		local def = item and core.registered_items[item]
		if not def or item == "" or progress[item] then return false end
		progress[item] = 1
		for group_spec, _ in pairs(group_cache) do
			local groups = extract_groups(group_spec)
			local has_groups = item_has_groups(def.groups, groups)
			if has_groups then
				progress[group_spec] = true
			end
		end
		return true
	end

	-- Initialize progress from list of unlocked items in player meta if necessary
	local function get_progress(player, init)
		local name = player:get_player_name()
		local data = get_player_data(name)

		if not data.progress and init ~= false then
			data.progress = {}
			local progress = data.progress
			local meta = player:get_meta()

			if meta:contains("inv_items") then
				-- compat
				core.log("none", "[mcl_craftguide] converting old progress data for player '" .. name .. "'")
				local data = meta:get_string("inv_items")
				meta:set_string(PLAYER_PROGRESS_KEY, data)
				meta:set_string("inv_items", "")
			end

			local inv_items
			if meta:contains(PLAYER_PROGRESS_KEY) then
				local data = meta:get_string(PLAYER_PROGRESS_KEY)

				inv_items = core.deserialize(data)

				if not inv_items or type(inv_items) ~= "table" then
					core.log("error", "[mcl_craftguide] resetting corrupt player progress for player '" .. name .. "'")
					meta:set_string(PLAYER_PROGRESS_KEY, "")
					meta:set_string(PLAYER_PROGRESS_KEY .. "_corrupt", data)

					inv_items = nil
				end
			end

			-- unlock items, computing unlocked groups
			for _, item in pairs(inv_items or {}) do
				reveal_item(item, progress)
			end
		end

		return data.progress
	end

	-- Store list of unlocked items into player metadata.
	--
	-- Groups are not stored, they need to be rebuilt each time, because
	-- relevant group specifications as well as item groups may change on
	-- game/mod updates.
	local function save_progress(player)
		local progress = get_progress(player, false)

		if not progress then
			-- nothing to do
			return
		end

		local inv_items = {}
		local c = 0

		for item, value in pairs(progress) do
			if value == 1 then
				c = c + 1
				inv_items[c] = item
			end
		end

		if c > 0 then
			local meta = player:get_meta()
			meta:set_string(PLAYER_PROGRESS_KEY, core.serialize(inv_items))
		else
			-- don't write metadata if c == 0, because chances are
			-- high that initialization was interrupted
			core.log("none", "[mcl_craftguide] not saving empty progress for player '" .. player:get_player_name() .. "'")
		end
	end

	local function reveal_inv_list(list, progress)
		if not list then return false end
		local changed = false
		for _, stack in pairs(list) do
			changed = changed or reveal_item(stack:get_name(), progress)
		end
		return changed
	end

	local function recipe_unlocked(recipe, progress, show_all)
		for _, item in pairs(recipe.items) do
			if not ((core.registered_items[item] or group_cache[item]) and (show_all or progress[item])) then
				return
			end
		end

		return true
	end

	local function progressive_filter(recipes, player)
		local show_all = core.is_creative_enabled(player:get_player_name())
		local progress = get_progress(player)

		local filtered, c = {}, 0
		for i = 1, #recipes do
			local recipe = recipes[i]
			if recipe_unlocked(recipe, progress, show_all) then
				c = c + 1
				filtered[c] = recipe
			end
		end

		return filtered
	end

	-- Workaround. Need engine support to detect when a player inventory
	-- changes instead.
	local function poll_new_items(player)
		local inv = player:get_inventory()
		local progress = get_progress(player)

		local changed = reveal_inv_list(inv:get_list("main"), progress)
		changed = changed or reveal_inv_list(inv:get_list("armor"), progress)
		changed = changed or reveal_inv_list(inv:get_list("offhand"), progress)

		if changed then
			save_progress(player)
		end
	end

	mcl_player.register_globalstep_slow(poll_new_items)

	mcl_craftguide.add_recipe_filter("Default progressive filter", progressive_filter)

	core.register_on_leaveplayer(function(player)
		save_progress(player)
		local name = player:get_player_name()
		player_data[name] = nil
	end)

	core.register_on_shutdown(function()
		for player in mcl_util.connected_players() do
			save_progress(player)
		end
	end)
else
	core.register_on_leaveplayer(function(player)
		local name = player:get_player_name()
		player_data[name] = nil
	end)

	if strict_mode then
		local function recipe_unlocked(recipe)
			for _, item in pairs(recipe.items) do
				if not (core.registered_items[item] or group_cache[item]) then
					return
				end
			end

			return true
		end

		local function strict_filter(recipes, player)
			local filtered, c = {}, 0
			for i = 1, #recipes do
				local recipe = recipes[i]
				if recipe_unlocked(recipe) then
					c = c + 1
					filtered[c] = recipe
				end
			end

			return filtered
		end

		mcl_craftguide.add_recipe_filter("Prevent unknown item filter", strict_filter)
	end
end

function mcl_craftguide.show(name)
	local player = core.get_player_by_name(name)
	if next(recipe_filters) then
		local data = get_player_data(name)
		data.items_raw = get_filtered_items(player)
		search(data)
	end
	show_fs(player, name)
end

doc.sub.items.register_factoid(nil, "groups", function(_, def)
	if def._repair_material then
		local mdef = core.registered_items[def._repair_material]
		if mdef and mdef.description and mdef.description ~= "" then
			return S("This item can be repaired at an anvil with: @1.", mdef.description)
		elseif def._repair_material == "group:wood" then
			return S("This item can be repaired at an anvil with any wooden planks.")
		elseif string.sub(def._repair_material, 1, 6) == "group:" then
			local group = string.sub(def._repair_material, 7)
			return S("This item can be repaired at an anvil with any item in the “@1” group.", group)
		end
	end
	return ""
end)
