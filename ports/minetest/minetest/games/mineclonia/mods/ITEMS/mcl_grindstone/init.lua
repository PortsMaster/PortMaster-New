mcl_grindstone = {}

local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape
local C = core.colorize

local MAX_WEAR = 65535

local grindstone_formspec = table.concat({
	"formspec_version[6]",
	"size[11.75,10.425]",

	"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Repair & Disenchant"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.875, 1.25, 1, 1),
	"list[context;input;2.875,1.25;1,1;]",

	mcl_formspec.get_itemslot_bg_v4(2.875, 2.625, 1, 1),
	"list[context;input;2.875,2.625;1,1;1]",

	"image[5.125,1.95;1.5,1;gui_crafting_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(7.875, 1.9375, 1, 1),
	"list[context;output;7.875,1.9375;1,1;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[context;output]",
	"listring[current_player;main]",
	"listring[context;input]",
	"listring[current_player;main]",
})

-- Creates a new item with the wear of the items and custom name
local function create_new_item(name_item, meta, wear)
	local new_item = ItemStack(name_item)
	if wear ~= nil then
		new_item:set_wear(wear)
		local tooldef = new_item:get_definition ()
		if tooldef and tooldef._on_repair then
			tooldef._on_repair (new_item)
		end
	end
	local new_meta = new_item:get_meta()
	new_meta:set_string("name", meta:get_string("name"))
	return new_item
end

-- If an input has a curse transfer it to the new item
local function transfer_curse(old_itemstack, new_itemstack)
	local enchants = mcl_enchanting.get_enchantments(old_itemstack)
	for enchant, level in pairs(enchants) do
		if mcl_enchanting.is_curse(enchant) then
			new_itemstack = mcl_enchanting.enchant(new_itemstack, enchant, level)
		end
	end
	return new_itemstack
end

-- Depending on an enchantment level and isn't a curse multiply xp given
local function calculate_xp(stack)
	local xp = 0
	local enchants = mcl_enchanting.get_enchantments(stack)
	for enchant, level in pairs(enchants) do
		if level > 0 and not mcl_enchanting.is_curse(enchant) then
			-- Add a bit of uniform randomisation
			xp = xp + math.random(7, 13) * level
		end
	end
	return xp
end

-- Helper function to make sure update_grindstone_slots NEVER overstacks the output slot
local function fix_stack_size(stack)
	if not stack or stack == "" then return "" end
	local count = stack:get_count()
	local max_count = stack:get_stack_max()

	if count > max_count then
		stack:set_count(max_count)
		count = max_count
	end
	return count
end

-- If an item has an enchanment then remove "_enchanted" from the name
function mcl_grindstone.remove_enchant_name(stack)
	local name = stack:get_name()
	if mcl_enchanting.is_enchanted(name) then
		name = name:gsub("_enchanted$", "")
	end
	return name
end

-- Accepts an itemstack and returns the disenchanted version of said stack (curses are kept)
-- Returns an empty string if nothing changed.
function mcl_grindstone.disenchant(stack)
	local def = stack:get_definition()
	local meta = stack:get_meta()
	local new_item = ""
	if def.type == "tool" and mcl_enchanting.is_enchanted(stack:get_name()) then
		new_item = create_new_item(mcl_grindstone.remove_enchant_name(stack), meta, stack:get_wear())
		new_item = transfer_curse(stack, new_item)
	elseif stack:get_name() == "mcl_enchanting:book_enchanted" then
		new_item = create_new_item("mcl_books:book", meta, nil)
		new_item = transfer_curse(stack, new_item)
	end
	return new_item
end

-- Update the inventory slots of an grindstone node.
-- meta: Metadata of grindstone node
local function update_grindstone_slots(meta)
	local inv = meta:get_inventory()
	local input1 = inv:get_stack("input", 1)
	local input2 = inv:get_stack("input", 2)
	local meta = input1:get_meta()

	local new_output = ""

	if not input1:is_empty() and not input2:is_empty() then
		local def1 = input1:get_definition()
		local def2 = input2:get_definition()
		local name1 = mcl_grindstone.remove_enchant_name(input1)
		local name2 = mcl_grindstone.remove_enchant_name(input2)

		local function calculate_repair(dur1, dur2)
			-- Grindstone gives a 5% bonus to durability
			local new_durability = (MAX_WEAR - dur1) + (MAX_WEAR - dur2) * 1.05
			return math.max(0, math.min(MAX_WEAR, MAX_WEAR - new_durability))
		end

		if def1.type == "tool" and def2.type == "tool" and name1 == name2 then
			local new_wear = calculate_repair(input1:get_wear(), input2:get_wear())
			local new_item = create_new_item(name1, meta, new_wear)
			new_output = transfer_curse(input1, new_item)
			new_output = transfer_curse(input2, new_output)
		end
	else
		if input2:is_empty() and not input1:is_empty() then
			new_output = mcl_grindstone.disenchant(input1)
		elseif input1:is_empty() and not input2:is_empty() then
			new_output = mcl_grindstone.disenchant(input2)
		end
	end

	if new_output then
		fix_stack_size(new_output)
		inv:set_stack("output", 1, new_output)
	end
end

