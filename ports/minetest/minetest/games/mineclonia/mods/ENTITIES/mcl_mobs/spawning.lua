local pairs = pairs
local ipairs = ipairs

--lua locals
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local instant_despawn_range = 128
local random_despawn_range = 32

--do mobs spawn?
local mobs_spawn = core.settings:get_bool("mobs_spawn", true) ~= false
local logging = core.settings:get_bool("mcl_logging_mobs_spawn", false)

local function count_mobs_total(mob_type)
	local num = 0
	for _,l in pairs(core.luaentities) do
		if l.is_mob then
			if mob_type == nil or l.type == mob_type then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_all()
	local mobs_found = {}
	local num = 0
	for _,entity in pairs(core.luaentities) do
		if entity.is_mob then
			local mob_name = entity.name
			if entity._reloaded then
				mob_name = mob_name .. " (reloaded)"
			end
			if mobs_found[mob_name] then
				mobs_found[mob_name] = mobs_found[mob_name] + 1
			else
				mobs_found[mob_name] = 1
			end
			num = num + 1
		end
	end
	return mobs_found, num
end

function mcl_mobs.spawn_setup (def)
	local blurb = "[mcl_mobs]: An obsolete mob spawning definition is being registered for `%s'.  `%s' will not spawn naturally till its spawning configuration is updated to conform to the modern spawning API."
	core.log ("warning", string.format (blurb, def.name, def.name))
end

function mcl_mobs.spawn (pos, id, staticdata)
	core.log ("warning", "[mcl_mobs]: `mcl_mobs.spawn' is obsolete.  Use `core.add_entity' or `mcl_mobs.spawn_abnormally' instead.")
	return core.add_entity (pos, id, staticdata)
end

local S = core.get_translator ("mcl_mobs")

function mob_class:despawn_ok (d_to_closest_player)
	return true
end

function mob_class:despawn_allowed ()
	local nametag = self.nametag and self.nametag ~= ""
	if self.can_despawn == true then
		if not nametag and not self.tamed
			and not self.persistent
		-- _just_portaled mobs should not despawn to allow
		-- mapblocks containing them to be unloaded if no
		-- players are nearby.
			and not self._just_portaled
		-- Mobs that are attached to other objects should
		-- never despawn.
			and not self.object:get_attach () then
			return true
		end
	end
	return false
end

local scale_chance = mcl_mobs.scale_chance

function mob_class:check_despawn (pos, dtime)
	if self:despawn_allowed () then
		local min_dist = math.huge
		for player in mcl_util.connected_players () do
			min_dist = math.min (min_dist, vector.distance (player:get_pos (), pos))
		end

		if not self:despawn_ok (min_dist) then
			self._inactivity_timer = 0
			return false
		elseif min_dist > instant_despawn_range then
			self:kill_me ("no players within distance " .. instant_despawn_range)
			return true
		elseif min_dist > random_despawn_range then
			if self._inactivity_timer >= 30.0 then
				if math.random (1, scale_chance (800, dtime)) == 1 then
					self:kill_me ("random chance at distance " .. math.round(min_dist))
					return true
				end
			else
				local t = self._inactivity_timer + dtime

				-- This timer should be reset once a
				-- player approaches, or when damage
				-- is sustained from any source.
				self._inactivity_timer = t
			end

			return false
		end
	end
	return false
end

function mob_class:kill_me(msg)
	if logging then
		core.log("action", "[mcl_mobs] Mob " .. self.name .. " despawns at " .. core.pos_to_string(self.object:get_pos(), 1) .. ": " .. msg)
	end
	if self._jockey_rider then
		if is_valid (self._jockey_rider) then
			-- Detach this rider.
			local entity = self._jockey_rider:get_luaentity ()
			entity:unjock ()
			entity.jockey_vehicle = nil
		end
		self._jockey_rider = nil
	end
	self:safe_remove()
end

core.register_chatcommand("spawn_mob",{
	privs = { debug = true },
	description=S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly_in=air>::var<fly=true>:\n etc."),
	func = function(n,param)
		local pos = core.get_player_by_name(n):get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			table.insert(modifiers, ":"..capture)
		end

		local mod1 = string.find(param, ":")



		local mobname = param
		if mod1 then
			mobname = string.sub(param, 1, mod1-1)
		end

		local staticdata = core.serialize ({ persist_in_peaceful = true })
		local mob = core.add_entity (pos, mobname, staticdata)

		if mob then
			for c=1, #modifiers do
				local modifs = modifiers[c]

				local mod1 = string.find(modifs, ":")
				local mod_start = string.find(modifs, "<")
				local mod_vals = string.find(modifs, "=")
				local mod_end = string.find(modifs, ">")
				local mob_entity = mob:get_luaentity()
				if string.sub(modifs, mod1+1, mod1+3) == "var" then
					if mod1 and mod_start and mod_vals and mod_end then
						local variable = string.sub(modifs, mod_start+1, mod_vals-1)
						local value = string.sub(modifs, mod_vals+1, mod_end-1)

						local number_tag = string.find(value, "NUM")
						if number_tag then
							value = tonumber(string.sub(value, 4, -1)) ---@diagnostic disable-line: cast-local-type
						end

						if value == "true" then
							value = true ---@diagnostic disable-line: cast-local-type
						elseif value == "false" then
							value = false ---@diagnostic disable-line: cast-local-type
						end

						if not mob_entity[variable] then
							core.log("warning", n.." mob variable "..variable.." previously unset")
						end

						mob_entity[variable] = value

					else
						core.log("warning", n.." couldn't modify "..mobname.." at "..core.pos_to_string(pos).. ", missing paramaters")
					end
				else
					core.log("warning", n.." couldn't modify "..mobname.." at "..core.pos_to_string(pos).. ", missing modification type")
				end
			end

			core.log("action", n.." spawned "..mobname.." at "..core.pos_to_string(pos))
			return true, mobname.." spawned at "..core.pos_to_string(pos)
		else
			return false, "Couldn't spawn "..mobname
		end
	end
})

