local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local H = core.hypertext_escape

local function get_formspec(text, title, author)
	local fs = "size[8,9]" ..
	"no_prepend[]" .. mcl_vars.gui_nonbg .. mcl_vars.gui_bg_color ..
	"style_type[button;border=false;bgimg=mcl_books_button9.png;bgimg_pressed=mcl_books_button9_pressed.png;bgimg_middle=2,2]" ..
	"background[-0.5,-0.5;9,10;mcl_books_book_bg.png]"

	if title ~= "" then
		fs = fs .. "scroll_container[0,0.5;8,0.7;;vertical]hypertext[0,-0.2;8,10;title;<style color=black font=normal size=24><center>"..H(F(title or "")).."</center></style>]scroll_container_end[]"
	end
	if author ~= "" then
		fs = fs .. "scroll_container[0.75,1.0;7.25,0.5;;vertical]hypertext[0,-0.2;7.25,10;author;<style color=black font=normal size=12>by </style><style color=#1E1E1E font=mono size=14>"..H(F(author or "")).."</style>]scroll_container_end[]"
	end
	fs = fs .."textarea[0.75,1.24;7.20,7.5;;" .. F(text or "") .. ";]" ..
	"button_exit[1.25,7.95;3,1;ok;" .. F(S("Done")) .. "]"..
	"button_exit[4.25,7.95;3,1;take;" .. F(S("Take Book")) .. "]"
	return fs
end

local lectern_tpl = {
	description = S("Lectern"),
	_tt_help = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_longdesc = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_usagehelp = S("Place the Lectern on a solid node for best results. May attract villagers, so it's best to place outside of where you call 'home'."),
	sounds = mcl_sounds.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "mcl_lectern_lectern.obj",
	tiles = {"mcl_lectern_lectern.png", },
	drop = "mcl_lectern:lectern",
	groups = {handy = 1, axey = 1, flammable = 2, fire_encouragement = 5, fire_flammability = 5, solid = 1, deco_block=1, lectern = 1, pathfinder_partial = 2},
	sunlight_propagates = true,
	is_ground_content = false,
	node_placement_prediction = "",
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
	_mcl_burntime = 15,
	selection_box = {
		type = "fixed",
		fixed = {
			--   L,    T,    Ba,    R,    Bo,    F.
			{-0.5, -0.5, -0.5, 0.5, -0.5 + 2/16, 0.5},
			{-0.25, -0.5 + 2/16, -0.25, 0.25, 0.5 - 2/16, 0.25},
			{-0.5 + 1/16, 0.5 - 2/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 + 2/16, 0.5 - 1/16},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			--   L,    T,    Ba,    R,    Bo,    F.
			{-0.32, 0.46, -0.32, 0.32, 0.175, 0.32},
			{-0.18, 0.175, -0.055, 0.18, -0.37, 0.21},
			{-0.5 + 1/16, 0.5 - 2/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 + 0/16, 0.5 - 1/16},
		}
	},

	on_place = function(itemstack, placer, pointed_thing)

		if not placer or not placer:is_player() then
			return itemstack
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if core.is_protected(pointed_thing.above, placer:get_player_name()) then
			core.record_protection_violation(pointed_thing.above, placer:get_player_name())
			return
		end

		if core.dir_to_wallmounted(vector.subtract(pointed_thing.under,  pointed_thing.above)) == 1 then
			local _, success = core.item_place_node(itemstack, placer, pointed_thing, core.dir_to_facedir(vector.direction(placer:get_pos(),pointed_thing.above)))
			if not success then
				return
			end
			core.sound_play(mcl_sounds.node_sound_wood_defaults().place, {pos=pointed_thing.above, gain=1}, true)
		end
		return itemstack
	end,
}

core.register_node("mcl_lectern:lectern", table.merge(lectern_tpl,{
	on_rightclick = function(pos, node, clicker, itemstack)
		if itemstack:get_name() == "mcl_books:written_book"
			or itemstack:get_name() == "mcl_books:writable_book" then
			local player_name = clicker:get_player_name()
			if core.is_protected(pos, player_name) then
				core.record_protection_violation(pos, player_name)
				return
			end
			local im = itemstack:get_meta()
			local nm = core.get_meta(pos)
			node.name = "mcl_lectern:lectern_with_book"
			mcl_redstone.swap_node(pos,node)
			nm:set_string("formspec",get_formspec(im:get_string("text"),im:get_string("title"),im:get_string("author")))
			if itemstack:get_name() == "mcl_books:written_book" then
				nm:set_string("infotext", im:get_string("author") .. " - " .. im:get_string("title"))
			end
			nm:set_string("pages","15")
			nm:set_string("page","1")
			local book_item = ItemStack(itemstack)
			if not core.is_creative_enabled(player_name) then
				book_item = itemstack:take_item()
			end
			book_item:set_count(1)
			nm:set_string("book_item", book_item:to_string())
			return itemstack
		end
	end,
	_mcl_redstone = {
		connects_to = function()
			return true
		end,
	},
}))

core.register_node("mcl_lectern:lectern_with_book", table.merge( lectern_tpl,{
	groups = table.merge(lectern_tpl.groups, {not_in_creative_inventory = 1}),
	mesh = "mcl_lectern_lectern_with_book.obj",
	on_receive_fields = function(pos, _, fields, sender)
		local sender_name = sender:get_player_name()
		if core.is_protected(pos, sender_name) then
			core.record_protection_violation(pos, sender_name)
			return
		end
		if fields and fields.take then
			local inv = sender:get_inventory()
			local node = core.get_node(pos)
			local nm = core.get_meta(pos)
			local is = nm:get_string("book_item")
			if is and is ~= "" then
				inv:add_item("main", is)
			end
			node.name = "mcl_lectern:lectern"
			core.set_node(pos, node)
			mcl_redstone.update_comparators(pos)
		elseif fields and fields.ok then
			-- simulate a page turn
			-- TODO: actually implement multi page books
			local node = core.get_node(pos)
			local nm = core.get_meta(pos)
			local pages = tonumber(nm:get_string("pages")) or 1
			local page = tonumber(nm:get_string("page")) or 1
			page = (page % pages) + 1
			nm:set_string("page",tostring(page))
			if node.param2 < 128 then
				node.param2 = node.param2 + 128
				mcl_redstone.swap_node(pos,node)
			end
		end
	end,
	after_dig_node = function(pos, _, oldmetadata, _)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.book_item then
			core.add_item(pos, ItemStack(oldmetadata.fields.book_item))
		end
	end,
	_mcl_redstone = {
		connects_to = function()
			return true
		end,
		get_power = function(node, dir)
			local powered = node.param2 >= 128
			return powered and 15 or 0, dir.y < 0
		end,
		update = function(_, node)
			local powered = node.param2 >= 128
			if powered then
				return {
					name = node.name,
					param2 = node.param2 - 128,
				}
			end
		end,
	},
}))

mcl_wip.register_wip_item("mcl_lectern:lectern")

-- April Fools setup
local date = os.date("*t")
if (date.month == 4 and date.day == 1) then
	core.override_item("mcl_lectern:lectern", {waving = 2})
end

core.register_craft({
	output = "mcl_lectern:lectern",
	recipe = {
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
		{"", "mcl_books:bookshelf", ""},
		{"", "group:wood_slab", ""},
	}
})
