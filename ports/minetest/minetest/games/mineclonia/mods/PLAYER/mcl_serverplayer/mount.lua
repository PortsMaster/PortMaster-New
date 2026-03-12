------------------------------------------------------------------------
-- Mob & vehicle mounting.
------------------------------------------------------------------------
------------------------------------------------------------------------
-- That which follows is an abridged overview of the vehicle mounting
-- protocol.  The server initiates a session by issuing
-- CLIENTBOUND_VEHICLE_HANDOFF with the object ID of the mounted mob,
-- which is recorded by the client.  The client responds with a
-- SERVERBOUND_REFUSE_VEHICLE or SERVERBOUND_ACKNOWLEDGE_VEHICLE
-- message either to reject the vehicle (in which event it is attached
-- server-side) or to accept the vehicle, whereupon the server
-- attaches the client to the vehicle and overrides its pose.  At this
-- point the client enjoys control over the vehicle's movement.
--
-- Once a vehicle is acknowledged and attached, the client begins to
-- deliver SERVERBOUND_MOVE_VEHICLE messages till it is detached.  The
-- server may periodically correct the client's movement physics by
-- calling CLIENTBOUND_VEHICLE_POSITION, and, lest objects IDs are
-- reused so that the client inadvertently assumes control over an
-- inappropriate object, CLIENTBOUND_RESCIND_VEHICLE is delivered when
-- a vehicle is no longer mountable.
------------------------------------------------------------------------

function mcl_serverplayer.get_id_of_object (object)
	for id, entity in pairs (core.luaentities) do
		if entity.object == object then
			return id
		end
	end
	return nil
end

function mcl_serverplayer.begin_mount (player, vehicle, vehicletype, attach_params)
	if not mcl_serverplayer.is_csm_capable (player)
		or not vehicle:is_valid () then
		return false
	end
	local id = mcl_serverplayer.get_id_of_object (vehicle)
	local state = mcl_serverplayer.client_states[player]

	-- Don't permit a client to request multiple mounts at once.
	if state.pending_vehicle then
		return false
	end

	local luaentity = vehicle:get_luaentity ()

	assert (id) -- A valid ObjectRef must have been assigned a
		    -- valid ID.
	if luaentity._pending_rider then
		-- Deny the previous rider this mount.
		local rider = luaentity._pending_rider
		if rider:is_valid () then
			local state1 = mcl_serverplayer.client_states[rider]
			assert (state1)
			state1.pending_vehicle = nil
			mcl_serverplayer.send_rescind_vehicle (rider, id)
		end
	end

	-- Relinquish any previous mount.
	if state.vehicle then
		if state.vehicle:is_valid () then
			local id = state.vehicle_id
			local entity = state.vehicle:get_luaentity ()
			mcl_serverplayer.send_rescind_vehicle (player, id)
			entity:detach_client_driver (player)
		end
		state.vehicle = nil
		state.vehicle_id = nil
		state.vehicle_pos = nil
		state.vehicle_vel = nil
		state.vehicle_dtime = nil
		state.vehicle_tsc = nil
	end

	mcl_serverplayer.send_vehicle_handoff (player, vehicletype, id)
	luaentity._pending_rider = player
	state.pending_vehicle = vehicle
	state.attach_params = attach_params
	return true
end

function mcl_serverplayer.handle_refuse_vehicle (player, state, objid)
	local entity = core.luaentities[objid]
	if not entity or entity.object ~= state.pending_vehicle then
		-- Outdated acknowledgment.
		return
	end
	entity._pending_rider = nil
	entity:fallback_attach (player, state)
	state.pending_vehicle = nil
	state.attach_params = nil
	state.vehicle = nil
	state.vehicle_id = nil
	state.vehicle_pos = nil
	state.vehicle_vel = nil
	state.vehicle_dtime = nil
	state.vehicle_tsc = nil
end

function mcl_serverplayer.handle_acknowledge_vehicle (player, state, objid)
	local entity = core.luaentities[objid]
	if not entity or entity.object ~= state.pending_vehicle then
		-- Outdated acknowledgment.
		return
	end
	entity._pending_rider = nil
	player:set_attach (entity.object, state.attach_params.bone,
			state.attach_params.position,
			state.attach_params.rotation)
	state.vehicle = entity.object
	state.vehicle_id = objid
	state.vehicle_pos = entity.object:get_pos ()
	state.vehicle_vel = vector.zero ()
	state.vehicle_dtime = 0
	state.vehicle_tsc = nil
	state.pending_vehicle = nil
	state.attach_params = nil
	entity:complete_attachment (player, state)
