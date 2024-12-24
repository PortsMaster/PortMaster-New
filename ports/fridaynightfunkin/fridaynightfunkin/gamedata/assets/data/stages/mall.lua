local upperBopper
local bottomBopper
local santa

function create()
	self.camZoom = 0.8

	self.boyfriendPos = {x = 970, y = 100}
	self.boyfriendCam = {x = 0, y = -100}

	local bg = Sprite(-1000, -500)
	bg:loadTexture(paths.getImage(SCRIPT_PATH .. 'bgWalls'))
	bg:setGraphicSize(math.floor(bg.width * 0.8))
	bg:updateHitbox()
	bg:setScrollFactor(0.2, 0.2)
	self:add(bg)

	upperBopper = Sprite(-240, -90)
	upperBopper:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'upperBop'))
	upperBopper:addAnimByPrefix('bop', 'Upper Crowd Bob', 24, false)
	upperBopper:play('bop')
	upperBopper:setGraphicSize(math.floor(upperBopper.width * 0.85))
	upperBopper:updateHitbox()
	upperBopper:setScrollFactor(0.33, 0.33)
	self:add(upperBopper)

	local bgEscalator = Sprite(-1100, -600)
	bgEscalator:loadTexture(paths.getImage(SCRIPT_PATH .. 'bgEscalator'))
	bgEscalator:setGraphicSize(math.floor(bgEscalator.width * 0.9))
	bgEscalator:updateHitbox()
	bgEscalator:setScrollFactor(0.3, 0.3)
	self:add(bgEscalator)

	local tree = Sprite(370, -250)
	tree:loadTexture(paths.getImage(SCRIPT_PATH .. 'christmasTree'))
	tree:setScrollFactor(0.4, 0.4)
	self:add(tree)

	bottomBopper = Sprite(-300, 140)
	bottomBopper:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'bottomBop'))
	bottomBopper:addAnimByPrefix('bop', 'Bottom Level Boppers', 24, false)
	bottomBopper:play('bop')
	bottomBopper:setGraphicSize(math.floor(bottomBopper.width * 1))
	bottomBopper:updateHitbox()
	bottomBopper:setScrollFactor(0.9, 0.9)
	self:add(bottomBopper)

	local fgSnow = Sprite(-600, 700)
	fgSnow:loadTexture(paths.getImage(SCRIPT_PATH .. 'fgSnow'))
	self:add(fgSnow)

	santa = Sprite(-840, 150)
	santa:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'santa'))
	santa:addAnimByPrefix('idle', 'santa idle in fear', 24, false)
	santa:play('idle')
	self:add(santa)
end

function beat()
	upperBopper:play('bop', true)
	bottomBopper:play('bop', true)
	santa:play('idle')
end
