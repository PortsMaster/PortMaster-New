-- mcl_raids
local S = core.get_translator(core.get_current_modname())
mcl_raids = {}

local oban_layers = {
	{
		pattern = "rhombus",
		color = "unicolor_cyan"
	},
	{
		color = "unicolor_grey",
		pattern = "stripe_bottom"
	},
	{
		pattern = "stripe_center",
		color = "unicolor_darkgrey"
	},
	{
		color = "unicolor_black",
		pattern = "stripe_middle"
	},
	{
		pattern = "half_horizontal",
		color = "unicolor_grey"
	},
	{
		color = "unicolor_grey",
		pattern = "circle"
	},
	{
		pattern = "border",
		color = "unicolor_black"
	}
}

mcl_raids.ominous_banner_name = S("Ominous Banner")
mcl_raids.ominous_banner_layers = oban_layers

local oban_def = table.copy(core.registered_entities["mcl_banners:standing_banner"])
oban_def.initial_properties.visual_size = { x=1, y=1 }
local old_step = oban_def.on_step
oban_def.on_step = function(self)
	if not self.object:get_attach() then return self.object:remove() end
	if old_step then return old_step(self.dtime) end
end

core.register_entity(":mcl_raids:ominous_banner",oban_def)

function mcl_raids.drop_obanner(pos)
	local it = ItemStack("mcl_banners:banner_item_white")
	mcl_banners.write_layers(it:get_meta(), oban_layers)
	tt.reload_itemstack_description(it)
	core.add_item(pos,it)
end

function mcl_raids.is_banner_item (stack, layers)
	local name = stack:get_name ()
	if name ~= "mcl_banners:banner_item_white" then return false end
	if not layers then
		local metadata = stack:get_meta ()
		layers = mcl_banners.read_layers (metadata)
	end
	return mcl_banners.is_same_layers(layers, oban_layers)
end

local pr = PcgRandom (os.time () + 970)
local r = 1 / 2147483647

local function is_opaque (node)
	return core.get_item_group (node.name, "opaque") > 0
end

local function is_clear (node)
	return core.get_item_group (node.name, "liquid") == 0
		and not core.registered_nodes[node.name].walkable
end

local function is_opaque_or_snow (node)
	if is_opaque (node) then
		return true
	end
	local snow = core.get_item_group (node.name, "top_snow")
	return snow > 0 and snow <= 4
end

function mcl_raids.do_spawn_pos_phase (phaseno, center, attempts)
	local spread = phaseno == 0 and 2 or 2 - phaseno

	-- Perform twenty attempts to select a valid spawn position
	-- per phase.
	for i = 1, attempts or 20 do
		local random = pr:next (0, 2147483647) * r * math.pi * 2
		local xoff = math.floor (math.cos (random) * 32 * spread)
			+ pr:next (0, 4)
		local zoff = math.floor (math.sin (random) * 32 * spread)
			+ pr:next (0, 4)
		local new_pos = vector.offset (center, xoff, 0, zoff)
		local surface = mcl_raids.find_surface_position (new_pos)
		local below = vector.offset (surface, 0, -1, 0)
		local above = vector.offset (surface, 0, 1, 0)

		-- Is this surface outside of any village or is this
		-- the final attempt?
		if phaseno == 2
			or mcl_villages.get_poi_heat (surface) <= 4 then
			-- Is this surface walkable and loaded...
			local node = core.get_node (surface)
			local node_above = core.get_node (above)
			local node_below = core.get_node (below)
			if node.name ~= "ignore"
				and node_above.name ~= "ignore"
				and node_below.name ~= "ignore"
				and is_clear (node_above)
				and is_clear (node)
				and is_opaque_or_snow (node_below) then
				return surface
			end
		end
	end
end

function mcl_raids.select_spawn_position (center)
	local pos = mcl_raids.do_spawn_pos_phase (0, center, 20)
	if pos then
		return pos
	end
	local pos = mcl_raids.do_spawn_pos_phase (1, center, 20)
	if pos then
		return pos
	end
	local pos = mcl_raids.do_spawn_pos_phase (2, center, 20)
	return pos
