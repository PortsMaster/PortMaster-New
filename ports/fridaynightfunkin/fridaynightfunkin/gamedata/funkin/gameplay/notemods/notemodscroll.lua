local NoteModScroll = NoteModifier:extend("NoteModScroll")

function NoteModScroll:new(split, alternate, cross, center)
	NoteModScroll.super.new(self)
	self:set(split or 0, alternate or 0, cross or 0, center or 0)
	self.reverse, self.centerPath = 0, 0
end

function NoteModScroll:set(split, alternate, cross, center)
	self.split, self.alternate, self.cross, self.center =
		split or self.split, alternate or self.alternate, cross or self.cross, center or self.center
end

function NoteModScroll:apply(notefield)
	local per = self.percent
	local halfKeys, split, alternate, cross = notefield.keys / 2,
		self.split * per, self.alternate * per, self.cross * per --, self.center * per, self.reverse * per, self.centerPath * per

	for i, r in ipairs(notefield.receptors) do
		NoteModifier.prepare(r, "y", r.y); i = i - 1
		r.y = r.y * (1 - (
			(split * (i >= halfKeys and 2 or 0)) +
			(alternate * (i % 2 == 1 and 2 or 0)) --+
		--(cross * (i >=))
		))
	end
end

function NoteModScroll:applyPath(path, curBeat, pos, notefield, direction)
	path.y = path.y * (1 - (
		(self.split * self.percent * (direction >= notefield.keys / 2 and 2 or 0)) +
		(self.alternate * self.percent * (direction % 2 == 1 and 2 or 0))
	))
end

return NoteModScroll
