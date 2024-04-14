local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

local MAX_NAME_LENGTH = 35
local MAX_WEAR = 65535
local SAME_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.12) -- 12%
local MATERIAL_TOOL_REPAIR_BOOST = {
	math.ceil(MAX_WEAR * 0.25), -- 25%
	math.ceil(MAX_WEAR * 0.5), -- 50%
	math.ceil(MAX_WEAR * 0.75), -- 75%
	MAX_WEAR, -- 100%
}

local function get_anvil_formspec(set_name, player, cost)
	if not set_name then
		set_name = ""
	end
	local cost_label = ""
	if player and not minetest.is_creative_enabled(player:get_player_name()) and cost and cost > 0 then
		local st = S("Levels")
		if cost == 1 then st = S("Level") end
		local c = "label[9.125,4.225;"
		cost_label = c..F(C(mcl_formspec.label_color, tostring(cost).." "..st)).."]"
		if player and mcl_experience.get_level(player) < cost then
			cost_label = c..F(C(mcl_colors.RED, S("Too expensive!"))).."]"
		end
	end
	return table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",

		"label[4.125,0.375;" .. F(C(mcl_formspec.label_color, S("Repair and Name"))) .. "]",

		"image_button[0.875,0.375;1.75,1.75;mcl_anvils_inventory_hammer.png;anvil_set_name;]",
		"tooltip[anvil_set_name;" .. F(S("Repair and Name")) .. "]",

		"field[4.125,0.75;7.25,1;name;;" .. F(set_name) .. "]",
		"field_close_on_enter[name;false]",
		"set_focus[name;true]",

		mcl_formspec.get_itemslot_bg_v4(1.625, 2.6, 1, 1),
		"list[context;input;1.625,2.6;1,1;]",

		"image[3.5,2.6;1,1;mcl_anvils_inventory_cross.png]",

		mcl_formspec.get_itemslot_bg_v4(5.375, 2.6, 1, 1),
		"list[context;input;5.375,2.6;1,1;1]",

		"image[6.75,2.6;2,1;mcl_anvils_inventory_arrow.png]",

		mcl_formspec.get_itemslot_bg_v4(9.125, 2.6, 1, 1),
		"list[context;output;9.125,2.6;1,1;]",

		-- Player Inventory

		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		cost_label,
		-- Listrings

		"listring[context;output]",
		"listring[current_player;main]",
		"listring[context;input]",
		"listring[current_player;main]",
	})
end

-- Given a tool and material stack, returns how many items of the material stack
-- needs to be used up to repair the tool.
local function get_consumed_materials(tool, material)
	local wear = tool:get_wear()
	--local health = (MAX_WEAR - wear)
	local matsize = material:get_count()
	local materials_used = 0
	for m = 1, math.min(4, matsize) do
		materials_used = materials_used + 1
		if (wear - MATERIAL_TOOL_REPAIR_BOOST[m]) <= 0 then
			break
		end
	end
	return materials_used
end

-- Given 2 input stacks, tells you which is the tool and which is the material.
-- Returns ("tool", input1, input2) if input1 is tool and input2 is material.
-- Returns ("material", input2, input1) if input1 is material and input2 is tool.
-- Returns nil otherwise.
local function distinguish_tool_and_material(input1, input2)
	local def1 = input1:get_definition()
	local def2 = input2:get_definition()
	local r1 = def1._repair_material
	local r2 = def2._repair_material
	if def1.type == "tool" and r1 and type(r1) == "table" and table.indexof(r1, input2) ~= -1 then
		return "tool", input1, input2
	elseif def2.type == "tool" and r2 and type(r2) == "table" and table.indexof(r1, input1) ~= -1 then
		return "material", input2, input1
	elseif def1.type == "tool" and r1 then
		return "tool", input1, input2
	elseif def2.type == "tool" and r2 then
		return "material", input2, input1
	else
		return nil
	end
end

---Helper function to make sure update_anvil_slots NEVER overstacks the output slot
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

local function clear_cost(meta, cost) meta:set_string("mcl_anvil:xp_cost", "") end

