mcl_loot = {}

--[[
Select a number of itemstacks out of a pool of treasure definitions randomly.

Parameters:
* loot_definitions: Probabilities and information about the loot to select. Syntax:

{
	stacks_min = 1,	-- Minimum number of item stacks to get. Default: 1
	stacks_max = 3, -- Maximum number of item stacks to get. Default: 1
	items = { -- Table of possible loot items. This function selects between stacks_min and stacks_max of these.
		{
		weight = 5,		-- Likelihood of this item being selected (see below). Optional (default: 1)

		itemstack = ItemStack("example:item1"), -- Itemstack to select
		-- OR
		itemstring = "example:item1", -- Which item to select
		amount_min = 1,		-- Minimum size of itemstack. Must not be larger than 6553. Optional (default: 1)
		amount_max = 10,	-- Maximum size of item stack. Must not be larger than item definition's stack_max or 6553. Optional (default: 1)
		wear_min = 1,		-- Minimum wear value. Must be at least 1. Optional (default: no wear)
		wear_max = 1,		-- Maxiumum wear value. Must be at least 1. Optional (default: no wear)
		-- OR
		nothing = true,		-- simulate a failure roll with the given weight

		-- optional
		func = function(stack, pr) end	-- modify stack, e.g. enchant item
		},
		{ -- more tables like above, one table per item stack }
	}
}
* pr: PcgRandom object used for the randomness

How weight works: The probability of a single item stack being selected is weight/total_weight, with
total_weight being the sum of all weight values in the items table. If you leave out the weight for
all items, the likelihood of each item being selected is equal.

Returns: Table of ItemStacks
]]
function mcl_loot.get_loot(loot_definitions, pr)
	local items = {}

	local total_weight = 0
	for i=1, #loot_definitions.items do
		total_weight = total_weight + (loot_definitions.items[i].weight or 1)
	end

	--local stacks_min = loot_definitions.stacks_min or 1
	--local stacks_max = loot_definitions.stacks_max or 1

	local stacks = pr:next(loot_definitions.stacks_min, loot_definitions.stacks_max)
	for _ = 1, stacks do
		local r = pr:next(1, total_weight)

		local accumulated_weight = 0
		local item
		for i=1, #loot_definitions.items do
			accumulated_weight = accumulated_weight + (loot_definitions.items[i].weight or 1)
			if accumulated_weight >= r then
				item = loot_definitions.items[i]
				break
			end
		end
		if item then
			local itemstring = item.itemstring

			if itemstring then
				local stack = ItemStack(itemstring)

				if item.amount_min and item.amount_max then
					stack:set_count(pr:next(item.amount_min, item.amount_max))
				end

				if item.wear_min and item.wear_max then
					-- Sadly, PcgRandom only allows very narrow ranges, so we set wear in steps of 10
					local wear_min = math.floor(item.wear_min / 10)
					local wear_max = math.floor(item.wear_max / 10)

					stack:set_wear(pr:next(wear_min, wear_max) * 10)
				end

				if item.func then
					item.func(stack, pr)
				end

				table.insert(items, stack)
			elseif not item.nothing then
				core.log("error", "[mcl_loot] INTERNAL ERROR! Failed to select random loot item!")
			end
		end
	end

	return items
end

--[[
Repeat mcl_loot.get_loot multiple times for various loot_definitions.
Useful for filling chests.

* multi_loot_definitions: Table of loot_definitions (see mcl_loot.get_loot)
* pr: PcgRandom object used for the randomness

Returns: Table of ItemStacks ]]
function mcl_loot.get_multi_loot(multi_loot_definitions, pr)
	local items = {}
	for m=1, #multi_loot_definitions do
		local group = mcl_loot.get_loot(multi_loot_definitions[m], pr)
		for g=1, #group do
			table.insert(items, group[g])
		end
	end
	return items
end

--[[
Returns a table of length `max_slot` and all natural numbers between 1 and `max_slot`
in a random order.
]]
local function get_random_slots(max_slot, pr)
	local slots = {}
	for s=1, max_slot do
		slots[s] = s
	end
	local slots_out = {}
	while #slots > 0 do
		local r = pr and pr:next(1, #slots) or math.random(1, #slots)
		table.insert(slots_out, slots[r])
		table.remove(slots, r)
	end
	return slots_out
end

--[[
Puts items in an inventory list into random slots.
* inv: InvRef
* listname: Inventory list name
* items: table of items to add

Items will be added from start of the table to end.
If the inventory already has occupied slots, or is
too small, placement of some items might fail.
]]
function mcl_loot.fill_inventory(inv, listname, items, pr)
	local size = inv:get_size(listname)
	local slots = get_random_slots(size, pr)
	local leftovers = {}
	-- 1st pass: Add items into random slots
	for i=1, math.min(#items, size) do
		local item = items[i]
		local slot = slots[i]
		local old_item = inv:get_stack(listname, slot)
		local leftover = old_item:add_item(item)
		inv:set_stack(listname, slot, old_item)
		if not leftover:is_empty() then
			table.insert(leftovers, item)
		end
	end
	-- 2nd pass: If some items couldn't be added in first pass,
	-- try again in a non-random fashion
	for l=1, math.min(#leftovers, size) do
		inv:add_item(listname, leftovers[l])
	end
	-- If there are still items left, tough luck!
end
