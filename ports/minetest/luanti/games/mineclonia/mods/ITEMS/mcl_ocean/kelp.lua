-- TODO: whenever it becomes possible to fully implement kelp without the
-- plantlike_rooted limitation, please update accordingly.
--
-- TODO: whenever it becomes possible to make kelp grow infinitely without
-- resorting to making intermediate kelp stem node, please update accordingly.
--
-- TODO: In MC, you can't actually destroy kelp by bucket'ing water in the middle.
-- However, because of the plantlike_rooted hack, we'll just allow it for now.

local S = core.get_translator(core.get_current_modname())

-- Kelp API
--------------------------------------------------------------------------------

local kelp = {}
mcl_ocean.kelp = kelp

-- Once reach the maximum, kelp no longer grows.
kelp.MIN_AGE = 0
kelp.MAX_AGE = 25

kelp.TICK = 0.2 -- Tick interval (in seconds) for updating kelp.

-- The average amount of growth for kelp in a day is 2.16 (https://youtu.be/5Bp4lAjAk3I)
-- Normally, a day lasts 20 minutes, meaning kelp.next_grow() is executed
-- 1200 / TICK times. Per tick probability = (216/100) / (1200/TICK)
-- NOTE: currently, we can't exactly use the same type of randomness MC does, because
-- it has multiple complicated sets of PRNGs.
-- NOTE: Small loss of precision, should be 10 to preserve it.
-- kelp.ROLL_GROWTH_PRECISION = 10
-- kelp.ROLL_GROWTH_NUMERATOR = 216 * kelp.TICK * kelp.ROLL_GROWTH_PRECISION
-- kelp.ROLL_GROWTH_DENOMINATOR = 100 * 1200 * kelp.ROLL_GROWTH_PRECISION
kelp.ROLL_GROWTH_PRECISION = 1
kelp.ROLL_GROWTH_NUMERATOR = 216 * kelp.TICK
kelp.ROLL_GROWTH_DENOMINATOR = 100 * 1200

-- Sounds used to dig and place kelp.
kelp.leaf_sounds = mcl_sounds.node_sound_leaves_defaults()

-- is age in the growable range?
function kelp.is_age_growable(age)
	return age >= 0 and age < kelp.MAX_AGE
end


-- Is this water?
-- Returns the liquidtype, if indeed water.
function kelp.is_submerged(node)
	local g = core.get_item_group(node.name, "water")
	if g > 0 and g <= 3  then
		-- Expected only "source" and "flowing" from water liquids
		return core.registered_nodes[node.name].liquidtype
	end
	return false
end


-- Is the water downward flowing?
-- (kelp can grow/be placed inside downward flowing water)
function kelp.is_downward_flowing(pos, node, pos_above, node_above, __is_above__)
	-- Function params: (pos[, node]) or (node, pos_above) or (node, node_above)
	local node = node or core.get_node(pos)

	local result = (math.floor(node.param2 / 8) % 2) == 1
	if not (result or __is_above__) then
		-- If not, also check node above.
		-- (this is needed due a weird quirk in the definition of "downwards flowing"
		-- liquids in Minetest)
		local pos_above = pos_above or {x=pos.x,y=pos.y+1,z=pos.z}
		local node_above = node_above or core.get_node(pos_above)
		result = kelp.is_submerged(node_above)
			or kelp.is_downward_flowing(nil, node_above, nil, nil, true)
	end
	return result
end


-- Will node fall at that position?
-- This only checks if a node would fall, meaning that node need not be at pos.
function kelp.is_falling(pos, node, is_falling, pos_bottom, node_bottom, def_bottom)
	-- Optional params: is_falling, pos_bottom, node_bottom, def_bottom

	-- NOTE: Modified from check_single_for_falling in builtin.
	-- Please update accordingly.
	local nodename = node.name

	if is_falling == false or
		is_falling == nil and core.get_item_group(nodename, "falling_node") == 0 then
		return false
	end

	local pos_bottom = pos_bottom or {x = pos.x, y = pos.y - 1, z = pos.z}
	-- get_node_or_nil: Only fall if node below is loaded
	local node_bottom = node_bottom or core.get_node_or_nil(pos_bottom)
	if not node_bottom then return end
	local nodename_bottom = node_bottom.name
	local def_bottom = def_bottom or node_bottom and core.registered_nodes[nodename_bottom]
	if not def_bottom then
		return false
	end

	local same = nodename == nodename_bottom
	-- Let leveled nodes fall if it can merge with the bottom node
	if same and def_bottom.paramtype2 == "leveled" and
			core.get_node_level(pos_bottom) <
			core.get_node_max_level(pos_bottom) then
		return true
	end

	-- Otherwise only if the bottom node is considered "fall through"
	if not same and
			(not def_bottom.walkable or def_bottom.buildable_to) and
			(core.get_item_group(nodename, "float") == 0 or
			def_bottom.liquidtype == "none") then
		return true
	end

	return false
end


-- Roll initial age for kelp.
function kelp.roll_init_age(min, max)
	-- Optional params
	return math.random(min or kelp.MIN_AGE, (max or kelp.MAX_AGE)-1)
end


-- Converts param2 to kelp height.
-- For the special case where the max param2 is reached, interpret that as the
-- 16th kelp stem.
local floor = math.floor
local function kelp_get_height (param2)
	return floor (param2 / 16) + floor (param2 % 16 / 8)
end


-- Obtain pos and node of the tip of kelp.
function kelp.get_tip(pos, height)
	-- Optional params: height
	local height = height or kelp_get_height(core.get_node(pos).param2)
	local pos_tip = {x=pos.x, y=pos.y+height+1, z=pos.z}
	return pos_tip, core.get_node(pos_tip), height
end

local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_water_flowing = core.get_content_id ("mcl_core:water_flowing")
local cid_ignore = core.CONTENT_IGNORE

-- Obtain position of the first kelp unsubmerged.
function kelp.find_unsubmerged (pos)
	local cid, _, param2, _ = core.get_node_raw (pos.x, pos.y, pos.z)
	local height = param2 < 16 and 1 or kelp_get_height (param2)

	for y = pos.y + 1, pos.y + height do
		local walk_node, _, _, _
			= core.get_node_raw (pos.x, y, pos.z)
		if walk_node ~= cid_water_source
			and walk_node ~= cid_ignore
			and walk_node ~= cid_water_flowing then
			return vector.new (pos.x, y, pos.z), height, cid
		end
	end
	return nil, nil, nil
end


-- Obtain next param2.
function kelp.next_param2(param2)
	-- param2 max value is 255, so adding to 256 causes overflow.
	return math.min(param2+16 - param2 % 16, 255);
end

local function store_age (pos, age)
	if pos then
		core.get_meta(pos):set_int("mcl_ocean:kelp_age", age)
	end
end

local function retrieve_age (pos)
	local meta = core.get_meta(pos)
	local age_set = meta:contains("mcl_ocean:kelp_age")
	if not age_set then
		return nil
	end

	local age = meta:get_int("mcl_ocean:kelp_age")
	return age
end

-- Initialise a kelp's age.
function kelp.init_age(pos)
	local age = retrieve_age(pos)
	if not age then
		age = kelp.roll_init_age()
		store_age(pos, age)
	end
	return age
end

-- Apply next kelp height. The surface is swapped. so on_construct is skipped.
function kelp.next_height(pos, node, pos_tip, node_tip, submerged, downward_flowing)
	-- Modified params: node
	-- Optional params: node, set_node, pos_tip, node_tip, submerged, downward_flowing
	local node = node or core.get_node(pos)
	local pos_tip = pos_tip
	local node_tip = node_tip or (pos_tip and core.get_node(pos_tip))
	if not pos_tip then
		pos_tip,node_tip = kelp.get_tip(pos)
	end
	local downward_flowing = downward_flowing or
		(submerged or kelp.is_submerged(node_tip)
		 and kelp.is_downward_flowing(pos_tip, node_tip))

	-- Liquid source: Grow normally.
	node.param2 = kelp.next_param2(node.param2)
	core.swap_node(pos, node)

	-- Flowing liquid: Grow 1 step, but also turn the tip node into a liquid source.
	if downward_flowing then
		local alt_liq = core.registered_nodes[node_tip.name].liquid_alternative_source
		if alt_liq and core.registered_nodes[alt_liq] then
			core.set_node(pos_tip, {name=alt_liq})
		end
	end

	return node, pos_tip, node_tip, submerged, downward_flowing
end


-- Grow next kelp.
function kelp.next_grow(age, pos, node, pos_tip, node_tip, submerged, downward_flowing)
	local node = node or core.get_node(pos)
	local pos_tip = pos_tip
	local node_tip = node_tip or (pos_tip and core.get_node(pos_tip))
	if not pos_tip then
		pos_tip,node_tip = kelp.get_tip(pos)
	end

	-- New kelp must also be submerged in water.
	local downward_flowing = downward_flowing or kelp.is_downward_flowing(pos_tip, node_tip)
	if not (submerged or kelp.is_submerged(node_tip)) then
		return
	end

	kelp.next_height(pos, node, pos_tip, node_tip, submerged, downward_flowing)
	store_age(pos, age)
	return true, node, pos_tip, node_tip, submerged, downward_flowing
end


-- Drops the items for detached kelps.
function kelp.detach_drop(pos, height)
	-- Optional params: height
	local height = height or kelp_get_height(core.get_node(pos).param2)
	local y = pos.y
	local walk_pos = {x=pos.x, z=pos.z}
	for i=1,height do
		walk_pos.y = y+i
		core.add_item(walk_pos, "mcl_ocean:kelp")
	end
	return true
end


-- Detach the kelp at dig_pos, and drop their items.
-- Synonymous to digging the kelp.
-- NOTE: this is intended for whenever kelp truly becomes segmented plants
-- instead of rooted to the floor. Don't try to remove dig_pos.
function kelp.detach_dig(dig_pos, pos, drop, node, height)
	-- Optional params: drop, node, height

	local node = node or core.get_node(pos)
	local height = height or kelp_get_height(node.param2)
	-- pos.y points to the surface, offset needed to point to the first kelp.
	local new_height = dig_pos.y - (pos.y+1)

	-- Digs the entire kelp.
	if new_height <= 0 then
		if drop then
			kelp.detach_drop(dig_pos, height)
		end
		core.set_node(pos, {
			name=core.registered_nodes[node.name].node_dig_prediction,
			param=node.param,
			param2=0 })

	-- Digs the kelp beginning at a height.
	else
		if drop then
			kelp.detach_drop(dig_pos, height - new_height)
		end
		core.swap_node(pos, {name=node.name, param=node.param, param2=16*new_height})
	end
end


--------------------------------------------------------------------------------
-- Kelp callback functions
--------------------------------------------------------------------------------

function kelp.surface_on_dig(pos, node, digger) ---@diagnostic disable-line: unused-local
	kelp.detach_dig(pos, pos, true, node)
end

function kelp.surface_after_dig_node(pos, node)
	return core.set_node(pos, {name=core.registered_nodes[node.name].node_dig_prediction})
end

local function detach_unsubmerged (pos)
	local dig_pos, height, cid_kelp = kelp.find_unsubmerged (pos)
	if dig_pos then
		local name = core.get_name_from_content_id (cid_kelp)
		if name and core.registered_nodes[name] then
			local sound = core.registered_nodes[name].sounds.dug
			core.sound_play (sound, { gain = 0.5, pos = dig_pos }, true)
			kelp.detach_dig (dig_pos, pos, true, nil, height)
		end
		local new_age = kelp.roll_init_age ()
		store_age (pos, new_age)
	end
end

local function grow_kelp (pos)
	local node = core.get_node(pos)
	local age = retrieve_age(pos)
	if not age then
		age = kelp.init_age(pos)
	end

	if kelp.is_age_growable(age) then
		kelp.next_grow(age+1, pos, node)
	end
end

function kelp.surface_on_construct(pos)
	kelp.init_age(pos)
end


function kelp.surface_on_destruct(pos)
	local node = core.get_node(pos)
	-- on_falling callback. Activated by pistons for falling nodes too.
	-- I'm not sure this works. I think piston digs water and the unsubmerged nature drops kelp.
	if kelp.is_falling(pos, node) then
		kelp.detach_drop(pos, kelp_get_height(node.param2))
	end
end



function kelp.surface_on_piston_move(movednode) ---@diagnostic disable-line: unused-local
	-- Pistons moving falling nodes will have already activated on_falling callback.
	kelp.detach_dig(movednode.pos, movednode.pos, core.get_item_group(movednode.node.name, "falling_node") ~= 1, movednode.node)
end


function kelp.kelp_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above
	local node_under = core.get_node(pos_under)
	local nu_name = node_under.name

	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	-- Protection
	if core.is_protected(pos_under, player_name) or
			core.is_protected(pos_above, player_name) then
		core.log("action", player_name
			.. " tried to place " .. itemstack:get_name()
			.. " at protected position "
			.. core.pos_to_string(pos_under))
		core.record_protection_violation(pos_under, player_name)
		return itemstack
	end


	local pos_tip, node_tip, def_tip, new_surface, height
	-- Kelp must also be placed on the top/tip side of the surface/kelp
	if pos_under.y >= pos_above.y then
		return itemstack
	end

	-- When placed on kelp.
	if core.get_item_group(nu_name, "kelp") == 1 then
		height = kelp_get_height(node_under.param2)
		pos_tip,node_tip = kelp.get_tip(pos_under, height)
		def_tip = core.registered_nodes[node_tip.name]

	-- When placed on surface.
	else
		new_surface = false
		for _,surface in pairs(kelp.surfaces) do
			if nu_name == surface.nodename then
				node_under.name = "mcl_ocean:kelp_" ..surface.name
				node_under.param2 = 0
				new_surface = true
				break
			end
		end
		-- Surface must support kelp
		if not new_surface then
			return itemstack
		end

		pos_tip = pos_above
		node_tip = core.get_node(pos_above)
		def_tip = core.registered_nodes[node_tip.name]
		height = 0
	end

	-- Next kelp must also be submerged in water.
	local submerged = kelp.is_submerged(node_tip)
	if not submerged then
		return itemstack
	end

	-- Play sound, place surface/kelp and take away an item
	local def_node = core.registered_items[nu_name]
	if def_node.sounds then
		core.sound_play(def_node.sounds.place, { gain = 0.5, pos = pos_under }, true)
	end
	-- TODO: get rid of rooted plantlike hack
	if height < 16 then
		kelp.next_height(pos_under, node_under, pos_tip, node_tip, def_tip, submerged)
	else
		core.add_item(pos_tip, "mcl_ocean:kelp")
	end
	if not core.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	kelp.init_age(pos_under)

	return itemstack
end

function kelp.lbm_register(pos)
	kelp.init_age(pos)
end

--------------------------------------------------------------------------------
-- Kelp registration API
--------------------------------------------------------------------------------

-- List of supported surfaces for seagrass and kelp.
-- Note that Minecraft supports placing kelp on all surfaces but magma
-- blocks.
kelp.surfaces = {
	{ name="dirt",			nodename="mcl_core:dirt",		},
	{ name="sand",			nodename="mcl_core:sand",		},
	{ name="redsand",		nodename="mcl_core:redsand",		},
	{ name="gravel",		nodename="mcl_core:gravel",		},
	{ name="stone",			nodename="mcl_core:stone",		},
	{ name="andesite",		nodename="mcl_core:andesite",		},
	{ name="cobble",		nodename="mcl_core:cobble",		},
	{ name="diorite",		nodename="mcl_core:diorite",		},
	{ name="clay",			nodename="mcl_core:clay",		},
	{ name="granite",		nodename="mcl_core:granite",		},
	{ name="sandstone",		nodename="mcl_core:sandstone",		},
	{ name="redsandstone",		nodename="mcl_core:redsandstone",	},
	{ name="prismarine",		nodename="mcl_ocean:prismarine",	},
	{ name="prismarine_brick",	nodename="mcl_ocean:prismarine_brick",	},
	{ name="prismarine_dark",	nodename="mcl_ocean:prismarine_dark",	},
}

-- Commented properties are the ones obtained using register_kelp_surface.
-- If you define your own properties, it overrides the default ones.
kelp.surface_deftemplate = {
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "leveled",
	place_param2 = 16,
	--tiles = def.tiles,
	special_tiles = {
		{
		name = "mcl_ocean_kelp_plant.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
		tileable_vertical = true,
		}
	},
	--inventory_image = "("..def.tiles[1]..")^mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.5, 0.5 },
		},
	},
	-- groups.falling_node = is_falling,
	groups = { dig_immediate = 3, deco_block = 1, plant = 1, kelp = 1, not_in_creative_inventory = 1 },
	--sounds = sounds,
	--node_dig_prediction = nodename,
	on_construct = kelp.surface_on_construct,
	on_destruct = kelp.surface_on_destruct,
	on_dig = kelp.surface_on_dig,
	after_dig_node = kelp.surface_after_dig_node,
	_mcl_pistons_on_move = kelp.surface_on_piston_move,
	drop = "", -- drops are handled in on_dig
	--_mcl_falling_node_alternative = is_falling and nodename or nil,
	_mcl_hardness = 0,
	_mcl_baseitem = "mcl_ocean:kelp"
}

