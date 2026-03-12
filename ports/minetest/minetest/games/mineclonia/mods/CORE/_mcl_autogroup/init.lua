--[[
This mod implements a HACK to make 100% sure the digging times of all tools
match Minecraft's perfectly.  The digging times system of Minetest is very
different, so this weird group trickery has to be used.  In Minecraft, each
block has a hardness and the actual Minecraft digging time is determined by
this:

1) The block's hardness
2) The tool being used (the tool speed and its efficiency level)
3) Whether the tool is considered as "eligible" for the block
   (e.g. only diamond pick eligible for obsidian)

See Minecraft Wiki <http://minecraft.gamepedia.com/Minecraft_Wiki> for more
information.

How the mod is used
-------------------

In Mineclonia, all diggable nodes have the hardness set in the custom field
"_mcl_hardness" (0 by default).  These values are used together with digging
groups by this mod to create the correct digging times for nodes.  Digging
groups are registered using the following code:

    mcl_autogroup.register_diggroup("shovely")
    mcl_autogroup.register_diggroup("pickaxey", {
        levels = { "wood", "gold", "stone", "iron", "diamond" }
    })

The first line registers a simple digging group.  The second line registers a
digging group with 5 different levels (in this case one for each material of a
pickaxes).

Nodes indicate that they belong to a particular digging group by being member of
the digging group in their node definition.  "mcl_core:dirt" for example has
shovely=1 in its groups.  If the digging group has multiple levels the value of
the group indicates which digging level the node requires.
"mcl_core:stone_with_gold" for example has pickaxey=4 because it requires a
pickaxe of level 4 be mined.

For tools to be able to dig nodes of digging groups they need to use the have
the custom field "_mcl_diggroups" function to get the groupcaps.  The value of
this field is a table which defines which groups the tool can dig and how
efficiently.

    _mcl_diggroups = {
        handy = { speed = 1, level = 1, uses = 0 },
        pickaxey = { speed = 1, level = 0, uses = 0 },
    }

The "uses" field indicate how many uses (0 for infinite) a tool has when used on
the specified digging group.  The "speed" field is a multiplier to the dig speed
on that digging group.

The "level" field indicates which levels of the group the tool can harvest.  A
level of 0 means that the tool cannot harvest blocks of that node.  A level of 1
or above means that the tool can harvest nodes with that level or below.  See
"mcl_farming/hoes.lua" for examples on how "_mcl_diggroups" is used in practice.

Information about the mod
-------------------------

The mod is split up into two parts, mcl_autogroup and _mcl_autogroup.
mcl_autogroup contains the API functions used to register custom digging groups.
_mcl_autogroup contains most of the code.  The leading underscore in the name
"_mcl_autogroup" is used to force Minetest to load that part of the mod as late
as possible.  Minetest loads mods in reverse alphabetical order.

This also means that it is very important that no mod adds _mcl_autogroup as a
dependency.
--]]

assert(core.get_modpath("mcl_autogroup"), "This mod requires the mod mcl_autogroup to function")

local groups_mtg2mcl = {
	["choppy"] = { group = "axey", hardness = 2 },
	["oddly_breakable_by_hand"] = { group = "handy", hardness = 0 },
	["cracky"] = { group = "pickaxey", hardness = 1.5 },
	["crumbly"] = { group = "shovely", hardness = 0.5 },
	["snappy"] = { group = "swordy", hardness = 0.2 },
}

local C = core.colorize

-- maps rarity group rating to their colors; 1=uncommen, 2=rare, 3=epic
local rarity_colors = {
	mcl_colors.YELLOW,
	mcl_colors.AQUA,
	mcl_colors.DARK_PURPLE,
}

-- shapes for simple recipes
local shapes = {
	-- single
	single = {{"mat"}},
	-- line_wide
	line_wide2 = {{"mat", "mat"}},
	line_wide3 = {{"mat", "mat", "mat"}},
	-- line_tall
	line_tall2 = {{"mat"}, {"mat"}},
	line_tall3 = {{"mat"}, {"mat"}, {"mat"}},
	-- square
	square2 = {{"mat", "mat"}, {"mat", "mat"}},
	square3 = {{"mat", "mat", "mat"}, {"mat", "mat", "mat"}, {"mat", "mat", "mat"}}
}
-- replaces "mat" tag
local function replace_material_tag(shape, material)
	local recipe = table.copy(shape)
	for _, line in ipairs(recipe) do
		for count, tag in ipairs(line) do
			if tag == "mat" then
				line[count] = material
			end
		end
	end
	return recipe
