sprites = {

-- Player

	["player-flying"] = {
		fps = 14,
	},
	["player-crashed"] = {
	},
	["player-idle"] = {
		frames = {
			{}, --back
			{ "player-flying-middle-01", }, --middle
			{}, --front
		}
	},

-- NPC Woman

	["npc-woman-walk-right"] = {
		fps = 12,
	},
	["npc-woman-walk-left"] = {
		fps = 12,
	},
	["npc-woman-swimming-right"] = {
		fps = 8,
	},
	["npc-woman-swimming-idle"] = {
		fps = 8,
	},
	["npc-woman-swimming-left"] = {
		fps = 8,
	},
	["npc-woman-falling"] = {
		fps = 8,
	},
	["npc-woman-idle"] = {
		fps = 4,
		delays = { 0, 2000 },
	},

-- NPC Grandpa

	["npc-grandpa-walk-right"] = {
		fps = 12,
	},
	["npc-grandpa-walk-left"] = {
		fps = 12,
	},
	["npc-grandpa-swimming-idle"] = {
		fps = 8,
	},
	["npc-grandpa-swimming-right"] = {
		fps = 8,
	},
	["npc-grandpa-swimming-left"] = {
		fps = 8,
	},
	["npc-grandpa-falling"] = {
		fps = 8,
	},
	["npc-grandpa-idle"] = {
		fps = 4,
		delays = { 0, 2000 },
	},

-- NPC Man

	["npc-man-walk-right"] = {
		fps = 12,
	},
	["npc-man-walk-left"] = {
		fps = 12,
	},
	["npc-man-swimming-idle"] = {
		fps = 8,
	},
	["npc-man-swimming-right"] = {
		fps = 8,
	},
	["npc-man-swimming-left"] = {
		fps = 8,
	},
	["npc-man-falling"] = {
		fps = 8,
	},
	["npc-man-idle"] = {
		fps = 4,
	},

-- NPC Flying

	["npc-flying-flying-left" ] = {
		fps = 6,
	},
	["npc-flying-flying-right"] = {
		fps = 6,
	},
	["npc-flying-falling-left"] = {
		fps = 6,
	},
	["npc-flying-falling-right"] = {
		fps = 6,
	},

-- NPC Fish

	["npc-fish-swimming-left" ] = {
		fps = 28,
	},

	["npc-fish-swimming-right" ] = {
		fps = 28,
	},

	["npc-fish-idle-right"] = {
		frames = {
			{}, --back
			{}, --middle
			{ "npc-fish-swimming-right-front-01", }, --front
		},
	},

	["npc-fish-idle-left"] = {
		frames = {
			{}, --back
			{}, --middle
			{ "npc-fish-swimming-left-front-01", }, --front
		},
	},

-- NPC Walking

	["npc-walking-idle-right"] = {
		fps = 3,
		delays = { 0, 150, 0, 50, 900 },
	},
	["npc-walking-idle-left"] = {
		fps = 3,
		delays = { 0, 150, 0, 50, 900 },
	},
	["npc-walking-walk-left"] = {
		fps = 8,
	},
	["npc-walking-walk-right"] = {
		fps = 8,
	},
	["npc-walking-turn-left"] = {
		fps = 8,
	},
	["npc-walking-turn-right"] = {
		fps = 8,
	},
	["npc-walking-attack-init-left"] = {
		fps = 6,
	},
	["npc-walking-attack-init-right"] = {
		fps = 6,
	},
	["npc-walking-attack-left"] = {
		fps = 8,
	},
	["npc-walking-attack-right"] = {
		fps = 8,
	},
	["npc-walking-dazed-left"] = {
		fps = 8,
	},
	["npc-walking-dazed-right"] = {
		fps = 8,
	},
	["npc-walking-wakeup-left"] = {
		fps = 8,
	},
	["npc-walking-wakeup-right"] = {
		fps = 8,
	},
	["npc-walking-knockout-left"] = {
		fps = 8,
	},
	["npc-walking-knockout-right"] = {
		fps = 8,
	},

-- NPC Mammut

	["npc-mammut-idle-right"] = {
		fps = 4,
	},
	["npc-mammut-idle-left"] = {
		fps = 4,
	},
	["npc-mammut-walk-left"] = {
		fps = 8,
	},
	["npc-mammut-walk-right"] = {
		fps = 8,
	},
	["npc-mammut-turn-left"] = {
		fps = 8,
	},
	["npc-mammut-turn-right"] = {
		fps = 8,
	},
	["npc-mammut-attack-init-left"] = {
		fps = 6,
	},
	["npc-mammut-attack-init-right"] = {
		fps = 6,
	},
	["npc-mammut-attack-left"] = {
		fps = 8,
	},
	["npc-mammut-attack-right"] = {
		fps = 8,
	},
	["npc-mammut-dazed-left"] = {
		fps = 8,
	},
	["npc-mammut-dazed-right"] = {
		fps = 8,
	},
	["npc-mammut-wakeup-left"] = {
		fps = 8,
	},
	["npc-mammut-wakeup-right"] = {
		fps = 8,
	},
	["npc-mammut-knockout-left"] = {
		fps = 8,
	},
	["npc-mammut-knockout-right"] = {
		fps = 8,
	},

-- NPC Blowing

	["npc-blowing-idle-right"] = {
		fps = 4,
		delays = { 100, 50, 2000, 50 },
		active = { true, true, false, true },
	},
	["npc-blowing-idle-left"] = {
		fps = 4,
		delays = { 100, 50, 2000, 50 },
		active = { true, true, false, true },
	},
	["npc-blowing-dazed-left"] = {
		fps = 8,
	},
	["npc-blowing-dazed-right"] = {
		fps = 8,
	},
	["npc-blowing-wakeup-left"] = {
		fps = 8,
	},
	["npc-blowing-wakeup-right"] = {
		fps = 8,
	},
	["npc-blowing-knockout-left"] = {
		fps = 8,
	},
	["npc-blowing-knockout-right"] = {
		fps = 8,
	},

-- NPC Breeding

	["npc-breeding-idle-right"] = {
		fps = 4,
		delays = { 100, 50, 2000, 50 },
	},

	["npc-breeding-idle-left"] = {
		fps = 4,
		delays = { 100, 50, 2000, 50 },
	},

	["npc-breeding-dazed-right"] = {},

	["npc-breeding-dazed-left"] = {},

-- Items

	["item-apple-idle"] = {
		rotateable = 1,
		circles = {
			{ "", 0.0, 0.0, 18 },
		},
	},
	["item-banana-idle"] = {
		rotateable = 1,
		polygons = {
			{
				"", -0.855, -1.04, -19.8, 0.238, -10.4, -13.5, 6.36, -18.1
			},
			{
				"", 6.36, -18.1, 18.0, -6.27, 7.79, 16.6, -0.855, -1.04
			},
		},
	},
	["item-egg-idle"] = {
		rotateable = 1,
		polygons = {
			{
				"", -5.7, 20.9, -12.7, 14.2, -17.7, 0.177, -15.7, -12.0,
				-4.65, -20.6, 5.99, -20.6
			},
			{
				"", 5.99, -20.6, 16.0, -11.4, 17.4, 0.095, 12.5, 14.0,
				5.51, 20.9, -5.7, 20.9
			},
		},
	},
	["item-stone-idle"] = {
		fps = 4,
		delays = { 2000, },
		rotateable = 1,
		polygons = {
			{
				"", -27.259142, -18.241735, 31.334618, -18.24175, 36.022114, -2.6317247,
				24.498684, 16.740117, 8.483055, 26.471363, -27.845085, 8.343251,
				-34.876324, -6.925499,
			},
		},
	},
	["item-bomb-idle"] = {
		rotateable = 1,
		circles = {
			{ "", 0, -25, 23 },
		},
	},
	["item-bomb-explode"] = {},
	["item-package-ice-idle"] = {
		rotateable = 1,
		theme = "ice",
	},
	["item-package-idle"] = {
		rotateable = 1,
		theme = "rock",
	},

-- Tree

	["tree-idle"] = {
		fps = 5,
		maptile = true,
		delays = { 2000, },
	},

	["tree-dazed"] = {
	},

-- Ice Tiles

	["tile-background-ice-01"] = { type = "background", theme = "ice", },
	["tile-background-ice-02"] = { type = "background", theme = "ice", },
	["tile-background-ice-03"] = { type = "background", theme = "ice", },
	["tile-background-ice-04"] = { type = "background", theme = "ice", },
	["tile-background-ice-05"] = { type = "background", theme = "ice", },
	["tile-background-ice-06"] = { type = "background", theme = "ice", },
	["tile-background-ice-07"] = { type = "background", theme = "ice", },
	["tile-background-ice-08"] = { type = "background", theme = "ice", },
	["tile-background-ice-cave-art-01"] = { type = "background", theme = "ice", },
	["tile-background-ice-cave-art-02"] = { type = "background", theme = "ice", },
	["tile-background-ice-big-01"] = { type = "background", width = 2, height = 2, theme = "ice", },
	["tile-background-ice-window-01"] = {
		type = "window",
		theme = "ice",
		frames = {
			{ "tile-background-ice-window-01-on", "tile-background-ice-window-01-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},
	["tile-background-ice-window-02"] = {
		type = "window",
		theme = "ice",
		frames = {
			{ "tile-background-ice-window-02-on", "tile-background-ice-window-02-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},

	["tile-cave-ice-01"] = {
		type = "cave",
		theme = "ice",
		frames = {
			{ "tile-cave-ice-01-on", "tile-cave-ice-01-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},
	["tile-cave-ice-02"] = {
		type = "cave",
		theme = "ice",
		frames = {
			{ "tile-cave-ice-02-on", "tile-cave-ice-02-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},

	["tile-ground-ice-01"] = { type = "ground", theme = "ice", },
	["tile-ground-ice-02"] = { type = "ground", theme = "ice", },
	["tile-ground-ice-03"] = { type = "ground", theme = "ice", },
	["tile-ground-ice-04"] = { type = "ground", theme = "ice", },
	["tile-ground-ice-05"] = {
		type = "ground",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, 50, 50, 50, 20, -50, 20,
			},
		},
	},
	["tile-ground-ice-06"] = { type = "ground", theme = "ice", },
	["tile-ground-ice-big-01"] = { type = "ground", width = 2, height = 2, theme = "ice", },
	["tile-lava-ice-left-01"] = {
		type = "lava",
		theme = "ice",
		fps = 2,
		polygons = {
			{
				"solid", -50, 0, 50, 0, 50, -50, -50, -50,
			},
			{
				"lava", -50, 40, 50, 40, 50, 0, -50, 0,
			},
		},
	},
	["tile-lava-ice-left-02"] = { type = "lava", theme = "ice", fps = 2, },
	["tile-lava-ice-right-01"] = {
		type = "lava",
		theme = "ice",
		fps = 2,
		polygons = {
			{
				"solid", -50, 0, 50, 0, 50, -50, -50, -50,
			},
			{
				"lava", -50, 40, 50, 40, 50, 0, -50, 0,
			},
		},
	},
	["tile-lava-ice-right-02"] = { type = "lava", theme = "ice", fps = 2, },
	["tile-ground-ledge-ice-right-01"] = {
		type = "ground-right",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, -20, 50, 0, 50, 50,
			},
		},
	},
	["tile-ground-ledge-ice-right-02"] = {
		type = "ground-right",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, 20, 50, 50,
			},
		},
	},
	["tile-ground-ledge-ice-left-01"] = {
		type = "ground-left",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, -20, 50, 50,
			},
		},
	},
	["tile-ground-ledge-ice-left-02"] = {
		type = "ground-right",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 0, 50, 50,
			},
		},
	},

	["tile-waterfall-ice-01"] = {
		type = "waterfall",
		theme = "ice",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		height = 2,
	},

	["tile-packagetarget-ice-01-rotate"] = {
		type = "packagetarget-ice",
		theme = "ice",
		rotateable = 90,
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-packagetarget-ice-01-active"] = {
		type = "packagetarget-ice",
		theme = "ice",
		rotateable = 90,
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-packagetarget-ice-01-idle"] = {
		type = "packagetarget-ice",
		theme = "ice",
		rotateable = 90,
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-geyser-ice-01-idle"] = {
		fps = 4,
		type = "geyser-ice",
		theme = "ice",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		height = 2,
	},

	["tile-geyser-ice-01-active"] = {
		fps = 8,
		type = "geyser-ice",
		theme = "ice",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		height = 2,
	},

	["tile-rock-ice-01"] = { type = "rock", theme = "ice", },
	["tile-rock-ice-02"] = { type = "rock", theme = "ice", },
	["tile-rock-ice-03"] = { type = "rock", theme = "ice", },
	["tile-rock-ice-left-04"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, -50, -10, -50, 0, 50,
			},
		},
	},
	["tile-rock-ice-right-04"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", 0, 50, 50, 50, 50, -50, 10, -50,
			},
		},
	},
	["tile-rock-ice-left-05"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, -50, 0, -50, -10, 50,
			},
		},
	},
	["tile-rock-ice-right-05"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", 10, 50, 50, 50, 50, -50, 0, -50,
			},
		},
	},
	["tile-rock-ice-big-01"] = { type = "rock", width = 2, height = 2, theme = "ice", },
	["tile-rock-slope-ice-right-01"] = {
		type = "slope-right",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, 50, -50, -50, -50,
			},
		},
		friction = 0.01,
	},
	["tile-rock-slope-ice-left-01"] = {
		type = "slope-left",
		theme = "ice",
		polygons = {
			{
				"", 50, 50, 50, -50, -50, -50,
			},
		},
		friction = 0.01,
	},
	["tile-rock-slope-ice-right-02"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", -50, -50, 50, 50, -50, 50,
			},
		},
	},
	["tile-rock-slope-ice-left-02"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", 50, -50, 50, 50, -50, 50,
			},
		},
	},
	["tile-rock-shim-ice-01"] = {
		type = "rock",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, 0, 0, 50, 50,
			},
		},
	},

