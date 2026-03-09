local mob_class = mcl_mobs.mob_class
local active_particlespawners = {}
local enable_blood = core.settings:get_bool("mcl_damage_particles", true)
local DEFAULT_FALL_SPEED = -9.81*1.5
local is_valid = mcl_util.is_valid_objectref

local player_transfer_distance = tonumber(core.settings:get("player_transfer_distance")) or 128
if player_transfer_distance == 0 then player_transfer_distance = math.huge end

-- custom particle effects
function mcl_mobs.effect(pos, amount, texture, min_size, max_size, radius, gravity, glow, go_down)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or DEFAULT_FALL_SPEED
	glow = glow or 0
	go_down = go_down or false

	local ym
	if go_down then
		ym = 0
	else
		ym = -radius
	end

	core.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = ym, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow,
	})
end

function mcl_mobs.death_effect(pos, yaw, collisionbox, rotate)
	local min, max
	if collisionbox then
		min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
		max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
	else
		min = { x = -0.5, y = 0, z = -0.5 }
		max = { x = 0.5, y = 0.5, z = 0.5 }
	end
	if rotate then
		min = vector.rotate(min, {x=0, y=yaw, z=math.pi/2})
		max = vector.rotate(max, {x=0, y=yaw, z=math.pi/2})
		min, max = vector.sort(min, max)
		min = vector.multiply(min, 0.5)
		max = vector.multiply(max, 0.5)
	end

	core.add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, min),
		maxpos = vector.add(pos, max),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	core.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end


-- play sound
function mob_class:mob_sound(soundname, is_opinion, fixed_pitch)
	local soundinfo = self.child and self.sounds_child or self.sounds
	local sound = soundinfo and soundinfo[soundname]

	if sound then
		if is_opinion and not self:check_timer("opinion_sound_cooloff", self.opinion_sound_cooloff) then
			return
		end
		local pitch
		if not fixed_pitch then
			local base_pitch = soundinfo.base_pitch or 1
			pitch = ( self.child and not self.sounds_child and base_pitch * 1.5 or base_pitch ) + math.random(-10, 10) * 0.005 -- randomize the pitch a bit
		end
		-- Should be 0.1 to 0.2 for mobs. Cow and zombie farms loud. At least have cool down.
		local sound_params = self.sound_params and table.copy(self.sound_params) or {
			max_hear_distance = self.sounds.distance,
			pitch = pitch,
		}
		sound_params.object = self.object
		core.sound_play(sound, sound_params, true)
	end
end

function mob_class:add_texture_mod(mod)
	local full_mod = ""
	local already_added = false
	for i=1, #self.texture_mods do
		if mod == self.texture_mods[i] then
			already_added = true
		end
		full_mod = full_mod .. self.texture_mods[i]
	end
	if not already_added then
		full_mod = full_mod .. mod
		table.insert(self.texture_mods, mod)
	end
	self.object:set_texture_mod(full_mod)
end

function mob_class:remove_texture_mod(mod)
	local full_mod = ""
	local remove = {}
	for i=1, #self.texture_mods do
		if self.texture_mods[i] ~= mod then
			full_mod = full_mod .. self.texture_mods[i]
		else
			table.insert(remove, i)
		end
	end
	for i=#remove, 1, -1 do
		table.remove(self.texture_mods, remove[i])
	end
	self.object:set_texture_mod(full_mod)
end

function mob_class:damage_effect(damage)
	-- damage particles
	if enable_blood and damage > 0 then
		local amount_large = math.floor(damage / 2)
		local amount_small = damage % 2

		local pos = self.object:get_pos()

		local cbox = self.object:get_properties().collisionbox
		pos.y = pos.y + (cbox[5] - cbox[2]) * .5

		local texture = "mobs_blood.png"
		-- full heart damage (one particle for each 2 HP damage)
		if amount_large > 0 then
			mcl_mobs.effect(pos, amount_large, texture, 2, 2, 1.75, 0, nil, true)
		end
		-- half heart damage (one additional particle if damage is an odd number)
		if amount_small > 0 then
			-- TODO: Use "half heart"
			mcl_mobs.effect(pos, amount_small, texture, 1, 1, 1.75, 0, nil, true)
		end
	end
