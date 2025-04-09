local SoundTray = {
	images = {
		bars = love.graphics.newImage(paths.getPath("images/soundtray/bars.png")),
		box = love.graphics.newImage(paths.getPath("images/soundtray/volumebox.png"))
	},

	sounds = {
		voldown = love.sound.newSoundData(paths.getPath("sounds/soundtray/voldown.ogg")),
		volup = love.sound.newSoundData(paths.getPath("sounds/soundtray/volup.ogg")),
		volmax = love.sound.newSoundData(paths.getPath("sounds/soundtray/volmax.ogg"))
	},

	game = {width = 0, height = 0}
}

local DEFAULT_VOLUME = 10
local prev = DEFAULT_VOLUME
local n = DEFAULT_VOLUME

function SoundTray.init(width, height)
	SoundTray.game.width = width
	SoundTray.game.height = height

	if game.save.data.gameVolume ~= nil then
		game.sound.setVolume(game.save.data.gameVolume / 10)
		prev = game.save.data.gameVolume
		n = game.save.data.gameVolume
	end

	return SoundTray
end

function SoundTray.new()
	local this = SoundTray

	this.visible = false
	this.silent = false
	this.canSpawn = false
	this.timer = 0

	this.box = {
		image = this.images.box,
		x = 0,
		y = 0,
		width = this.images.box:getWidth(),
		height = this.images.box:getHeight()
	}

	this.bars = {
		image = this.images.bars,
		x = 0,
		y = 0,
		width = this.images.bars:getWidth(),
		height = this.images.bars:getHeight()
	}

	this.throttles = {}
	this.throttles.up = Throttle:make({controls.down, controls, "volume_up"})
	this.throttles.down = Throttle:make({controls.down, controls, "volume_down"})

	this.adjust()

	return this
end

function SoundTray.adjust()
	local this = SoundTray

	this.box.x = (this.game.width - this.box.width) / 2
	this.bars.x = (this.game.width - this.bars.width) / 2
	this.bars.y = (this.box.y + (this.box.width - this.bars.width) / 2) - 11
end

function SoundTray.adjustVolume(amount)
	local this = SoundTray

	this.canSpawn = true
	this.timer = 0

	local newVolume = n + amount
	newVolume = math.max(0, math.min(10, newVolume))

	prev, n = n, newVolume
	local sound = amount > 0 and (prev == 10 and "volmax" or "volup") or "voldown"

	game.sound.setVolume(newVolume / 10)
	game.sound.setMute(newVolume == 0)

	if not this.silent then
		game.sound.play(SoundTray.sounds[sound], 1, false, false)
	end

	game.save.data.gameVolume = newVolume
end

function SoundTray.toggleMute()
	local this = SoundTray

	game.sound.setMute(not game.sound.__mute)
	if not game.sound.__mute then
		this.adjustVolume(prev > 0 and prev or 1)
	else
		this.adjustVolume(-n)
	end
end

function SoundTray:update(dt)
	local this = SoundTray

	if this.throttles.up:check() then this.adjustVolume(1) end
	if this.throttles.down:check() then this.adjustVolume(-1) end
	if controls:pressed("volume_mute") then this.toggleMute() end

	this.timer = this.timer + dt
	if this.timer >= 2 then this.canSpawn = false end

	if this.canSpawn then
		this.visible = true
		this.box.y = math.lerp(25, this.box.y, math.exp(-dt * 14))
	else
		this.box.y = math.lerp(-230, this.box.y, math.exp(-dt * 7))
		if this.box.y < -160 then this.visible = false end
	end

	this.adjust()
end

function SoundTray:fullscreen()
	SoundTray.resize(love.graphics.getDimensions())
end

function SoundTray:resize(width, height)
	local this = SoundTray

	this.game.width = width
	this.game.height = height
	this.adjust()
end

function SoundTray:__render()
	local this = SoundTray

	if this.visible then
		local lg = love.graphics
		local state = Object.saveDrawState()
		lg.setColor(1, 1, 1, 1)
		lg.draw(this.box.image, this.box.x, this.box.y)

		lg.setColor(1, 1, 1, 0.4)
		lg.draw(this.bars.image, this.bars.x, this.bars.y)

		lg.setColor(1, 1, 1, 1)
		lg.stencil(function()
			local width = n * 20
			lg.rectangle("fill", this.bars.x, this.bars.y, width, this.bars.height)
		end, "replace", 1)
		lg.setStencilTest("greater", 0)
		lg.draw(this.bars.image, this.bars.x, this.bars.y)

		lg.setStencilTest()
		Object.loadDrawState(state)
	end
end

return SoundTray