end

local COS_5_DEG = math.cos (math.rad (5))
local PLACEHOLDER_VECTOR = vector.new (1.0e+6, 1.0e+6, 1.0e+6)

function mcl_serverplayer.handle_move_vehicle (player, state, objid, tsc, pos, vel)
	if not state.vehicle
		or core.object_refs[objid] ~= state.vehicle
	-- ???
		or not core.object_refs[objid]:is_valid () then
		return
	end

	local entity = state.vehicle:get_luaentity ()
	local max_delta_movement = entity:max_delta_movement ()
	if vector.length (vel) > max_delta_movement then
		local dir = vector.normalize (vel)
		local vel_1 = vector.multiply (dir, max_delta_movement)
		vel.x = vel_1.x
		vel.z = vel_1.z
	end

	-- If a course correction is required, send it to the client.
	local corrected_pos, corrected_vel
		= mcl_serverplayer.maybe_correct_course (player, state.vehicle,
							 nil, 0.0, pos, vel)

	-- Enforce course corrections after they are produced.
	if corrected_pos
		and not vector.equals (corrected_pos, PLACEHOLDER_VECTOR) then
		pos = corrected_pos
	end
	if corrected_vel
		and not vector.equals (corrected_vel, PLACEHOLDER_VECTOR) then
		vel = corrected_vel
	end

	-- Predict movement ahead of this vehicle.  TSC is a
	-- sub-millisecond counter specifying the time at which this
	-- message was generated.  If the server is already aware of
	-- the time of the first movement and consequently has a frame
	-- of reference synchronized with the client, the server may
	-- rewind to the time of the previous movement, apply the new
	-- velocity, and simulate the intervening period according to
	-- the same.

	if not state.vehicle_tsc then
		state.vehicle_tsc = tsc / 5000
		state.vehicle:set_pos (pos)
		state.vehicle:set_velocity (vel)
		state.vehicle_pos = pos
		state.vehicle_vel = vel
		state.vehicle_dtime = 0.0
	else
		local diff = (tsc / 5000) - state.vehicle_tsc
		if diff > 0 then
			-- Resynchronize with the client.
			-- This is not supposed to take place.
			state.vehicle_tsc = tsc / 5000
		end

		-- if false then
		-- 	-- Simulating motion on the server would be
		-- 	-- feasible with a collisionMove primitive in
		-- 	-- the server modding API, but since that is
		-- 	-- not forthcoming, this code is disabled.
		-- 	state.vehicle_vel = vel
		-- 	state.vehicle_pos = pos

		-- 	-- Apply intervening movement.
		-- 	if diff < 0 then
		-- 		local mag = vector.multiply (vel, -diff)
		-- 		local new = vector.add (pos, mag)
		-- 		state.vehicle_pos = new
		-- 	end
		-- 	state.vehicle:set_pos (state.vehicle_pos)
		-- 	state.vehicle:set_velocity (vel)
		-- 	state.vehicle_dtime = 0.0
		-- else
			-- Don't adjust position if the new position
			-- sits between its previously recorded
			-- position and the current.
			assert (state.vehicle_pos)
			local update = false
			local self_pos = state.vehicle:get_pos ()

			if diff > 0 then
				update = true
			else
				if vector.distance (pos, self_pos)
					>= vector.length (vel) * -diff then
					update = true
				else
					local v1 = vector.subtract (pos, state.vehicle_pos)
					local v2 = vector.subtract (self_pos, state.vehicle_pos)
					local dot = vector.dot (vector.normalize (v1),
								vector.normalize (v2))
					if dot > COS_5_DEG then
						local prod = vector.dot (v1, v2)
						if prod >= 1 or prod < 0 then
							update = true
						end
					else
						update = true
					end
				end
			end
			if update then
				state.vehicle:set_pos (pos)
				state.vehicle_pos = pos
			else
				state.vehicle_pos = self_pos
			end
			state.vehicle_vel = vel
			state.vehicle:set_velocity (vel)
			state.vehicle_dtime = 0.0
		-- end
	end
end

function mcl_serverplayer.handle_turn_vehicle (player, state, objid, tsc, yaw)
	if not state.vehicle
		or core.object_refs[objid] ~= state.vehicle then
		return
	end

	local entity = state.vehicle:get_luaentity ()
	if entity then
		entity:set_yaw (yaw)
	end
end

