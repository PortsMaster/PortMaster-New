local S = core.get_translator("mobs_mc")
local mobs_griefing = mobs_mc.is_mob_griefing_enabled("wither")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Wither.
------------------------------------------------------------------------

local wither_def = {
	description = S("Wither"),
	type = "monster",
	_spawn_category = "misc",
	hp_max = 600,
	hp_min = 600,
	xp_min = 50,
	xp_max = 50,
	head_swivel = "head",
	bone_eye_height = 0.625,
	armor = {undead = 80, fleshy = 100},
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 3.49, 0.45},
	doll_size_override = { x = 1.2, y = 1.2 },
	visual = "mesh",
	mesh = "mobs_mc_wither.b3d",
	textures = {
		{
			"mobs_mc_wither_invulnerable.png",
			"mobs_mc_wither_armor.png",
		},
	},
	visual_size = {x=4, y=4},
	movement_speed = 5.0,
	airborne_speed = 5.0,
	_airborne_agile = true,
	sounds = {
		shoot_attack = "mobs_fireball",
		distance = 60,
	},
	jump_height = 10,
	fly = true,
	makes_footstep_sound = false,
	can_ride_cart = false,
	can_ride_boat = false,
	can_despawn = false,
	drops = {
		{
			name = "mcl_mobitems:nether_star",
			chance = 1,
			min = 1,
			max = 1,
		},
	},
	_mcl_freeze_damage = 0,
	lava_damage = 0,
	fire_damage = 0,
	attack_type = "null",
	arrow = "mobs_mc:wither_skull",
	reach = 5,
	shoot_offset = 0.3,
	_projectile_gravity = false,
	animation = {
		stand_speed = 12,
		stand_start = 20, stand_end = 40,
		charge_speed = 12,
		charge_start = 40, charge_end = 46,
		charge_loop = false,
	},
	harmed_by_heal = true,
	is_boss = true,
	airborne = true,
	tracking_distance = 64,
	view_range = 40,
	gravity_drag = 0.6,
	fall_damage = 0,
	slowdown_nodes = {},
	particlespawners = {
		{
			amount = 40,
			time = 0,
			minpos = vector.new (-1.0,1.5,-1.0),
			maxpos = vector.new (1.0,3.4,1.0),
			minvel = vector.new (-0.05,0.65,-0.05),
			maxvel = vector.new (0.05,0.60,0.05),
			minexptime = 1.9,
			maxexptime = 2.5,
			minsize = 0.8,
			maxsize = 1.5,
			glow = 5,
			collisiondetection = true,
			collision_removal = true,
			texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
		},
	},
}

------------------------------------------------------------------------
-- Wither mechanics, combat and AI.
------------------------------------------------------------------------

local WITHER_INIT_BOOM = 7
local WITHER_DESCENT_BOOM = 7

local function wither_unstuck (self, xz_exp)
	local pos = self.object:get_pos()
	if mobs_griefing then
		local col = self.collisionbox
		local pos1 = vector.offset(pos, col[1] - xz_exp, col[2], col[3] - xz_exp)
		local pos2 = vector.offset(pos, col[4] + xz_exp, col[5], col[6] + xz_exp)
		for z = pos1.z, pos2.z do for y = pos1.y, pos2.y do for x = pos1.x, pos2.x do
			local npos = vector.new(x,y,z)
			local name = core.get_node(npos).name
			if name ~= "air" then
				local ndef = core.registered_nodes[name]
				if ndef and ndef._mcl_hardness and ndef._mcl_hardness >= 0 and
				(ndef.can_dig == nil or ndef.can_dig(npos)) and
				core.get_item_group(name, "wither_immune") == 0 then
					core.remove_node(npos)
					local drops = core.get_node_drops(name, "")
					if drops then
						for _, item in pairs(drops) do
							core.add_item(npos, item)
						end
					end
				end
			end
		end end end
	end
end

local function wither_register_damage (self)
	local ws = self._wither_state
	local health = self.health

	if ws.previous_health_threshold - health
		> ws.firerate_reduction_threshold then
		ws.firerate = ws.firerate * 0.5
		ws.previous_health_threshold
			= ws.previous_health_threshold - ws.firerate_reduction_threshold
	end
	if health < ws.half_health and ws.phase == 0 then
		ws.phase = 1
		ws.air_attack = false
		ws.pending_explode = true
		ws.firerate = 1.0
		ws.default_attack_cooldown = ws.default_attack_cooldown * 2
	end
	if ws.block_destruction_remaining == 0 then
		ws.block_destruction_remaining = 1
	end
