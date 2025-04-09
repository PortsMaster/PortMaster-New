local ModCard = SpriteGroup:extend("ModCard")

function ModCard:new(x, y, mods)
	ModCard.super.new(self, x, y)

	local metadata = Mods.getMetadata(mods)

	local enabledColor = (Mods.currentMod == mods and Color.GREEN or Color.RED)
	self.enableCheck = Graphic(0, 0, 432, 600, enabledColor, nil, "line")
	self.enableCheck.line.width = 3
	self.enableCheck.config.round = {16, 16}
	self:add(self.enableCheck)

	self.bg = Graphic(0, 0, 432, 600, Color.BLACK)
	self.bg.alpha = 0.5
	self.bg.config.round = {16, 16}
	self:add(self.bg)

	self.banner = Sprite(0, 8):loadTexture(Mods.getBanner(mods))
	self.banner:setGraphicSize(self.bg.width - 16)
	self.banner:updateHitbox()
	self.banner.x = (self.bg.width - self.banner.width) / 2
	self:add(self.banner)

	self.titleBG = Graphic(0, 8, 0, 0, Color.BLACK)
	self.titleBG.width, self.titleBG.height = self.bg.width - 16, 40
	self.titleBG.x, self.titleBG.y = (self.bg.width - self.titleBG.width) / 2,
		self.titleBG.y + self.banner.height + 8
	self.titleBG.alpha = 0.3
	self.titleBG.config.round = {16, 16}
	self:add(self.titleBG)

	self.titleTxt = Text(0, 0, metadata.name, paths.getFont("phantommuff.ttf", 30),
		Color.WHITE, "center", self.titleBG.width - 8)
	self.titleBG.height = self.titleTxt:getHeight() + 8
	self.titleTxt.x, self.titleTxt.y = self.titleBG.x + (self.bg.width - self.titleBG.width) / 2, self.titleBG.y +
		(self.titleBG.height - self.titleTxt:getHeight()) / 2
	self:add(self.titleTxt)

	self.descBG = Graphic(0, 0, 0, 0, Color.BLACK)
	self.descBG.width, self.descBG.height = self.bg.width - 16, self.bg.height - (
		self.titleBG.y + self.titleBG.height) - 16
	self.descBG.x, self.descBG.y = (self.bg.width - self.descBG.width) / 2, self.titleBG.y + self.titleBG.height + 8
	self.descBG.alpha = 0.5
	self.descBG.config.round = {16, 16}
	self:add(self.descBG)

	self.descTxt = Text(self.descBG.x + 8, self.descBG.y + 8, metadata.description, love.graphics.newFont(16),
		Color.WHITE, "left", self.descBG.width - 16)
	self:add(self.descTxt)

	self.metadata = metadata
end

return ModCard
