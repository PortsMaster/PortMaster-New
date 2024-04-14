-- Chorus plants
-- This includes chorus flowers, chorus plant stem nodes and chorus fruit

local S = minetest.get_translator(minetest.get_current_modname())

--- Plant parts ---

local MAX_FLOWER_AGE = 5 -- Maximum age of chorus flower before it dies

local chorus_flower_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.375, -0.375, 0.5, 0.375, 0.375},
		{-0.375, -0.375, 0.375, 0.375, 0.375, 0.5},
		{-0.375, -0.375, -0.5, 0.375, 0.375, -0.375},
		{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
		{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
	}
}

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- This is a list of nodes that SHOULD NOT call their detach function
local no_detach = {}

-- This detaches all chorus plants that are/were attached
-- at start_pos.
function mcl_end.detach_chorus_plant(start_pos, digger)
	-- This node should not call a detach function, do NOTHING
	local hash = minetest.hash_node_position(start_pos)
	if no_detach[hash] then
		return
	end

	-- This node SHOULD be detached, make sure no others are
	no_detach = {}

	local neighbors = {
		{ x=0, y=1, z=0 },
		{ x=0, y=0, z=1 },
		{ x=-1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=1, y=0, z=0 },
		{ x=0, y=-1, z=0 },
	}
	table.insert(neighbors, { x=0, y=-1, z=0 })
	local tree_start_posses = {}
	for i=1, #neighbors do
		table.insert(tree_start_posses, vector.add(start_pos, neighbors[i]))
	end

	-- From the start_pos, we look at the 6 possible directions. Each of these can
	-- have a full independent chorus plant ("tree") that might be detached.
	for t=1, #tree_start_posses do
		-- For each "tree", we do a depth-first search to traverse all
		-- chorus plant nodes.
		local touched_nodes_hashes = { minetest.hash_node_position(start_pos) }
		local check_posses = { tree_start_posses[t] }
		local chorus_nodes = {}
		local break_tree = true
		while #check_posses > 0 do
			local pos = check_posses[1]

			-- Don't just count neighbors as being touched, count THIS NODE as well
			-- This will prevent it from getting stuck in an endless loop
			if not touched_nodes_hashes[minetest.hash_node_position(pos)] then
				local node = minetest.get_node(pos)
				touched_nodes_hashes[minetest.hash_node_position(pos)] = true
				if node.name == "mcl_end:end_stone" then
					-- End stone found, the algorithm ends here (haha!)
					-- without destroying any nodes, because chorus plants
					-- attach to end stone.
					break_tree = false
					break
				elseif minetest.get_item_group(node.name, "chorus_plant") == 1 then
					table.insert(chorus_nodes, pos)
					for i=1, #neighbors do
						local newpos = vector.add(pos, neighbors[i])
						if not touched_nodes_hashes[minetest.hash_node_position(newpos)] then
							table.insert(check_posses, vector.add(pos, neighbors[i]))
						end
					end
				end
			end

			table.remove(check_posses, 1)
		end
		if break_tree then
			-- If we traversed the entire chorus plant and it was not attached to end stone:
			-- Drop ALL the chorus nodes we found.
			for c=1, #chorus_nodes do
				no_detach[ minetest.hash_node_position(chorus_nodes[c]) ] = true
				if digger then
					minetest.node_dig(chorus_nodes[c], { name = "mcl_end:chorus_plant" }, digger)
				else
					minetest.remove_node(chorus_nodes[c])
				end
			end
		end
	end

	no_detach = {}
end

function mcl_end.check_detach_chorus_plant(pos, oldnode, oldmetadata, digger)
	mcl_end.detach_chorus_plant(pos, digger)
end

function mcl_end.check_blast_chorus_plant(pos)
	minetest.remove_node(pos)
	mcl_end.detach_chorus_plant(pos)
end

