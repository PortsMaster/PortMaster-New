local NoteModBeat = require "funkin.gameplay.notemods.notemodscroll"

local NoteModColumn = NoteModifier:extend("NoteModColumn")

function NoteModColumn:new(flip, invert)
	NoteModColumn.super.new(self)
	self:set(flip or 0, invert or 0)
	self.angle = 0
end

function NoteModColumn:set(flip, invert)
	self.flip, self.invert = flip or self.flip, invert or self.invert
end

function NoteModColumn:apply(notefield)
	local keys, width, lanes = notefield.keys, notefield.noteWidth, notefield.lanes

	for i = 1, keys do
		local lane = lanes[i]
		NoteModifier.prepare(lane, "x", lane.x)
		NoteModifier.prepare(lane.receptor, "angle", lane.receptor.angle)
		NoteModifier.prepare(lane.receptor, "noteAngles", lane.receptor.noteAngles)
		lane.x, lane.receptor.angle, lane.receptor.noteAngles =
			lane.x + (
				(self.flip * (keys / 2 - (i - 0.5)) * 2) +
				(self.invert * (i % 2 == 1 and 1 or -1))
			) * width * self.percent,
			lane.receptor.angle + self.angle * self.percent,
			lane.receptor.noteAngles + self.angle * self.percent
	end
end

return NoteModColumn
