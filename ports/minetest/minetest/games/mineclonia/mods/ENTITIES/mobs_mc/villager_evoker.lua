--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local posing_humanoid = mcl_mobs.posing_humanoid
local illager = mobs_mc.illager
local mob_griefing = mobs_mc.is_mob_griefing_enabled("evoker")
local is_valid = mcl_util.is_valid_objectref

--###################
--################### EVOKER
--###################

local pr = PcgRandom (os.time () * 666)

local evoker = table.merge (illager, table.merge (posing_humanoid, {
	description = S("Evoker"),
	type = "monster",
	_spawn_category = "monster",
	can_despawn = false,
	hp_min = 24,
	hp_max = 24,
	xp_min = 10,
	xp_max = 10,
	head_swivel = "head.control",
	bone_eye_height = 6.61948,
	head_eye_height = 2.2,
	curiosity = 10,
	collisionbox = {-0.4, 0, -0.4, 0.4, 1.95, 0.4},
	visual = "mesh",
	mesh = "mobs_mc_evoker.b3d",
	textures = {
		{
			"mobs_mc_evoker.png",
		},
	},
	makes_footstep_sound = true,
	movement_speed = 10,
	runaway_from = {
		"player",
	},
	drops = {
		{
			name = "mcl_core:emerald",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
		{
			name = "mcl_totems:totem",
			chance = 1,
			min = 1,
			max = 1,
		},
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40,
		walk_speed = 35,
		spellcast_speed = 20,
		spellcast_start = 41,
		spellcast_end = 61,
	},
	attack_type = "null",
	pace_bonus = 0.6,
	runaway_bonus_near = 1.0,
	runaway_bonus_far = 0.6,
	_banner_bone = "head",
	_banner_bone_position = vector.new (0, 0, -2.556729),
	tracking_distance = 12.0,
	view_range = 12.0,
	_humanoid_superclass = illager,
}))

------------------------------------------------------------------------
-- Evoker visuals.
------------------------------------------------------------------------

local MIN_VEL = vector.new (0, 0.6, 0)
local MAX_VEL = vector.new (0, 0.9, 0)
local MIN_POS_1 = vector.new (-0.6 - 0.2, 1.62, -0.2)
local MAX_POS_1 = vector.new (-0.6 + 0.2, 1.62, 0.2)
local MIN_POS_2 = vector.new (0.6 - 0.2, 1.62, -0.2)
local MAX_POS_2 = vector.new (0.6 + 0.2, 1.62, 0.2)
local Y_AXIS = vector.new (0, 1, 0)

function evoker:add_particlespawner (min_pos, max_pos)
	local self_pos = self.object:get_pos ()
	if self.jockey_vehicle then
		self_pos.y = self_pos.y + self._jockey_eye_offset
	end
	local yaw = self:get_yaw ()
	local min_pos = vector.rotate_around_axis (min_pos, Y_AXIS, yaw)
	local max_pos = vector.rotate_around_axis (max_pos, Y_AXIS, yaw)
	core.add_particlespawner ({
		amount = 15,
		time = 0.2,
		texture = self._cast_particle,
		exptime = {
			min = 0.2,
			max = 0.4,
		},
		pos = {
			min = vector.add (self_pos, min_pos),
			max = vector.add (self_pos, max_pos),
		},
		vel = {
			min = MIN_VEL,
			max = MAX_VEL,
		},
	})
end

function evoker:do_custom (dtime)
	posing_humanoid.do_custom (self, dtime)

	if self._casting_spell and self._cast_particle then
		if self:check_timer ("evoker_particles", 0.2) then
			self:add_particlespawner (MIN_POS_1, MAX_POS_1)
			self:add_particlespawner (MIN_POS_2, MAX_POS_2)
		end
	end
end

function evoker:who_are_you_looking_at ()
	if self._dont_stare then
		self._locked_object = nil
	elseif self._wololo and self._wololo_sheep
		and is_valid (self._wololo_sheep) then
		self._locked_object = self._wololo_sheep
	else
		mob_class.who_are_you_looking_at (self)
	end
end

local evoker_poses = {
	["default"] = {
		["leg.left"] = {},
		["leg.right"] = {},
	},
	["jockey"] = {
		["leg.left"] = {
			vector.zero (),
			vector.new (90, -30, 0),
			nil,
		},
		["leg.right"] = {
			vector.zero (),
			vector.new (90, 30, 0),
			nil,
		},
	},
}

evoker._arm_poses = evoker_poses

function evoker:select_arm_pose ()
	if not self.jockey_vehicle then
		return "default"
	else
		return "jockey"
	end
end

------------------------------------------------------------------------
-- Evoker combat routines.
------------------------------------------------------------------------

function evoker:ai_step (dtime)
	illager.ai_step (self, dtime)
	self:tick_combat_spells (dtime)
	if not self.attack then
		self._dont_stare = false
	end
	if self._wololo
		and self._wololo_sheep
		and is_valid (self._wololo_sheep) then
		self:look_at (self._wololo_sheep:get_pos ())
	else
		self._wololo_sheep = nil
	end
end

function evoker:attack_null (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self.attacking = true
	end

	self._dont_stare = false
	-- Avoid the target if it is a player and a spell is being
	-- cast.
	if not self._casting_spell and self.attack:is_player () then
		if self:navigation_finished () then
			local target
				= self:target_away_from (self_pos, target_pos)

			if target then
				local bonus = self.runaway_bonus_near
				self:gopath (target, bonus)
			end
		else
			local distance = vector.distance (self_pos, target_pos)
			local mob = self:mob_controlling_movement ()
			if distance < 7.0 then
				mob.gowp_velocity
					= mob.movement_speed * self.runaway_bonus_near
			else
				mob.gowp_velocity
					= mob.movement_speed * self.runaway_bonus_far
			end
		end
		self._dont_stare = true
		return
	elseif self._casting_spell then
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self:look_at (target_pos)
	end
end

------------------------------------------------------------------------
-- Evoker AI & spells.
------------------------------------------------------------------------

local function define_spell (def)
	local status_field = def.activity_name
	local cooldown_field = status_field .. "_cooldown"
	local particle = "mcl_particles_effect.png^[colorize:"
		.. def.particle_color .. ":255"

	return function (self, self_pos, dtime)
		if self[status_field] then
			local t = self._arm_time - dtime
			self._arm_time = math.max (0, t)

			if t <= 0 then
				self._cast_particle = nil
				self:set_animation ("stand")
				local t = math.max (self._cast_time - dtime, 0)
				self._cast_time = t
				local rc = def.step (self, self_pos, dtime, t)
				if not rc then
					self[cooldown_field] = def.interval
					self._casting_spell = nil
					self[status_field] = false
				end
				return rc
			else
				self:set_animation ("spellcast")
				self:cancel_navigation ()
				self:halt_in_tracks ()
				return true
			end
		else
			local t = (self[cooldown_field] or 0) - dtime
			self[cooldown_field] = math.max (0, t)
			if t <= 0 then
				if def.check_activate (self, self_pos, dtime) then
					self[status_field] = true
					self._casting_spell = status_field
					self._arm_time = def.arm_time
					self._cast_time = def.duration
					self._cast_particle = particle
					return status_field
				end
			end
			return false
		end
	end
end

evoker.define_spell = define_spell

function evoker:tick_combat_spells (dtime)
	local self_pos = self.object:get_pos ()
	local moveresult = self._moveresult

	if not self.attack then
		if self._active_activity ~= self._casting_spell then
			if self._casting_spell then
				self[self._casting_spell] = nil
			end
			self._active_spell_fn = nil
			self._casting_spell = nil
		end
		return
	end

	-- Proceed with the current spell if it is still in progress.
	if self._active_spell_fn
		and self._casting_spell
		and self[self._casting_spell] then
		self._active_spell_fn (self, self_pos, dtime, moveresult)
		return
	else
		-- Clear a number of fields otherwise.
		self._active_spell_fn = nil
		self._casting_spell = nil
		self._spell_particle = nil
	end

	local spells = table.copy (self._combat_spells)
	table.shuffle (spells)
	for _, fn in pairs (spells) do
		if fn (self, self_pos, dtime, moveresult) then
			self._active_spell_fn = fn
			break
		end
	end
end

local function is_walkable (nodepos)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and def.walkable
end

local function cbox_max_y (nodepos)
	local max_y = nil
	local boxes = core.get_node_boxes ("collision_box", nodepos)
	for _, box in ipairs (boxes) do
		max_y = math.max (max_y or 0, box[2], box[5])
	end
	return max_y or -0.5
end

function evoker:spawn_fang (x, z, miny, maxy, fangno, yaw)
	local v = vector.new (x, maxy, z)
	local nodepos = mcl_util.get_nodepos (v)
	local minpos = math.floor (miny + 0.5)
	local valid_nodepos = false
	repeat
		local surface = vector.offset (nodepos, 0, -1, 0)
		if is_walkable (surface) then
			if is_walkable (nodepos) then
				-- Deal with slabs and the like.
				nodepos.y = nodepos.y + cbox_max_y (nodepos)
			else
				nodepos.y = nodepos.y - 0.5
			end
			valid_nodepos = true
			break
		end
		nodepos.y = nodepos.y - 1
	until nodepos.y < minpos
	if valid_nodepos then
		local delay = (fangno - 1) / 20.0
		v.y = nodepos.y
		local fang = core.add_entity (v, "mobs_mc:evoker_fangs")

		if fang then
			local entity = fang:get_luaentity ()
			entity._startup_delay = delay
			entity._owner = self.object
			fang:set_yaw (yaw)
		end
	end
end

local SEVENTY_TWO_DEG = math.rad (72)

function evoker:cast_fangs (self, self_pos)
	local target = self.attack
	local target_pos = target and target:get_pos ()
	if not target_pos then
		return
	end

	-- Ref: https://minecraft.wiki/w/Evoker#Fang_attack
	local min = math.min (self_pos.y, target_pos.y)
	local max = math.max (self_pos.y, target_pos.y) + 1.0
	local dz = target_pos.z - self_pos.z
	local dx = target_pos.x - self_pos.x
	local yaw = math.atan2 (dz, dx) - math.pi / 2

	if vector.distance (self_pos, target_pos) < 3 then
		-- Ring 1.
		for fangno = 1, 5 do
			local i = fangno - 1
			local dir = yaw + i * math.pi * 0.4
			local dx = -math.sin (dir) * 1.5
			local dz = math.cos (dir) * 1.5
			self:spawn_fang (self_pos.x + dx, self_pos.z + dz,
					 min, max, fangno, yaw)
		end

		-- Ring 1.
		for fangno = 1, 8 do
			local i = fangno - 1
			local offset = SEVENTY_TWO_DEG
			local dir = yaw + i * math.pi * 2.0 / 8.0
				+ offset
			local dx = -math.sin (dir) * 2.5
			local dz = math.cos (dir) * 2.5
			self:spawn_fang (self_pos.x + dx, self_pos.z + dz,
					 min, max, fangno, yaw)
		end
	else
		-- Create a line of 16 evoker fangs.
		for fangno = 1, 16 do
			local dist = 1.25 * fangno
			local dx = -math.sin (yaw) * dist
			local dz = math.cos (yaw) * dist
			self:spawn_fang (self_pos.x + dx, self_pos.z + dz,
					 min, max, fangno, yaw)
		end
	end
end

function evoker:wololo_find_sheep (self_pos)
	for object in core.objects_inside_radius (self_pos, 16) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:sheep"
			and not entity.gotten
			and entity.color == "unicolor_blue" then
			self._wololo_sheep = entity.object
			return self._wololo_sheep
		end
	end
	return nil
end

local evoker_vex_spell = define_spell ({
	activity_name = "_summoning_vex",
	particle_color = "#b3b3cc",
	arm_time = 1.0,
	duration = 5.0,
	interval = 17.0,
	check_activate = function (self, self_pos, dtime)
		if not self.attack
			or not is_valid (self.attack) then
			return false
		else
			local n_vexes = 0

			for object in core.objects_inside_radius (self_pos, 16) do
				local entity = object:get_luaentity ()
				if entity and entity.name == "mobs_mc:vex" then
					n_vexes = n_vexes + 1
				end
			end

			self._summoned = false
			return pr:next (0, 7) + 1 > n_vexes
		end
	end,
	step = function (self, self_pos, dtime, rem)
		if self._summoned then
			return rem > 0
		end
		local nodepos = mcl_util.get_nodepos (self_pos)
		for i = 1, 3 do
			local pos = {
				x = nodepos.x + pr:next (-2, 2),
				y = nodepos.y + pr:next (-2, 2) - 0.5,
				z = nodepos.z + pr:next (-2, 2),
			}
			local obj = core.add_entity (pos, "mobs_mc:vex")
			if obj then
				local entity = obj:get_luaentity ()
				entity._summoned_by = self.object
				entity._summoned = true
				entity:restrict_to (nodepos, 32)
			end
		end
		self._summoned = true
		return rem > 0
	end,
})

local evoker_fang_spell = define_spell ({
	activity_name = "_summoning_fangs",
	particle_color = "#664d59",
	arm_time = 1.0,
	duration = 2.0,
	interval = 5.0,
	check_activate = function (self, self_pos, dtime)
		self._fangs_cast = false
		return true
	end,
	step = function (self, self_pos, dtime, rem)
		if not self._fangs_cast then
			self:cast_fangs (self, self_pos)
			self._fangs_cast = true
		end
		return rem > 0
	end,
})

local evoker_wololo_spell = define_spell ({
	activity_name = "_wololo",
	particle_color = "#bc8033",
	arm_time = 2.0,
	duration = 3.0,
	interval = 7.0,
	check_activate = function (self, self_pos, dtime)
		return mob_griefing
			and self:wololo_find_sheep (self_pos)
	end,
	step = function (self, self_pos, dtime, rem)
		if self._wololo_sheep
			and is_valid (self._wololo_sheep) then
			local entity = self._wololo_sheep:get_luaentity ()
			entity:set_color ("unicolor_red")
		end
		self._wololo_sheep = nil
		return rem > 0
	end,
})

evoker._combat_spells = {
	evoker_vex_spell,
	evoker_fang_spell,
}

evoker.ai_functions = {
	mob_class.check_attack,
	illager.check_recover_banner,
	mob_class.check_avoid,
	illager.check_pathfind_to_raid,
	illager.check_navigate_village,
	illager.check_distant_patrol,
	illager.check_celebrate,
	evoker_wololo_spell,
	mob_class.check_pace,
}

local evoker_friends = {
	"mobs_mc:evoker",
	"mobs_mc:illusioner",
}

evoker._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (mobs_mc.raid_mob_predicate, true,
						evoker_friends),
	mcl_mobs.build_nearest_target_rule ("player", nil, nil, nil, 15.0),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:villager", {
		"mobs_mc:villager",
		"mobs_mc:wandering_trader",
	}, nil, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:iron_golem", {
		"mobs_mc:iron_golem",
	}, nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