end

function mob_class:remove_particlespawners(pn)
	if not active_particlespawners[pn] then return end
	if not active_particlespawners[pn][self.object] then return end
	for _, v in pairs(active_particlespawners[pn][self.object]) do
		core.delete_particlespawner(v)
	end
end

function mob_class:add_particlespawners(pn)
	if not active_particlespawners[pn] then active_particlespawners[pn] = {} end
	if not active_particlespawners[pn][self.object] then active_particlespawners[pn][self.object] = {} end
	for _,ps in pairs(self.particlespawners) do
		ps.attached = self.object
		ps.playername = pn
		table.insert(active_particlespawners[pn][self.object],core.add_particlespawner(ps))
	end
end

function mob_class:check_particlespawners(dtime)
	if not self.particlespawners then return end
	--core.log(dump(active_particlespawners))
	if self._particle_timer and self._particle_timer >= 1 then
		self._particle_timer = 0
		local players = {}
		for player in mcl_util.connected_players() do
			local pn = player:get_player_name()
			table.insert(players,pn)
			if not active_particlespawners[pn] then
				active_particlespawners[pn] = {} end

			local dst = vector.distance(player:get_pos(),self.object:get_pos())
			if dst < player_transfer_distance and not active_particlespawners[pn][self.object] then
				self:add_particlespawners(pn)
			elseif dst >= player_transfer_distance and active_particlespawners[pn][self.object] then
				self:remove_particlespawners(pn)
			end
		end
	elseif not self._particle_timer then
		self._particle_timer = 0
	end
	self._particle_timer = self._particle_timer + dtime
end

