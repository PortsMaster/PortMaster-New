-- Achievements and daily requests, with coin rewards you claim in the tackle box.
local FISH = require("fishdata")
local GR = require("gear")
local GO = {}

local function speciesDone(g, loc, legends)
  for _, f in ipairs(FISH) do
    if f.loc == loc and (legends or not f.legend) and not g.log[f.id] then return false end
  end
  return true
end
local function legends(g)
  local n = 0
  for _, f in ipairs(FISH) do if f.legend and g.log[f.id] then n = n + 1 end end
  return n
end
local function count(t) local n = 0; for _ in pairs(t or {}) do n = n + 1 end; return n end

-- each: id, name, how to get it, reward, and a progress function returning (have, need)
GO.LIST = {
  { id = "first",    name = "First Bite",         desc = "Catch your first fish.",                 reward = 25,   prog = function(g) return g.stats.catches, 1 end },
  { id = "ten",      name = "Getting the Hang",   desc = "Catch 10 fish.",                         reward = 100,  prog = function(g) return g.stats.catches, 10 end },
  { id = "fifty",    name = "Seasoned Angler",    desc = "Catch 50 fish.",                         reward = 400,  prog = function(g) return g.stats.catches, 50 end },
  { id = "oldsalt",  name = "Old Salt",           desc = "Catch 150 fish.",                        reward = 1200, prog = function(g) return g.stats.catches, 150 end },
  { id = "night",    name = "Night Owl",          desc = "Catch 5 fish after dark.",               reward = 80,   prog = function(g) return g.stats.night, 5 end },
  { id = "rain",     name = "Rain or Shine",      desc = "Catch 5 fish in the rain or snow.",      reward = 80,   prog = function(g) return g.stats.rain, 5 end },
  { id = "bigone",   name = "The Big One",        desc = "Land a trophy-sized fish.",              reward = 150,  prog = function(g) return g.stats.trophies, 1 end },
  { id = "gentle",   name = "Gentle Touch",       desc = "Land 10 fish in a row without a snap.",  reward = 200,  prog = function(g) return g.stats.bestStreak, 10 end },
  { id = "jumper",   name = "Airborne",           desc = "Land a fish that leapt out of the water.", reward = 120, prog = function(g) return g.stats.jumpers, 1 end },
  { id = "lakeall",  name = "Pine Lake Naturalist", desc = "Catch every Pine Lake species.",       reward = 500,  prog = function(g) return speciesDone(g, "lake") and 1 or 0, 1 end },
  { id = "riverall", name = "River Rat",          desc = "Catch every Willow River species.",      reward = 600,  prog = function(g) return speciesDone(g, "river") and 1 or 0, 1 end },
  { id = "coastall", name = "Bay Watcher",        desc = "Catch every Driftwood Bay species.",     reward = 800,  prog = function(g) return speciesDone(g, "coast") and 1 or 0, 1 end },
  { id = "frostall", name = "Ice Fisher",         desc = "Catch every Frost Lake species.",        reward = 900,  prog = function(g) return speciesDone(g, "frost") and 1 or 0, 1 end },
  { id = "legend",   name = "Tall Tale",          desc = "Catch a legendary fish.",                reward = 1000, prog = function(g) return legends(g), 1 end },
  { id = "legends",  name = "Living Legend",      desc = "Catch all four legends.",                reward = 3000, prog = function(g) return legends(g), 4 end },
  { id = "earn1k",   name = "Nest Egg",           desc = "Earn 1,000 coins selling fish.",         reward = 100,  prog = function(g) return g.stats.earned, 1000 end },
  { id = "earn10k",  name = "Fishmonger",         desc = "Earn 10,000 coins selling fish.",        reward = 1000, prog = function(g) return g.stats.earned, 10000 end },
  { id = "explorer", name = "Explorer",           desc = "Fish all five places.",                  reward = 500,  prog = function(g) return count(g.stats.visited), 5 end },
  { id = "columbiaall", name = "Gorge Angler",     desc = "Catch every Columbia River species.",    reward = 1100, prog = function(g) return speciesDone(g, "columbia") and 1 or 0, 1 end },
  { id = "lures",    name = "Tackle Hoarder",     desc = "Own every lure.",                        reward = 800,  prog = function(g) return count(g.owned.lure), #GR.LURES end },
  { id = "workboat", name = "Shipshape",          desc = "Own the workboat.",                      reward = 300,  prog = function(g) return g.owned.boat.workboat and 1 or 0, 1 end },
  { id = "friend",   name = "Best Friend",        desc = "Give your companion 25 pats.",           reward = 75,   prog = function(g) return g.stats.pats, 25 end },
}

function GO.init(g)
  g.stats = g.stats or {}
  local s = g.stats
  s.catches = s.catches or g.catches or 0
  for _, k in ipairs({ "night", "rain", "trophies", "streak", "bestStreak", "jumpers", "earned", "pats" }) do s[k] = s[k] or 0 end
  s.visited = s.visited or {}
  g.ach = g.ach or {}          -- id -> "done" (ready to claim) or "claimed"
  g.daily = g.daily or nil
end

-- check for newly finished goals; returns a list of names to announce
function GO.check(g)
  local new = {}
  for _, a in ipairs(GO.LIST) do
    if not g.ach[a.id] then
      local have, need = a.prog(g)
      if have >= need then g.ach[a.id] = "done"; new[#new + 1] = a.name end
    end
  end
  if g.daily then
    for _, r in ipairs(g.daily.list) do
      if not r.done and r.have >= r.need then r.done = true; new[#new + 1] = r.text end
    end
  end
  return new
end

function GO.ready(g)
  local n = 0
  for _, v in pairs(g.ach) do if v == "done" then n = n + 1 end end
  if g.daily then for _, r in ipairs(g.daily.list) do if r.done and not r.claimed then n = n + 1 end end end
  return n
end

-- three small requests for each new day, drawn from what lives where you are
function GO.newDay(g, day)
  local pool = {}
  for _, f in ipairs(FISH) do
    if f.loc == g.loc and not f.legend then pool[#pool + 1] = f end
  end
  local r = love.math.newRandomGenerator(day * 7919 + #g.loc)
  local list = {}
  local f = pool[r:random(#pool)]
  local n = r:random(2, 3)
  list[#list + 1] = { kind = "species", id = f.id, need = n, have = 0, reward = 30 + f.value * n,
                      text = "Catch " .. n .. " " .. f.name .. (n > 1 and "s" or "") }
  local n2 = r:random(4, 7)
  list[#list + 1] = { kind = "any", need = n2, have = 0, reward = 40 + n2 * 10, text = "Catch any " .. n2 .. " fish" }
  local f2 = pool[r:random(#pool)]
  local size = math.floor(f2.min + (f2.max - f2.min) * 0.6)
  list[#list + 1] = { kind = "size", id = f2.id, need = 1, have = 0, size = size, reward = 60 + f2.value * 2,
                      text = "Catch a " .. f2.name .. " over " .. size .. " cm" }
  g.daily = { day = day, loc = g.loc, list = list }
end

-- record a catch against the stats and today's requests
function GO.onCatch(g, f, size, ctx)
  local s = g.stats
  s.catches = s.catches + 1
  if ctx.night then s.night = s.night + 1 end
  if ctx.rain then s.rain = s.rain + 1 end
  if size >= f.min + (f.max - f.min) * 0.9 then s.trophies = s.trophies + 1 end
  if ctx.jumped then s.jumpers = s.jumpers + 1 end
  s.streak = s.streak + 1
  s.bestStreak = math.max(s.bestStreak, s.streak)
  if g.daily then
    for _, r in ipairs(g.daily.list) do
      if not r.done then
        if r.kind == "any" then r.have = r.have + 1
        elseif r.kind == "species" and r.id == f.id then r.have = r.have + 1
        elseif r.kind == "size" and r.id == f.id and size >= r.size then r.have = 1 end
      end
    end
  end
end

return GO
