mcl_stairs = {}

local S = core.get_translator(core.get_current_modname())

-- Core mcl_stairs API

-- Determine if pointer (player) is pointing above the middle of a pointed thing
-- Used when placing slabs and stairs.
local function is_pointing_above_middle(pointer, pointed_thing)
	if
		not pointer
		or not pointer:is_player()
		or not pointed_thing
		or not pointed_thing.under
		or not pointed_thing.above
	then
		return false
	end

	local p1 = pointed_thing.above

	-- this uses placer:get_look_dir() which is not quite right on touch
	-- with disabled crosshair, but the shootline used on the client isn't
	-- available to the server; therefore just check the general look
	-- direction to make it somewhat controllable by touch users (even if
	-- standing on the pointed node) without changing anything for crosshair
	-- users
	--
	-- if looking at a side face we check whether player is looking more
	-- than a little bit above the center (keeping default positioning if
	-- looking more or less at the center of the node) of the pointed node
	--
	-- if looking at the top/bottom face never/always return true (this is
	-- achieved by using y of pointed_thing.above for comparison; note that
	-- under.y == above.y if looking at a side face)
	--
	-- also note that it is actually beneficial that the exact position of
	-- the touch event is not used, allowing touch users to touch any part
	-- of the node face
	local fpos = core.pointed_thing_to_face_pos(pointer, pointed_thing).y - p1.y

	return (fpos > 0.05)
end

local function place_slab_normal(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local place = ItemStack(itemstack)
	local origname = place:get_name()
	local origdef = core.registered_nodes[origname]

	--local placer_pos = placer:get_pos()
	if
		placer
		and is_pointing_above_middle(placer, pointed_thing)
		and origdef and origdef._mcl_other_slab_half
	then
		place:set_name(origdef._mcl_other_slab_half)
	end

	local ret = core.item_place_node(place, placer, pointed_thing, 0)
	ret:set_name(origname)
	return ret
end

local function place_stair(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local p1 = pointed_thing.above
	local param2 = 0

	if placer then
		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = core.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		if is_pointing_above_middle(placer, pointed_thing) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end

	return core.item_place_node(itemstack, placer, pointed_thing, param2)
end

local function placement_prevented(params)
	if params == nil or params.itemstack == nil or params.pointed_thing == nil then
		return true
	end

	local wield_name = params.itemstack:get_name()
	local ndef = core.registered_nodes[wield_name]
	local groups = ndef.groups or {}

	local under = params.pointed_thing.under
	local node = core.get_node(under)
	local above = params.pointed_thing.above
	local wdir = core.dir_to_wallmounted({ x = under.x - above.x, y = under.y - above.y, z = under.z - above.z })

	-- on top of upside down
	if groups.attaches_to_top and (node.param2 >= 20 and wdir == 1) then
		return false
	end

	-- on base of upright stair
	if groups.attaches_to_base and (node.param2 < 20 and wdir == 0) then
		return false
	end

	-- On back of rotated stair
	if
		groups.attaches_to_side
		and (
			--upside down
			(node.param2 == 20 and wdir == 5)
			or (node.param2 == 21 and wdir == 2)
			or (node.param2 == 22 and wdir == 4)
			or (node.param2 == 23 and wdir == 3)
			-- upright
			or (node.param2 == 0 and wdir == 5)
			or (node.param2 == 1 and wdir == 3)
			or (node.param2 == 2 and wdir == 4)
			or (node.param2 == 3 and wdir == 2)
		)
	then
		return false
	end

	return true
end

local function get_stairdef_groups(nodedef)
	local groups = {}
	-- Only allow a strict set of groups to be added to stairs and slabs for more predictable results
	local allowed_groups = { "dig_immediate", "handy", "pickaxey", "axey", "shovely", "shearsy", "shearsy_wool", "swordy", "swordy_wool" }
	for a=1, #allowed_groups do
		if nodedef.groups[allowed_groups[a]] then
			groups[allowed_groups[a]] = nodedef.groups[allowed_groups[a]]
		end
	end

	return groups
end

-- Register stair function used internally for new and old API (not exposed
-- externally).
local function register_stair(subname, stairdef)

	local recipe_item = stairdef.recipeitem
	local ri_defs = core.registered_nodes[recipe_item]

	if ri_defs then
		if not stairdef.tiles then
			stairdef.tiles = ri_defs.tiles
		end
		if not stairdef.groups then
			stairdef.groups = get_stairdef_groups(ri_defs)
		end
		if not stairdef.sounds then
			stairdef.sounds = ri_defs.sounds
		end
		if not stairdef.hardness then
			stairdef.hardness = ri_defs._mcl_hardness
		end
		if not stairdef.blast_resistance then
			stairdef.blast_resistance = ri_defs._mcl_blast_resistance
		end
	end

	local image_table = {}
	for i, image in pairs(stairdef.tiles) do
		image_table[i] = type(image) == "string" and { name = image } or table.copy(image)
		image_table[i].align_style = "world"
	end

	core.register_node(":mcl_stairs:stair_" .. subname, table.merge({
		description = stairdef.description,
		_doc_items_longdesc = S("Stairs are useful to reach higher places by walking over them; jumping is not required. Placing stairs in a corner pattern will create corner stairs. Stairs placed on the ceiling or at the upper half of the side of a block will be placed upside down."),
		drawtype = "nodebox",
		tiles = image_table,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = table.merge(stairdef.groups, {
			pathfinder_partial = 2, building_block = 1, stair = 1
		}),
		sounds = stairdef.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return place_stair(itemstack, placer, pointed_thing)
		end,
		on_rotate = function(pos, node, _, mode)
			-- Flip stairs vertically
			if mode == screwdriver.ROTATE_AXIS then
				local minor = node.param2
				if node.param2 >= 20 then
					minor = node.param2 - 20
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
				else
					if minor == 3 then
						minor = 1
					elseif minor == 1 then
						minor = 3
					end
					node.param2 = minor
					node.param2 = node.param2 + 20
				end
				core.set_node(pos, node)
				return true
			end
		end,
		_mcl_blast_resistance = stairdef.blast_resistance,
		_mcl_hardness = stairdef.hardness,
		placement_prevented = placement_prevented,
	}, stairdef.overrides or {}))

	if recipe_item then
		core.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{recipe_item, "", ""},
				{recipe_item, recipe_item, ""},
				{recipe_item, recipe_item, recipe_item},
			},
		})

		-- Flipped recipe
		core.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{"", "", recipe_item},
				{"", recipe_item, recipe_item},
				{recipe_item, recipe_item, recipe_item},
			},
		})
	end

	mcl_stairs.cornerstair.add("mcl_stairs:stair_"..subname, stairdef.corner_stair_texture_override)
