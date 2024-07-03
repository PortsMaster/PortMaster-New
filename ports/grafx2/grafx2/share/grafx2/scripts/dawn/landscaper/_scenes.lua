-- {45,60,{0,0,160},3}
-- 1. Azimuth (0 = Fr. Bottom, 90 = Fr. Right, -90 Fr. Left, 180 = Fr. Top, 135 = Isometric Right, 225/-135 = Isometric Top)
-- 2. Elevation (0 = top)


return function()

 local SCENES

SCENES = {


{ -- Basic

   TITLE = "Basic",
   _ACTIVE = true, -- Is Scene Active

-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 1.0,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {0,0,0},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{0, 25, {255,255,255}, 3.0}},
-- {0,0,24},{{0, 25, {255,240,208}, 3.0}}

-- Perlin ------------------------------ 

  OCTAVES   = 7,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 2.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = {"ip_.kenip", ip_.kenip}, -- HARDCODED override right now, BUT still active for Sampling


-- Map ---------------------------------

 PSEED   = 10010,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = 0,    -- Noise Offset 
 OFFSETY = 0,    --
 ZOOM    = 1,    --

 AUTOMATA = 0, -- Celluar Automata Iterations of Noise Map (Island effect)
 MAP_ERODE_FREQ = 0, -- Erode/Decontrast noise-map, Frequency 0..1
 MAP_ERODE_POW  = 0, -- Power 0..1..4


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_R0 = -128, -- -160,-130,-120 to 170,130,100
ADD_G0 = -128,
ADD_B0 = -128,
ADD_R1 = 128,
ADD_G1 = 128,
ADD_B1 = 128,
ADD_FUNC = 1, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 0, -- 0=Nothing, 1=Water(0.3), 2=Plains, 3=Flats, 4=Plains+Flats
ALT_LEVEL = 0.5,
TEXTURE      = 0, -- 1=Combo, 2=SoftCloud, 3=Post-Inflected, 4=Inflected, 5=GrainedPatchy, 6=Cyclic(Woodgrain), 7=Cow-Hide
TEXTURE_STR  = 50, -- Texture strength %
TEXTURE_FREQ = 1,

HAZE_POW   = 0,    -- Total Effect, 0 = off
HAZE_BASE  = 0,    -- Base Haze (Extra) 0..1
HAZE_EXP   = 1,    -- Gradient Exponent: 1 = Linear, 0.5 = Haze mostly at the far back. ~0.75 is usually good
HAZE_DMULT = 1.0,  -- Depth Fade, 0 = Full Haze at all depths, nom: 1.0
HAZE_VMULT = 0.5,  -- Haze loses strength at heights, nom: 0.5
HAZE_R = 127,
HAZE_G = 127,
HAZE_B = 127,

BUMP_TEXTURE = 0, -- Same set as normal textures #0-7 (0 = none / bump-mapping off)
BUMP_FREQ    = 1, -- Same as textures
BUMP_HEIGHT  = 0.05,
BUMP_DETAILBALANCE = 0, -- More or less octaves
-----------------------------------------

 dummy = 0
}, -- eof Basic



{ -- Sound of Gibraltar

   TITLE = "Mountains & Water",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 0.9,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {10,5,15}, -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = { {0,45,{255,255,192},3}, {45,60,{0,0,160},3}, {190,10,{80,80,96},18}, {300,30,{80,16,16},5}, {0,40,{16,64,16},3},  {180,50,{80,80,16},9}}, --Perlin


-- Perlin ------------------------------ 

  OCTAVES   = 8,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 2.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 999,    -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = -0.05, -- Noise Offset
 OFFSETY = -0.03,  --
 ZOOM    = 1,      --


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_FUNC = 2, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 1, -- 0=Nothing, 1=Water(0.3), 2=Riverbed(Mars) Direct modification of the Perlin Noise output (f.ex Water effect)
ALT_LEVEL = 0.3,
TEXTURE       = 0, -- Texture mode 0 = none
TEXTURE_STR   = 50, -- Texture strength %
TEXTURE_FREQ  = 1,

 HAZE_POW   = 1,
 HAZE_BASE  = 0,
 HAZE_EXP   = 0.6,
 HAZE_DMULT = 1,
 HAZE_VMULT = 0.9,
 HAZE_R = 8,
 HAZE_G = 4,
 HAZE_B = 24,

 BUMP_TEXTURE = 1,
 BUMP_FREQ    = 2,
 BUMP_HEIGHT  = 0.1,
 BUMP_DETAILBALANCE = 0,
 BUMP_DISTFADE = 0.85,
 BUMP_LEVEL_LO = 0.28,
-----------------------------------------

 dummy = 0
}, -- eof Gibralter