-- Ice Bridge

	["bridge-wall-ice-left-01"] = {
		type = "bridge-left",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, 20, 50, 50,
			},
		},
	},
	["bridge-plank-ice-01"] = {
		type = "bridge-plank",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 20, 50, 50,
			},
		},
	},
	["bridge-wall-ice-right-01"] = {
		type = "bridge-right",
		theme = "ice",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 0, 50, 50,
			},
		},
	},

-- Rock Tiles

	["tile-background-01"] = { type = "background", theme = "rock", },
	["tile-background-02"] = { type = "background", theme = "rock", },
	["tile-background-03"] = { type = "background", theme = "rock", },
	["tile-background-04"] = { type = "background", theme = "rock", },
	["tile-background-cave-art-01"] = { type = "background", theme = "rock", },
	["tile-background-big-01"] = { type = "background", width = 2, height = 2, theme = "rock", },
	["tile-background-window-01"] = {
		type = "window",
		theme = "rock",
		frames = {
			{ "tile-background-window-01-on", "tile-background-window-01-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},
	["tile-background-window-02"] = {
		type = "window",
		theme = "rock",
		frames = {
			{ "tile-background-window-02-on", "tile-background-window-02-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},

	["tile-cave-01"] = {
		type = "cave",
		theme = "rock",
		frames = {
			{ "tile-cave-01-on", "tile-cave-01-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},
	["tile-cave-02"] = {
		type = "cave",
		theme = "rock",
		frames = {
			{ "tile-cave-02-on", "tile-cave-02-off", }, --back
			{}, --middle
			{}, --front
		},
		fps = 0,
	},

	["tile-ground-01"] = { type = "ground", theme = "rock", },
	["tile-ground-02"] = { type = "ground", theme = "rock", },
	["tile-ground-03"] = { type = "ground", theme = "rock", },
	["tile-ground-04"] = { type = "ground", theme = "rock", },
	["tile-ground-05"] = {
		type = "ground",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, 50, 50, 50, 20, -50, 20,
			},
		},
	},
	["tile-ground-06"] = {
		type = "ground",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, 50, 50, 50, 20, -50, 20,
			},
		},
	},

	["tile-ground-ledge-right-01"] = {
		type = "ground-right",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, -20, 50, 0, 50, 50,
			},
		},
	},
	["tile-ground-ledge-right-02"] = {
		type = "ground-right",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, 20, 50, 50,
			},
		},
	},
	["tile-ground-ledge-left-01"] = {
		type = "ground-left",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, -20, 50, 50,
			},
		},
	},
	["tile-ground-ledge-left-02"] = {
		type = "ground-right",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 0, 50, 50,
			},
		},
	},
	["tile-rock-shim-01"] = {
		type = "rock",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, 0, 0, 50, 50,
			},
		},
	},

	["tile-waterfall-01"] = {
		type = "waterfall",
		theme = "rock",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		fps = 6,
		height = 2,
	},

	["tile-rock-01"] = { type = "rock", theme = "rock", },
	["tile-rock-02"] = { type = "rock", theme = "rock", },
	["tile-rock-03"] = { type = "rock", theme = "rock", },
	["tile-rock-left-04"] = {
		type = "rock",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -10, 50, 0, -10, 0, -50, -50, -50
			},
		},
	},
	["tile-rock-right-04"] = {
		type = "rock",
		theme = "rock",
		polygons = {
			{
				"", 50, 50, 10, 50, 0, -10, 0, -50, 50, -50
			},
		},
	},
	["tile-rock-big-01"] = { type = "rock", width = 2, height = 2, theme = "rock", },
	["tile-lava-rock-left-01"] = {
		type = "lava",
		theme = "rock",
		fps = 2,
		polygons = {
			{
				"solid", -50, 0, 50, 0, 50, -50, -50, -50,
			},
			{
				"lava", -50, 40, 50, 40, 50, 0, -50, 0,
			},
		},
	},
	["tile-lava-rock-right-01"] = {
		type = "lava",
		theme = "rock",
		fps = 2,
		polygons = {
			{
				"solid", -50, 0, 50, 0, 50, -50, -50, -50,
			},
			{
				"lava", -50, 40, 50, 40, 50, 0, -50, 0,
			},
		},
	},
	["tile-rock-slope-right-01"] = {
		type = "slope-right",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, 50, -50, -50, -50,
			},
		},
		friction = 0.1,
	},
	["tile-rock-slope-left-01"] = {
		type = "slope-left",
		theme = "rock",
		polygons = {
			{
				"", 50, 50, 50, -50, -50, -50,
			},
		},
		friction = 0.1,
	},
	["tile-rock-slope-right-02"] = {
		type = "rock",
		theme = "rock",
		polygons = {
			{
				"", -50, -50, 50, 50, -50, 50,
			},
		},
	},
	["tile-rock-slope-left-02"] = {
		type = "rock",
		theme = "rock",
		polygons = {
			{
				"", 50, -50, 50, 50, -50, 50,
			},
		},
	},
	["tile-packagetarget-rock-01-rotate"] = {
		type = "packagetarget-rock",
		rotateable = 90,
		theme = "rock",
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-packagetarget-rock-01-active"] = {
		type = "packagetarget-rock",
		rotateable = 90,
		theme = "rock",
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-packagetarget-rock-01-idle"] = {
		type = "packagetarget-rock",
		rotateable = 90,
		theme = "rock",
		polygons = {
			{
				"top", -40, 35, -40, 40, 40, 40, 40, 35,
			},
			{
				"body1", -50, -50, 50, -50, 50, 34, -50, 34,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallleft", -50, 40, -30, 40, -50, 50,
			},
			{
				-- winding order: lower left, lower right, upper left
				"smallright", 30, 40, 50, 40, 50, 50
			},
		},
	},

	["tile-geyser-rock-01-idle"] = {
		fps = 6,
		type = "geyser-rock",
		theme = "rock",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		height = 2,
	},

	["tile-geyser-rock-01-active"] = {
		fps = 8,
		type = "geyser-rock",
		theme = "rock",
		polygons = {
			{
				"", -50, 0, 50, 0, 50, -100, -50, -100,
			},
		},
		height = 2,
	},

