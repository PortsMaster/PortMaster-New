local ProgressArc = SpriteGroup:extend("ProgressArc")

function ProgressArc:new(x, y, size, lsize, colors, tracker, max)
	ProgressArc.super.new(self, x, y)
	self.size = size
	self.linesize = lsize
	self.colors = colors or {Color.BLACK, Color.WHITE}
	self.width, self.height = size, size

	self.bg = Graphic(0, 0, size, size, self.colors[1], "arc", "line")
	self.bg.line.width = self.linesize
	self.bg.config = {
		type = "closed",
		angle = {0, 360},
		segments = 32
	}
	self:add(self.bg)

	self.arc = Graphic(0, 0, size, size, self.colors[2], "arc", "line")
	self.arc.line.width = self.linesize * 0.5
	self.arc.width = self.bg.width - self.arc.line.width
	self.arc.height = self.bg.height - self.arc.line.width
	self.arc.config = {
		type = "open",
		angle = {-90, -90},
		segments = 32
	}
	self:add(self.arc)
	self.arc.x = (self.bg.width - self.arc.width) / 2
	self.arc.y = (self.bg.height - self.arc.height) / 2

	self.tracker = tracker or 1
	self.max = max or 2
end

function ProgressArc:update(dt)
	local angle = (self.tracker / self.max) * 0.36
	self.arc.config.angle[2] = -90 + math.ceil(angle)

	if self.width ~= self.size then self.width = self.size end
	if self.width ~= self.height then self.height = self.width end

	if self.size ~= self.bg.width or self.size ~= self.bg.height or
		self.linesize ~= self.bg.line.size then
		self:__updateDimensions()
	end
end

function ProgressArc:updateColors(color1, color2)
	if color1 then self.colors[1] = color1 end
	if color2 then self.colors[2] = color2 end
	self.arc.color = self.colors[1]
	self.bg.color = self.colors[2]
end

function ProgressArc:__updateDimensions()
	self.bg.width, self.bg.height = self.size, self.size
	self.bg.line.width = self.linesize

	self.arc.line.width = self.linesize * 0.5
	self.arc.width = self.bg.width - self.arc.line.width
	self.arc.height = self.bg.height - self.arc.line.width

	self.arc.x = (self.bg.width - self.arc.width) / 2
	self.arc.y = (self.bg.height - self.arc.height) / 2
end

return ProgressArc
