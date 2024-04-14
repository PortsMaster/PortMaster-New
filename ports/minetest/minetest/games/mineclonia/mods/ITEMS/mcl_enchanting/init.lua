local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_enchanting = {
	book_offset = vector.new(0, 0.75, 0),
	book_animations = {["close"] = 1, ["opening"] = 2, ["open"] = 3, ["closing"] = 4},
	book_animation_steps = {0, 640, 680, 700, 740},
	book_animation_loop = {["open"] = true, ["close"] = true},
	book_animation_speed = 40,
	roman_numerals = dofile(modpath .. "/roman_numerals.lua"), 			-- https://exercism.io/tracks/lua/exercises/roman-numerals/solutions/73c2fb7521e347209312d115f872fa49
	enchantments = {},
	overlay = "^[colorize:purple:50",
	--overlay = "^[invert:rgb^[multiply:#4df44d:50^[invert:rgb",
	enchanting_lists = {"enchanting", "enchanting_item", "enchanting_lapis"},
	bookshelf_positions = {
		{x = -2, y = 0, z = -2}, {x = -2, y = 1, z = -2},
		{x = -1, y = 0, z = -2}, {x = -1, y = 1, z = -2},
		{x =  0, y = 0, z = -2}, {x =  0, y = 1, z = -2},
		{x =  1, y = 0, z = -2}, {x =  1, y = 1, z = -2},
		{x =  2, y = 0, z = -2}, {x =  2, y = 1, z = -2},
		{x = -2, y = 0, z =  2}, {x = -2, y = 1, z =  2},
		{x = -1, y = 0, z =  2}, {x = -1, y = 1, z =  2},
		{x =  0, y = 0, z =  2}, {x =  0, y = 1, z =  2},
		{x =  1, y = 0, z =  2}, {x =  1, y = 1, z =  2},
		{x =  2, y = 0, z =  2}, {x =  2, y = 1, z =  2},
		-- {x = -2, y = 0, z = -2}, {x = -2, y = 1, z = -2},
		{x = -2, y = 0, z = -1}, {x = -2, y = 1, z = -1},
		{x = -2, y = 0, z =  0}, {x = -2, y = 1, z =  0},
		{x = -2, y = 0, z =  1}, {x = -2, y = 1, z =  1},
		-- {x = -2, y = 0, z =  2}, {x = -2, y = 1, z =  2},
		-- {x =  2, y = 0, z = -2}, {x =  2, y = 1, z = -2},
		{x =  2, y = 0, z = -1}, {x =  2, y = 1, z = -1},
		{x =  2, y = 0, z =  0}, {x =  2, y = 1, z =  0},
		{x =  2, y = 0, z =  1}, {x =  2, y = 1, z =  1},
		-- {x =  2, y = 0, z =  2}, {x =  2, y = 1, z =  2},
	},
	air_positions = {
		{x = -1, y = 0, z = -1}, {x = -1, y = 1, z = -1},
		{x = -1, y = 0, z = -1}, {x = -1, y = 1, z = -1},
		{x =  0, y = 0, z = -1}, {x =  0, y = 1, z = -1},
		{x =  1, y = 0, z = -1}, {x =  1, y = 1, z = -1},
		{x =  1, y = 0, z = -1}, {x =  1, y = 1, z = -1},
		{x = -1, y = 0, z =  1}, {x = -1, y = 1, z =  1},
		{x = -1, y = 0, z =  1}, {x = -1, y = 1, z =  1},
		{x =  0, y = 0, z =  1}, {x =  0, y = 1, z =  1},
		{x =  1, y = 0, z =  1}, {x =  1, y = 1, z =  1},
		{x =  1, y = 0, z =  1}, {x =  1, y = 1, z =  1},
		-- {x = -1, y = 0, z = -1}, {x = -1, y = 1, z = -1},
		{x = -1, y = 0, z = -1}, {x = -1, y = 1, z = -1},
		{x = -1, y = 0, z =  0}, {x = -1, y = 1, z =  0},
		{x = -1, y = 0, z =  1}, {x = -1, y = 1, z =  1},
		-- {x = -1, y = 0, z =  1}, {x = -1, y = 1, z =  1},
		-- {x =  1, y = 0, z = -1}, {x =  1, y = 1, z = -1},
		{x =  1, y = 0, z = -1}, {x =  1, y = 1, z = -1},
		{x =  1, y = 0, z =  0}, {x =  1, y = 1, z =  0},
		{x =  1, y = 0, z =  1}, {x =  1, y = 1, z =  1},
		-- {x =  1, y = 0, z =  1}, {x =  1, y = 1, z =  1},
	},
}

