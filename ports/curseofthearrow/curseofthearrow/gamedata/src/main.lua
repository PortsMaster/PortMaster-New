require("src.engine")
require("src.guy")
require("src.level")
require("src.other")
require("src.states")
require("src.cutscene")
-- require("src.autobatch")

g_allm = 100

local ach = require("src.achievements")


mobile = false
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
  mobile = true
end

chap = {
  "Chapter I: The Curse",
  "Chapter II: Lost Civilization",
  "Chapter III: Crystallinium",
  "Chapter IV: Chamber of Thoughts",
  "Chapter V: Death"
}

sfx = {
  ["step"] = love.audio.newSource("assets/step.wav","static"),
  ["jump"] = love.audio.newSource("assets/jump.wav","static"),
  ["hit"] = love.audio.newSource("assets/hit.wav","static"),
  ["door"] = love.audio.newSource("assets/door.wav","static"),
  ["arrow_hit"] = love.audio.newSource("assets/arrow_hit.wav","static"),
  ["arrow_hit_breaking"] = love.audio.newSource("assets/arrow_hit_breaking.wav","static"),
  ["toggle"] = love.audio.newSource("assets/toggle.wav","static"),
  ["button"] = love.audio.newSource("assets/button.wav","static"),
  ["ui"] = love.audio.newSource("assets/ui.wav","static"),
  ["coin"] = love.audio.newSource("assets/coin.wav","static"),
  ["lift"] = love.audio.newSource("assets/lift.wav","static"),
  ["lift2"] = love.audio.newSource("assets/lift2.wav","static"),
  ["bhit"] = love.audio.newSource("assets/bhit.wav","static"),
  ["expl"] = love.audio.newSource("assets/exlp.wav","static"),
  ["pop"] = love.audio.newSource("assets/pop.wav","static"),
  ["death"] = love.audio.newSource("assets/death.wav","static"),
  ["fire"] = love.audio.newSource("assets/fire.wav","static"),
  ["pick"] = love.audio.newSource("assets/pick.wav","static"),
  ["step2"] = love.audio.newSource("assets/step2.wav","static"),
  ["land"] = love.audio.newSource("assets/land.wav","static"),
  ["startup"] = love.audio.newSource("assets/startup.wav","static"),
  ["locked"] = love.audio.newSource("assets/locked.wav","static"),
  ["edead"] = love.audio.newSource("assets/edead.wav","static"),
  ["power"] = love.audio.newSource("assets/power.wav","static"),
  ["cube"] = love.audio.newSource("assets/cube.wav","static"),
  ["saw"] = love.audio.newSource("assets/saw.wav","static"),
  ["teleport"] = love.audio.newSource("assets/teleport.wav","static"),
  ["ach"] = love.audio.newSource("assets/ach.wav","static"),
}

music = {
  ["forest"] = love.audio.newSource("assets/forest.ogg", "stream"),
  ["jungle"] = love.audio.newSource("assets/jungle.ogg", "stream"),
  ["ice"] = love.audio.newSource("assets/ice.ogg", "stream"),
  ["dungeon"] = love.audio.newSource("assets/dungeon.ogg", "stream"),
  ["win"] = love.audio.newSource("assets/win.ogg", "stream"),
  ["cut"] = love.audio.newSource("assets/cut.ogg", "stream"),
  ["empty"] = love.audio.newSource("assets/empty.ogg", "stream"),
  ["menu"] = love.audio.newSource("assets/home.ogg", "stream"),
  ["hell"] = love.audio.newSource("assets/hell.ogg", "stream")
}

bg = {
  ["hell"] = love.graphics.newImage("assets/hell.png"),
  ["ice"] = love.graphics.newImage("assets/ice.png"),
  ["forest"] = love.graphics.newImage("assets/forest.png"),
  ["jungle"] = love.graphics.newImage("assets/jungle.png"),
  ["dungeon"] = love.graphics.newImage("assets/dungeon.png")
}

function play_music(n)
  if not g_em then return end

  if curr_music == n then return end
  -- if curr_music then music[curr_music]:stop() end
  fade_outm = music[curr_music]
  -- if fade_outm then fade_outm:stop() end
  curr_music = n
  fade_inm = music[n]

  music[n]:play()
  music[n]:setLooping(true)
  music[n]:setVolume(0.01)
end

function play_sfx(n)
  if not g_es or not love.window.isVisible() then return end
  if sfx[n] then sfx[n]:stop() sfx[n]:play() end
end