{ -- Marsian

   TITLE = "Marsian",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.7,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 5,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 0.85,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = -10,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {10,2,12}, -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{9, 13, {255,176,100}, 6},{100, 35, {100,90,105}, 10}}, -- Marsian

-- Perlin ------------------------------ 

  OCTAVES   = 8,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.42,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 2.2,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 10010,   -- Perlin Noise, Random Seed, -1 = Random
 OFFSETX = 0,    -- Noise Offset
 OFFSETY = 0,    -- 
 ZOOM    = 1.2,    --


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_FUNC = 3, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 2, -- 0=Nothing, 1=Water(0.3), 2=Riverbed(Mars) Direct modification of the Perlin Noise output (f.ex Water effect)
ALT_LEVEL = 0.5,
TEXTURE      = 1, -- 1=Combo, 2=SoftCloud, 3=Post-Inflected, 4=Inflected, 5=GrainedPatchy, 6=Cyclic(Woodgrain), 7=Cow-Hide
TEXTURE_STR  = 65, -- Texture strength %
TEXTURE_FREQ = 1,

HAZE_POW   = 1, 
HAZE_BASE  = 0,
HAZE_EXP   = 0.9,
HAZE_DMULT = 1.0,
HAZE_VMULT = 0.4,
HAZE_R = 90,
HAZE_G = 115,
HAZE_B = 150,

-----------------------------------------

 dummy = 0
}, -- eof Marsian





{ -- Wild Seas

   TITLE = "Wild Seas",
 _ACTIVE = false, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 0.85,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = -10,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {6,2,12}, -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{194, 32, {228,204,207}, 5}, {75, 28, {128,155,118}, 10}, {152, 10, {26,65,47}, 9}},

-- Perlin ------------------------------ 

  OCTAVES   = 7,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 2.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 999,   -- Perlin Noise, Random Seed, -1 = Random
 OFFSETX = -0.05,    -- Noise Offset
 OFFSETY = -0.03,    -- 
 ZOOM    = 1.0,    --


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_FUNC = 3, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 2, -- 0=Nothing, 1=Sea, 2=Plains, 3=Floor, 4 = Flats, 5 = Plains + Flats
ALT_LEVEL = 0.5,
TEXTURE = 5,
TEXTURE_STR = 100, -- Texture strength %

-----------------------------------------

 dummy = 0
}, -- eof WildSeas



{ -- Lava 1

   TITLE = "Lava",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.6,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 0.35,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {8,0,4},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{0, 0, {255,255,255}, 3.0}},


-- Perlin ------------------------------ 

  OCTAVES   = 7,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 2.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 10333,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = 0,    -- Noise Offset 
 OFFSETY = 0,    --
 ZOOM    = 1,    --


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_R0 = 260,
ADD_G0 = 125,
ADD_B0 = -10,
ADD_R1 = -384,
ADD_G1 = -255,
ADD_B1 =  -60,
ADD_FUNC = 1, -- 0=Nothing, 1 = Gradient, 2=Landscape+Water, 3=Mars
ALT_FUNC = 4, -- 0=Nothing, 1=Sea, 2=Plains, 3 = Flats, 4 = Plains + Flats, 5 = Floor (Order is that of menu)
ALT_LEVEL = 0.45,
TEXTURE = 1,
TEXTURE_STR = 65, -- Texture strength %

-----------------------------------------

 dummy = 0
}, -- eof Lava


