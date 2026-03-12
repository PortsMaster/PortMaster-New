mcl_events = {}
mcl_events.registered_events = {}
local disabled_events = core.settings:get("mcl_disabled_events")
if disabled_events then	disabled_events = disabled_events:split(",")
else disabled_events = {} end
local active_events = {}
mcl_events.active_events = active_events

local event_tpl = {
	stage = 0,
	max_stage = 1,
	percent = 100,
	bars = {},
	completed = false,
	cond_start = function() end, --return table of positions
	on_step = function() end,
	on_start = function() end,
	on_stage_begin = function() end,
	cond_progress = function() end, --return next stage
	cond_complete = function() end, --return success
}

function mcl_events.register_event(name,def)
	if table.indexof(disabled_events,name) ~= -1 then return end
	mcl_events.registered_events[name] = def
	mcl_events.registered_events[name].name = name
end

local function addbars(self)
	if not self.enable_bossbar then return end
	for player in mcl_util.connected_players(self.pos, 63) do
		local bar = mcl_bossbars.add_bar(player, {color = "red", text = self.readable_name .. ": Wave "..self.stage.." / "..self.max_stage, percentage = self.percent }, true,1)
		table.insert(self.bars,bar)
	end
end

local function start_event(p,e)
	local idx = #active_events + 1
	active_events[idx] = table.copy(e)
	setmetatable(active_events[idx],{__index = event_tpl})
	for k,v in pairs(p) do active_events[idx][k] = v end
	active_events[idx].stage = 0
	active_events[idx].percent = 100
	active_events[idx].bars = {}
	active_events[idx].time_start = os.time()
	if active_events[idx].on_start then
		active_events[idx]:on_start(p.pos)
	end
	addbars(active_events[idx])
end

local function finish_event(self,idx)
	if self.on_complete then self:on_complete() end
	for _,b in pairs(self.bars) do
		mcl_bossbars.remove_bar(b)
	end
	table.remove(active_events,idx)
end

local etime = 0
function check_events(dtime)
	--process active events
	for idx,ae in pairs(active_events) do
		if ae.cond_complete and ae:cond_complete() then
			ae.finished = true
			finish_event(ae,idx)
		elseif not ae.cond_complete and ae.max_stage and ae.max_stage <= ae.stage then
			ae.finished = true
			finish_event(ae,idx)
		elseif not ae.finished and ae.cond_progress then
			local p = ae:cond_progress()
			if p == true then
				ae.stage = ae.stage + 1
				if ae:on_stage_begin() == true then
					active_events[idx] = nil
				end
			elseif tonumber(p) then
				ae.stage = tonumber(p) or ae.stage + 1
				ae:on_stage_begin()
			end
		elseif not ae.finished and ae.on_step then
			ae:on_step(dtime)
		end
		addbars(ae)
	end
	-- check if a new event should be started
	etime = etime - dtime
	if etime > 0 then return end
	etime = 10
	for _,e in pairs(mcl_events.registered_events) do
		local pp = e.cond_start()
		if pp then
			for _,p in pairs(pp) do
				local start = true
				if e.exclusive_to_area then
					for _,ae in pairs(active_events) do
						if e.name == ae.name and vector.distance(p.pos,ae.pos) < e.exclusive_to_area then start = false end
					end
				end
				if start then
					start_event(p,e)
				end
			end
		end
	end
	for idx,ae in pairs(active_events) do
		local player_near = false
		if ae.pos then
			for _ in mcl_util.connected_players(ae.pos, 63) do
				player_near = true
				break
			end
			if not player_near then
				active_events[idx] = nil
			end
		end
	end
end

core.register_globalstep(check_events)

mcl_info.register_debug_field("Active Events",{
	level = 4,
	func = function()
		return tostring(#active_events)
	end
})

core.register_chatcommand("event_start",{
	privs = {debug = true},
	description = "Debug command to start events",
	func = function(pname,param)
		local p = core.get_player_by_name(pname)
		local evdef = mcl_events.registered_events[param]
		if not evdef then return false,"Event "..param.." doesn't exist.'" end
		start_event({pos=p:get_pos(),player=pname,factor=1},evdef)
		return true,"Started event "..param
	end,
})
