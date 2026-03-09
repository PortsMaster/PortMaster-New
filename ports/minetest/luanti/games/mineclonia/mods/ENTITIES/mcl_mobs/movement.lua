local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

function mob_class:target_visible(origin, target)
	-- This cache is flushed on each call to on_step.
	if self._targets_visible[target] then
		return true
	end

	local target_pos = mcl_util.target_eye_pos (target)
	local origin_eye_pos = vector.offset (origin, 0, self.head_eye_height, 0)

	if self:line_of_sight (origin_eye_pos, target_pos) then
		self._targets_visible[target] = true
		return true
	end

	self._targets_visible[target] = false
	return false
end

-- Check line of sight:
-- http://www.cse.yorku.ca/~amana/research/grid.pdf
-- The ubiquitous slab method of intersecting rays with
-- AABBs.

local function signum (number)
	return number == 0.0 and 0 or number < 0 and -1 or 1
end

local function genbox (box, node)
	box[1] = box[1] + node.x
	box[2] = box[2] + node.y
	box[3] = box[3] + node.z
	box[4] = box[4] + node.x
	box[5] = box[5] + node.y
	box[6] = box[6] + node.z
end

local function maxnum (a, b)
	return math.max (a, b)
end

local function minnum (a, b)
	return math.min (a, b)
end

-- This is a Minetest internal function that enables this frequently
-- invoked function to avoid table allocation and consequently
-- generated garbage.
local get_node_raw = mcl_mobs.get_node_raw

local function get_node (node)
	if get_node_raw then
		local content, _, _ = get_node_raw (node.x, node.y, node.z)
		return core.get_name_from_content_id (content)
	else
		local data = core.get_node (node)
		return data.name
	end
end

local function aabb_clear (node, origin, pos2, direction, dist, typetest)
	local node_type = get_node (node)
	if node_type == "air" then
		return true
	else
		local def = core.registered_nodes[node_type]
		if def and not def.walkable then
			return true
		elseif typetest and typetest (node_type, def) then
			return true
		elseif not def then
			return false
		end
	end
	local boxes = core.get_node_boxes ("collision_box", node)

	for _, box in ipairs (boxes) do
		genbox (box, node)
		local x1, y1, z1, x2, y2, z2
			= box[1], box[2], box[3], box[4], box[5], box[6]

		local min, max = -1/0, 1/0
		-- X face.
		local n1 = (x1 - origin.x) * direction.x
		local f1 = (x2 - origin.x) * direction.x
		if n1 > f1 then
			n1, f1 = f1, n1
		end
		min = maxnum (min, n1)
		max = minnum (max, f1)

		-- Y face.
		local n2 = (y1 - origin.y) * direction.y
		local f2 = (y2 - origin.y) * direction.y
		if n2 > f2 then
			n2, f2 = f2, n2
		end
		min = maxnum (min, n2)
		max = minnum (max, f2)

		-- Z face.
		local n3 = (z1 - origin.z) * direction.z
		local f3 = (z2 - origin.z) * direction.z
		if n3 > f3 then
			n3, f3 = f3, n3
		end
		min = maxnum (min, n3)
		max = minnum (max, f3)
		local x = min < 0 and max or min
		-- Intersection with furthest near face is within the
		-- vector.
		if (x <= dist)
			-- Intersection with closest far face
			-- falls after the origin.
			and (max >= 0)
			-- luacheck: push ignore 581
			and not (max <= min) then
			-- luacheck: pop
			return false
		end
	end
	return true
end

local line_of_sight_scratch = vector.zero ()

local function mod (x)
	return x - math.floor (x)
end

local scale_poses_scratch = vector.zero ()
local scale_poses_scratch_1 = vector.zero ()

local function scale_poses (pos1, pos2)
	local v1, v2 = scale_poses_scratch, scale_poses_scratch_1
	v1.x = pos1.x + 1.0e-7
	v1.y = pos1.y + 1.0e-7
	v1.z = pos1.z + 1.0e-7
	v2.x = pos2.x + -1.0e-7
	v2.y = pos2.y + -1.0e-7
	v2.z = pos2.z + -1.0e-7
	return v1, v2
end

local fast_direction_scratch = vector.zero ()

