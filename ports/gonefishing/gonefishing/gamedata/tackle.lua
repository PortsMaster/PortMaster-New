-- The Tackle Box: the game's menu. It slides up, the lid swings open into a page,
-- and two cantilever trays fan out with a compartment for each section.
-- L / R (or Left / Right on the trays) move between sections.
local U = require("util")
local UI = require("ui")
local L = require("look")
local FD = require("fishdraw")
local GR = require("gear")
local GO = require("goals")
local lg = love.graphics
local fl, clamp = U.fl, U.clamp

local T = {}

local TABS = {
  { id = "cooler", name = "Cooler" }, { id = "shop", name = "Shop" }, { id = "gear", name = "Gear" },
  { id = "goals", name = "Goals" }, { id = "log", name = "Logbook" }, { id = "map", name = "Map" },
  { id = "look", name = "Look" }, { id = "settings", name = "Settings" },
}
T.TABS = TABS
local SECTIONS = { { id = "rod", name = "Rods" }, { id = "line", name = "Lines" }, { id = "lure", name = "Lures" }, { id = "bobber", name = "Floats" },
                   { id = "cooler", name = "Coolers" }, { id = "boat", name = "Boats" }, { id = "motor", name = "Motors" } }
local ACTIONS = { { id = "cast", name = "Cast / reel / keep" }, { id = "fast", name = "Reel fast / release" },
                  { id = "pet", name = "Pet companion" }, { id = "box", name = "Open tackle box" },
                  { id = "motor", name = "Trolling motor" } }
local VOLS = { { key = "master", name = "Volume" }, { key = "music", name = "Music" },
               { key = "sfx", name = "Sound effects" }, { key = "amb", name = "Nature sounds" } }
local BUTTONS = { a = "A", b = "B", x = "X", y = "Y", l = "L", r = "R", select = "SELECT", start = "START" }

local INK = { 0.25, 0.18, 0.12 }
local INK_L = { 0.48, 0.40, 0.30 }
local INK_G = { 0.16, 0.38, 0.26 }
local RED = { 0.66, 0.22, 0.16 }
local SEL = { 0.95, 0.80, 0.42 }

local BX, BODY_Y, HINGE = 40, 226, 230
local PX0, PY0, PX1, PY1 = 64, 30, 448, 214

local s = { open = 0, want = false, tab = 1, focus = "tabs", sel = {}, section = { shop = 1, gear = 1 },
            logLoc = nil, msg = nil, msgT = 0, bounce = 0, sub = nil, capture = nil }
T.state = s

function T.setTab(i) s.tab = i; s.focus = "tabs" end
function T.isOpen() return s.want or s.open > 0 end

function T.open()
  if s.want then return end
  s.want, s.focus, s.sub, s.capture = true, "tabs", nil, nil
  s.logLoc = G.game.loc
  G.play("latch")
end

function T.close()
  if not s.want then return end
  s.want = false
  G.play("lid", 0.85)
end

local function flash(msg) s.msg, s.msgT = msg, 2.2 end
T.flash = flash

local function sel(id, n)
  local v = s.sel[id] or 1
  if n then v = clamp(v, 1, math.max(1, n)); s.sel[id] = v end
  return v
end

