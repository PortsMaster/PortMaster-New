local S = core.get_translator(core.get_current_modname())
local C = core.colorize
local F = core.formspec_escape

local dispenser_formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[4.125,0.375;" .. F(C(mcl_formspec.label_color, S("Dispenser"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(4.125, 0.75, 3, 3),
	"list[context;main;4.125,0.75;3,3;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[context;main]",
	"listring[current_player;main]",
})

local function setup_dispenser(pos)
	local meta = core.get_meta(pos)
	meta:set_string("formspec", dispenser_formspec)
	local inv = meta:get_inventory()
	inv:set_size("main", 9)
end

local function orientate(pos, placer, basename)
	if not placer then return end

	local pitch_deg = placer:get_look_vertical() * (180 / math.pi)

	local node = core.get_node(pos)
	if pitch_deg > 55 then
		core.swap_node(pos, { name = "mcl_dispensers:"..basename.."_up", param2 = node.param2 })
	elseif pitch_deg < -55 then
		core.swap_node(pos, { name = "mcl_dispensers:"..basename.."_down", param2 = node.param2 })
	end
end

local function drop(pos, droppos, dropitem, inv, stack_)
	-- Drop item normally
	local pos_variation = 100
	droppos = vector.offset(droppos,
		math.random(-pos_variation, pos_variation) / 1000,
		math.random(-pos_variation, pos_variation) / 1000,
		math.random(-pos_variation, pos_variation) / 1000
	)
	local item_entity = core.add_item(droppos, dropitem)
	if item_entity then
		local drop_vel = vector.subtract(droppos, pos)
		local speed = 3
		item_entity:set_velocity(vector.multiply(drop_vel, speed))
		stack_.stack:take_item()
		inv:set_stack("main", stack_.stackpos, stack_.stack)
	end
end

local function activate_dropper(pos, droppos, dropdir, inv, stack_)
	local dropnode = core.get_node(droppos)
	local dropitem = ItemStack(stack_.stack)
	dropitem:set_count(1)

	local dropped = mcl_util.move_item_container(pos, droppos, nil, stack_.stackpos)
	if not dropped and core.get_item_group(dropnode.name, "container") == 0 then
		drop(pos, droppos, dropitem, inv, stack_)
	end
	mcl_redstone.update_comparators(pos)
end

local function activate_dispenser(pos, droppos, dropdir, inv, stack_)
	local node = core.get_node(pos)
	local dropnode = core.get_node(droppos)
	local dropnodedef = core.registered_nodes[dropnode.name]
	local dropitem = ItemStack(stack_.stack)
	dropitem:set_count(1)
	local stack = stack_.stack
	local stack_id = stack_.stackpos
	local stackdef = stack:get_definition()
	if not stackdef then
		return
	end

	local iname = stack:get_name()
	local igroups = stackdef.groups

	-- Dispense item on luaentity
	for obj in core.objects_inside_radius(droppos, 1) do
		local ent = obj:get_luaentity()
		if ent and ent._on_dispense then
			local pos = obj:get_pos()
			local od_ret = ent:_on_dispense(stack, pos, droppos, dropnode, dropdir)
			if od_ret then
				inv:set_stack("main", stack_id, od_ret)
				mcl_redstone.update_comparators(pos)
				return
			end
		end
	end

	if igroups.armor then -- Armor, mob heads and pumpkins
		local droppos_below = vector.offset(droppos, 0, -1, 0)
		for _, objs in ipairs({ core.get_objects_inside_radius(droppos, 1),
			core.get_objects_inside_radius(droppos_below, 1) }) do
			for _, obj in ipairs(objs) do
				stack = mcl_armor.equip(stack, obj)
				if stack:is_empty() then
					break
				end
			end
			if stack:is_empty() then
				break
			end
		end

		-- Place head or pumpkin as node, if equipping it as armor has failed
		if not stack:is_empty() then
			if igroups.head or iname == "mcl_farming:pumpkin_face" then
				if dropnodedef.buildable_to then
					core.set_node(droppos, { name = iname, param2 = node.param2 })
					stack:take_item()
				end
			end
		end

		inv:set_stack("main", stack_id, stack)
	elseif igroups.spawn_egg then
		if not dropnodedef.walkable then
			core.add_entity(droppos, stack:get_name())

			stack:take_item()
			inv:set_stack("main", stack_id, stack)
		end
	elseif dropnodedef and (not dropnodedef.walkable or stackdef._dispense_into_walkable) then
		if stackdef._on_dispense then -- Item-specific dispension (if defined)
			if not pos then
				error("no pos")
			end
			if not droppos then
				error("no droppos")
			end
			if not dropdir then
				error("no drodir")
			end
			local od_ret = stackdef._on_dispense(dropitem, pos, droppos, dropnode, dropdir)
			if od_ret then
				local newcount = stack:get_count() - 1
				stack:set_count(newcount)
				inv:set_stack("main", stack_id, stack)
				if newcount == 0 then
					inv:set_stack("main", stack_id, od_ret)
				elseif inv:room_for_item("main", od_ret) then
					inv:add_item("main", od_ret)
				else
					local pos_variation = 100
					droppos = {
						x = droppos.x + math.random(-pos_variation, pos_variation) / 1000,
						y = droppos.y + math.random(-pos_variation, pos_variation) / 1000,
						z = droppos.z + math.random(-pos_variation, pos_variation) / 1000,
					}
					local item_entity = core.add_item(droppos, dropitem)
					local drop_vel = vector.subtract(droppos, pos)
					local speed = 3
					item_entity:set_velocity(vector.multiply(drop_vel, speed))
				end
			else
				stack:take_item()
				inv:set_stack("main", stack_id, stack)
			end
		elseif core.get_item_group(dropitem:get_name(), "shears") == 0 then
			drop(pos, droppos, dropitem, inv, stack_)
		end
	end
	mcl_redstone.update_comparators(pos)
