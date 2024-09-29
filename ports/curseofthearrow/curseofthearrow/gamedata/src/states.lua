ingame = {}
pause = false
g_skip = false
local ct = 0
local ctstate = "in"

function ingame.update()
    lightsList = {}
    local o = btn
    local op = btnp

    if g_skip or pause then
      btn = function() return false end
      btnp = function() return false end
    end


      e_update_all()

    if not pause and flr(g_trans) == 0 then do_movement() end
      do_collisions()
      do_supports()

    if g_skip or pause then
      btn = o
      btnp = op
    end



  if (btnp("escape") or (not love.window.isVisible() and not pause))  and state == ingame  and not g_skip then
    pause = not pause

    if curr_music then
      local m = music[curr_music]
      -- if pause then m:setPitch(0.9) else m:setPitch(1) end
    end

    play_sfx("ui")
  end

  local hub = g_index > 99

  if pause then
    if btnp("x") or btnp("z") then
      play_sfx("ui")

      if hub then
        if current == 0 then
          pause = false
            t_calpa = 100
        else
          g_index = 102
          pause = false
          restart_level()
        end
      else
        if current == 0 then
          pause = false
            t_calpa = 100
        elseif current == 1 then
          g_index = 107 + flr(min(99, g_game) / 10)
          restart_level()
          pause = false
        elseif current == 2 then
          restart_level()
          pause = false
        else

            g_last = g_index
            g_index = 102
            swap_state(ingame)
          pause = false

        end
      end
    elseif btnp("up") then
      current = (current - 1) % (hub and 2 or 4)
      play_sfx("ui")
    elseif btnp("down") then
      current = (current + 1) % (hub and 2 or 4)
      play_sfx("ui")
    end
  end

  if g_skip then
    if btnp("up") then
      g_current = (g_current - 1) % 2
    elseif btnp("down") then
      g_current = (g_current + 1) % 2
    end

    if btnp("x") or btnp("z") then
      if g_current == 0 then
        g_index = g_index + 1
        g_levels[g_index + 1].unlocked = true
        restart_level()
        g_ldeaths = 0
      else
        g_skip = false
          t_calpa = 100
      end
    end
  end

  if ingamestate then -- menu
    ingamestate.update()
  end

end

g_dockstate = "idle"
dockx = -5
local dv = 0

