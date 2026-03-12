-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models -hi 22i ~jordan4ibanez
-- blaze.lua partial copy of mobs_mc/ghast.lua

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### BLAZE
--###################

local blaze = {
	description = S("Blaze"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 20,
	hp_max = 20,
	xp_min = 10,
	xp_max = 10,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.79, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_blaze.b3d",
	head_swivel = "head.control",
	bone_eye_height = 4,
	textures = {
		{"mobs_mc_blaze.png"},
	},
	armor = {
		fleshy = 100,
		snowball_vulnerable = 100,
		water_vulnerable = 100,
	},
	visual_size = {x=3, y=3},
	sounds = {
		shoot_attack = "mobs_fireball",
		random = "mobs_mc_blaze_breath",
		death = "mobs_mc_blaze_died",
		damage = "mobs_mc_blaze_hurt",
		distance = 16,
	},
	movement_speed = 4.6,
	damage = 6,
	reach = 2,
	drops = {
		{
			name = "mcl_mobitems:blaze_rod",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
	},
	animation = {
		stand_speed = 25,
		stand_start = 0,
	        stand_end = 100,
	},
	-- MC Wiki: takes 1 damage every half second while in water
	water_damage = 2,
	_mcl_freeze_damage = 5,
	lava_damage = 0,
	fire_damage = 0,
	fall_damage = 0,
	gravity_drag = 0.6,
	attack_type = "null",
	arrow = "mobs_mc:blaze_fireball",
	makes_footstep_sound = false,
	glow = 14,
	fire_damage_resistant = true,
	view_range = 48.0,
	tracking_distance = 48.0,
	_projectile_gravity = false,
}

------------------------------------------------------------------------
-- Blaze visuals.
------------------------------------------------------------------------

local function blaze_set_charged (self, charged)
	if charged then
		mcl_burning.set_on_fire (self.object, math.huge)
	else
		mcl_burning.extinguish (self.object)
	end
end

function blaze:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self.object:set_animation ({
		x = self.animation.stand_start,
		y = self.animation.stand_end,
	})
	return true
end

function blaze:set_animation (anim, fixed_frame)
	return
end

function blaze:do_custom (dtime)
	local pos = self.object:get_pos()

	if not self._height_diff_tolerance or self._height_diff_tolerance_age >= 5 then
		self._height_diff_tolerance = mcl_util.dist_triangular (0.5, 6.891)
		self._height_diff_tolerance_age = 0
	end
	self._height_diff_tolerance_age = self._height_diff_tolerance_age + dtime

	if not self:check_timer("blaze_particles", mcl_util.float_random(0.5, 2)) then return end

	core.add_particle({
			pos = {x = pos.x+mcl_util.float_random(-0.7,0.7) * math.random()/2, y = pos.y+mcl_util.float_random(0.7,1.2), z = pos.z+mcl_util.float_random(-0.7,0.7) * math.random()/2},
			velocity = {x=0, y = mcl_util.float_random(0.5, 2), z=0},
			expirationtime = math.random(),
			size = mcl_util.float_random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#2c2c2c:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
	})
	core.add_particle({
			pos = {x = pos.x+mcl_util.float_random(-0.7,0.7)* math.random()/2, y = pos.y+mcl_util.float_random(0.7,1.2), z = pos.z+mcl_util.float_random(-0.7,0.7) * math.random()/2},
			velocity = {x=0, y = mcl_util.float_random(0.5, 2), z=0},
			expirationtime = math.random(),
			size = mcl_util.float_random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#424242:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
	})
	core.add_particle({
			pos = {x = pos.x+mcl_util.float_random(-0.7,0.7)*math.random()/2, y = pos.y+mcl_util.float_random(0.7,1.2), z = pos.z+mcl_util.float_random(-0.7,0.7)*math.random()/2},
			velocity = {x=0, y = mcl_util.float_random(0.5,2), z=0},
			expirationtime = math.random(),
			size = mcl_util.float_random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#0f0f0f:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
	})

	if not self.attack then
		blaze_set_charged (self, false)
	end
end

function blaze:set_animation_speed (custom_speed)
	self.object:set_animation_frame_speed (25)
end

------------------------------------------------------------------------
-- Blaze AI.
------------------------------------------------------------------------

local TICKS_PER_SEC = 20
local mathpow = math.pow

local function lerp1d_scaled (u, dtime, s1, s2)
	local x = dtime * TICKS_PER_SEC
	local v = -(s2 * mathpow (1 - u, x))
		+ s1 * mathpow (1 - u, x) + s2
	return v
end

function blaze:attack_null (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		-- Initialize fields used during the attack.
		self._visible_for = 0
		self._phase_remaining = 0
		self._phase = 0 -- 1: charging; 2 to 4: shooting; 5/0: recharge.
		blaze_set_charged (self, false)
		self.attacking = true
	end

	if line_of_sight then
		self._visible_for = self._visible_for + dtime
	else
		self._visible_for = 0
	end
	self._phase_remaining
		= self._phase_remaining - dtime

	-- Move above target if necessary
	local target_eye_height
		= target_pos.y + mcl_util.target_eye_height (self.attack)
	local self_eye_height
		= self_pos.y + self:get_eye_height ()
	if target_eye_height > self_eye_height + self._height_diff_tolerance then
		local v = self.object:get_velocity ()
		v.y = lerp1d_scaled (0.3, dtime, v.y, 6.0)
		self.object:set_velocity (v)
	end

	local distance = vector.distance (self_pos, target_pos)
	-- Resort to melee attacks if the target has approached too
	-- near.
	if distance < 2.0 then
		if not line_of_sight then
			return
		end

		if self._phase_remaining <= 0 then
			self._phase_remaining = 1
			self.attack:punch (self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {
					fleshy = self.damage,
				},
			}, vector.direction (self_pos, target_pos))
		end
		self:go_to_pos (target_pos)
	elseif distance < self.tracking_distance and line_of_sight then
		if self._phase_remaining > 0 then
			return
		end

		-- Proceeed to next phase.
		self._phase = self._phase + 1
		if self._phase == 1 then
			-- Charge for three seconds.
			blaze_set_charged (self, true)
			self._phase_remaining = 3
		elseif self._phase <= 4 then
			-- Shoot fireballs.
			local dx, dy, dz
			local props = self.attack:get_properties ()
			local cbox = props.collisionbox
			dx = target_pos.x - self_pos.x
			dy = (target_pos.y + cbox[2] + (cbox[5] - cbox[2]) / 2)
				- (self_pos.y + 0.9)
			dz = target_pos.z - self_pos.z

			local scatter = math.sqrt (distance) / 2
			local vec = vector.normalize ({
				x = mcl_util.dist_triangular (dx, 2.297 * scatter),
				y = dy,
				z = mcl_util.dist_triangular (dz, 2.297 * scatter),
			})
			local pos = vector.offset (self_pos, 0, 0.9, 0)
			local arrow = core.add_entity (pos, self.arrow)
			if arrow then
				local luaentity = arrow:get_luaentity ()
				self:mob_sound ("shoot_attack")
				arrow:set_velocity (vector.multiply (vec, luaentity.velocity))
				luaentity.switch = 1
				luaentity.owner_id = tostring (self.object)
				luaentity._shooter = self.object
				luaentity._saved_shooter_pos = vector.copy (self_pos)
			end
			self._phase_remaining = 0.3
		else
			-- 5 second timeout.
			self._phase_remaining = 5
			self._phase = 0
			blaze_set_charged (self, false)
		end
	elseif self._visible_for < 0.25 then
		-- Shift around slightly if the target was in view
		-- only briefly.
		self:go_to_pos (target_pos)
	end
end

blaze.gwp_penalties = table.copy (mob_class.gwp_penalties)
blaze.gwp_penalties.WATER = -1.0
blaze.gwp_penalties.LAVA = 8.0
blaze.gwp_penalties.DANGER_FIRE = 0.0
blaze.gwp_penalties.DAMAGE_FIRE = 0.0

blaze.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

blaze._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (nil, true, {"mobs_mc:blaze",}),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:blaze", blaze)

------------------------------------------------------------------------
-- Blaze spawning.
------------------------------------------------------------------------

local blaze_spawner = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:blaze",
	weight = 10,
	pack_min = 2,
	pack_max = 3,
	max_artificial_light = 11,
	max_light = 11,
	biomes = {},
	structures = {
		"mcl_levelgen:nether_fortress",
	},
})