g_em = true
g_es = true
g_ess = true
g_index = 0
g_deaths = 0
g_dead = false
g_powered= 0
g_dif = "Normal"
g_ldeaths = 0
g_game = 0
g_dt = -1
g_trans = 0
g_ppet = ""
g_trans_in = false
g_played = false
unlocked = {}

  g_money = 0
g_names = {
-- forest
  "The basics",
  "Tiny hills",
  "Spikes? Really?",
  "Iron mountains",
  "Bouncy fun",
  "On and off",
  "Stuff starts to get complex",
  "Red balloon in the blue sky",
  "Shooting through holes",
  "Moving and jumping",
  "Swimming pool",
  "The right order",
  "Not such a tiny mountin",
  "Jumping and shooting part 2",
  "Road on over the abyss",
  "Fighting jelly",
  "BOOM!",
  "A bit harder, but BOOM!",
  "Jumping TNT",
  "Transferring explosives",
-- jungle
  "Ssssnakes and lianas",
  "Heritage of aboriginal",
  "Pit with spikes",
  "Walls are your friends",
  "Explosion in the mid-air",
  "The best level",
  "Floating gelatin",
  "Double snake",
  "Changing transport",
  "Back and forth",
  "Don't touch the water",
  "Suspicious snakes",
  "Timing your jumps",
  "Shooting at the right time",
  "Hard jump",
  "Jump!",
  "Transferring the key",
  "Updated start",
  "Don't kill animals!",
  "You did it!",
-- ice
  "Don't fall, it's slippery",
  "Aaa, the floor is falling!",
  "Shooting ice",
  "Jumping and running",
  "Well, that's complex!",
  "Arrow will show your way",
  "Delayed hide and seek",
  "Pff, that's too easy!",
  "Pushing blocks",
  "The power of arrows",
  "One box, many buttons",
  "Up and down",
  "Wait, stop for a second!",
  "Light enough to carry",
  "Doodle jump",
  "Transferring the box",
  "Too many switches",
  "What can go wrong?",
  "Explosion makes all better",
  "The Ice Cave",
-- dungeon
  "AND gate",
  "Inverters",
  "XOR lock",
  "The right combination",
  "Powering on the fly",
  "The box is your friend",
  "Shooting through snakes",
  "That's a trap!",
  "The ball won't wait",
  "A huge drop",
  "Upgraded spikes",
  "On-off-on-off",
  "Stairway to heaven",
  "Buffers @_@",
  "All is fine, just wait",
  "Jumps in the dark",
  "Temporary bridge",
  "SSSSSnakes :)",
  "Repeating basics",
  "The end?!",
-- hell
  "The hell is real",
  "Meat factory",
  "Super Meat Boy",
  "Timing spikes",
  "Lava swimming pool",
  "Rememering logic",
  "Up, oops, down!",
  "Lifting into the spikes",
  "Controling lifts",
  "Did it go wrong?",
  "Counting jumps",
  "Pizza delivery",
  "Teleporting",
  "Where did it go?",
  "Flying teleport",
  "Was it worth it?",
  "Green lock",
  "Transferring TNT",
  "Where is the key?",
  "The final"
}

g_shopped = {}

function _init()
  if mobile then
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight())
  end

  if g_ek then touch_fade() end
  load()

  g_time = 0
  btns = {}
  state = menu
--   g_demo = true
state = splash
  g_last = 0
  g_index = 102
  state.start()
end

function _update(dt)
  if g_time % 60 == 0 and not pause and not g_stop_timer and state == ingame and g_index < 100 then
    g_timer = g_timer + 1
  end

  if flr(g_trans) == 0 then
    flux.update(dt)

    if not g_ach and #aqu > 0 then
      g_ach = aqu[1]
      del(aqu, g_ach)
      play_sfx("ach")
      if g_ach then
      printh("load")
        flux.to(g_ach, 0.04, { y = 0 }):oncomplete(function()
          flux.to(g_ach, 0.04, {y = -16 }):delay(0.5):oncomplete(function()
            g_ach = nil
          end)
        end)
      end
    end
  end

  if g_jvtime then
    g_jvtime = g_jvtime - 1
    if g_jvtime <= 0 then
      g_jvtime = 0
      if joystick then joystick:setVibration(0, 0) end
    end
  end

  g_cubes = min(g_cubes, get_amount())
  if fade_outm then
    local v = fade_outm:getVolume()
    if v >= 0 then
      fade_outm:setVolume(v - 0.01)
    else
      fade_outm:stop()
      fade_outm:setVolume(0)
      fade_outm = nil
    end
  end


  if fade_inm then
    local v = fade_inm:getVolume()
    if v < 1 then
      fade_inm:setVolume(v + 0.01)
    else
      fade_inm = nil
    end
  end

  state.update()
  g_time = g_time + 1
  if scheduled then
    scheduled()
    scheduled = nil
  end
