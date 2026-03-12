local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local C = core.colorize

local max_text_length =  12800
local max_title_length = 64

local bookshelf_inv = core.settings:get_bool("mcl_bookshelf_inventories", true)

local header = "no_prepend[]" .. mcl_vars.gui_nonbg .. mcl_vars.gui_bg_color ..
		"style_type[button;border=false;bgimg=mcl_books_button9.png;bgimg_pressed=mcl_books_button9_pressed.png;bgimg_middle=2,2]"

-- Book
core.register_craftitem("mcl_books:book", {
	description = S("Book"),
	_doc_items_longdesc = S("Books are used to make bookshelves and book and quills."),
	inventory_image = "default_book.png",
	groups = { book = 1, craftitem = 1, enchantability = 1 },
	_mcl_enchanting_enchanted_tool = "mcl_enchanting:book_enchanted",
})

core.register_craft({
	type = "shapeless",
	output = "mcl_books:book",
	recipe = { "mcl_core:paper", "mcl_core:paper", "mcl_core:paper", "mcl_mobitems:leather", }
})

local function make_description(itemstack)
	local m = itemstack:get_meta()
	local title = m:get_string("title")
	local author = m:get_string("author")
	local generation = m:get_int("generation")
	if author == "" then
		return
	end

	local desc
	if generation == 0 then
		desc = S("“@1”", title)
	elseif generation == 1 then
		desc = S("Copy of “@1”", title)
	elseif generation == 2 then
		desc = S("Copy of Copy of “@1”", title)
	else
		desc = S("Tattered Book")
	end
	desc = desc .. "\n" .. C(mcl_colors.GRAY, S("by @1", author))
	m:set_string("description", desc)
end

local function cap_text_length(text, max_length)
	return string.sub(text, 1, max_length)
end

local function write(itemstack, user, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if rc then return rc end

	local text = itemstack:get_meta():get_string("text")
	local formspec = "size[8,9]" ..
		header ..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]" ..
		"textarea[0.75,0.1;7.25,9;text;;" .. F(text) .. "]" ..
		"button[0.75,7.95;3,1;sign;" .. F(S("Sign")) .. "]" ..
		"button_exit[4.25,7.95;3,1;ok;" .. F(S("Done")) .. "]"
	core.show_formspec(user:get_player_name(), "mcl_books:writable_book", formspec)
end