-- Commented properties are the ones obtained using register_kelp_surface.
kelp.surface_docs = {
	-- entry_id_orig = nodename,
	_doc_items_entry_name = S("Kelp"),
	_doc_items_longdesc = S("Kelp grows inside water on top of dirt, sand or gravel."),
	--_doc_items_create_entry = doc_create,
	_doc_items_image = "mcl_ocean_kelp_item.png",
}

-- Creates new surfaces.
-- NOTE: surface_deftemplate will be modified in-place.
function kelp.register_kelp_surface(surface, surface_deftemplate, surface_docs)
	local name = surface.name
	local nodename = surface.nodename
	local def = core.registered_nodes[nodename]
	local def_tiles = def.tiles

	local surfacename = "mcl_ocean:kelp_"..name
	local surface_deftemplate = surface_deftemplate or kelp.surface_deftemplate -- Optional param

	local doc_create = surface.doc_create or false
	local surface_docs = surface_docs or kelp.surface_docs -- Optional param

	if doc_create then
		surface_deftemplate._doc_items_entry_name = surface_docs._doc_items_entry_name
		surface_deftemplate._doc_items_longdesc = surface_docs._doc_items_longdesc
		surface_deftemplate._doc_items_create_entry = true
		surface_deftemplate._doc_items_image = surface_docs._doc_items_image
		-- Sets the first surface as the docs' entry ID
		if not surface_docs.entry_id_orig then
			surface_docs.entry_id_orig = nodename
		end
	else
		doc.add_entry_alias("nodes", surface_docs.entry_id_orig, "nodes", surfacename)
	end

	local sounds = table.copy(def.sounds)
	sounds.dig = kelp.leaf_sounds.dig
	sounds.dug = kelp.leaf_sounds.dug
	sounds.place = kelp.leaf_sounds.place

	surface_deftemplate.tiles = surface_deftemplate.tiles or def_tiles
	surface_deftemplate.inventory_image = surface_deftemplate.inventory_image
		or ("("..(type (def_tiles[1]) == "string" and def_tiles[1] or def_tiles[1].name)
		    ..")^mcl_ocean_kelp_item.png")
	surface_deftemplate.sounds = surface_deftemplate.sound or sounds
	local falling_node = core.get_item_group(nodename, "falling_node")
	surface_deftemplate.node_dig_prediction = surface_deftemplate.node_dig_prediction or nodename
	surface_deftemplate.groups.falling_node = surface_deftemplate.groups.falling_node or falling_node
	surface_deftemplate._mcl_falling_node_alternative = surface_deftemplate._mcl_falling_node_alternative or (falling_node and nodename or nil)

	core.register_node(surfacename, surface_deftemplate)

	if core.ipc_get then
		local surfaces = core.ipc_get ("mcl_ocean:registered_kelp_surfaces") or {}
		table.insert (surfaces, {
			name = name,
			nodename = nodename,
		})
		core.ipc_set ("mcl_ocean:registered_kelp_surfaces", surfaces)
	end