minetest.register_node("mcl_end:chorus_flower", {
	description = S("Chorus Flower"),
	_tt_help = S("Grows on end stone"),
	_doc_items_longdesc = S("A chorus flower is the living part of a chorus plant. It can grow into a tall chorus plant, step by step. When it grows, it may die on old age eventually. It also dies when it is unable to grow."),
	_doc_items_usagehelp = S("Place it and wait for it to grow. It can only be placed on top of end stone, on top of a chorus plant stem, or at the side of exactly one chorus plant stem."),
	tiles = {
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = chorus_flower_box,
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,chorus_plant = 1},

	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local node_under = minetest.get_node(pointed_thing.under)

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		--[[ Part 1: Check placement rules. Placement is legal if one of the following
		conditions is met:
		1) On top of end stone or chorus plant
		2) On top of air and horizontally adjacent to exactly 1 chorus plant ]]
		local pos
		local def = minetest.registered_nodes[node_under.name]
		if def and def.buildable_to then
			pos = pointed_thing.under
		else
			pos = pointed_thing.above
		end


		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local node_below = minetest.get_node(below)
		local plant_ok = false
		-- Condition 1
		if node_below.name == "mcl_end:chorus_plant" or node_below.name == "mcl_end:end_stone" then
			plant_ok = true
		-- Condition 2
		elseif node_below.name == "air" then
			local around = {
				{ x= 1, y=0, z= 0 },
				{ x=-1, y=0, z= 0 },
				{ x= 0, y=0, z= 1 },
				{ x= 0, y=0, z=-1 },
			}
			local around_count = 0
			for a=1, #around do
				local pos_side = vector.add(pos, around[a])
				local node_side = minetest.get_node(pos_side)
				if node_side.name == "mcl_end:chorus_plant" then
					around_count = around_count + 1
					if around_count > 1 then
						break
					end
				end
			end
			if around_count == 1 then
				plant_ok = true
			end
		end
		if plant_ok then
			-- Placement OK! Proceed normally
			local it, suc = minetest.item_place_node(itemstack, placer, pointed_thing)
			if suc then
				minetest.sound_play(mcl_sounds.node_sound_wood_defaults().place, {pos = pos}, true)
			end
			return it
		else
			return itemstack
		end
	end,
	after_dig_node = mcl_end.check_detach_chorus_plant,
	on_blast = mcl_end.check_blast_chorus_plant,
	_mcl_blast_resistance = 0.4,
	_mcl_hardness = 0.4,
})

