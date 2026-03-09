local S = core.get_translator(core.get_current_modname())

local enable_pvp = core.settings:get_bool("enable_pvp")

local GRAVITY = 9.81

-- Time in seconds to despawn an arrow.
local ARROW_LIFETIME = 120
-- Time in seconds after which a stuck arrow is deleted
local STUCK_ARROW_TIMEOUT = 60
-- Time in seconds after which an attached arrow is deleted
local ATTACHED_ARROW_TIMEOUT = 30
-- Time after which stuck arrow is rechecked for being stuck
local STUCK_RECHECK_TIME = 0.25
-- Range for stuck arrow to be collected by player
local PICKUP_RANGE = 2

-- For each DRAG_TICK second, set velocity to DRAG_RATE%
local DRAG_TICK = 0.05
local DRAG_RATE = 0.99

-- Each block of liquid set velocity to LIQUID_RATE%
local LIQUID_RATE = 0.74 -- Bow arrow lost most horizontal speed at 8 liquid blocks.

--local GRAVITY = 9.81

local YAW_OFFSET = -math.pi/2

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function random_arrow_positions(positions, placement)
	if positions == "x" then
		return math.random(-4, 4)
	elseif positions == "y" then
		return math.random(0, 10)
	end
	if placement == "front" and positions == "z" then
		return 3
	elseif placement == "back" and positions == "z" then
		return -3
	end
	return 0
end