local function dir_and_magnitude (a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	local v = fast_direction_scratch
	local magnitude = math.sqrt (dx * dx + dy * dy + dz * dz)
	v.x = dx / magnitude
	v.y = dy / magnitude
	v.z = dz / magnitude
	return v, magnitude
end

function mob_class:line_of_sight (pos1, pos2, typetest)
	-- Move pos1 and pos2 by minuscule values to avoid generating
	-- Inf or NaN.
	pos1, pos2 = scale_poses (pos1, pos2)
	local traveledx = mod (pos1.x + 0.5)
	local traveledy = mod (pos1.y + 0.5)
	local traveledz = mod (pos1.z + 0.5)
	local x = math.floor (pos1.x + 0.5)
	local y = math.floor (pos1.y + 0.5)
	local z = math.floor (pos1.z + 0.5)
	local dx, dy, dz = pos2.x - pos1.x, pos2.y - pos1.y, pos2.z - pos1.z
	local sx, sy, sz = signum (dx), signum (dy), signum (dz)
	local stepx, stepy, stepz = sx / dx, sy / dy, sz / dz
	local direction, dist = dir_and_magnitude (pos1, pos2)

	-- Precompute reciprocal.
	direction.x = 1.0 / direction.x
	direction.y = 1.0 / direction.y
	direction.z = 1.0 / direction.z

	if sx == 0 then
		traveledx = 1.0
	elseif sx > 0 then
		traveledx = stepx * (1.0 - traveledx)
	else
		traveledx = stepx * (traveledx)
	end
	if sy == 0 then
		traveledy = 1.0
	elseif sy > 0 then
		traveledy = stepy * (1.0 - traveledy)
	else
		traveledy = stepy * (traveledy)
	end
	if sz == 0 then
		traveledz = 1.0
	elseif sz > 0 then
		traveledz = stepz * (1.0 - traveledz)
	else
		traveledz = stepz * (traveledz)
	end

	local v = line_of_sight_scratch
	v.x = x
	v.y = y
	v.z = z
	if not aabb_clear (v, pos1, pos2, direction, dist, typetest) then
		return false, v
	end

	while (traveledx <= 1.0)
		or (traveledy <= 1.0)
		or (traveledz <= 1.0) do
		if traveledx < traveledy then
			if traveledx < traveledz then
				x = x + sx
				traveledx = traveledx + stepx
			else
				z = z + sz
				traveledz = traveledz + stepz
			end
		else
			if traveledy < traveledz then
				y = y + sy
				traveledy = traveledy + stepy
			else
				z = z + sz
				traveledz = traveledz + stepz
			end
		end

		v.x = x
		v.y = y
		v.z = z

		if not aabb_clear (v, pos1, pos2, direction, dist) then
			return false, v
		end
	end

	return true
end

function mob_class:check_jump (self_pos, moveresult)
	local max_y = nil
	local dir = vector.zero ()

	-- Read the height of every colliding node in moveresult,
	-- and the node above.
	for _, item in pairs (moveresult.collisions) do
		if item.type == "node"
			and (item.new_velocity.x ~= item.old_velocity.x
			     or item.new_velocity.z ~= item.old_velocity.z) then
			dir.x = dir.x + item.old_velocity.x - item.new_velocity.x
			dir.z = dir.z + item.old_velocity.z - item.new_velocity.z
			local pos = item.node_pos
			local boxes = core.get_node_boxes ("collision_box", pos)
			if pos.y + 0.5 > self_pos.y then
				for _, box in ipairs (boxes) do
					max_y = math.max (max_y or 0, pos.y + box[2], pos.y + box[5])
				end
			end
		end
	end

	if max_y and (max_y > self_pos.y)
		and (max_y - self_pos.y > self._initial_step_height) then
		-- Verify that the direction of the collision measured as a
		-- force substantially matches the direction of movement.
		dir = vector.normalize (dir)
		local yaw = self:get_yaw ()
		local d = math.atan2 (dir.z, dir.x) - math.pi / 2
		local diff = math.atan2 (math.sin (d - yaw), math.cos (yaw - d))
		return math.abs (diff) < math.rad (40) -- ~40 deg.
	end
end

local function in_list(list, what)
	return type(list) == "table" and table.indexof(list, what) ~= -1
end

-- should mob follow what I'm holding ?
function mob_class:follow_holding(clicker)
	local item = clicker:get_wielded_item()
	if in_list(self.follow, item:get_name()) then
		return true
	end
	return false
end

local norm_radians = nil

core.register_on_mods_loaded (function ()
		norm_radians = mcl_util.norm_radians
end)

local function clip_rotation (from, to, limit)
	local difference = norm_radians (to - from)
	if difference > limit then
		difference = limit
	end
	if difference < -limit then
		difference = -limit
	end
	return from + difference
end

mcl_mobs.clip_rotation = clip_rotation

function mob_class:look_at (b, clip_to)
	local mob = self:mob_controlling_movement ()
	local s = mob.object:get_pos()
	local yaw = (math.atan2 (b.z - s.z, b.x - s.x) - math.pi / 2)
	if clip_to then
		local old_yaw = mob:get_yaw ()
		local x = clip_rotation (old_yaw, yaw, clip_to)
		yaw = x
	end
	mob:set_yaw (yaw)
end

function mob_class:go_to_pos (b, velocity, animation)
	local mob = self:mob_controlling_movement ()
	mob.movement_goal = "go_pos"
	mob.movement_target = b
	mob.movement_velocity = velocity or mob.movement_speed
	mob:set_animation (animation or "walk")
end

function mob_class:teleport(target)
	if self.do_teleport then
		if self.do_teleport(self, target) == false then
			return
		end
	end
end

------------------------------------------------------------------------
-- Jockeys.
------------------------------------------------------------------------

local MODEL_RECIPROCAL = 1.0 / 10.0

function mob_class:jock_to (mob, relative_pos, rot, fix_eye_height)
	local jock = core.add_entity (self.object:get_pos (), mob)
	if not jock then return end
	return self:jock_to_existing (jock, "", relative_pos, rot,
				      fix_eye_height)
end

function mob_class:jock_to_existing (jock, bone, relative_pos, rot,
				     fix_eye_height)
	local entity = jock:get_luaentity ()
	-- Controlling mobs in jockeys are not saved directly, but in
	-- the staticdata of their vehicles.
	self.jockey_vehicle = jock
	-- Fix the visual size of this mob.
	local jock_properties = jock:get_properties ()
	local properties = self.object:get_properties ()
	self._original_visual_size = properties.visual_size
	-- CAUTION: it is far too involved to get this to function
	-- correctly in the presence of nested attachments that differ
	-- in visual size, and consequently, if multiple objects are
	-- to be jocked above each other, they _must_ share a
	-- visual_size of 1.
	self.object:set_properties ({
			static_save = false,
			visual_size = {
				x = properties.visual_size.x
					/ jock_properties.visual_size.x,
				y = properties.visual_size.y
					/ jock_properties.visual_size.y,
			},
	})
	entity._jockey_rider = self.object
	entity._jockey_relative_pos = relative_pos
	entity._jockey_bone = bone
	entity._jockey_rot = rot
	entity._jockey_rider_non_dominant = not self._dominant_in_jockeys
	entity._jockey_fix_eye_height = fix_eye_height
	if fix_eye_height then
		-- Caveat emptor: FIX_EYE_HEIGHT when specified will
		-- not prompt eye height to be readjusted when the
		-- mob's parent's eye height is adjusted, or account
		-- for more than one mob in the attachment chain.
		-- Neither will it function if BONE is not the base of
		-- the object, as bone offsets are unavailable to
		-- server-side programs.
		local pos = relative_pos.y * MODEL_RECIPROCAL
		self._jockey_eye_offset
			= pos / jock_properties.visual_size.y
	else
		self._jockey_eye_offset = 0
	end
	self.object:set_attach (jock, bone, relative_pos, rot)
	self:set_animation ("jockey")
	return jock
end

function mob_class:dismount_jockey ()
	self:unjock ()
	local vehicle = self.jockey_vehicle:get_luaentity ()
	self.jockey_vehicle = nil
	if vehicle._jockey_rider == self.object then
		vehicle._jockey_rider = nil
		vehicle._jockey_staticdata = nil
		return
	end
end

function mob_class:check_jockey_status ()
	-- Remove any jockey that is no longer valid and was not
	-- expressly removed.
	if self._jockey_rider and not is_valid (self._jockey_rider) then
		self._jockey_rider = nil
		self._jockey_staticdata = nil
		core.log ("warning", "Rider of jockeyed mob "
			      .. self.name .. " disappeared abruptly")
	end

	-- If this mob's mount has vanished, remove itself also.
	if self.jockey_vehicle then
		local attach = self.object:get_attach ()
		if not attach or attach ~= self.jockey_vehicle then
			core.log ("warning", "Jockeyed mob controlled by "
				      .. self.name .. " disappeared abruptly")
			self.object:remove ()
			return true
		end
	end
end

function mob_class:on_deactivate (removal)
	if self.raidmob then
		mcl_raids.unload_raidmob (self, removal)
	end

	if self.jockey_vehicle then
		-- Dismount the jockey if this mob is to be
		-- permanantly removed, and otherwise, save its
		-- staticdata into its vehicle.
		if not removal then
			local entity = self.jockey_vehicle:get_luaentity ()
			if entity then
				-- XXX: is it possible that a jockey's
				-- passenger should be unloaded
				-- independently of its vehicle?
				entity._jockey_rider = nil
				entity._jockey_staticdata
					= self:get_staticdata_table ()
				entity._jockey_staticdata.name = self.name
			end
		else
			local entity = self.jockey_vehicle:get_luaentity ()
			if entity then
				entity._jockey_rider = nil
				entity._jockey_staticdata = nil
			end
		end
	end

	if self._jockey_rider and is_valid (self._jockey_rider) then
		-- Save the rider's staticdata.
		local entity = self._jockey_rider:get_luaentity ()
		local staticdata = entity:get_staticdata_table ()
		entity.jokey_vehicle = nil
		self._jockey_rider:remove ()
		self._jockey_staticdata = staticdata
		self._jockey_staticdata.name = entity.name
		self._jockey_rider = nil
	end

	if self._activated then
		self:remove_for_spawning ()
	end

	if self.particlespawners then
		for player in mcl_util.connected_players () do
			local name = player:get_player_name ()
			self:remove_particlespawners (name)
		end
	end

	if self.wears_armor then
		mcl_armor.head_entity_unequip (self.object)
	end
end

function mob_class:jockey_death ()
	if self.jockey_vehicle then
		local entity = self.jockey_vehicle:get_luaentity ()
		if entity then
			entity._jockey_staticdata = nil
			entity._jockey_rider = nil
		end
	end
	if self._jockey_rider then
		local entity = self._jockey_rider:get_luaentity ()
		if entity then
			entity.jockey_vehicle = nil
			entity:unjock ()
			self._jockey_rider = nil
			self._jockey_staticdata = nil
		end
	end
end

function mob_class:restore_jockey ()
	if self._jockey_staticdata and not self._jockey_rider then
		local name = self._jockey_staticdata.name
		if not name then
			self._jockey_staticdata = nil
			return
		end
		-- Don't serialize name.
		self._jockey_staticdata.name = nil
		local serialized = core.serialize (self._jockey_staticdata)
		local jock = core.add_entity (self.object:get_pos (),
						  name, serialized)
		if jock then
			local entity = jock:get_luaentity ()
			local relative_pos = self._jockey_relative_pos
			local rot = self._jockey_rot
			local bone = self._jockey_bone
			local fix_eye_height = self._jockey_fix_eye_height
			entity:jock_to_existing (self.object, bone, relative_pos, rot,
						 fix_eye_height)
		end
		self._jockey_staticdata = nil
	end
end

function mob_class:mob_controlling_movement ()
	if self.jockey_vehicle then
		local attached = self.object:get_attach ()
		local entity = attached and attached:get_luaentity ()
		return entity:mob_controlling_movement () or self
	end
	return self
end

function mob_class:unjock ()
	self.object:set_detach ()
	self.object:set_properties ({
		static_save = true,
		-- XXX: what about mobs which alter their visual
		-- sizes?
		visual_size = self._original_visual_size,
	})
end

--------------------------------------------------------------------------------
--- Movement mechanics for flying/swimming/landed mobs.
--------------------------------------------------------------------------------

local ZERO_VECTOR = vector.zero ()

function mob_class:do_go_pos (dtime, moveresult)
	local target = self.movement_target or ZERO_VECTOR
	local vel = self.movement_velocity
	local pos = self.object:get_pos ()
	local dist = vector.distance (pos, target)

	if dist < 0.0005 then
		self.acc_dir.z = 0
		self.acc_dir.x = 0
		self.acc_dir.y = 0
		return
	end

	self:look_at (target, math.pi / 2 * (dtime / 0.05))
	self:set_velocity (vel)

	local node_surface = pos.y
	local target_node_surface = math.floor (target.y + 0.5) - 0.5

	if self:check_jump (pos, moveresult) then
		if self.should_jump and self.should_jump > 2
		-- Be more eager to jump if it is really certain that
		-- this mob expects to do so.
			or target_node_surface - node_surface >= 0.98 then
			self._jump = true
			self.movement_goal = "jump"
			self.should_jump = 0
		else
			-- Jump again if the collision remains after
			-- the next step.
			local i = self.should_jump or 0
			self.should_jump = i + 1
		end
		return
	end
end

function mob_class:do_jump_goal (dtime, moveresult)
	local vel = self.movement_velocity

	-- Continue accelerating until contact is made with the
	-- ground, but do not rotate while jumping.
	self:set_velocity (vel)

	if not self._jump
		and (moveresult.touching_ground or moveresult.standing_on_object) then
		self.movement_goal = nil
	end
end

function mob_class:do_strafe (dtime, moveresult)
	local vel = self.movement_velocity
	local sx, sz = self.strafe_direction.x, self.strafe_direction.z
	local magnitude = sx * sx + sz * sz

	-- "Normalize" direction if greater than 1.
	if magnitude > 1 then
		vel = vel / magnitude
	end

	-- Don't jump off ledges or head into unwalkable nodes if
	-- strafing in reverse or to the sides.
	local node, est_dx, est_dz
	local v = { x = sx * vel, y = 0, z = sz * vel, }
	local self_pos = self.object:get_pos ()
	est_dx, est_dz = self:accelerate_relative (v, vel, vel)
	node = vector.offset (self_pos,
			      -- Scale the delta to reflect the
			      -- quantity of movement applied in one
			      -- Minecraft tick.
			      est_dx * 0.05, 0, est_dz * 0.05)
	node.x = math.floor (node.x + 0.5)
	node.y = math.floor (node.y + 0.5)
	node.z = math.floor (node.z + 0.5)

	if self:gwp_classify_for_movement (node) ~= "WALKABLE" then
		self.strafe_direction.x, sx = 0, 0
		self.strafe_direction.z, sz = 1, 1
	end

	-- Begin strafing.
	self.acc_speed = vel
	self.acc_dir.x = sx
	self.acc_dir.z = sz
end

function mob_class:halt_in_tracks (immediate, keep_animation)
	local mob = self:mob_controlling_movement ()
	mob.acc_dir.z = 0
	mob.acc_dir.y = 0
	mob.acc_dir.x = 0
	mob.acc_speed = 0
	mob._acc_movement_speed = 0
	mob._acc_y_fixed = nil
	mob.movement_goal = nil
	mob._acc_no_gravity = false

	if not keep_animation
		and (mob._current_animation == "walk"
			or mob._current_animation == "run") then
		mob:set_animation ("stand")
	end

	if immediate then
		local v = vector.zero ()
		mob.object:set_acceleration (v)
		mob.object:set_velocity (v)
	end
end

function mob_class:movement_step (dtime, moveresult)
	if self.dead then
		return
	end
	if self.movement_goal == nil then
		-- Arrest movement.
		self.acc_dir.z = 0
		self.acc_dir.y = 0
		self.acc_dir.x = 0
		self.acc_speed = 0
		return
	elseif self.movement_goal == "go_pos" then
		self:do_go_pos (dtime, moveresult)
	elseif self.movement_goal == "jump" then
		self:do_jump_goal (dtime, moveresult)
	elseif self.movement_goal == "strafe" then
		self:do_strafe (dtime, moveresult)
	end
end

------------------------------------------------------------------------
-- Mob navigation.
------------------------------------------------------------------------

function mob_class:is_navigating ()
	local mover = self:mob_controlling_movement ()
	return mover.waypoints or mover.stupid_target
end

function mob_class:navigation_finished ()
	local mover = self:mob_controlling_movement ()
	if mover.waypoints or mover.pathfinding_context then
		return false
	end
	if mover.stupid_target then
		local v = mover.object:get_pos ()
		local target = vector.new (mover.stupid_target.x,
					   v.y, mover.stupid_target.z)
		if vector.distance (v, target) > 0.5 then
			return false
		end
		mover:cancel_navigation ()
	end
	return true
end

function mob_class:navigation_step (dtime, moveresult)
	if self.waypoints or self.pathfinding_context then
		self:next_waypoint (dtime)
	elseif self.stupid_target then
		self:go_to_pos (self.stupid_target, self.stupid_velocity)
	end
end

function mob_class:cancel_navigation ()
	local mob = self:mob_controlling_movement ()
	mob.pathfinding_context = nil
	mob.waypoints = nil
	mob.stupid_target = nil
	mob.movement_goal = nil
	mob._last_wp = nil
end

function mob_class:go_to_stupidly (pos, factor)
	local mob = self:mob_controlling_movement ()
	mob.stupid_target = pos
	mob.stupid_velocity = mob.movement_speed * (factor or 1)
end

------------------------------------------------------------------------
-- Navigation wrapper.
------------------------------------------------------------------------

local DEFAULT_REPATH_INTERVAL = 6.0
local RETRY_INTERVAL_BASE = 1.0
local MINIMUM_REPATH_INTERVAL = 0.5
local MAX_RETRIES = 5

function mob_class:session_navigate (destination, bonus, tolerance, repath_interval, repath_min,
					max_retries, max_frustration)
	local mob = self:mob_controlling_movement ()
	local dest = mcl_util.get_nodepos (destination)
	mob._navigation_session = {
		destination = dest,
		bonus = bonus,
		repath_interval
			= repath_interval or DEFAULT_REPATH_INTERVAL,
		repath_min = repath_min or MINIMUM_REPATH_INTERVAL,
		repath_timer = 0,
		path_requested = 0,
		tolerance = tolerance or 0,
		total_time = 0,
		was_partial = false,
		last_partial = nil,
		partial_check = 0,
		max_retries = max_retries or MAX_RETRIES,
		max_frustration = max_frustration,
	}
	mob:gopath_internal (dest, bonus, nil, tolerance)
end

local function clamp (x, a, b)
	if a > b then
		a, b = b, a
	end

	return math.min (math.max (x, a), b)
end

local function has_strayed (self_pos, last_wp, next_wp)
	if not last_wp then
		return vector.distance (self_pos, next_wp) >= 3.0
	end
	local vec = vector.subtract (next_wp, last_wp)
	local pos = vector.subtract (self_pos, last_wp)
	local proj = vector.dot (vec, pos)
	local norm = vector.normalize (vec)
	local closest = vector.multiply (norm, proj)
	closest.x = clamp (closest.x, 0, vec.x)
	closest.y = clamp (closest.y, 0, vec.y)
	closest.z = clamp (closest.z, 0, vec.z)
	local dx = closest.x - pos.x
	local dy = closest.y - pos.y
	local dz = closest.z - pos.z
	local diff = math.sqrt (dx * dx + dy * dy + dz * dz)
	return diff >= 2.0
end

local function get_new_target (self, current, new)
	if not vector.equals (new, current) then
		local aligned = mcl_util.get_nodepos (new)
		if not vector.equals (aligned, current) then
			return aligned
		end
	end
	return nil
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

-- Return the state of the current navigation session.
-- Value is:
--
--   "failed", if navigation failed to bring this mob to its
--   destination.
--
--   "wait", if navigation is proceeding or a timeout is being
--   processed.
--
--   "arrived", if navigation completed successfully or was
--   terminated.

function mob_class:poll_navigation_state (self_pos, dtime, timeout, new_target)
	local mob = self:mob_controlling_movement ()
	if mob ~= self then
		self_pos = mob.object:get_pos ()
	end
	local session = self._navigation_session
	if not session then
		return "arrived"
	end
	local destination = session.destination
	local bonus = session.bonus
	local tolerance = session.tolerance

	if timeout then
		local total_time = session.total_time + dtime
		session.total_time = total_time

		if total_time > timeout then
			mob:cancel_navigation ()
			mob:halt_in_tracks ()
			return "failed"
		end
	end

	-- If pathfinding is still in progress, wait for its
	-- completion.
	if mob.pathfinding_context then
		return "wait"
	end

	-- A path was just requested.  If no path now exists, this
	-- navigation should be considered to have failed; likewise
	-- if the terminus of this path.
	local path_requested = session.path_requested
	if path_requested and not mob.waypoints then
		if path_requested >= session.max_retries then
			return "failed"
		end

		-- If the distance between the current position and
		-- the destination is within the defined tolerance,
		-- this mob has arrived at its destination.
		local startpos = self:gwp_align_start_pos (self_pos)
		if manhattan3d (startpos, destination) <= tolerance then
			return "arrived"
		end

		-- Retry in a staggered fashion.
		if session.repath_timer <= 0 then
			local t = session.repath_timer
				+ RETRY_INTERVAL_BASE
				+ math.random () * RETRY_INTERVAL_BASE
			session.repath_timer = t
		else
			local t = session.repath_timer - dtime
			session.repath_timer = t

			if t <= 0 then
				local destination = session.destination
				local bonus = session.bonus
				session.path_requested = path_requested + 1

				-- Always use a new target if specified.
				if new_target then
					destination = mcl_util.get_nodepos (new_target)
					session.destination = destination
					session.last_partial = nil
				end
				mob:gopath_internal (destination, bonus, nil, tolerance)
			end
		end

		return "wait"
	end

	local t = session.repath_timer - dtime
	session.repath_timer = t
	session.path_requested = nil

	-- Has this mob strayed very far from the next waypoint along
	-- the path?  If so, recompute this path.
	if mob.waypoints then
		local n_waypoints = #mob.waypoints
		local next_wp = mob.waypoints[n_waypoints]
		local new_target = new_target
			and get_new_target (self, destination, new_target)
		local last_wp = self._last_wp
		local terminus = mob.waypoints[1]

		-- Check for frustration...  If the destination is
		-- identical to the previous partial position,
		-- increment the frustration counter.
		if session.max_frustration and session.last_partial
			and vector.equals (terminus, session.last_partial) then
			local count = session.partial_check + 1
			session.partial_check = count
			session.last_partial = nil

			if count >= session.max_frustration then
				return "failure"
			end
		end

		-- mob.waypoints.target is set if the path is
		-- complete.
		session.was_partial = not mob.waypoints.target
		if (t < -session.repath_min
			and (has_strayed (self_pos, last_wp, next_wp)
				or new_target))
			or t < -session.repath_interval then
			session.repath_timer = 0
			session.path_requested = 0
			if new_target then
				destination = new_target
				session.destination = new_target
				session.last_partial = nil
			end
			mob:gopath_internal (destination, bonus, nil, tolerance)
		end

		return "wait"
	end

	-- Navigation has completed.  Attempt to detect whether this
	-- mob has arrived at its destination, and if not, attempt to
	-- return to the destination.
	if session.was_partial or mob._gwp_did_timeout then
		session.repath_timer = 0
		session.path_requested = 0
		-- Always use a new target if specified.
		if new_target then
			destination = mcl_util.get_nodepos (new_target)
			session.destination = destination
			session.last_partial = nil
		else
			-- Remember the position of the waypoint just
			-- passed.  If another partial path is created
			-- to the same position, indicate failure.
			session.last_partial = self._last_wp
		end
		mob:gopath_internal (destination, bonus, nil, tolerance)
		return "wait"
	end

	self._navigation_session = nil
	self:halt_in_tracks ()
	return "arrived"
end

------------------------------------------------------------------------
-- Mob AI.
------------------------------------------------------------------------

function mob_class:ascend_in_powder_snow (self_pos, dtime)
	local in_powder_snow
		= self.standing_on == "mcl_powder_snow:powder_snow"
		or self.standing_in == "mcl_powder_snow:powder_snow"
	if in_powder_snow then
		local block_above = vector.offset (self_pos, 0, 1, 0)
		local node = core.get_node (block_above)
		local def = core.registered_nodes[node.name]
		if node.name == "mcl_powder_snow:powder_snow"
			or (def and not def.walkable) then
			self._jump = true
			return "_ascending_in_powder_snow"
		end
	end
	return false
end

local function convert_top_snow (node)
	local nodedata = core.get_node (node)
	if core.get_item_group (nodedata.name, "top_snow") <= 2 then
		return node
	end

	-- Otherwise move to the air node above.
	node.y = node.y + 1
	return node
end

function mob_class:pacing_target (pos, width, height, groups)
	local aa = vector.new (pos.x - width, pos.y - height, pos.z - width)
	local bb = vector.new (pos.x + width, pos.y + height, pos.z + width)
	local nodes = core.find_nodes_in_area_under_air (aa, bb, groups)

	if (self._restrict_center or self.acceptable_pacing_target)
		and #nodes >= 1 then
		-- Make ten attempts to select a node within the
		-- restriction or one that is eligible.
		for i = 1, 10 do
			local node = nodes[math.random (#nodes)]
			if self:node_in_restriction (node)
				and (not self.acceptable_pacing_target
					or self:acceptable_pacing_target (node)) then
				return convert_top_snow (node)
			end
		end
		return nil
	end

	return #nodes >= 1 and convert_top_snow (nodes[math.random (#nodes)])
end

function mob_class:target_in_shade (pos, width, height)
	local groups = {"group:solid", "group:water"}
	local aa = vector.new (pos.x - width, pos.y - height, pos.z - width)
	local bb = vector.new (pos.x + width, pos.y + height, pos.z + width)
	local nodes = core.find_nodes_in_area_under_air (aa, bb, groups)

	-- Minecraft tries ten times every tick.
	if #nodes < 1 then
		return nil
	end

	local newnode = {}
	for i = 1, 10 do
		local node = nodes[math.random (#nodes)]
		newnode.x = node.x
		newnode.y = node.y + 1
		newnode.z = node.z
		local sunlight
			= core.get_natural_light (newnode, 0.5)
		if sunlight < 15 then
			return newnode
		end
	end
	return nil
end

function mob_class:random_node_direction (limx, limy, direction, range)
	local input = math.atan2 (direction.z, direction.x) - math.pi/2
	local yaw = input + (2 * math.random () - 1.0) * range
	local xdist = math.sqrt (math.random () * 2) * limx
	local x, z = xdist * -math.sin (yaw), xdist * math.cos (yaw)
	local y = math.random (2 * limy + 1) - limy

	if math.abs (x) <= limx and math.abs (y) <= limx then
		return vector.new (math.floor (x),
					math.floor (y),
					math.floor (z))
	end
	return nil
end

function mob_class:target_away_from (pos, pursuer)
	local forward_dir = vector.subtract (pos, pursuer)
	return self:target_in_direction (pos, 14, 7, forward_dir,
					 math.pi / 2)
end

function mob_class:target_in_direction (pos, xmax, ymax, dir, deviation)
	for i = 1, 10 do
		local dir = self:random_node_direction (xmax, ymax, dir,
							deviation)
		if dir then
			local pos = vector.add (pos, dir)
			if self:node_in_restriction (pos) then
				local class = self:gwp_classify_for_movement (pos)
				if class == "WALKABLE" then
					return pos
				end
			end
		end
	end
end

local IDLE_TIME_MAX = 250

local levelgen_enabled = mcl_levelgen.levelgen_enabled
local conv_pos_dimension = mcl_levelgen.conv_pos_dimension
local is_generated = mcl_levelgen.is_generated
local floor = math.floor

function mcl_mobs.is_position_completely_generated (pos)
	if levelgen_enabled then
		local x, y, z, dim = conv_pos_dimension (pos)
		return not dim or is_generated (dim, floor (x / 16),
						floor (y / 16),
						floor (z / 16))
	end
	return true
end

function mob_class:init_ai ()
	self.ai_idle_time = 2 + math.random (2)
	if self._active_activity then
		self[self._active_activity]  = nil
		self._active_activity = nil
		self._can_interrupt_activity = false
	end
	self:cancel_navigation ()
	self:halt_in_tracks ()

	if self.swims then
		self:gwp_configure_aquatic_mob (false)
		self:configure_aquatic_mob ()
	end
	if self.amphibious then
		self:gwp_configure_amphibious_mob ()
		self:configure_amphibious_mob ()
	end
	if self.airborne then
		self:gwp_configure_airborne_mob ()
		self:configure_airborne_mob ()
	end
	-- Last mob to have attacked this mob within the past five
	-- seconds.
	self._recent_attacker = nil
	self._recent_attacker_age = 0

	-- If spawned in a proto-chunk, suspend the mob's AI until
	-- such time as the chunk where it resides is completely
	-- generated.
	local self_pos = self.object:get_pos ()
	self_pos.x = floor (self_pos.x + 0.5)
	self_pos.y = floor (self_pos.y + 0.5)
	self_pos.z = floor (self_pos.z + 0.5)
	if not mcl_mobs.is_position_completely_generated (self_pos) then
		self._in_proto_chunk = 0.20
	else
		self._in_proto_chunk = nil
	end
end

function mob_class:check_proto_chunk (self_pos, dtime)
	local t = self._in_proto_chunk
	if t ~= nil then
		t = t - dtime
		if t <= 0 then
			local nodepos = mcl_util.get_nodepos (self_pos)
			if mcl_mobs.is_position_completely_generated (nodepos) then
				t = nil
			else
				t = 0.20
			end
		end
		self._in_proto_chunk = t
		return t ~= nil
	else
		return false
	end
end

function mob_class:is_frightened ()
	return (mcl_burning.is_burning (self.object) or self.runaway_timer > 0)
end

function mob_class:ai_step (dtime)
	-- Number of seconds since mob was last punched.
	if self.runaway_timer > 0 then
		self.runaway_timer = self.runaway_timer - dtime
	end
	if self.follow_cooldown and self.follow_cooldown > 0 then
		self.follow_cooldown = self.follow_cooldown - dtime
	else
		self.follow_cooldown = nil
	end
	if self._recent_attacker then
		self._recent_attacker_age = self._recent_attacker_age + dtime
		if not is_valid (self._recent_attacker)
			or self._recent_attacker_age > 5 then
			self._recent_attacker = nil
			self._recent_attacker_age = 0
		end
	end
	if self._last_attacker then
		if not is_valid (self._last_attacker) then
			self._last_attacker = nil
		end
	end
	self:tick_breeding ()
	if self.can_wield_items then
		self:wielditem_step (dtime)
	end
end

function mob_class:should_runaway_from_mob (entity)
	return true
end

function mob_class:check_avoid (self_pos)
	local runaway_from = self.runaway_from
	if not runaway_from then
		return false
	end

	if self.avoiding then
		if self:navigation_finished () then
			self.avoiding = nil
		elseif not is_valid (self.avoiding) then
			self.avoiding = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
		else
			local mob = self:mob_controlling_movement ()
			local avoid_pos = self.avoiding:get_pos ()
			local distance = vector.distance (self_pos, avoid_pos)
			if distance < 7.0 then
				mob.gowp_velocity
					= mob.movement_speed * self.runaway_bonus_near
			else
				mob.gowp_velocity
					= mob.movement_speed * self.runaway_bonus_far
			end
		end
		return true
	else
		-- Search for nearby mobs to avoid.
		local target, max_distance, target_pos
		local range = self.runaway_view_range
		local runaway_from_players
			= table.indexof (runaway_from, "players") ~= -1
		local runaway_from_monsters
			= table.indexof (runaway_from, "monsters") ~= -1
		for object in core.objects_inside_radius (self_pos, range) do
			local entity = object:get_luaentity ()
			local eligible = false
			local view_range = range
			if entity
				and table.indexof (runaway_from, entity.name) ~= -1
				and self:should_runaway_from_mob (entity)
				and self:target_visible (self_pos, object) then
				eligible = true
			elseif runaway_from_monsters
				and entity
				and entity.type == "monster" then
				eligible = true
				if self._runaway_monster_view_range then
					view_range = self._runaway_monster_view_range
				end
			elseif object:is_player ()
				and runaway_from_players
				and not core.is_creative_enabled (object:get_player_name ())
				and self:target_visible (self_pos, object) then
				eligible = true
				if self._runaway_player_view_range then
					view_range = self._runaway_player_view_range
				end
			end
			if eligible then
				local pos = object:get_pos ()
				local distance = vector.distance (self_pos, pos)
				if distance <= view_range
					and (not max_distance or distance < max_distance) then
					target = object
					target_pos = pos
					max_distance = distance
				end
			end
		end
		if target then
			local pos = self:target_away_from (self_pos, target_pos)
			if pos and vector.distance (pos, target_pos) > max_distance then
				local bonus = self.runaway_bonus_near
				self:gopath (pos, bonus)
				self.avoiding = target
				return "avoiding"
			end
		end
	end
	return false
end

function mob_class:check_following (self_pos, dtime)
	if self.following then
		-- Can this mob continue to follow its target?
		local pos = self.following:get_pos ()
		local must_stop = false
		if not pos then
			self.following = nil
			self.follow_cooldown = 4
			self:halt_in_tracks ()
			self:set_animation ("stand")
		else
			local distance = vector.distance (self_pos, pos)
			if not self:follow_holding (self.following) then
				distance = nil
			end
			if not distance
				or distance > self.follow_distance
				or distance <= self.stop_distance then
				if not distance or distance > self.follow_distance then
					self.following = nil
					self.follow_cooldown = 4
				end
				self:halt_in_tracks ()
				self:cancel_navigation ()
				self:set_animation ("stand")
				must_stop = true
			end
		end
		if self.following and not must_stop then
			-- check_head_swivel is responsible for
			-- looking at the target.
			self:go_to_stupidly (pos, self.follow_bonus)
		end
		return true
	elseif self.follow and not self.follow_cooldown then
		for player in mcl_util.connected_players () do
			local distance = vector.distance (player:get_pos (), self_pos)
			if distance < self.follow_distance
				and distance > self.stop_distance and self:follow_holding (player) then
				self.following = player
				return "following"
			end
		end
	end
	return false
end

function mob_class:check_avoid_sunlight (pos)
	if self.avoiding_sunlight then
		-- Still seeking sunlight?
		if self:navigation_finished () then
			self.avoiding_sunlight = false
			local eye_height = self:get_eye_height ()
			local head_pos = vector.offset (pos, 0, eye_height, 0)
			self._direct_sunlight
				= core.get_natural_light (head_pos, 0.5)
			self:set_animation ("stand")
		end
		return true
	elseif mcl_util.is_daytime ()
		and self._direct_sunlight >= 15
		and mcl_burning.is_burning (self.object) then
		local tpos = self:target_in_shade (pos, 10, 3)

		if tpos then
			self:gopath (tpos, self.run_bonus)
			self.avoiding_sunlight = true
			return "avoiding_sunlight"
		end
	end
	return false
end

local SOLID_PACING_GROUPS = {
	"group:solid",
	"group:top_snow",
}
mcl_mobs.SOLID_PACING_GROUPS = SOLID_PACING_GROUPS

function mob_class:check_frightened (pos)
	if self.frightened then
		-- Still frightened?
		if self:navigation_finished () then
			self.frightened = false
			self:set_animation ("stand")
		end
		return true
	else
		if self:is_frightened () then
			-- If this mob is burning, search for water.
			local tpos

			if mcl_burning.is_burning (self.object) then
				tpos = self:pacing_target (pos, 5, 4, {"group:water"})
			end
			if not tpos then
				tpos = self:pacing_target (pos, 5, 4, SOLID_PACING_GROUPS)
			end
			if tpos then
				self:gopath (tpos, self.run_bonus)
				self.frightened = true
				return "frightened"
			end
		end
	end

	return false
end

function mob_class:check_pace (pos)
	if self.pacing then
		-- Still pacing?
		if self:navigation_finished () then
			self._pace_asap = nil
			self.pacing = false
			self:set_animation ("stand")
		end
		return true
	else
		local pace_asap = self._pace_asap
		-- Should pace?
		if pace_asap
			or (self.ai_idle_time > self.pace_interval
				and (self.pace_chance == 1
					or math.random (self.pace_chance) == 1)) then
			-- Minecraft mobs pace to random positions
			-- within a 20 block distance lengthwise and
			-- 14 blocks vertically.
			local groups = SOLID_PACING_GROUPS
			if self.swims_in and (self.swims or self.amphibious) then
				-- If this is an aquatic mob, search
				-- for nodes in which it is capable of
				-- swimming.
				groups = self.swims_in
			end
			local width, height = self.pace_width, self.pace_height
			local target = self:pacing_target (pos, width, height, groups)
			if target and self:gopath (target, self.pace_bonus) then
				self.pacing = true
				return "pacing"
			end
		end
		return false
	end
end

function mob_class:replace_activity (activity_name, uninterruptible)
	if self._active_activity
		and self._active_activity ~= activity_name then
		self[self._active_activity] = nil
	end
	self._active_activity = activity_name
	self._can_interrupt_activity = not uninterruptible
end

function mcl_mobs.scale_chance (frequency, dtime)
	return math.max (2, math.round (frequency * (0.05 / dtime)))
end

local function run_ai_1 (self, self_pos, dtime, moveresult)
	local active, uninterruptible
	for _, fn in ipairs (self.ai_functions) do
		active, uninterruptible = fn (self, self_pos, dtime, moveresult)

		if active then
			if active ~= true then
				local current = self._active_activity
				-- Cancel the current activity.
				if current and current ~= active then
					self[current] = nil
				end
				self._active_activity = active
				self._can_interrupt_activity
					= not uninterruptible
				self._active_activity_function = fn
			end
			break
		end
	end
	return active
end

function mob_class:run_ai (dtime, moveresult)
	local pos = self.object:get_pos ()

	if self.dead then
		self:halt_in_tracks ()
		return
	end

	local active = nil

	-- Don't run AI if controlled as a jockey.
	if not self._jockey_rider or self._jockey_rider_non_dominant then
		-- Check all inactive AI functions if the current
		-- activity can be interrupted.
		if self._can_interrupt_activity
			or not self._active_activity then
			active = run_ai_1 (self, pos, dtime, moveresult)
		else
			-- Or tick the active activity if not.
			active = self._active_activity_function (self, pos, dtime, moveresult)
		end
	end

	if not active then
		if not self._jockey_rider then
			local mob = self:mob_controlling_movement ()
			mob:set_animation ("stand")
			self:set_animation ("stand")
		end
		if self._active_activity then
			self[self._active_activity] = nil
			self._active_activity = nil
		end
	end

	if active and not self._is_idle_activity[self._active_activity] then
		self.ai_idle_time = 0
	elseif self.ai_idle_time < IDLE_TIME_MAX then
		self.ai_idle_time = self.ai_idle_time + dtime

		if not self._jockey_rider and not active then
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end
	end
end

------------------------------------------------------------------------
-- Aquatic mob behavior.
------------------------------------------------------------------------

local function aquatic_pacing_target (self, pos, width, height, groups)
	local aa = vector.new (pos.x - width, pos.y - height, pos.z - width)
	local bb = vector.new (pos.x + width, pos.y + height, pos.z + width)
	local nodes = core.find_nodes_in_area (aa, bb, groups)

	if self._restrict_center and #nodes >= 1 then
		-- Make ten attempts to select a node within the
		-- restriction.
		for i = 1, 10 do
			local node = nodes[math.random (#nodes)]
			if self:node_in_restriction (node) then
				return node
			end
		end
		return nil
	end

	return #nodes >= 1 and nodes[math.random (#nodes)]
end

mob_class.aquatic_pacing_target = aquatic_pacing_target

function mob_class:can_reset_pitch ()
	return true
end

function mob_class:aquatic_movement_step (dtime, moveresult)
	if self.movement_goal ~= "go_pos"
		and self.idle_gravity_in_liquids then
		self._acc_no_gravity = false
		if self:can_reset_pitch () then
			self:set_pitch (0)
		end
	end
	if not self.idle_gravity_in_liquids and self._immersion_depth then
		self._acc_no_gravity
			= self._immersion_depth >= self.head_eye_height
	end
	if self.flops and self._immersion_depth and self._immersion_depth <= 0 then
		local touching_ground
		touching_ground = moveresult.touching_ground
			or moveresult.standing_on_object
		if touching_ground then
			local flop_velocity = {
				x = (math.random () - 0.5) * 2,
				y = 8.0,
				z = (math.random () - 0.5) * 2,
			}
			self.object:add_velocity (flop_velocity)
			self:mob_sound ("flop")
		end
	end
	self._acc_y_fixed = nil
	mob_class.movement_step (self, dtime, moveresult)
end

function mob_class:fish_do_go_pos (dtime, moveresult)
	local target = self.movement_target or vector.zero ()
	local vel = self.movement_velocity
	local self_pos = self.object:get_pos ()
	local dx, dy, dz = target.x - self_pos.x,
		target.y - self_pos.y,
		target.z - self_pos.z
	local current_speed = self._acc_movement_speed or 0
	current_speed = (vel - current_speed) * 0.125 + current_speed
	local move_speed = 0.4

	self._acc_movement_speed = current_speed
	self.acc_speed = move_speed
	self.acc_dir.z = current_speed / 20
	if dy ~= 0 then
		local dxyz = math.sqrt (dx * dx + dy * dy + dz * dz)
		local t2 = current_speed * (dy / dxyz) * 0.1
		self._acc_y_fixed = t2
	end
	local dir = math.atan2 (dz, dx) - math.pi / 2
	local rotation = clip_rotation (self:get_yaw (), dir,
					(math.pi / 2) * dtime / 0.05)
	self:set_yaw (rotation)
end

function mob_class.school_init_group (list)
	-- Designate one of the school's fish as its leader.
	local leader = list[math.random (#list)]
	local entity = leader:get_luaentity ()

	entity._school = {}
	entity._desired_school_size = #list - 1
	for _, item in pairs (list) do
		if item ~= leader then
			local mob = item:get_luaentity ()
			table.insert (entity._school, item)
			mob._leader = leader
			mob:replace_activity ("_leader")
		end
	end
end

local function find_school_leader (list, species, cluster)
	for _, mob in pairs (list) do
		local entity = mob:get_luaentity ()
		if entity and entity.name == species
			and entity._school
			and #entity._school > 1
			and #entity._school < cluster then
			return entity
		end
	end
end

function mob_class:check_schooling (self_pos, list)
	if self._leader then
		if not is_valid (self._leader) then
			self._leader = nil
			return false
		end
		local leader_pos = self._leader:get_pos ()
		if vector.distance (leader_pos, self_pos) > 11.0 then
			local luaentity = self._leader:get_luaentity ()
			local index = table.indexof (luaentity._school, self.object)
			assert (index >= 1)
			table.remove (luaentity._school, index)
			self._leader = nil
			return false
		end

		if self:check_timer ("school_pathfind", 0.5) then
			self:gopath (leader_pos, nil, nil, 3)
		end
		return true
	elseif self._school and #self._school > 0 then
		-- This fish already leads a school.  Remove invalid
		-- entries from its list of members.
		local cleaned = {}
		for _, follower in pairs (self._school) do
			if is_valid (follower) then
				table.insert (cleaned, follower)
			end
		end
		self._school = cleaned
		return false
	elseif self:check_timer ("form_school", (200 + math.random (20)) / 40) then
		local nearby = core.get_objects_inside_radius (self_pos, 8)
		local cluster = self._school_size or 4
		local leader = find_school_leader (nearby, self.name, cluster) or self
		leader._school = leader._school or {}

		-- Assign nearby unassigned mobs other than the
		-- selected leader to its school.
		for _, mob in pairs (nearby) do
			local entity = mob:get_luaentity ()
			if entity
				and entity.object ~= leader.object
				and entity.name == self.name
				and (not entity._school or #entity._school == 0)
				and (not entity._leader) then
				entity._leader = leader.object
				entity:replace_activity ("_leader")
				table.insert (leader._school, mob)
			end
		end

		-- Was this mob assigned to a leader, or has it gained
		-- a school?
		if self._school and #self._school > 0 then
			return false
		end
		if self._leader then
			return "_leader"
		end
		return false
	end
end

function mob_class:configure_aquatic_mob ()
	self.pacing_target = aquatic_pacing_target
	self.motion_step = self.aquatic_step
	self.movement_step = self.aquatic_movement_step
	self._acc_no_gravity = false
end

------------------------------------------------------------------------
-- Amphibious mobs.  These are very akin to landed mobs in their
-- pathfinding mechanics, but not in their movement.
------------------------------------------------------------------------

function mob_class:pitchswim_do_go_pos (dtime, moveresult)
	local target = self.movement_target
	local pos = self.object:get_pos ()
	local dx, dy, dz = target.x - pos.x,
		target.y - pos.y,
		target.z - pos.z
	local dir = math.atan2 (dz, dx) - math.pi / 2
	local standin = core.registered_nodes[self.standing_in]
	local yaw = self:get_yaw ()
	local f = dtime / 0.05
	local target_yaw = clip_rotation (yaw, dir, self.max_yaw_movement * f)
	self:set_yaw (target_yaw)

	-- Orient the mob vertically.
	local speed = self.movement_velocity
	if standin.groups.water and standin.groups.water > 0 then
		local xz_mag = math.sqrt (dx * dx + dz * dz)
		local des_pitch
		if xz_mag > 1.0e-5 or xz_mag < -1.0e-5 then
			local swim_max_pitch = self.swim_max_pitch
			local old_pitch = self:get_pitch ()
			des_pitch = -math.atan2 (dy, xz_mag)

			if des_pitch > swim_max_pitch then
				des_pitch = self.swim_max_pitch
			elseif des_pitch < -swim_max_pitch then
				des_pitch = -self.swim_max_pitch
			end

			local target
			-- ~50 degrees.
			target = clip_rotation (old_pitch, des_pitch, 0.8727 * f)
			self:set_pitch (target)
			des_pitch = target
		else
			-- Not moving horizontally.
			des_pitch = self:get_pitch ()
		end
		self.acc_dir.z = math.cos (des_pitch) * speed / 20
		self.acc_dir.y = -math.sin (des_pitch) * speed / 20
		self.acc_speed = speed * self.swim_speed_factor
		self._acc_no_gravity = true
	else
		-- Fish cannot change their pitch outside a body of
		-- water.
		self.acc_dir.y = 0
		if self.fixed_grounded_speed then
			speed = self.fixed_grounded_speed
		end
		self:set_velocity (speed * self.grounded_speed_factor)
		self._acc_no_gravity = false
		self:set_yaw (target_yaw)
		if self:can_reset_pitch () then
			self:set_pitch (0)
		end
	end
end

local function amphibious_pacing_target (self, pos, width, height, groups)
	local target_aquatic
		= aquatic_pacing_target (self, pos, width, height, groups)
	if target_aquatic then
		return target_aquatic
	end
	-- Otherwise attempt to move onto land, if possible.
	local target
		= mob_class.pacing_target (self, pos, width, height, SOLID_PACING_GROUPS)
	return target
end

mob_class.amphibious_pacing_target = amphibious_pacing_target

function mob_class:configure_amphibious_mob ()
	self.pacing_target = amphibious_pacing_target
	self.motion_step = self.aquatic_step
	self.movement_step = self.aquatic_movement_step
	self._acc_no_gravity = false
end

------------------------------------------------------------------------
-- Flying mob behavior.  This only applies to mobs that are truly
-- adapted to flight in all respects, which excludes bats, whose
-- flight is implemented in their AI loop, or ghasts, which do not
-- pathfind.
------------------------------------------------------------------------

function mob_class:airborne_do_go_pos (dtime, moveresult)
	local target = self.movement_target or vector.zero ()
	local vel = self.movement_velocity
	local self_pos = self.object:get_pos ()
	local dx, dy, dz = target.x - self_pos.x,
		target.y - self_pos.y,
		target.z - self_pos.z
	local touching_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	-- Replace movement_speed with airborne_speed if airborne.
	if not touching_ground then
		vel = vel / self.movement_speed * self.airborne_speed
		self:set_animation ("fly")
	else
		self:set_animation ("run")
	end

	local yaw = math.atan2 (dz, dx) - math.pi / 2
	local old_yaw = self:get_yaw ()
	local clipped = clip_rotation (old_yaw, yaw, (math.pi / 2) * dtime / 0.05)

	self:set_yaw (clipped)
	self:set_velocity (vel)

	local xz_magnitude = math.sqrt (dx * dx + dz * dz)
	if math.abs (dy) > 1.0e-5 or math.abs (xz_magnitude) > 1.0e-5 then
		-- Vertical acceleration is not adjusted by the pitch
		-- in order to simulate real world flight.
		self.acc_dir.y = dy > 0.0 and vel / 20 or -vel / 20
	end
	self._acc_no_gravity = true
end

local function airborne_movement_step (self, dtime, moveresult)
	if self.dead then
		return
	end
	if self.movement_goal == nil then
		-- Arrest movement.
		self.acc_dir.z = 0
		self.acc_dir.y = 0
		self.acc_dir.x = 0
		self.acc_speed = 0
		if not self._hovers then
			self._acc_no_gravity = false
		end
		return
	elseif self.movement_goal == "go_pos" then
		self:do_go_pos (dtime, moveresult)
	end
end

local function airborne_pacing_target (self, pos, width, height, groups)
	return self:airborne_pacing_target (pos, width, height, groups)
end

function mob_class:airborne_pacing_target (pos, width, height, groups)
	-- First, generate a position within 90 degrees of this mob's
	-- current direction of sight.
	local dir = self:get_yaw ()
	dir = { x = -math.sin (dir), z = math.cos (dir), }
	local node_pos = vector.copy (pos)
	node_pos.x = math.floor (node_pos.x + 0.5)
	node_pos.y = math.floor (node_pos.y + 0.5)
	node_pos.z = math.floor (node_pos.z + 0.5)
	for i = 1, 10 do
		local node = self:random_node_direction (width, height, dir, math.pi / 20)
		if node then
			local target = node_pos + node
			local class = self:gwp_classify_for_movement (target)

			-- Is this node walkable?
			if class == "WALKABLE" then
				-- Move an arbitrary number of blocks
				-- into the air above this node.
				local n = math.random (3)
				repeat
					target.y = target.y + 1
					if self:gwp_classify_for_movement (target) ~= "OPEN" then
						target.y = target.y - 1
						break
					end
					n = n - 1
				until n < 1
				return target
			end
		end
	end
end

function mob_class:configure_airborne_mob ()
	self.movement_step = airborne_movement_step
	self.do_go_pos = mob_class.airborne_do_go_pos
	self.pacing_target = airborne_pacing_target
end

------------------------------------------------------------------------
-- Mob restrictions.
------------------------------------------------------------------------

function mob_class:restrict_to (node, radius)
	self._restriction_center = node
	self._restriction_size = radius
end

function mob_class:node_in_restriction (node)
	if self._restriction_center then
		return vector.distance (self._restriction_center, node)
			< self._restriction_size
	end
	return true
end

function mob_class:return_to_restriction (self_pos, dtime)
	if self._returning_to_restriction then
		if self:navigation_finished () then
			self._returning_to_restriction = false
			return false
		end
		return true
	end
	if not self._restriction_center
		or self:node_in_restriction (self_pos) then
		return false
	end
	for i = 1, 10 do
		local restrict = self._restriction_center
		local restriction_dir = vector.direction (self_pos, restrict)
		local node = self:target_in_direction (self_pos, 16, 7,
						       restriction_dir,
						       math.pi / 2)
		if node then
			if self:node_in_restriction (node) then
				self:gopath (node, self.restriction_bonus)
				self._returning_to_restriction = true
				return "_returning_to_restriction"
			end
		end
	end
	return false
end

------------------------------------------------------------------------
-- Mob attribute randomization.
------------------------------------------------------------------------

mob_class._persistent_physics_factors = {
	["mcl_mobs:standard_view_range_bonus"] = true,
	["mcl_mobs:standard_tracking_distance_bonus"] = true,
}

function mob_class:randomize_attributes ()
	-- This was once 0.05 but has been increased to ~1/9 in MC
	-- 1.20.
	local d = mcl_util.dist_triangular (0.0, 0.11485)
	self:add_physics_factor ("view_range", "mcl_mobs:standard_view_range_bonus",
		d, "add_multiplied_base")
	self:add_physics_factor ("tracking_distance", "mcl_mobs:standard_tracking_distance_bonus",
		d, "add_multiplied_base")
end

------------------------------------------------------------------------
-- Utility functions.
------------------------------------------------------------------------

-- Return position of the node containing this mob's base, providing
-- for minor deviations below the surface of any colliding supporting
-- node that may have been produced by imprecisions in collision
-- detection.

function mob_class:get_nodepos ()
	local pos = self.object:get_pos ()
	if pos then
		pos.x = floor (pos.x + 0.5)
		pos.y = floor (pos.y + 0.50001)
		pos.z = floor (pos.z + 0.5)
		return pos
	end
	return nil
end
