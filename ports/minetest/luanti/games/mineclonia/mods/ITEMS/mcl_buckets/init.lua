local modname = core.get_current_modname()
local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

core.register_craft({
	output = "mcl_buckets:bucket_empty 1",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"", "mcl_core:iron_ingot", ""},
	},
})


mcl_buckets = {
	liquids = {},
	buckets = {},
}

-- Sound helper functions for placing and taking liquids
local function sound_place(itemname, pos)
	local def = core.registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		core.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function sound_take(itemname, pos)
	local def = core.registered_nodes[itemname]
	if def and def.sounds and def.sounds.dug then
		core.sound_play(def.sounds.dug, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function place_liquid(pos, itemstring)
	local fullness = core.registered_nodes[itemstring].liquid_range
	sound_place(itemstring, pos)
	core.set_node(pos, {name=itemstring, param2=fullness})
end

local function give_bucket(new_bucket, itemstack, user)
	local inv = user:get_inventory()
	if core.is_creative_enabled(user:get_player_name()) then
		--TODO: is a full bucket added if inv doesn't contain one?
		return itemstack
	else
		if itemstack:get_count() == 1 then
			return new_bucket
		else
			if inv:room_for_item("main", new_bucket) then
				inv:add_item("main", new_bucket)
			else
				core.add_item(user:get_pos(), new_bucket)
			end
			itemstack:take_item()
			return itemstack
		end
	end
end

local pointable_sources = {}

local function get_node_place(source_place, place_pos)
	local node_place
	if type(source_place) == "function" then
		node_place = source_place(place_pos)
	else
		node_place = source_place
	end
	return node_place
end

local function get_extra_check(check, pos, user)
	local result
	local take_bucket
	if check then
		result, take_bucket = check(pos, user)
		if result == nil then result = true end
		if take_bucket == nil then take_bucket = true end
	else
		result = true
		take_bucket = true
	end
	return result, take_bucket
end

local function get_bucket_drop(itemstack, user, take_bucket)
	-- Handle bucket item and inventory stuff
	if take_bucket and not core.is_creative_enabled(user:get_player_name()) then
		-- Add empty bucket and put it into inventory, if possible.
		-- Drop empty bucket otherwise.
		local new_bucket = ItemStack("mcl_buckets:bucket_empty")
		if itemstack:get_count() == 1 then
			return new_bucket
		else
			local inv = user:get_inventory()
			if inv:room_for_item("main", new_bucket) then
				inv:add_item("main", new_bucket)
			else
				core.add_item(user:get_pos(), new_bucket)
			end
			itemstack:take_item()
			return itemstack
		end
	else
		return itemstack
	end
end

local function on_place_bucket(itemstack, user, pointed_thing)

	-- Must be pointing to node
	if not pointed_thing or pointed_thing.type ~= "node" then
		return
	end

	-- Call on_rightclick if the pointed node defines it
	local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if new_stack then
		return new_stack
	end

	local def = core.registered_nodes[core.get_node(pointed_thing.under).name]
	if def and def._on_bucket_place then
		return def._on_bucket_place(itemstack,user,pointed_thing)
	end

	local bucket_def = mcl_buckets.buckets[itemstack:get_name()]
	for _, pos in pairs({ pointed_thing.under, pointed_thing.above }) do
		local node = core.get_node(pos)
		local node_def = core.registered_nodes[node.name]

		if node_def and node_def.buildable_to then
			local result, take_bucket = get_extra_check(bucket_def.extra_check, pos, user)
			if result then
				local node_place = get_node_place(bucket_def.source_place, pos)
				local player_name = user:get_player_name()

				if core.is_protected(pos, player_name) then
					core.record_protection_violation(pos, player_name)
					return itemstack
				end

				place_liquid(pos, node_place)

				if doc.entry_exists("nodes", node_place) then
					doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_place)
				end
			end
			return get_bucket_drop(itemstack, user, take_bucket)
		end
	end
	return itemstack
end

