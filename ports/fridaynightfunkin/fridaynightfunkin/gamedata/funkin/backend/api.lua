local API = {chart = {}, meta = {}, character = {}}

API.meta.base = {
	songName = nil,
	artist = nil,
	charter = nil,

	preview = {0, 1500}
}

API.chart.base = {
	song = nil,
	bpm = 100,
	speed = 1,

	difficulties = {"Easy", "Normal", "Hard"},

	player1 = "bf",
	player2 = "dad",
	gfVersion = nil,

	stage = nil,
	skin = nil,

	events = {},
	notes = {
		player = {}, enemy = {}
	},
	timeChanges = nil
}

API.character.base = {}

local function sortByTime(a, b) return a.t < b.t end
local function set(tbl, key, v) if v ~= nil then tbl[key] = v end end

function API.chart.parse(song, diff, returnRaw)
	assert(type(song) == "string", "Song must be a string.")
	song = paths.formatToSongPath(song)

	local chart, isV1 = table.clone(API.chart.base), false
	local data = paths.getJSON("songs/" .. song .. "/chart")

	if data == nil then
		path = "songs/" .. song .. "/charts/" .. diff:lower() or
			PlayState.defaultDifficulty

		data = paths.getJSON(path)
		if data == nil then data = chart end
		isV1 = true
	end

	set(chart, "song", song:capitalize())

	local meta = API.chart.adjustMeta(song, chart)

	if chart.timeChanges then
		-- todo rework this and change conductor maybe??, fnf base works with different times
		--[[
		t: Timestamp in specified `timeFormat`.
		b: Time in beats (int). The game will calculate further beat values based on this one, so it can do it in a simple linear fashion.
		bpm: Quarter notes per minute (float). Cannot be empty in the first element of the list, but otherwise it's optional,
		and defaults to the value of the previous element.
		n: Time signature numerator (int). Optional, defaults to 4.
		d: Time signature denominator (int). Optional, defaults to 4. Should only ever be a power of two.
		bt: Beat tuplets (Array<int> or int). This defines how many steps each beat is divided into.
		It can either be an array of length `n` (see above) or a single integer number. Optional, defaults to 4.
		]]
		for i, c in ipairs(chart.timeChanges) do
			if c.t <= 0 then
				chart.bpm = c.bpm
				table.remove(chart.timeChanges, i)
				break
			end
		end
	end

	local realData = data.song or data

	if isV1 then
		set(chart, "song", realData.song)
		set(chart, "bpm", realData.bpm)
		set(chart, "speed", realData.speed)

		set(chart, "stage", realData.stage)
		set(chart, "skin", realData.skin)

		set(chart, "player1", realData.player1)
		set(chart, "player2", realData.player2)
		set(chart, "gfVersion", realData.gfVersion)
	end

	if not chart.stage then
		switch(song, {
			["test"] = function() chart.stage = "test" end,
			[{"spookeez", "south", "monster"}] = function() chart.stage = "spooky" end,
			[{"pico", "philly-nice", "blammed"}] = function() chart.stage = "philly" end,
			[{"satin-panties", "high", "milf"}] = function() chart.stage = "limo" end,
			[{"cocoa", "eggnog"}] = function() chart.stage = "mall" end,
			["winter-horrorland"] = function() chart.stage = "mall-evil" end,
			[{"senpai", "roses"}] = function() chart.stage = "school" end,
			["thorns"] = function() chart.stage = "school-evil" end,
			[{"ugh", "guns", "stress"}] = function() chart.stage = "tank" end,
			default = function() chart.stage = "stage" end
		})
	end
	if not chart.skin then
		switch(chart.stage, {
			[{"school", "school-evil"}] = function() chart.skin = "default-pixel" end,
			default = function() chart.skin = "default" end
		})
	end
	if not chart.gfVersion then
		switch(chart.stage, {
			["limo"] = function() chart.gfVersion = "gf-car" end,
			[{"mall", "mall-evil"}] = function() chart.gfVersion = "gf-christmas" end,
			[{"school", "school-evil"}] = function() chart.gfVersion = "gf-pixel" end,
			["tank"] = function()
				chart.gfVersion = song == "stress" and "pico-speaker" or "gf-tankmen"
			end,
			default = function() chart.gfVersion = "gf" end
		})
	end

	if isV1 then
		if realData.notes then
			chart.notes, chart.events, chart.bpmChanges =
				API.chart.readDiff(chart.bpm, realData.notes, true)
		end
	elseif data.notes[diff:lower()] then
		local speed = data.scrollSpeed and (data.scrollSpeed[diff:lower()] or
			data.scrollSpeed.default) or 1
		chart.speed = speed
		chart.notes, chart.events =
			API.chart.readDiff(chart.bpm, data.notes[diff:lower()]), data.events
	end

	table.sort(chart.notes.enemy, sortByTime)
	table.sort(chart.notes.player, sortByTime)
	table.sort(chart.events, sortByTime)

	return returnRaw and data or chart, meta
