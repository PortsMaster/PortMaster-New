local mob_class = mcl_mobs.mob_class
local active_particlespawners = {}
local enable_blood = minetest.settings:get_bool("mcl_damage_particles", true)
local DEFAULT_FALL_SPEED = -9.81*1.5

local player_transfer_distance = tonumber(minetest.settings:get("player_transfer_distance")) or 128
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

	minetest.add_particlespawner({
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

	minetest.add_particlespawner({
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

	minetest.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end


-- play sound
function mob_class:mob_sound(soundname, is_opinion, fixed_pitch)

	local soundinfo
	if self.sounds_child and self.child then
		soundinfo = self.sounds_child
	elseif self.sounds then
		soundinfo = self.sounds
	end
	if not soundinfo then
		return
	end
	local sound = soundinfo[soundname]
	if sound then
		if is_opinion and self.opinion_sound_cooloff > 0 then
			return
		end
		local pitch
		if not fixed_pitch then
			local base_pitch = soundinfo.base_pitch
			if not base_pitch then
				base_pitch = 1
			end
			if self.child and (not self.sounds_child) then
				-- Children have higher pitch
				pitch = base_pitch * 1.5
			else
				pitch = base_pitch
			end
			-- randomize the pitch a bit
			pitch = pitch + math.random(-10, 10) * 0.005
		end
		-- Should be 0.1 to 0.2 for mobs. Cow and zombie farms loud. At least have cool down.
		local sound_params = self.sound_params and table.copy(self.sound_params) or {
			max_hear_distance = self.sounds.distance,
			pitch = pitch,
		}
		sound_params.object = self.object
		minetest.sound_play(sound, sound_params, true)
		self.opinion_sound_cooloff = 1
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
	for k,v in pairs(active_particlespawners[pn][self.object]) do
		minetest.delete_particlespawner(v)
	end
end

function mob_class:add_particlespawners(pn)
	if not active_particlespawners[pn] then active_particlespawners[pn] = {} end
	if not active_particlespawners[pn][self.object] then active_particlespawners[pn][self.object] = {} end
	for _,ps in pairs(self.particlespawners) do
		ps.attached = self.object
		ps.playername = pn
		table.insert(active_particlespawners[pn][self.object],minetest.add_particlespawner(ps))
	end
end

function mob_class:check_particlespawners(dtime)
	if not self.particlespawners then return end
	--minetest.log(dump(active_particlespawners))
	if self._particle_timer and self._particle_timer >= 1 then
		self._particle_timer = 0
		local players = {}
		for _,player in pairs(minetest.get_connected_players()) do
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


-- set defined animation
function mob_class:set_animation(anim, fixed_frame)
	if not self.animation or not anim then
		return
	end

	if self.jockey and self.object:get_attach() then
		anim = "jockey"
	elseif not self.object:get_attach() then
		self.jockey = nil
	end

	if self.state == "die" and anim ~= "die" and anim ~= "stand" then
		return
	end



	if self:flight_check() and self.fly and anim == "walk" then anim = "fly" end

	self._current_animation = self._current_animation or ""

	if (anim == self._current_animation
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and self.state ~= "die" then
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
		self.object:set_animation({
			x = a_start,
			y = a_end},
			self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
			0, self.animation[anim .. "_loop"] ~= false)
		end
end

-- above function exported for mount.lua
function mcl_mobs.set_animation(self, anim)
	self:set_animation(anim)
end

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

function mob_class:who_are_you_looking_at()
	local pos = self.object:get_pos()

	local stop_look_at_player_chance = math.random(833/self.curiosity)
	-- was 10000 - div by 12 for avg entities as outside loop

	local stop_look_at_player = stop_look_at_player_chance == 1

	if self.attack then
		if not self.target_time_lost then
			self._locked_object = self.attack
		else
			self._locked_object = nil
		end
	elseif self.following then
		self._locked_object = self.following
	elseif self._locked_object then
		if stop_look_at_player then
			--minetest.log("Stop look: ".. self.name)
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

			for _, obj in pairs(minetest.get_objects_inside_radius(pos, 8)) do
				if obj:is_player() and vector.distance(pos,obj:get_pos()) < 4 then
					self._locked_object = obj
					break
				elseif obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name == self.name and self ~= obj:get_luaentity()) then
					if look_at_player then
						self._locked_object = obj
						break
					end
				end
			end
		end

	end
end

function mob_class:check_head_swivel(dtime)
	if not self.head_swivel or type(self.head_swivel) ~= "string" then return end

	self:who_are_you_looking_at()

	local final_rotation = vector.zero()
	local _,oldr = self.object:get_bone_position(self.head_swivel)

	if self._locked_object and (self._locked_object:is_player() or self._locked_object:get_luaentity()) and self._locked_object:get_hp() > 0 then
		local _locked_object_eye_height = 1.5
		if self._locked_object:get_luaentity() then
			_locked_object_eye_height = self._locked_object:get_luaentity().head_eye_height
		end
		if self._locked_object:is_player() then
			_locked_object_eye_height = self._locked_object:get_properties().eye_height
		end
		if _locked_object_eye_height then

			local self_rot = self.object:get_rotation()
			if self.object:get_attach() and self.object:get_attach():get_rotation() then
				self_rot = self.object:get_attach():get_rotation()
			end

			local player_pos = self._locked_object:get_pos()
			local direction_player = vector.direction(vector.add(self.object:get_pos(), vector.new(0, self.head_eye_height*.7, 0)), vector.add(player_pos, vector.new(0, _locked_object_eye_height, 0)))
			local mob_yaw = math.deg(-(-(self_rot.y)-(-minetest.dir_to_yaw(direction_player))))+self.head_yaw_offset
			local mob_pitch = math.deg(-dir_to_pitch(direction_player))*self.head_pitch_multiplier

			if (mob_yaw < -60 or mob_yaw > 60) and not (self.attack and self.state == "attack" and not self.runaway) then
				final_rotation = vector.multiply(oldr, 0.9)
			elseif self.attack and self.state == "attack" and not self.runaway then
				if self.head_yaw == "y" then
					final_rotation = vector.new(mob_pitch, mob_yaw, 0)
				elseif self.head_yaw == "z" then
					final_rotation = vector.new(mob_pitch, 0, -mob_yaw)
				end

			else

				if self.head_yaw == "y" then
					final_rotation = vector.new(((mob_pitch-oldr.x)*.3)+oldr.x, ((mob_yaw-oldr.y)*.3)+oldr.y, 0)
				elseif self.head_yaw == "z" then
					final_rotation = vector.new(((mob_pitch-oldr.x)*.3)+oldr.x, 0, -(((mob_yaw-oldr.y)*.3)+oldr.y)*3)
				end
			end
		end
	elseif not self._locked_object and math.abs(oldr.y) > 3 and math.abs(oldr.x) < 3 then
		final_rotation = vector.multiply(oldr, 0.9)
	end

	mcl_util.set_bone_position(self.object,self.head_swivel, vector.new(0,self.bone_eye_height,self.horizontal_head_height), final_rotation)
end

function mob_class:set_animation_speed()
	local v = self.object:get_velocity()
	if v then
		if self.frame_speed_multiplier then
			local v2 = math.abs(v.x)+math.abs(v.z)*.833
			if not self.animation.walk_speed then
				self.animation.walk_speed = 25
			end
			if math.abs(v.x)+math.abs(v.z) > 0.5 then
				self.object:set_animation_frame_speed((v2/math.max(1,self.run_velocity))*self.animation.walk_speed*self.frame_speed_multiplier)
			else
				self.object:set_animation_frame_speed(25)
			end
		end
		if self.acc and mcl_mobs.check_vector(self.acc) then
			self.object:add_velocity(self.acc)
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if not active_particlespawners[pn] then return end
	for _,m in pairs(active_particlespawners[pn]) do
		for k,v in pairs(m) do
			minetest.delete_particlespawner(v)
		end
	end
	active_particlespawners[pn] = nil
end)