end

-- Get new groups and hardness
local function convert_mtg_groups(nname)
	local groups = table.copy(core.registered_nodes[nname].groups)
	local hardness = core.registered_nodes[nname]._mcl_hardness

	if not hardness then --if _mcl_hardness is defined the node is clearly intended for mcl specifically, don't mess with the groups in that case
		-- mtg group `level` indicates tool tier needed to dig the node
		local level = 2 * (groups.level or 1) - 1
		groups.level = nil
		for mtg, mcl in pairs(groups_mtg2mcl) do
			local g_mtg = core.get_item_group(nname, mtg)
			local g_mcl = core.get_item_group(nname, mcl.group)
			if g_mtg > 0 and g_mcl == 0 then
				groups[mcl.group] = level
				groups[mtg] = nil
				-- mtg dig group value indicates hardness
				hardness = math.max(hardness or 0, (4 - g_mtg) * mcl.hardness)
			end
		end
	end
	return groups, hardness
end

for nname, _ in pairs(core.registered_nodes) do
	local newgroups, newhardness = convert_mtg_groups(nname)

	core.override_item(nname, {
		groups = newgroups,
		_mcl_hardness = newhardness,
	})
end

-- Returns a table containing the unique "_mcl_hardness" for nodes belonging to
-- each diggroup.
local function get_hardness_values_for_groups()
	local maps = {}
	local values = {}
	for g, _ in pairs(mcl_autogroup.registered_diggroups) do
		maps[g] = {}
		values[g] = {}
	end

	for _, ndef in pairs(core.registered_nodes) do
		for g, _ in pairs(mcl_autogroup.registered_diggroups) do
			if ndef.groups[g] then
				maps[g][ndef._mcl_hardness or 0] = true
			end
		end
	end

	for g, map in pairs(maps) do
		for k, _ in pairs(map) do
			table.insert(values[g], k)
		end
	end

	for g, _ in pairs(mcl_autogroup.registered_diggroups) do
		table.sort(values[g])
	end
	return values
end

-- Returns a table containing a table indexed by "_mcl_hardness" value to get
-- its index in the list of unique hardnesses for each diggroup.
local function get_hardness_lookup_for_groups(hardness_values)
	local map = {}
	for g, values in pairs(hardness_values) do
		map[g] = {}
		for k, v in pairs(values) do
			map[g][v] = k
		end
	end
	return map
end

-- Array of unique hardness values for each group which affects dig time.
local hardness_values = get_hardness_values_for_groups()

--[[local function compute_creativetimes(group)
	local creativetimes = {}

	for index, hardness in pairs(hardness_values[group]) do
		table.insert(creativetimes, 0)
	end

	return creativetimes
end]]

-- Get the list of digging times for using a specific tool on a specific
-- diggroup.
--
-- Parameters:
-- group - the group which it is digging
-- can_harvest - if the tool can harvest the block
-- speed - dig speed multiplier for tool (default 1)
-- efficiency - efficiency level for the tool if applicable
local function get_digtimes(group, can_harvest, speed, efficiency)
	local speed = speed or 1
	if efficiency then
		speed = speed + efficiency * efficiency + 1
	end

	local digtimes = {}

	for _, hardness in pairs(hardness_values[group]) do
		local digtime = (hardness or 0) / speed
		if can_harvest then
			digtime = digtime * 1.5
		else
			digtime = digtime * 5
		end

		if digtime <= 0.05 then
			digtime = 0
		else
			digtime = math.ceil(digtime * 20) / 20
		end
		table.insert(digtimes, digtime)
	end

	return digtimes
end

-- Get one groupcap field for using a specific tool on a specific group.
local function get_groupcap(group, can_harvest, multiplier, efficiency, uses)
	return {
		times = get_digtimes(group, can_harvest, multiplier, efficiency),
		uses = uses,
		maxlevel = 0,
	}
end

