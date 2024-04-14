mcl_craftguide = {}

local player_data = {}

-- Caches
local init_items    = {}
local searches      = {}
local recipes_cache = {}
local usages_cache  = {}
local fuel_cache    = {}

local progressive_mode = minetest.settings:get_bool("mcl_craftguide_progressive_mode", true)

local C = minetest.colorize
local F = minetest.formspec_escape
local S = minetest.get_translator("mcl_craftguide")

local DEFAULT_SIZE = 10
local MIN_LIMIT, MAX_LIMIT = 10, 12
DEFAULT_SIZE = math.min(MAX_LIMIT, math.max(MIN_LIMIT, DEFAULT_SIZE))

local GRID_LIMIT = 5
local POLL_FREQ  = 0.25

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



local item_lists = {
	"main",
	"craft",
	"craftpreview",
}

local function table_merge(t, t2)
	t, t2 = t or {}, t2 or {}
	local c = #t

	for i = 1, #t2 do
		c = c + 1
		t[c] = t2[i]
	end

	return t
end

local function table_replace(t, val, new)
	for k, v in pairs(t) do
		if v == val then
			t[k] = new
		end
	end
end

local function table_diff(t, t2)
	local hash = {}

	for i = 1, #t do
		local v = t[i]
		hash[v] = true
	end

	for i = 1, #t2 do
		local v = t2[i]
		hash[v] = nil
	end

	local diff, c = {}, 0

	for i = 1, #t do
		local v = t[i]
		if hash[v] then
			c = c + 1
			diff[c] = v
		end
	end

	return diff