end

-- Kelp surfaces nodes ---------------------------------------------------------

-- Dirt must be registered first, for the docs
kelp.register_kelp_surface(kelp.surfaces[1], table.copy(kelp.surface_deftemplate), kelp.surface_docs)
for i=2, #kelp.surfaces do
	kelp.register_kelp_surface(kelp.surfaces[i], table.copy(kelp.surface_deftemplate), kelp.surface_docs)
end

-- Kelp item -------------------------------------------------------------------

core.register_craftitem("mcl_ocean:kelp", {
	description = S("Kelp"),
	_tt_help = S("Grows in water on dirt, sand, gravel"),
	_doc_items_create_entry = false,
	inventory_image = "mcl_ocean_kelp_item.png",
	wield_image = "mcl_ocean_kelp_item.png",
	on_place = kelp.kelp_on_place,
	groups = {deco_block = 1, compostability = 30, smoker_cookable = 1, campfire_cookable = 1},
	_mcl_cooking_output = "mcl_ocean:dried_kelp"
})

doc.add_entry_alias("nodes", kelp.surface_docs.entry_id_orig, "craftitems", "mcl_ocean:kelp")

-- Dried kelp ------------------------------------------------------------------

-- TODO: This is supposed to be eaten very fast
core.register_craftitem("mcl_ocean:dried_kelp", {
	description = S("Dried Kelp"),
	_doc_items_longdesc = S("Dried kelp is a food item."),
	inventory_image = "mcl_ocean_dried_kelp.png",
	wield_image = "mcl_ocean_dried_kelp.png",
	groups = {food = 2, eatable = 1, compostability = 30},
	_mcl_saturation = 0.6,
	_mcl_eat_delay = 0.8,
	_mcl_crafting_output = {square3 = {output = "mcl_ocean:dried_kelp_block"}}
})