dofile(modpath .. "/engine.lua")
dofile(modpath .. "/groupcaps.lua")
dofile(modpath .. "/enchantments.lua")

minetest.register_chatcommand("enchant", {
	description = S("Enchant an item"),
	params = S("<player> <enchantment> [<level>]"),
	privs = {give = true},
	func = function(_, param)
		local sparam = param:split(" ")
		local target_name = sparam[1]
		local enchantment = sparam[2]
		local level_str = sparam[3]
		local level = tonumber(level_str or "1")
		if not target_name or not enchantment then
			return false, S("Usage: /enchant <player> <enchantment> [<level>]")
		end
		local target = minetest.get_player_by_name(target_name)
		if not target then
			return false, S("Player '@1' cannot be found.", target_name)
		end
		local itemstack = target:get_wielded_item()
		local can_enchant, errorstring, extra_info = mcl_enchanting.can_enchant(itemstack, enchantment, level)
		if not can_enchant then
			if errorstring == "enchantment invalid" then
				return false, S("There is no such enchantment '@1'.", enchantment)
			elseif errorstring == "item missing" then
				return false, S("The target doesn't hold an item.")
			elseif errorstring == "item not supported" then
				return false, S("The selected enchantment can't be added to the target item.")
			elseif errorstring == "level invalid" then
				return false, S("'@1' is not a valid number", level_str)
			elseif errorstring == "level too high" then
				return false, S("The number you have entered (@1) is too big, it must be at most @2.", level_str, extra_info)
			elseif errorstring == "level too small" then
				return false, S("The number you have entered (@1) is too small, it must be at least @2.", level_str, extra_info)
			elseif errorstring == "incompatible" then
				return false, S("@1 can't be combined with @2.", mcl_enchanting.get_enchantment_description(enchantment, level), extra_info)
			end
		else
			target:set_wielded_item(mcl_enchanting.enchant(itemstack, enchantment, level))
			return true, S("Enchanting succeded.")
		end
	end
})

minetest.register_chatcommand("forceenchant", {
	description = S("Forcefully enchant an item"),
	params = S("<player> <enchantment> [<level>]"),
	privs = {give = true},
	func = function(_, param)
		local sparam = param:split(" ")
		local target_name = sparam[1]
		local enchantment = sparam[2]
		local level_str = sparam[3]
		local level = tonumber(level_str or "1")
		if not target_name or not enchantment then
			return false, S("Usage: /forceenchant <player> <enchantment> [<level>]")
		end
		local target = minetest.get_player_by_name(target_name)
		if not target then
			return false, S("Player '@1' cannot be found.", target_name)
		end
		local itemstack = target:get_wielded_item()
		local _, errorstring = mcl_enchanting.can_enchant(itemstack, enchantment, level)
		if errorstring == "enchantment invalid" then
			return false, S("There is no such enchantment '@1'.", enchantment)
		elseif errorstring == "item missing" then
			return false, S("The target doesn't hold an item.")
		elseif errorstring == "item not supported" and not mcl_enchanting.is_enchantable(itemstack:get_name()) then
			return false, S("The target item is not enchantable.")
		elseif errorstring == "level invalid" then
			return false, S("'@1' is not a valid number.", level_str)
		else
			target:set_wielded_item(mcl_enchanting.enchant(itemstack, enchantment, level))
			return true, S("Enchanting succeded.")
		end
	end
})

minetest.register_craftitem("mcl_enchanting:book_enchanted", {
	description = S("Enchanted Book"),
	inventory_image = "mcl_enchanting_book_enchanted.png" .. mcl_enchanting.overlay,
	groups = {enchanted = 1, not_in_creative_inventory = 1, enchantability = 1},
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
	stack_max = 1,
})