local SPAWN_DISTANCE = tonumber (core.settings:get ("active_block_range")) or 4
local MOB_CAP_DIVISOR = 289
local MOB_CAP_RECIPROCAL = 1 / MOB_CAP_DIVISOR
local OVERWORLD_CEILING_MARGIN = 64
local OVERWORLD_DEFAULT_CEILING = 256

-- Return a range of positions along the vertical axes in which to
-- spawn mobs around a player at POS in the dimension LEVEL.

local function level_y_range (level, pos)
	if level == "overworld" then
		local nodepos = math.floor (pos.y + 0.5)
		-- Spawn mobs between the bottom of the overworld and
		-- OVERWORLD_DEFAULT_CEILING.
		if nodepos < OVERWORLD_DEFAULT_CEILING - OVERWORLD_CEILING_MARGIN then
			return mcl_vars.mg_overworld_min, OVERWORLD_DEFAULT_CEILING
		else
			-- Otherwise spawn between nodepos - 236 and
			-- nodepos + 64.
			return nodepos
				- OVERWORLD_DEFAULT_CEILING
				+ OVERWORLD_CEILING_MARGIN
				+ mcl_vars.mg_overworld_min,
				nodepos + OVERWORLD_CEILING_MARGIN
		end
	elseif level == "nether" then
		return mcl_vars.mg_nether_min,
			mcl_vars.mg_nether_max - 1
	elseif level == "end" then
		return mcl_vars.mg_end_min,
			mcl_vars.mg_end_max_official - 1
	end
end

local function merge_range (rangearray, start, fin)
	local nmax, first_overlap, last_overlap = #rangearray
	local last_before = 0
	assert (nmax % 2 == 0)

	-- Locate the index of the final pairs whose start and end
	-- values precede START and FIN.
	for i = 1, nmax, 2 do
		if rangearray[i] < start then
			last_before = i + 1
		end
		if rangearray[i] <= fin and start <= rangearray[i + 1] then
			if not first_overlap then
				first_overlap = i
			end
			last_overlap = i
		end
	end

	if first_overlap then
		-- Fast case.
		if rangearray[first_overlap] == start
			and rangearray[last_overlap + 1] == fin then
			return
		end

		-- Consider first_overlap's start and last_overlap's fin.
		-- Combine them and all in between into a solitary range
		-- and adjust their bounds to encompass this one.

		if rangearray[first_overlap] > start then
			rangearray[first_overlap] = start
		end

		local value = rangearray[last_overlap + 1]
		-- Index of first element to preserve.
		local src_begin = last_overlap + 2
		-- New index after it is moved.
		local dst_begin = first_overlap + 2

		if src_begin ~= dst_begin then
			local num_copies = nmax - src_begin + 1
			for i = 0, num_copies - 1 do
				rangearray[dst_begin + i]
					= rangearray[src_begin + i]
			end
			-- Clear the remainder of the array
			-- (i.e. shrink it).
			for i = dst_begin + num_copies, nmax do
				rangearray[i] = nil
			end
		end
		rangearray[first_overlap + 1] = math.max (value, fin)
	else
		-- No ranges overlap.  Insert START, FIN into their
		-- proper position.
		local new_max = nmax + 2
		for i = 0, nmax - last_before - 1 do
			rangearray[new_max - i] = rangearray[nmax - i]
		end
		rangearray[last_before + 1] = start
		rangearray[last_before + 2] = fin
	end
	return rangearray
end

local function position_in_chunk (data)
	local total = 0
	local ranges = data.y_ranges
	local psize = #ranges
	for i = 1, psize, 2 do
		total = total + (ranges[i + 1] - ranges[i] + 1)
	end
	local value = math.random (1, total)
	for i = 1, psize, 2 do
		value = value - (ranges[i + 1] - ranges[i] + 1)
		if value <= 0 then
			return ranges[i + 1] + value
		end
	end
	-- Shouldn't ever be reached.
	assert (false)
end

local function collect_unique_chunks (level)
	local chunk_data, chunks, players = {}, {}, {}
	for player in mcl_util.connected_players () do
		-- Players outside any dimension should not be
		-- considered for spawning.
		local pos = player:get_pos ()
		local chunk_x = math.floor (pos.x / 16.0)
		local chunk_z = math.floor (pos.z / 16.0)
		local chunk_dim = mcl_worlds.pos_to_dimension (pos)
		players[player] = pos

		if chunk_dim == level then
			local start, fin = level_y_range (level, pos)

			for x = chunk_x - SPAWN_DISTANCE, chunk_x + SPAWN_DISTANCE do
				for z = chunk_z - SPAWN_DISTANCE, chunk_z + SPAWN_DISTANCE do
					local hash = ((x + 2048) * 4096) + (z + 2048)
					local data = chunk_data[hash]
					if not data then
						table.insert (chunks, hash)
						chunk_data[hash] = {
							y_ranges = {
								start, fin,
							},
						}
					else
						merge_range (data.y_ranges, start, fin)
					end
				end
			end
		end
	end
	return chunks, players, chunk_data
end

local function collect_all_unique_chunks ()
	local chunks = {}
	local n_chunks = 0

	chunks["overworld"] = { collect_unique_chunks ("overworld") }
	n_chunks = n_chunks + #chunks.overworld[1]
	chunks["nether"] = { collect_unique_chunks ("nether") }
	n_chunks = n_chunks + #chunks.nether[1]
	chunks["end"] = { collect_unique_chunks ("end") }
	n_chunks = n_chunks + #chunks["end"][1]
	return chunks, n_chunks
end

-- Chunk count from which to derive a number of mobs which, if
-- exceeded by overfulfillment of the mob caps, will induce reloaded
-- mobs immediately to despawn.
local spawn_border_chunks
local current_mob_caps = {}