end

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

	custom_crafts[#custom_crafts + 1] = def
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
		if not item_groups[group] then
			return
		end
	end

	return true
end

local function extract_groups(str)
	return string.split(string.sub(str, 7), ",")
end

local function item_in_recipe(item, recipe)
	for _, recipe_item in pairs(recipe.items) do
		if recipe_item == item then
			return true
		end
	end
end

local function groups_item_in_recipe(item, recipe)
	local item_groups = minetest.registered_items[item].groups
	for _, recipe_item in pairs(recipe.items) do
		if string.sub(recipe_item, 1, 6) == "group:" then
			local groups = extract_groups(recipe_item)
			if item_has_groups(item_groups, groups) then
				local usage = table.copy(recipe)
				table_replace(usage.items, recipe_item, item)
				return usage
			end
		end
	end
end

local function get_item_usages(item)
	local usages, c = {}, 0

	for _, recipes in pairs(recipes_cache) do
	for i = 1, #recipes do
		local recipe = recipes[i]
		if item_in_recipe(item, recipe) then
			c = c + 1
			usages[c] = recipe
		else
			recipe = groups_item_in_recipe(item, recipe)
			if recipe then
				c = c + 1
				usages[c] = recipe
			end
		end
	end
	end

	if fuel_cache[item] then
		usages[#usages + 1] = {type = "fuel", width = 1, items = {item}}
	end

	return usages
end

local function get_filtered_items(player)
	local items, c = {}, 0

	for i = 1, #init_items do
		local item = init_items[i]
		local recipes = recipes_cache[item]
		local usages = usages_cache[item]

		if recipes and #apply_recipe_filters(recipes, player) > 0 or
		   usages and #apply_recipe_filters(usages, player) > 0 then
			c = c + 1
			items[c] = item
		end
	end

	return items
end

local function cache_recipes(output)
	local recipes = minetest.get_all_craft_recipes(output) or {}
	local c = 0

	for i = 1, #custom_crafts do
		local custom_craft = custom_crafts[i]
		if string.match(custom_craft.output, "%S*") == output then
			c = c + 1
			recipes[c] = custom_craft
		end
	end

	if #recipes > 0 then
		recipes_cache[output] = recipes
		return true
	end
end

local function get_recipes(item, data, player)
	local recipes = recipes_cache[item]
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
		recipes = apply_recipe_filters(usages_cache[item], player)
		if #recipes == 0 then
			return
		end
	end

	return recipes
end

local function get_burntime(item)
	return minetest.get_craft_result({method = "fuel", width = 1, items = {item}}).time
end

local function cache_fuel(item)
	local burntime = get_burntime(item)
	if burntime > 0 then
		fuel_cache[item] = burntime
		return true
	end
end

local function groups_to_item(groups)
	if #groups == 1 then
		local group = groups[1]
		local def_gr = "mcl_core:" .. group

		if group_stereotypes[group] then
			return group_stereotypes[group]
		elseif minetest.registered_items[def_gr] then
			return def_gr
		end
	end

	for name, def in pairs(minetest.registered_items) do
		if item_has_groups(def.groups, groups) then
			return name
		end
	end

	return ""
end

local function get_tooltip(item, groups, cooktime, burntime)
	local tooltip

	if groups then
		local gcol = mcl_colors.LIGHT_PURPLE
		if #groups == 1 then
			local g = group_names[groups[1]]
			local groupstr
			-- Treat the groups “compass” and “clock” as fake groups
			-- and just print the normal item name without special formatting
			if groups[1] == "compass" or groups[1] == "clock" then
				groupstr = minetest.registered_items[item].description
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

			groupstr = table.concat(groupstr, ", ")
			tooltip = S("Any item belonging to the groups: @1", groupstr)
		end
	else
		tooltip = minetest.registered_items[item].description
	end

	if not groups and cooktime then
		tooltip = tooltip .. "\n" ..
			S("Cooking time: @1", C(mcl_colors.YELLOW, cooktime))
	end

	if not groups and burntime then
		tooltip = tooltip .. "\n" ..
			S("Burning time: @1", C(mcl_colors.YELLOW, burntime))
	end

	return string.format(FMT.tooltip, item, F(tooltip))
end

local function get_recipe_fs(data, iY, player)
	mcl_inventory.reset_craft_grid(player)
	local fs = {}
	local recipe = data.recipes[data.rnum]
	local width = recipe.width
	local xoffset = data.iX / 2.15
	local cooktime, shapeless

	if recipe.type == "cooking" then
		cooktime, width = width, 1
	elseif width == 0 then
		shapeless = true
		if #recipe.items <= 4 then
			width = 2
		else
			width = math.min(3, #recipe.items)
		end
	end

	local rows = math.ceil(table.maxn(recipe.items) / width)
	local rightest, btn_size, s_btn_size = 0, 1.1

	local btn_lab = data.show_usages and
		F(S("Usage @1 of @2", data.rnum, #data.recipes)) or
		F(S("Recipe @1 of @2", data.rnum, #data.recipes))

	fs[#fs + 1] = string.format(FMT.button,
		data.iX - 2.6,
		iY + 3.3,
		2.2,
		1,
		"alternate",
		btn_lab)

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

		local burntime = fuel_cache[item]

		if groups or cooktime or burntime then
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
		local burntime = fuel_cache[output_name]

		fs[#fs + 1] = string.format(FMT.item_image_button,
			output_X,
			iY + 2.2,
			1.1,
			1.1,
			recipe.output,
			F(output_name),
			"")

		if burntime then
			fs[#fs + 1] = get_tooltip(output_name, nil, nil, burntime)

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
		--show the button crafting button if recipe items are in inventory and the recipe fits the available crafting grid
		local pinv = player:get_inventory()
		if mcl_inventory.get_recipe_groups(pinv, recipe) and
			( mcl_crafting_table.has_crafting_table(player) or
			( recipe.width <= pinv:get_width("craft") and table.count(recipe.items, function(_,v) return not ItemStack(v):is_empty() end) <= pinv:get_size("craft"))) then
			fs[#fs + 1] = string.format("image_button[%f,%f;%f,%f;%s;%s_inv;%s]",
				8.5,
				7.2,
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
	mcl_inventory.reset_craft_grid(minetest.get_player_by_name(name))
	local data = player_data[name]
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
	end

	if data.recipes and #data.recipes > 0 then
		fs[#fs + 1] = get_recipe_fs(data, iY, minetest.get_player_by_name(name))
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

local function show_fs(player, name)
	minetest.show_formspec(name, "mcl_craftguide", make_formspec(name))
end

mcl_craftguide.add_search_filter("groups", function(item, groups)
	local itemdef = minetest.registered_items[item]
	local has_groups = true

	for i = 1, #groups do
		local group = groups[i]
		if not itemdef.groups[group] then
			has_groups = nil
			break
		end
	end

	return has_groups
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
		local def  = minetest.registered_items[item]
		local desc = string.lower(minetest.get_translated_string(data.lang_code, def.description))
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

local function get_inv_items(player)
	local inv = player:get_inventory()
	local stacks = {}

	for i = 1, #item_lists do
		local list = inv:get_list(item_lists[i])
		table_merge(stacks, list)
	end

	local inv_items, c = {}, 0

	for i = 1, #stacks do
		local stack = stacks[i]
		if not stack:is_empty() then
			local name = stack:get_name()
			if minetest.registered_items[name] then
				c = c + 1
				inv_items[c] = name
			end
		end
	end

	return inv_items
end

local function init_data(name)
	player_data[name] = {
		filter  = "",
		pagenum = 1,
		iX      = DEFAULT_SIZE,
		items   = init_items,
		items_raw = init_items,
		lang_code = minetest.get_player_information(name).lang_code or 'en',
	}
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

local function cache_usages()
	for i = 1, #init_items do
		local item = init_items[i]
		usages_cache[item] = get_item_usages(item)
	end
end

local function get_init_items()
	local c = 0
	for name, def in pairs(minetest.registered_items) do
		local is_fuel = cache_fuel(name)
		if def.groups.not_in_craft_guide ~= 1 and
				def.description and def.description ~= "" and
				(cache_recipes(name) or is_fuel) then
			c = c + 1
			init_items[c] = name
		end
	end

	table.sort(init_items)
	cache_usages()
end

local function on_receive_fields(player, fields)
	local name = player:get_player_name()
	local data = player_data[name]

	for elem_name, def in pairs(formspec_elements) do
		if fields[elem_name] and def.action then
			return def.action(player, data)
		end
	end

	if fields.clear then
		reset_data(data)
		show_fs(player, name)

	elseif fields.alternate then
		if #data.recipes == 1 then
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
		local pinv = player:get_inventory()
		if not mcl_inventory.get_recipe_groups(pinv, data.recipes[data.rnum]) then return end
		if mcl_crafting_table.has_crafting_table(player) then
			mcl_crafting_table.show_crafting_form(player)
		elseif data.recipes[data.rnum].width <= pinv:get_width("craft") and table.count(data.recipes[data.rnum].items, function(_,v) return not ItemStack(v):is_empty()  end) <= pinv:get_size("craft") then
			minetest.show_formspec(name, "", player:get_inventory_formspec())
		else
			return
		end
		mcl_inventory.to_craft_grid(player, data.recipes[data.rnum])
	else
		local item
		for field in pairs(fields) do
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

minetest.register_on_mods_loaded(get_init_items)


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mcl_craftguide" then
		on_receive_fields(player, fields)
	elseif fields.__mcl_craftguide then
		mcl_craftguide.show(player:get_player_name())
	end
end)

--[[local function on_use(user)
	local name = user:get_player_name()

	if next(recipe_filters) then
		local data = player_data[name]
		data.items_raw = get_filtered_items(user)
		search(data)
	end

	minetest.show_formspec(name, "mcl_craftguide", make_formspec(name))
end]]

if progressive_mode then
	local function item_in_inv(item, inv_items)
		local inv_items_size = #inv_items

		if string.sub(item, 1, 6) == "group:" then
			local groups = extract_groups(item)
			for i = 1, inv_items_size do
				local inv_item = minetest.registered_items[inv_items[i]]
				if inv_item then
					local item_groups = inv_item.groups
					if item_has_groups(item_groups, groups) then
						return true
					end
				end
			end
		else
			for i = 1, inv_items_size do
				if inv_items[i] == item then
					return true
				end
			end
		end
	end

	local function recipe_in_inv(recipe, inv_items)
		for _, item in pairs(recipe.items) do
			if not item_in_inv(item, inv_items) then
				return
			end
		end

		return true
	end

	local function progressive_filter(recipes, player)
		local name = player:get_player_name()
		local data = player_data[name]

		if #data.inv_items == 0 then
			return {}
		end

		local filtered, c = {}, 0
		for i = 1, #recipes do
			local recipe = recipes[i]
			if recipe_in_inv(recipe, data.inv_items) then
				c = c + 1
				filtered[c] = recipe
			end
		end

		return filtered
	end

	-- Workaround. Need an engine call to detect when the contents
	-- of the player inventory changed, instead.
	local function poll_new_items()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			local name   = player:get_player_name()
			local data   = player_data[name]
			local inv_items = get_inv_items(player)
			if data and data.inv_items then
				local diff      = table_diff(inv_items, data.inv_items)

				if #diff > 0 then
					data.inv_items = table_merge(diff, data.inv_items)
				end
			end
		end

		minetest.after(POLL_FREQ, poll_new_items)
	end

	minetest.register_on_mods_loaded(function()
		minetest.after(1, poll_new_items)
	end)

	mcl_craftguide.add_recipe_filter("Default progressive filter", progressive_filter)

	minetest.register_on_joinplayer(function(player)
		local name = player:get_player_name()
		init_data(name)
		local meta = player:get_meta()
		local data = player_data[name]

		data.inv_items = minetest.deserialize(meta:get_string("inv_items")) or {}
	end)

	local function save_meta(player)
		local meta = player:get_meta()
		local name = player:get_player_name()
		local data = player_data[name]

		if not data then
			return
		end

		local inv_items = data.inv_items or {}

		meta:set_string("inv_items", minetest.serialize(inv_items))
	end

	minetest.register_on_leaveplayer(function(player)
		save_meta(player)
		local name = player:get_player_name()
		player_data[name] = nil
	end)

	minetest.register_on_shutdown(function()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			save_meta(player)
		end
	end)
else
	minetest.register_on_joinplayer(function(player)
		local name = player:get_player_name()
		init_data(name)
	end)

	minetest.register_on_leaveplayer(function(player)
		local name = player:get_player_name()
		player_data[name] = nil
	end)
end

function mcl_craftguide.show(name)
	local player = minetest.get_player_by_name(name)
	if next(recipe_filters) then
		local data = player_data[name]
		data.items_raw = get_filtered_items(player)
		search(data)
	end
	minetest.show_formspec(name, "mcl_craftguide", make_formspec(name))
end

doc.sub.items.register_factoid(nil, "groups", function(itemstring, def)
	if def._repair_material then
		local mdef = minetest.registered_items[def._repair_material]
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

--[[ Custom recipes (>3x3) test code

minetest.register_craftitem(":secretstuff:custom_recipe_test", {
	description = "Custom Recipe Test",
})

local cr = {}
for x = 1, 6 do
	cr[x] = {}
	for i = 1, 10 - x do
		cr[x][i] = {}
		for j = 1, 10 - x do
			cr[x][i][j] = "group:wood"
		end
	end

	minetest.register_craft({
		output = "secretstuff:custom_recipe_test",
		recipe = cr[x]
	})
end
]]
