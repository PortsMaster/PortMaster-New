-- The angler's look and the companion: options, and drawing them from layered art (art2/angler.py, art2/pets2.py).
local U = require("util")
local lg = love.graphics
local L = {}

L.POSE = nil -- filled in by L.load() from gfx/char/poses.lua

-- Options are plain features, freely combined. No presets, no labels by gender.
-- New entries are only ever added at the end of a list, so saved looks keep their meaning.
L.OPTIONS = {
  { key = "build", label = "BUILD",      list = { "1", "2", "3", "4" }, names = { "SLENDER", "AVERAGE", "STURDY", "BROAD" } },
  { key = "skin",  label = "SKIN TONE",  colors = "skin" },
  { key = "eyec",  label = "EYE COLOR",  colors = "eyes" },
  { key = "hair",  label = "HAIR",
    list = { "bald", "short", "long", "bun", "ponytail", "curly", "buzz", "sidepart", "spiky", "bob", "afro", "braid", "mullet", "mohawk" },
    names = { "NONE", "SHORT", "LONG", "BUN", "PONYTAIL", "CURLY", "BUZZ CUT", "SIDE PART", "SPIKY", "BOB", "AFRO", "BRAID", "MULLET", "MOHAWK" } },
  { key = "hairc", label = "HAIR COLOR", colors = "hair" },
  { key = "face",  label = "FACIAL HAIR",
    list = { "none", "beard", "mustache", "stubble", "goatee", "longbeard", "sideburns", "chinstrap" },
    names = { "NONE", "BEARD", "MUSTACHE", "STUBBLE", "GOATEE", "LONG BEARD", "SIDEBURNS", "CHIN STRAP" } },
  { key = "hat",   label = "HEADWEAR",
    list = { "none", "bucket", "beanie", "cap", "straw", "pompom", "trucker", "visor", "boonie", "cowboy", "trapper", "headband" },
    names = { "NONE", "BUCKET HAT", "BEANIE", "CAP", "STRAW HAT", "BOBBLE HAT", "TRUCKER CAP", "VISOR", "BOONIE HAT",
              "WIDE BRIM", "TRAPPER HAT", "HEADBAND" } },
  { key = "hatc",  label = "HAT COLOR",  colors = "cloth" },
  { key = "glasses", label = "GLASSES",  list = { "none", "round", "square", "shades", "aviators" },
    names = { "NONE", "ROUND", "SQUARE", "SUNGLASSES", "AVIATORS" } },
  { key = "top",   label = "TOP",
    list = { "jacket", "flannel", "hoodie", "sweater", "tshirt", "shirt", "fleece", "overalls" },
    names = { "RAIN JACKET", "FLANNEL", "HOODIE", "SWEATER", "T-SHIRT", "SHORT SLEEVE", "FLEECE", "OVERALLS" } },
  { key = "topc",  label = "TOP COLOR",  colors = "cloth" },
  { key = "vest",  label = "VEST",       list = { "none", "fishing", "life", "puffer" },
    names = { "NONE", "FISHING VEST", "LIFE JACKET", "PUFFER" } },
  { key = "vestc", label = "VEST COLOR", colors = "cloth" },
  { key = "neck",  label = "NECKWEAR",   list = { "none", "bandana", "scarf" }, names = { "NONE", "BANDANA", "SCARF" } },
  { key = "neckc", label = "NECK COLOR", colors = "cloth" },
  { key = "pants", label = "PANTS",      colors = "pants" },
  { key = "boots", label = "BOOTS",      colors = "boots" },
  { key = "pet",   label = "COMPANION",  list = { "none", "dog", "cat", "spitz", "longcat" },
    names = { "NONE", "RETRIEVER", "SHORTHAIR CAT", "SPITZ", "LONGHAIR CAT" } },
  { key = "coat",  label = "COAT",       colors = "coat" },
  { key = "mark",  label = "MARKINGS",   list = { "none", "white", "dark" }, names = { "NONE", "WHITE BIB", "SADDLE / TABBY" } },
}