local function add_cost(meta, cost)
	local old = meta:get_int("mcl_anvil:xp_cost")
	meta:set_int("mcl_anvil:xp_cost", old + cost)
end

-- Update the inventory slots of an anvil node.
-- meta: Metadata of anvil node
local function update_anvil_slots(meta, player)
	local inv = meta:get_inventory()
	local new_name = meta:get_string("set_name")
	local input1 = inv:get_stack("input", 1)
	local input2 = inv:get_stack("input", 2)
	--local output = inv:get_stack("output", 1)
	local new_output, name_item
	local just_rename = false

	clear_cost(meta)
	-- Both input slots occupied
	if (not input1:is_empty() and not input2:is_empty()) then
		add_cost(meta, mcl_enchanting.get_prior_work_penalty(input1) + mcl_enchanting.get_prior_work_penalty(input2))
		-- Repair, if tool
		local def1 = input1:get_definition()
		local def2 = input2:get_definition()

		-- Repair calculation helper.
		-- Adds the “inverse” values of wear1 and wear2.
		-- Then adds a boost health value directly.
		-- Returns the resulting (capped) wear.
		local function calculate_repair(wear1, wear2, boost)
			local new_health = (MAX_WEAR - wear1) + (MAX_WEAR - wear2)
			if boost then
				new_health = new_health + boost
			end
			return math.max(0, math.min(MAX_WEAR, MAX_WEAR - new_health))
		end

		local can_combine, enchanting_level_requirements = mcl_enchanting.combine(input1, input2)

		if can_combine then
			-- Add tool health together plus a small bonus
			if def1.type == "tool" and def2.type == "tool" then
				local new_wear = calculate_repair(input1:get_wear(), input2:get_wear(), SAME_TOOL_REPAIR_BOOST)
				input1:set_wear(new_wear)
			end

			add_cost(meta, enchanting_level_requirements)
			name_item = input1
			new_output = name_item
			-- Tool + repair item
		else
			-- Any tool can have a repair item. This may be defined in the tool's item definition
			-- as an itemstring in the field `_repair_material`. Only if this field is set, the
			-- tool can be repaired with a material item.
			-- Example: Iron Pickaxe + Iron Ingot. `_repair_material = mcl_core:iron_ingot`

			-- Big repair bonus
			-- TODO: Combine tool enchantments
			local distinguished, tool, material = distinguish_tool_and_material(input1, input2)
			if distinguished then
				local tooldef = tool:get_definition()
				local repair = tooldef._repair_material
				local has_correct_material = false
				local material_name = material:get_name()
				if type(repair) == "string" then
					if string.sub(repair, 1, 6) == "group:" then
						has_correct_material = minetest.get_item_group(material_name, string.sub(repair, 7)) ~= 0
					elseif material_name == repair then
						has_correct_material = true
					end
				else
					if table.indexof(repair, material_name) ~= -1 then
						has_correct_material = true
					else
						for _, r in pairs(repair) do
							if string.sub(r, 1, 6) == "group:" then
								if minetest.get_item_group(material_name, string.sub(r, 7)) ~= 0 then
									has_correct_material = true
								end

							end
						end
					end
				end
				if has_correct_material and tool:get_wear() > 0 then
					local materials_used = get_consumed_materials(tool, material)
					local new_wear = calculate_repair(tool:get_wear(), MAX_WEAR, MATERIAL_TOOL_REPAIR_BOOST[materials_used])
					add_cost(meta, 2)
					tool:set_wear(new_wear)
					name_item = tool
					new_output = name_item
				else
					new_output = ""
				end
			else
				new_output = ""
			end
		end
		-- Exactly 1 input slot occupied
	elseif (not input1:is_empty() and input2:is_empty()) or (input1:is_empty() and not input2:is_empty()) then
		-- Just rename item
		if input1:is_empty() then
			name_item = input2
		else
			name_item = input1
		end
		just_rename = true
	else
		new_output = ""
	end

	-- Rename handling
	if name_item then
		-- No renaming allowed with group no_rename=1
		if minetest.get_item_group(name_item:get_name(), "no_rename") == 1 then
			new_output = ""
		else
			if new_name == nil then
				new_name = ""
			else
				add_cost(meta, 1)
			end
			local meta = name_item:get_meta()
			local old_name = meta:get_string("name")
			-- Limit name length
			new_name = string.sub(new_name, 1, MAX_NAME_LENGTH)
			-- Don't rename if names are identical
			if new_name ~= old_name then
				-- Save the raw name internally
				meta:set_string("name", new_name)
				-- Rename item handled by tt
				tt.reload_itemstack_description(name_item)
				new_output = name_item
			elseif just_rename then
				new_output = ""
			end
		end
	end

	-- Set the new output slot
	if minetest.is_creative_enabled(player:get_player_name()) then clear_cost(meta)	end

	local cost = meta:get_int("mcl_anvil:xp_cost")
	local has_result = not ItemStack(new_output):is_empty()
	if new_output and mcl_experience.get_level(player) >= cost then
		meta:set_string("formspec", get_anvil_formspec(new_name, player, cost))
		fix_stack_size(new_output)
		inv:set_stack("output", 1, new_output)
	elseif has_result and mcl_experience.get_level(player) < cost then
		meta:set_string("formspec", get_anvil_formspec(new_name, player, cost))
	end

	if not has_result then
		meta:set_string("formspec", get_anvil_formspec())
		inv:set_stack("output", 1, ItemStack(""))
	end
