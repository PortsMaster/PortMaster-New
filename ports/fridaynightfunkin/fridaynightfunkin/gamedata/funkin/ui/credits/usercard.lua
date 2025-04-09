local UserCard = SpriteGroup:extend("UserCard")
local MediaList = require "funkin.ui.credits.medialist"

function UserCard:new(x, y, width, height)
	UserCard.super.new(self, x, y)

	self.icon = Sprite(0, 0)
	self.icon:setGraphicSize(100)
	self.icon:updateHitbox()
	self.icon:setScrollFactor()
	self:add(self.icon)

	self.name = Text(self.icon.x + self.icon.width + 10, 0, "Name",
		paths.getFont("phantommuff.ttf", 75))
	self.name:setOutline("normal", 4)
	self.name.y = 10 + (self.icon.height - self.name:getHeight()) / 2
	self.name.antialiasing = false
	self.name:setScrollFactor()
	self:add(self.name)

	self.box = Graphic(
		self.icon.x, self.icon.y + self.icon.height + 10, width, height, Color.fromRGB(10, 12, 26))
	self.box.alpha = 0.4
	self.box.config.round = {24, 24}
	self.box:setScrollFactor()
	self:add(self.box)

	self.desc = Text(
		self.box.x + 10, self.box.y + 10, "Description",
		paths.getFont("vcr.ttf", 32), nil, nil, self.box.width - 20)
	self.desc.antialiasing = false
	self.desc:setScrollFactor()
	self:add(self.desc)

	self.media = MediaList(10, self.box.y)
	self:add(self.media)
end

function UserCard:reload(d)
	self.name.content = d.name
	self.desc.content = d.description

	self.icon:loadTexture(paths.getImage("menus/credits/icons/" .. d.icon))
	self.icon:setGraphicSize(100)
	self.icon:updateHitbox()

	self.media:reload(d)
	self.media:setPosition(10, self.y + game.height - self.media:getHeight() - 40)
end

return UserCard
