function isMobile()
	return (isAndroid() or isIOS()) and not isOUYA();
end

defaultwidth = -1
defaultheight = -1
defaultfullscreen = true
defaultpersister = "sqlite"
defaultfrontend = "sdl"
defaultsoundengine = "sdl"
defaultshowcursor = true
defaultnetwork = true
defaultgamecontroller = false
defaulttexturesize = "auto"
defaultparticles = 100
defaultfpslimit = 60
defaultred = 8
defaultgreen = 8
defaultblue = 8

if isOUYA() then
	defaultgamecontroller = true
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
	defaultshowcursor = false
	defaultparticles = 0
	defaultfpslimit = 30
	rendertotexture = 0
	defaultpersister = "googleplay"
	defaultred = 6
	defaultgreen = 5
	defaultblue = 6
elseif isIOS() then
	defaultshowcursor = false
	defaultparticles = 0
	defaultfpslimit = 30
	rendertotexture = 0
	defaultred = 6
	defaultgreen = 5
	defaultblue = 6
elseif isMobile() then
	defaultshowcursor = false
	defaultparticles = 0
	defaultfpslimit = 30
elseif isHTML5() then
	defaultnetwork = false
	defaultfrontend = "opengl"
	defaultsoundengine = "dummy"
elseif isNaCl() then
	defaultpersister = "nop"
	defaultnetwork = false
else
	defaultgamecontroller = true
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
	showfps = not isMobile(),
	gamecontroller = defaultgamecontroller,
	gamecontrollertriggeraxis = false,
	sound = true,
	soundengine = defaultsoundengine,
	persister = defaultpersister,
	network = defaultnetwork,
	fpslimit = defaultfpslimit,
	texturesize = defaulttexturesize,
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
		--A = "",
		--B = "",
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
			MENU = "ui_push settings",
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
			SPACE = "ui_pop",
			RETURN = "ui_pop",
			ESCAPE = "ui_pop",
			TAB = "ui_focus_next",
			PAGEDOWN = "zoom -0.1",
			PAGEUP = "zoom 0.1",
		},
	}

	keybindings["map"]["U"] = "undo"
	keybindings["map"]["BACKSPACE"] = "undo"
	keybindings["ui"]["."] = "screenshot"
	keybindings["map"]["."] = "screenshot"
	keybindings["map"]["S"] = "solve"

	if isDebug() then
		keybindings["map"]["F"] = "finish"
	end
end