end

function wither_def:receive_damage (mcl_reason, damage)
	if self._spawning then
		return false
	end
	if mcl_reason.direct then
		local ent = mcl_reason.direct:get_luaentity ()
		if ent and self._arrow_resistant and ent._is_arrow then
			return false
		end
	end
	if mob_class.receive_damage (self, mcl_reason, damage) then
		wither_register_damage (self)
		return true
	end
end

function wither_def:on_spawn ()
	-- Adjust maximum health by one of the following factors,
	-- contingent on difficulty:
	--
	--   - Hard: 1.0
	--   - Normal: 0.75
	--   - Easy: 0.5

	local properties = self.object:get_properties ()
	local health_factor = 1.0 - (3 - mcl_vars.difficulty) * 0.25
	properties.hp_max = math.max (0.5, health_factor) * properties.hp_max
	self.object:set_properties ({
			hp_max = properties.hp_max,
	})
	self.health = properties.hp_max
	self.hp_max = properties.hp_max

	core.sound_play("mobs_mc_wither_spawn", {gain=1.0})
	self._custom_timer = 0.0
	self._death_timer = 0.0
	self._health_old = properties.hp_max
	self._spawning = 10
	return true
end

function wither_def:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end

	-- Restore the max health calculated at spawn time, which is
	-- lost when the object is unloaded.
	if self.hp_max then
		self.object:set_properties ({
				hp_max = self.hp_max,
		})
		self.health = math.min (self.health, self.hp_max)
	end

	local properties = self.object:get_properties ()
	if not self._wither_state then
		-- Upgrade old withers.
		self._wither_state = {
			-- Whether to explode and spawn wither skeletons upon
			-- contact with the ground.
			pending_explode = false,
			-- Number of ticks remaining till blocks should be
			-- destroyed in response to damage.
			block_destruction_remaining = 0,
			-- Direction to target during charge.
			dir_to_target = nil,
			-- Number of seconds remaining in this charge.
			charge_time = 0,
			-- Number of seconds remaining till charge begins.
			charge_buildup = 0,
			-- Interval in seconds between firing of skulls.
			firerate = 1,
			-- Cooldown period remaining after a round of skulls
			-- was fired.
			attack_cooldown = 0,
			-- Default cooldown period after a round of skulls is
			-- fired.  Multiplied by two after this wither reaches
			-- half health.
			default_attack_cooldown = 2,
			-- Whether wither ought to fly to a position near the
			-- player.
			wants_to_move = false,
			-- Number of seconds till skulls may be fired again.
			shoot_delay = 1,
			-- Counter which upon elapsing will prompt an attempt
			-- to fire a skull.
			time_to_discharge = 1,
			-- Health threshold at which to switch phases.
			half_health = properties.hp_max / 2,
			-- Change in health that should prompt
			-- a reduction in shelling rate.
			firerate_reduction_threshold
				= properties.hp_max / 6,
			-- Recentest value to trigger such a
			-- reduction.
			previous_health_threshold
				= properties.hp_max,
			-- Number of skulls fired in total.  Every fourth
			-- skull should be blue.
			skulls_fired = 0,
			-- Time spent idling.
			time_inactive = 0,
			-- Flag indicating that the attack cooldown was
			-- previously set in response to the discharge of a
			-- blue skull.
			blue_skull_fired = false,
			-- Whether wither remains airborne.
			air_attack = true,
			-- One if wither has entered the second phase of its
			-- combat routine.
			phase = 0,
			-- Metadata for auxiliary heads.
			aux_heads = {
				-- Left.
				{
					-- Time remaining till next
					-- attempt to fire a skull at
					-- random.
					next_update = 0,
					-- Number of attempts elapsed
					-- since skulls were last
					-- fired from this head.
					idle_update = 0,
					bone = "minihead.left",
				},
				-- Right.
				{
					-- Time remaining till next
					-- attempt to fire a skull at
					-- random.
					next_update = 0,
					-- Number of attempts elapsed
					-- since skulls were last
					-- fired from this head.
					idle_update = 0,
					bone = "minihead.right",
				},
			},
		}
	end
	return true