mobs_mc.evoker = evoker

mcl_mobs.register_mob ("mobs_mc:evoker", evoker)

------------------------------------------------------------------------
-- Evoker spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:evoker", S("Evoker"), "#959b9b", "#1e1c1a", 0)

------------------------------------------------------------------------
-- Evoker fangs.
------------------------------------------------------------------------

local evoker_fangs = {
	initial_properties = {
		visual = "mesh",
		mesh = "mobs_mc_evoker_fangs.b3d",
		textures = {
			"mobs_mc_evoker_fangs.png",
		},
		collisionbox = {
			-0.5, 0, -0.5,
			0.5, 0.8, -0.5,
		},
		physical = false,
		static_save = false,
		visual_size = {
			x = 0,
			y = 0,
		},
	},
	_startup_delay = 0.5,
	_owner = nil,
	_animation_started = false,
	_damage_dealt = false,
}

local function check_intersection (box, other_box)
	for index = 1, 3 do
		if box[index] > other_box[index + 3]
			or other_box[index] > box[index + 3] then
			return false
		end
	end
	return true
end

recently_damaged = {}

core.register_globalstep (function (dtime)
	for key, value in pairs (recently_damaged) do
		local t = recently_damaged[key] - dtime
		if t <= 0 then
			recently_damaged[key] = nil
		else
			recently_damaged[key] = t
		end
	end
end)