end

---Drop input items of anvil at pos with metadata meta
local drop_contents = mcl_util.drop_items_from_meta_container({"input"})

local function damage_particles(pos, node)
	minetest.add_particlespawner({
		amount = 30,
		time = 0.1,
		minpos = vector.offset(pos, -0.5, -0.5, -0.5),
		maxpos = vector.offset(pos, 0.5, -0.25, 0.5),
		minvel = vector.new(-0.5, 0.05, -0.5),
		maxvel = vector.new(0.5, 0.3, 0.5),
		minacc = vector.new(0, -9.81, 0),
		maxacc = vector.new(0, -9.81, 0),
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.4,
		maxsize = 0.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

local function destroy_particles(pos, node)
	minetest.add_particlespawner({
		amount = math.random(20, 30),
		time = 0.1,
		minpos = vector.offset(pos, -0.4, -0.4, -0.4),
		maxpos = vector.offset(pos, 0.4, 0.4, 0.4),
		minvel = vector.new(-0.5, -0.1, -0.5),
		maxvel = vector.new(0.5, 0.2, 0.5),
		minacc = vector.new(0, -9.81, 0),
		maxacc = vector.new(0, -9.81, 0),
		minexptime = 0.2,
		maxexptime = 0.65,
		minsize = 0.8,
		maxsize = 1.2,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-- Damage the anvil by 1 level.
-- Destroy anvil when at highest damage level.
-- Returns true if anvil was destroyed.
local function damage_anvil(pos)
	local node = minetest.get_node(pos)
	if node.name == "mcl_anvils:anvil" then
		minetest.swap_node(pos, { name = "mcl_anvils:anvil_damage_1", param2 = node.param2 })
		damage_particles(pos, node)
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dig, { pos = pos, max_hear_distance = 16 }, true)
		return false
	elseif node.name == "mcl_anvils:anvil_damage_1" then
		minetest.swap_node(pos, { name = "mcl_anvils:anvil_damage_2", param2 = node.param2 })
		damage_particles(pos, node)
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dig, { pos = pos, max_hear_distance = 16 }, true)
		return false
	elseif node.name == "mcl_anvils:anvil_damage_2" then
		drop_contents(pos, node, minetest.get_meta(pos))
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dug, { pos = pos, max_hear_distance = 16 }, true)
		minetest.remove_node(pos)
		destroy_particles(pos, node)
		minetest.check_single_for_falling(vector.offset(pos, 0, 1, 0))
		return true
	end
end

---Roll a virtual dice and damage anvil at a low chance.
local function damage_anvil_by_using(pos)
	local r = math.random(1, 100)
	-- 12% chance
	if r <= 12 then
		return damage_anvil(pos)
	else
		return false
	end
end

local function damage_anvil_by_falling(pos, distance)
	local r = math.random(1, 100)
	if distance > 1 then
		if r <= (5 * distance) then
			damage_anvil(pos)
		end
	end
end

local anvilbox = {
	type = "fixed",
	fixed = {
		{ -8 / 16, -8 / 16, -6 / 16, 8 / 16, 8 / 16, 6 / 16 },
	},
}

local anvildef = {
	groups = { pickaxey = 1, falling_node = 1, falling_node_damage = 1, crush_after_fall = 1, deco_block = 1, anvil = 1 },
	tiles = { "mcl_anvils_anvil_top_damaged_0.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png" },
	use_texture_alpha = "opaque",
	_tt_help = S("Repair and rename items"),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -6 / 16, -8 / 16, -6 / 16, 6 / 16, -4 / 16, 6 / 16 },
			{ -5 / 16, -4 / 16, -4 / 16, 5 / 16, -3 / 16, 4 / 16 },
			{ -4 / 16, -3 / 16, -2 / 16, 4 / 16, 2 / 16, 2 / 16 },
			{ -8 / 16, 2 / 16, -5 / 16, 8 / 16, 8 / 16, 5 / 16 },
		},
	},
	selection_box = anvilbox,
	collision_box = anvilbox,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,
	_mcl_after_falling = damage_anvil_by_falling,

	after_dig_node = drop_contents,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" and not minetest.is_creative_enabled(player:get_player_name()) then
			local meta = minetest.get_meta(pos)
			local player_level = mcl_experience.get_level(player)
			local anvil_costs = meta:get_int("mcl_anvil:xp_cost")
			if player_level < anvil_costs then
				return 0
			end
		end
		return stack:get_count()
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
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		update_anvil_slots(meta, player)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
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
		update_anvil_slots(meta, player)

		if from_list == "output" then
			local destroyed
			if not minetest.is_creative_enabled(player:get_player_name()) then
				destroyed = damage_anvil_by_using(pos)
			end
			-- Close formspec if anvil was destroyed
			if destroyed then
				--[[ Closing the formspec w/ emptyformname is discouraged. But this is justified
				because node formspecs seem to only have an empty formname in MT 0.4.16.
				Also, sice this is on_metadata_inventory_take, we KNOW which formspec has
				been opened by the player. So this should be safe nonetheless.
				TODO: Update this line when node formspecs get proper identifiers in Minetest. ]]
				minetest.close_formspec(player:get_player_name(), "")
			end
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local input1 = inv:get_stack("input", 1)
			local input2 = inv:get_stack("input", 2)

			local player_level = mcl_experience.get_level(player)
			local anvil_costs = meta:get_int("mcl_anvil:xp_cost")
			if player_level < anvil_costs then
				return
			end
			clear_cost(meta)
			if not minetest.is_creative_enabled(player:get_player_name()) then
				mcl_experience.set_level(player, player_level - anvil_costs)
			end

			-- Both slots occupied?
			if not input1:is_empty() and not input2:is_empty() then
				-- Take as many items as needed
				local distinguished, tool, material = distinguish_tool_and_material(input1, input2)
				if distinguished then
					-- Tool + material: Take tool and as many materials as needed
					local materials_used = get_consumed_materials(tool, material)
					material:set_count(material:get_count() - materials_used)
					tool:take_item()
					if distinguished == "tool" then
						input1, input2 = tool, material
					else
						input1, input2 = material, tool
					end
					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				else
					-- Else take 1 item from each stack
					input1:take_item()
					input2:take_item()
					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				end
			else
				-- Otherwise: Rename mode. Remove the same amount of items from input
				-- as has been taken from output
				if not input1:is_empty() then
					input1:set_count(math.max(0, input1:get_count() - stack:get_count()))
					inv:set_stack("input", 1, input1)
				end
				if not input2:is_empty() then
					input2:set_count(math.max(0, input2:get_count() - stack:get_count()))
					inv:set_stack("input", 2, input2)
				end
			end
			local destroyed
			if not minetest.is_creative_enabled(player:get_player_name()) then
				destroyed = damage_anvil_by_using(pos)
			end
			-- Close formspec if anvil was destroyed
			if destroyed then
				-- See above for justification.
				minetest.close_formspec(player:get_player_name(), "")
			end
		elseif listname == "input" then
			update_anvil_slots(meta, player)
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 2)
		inv:set_size("output", 1)
		local form = get_anvil_formspec()
		meta:set_string("formspec", form)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end

		if fields.name then
			local meta = minetest.get_meta(pos)

			-- Limit name length
			local set_name = string.sub(fields.name, 1, MAX_NAME_LENGTH)

			meta:set_string("set_name", set_name)
			update_anvil_slots(meta, sender)
		end
	end,
}