mcl_mobs.register_spawner (blaze_spawner)

mcl_mobs.register_egg ("mobs_mc:blaze", S("Blaze"), "#f6b201", "#fff87e", 0)

------------------------------------------------------------------------
-- Small Fireball.
------------------------------------------------------------------------

mcl_mobs.register_arrow ("mobs_mc:blaze_fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 24,
	collisionbox = {-.5, -.5, -.5, .5, .5, .5},
	_is_fireball = true,

	-- Direct hit, no fire... just plenty of pain
	hit_player = function (self, player)
		mcl_mobs.get_arrow_damage_func (5, "fireball") (self, player)
		mcl_burning.set_on_fire (player, 5)
	end,
	hit_mob = function (self, mob)
		mcl_mobs.get_arrow_damage_func (5, "fireball") (self, mob)
		mcl_burning.set_on_fire (mob, 5)
	end,
	hit_object = function(_, object)
		local lua = object:get_luaentity()
		if lua then
			if lua.name == "mcl_minecarts:tnt_minecart" then
				lua:on_activate_by_rail(2)
			end
		end
	end,

	-- Node hit, make fire
	hit_node = function(self, pos, node)
		if node == "air" then
			core.set_node(pos, {name = "mcl_fire:fire"})
		else
			if self._shot_from_dispenser and node == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos))
			end
			local v = vector.normalize(self.object:get_velocity())
			local crashpos = vector.subtract(pos, v)
			local crashnode = core.get_node(crashpos)
			local cndef = core.registered_nodes[crashnode.name]
			-- Set fire if node is air, or a replacable flammable node (e.g. a plant)
			if crashnode.name == "air" or
					(cndef and cndef.buildable_to and core.get_item_group(crashnode.name, "flammable") >= 1) then
				core.set_node(crashpos, {name = "mcl_fire:fire"})
			end
		end
	end
})