local function on_place_bucket_empty(itemstack, user, pointed_thing)

	-- Must be pointing to node
	if not pointed_thing or pointed_thing.type ~= "node" then
		return itemstack
	end

	local new_bucket = false
	local under = pointed_thing.under
	local node_name = core.get_node(under).name
	local def = core.registered_nodes[node_name]
	if def and def._on_bucket_place_empty then
		return def._on_bucket_place_empty(itemstack,user,pointed_thing)
	end

	-- Call on_rightclick if the pointed node defines it
	local new_stack = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if new_stack then
		return new_stack
	end
	if pointable_sources[node_name] then
		if core.is_protected(under, user:get_player_name()) then
			core.record_protection_violation(under, user:get_player_name())
		end
		local liquid_def = mcl_buckets.liquids[node_name]
		if liquid_def then
			-- Fill bucket, but not in Creative Mode
			if not core.is_creative_enabled(user:get_player_name()) then
				new_bucket = ItemStack({name = liquid_def.bucketname})
				if liquid_def.on_take then
					liquid_def.on_take(user)
				end
			end
			core.set_node(under, {name="air"})
			sound_take(node_name, under)

			if doc.entry_exists("nodes", node_name) then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", node_name)
			end
			if new_bucket then
				return give_bucket(new_bucket, itemstack, user)
			end
		end
		return itemstack
	else
		if new_bucket then
			return give_bucket(new_bucket, itemstack, user)
		end
	end
	return itemstack
end

function mcl_buckets.register_liquid(def)
	for _,source in ipairs(def.source_take) do
		mcl_buckets.liquids[source] = {
			source_place = def.source_place,
			source_take = source,
			on_take = def.on_take,
			bucketname = def.bucketname,
		}
		pointable_sources[source] = true
		if type(def.source_place) == "string" then
			mcl_buckets.liquids[def.source_place] = mcl_buckets.liquids[source]
		end
	end

	mcl_buckets.buckets[def.bucketname] = def

	assert(def.bucketname and def.bucketname ~= "", string.format("[mcl_bucket] Invalid itemname then registering [%s]!", def.name))

	core.register_craftitem(def.bucketname, {
		description = def.name,
		_doc_items_longdesc = def.longdesc,
		_doc_items_usagehelp = def.usagehelp,
		_tt_help = def.tt_help,
		inventory_image = def.inventory_image,
		stack_max = 1,
		groups = def.groups,
		on_place = on_place_bucket,
		on_secondary_use = on_place_bucket,
		_placement_def = "placeable_on_any_thing",
		_on_dispense = function(stack, _, droppos, dropnode, _)
			local buildable = core.registered_nodes[dropnode.name].buildable_to or dropnode.name == "mcl_portals:portal"
			if not buildable then return stack end
			local result, take_bucket = get_extra_check(def.extra_check, droppos, nil)
			if result then -- Fail placement of liquid if result is false
				place_liquid(droppos, get_node_place(def.source_place, droppos))
			end
			if take_bucket then
				stack:set_name("mcl_buckets:bucket_empty")
			end
			return stack
		end,
		_mcl_burntime = def._mcl_burntime,
		_mcl_fuel_replacements = def._mcl_fuel_replacements,
		_mcl_buckets_liquid = def.id,
	})
end

core.register_craftitem("mcl_buckets:bucket_empty", {
	description = S("Empty Bucket"),
	_doc_items_longdesc = S("A bucket can be used to collect and release liquids."),
	_doc_items_usagehelp = S("Punch a liquid source to collect it. You can then use the filled bucket to place the liquid somewhere else."),
	_tt_help = S("Collects liquids"),
	inventory_image = "bucket.png",
	stack_max = 16,
	pointabilities = {
		nodes = {
			["group:liquid_source"] = true,
		},
	},

	on_place = on_place_bucket_empty,
	on_secondary_use = on_place_bucket_empty,
	_placement_def = "placeable_on_any_thing",
	_on_dispense = function(stack, _, droppos, dropnode, _)
		-- Fill empty bucket with liquid or drop bucket if no liquid
		local collect_liquid = false

		local liquiddef = mcl_buckets.liquids[dropnode.name]
		local new_bucket
		if liquiddef and liquiddef.bucketname and (dropnode.name  == liquiddef.source_take) then
			-- Fill bucket
			new_bucket = ItemStack({name = liquiddef.bucketname})
			sound_take(dropnode.name, droppos)
			collect_liquid = true
		end
		if collect_liquid then
			core.set_node(droppos, {name="air"})

			-- Fill bucket with liquid
			stack = new_bucket
		else
			-- No liquid found: Drop empty bucket
			core.add_item(droppos, stack)
			stack:take_item()
		end
		return stack
	end,
})

dofile(modpath.."/register.lua")
dofile(modpath.."/fishbuckets.lua")
