-- Fish definitions. Art is in fish/<id>.png: a strip of 4 swim frames, each w x h, facing right.
-- loc: which location it lives in. time: "any", "day" or "night".
-- zone: the depth band it prefers, 0 = just under the surface, 1 = the bottom.
-- str: how hard it fights (0.25 easy .. 1.5 brutal). value: base coins.
local F = {}
local function add(t) F[#F + 1] = t end

-------------------------------------------------------------------- Pine Lake
add{ id="bluegill",    loc="lake", name="Bluegill",         tier=1, w=16, h=8,  min=12,  max=25,  value=4,   weight=30, time="day",   zone={0.0, 0.5},  str=0.30 }
add{ id="shiner",      loc="lake", name="Golden Shiner",    tier=1, w=16, h=8,  min=8,   max=18,  value=3,   weight=30, time="any",   zone={0.0, 0.4},  str=0.25 }
add{ id="perch",       loc="lake", name="Yellow Perch",     tier=1, w=16, h=8,  min=15,  max=30,  value=6,   weight=22, time="day",   zone={0.3, 0.7},  str=0.35 }
add{ id="crappie",     loc="lake", name="Crappie",          tier=1, w=16, h=8,  min=15,  max=32,  value=7,   weight=18, time="night", zone={0.3, 0.7},  str=0.40 }
add{ id="trout",       loc="lake", name="Rainbow Trout",    tier=2, w=32, h=12, min=30,  max=65,  value=18,  weight=14, time="day",   zone={0.2, 0.6},  str=0.60 }
add{ id="bass",        loc="lake", name="Smallmouth Bass",  tier=2, w=32, h=12, min=28,  max=55,  value=16,  weight=14, time="any",   zone={0.4, 0.9},  str=0.70 }
add{ id="catfish",     loc="lake", name="Channel Catfish",  tier=2, w=32, h=12, min=40,  max=90,  value=22,  weight=12, time="night", zone={0.65, 1.0}, str=0.80 }
add{ id="walleye",     loc="lake", name="Walleye",          tier=2, w=32, h=12, min=35,  max=75,  value=24,  weight=10, time="night", zone={0.55, 1.0}, str=0.75 }
add{ id="pike",        loc="lake", name="Northern Pike",    tier=3, w=48, h=16, min=60,  max=120, value=60,  weight=5,  time="day",   zone={0.2, 0.6},  str=1.00 }
add{ id="salmon",      loc="lake", name="Chinook Salmon",   tier=3, w=48, h=16, min=65,  max=130, value=75,  weight=4,  time="any",   zone={0.3, 0.8},  str=1.15 }
add{ id="carp",        loc="lake", name="Common Carp",      tier=3, w=48, h=16, min=50,  max=100, value=45,  weight=6,  time="any",   zone={0.6, 1.0},  str=0.90 }
add{ id="oldwhiskers", loc="lake", name="Old Whiskers",     tier=4, w=64, h=24, min=180, max=300, value=500, weight=1,  time="night", zone={0.75, 1.0}, str=1.50, legend=true }

-------------------------------------------------------------------- Willow River
add{ id="chub",        loc="river", name="Creek Chub",      tier=1, w=16, h=8,  min=10,  max=25,  value=7,   weight=30, time="any",   zone={0.0, 0.5},  str=0.32 }
add{ id="sculpin",     loc="river", name="Mottled Sculpin", tier=1, w=16, h=8,  min=6,   max=14,  value=8,   weight=24, time="any",   zone={0.75, 1.0}, str=0.28 }
add{ id="brooktrout",  loc="river", name="Brook Trout",     tier=2, w=32, h=12, min=25,  max=55,  value=30,  weight=15, time="day",   zone={0.2, 0.6},  str=0.65 }
add{ id="grayling",    loc="river", name="Arctic Grayling", tier=2, w=32, h=12, min=25,  max=50,  value=34,  weight=12, time="day",   zone={0.0, 0.45}, str=0.60 }
add{ id="steelhead",   loc="river", name="Steelhead",       tier=3, w=48, h=16, min=55,  max=110, value=110, weight=5,  time="any",   zone={0.3, 0.7},  str=1.15 }
add{ id="riverghost",  loc="river", name="The River Ghost", tier=4, w=64, h=24, min=150, max=260, value=850, weight=1,  time="night", zone={0.7, 1.0},  str=1.55, legend=true }

-------------------------------------------------------------------- Driftwood Bay
add{ id="mackerel",    loc="coast", name="Atlantic Mackerel", tier=1, w=16, h=8, min=20,  max=45,  value=12,  weight=30, time="day",   zone={0.0, 0.4},  str=0.40 }
add{ id="rockfish",    loc="coast", name="Rockfish",        tier=2, w=32, h=12, min=25,  max=60,  value=40,  weight=16, time="any",   zone={0.65, 1.0}, str=0.70 }
add{ id="flounder",    loc="coast", name="Flounder",        tier=2, w=32, h=12, min=30,  max=70,  value=44,  weight=14, time="any",   zone={0.8, 1.0},  str=0.65 }
add{ id="snapper",     loc="coast", name="Red Snapper",     tier=2, w=32, h=12, min=35,  max=80,  value=52,  weight=12, time="day",   zone={0.4, 0.8},  str=0.80 }
add{ id="mahi",        loc="coast", name="Mahi-Mahi",       tier=3, w=48, h=16, min=70,  max=140, value=160, weight=5,  time="day",   zone={0.0, 0.4},  str=1.20 }
add{ id="marlin",      loc="coast", name="The Admiral",     tier=4, w=64, h=24, min=250, max=420, value=1300, weight=1, time="any",   zone={0.1, 0.5},  str=1.60, legend=true }

-------------------------------------------------------------------- Frost Lake
add{ id="cisco",       loc="frost", name="Cisco",           tier=1, w=16, h=8,  min=15,  max=35,  value=16,  weight=30, time="any",   zone={0.3, 0.6},  str=0.38 }
add{ id="char",        loc="frost", name="Arctic Char",     tier=2, w=32, h=12, min=35,  max=75,  value=60,  weight=15, time="any",   zone={0.4, 0.8},  str=0.75 }
add{ id="burbot",      loc="frost", name="Burbot",          tier=2, w=32, h=12, min=35,  max=80,  value=56,  weight=14, time="night", zone={0.75, 1.0}, str=0.70 }
add{ id="whitefish",   loc="frost", name="Lake Whitefish",  tier=2, w=32, h=12, min=30,  max=65,  value=50,  weight=16, time="day",   zone={0.3, 0.7},  str=0.65 }
add{ id="laketrout",   loc="frost", name="Lake Trout",      tier=3, w=48, h=16, min=60,  max=125, value=200, weight=5,  time="any",   zone={0.6, 1.0},  str=1.25 }
add{ id="frostfin",    loc="frost", name="Frostfin",        tier=4, w=64, h=24, min=200, max=330, value=1800, weight=1, time="night", zone={0.35, 0.75}, str=1.65, legend=true }

-------------------------------------------------------------------- Columbia River at Hood River, Oregon
-- the Bonneville Pool: smallmouth on the basalt riprap, walleye in the channel, shad runs in summer,
-- salmon and steelhead passing upriver, pikeminnow everywhere, and white sturgeon on the deep bottom
add{ id="peamouth",    loc="columbia", name="Peamouth",          tier=1, w=16, h=8,  min=15, max=30,  value=10,  weight=26, time="any",   zone={0.0, 0.5},  str=0.35 }
add{ id="c_perch",     loc="columbia", name="Yellow Perch",      tier=1, w=16, h=8,  min=15, max=30,  value=10,  weight=20, time="day",   zone={0.3, 0.7},  str=0.35 }
add{ id="c_smallmouth",loc="columbia", name="Smallmouth Bass",   tier=2, w=32, h=12, min=25, max=55,  value=34,  weight=22, time="day",   zone={0.5, 0.95}, str=0.80 }
add{ id="pikeminnow",  loc="columbia", name="Northern Pikeminnow", tier=2, w=32, h=12, min=25, max=60, value=30, weight=18, time="any",  zone={0.3, 0.8},  str=0.60 }
add{ id="shad",        loc="columbia", name="American Shad",     tier=2, w=32, h=12, min=35, max=60,  value=28,  weight=16, time="day",   zone={0.0, 0.4},  str=0.70 }
add{ id="c_walleye",   loc="columbia", name="Walleye",           tier=2, w=32, h=12, min=35, max=80,  value=46,  weight=12, time="night", zone={0.6, 1.0},  str=0.80 }
add{ id="c_catfish",   loc="columbia", name="Channel Catfish",   tier=2, w=32, h=12, min=40, max=90,  value=40,  weight=10, time="night", zone={0.7, 1.0},  str=0.85 }
add{ id="coho",        loc="columbia", name="Coho Salmon",       tier=3, w=48, h=16, min=50, max=80,  value=140, weight=5,  time="day",   zone={0.1, 0.5},  str=1.10 }
add{ id="c_steelhead", loc="columbia", name="Summer Steelhead",  tier=3, w=48, h=16, min=55, max=95,  value=160, weight=5,  time="any",   zone={0.2, 0.6},  str=1.20 }
add{ id="chinook",     loc="columbia", name="Chinook Salmon",    tier=3, w=48, h=16, min=70, max=115, value=190, weight=4,  time="any",   zone={0.3, 0.8},  str=1.30 }
add{ id="sturgeon",    loc="columbia", name="White Sturgeon",    tier=3, w=48, h=16, min=90, max=250, value=220, weight=3,  time="any",   zone={0.85, 1.0}, str=1.40 }
add{ id="gorgegiant",  loc="columbia", name="The Gorge Giant",   tier=4, w=64, h=24, min=300, max=430, value=2200, weight=1, time="night", zone={0.9, 1.0}, str=1.75, legend=true }

return F