if minetest.get_modpath("screwdriver") then
	anvildef.on_rotate = screwdriver.rotate_simple
end

minetest.register_node("mcl_anvils:anvil", table.merge(anvildef, {
	description = S("Anvil"),
	_doc_items_longdesc =	S("The anvil allows you to repair tools and armor, and to give names to items. It has a limited durability, however. Don't let it fall on your head, it could be quite painful!"),
	_doc_items_usagehelp = S("To use an anvil, rightclick it. An anvil has 2 input slots (on the left) and one output slot.") .. "\n" ..
	S("To rename items, put an item stack in one of the item slots while keeping the other input slot empty. Type in a name, hit enter or “Set Name”, then take the renamed item from the output slot.")
	.. "\n" ..
	S("There are two possibilities to repair tools (and armor):") .. "\n" ..
	S("• Tool + Tool: Place two tools of the same type in the input slots. The “health” of the repaired tool is the sum of the “health” of both input tools, plus a 12% bonus.")
	.. "\n" ..
	S("• Tool + Material: Some tools can also be repaired by combining them with an item that it's made of. For example, iron pickaxes can be repaired with iron ingots. This repairs the tool by 25%.")
	.. "\n" ..
	S("Armor counts as a tool. It is possible to repair and rename a tool in a single step.") .. "\n\n" ..
	S("The anvil has limited durability and 3 damage levels: undamaged, slightly damaged and very damaged. Each time you repair or rename something, there is a 12% chance the anvil gets damaged. Anvils also have a chance of being damaged when they fall by more than 1 block. If a very damaged anvil is damaged again, it is destroyed."),
}))