end

-- blast damage to entities nearby
local function blast_damage(pos, radius, source)
	radius = radius * 2

	for obj in core.objects_inside_radius(pos, radius) do

		local obj_pos = obj:get_pos()
		local dist = vector.distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = math.floor((4 / dist) * radius)

		-- punches work on entities AND players
		obj:punch(source, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = damage},
		}, vector.direction(pos, obj_pos))
	end
end

function wither_def:safe_boom (pos, strength, no_remove)
	core.sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	blast_damage(pos, radius, self.object)
	mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end

function wither_def:do_custom (dtime, moveresult)
	if self._spawning then
		if not self._spw_max then self._spw_max = self._spawning end
		self._spawning = self._spawning - dtime
		local bardef = {
			color = "dark_purple",
			text = S ("Wither"),
			percentage = math.floor((self._spw_max - self._spawning) / self._spw_max * 100),
		}

		local pos = self.object:get_pos()
		for player in mcl_util.connected_players() do
			local d = vector.distance(pos, player:get_pos())
			if d <= 80 then
				mcl_bossbars.add_bar(player, bardef, true, d)
			end
		end
		self:set_yaw (self._spawning * math.pi * 5)
		self:rotate_step (dtime)

		local value = (self._spawning / self._spw_max)
		self.object:set_texture_mod (table.concat ({
			"^[colorize:#ffffff:", 128 + math.floor (value * 128),
		}))

		local v = self.object:get_velocity ()
		v.y = v.y * 0.6
		self.object:set_velocity (v)

		if self._spawning <= 0 then
			if mobs_griefing and not core.is_protected(pos, "") then
				mcl_explosions.explode(pos, WITHER_INIT_BOOM, { drop_chance = 1.0 }, self.object)
			else
				self:safe_boom (pos, WITHER_INIT_BOOM, true)
			end
			self.object:set_texture_mod ("")
			self._spawning = nil
			self._spw_max = nil
		else
			return false
		end
	end

	self._custom_timer = self._custom_timer + dtime
	if self._custom_timer > 1 then
		-- Only heal if there are no players in a 100 block
		-- radius.
		local player
		for object in core.objects_inside_radius (self.object:get_pos (), 100) do
			if object:is_player () then
				player = object
				break
			end
		end
		if not player then
			self.health = math.min(self.health + 1, self.object:get_properties().hp_max)
		end
		self._custom_timer = self._custom_timer - 1
	end

	if self._wither_state.phase == 1 then
		self.base_texture = {
			"mobs_mc_wither.png",
			"mobs_mc_wither_armor.png",
		}
		self._arrow_resistant = true
	else
		self.base_texture = {
			"mobs_mc_wither.png",
			"blank.png",
		}
		self._arrow_resistant = false
	end

	self:set_textures (self.base_texture)
	mcl_bossbars.update_boss(self.object, "Wither", "dark_purple")
end

