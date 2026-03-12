local S = core.get_translator(core.get_current_modname())
mcl_composters = {}

--
-- Composter mod, adds composters.
--
-- Copyleft 2022 by kabou
-- GNU General Public Licence 3.0
--

local composter_description = S(
	"Composter"
)
local composter_longdesc = S(
	"Composters can convert various organic items into bonemeal."
)
local composter_usagehelp = S(
	"Use organic items on the composter to fill it with layers of compost. " ..
	"Every time an item is put in the composter, there is a chance that the " ..
	"composter adds another layer of compost.  Some items have a bigger chance " ..
	"of adding an extra layer than other items.  After filling up with 7 layers " ..
	"of compost, the composter is full.  After a delay of approximately one " ..
	"second the composter becomes ready and bone meal can be retrieved from it. " ..
	"Right-clicking the composter takes out the bone meal empties the composter."
)

core.register_craft({
	output = "mcl_composters:composter",
	recipe = {
		{"group:wood_slab", "", "group:wood_slab"},
		{"group:wood_slab", "", "group:wood_slab"},
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
	}
})

local function get_composter_level(pos, node)
	node = node or core.get_node(pos)
	local def = core.registered_nodes[node.name]
	return def and def._mcl_compost_level
end

-- Create bonemeal and reset composter to empty.
local function create_bonemeal(pos, node, no_drop, no_validate)
	-- Suppress validation for farmer villager convenience.
	if not no_validate and get_composter_level(pos, node) ~= 8 then
		return false
	end
	-- reset composter to empty
	mcl_redstone.swap_node(pos, {name="mcl_composters:composter"})
	local stack = ItemStack("mcl_bone_meal:bone_meal")
	if not no_drop then
		core.add_item(pos, stack)
	end
	return stack
end

-- Try to compost one item. Returns true if item is compostable.
local function compost_item(pos, node, itemstack, auto_cycle)
	local level = get_composter_level(pos, node)
	if not level then return end

	-- When filled by a player a full composter becomes ready for harvest
	-- after one second. The block will get updated by the node timer
	-- callback and no further items can be added until the composter is
	-- emptied. To simplify usage by farmer villagers the composter will
	-- empty automatically when trying to add an item to a full composter.
	if level >= 7 and auto_cycle then
		core.get_node_timer(pos):stop()
		create_bonemeal(pos, node, false, true)
		level = 0
	end

	if level < 7 then
		local chance = core.get_item_group (itemstack:get_name(), "compostability")
		if chance >= math.random(1, 100) then
			-- spawn green particles above new layer
			mcl_bone_meal.add_bone_meal_particle(vector.offset(pos, 0, level/8, 0))
			level = level + 1
			mcl_redstone.swap_node(pos, {name = "mcl_composters:composter_" .. level})
			core.sound_play({name="default_grass_footstep", gain=0.4}, {
				pos = pos,
				gain= 0.4,
				max_hear_distance = 16,
			}, true)
			if level == 7 then
				core.get_node_timer(pos):start(1)
			end
		end
		return chance > 0
	end
end

-- Entry point for farmer villagers.
function mcl_composters.farmer_add_compost (pos, node, itemstack)
	-- make sure pos has the vector metatable
	return compost_item(vector.copy(pos), node, itemstack, true)
end

--- Fill the composter when rightclicked.
--
-- `on_rightclick` handler for composter blocks of all fill levels except
-- for the "ready" composter (see: composter_harvest).
-- If the item used on the composter block is compostable, there is a chance
-- that the level of the composter may increase, depending on the value of
-- compostability of the item.
--
-- parameters are the standard parameters passed to `on_rightclick`.
-- returns the remaining itemstack.
--
local function composter_add_item(pos, node, player, itemstack, _)
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return itemstack
	end
	if not itemstack or itemstack:is_empty() then
		return itemstack
	end
	if compost_item(pos, node, itemstack) and not core.is_creative_enabled(name) then
		itemstack:take_item()
		core.sound_play({name="default_gravel_dug", gain=1}, {
				pos = pos,
				max_hear_distance = 16,
		}, true)
	end
	return itemstack
end

--- Update a full composter block to ready for harvesting.
--
-- `on_timer` handler. The timer is set in function 'composter_add_item'
-- when the composter level has reached 7.
--
-- pos: position of the composter block.
-- returns false, thereby cancelling further activity of the timer.
--
local function composter_ready(pos, _)
	-- verify that full composter is still there
	if get_composter_level(pos) ~= 7 then return false end
	mcl_redstone.swap_node(pos, {name = "mcl_composters:composter_ready"})
	-- maybe spawn particles again?
	core.sound_play({name="default_dig_snappy", gain=1}, {
		pos = pos,
		max_hear_distance = 16,
	}, true)
	return false
end

--- Spawn bone meal item and reset composter block.
--
-- `on_rightclick` handler for the "ready" composter block.  Causes a
-- bone meal item to be spawned from the composter and resets the
-- composter block to an empty composter block.
--
-- parameterss are the standard parameters passed to `on_rightclick`.
-- returns itemstack (unchanged in this function).
--
local function composter_harvest(pos, node, player, itemstack, _)
	if not player or (player:get_player_control() and player:get_player_control().sneak) then
		return itemstack
	end
	local name = player:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return itemstack
	end
	create_bonemeal(pos, node)
	return itemstack