core.register_node("mcl_ocean:dried_kelp_block", {
	description = S("Dried Kelp Block"),
	_doc_items_longdesc = S("A decorative block that serves as a great furnace fuel."),
	tiles = { "mcl_ocean_dried_kelp_top.png", "mcl_ocean_dried_kelp_bottom.png", "mcl_ocean_dried_kelp_side.png" },
	is_ground_content = false,
	groups = {
		handy = 1, hoey = 1, building_block = 1, compostability = 50,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = screwdriver.rotate_3way,
	_mcl_hardness = 0.5,
	_mcl_blast_resistance = 2.5,
	_mcl_burntime = 200,
	_mcl_crafting_output = {single = {output = "mcl_ocean:dried_kelp 9"}}
})

--------------------------------------------------------------------------------
-- Kelp ABM + LBM's
--------------------------------------------------------------------------------


core.register_lbm({
	label = "Kelp initialise",
	name = "mcl_ocean:kelp_init_83",
	nodenames = { "group:kelp" },
	run_at_every_load = false, -- so old kelps are also initialised
	action = kelp.lbm_register,
})

core.register_abm({
	label = "Kelp drops",
	nodenames = { "group:kelp" },
	interval = 1.0,
	chance = 1,
	catch_up = false,
	action = detach_unsubmerged, --surface_unsubmerged_abm,
})


-- 50% growth over a minute https://minecraft.wiki/w/Tutorials/Kelp_farming
-- 14% chance every random tick
-- On average, blocks are updated every 68.27 seconds (1365.33 game ticks)
-- 1 in 7 every 68
-- 1 in 28 every 17
-- 1 in 21 every 22
-- https://minecraft.wiki/w/Tick#Random_tick
core.register_abm({
	label = "Kelp growth",
	nodenames = { "group:kelp" },
	interval = 17,
	chance = 28,
	catch_up = false,
	action = grow_kelp,
})

--------------------------------------------------------------------------------
-- Async feature generation.
--------------------------------------------------------------------------------

local function unpack4 (x)
	return x[1], x[2], x[3], x[4]
end

local v = vector.zero ()

mcl_levelgen.register_notification_handler ("mcl_ocean:kelp_age", function (_, poses_with_age)
	for _, gendata in ipairs (poses_with_age) do
		local age
		v.x, v.y, v.z, age = unpack4 (gendata)
		local node = core.get_node (v)
		if core.get_item_group (node.name, "kelp") >= 1 then
			store_age (v, age)
		end
	end
end)