core.register_chatcommand("mobstats",{
	privs = { debug = true },
	func = function(n, _)
		local mob_caps = {}
		local pos = core.get_player_by_name (n):get_pos ()
		local level = mcl_worlds.pos_to_dimension (pos)

		if level == "void" then
			local blurb = "No spawning data is available in the Void"
			core.chat_send_player (n, blurb)
			return
		end

		local _, n_chunks = collect_all_unique_chunks ()
		for category, data in pairs (mcl_mobs.spawn_categories) do
			local global_max
				= math.floor ((n_chunks * data.chunk_mob_cap)
					* MOB_CAP_RECIPROCAL)
			global_max = math.max (global_max, data.min_chunk_mob_cap)
			mob_caps[category] = global_max
		end

		core.chat_send_player (n, table.concat ({
			"Currently active mobs by category: ",
			dump (mcl_mobs.active_mobs_by_category),
			"\n",
			"Chunk-derived mob caps (per-level): ",
			dump (mob_caps), "\n",
			"Chunk count: ", tostring (n_chunks), "\n",
			"Mob cap overfulfillment theshold: ",
			tostring (spawn_border_chunks), "\n",
			"No. active mobs in total: ",
			tostring (count_mobs_total ()), "\n"
		}))

		local mob_counts, _ = count_mobs_all ()
		for k, v1 in pairs (mob_counts) do
			core.chat_send_player (n, table.concat ({
				"  ", k, ": ", tostring (v1),
			}))
		end
	end
})

------------------------------------------------------------------------
-- Modern spawning mechanics.
------------------------------------------------------------------------

local MAX_PACK_SIZE = 8

function mob_class:check_despawn_on_activation (self_pos)
	if not self:despawn_allowed ()
	-- New spawns (e.g. from infested blocks or mob spawners)
	-- should always be permitted.
		or not self._reloaded then
		return false
	end

	local category = self._spawn_category
	local caps = mcl_mobs.spawn_categories[category]

	-- Have mob caps been exceeded by a greater number of mobs
	-- than the previously established number of border blocks
	-- permit?

	if caps then
		local level = mcl_worlds.pos_to_dimension (self_pos)
		if level == "void" then
			return false
		end

		-- Mobs loaded before mob caps were first initialized.
		local global = current_mob_caps
		if not global or not spawn_border_chunks then
			core.log ("warning", self.name .. " was loaded before spawning "
				  .. "was initialized.")
			return false
		end

		local active = mcl_mobs.active_mobs_by_category[category]
		if active and active > global[category] then
			local border = spawn_border_chunks
			local buffer
				= math.floor ((caps.chunk_mob_cap * border)
					* MOB_CAP_RECIPROCAL)
			buffer = buffer + MAX_PACK_SIZE
			if active > buffer then
				if logging then
					core.log ("action", table.concat ({
						"[mcl_mobs] ", self.name,
						" at ", vector.to_string (self_pos),
						" is despawning as it is more than ",
						tostring (buffer), " mobs over the",
						" mob cap for `", category, "' (",
						tostring (global[category]), ")",
					}))
				end
				self.object:remove ()
				return true
			end
		end
	end
	return false
end

function mob_class:announce_for_spawning ()
	local category = self._spawn_category
	local n_active = mcl_mobs.active_mobs_by_category[category]
	if not n_active then
		n_active = 0
	end
	mcl_mobs.active_mobs_by_category[category] = n_active + 1
	self._activated = true
	local self_pos = self.object:get_pos ()
	return self:check_despawn_on_activation (self_pos)
end

function mob_class:remove_for_spawning ()
	self._activated = nil

	-- Record this mob's absence.
	local category = self._spawn_category
	local n_active = mcl_mobs.active_mobs_by_category[category]
	if not n_active or n_active <= 0 then
		return
	end
	mcl_mobs.active_mobs_by_category[category] = n_active - 1
end

function mob_class:update_mob_caps ()
	local persistent = (self.persistent or self.tamed)
	if self._activated and persistent then
		self:remove_for_spawning ()
	elseif not self._activated and not persistent then
		-- Value is whether this process prompted the mob to
		-- be deleted.
		return self:announce_for_spawning ()
	end
	return false
end

local active_mobs_by_category = {}
local registered_spawners = {}
local registered_structure_spawners = {}

-- This map between spawner lists and their total weight is rather
-- contrived but avoids the creation of combined hash tables/arrays,
-- which are NYIs in Luajit...
local total_weight = {}

mcl_mobs.active_mobs_by_category = active_mobs_by_category
mcl_mobs.registered_spawners = registered_spawners
mcl_mobs.registered_structure_spawners = registered_structure_spawners

-- https://nekoyue.github.io/ForgeJavaDocs-NG/javadoc/1.18.2/net/minecraft/world/entity/MobCategory.html

local spawn_categories = {
	["monster"] = {
		chunk_mob_cap = 70,
		min_chunk_mob_cap = 16,
		is_friendly = false,
		is_animal = false,
	},
	["creature"] = {
		chunk_mob_cap = 10,
		min_chunk_mob_cap = 10,
		is_friendly = false,
		is_animal = true,
	},
	["ambient"] = {
		chunk_mob_cap = 15,
		min_chunk_mob_cap = 5,
		is_friendly = true,
		is_animal = false,
	},
	["axolotl"] = {
		chunk_mob_cap = 5,
		min_chunk_mob_cap = 5,
		is_friendly = true,
		is_animal = false,
	},
	["underground_water_creature"] = {
		chunk_mob_cap = 5,
		min_chunk_mob_cap = 5,
		is_friendly = true,
		is_animal = false,
	},
	["water_creature"] = {
		chunk_mob_cap = 5,
		min_chunk_mob_cap = 5,
		is_friendly = true,
		is_animal = false,
	},
	["water_ambient"] = {
		chunk_mob_cap = 5,
		min_chunk_mob_cap = 5,
		is_friendly = true,
		is_animal = false,
	},
}
mcl_mobs.spawn_categories = spawn_categories

local NUM_MONSTER_CATEGORIES = 6
local NUM_CREATURE_CATEGORIES = 1

