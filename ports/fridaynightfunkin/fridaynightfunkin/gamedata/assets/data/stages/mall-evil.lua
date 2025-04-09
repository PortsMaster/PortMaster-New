local upperBopper
local bottomBopper
local santa

function create()
	self.boyfriendPos = {x = 1090, y = 100}

	local bg = Sprite(-400, -500)
	bg:loadTexture(paths.getImage(SCRIPT_PATH .. 'evilBG'))
	bg:setGraphicSize(math.floor(bg.width * 0.8))
	bg:updateHitbox()
	bg:setScrollFactor(0.2, 0.2)
	self:add(bg)

	local evilTree = Sprite(300, -300)
	evilTree:loadTexture(paths.getImage(SCRIPT_PATH .. 'evilTree'))
	evilTree:setScrollFactor(0.2, 0.2)
	self:add(evilTree)

	local evilSnow = Sprite(-200, 700)
	evilSnow:loadTexture(paths.getImage(SCRIPT_PATH .. 'evilSnow'))
	self:add(evilSnow)

	close()
end
