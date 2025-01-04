local animationNotes = {}

function create() loadMappedAnims() end

function loadMappedAnims()
	local swagShit = paths.getJSON("songs/"
		.. paths.formatToSongPath(PlayState.SONG.song)
		.. "/picospeaker").song

	local notes = swagShit.notes

	for _, section in ipairs(notes) do
		for _, idk in ipairs(section.sectionNotes) do
			table.insert(animationNotes, idk)
		end
	end
	table.sort(animationNotes, sortAnims)

	TankmenBG.animationNotes = animationNotes
end

function sortAnims(a, b) return a[1] < b[1] end

function update(dt)
	if #animationNotes > 0 and PlayState.conductor.time > animationNotes[1][1] then
		local noteData = 1

		if animationNotes[1][2] > 2 then noteData = 3 end

		noteData = noteData + love.math.random(0, 1)

		self:playAnim('shoot' .. noteData, true)
		table.remove(animationNotes, 1)
	end
end
