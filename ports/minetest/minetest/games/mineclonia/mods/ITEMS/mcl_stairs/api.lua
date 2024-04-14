mcl_stairs = {}

local S = minetest.get_translator(minetest.get_current_modname())

-- Core mcl_stairs API

local function place_slab_normal(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local place = ItemStack(itemstack)
	local origname = place:get_name()
	local origdef = minetest.registered_nodes[origname]

	--local placer_pos = placer:get_pos()
	if placer
		and mcl_util.is_pointing_above_middle(placer, pointed_thing)
		and origdef and origdef._mcl_other_slab_half
	then
		place:set_name(origdef._mcl_other_slab_half)
	end

	local ret = minetest.item_place(place, placer, pointed_thing, 0)
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
			param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		if mcl_util.is_pointing_above_middle(placer, pointed_thing) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end

	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

local function placement_prevented(params)
	if params == nil or params.itemstack == nil or params.pointed_thing == nil then
		return true
	end

	local wield_name = params.itemstack:get_name()
	local ndef = minetest.registered_nodes[wield_name]
	local groups = ndef.groups or {}

	local under = params.pointed_thing.under
	local node = minetest.get_node(under)
	local above = params.pointed_thing.above
	local wdir = minetest.dir_to_wallmounted({ x = under.x - above.x, y = under.y - above.y, z = under.z - above.z })

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
	if stairdef.recipeitem and minetest.registered_items[stairdef.recipeitem] then
		if not stairdef.tiles then
			stairdef.tiles = minetest.registered_items[stairdef.recipeitem].tiles
		end
		if not stairdef.groups then
			stairdef.groups = get_stairdef_groups(minetest.registered_items[stairdef.recipeitem])
		end
		if not stairdef.sounds then
			stairdef.sounds = minetest.registered_items[stairdef.recipeitem].sounds
		end
		if not stairdef.hardness then
			stairdef.hardness = minetest.registered_items[stairdef.recipeitem]._mcl_hardness
		end
		if not stairdef.blast_resistance then
			stairdef.blast_resistance = minetest.registered_items[stairdef.recipeitem]._mcl_blast_resistance
		end
	end

	stairdef.groups.stair = 1
	stairdef.groups.building_block = 1

	local image_table = {}
	for i, image in pairs(stairdef.tiles) do
		image_table[i] = type(image) == "string" and { name = image } or table.copy(image)
		image_table[i].align_style = "world"
	end

	minetest.register_node(":mcl_stairs:stair_" .. subname, table.merge({
		description = stairdef.description,
		_doc_items_longdesc = S("Stairs are useful to reach higher places by walking over them; jumping is not required. Placing stairs in a corner pattern will create corner stairs. Stairs placed on the ceiling or at the upper half of the side of a block will be placed upside down."),
		drawtype = "nodebox",
		tiles = image_table,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = table.merge(stairdef.groups,{stair = 1}),
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
		on_rotate = function(pos, node, user, mode, param2)
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
				minetest.set_node(pos, node)
				return true
			end
		end,
		_mcl_blast_resistance = stairdef.blast_resistance,
		_mcl_hardness = stairdef.hardness,
		placement_prevented = placement_prevented,
	}, stairdef.overrides or {}))

	if stairdef.recipeitem and stairdef.recipeitem ~= "" then
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{stairdef.recipeitem, "", ""},
				{stairdef.recipeitem, stairdef.recipeitem, ""},
				{stairdef.recipeitem, stairdef.recipeitem, stairdef.recipeitem},
			},
		})

		-- Flipped recipe
		minetest.register_craft({
			output = "mcl_stairs:stair_" .. subname .. " 4",
			recipe = {
				{"", "", stairdef.recipeitem},
				{"", stairdef.recipeitem, stairdef.recipeitem},
				{stairdef.recipeitem, stairdef.recipeitem, stairdef.recipeitem},
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

	if stairdef.recipeitem and minetest.registered_items[stairdef.recipeitem] then
		if not stairdef.tiles then
			stairdef.tiles = minetest.registered_items[stairdef.recipeitem].tiles
		end
		if not stairdef.groups then
			stairdef.groups = minetest.registered_items[stairdef.recipeitem].groups
		end
		if not stairdef.sounds then
			stairdef.sounds = minetest.registered_items[stairdef.recipeitem].sounds
		end
		if not stairdef.hardness then
			stairdef.hardness = minetest.registered_items[stairdef.recipeitem]._mcl_hardness
		end
		if not stairdef.blast_resistance then
			stairdef.blast_resistance = minetest.registered_items[stairdef.recipeitem]._mcl_blast_resistance
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
		groups = table.merge(stairdef.groups, { slab = 1, building_block = 1 }),
		sounds = stairdef.sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local under = minetest.get_node(pointed_thing.under)
			local wield_item = itemstack:get_name()
			local player_name = placer and placer:get_player_name() or ""
			local creative_enabled = minetest.is_creative_enabled(player_name)
			local def = minetest.registered_nodes[wield_item]

			-- place slab using under node orientation
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)

			local p2 = under.param2

			-- combine two slabs if possible
			-- Requirements: Same slab material, must be placed on top of lower slab, or on bottom of upper slab
			if (wield_item == under.name or (minetest.registered_nodes[under.name] and wield_item == minetest.registered_nodes[under.name]._mcl_other_slab_half)) and
					not ((dir.y >= 0 and minetest.get_item_group(under.name, "slab_top") == 1) or
					(dir.y <= 0 and minetest.get_item_group(under.name, "slab_top") == 0)) then


				if minetest.is_protected(pointed_thing.under, player_name) and not
						minetest.check_player_privs(player_name, "protection_bypass") then
					minetest.record_protection_violation(pointed_thing.under,
						player_name)
					return
				end
				local newnode = def._mcl_stairs_double_slab or double_slab
				minetest.set_node(pointed_thing.under, {name = newnode, param2 = p2})
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
		on_rotate = function(pos, node, user, mode, param2)
			-- Flip slab
			if mode == screwdriver.ROTATE_AXIS then
				node.name = upper_slab
				minetest.set_node(pos, node)
				return true
			end
			return false
		end,
	}, stairdef.overrides or {})

	minetest.register_node(":"..lower_slab, table.merge(nodedef,{
		groups = table.merge(stairdef.groups,{slab = 1}),
	}))

	-- Register the upper slab.
	-- Using facedir is not an option, as this would rotate the textures as well and would make
	-- e.g. upper sandstone slabs look completely wrong.
	local topdef = table.copy(nodedef)
	topdef.groups.slab = 1
	topdef.groups.slab_top = 1
	topdef.groups.not_in_creative_inventory = 1
	topdef.groups.not_in_craft_guide = 1
	topdef.description = S("Upper @1", stairdef.description)
	topdef._doc_items_create_entry = false
	topdef._doc_items_longdesc = nil
	topdef._doc_items_usagehelp = nil
	topdef.drop = lower_slab
	topdef._mcl_other_slab_half = lower_slab
	function topdef.on_rotate(pos, node, user, mode, param2)
		-- Flip slab
		if mode == screwdriver.ROTATE_AXIS then
			node.name = lower_slab
			minetest.set_node(pos, node)
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
	minetest.register_node(":"..upper_slab, topdef)


	-- Double slab node
	local dgroups = table.copy(stairdef.groups)
	dgroups.not_in_creative_inventory = 1
	dgroups.not_in_craft_guide = 1
	dgroups.slab = nil
	dgroups.double_slab = 1
	minetest.register_node(":"..double_slab, {
		description = stairdef.double_description,
		_doc_items_longdesc = S("Double slabs are full blocks which are created by placing two slabs of the same kind on each other."),
		tiles = stairdef.tiles,
		is_ground_content = false,
		groups = dgroups,
		sounds = stairdef.sounds,
		drop = lower_slab .. " 2",
		_mcl_hardness = stairdef.hardness,
		_mcl_blast_resistance = stairdef.blast_resistance,
	})

	if stairdef.recipeitem and stairdef.recipeitem ~= "" then
		minetest.register_craft({
			output = lower_slab .. " 6",
			recipe = {
				{stairdef.recipeitem, stairdef.recipeitem, stairdef.recipeitem},
			},
		})

	end

	-- Help alias for the upper slab
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", lower_slab, "nodes", upper_slab)
	end
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
		local ndef = minetest.registered_nodes[stairdef.baseitem]

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
		local ndef = minetest.registered_nodes[stairdef.baseitem]

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
	local def = minetest.registered_nodes[sourcenode]
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
