--
-- Lava vs water interactions
--
core.register_abm({
	label = "Lava cooling",
	nodenames = {"group:lava"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	min_y = mcl_vars.mg_end_min,
	action = function(pos, node)
		local water = core.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "group:water")

		local lavatype = core.registered_nodes[node.name].liquidtype

		for w=1, #water do
			--local waternode = core.get_node(water[w])
			--local watertype = core.registered_nodes[waternode.name].liquidtype
			-- Lava on top of water: Water turns into stone
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				core.set_node(water[w], {name="mcl_core:stone"})
				core.sound_play("fire_extinguish_flame", {pos = water[w], gain = 0.2, max_hear_distance = 16}, true)
			-- Flowing lava vs water on same level: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				core.set_node(pos, {name="mcl_core:cobble"})
				core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.2, max_hear_distance = 16}, true)
			-- Lava source vs flowing water above or horizontally neighbored: Lava turns into obsidian
			elseif lavatype == "source" and
					((water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z) or
					(water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z))) then
				core.set_node(pos, {name="mcl_core:obsidian"})
				core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.2, max_hear_distance = 16}, true)
			-- water above flowing lava: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				core.set_node(pos, {name="mcl_core:cobble"})
				core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.2, max_hear_distance = 16}, true)
			end
		end
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
function mcl_core.grow_cactus(pos, _)
	pos.y = pos.y-1
	local name = core.get_node(pos).name
	if core.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while core.get_node(pos).name == "mcl_core:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end

		if math.random() < (height >= 3 and 0.25 or 0.1) then
			if core.get_node(pos).name == "air" then
				core.set_node(pos, {name="mcl_core:cactus_flower"})
			end

			return
		end

		if height < 3 then
			if core.get_node(pos).name == "air" then
				core.set_node(pos, {name="mcl_core:cactus"})
			end
		end
	end
end

function mcl_core.grow_reeds(pos, amount)
	local amount = tonumber(amount) or 1
	local top_pos = mcl_util.traverse_tower(pos, 1)
	local bot_pos, height = mcl_util.traverse_tower(top_pos, -1)
	local ground_pos = vector.offset(bot_pos, 0, -1, 0)

	local name = core.get_node(ground_pos).name
	if core.get_item_group(name, "soil_sugarcane") ~= 0 then
		if core.find_node_near(ground_pos, 1, {"group:water"}) == nil and core.find_node_near(ground_pos, 1, {"group:frosted_ice"}) == nil then
			core.remove_node(vector.offset(ground_pos,0,1,0))
			core.add_item(vector.offset(ground_pos,0,1,0), "mcl_core:reeds")
			core.check_for_falling(vector.offset(ground_pos,0,2,0))
			return false
		end

		if height >= 3 then return end
		amount = math.min(amount, 3 - height)

		for i = 1, amount do
			local pos2 = pos:offset(0, i, 0)
			local node2 = core.get_node(pos2)
			local ndef = core.registered_nodes[node2.name]
			if node2.name ~= "air" and not ndef.buildable_to then
				break
			end
			core.set_node(pos2, {name="mcl_core:reeds"})
		end
		return true
	end
	return false
end

-- ABMs and liquid flow.