function mob_class:set_animation (anim, fixed_frame)
	if not self.animation or not anim then
		return
	end

	if self.jockey_vehicle
	-- Don't use `jockey' animations if none are defined.
		and self.animation.jockey_start
		and self.object:get_attach () then
		anim = "jockey"
	end

	if self.dead and anim ~= "die" and anim ~= "stand" then
		return
	end

	if self.attack
		and self._punch_animation_timeout
		and self._punch_animation_timeout > 0 then
		anim = "punch"
	end

	self._current_animation = self._current_animation or ""

	if (anim == self._current_animation
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and not self.dead then
		return
	end

	self._current_animation = anim

	local a_start = self.animation[anim .. "_start"]
	local a_end
	if fixed_frame then
		a_end = a_start
	else
		a_end = self.animation[anim .. "_end"]
	end
	if a_start and a_end then
		local loop = self.animation[anim .. "_loop"] ~= false
		self.object:set_animation({x = a_start,
					   y = a_end},
			self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
			0, loop)
	end
end

-- above function exported for mount.lua
function mcl_mobs.set_animation(self, anim)
	self:set_animation(anim)
end

function mob_class:who_are_you_looking_at()
	local pos = self.object:get_pos()

	if self.order == "sleep" then
		self._locked_object = nil
		return
	end

	local stop_look_at_player_chance = math.random(833/self.curiosity)
	-- was 10000 - div by 12 for avg entities as outside loop

	local stop_look_at_player = stop_look_at_player_chance == 1

	if self.attack then
		self._locked_object = self.attack
	elseif self.following then
		self._locked_object = self.following
	elseif self.mate then
		self._locked_object = self.mate
	elseif self._locked_object then
		if stop_look_at_player
			or self._locked_object == self.driver then
			self._locked_object = nil
		end
	elseif not self._locked_object then
		if math.random(1, 30) then
			-- For the wither this was 20/60=0.33, so probably need to rebalance and divide rates.
			-- but frequency of check isn't good as it is costly. Making others too infrequent requires testing
			local look_at_player_chance = math.random(math.max(1,20/self.curiosity))

			-- was 5000 but called in loop based on entities. so div by 12 as estimate avg of entities found,
			-- then div by 20 as less freq lookup

			local look_at_player = look_at_player_chance == 1

			for obj in core.objects_inside_radius(pos, 8) do
				if obj:is_player() and vector.distance(pos,obj:get_pos()) < 4
					and obj ~= self.driver then
					self._locked_object = obj
					break
				elseif obj:is_player()
					or (obj:get_luaentity()
						and obj:get_luaentity().name == self.name
						and self ~= obj:get_luaentity()) then
					if look_at_player and obj ~= self.driver then
						self._locked_object = obj
						break
					end
				end
			end
		end

	end
end

local HALF_DEG = math.rad (0.5)

local function is_zero_vector (v)
	return v.x == 0 and v.y == 0 and v.z == 0
end

local ZERO_VECTOR = vector.zero ()

function mob_class:check_head_swivel (self_pos, dtime, clear)
	if not self.head_swivel
		or type (self.head_swivel) ~= "string" then
		return
	end

	if clear then
		self._locked_object = nil
	else
		self:who_are_you_looking_at ()
	end

	local oldr = self._old_head_swivel_vector
	local oldp = self._old_head_swivel_pos
	local newr, axis_scale = ZERO_VECTOR, self._head_axis_scale

	local locked_object = self._locked_object
	if locked_object
		and is_valid (locked_object)
		and locked_object:get_hp () > 0 then
		local _locked_object_eye_height
			= mcl_util.target_eye_height (locked_object)

		if _locked_object_eye_height then
			local self_yaw
			-- It so transpires that
			-- ObjectRef:get_rotation does not return the
			-- rotation of the parent if there is an
			-- attachment.
			local attach = self.object:get_attach ()
			if attach then
				self_yaw = attach:get_yaw () or 0
			else
				self_yaw = self.object:get_yaw ()
			end
			local ps = self_pos
			local old_y = ps.y
			ps.y = ps.y + self:get_eye_height ()
			local pt = locked_object:get_pos ()
			pt.y = pt.y + _locked_object_eye_height
			local dir = vector.direction (ps, pt)
			ps.y = old_y
			local mob_yaw_raw = self_yaw
				+ math.atan2 (dir.x, dir.z)
			local mob_yaw = mcl_util.norm_radians (mob_yaw_raw)
			local mob_pitch = math.asin(-dir.y) * self.head_pitch_multiplier
				+ self._head_pitch_offset
			local out_of_view
				= (mob_yaw < -self._head_rot_limit
				   or mob_yaw > self._head_rot_limit)
					and not (self.attack and not self.runaway)
			if self.adjust_head_swivel then
				mob_yaw, mob_pitch, out_of_view
					= self:adjust_head_swivel (mob_yaw, mob_pitch, out_of_view)
			end

			if out_of_view then
				newr = vector.multiply(oldr, 0.9)
			elseif self.attack and not self.runaway then
				if self.head_yaw == "y" then
					newr = vector.new (mob_pitch, mob_yaw, 0)
				else -- if self.head_yaw == "z" then
					newr = vector.new (mob_pitch, 0, -mob_yaw)
				end
			else
				if self.head_yaw == "y" then
					newr = vector.new ((mob_pitch-oldr.x)*.3+oldr.x, (mob_yaw-oldr.y)*.3+oldr.y, 0)
				else -- if self.head_yaw == "z" then
					newr = vector.new ((mob_pitch-oldr.x)*.3+oldr.x, 0, ((mob_yaw-oldr.y)*.3+oldr.y)*-3)
				end
			end
		end
	elseif not locked_object
		and (math.abs (oldr.x + oldr.y + oldr.z) > 0) then
		newr = vector.multiply (oldr, 0.9)
		if self.adjust_head_swivel then
			self:adjust_head_swivel (nil, nil, nil)
		end
	else
		newr = ZERO_VECTOR
		axis_scale = nil
	end

	local newp = self._head_swivel_pos

	if math.abs (oldr.x - newr.x) < HALF_DEG
		and math.abs (oldr.y - newr.y) < HALF_DEG
		and math.abs (oldr.z - newr.z) < HALF_DEG
		and (is_zero_vector (oldr) or not is_zero_vector (newr))
		and vector.equals (oldp, newp) then
		return
	end

	self.object:set_bone_override (self.head_swivel, {
		position = { vec = newp, absolute = true, interpolation = 0.1 },
		rotation = { vec = newr, absolute = true, interpolation = 0.1 },
		scale = axis_scale,
	})
	self._old_head_swivel_pos = newp
	self._old_head_swivel_vector = newr
end

-- set animation speed relative to velocity
function mob_class:set_animation_speed(custom_speed)
	local anim = self._current_animation
	if not anim then
		return
	end
	local name = anim .. "_speed"
	local normal_speed = self.animation[name]
		or self.animation.speed_normal
		or 25
	if anim ~= "walk" and self.anim ~= "run" then
		self.object:set_animation_frame_speed (normal_speed)
		return
	end
	local speed = custom_speed or normal_speed
	local v = self:get_velocity ()
	local scaled_speed = speed * self.frame_speed_multiplier
	self.object:set_animation_frame_speed (scaled_speed * v)
end

core.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if not active_particlespawners[pn] then return end
	for _,m in pairs(active_particlespawners[pn]) do
		for _, v in pairs(m) do
			core.delete_particlespawner(v)
		end
	end
	active_particlespawners[pn] = nil
end)