end

core.register_chatcommand("dump_banner_layers",{
	privs = {debug = true},
	func = function(pname)
		local p = core.get_player_by_name(pname)
		mcl_raids.drop_obanner(vector.offset(p:get_pos(),1,1,1))
		for v in core.objects_inside_radius(p:get_pos(), 5) do
			local l = v:get_luaentity()
			if l and l.name == "mcl_banners:standing_banner" then
				core.log(dump(l._base_color))
				core.log(dump(l._layers))
			end
		end
	end
})

------------------------------------------------------------------------
-- Raid event accounting.
------------------------------------------------------------------------

local mod_storage = core.get_mod_storage ()
local raid_debug = core.settings:get_bool ("raid_debug", false)
mcl_raids.raid_table = {}

core.register_on_shutdown (function ()
	-- Persist active raids.
	local serialized = core.serialize (mcl_raids.raid_table)
	mod_storage:set_string ("saved_raid", serialized)
end)

core.register_on_mods_loaded (function ()
	-- Restore previously active raids.
	local raids = mod_storage:get_string ("saved_raid")
	if raids then
		raids = core.deserialize (raids)
		if raids then
			mcl_raids.raid_table = raids
			if raid_debug then
				local blurb
					= "[mcl_raids] Loading active raids: "
					.. dump (raids)
				core.log ("action", blurb)
			end
		end
	end
end)

local function table_remove (tbl, element)
	local index = table.indexof (tbl, element)
	if index ~= -1 then
		table.remove (tbl, index)
	end
end

local raidmobs_by_uuid = {}

local function total_raider_hp (self)
	local hp = 0

	for _, health in pairs (self.member_hp) do
		hp = hp + health
	end
	return hp
end

local bossbars_by_player = {}

core.register_on_joinplayer (function (player)
	bossbars_by_player[player] = {}
end)

core.register_on_leaveplayer (function (player)
	bossbars_by_player[player] = nil
end)

local function update_bossbar (self)
	local progress, name
	if self.status == "ongoing" then
		local max_waves = self.num_ordinary_waves
		if self.bad_omen_level > 1 then
			max_waves = max_waves + 1
		end
		if self.pre_raid_time >= 0 then
			name = S ("Raid (@1 of @2)",
				  tostring (self.waves_spawned + 1),
				  tostring (max_waves))
			progress = 1 - self.pre_raid_time / 15
		elseif self.waves_spawned > 0 then
			local wave = self.waves[self.waves_spawned]
			name = S ("Raid (@1 of @2)",
				  tostring (self.waves_spawned),
				  tostring (max_waves))
			progress = total_raider_hp (self)
				/ (wave and wave.hp_max or 1.0)
		else
			progress = 0
			name = S ("Raid")
		end
	elseif self.status == "loss" then
		name = S ("Raid (defeat)")
		progress = 0.0
	elseif self.status == "victory" then
		name = S ("Raid (victory)")
		progress = 1.0
	end

	self.bossbar_name = name
	self.bossbar_progress = progress

	for player, bossbars in pairs (bossbars_by_player) do
		local id = bossbars[self.uuid]
		if id then
			local def = {
				color = "red",
				text = name,
				percentage = math.min (progress * 100, 100),
			}
			mcl_bossbars.update_bar (id, def, 1)
		end
	end
end

local function enroll_in_raid_2 (self, entity)
	entity._get_active_raid = function (raidmob)
		return self.status ~= "stopped" and self
	end
	self.member_hp[entity._raid_uuid] = entity.health
end

local function enroll_in_raid_1 (self, entity, waveobj)
	entity._raid_uuid = mcl_util.generate_uuid ()
	entity._attached_to_raid = self.uuid
	entity._raid_wave_number = waveobj.number
	entity.raidmob = true
	entity._time_outside_raid = 0.0
	raidmobs_by_uuid[entity._raid_uuid] = entity.object
	enroll_in_raid_2 (self, entity)
	return entity._raid_uuid
end