end

function API.chart.readDiff(bpm, data, isV1)
	local dad, bf, events, bpmChanges =
		{}, {}, {}, Conductor.newBPMChanges(bpm)
	if isV1 then
		local time, steps, total,
		add, focus, lastFocus = 0, 0, 0
		for _, s in ipairs(data) do
			if s and s.sectionNotes then
				for _, n in ipairs(s.sectionNotes) do
					local hit = s.mustHitSection
					local kind = n[4]
					local column, gf = n[2], kind == "GF Sing"
					if column > 3 then hit = not hit end
					if not gf and (kind == true or kind == 1 or (not hit and s.altAnim)) then
						kind = "alt"
					elseif gf or type(kind) ~= "string" then
						kind = nil
					end
					table.insert(hit and bf or dad, {
						t = n[1],
						d = column % 4,
						l = n[3],
						k = kind,
						gf = gf or not hit and s.gfSection
					})
				end

				focus = s.gfSection and 2 or (s.mustHitSection and 0 or 1)
				if focus ~= lastFocus then
					table.insert(events, {
						t = time,
						e = "FocusCamera",
						v = focus
					})
					lastFocus = focus
				end

				if s.changeBPM and s.bpm ~= nil and s.bpm ~= bpm then
					bpm, total = s.bpm, total + 1
					table.insert(bpmChanges, {
						step = steps,
						time = time,
						bpm = bpm,
						stepCrotchet = Conductor.calculateCrotchet(bpm) / 4,
						id = total
					})
				end

				add = s.sectionBeats and s.sectionBeats * 4 or 16
				steps = steps + add
				time = time + bpmChanges[total].stepCrotchet * add
			end
		end
	else
		for _, n in ipairs(data) do
			local data = n.d
			table.insert(data > 3 and dad or bf, {
				t = n.t,
				d = data % 4,
				l = n.l or 0,
				k = n.k
			})
		end
	end
	return {enemy = dad, player = bf}, events, bpmChanges
end

--[[
This moves a lot of playData info to charts, then it gets
wiped from the meta, to avoid unused values.
]]
function API.chart.adjustMeta(song, tbl)
	local data = API.meta.parse(song, true)
	local info = {}

	if data then
		local info = data.playData or data
		set(tbl, "song", data.songName or data.song)
		set(tbl, "stage", info.stage)
		set(tbl, "skin", info.skin)

		set(tbl, "difficulties", info.difficulties)
		set(tbl, "timeChanges", data.timeChanges)

		info = info.characters or info
		set(tbl, "player1", info.player)
		set(tbl, "player2", info.opponent)
		set(tbl, "gfVersion", info.girlfriend)
	end

	data.playData, data.timeChanges = nil, nil
	data.preview = nil

	return data
end

-- Function to parse metadata song files.
function API.meta.parse(song, isPlayable)
	local clone = table.clone(API.meta.base)
	local path = isPlayable and "songs/" .. song .. "/meta" or "music/" .. song .. "-meta"

	local meta = table.merge(clone, paths.getJSON(path))
	if meta == nil then meta = clone end

	local info = {}
	if meta.playData then
		local info = meta.playData
	end

	set(meta.preview[1], info.previewStart)
	set(meta.preview[2], info.previewEnd)

	info.previewStart, info.previewEnd = nil, nil

	return meta
end

return API