------------------------------------------------------------------------
-- Smooth rotation.  In the long run, most mob models should receive a
-- root bone, enabling client-side interpolation.
------------------------------------------------------------------------

local norm_radians = nil

core.register_on_mods_loaded (function ()
		norm_radians = mcl_util.norm_radians
end)

function mob_class:rotation_info ()
	if not self._rotation_info then
		local oldyaw
			= self.object:get_yaw () + self.rotate
		self._rotation_info = {
			yaw = {
				current	= norm_radians (oldyaw),
				remaining_turn = 0,
				amt_per_second = 0,
			},
			pitch = {
				current = self.object:get_rotation ().x,
				remaining_turn = 0,
				amt_per_second = 0,
			},
		}
	end
	return self._rotation_info
end

local ROTATE_TIME = 1/0.15 -- 3 minecraft ticks.

function mob_class:rotate_axis (axis, target)
	local rotation_info = self:rotation_info ()[axis]
	local current_rot

	if axis == "yaw" then
		current_rot = self.object:get_yaw ()
		if self.rotate ~= 0 then
			current_rot
				= norm_radians (current_rot + self.rotate)
		end
	elseif axis == "pitch" then
		current_rot = self.object:get_rotation ().x
	else
		current_rot = self.object:get_rotation ().z
	end

	rotation_info.current = current_rot
	rotation_info.remaining_turn
		= norm_radians (target - current_rot)
	rotation_info.amt_per_second
		= rotation_info.remaining_turn * ROTATE_TIME
end

function mob_class:rotate_gradually (info, axis, dtime)
	local info = info[axis]
	local rem = info.remaining_turn

	if math.abs (info.remaining_turn) > 1.0e-5 then
		local increment = info.amt_per_second * dtime

		if (increment < 0 and increment < info.remaining_turn)
			or (increment > 0 and increment > info.remaining_turn) then
			increment = info.remaining_turn
		end

		local target = info.current + increment
		info.remaining_turn = rem - increment
		info.current = norm_radians (target)
		return info.current
	else
		if axis == "yaw" and self._target_yaw then
			info.current = self._target_yaw
		elseif axis == "pitch" and self._target_pitch then
			info.current = self._target_pitch
		end
		return info.current
	end
end

local rotate_step_scratch = vector.zero ()

function mob_class:rotate_step (dtime)
	local yaw, pitch
	local info = self:rotation_info ()
	yaw = self:rotate_gradually (info, "yaw", dtime)
	pitch = self:rotate_gradually (info, "pitch", dtime)
	if self.shaking then
		yaw = yaw + (math.random () * 1 - 0.5) * dtime
	end
	local v = rotate_step_scratch
	v.x = pitch
	v.y = yaw - self.rotate
	v.z = self:get_roll ()
	self.object:set_rotation (v)
end

function mob_class:set_yaw (yaw)
	self:rotate_axis ("yaw", yaw)
	self._target_yaw = yaw
	return yaw
end

function mob_class:get_yaw (yaw)
	return self._target_yaw or (self.object:get_yaw () + self.rotate)
end

function mob_class:set_pitch (pitch)
	self:rotate_axis ("pitch", pitch)
	self._target_pitch = pitch
end

function mob_class:get_pitch ()
	return self._target_pitch or self.object:get_rotation ().x
end