{ -- Snowy Mountains

   TITLE = "Snowy Mountains",
 _ACTIVE = true, -- Is Scene Active

 -- Isometrics -------------------
 ISOMODE = 1,
 VSCALE = 0.15,
 BASELINE = 0.5,
 YPLOTS = 4,
 
-- Lights -----------------------
 HARDNESS = 1,
 AMP = 1,
 GROT = 0,
 RNDLIGHT = false,
 FC = {0, 10, 24},
 LS = {{163, 43, {104,120,118}, 7}, {303, 24, {245,195,138}, 4} },

-- Perlin -----------------------
 OCTAVES   = 7,
 PERSIST   = 0.42,
 FREQ_MULT = 4,
 FREQ_BASE = 2,
 MULTIPLY  = 2,
 IP_FUNC = ip_.kenip,
 
-- Map --------------------------
 PSEED   = 24777,
 OFFSETX = 0,
 OFFSETY = 0,
 ZOOM    = 1,
 
 AUTOMATA = 0,
 MAP_ERODE_FREQ = 0,
 MAP_ERODE_POW  = 0,
 
-- Visuals ----------------------
 MAKEPAL_FLAG = true,
 ADD_R0 = -110,
 ADD_G0 = -110,
 ADD_B0 = -90,
 ADD_R1 = 115,
 ADD_G1 = 115,
 ADD_B1 = 110,
 ADD_FUNC = 1,
 ALT_FUNC = 2,
 ALT_LEVEL = 0.2,
 
 TEXTURE      = 5,
 TEXTURE_STR  = 60,
 TEXTURE_FREQ = 2.5,
 
 HAZE_POW   = 0.95,
 HAZE_BASE  = 0.15,
 HAZE_EXP   = 0.8,
 HAZE_DMULT = 0.8,
 HAZE_VMULT = 0.65,
 HAZE_R = 100,
 HAZE_G = 120,
 HAZE_B = 145,
 
 BUMP_TEXTURE = 1,
 BUMP_FREQ    = 1,
 BUMP_HEIGHT  = 0.08,
 BUMP_DETAILBALANCE = 0,
 BUMP_DISTFADE = 0.65,
 BUMP_LEVEL_LO = -0.2,
 

 dummy = 0

}, -- eof Snowy Mountains



{ -- Namibia (Sandstone and water)

   TITLE = "Namibia",
 _ACTIVE = true, -- Is Scene Active

 -- Isometrics -------------------
 ISOMODE = 1,
 VSCALE = 0.15,
 BASELINE = 0.5,
 YPLOTS = 4,
 
-- Lights -----------------------
 HARDNESS = 1,
 AMP = 1,
 GROT = 0,
 RNDLIGHT = false,
 FC = {0, 10, 24},
 LS = {{163, 43, {104,120,118}, 7}, {303, 24, {252,187,138}, 4} },

-- Perlin -----------------------
 OCTAVES   = 7,
 PERSIST   = 0.4,
 FREQ_MULT = 4,
 FREQ_BASE = 2,
 MULTIPLY  = 2,
 IP_FUNC = ip_.kenip,
 
-- Map --------------------------
 PSEED   = 44538,
 OFFSETX = 0,
 OFFSETY = 0,
 ZOOM    = 1,
 
 AUTOMATA = 0,
 MAP_ERODE_FREQ = 0,
 MAP_ERODE_POW  = 0,
 
-- Visuals ----------------------
 MAKEPAL_FLAG = true,
 ADD_R0 = -130,
 ADD_G0 = -130,
 ADD_B0 = -105,
 ADD_R1 = 140,
 ADD_G1 = 130,
 ADD_B1 = 85,
 ADD_FUNC = 1,
 ALT_FUNC = 1,
 ALT_LEVEL = 0.35,
 
 TEXTURE      = 1,
 TEXTURE_STR  = 50,
 TEXTURE_FREQ = 0.9,
 
 HAZE_POW   = 1,
 HAZE_BASE  = 0,
 HAZE_EXP   = 1,
 HAZE_DMULT = 1,
 HAZE_VMULT = 0.5,
 HAZE_R = 90,
 HAZE_G = 120,
 HAZE_B = 150,
 
 BUMP_TEXTURE = 4,
 BUMP_FREQ    = 2,
 BUMP_HEIGHT  = 0.1,
 BUMP_DETAILBALANCE = -1,
 BUMP_DISTFADE = 0.65,
 BUMP_LEVEL_LO = 0.25,
 

 dummy = 0

}, -- eof Namibia


