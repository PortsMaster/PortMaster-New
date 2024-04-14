## mcl_events
### Registering Events
		`mlc_events.register_event("name",def)`

#### Event Definition
 {
	stage = 0,
	max_stage = 1,
	percent = 100,
	bars = {},
	completed = false,
	cond_start = function() end,
		--return table of paramtables e.g. { { player = playername, pos = position, ... } }, custom parameters will be passed to the event object/table
	on_step = function(event) end,
		--this function is run every game step when the event is active
	on_start = function(event) end,
		-- this function is run when the event starts
	on_stage_begin = function(event) end,
		-- this function runs when a new stage of the event starts
	cond_progress = function(event) end, --return false or next stage id
		--this function checks if the event should progress to the next (or any other) stage
	cond_complete = function(event) end,
		--return true if event finished successfully
}

### Debugging
	* /event_start <event> -- starts the given event at the current player coordinates
