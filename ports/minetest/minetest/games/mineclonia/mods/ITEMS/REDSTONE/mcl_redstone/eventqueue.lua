mcl_redstone.tick_speed = tonumber(core.settings:get("mcl_redstone_update_tick")) or 0.1
local MAX_EVENTS = tonumber(core.settings:get("mcl_redstone_max_events")) or 65535
local TIME_BUDGET = math.max(0.01, mcl_redstone.tick_speed * (tonumber(core.settings:get("mcl_redstone_time_budget")) or 0.2))
local EXPERIMENTAL_USE_ORDERED_EVENT_QUEUE = core.settings:get_bool("mcl_redstone_ordered_event_queue", false)

mcl_redstone.is_tick_frozen = false

mcl_redstone._pending_updates = {}

local eventqueue
if EXPERIMENTAL_USE_ORDERED_EVENT_QUEUE then
	eventqueue = mcl_redstone._priority_queue_ordered()
else
	eventqueue = mcl_redstone._priority_queue()
end

local current_tick = 0

-- Table containing the highest priority update event for each node position.
local update_event_tab = {}

function mcl_redstone._schedule_update(delay, priority, pos, node, oldnode)
	local h = core.hash_node_position(pos)
	if update_event_tab[h] and priority >= update_event_tab[h].priority then
		return
	end

	-- For events that do not change anything, only cancel other pending
	-- events with lower priority.
	if node.name == oldnode.name and node.param2 == oldnode.param2 then
		update_event_tab[h] = nil
		return
	end

	local tick = current_tick + delay
	local event = {
		type = "update",
		pos = pos,
		tick = tick,
		priority = priority,
		node = node,
		oldnode = oldnode,
	}
	update_event_tab[h] = event
	eventqueue:enqueue(tick, event)
end

function mcl_redstone.after(delay, func)
	local tick = current_tick + delay
	local event = {
		type = "after",
		tick = tick,
		func = func,
	}
	eventqueue:enqueue(tick, event)
end

function mcl_redstone._abort_pending_update(pos)
	local h = core.hash_node_position(pos)
	update_event_tab[h] = nil
end

function mcl_redstone._get_current_tick()
	return current_tick
end

local function handle_update_event(event)
	local h = core.hash_node_position(event.pos)
	if update_event_tab[h] ~= event then
		return
	end

	update_event_tab[h] = nil
	local oldnode = core.get_node(event.pos)
	if oldnode.name ~= event.oldnode.name or oldnode.param2 ~= event.oldnode.param2 then
		return
	end
	core.swap_node(event.pos, event.node)
	mcl_redstone._update_neighbours(event.pos, event.oldnode, event.node)
	mcl_redstone._notify_observer_neighbours(event.pos)
end

local function handle_event(event)
	if event.type == "after" then
		event.func()
	elseif event.type == "update" then
		handle_update_event(event)
	end
end

local function clear_all_pending_events()
	update_event_tab = {}
	while eventqueue:size() > 0 do
		eventqueue:dequeue()
	end
end

local function get_time()
	return core.get_us_time() / 1e6
end

local function debug_log(tick, nevents, nupdates, npending, time, aborted)
	if not core.settings:get_bool("mcl_redstone_debug_eventqueue", false)
			or (nevents == 0 and nupdates == 0) then
		return
	end

	local saborted = aborted and ", was aborted" or ""
	core.log(string.format(
		"[mcl_redstone] tick %d, %d events and %d updates processed, %d pending events, took %f ms%s",
		tick,
		nevents,
		nupdates,
		npending,
		time / 1000,
		saborted
	))
end

function mcl_redstone.tick_step()
	local player_poses = {}
	for _, player in pairs(core.get_connected_players()) do
		table.insert(player_poses, player:get_pos())
	end

	if eventqueue:size() > MAX_EVENTS then
		core.log("error", string.format("[mcl_redstone]: Maximum number of queued redstone events (%d) exceeded, deleting all of them.", MAX_EVENTS))
		clear_all_pending_events()
	end

	local starttime = get_time()
	local endtime = starttime + TIME_BUDGET
	local nevents = 0
	local nupdates = 0

	local function log_redstone_events(aborted)
		local time = get_time() - starttime
		local npending = eventqueue:size()

		debug_log(current_tick, nevents, nupdates, npending, time, aborted)
	end

	local last_tick = current_tick
	while eventqueue:size() > 0 and eventqueue:peek().tick <= current_tick do
		if get_time() > endtime then
			log_redstone_events(true)
			return
		end

		local event = eventqueue:dequeue()
		nevents = nevents + 1
		handle_event(event)
		last_tick = event.tick
	end

	for h, pos in pairs(mcl_redstone._pending_updates) do
		if get_time() > endtime then
			log_redstone_events(true)
			return
		end

		nupdates = nupdates + 1
		mcl_redstone._call_update(pos)
		mcl_redstone._pending_updates[h] = nil
	end

	log_redstone_events(false)
	current_tick = last_tick + 1
end

core.register_chatcommand("tick",
{
	description = "Allows to stop redstone ticking, speed it up, or freezing it. Note that \"ticks\" in this command actually refer to redstone ticks",
	params = "step [ticks] | sprint <ticks> | freeze | unfreeze | rate <seconds per tick> | query",
	privs = {server = true},
	func = function(name, param)
		local _, end_pos, operation = string.find(param, "^%s*(%a+)")
		if not end_pos then
			return false
		end

		local _, _, arg = string.find(param, "^%s*([%a%d.]+)", end_pos + 1)

		if operation == "query" then
			return true, mcl_redstone.tick_speed
		elseif operation == "freeze" then
			mcl_redstone.is_tick_frozen = true
			return true
		elseif operation == "unfreeze" then
			mcl_redstone.is_tick_frozen = false
			return true
		elseif operation == "reset" then
			mcl_redstone.tick_speed = tonumber(core.settings:get("mcl_redstone_update_tick")) or 0.1
			return true
		elseif operation == "rate" then
			if tonumber(arg) then
				mcl_redstone.tick_speed = tonumber(arg)
				return true
			else
				return false, "second argument must be a number"
			end
		elseif operation == "sprint" then
			if mcl_redstone.is_tick_frozen then
				if tonumber(arg) then
					local timer = core.get_us_time()
					for i = 1, tonumber(arg) do
						mcl_redstone.tick_step()
					end
					return true, string.format("sprint finished: took %sms", (core.get_us_time() - timer) / 1000)
				else
					return false, "second argument must be a number"
				end
			else
				return false, "tick step can only be used when ticking is frozen"
			end
		elseif operation == "step" then
			if mcl_redstone.is_tick_frozen then
				if tonumber(arg) then
					mcl_redstone.is_tick_frozen = false
					mcl_redstone.after(tonumber(arg), function() mcl_redstone.is_tick_frozen = true end)
					return true
				elseif arg == nil then
					mcl_redstone.tick_step()
					return true
				else
					return false, "second argument must be a number"
				end
			else
				return false, "tick step can only be used when ticking is frozen"
			end
		end

		return false
	end
})

local timer = 0
core.register_globalstep(function(dtime)
	if not mcl_redstone.is_tick_frozen then
		timer = timer + dtime
		if timer < mcl_redstone.tick_speed then
			return
		end
		timer = timer - mcl_redstone.tick_speed

		mcl_redstone.tick_step()
	end
end)
