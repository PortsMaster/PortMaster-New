-- Everything you can buy, own and equip: rods, lines, lures, coolers and boats,
-- plus which lures each fish goes for.
local GR = {}

GR.RODS = {
  { name = "Willow Cane",     cost = 0,    desc = "A springy old cane rod. Slow, but it gets the job done." },
  { name = "Fiberglass Rod",  cost = 140,  desc = "Tough and forgiving. Reels in a little faster." },
  { name = "Graphite Rod",    cost = 480,  desc = "Light and quick. You feel every nibble." },
  { name = "Carbon Pro",      cost = 1400, desc = "Fast and powerful. Big fish come in quicker." },
  { name = "Heritage Bamboo", cost = 3200, desc = "Hand-split bamboo with a silk-smooth reel. The best there is." },
}
GR.LINES = {
  { name = "6 lb Mono",       cost = 0,    desc = "Thin nylon line. Snaps if you're rough with it." },
  { name = "12 lb Mono",      cost = 110,  desc = "Thicker nylon. Takes a bit more strain." },
  { name = "20 lb Braid",     cost = 380,  desc = "Woven line with no stretch. Much harder to snap." },
  { name = "30 lb Fluoro",    cost = 1050, desc = "Near invisible and very strong." },
  { name = "50 lb Big Game",  cost = 2700, desc = "Built for marlin. Almost nothing breaks it." },
}
GR.COOLERS = {
  { name = "Foam Box",        cost = 0,    cap = 6,  desc = "A cheap foam box. Holds six fish." },
  { name = "Day Cooler",      cost = 200,  cap = 10, desc = "A sturdy little cooler for ten fish." },
  { name = "Marine Cooler",   cost = 650,  cap = 15, desc = "Keeps fifteen fish fresh all day." },
  { name = "Rotomold Chest",  cost = 1600, cap = 22, desc = "Built like a tank. Twenty-two fish." },
  { name = "Big Chill",       cost = 3600, cap = 30, desc = "Room for thirty. You may need a bigger boat." },
}
GR.BOATS = {
  { key = "rowboat",  name = "Rowboat",  cost = 0,    speed = 44,  desc = "Wooden and quiet. You row it yourself." },
  { key = "skiff",    name = "Skiff",    cost = 900,  speed = 74,  desc = "Light aluminium with a small outboard." },
  { key = "workboat", name = "Workboat", cost = 3200, speed = 104, desc = "Roomy, steady, and quick across the water." },
}

-- bobbers (floats): ride the surface and hold the bait at a set depth below them, and dip when a fish bites
GR.BOBBERS = {
  { name = "No Bobber",   cost = 0,  desc = "Fish the lure on its own." },
  { name = "Slip Bobber", cost = 60, desc = "A red-and-white float. Holds your bait at a set depth and dips when a fish bites. Up and Down set the depth." },
}

-- trolling motors: electric, clamped to the boat. On the rowboat it drives the boat instead of the oars
-- (steered by its tiller with one hand); on any boat it can be left running slowly while you fish.
--   speed: top speed when driving (rowboat only); troll: the slow trolling speed
GR.MOTORS = {
  { name = "No Motor",              cost = 0,    speed = 0,  troll = 0, desc = "Just the oars, or your boat's own engine." },
  { name = "Trolling Motor",        cost = 450,  speed = 46, troll = 0, desc = "A quiet electric motor you steer by hand with its tiller. Drives the rowboat." },
  { name = "Auto Trolling Motor",   cost = 1600, speed = 56, troll = 9, auto = true,
    desc = "Faster, and it can troll on its own: press Y to creep along towing your lure while you fish." },
}

-- lures: how they behave in the water and how far fish notice them
--   oz: weight (a heavier lure loads the rod and carries farther); area: how much air drag it catches
--   sink: drift down per second when left alone (negative floats up); fast: sink when letting line out
--   float: stays at the surface; dive: swims down to this depth (px) while reeled; flash: catches the eye when moving
GR.LURES = {
  { id = "worm",    name = "Worm and Hook",     cost = 0,    oz = 0.07, area = 1.0, attract = 1.0, sink = 7,  fast = 30, desc = "Everything eats a worm. Panfish, perch, catfish." },
  { id = "spinner", name = "Inline Spinner",  cost = 80,   oz = 0.125, area = 0.8, attract = 1.2, sink = 9,  fast = 30, flash = true, desc = "A flashing blade. Trout, bass and pike chase it." },
  { id = "jig",     name = "Lead Jig",        cost = 150,  oz = 0.25, area = 0.6, attract = 1.1, sink = 24, fast = 45, desc = "Drops fast to the bottom. Walleye, rockfish, lake trout." },
  { id = "crank",   name = "Diving Crank",    cost = 280,  oz = 0.25, area = 1.1, attract = 1.3, sink = -5, fast = 20, dive = 70, desc = "Floats when still, dives when reeled. Bass, pike, walleye." },
  { id = "popper",  name = "Topwater Popper", cost = 320,  oz = 0.25, area = 1.3, attract = 1.3, sink = 0,  fast = 0,  float = true, desc = "Pops along the surface. Bass, pike and mahi strike it." },
  { id = "spoon",   name = "Silver Spoon",    cost = 420,  oz = 0.33, area = 0.6, attract = 1.4, sink = 14, fast = 36, flash = true, desc = "A wobbling flash. Salmon, steelhead, char, mackerel." },
  { id = "glow",    name = "Glow Jig",        cost = 650,  oz = 0.25, area = 0.6, attract = 1.4, sink = 20, fast = 40, glow = true, desc = "Glows in the dark. Burbot, catfish, and something in Frost Lake." },
  { id = "stink",   name = "Stink Bait",      cost = 900,  oz = 0.2, area = 0.9, attract = 1.2, sink = 12, fast = 34, desc = "Smells awful. Catfish love it. Maybe something bigger, too." },
  { id = "fly",     name = "Mayfly Dry Fly",  cost = 900,  oz = 0.05, area = 1.2, attract = 1.2, sink = 0,  fast = 0,  float = true, desc = "Sits on the surface like a hatching mayfly. Trout and grayling." },
  { id = "plug",    name = "Trolling Plug",   cost = 1500, oz = 0.5, area = 1.0, attract = 1.6, sink = 8,  fast = 30, dive = 50, flash = true, desc = "A big offshore lure. Mahi-mahi, snapper... and the Admiral." },
}
GR.LURE = {}
for i, l in ipairs(GR.LURES) do l.index = i; GR.LURE[l.id] = l end