local function read(itemstack, user, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if rc then return rc end

	local text = itemstack:get_meta():get_string("text")
	local formspec = "size[8,9]" ..
		header ..
		"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]" ..
		"textarea[0.75,0.1;7.25,9;;" .. F(text) .. ";]" ..
		"button_exit[2.25,7.95;3,1;ok;" .. F(S("Done")) .. "]"
	core.show_formspec(user:get_player_name(), "mcl_books:written_book", formspec)
end

-- Book and Quill
core.register_craftitem("mcl_books:writable_book", {
	description = S("Book and Quill"),
	_tt_help = S("Write down some notes"),
	_doc_items_longdesc = S("This item can be used to write down some notes."),
	_doc_items_usagehelp = S(
			"Hold it in the hand, then rightclick to read the current notes and edit then. You can edit the text as often as you like. You can also sign the book which turns it into a written book which you can stack, but it can't be edited anymore.")
		.. "\n" ..
		S("A book can hold up to @1 characters. The title length is limited to @2 characters.", max_text_length, max_title_length),
	inventory_image = "mcl_books_book_writable.png",
	groups = { book = 1 },
	stack_max = 1,
	on_place = write,
	on_secondary_use = write,
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if ((formname == "mcl_books:writable_book") and fields and fields.text) then
		local stack = player:get_wielded_item()
		if (stack:get_name() and (stack:get_name() == "mcl_books:writable_book")) then
			local meta = stack:get_meta()
			local text = cap_text_length(fields.text, max_text_length)
			if fields.ok then
				meta:set_string("text", text)
				player:set_wielded_item(stack)
			elseif fields.sign then
				local overlength = string.len(fields.text) - max_text_length
				local ov_warning = ""
				if overlength > 0 then
					ov_warning = "label[0.75, 2.5;".. F(C(mcl_colors.RED, S("Text is @1 characters too long for one book.\nIt will be capped at @2 characters.", overlength, max_text_length))).."]"
				end
				meta:set_string("text", text)
				player:set_wielded_item(stack)

				local name = player:get_player_name()
				local formspec = "size[8,9]" ..
					header ..
					"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]" ..
					"field[0.75,1;7.25,1;title;" ..
					F(C("#000000", S("Enter book title:"))) .. ";]" ..
					"label[0.75,1.5;" ..
					F(C("#404040", S("by @1", name))) .. "]" ..
					ov_warning..
					"button_exit[0.75,7.95;3,1;sign;" .. F(S("Sign and Close")) .. "]" ..
					"tooltip[sign;" ..
					F(S("Note: The book will no longer be editable after signing")) .. "]" ..
					"button[4.25,7.95;3,1;cancel;" .. F(S("Cancel")) .. "]"
				core.show_formspec(player:get_player_name(), "mcl_books:signing", formspec)
			end
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.sign and fields.title) then
		local newbook = ItemStack("mcl_books:written_book")
		local book = player:get_wielded_item()
		local name = player:get_player_name()
		if book:get_name() == "mcl_books:writable_book" then
			local title = fields.title
			if string.len(title) == 0 then
				title = S("Nameless Book")
			end
			title = cap_text_length(title, max_title_length)
			local meta = newbook:get_meta()
			local text = cap_text_length(book:get_meta():get_string("text"), max_text_length)
			meta:set_string("title", title)
			meta:set_string("author", name)
			meta:set_int("date", os.time())
			meta:set_string("text", text)
			-- The book copy counter. 0 = original, 1 = copy of original, 2 = copy of copy of original, …
			meta:set_int("generation", 0)

			tt.reload_itemstack_description(newbook)

			player:set_wielded_item(newbook)
		else
			core.log("error", "[mcl_books] " .. name .. " failed to sign a book!")
		end
	elseif ((formname == "mcl_books:signing") and fields and fields.cancel) then
		local book = player:get_wielded_item()
		if book:get_name() == "mcl_books:writable_book" then
			write(book, player, { type = "nothing" })
		end
	end
end)

core.register_craft({
	type = "shapeless",
	output = "mcl_books:writable_book",
	recipe = { "mcl_books:book", "mcl_mobitems:ink_sac", "mcl_mobitems:feather" },
})

-- Written Book
core.register_craftitem("mcl_books:written_book", {
	description = S("Written Book"),
	_doc_items_longdesc = S(
		"Written books contain some text written by someone. They can be read and copied, but not edited."
	),
	_doc_items_usagehelp = S("Hold it in your hand, then rightclick to read the book.") ..
		"\n\n" ..
		S(
			"To copy the text of the written book, place it into the crafting grid together with a book and quill (or multiple of those) and craft. The written book will not be consumed. Copies of copies can not be copied."
		),
	inventory_image = "mcl_books_book_written.png",
	groups = { not_in_creative_inventory = 1, book = 1, no_rename = 1 },
	stack_max = 16,
	on_place = read,
	on_secondary_use = read,
	_mcl_generate_description = make_description,
})

--This adds 8 recipes containing 1 written book and 1-8 writeable book
for i = 1, 8 do
	local rc = {}
	table.insert(rc, "mcl_books:written_book")
	for _ = 1, i do	table.insert(rc, "mcl_books:writable_book") end

	core.register_craft({
		type = "shapeless",
		output = "mcl_books:written_book " .. i,
		recipe = rc,
	})
end

local function craft_copy_book(itemstack, player, old_craft_grid, _)
	if itemstack:get_name() ~= "mcl_books:written_book" then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if old_craft_grid[i]:get_name() == "mcl_books:written_book" then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end

	local ometa = original:get_meta()
	local generation = ometa:get_int("generation")

	-- No copy of copy of copy of book allowed
	if generation >= 2 then
		return ItemStack("")
	end

	-- Copy metadata
	local imeta = itemstack:get_meta()
	imeta:from_table(ometa:to_table())
	imeta:set_string("title", cap_text_length(ometa:get_string("title"), max_title_length))
	imeta:set_string("text", cap_text_length(ometa:get_string("text"), max_text_length))

	-- Increase book generation and update description
	generation = generation + 1
	if generation < 1 then
		generation = 1
	end
	imeta:set_int("generation", generation)

	tt.reload_itemstack_description(itemstack)
	return itemstack, original, index
end
core.register_craft_predict(craft_copy_book)

core.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local _, original, index = craft_copy_book(itemstack, player, old_craft_grid, craft_inv)
	if original and index then craft_inv:set_stack("craft", index, original) end
end)