end

aqu = {}

function unlock(name)
  local a = ach[name]
  if not a or unlocked[name] then return end

  unlocked[name] = true
  printh(name .. " unlocked!")



  add(aqu,{
    name = a.name,
    desc = a.desc,
    spr = a.spr,
    y = -16,
    bold = a.bold
  })
end


function _draw()

  if g_trans > 0 then
    g_trans = g_trans - 0.9
    local s = 128 / 15
    if not g_trans_in then
      love.graphics.translate(0, s * g_trans)
    else
      love.graphics.translate(0, s * g_trans - 128)
    end
  end

   state.draw()

   if g_ach then
     local x = 192 - #g_ach.name * 4 - 2
     local y = g_ach.y

     love.graphics.setColor(palette[1])
     local f = g_ach.bold and ospr or spr
     f(g_ach.spr, x - 12, y +2)
     love.graphics.setColor(palette[13])
     oprint(g_ach.name, x - 1, y + 5)
   end

  btns = {}

  if g_trans > 0 then

    g_calpha = nil

    love.graphics.setColor(10 / 255, 10 / 255, 10 / 255, 1)
    local s = 128 / 15
    if not g_trans_in then
      love.graphics.rectangle("fill", 0, 0, 192, s * g_trans)
    else
      love.graphics.rectangle("fill", 0, s * g_trans, 192, 128)
    end
    g_calpha = t_calpa

    if flr(g_trans) <= 0 and g_trans_in then
      g_trans = 15
      g_trans_in = false

      if g_call then
        g_call()
      end
    end
  else
    g_trans = 0
  end
end

function vibrate(s)
  if not g_ev then return end

  if joystick then
    if joystick:isVibrationSupported() then
      g_jvtime = s
      joystick:setVibration(0.5, 0.5)
    end
  else
    love.system.vibrate(s)
  end
end

function swap_state(s)
  g_trans = 15
  g_trans_in = true

  lstate = state
  g_call = function()
    state = s
    g_not = true
    s.start()
  end
end

function restart_level()

    printh(g_game)
    if g_index >= 0 and g_index <= 99 then
      g_game = g_index
    end

  --  if g_not then
  g_trans = 15
  g_powered = 0
  g_trans_in = true
  g_skip = false
  g_got_coin = false
  --end
  --g_not = false

  if g_index % 20 == 19 and g_spawned then
    printh("fail")
    g_failc = true
    g_spawned = false
  end

  g_call = function()
    if g_failc then
      printh("add max")
      g_cubes = get_amount()
    end
    g_failc = false
    if g_dead then
      g_deaths = g_deaths + 1
      g_ldeaths = g_ldeaths + 1
      if g_ldeaths % 6 == 5 and g_index < 100 then
        g_current = 0
        g_skip = true
      end
      if g_picked then
        printh("remove 1")
        g_cubes = g_cubes - 1
      end

    end

    start()
    g_next = false
    save()
  end
end

function start()
  g_time = 0
  g_sei = 0
  g_li = 0
  g_r = 0
  wreg = {}
  g_enemies = 0
  g_dead = false
  g_cube = nil
  g_picked = false
  g_hold = false
  g_cubes = 0

  g_failc  =false
  g_snk = {}
  g_arrow = nil
  g_guy = nil
  entity_reset()
  collision_reset()
  if g_index == 0 and not g_lost and not g_played then
    state = cut
    g_played = true
    state.start()
    return
  elseif g_next then

    g_index = g_index + 1
    g_played = false

  end
    if g_ldeaths == 0 and g_index % 20 == 0 then
      g_drawchap = true
      g_cubes = 0
    else
      g_drawchap = false
    end
  stuff()

  if g_index == 20 then unlock("jungle")
  elseif g_index == 40 then unlock("ice")
  elseif g_index == 60 then unlock("dungeon")
  elseif g_index == 80 then unlock("hell") end

  e_add(level({
    base = v(g_index % 10 * 24, flr(g_index / 10) * 16),
    size = v(24, 16)
  }))

end

