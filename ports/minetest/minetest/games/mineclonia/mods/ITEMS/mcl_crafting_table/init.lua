local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local C = core.colorize
mcl_crafting_table = {}

mcl_crafting_table.formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[2.25,0.375;" .. F(C(mcl_formspec.label_color, S("Crafting"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.25, 0.75, 3, 3),
	"list[current_player;craft;2.25,0.75;3,3;]",

	"image[6.125,2;1.5,1;gui_crafting_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(8.2, 2, 1, 1, 0.2),
	"list[current_player;craftpreview;8.2,2;1,1;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;craft]",
	"listring[current_player;main]",

	--Crafting guide button
	"image_button[0.325,1.95;1.1,1.1;craftguide_book.png;__mcl_craftguide;]",
	"tooltip[__mcl_craftguide;" .. F(S("Recipe book")) .. "]",

	"image_button[6.025,3.175;1,1;mcl_crafting_table_inv_fill.png;__mcl_crafting_fillgrid;]",
	"tooltip[__mcl_crafting_fillgrid;" .. F(S("Fill Craft Grid")) .. "]",
})

function mcl_crafting_table.has_crafting_table(player)
	if not player or not player:get_pos() then return end
	local wdef = player:get_wielded_item():get_definition()
	local range = wdef and wdef.range or ItemStack():get_definition().range or tonumber(core.settings:get("mcl_hand_range")) or 4.5
	return core.is_creative_enabled(player:get_player_name()) or (core.find_node_near(player:get_pos(), range, { "group:crafting_table" }, true) ~= nil)
end

function mcl_crafting_table.show_crafting_form(player)
	if not mcl_crafting_table.has_crafting_table(player) then
		return
	end
	-- temporarily expand crafting grid to 3x3
	local inv = player:get_inventory()
	if inv then
		inv:set_width("craft", 3)
		inv:set_size("craft", 9)
	end

	core.show_formspec(player:get_player_name(), "main", mcl_crafting_table.formspec)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit and formname == "main" then
		local inv = player:get_inventory()
		inv:set_width("craft", 2)
		inv:set_size("craft", 4)
	end
end)

mcl_player.register_globalstep_slow(function(player)
	local inv = player:get_inventory()
	if inv:get_size("craft") > 4 and not mcl_crafting_table.has_crafting_table(player) then
		-- Player managed to get out of range of a crafting table
		-- without triggering the close formspec handler in
		-- mcl_inventory. This can happen when using a hacked client,
		-- but also legitimately when the player is moved by the
		-- environment, e.g. sinking in water.
		--
		-- Trigger the actions that would normally be caused by closing
		-- the formspec.
		core.close_formspec(player:get_player_name(), "main")
		core.run_callbacks(core.registered_on_player_receive_fields, 5, player, "main", { quit = true })
	end
end)

core.register_node("mcl_crafting_table:crafting_table", {
	description = S("Crafting Table"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting table to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = { "crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png" },
	paramtype2 = "facedir",
	groups = { handy = 1, axey = 1, deco_block = 1, material_wood = 1, flammable = -1, crafting_table = 9 },
	on_rightclick = function(_, _, player)
		if not player:get_player_control().sneak then
			mcl_crafting_table.show_crafting_form(player)
		end
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 2.5,
	_mcl_burntime = 15
})

core.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{ "group:wood", "group:wood" },
		{ "group:wood", "group:wood" }
	},
})

core.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
core.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