-- the items listed in a shop or gear section
local function sectionItems(tab, sec)
  local g = G.game
  local out = {}
  local function add(kind, key, item)
    local owned = g.owned[kind][key]
    if tab == "shop" or owned then out[#out + 1] = { kind = kind, key = key, item = item, owned = owned } end
  end
  if sec == "rod" then for i, it in ipairs(GR.RODS) do add("rod", i, it) end
  elseif sec == "line" then for i, it in ipairs(GR.LINES) do add("line", i, it) end
  elseif sec == "lure" then for _, it in ipairs(GR.LURES) do add("lure", it.id, it) end
  elseif sec == "cooler" then for i, it in ipairs(GR.COOLERS) do add("cooler", i, it) end
  elseif sec == "motor" then for i, it in ipairs(GR.MOTORS) do add("motor", i, it) end
  elseif sec == "bobber" then for i, it in ipairs(GR.BOBBERS) do add("bobber", i, it) end
  else for _, it in ipairs(GR.BOATS) do add("boat", it.key, it) end end
  return out
end

local function goalRows()
  local g = G.game
  local rows = {}
  if g.daily then
    for i, r in ipairs(g.daily.list) do rows[#rows + 1] = { daily = true, idx = i, r = r } end
  end
  for _, a in ipairs(GO.LIST) do rows[#rows + 1] = { a = a } end
  return rows
end

local function rowsFor(id)
  local g = G.game
  if id == "cooler" then return #g.cooler end
  if id == "shop" or id == "gear" then return #sectionItems(id, SECTIONS[s.section[id]].id) end
  if id == "goals" then return #goalRows() end
  if id == "log" then return #G.fishAt(s.logLoc) end
  if id == "map" then return #G.LOCS end
  if id == "look" then return #L.OPTIONS end
  if id == "settings" then return s.sub == "controls" and #ACTIONS + 2 or s.sub == "exit" and 3 or 7 end
  return 0
end

local function equipped(kind, key)
  local g = G.game
  if kind == "boat" then return g.boat == key end
  return g.equip[kind] == key
end

function T.update(dt, pressed)
  local was = s.open
  local speed = 1 / 0.75
  if s.want then s.open = math.min(1, s.open + dt * speed) else s.open = math.max(0, s.open - dt * speed * 1.4) end
  if s.want and was < 0.35 and s.open >= 0.35 then G.play("lid") end
  if s.want and was < 0.7 and s.open >= 0.7 then G.play("click") end
  s.msgT = math.max(0, s.msgT - dt)
  s.bounce = s.bounce + dt
  if not s.want or s.open < 0.7 then return end
  local g = G.game
  -- waiting for a button to bind to an action
  if s.capture then
    if s.captureDelay > 0 then s.captureDelay = s.captureDelay - 1; return end
    for btn in pairs(BUTTONS) do
      if pressed[btn] then
        local old = g.binds[s.capture]
        for k, v in pairs(g.binds) do if v == btn then g.binds[k] = old end end   -- swap if taken
        g.binds[s.capture] = btn
        s.capture = nil
        G.play("buy")
        flash("Saved.")
        G.api.save()
        return
      end
    end
    return
  end
  local tab = TABS[s.tab].id
  if pressed.start or (g.binds.box ~= "start" and pressed[g.binds.box]) then T.close(); return end
  if pressed.l or pressed.r then
    s.tab = pressed.l and (s.tab - 2) % #TABS + 1 or s.tab % #TABS + 1
    s.sub = nil; s.bounce = 0
    G.play("blip")
    return
  end
  if s.focus == "tabs" then
    if pressed.left then s.tab = (s.tab - 2) % #TABS + 1; G.play("blip"); s.bounce = 0 end
    if pressed.right then s.tab = s.tab % #TABS + 1; G.play("blip"); s.bounce = 0 end
    if pressed.a or pressed.down or pressed.up then
      if rowsFor(tab) > 0 or tab == "log" or tab == "shop" or tab == "gear" then s.focus = "page"; G.play("click") end
    elseif pressed.b or pressed.start then T.close() end
    return
  end
  -- page focus
  if pressed.b then
    if s.sub then s.sub = nil else s.focus = "tabs" end
    G.play("click")
    return
  end
  local n = rowsFor(tab)
  local key = tab .. (s.sub or "") .. ((tab == "shop" or tab == "gear") and s.section[tab] or "")
  local i = sel(key, n)
  if pressed.up then
    if i == 1 and tab ~= "look" and not s.sub then s.focus = "tabs" else s.sel[key] = (i - 2) % math.max(1, n) + 1 end
    G.play("blip")
  end
  if pressed.down then s.sel[key] = i % math.max(1, n) + 1; G.play("blip") end
  i = sel(key, n)
  if tab == "cooler" then
    if pressed.a and n > 0 then G.api.sell(i); sel(key, #g.cooler) end
    if pressed.x and n > 0 then G.api.sellAll() end
    if #g.cooler == 0 then s.focus = "tabs" end
  elseif tab == "shop" or tab == "gear" then
    if pressed.left or pressed.right then
      s.section[tab] = (s.section[tab] - 1 + (pressed.left and -1 or 1)) % #SECTIONS + 1
      G.play("blip")
    elseif pressed.a and n > 0 then
      local it = sectionItems(tab, SECTIONS[s.section[tab]].id)[i]
      if tab == "shop" and not it.owned then G.api.buy(it.kind, it.key)
      elseif equipped(it.kind, it.key) then flash("Already in use.")
      else G.api.equip(it.kind, it.key) end
    end
  elseif tab == "goals" then
    if pressed.a then
      local row = goalRows()[i]
      if row then
        if row.daily then G.api.claim("daily", row.idx) else G.api.claim("ach", row.a.id) end
      end
    end
  elseif tab == "log" then
    if pressed.left or pressed.right then
      local idx = G.LOCBY[s.logLoc].index
      for _ = 1, #G.LOCS do
        idx = pressed.left and (idx - 2) % #G.LOCS + 1 or idx % #G.LOCS + 1
        if g.unlocked[G.LOCS[idx].id] then break end
      end
      s.logLoc = G.LOCS[idx].id
      s.sel.log = 1
      G.play("blip")
    end
  elseif tab == "map" then
    if pressed.a then G.api.travel(G.LOCS[i].id) end
  elseif tab == "look" then
    local o = L.OPTIONS[i]
    if pressed.left or pressed.right or pressed.a then
      local c = L.count(o)
      g.look[o.key] = (g.look[o.key] - 1 + (pressed.left and -1 or 1)) % c + 1
      G.play("click")
      if o.key == "pet" or o.key == "coat" or o.key == "mark" then G.api.petHello() end
    end
  elseif tab == "settings" and s.sub == "controls" then
    if i == 1 and (pressed.a or pressed.left or pressed.right) then
      -- swap A/B and X/Y for devices whose buttons are labelled the other way round
      G.prefs.swapButtons = not G.prefs.swapButtons
      G.savePrefs()
      flash(G.prefs.swapButtons and "A/B and X/Y swapped." or "Standard button layout.")
      G.play("click")
    elseif pressed.a then
      if i - 1 <= #ACTIONS then s.capture, s.captureDelay = ACTIONS[i - 1].id, 2; G.play("click")
      else
        g.binds = { cast = "a", fast = "b", pet = "x", box = "start", motor = "y" }
        G.prefs.swapButtons = false; G.savePrefs()
        flash("Buttons reset."); G.play("buy")
      end
    end
  elseif tab == "settings" and s.sub == "exit" then
    if pressed.a then
      if i == 1 then G.api.saveFlow("save")
      elseif i == 2 then s.sub = nil; G.api.saveFlow("title")
      else G.api.saveFlow("quit") end
    end
  elseif tab == "settings" then
    local vk = VOLS[i - 1]
    if vk then
      -- volume rows: left and right change the level, A steps it up and wraps round
      if pressed.left or pressed.right or pressed.a then
        local v = g.vol[vk.key]
        if pressed.left then v = math.max(0, v - 1) elseif pressed.right then v = math.min(10, v + 1) else v = (v + 1) % 11 end
        g.vol[vk.key] = v
        G.api.applyVolume()
        G.play("click")
      end
    elseif pressed.a or ((pressed.left or pressed.right) and i == 1) then
      if i == 1 then g.idle = not g.idle; G.play("click")
      elseif i == 6 then s.sub = "controls"; G.play("click")
      elseif i == 7 then s.sub = "exit"; G.play("click") end
    end
  end
end

---------------------------------------------------------------- drawing helpers
local function wrap(text, x, y, c, maxw)
  local line = ""
  for word in text:gmatch("%S+") do
    if line ~= "" and UI.width(line .. " " .. word, 2) > maxw then
      UI.text(line, x, y, c, 2); y = y + 12; line = word
    else line = line == "" and word or line .. " " .. word end
  end
  if line ~= "" then UI.text(line, x, y, c, 2) end
  return y
end

local function header(title, right)
  UI.text(title, PX0, PY0, INK_G, 3)
  if right then UI.text(right, PX1, PY0 + 4, INK_L, 2, "right") end
  lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.5)
  for x = PX0, PX1, 4 do lg.rectangle("fill", x, PY0 + 20, 2, 1) end
end

local function rowBox(y, h, on)
  if on and s.focus == "page" then
    lg.setColor(SEL[1], SEL[2], SEL[3], 0.55)
    lg.rectangle("fill", PX0 - 6, y - 2, PX1 - PX0 + 12, h, 3, 3)
    lg.setColor(0.55, 0.40, 0.16)
    lg.rectangle("line", PX0 - 6 + 0.5, y - 2 + 0.5, PX1 - PX0 + 11, h - 1, 3, 3)
  end
end

local function pips(x, y, lvl, max)
  for k = 1, max do
    if k <= lvl then lg.setColor(INK_G) else lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.35) end
    lg.rectangle("fill", x + (k - 1) * 9, y, 7, 7, 2, 2)
  end
end

local function price(x, y, cost, align)
  local can = G.game.coins >= cost
  local w = UI.width(cost, 2)
  if align == "right" then x = x - w - 11 end
  UI.coin(x, y + 1)
  UI.text(cost, x + 11, y, can and INK or RED, 2)
end

local function bar(x, y, w, f)
  lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.3); lg.rectangle("fill", x, y, w, 6, 2, 2)
  lg.setColor(INK_G); lg.rectangle("fill", x, y, fl(w * clamp(f, 0, 1)), 6, 2, 2)
end

local function scrollList(n, i, per)
  return clamp(i - math.floor(per / 2), 1, math.max(1, n - per + 1))
end

local function itemIcon(kind, key, x, y, t)
  lg.setColor(1, 1, 1)
  if kind == "boat" then
    local bm = G.BOATS[key]
    local strip = U.grid("gfx/boat/" .. key .. ".png", bm.w, bm.h, bm.cols, bm.frames)
    local sc = 40 / bm.w
    U.drawStrip(strip, 1, x, y + 14 - bm.oy * sc, false, sc, sc)
  else
    local name = kind == "lure" and ("icon_lure_" .. key) or ("icon_" .. kind .. key)
    lg.draw(U.img("gfx/items/" .. name .. ".png"), x, y)
  end
end

---------------------------------------------------------------- pages
local function pageCooler(t)
  local g = G.game
  local cap = GR.COOLERS[g.equip.cooler].cap
  header("Cooler", #g.cooler .. " / " .. cap)
  if #g.cooler == 0 then
    UI.text("The cooler is empty.", (PX0 + PX1) / 2, 100, INK_L, 2, "center")
    UI.text("Go catch something!", (PX0 + PX1) / 2, 116, INK_L, 2, "center")
    return
  end
  local i = sel("cooler", #g.cooler)
  local per = 7
  local first = scrollList(#g.cooler, i, per)
  local total = 0
  for _, c in ipairs(g.cooler) do total = total + G.api.value(c) end
  for k = first, math.min(#g.cooler, first + per - 1) do
    local c = g.cooler[k]
    local f = G.FISHBY[c.id]
    local y = PY0 + 28 + (k - first) * 22
    rowBox(y, 21, k == i)
    local sc = math.min(1, 34 / f.fw, 18 / f.fh)
    FD.icon(f, PX0 + 18 - f.fw * sc / 2, y + 8 - f.fh * sc / 2, sc)
    UI.text(f.name, PX0 + 42, y + 2, INK, 2)
    UI.text(c.size .. " cm", PX0 + 250, y + 2, INK_L, 2)
    price(PX1, y + 2, G.api.value(c), "right")
  end
  UI.hints({ { "A", "Sell" }, { "X", "Sell all (" .. total .. ")" } }, PX0, PY1 - 14, INK)
end

local function statLine(it)
  local d = it.item
  if it.kind == "rod" then return "Reel speed", it.key
  elseif it.kind == "line" then return "Strength", it.key
  elseif it.kind == "cooler" then return "Holds " .. d.cap .. " fish"
  elseif it.kind == "boat" then return "Speed", ({ rowboat = 1, skiff = 3, workboat = 5 })[it.key]
  elseif it.kind == "bobber" then
    return it.key == 1 and "Lure only" or "Holds bait at a depth"
  elseif it.kind == "motor" then
    if it.key == 1 then return "Oars or engine" end
    return it.item.auto and "Speed, auto troll" or "Speed", it.key == 2 and 2 or 4
  else return "Lure power", math.floor(d.attract * 2.5 + 0.5) - 1 end
end

local function pageItems(tab, t)
  local g = G.game
  header(tab == "shop" and "Shop" or "Gear", tab == "gear" and "Pick what to use" or nil)
  -- the section strip
  local x = PX0
  for k, sec in ipairs(SECTIONS) do
    local on = k == s.section[tab]
    local w = UI.width(sec.name, 2) + 8
    if on then
      lg.setColor(INK_G); lg.rectangle("fill", x, PY0 + 25, w, 13, 3, 3)
      UI.text(sec.name, x + 5, PY0 + 27, { 0.92, 0.9, 0.8 }, 2)
    else
      UI.text(sec.name, x + 5, PY0 + 27, INK_L, 2)
    end
    x = x + w + 2
  end
  local items = sectionItems(tab, SECTIONS[s.section[tab]].id)
  local key = tab .. s.section[tab]
  if #items == 0 then
    UI.text("Nothing here yet.", (PX0 + PX1) / 2, 110, INK_L, 2, "center")
    return
  end
  local i = sel(key, #items)
  local per = 4
  local first = scrollList(#items, i, per)
  for k = first, math.min(#items, first + per - 1) do
    local it = items[k]
    local y = PY0 + 42 + (k - first) * 28
    rowBox(y, 27, k == i)
    itemIcon(it.kind, it.key, PX0, y, t)
    UI.text(it.item.name, PX0 + 48, y + 2, INK, 2)
    local label, lvl = statLine(it)
    UI.text(label, PX0 + 48, y + 13, INK_L, 2)
    if lvl then pips(PX0 + 48 + UI.width(label, 2) + 8, y + 15, lvl, 5) end
    if equipped(it.kind, it.key) then UI.text("In use", PX1, y + 8, INK_G, 2, "right")
    elseif it.owned then UI.text(tab == "shop" and "Owned" or "Use", PX1, y + 8, INK_L, 2, "right")
    else price(PX1, y + 8, it.item.cost, "right") end
  end
  if #items > per then
    lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.5)
    lg.rectangle("fill", PX1 + 3, PY0 + 42 + (first - 1) / #items * 112, 2, per / #items * 112)
  end
  local it = items[i]
  wrap(it.item.desc, PX0, PY1 - 22, INK_L, PX1 - PX0)
end

local function pageGoals(t)
  local g = G.game
  local rows = goalRows()
  local done = 0
  for _, a in ipairs(GO.LIST) do if g.ach[a.id] then done = done + 1 end end
  header("Goals", done .. " / " .. #GO.LIST)
  local i = sel("goals", #rows)
  local per = 6
  local first = scrollList(#rows, i, per)
  for k = first, math.min(#rows, first + per - 1) do
    local row = rows[k]
    local y = PY0 + 26 + (k - first) * 22
    rowBox(y, 21, k == i)
    local name, have, need, reward, state
    if row.daily then
      local r = row.r
      name, have, need, reward = r.text, r.have, r.need, r.reward
      state = r.claimed and "claimed" or (r.done and "done" or nil)
      UI.text("Today", PX0, y + 2, INK_G, 1)
    else
      local a = row.a
      have, need = a.prog(g)
      name, reward, state = a.name, a.reward, g.ach[a.id]
    end
    UI.text(name, PX0 + 22, y + 2, state == "claimed" and INK_L or INK, 2)
    if state == "done" then
      local pulse = 0.6 + 0.4 * math.sin(t * 6)
      UI.text("Claim!", PX1 - 64, y + 2, { 0.66 * pulse + 0.2, 0.22, 0.16 }, 2, "right")
    elseif state == "claimed" then
      UI.text("Done", PX1 - 64, y + 2, INK_G, 2, "right")
    else
      bar(PX1 - 130, y + 5, 64, have / need)
    end
    price(PX1, y + 2, reward, "right")
  end
  local row = rows[i]
  if row then
    local text
    if row.daily then text = "A request for today. New ones arrive each morning."
    else local have, need = row.a.prog(g); text = row.a.desc .. "  (" .. math.min(have, need) .. " / " .. need .. ")" end
    wrap(text, PX0, PY1 - 20, INK_L, PX1 - PX0)
  end
end

local function pageLog(t)
  local g = G.game
  local L0 = G.LOCBY[s.logLoc]
  local list = G.fishAt(s.logLoc)
  local got = 0
  for _, f in ipairs(list) do if g.log[f.id] then got = got + 1 end end
  header("Logbook", got .. " / " .. #list)
  UI.text("< " .. L0.name .. " >", (PX0 + PX1) / 2, PY0 + 26, INK, 2, "center")
  local i = sel("log", #list)
  local per = 5
  local first = scrollList(#list, i, per)
  for k = first, math.min(#list, first + per - 1) do
    local f = list[k]
    local y = PY0 + 42 + (k - first) * 22
    rowBox(y, 21, k == i)
    local e = g.log[f.id]
    local sc = math.min(1, 34 / f.fw, 18 / f.fh)
    if e then FD.icon(f, PX0 + 18 - f.fw * sc / 2, y + 8 - f.fh * sc / 2, sc)
    else FD.icon(f, PX0 + 18 - f.fw * sc / 2, y + 8 - f.fh * sc / 2, sc, { 0.30, 0.24, 0.18 }, 0.6) end
    UI.text(e and f.name or "???", PX0 + 42, y + 2, e and INK or INK_L, 2)
    if e then
      UI.text("Best " .. e.best .. " cm", PX0 + 230, y + 2, INK_L, 2)
      UI.text("x" .. e.n, PX1, y + 2, INK_L, 2, "right")
    end
  end
  local f = list[i]
  if f then
    local hint
    if g.log[f.id] then
      hint = (f.time == "night" and "Bites at night" or f.time == "day" and "Bites by day" or "Bites any time")
        .. (f.zone[1] > 0.6 and ", near the bottom. " or f.zone[2] < 0.5 and ", near the top. " or ", in mid water. ")
        .. GR.likesText(f.id)
    elseif f.legend then
      local req = GR.LIKES[f.id] and GR.LIKES[f.id].req
      hint = "Something big lurks here. They say it only takes a " .. (req and GR.LURE[req].name or "special lure") .. "."
    else
      hint = "Not caught yet."
    end
    wrap(hint, PX0, PY1 - 24, INK_L, PX1 - PX0)
  end
end

local function pageMap(t)
  local g = G.game
  header("Map")
  local i = sel("map", #G.LOCS)
  local step = #G.LOCS > 4 and 31 or 38
  for k, l in ipairs(G.LOCS) do
    local y = PY0 + 28 + (k - 1) * step
    rowBox(y, step - 3, k == i)
    lg.setColor(l.tint[1], l.tint[2], l.tint[3])
    lg.rectangle("fill", PX0, y + 2, 22, 22, 4, 4)
    lg.setColor(1, 1, 1, 0.5)
    lg.rectangle("fill", PX0 + 3, y + 7, 16, 2); lg.rectangle("fill", PX0 + 7, y + 14, 10, 2)
    UI.text(l.name, PX0 + 32, y + 1, g.unlocked[l.id] and INK or INK_L, 2)
    UI.text(l.blurb, PX0 + 32, y + 14, INK_L, 2)
    if g.loc == l.id then UI.text("Here", PX1, y + 2, INK_G, 2, "right")
    elseif g.unlocked[l.id] then UI.text("Go", PX1, y + 2, INK, 2, "right")
    else price(PX1, y + 2, l.cost, "right") end
  end
end

local LOOK_FOCUS = {
  skin = "head", eyec = "head", hair = "head", hairc = "head", face = "head", hat = "head", hatc = "head",
  glasses = "head", build = "upper", top = "upper", topc = "upper", vest = "upper", vestc = "upper",
  neck = "head", neckc = "head", pants = "legs", boots = "legs", pet = "pet", coat = "pet", mark = "pet",
}
local function pageLook(t)
  local g = G.game
  header("Look")
  local n = #L.OPTIONS
  local i = sel("look", n)
  -- a scrolling window of rows
  local ROWS = 11
  local top = math.max(1, math.min(i - 5, n - ROWS + 1))
  for k = top, math.min(n, top + ROWS - 1) do
    local o = L.OPTIONS[k]
    local y = PY0 + 25 + (k - top) * 14
    if k == i and s.focus == "page" then
      lg.setColor(SEL[1], SEL[2], SEL[3], 0.55)
      lg.rectangle("fill", PX0 - 6, y - 2, 250, 14, 3, 3)
    end
    UI.text(o.label, PX0, y, INK_L, 2)
    local v = g.look[o.key]
    if o.list then
      UI.text("< " .. o.names[v] .. " >", PX0 + 236, y, INK, 2, "right")
    else
      local c = L.COLORS[o.colors][v]
      UI.text("<", PX0 + 196, y, INK, 2)
      lg.setColor(0.2, 0.15, 0.1); lg.rectangle("fill", PX0 + 205, y - 1, 20, 12, 2, 2)
      lg.setColor(c); lg.rectangle("fill", PX0 + 206, y, 18, 10, 2, 2)
      UI.text(">", PX0 + 230, y, INK, 2)
    end
  end
  -- scroll bar
  local bh = ROWS * 14 - 4
  lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.25)
  lg.rectangle("fill", PX0 + 246, PY0 + 23, 3, bh, 1, 1)
  lg.setColor(INK_L[1], INK_L[2], INK_L[3], 0.8)
  local th = bh * ROWS / n
  lg.rectangle("fill", PX0 + 246, PY0 + 23 + (bh - th) * (top - 1) / math.max(1, n - ROWS), 3, th, 1, 1)
  local cx = PX0 + 320
  -- the preview eases in toward whatever is being changed: the head for hair, hats, glasses and faces,
  -- the body for clothes, the feet for boots, the companion for pet options
  local GY = PY0 + 166                                 -- the ground line the angler and pet sit on
  local ax, ay = PX0 + 254, GY - 46 * 2 + 2
  local px, py = PX0 + 330, GY - 28 * 2 + 2
  local VX, VY = PX0 + 333, PY0 + 104                  -- the middle of the preview area
  local FOCUS = {
    head = { ax + 42, ay + 16, 2.0 }, upper = { ax + 40, ay + 44, 1.45 }, legs = { ax + 50, ay + 74, 1.5 },
    pet = { px + 32, py + 28, 1.7 }, all = { VX, VY, 1 },
  }
  local want = FOCUS[s.focus == "page" and (LOOK_FOCUS[L.OPTIONS[i].key] or "all") or "all"]
  local lz = s.lookZoom or { x = VX, y = VY, z = 1 }
  s.lookZoom = lz
  local k = math.min(1, love.timer.getDelta() * 7)
  lz.x, lz.y, lz.z = lz.x + (want[1] - lz.x) * k, lz.y + (want[2] - lz.y) * k, lz.z + (want[3] - lz.z) * k
  lg.push("all")
  lg.setScissor(PX0 + 252, PY0 + 16, PX1 + 26 - (PX0 + 252), PY1 - (PY0 + 16))
  lg.translate(VX, VY)
  lg.scale(lz.z)
  lg.translate(-lz.x, -lz.y)
  lg.setColor(0.80, 0.75, 0.62)
  lg.ellipse("fill", PX0 + 330, GY, 74, 7)
  local blink = (t % 3.5) < 0.12
  L.drawAngler(g.look, ax, ay, blink and "idle_blink" or "idle", nil, false, 2)
  local pet = L.value(g.look, "pet")
  if pet ~= "none" then
    local fr = ((t * 1.6) % 4 < 1) and 2 or 1
    L.drawPet(pet, g.look.coat, px, py, fr, nil, true, 2, g.look.mark)
  end
  lg.pop()
end

local function pageSettings(t)
  local g = G.game
  if s.sub == "controls" then
    header("Controls", "B: back")
    local i = sel("settingscontrols", #ACTIONS + 2)
    do
      local y = PY0 + 26
      rowBox(y, 15, i == 1)
      UI.text("Button layout", PX0 + 4, y + 2, INK, 2)
      UI.text(G.prefs.swapButtons and "< Swapped >" or "< Standard >", PX1 - 4, y + 2, INK_G, 2, "right")
    end
    for k, a in ipairs(ACTIONS) do
      local y = PY0 + 26 + k * 17
      rowBox(y, 15, k + 1 == i)
      UI.text(a.name, PX0 + 4, y + 2, INK, 2)
      if s.capture == a.id then
        UI.text("Press a button...", PX1, y + 2, RED, 2, "right")
      else
        UI.button(BUTTONS[g.binds[a.id]] or "?", PX1 - UI.width(BUTTONS[g.binds[a.id]] or "?", 2) - 10, y + 1)
      end
    end
    local y = PY0 + 26 + (#ACTIONS + 1) * 17
    rowBox(y, 15, i == #ACTIONS + 2)
    UI.text("Reset to default", PX0 + 4, y + 2, INK, 2)
    wrap(i == 1 and "If A and B (or X and Y) feel the wrong way round on your device, swap them here."
         or "Pick an action and press A, then press the button you want for it.",
         PX0, PY1 - 32, INK_L, PX1 - PX0)
    return
  end
  header("Settings", g.name and ("Save " .. (G.slot or 1) .. ": " .. g.name) or nil)
  if s.sub == "exit" then
    -- Save and exit: everything that leaves the water in one place
    local i = sel("settingsexit", 3)
    local rows = { "Save now", "Exit to title", "Quit game" }
    local notes = { "Your progress is also saved as you play.",
                    "Saves, then back to the title to pick a save.",
                    "Saves and closes the game. See you on the water." }
    for k, r in ipairs(rows) do
      local y = PY0 + 30 + (k - 1) * 22
      rowBox(y, 20, k == i)
      UI.text(r, PX0 + 4, y + 3, INK, 2)
    end
    wrap(notes[i], PX0, PY1 - 20, INK_L, PX1 - PX0)
    return
  end
  local i = sel("settings", 7)
  local rows = { "Idle fishing: " .. (g.idle and "on" or "off"), VOLS[1].name, VOLS[2].name,
                 VOLS[3].name, VOLS[4].name, "Controls  >", "Save and exit  >" }
  for k, r in ipairs(rows) do
    local y = PY0 + 24 + (k - 1) * 15
    rowBox(y, 14, k == i)
    UI.text(r, PX0 + 4, y + 1, INK, 2)
    local vk = VOLS[k - 1]
    if vk then
      -- a level meter of ten steps
      local v = g.vol[vk.key]
      local x0 = PX1 - 128
      if k == i then UI.text("<", x0 - 12, y + 1, INK, 2); UI.text(">", PX1 - 4, y + 1, INK, 2, "right") end
      for n = 1, 10 do
        local on = n <= v
        lg.setColor(on and INK_G or { INK_L[1], INK_L[2], INK_L[3], 0.3 })
        local bh = 4 + n * 0.7
        lg.rectangle("fill", x0 + (n - 1) * 10, y + 12 - bh, 7, bh, 1, 1)
      end
      UI.text(v == 0 and "off" or tostring(v * 10) .. "%", x0 - 18, y + 1, INK_L, 2, "right")
    end
  end
  local notes = {
    "When idle, you fish on your own and sell when the cooler is full.",
    "How loud everything is.",
    "Quiet tunes for each place, shuffled, calmer at night.",
    "The reel, splashes, bites, your boat and your pet.",
    "Birds, wind, water, rain and crickets around you.",
    "Choose which button does what.",
    "Save, change saves, or quit.",
  }
  local played = math.floor((g.playTime or 0) / 60)
  UI.text("Fish caught: " .. (g.stats.catches or 0) .. "    Time on the water: " .. played .. " min", PX0, PY1 - 36, INK_G, 2)
  UI.text("v" .. G.VERSION, PX1, PY1 - 36, INK_L, 2, "right")
  wrap(notes[i], PX0, PY1 - 20, INK_L, PX1 - PX0)
end

local PAGES = { cooler = pageCooler, shop = function(t) pageItems("shop", t) end, gear = function(t) pageItems("gear", t) end,
                goals = pageGoals, log = pageLog, map = pageMap, look = pageLook, settings = pageSettings }

local ICONQ = {}
for i = 1, 8 do ICONQ[i] = lg.newQuad((i - 1) * 32, 0, 32, 24, 256, 24) end

local CW = 48
local TRAYS = { { img = "tb_tray4", n = 4, x = 46, from = 1 }, { img = "tb_tray4", n = 4, x = 262, from = 5 } }

function T.draw(t)
  if s.open <= 0 then return end
  local o = s.open
  lg.setColor(0.02, 0.03, 0.06, 0.45 * U.easeOutCubic(o / 0.35))
  lg.rectangle("fill", 0, 0, U.W, U.H)
  local slide = U.easeOutBack(clamp(o / 0.35, 0, 1))
  local dy = (1 - slide) * 200
  local bodyY = BODY_Y + dy
  local hinge = HINGE + dy
  local body = U.img("gfx/ui/tb_body.png")
  local lid = U.img("gfx/ui/tb_lid.png")
  local lidIn = U.img("gfx/ui/tb_lid_in.png")
  local lp = U.easeInOutSine(clamp((o - 0.3) / 0.4, 0, 1))
  if lp < 0.5 then
    local k = 1 - lp * 2
    lg.setColor(1, 1, 1)
    lg.draw(lid, BX, hinge - 40 * k, 0, 1, k)
  else
    local k = (lp - 0.5) * 2
    local h = 222 * U.easeOutBack(k)
    local shade = 0.7 + 0.3 * k
    lg.setColor(shade, shade, shade)
    lg.draw(lidIn, BX, hinge - h, 0, 1, h / 222)
  end
  if o >= 0.7 then
    local a = clamp((o - 0.7) / 0.15, 0, 1)
    lg.push("all")
    lg.setScissor(BX + 12, 8 + 12 + dy, 432 - 24, 222 - 24)
    local pg = PAGES[TABS[s.tab].id]
    if pg then pg(t) end
    lg.pop()
    if a < 1 then
      lg.setColor(0.90, 0.86, 0.74, 1 - a)
      lg.rectangle("fill", BX + 12, 20, 408, 200)
    end
  end
  lg.setColor(1, 1, 1)
  lg.draw(body, BX, bodyY)
  local tp = U.easeOutBack(clamp((o - 0.62) / 0.38, 0, 1))
  if o > 0.62 then
    local icons = U.img("gfx/ui/tb_icons.png")
    local ready = GO.ready(G.game)
    for _, tr in ipairs(TRAYS) do
      local im = U.img("gfx/ui/" .. tr.img .. ".png")
      local cx = BX + 216 - im:getWidth() / 2
      local x = fl(cx + (tr.x - cx) * tp)
      local y = fl(bodyY + 10 + (1 - tp) * 30)
      lg.setColor(1, 1, 1)
      lg.draw(im, x, y)
      for c = 0, tr.n - 1 do
        local idx = tr.from + c
        local px = x + 6 + c * CW
        local on = idx == s.tab
        if on then
          lg.setColor(SEL[1], SEL[2], SEL[3], s.focus == "tabs" and (0.55 + 0.25 * math.sin(t * 5)) or 0.35)
          lg.rectangle("fill", px + 2, y + 10, CW - 4, 46, 5, 5)
        end
        local lift = on and (3 + math.abs(math.sin(math.min(s.bounce * 6, math.pi))) * 3) or 0
        lg.setColor(0, 0, 0, 0.35)
        lg.draw(icons, ICONQ[idx], px + 8 + 1, y + 20 + 2)
        lg.setColor(1, 1, 1)
        lg.draw(icons, ICONQ[idx], px + 8, fl(y + 20 - lift))
        if TABS[idx].id == "goals" and ready > 0 then
          lg.setColor(0.85, 0.25, 0.2); lg.circle("fill", px + 38, y + 18, 6)
          UI.text(ready, px + 38, y + 14, { 1, 1, 1 }, 1, "center")
        end
      end
    end
    UI.text(TABS[s.tab].name, BX + 216, bodyY + 84, { 0.86, 0.94, 0.86 }, 2, "center", { 0.06, 0.12, 0.08 })
    UI.text("L", BX + 150, bodyY + 84, { 0.6, 0.75, 0.62 }, 2, "center")
    UI.text("R", BX + 282, bodyY + 84, { 0.6, 0.75, 0.62 }, 2, "center")
    UI.coin(BX + 30, bodyY + 120)
    UI.text(G.game.coins, BX + 42, bodyY + 119, { 1, 0.92, 0.6 }, 2, nil, { 0.06, 0.12, 0.08 })
    local hl = s.focus == "tabs" and { { "A", "Open" }, { "B", "Close" } } or { { "B", "Back" } }
    UI.hints(hl, BX + 412, bodyY + 118, { 0.86, 0.94, 0.86 }, "right")
  end
  if s.msgT > 0 then
    local a = math.min(1, s.msgT * 2)
    UI.text(s.msg, U.W / 2, 4, { 1, 1, 0.9, a }, 2, "center", { 0, 0, 0, a * 0.6 })
  end
end

return T
