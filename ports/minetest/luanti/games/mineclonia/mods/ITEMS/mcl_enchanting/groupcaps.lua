local groupcaps_cache = {}

-- Compute a hash value.
function compute_hash(value)
	return string.sub(core.sha1(core.serialize(value)), 1, 8)
end

-- Get the groupcaps and hash for an enchanted tool.  If this function is called
-- repeatedly with the same values it will return data from a cache.
--
-- Parameters:
-- toolname - Name of the tool
-- level - The efficiency level of the tool
--
-- Returns a table with the following two fields:
-- values - The groupcaps table
-- hash - The hash of the groupcaps table
local function get_efficiency_groupcaps(toolname, level)
	local toolcache = groupcaps_cache[toolname]
	local level = level

	if not toolcache then
		toolcache = {}
		groupcaps_cache[toolname] = toolcache
	end

	local levelcache = toolcache[level]
	if not levelcache then
		levelcache = {}
		levelcache.values = mcl_autogroup.get_groupcaps(toolname, level)
		levelcache.hash = compute_hash(levelcache.values)
		toolcache[level] = levelcache
	end

	return levelcache
end

-- Update groupcaps of an enchanted tool.  This function will be called
-- repeatedly to make sure the digging times stored in groupcaps stays in sync
-- when the digging times of nodes can change.
--
-- To make it more efficient it will first check a hash value to determine if
-- the tool needs to be updated.
--
-- IGNORE_HASH means to ignore the hash so that values may be
-- overwritten when they have received alterations from elsewhere,
-- e.g., haste/fatigue effects.
function mcl_enchanting.update_groupcaps(itemstack, ignore_hash)
	local name = itemstack:get_name()
	if not core.registered_tools[name] or not core.registered_tools[name].tool_capabilities then
		return
	end

	local efficiency = mcl_enchanting.get_enchantment(itemstack, "efficiency")
	local unbreaking = mcl_enchanting.get_enchantment(itemstack, "unbreaking")
	if unbreaking == 0 and efficiency == 0 then
		return
	end

	local groupcaps = get_efficiency_groupcaps(name, efficiency)
	local hash = itemstack:get_meta():get_string("groupcaps_hash")

	if ignore_hash or not hash or hash ~= groupcaps.hash then
		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.groupcaps = table.copy(groupcaps.values)

		-- Increase the number of uses depending on the unbreaking level
		-- of the tool.
		for _, capability in pairs(tool_capabilities.groupcaps) do
			capability.uses = capability.uses * (1 + unbreaking)
		end

		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
		itemstack:get_meta():set_string("groupcaps_hash", groupcaps.hash)
	end
end