end

--- Construct composter nodeboxes with varying levels of compost.
--
-- level: compost level in the composter
-- returns a nodebox definition table.
--
local function composter_get_nodeboxes(level)
	local top_y_tbl = {[0]=-7, -5, -3, -1, 1, 3, 5, 7}
	local top_y = top_y_tbl[level] / 16
	return {
		type = "fixed",
		fixed = {
			{-0.5,   -0.5, -0.5,  -0.375, 0.5,   0.5},   -- Left wall
			{ 0.375, -0.5, -0.5,   0.5,   0.5,   0.5},   -- Right wall
			{-0.375, -0.5,  0.375, 0.375, 0.5,   0.5},   -- Back wall
			{-0.375, -0.5, -0.5,   0.375, 0.5,  -0.375}, -- Front wall
			{-0.5,   -0.5, -0.5,   0.5,   top_y, 0.5},   -- Bottom level
		}
	}
end

local function on_hopper_out(uppos, pos)
	-- Get bonemeal from composter above
	local stack = create_bonemeal(uppos, nil, true)
	if stack then
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:add_item("main", "mcl_bone_meal:bone_meal")
	end
end

local function on_hopper_in(pos, downpos)
	local downnode = core.get_node(downpos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()

	for i = 1, 5 do
		local stack = inv:get_stack("main", i)
		if compost_item(downpos, downnode, stack) then
			stack:take_item()
			inv:set_stack("main", i, stack)
			break
		end
	end
end


--- Register empty composter node.
--
-- This is the craftable base model that can be placed in an inventory.
--
core.register_node("mcl_composters:composter", {
	description = composter_description,
	_tt_help = S("Converts organic items into bonemeal"),
	_doc_items_longdesc = composter_longdesc,
	_doc_items_usagehelp = composter_usagehelp,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = composter_get_nodeboxes(0),
	selection_box = {type = "regular"},
	tiles = {
		"mcl_composter_bottom.png^mcl_composter_top.png",
		"mcl_composter_bottom.png",
		"mcl_composter_side.png"
	},
	is_ground_content = false,
	groups = {
		handy=1, material_wood=1, deco_block=1, dirtifier=1,
		flammable=2, fire_encouragement=3, fire_flammability=4,
		comparator_signal=0, container = 1, composter = 1,
		pathfinder_partial = 2,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 0.6,
	_mcl_compost_level = 0,
	_mcl_burntime = 15,
	on_rightclick = composter_add_item,
	_on_hopper_in = on_hopper_in,
})

--- Template function for composters with compost.
--
-- For each fill level a custom node is registered.
--
local function register_filled_composter(level)
	local id = "mcl_composters:composter_"..level
	core.register_node(id, {
		description = S("Composter") .. " (" .. level .. "/7 " .. S("filled") .. ")",
		_doc_items_create_entry = false,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = composter_get_nodeboxes(level),
		selection_box = {type = "regular"},
		tiles = {
			"mcl_composter_compost.png^mcl_composter_top.png",
			"mcl_composter_bottom.png",
			"mcl_composter_side.png"
		},
		is_ground_content = false,
		groups = {
			handy=1, material_wood=1, deco_block=1, dirtifier=1,
			not_in_creative_inventory=1, not_in_craft_guide=1,
			flammable=2, fire_encouragement=3, fire_flammability=4,
			comparator_signal=level, container = 1, composter = 1,
			pathfinder_partial = 2,
		},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		drop = "mcl_composters:composter",
		_mcl_hardness = 0.6,
		_mcl_compost_level = level,
		on_rightclick = composter_add_item,
		on_timer = composter_ready,
		_on_hopper_in = level < 7 and on_hopper_in or nil,
		_mcl_baseitem = "mcl_composters:composter",
	})

	doc.add_entry_alias("nodes", "mcl_composters:composter", "nodes", id)
end

--- Register filled composters (7 levels).
--
for level = 1, 7 do
	register_filled_composter(level)
end

core.register_lbm({
	name = "mcl_composters:start_composter_7",
	nodenames = {
		"mcl_composters:composter_7",
	},
	run_at_every_load = true,
	action = function(pos)
		core.get_node_timer(pos):start(1)
	end,
})

--- Register composter that is ready to be harvested.
--
core.register_node("mcl_composters:composter_ready", {
	description = S("Composter") .. "(" .. S("ready for harvest") .. ")",
	_doc_items_create_entry = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = composter_get_nodeboxes(7),
	selection_box = {type = "regular"},
	tiles = {
		"mcl_composter_ready.png^mcl_composter_top.png",
		"mcl_composter_bottom.png",
		"mcl_composter_side.png"
	},
	is_ground_content = false,
	groups = {
		handy=1, material_wood=1, deco_block=1, dirtifier=1,
		not_in_creative_inventory=1, not_in_craft_guide=1,
		flammable=2, fire_encouragement=3, fire_flammability=4,
		comparator_signal=8, container = 1, composter = 1,
		pathfinder_partial = 2,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_composters:composter",
	_mcl_hardness = 0.6,
	_mcl_compost_level = 8,
	on_rightclick = composter_harvest,
	_on_hopper_out = on_hopper_out,
	_mcl_baseitem = "mcl_composters:composter",
})

doc.add_entry_alias("nodes", "mcl_composters:composter", "nodes", "mcl_composters:composter_ready" )