function mob_class:get_roll ()
	if self.dead and not self.animation.die_end then
		return self.object:get_rotation ().z
	else
		-- Avoid the needless call to get_rotation and
		-- subsequent consing.
		return 0
	end
end

----------------------------------------------------------------------------------
-- Invisibility.  This invisibility exempts attached objects and armor
-- by altering textures rather than visual size.
----------------------------------------------------------------------------------

function mob_class:set_invisible (hide)
	if hide then
		self._mob_invisible = true
		self:set_textures (self._active_texture_list)
	else
		self._mob_invisible = false
		self:set_textures (self._active_texture_list)
	end
end

function mob_class:is_armor_texture_slot (i)
	if self.wears_armor then
		for k, _ in pairs (self._armor_texture_slots) do
			if k == i then
				return true
			end
		end
	end

	return false
end

function mob_class:set_textures (textures)
	self._active_texture_list = textures
	if self._mob_invisible then
		textures = table.copy (textures)
		for i = 1, #textures do
			if not self:is_armor_texture_slot (i) then
				textures[i] = "blank.png"
			end
		end
	end
	self.object:set_properties ({
		textures = textures,
	})
end

----------------------------------------------------------------------------------
-- Humanoids.  This provides support for managing humanoid poses in
-- Lua.
----------------------------------------------------------------------------------

local posing_humanoid = {
	_arm_poses = {
		default = {},
	},
	_arm_pose_continuous = {
		default = false,
	}
}

function posing_humanoid:pose_bone_absolute_p (bone)
	return true
end

function posing_humanoid:apply_arm_pose (pose)
	local pose = self._arm_poses[pose]
	if pose then
		for k, v in pairs (pose) do
			if v[1] or v[2] or v[3] then
				local pos = v[1] and (type (v[1]) ~= "function"
						      and v[1] or v[1] (self))
				local rot = v[2] and (type (v[2]) ~= "function"
						      and vector.apply (v[2], math.rad)
						      or v[2] (self))
				local scale = v[3]
				local pos = pos
				local rot = rot
				local absolute = self:pose_bone_absolute_p (k)
				self.object:set_bone_override (k, {
					position = pos and {
						vec = pos,
						absolute = absolute,
						interpolation = 0.1,
					},
					rotation = rot and {
						vec = rot,
						absolute = absolute,
						interpolation = 0.1,
					},
					scale = scale and {
						vec = scale,
						absolute = absolute,
						interpolation = 0.1,
					},
				})
				if k == self.head_swivel then
					self._old_head_swivel_vector = rot
				end
			else
				if self.object.set_bone_override then
					self.object:set_bone_override (k)
				else
					self.object:set_bone_position (k, ZERO_VECTOR, ZERO_VECTOR)
				end
			end
		end
	end
end

function posing_humanoid:do_custom (dtime)
	local class = self._humanoid_superclass

	if class.do_custom then
		class.do_custom (self, dtime)
	end

	local last_arm_pose = self._arm_pose
	self._arm_pose = self:select_arm_pose ()
	if last_arm_pose ~= self._arm_pose
		or self._arm_pose_continuous[self._arm_pose] then
		self:apply_arm_pose (self._arm_pose)
	end
end

function posing_humanoid:select_arm_pose ()
	return "default"
end

function posing_humanoid:mob_activate (staticdata, dtime)
	local class = self._humanoid_superclass

	if class.mob_activate then
		if not class.mob_activate (self, staticdata, dtime) then
			return false
		end
	else
		if not mob_class.mob_activate (self, staticdata, dtime) then
			return false
		end
	end
	self._arm_pose = self:select_arm_pose ()
	self:apply_arm_pose (self._arm_pose)
	return true
end

function mcl_mobs.define_composite_pose (poses, prefix, overrides)
	local new_poses = {}

	for k, v in pairs (poses) do
		new_poses[prefix .. "_" .. k]
			= table.merge (v, overrides)

		-- Have the original poses reset modified bones to
		-- their default values.
		for bone, _ in pairs (overrides) do
			if not v[bone] then
				v[bone] = {}
			end
		end
	end
	for k, v in pairs (new_poses) do
		poses[k] = v
	end
end

mcl_mobs.posing_humanoid = posing_humanoid
