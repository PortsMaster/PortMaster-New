local Button = class('Button')

function Button:initialize()

	self.id = ""
	self.x = 0
	self.y = 0
	self.width = 1
	self.height = 1
	self.normal = ""
	self.over = ""
	self.trigger = nil

	self.highlighted = false

end

function Button:getImage()

	if self.highlighted then
		return assets.images[self.over]
	else
		return assets.images[self.normal]
	end

end

function Button:isOver(x, y)

	self.highlighted = intersect(x, y, self.x, self.y, self.width, self.height)

	return self.highlighted

end

return Button