function mcl_raids.enroll_in_raid (self, entity)
	if entity.health > 0 and self.status == "ongoing" then
		local wave = self.waves[self.waves_spawned]
		if not wave then
			return
		end
		local uuid = enroll_in_raid_1 (self, entity, wave)
		table.insert (wave.members, uuid)
		wave.hp_max
			= wave.hp_max + entity.initial_properties.hp_max

		if raid_debug then
			core.log ("action", table.concat ({
				"[mcl_raids] Enrolling ",
				entity.name, " {", uuid,
				"} into raid {", self.uuid, "} at ",
				vector.to_string (self.center),
			}))
		end
	end
end

function mcl_raids.report_mob_damage_event (entity, hp, mcl_reason)
	if entity._get_active_raid then
		local raid = entity:_get_active_raid ()
		if not raid then
			return
		end

		if raid_debug then
			core.log ("action", table.concat ({
				"[mcl_raids] Raid mob damaged; HP: ",
				tostring (hp), ", mob: ", entity.name,
				" {", entity._raid_uuid, "}, raid: ",
				raid.uuid,
			}))
		end

		if hp <= 0 then
			for _, wave in pairs (raid.waves) do
				if wave.leader == entity._raid_uuid then
					wave.leader = nil
				end
				table_remove (wave.members, entity._raid_uuid)
			end
			raid.member_hp[entity._raid_uuid] = nil
			raid.member_unloaded_time[entity._raid_uuid] = nil

			local source = mcl_reason.source
			if source and source:is_player () then
				local player = source:get_player_name ()
				if table.indexof (raid.heroes, player) == -1 then
					table.insert (raid.heroes, player)
				end
				if raid_debug then
				    core.log ("action", table.concat ({
					    "[mcl_raids]: ", player, " has been cited ",
					    "for heroism in raid ", raid.uuid,
				    }))
				end
			end
		else
			-- Update health.
			raid.member_hp[entity._raid_uuid] = entity.health
		end

		update_bossbar (raid)
	end
end

function mcl_raids.load_raidmob (entity)
	-- Search for an extant raid into which to enroll ENTITY,
	-- or clear ENTITY's raid metadata if none exists.
	if entity._raid_uuid
		and entity._attached_to_raid
		and entity._raid_wave_number
		and entity.health > 0 then
		local raid = mcl_raids.raid_table[entity._attached_to_raid]
		if raid and raid.status == "ongoing"
			and raid.waves_spawned > 0 then
			local uuid = entity._raid_uuid
			raidmobs_by_uuid[uuid] = entity.object
			enroll_in_raid_2 (raid, entity)
			if raid_debug then
				core.log ("action", table.concat ({
					"[mcl_raids] Reloading raidmob ",
					entity.name, " {", uuid,
					"} into raid ", raid.uuid,
				}))
			end
			raid.member_unloaded_time[uuid] = 0.0

			local wave = entity._raid_wave_number
			local waveobj = raid.waves[wave]
			if not waveobj
				or table.indexof (waveobj.members, uuid) == -1 then
				core.log ("action", "[mcl_raids]  Raidmob is "
					  .. "rejoining as a member of a different wave!")
				waveobj = raid.waves[raid.waves_spawned]
				if waveobj then
					table.insert (waveobj.members, uuid)
				end
			end
		else
			entity._raid_wave_number = nil
			entity._raid_uuid = nil
			entity.raidmob = false
		end
	end
end

function mcl_raids.unload_raidmob (entity, remove)
	local raid = entity._get_active_raid ()
	if entity._raid_uuid then
		raidmobs_by_uuid[entity._raid_uuid] = nil
	end
	if not raid then
		return
	end
	if raid_debug then
		core.log ("action", table.concat ({
			"[mcl_raids] Unloading raidmob ",
			entity.name, " {", entity._raid_uuid,
			"} from raid ", raid.uuid,
			" (remove = ", remove and "true" or "false",
			")",
		}))
	end
	if remove then
		for _, wave in pairs (raid.waves) do
			if wave.leader == entity._raid_uuid then
				wave.leader = nil
			end
			table_remove (wave.members, entity._raid_uuid)
		end
		raid.member_hp[entity._raid_uuid] = nil
		raid.member_unloaded_time[entity._raid_uuid] = nil
	else
		-- Otherwise save the entity's HP.
		raid.member_hp[entity._raid_uuid] = entity.health
		raid.member_unloaded_time[entity._raid_uuid] = 0.0
	end
