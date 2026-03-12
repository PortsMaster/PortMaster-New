local pairs = pairs
local insert = table.insert

------------------------------------------------------------------------
-- Data initialization.  This extracts information that is only
-- available within async or emerge threads and provides the same to
-- the main thread.
------------------------------------------------------------------------

if core.ipc_cas ("mcl_biome_dispatch:async_initialized", nil, true) then
	local biomes_and_tags = {}
	local groups_seen = {}

	for name, def in pairs (mcl_levelgen.registered_biomes) do
		table.insert (biomes_and_tags, name)
		for group, value in pairs (def.groups) do
			if not groups_seen[group] then
				groups_seen[group] = true
				insert (biomes_and_tags, "#" .. group)
			end
		end
	end

	local structures = {}
	for name, _ in pairs (mcl_levelgen.registered_structures) do
		insert (structures, name)
	end

	table.sort (biomes_and_tags)
	table.sort (structures)
	core.ipc_set ("mcl_biome_dispatch:registered_biomes_and_groups",
		      biomes_and_tags)
	core.ipc_set ("mcl_biome_dispatch:registered_structures",
		      structures)
end