end

function mcl_stairs.get_base_itemstring(itemstring)
	local is = itemstring:gsub("_top", "")
	is = is:gsub("_double", "")
	is = is:gsub("_inner", "")
	is = is:gsub("_outer", "")
	return is
end

-- Register slab function used internally for new and old API (not exposed
-- externally).
local function register_slab(subname, stairdef)
	local lower_slab = "mcl_stairs:slab_"..subname
	local upper_slab = lower_slab.."_top"
	local double_slab = lower_slab.."_double"

	local recipe_item = stairdef.recipeitem
	local ri_defs = core.registered_nodes[recipe_item]

	if ri_defs then
		if not stairdef.tiles then
			stairdef.tiles = ri_defs.tiles
		end
		if not stairdef.groups then
			stairdef.groups = ri_defs.groups
		end
		if not stairdef.sounds then
			stairdef.sounds = ri_defs.sounds
		end
		if not stairdef.hardness then
			stairdef.hardness = ri_defs._mcl_hardness
		end
		if not stairdef.blast_resistance then
			stairdef.blast_resistance = ri_defs._mcl_blast_resistance
		end
	end

	-- Automatically generate double slab description if not supplied
	stairdef.double_description = stairdef.double_description or S("Double @1", stairdef.description)
	local longdesc = S("Slabs are half as high as their full block counterparts and occupy either the lower or upper part of a block, depending on how it was placed. Slabs can be easily stepped on without needing to jump. When a slab is placed on another slab of the same type, a double slab is created.")

	local nodedef = table.merge({
		description = stairdef.description,
		_doc_items_longdesc = longdesc,
		drawtype = "nodebox",
		tiles = stairdef.tiles,
		paramtype = "light",
		-- Facedir intentionally left out (see below)
		is_ground_content = false,
		groups = table.merge(stairdef.groups, {
			pathfinder_partial = 3, building_block = 1, slab = 1
		}),
		sounds = stairdef.sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if not placer then return end

			local above = pointed_thing.above
			local under = pointed_thing.under
			local anode = core.get_node(above)
			local unode = core.get_node(under)
			local adefs = core.registered_nodes[anode.name]
			local udefs = core.registered_nodes[unode.name]
			local wield_item = itemstack:get_name()
			local def = core.registered_nodes[wield_item]
			local player_name = placer:get_player_name()
			local creative_enabled = core.is_creative_enabled(player_name)

			-- place slab using under node orientation
			local dir = vector.subtract(above, under)
			local p2 = unode.param2

			if core.is_protected(under, player_name) and not
				core.check_player_privs(placer, "protection_bypass") then
					core.record_protection_violation(under, player_name)
					return
			end

			-- combine two slabs if possible
			-- Requirements: Same slab material, must be placed on top of lower slab, or on bottom of upper slab
			if (wield_item == unode.name or (udefs and wield_item == udefs._mcl_other_slab_half)) and
					not ((dir.y >= 0 and core.get_item_group(unode.name, "slab_top") == 1) or
					(dir.y <= 0 and core.get_item_group(unode.name, "slab_top") == 0)) then
				core.set_node(under, {name = def._mcl_stairs_double_slab or double_slab, param2 = p2})
				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			elseif (wield_item == anode.name or (adefs and wield_item == adefs._mcl_other_slab_half)) then
				core.set_node(above, {name = def._mcl_stairs_double_slab or double_slab, param2 = p2})
				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			-- No combination possible: Place slab normally
			else
				return place_slab_normal(itemstack, placer, pointed_thing)
			end
		end,
		_mcl_hardness = stairdef.hardness,
		_mcl_blast_resistance = stairdef.blast_resistance,
		_mcl_other_slab_half = upper_slab,
		on_rotate = function(pos, node, _, mode)
			-- Flip slab
			if mode == screwdriver.ROTATE_AXIS then
				node.name = upper_slab
				core.set_node(pos, node)
				return true
			end
			return false
		end,
	}, stairdef.overrides or {})

	core.register_node(":"..lower_slab, nodedef)

	-- Register the upper slab.
	-- Using facedir is not an option, as this would rotate the textures as well and would make
	-- e.g. upper sandstone slabs look completely wrong.
	local topdef = table.copy(nodedef)
	topdef.groups.pathfinder_partial = 2
	topdef.groups.slab_top = 1
	topdef.groups.not_in_creative_inventory = 1
	topdef.groups.not_in_craft_guide = 1
	topdef.description = S("Upper @1", stairdef.description)
	topdef._doc_items_create_entry = false
	topdef._doc_items_longdesc = nil
	topdef._doc_items_usagehelp = nil
	topdef.drop = lower_slab
	topdef._mcl_other_slab_half = lower_slab
	topdef._mcl_baseitem = lower_slab
	function topdef.on_rotate(pos, node, _, mode)
		-- Flip slab
		if mode == screwdriver.ROTATE_AXIS then
			node.name = lower_slab
			core.set_node(pos, node)
			return true
		end
		return false
	end
	topdef.node_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	topdef.selection_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	core.register_node(":"..upper_slab, topdef)


	-- Double slab node
	local dgroups = table.copy(stairdef.groups)
	dgroups.not_in_creative_inventory = 1
	dgroups.not_in_craft_guide = 1
	dgroups.slab = nil
	dgroups.pathfinder_partial = 2
	dgroups.double_slab = 1
	core.register_node(":"..double_slab, {
		description = stairdef.double_description,
		_doc_items_longdesc = S("Double slabs are full blocks which are created by placing two slabs of the same kind on each other."),
		tiles = stairdef.tiles,
		is_ground_content = false,
		groups = dgroups,
		sounds = stairdef.sounds,
		drop = lower_slab .. " 2",
		_mcl_hardness = stairdef.hardness,
		_mcl_blast_resistance = stairdef.blast_resistance,
		_mcl_baseitem = lower_slab,
	})

	if recipe_item then
		core.register_craft({
			output = lower_slab .. " 6",
			recipe = {
				{recipe_item, recipe_item, recipe_item},
			},
		})

	end
	doc.add_entry_alias("nodes", lower_slab, "nodes", upper_slab)
