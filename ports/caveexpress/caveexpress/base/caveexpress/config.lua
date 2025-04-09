function isMobile()
	return (isAndroid() or isIOS()) and not isOUYA();
end

defaultwidth = -1
defaultheight = -1
defaultfullscreen = true
defaultpersister = "sqlite"
defaultfrontend = "sdl"
defaultsoundengine = "sdl"
defaultnetwork = true
defaultshowcursor = true
defaultgamecontroller = true
defaulttexturesize = "auto"
defaultreferencetimefactor = 1.0
defaultdamagethreshold = 3.0
defaultnpcflyingspeed = 2.0
defaultparticles = 100
defaultred = 8
defaultgreen = 8
defaultblue = 8

if isOUYA() then
	defaultgamecontroller = true
	defaultreferencetimefactor = 1.3
	defaultdamagethreshold = 5.0
	defaultparticles = 0
	defaultred = 6
	defaultgreen = 5
	defaultblue = 6
elseif isSteamLink() then
	defaultwidth = 1280
	defaultheight = 720
	defaultgamecontroller = true
	defaultparticles = 0
	defaultnetwork = true
	defaultshowcursor = false
elseif isAndroid() then
	defaultpersister = "googleplay"
	defaultreferencetimefactor = 1.5
	defaultshowcursor = false
	defaultnetwork = true
	defaultdamagethreshold = 5.0
	defaultparticles = 50
	defaultred = 6
	defaultgreen = 5
	defaultblue = 6
elseif isMobile() then
	defaultreferencetimefactor = 1.5
	defaultshowcursor = false
	defaultnetwork = true
	defaultdamagethreshold = 5.0
	defaultparticles = 0
elseif isHTML5() then
	defaultfrontend = "opengl"
	defaultsoundengine = "dummy"
	defaultnetwork = false
elseif isNaCl() then
	defaultpersister = "nop"
	defaultnetwork = false
else
	defaultgamecontroller = true
	defaultfrontend = "opengl3"
end

settings = {
	width = defaultwidth,
	height = defaultheight,
	fullscreen = defaultfullscreen,
	frontend = defaultfrontend,
	port = 45678,
	grabmouse = true,
	showcursor = defaultshowcursor,
	debug = false,
	showfps = false,
	gamecontroller = defaultgamecontroller,
	gamecontrollertriggeraxis = false,
	sound = true,
	soundengine = defaultsoundengine,
	persister = defaultpersister,
	network = defaultnetwork,
	texturesize = defaulttexturesize,
	referencetimefactor = defaultreferencetimefactor,
	damagethreshold = defaultdamagethreshold,
	fruitcollectdelayforanewlife = 15000,
	amountoffruitsforanewlife = 4,
	fruithitpoints = 10,
	waterparticle = false,
	npcflyingspeed = defaultnpcflyingspeed,
	particles = defaultparticles,
	red = defaultred,
	green = defaultgreen,
	blue = defaultblue,
}

controllerbindings = {
	["ui"] = {
		A = "ui_execute",
		B = "ui_pop",
		--X = "ui_pop",
		--Y = "ui_pop",
		BACK = "ui_pop",
		--GUIDE = "",
		--START = "",
		--LEFTSTICK = "",
		--RIGHTSTICK = "",
		--LEFTSHOULDER = "",
		--RIGHTSHOULDER = "",
		DPUP = "ui_focus_prev",
		DPDOWN = "ui_focus_next",
		DPLEFT = "ui_focus_prev",
		DPRIGHT = "ui_focus_next",
	},
	["map"] = {
		A = "drop",
		B = "drop",
		--X = "ui_pop",
		--Y = "ui_pop",
		BACK = "ui_pop",
		--GUIDE = "",
		START = "ui_pop",
		LEFTSTICK = "+move_left",
		RIGHTSTICK = "+move_right",
		LEFTSHOULDER = "+zoom 0.1",
		RIGHTSHOULDER = "+zoom -0.1",
		DPUP = "+move_up",
		DPDOWN = "+move_down",
		DPLEFT = "+move_left",
		DPRIGHT = "+move_right",
	},
}

if isMobile() or isOUYA() then
	keybindings = {
		["ui"] = {
			AC_BACK = "ui_pop",
		},
		["map"] = {
			--MENU = "ui_push settings",
			AC_BACK = "ui_pop",
		},
	}

	if isOUYA() then
		keybindings["ui"]["PAUSE"] = "ui_pop"
		keybindings["map"]["PAUSE"] = "ui_pop"
	end
else
	keybindings = {
		["ui"] = {
			LEFT = "ui_focus_prev",
			RIGHT = "ui_focus_next",
			UP = "ui_focus_prev +",
			DOWN = "ui_focus_next -",
			A = "ui_focus_prev",
			D = "ui_focus_next",
			W = "ui_focus_prev +",
			S = "ui_focus_next -",
			SPACE = "ui_execute",
			RETURN = "ui_execute",
			ESCAPE = "ui_pop",
			TAB = "ui_focus_next",
		},
		["map"] = {
			LEFT = "+move_left",
			RIGHT = "+move_right",
			UP = "+move_up",
			DOWN = "+move_down",
			A = "+move_left",
			D = "+move_right",
			W = "+move_up",
			S = "+move_down",
			SPACE = "drop",
			RETURN = "drop",
			ESCAPE = "ui_pop",
			TAB = "ui_focus_next",
			PAGEDOWN = "zoom -0.1",
			PAGEUP = "zoom 0.1",
		},
	}
end

if isDebug() then
	keybindings["ui"]["."] = "screenshot"
	keybindings["map"]["."] = "screenshot"
	keybindings["map"]["BACKSPACE"] = "map_debug"
	keybindings["map"]["E"] = "map_open_in_editor"
	keybindings["map"]["X"] = "kill"
	keybindings["map"]["F"] = "finish"
end

if isMobile() and isDebug() then
	keybindings["map"]["VOLUMEUP"] = "map_debug"
end