-- Rock Bridge

	["bridge-wall-left-01"] = {
		type = "bridge-left",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 0, 50, 20, 50, 50,
			},
		},
	},
	["bridge-plank-01"] = {
		type = "bridge-plank",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 20, 50, 50,
			},
		},
	},
	["bridge-wall-right-01"] = {
		type = "bridge-right",
		theme = "rock",
		polygons = {
			{
				"", -50, 50, -50, 20, 50, 0, 50, 50,
			},
		},
	},

-- Various

	["liane-01"] = {
		rotateable = 1,
		type = "liane",
		theme = "rock",
		width = 0.25,
		height = 2,
	},
	["cave-sign-01"] = { type = "cave-sign", },
	["cave-sign-02"] = { type = "cave-sign", },
	["cave-sign-03"] = { type = "cave-sign", },
	["cave-sign-04"] = { type = "cave-sign", },
	["cave-sign-05"] = { type = "cave-sign", },
	["cave-sign-06"] = { type = "cave-sign", },
	["cave-sign-07"] = { type = "cave-sign", },
	["cave-sign-08"] = { type = "cave-sign", },
	["cavenumber1"] = {},
	["cavenumber2"] = {},
	["cavenumber3"] = {},
	["cavenumber4"] = {},
	["cavenumber5"] = {},
	["cavenumber6"] = {},
	["cavenumber7"] = {},
	["cavenumber8"] = {},

-- UI sprites

	["ui-player"] = {
		fps = 10,
	},
	["ui-npc-grandpa"] = {
		fps = 8,
	},
	["ui-npc-mammut"] = {
		fps = 11,
	},
	["icon-heart"] = {},
}