local function dist_sqr (a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	return dx * dx + dy * dy + dz * dz
end

-- local function horiz_dist_sqr (ax, az, bx, bz)
-- 	local dx = bx - ax
-- 	local dz = bz - az
-- 	return dx * dx + dz * dz
-- end

local function get_nearest_player (pos, list)
	local dist, pos_nearest, player = nil

	for player_1, test_pos in pairs (list) do
		local d = dist_sqr (test_pos, pos)
		if not dist or dist > d then
			dist = d
			pos_nearest = test_pos
			player = player_1
		end
	end

	return player, pos_nearest
end

local function get_weighted_value (mob_types)
	if total_weight[mob_types] > 0 then
		local weight = math.random (total_weight[mob_types])
		for _, spawner in ipairs (mob_types) do
			weight = weight - spawner.weight
			if weight <= 0 then
				return spawner
			end
		end
	end
	return nil
end

local get_biome_name_nosample = mcl_biome_dispatch.get_biome_name_nosample
local get_structures_at = mcl_levelgen.get_structures_at

local function structure_override (pos, category)
	local structures = get_structures_at (pos, false)
	for _, structure in pairs (structures) do
		local list = registered_structure_spawners[structure.data]
		if list and list[category] then
			return list[category]
		end
	end
	return nil
end

local function get_eligible_spawn_type (pos, category)
	local override = structure_override (pos, category)
	if override then
		return get_weighted_value (override)
	end
	local value
	local spawners = registered_spawners[get_biome_name_nosample (pos)]
	if spawners then
		-- XXX: reduce chances of spawning ambient water
		-- creatures in rivers if possible.
		local mob_types = spawners[category]
		if mob_types then
			value = get_weighted_value (mob_types)
		end
	end
	return value
end

local function test_spawn_position (mob_def, spawn_pos, node_pos, sdata, node_cache,
				    spawn_flag)
	local value = mob_def:test_spawn_position (spawn_pos, node_pos, sdata,
						   node_cache, spawn_flag)
	return value
end

local function test_spawn_clearance (mob_def, spawn_pos, sdata)
	local value = mob_def:test_spawn_clearance (spawn_pos, sdata)
	return value
end

local is_position_completely_generated = mcl_mobs.is_position_completely_generated
local spawn_proto_chunk_blurb
	= "[mcl_mobs] Declining to spawn mob %s in proto-chunk at (%d,%d,%d)"

local function test_generation (pos, mob_def)
	if not core.compare_block_status (pos, "active") then
		return false
	elseif is_position_completely_generated (pos) then
		return true
	elseif logging then
		local msg = string.format (spawn_proto_chunk_blurb,
					   mob_def.name, pos.x, pos.y, pos.z)
		core.log ("action", msg)
	end
	return false
end

local function spawn_a_pack (pos, players, category, scratch0,
			     existing, global_max)
	local player, player_pos = get_nearest_player (pos, players)
	assert (player and player_pos)

	local mob_def = get_eligible_spawn_type (pos, category)
	if not mob_def then
		return
	end
	local pack_size = math.random (mob_def.pack_min, mob_def.pack_max)

	local sdata = mob_def:prepare_to_spawn (pack_size, pos)
	local x, y, z = pos.x, pos.y, pos.z
	local spawn_pos = scratch0
	spawn_pos.y = y - 0.5

	local n_spawned, spawned = 0, mob_def.init_group and {}
	for i = 1, pack_size do
		local dx = math.random (0, 5) - math.random (0, 5)
		local dz = math.random (0, 5) - math.random (0, 5)
		spawn_pos.x = x + dx
		spawn_pos.z = z + dz
		pos.x = x + dx
		pos.z = z + dz
		local dist = dist_sqr (player_pos, spawn_pos)

		-- Is it possible to spawn mobs here?
		if dist < mob_def.despawn_distance_sqr
			and dist > 576.0
			and test_spawn_position (mob_def, spawn_pos, pos, sdata, {}, nil)
			and test_spawn_clearance (mob_def, spawn_pos, sdata)
			and test_generation (pos, mob_def) then
			local object = mob_def:spawn (spawn_pos, n_spawned + 1, sdata)
			if object then
				n_spawned = n_spawned + 1
				if spawned then
					spawned[n_spawned] = object
				end
			end
		end
	end
	if logging and n_spawned > 0 then
		if n_spawned == 1 then
			local blurb = "[mcl_mobs] Spawned "
				.. mob_def.name .. " at "
				.. vector.to_string (spawn_pos)
				.. " (" .. existing .. " / "
				.. global_max .. "; category = "
				.. category .. ")"
			core.log ("action", blurb)
		else
			local blurb = "[mcl_mobs] Spawned pack of "
				.. n_spawned .. " ".. mob_def.name
				.. " around " .. vector.to_string (pos)
				.. " (" .. existing .. " / "
				.. global_max .. "; category = "
				.. category .. ")"
			core.log ("action", blurb)
		end
	end
	if n_spawned > 0 and mob_def.init_group then
		mob_def:init_group (spawned, sdata)
	end
end

local function unpack3 (x)
	return x[1], x[2], x[3]
end

function mcl_mobs.spawn_cycle (level, chunks, n_chunks, spawn_animals)
	local scratch0 = vector.zero ()

	-- Collect a list of chunks to evaluate for purposes of
	-- spawning.
	local chunks, players, chunk_data = unpack3 (chunks[level])
	local mobs_spawned = {}

	-- Shuffle the list of chunks to be evaluated.
	table.shuffle (chunks)

	local test_pos = vector.zero ()
	local n_chunks_orig = n_chunks

	-- Divide the number of chunks to be evaluated by the number
	-- of eligible categories.
	local num_categories = NUM_CREATURE_CATEGORIES
	if not spawn_animals then
		num_categories = NUM_MONSTER_CATEGORIES
	end

	-- Calculate mob caps and cache them in current_mob_caps.
	local caps = current_mob_caps

	for category, data in pairs (spawn_categories) do
		local mob_cap = data.chunk_mob_cap
		-- Verify that global mob caps have not been exceeded.
		local global_max
			= math.floor ((n_chunks_orig * mob_cap)
				* MOB_CAP_RECIPROCAL)
		-- Although the number of chunks loaded by default is
		-- smaller than in Minecraft, yet this disparity
		-- renders it almost impossible for certain animals to
		-- spawn.  A lower bound is placed on their mob caps
		-- to address this.
		global_max = math.max (global_max, data.min_chunk_mob_cap)
		caps[category] = global_max
	end

	local n_chunks = math.ceil (#chunks / num_categories)
	for i = 1, n_chunks do
		local chunk = chunks[i]
		local x = math.floor (chunk / 4096) - 2048
		local z = chunk % 4096 - 2048
		local center_x = (x * 16) + 7.5
		local center_z = (z * 16) + 7.5
		local eligible = false

		-- Is any player within 128 blocks of this chunk
		-- horizontally?
		for _, pos in pairs (players) do
			local dist = (pos.x - center_x) * (pos.x - center_x)
				+ (pos.z - center_z) * (pos.z - center_z)
			if dist < 16384.0 then
				eligible = true
				break
			end
		end

		if eligible then
			for key, _ in pairs (spawn_categories) do
				mobs_spawned[key] = active_mobs_by_category[key] or 0
			end
			for category, existing in pairs (mobs_spawned) do
				local data = spawn_categories[category]
				if (data.is_animal and spawn_animals)
					or (not data.is_animal and not spawn_animals) then
					local global_max = caps[category]
					-- Verify that global mob caps
					-- have not been exceeded.
					if existing < global_max then
						-- Select a random position.
						test_pos.x = math.random (x * 16, x * 16 + 15)
						test_pos.z = math.random (z * 16, z * 16 + 15)
						test_pos.y = position_in_chunk (chunk_data[chunk])
						spawn_a_pack (test_pos, players, category, scratch0,
							      existing, global_max)
					end
				end
			end
		end
	end
end

local default_spawner = {
	weight = 100,
	biomes = {},
	structures = {},
	despawn_distance_sqr = 128 * 128,
	spawn_placement = "ground", -- misc, ground, aquatic, lava
	spawn_category = "misc", -- Should be identical to that of the
				 -- mob def.
	fire_immune = false,
	pack_min = 4,
	pack_max = 4,
	is_canonical = false, 	-- If true, this is the only spawner
				-- that will be invoked by
				-- `mcl_mobs.spawn_abnormally'.
}

local spawners_initialized = false
local canonical_spawners = {}
local ordinary_spawners = {}

function mcl_mobs.register_spawner (spawner)
	if spawners_initialized then
		error ("mcl_mobs.register_spawner mustn't be called "
		       .. "after mod initialization")
	end
	local spawner = table.merge (default_spawner, spawner)
	table.insert (registered_spawners, spawner)

	if spawner.is_canonical then
		canonical_spawners[spawner.name] = spawner
	else
		if not ordinary_spawners[spawner.name] then
			ordinary_spawners[spawner.name] = {}
		end
		table.insert (ordinary_spawners[spawner.name], spawner)
	end
end

function mcl_mobs.suppress_spawning_in_structure (structure, category)
	if not registered_structure_spawners[structure] then
		registered_structure_spawners[structure] = {}
	end
	local data = registered_structure_spawners[structure]
	if not data[category] then
		data[category] = {}
		total_weight[data[category]] = 0
	end
end

mcl_mobs.default_spawner = default_spawner

-- Convert this table into a map between biome IDs, structures, and
-- spawners once all biomes are registered.

core.register_on_mods_loaded (function ()
	local output = {}
	local n = #registered_spawners
	for i = 1, n do
		local spawner = registered_spawners[i]
		local biomes = mcl_biome_dispatch.build_biome_list (spawner.biomes)
		local biome_test = mcl_biome_dispatch.make_biome_test (spawner.biomes)
		spawner.internal_biome_dest = biome_test
		for _, id in ipairs (biomes) do
			if not output[id] then
				output[id] = {}
			end

			if not output[id][spawner.spawn_category] then
				output[id][spawner.spawn_category] = {}
			end

			local list = output[id][spawner.spawn_category]
			total_weight[list] = (total_weight[list] or 0) + spawner.weight
			table.insert (list, spawner)
		end

		for _, structure in ipairs (spawner.structures) do
			if not registered_structure_spawners[structure] then
				registered_structure_spawners[structure] = {}
			end
			local data = registered_structure_spawners[structure]
			if not data[spawner.spawn_category] then
				data[spawner.spawn_category] = {}
			end
			local list = data[spawner.spawn_category]
			total_weight[list] = (total_weight[list] or 0) + spawner.weight
			table.insert (list, spawner)
		end
	end

	spawners_initialized = true
	registered_spawners = output
	mcl_mobs.registered_spawners = registered_spawners
end)

------------------------------------------------------------------------
-- Default spawning criteria.
------------------------------------------------------------------------

function mob_class:is_up_face_sturdy (pos)
	local node = core.get_node (pos)
	return mcl_mobs.is_up_face_sturdy (pos, node)
end

local cube = mcl_util.decompose_AABBs ({{
	-0.5, -0.5, -0.5,
	0.5, 0.5, 0.5,
}})
local up_face_sturdy = {}

core.register_on_mods_loaded (function ()
	for node, def in pairs (core.registered_nodes) do
		local node_type = def.paramtype2
		if not def.walkable
			or node_type == "flowingliquid" then
			up_face_sturdy[node] = false
		elseif node_type == "4dir"
			or node_type == "degrotate"
			or node_type == "color4dir"
			or node_type == "color"
			or node_type == "colordegrotate"
			or node_type == "none" then
			local boxes = def.node_box

			if not boxes or boxes.type == "regular" then
				up_face_sturdy[node] = true
			elseif boxes.type == "fixed" then
				-- Since these node types can only
				-- rotate around the Y axis, it is
				-- only necessary to verify that their
				-- up faces are full cubes.

				local fixed = boxes.fixed
				if fixed and type (fixed[1]) == "number" then
					fixed = {fixed}
				end
				local shape = mcl_util.decompose_AABBs (fixed)
				local face = shape:select_face ("y", 0.5)
				up_face_sturdy[node] = face:equal_p (cube)
			end
		else
			-- Only full cubes can be sturdy once rotation
			-- around other axes is involved.
			local boxes = def.node_box

			if not boxes or boxes.type == "regular" then
				up_face_sturdy[node] = true
			elseif boxes.type == "fixed" then
				-- Since these node types can only
				-- rotate around the Y axis, it is
				-- only necessary to verify that their
				-- up faces are full cubes.

				local fixed = boxes.fixed
				if fixed and type (fixed[1]) == "number" then
					fixed = {fixed}
				end
				local shape = mcl_util.decompose_AABBs (fixed)
				if shape:equal_p (cube) then
					up_face_sturdy[node] = true
				end
			end
		end
	end
end)

function mcl_mobs.is_up_face_sturdy (node, node_data)
	local sturdy = up_face_sturdy[node_data.name]
	if sturdy ~= nil then
		return sturdy
	end
	local boxes = core.get_node_boxes ("collision_box", node)
	local shape = mcl_util.decompose_AABBs (boxes)
	local up_face = shape and shape:select_face ("y", 0.5)
	return up_face and up_face:equal_p (cube)
end

function default_spawner:is_valid_spawn_ceiling (name)
	local def = core.registered_nodes[name]
	if name == "ignore"
		or not def
		or (def.walkable or def.liquidtype ~= "none")
		or (def.groups.no_spawning_inside
			and def.groups.no_spawning_inside ~= 0)
		or (def.damage_per_second > 0)
		or (not self.fire_immune
			and def.groups.fire
			and def.groups.fire ~= 0)
		or (not self.fire_immune
			and def.groups.lava
			and def.groups.lava ~= 0) then
		return false
	end
	return true
end

function default_spawner:get_node (node_cache, y_offset, base)
	local cache = node_cache[y_offset]
	if not cache then
		base.y = base.y + y_offset
		cache = core.get_node (base)
		node_cache[y_offset] = cache
		base.y = base.y - y_offset
	end
	return cache
end

-- Implementors may modified and/or reuse node_pos as a scratch value,
-- provided that they restore its original values before calling the
-- default test_spawn_position implementation.

function default_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					      spawn_flag)
	local spawn_placement = self.spawn_placement
	if spawn_placement == "misc"
		or (spawn_placement == "ground" and spawn_flag == "spawner") then
		-- Just test that the position is loaded.
		return core.compare_block_status (node_pos, "active")
	elseif spawn_placement == "ground" then
		local node_below = self:get_node (node_cache, -1, node_pos)
		if core.get_item_group (node_below.name, "opaque") == 0
			or node_below.name == "mcl_core:bedrock" then
			return false
		end
		-- The up face of the supporting node must be sturdy.
		if node_below.name == "mcl_nether:soul_sand"
			or mcl_mobs.is_up_face_sturdy (node_pos, node_below) then
			-- The block here and the block above must not
			-- be opaque nor deal damage.
			local node_here = self:get_node (node_cache, 0, node_pos)
			local node_above = self:get_node (node_cache, 1, node_pos)

			return self:is_valid_spawn_ceiling (node_here.name)
				and self:is_valid_spawn_ceiling (node_above.name)
		end
		return false
	elseif spawn_placement == "aquatic" then
		local node = self:get_node (node_cache, 0, node_pos)
		if core.get_item_group (node.name, "water") > 0 then
			local above = self:get_node (node_cache, 1, node_pos)
			return core.get_item_group (above.name, "opaque") == 0
		end
		return false
	elseif spawn_placement == "lava" then
		local node = self:get_node (node_cache, 0, node_pos)
		if core.get_item_group (node.name, "lava") > 0 then
			return true
		end
	end
	return false
end

local function box_intersection (box, other_box)
	for index = 1, 3 do
		if box[index] > other_box[index + 3]
			or other_box[index] > box[index + 3] then
			return false
		end
	end
	return true
end

function default_spawner:test_collision (node, cbox)
	local node_data = core.get_node (node)
	if node_data.name == "ignore" then
		return true
	end
	local def = core.registered_nodes[node_data.name]

	if def and not def.walkable
		and ((self.spawn_placement == "aquatic"
			or self.spawn_placement == "lava")
			or def.liquidtype == "none"
			-- Cobwebs are defined as liquids solely in
			-- order to retard player movement.
			or node.name == "mcl_core:cobweb") then
		return false
	end

	local boxes
		= core.get_node_boxes ("collision_box", node, node_data)
	for _, box in pairs (boxes) do
		box[1] = box[1] + node.x
		box[2] = box[2] + node.y
		box[3] = box[3] + node.z
		box[4] = box[4] + node.x
		box[5] = box[5] + node.y
		box[6] = box[6] + node.z

		if box_intersection (box, cbox) then
			return true
		end
	end
	return false
end

function default_spawner:test_spawn_clearance (spawn_pos, sdata)
	local mob_def = core.registered_entities[self.name]
	if not mob_def then
		return false
	end
	local cbox = mob_def.initial_properties.collisionbox
	if not cbox then
		return false
	end

	local cbox_1 = {
		cbox[1] + spawn_pos.x + 0.01,
		cbox[2] + spawn_pos.y + 0.01,
		cbox[3] + spawn_pos.z + 0.01,
		cbox[4] + spawn_pos.x - 0.01,
		cbox[5] + spawn_pos.y - 0.01,
		cbox[6] + spawn_pos.z - 0.01,
	}
	local xmin = math.floor (cbox_1[1] + 0.5)
	local ymin = math.floor (cbox_1[2] + 0.5)
	local zmin = math.floor (cbox_1[3] + 0.5)
	local xmax = math.floor (cbox_1[4] + 0.5)
	local ymax = math.floor (cbox_1[5] + 0.5)
	local zmax = math.floor (cbox_1[6] + 0.5)
	local v = vector.zero ()

	for z = zmin, zmax do
		v.z = z
		for x = xmin, xmax do
			v.x = x
			for y = ymin, ymax do
				v.y = y
				if self:test_collision (v, cbox_1) then
					return false
				end
			end
		end
	end
	return true
end

function default_spawner:spawn (spawn_pos, idx, sdata, pack_size)
	local staticdata = sdata and core.serialize (sdata)
	return core.add_entity (spawn_pos, self.name, staticdata)
end

function default_spawner:prepare_to_spawn (pack_size, center)
	return nil
end

function default_spawner:describe_mob_collision_box ()
	local mob_def = core.registered_entities[self.name]
	if not mob_def then
		return false
	end
	local cbox = mob_def.initial_properties.collisionbox
	if not cbox then
		return false
	end
	return string.format ("%.2f,%.2f,%.2f", cbox[4] - cbox[1],
			      cbox[5] - cbox[2], cbox[6] - cbox[3])
end

function default_spawner:get_misc_spawning_description ()
	return nil
end

function default_spawner:describe_additional_spawning_criteria ()
	return nil
end

function default_spawner:describe_criteria (tbl, omit_group_details)
	local tbl1 = {}
	local desc = self:get_misc_spawning_description ()
	if desc then
		tbl1[1] = desc
	elseif self.spawn_placement == "ground" then
		tbl1[1] = S ("This mob will spawn on solid and opaque nodes with a surface occupying a full node when no obstructions exist within a volume @1 nodes in size around the center of such a node's upper surface.",
			     self:describe_mob_collision_box ())
	elseif self.spawn_placement == "aquatic" then
		tbl1[1] = S ("This mob will spawn in water when the node above is not opaque and no obstructions exist within a volume @1 nodes in size around the center of the base of the fluid node in question.",
			     self:describe_mob_collision_box ())
	elseif self.spawn_placement == "lava" then
		tbl1[1] = S ("This mob will spawn on flowing lava and lava sources when no liquid or solid obstructions exist within a volume @1 nodes in size.",
			     self:describe_mob_collision_box ())
	else
		tbl1[1] = S ("This mob does not document its spawning requirements.")
	end
	local addendum = self:describe_additional_spawning_criteria ()
	if addendum then
		table.insert (tbl1, addendum)
	end
	if not omit_group_details then
		if self.pack_min == 1 and self.pack_max == 1 then
			tbl1[#tbl1 + 1] = S ("Mobs will spawn in individual groups of 1.")
		elseif self.pack_min == self.pack_max then
			tbl1[#tbl1 + 1] = S ("Up to @1 mobs will spawn as a single group upon each spawning attempt.", self.pack_min)
		else
			tbl1[#tbl1 + 1] = S ("A group of @1 to @2 mobs will attempt to be spawned upon each spawning attempt.", self.pack_min, self.pack_max)
		end
	end
	table.insert (tbl, table.concat (tbl1, "  "))
end

if mobs_spawn then

local spawn_timer = 0
local passive_spawn_timer = 0

core.register_globalstep (function (dtime)
	spawn_timer = spawn_timer - dtime
	passive_spawn_timer = passive_spawn_timer - dtime
	local chunks, n_chunks = collect_all_unique_chunks ()

	-- Calculate the number of chunks bordering this list of
	-- chunks as if it were a single rectangle.
	spawn_border_chunks
		= (math.floor (math.sqrt (n_chunks)) + 1) * 4

	if spawn_timer <= 0 then
		mcl_mobs.spawn_cycle ("overworld", chunks, n_chunks, false)
		mcl_mobs.spawn_cycle ("nether", chunks, n_chunks, false)
		mcl_mobs.spawn_cycle ("end", chunks, n_chunks, false)
		spawn_timer = 0.05
	end
	if passive_spawn_timer <= 0 then
		mcl_mobs.spawn_cycle ("overworld", chunks, n_chunks, true)
		mcl_mobs.spawn_cycle ("nether", chunks, n_chunks, true)
		mcl_mobs.spawn_cycle ("end", chunks, n_chunks, true)
		passive_spawn_timer = 10.0
	end
end)

end

------------------------------------------------------------------------
-- Spawn testing utilities.
------------------------------------------------------------------------

local function evaluate_node_properties (itemstack, user, pointed_thing)
	if not (user and user:is_player ()) then
		return
	end
	local playername = user:get_player_name ()
	if pointed_thing.type == "node" then
		local node = core.get_node (pointed_thing.under)
		core.chat_send_player (playername, table.concat ({
			"Node: ", node.name, "\n",
			"Up face sturdy: ",
			tostring (mcl_mobs.is_up_face_sturdy (pointed_thing.under, node)),
		}))

		local spawn_pos = vector.offset (pointed_thing.under, 0, 0.5, 0)
		local zombie_spawner = table.merge (default_spawner, {
			name = "mobs_mc:zombie",
		})
		core.chat_send_player (playername, table.concat ({
			"Zombie clearance tests pass? ",
			tostring (zombie_spawner:test_spawn_clearance (spawn_pos, {})),
			"\n",
		}))
	end
end

core.register_tool ("mcl_mobs:spawn_stick", {
	description = "Evaluate node properties",
	inventory_image = "default_stick.png^[colorize:purple:50",
	groups = { testtool = 1, disable_repair = 1,
		   not_in_creative_inventory = 1, },
	on_use = evaluate_node_properties,
})

core.register_chatcommand ("spawn_cycle", {
	privs = { server = true, },
	params = "[ end | overworld | nether ]",
	func = function (n, param)
		mcl_mobs.spawn_cycle (param)
		mcl_mobs.spawn_cycle (param, true)
	end,
})

local function sort_by_weight_dsc (a, b)
	if b.weight < a.weight then
		return true
	elseif b.weight > a.weight then
		return false
	else
		return b.name < a.name
	end
end

core.register_chatcommand ("dump_spawners", {
	privs = { debug = true, },
	params = "[<biome>]",
	func = function (player, param)
		local player = core.get_player_by_name (player)
		if not player then
			return false
		end

		local pos = mcl_util.get_nodepos (player:get_pos ())
		local param = param:trim ()
		local biome_name = #param > 0 and param
			or mcl_biome_dispatch.get_biome_name (pos)
		local tbl = registered_spawners[biome_name]

		if not tbl then
			return false
		end

		print (";; Registered spawners in biome `" .. biome_name .. "'")
		for category, list in pairs (tbl) do
			local total_weight = total_weight[list] or -1
			local mobs_by_weight = {}
			local entry_by_mob = {}

			for _, spawner in ipairs (list) do
				local mob = spawner.name

				if not entry_by_mob[mob] then
					entry_by_mob[mob] = {
						name = mob,
						weight = spawner.weight,
						spawners = {spawner},
					}
					table.insert (mobs_by_weight, entry_by_mob[mob])
				else
					local entry = entry_by_mob[mob]
					entry.weight = entry.weight + spawner.weight
					table.insert (entry.spawners, spawner)
				end
			end

			print (string.format ("  ;; Category: %s, total weight: %d",
					      category, total_weight))
			table.sort (mobs_by_weight, sort_by_weight_dsc)
			for _, entry in ipairs (mobs_by_weight) do
				print (string.format ("    ;; Mob: %s: weight: %d", entry.name,
						      entry.weight))
				table.sort (entry.spawners, sort_by_weight_dsc)
				for _, spawner in ipairs (entry.spawners) do
					print (string.format ("    ;;  weight: %d pack_min, pack_max: %d, %d",
							      spawner.weight, spawner.pack_min,
							      spawner.pack_max))
				end
				print ("")
			end
		end
		return true, S ("Dumped spawners for biome: @1", biome_name)
	end,
})

------------------------------------------------------------------------
-- Manual spawning API.
------------------------------------------------------------------------

local function get_mob_spawner_at_pos (mob, pos)
	if canonical_spawners[mob] then
		return canonical_spawners[mob]
	end

	local spawners = ordinary_spawners[mob]
	if spawners then
		-- First search for an overriding structure spawner.
		local structures = get_structures_at (pos, false)
		for _, structure in pairs (structures) do
			for _, spawner in ipairs (spawners) do
				if table.indexof (spawner.structures, structure) ~= -1 then
					return spawner
				end
			end
		end

		-- Next, search for a spawner which applies to the biome at
		-- POS.
		local biome = get_biome_name_nosample (pos)
		for _, spawner in ipairs (spawners) do
			if spawner.internal_biome_dest (biome) then
				return spawner
			end
		end

		-- And in extremis, just return the first registered
		-- spawner.
		return spawners[1]
	end
end

-- Spawn an instance of MOB at POS (a node position) independently of
-- the ordinary course of environmental mob spawning, applying
-- spawning criteria enforced by its mob spawning definitions, such as
-- the absence of collisions, and minimum or maximum light level
-- requirements.  Value is the object if spawning is successful, nil
-- otherwise.  SDATA is a table of parameters which is provided to the
-- mob's spawning procedure.  SPAWN_FLAG is nil, or a string
-- designating the source from which this mob is spawning, which is
-- provided to each spawning definition's `test_spawn_position'
-- method.

local warned = {}
function mcl_mobs.spawn_abnormally (pos, mob, sdata, spawn_flag)
	local spawner = get_mob_spawner_at_pos (mob, pos)
	if not spawner then
		if not warned[mob] then
			local spawner = "[mcl_mobs]: Can't decide how to spawn "
				.. mob .. " at " .. vector.to_string (pos)
			core.log ("warning", spawner)
			warned[mob] = true
		end
		return nil
	end

	local spawn_pos = vector.new (pos.x, pos.y - 0.5, pos.z)
	if test_spawn_position (spawner, spawn_pos, pos, sdata, {},
				spawn_flag)
		and test_spawn_clearance (spawner, spawn_pos, sdata)
		and test_generation (pos, spawner) then
		local object = spawner:spawn (spawn_pos, 0, sdata)
		return object
	end

	return nil
end

function mcl_mobs.spawning_possible (pos, mob, sdata, spawn_flag)
	local spawner = get_mob_spawner_at_pos (mob, pos)
	if not spawner then
		if not warned[mob] then
			local spawner = "[mcl_mobs]: Can't decide how to spawn "
				.. mob .. " at " .. vector.to_string (pos)
			core.log ("warning", spawner)
			warned[mob] = true
		end
		return nil
	end

	local spawn_pos = vector.new (pos.x, pos.y - 0.5, pos.z)
	return test_spawn_position (spawner, spawn_pos, pos, sdata, {},
				    spawn_flag)
		and test_spawn_clearance (spawner, spawn_pos, sdata)
		and test_generation (pos, spawner)
end

function mcl_mobs.describe_spawning (mob)
	local tbl = {
		S ("Environmental spawning requirements and mechanics:"),
	}

	if canonical_spawners[mob] then
		table.insert (tbl, S ("\nWhen spawned from spawner:"))
		canonical_spawners[mob]:describe_criteria (tbl, true)
	elseif ordinary_spawners[mob]and ordinary_spawners[mob][1] then
		table.insert (tbl, S ("\nWhen spawned from spawner:"))
		ordinary_spawners[mob][1]:describe_criteria (tbl, true)
	else
		table.insert (tbl, S ("\nMob does not spawn environmentally."))
	end

	if ordinary_spawners[mob] then
		for _, spawner in ipairs (ordinary_spawners[mob]) do
			if #spawner.biomes > 0 then
				table.insert (tbl, S ("\nWhen spawned in biome(s): "))
				table.insert (tbl, table.concat (spawner.biomes, ", "))
			end

			if #spawner.structures > 0 then
				if #spawner.biomes > 0 then
					table.insert (tbl, S ("and when spawned in structure(s): "))
				else
					table.insert (tbl, S ("\nWhen spawned in structure(s): "))
				end
				table.insert (tbl, table.concat (spawner.structures, ", "))
			end

			spawner:describe_criteria (tbl, false)
		end
	end

	return table.concat (tbl, "\n")
end