end

function mcl_raids.find_surface_position (node_pos)
	if node_pos.y < mcl_vars.mg_overworld_min then
		return node_pos
	else
		-- Raycast from a position 256 blocks above the
		-- overworld to the bottom of the world, and locate
		-- the first opaque or liquid non-leaf block.

		local v = vector.copy (node_pos)
		v.y = math.max (node_pos.y, 256)
		local lim
			= math.max (mcl_vars.mg_overworld_min, node_pos.y - 512)
		while v.y >= lim do
			local node = core.get_node (v)
			local def = core.registered_nodes[node.name]
			if node.name ~= "ignore"
				and (def.groups.liquid or def.walkable) then
				break
			end
			v.y = v.y - 1
		end
		v.y = v.y + 1
		return v
	end
end

function mcl_raids.promote_to_raidcaptain (entity)
	if entity.raidmob and entity._raid_uuid
		and entity._attached_to_raid then
		local raid = mcl_raids.raid_table[entity._attached_to_raid]
		local wave = entity._raid_wave_number
		if raid then
			local waveobj = raid.waves[wave]
			if waveobj then
				if raid_debug then
					local blurb = table.concat ({
						"[mcl_raids] Promoting ",
						entity.name, " {",
						entity._raid_uuid, "} to ",
						"leader of wave ",
						tostring (wave), " of raid ",
						raid.uuid,
					})
					core.log ("action", blurb)
				end
				waveobj.leader = entity._raid_uuid
			end
		end
	end
end

local function register_raid (level, center)
	-- Register a raid and return its UUID and data tables.
	local raid_data = {
		has_started = false,
		is_active = false,
		time_active = 0,
		bad_omen_level = level,
		pre_raid_time = 15.0,
		post_raid_time = 0,
		status = "ongoing",
		waves_spawned = 0,
		center = vector.copy (center),
		waves = {},
		spawn_pos = nil,
		num_ordinary_waves = 1 + mcl_vars.difficulty * 2,
		spawn_pos_timer = 0.0,
		update_timer = 0.0,
		player_update_timer = 0.0,
		-- Last recorded health statistic of each participant
		-- of the raid, indiced by UUID.
		member_hp = {},
		-- Number of seconds for which raiders have not been
		-- loaded.
		member_unloaded_time = {},
		bossbar_name = nil,
		bossbar_progress = nil,
		-- Names of players who have slain raiders.
		heroes = {},
	}
	local uuid = mcl_util.generate_uuid ()
	raid_data.uuid = uuid
	mcl_raids.raid_table[uuid] = raid_data
	update_bossbar (raid_data)
	return raid_data.uuid, raid_data
end

local function stop_raid (self)
	self.status = "stopped"
	self.is_active = false
	mcl_raids.raid_table[self.uuid] = nil
	for player, bossbars in pairs (bossbars_by_player) do
		local id = bossbars[self.uuid]
		if id then
			mcl_bossbars.remove_bar (id)
			bossbars[self.uuid] = nil
		end
	end
end

local test_positions = {
}

for x = -2, 2 do
	for y = -2, 2 do
		for z = -2, 2 do
			if x ~= 0 or y ~= 0 or z ~= 0 then
				local v = vector.new (x, y, z)
				table.insert (test_positions, v)
			end
		end
	end
end
local ZERO_VECTOR = vector.zero ()
table.sort (test_positions, function (a, b)
	return vector.distance (a, ZERO_VECTOR)
		< vector.distance (b, ZERO_VECTOR)
end)

local function recenter_raid (self)
	local center = mcl_villages.section_position (self.center)
	local tem = vector.zero ()
	for _, off in ipairs (test_positions) do
		tem.x = center.x + off.x
		tem.y = center.y + off.y
		tem.z = center.z + off.z

		if mcl_villages.get_poi_heat_of_section (tem) >= 5 then
			self.center = mcl_villages.center_of_section (tem)
			if raid_debug then
				core.log ("action", table.concat ({
					"Raid ", self.uuid, " recentered on ",
					vector.to_string (self.center),
				}))
			end
			return true
		end
	end
	if raid_debug then
		core.log ("action", table.concat ({
			"Raid ", self.uuid, " failed to be recentered",
		}))
	end
	return false