end

local function activate(pos, activate_func)
	local node = core.get_node(pos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local droppos, dropdir
	if node.name:match("_up$") then
		dropdir = vector.new(0, 1, 0)
		droppos = vector.offset(pos, 0, 1, 0)
	elseif node.name:match("_down$") then
		dropdir = vector.new(0, -1, 0)
		droppos = vector.offset(pos, 0, -1, 0)
	else
		dropdir = vector.multiply(core.facedir_to_dir(node.param2), -1)
		droppos = vector.add(pos, dropdir)
	end
	local stacks = {} -- Y
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not stack:is_empty() then
			table.insert(stacks, { stack = stack, stackpos = i })
		end
	end
	if #stacks >= 1 then
		local r = math.random(1, #stacks)
		local stack = stacks[r]
		activate_func(pos, droppos, dropdir, inv, stack)
	end
end

local commdef  = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {
		pickaxey = 1, container = 2, material_stone = 1,
		jigsaw_construct = 1, jigsaw_preserve_meta = 1
	},
	after_dig_node = mcl_util.drop_items_from_meta_container({"main"}),
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
		core.log("action", player:get_player_name() ..
			" moves stuff in dispenser at " .. core.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, _, stack, player)
		core.log("action", player:get_player_name() ..
			" moves stuff to dispenser at " .. core.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	on_metadata_inventory_take = function(pos, _, _, _, player)
		core.log("action", player:get_player_name() ..
			" takes stuff from dispenser at " .. core.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	on_rotate = screwdriver.rotate_simple,
	_mcl_hardness = 3.5,
	_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		update = function(pos, node)
			local oldpowered = math.floor(node.param2 / 32) ~= 0
			local powered = mcl_redstone.get_power(pos) ~= 0
			if powered and not oldpowered then
				local is_dispenser = core.get_item_group(node.name, "dispenser") ~= 0
				activate(pos, is_dispenser and activate_dispenser or activate_dropper)
			end
			return {
				name = node.name,
				param2 = node.param2 % 32 + (powered and 32 or 0),
			}
		end,
	},
}

-- Register dispensers
do
	local dispenserdef = table.merge(commdef, {
		groups = table.merge(commdef.groups, {dispenser = 1})
	})

	core.register_node("mcl_dispensers:dispenser", table.merge(dispenserdef, {
		description = S("Dispenser"),
		_tt_help = S("9 inventory slots") .. "\n" .. S("Launches item when powered by redstone power"),
		_doc_items_longdesc = S("A dispenser is a block which acts as a redstone component which, when powered with redstone power, dispenses an item. It has a container with 9 inventory slots."),
		_doc_items_usagehelp = S("Place the dispenser in one of 6 possible directions. The “hole” is where items will fly out of the dispenser. Use the dispenser to access its inventory. Insert the items you wish to dispense. Supply the dispenser with redstone energy once to dispense a random item.")
			.. "\n\n" ..

			S("The dispenser will do different things, depending on the dispensed item:") .. "\n\n" ..

			S("• Arrows: Are launched") .. "\n" ..
			S("• Eggs and snowballs: Are thrown") .. "\n" ..
			S("• Fire charges: Are fired in a straight line") .. "\n" ..
			S("• Armor: Will be equipped to players and armor stands") .. "\n" ..
			S("• Boats: Are placed on water or are dropped") .. "\n" ..
			S("• Minecart: Are placed on rails or are dropped") .. "\n" ..
			S("• Bone meal: Is applied on the block it is facing") .. "\n" ..
			S("• Empty buckets: Are used to collect a liquid source") .. "\n" ..
			S("• Filled buckets: Are used to place a liquid source") .. "\n" ..
			S("• Heads, pumpkins: Equipped to players and armor stands, or placed as a block") .. "\n" ..
			S("• Shulker boxes: Are placed as a block") .. "\n" ..
			S("• TNT: Is placed and ignited") .. "\n" ..
			S("• Flint and steel: Is used to ignite a fire in air and to ignite TNT") .. "\n" ..
			S("• Spawn eggs: Will summon the mob they contain") .. "\n" ..
			S("• Other items: Are simply dropped"),
		tiles = {
			"default_furnace_top.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "mcl_dispensers_dispenser_front_horizontal.png"
		},
		paramtype2 = "facedir",
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			setup_dispenser(pos)
			orientate(pos, placer, "dispenser")
		end,
		on_construct = function (pos)
			setup_dispenser(pos)
		end
	}))

	core.register_node("mcl_dispensers:dispenser_down", table.merge(dispenserdef, {
		description = S("Dispenser"),
		after_place_node = setup_dispenser,
		on_construct = function (pos)
			setup_dispenser(pos)
		end,
		tiles = {
			"default_furnace_top.png", "mcl_dispensers_dispenser_front_vertical.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_side.png"
		},
		groups = table.merge(dispenserdef.groups, { not_in_creative_inventory = 1, }),
		_doc_items_create_entry = false,
		drop = "mcl_dispensers:dispenser",
	}))
	core.register_node("mcl_dispensers:dispenser_up", table.merge(dispenserdef, {
		description = S("Dispenser"),
		after_place_node = setup_dispenser,
		on_construct = function (pos)
			setup_dispenser(pos)
		end,
		tiles = {
			"mcl_dispensers_dispenser_front_vertical.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_side.png"
		},
		groups = table.merge(dispenserdef.groups, { not_in_creative_inventory = 1, }),
		_doc_items_create_entry = false,
		drop = "mcl_dispensers:dispenser",
	}))

	core.register_craft({
		output = "mcl_dispensers:dispenser",
		recipe = {
			{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble", },
			{ "mcl_core:cobble", "mcl_bows:bow", "mcl_core:cobble", },
			{ "mcl_core:cobble", "mcl_redstone:redstone", "mcl_core:cobble", },
		}
	})

	doc.add_entry_alias("nodes", "mcl_dispensers:dispenser", "nodes", "mcl_dispensers:dispenser_down")
	doc.add_entry_alias("nodes", "mcl_dispensers:dispenser", "nodes", "mcl_dispensers:dispenser_up")
end

-- Register droppers
do
	local dropperdef = table.merge(commdef, {
		groups = table.merge(commdef.groups, {dropper = 1})
	})

	core.register_node("mcl_dispensers:dropper", table.merge(dropperdef, {
		description = S("Dropper"),
		_tt_help = S("9 inventory slots") .. "\n" .. S("Drops item when powered by redstone power"),
		_doc_items_longdesc = S("A dropper is a redstone component and a container with 9 inventory slots which, when supplied with redstone power, drops an item or puts it into a container in front of it."),
		_doc_items_usagehelp = S("Droppers can be placed in 6 possible directions, items will be dropped out of the hole. Use the dropper to access its inventory. Supply it with redstone energy once to make the dropper drop or transfer a random item."),
		tiles = {
			"default_furnace_top.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "mcl_droppers_dropper_front_horizontal.png"
		},
		paramtype2 = "facedir",
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			setup_dispenser(pos)
			orientate(pos, placer, "dropper")
		end,
	}))

	core.register_node("mcl_dispensers:dropper_down", table.merge(dropperdef, {
		description = S("Dropper"),
		after_place_node = setup_dispenser,
		tiles = {
			"default_furnace_top.png", "mcl_droppers_dropper_front_vertical.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_side.png"
		},
		groups = table.merge(dropperdef.groups, { not_in_creative_inventory = 1, }),
		_doc_items_create_entry = false,
		drop = "mcl_dispensers:dropper",
	}))
	core.register_node("mcl_dispensers:dropper_up", table.merge(dropperdef, {
		description = S("Dropper"),
		after_place_node = setup_dispenser,
		tiles = {
			"mcl_droppers_dropper_front_vertical.png", "default_furnace_bottom.png",
			"default_furnace_side.png", "default_furnace_side.png",
			"default_furnace_side.png", "default_furnace_side.png"
		},
		groups = table.merge(dropperdef.groups, { not_in_creative_inventory = 1, }),
		_doc_items_create_entry = false,
		drop = "mcl_dispensers:dropper",
	}))

	core.register_craft({
		output = "mcl_dispensers:dropper",
		recipe = {
			{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble", },
			{ "mcl_core:cobble", "", "mcl_core:cobble", },
			{ "mcl_core:cobble", "mcl_redstone:redstone", "mcl_core:cobble", },
		}
	})

	doc.add_entry_alias("nodes", "mcl_droppers:dropper", "nodes", "mcl_droppers:dropper_down")
	doc.add_entry_alias("nodes", "mcl_droppers:dropper", "nodes", "mcl_droppers:dropper_up")
end