end

local copied_groups = {
	"pickaxey",
	"axey",
	"shovely",
	"handy",
	"shearsy",
	"swordy",
	"flammable",
	"fire_encouragement",
	"fire_flammability",
	"affected_by_lightning",
	"building_block",
	"material_stone",
	"creative_breakable",
	"not_in_creative_inventory",
	"not_in_craft_guide",
}

local function get_groups(basegroups)
	local groups = {}

	for _, group in pairs(copied_groups or {}) do
		groups[group] = basegroups[group]
	end

	return groups
end

function mcl_stairs.register_stair(subname, ...)
	if type(select(1, ...)) == "table" then
		local stairdef = select(1, ...)
		local ndef = core.registered_nodes[stairdef.baseitem]

		register_stair(subname, {
			recipeitem = stairdef.recipeitem or stairdef.baseitem,
			groups = table.merge(get_groups(ndef.groups), stairdef.groups or {}),
			tiles = stairdef.tiles or ndef.tiles,
			description = stairdef.description,
			sounds = ndef.sounds,
			blast_resistance = ndef._mcl_blast_resistance,
			hardness = ndef._mcl_hardness,
			overrides = stairdef.overrides,
		})
	else
		register_stair(subname, {
			recipeitem = select(1, ...),
			groups = select(2, ...),
			tiles = select(3, ...),
			description = select(4, ...),
			sounds = select(5, ...),
			blast_resistance = select(6, ...),
			hardness = select(7, ...),
			corner_stair_texture_override = select(8, ...),
			overrides = select(9, ...),
		})
	end