function spawn_one_skeleton (object, aa, bb, self_pos)
	local nodes = core.find_nodes_in_area_under_air (aa, bb, {"group:solid"})
	if #nodes > 0 then
		for i = 1, 10 do
			local nodepos = nodes[math.random (#nodes)]

			-- Verify that there is three blocks worth of
			-- clearance above this node.
			local copy = vector.offset (nodepos, 0, 1, 0)
			local node = core.get_node (copy)
			local def1 = core.registered_nodes[node.name]
			copy.y = copy.y + 1
			node = core.get_node (copy)
			local def2 = core.registered_nodes[node.name]
			copy.y = copy.y + 1
			node = core.get_node (copy)
			local def3 = core.registered_nodes[node.name]

			if def1 and not def1.walkable
				and def2 and not def2.walkable
				and def3 and not def3.walkable then
				copy.y = nodepos.y + 1
				local entity
					= core.add_entity (copy, "mobs_mc:witherskeleton")
				-- Prevent summoned skeletons from
				-- attacking their invoker.
				if entity then
					local luaentity = entity:get_luaentity ()
					luaentity._wither_parent = object
				end
				return
			end
		end
	end
end

function wither_def:spawn_skeletons (self_pos)
	if mcl_vars.difficulty <= 1 then
		return
	end
	local aa = vector.offset (self_pos, -7, -2, -7)
	local bb = vector.offset (self_pos, 7, 2, 7)
	-- Search for valid spawn positions within a 15x4x15 area
	-- around this mob's position on which to spawn wither
	-- skeletons.
	spawn_one_skeleton (self.object, aa, bb, self_pos)
	spawn_one_skeleton (self.object, aa, bb, self_pos)
	spawn_one_skeleton (self.object, aa, bb, self_pos)
	spawn_one_skeleton (self.object, aa, bb, self_pos)
end

function wither_def:ranged_attack (ws, self_pos, target_pos)
	ws.time_inactive = 0
	ws.skulls_fired = ws.skulls_fired + 1
	local is_blue_skull = (ws.skulls_fired % 4) == 0

	if is_blue_skull then
		self.arrow = "mobs_mc:wither_skull_strong"
	else
		self.arrow = "mobs_mc:wither_skull"
	end
	self:discharge_ranged (self_pos, target_pos)

	if is_blue_skull then
		-- Trigger an attack or repath after firing every blue
		-- skull, or if no longer airborne, every second blue
		-- skull.
		ws.attack_cooldown = ws.default_attack_cooldown
		if not ws.air_attack then
			if ws.blue_skull_fired then
				-- Reset cooldown.
				ws.attack_cooldown = 0
				ws.shoot_delay = 3
			end
			ws.blue_skull_fired = not ws.blue_skull_fired
		end
	end
end

local function may_discharge (self, ws)
	return ws.attack_cooldown == 0
		and not ws.wants_to_move
		and ws.charge_time == 0
		and ws.charge_buildup == 0
		and ws.shoot_delay == 0
		and (self.attack and self.attack:get_pos ())
end

local function wither_strafe_above_target (self, self_pos, dtime)
	-- The gist of Minecraft's logic is to generate a random
	-- position within a 10x1x10 cube surrounding the target on
	-- the X axis and around itself on the Y axis.  Instead,
	-- maintaining a vertical distance from the target is the
	-- responsibility of wither_def:attack_null.

	local ws = self._wither_state
	if self._wither_strafing then
		if self:navigation_finished () then
			ws.wants_to_move = false
			ws.shoot_delay = 1.0
			self._wither_strafing = false
			return false
		end
		return true
	elseif ws.wants_to_move
		and self.attack
		and is_valid (self.attack) then
		local target_pos = self.attack:get_pos ()
		local rx, rz = math.random (0, 20) - 10, math.random (0, 20) - 10
		local dest = vector.offset (target_pos, rx, 0, rz)
		dest.y = self_pos.y

		if self:gopath (dest, 12 / self.movement_speed) then
			self._wither_strafing = true
			return true
		end
	end
	return false
end

local function wither_ascend (self, self_pos, target_pos)
	local ws = self._wither_state
	local v = self.object:get_velocity ()
	if ws.charge_buildup > 0 or ws.charge_time > 0 then
		if math.abs (v.y) < 0.0009 then
			v.y = 0
		end
	elseif ws.pending_explode then
		v.y = v.y - 20.0
	elseif self.movement_goal == "go_pos" then
		v.y = (self.movement_target.y - self_pos.y)
	elseif ws.air_attack and self.attack then
		if v.y < 0 then
			v.y = 0
		end

		if self_pos.y - 5 <= target_pos.y then
			v.y = (10 - v.y) * 0.6 + v.y
		end
	end
	self.object:set_velocity (v)
end

function wither_def:attack_null (self_pos, dtime, target_pos, line_of_sight)
	-- Initialize attack state.
	if not self.attacking then
		self.attacking = true
		self._wither_strafing = false
	end
end

function wither_def:float_around (self_pos, dtime)
	self.ai_idle_time = self.ai_idle_time + dtime
	self:check_pace (self_pos, dtime)
end

local WITHER_CHARGE_DAMAGE = 15

function wither_def:ranged_attack_from_head (idx, ws, self_pos, target_pos, blue)
	local yaw_off = self:get_yaw () + math.pi / 2
	local distance = idx == 2 and 0.65 or -0.65
	local x, z = -math.sin (yaw_off) * distance, math.cos (yaw_off) * distance
	local pos = vector.offset (self_pos, x, -0.1, z)

	if blue then
		self.arrow = "mobs_mc:wither_skull_strong"
	else
		self.arrow = "mobs_mc:wither_skull"
	end
	self:discharge_ranged (pos, target_pos)
end

local FOURTY_DEG = math.rad (40)
local TEN_DEG = math.rad (10)
local object_targetable_p = mcl_mobs.object_targetable_p

function wither_def:run_ai (dtime, moveresult)
	local self_pos = self.object:get_pos ()
	local ws = self._wither_state
	local did_charge = false

	if self:check_attack (self_pos, dtime) then
		self.ai_idle_time = 0
	end
	if (not ws.air_attack or not self.attack)
		and ws.charge_time == 0 then
		if self.attack then
			self.pace_interval = 0.0
			self.pace_chance = 1
		else
			self.pace_interval = 5
			self.pace_chance = 120
		end
		self:float_around (self_pos, dtime)
	end

	if self.dead then
		return
	end

	local target = self.attack
	local target_pos = target and target:get_pos ()

	if target_pos then
		wither_ascend (self, self_pos, target_pos)
		wither_strafe_above_target (self, self_pos, target_pos)
	end

	if ws.shoot_delay > 0 then
		ws.shoot_delay = math.max (0, ws.shoot_delay - dtime)
	end
	if ws.charge_time > 0 then
		ws.charge_time = math.max (0, ws.charge_time - dtime)
		self:cancel_navigation ()

		if ws.dir_to_target then
			local v = self.object:get_velocity ()
			if ws.charge_time == 0 then
				-- Arrest movement immediately after
				-- charge completes.
				v.x = 0
				v.z = 0
				ws.dir_to_target = nil
				self:set_animation ("stand")
			else
				v.x = ws.dir_to_target.x * 40
				v.z = ws.dir_to_target.z * 40
				did_charge = true
			end
			self.object:set_velocity (v)
		end
	end
	if ws.pending_explode
		and (moveresult.touching_ground
		     or (self._immersion_depth or 0) > 0) then
		mcl_explosions.explode (vector.offset (self_pos, 0, self:get_eye_height (), 0),
					WITHER_DESCENT_BOOM, {drop_chance = 1.0}, self.object)
		self:spawn_skeletons (self_pos)
		ws.pending_explode = false
	end
	if ws.time_to_discharge > 0 then
		ws.time_to_discharge = math.max (0, ws.time_to_discharge - dtime)
		if ws.time_to_discharge == 0 then
			if may_discharge (self, ws) then
				-- Cancel navigation and halt.
				self:cancel_navigation ()
				self:halt_in_tracks ()
				self:ranged_attack (ws, self_pos, target_pos)
			end
			ws.time_to_discharge = ws.firerate
		end
	end

	-- Process idle heads.
	for idx = 1, 2 do
		local head = ws.aux_heads[idx]
		local yaw, pitch
		head.next_update = head.next_update - dtime
		local name = "_wither_target_" .. idx
		local attack = self[name]
		local attack_pos = attack and attack:get_pos ()

		-- Turn this head towards any creature it is attacking.
		if attack_pos then
			-- Look at this target.
			local head_x, head_y, head_z, base_yaw
			local head_off = idx == 1 and -0.65 or 0.65

			base_yaw = self:get_yaw () + math.pi / 2
			head_x = self_pos.x + head_off * -math.sin (base_yaw)
			head_y = self_pos.y + 0.6
			head_z = self_pos.z + head_off * math.cos (base_yaw)

			local target_x = attack_pos.x
			local target_y = attack_pos.y + mcl_util.target_eye_height (attack)
			local target_z = attack_pos.z
			local dx, dy, dz = target_x - head_x,
				target_y - head_y,
				target_z - head_z
			local x_magnitude = math.sqrt (dx * dx + dz * dz)
			yaw = math.atan2 (dx, dz) + self:get_yaw ()
			pitch = -math.atan2 (dy, x_magnitude)
		else
			yaw = 0
			pitch = 0
		end

		if head.next_update <= 0 then
			head.next_update = 0.5 + math.random () * 0.5
			if mcl_vars.difficulty >= 2 and head.idle_update >= 15 then
				head.idle_update = 0
				local random = {
					x = self_pos.x + math.random () * 20 - 10,
					y = self_pos.y + math.random () * 10 - 5,
					z = self_pos.z + math.random () * 20 - 10,
				}
				self:ranged_attack_from_head (idx, ws, self_pos, random, true)
			end
			head.idle_update = head.idle_update + 1

			if attack then
				if attack_pos
					and self:should_continue_to_attack (attack)
					and vector.distance (self_pos, attack_pos) <= 30
					and self:target_visible (self_pos, attack) then
					head.next_update = 2 + math.random ()
					head.idle_update = 0
					self:ranged_attack_from_head (idx, ws, self_pos, attack_pos)
				else
					self[name] = nil
				end
			else
				local other_head = idx == 1 and 2 or 1
				local other_name = "_wither_target_" .. other_head
				for object in core.objects_inside_radius (self_pos, 20) do
					local pos = object:get_pos ()
					local entity = object:get_luaentity ()
					if object_targetable_p (object)
						and (not entity or not entity.harmed_by_heal)
						and self:test_object_and_restriction (object, pos)
						and self:target_visible (self_pos, object)
						and object ~= self.attack
						and object ~= self[other_name] then
						self[name] = object
						break
					end
				end
			end
		end

		-- Interpolate head yaw and pitch.
		if yaw ~= head.yaw or pitch ~= head.pitch then
			head.yaw
				= mcl_mobs.clip_rotation (head.yaw or 0, yaw, FOURTY_DEG)
			head.pitch
				= mcl_mobs.clip_rotation (head.pitch or 0, pitch, TEN_DEG)
		end
		local vec = vector.new (head.pitch, head.yaw, 0)
		local info = {
			rotation = {
				vec = vec,
				absolute = true,
			},
		}
		self.object:set_bone_override (head.bone, info)
	end

	if ws.block_destruction_remaining > 0 then
		ws.block_destruction_remaining
			= math.max (0, ws.block_destruction_remaining - dtime)
		if ws.block_destruction_remaining == 0 then
			wither_unstuck (self, 1, 1)
		end
	end

	if ws.attack_cooldown > 0 then
		ws.attack_cooldown = math.max (0, ws.attack_cooldown - dtime)
		if ws.attack_cooldown == 0 then
			if not ws.air_attack then
				-- Prepare to charge.
				ws.charge_buildup = 1.0
				if target_pos then
					ws.dir_to_target = vector.direction (self_pos, target_pos)
					local yaw = math.atan2 (ws.dir_to_target.z,
								ws.dir_to_target.x) - math.pi / 2
					self:set_yaw (yaw)
					self:set_animation ("charge")
				end
			else
				-- Switch positions.
				ws.wants_to_move = true
			end
		end
	end

	if did_charge then
		wither_unstuck (self, 2, 0)

		-- Damage players and mobs within a 3x3 radius.
		for object in core.objects_inside_radius (self_pos, 3) do
			local entity = object:get_luaentity ()
			if object ~= self.object
				and (object:is_player () or (entity and entity.is_mob)) then
				mcl_util.deal_damage (object, WITHER_CHARGE_DAMAGE, {type = "explosion"})
			end
		end
	end

	if ws.charge_buildup > 0 then
		self.pacing = false
		self:cancel_navigation ()
		self:halt_in_tracks ()
		ws.charge_buildup = math.max (0, ws.charge_buildup - dtime)
		if ws.charge_buildup == 0 then
			ws.charge_time = 0.5
		end
	end

	if may_discharge (self, ws) then
		ws.time_inactive = ws.time_inactive + dtime
		if ws.time_inactive >= 5 then
			ws.time_inactive = 0
			-- Jab attack logic: either switch positions or begin
			-- charging.
			ws.attack_cooldown = 1
		end
	end
end

local function is_not_undead (self, self_pos, obj, entity)
	return not entity or not entity.harmed_by_heal
end

wither_def._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("entity", is_not_undead,
					    nil, nil, nil),
}

mcl_mobs.register_mob ("mobs_mc:wither", wither_def)

------------------------------------------------------------------------
-- Wither Skull.
------------------------------------------------------------------------

local wither_rose_soil = {
	"group:grass_block",
	"mcl_core:dirt",
	"mcl_core:coarse_dirt",
	"mcl_nether:netherrack",
	"group:soul_block",
	"mcl_mud:mud",
	"mcl_lush_caves:moss",
}

local function spawn_wither_rose (obj)
	local n = core.find_node_near(obj:get_pos(),2,wither_rose_soil)
	if n then
		local p = vector.offset(n,0,1,0)
		if core.get_node(p).name == "air" then
			if not ( mobs_griefing and core.place_node(p,{name="mcl_flowers:wither_rose"}) ) then
				core.add_item(p,"mcl_flowers:wither_rose")
			end
		end
	end
end

local skull_def = {
	visual = "cube",
	visual_size = {x = 0.35, y = 0.35},
	textures = {
		"mobs_mc_wither_projectile.png^[verticalframe:6:0", -- top
		"mobs_mc_wither_projectile.png^[verticalframe:6:1", -- bottom
		"mobs_mc_wither_projectile.png^[verticalframe:6:2", -- left
		"mobs_mc_wither_projectile.png^[verticalframe:6:3", -- right
		"mobs_mc_wither_projectile.png^[verticalframe:6:4", -- back
		"mobs_mc_wither_projectile.png^[verticalframe:6:5", -- front
	},
	velocity = 17,
	rotate = 90,
	_lifetime = 500,
	_explosioninfo = {},
	on_punch = function() end,

	-- direct hit
	hit_player = function(self, player)
		local pos = vector.new(self.object:get_pos())
		if mcl_vars.difficulty >= 2 then
			local duration = mcl_vars.difficulty == 2 and 10 or 40
			mcl_potions.give_effect_by_level ("withering", player, 2,
							  duration)
		end
		mcl_util.deal_damage (player, 8.0, {
					      source = self._shooter,
					      direct = self.object,
					      type = "wither_skull",
		})
		-- This must come before mcl_explosions.explode, which
		-- is liable to remove this object.
		local v = self.object:get_velocity ()
		v.y = 0
		local dir = vector.normalize (v)
		if mobs_griefing and not core.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, self._explosioninfo, self.object)
		else
			wither_def.safe_boom (self, pos, 1) --need to call it this way bc self is the "arrow" object here
		end
		if player:get_hp() <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(player)
		else
			mcl_player.player_knockback (player, self.object, dir, nil, 8.0)
		end
	end,

	hit_mob = function(self, mob)
		local pos = vector.new (self.object:get_pos())
		if mcl_vars.difficulty >= 2 then
			local duration = mcl_vars.difficulty == 2 and 10 or 40
			mcl_potions.give_effect_by_level ("withering", mob, 2,
							  duration)
		end
		mcl_util.deal_damage (mob, 8.0, {
					      source = self._shooter,
					      direct = self.object,
					      type = "wither_skull",
		})
		local v = self.object:get_velocity ()
		v.y = 0
		local dir = vector.normalize (v)
		if mobs_griefing and not core.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, self._explosioninfo, self.object)
		else
			wither_def.safe_boom (self, pos, 1, true) --need to call it this way bc self is the "arrow" object here
		end
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(mob)
		end
		if l then
			l:projectile_knockback (1, dir)
		end
	end,

	-- node hit, explode
	hit_node = function(self, pos)
		if mobs_griefing and not core.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, self._explosioninfo, self.object)
		else
			wither_def.safe_boom (self, pos, 1, true) --need to call it this way bc self is the "arrow" object here
		end
	end
}

mcl_mobs.register_arrow("mobs_mc:wither_skull", skull_def)

strong_skull_def = table.copy (skull_def)
strong_skull_def.velocity = 12
strong_skull_def.redirectable = true
strong_skull_def.explosioninfo = {
	drop_chance = 1.0,
	max_blast_resistance = 0,
}
strong_skull_def.textures = {
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:0", -- top
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:1", -- bottom
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:2", -- left
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:3", -- right
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:4", -- back
	"mobs_mc_wither_projectile_strong.png^[verticalframe:6:5", -- front
}

mcl_mobs.register_arrow("mobs_mc:wither_skull_strong", strong_skull_def)

--Spawn egg
mcl_mobs.register_egg ("mobs_mc:wither", S("Wither"), "#4f4f4f", "#4f4f4f", 0, true)