L.COLORS = {
  skin = { { 0.98, 0.80, 0.66 }, { 0.93, 0.72, 0.58 }, { 0.80, 0.58, 0.42 }, { 0.64, 0.44, 0.30 }, { 0.47, 0.31, 0.21 },
           { 0.33, 0.22, 0.15 }, { 0.88, 0.66, 0.50 }, { 0.56, 0.38, 0.26 } },
  eyes = { { 0.36, 0.24, 0.14 }, { 0.30, 0.48, 0.70 }, { 0.32, 0.55, 0.36 }, { 0.50, 0.52, 0.56 }, { 0.52, 0.40, 0.22 }, { 0.15, 0.12, 0.10 } },
  hair = { { 0.22, 0.19, 0.20 }, { 0.45, 0.30, 0.19 }, { 0.66, 0.32, 0.19 }, { 0.94, 0.80, 0.48 }, { 0.74, 0.74, 0.76 },
           { 0.96, 0.95, 0.92 }, { 0.95, 0.55, 0.70 }, { 0.35, 0.72, 0.72 }, { 0.55, 0.45, 0.85 }, { 0.30, 0.22, 0.16 },
           { 0.80, 0.56, 0.30 } },
  cloth = { { 0.95, 0.58, 0.25 }, { 0.85, 0.30, 0.27 }, { 0.95, 0.82, 0.32 }, { 0.42, 0.64, 0.36 }, { 0.30, 0.62, 0.65 },
            { 0.38, 0.50, 0.82 }, { 0.60, 0.44, 0.78 }, { 0.92, 0.55, 0.68 }, { 0.62, 0.44, 0.30 }, { 0.62, 0.62, 0.66 },
            { 0.92, 0.88, 0.78 }, { 0.28, 0.28, 0.32 }, { 0.45, 0.50, 0.32 }, { 0.94, 0.82, 0.55 }, { 0.18, 0.26, 0.42 } },
  pants = { { 0.33, 0.42, 0.62 }, { 0.74, 0.64, 0.44 }, { 0.28, 0.28, 0.31 }, { 0.45, 0.50, 0.30 }, { 0.55, 0.38, 0.26 }, { 0.62, 0.62, 0.66 } },
  boots = { { 0.40, 0.30, 0.22 }, { 0.22, 0.22, 0.25 }, { 0.30, 0.42, 0.30 }, { 0.85, 0.75, 0.30 }, { 0.70, 0.25, 0.22 } },
  coat = { { 0.93, 0.73, 0.43 }, { 0.55, 0.36, 0.22 }, { 0.30, 0.29, 0.31 }, { 0.95, 0.93, 0.88 }, { 0.96, 0.63, 0.32 },
           { 0.62, 0.62, 0.66 }, { 0.78, 0.60, 0.42 } },
}

local DEFAULT = { build = 2, skin = 2, eyec = 1, hair = 2, hairc = 5, face = 2, hat = 2, hatc = 4, glasses = 1, top = 1, topc = 1,
                  vest = 1, vestc = 13, neck = 1, neckc = 2, pants = 1, boots = 1, pet = 2, coat = 1, mark = 1 }

function L.defaultLook()
  local t = {}
  for k, v in pairs(DEFAULT) do t[k] = v end
  return t
end

function L.count(opt)
  if opt.list then return #opt.list end
  return #L.COLORS[opt.colors]
end

local BYKEY = {}
for _, o in ipairs(L.OPTIONS) do BYKEY[o.key] = o end
L.BYKEY = BYKEY

-- fill in options an older save doesn't have, and keep every choice in range
function L.normalize(look)
  look = look or {}
  for _, o in ipairs(L.OPTIONS) do
    local v = tonumber(look[o.key]) or DEFAULT[o.key]
    if v < 1 or v > L.count(o) then v = DEFAULT[o.key] end
    look[o.key] = math.floor(v)
  end
  return look
end

function L.value(look, key)
  local o = BYKEY[key]
  if not o then return nil end
  if o.list then return o.list[look[key]] end
  return L.COLORS[o.colors][look[key]]
end

-- companion species, for its sounds
function L.species(kind)
  if kind == "dog" or kind == "spitz" then return "dog" end
  if kind == "cat" or kind == "longcat" then return "cat" end
  return "none"
end

local FW, FH = 40, 46
local NPOSE = 17

function L.load()
  L.POSE = love.filesystem.load("gfx/char/poses.lua")()
end

local function cs(name) return U.strip("gfx/char/" .. name .. ".png", NPOSE) end
local function ps(name) return U.strip("gfx/pets/" .. name .. ".png", 7) end