end

function mcl_stairs.register_slab(subname, ...)
	if type(select(1, ...)) == "table" then
		local stairdef = select(1, ...)
		local ndef = core.registered_nodes[stairdef.baseitem]

		register_slab(subname, {
			recipeitem = stairdef.recipeitem or stairdef.baseitem,
			groups = table.merge(get_groups(ndef.groups), stairdef.groups or {}),
			tiles = stairdef.tiles or ndef.tiles,
			description = stairdef.description,
			double_description = S("Double @1", stairdef.description),
			sounds = ndef.sounds,
			blast_resistance = ndef._mcl_blast_resistance,
			hardness = ndef._mcl_hardness,
			overrides = stairdef.overrides,
		})
	else
		register_slab(subname, {
			recipeitem = select(1, ...),
			groups = select(2, ...),
			tiles = select(3, ...),
			description = select(4, ...),
			sounds = select(5, ...),
			blast_resistance = select(6, ...),
			hardness = select(7, ...),
			double_description = select(8, ...),
			overrides = select(9, ...),
		})
	end
end

-- Stair/slab registration function.
function mcl_stairs.register_stair_and_slab(subname, ...)
	if type(select(1, ...)) == "table" then
		local stairdef = select(1, ...)
		mcl_stairs.register_stair(subname, table.merge(stairdef, { description = stairdef.description_stair }))
		mcl_stairs.register_slab(subname, table.merge(stairdef, { description = stairdef.description_slab }))
		return
	end

	register_stair(subname, {
		recipeitem = select(1, ...),
		groups = select(2, ...),
		tiles = select(3, ...),
		description = select(4, ...),
		sounds = select(6, ...),
		blast_resistance = select(7, ...),
		hardness = select(8, ...),
		corner_stair_texture_override = select(10, ...),
	})
	register_slab(subname, {
		recipeitem = select(1, ...),
		groups = select(2, ...),
		tiles = select(3, ...),
		description = select(5, ...),
		sounds = select(6, ...),
		blast_resistance = select(7, ...),
		hardness = select(8, ...),
		double_description = select(9, ...),
	})
end

-- Very simple registration function.
function mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab, corner_stair_texture_override)
	local def = core.registered_nodes[sourcenode]
	local groups = {}
	-- Only allow a strict set of groups to be added to stairs and slabs for more predictable results
	local allowed_groups = { "dig_immediate", "handy", "pickaxey", "axey", "shovely", "shearsy", "shearsy_wool", "swordy", "swordy_wool" }
	for a=1, #allowed_groups do
		if def.groups[allowed_groups[a]] then
			groups[allowed_groups[a]] = def.groups[allowed_groups[a]]
		end
	end
	mcl_stairs.register_stair_and_slab(subname, sourcenode, groups, def.tiles, desc_stair, desc_slab, def.sounds, def._mcl_blast_resistance, def._mcl_hardness, desc_double_slab, corner_stair_texture_override)
end