{ -- Titan Sunrise

  TITLE = "Titan Sunrise",
 _ACTIVE = true, -- Is Scene Active

 -- Isometrics -------------------
 ISOMODE = 1,
 VSCALE = 0.15,
 BASELINE = 0.7,
 YPLOTS = 7,
 
-- Lights -----------------------
 HARDNESS = 1,
 AMP = 1.15,
 GROT = 0,
 RNDLIGHT = false,
 FC = {18, 14, 24},
 LS = {{0, 10, {85,85,95}, 2}, {-5, 47, {235,115,45}, 5} },

-- Perlin -----------------------
 OCTAVES   = 7,
 PERSIST   = 0.5,
 FREQ_MULT = 4,
 FREQ_BASE = 1.65,
 MULTIPLY  = 2,
 IP_FUNC = ip_.kenip,
 
-- Map --------------------------
 PSEED   = 50556,
 OFFSETX = -0.05,
 OFFSETY = 0.27,
 ZOOM    = 1.1,
 
 AUTOMATA = 0,
 MAP_ERODE_FREQ = 0,
 MAP_ERODE_POW  = 0,
 
-- Visuals ----------------------
 MAKEPAL_FLAG = true,
 ADD_R0 = -145,
 ADD_G0 = -120,
 ADD_B0 = -115,
 ADD_R1 = 70,
 ADD_G1 = 60,
 ADD_B1 = 45,
 ADD_FUNC = 1,
 ALT_FUNC = 5,
 ALT_LEVEL = 0.44,
 
 TEXTURE      = 3,
 TEXTURE_STR  = 25,
 TEXTURE_FREQ = 2,
 
 HAZE_POW   = 1.2,
 HAZE_BASE  = 0.25,
 HAZE_EXP   = 0.3,
 HAZE_DMULT = 0,
 HAZE_VMULT = 0.81,
 HAZE_R = 68,
 HAZE_G = 92,
 HAZE_B = 80,
 
 BUMP_TEXTURE = 4,
 BUMP_FREQ    = 1,
 BUMP_HEIGHT  = 0.15,
 BUMP_DETAILBALANCE = -1,
 BUMP_DISTFADE = 0.65,
 BUMP_LEVEL_LO = 0.2,
 

 dummy = 0

}, -- eof Titan Sunrise

{ -- Alien

   TITLE = "Alien",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 1, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 5,


-- Lights -----------------------------

HARDNESS = 1.1,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 0.86,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,         -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {0,0,24},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{-45, 20, {265,255,208}, 7}},


-- Perlin ------------------------------ 

  OCTAVES   = 8,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 3.4,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 97470,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = -0.25,    -- Noise Offset 
 OFFSETY = 0.15,    --
 ZOOM    = 1.57,    --


-- Visuals -----------------------------

MAKEPAL_FLAG = true,
ADD_R0 = -115,
ADD_G0 = -115,
ADD_B0 = -115,
ADD_R1 = 65,
ADD_G1 = 65,
ADD_B1 = 65,
ADD_FUNC = 1, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 2, -- 0=Nothing, 1=Water(0.3), 2=Riverbed(Mars) Direct modification of the Perlin Noise output (f.ex Water effect)
ALT_LEVEL = 0.5,
TEXTURE = 0,
TEXTURE_STR = 50, -- Texture strength %

-----------------------------------------

 dummy = 0
}, -- eof Alien




{ -- 2D Texture test

   TITLE = "(Texture Test)",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 0, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 1.0,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {127,127,127},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      --LS = {{0, 25, {255,255,255}, 3.0}},
      LS = {},

-- Perlin ------------------------------ 

  OCTAVES   = 1,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 0.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 999,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = 0,    -- Noise Offset 
 OFFSETY = 0,    --
 ZOOM    = 1,    --


-- Visuals -----------------------------

MAKEPAL_FLAG = false,
ADD_FUNC = 0, -- 0=Nothing, 1 = values, 2=Landscape+Water, 3=Mars
ALT_FUNC = 0, -- 0=Nothing, 1=Water(0.3), 2=Riverbed(Mars) Direct modification of the Perlin Noise output (f.ex Water effect)
ALT_LEVEL = 0.5,
TEXTURE = 1,
TEXTURE_STR = 100, -- Texture strength %

-----------------------------------------

 dummy = 0
}, -- eof 2D Texture Test



