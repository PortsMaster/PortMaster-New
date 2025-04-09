local NoteModScale = NoteModifier:extend("NoteModScale")

function NoteModScale:new(x, y, z)
	NoteModScale.super.new(self)
	self:set(x or 1, y or 1, z or 1)
end

function NoteModScale:set(x, y, z)
	self.x, self.y, self.z = x or self.x, y or self.y, z or self.z
end

local lerp = math.lerp
function NoteModScale:apply(notefield)
	local scale = notefield.scale; NoteModifier.prepare(scale, scale)
	scale.x, scale.y, scale.z =
		lerp(scale.x, self.x, self.percent), lerp(scale.y, self.y, self.percent), lerp(scale.z, self.z, self.percent)

	scale = notefield.memberScales; NoteModifier.prepare(scale, scale)
	scale.x, scale.y, scale.z =
		lerp(scale.x, self.x, self.percent), lerp(scale.y, self.y, self.percent), lerp(scale.z, self.z, self.percent)
end

return NoteModScale