local function drop_attached_node(p)
	local nn = core.get_node(p).name
	if nn == "air" or nn == "ignore" then
		return
	end
	core.remove_node(p)
	for _, item in pairs(core.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		if item ~= "" then
			core.add_item(pos, item)
		end
	end
end

function mcl_core.basic_flood (pos, _, new_node)
	if core.get_item_group (new_node.name, "water") > 0 then
		drop_attached_node (pos)
		core.dig_node (pos)
	elseif core.get_item_group (new_node.name, "lava") > 0 then
		core.remove_node (pos)
		core.sound_play ("builtin_item_lava", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		core.check_for_falling (pos)
	else
		return true
	end
end

-- Cactus mechanisms
core.register_abm({
	label = "Cactus growth",
	nodenames = {"mcl_core:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_cactus(pos)
	end,
})

core.register_abm({
	label = "Cactus mechanisms",
	nodenames = {"mcl_core:cactus"},
	interval = 1,
	chance = 1,
	action = function(pos)
		for object in core.objects_inside_radius(pos, 1.1) do
			local entity = object:get_luaentity()
			local dst = vector.distance(object:get_pos(), pos)
			if entity and entity.name == "__builtin:item" and dst <= 0.9 then
				object:remove()
			elseif entity and entity.is_mob then
				mcl_util.deal_damage(object, 1, {type = "cactus"})
			end
		end
		local posses = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
		for _, p in pairs(posses) do
			local ndef = core.registered_nodes[core.get_node(vector.new(pos.x + p[1], pos.y, pos.z + p[2])).name]
			if ndef and ndef.walkable then
				local pos1 = vector.copy(pos)
				while core.get_node(pos1).name == "mcl_core:cactus" do
					core.remove_node(pos1)
					core.add_item(vector.offset(pos1, mcl_util.float_random(-0.5, 0.5), 0, mcl_util.float_random(-0.5, 0.5)), "mcl_core:cactus")
					pos1.y = pos1.y + 1
				end
				core.check_for_falling(pos1)
				break
			end
		end
	end,
})


core.register_abm({
	label = "Sugar canes growth",
	nodenames = {"mcl_core:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_reeds(pos)
	end,
})

local grass_spread_randomizer = PcgRandom(core.get_mapgen_setting("seed"))

function mcl_core.get_grass_palette_index(pos)
	local index = 0
	if mcl_levelgen.levelgen_enabled then
		local biome = mcl_levelgen.get_biome (pos, true)
		local biome_data = mcl_levelgen.registered_biomes[biome]
		return (biome_data and biome_data.grass_palette_index) or 0
	else
		local biome_data = core.get_biome_data(pos)
		if biome_data then
			local biome = biome_data.biome
			local biome_name = core.get_biome_name(biome)
			local reg_biome = core.registered_biomes[biome_name]
			if reg_biome then
				index = reg_biome._mcl_palette_index
			end
		end
	end
	return index
end

-- Return appropriate grass block node for pos
function mcl_core.get_grass_block_type(pos)
	local idx = mcl_core.get_grass_palette_index(pos)
	if idx then
		return {name = "mcl_core:dirt_with_grass", param2 = idx}
	end
	return nil
end

------------------------------
-- Spread grass blocks and mycelium on neighbor dirt
------------------------------
core.register_abm({
	label = "Grass Block and Mycelium spread",
	nodenames = {"mcl_core:dirt"},
	neighbors = {"air", "group:grass_block_no_snow", "mcl_core:mycelium"},
	interval = 30,
	chance = 20,
	catch_up = false,
	action = function(pos)
		if pos == nil then
			return
		end
		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local abovenode = core.get_node(above)
		if core.get_item_group(abovenode.name, "liquid") ~= 0 or core.get_item_group(abovenode.name, "opaque") == 1 then
			-- Never grow directly below liquids or opaque blocks
			return
		end
		local light_self = core.get_node_light(above)
		if not light_self then return end
		--[[ Try to find a spreading dirt-type block (e.g. grass block or mycelium)
		within a 3×5×3 area, with the source block being on the 2nd-topmost layer. ]]
		local nodes = core.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+3, z=pos.z+1}, "group:spreading_dirt_type")
		local p2
		-- Nothing found ? Bail out!
		if #nodes <= 0 then
			return
		else
			p2 = nodes[grass_spread_randomizer:next(1, #nodes)]
		end

		-- Found it! Now check light levels!
		local source_above = {x=p2.x, y=p2.y+1, z=p2.z}
		local light_source = core.get_node_light(source_above)
		if not light_source then return end

		if light_self >= 4 and light_source >= 9 then
			-- All checks passed! Let's spread the grass/mycelium!
			local n2 = core.get_node(p2)
			if core.get_item_group(n2.name, "grass_block") ~= 0 then
				n2 = mcl_core.get_grass_block_type(pos)
			end
			if n2 then
				core.swap_node(pos, n2)
				-- If this was mycelium, uproot plant above
				if n2.name == "mcl_core:mycelium" then
					if core.get_item_group(core.get_node(above).name, "non_mycelium_plant") > 0 then
						core.dig_node(above)
					end
				end
			end
		end
	end
})

-- Grass/mycelium death in darkness
core.register_abm({
	label = "Grass Block / Mycelium in darkness",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, _)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = core.get_node(above).name
		-- Kill grass/mycelium when below opaque block or liquid
		if name ~= "ignore" and (core.get_item_group(name, "opaque") == 1 or core.get_item_group(name, "liquid") ~= 0) then
			core.swap_node(pos, {name = "mcl_core:dirt"})
		end
	end
})

-- Turn Grass Path and similar nodes to Dirt if a solid node is placed above it
core.register_on_placenode(function(pos, newnode)
	if core.get_item_group(newnode.name, "solid") ~= 0 or
			core.get_item_group(newnode.name, "dirtifier") ~= 0 then
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local belownode = core.get_node(below)
		if core.get_item_group(belownode.name, "dirtifies_below_solid") == 1 then
			core.set_node(below, {name="mcl_core:dirt"})
		end
	end
end)

core.register_abm({
	label = "Turn Grass Path below solid block into Dirt",
	nodenames = {"mcl_core:grass_path"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = core.get_node(above).name
		local nodedef = core.registered_nodes[name]
		if name ~= "ignore" and nodedef and (nodedef.groups and nodedef.groups.solid) then
			core.swap_node(pos, {name = "mcl_core:dirt"})
		end
	end,
})

local SAVANNA_INDEX = 1
core.register_lbm({
	label = "Replace legacy dry grass",
	name = "mcl_core:replace_legacy_dry_grass_0_65_0",
	nodenames = {"mcl_core:dirt_with_dry_grass", "mcl_core:dirt_with_dry_grass_snow"},
	action = function(pos, node)
		local biome_data = core.get_biome_data(pos)
		if biome_data then
			local biome = biome_data.biome
			local biome_name = core.get_biome_name(biome)
			local reg_biome = core.registered_biomes[biome_name]
			if reg_biome then
				if node.name == "mcl_core:dirt_with_dry_grass_snow" then
					node.name = "mcl_core:dirt_with_grass_snow"
				else
					node.name = "mcl_core:dirt_with_grass"
				end
				node.param2 = reg_biome._mcl_palette_index
				-- Fall back to savanna palette index
				if not node.param2 then
					node.param2 = SAVANNA_INDEX
				end
				core.set_node(pos, node)
				return
			end
		end
		node.param2 = SAVANNA_INDEX
		core.swap_node(pos, node)
	end,
})

---------------------
-- Vine generating --
---------------------
core.register_abm({
	label = "Vines growth",
	nodenames = {"mcl_core:vine"},
	interval = 47,
	chance = 4,
	action = function(pos, node)

		-- XXX: support spreading vertically attached vines.
		if node.param2 < 2 then
			return
		end

		-- Add vines below pos (if empty)
		local function spread_down(_, target, _, node)
			if math.random(1, 2) == 1 then
				if core.get_node(target).name == "air" then
					core.set_node(target, {name = "mcl_core:vine", param2 = node.param2})
				end
			end
		end

		-- Add vines above pos if it is backed up
		local function spread_up(origin, target, _, node)
			local vines_in_area = core.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "mcl_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				if math.random(1, 2) == 1 then
					if core.get_node(target).name == "air" then
						local backup_dir = core.wallmounted_to_dir(node.param2)
						local backup = vector.subtract(target, backup_dir)
						local backupnodename = core.get_node(backup).name

						-- Check if the block above is supported
						if mcl_core.supports_vines(backupnodename) then
							core.set_node(target, {name = "mcl_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local function spread_horizontal(origin, target, dir, node)
			local vines_in_area = core.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "mcl_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				-- Spread horizontally
				local backup_dir = core.wallmounted_to_dir(node.param2)
				if not vector.equals(backup_dir, dir) then
					local target_node = core.get_node(target)
					if target_node.name == "air" then
						local backup = vector.add(target, backup_dir)
						local backupnodename = core.get_node(backup).name
						if mcl_core.supports_vines(backupnodename) then
							core.set_node(target, {name = "mcl_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local directions = {
			{ { x= 1, y= 0, z= 0 }, spread_horizontal },
			{ { x=-1, y= 0, z= 0 }, spread_horizontal },
			{ { x= 0, y= 1, z= 0 }, spread_up },
			{ { x= 0, y=-1, z= 0 }, spread_down },
			{ { x= 0, y= 0, z= 1 }, spread_horizontal },
			{ { x= 0, y= 0, z=-1 }, spread_horizontal },
		}

		local d = math.random(1, #directions)
		local dir = directions[d][1]
		local spread = directions[d][2]

		spread(pos, vector.add(pos, dir), dir, node)
	end
})

-- Returns true of the node supports vines
function mcl_core.supports_vines(nodename)
	local def = core.registered_nodes[nodename]
	-- Rules: 1) walkable 2) full cube
	return def and def.walkable and
			(def.node_box == nil or def.node_box.type == "regular") and
			(def.collision_box == nil or def.collision_box.type == "regular")
end

-- Melt snow
core.register_abm({
	label = "Top snow and ice melting",
	nodenames = {"mcl_core:snow", "mcl_core:ice"},
	interval = 16,
	chance = 8,
	action = function(pos, node)
		if core.get_node_light(pos, 0) >= 12 then
			if node.name == "mcl_core:ice" then
				mcl_core.melt_ice(pos)
			else
				core.remove_node(pos)
			end
		end
	end
})

-- Freeze water

local function position_cold_p (pos)
	-- Avoid the redundant natural light tests in mcl_weather.
	local name = mcl_biome_dispatch.get_biome_name (pos)
	return mcl_biome_dispatch.is_position_cold (name, pos)
end

local band = bit.band

local function is_sunlit (param1, dnr)
	-- It is possible to sidestep various expensive computations
	-- in core.get_natural_light and a redundant Luanti API call
	-- because the artificial light level that is also required is
	-- lesser than full daylight.

	local artificial = band (param1, 0xf0)
	return band (param1, 0xf) == 0xf and param1 < 0xa0
		and dnr < (artificial - 0xa0) / (artificial - 0xf0)
end

-- Day-night ratio below which areas exposed to full daylight receive
-- light levels lesser than 10.
local MAX_DNR = 11.0 / 15.0

local get_current_day_night_ratio
	= mcl_util.get_current_day_night_ratio

core.register_abm({
	label = "Freeze water in cold areas",
	nodenames = {"mcl_core:water_source", "mclx_core:river_water_source"},
	interval = 32,
	chance = 10,
	action = function(pos, node)
		local ratio = get_current_day_night_ratio ()
		if ratio < MAX_DNR then
			local _, param1, _, _
				= core.get_node_raw (pos.x, pos.y + 1, pos.z)
			if is_sunlit (param1, ratio) and position_cold_p (pos) then
				node.name = "mcl_core:ice"
				core.swap_node (pos, node)
			end
		end
	end
})

-- Melt ice at pos. mcl_core:ice MUST be at pos if you call this!
function mcl_core.melt_ice(pos)
	-- Create a water source if ice is destroyed and there was something below it
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local belownode = core.get_node(below)
	local dim = mcl_worlds.pos_to_dimension(below)
	if dim ~= "nether" and belownode.name ~= "air" and belownode.name ~= "ignore" and belownode.name ~= "mcl_core:void" then
		core.set_node(pos, {name="mcl_core:water_source"})
	else
		core.remove_node(pos)
	end
	local neighbors = {
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
	}
	for n=1, #neighbors do
		core.check_single_for_falling(vector.add(pos, neighbors[n]))
	end
end

---- FUNCTIONS FOR SNOWED NODES ----
-- These are nodes which change their appearence when they are below a snow cover
-- and turn back into “normal” when the snow cover is removed.

-- Registers a snowed variant of a node (e.g. grass block, podzol, mycelium).
-- * itemstring_snowed: Itemstring of the snowed node to add
-- * itemstring_clear: Itemstring of the original “clear” node without snow
-- * tiles: Optional custom tiles
-- * sounds: Optional custom sounds
-- * clear_colorization: Optional. If true, will clear all paramtype2="color" related node def. fields
-- * desc: Item description
--
-- The snowable nodes also MUST have _mcl_snowed defined to contain the name
-- of the snowed node.
function mcl_core.register_snowed_node(itemstring_snowed, itemstring_clear, tiles, sounds, clear_colorization, desc)
	local def = table.copy(core.registered_nodes[itemstring_clear])
	local create_doc_alias
	if def.description then
		create_doc_alias = true
	else
		create_doc_alias = false
	end
	-- Just some group clearing
	def.description = desc
	def._doc_items_longdesc = nil
	def._doc_items_usagehelp = nil
	def._doc_items_create_entry = false
	def.groups.not_in_creative_inventory = 1
	if def.groups.grass_block == 1 then
		def.groups.grass_block_no_snow = nil
		def.groups.grass_block_snow = 1
	end

	-- Enderman must never take this because this block is supposed to be always buried below snow.
	def.groups.enderman_takable = nil

	-- Snowed blocks never spread
	def.groups.spreading_dirt_type = nil

	-- Add the clear node to the item definition for easy lookup
	def._mcl_snowless = itemstring_clear

	-- Note: _mcl_snowed must be added to the clear node manually!

	if not tiles then
		def.tiles = {"default_snow.png", "default_dirt.png", {name="mcl_core_grass_side_snowed.png", tileable_vertical=false}}
	else
		def.tiles = tiles
	end
	if clear_colorization then
		def.paramtype2 = nil
		def.palette = nil
		def.palette_index = nil
		def.color = nil
		def.overlay_tiles = nil
	end
	if not sounds then
		def.sounds = mcl_sounds.node_sound_dirt_defaults({
			footstep = mcl_sounds.node_sound_snow_defaults().footstep,
		})
	else
		def.sounds = sounds
	end

	def._mcl_silk_touch_drop = {itemstring_clear}

	-- Register stuff
	core.register_node(itemstring_snowed, def)

	if create_doc_alias then
		doc.add_entry_alias("nodes", itemstring_clear, "nodes", itemstring_snowed)
	end
end

-- Reverts a snowed dirtlike node at pos to its original snow-less form.
-- This function assumes there is no snow cover node above. This function
-- MUST NOT be called if there is a snow cover node above pos.
function mcl_core.clear_snow_dirt(pos, node)
	local def = core.registered_nodes[node.name]
	if def and def._mcl_snowless then
		core.swap_node(pos, {name = def._mcl_snowless, param2=node.param2})
	end
end

---- [[[[[ Functions for snowable nodes (nodes that can become snowed). ]]]]] ----
-- Always add these for snowable nodes.

-- on_construct
-- Makes constructed snowable node snowed if placed below a snow cover node.
function mcl_core.on_snowable_construct(pos)
	-- Myself
	local node = core.get_node(pos)

	-- Above
	local apos = {x=pos.x, y=pos.y+1, z=pos.z}
	local anode = core.get_node(apos)

	-- Make snowed if needed
	if core.get_item_group(anode.name, "snow_cover") == 1 then
		local def = core.registered_nodes[node.name]
		if def and def._mcl_snowed then
			core.swap_node(pos, {name = def._mcl_snowed, param2=node.param2})
		end
	end
end


---- [[[[[ Functions for snow cover nodes. ]]]]] ----

-- A snow cover node is a node which turns a snowed dirtlike --
-- node into its snowed form while it is placed above.
-- Mineclonia's snow cover nodes are Top Snow (mcl_core:snow) and Snow (mcl_core:snowblock).

-- Always add the following functions to snow cover nodes:

-- on_construct
-- Makes snowable node below snowed.
function mcl_core.on_snow_construct(pos)
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = core.get_node(npos)
	local def = core.registered_nodes[node.name]
	if def and def._mcl_snowed then
		core.swap_node(npos, {name = def._mcl_snowed, param2=node.param2})
	end
end
-- after_destruct
-- Clears snowed dirtlike node below.
function mcl_core.after_snow_destruct(pos)
	local nn = core.get_node(pos).name
	-- No-op if snow was replaced with snow
	if core.get_item_group(nn, "snow_cover") == 1 then
		return
	end
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = core.get_node(npos)
	mcl_core.clear_snow_dirt(npos, node)
end


-- Obsidian crying
local crobby_particle = {
	velocity = vector.zero(),
	acceleration = vector.zero(),
	texture = "mcl_core_crying_obsidian_tear.png",
	collisiondetection = false,
	collision_removal = false,
}

core.register_abm({
	label = "Obsidian cries",
	nodenames = {"mcl_core:crying_obsidian"},
	interval = 5,
	chance = 10,
	action = function(pos)
		if core.get_node(vector.offset(pos, 0, -1, 0)).name ~= "air" then return end
		core.after(0.1 + math.random() * 1.4, function()
			local pt = table.copy(crobby_particle)
			pt.size = 1.3 + math.random() * 1.2
			pt.expirationtime = 0.5 + math.random()
			pt.pos = vector.offset(pos, math.random() - 0.5, -0.51, math.random() - 0.5)
			core.add_particle(pt)
			core.after(pt.expirationtime, function()
				pt.acceleration = vector.new(0, -9, 0)
				pt.collisiondetection = true
				pt.expirationtime = 1.2 + math.random() * 3.3
				core.add_particle(pt)
			end)
		end)
	end
})

function mcl_core.make_dirtpath(itemstack, placer, pointed_thing)
	-- Only make grass path if tool used on side or top of target node
	if pointed_thing.above.y < pointed_thing.under.y then
		return itemstack
	end

	local above = table.copy(pointed_thing.under)
	above.y = above.y + 1
	if core.get_node(above).name == "air" then
		if not core.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a shovely node)
			local toolname = itemstack:get_name()
			local wear = mcl_autogroup.get_wear(toolname, "shovely")
			itemstack:add_wear(wear)
		end
		core.sound_play({name="default_grass_footstep", gain=1}, {pos = above}, true)
		core.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
	end
	return itemstack,true
end


function mcl_core.bottle_dirt(itemstack, placer, pointed_thing)
	local def = itemstack:get_definition()
	if def._mcl_cauldrons_liquid then
		local node = core.get_node(pointed_thing.under)
		itemstack = mcl_potions.set_node_empty_bottle(itemstack, placer, pointed_thing, "mcl_mud:mud", node.param2) or itemstack
		return itemstack
	end
end

function mcl_core.get_bottle_place_on_water(bottle)
	return function(itemstack, placer, pointed_thing)
		return mcl_inventory.give_and_take(placer, itemstack, bottle, "give")
	end
end


function mcl_core.bone_meal_grass(_, _, pointed_thing)
	local flowers_table_plains = {
		"mcl_flowers:dandelion",
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",

		"mcl_flowers:oxeye_daisy",
		"mcl_flowers:tulip_orange",
		"mcl_flowers:tulip_red",
		"mcl_flowers:tulip_white",
		"mcl_flowers:tulip_pink",
		"mcl_flowers:azure_bluet",
	}
	local flowers_table_simple = {
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",
	}
	local flowers_table_swampland = {
		"mcl_flowers:blue_orchid",
	}
	local flowers_table_flower_forest = {
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",
		"mcl_flowers:oxeye_daisy",
		"mcl_flowers:tulip_orange",
		"mcl_flowers:tulip_red",
		"mcl_flowers:tulip_white",
		"mcl_flowers:tulip_pink",
		"mcl_flowers:azure_bluet",
		"mcl_flowers:allium",
	}
	local flowers_table_palegarden_day = {
		"mcl_flowers:eyeblossom",
	}
	local flowers_table_palegarden_night = {
		"mcl_flowers:eyeblossom_open",
	}

	for i = -7, 7 do
		for j = -7, 7 do
			for y = 0, 2 do
				local pos = vector.offset(pointed_thing.under, i, y, j)
				local n = core.get_node(pos)
				local n2 = core.get_node(vector.offset(pos, 0, -1, 0))

				if n.name ~= "" and n.name == "air" and (core.get_item_group(n2.name, "grass_block_no_snow") == 1) then
					-- Randomly generate flowers, tall grass or nothing
					if math.random(1, 100) <= 90 / ((math.abs(i) + math.abs(j)) / 2)then
						-- 90% tall grass, 10% flower
						if math.random(1,100) <= 90 then
							local col = n2.param2
							core.set_node(pos, {name="mcl_flowers:tallgrass", param2=col})
						else
							local flowers_table
							local biome = core.get_biome_name(core.get_biome_data(pos).biome)
							if biome == "Swampland" or biome == "Swampland_shore" or biome == "Swampland_ocean" or biome == "Swampland_deep_ocean" or biome == "Swampland_underground" then
								flowers_table = flowers_table_swampland
							elseif biome == "FlowerForest" or biome == "FlowerForest_beach" or biome == "FlowerForest_ocean" or biome == "FlowerForest_deep_ocean" or biome == "FlowerForest_underground" then
								flowers_table = flowers_table_flower_forest
							elseif biome == "Plains" or biome == "Plains_beach" or biome == "Plains_ocean" or biome == "Plains_deep_ocean" or biome == "Plains_underground" or biome == "SunflowerPlains" or biome == "SunflowerPlains_ocean" or biome == "SunflowerPlains_deep_ocean" or biome == "SunflowerPlains_underground" then
								flowers_table = flowers_table_plains
							elseif biome == "PaleGarden" or biome == "PaleGarden_ocean" then
								if core.get_timeofday() <= 0.2 or core.get_timeofday() >= 0.8 then
									flowers_table = flowers_table_palegarden_night
								else
									flowers_table = flowers_table_palegarden_day
								end
							else
								flowers_table = flowers_table_simple
							end
							core.set_node(pos, {name=flowers_table[math.random(1, #flowers_table)]})
						end
					end
				end
			end
		end
	end
	return true
end

-- Show positions of barriers when player is wielding a barrier
mcl_player.register_globalstep_slow(function(player)
	local wi = player:get_wielded_item():get_name()
	if wi == "mcl_core:barrier"
		or wi == "mcl_core:realm_barrier"
		or core.get_item_group(wi, "light_block") ~= 0
		or wi == "mcl_levelgen:structure_void" then
		local pos = vector.round(player:get_pos())
		local r = 8
		local vm = core.get_voxel_manip()
		local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
		local area = VoxelArea:new{
			MinEdge = emin,
			MaxEdge = emax,
		}
		local data = vm:get_data()
		for x=pos.x-r, pos.x+r do
		for y=pos.y-r, pos.y+r do
		for z=pos.z-r, pos.z+r do
			local vi = area:indexp({x=x, y=y, z=z})
			local nodename = core.get_name_from_content_id(data[vi])
			local light_block_group = core.get_item_group(nodename, "light_block")

			local tex
			if nodename == "mcl_core:barrier" then
				tex = "mcl_core_barrier.png"
			elseif nodename == "mcl_core:realm_barrier" then
				tex = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX"
			elseif nodename == "mcl_levelgen:structure_void" then
				tex = "mcl_levelgen_structure_void.png"
			elseif light_block_group ~= 0 then
				tex = "mcl_core_light_" .. (light_block_group - 1) .. ".png"
			end
			if tex then
				core.add_particle({
					pos = {x=x, y=y, z=z},
					expirationtime = 1,
					size = 8,
					texture = tex,
					glow = 14,
					playername = player:get_player_name()
				})
			end
		end
		end
		end
	end
end)