{ -- 2D Noise Render

   TITLE = "(Noise Test)",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 0, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 1.0,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {0,0,0},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {},

-- Perlin ------------------------------ 

  OCTAVES   = 1,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 1.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 999,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = 0,    -- Noise Offset 
 OFFSETY = 0,    --
 ZOOM    = 0.05,  --


-- Visuals -----------------------------

MAKEPAL_FLAG = false,
ADD_R0 = 0,
ADD_G0 = 0,
ADD_B0 = 0,
ADD_R1 = 255.5, -- Rounding issue, noise may never quite reach 1.0 and with that the value 255
ADD_G1 = 255.5,
ADD_B1 = 255.5,
ADD_FUNC = 1, -- 0=Nothing, 1 = Gradient, 2=Landscape+Water, 3=Mars
ALT_FUNC = 0, -- 0=Nothing,
ALT_LEVEL = 0.5,
TEXTURE = 0,
TEXTURE_STR = 0, -- Texture strength %

-----------------------------------------

 dummy = 0
}, -- eof 2D Noise Test


{ -- 2D Bump Test

   TITLE = "(Bump Test)",
 _ACTIVE = true, -- Is Scene Active


-- Isometrics -------------------

 ISOMODE = 0, -- Isometric mode on=1/off=0 
  VSCALE = 0.15, -- (0..1) Vertical scale as fraction of screen height (0.1125 = max height of 90 in a 800 image)
BASELINE = 0.5,  -- Altitude of Noise where the Isometrics are centered vertically (ex 0.3 if waterline is at 0.3)
  YPLOTS = 4,


-- Lights -----------------------------

HARDNESS = 1.0,      -- Lights: Hardness/Contrast (no change to scale or altitude)
     AMP = 1.0,      -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
    GROT = 0,        -- Global rotation
RNDLIGHT = false,    -- Randomize the Lights (Not in active use inside core(), custom Randomizing is replacing O.LS before running)
      FC = {0,0,0},  -- Basecolor RGB. Now Also representing Ambient Light/Colorbalance. Pure Addition.
      LS = {{0, 25, {255,255,255}, 3.0}},

-- Perlin ------------------------------ 

  OCTAVES   = 1,     -- Octaves, Layers (Nominal 8, higher persistence may need more octaves for detail)
  PERSIST   = 0.4,   -- Persistence (Roughness): Nominal 0.5 (0.4 for Landscapes), Lower means later octaves will have reduced strength = Smoother
  FREQ_MULT = 4.0,   -- Frequency: Lower means "zoom-in" / enlarge (100% eq. to zooming the grid?)
  FREQ_BASE = 2.0,  -- "Scale Change": Nominal = 2.0. Lower = Softer, Less detail by octave, higher = more grain, "Zoom-out (>1.0) speed by octave"
  MULTIPLY  = 0.0,   -- Multiply/Contrast (for Clouds scenes etc.)
  IP_FUNC   = ip_.kenip, -- HARDCODED override right now, BUT still active for Sampling
 

-- Map ---------------------------------

 PSEED   = 999,   -- Perlin Noise, Random Seed, -1 = Random, 999 = "Sound of Gibraltar"
 OFFSETX = 0,    -- Noise Offset 
 OFFSETY = 0,    --
 ZOOM    = 1,  --


-- Visuals -----------------------------

MAKEPAL_FLAG = false,
ADD_R0 = 0,
ADD_G0 = 0,
ADD_B0 = 0,
ADD_R1 = 0, -- Rounding issue, noise may never quite reach 1.0 and with that the value 255
ADD_G1 = 0,
ADD_B1 = 0,
ADD_FUNC = 0, -- 0=Nothing, 1 = Gradient, 2=Landscape+Water, 3=Mars
ALT_FUNC = 0, -- 0=Nothing,
ALT_LEVEL = 0.5,
TEXTURE = 0,
TEXTURE_STR = 0, -- Texture strength %
TEXTURE_FREQ = 1,

BUMP_TEXTURE = 1,
BUMP_FREQ    = 1,
BUMP_HEIGHT  = 0.05,
BUMP_DETAILBALANCE = 0,

-----------------------------------------

 dummy = 0
} -- eof Bump Test



}
-- eof Data


 local n,i,list

 list = {}
 i = 1
 for n = 1, #SCENES, 1 do
  if SCENES[n]._ACTIVE then
   list[i] = {SCENES[n].TITLE, SCENES[n]}; i = i+1
  end
 end

 return list

end -- eof Pfunction