-- what each fish goes for (first = favourite); `req` means it will only take that lure
GR.LIKES = {
  -- Columbia River
  peamouth = { "worm", "fly", "spinner" },        c_perch = { "worm", "jig", "spinner" },
  c_smallmouth = { "crank", "jig", "worm", "popper" }, pikeminnow = { "worm", "spinner", "spoon" },
  shad = { "jig", "spinner" },                    c_walleye = { "jig", "plug", "crank", "worm" },
  c_catfish = { "stink", "worm" },                coho = { "spinner", "spoon", "plug" },
  c_steelhead = { "spinner", "jig", "plug", "fly" }, chinook = { "plug", "spinner", "spoon" },
  sturgeon = { "stink", "worm" },                 gorgegiant = { req = "stink" },
  bluegill = { "worm", "spinner", "fly" },       shiner = { "worm", "spinner", "fly" },
  perch = { "worm", "jig", "spinner" },          crappie = { "jig", "worm", "glow" },
  trout = { "spinner", "fly", "spoon", "worm" }, bass = { "crank", "popper", "spinner", "worm" },
  catfish = { "stink", "worm", "glow" },         walleye = { "jig", "crank", "glow" },
  pike = { "spoon", "crank", "popper", "spinner" }, salmon = { "spoon", "spinner", "plug" },
  carp = { "worm", "stink" },                    oldwhiskers = { req = "stink" },
  chub = { "worm", "spinner", "fly" },           sculpin = { "worm", "jig" },
  brooktrout = { "fly", "spinner", "worm" },     grayling = { "fly", "spinner" },
  steelhead = { "spoon", "spinner", "fly" },     riverghost = { req = "fly" },
  mackerel = { "spoon", "spinner", "jig" },      rockfish = { "jig", "worm" },
  flounder = { "worm", "jig" },                  snapper = { "jig", "crank", "plug" },
  mahi = { "popper", "plug", "spoon" },          marlin = { req = "plug" },
  cisco = { "jig", "spinner", "spoon" },         char = { "spoon", "jig", "spinner" },
  burbot = { "glow", "worm", "stink" },          whitefish = { "jig", "worm" },
  laketrout = { "spoon", "jig", "glow" },        frostfin = { req = "glow" },
}

-- how keen a fish is on a lure: 0 won't touch it .. 1.8 its favourite
function GR.affinity(fishId, lureId)
  local l = GR.LIKES[fishId]
  if not l then return 1 end
  if l.req then return l.req == lureId and 1.8 or 0 end
  for i, id in ipairs(l) do
    if id == lureId then return i == 1 and 1.8 or 1.25 end
  end
  return 0.2
end

function GR.likesText(fishId)
  local l = GR.LIKES[fishId]
  if not l then return "" end
  if l.req then return "Only takes: " .. GR.LURE[l.req].name end
  local names = {}
  for _, id in ipairs(l) do names[#names + 1] = GR.LURE[id].name end
  return "Likes: " .. table.concat(names, ", ")
end

function GR.motor(g) return GR.MOTORS[(g.equip and g.equip.motor) or 1] or GR.MOTORS[1] end
function GR.hasMotor(g) return ((g.equip and g.equip.motor) or 1) > 1 end
function GR.hasBobber(g) return ((g.equip and g.equip.bobber) or 1) > 1 end
function GR.canTroll(g) return GR.motor(g).auto == true end

-- set up ownership for a new or older save
function GR.migrate(g)
  if g.owned then
    g.owned.motor = g.owned.motor or { true }
    g.owned.bobber = g.owned.bobber or { true }
    g.equip.bobber = math.min(g.equip.bobber or 1, #GR.BOBBERS)
    g.equip.motor = math.min(g.equip.motor or 1, #GR.MOTORS)
    return
  end
  g.owned = { rod = {}, line = {}, lure = { worm = true }, cooler = {}, boat = {}, motor = { true }, bobber = { true } }
  for i = 1, math.max(1, g.rod or 1) do g.owned.rod[i] = true end
  for i = 1, math.max(1, g.line or 1) do g.owned.line[i] = true end
  for i = 1, math.max(1, g.coolerLvl or 1) do g.owned.cooler[i] = true end
  for k, v in pairs(g.boats or { rowboat = true }) do if v then g.owned.boat[k] = true end end
  g.owned.boat.rowboat = true
  if (g.lure or 1) >= 2 then g.owned.lure.spinner = true end
  if (g.lure or 1) >= 3 then g.owned.lure.jig = true end
  g.equip = { rod = g.rod or 1, line = g.line or 1, lure = "worm", cooler = g.coolerLvl or 1, motor = 1, bobber = 1 }
end

-- keep the stat fields the game reads in step with what's equipped
function GR.sync(g)
  g.rod, g.line, g.coolerLvl = g.equip.rod, g.equip.line, g.equip.cooler
  g.boats = g.owned.boat
end

return GR
