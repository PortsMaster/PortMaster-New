local Splash = State:extend("Splash")
local UpdateState = require "funkin.states.update"

function Splash:enter()
	self.skipTransIn = true
	Splash.super.enter(self)

	if Project.splashScreen then
		Timer.after(1, function() self:startSplash() end)
	else
		self:finishSplash()
	end
end

function Splash:startSplash()
	self.funkinLogo = Sprite():loadTexture(
		paths.getImage('menus/splashscreen/FNFLOVE_logo'))
	self.funkinLogo.scale = {x = 0.7, y = 0.7}
	self.funkinLogo.visible = false
	self.funkinLogo:updateHitbox()
	self.funkinLogo:screenCenter()
	self:add(self.funkinLogo)

	-- TODO: fix icon centering
	self.stilicIcon = HealthIcon('stilic')
	self.stilicIcon.scale = {x = 1.8, y = 1.8}
	self.stilicIcon.visible = false
	self.stilicIcon:updateHitbox()
	self.stilicIcon:screenCenter()
	self:add(self.stilicIcon)

	self.poweredBy = Text(0, game.height * 0.9, 'Powered by ',
		paths.getFont('phantommuff.ttf', 24))
	self.poweredBy.visible = false
	self.poweredBy:screenCenter('x')
	self.poweredBy.x = self.poweredBy.x - 12
	self:add(self.poweredBy)

	self.love2d = Sprite(self.poweredBy.x + self.poweredBy:getWidth(), game.height * 0.885)
	self.love2d:loadTexture(paths.getImage('menus/splashscreen/love2d'))
	self.love2d.scale = {x = 0.17, y = 0.17}
	self.love2d.visible = false
	self:add(self.love2d)

	self.skipText = Text(6, game.height * 0.96, 'Press ACCEPT to skip.',
		paths.getFont('phantommuff.ttf', 24))
	self.skipText.alpha = 0
	self:add(self.skipText)

	game.sound.play(paths.getMusic('titleShoot'), 0.5)
	Timer.after(3, function() Timer.tween(0.5, self.skipText, {alpha = 1}) end)

	Timer.script(function(setTimer)
		self.funkinLogo.alpha = 0
		self.funkinLogo.visible = true
		Timer.tween(5, self.funkinLogo.scale, {x = 0.65, y = 0.65})
		Timer.tween(0.2, self.funkinLogo, {alpha = 1})

		setTimer(2)

		self.poweredBy.alpha = 0
		self.poweredBy.visible = true
		self.love2d.alpha = 0
		self.love2d.visible = true
		Timer.tween(0.5, self.poweredBy, {alpha = 1})
		Timer.tween(0.5, self.love2d, {alpha = 1})

		setTimer(2)

		self.funkinLogo.visible = true
		self.stilicIcon.alpha = 0
		self.stilicIcon.visible = true
		Timer.tween(1, self.funkinLogo, {alpha = 0})
		Timer.tween(6, self.stilicIcon.scale, {x = 1.5, y = 1.5})
		Timer.tween(1, self.stilicIcon, {alpha = 1})

		setTimer(2)

		Timer.tween(0.5, self.poweredBy, {alpha = 0})
		Timer.tween(0.5, self.love2d, {alpha = 0})

		setTimer(2)

		Timer.tween(1, self.stilicIcon, {alpha = 0})

		setTimer(1)

		self:finishSplash(false)
	end)

	if love.system.getDevice() == "Mobile" then
		self:add(VirtualPad("return", 0, 0, game.width, game.height, false))
	end
end

function Splash:finishSplash(skip)
	if UpdateState.check(true) then
		game.switchState(TitleState(), skip)
	end
end

function Splash:update(dt)
	Splash.super.update(self, dt)

	if controls:pressed("accept") then
		self:finishSplash(true)
	end
end

return Splash