local lightimg = love.graphics.newImage("assets/light.png")
local mask_shader = love.graphics.newShader[[
   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]


lightsList = {}

function addLight(x,y)
  if (g_index > 59 and g_index < 101) or g_index >= 113 then
  table.insert(lightsList,{flr(x),flr(y - 0.5)}) end
end

local function stencilfunc()
  love.graphics.setShader(mask_shader)
  for k,v in pairs(lightsList) do
    local s = -32
    love.graphics.draw(lightimg,v[1] + s,v[2] + s)
  end
  love.graphics.setShader()
end

function setStencil()
  love.graphics.stencil(stencilfunc, "replace", 1, true)
end

function activate()
  love.graphics.setStencilTest("greater",0)
end

function de_activate()
  love.graphics.setStencilTest()
end

function ingame.draw()
  g_calpha = t_calpa


  if state == ingame and g_calpha then g_calpha = min(255, g_calpha + 4)
    if g_calpha == 0 then
      g_calpha = nil
    end
  end

  love.graphics.clear(10 / 255, 10 / 255, 10 / 255,1)

  if pause or g_skip then
    g_calpha = 100
  end

  if (g_index>59 and g_index < 101) or g_index >=113 then
    setStencil()
    activate()
  end

  local a = 100 / 255
  love.graphics.setColor(a, a, a)
  if g_bgi then love.graphics.draw(bg[g_bgi]) end
  color(7)

  r_render_all("render")
  r_render_all("render_hud")

  de_activate()

  if state==ingame and g_index == 0 and g_time % 120 < 60 then
    coprint("Press " .. kmap["r"] .. " to restart", 112, 13)
  end

  t_calpa = g_calpha
  g_calpha = nil

  if g_dockstate=="open" then
    dockx = dockx + dv
    dv = dv + 0.1

    if dockx >= 0 then
      dockx = 0
      dv = 0
      g_dockstate = "idle"
    end
  elseif g_dockstate == "close" then
    dv = dv + 0.1
    dockx = dockx - dv
    if dockx <= -5 then
      dockx = -5
      dv = 0
      g_dockstate = "idle"
    end
  end

  local max = get_amount()
  local h = max * 4 + 1
  rectfill(dockx, 64 - math.floor(h / 2), 5, h, 5)

  for i = 1, max do
    rectfill(dockx + 1, 64 - math.floor(h / 2) + (i -1)* 4 + 1, 3, 3,
      i <= g_cubes and 10 or 0
    )
  end

  if g_et then
    local s = string.format("%02d", flr(g_timer / 3600)) .. ":" .. string.format("%02d", flr(g_timer / 60) % 60) .. ":" .. string.format("%02d", g_timer % 60)
    oprint(s, 191 - #s * 4, 3, 6)
  end

  if entities_tagged["holder"] and not g_failc and g_index % 20 == 19 and  g_cubes == max then
    g_cubes = 0
    g_failc = true
    g_spawned = true
    printh("spawn")
    for i = 1, max do
      e_add(cube({
        pos = v(dockx + 1, 64 - math.floor(h / 2) + (i -1)* 4 + 1),
        state = "fly",
        target = entities_tagged["holder"][i]
      }))
      entities_tagged["holder"][i].found = true
    end
    g_dockstate = "open"
  end


  local name = g_names[g_index + 1] or "Missing level name"
  if  state == ingame and g_index < 100 then
    oprint("Level " .. (flr(g_index / 20) + 1) .. "-" .. (g_index % 20 + 1)..": " .. name, 2, ingamestate and 256 - 4 + menu.pos or 122, 7) -- ingamestate
    local mx = get_hp()
    local h = (g_guy and g_guy.hp or (g_lost and 0 or mx))
      for i = 1, get_hp() do
        ospr(512 + (h >= i and 0 or 32), 2 + (i - 1) * 11, ingamestate and min(2, -64 + -menu.pos) or 2)
      end
      -- oprint(g_guy.hp .. " HP", 2, ingamestate and min(3, 3 - 128 - menu.pos) or 3, 14)
  end


  if g_index == 102 then
    oprint(kmap["z"] .. " to jump", 2, 2, 6)
  end

  if g_index >= 102 and g_index <= 106 then
    spr(31, 1, 119)
    oprint(g_money .. "", 12, 122, 7)
  end


  if not ingamestate and g_drawchap and state==ingame and g_index < 100 then
    local s = chap[flr(g_index /   20) + 1]
    ct = ct + (ctstate == "fade" and -1 or 1)
    print_alpha = ct * 4
    if ctstate == "fade" and ct < 0 then
      g_drawchap = false
      ct = 0
      ctstate = "in"
    elseif ctstate ~= "fade" and ct * 4> 500 then
      ctstate = "fade"
    end
    coprint(s, 60, 7)

    print_alpha = nil
  end

  if g_index == 104 then
    for i = 1, #g_prompt do
      local x = (i * 4 -g_time / 2+192-4) % (#g_prompt * 4 + 4) - 1
      if x < 194 then
        love.graphics.setColor(palette[flr(sin(i / 10 - g_time / 50) * 2 + 12)])
        oprint(g_prompt:sub(i, i), x, 110 + sin(g_time / 100 + i / 10) * 3)
      end
    end
  end

    if pause then
      coprint("Pause", 32, 7)
      if g_index < 100 then
      coprint("Level " .. (flr(g_index / 20) + 1) .. "-" .. (g_index % 20 + 1)..": " .. name, 16 + 8 + 8 + 16, 6)
      coprint(g_deaths .. " deaths", 16 + 16 + 8 + 16, 6)
      coprint((current == 0 and ">  " or "  ") .. "Return to the game   ", 64 + 16, current == 0 and 7 or 13)
      coprint((current == 1 and ">  " or "  ") .. "Pick another level  ", 64 + 8+ 16, current == 1 and 7 or 13)
      coprint((current == 2 and ">  " or "  ") .. "Restart  ", 64 + 16+ 16, current == 2 and 7 or 13)
      coprint((current == 3 and ">  " or "  ") .. "Go back  ", 64 + 16+ 16+8, current == 3 and 7 or 13)
      else
        coprint((current == 0 and ">  " or "  ") .. "Return to the game  ", 64 + 8, current == 0 and 7 or 13)
        coprint((current == 1 and ">  " or "  ") .. "Exit to menu ", 64 + 16, current == 1 and 7 or 13)

      end
    end

    if g_skip then
      coprint("Skip this level?", 32, 7)
      coprint("It looks like you have some trouble", 48, 6)
      coprint("With solving this level. Do you want", 48 + 8, 6)
      coprint("to skip it for now and get", 48 + 16, 6)
      coprint("back to it later?", 48 + 24, 6)

      coprint((g_current == 0 and ">  " or "  ") .. "Yes  ", 48 + 24 + 16, g_current == 0 and 7 or 13)
      coprint((g_current == 1 and ">  " or "  ") .. "No  ", 48 + 24 + 8 + 16, g_current == 1 and 7 or 13)
    end

    if ingamestate then
          ingamestate.draw()
        end
end

g_prompt = "Developers: @egordorichev, @Failpositive, awesome guys, who gave ideas, or were inspiring: @merumerutho, @BeautifulPanda_, @harbichidian, @MBoffin, @fmaida, @gabrielcrowe, @pi_pi314, @RachetmanX, @MJewjitsu, @TRASEVOL_DOG, @krajzeg, @Liquidream, @trelemar, @ramilego4game, @wombatstuff, @BenstarDEV, @ohsat_games, @terakorp, @_AlexanderClay, @LootBndt, @Brastin3_, @gruber_music, @DavitMasia, @Gaziter, @guerragames, @matthughson, @Jupiter_Hadley, @NoelFB thanks to them a lot!"

function ingame.start()
  t_calpa = 100
  pause = false
  current = 0
  start()
end

menu = {}
local current = 0

function menu.start()
  if lstate ~= settings then ingame.start() end
  play_music("menu")
  current = 0
  menu.pos = 0
end

function menu.update()
  if state == ingame then
    menu.vel = min(5, menu.vel + 0.2)
    menu.pos = menu.pos - menu.vel

    if menu.pos < - 128 then
      ingamestate = nil
    end
  else
    -- if btnp("escape") and not mobile then love.event.quit() end

    if btnp("down") then
      play_sfx("ui")
      current = (current + 1) % 4
    elseif btnp("up") then
      play_sfx("ui")
      current = (current - 1) % 4
    end

    if btnp("z") or btnp("x") then
      play_sfx("ui")

      if current == 0 then
          state = ingame
          ingamestate = menu
          menu.pos = 0
          menu.vel = 0.1
          stuff()
          g_ignore_button = true
      elseif current == 1 then

        swap_state(level_select)
      elseif current == 2 then
        swap_state(settings)
      else
        love.system.openURL("https://egordorichev.itch.io/curse-of-the-arrow")

      end
    end
    local o = btn
    local op = btnp
    btn = function() return false end
    btnp = function() return false end
    ingame.update()
    btn = o
    btnp = op
  end
end

function render_cube(x, y, s, a)
  local h = s / 2 + sin(a)
  local z = y + h

  local zh = h / 2


  local y1 = y + sin(a) * zh
  local y2 = y + sin(a + 0.25) * zh
  local y3 = y + sin(a + 0.5) * zh
  local y4 = y + sin(a + 0.75) * zh

  local x1 = x + cos(a) * h
  local x2 = x + cos(a + 0.25) * h
  local x3 = x + cos(a + 0.5) * h
  local x4 = x + cos(a + 0.75) * h


  local z1 = z + sin(a) * zh
  local z2 = z + sin(a + 0.25) * zh
  local z3 = z + sin(a + 0.5) * zh
  local z4 = z + sin(a + 0.75) * zh

  local a = g_calpha or 255
  love.graphics.setColor(palette[10][1] / 255 * a, palette[10][2] / 255 * a, palette[10][3] / 255 * a)

  love.graphics.line(x1, z1, x2, z2)
  love.graphics.line(x3, z3, x2, z2)
  love.graphics.line(x3, z3, x4, z4)
  love.graphics.line(x1, z1, x4, z4)

  love.graphics.line(x1, y1, x2, y2)
  love.graphics.line(x3, y3, x2, y2)
  love.graphics.line(x3, y3, x4, y4)
  love.graphics.line(x1, y1, x4, y4)


  love.graphics.line(x1, z1, x1, y1)
  love.graphics.line(x2, z2, x2, y2)
  love.graphics.line(x3, z3, x3, y3)
  love.graphics.line(x4, z4, x4, y4)
end

function menu.draw()
  if state ~= ingame then

    clear_screen(0)
    g_calpha = 100
    ingame.draw()

    g_calpha = nil
  end
  -- love.graphics.draw(bg["hell"])
  -- render_cube(20, 20, 15, g_time / 100)


  local m = cos(g_time / 300)*3
  spr(489, 62, 32 + menu.pos + m, 8, 4)

  if g_demo then
    coprint("demo version!", 48 + 4 + 12 + menu.pos + m, 14)
  end

  if g_time % 120 < 60 then
    coprint("Press " .. kmap["z"] .. " to start", 112, 13)
  end
  g_calpha = 100


  -- if g_time%60<30 then coprint("Press X to start", 110, 7) end
end

function coprint(s, y, c)
  local cl = t_calpa
  local g = g_calpa
  t_calpa = nil
  g_calpha = nil
  oprint(s, (192 - #s * 4) / 2, y, c)
  t_calpa = cl
  g_calpha = g
end

settings = {}

function settings.start()
  current = 0
end

function settings.update()
  if btnp("down") then
    play_sfx("ui")
    current = (current + 1) % 11
  elseif btnp("up") then
    play_sfx("ui")
    current = (current - 1) % 11
  end

  if btnp("z") or btnp("x") then
    g_calpha = nil
    play_sfx("ui")
    if current == 0 then
      g_em = not g_em
      if g_em then
        play_music("menu")
      else
        music["menu"]:stop()
        music["menu"]:setVolume(0)
      end
    elseif current == 1 then
      g_es = not g_es
    elseif current == 2 then
      g_ess = not g_ess
    elseif current == 3 then
      g_ek = not g_ek

      if g_ek then
        touch_fade()
      else touch_fadeout( ) end
    elseif current == 4 then
      swap_state(keyconfig)
    elseif current == 5 then
      if g_dif == "Easy" then g_dif = "Normal"
      elseif g_dif == "Normal" then g_dif = "Hard"
      elseif g_dif == "Hard" then g_dif = "Ultra hard"
      elseif g_dif == "Ultra hard" then g_dif = "Easy" end
      if g_guy then g_guy.hp = get_hp() end
    elseif current == 6 then
      g_et = not g_et
    elseif current == 7 then
      joyid = (joyid + 1) % (#g_joysticks+1)
       joystick = g_joysticks[joyid]
       joysaveid = joystick and joystick:getName().."_"..joystick:getID().."_"..joystick:getGUID() or joystick

       if joystick then
         love.filesystem.write("/JoystickID.txt",joysaveid)
       elseif love.filesystem.getInfo("/JoystickID.txt") ~= nil then
         love.filesystem.remove("/JoystickID.txt")
       end
    elseif current == 8 then
      g_ev = not g_ev
    elseif current == 9 then
      g_pix  = not g_pix
      apiResize()
    else
      g_last = g_index
      g_index = 102
      swap_state(ingame)
    end

    save()
  end
  local o = btn
  local op = btnp
  btn = function() return false end
  btnp = function() return false end
  ingame.update()
  btn = o
  btnp = op
end

function settings.draw()
  clear_screen(0)
  g_calpha = 100
  ingame.draw()
  g_calpha = nil

  coprint((current == 0 and "> " or "  ").."Music: " .. (g_em and "On  " or "Off  "), 16 + 16, (current == 0 and 7 or 13))
  coprint((current == 1 and "> " or "  ").."Sounds: " .. (g_es and "On  " or "Off  "), 16 + 24, (current == 1 and 7 or 13))
  coprint((current == 2 and "> " or "  ").."Screen shake: " .. (g_ess and "On  " or "Off  "), 16 + 32, (current == 2 and 7 or 13))
  coprint((current == 3 and "> " or "  ").."On-screen controls: " .. (g_ek and "On  " or "Off  "), 16 + 32 + 8, (current == 3 and 7 or 13))
  coprint((current == 4 and "> " or "  ").."Configure key bindings  ", 16 + 32 + 16, (current == 4 and 7 or 13))
  coprint((current == 5 and "> " or "  ").."Difficulty: " .. (g_dif) .. "  ", 16 + 32 + 16 + 8, (current == 5 and 7 or 13))
  coprint((current == 6 and "> " or "  ").."Show timer: " .. (g_et and "Yes" or "No") .. "  ", 16 + 32 + 16 + 8 + 8, (current == 6 and 7 or 13))
  coprint((current == 7 and "> " or "  ").."Select joystick: " .. (joystick and joystick:getName():gsub("%s%s+", "%s") .. " " .. joystick:getID() or "None") .. "  ", 16 + 32 + 16 + 8 + 8 + 8, (current == 7 and 7 or 13))
  coprint((current == 8 and "> " or "  ").."Vibration: " .. (g_ev and "On  " or "Off "), 16 + 32 + 32 + 16 , (current == 8 and 7 or 13))
  coprint((current == 9 and "> " or "  ").."Pixel perfect: " .. (g_pix and "On  " or "Off "), 16 + 32 + 32 + 16 +8, (current == 9 and 7 or 13))
  coprint((current == 10 and "> " or "  ").."Go back  ", 16 + 32 + 32 + 16 + 8 + 16, (current == 10 and 7 or 13))
  --  g_calpha = 100
end

function stuff()

  if g_index < 20 or (g_index >= 102 and g_index <= 108) then
    play_music(g_index < 100 and "forest" or (g_index < 102 and "cut" or (g_index >= 107 and "forest" or "menu")))
    g_bgi = "forest"
    g_bg = 4

    for i = 1, 20 do
      -- e_add(bar())
    end
  elseif g_index == 100 or g_index == 101 then
    play_music("cut")
    if g_index == 101 then
    g_bgi = "forest"
    g_bg = 4

    for i = 1, 20 do
      -- e_add(bar())
    end
    else
      g_bg = 1
      g_bgi = "jungle"
    end
  elseif g_index < 40 or g_index == 109 or g_index == 110 then
    play_music("jungle")
    g_bg = 0
    g_bgi = "jungle"
  elseif g_index < 60 or g_index == 111 or g_index == 112 then
    play_music("ice")
    g_bgi = "ice"
    g_bg = 12

    for i = 1, 100 do
      e_add(snow())
    end
  elseif g_index < 80 or g_index == 113 or g_index == 114 then
    g_bgi = "dungeon"
    play_music("dungeon")
    g_bg = 5
  else
    play_music((g_index >= 95 and g_index <= 99) and "empty" or "hell")
    g_bgi = "hell"
    g_bg = 2
  end
end

level_select = {}
local char = 0

function level_select.start()
  current = g_index
  char = (g_index < 100 and flr(g_index / 20) or 0)
end

function level_select.update()
  if btnp("x") then
    if lstate == ingame then
      state = ingame
    else
      g_trans = 15
      g_trans_in = true
      g_call = function()
        state = menu
      end
    end
    current = 0
    play_sfx("ui")
  elseif btnp("z") then
    if g_levels[current + 1].unlocked then
      if g_index % 20 == 19 and g_powered > 0 then
        g_failc = true
        g_cubes = get_amount()
      end

      g_index = current


      swap_state(ingame)
      play_sfx("ui")
    else
      play_sfx("locked")
      shake(20, 3)
    end
  end

  local a = g_demo and 20 or 80

  if btnp("left") then
    current = (current - 1) % a
    play_sfx("ui")
  elseif btnp("right") then
    current = (current + 1) % a
    play_sfx("ui")
  elseif btnp("up") and current > 19 then
    current = flr((current - 20) % a) / 20 * 20
    play_sfx("ui")
  elseif btnp("down") and current < a - 20  then
    current = flr((current + 20) % a) / 20 * 20
    play_sfx("ui")
  end

  char = flr(current / 20)


  local o = btn
  local op = btnp
  btn = function() return false end
  btnp = function() return false end
  ingame.update()
  btn = o
  btnp = op
end

function level_select.draw()
  clear_screen(0)
  g_calpha = 100
  ingame.draw()
  g_calpha = nil

  coprint(chap[char + 1], 8, 7)
  local name = g_levels[current + 1].unlocked and g_names[current + 1] or "???"
  coprint(name, 15, 6)

  for i = 0, 19 do
    local id = i + char * 20
    local l = g_levels[id + 1]
    local c = current % 20
    love.graphics.setLineWidth(1)
    local x,y = 43 + (i % 5) * 22, 16 + 12 + flr(i / 5) * 22
    rectfill(x, y, 20, 20, (l.finished or l.unlocked) and (c == i and (l.finished and 11 or 8) or (l.finished and 3 or 2)) or (c == i and 6 or 5))
    rect(x, y, 20, 20, 0)
    if l.unlocked then
      oprint((i + 1) .. "",  x + 2, y+ 3, 7)

      if l.coin then
        spr(31, x + 11, y + 11)
      end
    else
      ospr(480, x + 6, y + 6)
    end
  end

  if g_time % 180 < 90 then
    coprint("Press " .. kmap["z"] .. " to start, " .. kmap["x"] ..  " to go back", 118, 13)
  end

  -- g_calpha = 100
end


keyconfig = {}
local order = {
  "up", "down", "left", "right", "shoot", "jump", "restart"
}
local korder = {
  "up", "down", "left", "right", "x", "z", "r"
}
function keyconfig.start()
  current = 1
  used = {}
end

function keyconfig.handle(k, r)
  if k == "escape" then
    swap_state(ingame)
     return end

  if not r and current <= #order and not used[k] then
    kmap[korder[current]] = k
    used[k] = true
    printh(order[current] .. " = " .. k)
    current = current + 1

    if current > #order then
      current = current - 1
      save()
      swap_state(ingame)
    end
  end
end

function keyconfig.draw()
  love.graphics.clear(10, 10, 10, 255)

  coprint("Configure key bindings", 32, 7)

  coprint("Press key for \"" .. order[current] .. "\"", 64, 7)
  coprint("(Current: " .. kmap[korder[current]] .. ")", 64 + 8, 6)

  coprint("Press escape to return to the settings", 118, 13)
end

function keyconfig.update()
end

splash = {}

function splash.start()
  love.graphics.clear()
end

function splash.update()

end

local logo = love.graphics.newImage("assets/logo.png")

function splash.draw()
  love.graphics.clear(10 / 255, 10 / 255, 10 / 255,1)
  love.graphics.setColor(1, 1, 1, (g_time*3 > 255 and flr(255+255 - g_time * 3) or  flr(g_time * 3)) / 255)
  if g_time * 3 > 255 and not iplayed then
    iplayed = true
    play_sfx("startup")
  end
  love.graphics.draw(logo, (192 - 26) / 2, (128 - 28) / 2)

  oprint("Rexcellent Games", 64, 96)

  if g_time * 3 > 255 and flr(255+255 - g_time * 3)  <= 0 and not swapped then
          state = menu--cut
          state.start()
          g_trans  = 15
          if g_ek then touch_fade() end
    swapped = true

  end
end

warn = {}

function warn.start()
  g_time = 0
end

function warn.update()
  if not ffade and (btnp("z") or btnp("x")) then
    ffade = true
    printh("press")
    play_sfx("ui")
    g_time = 0
  end
end

function warn.draw()

  print_alpha = (ffade and flr(255 - g_time * 3) or min(255, flr(g_time * 3))) / 255
  coprint("Warning", 32, 14)
  coprint("This is a beta build of the game.", 32 + 16)
  coprint("It may contain bugs or other issues.", 32 + 16 + 8)
  coprint("If you spot any, please, contact the", 32 + 16 + 16)
  coprint("developer on twitter (@egordorichev).", 32 + 16 + 16 + 8)
  coprint("Thanks, and have fun!", 32 + 16 + 16 + 24, 13)

  if g_time % 120< 60 then coprint("Press ".. kmap["x"] .. " to start", 32 + 16 + 16 + 24 + 8, 12) end

  print_alpha = nil
  if ffade and flr(255 - g_time * 3)  <= 0 and not sswapped then
    state = menu--cut
    printh("menu")
    state.start()
    g_trans = 15
    sswapped = true
  end
end

win = {}
local alp = 0

function win.start()
  alp = 0
  current = 0

--  g_stop_timer = true
  play_music("win")
  g_levels[g_index + 1].finished = true
  g_won = true
end

function win.draw()
  clear_screen(0)
  g_calpha = 100
  ingame.draw()
  g_calpha = nil

  alp = min(255, alp + 8)

  print_alpha = alp
  coprint("Congratulations!", 32, 7)
  coprint("You did it!", 32 + 16, 7)
  coprint("We hope that you enjoyed the " .. (g_demo and "demo!" or "game!"), 32 + 16 + 8, 7)
  coprint("Stay tuned for the future updates", 32 + 16 + 16, 7)
  coprint("of the game!", 32 + 16 + 24, 7)

  coprint(g_deaths .. " deaths", 32 + 16 + 24 + 16, 6)
  coprint(string.format("%02d", flr(g_timer / 3600)) .. ":" .. string.format("%02d", flr(g_timer / 60) % 60) .. ":" .. string.format("%02d", g_timer % 60), 32 + 16 + 24 + 24, 6)

  coprint((current == 0 and "> " or "  ") .. "Visit the game site  ", 32 + 16 + 16 + 32 + 8, current == 0 and 12 or 13)
  coprint((current == 1 and "> " or "  ") .. "Exit to the menu  ", 32 + 16 + 16 + 32 + 8 + 8, current == 1 and 12 or 13)
  print_alpha = nil
end


function win.update()
  if btnp("x") or btnp("z") then
    play_sfx("ui")
    if current == 0 then
      love.system.openURL("https://egordorichev.itch.io/curse-of-the-arrow")
    else

        g_index = 0
        g_deaths = 0
        g_ldeaths = 0
        g_cubes = 0

        g_timer = 0
        g_stop_timer = false
      play_music("menu")

        g_last = g_index
        g_index = 102
        swap_state(ingame)
    end
  elseif btnp("up") then
    play_sfx("ui")

    current = (current - 1) % 2
  elseif btnp("down") then
    current = (current + 1) % 2
    play_sfx("ui")

  end

    local o = btn
    local op = btnp
    btn = function() return false end
    btnp = function() return false end
    ingame.update()
    btn = o
    btnp = op
end
