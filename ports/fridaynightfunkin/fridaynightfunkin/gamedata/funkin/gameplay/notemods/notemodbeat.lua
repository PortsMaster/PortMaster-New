local NoteModBeat = NoteModifier:extend("NoteModBeat")

local function getAmplitude(curBeat)
	local beat, amp = curBeat % 1, 0
	if beat <= 0.3 then
		amp = Timer.tween.sine((0.3 - beat) / 0.3) * 0.3
	elseif beat >= 0.7 then
		amp = -(1 - Timer.tween.sine(1 - (beat - 0.7) / 0.3)) * 0.3
	end
	return amp / 0.3 * (curBeat % 2 >= 1 and -1 or 1)
end
NoteModBeat.getAmplitude = getAmplitude

function NoteModBeat:new(x, y, z)
	NoteModBeat.super.new(self)
	self:set(x or 1, y or 0, z or 0)
	self.beat = 1
	self.speed = 1
	self.beatOffset = 0
end

function NoteModBeat:set(x, y, z)
	self.x, self.y, self.z = x or self.x, y or self.y, z or self.z
end

function NoteModBeat:apply(notefield)
	local beat, width = notefield.beat / self.beat + self.beatOffset, notefield.noteWidth
	for _, r in ipairs(notefield.receptors) do
		NoteModifier.prepare(r.noteOffsets, r.noteOffsets)
		NoteModifier.prepare(r, "x", r.x)
		NoteModifier.prepare(r, "y", r.y)
		NoteModifier.prepare(r, "z", r.z)

		local x = getAmplitude(beat) * width / 2 * self.percent
		r.x, r.noteOffsets.x = r.x + x * self.x, r.noteOffsets.x - x * self.x
		r.y, r.noteOffsets.y = r.y + x * self.y, r.noteOffsets.y - x * self.y
		r.z, r.noteOffsets.z = r.z + x * self.z, r.noteOffsets.z - x * self.z
	end
end

function NoteModBeat:applyPath(path, curBeat, pos, notefield, direction)
	local x = getAmplitude(curBeat / self.beat + self.beatOffset)
		* math.fastcos(pos / 45 * self.speed) * notefield.noteWidth / 2 * self.percent

	path.x = path.x + x * self.x
	path.y = path.y + x * self.y
	path.z = path.z + x * self.z
end

return NoteModBeat
