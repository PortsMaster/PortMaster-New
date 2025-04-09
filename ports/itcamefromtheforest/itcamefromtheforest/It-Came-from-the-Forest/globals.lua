settings = {
	version = "0.9.2",
	quickstart = false,
	debugmode = false,
	startingArea = "forest-1",
	inventoryX = 119,
	inventoryY = 50,
	inventorySlotsStartX = 251,
	inventorySlotsStartY = 57,
	prices = {
		antsacs = 30,
	},
	frameColor = {105/255,102/255,130/255,1},
	canContinue = nil,
	sliderColor = {0.7,0.7,0.7,1},
	savegameSlots = {
		[1] = nil,
		[2] = nil,
		[3] = nil,
	}
}

savedsettings = {
	musicVolume = 0.75,
	sfxVolume = 1,
	lastSavegameSlot = -1,
	fullScreen = true,
	skipIntro = false,
}

isFading = false
fadeColor = {0,0,0}
fadeMusicVolume = {v = savedsettings.musicVolume}
inventoryDragSource = {}
spawnTarget = {}
loadingSavedFile = false

color = {
	black = {0,0,0,1},
	white = {1,1,1,1},
}

GameStates = {
	INIT = 0,
	EXPLORING = 1,
	LOADING_LEVEL = 2,
	FATAL_ERROR = 3,
	MAIN_MENU = 4,
	BUILDUP1 = 5,
	BUILDUP2 = 6,
	BUILDUP3 = 7,
	BUILDUP4 = 8,
	CREDITS = 9,
	ABOUT = 10,
	SETTINGS = 11,
	QUITTING = 12,
	GAMEOVER = 13,
	VICTORY = 14,
	
}

SubStates = {
	IDLE = 0,
	AUTOMAPPER = 1,
	INVENTORY = 2,
	SELECT_SPELL = 3,
	POPUP = 4,
	NPC = 5,
	FOUND_LOOT = 6,
	VENDOR_ANTSACS = 7,
	SYSTEM_MENU = 8,
	VENDOR = 9,
	TAVERN = 10,
	DISK_IO = 11,
	TWEENING = 12
}

gameState = GameStates.LOADING_LEVEL

world_hitboxes = {}
world_hitboxes["door"] = {x = 225, y = 10, w = 230, h = 295}
world_hitboxes["npc"] = {x = 264, y = 72, w = 115, h = 215}
world_hitboxes["portal"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["chest"] = {x = 248, y = 199, w = 146, h = 99}
world_hitboxes["well"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["prop"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["button"] = {x = 352, y = 211, w = 12, h = 23}
world_hitboxes["levelexit"] = {x = 225, y = 10, w = 230, h = 295}

highlightshader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]

strings = {
	npc_texts = {
		"Have you ever seen such a beautiful night sky?",
		"Shh. Don't disturb me!\n\nI'm trying to listen for monsters nearby. Have you seen any?",
		"Hello stranger.",
		"Oh, you startled me.\n\nYou should know better than to sneak up on someone like that!",
		"I am not interested in whatever you are selling.\n\nYou best be on your way.",
		"Well, well. Aren't you a brave little warrior,\n\nAre you the one who is going to save us from evil? Ha!",
		"Hrmm, well.. Nevermind!",
	}
}