-- Add the groupcaps from a field in "_mcl_diggroups" to the groupcaps of a
-- tool.
local function add_groupcaps(toolname, groupcaps, groupcaps_def, efficiency)
	if not groupcaps_def then
		return
	end

	for g, capsdef in pairs(groupcaps_def) do
		local mult = capsdef.speed or 1
		local uses = capsdef.uses
		local def = mcl_autogroup.registered_diggroups[g]
		assert(def, toolname .. " has unknown diggroup '" .. dump(g) .. "'")
		local max_level = def.levels and #def.levels or 1

		assert(capsdef.level, toolname .. ' is missing level for ' .. g)
		local level = math.min(capsdef.level, max_level)

		if def.levels then
			groupcaps[g .. "_dig_default"] = get_groupcap(g, false, mult, efficiency, uses)
			if level > 0 then
				groupcaps[g .. "_dig_" .. def.levels[level]] = get_groupcap(g, true, mult, efficiency, uses)
			end
		else
			groupcaps[g .. "_dig"] = get_groupcap(g, level > 0, mult, efficiency, uses)
		end
	end
end

-- Checks if the given node would drop its useful drop if dug by a given tool.
-- Returns true if it will yield its useful drop, false otherwise.
function mcl_autogroup.can_harvest(nodename, toolname, player)
	local ndef = core.registered_nodes[nodename]

	if not ndef then
		return false
	end

	if core.get_item_group(nodename, "dig_immediate") >= 2 then
		return true
	end

	-- Check if it can be dug by tool
	local tdef = core.registered_tools[toolname]
	if tdef and tdef._mcl_diggroups then
		for g, gdef in pairs(tdef._mcl_diggroups) do
			if ndef.groups[g] then
				if ndef.groups[g] <= gdef.level then
					return true
				end
			end
		end
	end

	-- Check if it can be dug by hand
	if player and player:is_player() then
		local name = player:get_inventory():get_stack("hand", 1):get_name()
		tdef = core.registered_items[name]
	end
	if tdef and tdef._mcl_diggroups then
		for g, gdef in pairs(tdef._mcl_diggroups) do
			if ndef.groups[g] then
				if ndef.groups[g] <= gdef.level then
					return true
				end
			end
		end
	end

	return false
end

-- Get one groupcap field for using a specific tool on a specific group.
--[[local function get_groupcap(group, can_harvest, multiplier, efficiency, uses)
	return {
		times = get_digtimes(group, can_harvest, multiplier, efficiency),
		uses = uses,
		maxlevel = 0,
	}
end]]

-- Returns the tool_capabilities from a tool definition or a default set of
-- tool_capabilities
local function get_tool_capabilities(tdef)
	if tdef.tool_capabilities then
		return tdef.tool_capabilities
	end

	-- If the damage group and punch interval from hand is not included,
	-- then the user will not be able to attack with the tool.
	local hand_toolcaps = mcl_meshhand.survival_hand_tool_caps
	return {
		full_punch_interval = hand_toolcaps.full_punch_interval,
		damage_groups = hand_toolcaps.damage_groups
	}
end

-- Get the groupcaps for a tool.  This function returns "groupcaps" table of
-- digging which should be put in the "tool_capabilities" of the tool definition
-- or in the metadata of an enchanted tool.
--
-- Parameters:
-- toolname - Name of the tool being enchanted (like "mcl_tools:pick_diamond")
-- efficiency - The efficiency level the tool is enchanted with (default 0)
--
-- NOTE:
-- This function can only be called after mod initialization.  Otherwise a mod
-- would have to add _mcl_autogroup as a dependency which would break the mod
-- loading order.
function mcl_autogroup.get_groupcaps(toolname, efficiency)
	local tdef = core.registered_items[toolname]
	local groupcaps = table.copy(get_tool_capabilities(tdef).groupcaps or {})
	add_groupcaps(toolname, groupcaps, tdef._mcl_diggroups, efficiency)
	return groupcaps
end

-- Get the wear from using a tool on a digging group.
--
-- Parameters
-- toolname - Name of the tool used
-- diggroup - The name of the diggroup the tool is used on
--
-- NOTE:
-- This function can only be called after mod initialization.  Otherwise a mod
-- would have to add _mcl_autogroup as a dependency which would break the mod
-- loading order.
function mcl_autogroup.get_wear(toolname, diggroup)
	local tdef = core.registered_tools[toolname]
	local uses = tdef._mcl_diggroups[diggroup].uses
	return math.ceil(65535 / uses)
end