function mcl_serverplayer.handle_configure_vehicle (player, state, config)
	if not config.id or type (config.id) ~= "number" then
		error ("Invalid vehicle configuration")
	end
	if not state.vehicle
		or core.object_refs[config.id] ~= state.vehicle then
		return
	end
	if config.touching_ground ~= nil then
		local entity = state.vehicle:get_luaentity ()
		entity:set_touching_ground (config.touching_ground)
	end
end

function mcl_serverplayer.validate_mounting (state, player, dtime)
	if state.pending_vehicle
		and not state.pending_vehicle:is_valid () then
		state.pending_vehicle = nil
		core.log ("warning", "Pending vehicle disappeared")
	end
	if state.vehicle and not state.vehicle:is_valid ()
	-- Revoke server-side vehicle ownership once it is detached.
		or player:get_attach () ~= state.vehicle then
		state.vehicle = nil
		state.vehicle_id = nil
		state.vehicle_tsc = nil
		state.vehicle_pos = nil
		state.vehicle_vel = nil
		state.attach_params = nil
	elseif state.vehicle_tsc then
		local tsc = state.vehicle_tsc + dtime
		state.vehicle_tsc = tsc
	end
end

function mcl_serverplayer.update_vehicle (driver, caps, pos, velocity)
	local state = mcl_serverplayer.client_states[driver]
	if state and state.vehicle then
		local id = state.vehicle_id
		if pos and velocity then
			mcl_serverplayer.send_vehicle_position (driver, id, pos, velocity)
		end
		if caps then
			mcl_serverplayer.send_vehicle_capabilities (driver, id, caps)
		end
	end
end

local MAX_VELOCITY_TOLERANCE = 0.5
local MAX_POS_TOLERANCE = 1.0

local function gravity_only_collisions (moveresult)
	for _, item in pairs (moveresult.collisions) do
		if item.axis ~= "y" or item.old_velocity.y >= 0.0 then
			return false
		end
	end
	return true
end

function mcl_serverplayer.maybe_correct_course (driver, object, moveresult, dtime, pos, vel)
	local state = mcl_serverplayer.client_states[driver]
	if not state or state.vehicle ~= object
		or not state.vehicle_vel or not state.vehicle_pos
		or not object:is_valid () then
		return
	end

	-- Decide whether to send a position correction.  N.B. that
	-- this function is called to reconcile both client movement
	-- with the server and server movement with the client.
	local v_orig = state.vehicle_vel
	local t = state.vehicle_dtime + dtime
	local movement = vector.multiply (v_orig, t)
	local predict_pos = vector.add (movement, state.vehicle_pos)
	local dx = predict_pos.x - pos.x
	local dy = (predict_pos.y - pos.y) * 0.25
	local dz = predict_pos.z - pos.z
	local d = math.sqrt (dx * dx + dy * dy + dz * dz)
	local correct_vel = false
	local correct_pos = false
	local v_new = object:get_velocity ()
	local v_mag = math.sqrt (v_orig.x * v_orig.x + v_orig.z * v_orig.z)
	local tolerance = math.max (1.0, v_mag / 2.5)
	state.vehicle_dtime = t
	if d > (MAX_POS_TOLERANCE * tolerance) then
		correct_pos = true
		correct_vel = true
	else
		-- Decide whether to send a velocity correction.  The criteria
		-- for such a correction are that the velocity must not have
		-- been affected by a horizontal or vertical collision, and
		-- must have changed more than MAX_VELOCITY_TOLERANCE.

		if not vector.equals (v_new, v_orig) then
			local dx = v_new.x - v_orig.x
			local dz = v_new.z - v_orig.z
			local diff = math.sqrt (dx * dx + dz * dz)
			if diff >= MAX_VELOCITY_TOLERANCE
				or (v_new.y > 0 and (v_new.y - v_orig.y) > 0) then
				if not moveresult then
					local entity = object:get_luaentity ()
					moveresult = entity._moveresult
				end
				correct_vel = not moveresult
					or gravity_only_collisions (moveresult)
			end
		end
	end

	if correct_pos or correct_vel then
		local pos = correct_pos and state.vehicle_pos
			or PLACEHOLDER_VECTOR
		local vel = correct_vel and v_new
			or PLACEHOLDER_VECTOR
		local id = state.vehicle_id
		if correct_pos then
			state.vehicle:set_pos (pos)
		end
		if correct_vel then
			state.vehicle:set_velocity (vel)
		end
		mcl_serverplayer.send_vehicle_position (driver, id, pos, vel)
		return pos, vel
	end
	return nil, nil
end