local anvildef1 = table.merge(anvildef, {
	description = S("Slightly Damaged Anvil"),
	_doc_items_create_entry = false,
	groups = table.merge(anvildef.groups, {anvil = 2}),
	tiles = { "mcl_anvils_anvil_top_damaged_1.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png" }
})
minetest.register_node("mcl_anvils:anvil_damage_1", anvildef1)

minetest.register_node("mcl_anvils:anvil_damage_2", table.merge(anvildef1, {
	description = S("Very Damaged Anvil"),
	groups = table.merge(anvildef.groups, {anvil = 3}),
	tiles = { "mcl_anvils_anvil_top_damaged_2.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png" }
}))

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "mcl_anvils:anvil",
		recipe = {
			{ "mcl_core:ironblock", "mcl_core:ironblock", "mcl_core:ironblock" },
			{ "", "mcl_core:iron_ingot", "" },
			{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
		},
	})
end

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_anvils:anvil", "nodes", "mcl_anvils:anvil_damage_1")
	doc.add_entry_alias("nodes", "mcl_anvils:anvil", "nodes", "mcl_anvils:anvil_damage_2")
end

-- Legacy
minetest.register_lbm({
	label = "Update anvil formspecs (0.60.0)",
	name = "mcl_anvils:update_formspec_0_60_0",
	nodenames = { "group:anvil" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local set_name = meta:get_string("set_name")
		meta:set_string("formspec", get_anvil_formspec(set_name))
	end,
})
