local S = core.get_translator(core.get_current_modname())

local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local food_items = {
	"mcl_fishing:fish_raw",
	"mcl_fishing:salmon_raw",
	"mcl_fishing:clownfish_raw",
}

local dolphin = {
	description = S("Dolphin"),
	type = "animal",
	_spawn_category = "water_creature",
	can_despawn = true,
	can_ride_boat = false,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	breath_max = 240,
	rotate = 180,
	pace_chance = 10,
	pace_interval = 0.5,
	tilt_swim = true,
	floats = 0,
	collisionbox = {-0.45, -0.0, -0.45, 0.45, 0.6, 0.45},
	head_eye_height = 0.3,
	visual = "mesh",
	mesh = "extra_mobs_dolphin.b3d",
	textures = {
		{
			"extra_mobs_dolphin.png",
		},
	},
	sounds = {
		random = "mobs_mc_dolphin_whistle",
		attack = "mobs_mc_dolphin_attack",
		damage = "mobs_mc_dolphin_hurt",
		death = "mobs_mc_dolphin_dying",
	},
	animation = {
		stand_start = 0, stand_end = 15, stand_speed = 20,
		walk_start = 0, walk_end = 15, walk_speed = 20,
	},
	drops = {
		{
			name = "mcl_fishing:fish_raw",
			chance = 1,
			min = 0,
			max = 1,
		},
	},
	runaway_from = {
		"mobs_mc:guardian",
		"mobs_mc:guardian_elder",
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swims = true,
	flops = true,
	do_go_pos = mcl_mobs.mob_class.pitchswim_do_go_pos,
	swims_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	idle_gravity_in_liquids = true,
	movement_speed = 24.0,
	reach = 2,
	damage = 2.5,
	attack_type = "melee",
	_moisture = 120,
	_waiting_for_treasure_position = false,
}

------------------------------------------------------------------------
-- Dolphin interaction.
------------------------------------------------------------------------

function dolphin:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item ()
	return table.indexof(food_items, wielditem:get_name()) ~= -1
end

function dolphin:on_rightclick (clicker)
	local wi = clicker:get_wielded_item()
	if table.indexof(food_items, wi:get_name()) ~= -1 then
		if not core.is_creative_enabled(clicker:get_player_name()) then
			wi:take_item()
			clicker:set_wielded_item(wi)
		end
		-- TODO: bone meal particles.
		self._fed = true
		self._treasure_position = nil
		if not self._waiting_for_treasure_position then
			local self_pos = self.object:get_pos ()
			self:find_treasure (self_pos)
		end
	end
end

------------------------------------------------------------------------
-- Dolphin AI.
------------------------------------------------------------------------

function dolphin:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if core.get_item_group (self.standing_in, "water") == 0
		and not mcl_weather.is_exposed_to_rain (self.object:get_pos ()) then
		self._moisture = self._moisture - dtime
		if self._moisture <= 0 and self:check_timer ("desiccation", 1.0) then
			self:damage_mob ("environment", 1.0)
		end
	else
		self._moisture = 120
	end
end

local function is_accelerating (player)
	local controls = player:get_player_control ()
	return math.abs (controls.movement_y) > 5.0e-4
		or math.abs (controls.movement_x) > 5.0e-4
end

local function dolphin_swim_with_boat (self, self_pos, dtime)
	if self._swim_with_driver then
		local driver = self._swim_with_driver
		local boat = self._swd_boat
		if not is_valid (driver) or not is_accelerating (driver)
			or driver:get_attach () ~= boat then
			self._swim_with_driver = nil
			self:cancel_navigation ()
			return false
		end
		self._swd_time = self._swd_time + dtime
		if self._swd_time < 0.5 then
			return true
		end
		self._swd_time = 0
		local driver_pos = driver:get_pos ()
		if self._swd_phase == 0 then
			-- If within four nodes of the driver,
			-- transition to swimming alongside his
			-- vehicle.
			if vector.distance (self_pos, driver_pos) < 4.0 then
				self._swd_phase = 1
			else
				-- Move towards the boat's driver.
				self:gopath (driver_pos, 1.97)
			end
		end
		if self._swd_phase == 1 then
			if vector.distance (self_pos, driver_pos) > 12 then
				self.swd_phase = 0
			else
				local driver_yaw = boat:get_yaw ()
				local dir = core.yaw_to_dir (driver_yaw)
				local target_pos = vector.offset (self_pos, dir.x * 10, 0,
								  dir.z * 10)
				self:gopath (target_pos, 1.97)
			end
		end
		return true
	else
		local driver, boat = nil, nil
		for object in core.objects_inside_radius (self_pos, 5) do
			local entity
			entity = object:get_luaentity ()
			if entity and (entity.name == "mcl_boats:boat"
					or entity.name == "mcl_boats:chest_boat") then
				if entity._driver
					and is_valid (entity._driver)
					and entity._driver:is_player ()
					and is_accelerating (entity._driver) then
					driver = entity._driver
					boat = object
					break
				end
			end
		end
		if driver then
			-- 0: Navigate to boat; 1: move in direction
			-- of boat, i.e., swim along the boat.
			self._swd_phase = 0
			self._swd_time = 0.5
			self._swd_boat = boat
			self._swim_with_driver = driver
			return "_swim_with_driver"
		end
		return false
	end
end

-- This appears to be unacceptably expensive and will remain so till
-- https://github.com/minetest/minetest/issues/14613
-- is resolved.
-- local function dolphin_harass_items (self, self_pos, dtime)
--
-- end

local CLEARANCE_STEPS = {
	0, 1, 4, 5, 6, 7,
}

local function is_water (nodepos)
	local node = core.get_node (nodepos)
	return core.get_item_group (node.name, "water") ~= 0
end

local function is_air (nodepos)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and not def.walkable and def.liquidtype == "none"
end

local TEN_DEG = math.rad (10)

function dolphin:can_reset_pitch ()
	return not self._jumping_over_water
end

local function dolphin_jump (self, self_pos, dtime, moveresult)
	if self._jumping_over_water then
		-- Set pitch according as the dolphin is falling or
		-- stable.
		local v = self.object:get_velocity ()
		local xz = math.sqrt (v.x * v.x + v.z * v.z)
		local pitch = math.atan2 (-v.y, xz)
		self:set_pitch (pitch)
		if math.abs (pitch) < TEN_DEG
			and v.y * v.y < 0.6
			and self._immersion_depth > 0 then
			self._jumping_over_water = false
			self:set_pitch (0)
			return false
		end
		if moveresult.touching_ground
			or moveresult.standing_on_object then
			self._jumping_over_water = false
			self:set_pitch (0)
			return false
		end
		return true
	elseif self:check_timer ("dolphin_jump", 0.5)
		and math.random (math.round (10 * (dtime / 0.05))) == 1 then
		-- Poor man's spline raycast.
		local yaw = self:get_yaw ()
		local dx, dz = mcl_util.get_2d_block_direction (yaw)
		local nodepos = {
			x = math.floor (self_pos.x + 0.5),
			y = math.floor (self_pos.y + 0.5),
			z = math.floor (self_pos.z + 0.5),
		}
		for _, i in ipairs (CLEARANCE_STEPS) do
			local water_node = vector.offset (nodepos, dx * i, 0, dz * i)
			local air_node0 = vector.offset (nodepos, dx * i, 1, dz * i)
			local air_node1 = vector.offset (nodepos, dx * i, 2, dz * i)
			if not is_water (water_node) or not is_air (air_node0)
				or not is_air (air_node1) then
				return false
			end
		end

		local v = self.object:get_velocity ()
		v.x = v.x + dx * 12
		v.y = v.y + 14
		v.z = v.z + dz * 12
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self.object:set_velocity (v)
		local xz = math.sqrt (v.x * v.x + v.z * v.z)
		local pitch = -math.atan2 (v.y, xz)
		self:set_pitch (pitch)
		self._jumping_over_water = true
		return "_jumping_over_water", true
	end
end

local function dolphin_swim_with_player (self, self_pos, dtime)
	local player = self._swimming_with

	if player then
		if not is_valid (player)
			or vector.distance (player:get_pos (), self_pos) >= 16
			or (not mcl_player.players[player].is_swimming
			    and not mcl_serverplayer.is_swimming (player)) then
			self._swimming_with = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end

		if math.random (math.round (6 * dtime / 0.05)) == 1 then
			mcl_potions.give_effect ("dolphin_grace", player, 1, 5)
		end

		if vector.distance (self_pos, player:get_pos ()) < 2.5 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
		elseif self:check_timer ("dolphin_repath_quick", 0.15) then
			self:gopath (player:get_pos (), 4.0, nil, nil)
		end
		return true
	elseif self:check_timer ("dolphin_locate_swimmers", 0.3) then
		local cur_dist, closest_player
		for player, meta in pairs (mcl_player.players) do
			local pos
			local is_swimming = meta.is_swimming
				or mcl_serverplayer.is_swimming (player)
			if self.attack ~= player and is_swimming then
				pos = player:get_pos ()

				if pos then
					local distance = vector.distance (self_pos, pos)
					if not closest_player or cur_dist > distance then
						closest_player = player
						cur_dist = distance
					end
				end
			end
		end
		if closest_player then
			self._swimming_with = closest_player
			self:gopath (closest_player:get_pos (), 4.0, nil, nil)
			return "_swimming_with"
		end
		return false
	end
end

local function is_still_valid (self)
	return self.object:is_valid ()
		and self._waiting_for_treasure_position
end

local function find_treasure_cb (v, self)
	if is_still_valid (self) then
		self._treasure_position = v
		self._waiting_for_treasure_position = false
	end
	return false
end

local dolphin_treasures = {
	"mcl_levelgen:ocean_ruin_cold",
	"mcl_levelgen:ocean_ruin_warm",
	"mcl_levelgen:shipwreck",
	"mcl_levelgen:shipwreck_beached",
}

function dolphin:find_treasure (self_pos)
	-- XXX: it's not currently possible actually to locate
	-- structures, just the chests.
	if not mcl_levelgen.levelgen_enabled then
		local p1 = vector.offset (self_pos, -64, -16, -64)
		local p2 = vector.offset (self_pos, 64, math.min (1, self_pos.y+16), 64)
		local chests = core.find_nodes_in_area (p1, p2, {"mcl_chests:chest_small"})
		if chests and #chests > 0 then
			table.sort (chests, function(a, b)
				return vector.distance (self_pos, a)
					< vector.distance (self_pos, b)
			end)
			self._waiting_for_treasure_position = false
			self._treasure_position = chests[1]
		end
	else
		assert (not self._waiting_for_treasure_position)
		self._waiting_for_treasure_position = true
		mcl_biome_dispatch.locate_structure_near (self_pos, dolphin_treasures,
							  16, find_treasure_cb, self,
							  is_still_valid)
	end
	return nil
end

function dolphin:get_destination ()
	return self.waypoints and self.waypoints[1] or nil
end

function dolphin:valid_node_in_direction (self_pos, limx, limy, direction, range)
	for _ = 1, 10 do
		local node = self:random_node_direction (limx, limy, direction, range)
		if node then
			node = vector.add (self_pos, node)
			if is_water (node) then
				return node
			end
		end
	end
	return nil
end

function dolphin:respire ()
	self.breath = 240
end

local function dolphin_seek_treasure (self, self_pos, dtime)
	if self._seeking_treasure then
		if self.breath < 5 then
			self._seeking_treasure = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		local treasure = self._seeking_treasure
		local target = self:get_destination ()
		-- If this dolphin has already horizontally arrived
		-- near the buried treasure, halt and consume fish.
		local xz_pos = vector.new (treasure.x, self_pos.y, treasure.z)
		if vector.distance (xz_pos, self_pos) <= 2.0 then
			self._fed = false
			self._seeking_treasure = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		-- Once the target has been approached, stop
		-- navigating to it directly, but swim in its general
		-- vicinity until air is depleted.
		if (target and vector.distance (self_pos, target) <= 12.0)
			or self:navigation_finished () then
			local direction = vector.direction (self_pos, treasure)
			local node = self:valid_node_in_direction (self_pos, 16, 1, direction,
								math.pi / 8)
			if not node then
				node = self:valid_node_in_direction (self_pos, 8, 4, direction,
								math.pi / 2)
			end
			if not node then
				node = self:valid_node_in_direction (self_pos, 8, 5, direction,
								math.pi / 2)
			end

			if node then
				self:gopath (node, 1.3)
				return true
			end
			self._seeking_treasure = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		if self:check_timer ("dolphin_repath", 0.5) then
			self:gopath (treasure, 1.3)
		end
		return true
	elseif self._fed and self.breath > 5 then
		if self._waiting_for_treasure_position then
			return false
		elseif not self._treasure_position then
			self._fed = false
			return false
		else
			self:gopath (self._treasure_position, 1.3)
			self._seeking_treasure = self._treasure_position
			self._waiting_for_treasure_position = false
			self._treasure_position = nil
			return "_seeking_treasure"
		end
	end
	return false
end

function dolphin:get_staticdata_table ()
	local tbl = mob_class.get_staticdata_table (self)
	if tbl then
		tbl._waiting_for_treasure_position = nil
		tbl._treasure_position = nil
	end
	return tbl
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

local function dolphin_return_to_water_1 (self_pos)
	local aa = vector.offset (self_pos, -2, -2, -2)
	local bb = vector.offset (self_pos, 2, 2, 2)
	local nodes = core.find_nodes_in_area (aa, bb, {
		"group:water",
	})
	table.sort (nodes, function (v1, v2)
		return manhattan3d (self_pos, v1)
			< manhattan3d (self_pos, v2)
	end)
	return #nodes > 1 and nodes[0] or nil
end

local function dolphin_return_to_water (self, self_pos, dtime)
	if self._moving_to_water then
		if self:navigation_finished () then
			self:halt_in_tracks ()
			self:cancel_navigation ()
			self._moving_to_water = false
			return false
		end
		return true
	end
	if self.pacing then
		return false
	end
	if core.get_item_group (self.standing_in, "water") ~= 0 then
		return false
	end
	local node = dolphin_return_to_water_1 (self_pos)
	if node and self:go_to_pos (node) then
		self._moving_to_water = true
		return "_moving_to_water"
	end
	return false
end

local function dolphin_breathe_air (self, self_pos, dtime)
	if self._seeking_air then
		if self.breath > 7 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		-- Search for air.  XXX: perhaps also consider other
		-- non-walkable blocks that are as good as air?
		local aa = vector.offset (self_pos, -1, 0, -1)
		local bb = vector.offset (self_pos, -1, 8, -1)
		local air_blocks = core.find_nodes_in_area (aa, bb, {"air"})
		table.sort (air_blocks, function (a, b)
			return manhattan3d (a, self_pos) < manhattan3d (b, self_pos)
		end)
		if #air_blocks > 0
			and self:check_timer ("dolphin_repath_quick", 0.15) then
			self:gopath (air_blocks[1])
		end
		return true
	elseif self.breath < 5 then
		-- Search for air.  XXX: perhaps also consider other
		-- non-walkable blocks that are as good as air?
		local aa = vector.offset (self_pos, -1, 0, -1)
		local bb = vector.offset (self_pos, 1, 8, 1)
		local air_blocks = core.find_nodes_in_area (aa, bb, {"air"})
		table.sort (air_blocks, function (a, b)
			return manhattan3d (a, self_pos) < manhattan3d (b, self_pos)
		end)
		if #air_blocks > 0 then
			self:gopath (air_blocks[1])
			self._seeking_air = true
			return "_seeking_air", true
		end
		return false
	end
end

local hashpos = mcl_mobs.gwp_hashpos
local gwp_get_node = mcl_mobs.gwp_get_node
local gwp_nodevalue_to_name = mcl_mobs.gwp_nodevalue_to_name

local function dolphin_gwp_basic_classify (pos)
	local nodevalue, value = gwp_get_node (pos), nil
	if not nodevalue then
		return "IGNORE"
	end
	local name = gwp_nodevalue_to_name (nodevalue)
	local def = core.registered_nodes[name]
	if not def then
		value = "BLOCKED"
	elseif not def.groups.water or def.groups.water == 0 then
		-- Enable dolphins to (attempt to) surface into and
		-- breathe air.
		if not def.walkable then
			return "AIR"
		end
		value = "BLOCKED"
	end
	return value
end

local function dolphin_gwp_classify_node (self, context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	if cache then
		return cache
	end

	local b_width, b_height
	b_width = context.mob_width - 1
	b_height = context.mob_height - 1

	local sx, sy, sz = pos.x, pos.y, pos.z
	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z

				local class = dolphin_gwp_basic_classify (vector)
				context.class_cache[hash] = class
				if class then
					return class
				end
			end
		end
	end
	context.class_cache[hash] = "WATER"
	return "WATER"
end

function dolphin:gwp_configure_aquatic_mob ()
	mob_class.gwp_configure_aquatic_mob (self)
	self.gwp_classify_node = dolphin_gwp_classify_node
	self.gwp_penalties.AIR = 8.0
end

dolphin.ai_functions = {
	mob_class.check_avoid,
	dolphin_return_to_water,
	dolphin_seek_treasure,
	dolphin_swim_with_player,
	dolphin_swim_with_boat,
	-- dolphin_harass_items,
	mob_class.check_attack,
	dolphin_jump,
	mob_class.check_pace,
	dolphin_breathe_air,
}

dolphin._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule ({
		"mobs_mc:guardian",
		"mobs_mc:elder_guardian",
	}, true, { "mobs_mc:dolphin", }),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:dolphin", dolphin)

------------------------------------------------------------------------
-- Dolphin spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg("mobs_mc:dolphin", S("Dolphin"), "#223b4d", "#f9f9f9", 0)

------------------------------------------------------------------------
-- Modern Dolphin spawning.
------------------------------------------------------------------------

local dolphin_spawner_warm = table.merge (mobs_mc.aquatic_animal_spawner, {
	spawn_category = "water_creature",
	name = "mobs_mc:dolphin",
	biomes = {
		"WarmOcean",
		"DeepLukewarmOcean",
		"LukewarmOcean",
	},
	weight = 2,
	pack_min = 1,
	pack_max = 2,
})

local dolphin_spawner = table.merge (mobs_mc.aquatic_animal_spawner, {
	spawn_category = "water_creature",
	name = "mobs_mc:dolphin",
	biomes = {
		"DeepOcean",
		"Ocean",
	},
	weight = 1,
	pack_min = 1,
	pack_max = 2,
})

mcl_mobs.register_spawner (dolphin_spawner_warm)
mcl_mobs.register_spawner (dolphin_spawner)