end

local RAID_TIMEOUT_SECONDS = 2400

local function count_living_raiders (self)
	local cnt = 0
	for _, wave in pairs (self.waves) do
		cnt = cnt + #wave.members
	end
	return cnt
end

local active_block_range
	= tonumber (core.settings:get ("active_block_range")) or 4

local function is_spawn_pos_loaded (spawn_pos)
	local section = mcl_villages.section_position (spawn_pos)
	for player in mcl_util.connected_players () do
		local pos = player:get_pos ();
		local x = math.floor (pos.x / 16)
		local y = math.floor (pos.y / 16)
		local z = math.floor (pos.z / 16)
		if math.abs (x - section.x) < active_block_range
			and math.abs (y - section.y) < active_block_range
			and math.abs (z - section.z) < active_block_range then
			return true
		end
	end
	return false
end

local RAID_DISTANCE_SQR = 96 * 96

local function find_active_raid (pos)
	local distance, nearest
	for _, raid in pairs (mcl_raids.raid_table) do
		local dx = pos.x - raid.center.x
		local dy = pos.y - raid.center.y
		local dz = pos.z - raid.center.z
		local dist = dx * dx + dy * dy + dz * dz
		if dist < RAID_DISTANCE_SQR
			and (not distance or dist < distance) then
			nearest = raid
			distance = dist
		end
	end
	return nearest
end

mcl_raids.find_active_raid = find_active_raid

local function update_players (self)
	for player, bossbars in pairs (bossbars_by_player) do
		local pos = player:get_pos ()
		local id = bossbars[self.uuid]
		local raid = find_active_raid (pos)
		if not pos or raid ~= self then
			if id then
				mcl_bossbars.remove_bar (id)
				bossbars[self.uuid] = nil
			end
		elseif not id and self.bossbar_name then
			local progress = self.bossbar_progress
			local def = {
				color = "red",
				text = self.bossbar_name,
				percentage = math.min (progress * 100, 100),
			}
			bossbars[self.uuid]
				= mcl_bossbars.add_bar (player, def, false, 1)
		end
	end
end

local mobs_and_spawn_count_by_wave = {
	["mobs_mc:vindicator"] = {
		0, 2, 0, 1, 4, 2, 5,
	},
	["mobs_mc:evoker"] = {
		0, 0, 0, 0, 1, 1, 2,
	},
	["mobs_mc:pillager"] = {
		4, 3, 3, 4, 4, 4, 2,
	},
	["mobs_mc:witch"] = {
		0, 0, 0, 3, 0, 0, 1,
	},
	["mobs_mc:ravager"] = {
	        0, 0, 1, 0, 1, 0, 2,
	},
}

local function num_ordinary_spawns (self, mobtype, wave)
	local tbl = mobs_and_spawn_count_by_wave[mobtype]
	return tbl and tbl[math.min (wave, self.num_ordinary_waves)] or 0
end

local function num_special_spawns (self, mobtype, wave, is_bonus_wave)
	local max_special_spawns = 0

	if mobtype == "mobs_mc:vindicator"
		or mobtype == "mobs_mc:pillager" then
		if mcl_vars.difficulty == 1 then
			max_special_spawns = pr:next (0, 1)
		elseif mcl_vars.difficulty == 2 then
			max_special_spawns = 1
		elseif mcl_vars.difficulty == 3 then
			max_special_spawns = 2
		end
	elseif mobtype == "mobs_mc:evoker" then
		max_special_spawns = 0
	elseif mobtype == "mobs_mc:witch" then
		if mcl_vars.difficulty == 3
		-- Only the last wave on Hard should feature bonus
		-- witches.
			and wave ~= 4 then
			max_special_spawns = 1
		end
	elseif mobtype == "mobs_mc:ravager" then
		if mcl_vars.difficulty > 1 and is_bonus_wave then
			max_special_spawns = 1
		end
	end
	return pr:next (0, max_special_spawns)