function evoker_fangs:deal_fang_damage ()
	local self_pos = self.object:get_pos ()
	local aa = vector.offset (self_pos, -3, -3, -3)
	local bb = vector.offset (self_pos, 3, 3, 3)
	local collisionbox = {
		-0.45 + self_pos.x,
		0.0 + self_pos.y,
		-0.45 + self_pos.z,
		0.45 + self_pos.x,
		1.0 + self_pos.y,
		0.45 + self_pos.z,
	}

	for object in core.objects_in_area (aa, bb) do
		if not recently_damaged[object] then
			local entity = object:get_luaentity ()
			if object:is_player ()
				or (entity and entity.is_mob
				    and not entity._is_illager
				    and entity.name ~= "mobs_mc:ravager") then
				local cbox = object:get_properties ().collisionbox
				local pos = object:get_pos ()
				cbox[1] = cbox[1] + pos.x
				cbox[2] = cbox[2] + pos.y
				cbox[3] = cbox[3] + pos.z
				cbox[4] = cbox[4] + pos.x
				cbox[5] = cbox[5] + pos.y
				cbox[6] = cbox[6] + pos.z

				if check_intersection (collisionbox, cbox) then
					recently_damaged[object] = 0.5
					local reason = {
						type = "magic",
						source = self._owner,
						direct = self.object,
					}
					mcl_damage.finish_reason (reason)
					mcl_util.deal_damage (object, 6.0, reason)
				end
			end
		end
	end

	core.add_particlespawner ({
		time = 0.1,
		amount = 12,
		attached = self.object,
		pos = {
			min = {
				x = -0.5,
				y = 0,
				z = -0.5,
			},
			max = {
				x = 0.5,
				y = 0.2,
				z = -0.5,
			},
		},
		vel = {
			min = MIN_VEL,
			max = MAX_VEL,
		},
		exptime = {
			min = 0.1,
			max = 0.2,
		},
		texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
	})
end

function evoker_fangs:on_step (dtime)
	local t = self._startup_delay - dtime
	self._startup_delay = t

	if not self._animation_started
		and self._startup_delay <= 0 then
		local d = math.max (0.2, 0.4 - (0 - t))
		self.object:set_properties ({
			visual_size = {
				x = 8.0,
				y = 4.0,
			},
		})
		self.object:set_animation ({
			x = 0,
			y = 20,
		}, 20 / d, 0.0, false)
		self._animation_started = true
	elseif self._startup_delay <= -0.4 then
		if not self._damage_dealt then
			self:deal_fang_damage ()
			if self._startup_delay > -1.1 then
				local fps = 15 / (self._startup_delay + 1.1)
				self.object:set_animation ({
					x = 20,
					y = 35,
				}, fps, 0.0, false)
			end
			self._damage_dealt = true
		elseif self._startup_delay <= -1.1 then
			self.object:remove ()
		end
	end
end

core.register_entity ("mobs_mc:evoker_fangs", evoker_fangs)
