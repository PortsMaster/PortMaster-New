local UserList = SpriteGroup:extend("UserList")

function UserList:new(data)
	UserList.super.new(self, 0, 0)

	self.lastHeight = 0
	self.curSelected = 1
	self.curTab = 1
	self.data = data or {}

	self.box = Graphic(10, 10, 426, game.height, Color.fromRGB(10, 12, 26))
	self.box.alpha = 0.4
	self.box:setScrollFactor()
	self:add(self.box)

	self.bar = Graphic(self.box.x + 20, self.box.y + 10,
		self.box.width - 40, 54, Color.WHITE)
	self.bar.alpha = 0.2
	self.bar:setScrollFactor(0, 1)
	self:add(self.bar)

	for i = 1, #self.data do
		local header = self.data[i]
		self:addUsers(header.header, header.credits, i - 1)
	end
end

function UserList:addUsers(name, people, i)
	local x, y = self.box.x + 10, self.box.y + 10

	local box = Graphic(x, y, self.box.width - 20, 60)
	box.y = self.lastHeight > 0 and self.lastHeight + 10 or box.y
	box.alpha = 0.2
	box.config.round = {18, 18}
	box:setScrollFactor(0, 1)
	self:add(box)

	local title = Text(x + 10, y + box.y + 8, name or "Unknown", paths.getFont("vcr.ttf", 38))
	title.y = box.y + (box.height - title:getHeight()) / 2
	title.limit = box.width - 20
	title:setScrollFactor(0, 1)
	title.alignment = "center"
	title.antialiasing = false
	self:add(title)

	local function makeCard(name, icon, i)
		local img = Sprite(x + 10, box.y +
			(64 * i + 10), paths.getImage("menus/credits/icons/" .. icon))
		img:setGraphicSize(54)
		img:updateHitbox()
		img:setScrollFactor(0, 1)
		self:add(img)

		local txt = Text(x + img.x + img.width + 10, y,
			name, paths.getFont("vcr.ttf", 36))
		txt.y = img.y + (img.height - txt:getHeight()) / 2
		txt.limit = box.width - img.width - 30
		txt:setScrollFactor(0, 1)
		txt.antialiasing = false
		self:add(txt)

		return img, txt
	end

	for i = 1, #people do
		local img, txt = makeCard(people[i].name, people[i].icon, i)
		self.lastHeight = img.y + img.height + 10
	end
end

function UserList:changeSelection(n)
	n = n or 0

	self.curSelected = self.curSelected + n

	if self.curSelected < 1 then
		self.curTab = (self.curTab - 2) % #self.data + 1
		self.curSelected = #self.data[self.curTab].credits
	elseif self.curSelected > #self.data[self.curTab].credits then
		self.curTab = self.curTab % #self.data + 1
		self.curSelected = 1
	end

	local currentList = self.curSelected
	for i = 1, self.curTab - 1 do
		currentList = currentList + #self.data[i].credits
	end

	self.bar.y = 94 + 84 * (self.curTab - 1) + 64 * (currentList - 1)
end


function UserList:getCurrent()
	return self.data[self.curTab].credits[self.curSelected]
end

function UserList:__render(c)
	love.graphics.stencil(function()
		local x, y, w, h = 10, 10, self.box.width, game.height - 20
		x, y = x - self.offset.x, y - self.offset.y

		love.graphics.rectangle("fill", x, y, w, h, 24, 24)
	end, "replace", 1)
	love.graphics.setStencilTest("greater", 0)
	UserList.super.__render(self, c)
	love.graphics.setStencilTest()
end

return UserList