minetest.register_alias("mcl_books:book_enchanted", "mcl_enchanting:book_enchanted")

local function spawn_book_entity(pos, respawn)
	if respawn then
		-- Check if we already have a book
		local objs = minetest.get_objects_inside_radius(pos, 1)
		for o=1, #objs do
			local obj = objs[o]
			local lua = obj:get_luaentity()
			if lua and lua.name == "mcl_enchanting:book" then
				if lua._table_pos and vector.equals(pos, lua._table_pos) then
					return
				end
			end
		end
	end
	local obj = minetest.add_entity(vector.add(pos, mcl_enchanting.book_offset), "mcl_enchanting:book")
	if obj then
		local lua = obj:get_luaentity()
		if lua then
			lua._table_pos = table.copy(pos)
		end
	end
end

minetest.register_entity("mcl_enchanting:book", {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_enchanting_book.b3d",
		visual_size = {x = 12.5, y = 12.5},
		collisionbox = {0, 0, 0},
		pointable = false,
		physical = false,
		textures = {"mcl_enchanting_book_entity.png", "mcl_enchanting_book_entity.png", "mcl_enchanting_book_entity.png", "mcl_enchanting_book_entity.png", "mcl_enchanting_book_entity.png"},
		static_save = false,
	},
	_player_near = false,
	_table_pos = nil,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		mcl_enchanting.set_book_animation(self, "close")
	end,
	on_step = function(self, dtime)
		local old_player_near = self._player_near
		local player_near = false
		local player
		for _, obj in pairs(minetest.get_objects_inside_radius(vector.subtract(self.object:get_pos(), mcl_enchanting.book_offset), 2.5)) do
			if obj:is_player() then
				player_near = true
				player = obj
			end
		end
		if player_near and not old_player_near then
			mcl_enchanting.set_book_animation(self, "opening")
			mcl_enchanting.schedule_book_animation(self, "open")
		elseif old_player_near and not player_near then
			mcl_enchanting.set_book_animation(self, "closing")
			mcl_enchanting.schedule_book_animation(self, "close")
		end
		if player then
			mcl_enchanting.look_at(self, player:get_pos())
		end
		self._player_near = player_near
		mcl_enchanting.check_animation_schedule(self, dtime)
	end,
})

local rotate
if minetest.get_modpath("screwdriver") then
	rotate = screwdriver.rotate_simple
end

