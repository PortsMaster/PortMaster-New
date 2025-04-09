local ClientPrefs = {}

ClientPrefs.data = {
	-- controls
	asyncInput = false,

	-- gameplay
	autoPause = true,
	downScroll = false,
	middleScroll = false,
	ghostTap = true,
	noteSplash = true,
	backgroundDim = 0,
	flashingLights = true,
	botplayMode = false,
	playback = 1,
	gameOverInfos = true,

	-- audio
	pauseMusic = "railways",
	hitSound = 0,
	songOffset = 0,
	menuMusicVolume = 80,
	musicVolume = 100,
	vocalVolume = 100,
	sfxVolume = 80,

	-- display
	fps = 0,
	antialiasing = true,
	lowQuality = false,
	shader = true,
	fullscreen = false,
	resolution = 1,
	toastPrints = false,

	-- stats
	showFps = false,
	showRender = false,
	showMemory = false,
	showDraws = false,
}

ClientPrefs.controls = {
	note_left = {"key:y", "key:left"},
	note_down = {"key:b", "key:down"},
	note_up = {"key:x", "key:up"},
	note_right = {"key:a", "key:right"},

	ui_left = {"key:left"},
	ui_down = {"key:down"},
	ui_up = {"key:up"},
	ui_right = {"key:right"},

	volume_down = {"key:-", "key:kp-"},
	volume_up = {"key:+", "key:kp+", "key:="},
	volume_mute = {"key:0", "key:kp0"},

	reset = {"key:r"},
	accept = {"key:a", "key:space", "key:return"},
	back = {"key:b", "key:backspace", "key:escape"},
	pause = {"key:p", "key:return", "key:escape"},

	fullscreen = {"key:f11"},
	pick_mods = {"key:tab"},

	debug_1 = {"key:7"},
	debug_2 = {"key:6"},
}

function ClientPrefs.saveData()
	ClientPrefs.data.fullscreen = love.window.getFullscreen()

	game.save.data.prefs = ClientPrefs.data
	game.save.data.controls = ClientPrefs.controls

	game.save.bind("funkin")
end

-- load save on start
game.save.init("funkin")
pcall(table.merge, ClientPrefs.data, game.save.data.prefs)
pcall(table.merge, ClientPrefs.controls, game.save.data.controls)

return ClientPrefs