local function overwrite()
	-- Refresh, now that all groups are known.
	hardness_values = get_hardness_values_for_groups()

	-- Map indexed by hardness values which return the index of that value in
	-- hardness_value.  Used for quick lookup.
	local hardness_lookup = get_hardness_lookup_for_groups(hardness_values)

	for nname, ndef in pairs(core.registered_nodes) do
		local override = {}
		local newgroups = table.copy(ndef.groups)
		if (nname ~= "ignore" and ndef.diggable) then
			-- Automatically assign the "solid" group for solid nodes
			if (ndef.walkable == nil or ndef.walkable == true)
					and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
					and (ndef.node_box == nil or ndef.node_box.type == "regular")
					and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
				newgroups.solid = 1
			end
			-- Automatically assign the "opaque" group for opaque nodes
			if (not (ndef.paramtype == "light" or ndef.sunlight_propagates)) and
					(ndef.groups.not_opaque == 0 or ndef.groups.not_opaque == nil) then
				newgroups.opaque = 1
			end

			-- Assign groups used for digging this node depending on
			-- the registered digging groups
			for g, gdef in pairs(mcl_autogroup.registered_diggroups) do
				local index = hardness_lookup[g][ndef._mcl_hardness] or newgroups[g] or hardness_lookup[g][0]
				if newgroups[g] then
					if gdef.levels then
						newgroups[g .. "_dig_default"] = index

						for i = newgroups[g], #gdef.levels do
							newgroups[g .. "_dig_" .. gdef.levels[i]] = index
						end
					else
						newgroups[g .. "_dig"] = index
					end
				end
			end

			-- Automatically assign the node to the
			-- creative_breakable group if it belongs to any digging
			-- group.
			newgroups["creative_breakable"] = 1
			override.groups = newgroups
		end

		-- dig_by_water and destroy_by_lava.  In most (all?) instances the two
		-- are wholly equivalent.
		if core.get_item_group(nname, "dig_by_water") > 0 or core.get_item_group(nname, "destroy_by_lava_flow") > 0 then
			override.floodable = true
			override.on_flood = mcl_core.basic_flood
		end

		if table.count(override) > 0 then
			core.override_item(nname, override)
		end
	end

	for tname, tdef in pairs(core.registered_items) do
		-- Assign groupcaps for digging the registered digging groups
		-- depending on the _mcl_diggroups in the tool definition
		if tdef._mcl_diggroups then
			local toolcaps = table.copy(get_tool_capabilities(tdef))
			toolcaps.groupcaps = mcl_autogroup.get_groupcaps(tname)

			core.override_item(tname, {
				tool_capabilities = toolcaps
			})
		end

		local rarity_group = core.get_item_group(tname, "rarity")
		if rarity_group > 0 and rarity_colors[rarity_group] then
			local desc = tdef.description or tname
			core.override_item(tname, {
				description = C(rarity_colors[rarity_group], desc)
			})
		end

		if tdef.groups.eatable and tdef.groups.eatable > 0 then
			core.override_item(tname, {
				touch_interaction = "short_dig_long_place",
			})
		end


		if tdef._mcl_burntime and tdef._mcl_burntime > 0 then
			core.register_craft({
				type = "fuel",
				recipe = tname,
				burntime = tdef._mcl_burntime,
				replacements = tdef._mcl_fuel_replacements
			})
		end

		local cooking_output = tdef._mcl_cooking_output
		if cooking_output and type(cooking_output) == "string" and cooking_output ~= "" then
			core.register_craft({
				type = "cooking",
				recipe = tname,
				output = cooking_output,
				cooktime = tdef._mcl_cooktime or 10,
				replacements = tdef._mcl_cooking_replacements
			})
		end

		local crafting_output = tdef._mcl_crafting_output
		if crafting_output and type(crafting_output) == "table" then
			for shape, defs in pairs(crafting_output) do
				if type(defs.output) == "string" and defs.output ~= "" then
					core.register_craft({
						output = defs.output,
						recipe = replace_material_tag(shapes[shape], tname),
						replacements = defs.replacements
					})
				end
			end
		end
	end
end

overwrite()

core.register_on_mods_loaded(function ()
	core.register_on_joinplayer(function(player)
		--attempt for this to be the last on_joinplayer function to be run
		mcl_player.players[player].joinplayer_done = true
	end)
end)