-- hats that sit low enough to hide the top of the hair (the art has a trimmed version of every hairstyle for these)
local TRIM = { bucket = true, beanie = true, cap = true, straw = true, pompom = true, trucker = true, boonie = true,
               cowboy = true, trapper = true }

-- the ordered list of layers (and their tints) for a look
local function layers(look)
  local v = function(k) return L.value(look, k) end
  local b = look.build
  local skin = v("skin")
  local hairc = v("hairc")
  local out = {
    { "body_" .. b, skin }, { "eyes" }, { "iris", v("eyec") },
    { "pants_" .. b, v("pants") }, { "boots_" .. b, v("boots") },
    { "top_" .. v("top") .. "_" .. b, v("topc") },
  }
  if v("top") == "overalls" then out[#out + 1] = { "bib_" .. b, v("pants") } end
  if v("vest") ~= "none" then out[#out + 1] = { "vest_" .. v("vest") .. "_" .. b, v("vestc") } end
  out[#out + 1] = { "hands_" .. b, skin }
  if v("neck") ~= "none" then out[#out + 1] = { "neck_" .. v("neck") .. "_" .. b, v("neckc") } end
  local hat = v("hat")
  local hair = v("hair")
  if hair ~= "bald" then out[#out + 1] = { "hair_" .. hair .. (TRIM[hat] and ("__" .. hat) or ""), hairc } end
  out[#out + 1] = { "brows", hairc }
  if v("face") ~= "none" then out[#out + 1] = { "face_" .. v("face"), hairc } end
  if v("glasses") ~= "none" then out[#out + 1] = { "glasses_" .. v("glasses") } end
  if hat ~= "none" then out[#out + 1] = { "hat_" .. hat, v("hatc") } end
  return out
end

-- the layer list only changes when the look does
local cache = { key = nil, list = nil }
local function cachedLayers(look)
  local parts = {}
  for _, o in ipairs(L.OPTIONS) do parts[#parts + 1] = look[o.key] or 0 end
  local key = table.concat(parts, ",")
  if cache.key ~= key then cache.key, cache.list = key, layers(look) end
  return cache.list
end

-- draw the angler: every outline first, then every fill, so outlines stay outside.
-- x, y is the top-left of the frame (as if facing right); flip mirrors it in place.
function L.drawAngler(look, x, y, pose, light, flip, sc)
  light = light or { 1, 1, 1 }
  local frame = (L.POSE[pose] or L.POSE.idle).frame
  local ls = cachedLayers(look)
  lg.setColor(light[1] * 0.9, light[2] * 0.9, light[3] * 0.9)
  for _, l in ipairs(ls) do U.drawStrip(cs(l[1] .. "_ol"), frame, x, y, flip, sc, sc) end
  for _, l in ipairs(ls) do
    local c = l[2] or { 1, 1, 1 }
    lg.setColor(c[1] * light[1], c[2] * light[2], c[3] * light[3])
    U.drawStrip(cs(l[1]), frame, x, y, flip, sc, sc)
  end
end

-- pet frames: 1 sit, 2 tail, 3 blink, 4 speak, 5 happy, 6 sleep, 7 sleep2
function L.drawPet(kind, coatIdx, x, y, frame, light, flip, sc, mark)
  if kind == "none" or not kind then return end
  light = light or { 1, 1, 1 }
  local c = L.COLORS.coat[coatIdx] or L.COLORS.coat[1]
  lg.setColor(light[1] * 0.9, light[2] * 0.9, light[3] * 0.9)
  U.drawStrip(ps(kind .. "_ol"), frame, x, y, flip, sc, sc)
  lg.setColor(c[1] * light[1], c[2] * light[2], c[3] * light[3])
  U.drawStrip(ps(kind), frame, x, y, flip, sc, sc)
  if mark == 3 then
    lg.setColor(c[1] * light[1] * 0.55, c[2] * light[2] * 0.55, c[3] * light[3] * 0.55)
    U.drawStrip(ps(kind .. "_dark"), frame, x, y, flip, sc, sc)
  elseif mark == 2 then
    lg.setColor(light[1], light[2], light[3])
    U.drawStrip(ps(kind .. "_white"), frame, x, y, flip, sc, sc)
  end
  lg.setColor(math.max(0.5, light[1]), math.max(0.5, light[2]), math.max(0.5, light[3]))
  U.drawStrip(ps(kind .. "_fx"), frame, x, y, flip, sc, sc)
end

L.FW, L.FH = FW, FH
return L