minetest.register_node("mcl_end:chorus_flower_dead", {
	description = S("Dead Chorus Flower"),
	_doc_items_longdesc = S("This is a part of a chorus plant. It doesn't grow. Chorus flowers die of old age or when they are unable to grow. A dead chorus flower can be harvested to obtain a fresh chorus flower which is able to grow again."),
	tiles = {
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = chorus_flower_box,
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_end:chorus_flower",
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,chorus_plant = 1, not_in_creative_inventory=1},
	after_dig_node = mcl_end.check_detach_chorus_plant,
	on_blast = mcl_end.check_blast_chorus_plant,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

minetest.register_node("mcl_end:chorus_plant", {
	description = S("Chorus Plant Stem"),
	_doc_items_longdesc = S("A chorus plant stem is the part of a chorus plant which holds the whole plant together. It needs end stone as its soil. Stems are grown from chorus flowers."),
	_doc_items_usagehelp = S("The stem attaches itself to end stone and other chorus blocks."),
	tiles = {
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "connected",
		fixed = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 }, -- Core
		connect_top = { -0.1875, 0.25, -0.1875, 0.1875, 0.5, 0.1875 },
		connect_left = { -0.5, -0.1875, -0.1875, -0.25, 0.1875, 0.1875 },
		connect_right = { 0.25, -0.1875, -0.1875, 0.5, 0.1875, 0.1875 },
		connect_bottom = { -0.1875, -0.5, -0.25, 0.1875, -0.25, 0.25 },
		connect_front = { -0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.25 },
		connect_back = { -0.1875, -0.1875, 0.25, 0.1875, 0.1875, 0.5 },
	},
	connect_sides = { "top", "bottom", "front", "back", "left", "right" },
	connects_to = {"group:chorus_plant", "mcl_end:end_stone"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = {
		items = {
			{ items = { "mcl_end:chorus_fruit"}, rarity = 2 },
		}
	},
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1, chorus_plant = 1 },

	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local node_under = minetest.get_node(pointed_thing.under)
		local node_above = minetest.get_node(pointed_thing.above)

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		--[[ Part 1: Check placement rules. Placement is legal if this
		condition is met:
		- placed on end stone or any chorus node ]]
		local pos_place, node_check
		local def = minetest.registered_nodes[node_under.name]
		if def and def.buildable_to then
			pos_place = pointed_thing.under
			node_check = node_above
		else
			pos_place = pointed_thing.above
			node_check = node_under
		end
		local plant_ok = false
		if node_check.name == "mcl_end:end_stone" or minetest.get_item_group(node_check.name, "chorus_plant") > 0 then
			plant_ok = true
		end
		if plant_ok then
			-- Placement OK! Proceed normally
			local it, suc = minetest.item_place_node(itemstack, placer, pointed_thing)
			if suc then
				minetest.sound_play(mcl_sounds.node_sound_wood_defaults().place, {pos = pos_place}, true)
			end
			return it
		else
			return itemstack
		end
	end,
	after_dig_node = mcl_end.check_detach_chorus_plant,
	on_blast = mcl_end.check_blast_chorus_plant,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

-- Grow a complete chorus plant at pos
function mcl_end.grow_chorus_plant(pos, node, pr)
	local flowers = { pos }
	-- Plant initial flower (if it isn't there already)
	if not node then
		node = minetest.get_node(pos)
	end
	if node.name ~= "mcl_end:chorus_flower" then
		minetest.set_node(pos, { name = "mcl_end:chorus_flower" })
	end
	while true do
		local new_flowers_list = {}
		for f=1, #flowers do
			local new_flowers = mcl_end.grow_chorus_plant_step(flowers[f], minetest.get_node(flowers[f]), pr)
			if #new_flowers > 0 then
				table.insert(new_flowers_list, new_flowers)
			end
		end
		if #new_flowers_list == 0 then
			return
		end
		flowers = {}
		for l=1, #new_flowers_list do
			for f=1, #new_flowers_list[l] do
				table.insert(flowers, new_flowers_list[l][f])
			end
		end
	end
end

-- Grow a single step of a chorus plant at pos.
-- Pos must be a chorus flower.
function mcl_end.grow_chorus_plant_step(pos, node, pr)
	local new_flower_buds = {}
	local above = { x = pos.x, y = pos.y + 1, z = pos.z }
	local node_above = minetest.get_node(above)
	local around = {
		{ x=-1, y=0, z= 0 },
		{ x= 1, y=0, z= 0 },
		{ x= 0, y=0, z=-1 },
		{ x= 0, y=0, z= 1 },
	}
	local air_around = true
	for a=1, #around do
		if minetest.get_node(vector.add(above, around[a])).name ~= "air" then
			air_around = false
			break
		end
	end
	local grown = false
	if node_above.name == "air" and air_around then
		local branching = false
		local h = 0
		for y=1, 4 do
			local checkpos = {x=pos.x, y=pos.y-y, z=pos.z}
			local node = minetest.get_node(checkpos)
			if node.name == "mcl_end:chorus_plant" then
				h = y
				if not branching then
					for a=1, #around do
						local node_side = minetest.get_node(vector.add(checkpos, around[a]))
						if node_side.name == "mcl_end:chorus_plant" then
							branching = true
						end
					end
				end
			else
				break
			end
		end

		local grow_chance
		if h <= 1 then
			grow_chance = 100
		elseif h == 2 and branching == false then
			grow_chance = 60
		elseif h == 2 and branching == true then
			grow_chance = 50
		elseif h == 3 and branching == false then
			grow_chance = 40
		elseif h == 3 and branching == true then
			grow_chance = 25
		elseif h == 4 and branching == false then
			grow_chance = 20
		end

		if grow_chance then
			local new_flowers = {}
			local r = pr:next(1, 100)
			local age = node.param2
			if r <= grow_chance then
				table.insert(new_flowers, above)
			else
				age = age + 1
				local branches
				if branching == false then
					branches = pr:next(1, 4)
				elseif branching == true then
					branches = pr:next(0, 3)
				end
				for b=1, branches do
					local next_branch = pr:next(1, #around)
					local branch = vector.add(pos, around[next_branch])
					local below_branch = vector.add(branch, {x=0,y=-1,z=0})
					if minetest.get_node(below_branch).name == "air" then
						table.insert(new_flowers, branch)
					end
				end
			end

			for _, f in pairs(new_flowers) do
				if age >= MAX_FLOWER_AGE then
					local nn = minetest.get_node(f).name
					if nn ~= "mcl_end:chorus_flower" and nn ~= "mcl_end:chorus_flower_dead" then
						minetest.set_node(f, {name="mcl_end:chorus_flower_dead"})
						grown = true
					end
				else
					local nn = minetest.get_node(f).name
					if nn ~= "mcl_end:chorus_flower" and nn ~= "mcl_end:chorus_flower_dead" then
						minetest.set_node(f, {name="mcl_end:chorus_flower", param2 = age})
						table.insert(new_flower_buds, f)
						grown = true
					end
				end
			end
			if #new_flowers >= 1 then
				minetest.set_node(pos, {name="mcl_end:chorus_plant"})
				grown = true
			end
		end
	end
	if not grown then
		-- FIXME: In the End, chorus plant fails to generate thru mapchunk borders.
		-- So the chorus plants are capped at a fixed height.
		-- The mapgen needs to be taught somehow how to deal with this.
		minetest.set_node(pos, {name = "mcl_end:chorus_flower_dead"})
	end
	return new_flower_buds
end

--- ABM ---
local seed = minetest.get_mapgen_setting("seed")
local pr = PseudoRandom(seed)
minetest.register_abm({
	label = "Chorus plant growth",
	nodenames = { "mcl_end:chorus_flower" },
	interval = 35.0,
	chance = 4.0,
	action = function(pos, node, active_object_count, active_object_count_wider)
		mcl_end.grow_chorus_plant_step(pos, node, pr)
	end,
})

--- Chorus fruit ---

-- Attempt to randomly teleport the player within a 8×8×8 box around. Rules:
-- * Not in solid blocks.
-- * Not in liquids.
-- * Always on top of a solid block
-- * Maximum attempts: 16
--
-- Returns true on success.
local function random_teleport(player)
	local pos = player:get_pos()
	-- 16 attempts to find a suitable position
	for a=1, 16 do
		-- Teleportation box
		local x,y,z
		x = math.random(round(pos.x)-8, round(pos.x)+8)
		y = math.random(math.ceil(pos.y)-8, math.ceil(pos.y)+8)
		z = math.random(round(pos.z)-8, round(pos.z)+8)
		local node_cache = {}
		local ground_level = false
		-- Scan nodes from selected position until we hit ground
		for t=0, 16 do
			local tpos = {x=x, y=y-t, z=z}
			local tnode = minetest.get_node(tpos)
			if tnode.name == "mcl_core:void" or tnode.name == "ignore" then
				break
			end
			local tdef = minetest.registered_nodes[tnode.name]
			table.insert(node_cache, {pos=tpos, node=tnode})
			if tdef.walkable then
				ground_level = true
				break
			end
		end
		-- Ground found? Then let's check if the player has enough room
		if ground_level and #node_cache >= 1 then
			local streak = 0
			local last_was_walkable = true
			for c=#node_cache, 1, -1 do
				local tpos = node_cache[c].pos
				local tnode = node_cache[c].node
				local tdef = minetest.registered_nodes[tnode.name]
				-- Player needs a space of 2 safe non-liquid nodes on top of a walkable node
				if not tdef.walkable and tdef.liquidtype == "none" and tdef.damage_per_second <= 0 then
					if (streak == 0 and last_was_walkable) or (streak > 0) then
						streak = streak + 1
					end
				else
					streak = 0
				end
				last_was_walkable = tdef.walkable
				if streak >= 2 then
					-- JACKPOT! Now we can teleport.
					local goal = {x=tpos.x, y=tpos.y-1.5, z=tpos.z}
					player:set_pos(goal)
					minetest.sound_play({name="mcl_end_teleport", gain=0.8}, {pos=goal, max_hear_distance=16}, true)
					return true
				end
			end
		end
	end
	return false
end

-- Randomly teleport player and update hunger
local eat_chorus_fruit = function(itemstack, player, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	if rc then return rc end

	local count = itemstack:get_count()
	local new_itemstack = minetest.do_item_eat(4, nil, itemstack, player, pointed_thing)
	local new_count = new_itemstack:get_count()
	if count ~= new_count or new_itemstack:get_name() ~= "mcl_end:chorus_fruit" or (minetest.is_creative_enabled(player:get_player_name()) == true) then
		random_teleport(player)
	end
	return new_itemstack
end

minetest.register_craftitem("mcl_end:chorus_fruit", {
	description = S("Chorus Fruit"),
	_tt_help = S("Randomly teleports you when eaten"),
	_doc_items_longdesc = S("A chorus fruit is an edible fruit from the chorus plant which is home to the End. Eating it teleports you to the top of a random solid block nearby, provided you won't end up inside a liquid, solid or harmful blocks. Teleportation might fail if there are very few or no places to teleport to."),
	wield_image = "mcl_end_chorus_fruit.png",
	inventory_image = "mcl_end_chorus_fruit.png",
	on_place = eat_chorus_fruit,
	on_secondary_use = eat_chorus_fruit,
	groups = { food = 2, transport = 1, eatable = 4, can_eat_when_full = 1 },
	_mcl_saturation = 2.4,
})

minetest.register_craftitem("mcl_end:chorus_fruit_popped", {
	description = S("Popped Chorus Fruit"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	wield_image = "mcl_end_chorus_fruit_popped.png",
	inventory_image = "mcl_end_chorus_fruit_popped.png",
	groups = { craftitem = 1 },
})

--- Crafting ---
minetest.register_craft({
	type = "cooking",
	output = "mcl_end:chorus_fruit_popped",
	recipe = "mcl_end:chorus_fruit",
	cooktime = 10,
})

