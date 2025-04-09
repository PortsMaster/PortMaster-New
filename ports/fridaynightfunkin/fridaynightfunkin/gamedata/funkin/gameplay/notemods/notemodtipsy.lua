local NoteModTipsy = NoteModifier:extend("NoteModTipsy")

function NoteModTipsy:new(tipsy, drunk)
	NoteModTipsy.super.new(self)

	self:set(tipsy or 1, tipsy or 0)
	self.offset = 0
	self.spacing = 1
	self.speed = 1

	self.tipsyOffset = 0
	self.tipsySpacing = 1
	self.tipsySpeed = 1

	self.drunkOffset = 0
	self.drunkSpacing = 1
	self.drunkSpeed = 1
end

function NoteModTipsy:set(tipsy, drunk)
	self.tipsy, self.drunk = tipsy or self.tipsy, drunk or self.drunk
end

function NoteModTipsy:apply(notefield)
	local beat, keys, width, receptors = notefield.beat, notefield.keys, notefield.noteWidth, notefield.receptors
	local tipsyOffset, tipsySpeed, tipsySpacing, tipsy, drunkOffset, drunkSpeed, drunkSpacing, drunk =
		self.tipsyOffset + self.offset, self.tipsySpeed * self.speed, self.tipsySpacing * self.spacing, self.tipsy * self.percent,
		self.drunkOffset + self.offset, self.drunkSpeed * self.speed, self.drunkSpacing * self.spacing, self.drunk * self.percent

	for i = 1, keys do
		local r, x = receptors[i], math.fastsin(beat / 4 * drunkSpeed * math.pi + (i - 1) * drunkSpacing / 2) * width / 2 * drunk
		NoteModifier.prepare(r, "y", r.y); NoteModifier.prepare(r, "x", r.x); NoteModifier.prepare(r.noteOffsets, r.noteOffsets)
		r.y, r.x, r.noteOffsets.x =
			r.y + math.fastsin(beat / 4 * tipsySpeed * math.pi + tipsyOffset + (i - 1) * tipsySpacing) * width / 2 * tipsy,
			r.x + x,
			r.noteOffsets.x - x
	end
end

function NoteModTipsy:applyPath(path, curBeat, pos, notefield, direction)
	path.x = path.x + math.fastsin(curBeat / 4 *
		(self.drunkSpeed * self.speed) * math.pi + (self.drunkOffset + self.offset) +
		(direction + pos / 222 * math.pi) * (self.drunkSpacing * self.spacing) / 2
	) * notefield.noteWidth / 2 * self.percent * self.drunk
end

return NoteModTipsy