end

local PERSISTENT_MOB_STATICDATA = core.serialize ({
	persistent = true,
	_raid_spawn = true,
})

local RAVAGER_ATTACHMENT_POS = vector.new (0, 16.5, -3.0)
local RAVAGER_ATTACHMENT_ROT = vector.zero ()

local function spawn_group (self, pos)
	local wave = self.waves_spawned + 1
	local captain = nil
	local floor = vector.offset (pos, 0, -0.5, 0)
	local raiders_spawned = {}

	if raid_debug then
		local blurb
			= string.format ("Spawning mobs for wave %d of raid %s at: %s",
					 wave, self.uuid, vector.to_string (floor))
		core.log ("action", blurb)
	end
	local max_hp = 0

	local is_bonus_wave = self.bad_omen_level > 1
		and wave > self.num_ordinary_waves
	for mob, _ in pairs (mobs_and_spawn_count_by_wave) do
		local count = num_ordinary_spawns (self, mob, wave)
		count = count + num_special_spawns (self, mob, wave, is_bonus_wave)

		for i = 1, count do
			local staticdata = PERSISTENT_MOB_STATICDATA
			local obj = core.add_entity (floor, mob, staticdata)

			if obj then
				local luaentity = obj:get_luaentity ()
				if not captain and luaentity._can_serve_as_captain then
					captain = obj
				end
				max_hp = max_hp + luaentity.initial_properties.hp_max

				-- Spawn jockeys if necessary.
				if mob == "mobs_mc:ravager" then
					local jockey_type = nil
					if wave == 5 then
						jockey_type = "mobs_mc:pillager"
					elseif wave >= 7 then
						if i == 1 then
							jockey_type = "mobs_mc:evoker"
						else
							jockey_type = "mobs_mc:vindicator"
						end
					end

					if jockey_type then
						local rider
							= core.add_entity (floor, jockey_type, staticdata)
						if rider then
							local entity = rider:get_luaentity ()
							local pos = RAVAGER_ATTACHMENT_POS
							local rot = RAVAGER_ATTACHMENT_ROT
							entity:jock_to_existing (obj, "", pos, rot, true)
							max_hp = max_hp + entity.initial_properties.hp_max
							table.insert (raiders_spawned, rider)
						end
					end
				end
			end
			table.insert (raiders_spawned, obj)
		end
	end

	-- Proceed to enroll each of these raiders into this wave
	-- by assigning them UUIDs and tallying their health.
	self.waves_spawned = wave
	local waveobj = {
		leader = nil,
		members = {},
		number = wave,
		hp_max = max_hp,
	}
	for _, mob in pairs (raiders_spawned) do
		local entity = mob:get_luaentity ()
		local uuid = enroll_in_raid_1 (self, entity, waveobj)
		if mob == captain then
			waveobj.leader = uuid
			entity:promote_to_raidcaptain ()
		end
		entity:apply_raid_buffs (wave)
		table.insert (waveobj.members, uuid)
		if raid_debug then
			core.log ("action", table.concat ({
				"[mcl_raids] Spawned ",
				entity.name, " {", uuid,
				"} into raid {", self.uuid, "} at ",
				vector.to_string (self.center),
			}))
		end
	end
	self.waves[wave] = waveobj
	self.wave_spawn_pos = nil
end

local return_nil = function (_)
	return nil
end