minetest.register_node("mcl_enchanting:table", {
	description = S("Enchanting Table"),
	_tt_help = S("Spend experience, and lapis to enchant various items."),
	_doc_items_longdesc = S("Enchanting Tables will let you enchant armors, tools, weapons, and books with various abilities. But, at the cost of some experience, and lapis lazuli."),
	_doc_items_usagehelp =
			S("Rightclick the Enchanting Table to open the enchanting menu.").."\n"..
			S("Place a tool, armor, weapon or book into the top left slot, and then place 1-3 Lapis Lazuli in the slot to the right.").."\n".."\n"..
			S("After placing your items in the slots, the enchanting options will be shown. Hover over the options to read what is available to you.").."\n"..
			S("These options are randomized, and dependent on experience level; but the enchantment strength can be increased.").."\n".."\n"..
			S("To increase the enchantment strength, place bookshelves around the enchanting table. However, you will need to keep 1 air node between the table, & the bookshelves to empower the enchanting table.").."\n".."\n"..
			S("After finally selecting your enchantment; left-click on the selection, and you will see both the lapis lazuli and your experience levels consumed. And, an enchanted item left in its place."),
	_doc_items_hidden = false,
	drawtype = "nodebox",
	tiles = {"mcl_enchanting_table_top.png",  "mcl_enchanting_table_bottom.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png", "mcl_enchanting_table_side.png"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.25, 0.5},
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey = 2, deco_block = 1},
	on_rotate = rotate,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player_meta = clicker:get_meta()
		--local table_meta = minetest.get_meta(pos)
		--local num_bookshelves = table_meta:get_int("mcl_enchanting:num_bookshelves")
		local table_name = minetest.get_meta(pos):get_string("name")
		if table_name == "" then
			table_name = S("Enchant")
		end
		local bookshelves = mcl_enchanting.get_bookshelves(pos)
		player_meta:set_int("mcl_enchanting:num_bookshelves", math.min(15, #bookshelves))
		player_meta:set_string("mcl_enchanting:table_name", table_name)
		mcl_enchanting.show_enchanting_formspec(clicker)
		-- Respawn book entity just in case it got lost
		spawn_book_entity(pos, true)
	end,
	on_construct = function(pos)
		spawn_book_entity(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local dname = (digger and digger:get_player_name()) or ""
		if minetest.is_creative_enabled(dname) then
			return
		end
		local itemstack = ItemStack("mcl_enchanting:table")
		local meta = minetest.get_meta(pos)
		local itemmeta = itemstack:get_meta()
		itemmeta:set_string("name", meta:get_string("name"))
		itemmeta:set_string("description", meta:get_string("description"))
		minetest.add_item(pos, itemstack)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local itemmeta = itemstack:get_meta()
		meta:set_string("name", itemmeta:get_string("name"))
		meta:set_string("description", itemmeta:get_string("description"))
	end,
	after_destruct = function(pos)
		local objs = minetest.get_objects_inside_radius(pos, 1)
		for o=1, #objs do
			local obj = objs[o]
			local lua = obj:get_luaentity()
			if lua and lua.name == "mcl_enchanting:book" then
				if lua._table_pos and vector.equals(pos, lua._table_pos) then
					obj:remove()
				end
			end
		end
	end,
	drop = "",
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,
})

minetest.register_craft({
	output = "mcl_enchanting:table",
	recipe = {
		{"", "mcl_books:book", ""},
		{"mcl_core:diamond", "mcl_core:obsidian", "mcl_core:diamond"},
		{"mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian"}
	}
})

minetest.register_abm({
	label = "Enchanting table bookshelf particles",
	interval = 1,
	chance = 1,
	nodenames = "mcl_enchanting:table",
	action = function(pos)
		local playernames = {}
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			if obj:is_player() then
				table.insert(playernames, obj:get_player_name())
			end
		end
		if #playernames < 1 then
			return
		end
		local absolute, relative = mcl_enchanting.get_bookshelves(pos)
		for i, ap in ipairs(absolute) do
			if math.random(5) == 1 then
				local rp = relative[i]
				local t = math.random()+1 --time
				local d = {x = rp.x, y=rp.y-0.7, z=rp.z} --distance
				local v = {x = -math.random()*d.x, y = math.random(), z = -math.random()*d.z} --velocity
				local a = {x = 2*(-v.x*t - d.x)/t/t, y = 2*(-v.y*t - d.y)/t/t, z = 2*(-v.z*t - d.z)/t/t} --acceleration
				local s = math.random()+0.9 --size
				t = t - 0.1 --slightly decrease time to avoid texture overlappings
				local tx = "mcl_enchanting_glyph_" .. math.random(18) .. ".png"
				for _, name in pairs(playernames) do
					minetest.add_particle({
						pos = ap,
						velocity = v,
						acceleration = a,
						expirationtime = t,
						size = s,
						texture = tx,
						collisiondetection = false,
						playername = name
					})
				end
			end
		end
	end
})

minetest.register_lbm({
	label = "(Re-)spawn book entity above enchanting table",
	name = "mcl_enchanting:spawn_book_entity",
	nodenames = {"mcl_enchanting:table"},
	run_at_every_load = true,
	action = function(pos)
		spawn_book_entity(pos, true)
	end,
})


minetest.register_on_mods_loaded(mcl_enchanting.initialize)
minetest.register_on_joinplayer(mcl_enchanting.initialize_player)
minetest.register_on_player_receive_fields(mcl_enchanting.handle_formspec_fields)
minetest.register_allow_player_inventory_action(mcl_enchanting.allow_inventory_action)
minetest.register_on_player_inventory_action(mcl_enchanting.on_inventory_action)
tt.register_priority_snippet(mcl_enchanting.enchantments_snippet)
