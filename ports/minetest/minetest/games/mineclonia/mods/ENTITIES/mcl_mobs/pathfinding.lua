local mob_class = mcl_mobs.mob_class

local PATHFINDING_FAIL_THRESHOLD = 100 -- no. of ticks to fail before giving up. 20p/s. 5s helps them get through door
local PATHFINDING_FAIL_WAIT = 10 -- how long to wait before trying to path again
local PATHING_START_DELAY = 4 -- When doing non-prioritised pathing, how long to wait until last mob pathed

local PATHFINDING_SEARCH_DISTANCE = 64 -- How big the square is that pathfinding will look

local PATHFINDING = "gowp"

local one_down = vector.new(0,-1,0)
local one_up = vector.new(0,1,0)

local plane_adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_mobs_pathfinding",false)

local LOG_MODULE = "[Mobs Pathfinding]"
local function mcl_log (message)
	if LOGGING_ON and message then
		minetest.log(LOG_MODULE .. " " .. message)
	end
end

function output_table (wp)
	if not wp then return end
	mcl_log("wp items: ".. tostring(#wp))
	for a,b in pairs(wp) do
		mcl_log(a.. ": ".. tostring(b))
	end
end

function append_paths (wp1, wp2)
	--mcl_log("Start append")
	if not wp1 or not wp2 then
		mcl_log("Cannot append wp's")
		return
	end
	output_table(wp1)
	output_table(wp2)
	for _,a in pairs (wp2) do
		table.insert(wp1, a)
	end
	--mcl_log("End append")
end

local function output_enriched (wp_out)
	mcl_log("Output enriched path")
	local i = 0
	for _,outy in pairs (wp_out) do
		i = i + 1
		mcl_log("Pos ".. i ..":" .. minetest.pos_to_string(outy["pos"]))

		local action =  outy["action"]
		if action then
			--mcl_log("Pos ".. i ..":" .. minetest.pos_to_string(outy["pos"]))
			mcl_log("type: " .. action["type"])
			mcl_log("action: " .. action["action"])
			mcl_log("target: " .. minetest.pos_to_string(action["target"]))
		end
		--mcl_log("failed attempts: " .. outy["failed_attempts"])
	end
end

-- This function will take a list of paths, and enrich it with:
-- a var for failed attempts
-- an action, such as to open or close a door where we know that pos requires that action
local function generate_enriched_path(wp_in, door_open_pos, door_close_pos, cur_door_pos)
	local wp_out = {}

	-- TODO  Just pass in door position and the index before is open, the index after is close

	for i, cur_pos in pairs(wp_in) do
		local action = nil

		local cur_pos_to_add
		if door_open_pos and vector.equals (cur_pos, door_open_pos) then
			mcl_log ("Door open match")
			action = {type = "door", action = "open", target = cur_door_pos}
			cur_pos_to_add = vector.add(cur_pos, one_down)
		elseif door_close_pos and vector.equals(cur_pos, door_close_pos) then
			mcl_log ("Door close match")
			action = {type = "door", action = "close", target = cur_door_pos}
			cur_pos_to_add = vector.add(cur_pos, one_down)
		elseif cur_door_pos and vector.equals(cur_pos, cur_door_pos) then
			mcl_log("Current door pos")
			action = {type = "door", action = "open", target = cur_door_pos}
			cur_pos_to_add = vector.add(cur_pos, one_down)
		else
			cur_pos_to_add = cur_pos
			--mcl_log ("Pos doesn't match")
		end

		wp_out[i] = {}
		wp_out[i]["pos"] = cur_pos_to_add
		wp_out[i]["failed_attempts"] = 0
		wp_out[i]["action"] = action

		--wp_out[i] = {"pos" = cur_pos, "failed_attempts" = 0, "action" = action}
		--output_pos(cur_pos, i)
	end
	output_enriched(wp_out)
	return wp_out
end

local last_pathing_time = os.time()

function mob_class:ready_to_path(prioritised)
	mcl_log("Check ready to path")
	-- Ensure mobs stuck in the same place don't all retrigger at the same time
	if self._pf_last_failed and (os.time() - self._pf_last_failed) < (PATHFINDING_FAIL_WAIT + math.random(1, PATHFINDING_FAIL_WAIT)) then
		mcl_log("Not ready to path as last fail is less than threshold: " .. (os.time() - self._pf_last_failed))
		return false
	else
		local time_since_path_start = os.time() - last_pathing_time
		mcl_log("time_since_path_start: " .. tostring(time_since_path_start))
		if prioritised or (time_since_path_start) > PATHING_START_DELAY then
			mcl_log("We are ready to pathfind, no previous fail or we are past threshold")
			return true
		end
	end
end

-- This function is used to see if we can path. We could use to check a route, rather than making people move.
local function calculate_path_through_door (p, cur_door_pos, t)
	if t then
		mcl_log("Plot route through door from pos: " .. minetest.pos_to_string(p) .. ", to target: " .. minetest.pos_to_string(t))
	else
		mcl_log("Plot route through door from pos: " .. minetest.pos_to_string(p))
	end

	local enriched_path
	local wp, prospective_wp

	local pos_closest_to_door
	local other_side_of_door

	if cur_door_pos then
		mcl_log("Found a door near: " .. minetest.pos_to_string(cur_door_pos))

		for _,v in pairs(plane_adjacents) do
			pos_closest_to_door = vector.add(cur_door_pos,v)
			other_side_of_door = vector.add(cur_door_pos,-v)

			local n = minetest.get_node(pos_closest_to_door)

			if n.name == "air" then
				mcl_log("We have air space next to door at: " .. minetest.pos_to_string(pos_closest_to_door))

				prospective_wp = minetest.find_path(p, pos_closest_to_door, PATHFINDING_SEARCH_DISTANCE, 1, 4)

				if prospective_wp then
					mcl_log("Found a path to next to door".. minetest.pos_to_string(pos_closest_to_door))
					mcl_log("Opposite is: ".. minetest.pos_to_string(other_side_of_door))

					table.insert(prospective_wp, cur_door_pos)

					if t then
						mcl_log("We have t, lets go from door to target")
						local wp_otherside_door_to_target = minetest.find_path(other_side_of_door, t, PATHFINDING_SEARCH_DISTANCE, 1, 4)

						if wp_otherside_door_to_target and #wp_otherside_door_to_target > 0 then
							append_paths (prospective_wp, wp_otherside_door_to_target)

							wp = prospective_wp
							mcl_log("We have a path from outside door to target")
						else
							mcl_log("We cannot path from outside door to target")
						end
					else
						mcl_log("No t, just add other side of door")
						table.insert(prospective_wp, other_side_of_door)
						wp = prospective_wp
					end

					if wp then
						enriched_path = generate_enriched_path(wp, pos_closest_to_door, other_side_of_door, cur_door_pos)
						break
					end
				else
					mcl_log("Cannot path to this air block next to door.")
				end
			end
		end
	else
		mcl_log("No door found")
	end

	if wp and not enriched_path then
		mcl_log("Wp but not enriched")
		enriched_path = generate_enriched_path(wp)
	end
	return enriched_path
end



function mob_class:gopath(target, callback_arrived, prioritised)
	if self.state == PATHFINDING then mcl_log("Already pathfinding, don't set another until done.") return end
	if not self:ready_to_path(prioritised) then return end

	last_pathing_time = os.time()

	self.order = nil

	local p = self.object:get_pos()
	local t = vector.offset(target,0,1,0)

	--Check direct route
	local wp = minetest.find_path(p, t, PATHFINDING_SEARCH_DISTANCE, 1, 4)

	if not wp then
		mcl_log("### No direct path. Path through door closest to target.")
		local door_near_target = minetest.find_node_near(target, 16, {"group:door"})
		wp = calculate_path_through_door(p, door_near_target, t)

		if not wp then
			mcl_log("### No path though door closest to target. Try door closest to origin.")
			local door_closest = minetest.find_node_near(p, 16, {"group:door"})
			wp = calculate_path_through_door(p, door_closest, t)

			-- Path through 2 doors
			if not wp then
				mcl_log("### Still not wp. Need to path through 2 doors.")
				local path_through_closest_door = calculate_path_through_door(p, door_closest)

				if path_through_closest_door and #path_through_closest_door > 0 then
					mcl_log("We have path through first door")
					mcl_log("Number of pos in path through door: " .. tostring(#path_through_closest_door))

					local pos_after_door_entry = path_through_closest_door[#path_through_closest_door]
					if pos_after_door_entry then
						local pos_after_door = vector.add(pos_after_door_entry["pos"], one_up)
						mcl_log("pos_after_door: " .. minetest.pos_to_string(pos_after_door))
						local path_after_door = calculate_path_through_door(pos_after_door, door_near_target, t)
						if path_after_door and #path_after_door > 1 then
							mcl_log("We have path after first door")
							table.remove(path_after_door, 1) -- Remove duplicate
							wp = path_through_closest_door
							append_paths (wp, path_after_door)
						else
							mcl_log("Path after door is not good")
						end
					else
						mcl_log("No pos after door")
					end
				else
					mcl_log("Path through closest door empty or null")
				end
			else
				mcl_log("ok, we have a path through 1 door")
			end
		end
	else
		wp = generate_enriched_path(wp)
		mcl_log("We have a direct route")
	end

	if not wp then
		mcl_log("Could not calculate path")
		self._pf_last_failed = os.time()
		-- If cannot path, don't immediately try again
	end

	if wp and #wp > 0 then
		--output_table(wp)
		self._target = t
		self.callback_arrived = callback_arrived
		local current_location = table.remove(wp,1)
		if current_location and current_location["pos"] then
			mcl_log("Removing first co-ord? " .. tostring(current_location["pos"]))
		else
			mcl_log("Nil pos")
		end
		self.current_target = current_location
		self.waypoints = wp
		self:set_state(PATHFINDING)
		return true
	else
		self:set_state("walk")
		self.waypoints = nil
		self.current_target = nil
		--	minetest.log("no path found")
	end
end

function mob_class:interact_with_door(action, target)
	if target then
		mcl_log("Door target is: ".. minetest.pos_to_string(target))

		local n = minetest.get_node(target)
		if n.name:find("_b_") or n.name:find("_t_") then
			mcl_log("Door")
			local def = minetest.registered_nodes[n.name]
			local meta = minetest.get_meta(target)
			local closed = meta:get_int("is_open") == 0
			--if self.state == PATHFINDING then
				if closed and action == "open" and def.on_rightclick then
					mcl_log("Open door")
					def.on_rightclick(target,n,self)
				end
				if not closed and action == "close" and def.on_rightclick then
					mcl_log("Close door")
					def.on_rightclick(target,n,self)
				end
			--else
		else
			mcl_log("Not door")
		end
	else
		mcl_log("no target. cannot try and open or close door")
	end
	--end
end

function mob_class:do_pathfind_action(action)
	if action then
		mcl_log("Action present")
		local type = action["type"]
		local action_val = action["action"]
		local target = action["target"]
		if target then
			mcl_log("Target: ".. minetest.pos_to_string(target))
		end
		if type and type == "door" then
			mcl_log("Type is door")
			self:interact_with_door(action_val, target)
		end
	end
end

function mob_class:check_gowp(dtime)
	local p = self.object:get_pos()

	-- no destination
	if not p or not self._target then
		mcl_log("p: ".. tostring(p))
		mcl_log("self._target: ".. tostring(self._target))
		return
	end

	-- arrived at location, finish gowp
	local distance_to_targ = vector.distance(p,self._target)
	--mcl_log("Distance to targ: ".. tostring(distance_to_targ))
	if distance_to_targ < 1.8 then
		mcl_log("Arrived at _target")
		self.waypoints = nil
		self._target = nil
		self.current_target = nil
		self:set_state("stand")
		self.order = "stand"
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.object:set_acceleration({x = 0, y = 0, z = 0})
		if self.callback_arrived then return self.callback_arrived(self) end
		return true
	elseif not self.current_target then
		mcl_log("Not close enough to targ: ".. tostring(distance_to_targ))
	end

	-- More pathing to be done
	local distance_to_current_target = 50
	if self.current_target and self.current_target["pos"] then
		distance_to_current_target = vector.distance(p,self.current_target["pos"])
	end

	-- 0.6 is working but too sensitive. sends villager back too frequently. 0.7 is quite good, but not with heights
	-- 0.8 is optimal for 0.025 frequency checks and also 1... Actually. 0.8 is winning
	-- 0.9 and 1.0 is also good. Stick with unless door open or closing issues
	if self.waypoints and #self.waypoints > 0 and ( not self.current_target or not self.current_target["pos"] or distance_to_current_target < 0.9 ) then
		-- We have waypoints, and are at current_target or have no current target. We need a new current_target.
		self:do_pathfind_action (self.current_target["action"])

		local failed_attempts = self.current_target["failed_attempts"]
		mcl_log("There after " .. failed_attempts .. " failed attempts. current target:".. minetest.pos_to_string(self.current_target["pos"]) .. ". Distance: " ..  distance_to_current_target)

		self.current_target = table.remove(self.waypoints, 1)
		self:go_to_pos(self.current_target["pos"])
		return
	elseif self.current_target and self.current_target["pos"] then
		-- No waypoints left, but have current target and not close enough. Potentially last waypoint to go to.

		self.current_target["failed_attempts"] = self.current_target["failed_attempts"] + 1
		local failed_attempts = self.current_target["failed_attempts"]
		if failed_attempts >= PATHFINDING_FAIL_THRESHOLD then
			mcl_log("Failed to reach position (" .. minetest.pos_to_string(self.current_target["pos"]) .. ") too many times. Abandon route. Times tried: " .. failed_attempts)
			self:set_state("stand")
			self.current_target = nil
			self.waypoints = nil
			self._target = nil
			self._pf_last_failed = os.time()
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			return
		end

		--mcl_log("Not at pos with failed attempts ".. failed_attempts ..": ".. minetest.pos_to_string(p) .. "self.current_target: ".. minetest.pos_to_string(self.current_target["pos"]) .. ". Distance: ".. distance_to_current_target)
		self:go_to_pos(self.current_target["pos"])
		-- Do i just delete current_target, and return so we can find final path.
	else
		-- Not at target, no current waypoints or current_target. Through the door and should be able to path to target.
		-- Is a little sensitive and could take 1 - 7 times. A 10 fail count might be a good exit condition.

		mcl_log("We don't have waypoints or a current target. Let's try to path to target")

		if self.waypoints then
			mcl_log("WP: " .. tostring(self.waypoints))
			mcl_log("WP num: " .. tostring(#self.waypoints))
		else
			mcl_log("No wp set")
		end
		if self.current_target then
			mcl_log("Current target: " .. tostring(self.current_target))
		else
			mcl_log("No current target")
		end

		local final_wp = minetest.find_path(p, self._target, PATHFINDING_SEARCH_DISTANCE, 1, 4)
		if final_wp then
			mcl_log("We can get to target here.")
		--	self.waypoints = final_wp
			self:go_to_pos(self._target)
		else
			-- Abandon route?
			mcl_log("Cannot plot final route to target")
		end
	end

	-- I don't think we need the following anymore, but test first.
	-- Maybe just need something to path to target if no waypoints left
	if self.current_target and self.current_target["pos"] and (self.waypoints and #self.waypoints == 0) then
		local updated_p = self.object:get_pos()
		local distance_to_cur_targ = vector.distance(updated_p,self.current_target["pos"])

		mcl_log("Distance to current target: ".. tostring(distance_to_cur_targ))
		mcl_log("Current p: ".. minetest.pos_to_string(updated_p))

		-- 1.6 is good. is 1.9 better? It could fail less, but will it path to door when it isn't after door
		if distance_to_cur_targ > 1.9 then
			mcl_log("not close to current target: ".. minetest.pos_to_string(self.current_target["pos"]))
			self:go_to_pos(self._current_target)
		else
			mcl_log("close to current target: ".. minetest.pos_to_string(self.current_target["pos"]))
			mcl_log("target is: ".. minetest.pos_to_string(self._target))
			self.current_target = nil
		end
		return
	end
end