local function update_raiders (self, dtime)
	for raider, health in pairs (self.member_hp) do
		local obj = raidmobs_by_uuid[raider]
		-- If obj is present, update HEALTH and evaluate
		-- whether it remains in a village.  Remove it from
		-- the raid if it has ventured more than 112 blocks
		-- from the raid center.
		if obj then
			local entity = obj:get_luaentity ()
			local pos = obj:get_pos ()
			if entity and entity._raid_wave_number
				and entity._raid_uuid then
				local waveno = entity._raid_wave_number
				local dist = vector.distance (pos, self.center)
				local timeout = false
				health = entity.health

				if entity._time_inactive
					and entity._time_inactive > 60 then
					-- If ~1 second is spent
					-- outside the confines the
					-- raid after being inactive
					-- longer than a minute,
					-- remove this entity.
					if mcl_villages.get_poi_heat (pos) < 5 then
						local t = entity._time_outside_raid or 0.0
						entity._time_outside_raid = t + 1.0
						if t >= 1.0 then
							timeout = true
						end
					end
				end

				if raid_debug and timeout then
					local blurb = table.concat ({
						entity.name, " {",
						entity._raid_uuid, "} timed",
						" out and is being removed from",
						" raid ", self.uuid,
					})
					core.log ("action", blurb)
				end

				if timeout or dist > 112.0 then
					local wave = self.waves[waveno]
					table_remove (wave.members, entity._raid_uuid)
					if wave.leader == raider then
						wave.leader = nil
					end
					health = nil
					entity._raid_uuid = nil
					entity._get_active_raid = return_nil
					entity.raidmob = false
					entity._attached_to_raid = nil
				end
			end
			self.member_hp[raider] = health
		else
			local t = self.member_unloaded_time[raider] or 0.0
			self.member_unloaded_time[raider] = t + dtime

			-- Expel raid mobs that are unloaded for a
			-- long time, but do not prohibit them from
			-- rejoining if they should be reloaded.
			if t > 120 then
				if raid_debug then
					local blurb = table.concat ({
						"Provisionally expelling unloaded raider ",
						"{", raider, "}"
					})
					core.log ("action", blurb)
				end
				self.member_hp[raider] = nil
				for _, wave in pairs (self.waves) do
					table_remove (wave.members, raider)
					if wave.leader == raider then
						wave.leader = nil
					end
				end
			end
		end
	end
end

local function maybe_update_players (self, dtime)
	local t = self.player_update_timer or 0.0
	if t <= 0 then
		update_players (self)
		self.player_update_timer = 1.0
	end
	self.player_update_timer = t - dtime
end