function next_level()
  if g_index >= 0 and g_index <= 99 then
    g_game = g_index
  end

  if (g_demo  and g_index == 19) or g_index == 99 then
    state = win
    win.start()

    if not g_demo then
      unlock("final")
    end
    return
  end

  g_next = true
  g_levels[g_index + 1].finished = true
  if g_got_coin then
    g_levels[g_index + 1].coin = true
    g_money = g_money + 1
    if g_money >= g_allm then
      unlock("rich")
    end
  end
  if g_levels[g_index + 2] then g_levels[g_index + 2].unlocked = true end
  g_ldeaths = 0
  g_dead = false


  restart_level()
end

function love.keypressed(key, s, rep)
  if key == (kmap["r"] or "r") and state == ingame then
    restart_level()
  end

  if state == keyconfig then
    keyconfig.handle(key, rep)
  end

  if not rep then btns[key] = true end
end


function btnp(b)
    b = kmap[b] or b
    return (btns[b] ~= nil)
end

lume = require("src.lume")

function save(exit)
  if g_failc and exit then g_cubes = get_amount() end



  local data = {
    g_index = g_index,
    g_deaths = g_deaths,
    g_em = g_em,
    g_es = g_es,
    g_ppet = g_ppet,
    g_ess = g_ess,
    g_ek = g_ek,
    g_et = g_et,
    release = true,
    g_cubes = g_cubes,
    g_dif = g_dif,
    g_timer = g_timer,
    g_bat = g_bat,
    kmap = kmap,
    g_shopped = g_shopped,
    g_played = g_played,
    g_pix = g_pix,
    g_ev = g_ev,
    g_game = g_game,
    g_money = g_money,
    unlocked = unlocked,
    levels = {}
  }

  for i = 1, 120 do
    data.levels[i] = g_levels[i]
  end

  love.filesystem.write("curse_of_the_arrow.save", lume.serialize(data))
end

local function get(d, n, v)
  if d[n] ~= nil then return d[n] end
  return v
end

function load()
  local data = love.filesystem.getInfo("curse_of_the_arrow.save") ~= nil and lume.deserialize(love.filesystem.read("curse_of_the_arrow.save")) or { g_game = 0}

  g_index = data.g_index or 0
  g_deaths = data.g_deaths or 0
  g_ldeaths = data.g_ldeaths or 0
  g_cubes = data.g_cubes or 0
  g_timer = data.g_timer or 0
  g_game = data.g_game or 0
  g_bat = data.g_bat or 0
  g_shopped = data.g_shopped or {}
  g_ppet = data.g_ppet or ""
  g_money = data.g_money or 0
  unlocked = data.unlocked or {}

  kmap = data.kmap or {
    x = "x",
    z = "z",
    r = "r",
    up = "up",
    down = "down",
    right = "right",
    left = "left",
    esc = "esc"
  }
  g_em = get(data, "g_em", true)
  g_pix = get(data, "g_pix", false)
  -- g_played = get(data, "g_played", false)
  g_ev = get(data, "g_ev", true)
  g_es = get(data, "g_es", true)
  g_et = get(data, "g_et", false)
  g_ess = get(data, "g_ess", true)
  g_dif = get(data, "g_dif", "Normal")
  g_ek = get(data, "g_ek", mobile)

  local ld = data.levels or {}
  g_levels = {}
  local m = 0
  for i = 1, 120 do
    g_levels[i] = ld[i] or {
      finished = false,
      unlocked = i == 1,
      coin = false
    }
    if g_levels[i].coin then m = m+1 end
  end
  if not data.release and g_money < m then g_money = m end
end

function love.quit()
  save(true)
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
function love.errhand(msg)
  print("Erro!")
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

    local trace = debug.traceback()


  local err = {}

  table.insert(err, "Error\n")
  table.insert(err, msg.."\n\n")

  for l in string.gmatch(trace, "(.-)\n") do
    if not string.match(l, "boot.lua") then
      l = string.gsub(l, "stack traceback:", "Traceback\n")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "\n")
  save()
  love.system.setClipboardText(p)

	local function draw()
    love.graphics.clear(0, 0, 0, 1)
    apiPreDraw()

    coprint("We have some bad news", 32, 14)
    coprint("Sadly, the game crashed.", 32 + 16, 7)
    coprint("Don't worry, your progress", 32 + 16  +8, 7)
    coprint("was saved. Please, report", 32 + 16  +16, 7)
    coprint("following message to the", 32 + 16  +24, 7)
    coprint("developer. It was copied", 32 + 16  +32, 7)
    coprint("into your clipboard.", 32 + 16  + 32 + 8, 7)

    print(msg, 1, 32 + 16  +64, 7)

    flip()
		love.graphics.present()
	end

	while true do
    love.graphics.setCanvas()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end