local node_box = {
	type = "fixed",
	fixed = {
		{ -0.25, -0.25, -0.375, 0.25, 0.5, 0.375 },
		{ -0.375, -0.0625, -0.1875, -0.25, 0.3125, 0.1875 },
		{ 0.25, -0.0625, -0.1875, 0.375, 0.3125, 0.1875 },
		{ 0.25, -0.5, -0.125, 0.375, -0.0625, 0.125 },
		{ -0.375, -0.5, -0.125, -0.25, -0.0625, 0.125 },
	}
}

core.register_node("mcl_grindstone:grindstone", {
	description = S("Grindstone"),
	_tt_help = S("Used to disenchant/fix tools"),
	_doc_items_longdesc = S("Grindstone disenchants tools and armour except for curses, and repairs two items of the same type it is also the weapon smith's work station."),
	_doc_items_usagehelp = S("To use the grindstone, rightclick it, Two input slots (on the left) and a single output slot.") .. "\n" ..
		S("To disenchant an item place enchanted item in one of the input slots and take the disenchanted item from the output.") .. "\n" ..
		S("To repair a tool you need a tool of the same type and material, put both items in the input slot and the output slot will combine two items durabilities with 5% bonus.") .. "\n" ..
		S("If both items have enchantments the player will get xp from both items from the disenchant.") .. "\n" ..
		S("Curses cannot be removed and will be transfered to the new repaired item, if both items have a different curse the curses will be combined."),
	tiles = {
		"grindstone_top.png",
		"grindstone_top.png",
		"grindstone_side.png",
		"grindstone_side.png",
		"grindstone_front.png",
		"grindstone_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = node_box,
	selection_box = node_box,
	collision_box = node_box,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = { pickaxey = 1, deco_block = 1, pathfinder_partial = 2, },
	after_dig_node = mcl_util.drop_items_from_meta_container({"input"}),
	_configures_formspec = true,
	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, _, count, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		elseif to_list == "output" then
			return 0
		elseif from_list == "output" and to_list == "input" then
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item(to_list, inv:get_stack(from_list, from_index)) then
				return count
			else
				return 0
			end
		else
			return count
		end
	end,
	on_metadata_inventory_put = function(pos)
		local meta = core.get_meta(pos)
		update_grindstone_slots(meta)
	end,
	on_metadata_inventory_move = function(pos, from_list, _, to_list, to_index, count)
		local meta = core.get_meta(pos)
		if from_list == "output" and to_list == "input" then
			local inv = meta:get_inventory()
			for i = 1, inv:get_size("input") do
				if i ~= to_index then
					local istack = inv:get_stack("input", i)
					istack:set_count(math.max(0, istack:get_count() - count))
					inv:set_stack("input", i, istack)
				end
			end
		end
		update_grindstone_slots(meta)
	end,
	on_metadata_inventory_take = function(pos, listname, _, stack)
		local meta = core.get_meta(pos)
		if listname == "output" then
			local xp_earnt = 0
			local inv = meta:get_inventory()
			local input1 = inv:get_stack("input", 1)
			local input2 = inv:get_stack("input", 2)
			-- Both slots occupied?
			if not input1:is_empty() and not input2:is_empty() then
				-- Get xp earnt from the enchanted items
				xp_earnt = calculate_xp(input1) + calculate_xp(input1)
				input1:take_item(1)
				input2:take_item(1)
				inv:set_stack("input", 1, input1)
				inv:set_stack("input", 2, input2)
			else
				if not input1:is_empty() then
					xp_earnt = calculate_xp(input1)
					input1:set_count(math.max(0, input1:get_count() - stack:get_count()))
					inv:set_stack("input", 1, input1)
				end
				if not input2:is_empty() then
					xp_earnt = calculate_xp(input2)
					input2:set_count(math.max(0, input2:get_count() - stack:get_count()))
					inv:set_stack("input", 2, input2)
				end
			end
			if mcl_experience.throw_xp and xp_earnt > 0 then
				mcl_experience.throw_xp(pos, xp_earnt)
			end
		elseif listname == "input" then
			update_grindstone_slots(meta)
		end
	end,

	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 2)
		inv:set_size("output", 1)
		meta:set_string("formspec", grindstone_formspec)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		-- scuffed wallmounted like implementation for compatibility
		local pos_diff = vector.subtract(pos, placer:get_pos())
		local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
		local facedir = 0

		if dir.z == -1 then
			facedir = 4
		elseif dir.z == 1 then
			facedir = 10
		elseif dir.x == -1 then
			facedir = 13
		elseif dir.x == 1 then
			facedir = 17
		elseif dir.y ~= 0 then
			facedir = math.abs(pos_diff.z) > math.abs(pos_diff.x) and 0 or 1
			if dir.y == 1 then
				facedir = facedir + 20
			end
		end
		core.swap_node(pos, {name = "mcl_grindstone:grindstone", param2 = facedir})
	end,
	on_rightclick = function(pos, _, player)
		if player and player:is_player() and not player:get_player_control().sneak then
			local meta = core.get_meta(pos)
			update_grindstone_slots(meta)
			meta:set_string("formspec", grindstone_formspec)
		end
	end,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2
})

core.register_craft({
	output = "mcl_grindstone:grindstone",
	recipe = {
		{ "mcl_core:stick", "mcl_stairs:slab_stone_rough", "mcl_core:stick" },
		{ "group:wood", "", "group:wood" },
	}
})
