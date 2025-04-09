dofile("config/default.lua") 	   --game config init

require("lang_changer")
LangChanger.LoadLanguage()

--dofile("scripts/utils/utils.lua")
require("routines")
require("iichantra-game")
mapvars = {}
stat = {}
vars = {}
difficulty = 1

if not LoadFont("Font.fif", "default") then
	LoadFont("Courier New", 14, 400, "default");
end

if not LoadFont("font-dialogue.fif", "dialogue") then
	LoadFont("Courier New", 14, 400, "dialogue");
end

name_of_script = 'init'
Loader = require('loader')
Loader.start()