local function tick_raid (self, dtime)
	if self.status == "loss" or self.status == "victory" then
		local t = self.post_raid_time
		if t > 30.0 then
			stop_raid (self)
			return
		end
		self.post_raid_time = t + dtime
		return
	elseif self.status == "stopped" then
		return
	end
	if mcl_vars.difficulty == 0 then
		stop_raid (self)
		return
	end

	-- Don't tick raids that are not loaded.
	if not self.center
		or not is_spawn_pos_loaded (self.center) then
		maybe_update_players (self, dtime)
		return
	end

	-- Recenter raid if all POIs in the current center are lost.
	-- Failing this, consider the raid a defeat.
	if mcl_villages.get_poi_heat (self.center) < 5
		and not recenter_raid (self) then
		if self.waves_spawned > 0 then
			self.status = "loss"
			update_bossbar (self)
		else
			stop_raid (self)
		end
		return
	end

	local t = self.time_active
	self.time_active = t + dtime
	if t >= RAID_TIMEOUT_SECONDS then
		stop_raid (self)
		return
	end

	--- Wave format:
	---
	--- {
	---   leader  = <uuid>,
	---   members = { <uuid> ... },
	---   hp_max  = <hp>,
	--- }
	---
	--- Mobs are enrolled into the `mob_by_uuid' table at
	--- load-time if a UUID field is detected.

	-- Spawn more waves if need be.
	local living = count_living_raiders (self)
	local max_waves = self.num_ordinary_waves
	if self.bad_omen_level > 1 then
		max_waves = max_waves + 1
	end
	local center = self.center
	maybe_update_players (self, dtime)
	if living == 0 and self.waves_spawned <= max_waves then
		-- Tick or reset cooldown.
		if self.pre_raid_time <= 0 then
			self.pre_raid_time = 15
			update_bossbar (self)
			return
		else
			if (not self.wave_spawn_pos and self.spawn_pos_timer <= 0)
				or (self.wave_spawn_pos
				    and not is_spawn_pos_loaded (self.wave_spawn_pos)) then
				local phaseno, pos = 0
				-- Select a new raid spawn position.

				if self.pre_raid_time < 2.0 then
					phaseno = 2
				elseif self.pre_raid_time < 5.0 then
					phaseno = 1
				end

				pos = mcl_raids.do_spawn_pos_phase (phaseno, center)
				if pos and is_spawn_pos_loaded (pos) then
					self.wave_spawn_pos = pos
				else
					self.wave_spawn_pos = nil
				end
				self.spawn_pos_timer = 0.25
			end

			local t = self.spawn_pos_timer
			self.spawn_pos_timer = t - dtime
			local t = self.pre_raid_time
			self.pre_raid_time = t - dtime
			update_bossbar (self)
		end
	end

	local t = self.update_timer
	self.update_timer = t - dtime

	if t <= 0 then
		update_raiders (self, 1.0 - t)
		update_players (self)
		update_bossbar (self)
		self.update_timer = 1.0
	end

	-- Spawn a new wave if necessary.
	if self.pre_raid_time <= 0
		and self.waves_spawned <= max_waves
		and living == 0 then
		-- If no spawning position could be located, terminate
		-- the raid.
		if not self.wave_spawn_pos then
			stop_raid (self)
			return
		else
			self.has_started = true
			spawn_group (self, self.wave_spawn_pos)
		end
	elseif living == 0 and self.waves_spawned >= max_waves then
		-- Victory.
		self.status = "victory"
		update_bossbar (self)

		for _, player in pairs (self.heroes) do
			local obj = core.get_player_by_name (player)
			awards.unlock (player, "mcl:hero_of_the_village")
			if obj then
				mcl_potions.give_effect ("hero_of_village", obj, 0, 2400)
			end
		end
	end
end

local function step_raids (dtime)
	for _, raid in pairs (mcl_raids.raid_table) do
		tick_raid (raid, dtime)
	end
end

core.register_globalstep (step_raids)

------------------------------------------------------------------------
-- Raid mechanics.
------------------------------------------------------------------------

function mcl_raids.should_enchant (raid)
	if raid.bad_omen_level < 2 then
		return false
	elseif raid.bad_omen_level < 3 then
		return pr:next (1, 10) == 1
	elseif raid.bad_omen_level < 4 then
		return pr:next (1, 4) == 1
	elseif raid.bad_omen_level < 5 then
		return pr:next (1, 2) == 1
	else
		return pr:next (1, 8) <= 6
	end
end

function mcl_raids.is_wave_active (raid)
	for _, wave in pairs (raid.waves) do
		if #wave.members > 0 then
			return true
		end
	end
	return false
end

------------------------------------------------------------------------
-- Raid event initiation.
------------------------------------------------------------------------

mcl_player.register_globalstep_slow (function (player, _)
	local level = mcl_potions.get_effect_level (player, "bad_omen")

	if level == 0 then
		return
	end

	local pos = player:get_pos ()
	local nodepos = mcl_util.get_nodepos (pos)
	local dim = mcl_worlds.pos_to_dimension (pos)

	-- Raids cannot spawn in the Nether.
	if dim == "nether" then
		return
	end

	-- Locate nearby village centers.
	local pois = mcl_villages.pois_in_radius (nodepos, 64.0,
						  nil, nil)
	if #pois == 0 then
		return
	end

	-- Derive a focal point for the raid.
	local x, y, z = 0, 0, 0
	for _, poi in pairs (pois) do
		x = x + poi.min.x
		y = y + poi.min.y
		z = z + poi.min.z
	end
	local r = 1.0 / #pois
	x = x * r
	y = y * r
	z = z * r
	local center = vector.new (x, y, z)

	-- Attempt to locate an ongoing raid.
	local raid = find_active_raid (center)
	if raid then
		local level = raid.bad_omen_level + level
		raid.bad_omen_level = math.min (5, level)
		mcl_potions.clear_effect (player, "bad_omen")
		return
	end

	-- Start a new raid.
	local uuid, _ = register_raid (level, center)
	core.log ("action", table.concat ({
		"Initializing raid ", uuid,
		" at level ", tostring (level),
		" and position ", vector.to_string (center),
	}))
	mcl_potions.clear_effect (player, "bad_omen")
end)