-- Bookshelf GUI
local drop_content = mcl_util.drop_items_from_meta_container("main")

local function on_blast(pos)
	local node = core.get_node(pos)
	drop_content(pos, node)
	core.remove_node(pos)
end

-- Simple protection checking functions
local function protection_check_move(pos, _, _, _, _, count, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end

local function protection_check_put_take(pos, _, _, stack, player)
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return 0
	elseif core.get_item_group(stack:get_name(), "book") ~= 0 or stack:get_name() == "mcl_enchanting:book_enchanted" then
		return stack:get_count()
	else
		return 0
	end
end

local function bookshelf_gui(pos, _, clicker)
	if not bookshelf_inv then return end
	local name = core.get_meta(pos):get_string("name")

	if name == "" then
		name = S("Bookshelf")
	end

	local playername = clicker:get_player_name()

	core.show_formspec(playername,
		"mcl_books:bookshelf_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z,
		table.concat({
			"formspec_version[4]",
			"size[11.75,10.425]",

			"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
			mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3, 0, "mcl_book_book_empty_slot.png"),
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0.375,0.75;9,3;]",
			"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
			"list[current_player;main;0.375,5.1;9,3;9]",

			mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
			"list[current_player;main;0.375,9.05;9,1;]",
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main]",
			"listring[current_player;main]",
		})
	)
end

local function close_forms(pos)
	local formname = "mcl_books:bookshelf_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z
	for pl in mcl_util.connected_players(pos, 30) do
			core.close_formspec(pl:get_player_name(), formname)
	end
end

-- Bookshelf
core.register_node("mcl_books:bookshelf", {
	description = S("Bookshelf"),
	_doc_items_longdesc = S("Bookshelves are used for decoration."),
	tiles = { "mcl_books_bookshelf_top.png", "mcl_books_bookshelf_top.png", "default_bookshelf.png" },
	is_ground_content = false,
	groups = {
		handy = 1,
		axey = 1,
		deco_block = 1,
		material_wood = 1,
		flammable = 3,
		fire_encouragement = 30,
		fire_flammability = 20,
		container = 1
	},
	drop = "mcl_books:book 3",
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
	_mcl_burntime = 15,
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 9 * 3)
	end,
	after_place_node = function(pos, _, itemstack, _)
		core.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
		core.log("action", player:get_player_name() ..
			" moves stuff in bookshelf at " .. core.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, _, _, _, player)
		core.log("action", player:get_player_name() ..
			" moves stuff to bookshelf at " .. core.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, _, _, _, player)
		core.log("action", player:get_player_name() ..
			" takes stuff from bookshelf at " .. core.pos_to_string(pos))
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = bookshelf_gui,
	on_destruct = close_forms,
})

core.register_craft({
	output = "mcl_books:bookshelf",
	recipe = {
		{ "group:wood",     "group:wood",     "group:wood" },
		{ "mcl_books:book", "mcl_books:book", "mcl_books:book" },
		{ "group:wood",     "group:wood",     "group:wood" },
	}
})

dofile(core.get_modpath(core.get_current_modname()).."/chiseled_bookshelf.lua")
