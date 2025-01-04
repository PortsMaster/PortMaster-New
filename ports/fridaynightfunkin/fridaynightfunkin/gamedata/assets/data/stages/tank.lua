local tankWatchtower
local tankGround
local tankAngle = love.math.random(-90, 45)
local tankSpeed = love.math.random(5, 7)

local tankmanRun
local fgSprites

function create()
	self.camZoom = 0.9

	self.boyfriendPos = {x = 810, y = 100}
	self.gfPos = {x = 200, y = 65}
	self.dadPos = {x = 20, y = 100}

	local bg = Sprite(-400, -400)
	bg:loadTexture(paths.getImage(SCRIPT_PATH .. 'tankSky'))
	bg:setScrollFactor()
	self:add(bg)

	local tankMountains = Sprite(-300, -20)
	tankMountains:loadTexture(paths.getImage(SCRIPT_PATH .. 'tankMountains'))
	tankMountains:setScrollFactor(0.2, 0.2)
	tankMountains:setGraphicSize(math.floor(tankMountains.width * 1.2))
	tankMountains:updateHitbox()
	self:add(tankMountains)

	local tankBuildings = Sprite(-200, 0)
	tankBuildings:loadTexture(paths.getImage(SCRIPT_PATH .. 'tankBuildings'))
	tankBuildings:setScrollFactor(0.3, 0.3)
	tankBuildings:setGraphicSize(math.floor(tankBuildings.width * 1.1))
	tankBuildings:updateHitbox()
	self:add(tankBuildings)

	local tankRuins = Sprite(-200, 0)
	tankRuins:loadTexture(paths.getImage(SCRIPT_PATH .. 'tankRuins'))
	tankRuins:setScrollFactor(0.35, 0.35)
	tankRuins:setGraphicSize(math.floor(tankRuins.width * 1.1))
	tankRuins:updateHitbox()
	self:add(tankRuins)

	local smokeLeft = Sprite(-200, -100)
	smokeLeft:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'smokeLeft'))
	smokeLeft:setScrollFactor(0.4, 0.4)
	smokeLeft:addAnimByPrefix('SmokeBlurLeft', 'SmokeBlurLeft', 24, true)
	smokeLeft:play('SmokeBlurLeft')
	self:add(smokeLeft)

	local smokeRight = Sprite(1100, -100)
	smokeRight:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'smokeRight'))
	smokeRight:setScrollFactor(0.4, 0.4)
	smokeRight:addAnimByPrefix('SmokeRight', 'SmokeRight', 24, true)
	smokeRight:play('SmokeRight')
	self:add(smokeRight)

	tankWatchtower = Sprite(100, 50)
	tankWatchtower:setFrames(paths.getSparrowAtlas(SCRIPT_PATH ..
		'tankWatchtower'))
	tankWatchtower:setScrollFactor(0.5, 0.5)
	tankWatchtower:addAnimByPrefix('watchtower gradient color',
		'watchtower gradient color', 24, false)
	tankWatchtower:play('watchtower gradient color', true)
	self:add(tankWatchtower)

	tankGround = Sprite(300, 300)
	tankGround:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tankRolling'))
	tankGround:setScrollFactor(0.5, 0.5)
	tankGround:addAnimByPrefix('BG tank w lighting', 'BG tank w lighting', 24,
		true)
	tankGround:play('BG tank w lighting', true)
	self:add(tankGround)

	tankmanRun = Group()
	self:add(tankmanRun)

	fgSprites = Group()
	self:add(fgSprites, true)

	local tankGround = Sprite(-420, -150)
	tankGround:loadTexture(paths.getImage(SCRIPT_PATH .. 'tankGround'))
	tankGround:setGraphicSize(math.floor(tankGround.width * 1.15))
	tankGround:updateHitbox()
	self:add(tankGround)

	local fgTank0 = Sprite(-500, 650)
	fgTank0:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank0'))
	fgTank0:setScrollFactor(1.7, 1.5)
	fgTank0:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank0:play('fg', true)
	fgSprites:add(fgTank0)

	local fgTank1 = Sprite(-300, 750)
	fgTank1:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank1'))
	fgTank1:setScrollFactor(2, 0.2)
	fgTank1:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank1:play('fg', true)
	fgSprites:add(fgTank1)

	local fgTank2 = Sprite(450, 940)
	fgTank2:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank2'))
	fgTank2:setScrollFactor(1.5, 1.5)
	fgTank2:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank2:play('fg', true)
	fgSprites:add(fgTank2)

	local fgTank4 = Sprite(1300, 900)
	fgTank4:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank4'))
	fgTank4:setScrollFactor(1.5, 1.5)
	fgTank4:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank4:play('fg', true)
	fgSprites:add(fgTank4)

	local fgTank5 = Sprite(1620, 700)
	fgTank5:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank5'))
	fgTank5:setScrollFactor(1.5, 1.5)
	fgTank5:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank5:play('fg', true)
	fgSprites:add(fgTank5)

	local fgTank3 = Sprite(1300, 1200)
	fgTank3:setFrames(paths.getSparrowAtlas(SCRIPT_PATH .. 'tank3'))
	fgTank3:setScrollFactor(3.5, 2.5)
	fgTank3:addAnimByPrefix('fg', 'fg', 24, false)
	fgTank3:play('fg', true)
	fgSprites:add(fgTank3)
end

function postCreate()
	if state.gf.char == 'pico-speaker' then
		local tempTankman = TankmenBG(20, 500, true)
		tempTankman.time = 10
		tempTankman:resetShit(20, 600, true)
		tankmanRun:add(tempTankman)

		for i = 1, #TankmenBG.animationNotes do
			if love.math.randomBool(16) then
				local tankman = tankmanRun:recycle(TankmenBG)
				tankman.time = TankmenBG.animationNotes[i][1]
				tankman:resetShit(500, 200 + love.math.random(50, 100), TankmenBG.animationNotes[i][2] < 2)
			end
		end
	end
end

function update(dt)
	tankAngle = tankAngle + dt * tankSpeed
	tankGround.angle = tankAngle - 90 + 15

	tankGround.x = 400 + math.cos(math.rad(tankAngle + 180)) * 1500
	tankGround.y = 1300 + math.sin(math.rad(tankAngle + 180)) * 1100
end

function beat(b)
	tankWatchtower:play('watchtower gradient color', true)

	for _, fgTank in ipairs(fgSprites.members) do fgTank:play('fg', true) end
end

local gameOverSound
function gameOverStart()
	local tankmanLines = 'jeffGameover-' .. love.math.random(1, 25)
	gameOverSound = paths.getSound('gameplay/jeffGameover/' .. tankmanLines)
end

function postGameOverStartLoop()
	game.sound.music:setVolume(ClientPrefs.data.musicVolume / 100 * 0.2)
	util.playSfx(gameOverSound, 1, false, true, function()
		game.sound.music:fade(1, game.sound.music:getVolume(), ClientPrefs.data.musicVolume / 100)
	end)
end