core.register_craftitem("mcl_bows:arrow", {
	description = S("Arrow"),
	_tt_help = S("Ammunition").."\n"..S("Damage from bow: 1-10").."\n"..S("Damage from dispenser: 3"),
	_doc_items_longdesc = S("Arrows are ammunition for bows and dispensers.").."\n"..
S("An arrow fired from a bow has a regular damage of 1-9. At full charge, there's a 20% chance of a critical hit dealing 10 damage instead. An arrow fired from a dispenser always deals 3 damage.").."\n"..
S("Arrows might get stuck on solid blocks and can be retrieved again. They are also capable of pushing wooden buttons."),
	_doc_items_usagehelp = S("To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory. To retrieve an arrow that sticks in a block, simply walk close to it."),
	inventory_image = "mcl_bows_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1, ammo_bow_regular=1, ammo_crossbow=1 },
	_on_dispense = function(itemstack, dispenserpos, _, _, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
		mcl_bows.shoot_arrow (itemstack:get_name(), shootpos, dropdir, yaw, "mcl_dispensers:dispenser", 0.366666)
	end,
})

local ARROW_ENTITY={
	initial_properties = {
		physical = true,
		pointable = false,
		visual = "mesh",
		mesh = "mcl_bows_arrow.b3d",
		visual_size = {x=-1, y=1},
		textures = {"mcl_bows_arrow.png"},
		collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
		collide_with_objects = false,
	},
	_fire_collisionbox = {-0.19, -0.125, -0.39, 0.19, 0.125, -0.01},
	fire_damage_resistant = true,
	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_is_critical=false, -- Whether this arrow would deal critical damage
	_stuck=false,   -- Whether arrow is stuck
	_lifetime=0,-- Amount of time (in seconds) the arrow has existed
	_dragtime=0,-- Amount of time (in seconds) the arrow has slowed down
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
	_stuckin=nil,	--Position of node in which arrow is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who shot it.
	_left_shooter = false,
	_is_arrow = true,
	_in_player = false,
	_blocked = nil, -- Name of last player who deflected this arrow with a shield.
	_particle_id=nil,
	_ignored=nil,
	_animtime = 0.0,
}

-- Drop arrow as item at pos
local function spawn_item(self, pos)
	if not core.is_creative_enabled("") then
		local itemstring = "mcl_bows:arrow"
		if self._itemstring then
			local stack = ItemStack (self.itemstring)
			if stack:get_definition () then
				itemstring = self._itemstring
			end
		end
		local item = core.add_item(pos, itemstring)
		if item then
			local luaentity = item:get_luaentity ()
			item:set_velocity(vector.new(0, 0, 0))
			item:set_yaw(self.object:get_yaw())
			luaentity._insta_collect = true
		end
	end
end

local function damage_particles(pos, is_critical)
	if is_critical then
		core.add_particlespawner({
			amount = 15,
			time = 0.1,
			minpos = vector.offset(pos, -0.5, -0.5, -0.5),
			maxpos = vector.offset(pos, 0.5, 0.5, 0.5),
			minvel = vector.new(-0.1, -0.1, -0.1),
			maxvel = vector.new(0.1, 0.1, 0.1),
			minexptime = 1,
			maxexptime = 2,
			minsize = 1.5,
			maxsize = 1.5,
			collisiondetection = false,
			vertical = false,
			texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
		})
	end
end

-- Add player bow height to position, which is simply y += 1.5
function mcl_bows.add_bow_height(pos)
	pos = vector.copy(pos)
	pos.y = pos.y + 1.5
	return pos
end

-- Add inaccuracy to a _direction_ vector (before speed is applied).
-- Player has an inaccuracy of 1, dispenser 6, mobs varies by difficulty (input nil)
-- The distribution will form a bell shape, loosely speaking.
function mcl_bows.add_inaccuracy(dir, inaccuracy)
	if not inaccuracy then
		inaccuracy = 14 - mcl_vars.difficulty * 4 -- 1:Easy = 10, 2:Normal = 6, 3:Hard = 2
	end
	if inaccuracy == 0 then return dir end
	dir = vector.copy(dir)
	-- Reference: https://midnight.wiki.gg/wiki/Ebonite_Arrow
	dir.x = dir.x + mcl_util.dist_triangular(0, 0.0172275 * inaccuracy)
	dir.y = dir.y + mcl_util.dist_triangular(0, 0.0172275 * inaccuracy)
	dir.z = dir.z + mcl_util.dist_triangular(0, 0.0172275 * inaccuracy)
	return dir
end

function ARROW_ENTITY:get_last_pos()
	return self._lastpos.x and self._lastpos or self._startpos
end

-- Multiply x and z velocity by given factor.
function ARROW_ENTITY:multiply_xz_velocity (factor)
	local vel = self.object:get_velocity ()
	vel.x = vel.x * factor
	vel.z = vel.z * factor
	vel.y = vel.y * factor
	self.object:set_velocity(vel)
end

function ARROW_ENTITY:arrow_knockback (object, damage)
	local entity = object:get_luaentity ()
	local v = self.object:get_velocity ()
	v.y = 0
	local dir = vector.normalize (v)

	-- Utilize different methods of applying knockback for consistency.
	if entity and entity.is_mob then
		entity:projectile_knockback (1, dir)
	elseif object:is_player () then
		mcl_player.player_knockback (object, self.object, dir, nil, damage)
	end

	if self._knockback and self._knockback > 0 then
		local resistance = entity and entity.knockback_resistance or 0
		-- Apply an additional horizontal force of
		-- self._knockback * 0.6 * 20 * 0.546 to the object.
		local total_kb = self._knockback * (1.0 - resistance) * 12 * 0.546
		v = vector.multiply (dir, total_kb)

		-- And a vertical force of 2.0 * 0.91.
		v.y = v.y + 2.0 * 0.91 * (1.0 - resistance)

		if object:is_player () then
			v.x = v.x * 0.25
			v.z = v.z * 0.25
		end
		object:add_velocity (v)
	end
end

function ARROW_ENTITY:calculate_damage (v)
	if not v then v = self.object:get_velocity() end
	local crit_bonus = 0
	local multiplier = vector.length (v) / 20
	local damage = (self._damage or 2) * multiplier

	if self._is_critical then
		crit_bonus = math.random (damage / 2 + 2)
	end
	return math.ceil (damage + crit_bonus)
end

function ARROW_ENTITY:do_particle()
	if not self._is_critical or self._particle_id then return end
	self._particle_id = core.add_particlespawner({
		amount = ARROW_LIFETIME * 15,
		time = ARROW_LIFETIME,
		pos = vector.new (0.5, 0, 0),
		vel = vector.new (6.0, 0.0, 0.0),
		alpha_tween = {	1.0, 0.0, },
		exptime = 0.25,
		size = 2,
		attached = self.object,
		collisiondetection = true,
		collision_removal = true,
		vertical = false,
		texture = "mobs_mc_arrow_particle.png",
	})
end

-- Calculate damage, knockback, burning, and tipped effect to target.
function ARROW_ENTITY:apply_effects(obj)
	local dmg = self:calculate_damage()
	local reason = {
		type = "arrow",
		source = self._shooter,
		direct = self.object,
	}
	local damage = mcl_util.deal_damage(obj, dmg, reason)
	self:arrow_knockback(obj, damage)
	if mcl_burning.is_burning(self.object) then
		mcl_burning.set_on_fire(obj, 5)
	end
	if self._extra_hit_func then
		self:_extra_hit_func(obj)
	end
end

-- Remove critical partical effects.
function ARROW_ENTITY:stop_particle()
	if not self._particle_id then return end
	core.delete_particlespawner(self._particle_id)
	self._particle_id = nil
end

-- Remove particle effect, clear most object fields, extinguish fire (optional), and optionally set remaining life.
function ARROW_ENTITY:cut_off(lifetime, keep_fire)
	if not keep_fire then mcl_burning.extinguish(self.object) end
	self._startpos, self._ignored = nil, nil -- last pos is used by stuck step to spawn arrow item
	self:stop_particle()
	if lifetime then
		self._lifetime = ARROW_LIFETIME - lifetime
	end
end

-- Remove burning status, crit particle effect, and finally the arrow object.
function ARROW_ENTITY:remove()
	self:cut_off()
	self.object:remove()
end

-- Process hitting a non-player object.  Return true to play damage particle and sound.
function ARROW_ENTITY:on_hit_object(obj, lua, _)
	if not lua or (not lua.is_mob and not lua._hittable_by_projectile)
	or lua.name == "mobs_mc:enderman" then
		return false
	end
	self:apply_effects(obj)
	return true
end

-- Process hitting a player, deflect if shield blocked, or attach if not piercing.
function ARROW_ENTITY:on_hit_player(obj, _, ray_hit)
	if not enable_pvp then return false end
	local piercing = self._piercing or 0
	if piercing > 0 then -- Piercing ignore shield.
		self:apply_effects(obj)
		return true
	end

	local dot_attack = mcl_shields.find_angle(self:get_last_pos(), obj)
	if not dot_attack then return false end
	local can_block, stack = mcl_shields.can_block(obj, dot_attack)
	if can_block then
		local vec = self.object:get_velocity()
		local damage = self:calculate_damage(vec)
		mcl_shields.add_wear(obj, damage, stack)
		self._blocked = obj:get_player_name()
		self:arrow_knockback (obj, damage)
		self.object:set_velocity(vector.multiply(vec, -0.15))
		-- Intersection point can be in the past or future.
		self.object:set_pos(ray_hit.intersection_point or mcl_bows.add_bow_height(obj:get_pos()))
		return "break"-- Stop further collision check as the arrow has changed direction.
	end

	self:apply_effects(obj)
	self._in_player = true
	local placement = dot_attack < 0 and "front" or "back"
	self._rotation_station = placement == "front" and -90 or 90
	self._y_position = random_arrow_positions("y", placement)
	self._x_position = random_arrow_positions("x", placement)
	if self._y_position > 6 and self._x_position < 2 and self._x_position > -2 then
		self._attach_parent = "Head"
		self._y_position = self._y_position - 6
	elseif self._x_position > 2 then
		self._attach_parent = "Arm_Right"
		self._y_position = self._y_position - 3
		self._x_position = self._x_position - 2
	elseif self._x_position < -2 then
		self._attach_parent = "Arm_Left"
		self._y_position = self._y_position - 3
		self._x_position = self._x_position + 2
	else
		self._attach_parent = "Body"
	end
	self._z_rotation = math.random(-30, 30)
	self._y_rotation = math.random( -30, 30)
	self.object:set_attach(
		obj, self._attach_parent,
		vector.new(self._x_position, self._y_position, random_arrow_positions("z", placement)),
		vector.new(0, self._rotation_station + self._y_rotation, self._z_rotation)
	)
	self:cut_off(ATTACHED_ARROW_TIMEOUT)
	return "stop"
end

local STUCK_COLLISIONBOX = {
	-0.25, -0.25, -0.25,
	0.25, 0.25, 0.25,
}

function ARROW_ENTITY:update_collisionbox ()
	-- When stuck, slightly expand the collisionbox to prevent
	-- this arrow from being rendered as completely unlit.
	if self._stuck then
		self.object:set_properties ({
			collisionbox = STUCK_COLLISIONBOX,
		})
	else
		self.object:set_properties ({
			collisionbox = ARROW_ENTITY.initial_properties.collisionbox,
		})
	end
end

function ARROW_ENTITY:set_stuck (new_pos, node)
	local selfobj = self.object
	local self_pos = selfobj:get_pos()
	self:cut_off(STUCK_ARROW_TIMEOUT, "keep fire")
	self._stuck = true
	self._is_critical = false
	self._dragtime = 0
	self._stuckrechecktimer = 0
	self._piercing = 0
	self._ignored = nil
	if not self._stuckin then
		self._stuckin = core.get_nodepos (new_pos)
	end
	selfobj:set_velocity(vector.new(0, 0, 0))
	selfobj:set_acceleration(vector.new(0, 0, 0))
	core.sound_play({name = "mcl_bows_hit_other",gain=0.6,},
		{pos=self_pos, max_hear_distance=16}, true)
	selfobj:set_animation ({x = 10, y = 60,}, 210, 1.0, false)
	self._animtime = 0.0

	local new_pos = mcl_util.get_nodepos (new_pos)
	local new_node = core.get_node (new_pos)
	local def = core.registered_nodes[new_node.name]
	if (def and def._on_arrow_hit) then   -- Entities: Button, Candle etc.
		def._on_arrow_hit(new_pos, self)
	else                                  -- Nodes: TNT, Campfire, Target etc.
		def = core.registered_nodes[node.name]
		if (def and def._on_arrow_hit) then
			def._on_arrow_hit(self._stuckin, self)
		end
	end
	self:update_collisionbox ()

	return "stop"
end

-- Hit a non-liquid node.  Either arrow could be stopped by engine or on its way to target.
function ARROW_ENTITY:on_solid_hit (node_pos, node, collisiondata)
	if not node then
		node = core.get_node(node_pos)
	end
	if node.name == "air" or node.name == "ignore" then return end
	local dir = vector.normalize (collisiondata.old_vel)
	local movement = vector.multiply (dir, 0.15)
	local pos = vector.add (collisiondata.new_pos, movement)
	self.object:move_to (pos)
	local collision_node = core.get_node (collisiondata.collision_pos)
	return self:set_stuck (collisiondata.new_pos, collision_node)
end

function ARROW_ENTITY:on_liquid_passthrough (node, def) ---@diagnostic disable-line: unused-local
	-- Slow down arrow in liquids. 8 water blocks shall kill most horizontal velocity.
	-- Water visco = 1, Lava visco = 7, but mc lava seems to not slowdown arrows a lot?
	--local v = def.liquid_viscosity or 0
	self:multiply_xz_velocity (LIQUID_RATE)
end

-- Handle "arrow hitting things".  Return "stop" if arrow is stopped by this thing.
function ARROW_ENTITY:on_intersect(ray_hit)
	local selfobj = self.object
	local result
	local ignored = self._ignored or {}
	local attach = self._shooter and self._shooter:get_attach ()
	if ray_hit.type == "object" then
		local obj = ray_hit.ref
		if obj:is_valid() and obj:get_hp() > 0
			and (obj ~= self._shooter or self._left_shooter)
			and (obj ~= attach or self._left_shooter)
			and table.indexof(ignored, obj) == -1 then
			if obj:is_player() then
				result = self:on_hit_player(obj, obj:get_luaentity(), ray_hit)
			else
				result = self:on_hit_object(obj, obj:get_luaentity(), ray_hit)
			end
		end
		if result and result ~= "break" then
			table.insert(ignored, obj)
			local shooter = self._shooter
			local self_pos = selfobj:get_pos()
			if obj:is_player() and shooter and shooter:is_valid() and shooter:is_player() then
				-- “Ding” sound for hitting another player
				core.sound_play({name="mcl_bows_hit_player", gain=0.1}, {to_player=shooter:get_player_name()}, true)
			end
			damage_particles(vector.add(self_pos, vector.multiply(selfobj:get_velocity(), 0.1)), self._is_critical)
			core.sound_play({name="mcl_bows_hit_other", gain=0.3}, {pos=self_pos, max_hear_distance=16}, true)
			-- Reduce piercing if not stopped
			if result ~= "stop" then
				local piercing = self._piercing or 0
				if piercing <= 1 then
					self:remove()
					result = "stop"
				elseif piercing > 1 then
					self._piercing = piercing - 1
				end
			end
		end
	elseif ray_hit.type == "node" then
		local hit_node_pos = core.get_pointed_thing_position(ray_hit)
		local hit_node_hash = core.hash_node_position (hit_node_pos)
		if table.indexof(ignored, hit_node_hash) == -1 then
			local hit_node = core.get_node (hit_node_pos)
			local def = core.registered_nodes[hit_node.name or ""]
			-- Set fire when passing through lava or fire, or put out fire when passing through water.
			if core.get_item_group(hit_node.name, "set_on_fire") > 0 then
				mcl_burning.set_on_fire(selfobj, ARROW_LIFETIME)
			elseif core.get_item_group(hit_node.name, "puts_out_fire") > 0 then
				mcl_burning.extinguish(selfobj)
			end

			if def and def.liquidtype ~= "none" then
				result = self:on_liquid_passthrough(hit_node, def)
			elseif def and def.walkable then
				self._stuckin = hit_node_pos
				result = self:on_solid_hit (hit_node_pos, hit_node, {
					old_vel = self.object:get_velocity (),
					new_pos = ray_hit.intersection_point or self.object:get_pos (),
					collision_pos = hit_node_pos,
			})
			end
			table.insert(ignored, hit_node_hash)
		end
	end
	if not self._ignored and #ignored > 0 then
		self._ignored = ignored
	end
	return result
end

function ARROW_ENTITY:find_first_collision (moveresult)
	local first_collision
	local max_len = -math.huge

	for _, collision in ipairs (moveresult.collisions) do
		local len = vector.length (collision.old_velocity)
		if max_len < len then
			first_collision = collision
			max_len = len
		end
	end
	if first_collision then
		return first_collision.old_velocity,
			first_collision.new_pos,
			first_collision.node_pos
	end
	return nil
end

function ARROW_ENTITY:on_step(dtime, moveresult)
	local selfobj = self.object
	local self_pos = selfobj:get_pos()
	if not self_pos then return end
	local last_pos = self:get_last_pos()

	self._lifetime = self._lifetime + dtime
	if self._lifetime > ARROW_LIFETIME then
		self:remove()
		return
	end

	if self._in_player or self._stuck then
		mcl_burning.tick(selfobj, dtime, self)
		if self._stuck then
			self:step_on_stuck(last_pos, dtime)
		end
		return
	end

	self:do_particle()

	-- Apply drag
	if self._lifetime >= self._dragtime + DRAG_TICK then
		repeat
			self:multiply_xz_velocity(DRAG_RATE)
			self._dragtime = self._dragtime + DRAG_TICK
		until self._lifetime < self._dragtime + DRAG_TICK
	end

	local result = nil
	local shooter_located = false
	-- Raycasting movement during dtime to handle lava, water, and hits.
	local attach = self._shooter and self._shooter:get_attach ()
	for ray_hit in core.raycast(last_pos, self_pos, true, true) do
		if (self._shooter and ray_hit.ref == self._shooter)
			or (attach and ray_hit.ref == attach) then
			shooter_located = true
		end
		result = self:on_intersect(ray_hit)
		if result == "stop" or result == "break" then break end
	end
	if not shooter_located then
		self._left_shooter = true
	end

	-- Put out fire if exposed to rain, or if burning expires.
	mcl_burning.tick(selfobj, dtime, self)

	-- Look for colliding nodes within moveresult.
	if result ~= "stop" then
		local old_vel, new_pos, collision_pos
			= self:find_first_collision (moveresult)
		if collision_pos then
			self._stuckin = collision_pos
			local stuck_node = core.get_node (collision_pos)
			self:on_solid_hit (collision_pos, stuck_node, {
				old_vel = old_vel,
				new_pos = new_pos,
				collision_pos = collision_pos,
			})
		end
	end

	-- Predicting froward motion in anticipation of lag.  Pos and vel could be changed by shield.
	if result ~= "stop" then
		local vel = selfobj:get_velocity()
		self_pos = selfobj:get_pos()
		local predict = vector.add(self_pos, vector.multiply(vector.copy(vel), 0.05))
		for ray_hit in core.raycast(self_pos, predict, true, true) do
			if ray_hit.type == "node" then
				local hit_node_pos
					= core.get_pointed_thing_position (ray_hit)
				local hit_node = core.get_node (hit_node_pos)
				local def = core.registered_nodes[hit_node.name]
				if def and def.walkable then
					break -- Hit a node, stop prediction and defer to next step.
				end
			end
			result = self:on_intersect(ray_hit) -- Hit mob or player.
			if result == "stop" then break end
		end
	end

	-- Update yaw and internal variable.
	if not self._stuck then
		local vel = selfobj:get_velocity()
		if vel then
			local yaw = core.dir_to_yaw(vel)+YAW_OFFSET
			local pitch = dir_to_pitch(vel)
			selfobj:set_rotation({ x = 0, y = yaw, z = pitch })
		end
	end
	self._lastpos = self_pos
end

function ARROW_ENTITY:step_on_stuck(last_pos, dtime)
	local timer = ( self._stuckrechecktimer or 0 ) + dtime
	-- Drop arrow when it is no longer stuck
	if timer < STUCK_RECHECK_TIME then
		self._stuckrechecktimer = timer
		return
	end
	local t = self._animtime or 0.0
	self._animtime = t + dtime
	if t + dtime >= 0.30 then
		self.object:set_animation ({x = 0, y = 0,})
	end
	self._stuckrechecktimer = 0

	local self_pos = self.object:get_pos()
	-- Convert to a collectable item if a player is nearby (not in Creative Mode)
	for obj in core.objects_inside_radius(self_pos, PICKUP_RANGE) do
		if obj and obj:is_valid() and obj:is_player() and self._collectable then
			if not core.is_creative_enabled(obj:get_player_name()) then
				spawn_item(self, self_pos)
			end
			self:remove()
			return
		end
	end

	if self._stuckin then
		local stuckin_name = core.get_node(self._stuckin).name
		if stuckin_name == "air" then
		-- local stuckin_def = core.registered_nodes[stuckin_name]
		-- if stuckin_def and stuckin_def.walkable == false then
			self._stuck = false
			self._stuckin = nil
			self._startpos = self_pos
			self._lastpos = self_pos
			self._lifetime = 0
			self._dragtime = 0
			self._is_critical = false
			self.object:set_animation ({x = 0, y = 0,})
			self.object:set_acceleration({x=0, y=-GRAVITY, z=0})
			self:update_collisionbox ()
		end
	end
end

-- Force recheck of stuck arrows when punched.
-- Otherwise, punching has no effect.
function ARROW_ENTITY:on_punch()
	if self._stuck then
		self._stuckrechecktimer = STUCK_RECHECK_TIME
	end
end

function ARROW_ENTITY:get_staticdata()
	local out = {
		lastpos = self._lastpos,
		startpos = self._startpos,
		dragtime = self._dragtime,
		damage = self._damage,
		piercing = self._piercing,
		blocked = self._blocked,
		is_critical = self._is_critical,
		stuck = self._stuck,
		stuckin = self._stuckin,
		stuckin_player = self._in_player,
		itemstring = self._itemstring,
	}
	-- If _lifetime is missing for some reason, assume the maximum
	if not self._lifetime then
		self._lifetime = ARROW_LIFETIME
	end
	out.starttime = core.get_gametime() - self._lifetime
	if self._shooter and self._shooter:is_player() then
		out.shootername = self._shooter:get_player_name()
	end
	return core.serialize(out)
end

function ARROW_ENTITY:on_activate(staticdata)
	local data = core.deserialize(staticdata)
	if data then
		-- First, check if the arrow is already past its life timer. If
		-- yes, delete it. If starttime is nil always delete it.
		self._lifetime = core.get_gametime() - (data.starttime or 0)
		if self._lifetime > ARROW_LIFETIME or data.stuckin_player then
			self:remove()
			return
		end
		self._stuck = data.stuck
		if data.stuck then
			-- Perform a stuck recheck on the next step.
			self._stuckrechecktimer = STUCK_RECHECK_TIME
			self._stuckin = data.stuckin
		end

		-- Get the remaining arrow state
		self._lastpos = data.lastpos
		self._startpos = data.startpos or self.object:get_pos()
		self._dragtime = data.dragtime or 0
		self._damage = data.damage or 0
		self._piercing = data.piercing or 0
		self._blocked = data.blocked or false
		self._is_critical = data.is_critical or false
		self._itemstring = data.itemstring
		self._is_arrow = true
		if data.shootername then
			local shooter = core.get_player_by_name(data.shootername)
			if shooter and shooter:is_player() then
				self._shooter = shooter
			end
		end
		self:update_collisionbox ()
		self:do_particle ()
	end
	self.object:set_armor_groups({ immortal = 1 })
end

function ARROW_ENTITY:on_deactivate()
	self:stop_particle()
end

core.register_on_respawnplayer(function(player)
	for _, obj in pairs(player:get_children()) do
		local ent = obj:get_luaentity()
		if ent and ent.name and string.find(ent.name, "mcl_bows:arrow_entity") then
			obj:remove()
		end
	end
end)

core.register_entity("mcl_bows:arrow_entity", ARROW_ENTITY)

core.register_craft({
	output = "mcl_bows:arrow 4",
	recipe = {
		{"mcl_core:flint"},
		{"mcl_core:stick"},
		{"mcl_mobitems:feather"}
	}
})

doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
