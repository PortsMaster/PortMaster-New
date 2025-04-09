local at = 3

spikes = entity:extend({
  draw_order = 3,
  hitboxes = {
    [68] = box(1, 4, 7, 8),
    [69] = box(1, 0, 7, 4),
    [8] = box(0, 1, 4, 7),
    [9] = box(4, 1, 8, 7)
  },
  bold = true,
  tags = {"spikes"},
  collides_with = {"guy","enemy"}
})

spikes:spawns_from(68, 69, 8, 9)

function spikes:init()
  self.hitbox = spikes.hitboxes[self.tile]
  self.sprite = {idle = {self.tile}}
end

function spikes:collide(o)
  if o.kill and (not o.isd or not o:isd()) then
    o:kill()
  end
end

function spikes:render()
  spr_render(self)
end

water = entity:extend({
  tags={"water"},
  collides_with = {"guy","item","enemy"},
  hitbox = box(0, 1, 8, 7),
  sprite = {
    idle = {39, 40, 41, 162, delay = 15},
    big = {72, 73, delay = 30},
    big2 = {269, 270, delay = 30},
    stat = {44, 71, 45, delay = 10},
    down = {200},
    near = {193}
  }
})

water:spawns_from(193, 200, 39, 40, 71, 72, 73, 269, 270)

function water:init()
  self.draw_order = 10
  if self.tile == 72 or self.tile == 73 then
    self:become("big")
    self.t = rnd(128)
  elseif self.tile == 269 or self.tile == 270 then
    self:become("big2")
    self.t = rnd(128)
  elseif self.tile == 71 then
    self:become("stat")
  elseif self.tile == 200 then
    self:become("down")
  elseif self.tile == 193 then
    self:become("near")
  else
    self.draw_order = 3
  end
  --self.t = rnd(128)
end

function water:collide(o)
  if o:is_a("guy") then
    if self.state~="idle" and o.state ~="dead" and o.state~="dead2" then o:kill() unlock("swim") end
  elseif not o.done and self.state ~="idle" then
    if o.float then
      o.vel.y = 0
      o.in_water = true
      if o.state~="floaty" and o.floaty then o:become("floaty") end
    else
      if o.exlodes then

            shake(10, 3)
            play_sfx("expl")
      end
      o.done = true
      for i = 0, 10 do
        e_add(particle({
          pos = v(o.pos.x + 4, o.pos.y + 4),
          size = 3,
          color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
        }))
      end
    end
  end
end


door = entity:extend({
  sprite = {
    idle = {544 + 96 + 64 + 1},
    nopower = {544 + 96 + 64 + 1},
    wait = {106},
    main = {106},
    up = {544 + 96 + 64 + 1, delay = 10},
    next = {544 + 96 + 64 + 1, delay = 10},
    toup = {544 + 96 + 64},
    towait = {544 + 96 + 64},
    tomain = {544 + 96 + 64},
    tonext = {544 + 96 + 64},
    toended = {544 + 96 + 64},
    height = 2
  },
  draw_order = 5,
  collides_with = {"guy"},
  hitbox=box(3, 4, 5, 12)
})

function door:toup(t) if t>=10 then self:become("up") end self:common() end
function door:tonext(t)
  if t>=10 and (g_dockstate == "idle" and dockx < -1) then self:become("next") end self:common()
end
function door:toended(t) if t>=10 then self:become("ended") end self:common() end
function door:towait(t) if t>=10 then self:become("wait") end self:common() end
function door:tomain(t) if t>=10 then self:become("main") end self:common() end

door:spawns_from(106, 139)

function door:main()
self:common()
end

function door:common()
  addLight(self.pos.x + 4, self.pos.y + 4)
end

function door:init()
  self.id = g_li
  g_li = g_li + 1
  mset(flr(self.pos.x / 8), flr(self.pos.y / 8), 107)
  self.vy = 0

  self.cd = 0
  if self.tile == 139 then
    self:become("up")
    self.target = self.pos.y + 1
    self.pos.y = 0
    self.vy = 2
    self.start = true
  else
    self:become("main")
    self.pos.y = self.pos.y - 1

    if g_hold then
      self:become("nopower")
    end
  end
end

function door:up()
  if self.pos.y >= self.target - 32 then
    if self.vy == 2 then

      play_sfx("lift2")
    end
    self.vy = max(0.1, self.vy - 0.06)
  else
    self.vy = min(2, self.vy + 0.1)
  end

  self.pos.y = self.pos.y + self.vy

  if self.pos.y >= self.target then
    self.pos.y = self.target
    self:become("towait")
    e_add(lfx({
      pos = v(self.pos.x - 4, self.pos.y + 8)
    }))

    e_add(guy({
      pos = v(self.pos.x, self.pos.y + 8),
      state = "born"
    }))
  end
  self:common()
end

function door:nopower()
  if not self.power and g_powered == get_amount() then
    self.power = true
    play_sfx("power")
    self:become("tomain")
  end
  self:common()
end

function door:wait(t)



  if t>180 then
    self.vy = 0
    self:become("toended")
  elseif t==160 then


    play_sfx("lift")
    e_add(lfx({
      pos = v(self.pos.x - 4, self.pos.y + 8)
    }))
  else
  end
  self:common()
end

function door:ended()
  self.vy = min(2, self.vy + 0.01)
  self.pos.y = self.pos.y + self.vy
  if self.pos.y >= 128 + 32 then
    self.done = true
  end
  self:common()
end

function door:render_hud()
  if self.cd > 0 and flr(g_trans)== 0 then
    self.cd = self.cd - 1
    ospr(326, self.pos.x + 1,flr(self.pos.y - 10.5))
  end
end

function door:collide(o)
  if self.state == "nopower" then

    if not self.fx or  self.fx.done then
      self.fx = e_add(tfx({
        text = "not enough power cubes",
        pos = v(self.pos.x, self.pos.y),
        target = v(self.pos.x, self.pos.y - 8)
      }))
      play_sfx("locked")
    end end
  if self.state == "main" and o:is_a("guy") and not self.start  then
    if  btnp("down") then
    if g_index%20 ~= 19 or g_powered == get_amount() then
      self:become("tonext")

      play_sfx("lift")
      e_add(lfx({
        pos = v(self.pos.x - 4, self.pos.y + 8)
      }))
      self.vy = 0
      g_guy:become("dend")
      g_guy.pos = v(self.pos.x, self.pos.y + 8)

    end
    else
      self.cd = 3
    end
  end
end

function door:next()
  if self.t > 60 then
  self.vy = min(4, self.vy + 0.03)
end
  self.pos.y = self.pos.y + self.vy
  if self.pos.y >=128 + 32 and state == ingame and g_trans == 0 then
    if g_index < 102 then next_level()

    else
      if g_got_coin then
        g_levels[g_index + 1].coin = true
        g_money = g_money + 1
        if g_money >= g_allm then
          unlock("rich")
        end
      end

      if g_index == 102 then
        if self.id == 3 then
          g_index = 107 + flr(min(99, g_game) / 10)
          restart_level()
        elseif self.id == 1 then
          next_level()
        elseif self.id == 2 then
          g_index = 104
          restart_level()
        end
      elseif g_index == 103 then
        g_index = 102
        restart_level()
      elseif g_index == 104 then
        if self.id == 1 then
          g_index = 106
        elseif self.id == 2 then
          g_index = 102
        else
          g_index = 105
        end
        restart_level()
      elseif g_index == 105 then
        g_index = 104
        restart_level()
      elseif g_index == 106 then
        g_index = 104
        restart_level()
      elseif g_index == 107 then
        if self.id == 1 then
          g_index = 102
        else
          g_index = 108
        end
        restart_level()

      elseif g_index == 108 then
        if self.id == 1 then
          g_index = 107
        else
          g_index = 109
        end
        restart_level()
      elseif g_index == 109 then
        if self.id == 1 then
          g_index = 108
        else
          g_index = 110
        end
        restart_level()
      elseif g_index == 110 then
        if self.id == 1 then
          g_index = 109
        else
          g_index = 111
        end
        restart_level()
      elseif g_index == 111 then
        if self.id == 1 then
          g_index = 110
        else
          g_index = 112
        end
        restart_level()
      elseif g_index == 112 then
        if self.id == 2 then
          g_index = 111
        else
          g_index = 113
        end
        restart_level()
      elseif g_index == 113 then
        if self.id == 1 then
          g_index = 112
        else
          g_index = 114
        end
        restart_level()
      elseif g_index == 114 then
        if self.id == 1 then
          g_index = 113
        else
          g_index = 115
        end
        restart_level()
      elseif g_index == 115 then
        if self.id == 1 then
          g_index = 114
        else
          g_index = 116
        end
        restart_level()
      elseif g_index == 116 then
        if self.id == 1 then
          g_index = 115
        end
        restart_level()
      end
    end

    save()
  end
  self:common()
end

function door:render()
if flr(g_trans)== 0 then
  spr_render(self)
end
end

ldoor = entity:extend({
  sprite = {
    idle = {170},
    todone = {99, 169, 105, delay = 6},
    height = 2
  },
  hitbox = { box(0, 0, 8, 16), todone = box(0, 0, 0, 0)},
  collides_with = {"guy"},
  tags = {"walls","door"},
  draw_order = 5,
  breaks = true,
})

ldoor:spawns_from(170)

function ldoor:collide(o)
  return c_push_out
end

function ldoor:idle()
  for k in all(entities_tagged["key"]) do
    if k.state ~= "todone" then
      local dx = self.pos.x + 4 - k.pos.x - 4
      local dy = self.pos.y + 8 - k.pos.y - 2
      local d = math.sqrt(dx * dx + dy * dy)

      if d < 16  then
        k:become("todone")
        g_guy.item = g_guy.bow
        self:become("todone")
        play_sfx("door")
      end
    end
  end
end

function ldoor:todone()
  if self.t >= 17 then
    self.done = true
  end
end

item = entity:extend({
  weight = {0.1, held = 0.0, todone = 0.01}
})

function item:init()
  self.collides = 0
end

function item:render_hud()
  if self.collides>0 and (self.state == "idle" or self.state == "jelly") then
    self.collides = self.collides - 1
    ospr(171, self.pos.x + 1, flr(self.pos.y - 8.5))
    if btnp("x") and self.t > 10 then
      g_guy:peek(self)
      btns[kmap["x"]] = false
    end
  end
end

key = item:extend({
  sprite = {
    idle = {199},
    todone = {92 + 64},
    flips = true
  },
  bold = true,
  tags = {"key","item"},
  hitbox = box(1, 1, 7, 4),
  feetbox = box(1, 1, 7, 4.01),
  collides_with = {"guy", "walls"},
  draw_order = 10
})

key:spawns_from(199)

function key:init()
  self.vel = v(0, 0)
  self.pos.y = self.pos.y + 4
end

function key:todone(t)
  if t>=10 then self.done = true end
end

function key:idle(t)
  self.vel.x = self.vel.x * 0.9
end

function key:collide(o)
  if o:is_a("guy") then
    self.collides = at
    o.collidei = self
  elseif o:is_a("walls") and not self.supported_by and o.state ~="hidden" and self.state~="held" then
    play_sfx("hit")
  end
end

function oprint(s, x, y, c)
  local r, g, b, a = love.graphics.getColor()
  for xx = x - 1, x + 1 do
    for yy = y - 1, y + 1 do
      if abs(xx - x)+abs(yy - y)== 1 then
        print(s, xx, yy, 0)
      end
    end
  end
  love.graphics.setColor(r, g, b, a)
  print(s, x, y, c)
end

fly = entity:extend({
  bold = true,
  hitbox = box(0, 0, 8, 3),
  draw_order = 8,
  collides_with = {"arrow","walls","water","guy","kills"},
  weight = {0, hidden = 0.1}
})

fly:spawns_from(230, 231)

function fly:collide(o)
  if o.state == "idle" and o:is_a("arrow") and not self.done and self.plrc == 0 then
    self.done = true
    if g_index < 100 then e_add(bat({
      pos = v(self.pos.x, self.pos.y),
      state = "fly"
    }))
  end
  g_bat = g_bat + 1
    printh(g_bat .. " flies")
    if g_bat == 50 then unlock("super_bad")
    elseif g_bat == 100 then unlock("omega_bad") end
    unlock("bad")
    o.did = true
    o.vel.x = 0
    o:become("hidden")
    self:become("die")
    play_sfx("edead")

    for i = 1, 10 do
      e_add(blood({
        pos = v(self.pos.x + 2, self.pos.y + 4),
        size = 2,
        color = rnd() > 0.7 and 2 or 8
      }))
    end
    o.did = true
  elseif o:is_a("guy") then
    self.plrc = 3
  end
end

function fly:init()
  local m = 230

  if g_bgi == "jungle" then m = 679
  elseif g_bgi == "ice" then m = 679 + 2
  elseif g_bgi == "dungeon" then m = 679 + 4
  elseif g_bgi == "hell" then m = 679 + 6 end

  self.sprite = {
    idle = {m, 1 + m, delay = 20},
    hidden = {}
  }

  self.t = rnd(128)
  self.vel = v(0, 0)
  self.start = self.pos
  self.plrc = 0
end

function fly:idle(t)
  if self.plrc > 0 then self.plrc = self.plrc - 1 end
  self.pos = v(
    self.start.x + sin(t / 70) * 3,
    self.start.y + cos(t / 90) * 3
  )
end

grass = entity:extend({
  sprite = {
    top = {38 , 70, delay = 60},
    ctop = {802 , 802 + 32, delay = 60},
    idle = {36, 37, delay = 60},
    cidle = {800, 801, delay = 60},
    cidle2 = {800, 801, delay = 60},
    idle2 = {300, 301, delay = 60}
  },
  tags = {"corrupt"},
  collides_with={"arrow"},
  draw_order = 2,
  hitbox = box(1, 1, 7, 7)
})

grass:spawns_from(38, 70, 36, 37, 300, 301)

function grass:init()
  if self.tile == 38 or self.tile == 70 then
    self:become("top")
  elseif self.tile == 300 or self.tile == 301 then
    self:become("idle2")
  end
  self.t = flr(rnd(1000))
  self.corrupted = false
end

function grass:corrupt()

    if g_index == 100 then return end
  if self.tile == 38 or self.tile == 70 then
    self:become("ctop")
  elseif self.tile == 300 or self.tile == 301 then
    self:become("cidle2")
  else
    self:become("cidle")
  end
  self.corrupted = true
end

function grass:render_hud()
  if self.corrupted and rnd() > 0.95 then

    for e in all(entities_tagged["corrupt"]) do
      if e ~= self and (not e.tile or corrupt_map[e.tile])  and not e.corrupted  then
        local dx = self.pos.x - e.pos.x
        local dy = self.pos.y - e.pos.y
        local d = math.sqrt(dx * dx + dy * dy)

        if d < 16 then
          e:corrupt()
          break
        end
      end
    end
  end
end

function grass:collide(e) if e.cursed then self:corrupt() end end

platform = entity:extend({
  sprite = {
    idle = {13},
    width = 2
  },
  draw_order = 9,
  hitbox = box(1, 0, 15, 8),
  collides_with = {"walls"},
  tags = {"walls"},
  s = 0.5
})

platform:spawns_from(13, 14)

function platform:init()
  self.nextvel = v((self.tile == 13 or self.tile == 87) and self.s or -self.s, 0)
  self.pos.x = self.pos.x + ((self.tile == 13 or self.tile == 87) and -1 or 1)

  self.vel = v(0, 0)
  self:become("waiting")
end

function platform:waiting(t)
  if t >= 60 then
    self:become("idle")
    self.vel = self.nextvel
  end
end

function platform:collide(o)
  if o:is_a("arrow") then
    o:become("hidden")
    o.vel.x = 0
  elseif o:is_a("walls") and not o.hidden then
    if self.state ~= "waiting" then play_sfx("hit") end
    self:become("waiting")
    self.nextvel = v(-self.vel.x, self.vel.y)
    self.vel.x = 0
    return c_move_out, {true, true, false, false}
  else
    return c_push_out
  end
end

small_platform = platform:extend({
  hitbox = box(1, 0, 7, 8),
  sprite = {
    idle = {87}
  }
})

small_platform:spawns_from(87)

bar = entity:extend({
  draw_order = 1
})

function bar:init()
  self.pos = v(rnd(196), rnd(128))
  self.sp = rnd(0.1) + 0.05
  self.vel = v(self.sp, 0)
  self.spr = rnd() > 0.5 and 1 or 0
end

function bar:render()
  spr(241 + 32 * self.spr, self.pos.x, self.pos.y, 4 - self.spr)
  --rectfill(self.pos.x, self.pos.y, self.w, self.h, self.c)
  if self.pos.x > 196 then
    self.pos = v(-40, rnd(128))
    self.sp = rnd(0.1) + 0.05
    self.vel = v(self.sp, 0)
  end
end

rswitch = entity:extend({
  color = "red",
  sprite = {
    idle = {17},
    toggled = {18}
  },

  draw_order = 6,
  hitbox=box(1, 1, 6, 6),
  collides_with = {"arrow"}
})

rswitch:spawns_from(17)

function rswitch:collide(o)
  if o:is_a("arrow") and not o.did and not o.done and o.state=="idle" then
    o:become("hidden")
    o.vel.x = 0
    for o in all(entities_tagged[self.color]) do
      if o.state == "idle" or o.state == "toidle" then o:become("tohid")
      else o:become("toidle") end
    end
    if self.state=="idle" then self:become("toggled") else
    self:become("idle") end
    o.did = true
    shake(10, 2)

    play_sfx("toggle")
  end
end

red = entity:extend({
  sprite = {
    idle = {15},
    hidden = {16},
    toidle = {90 + 64},
    tohid = {90 + 64},
  },
  hitbox = {
    hidden = box(0, 0, 0, 0),
    box(1, 1, 7, 7)
  },
  draw_order = 6,
  tags={"red", "walls"}
})
red:spawns_from(15, 16)

function red:init()
  if self.tile == 16 then
    self:become("hidden")
  end
end

function red:tohid(t)
  if t>=5 then self:become("hidden") end
end

function red:toidle(t)
  if t>=5 then self:become("idle") end
end

function red:collide(o)
  if o:is_a("arrow")  and self.state == "idle" then o:become("hidden") end
  if self.state=="idle" then return c_push_out end
end

bswitch = rswitch:extend({
  color = "blue",
  sprite = {
    idle = {17 + 32},
    toggled = {18 + 32}
  }
})

bswitch:spawns_from(17 + 32)

blue = red:extend({
  sprite = {
    idle = {15 + 32},
    toidle = {90 + 96},
    tohid = {90 + 96},
    hidden = {16 + 32}
  },
  tags={"blue","walls"}
})

blue:spawns_from(15 + 32, 16 + 32)

function blue:init()
  if self.tile == 16 + 32 then
    self:become("hidden")
  end
end

gswitch = rswitch:extend({
  color = "green",
  sprite = {
    idle = {17 + 64},
    toggled = {18 + 64}
  }
})

gswitch:spawns_from(17 + 64)

green = red:extend({
  sprite = {
    idle = {15 + 64},
    toidle = {90 + 128},
    tohid = {90 + 128},
    hidden = {16 + 64}
  },
  tags={"green","walls"}
})

green:spawns_from(15 + 64, 16 + 64)

function green:init()
  if self.tile == 16 + 64 then
    self:become("hidden")
  end
end

rope = entity:extend({
  tags = {"rope"},
  draw_order = 3,
  hitbox = box(2, 9, 4, 8)
})

rope:spawns_from(20, 21, 88, 89)

function rope:render(p)
  spr(self.tile, p.x, p.y)
end

launcher = entity:extend({
  collides_with = {"guy","item","walls"},
  hitbox = box(0, 1, 8, 7),
  sprite = {
    idle = {51},
    half = {52},
    down = {53}
  },
  draw_order = 5,
  feetbox = box(0, 8, 8, 8.01)
})

launcher:spawns_from(51)

function launcher:down(t)
  if t>=15 then
    self:become("idle")
  end
end

function launcher:collide(o)
  if not self.supported_by then return end
  if not o.supported_by and self.state=="idle" and o.state~="held" and o.vel and not o:is_a("arrow") then
    self:become("down")
    if o.fly then
      o:become("fly")
    end
    o.vel.y = -2.7
    play_sfx("jump")
  end

  if o:is_a("wall") then
    return c_push_out
  end
end

jelly = item:extend({
  sprite = {
    idle = {22},
    bounce = {23}
  },
  tags={"item"},
  float = true,
  collides_with={"walls","guy","item"},
  hitbox = box(1, 0, 7, 4),
  weight = {0.1,held=0,floaty=0},
  draw_order = 9,
  feetbox = box(1, 4, 7, 4.01)
})

jelly:spawns_from(22)

function jelly:init()
  self.vel = v(0, 0)
  self.pos.x = self.pos.x - 1
  self.pos.y = self.pos.y + 4
end

function jelly:floaty(t)
  if t==0 then self.start = self.pos.y - 1 end
  self.pos.y = self.start + cos(t / 200) * 2
end

function jelly:idle()
  self.vel.x = self.vel.x * 0.8
end

function jelly:collide(e)
  if e:is_a("guy")  then
    self.collides = at
    e.collidei = self
  end

  if not ( self.state == "held" or abs(self.vel.x) > 0.1) and e~=self and e.vel and not e.supported_by and e.state~="held" and (self.state=="idle" or self.state=="floaty") and not e:is_a("walls")  and (not e.isd or not e:isd()) then
    self:become("bounce")
    if e.fly then e:become("fly") end
    e.vel.y = -2.7
    play_sfx("jump")
  end
  if e:is_a("walls") and not self.supported_by and e.state ~="hidden" and self.state~="held" then
    play_sfx("bhit")
  end
end

function jelly:bounce(t)
  if t >= 15 then self:become("idle") end
end

star = entity:extend({

})

function star:init()

  self.pos = v(rnd(192),rnd(128))
  self.s = rnd(2)
  self.c = rnd() > 0.7 and (rnd() > 0.5 and 12 or 6) or 7
end

function star:render()
  color(self.c)
  love.graphics.points(self.pos.x + 0.5, self.pos.y + 0.5)
end


snow=entity:extend({
  draw_order = 15
})
 function snow:init()
  self.pos=v(rnd(192),rnd(128))
  self.sz=rnd()>0.7 and 2 or 1
  self.sp=0.3+rnd(1)
  self.t=rnd(100)
 end
 function snow:render()
  local x,y,sz=self.pos.x,
   self.pos.y,self.sz
  rectfill(x,y,self.sz,self.sz,7)
 end
 function snow:idle(t)
  self.pos=self.pos+v(self.sp,cos(t/100)/2)
  if self.pos.x>192 then self.pos=v(-10,rnd(192)) end
 end


balloon = entity:extend({
  hitbox = box(0, 0, 8, 8),
  draw_order = 4,
  collides_with = {"arrow", "item"},
  sprite = {
    idle = {83},
    hidden = {83, 84, 85, delay = 5}
  },
  weight = {
    0,
    hidden = 0.1
  }
})

balloon:spawns_from(83)

function balloon:init()
  self.vel = v(0, 0)
  self.pos.y = self.pos.y + 4
  self.start = self.pos.y
end

function balloon:idle(t)
  self.pos.y = self.start + cos(t / 120) * 2
  if self.item then
    self.item.pos.y = self.pos.y + 13
    self.item.pos.x = self.pos.x
  end
end

function balloon:hidden(t)
  if t >= 14 then
    self.done = true
  end
end

function balloon:render()
  ospr(239 + (self.t % 60 > 30 and 1 or 0), self.pos.x, self.pos.y + 7)
  spr_render(self)
end

function balloon:collide(o)
  if o:is_a("arrow") and o.state =="idle" and self.state == "idle" then
    self:become("hidden")
    o.did = true
    o:become("hidden")
    o.vel.x = 0
    play_sfx("pop")

    if self.item then
      self.item:become("idle")
    end
  elseif o:is_a("item") then
    o:become("held")
    self.item = o
    self.t = rnd(1000)

  end
end

tnt = item:extend({
  sprite = {
    idle = {46},
    blowing = {19}
  },
  exlodes  = true,
  draw_order = 10,
  tags = {"item","expl"},
  collides_with = {"arrow","walls","guy"},
  hitbox = box(1, 1, 5, 7),
  feetbox = box(1, 1, 5, 7.01)
})

tnt:spawns_from(46)

function tnt:init()
  self.vel = v(0, 0)
  self.pos.y = self.pos.y + 1
  self.nostop = 0
end

function tnt:idle()
  if self.nostop > 0 then self.nostop = self.nostop - 1 else
  self.vel.x = self.vel.x * 0.8 end
end

function tnt:collide(o)

  if o:is_a("arrow") and o.state=="idle" then
    o:become("hidden")
    o.vel.x = 0

      self.noexpl = true
    self:become("blowing")
    unlock("boom")
    expl(self.pos.x + 4, self.pos.y +4 , true)
  elseif o:is_a("guy") then
    if self.state ~= "idle" then return end

    self.collides = at
    o.collidei = self
  elseif o:is_a("walls") and not self.supported_by and o.pos.y>self.pos.y  and self.state~="held" then
    if self.state ~= "idle" then return end

     play_sfx("hit")
  end
end

function tnt:blowing(t)
  if t>10 then self.done = true end
end

particle = entity:extend({
  draw_order = 11
})

function particle:init()
  self.vel = v(rnd(2) - 1, rnd(2) - 1)
end

function particle:idle()
  self.size = self.size - 0.1

  if self.size < 0 then
    self.done = true
  end

  self.vel = self.vel * 0.9
end

function particle:render()
  circfill(self.pos.x, self.pos.y, self.size, self.color)
end

snake = entity:extend({
  sprite = {
    idle = {144},
    toidle = {145},
    tohid = {145},
    hidden = {112}
  },
  tags = {"walls","snk"},
  collides_with = {"item","arrow","guy"},
  breaks = true,
  hitbox = box(1, 1, 6, 6),
  force = 4,
  sp = 15,
  sp2 = 75,
  color = "green"
})

snake:spawns_from(112, 144)

function snake:init()
  if self.tile == 112 then
    self:become("hidden")
  else
    if not g_snk[self.color] then
      g_snk[self.color]=self
    end
  end
end

function snake:idle(t)
  if t == self.sp then
    local e
    local e2

    for en in all(entities_tagged["snk"]) do
      if en.color==self.color and en~=self and en.state=="hidden" then
        local dx=flr((en.pos.x-self.pos.x)/8)
        local dy=flr((en.pos.y-self.pos.y)/8)
        local d=abs(dx)+abs(dy)

        if d==1 then
          e = en
          break
        elseif d==2 and not e2 then
          e2 = e
        end
      end
    end

    if e then
      e:become("toidle")
    elseif e2 then
      e2:become("toidle")
    else
      g_snk[self.color]:become("toidle")
    end
  elseif t >= self.sp2 then
    self:become("tohid")
  end
end

function snake:toidle(t) if t>=4 then self:become("idle") end end
function snake:tohid(t) if t>=4 then self:become("hidden") end end

function snake:collide(o)
  local b = false
  if self.state == "idle" and not o:is_a("arrow") then return c_push_out, {b,b,true,b} end
end

rsnake = snake:extend({
  color = "red",
  sprite = {
    idle = {144 + 256},
    toidle = {145 + 256},
    tohid = {145 + 256},
    hidden = {112 + 256}
  },
  sp = 15,
  sp2 = 33
})

rsnake:spawns_from(112 + 256, 144 + 256)

function rsnake:init()
  if self.tile == 112 + 256 then
    self:become("hidden")
  else
    if not g_snk[self.color] then
      g_snk[self.color]=self
    end
  end
end

function rsnake:collide(o)
  if o.kill and self.state=="idle" then
    o:kill()
  end
end

tiki = entity:extend({
  sprite = {
    idle={271},
    height = 2
  },
  tags={"walls"},
  collides_with={"guy"},
  hitbox = box(0, 0, 8, 16)
})

tiki:spawns_from(271)

function tiki:init()
  e_add(tiki_spikes({pos = v(self.pos.x - 8, self.pos.y + 2),tile=302}))
  e_add(tiki_spikes({pos = v(self.pos.x - 8, self.pos.y + 8),tile=302}))
  e_add(tiki_spikes({pos = v(self.pos.x + 8, self.pos.y + 2),tile=304}))
  e_add(tiki_spikes({pos = v(self.pos.x + 8, self.pos.y + 8),tile=304}))
end

function tiki:collide(o)
  return c_push_out
end

tiki_spikes = entity:extend({
  collides_with={"guy","arrow"}
})

function tiki_spikes:init()
  self.hitbox = (self.tile == 302 and box(6, 2, 8, 7)
    or box(0, 2, 2, 7))
end

function tiki_spikes:idle(t)
  if t>120 then
    self:become("hidden")
  end
end

function tiki_spikes:hidden(t)
  if t>120 then
    self:become("idle")
  end
end

function tiki_spikes:collide(o)
  if self.state == "idle" then
    if o.kill then o:kill() end
    if o:is_a("arrow") then o.vel.x = 0 o:become("hidden") end
  end
end

function tiki_spikes:render()
  if self.state=="idle" then spr(self.tile, self.pos.x, self.pos.y) end
end

toggle = entity:extend({
  sprite = {
    idle = {24 + 32},
    hidden = {25 + 32}
  },
  tags = {"jump","walls"},
  hitbox = box(2, 2, 6, 6)
})

toggle:spawns_from(24 + 32, 25 + 32)

function toggle:init()
  if self.tile == 25 + 32 then
    self:become("hidden")
  end
end

function toggle:jump()
  self:become(self.state == "idle" and "hidden" or "idle")
  play_sfx("toggle")
end

function toggle:collide()
  if self.state=="idle" then return c_push_out end
end

light = entity:extend({

})

light:spawns_from(137 + 256, 136 + 256)

function light:render()
  spr(self.tile + (self.t%30 > 15 and 32 or 0), self.pos.x, self.pos.y)
end

fall = entity:extend({
  hitbox = box(0, 0, 8, 8),
  tags = {"walls"},
  collides_with={"guy","arrow","item"},
  sprite = {
    idle = {24},
    breaking = {24, 25, 26, delay = 5},
    build = {27, 28, 24, delay = 5},
    hidden = {}
  },
  weight = {0, breaking = 0.1}
})

fall:spawns_from(24)

function fall:init()
  self.vel = v(0, 0)
  self.pos.x = self.pos.x - 1
  self.start = self.pos.y
end

function fall:breaking(t)
  if t >= 14 then self:become("hidden") end
end

function fall:hidden(t)
  if t >= 120 then self:become("build") self.pos.y = self.start self.vel.y = 0 end
end

function fall:build(t)
  if t >= 14 then self:become("idle") end
end

function fall:collide(o)
  if self.state~="idle" and self.state ~= "breaking" then return end
  if o:is_a("guy") then
    self:become("breaking")
    return c_push_out
  elseif o:is_a("arrow") and not arrow.did and self.state=="idle" then
    o.did = true
    o.vel.x = 0

    self:become("breaking")
    o:become("hidden")
    return c_push_out
  end
  return c_push_out
end

invis = entity:extend({
  sprite = {
    hidden = {},
    idle = {111},
    tovis = {113},
    tohid = {113}
  },
  hitbox = box(2, 2, 7, 7),
  tags = {"walls"},
  collides_with = {"guy","arrow"}
})

invis:spawns_from(111)

function invis:init()
  self:become("hidden")
  self.long = false
end

function invis:render()
  local s = self.sprite[self.state][1]

  if self.state=="idle" and self.long and (self.t < 200 or self.t % 30 < 15) then
    s = s - 3
  end

  spr(s,self.pos.x,self.pos.y)
end

function invis:idle(t)
  self.vis=self:should()
  -- todo: long
  if self.vis and self.state ~="tovis" and self.state ~="idle" then self:become("tovis") end
  if not self.vis and self.state ~="tohid" and self.state~="hidden" then self:become("tohid") self.long = false end
end

function invis:should()
  if not g_guy then return false end

  local pd = g_guy.pos - self.pos
  local pa

  if g_arrow and (g_arrow.state=="stuck" or g_arrow.state =="idle") and not g_arrow.did then
    pa = g_arrow.pos - self.pos
  end

  if math.sqrt(pd.x * pd.x + pd.y * pd.y) < 20 then
    return true
  elseif pa and math.sqrt(pa.x * pa.x + pa.y * pa.y) < 50 then
    return true
  end

  return (self.long and self.t <= 299 or false)
end

function invis:hidden()
  self:idle()
end

function invis:tovis(t) if t>=5 then self:become("idle") end end
function invis:tohid(t) if t>=5 then self:become("hidden") end end

function invis:collide(o)
  if o:is_a("arrow") and o.state=="idle" and not o.did then
    o:become("hidden")
    o.did = true
    o.vel.x = 0
    self.long = true
    self.t = 0
  end

  if self.state=="idle" then return c_push_out end
end

pushable = entity:extend({
  sprite = {
    idle = {121}
  },
  tags = {"walls","weight","pbox"},
  collides_with = {"guy","walls","arrow","item"},
  hitbox = box(1, 1, 7, 7),
  feetbox = box(0, 6, 7, 7.01),
  weight = {0.1,held=0},
  draw_order = 10
})

pushable:spawns_from(121)

function pushable:idle()
  self.vel.x = self.vel.x * 0.6
self.wall =  false
end

function pushable:init()
  self.vel = v(0, 0)
  self.pos.y = self.pos.y + 1
  self.pos.x = self.pos.x - 1
end

function pushable:collide(o)
  if o==self or o.state=="hidden" then return end
  if o:is_a("guy")  then
    self.collides = 3
    o.collidei = self
    if self.state=="held" then return end
    if not self.lig and self.t%2 == 0 then
      if o.pos.y >= self.pos.y - 2 and o.item == o.bow
       then -- fixme: can be pushed into walls
        o.push = 3
        return c_move_out,{true,true,false,false}
      else
        return c_push_out
      end
    end
  elseif o:is_a("arrow") and not o.did  and o.state~="hidden" then
  if self.state=="held" then return end
    o.did = true
    o:become("hidden")
    o.vel.x = 0
    return c_move_out_vel, {true,true,false,false}
  elseif o:is_a("walls") and o.state~="hidden" then
    self.wall = true
  if self.state=="held" then return end
    if not self.supported_by and o.pos.y>self.pos.y then play_sfx("hit") end
    return c_move_out,{true,true,true,false}
  elseif not o:is_a("btn") then

    if self.state=="held" then return end
    return c_push_out
  end
end

button = entity:extend({
  sprite = {
    idle = {90},
    down = {90 + 32}
  },
  color = "red",
  tags = {"btn"},
  collides_with = {"weight"},
  hitbox = box(1, 7, 7, 8)
})

button:spawns_from(90)

function button:init()
  if g_index > 59 then
    self.w = e_add(wire({
      pos = v(self.pos.x, self.pos.y + 8),
      state = "off",
      draw_order = 13,
      tile = 284
    }))
  end
end

function button:collide(o)
  if o:is_a("weight") then

    if self.state~="down" then self:toggle() play_sfx("button") end
    self:become("down")
    self.t = 0
  end
end

function button:toggle()
  for o in all(entities_tagged[self.color]) do
    if o.state == "idle" or o.state == "toidle" then o:become("tohid")
    else o:become("toidle") end
  end
end


function button:idle() if self.w then self.w:set("off") end end
function button:down(t)
  if self.w then self.w:set("idle") end
  if t>3 then self:become("idle") self:toggle() play_sfx("button") end
end


gbutton = button:extend({
  sprite = {
    idle = {91},
    down = {90 + 32}
  },
  color = "green"
})

gbutton:spawns_from(91)

bbutton = button:extend({
  sprite = {
    idle = {91 + 64},
    down = {90 + 32}
  },
  color = "blue"
})

bbutton:spawns_from(91 + 64)


ball = entity:extend({
  sprite = {
    idle = {91 + 32}
  },
  hitbox = box(1, 1, 5, 5),
  weight = 0.2,
  collides_with = {"walls","guy","arrow"},
  draw_order = 11,
  tags = {"ball","weight"}
})

ball:spawns_from(91 + 32)

function ball:init()
  self.vel = v(0, 0)
  self.pos.y = self.pos.y + 3
  self.old = self.pos
end

function ball:idle()
  if self.pos.x~=self.old.x then
    self.vel.x = (self.pos.x - self.old.x > 0 and 1 or -1) * 0.5
  end

  self.old = self.pos
end

function ball:collide(o)
  if o:is_a("guy") and self.vel.x == 0 then
    if o.pos.y >= self.pos.y - 4 and o.item == o.bow then
      o.push = 3
      return c_move_out,{true,true,false,false}
    else
      return c_push_out
    end
  elseif o:is_a("arrow") and not o.did and o.state~="hidden" then
    o.did = true
    o:become("hidden")
    o.vel.x = 0
    return c_move_out, {true,true,false,false}
  elseif o:is_a("walls") and o.state~="hidden" and not o:is_a("guy") then
    return c_move_out
  elseif not o:is_a("btn") and not o:is_a("guy") then
    return c_push_out
  end
end
blowable = entity:extend({
  tags = {"walls","blowable"},
  draw_order = 8,
  hitbox = box(1, 1, 7, 7)
})

blowable:spawns_from(259)

function blowable:collide(o)
  return c_push_out
end

function blowable:render()
  spr(self.tile,self.pos.x,self.pos.y)
end

takeable = pushable:extend({
  tags = {"weight","pbox","item"},
  sprite = {
    idle = {119}
  },
  lig = true
})

takeable:spawns_from(119)

function takeable:init()
  self.collides = 0
end

function takeable:idle()
  self.vel.x = self.vel.x * 0.7
  self.collides = max(0, self.collides - 1)
end

function takeable:render_hud()
  if self.collides>0 and self.state == "idle" then
    ospr(171, self.pos.x + 1, self.pos.y - 10)
    if btnp("x") and self.t > 10 then
      g_guy:peek(self)
    end
  end
end

spear = entity:extend({
  sprite = {
    idle = {246}
  },
  hitbox = box(0, 0, 8, 3),
  bold = true,
  collides_with = {"guy","walls"}
})

spear:spawns_from(246)

function spear:init()
  self.start = self.pos.y
end

function spear:idle()
  if not g_guy then return end
  if abs(g_guy.pos.x - self.pos.x)<10 and g_guy.pos.y > self.pos.y then
    self:become("down")
  end
end

function spear:down()
  self.pos.y = self.pos.y + 1
end

function spear:render()
  rectfill(self.pos.x + 3, self.start, 2, self.pos.y - self.start + 1, 0)
  spr_render(self)
end

function spear:collide(o)
  if o.kill and self.state=="down" then
    o:kill()
  end

  self:become("did")
end


lava = entity:extend({
  tags={"water"},
  collides_with = {"guy","item"},
  hitbox = box(0, 1, 8, 7),
  sprite = {
    idle = {220, 221, 222, 223, delay = 15},
    big = {190, 191, delay = 30}
  }
})

lava:spawns_from(220, 221, 222, 223, 190, 191)

function lava:init()
  self.draw_order = 10
  if self.tile == 190 or self.tile == 191 then
    self:become("big")
    self.t = rnd(128)
  else
    self.draw_order = 3
  end
  --self.t = rnd(128)
end

function lava:collide(o)
  if o:is_a("guy") then
    if self.state~="idle" then o:kill() unlock("melt") end
  elseif not o.done and self.state ~="idle" then
    o.done = true
    for i = 0, 10 do
      e_add(particle({
        pos = v(o.pos.x + 4, o.pos.y + 4),
        size = 3,
        color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
      }))
    end
  end
end

jump = entity:extend({
  draw_order = 3
})

jump:spawns_from(544 + 96)

function jump:render()
  local s=btn("z") and 544 + 100 or 544 + 96
  spr(s, self.pos.x, self.pos.y)
end

shoot = entity:extend({
  draw_order = 3
})

shoot:spawns_from(544 + 96 + 32)

function shoot:render()
  local s=btn("x") and 544 + 100 + 32 or 544 + 96 + 32
  spr(s, self.pos.x, self.pos.y)
end

coin = entity:extend({
  sprite = {
    idle = {31, 31 + 32, 29, 30, delay = 10},
    die = {738, 739, delay = 6}
  },
  hitbox = box(1, 1, 7, 7),
  collides_with = {"guy"},
  draw_order = 8
})

coin:spawns_from(31)

function coin:die()
  if self.t >= 2 * 6 - 1 then self.done = true  end
end

function coin:init()
  if g_levels[g_index + 1] and g_levels[g_index + 1].coin then
    self.done = true
  end

  self.start = self.pos.y + 4
  self.pos.x = self.pos.x - 1
  self.vel = v(0, 0)
end

function coin:idle(t)
  self.pos.y = self.start + cos(t / 100) * 2
end

function coin:follow()
  self.vel.x = self.vel.x * 0.9
  self.vel.y = self.vel.y * 0.9
  if g_guy.done then
    self:become("die")
    return
  end

  local dx = self.pos.x + 4 - g_guy.pos.x - 4
  local dy = self.pos.y + 4 - g_guy.pos.y - 4
  local d = math.sqrt(dx * dx + dy * dy)

  if d > 10 then

    self.vel.x = self.vel.x - dx / (d * 10)
    self.vel.y = self.vel.y - dy / (d * 10)
  end
end

function coin:collide(o)
  if self.state=="idle" and o:is_a("guy") then
    g_got_coin = true
    self:become("follow")
    play_sfx("coin")
    unlock("shiny")
  end
end


cube = entity:extend({
  draw_order = 11,
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy","holder"}
})

cube:spawns_from(321)

function cube:init()
  self.t = rnd(1000)
  g_cube = self
  local max = get_amount()
  if max <= g_cubes then
    self.done = true
  end
  self.size = 8
end

function cube:render()
  render_cube(self.pos.x, self.pos.y, self.size, self.t / 200)
end

function cube:collide(o)
  if o:is_a("guy") then
    if self.state == "idle" then
      self:become("pick")
      g_dockstate = "open"

      play_sfx("cube")
      if g_index == 0 then
        e_add(tfx({
          text = "collected power cube",
          pos = v(self.pos.x, self.pos.y),
          target = v(self.pos.x, self.pos.y - 8)
        }))
      end
    end
  end
end

function cube:idle() self:common() end

function cube:pick()
  local max = get_amount()
  local h = max * 4 + 1
  local target = 64 - math.floor(h / 2) + (g_cubes)* 4 + 1

  local dx = 2 - self.pos.x - self.size / 2
  local dy = target + 1 - self.pos.y - self.size / 2
  local d = math.sqrt(dx * dx + dy * dy)

  if not self.startd then
    self.startd = d
  end

  self.size = 7 * (d / self.startd) + 1

  if d <= 4 then
    self.done = true
    g_cubes = g_cubes + 1
    g_picked = true
    g_dockstate = "close"
  else
    self.pos.x = self.pos.x + dx / d
    self.pos.y = self.pos.y + dy / d
  end
  self:common()
end

function cube:fly()
  local dx = self.target.pos.x - self.pos.x +4
  local dy = self.target.pos.y - self.pos.y + 4
  local d = math.sqrt(dx * dx + dy * dy)

  if not self.startd then
    self.startd = d
  end

  self.size = 8 - 7 * (d / self.startd)

  if d <= 2 then
    self:become("toend")
    self.target.power = true
    g_dockstate = "close"
    g_powered = g_powered + 1
  else
    self.pos.x = self.pos.x + dx / d
    self.pos.y = self.pos.y + dy / d
  end
  self:common()
end

function cube:toend()
  self.size = self.size - 1
  if self.size <=0 then
    self.done = true
  end
  self:common()
end


function cube:common()
  addLight(self.pos.x, self.pos.y)
end

cube_holder = entity:extend({
  tags = {"holder"},
  sprite = {idle={322}},
  hitbox = box(2, 2, 6, 6),
  draw_order = 4,
})

cube_holder:spawns_from(323, 322)

function cube_holder:render()
  spr(self.tile + (self.power and -32 or 0), self.pos.x, self.pos.y)
end
function cube_holder:idle()
  addLight(self.pos.x, self.pos.y)
end

function cube_holder:init()
  self.power = false
  self.found = false
  g_hold = true
end

tfx = entity:extend({
  draw_order = 14
})


function tfx:idle()
  local dx = self.target.x - self.pos.x
  local dy = self.target.y - self.pos.y
  local d = math.sqrt(dx * dx + dy * dy)

  if not self.id then self.id = d end

  if d > 1 then
    self.pos.x = self.pos.x + dx / self.id
    self.pos.y = self.pos.y + dy / self.id
  else
    self:become("wait")
  end
end

function tfx:wait()
  if self.t > 180 then self.done = true end
end
function tfx:wait()
  if self.t > 180 then self.done = true end
end

function tfx:render()
  -- todo: fade in?

  t_calpa = g_calpha
  g_calpha = nil
  local c = (self.state == "idle" and (min(7, flr(self.t / 5) + 5)) or 7)
  if self.state ~="wait" or (self.t < 120 or self.t % 20 < 11) then oprint(self.text, self.pos.x - #self.text * 2, self.pos.y - 2, c) end

  g_calpha = t_calpa
end

bat = entity:extend({
  sprite = {
    idle = {640, 641, 642, 643, delay = 6},
    fly = {644, 645, 646, delay = 10},
    die = {647}
  },
  bold = true,
  hitbox = { box(0, 0, 8, 5), die= box(0, 0, 8, 3)},
  draw_order = 8,
  collides_with = {"walls","guy","arrow"},
  tags= {"enemy","expl"},
  weight = {0, die = 0.1}
})

function bat:init()
  self.dead =false
  self.vel = v(0, 0)
  g_enemies = g_enemies + 1
end

function bat:collide(o)
if o:is_a("guy") and self.state ~="idle" and self.state ~="die" then
  o:hit()
  self:kill()
elseif o:is_a("arrow") and not o.did and o.state == "idle"  and self.state~="die" then
    o:become("hidden")
    o.did = true
    o.vel.x = 0
    self:kill()
  end
end

function bat:idle()
  if self.t >= 23 then
    self:become("fly")
    self.t = rnd(128)
  end
end

function bat:check()
  if self.pos.y > 128 then self:kill() end
end

function bat:fly()
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)
    if d > 1 then
      self.pos.x = self.pos.x - dx / (d * 3)
      self.pos.y = self.pos.y - dy / (d * 3) + cos(self.t / 30) / 5
    end
  end
end
function bat:kill()
  if not self.dead then
    -- todo: sfx
    g_enemies = g_enemies - 1
    self.dead = true
    self:become("die")
    self.vel.x = 0
    self.vel.y = 0
    play_sfx("edead")
    for i = 1, 10 do
      e_add(blood({
        pos = v(self.pos.x + 2, self.pos.y + 4),
        size = 2,
        color = rnd() > 0.7 and 2 or 8
      }))
    end
  end
end

function bat:die()

end


blood = entity:extend({
  draw_order = 2,
  weight = 0.1
})

function blood:init()
  self.vel = v(rnd(2) - 1, 0)
end

function blood:idle()
  self.size = self.size - 0.1

  if self.size < 0 then
    self.done = true
  end

  self.vel = self.vel * 0.9
end

function blood:render()
  circfill(self.pos.x, self.pos.y, self.size, self.color)
end

zombie = bat:extend({
  sprite = {
    idle = {648, 649, 650, 651, 652, delay = 6},
    main = {653, 654, delay = 15},
    die = {652, 651, 650, 649, 648, delay = 6},
    flips = true
  },
  hitbox =box(0, 0, 8, 8),
  feetbox=box(0, 0, 8, 8.01),
  weight = 0.1
})

function zombie:die()
  self.vel.x = 0
  if self.t >= 23 then
    self.t = 23
  end
end

function zombie:idle()
  if self.t >= 29 then self:become("main")
  self.t = rnd(128) end
end

function zombie:main()
  self.vel.x = 0
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)
    self.flipped = dx > 0
    if d > 1 then
      self.pos.x = self.pos.x - dx / (d * 4)
      if dy > 0 and self.supported_by then
        self.vel.y = -1.55
      end
    end
  end
  self:check()
end

slime = bat:extend({
  sprite = {
    idle = {655, 656, 657, 658, delay = 6},
    main = {659, 660, delay = 15},
    die = {658, 657, 656, 655, delay = 6}
  },
  hitbox =box(0, 0, 8, 8),
  feetbox=box(0, 0, 8, 8.01),
  weight = 0.1,
  float = true
})

function slime:die()
  self.vel.x = 0
  if self.t >= 22 then
    self.t = 22
  end
end

function slime:idle()
  if self.t >= 23 then self:become("main")
  self.t = rnd(128) end
end

function slime:main()
  self.vel.x = 0
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)

    self.vel.x = dx > 0 and -0.7 or 0.7
          -- self.pos.x = self.pos.x - dx / (d * 4)
      if self.supported_by or self.in_water then
        self.vel.y = -1.75
      end
  end
  self:check()
  self.in_water = false
end

spider = bat:extend({
  sprite = {
    idle = {661, 662, 663, 664, delay = 16},
    main = {665},
    jump = {666},
    down = {666, 667, 666, 669, delay = 10},
    die = {668}
  },
  hitbox ={box(0, 0, 8, 4),die=box(0, 0, 8, 2)},
  feetbox=box(0, 0, 8, 4.01),
  weight = {0, jump=0.1,down=0.1}
})

function spider:idle()
  self.vel.x = 0
  if self.t >= 23 then self:become("main")
  self.t = rnd(128) end
end

function spider:main()
  self.vel.x = 0
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)

    if dx < 20 then
      self:become("jump")
    end
  end
  self.in_water = false
end

function spider:jump()
  if self.supported_by then
    self:become("down")
  end
end

function spider:down()
  self.vel.x = 0
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)

    self.vel.x = self.vel.x - dx / (d * 2)
          -- self.pos.x = self.pos.x - dx / (d * 4)
    if self.supported_by and self.t % 120 < 60 then
      self.vel.y = -1.75
    end
  end
  self:check()
end

bomber = bat:extend({
  sprite = {
    idle = {672},
    grow = {673, 674, 675, delay = 6},
    main = {676, 677, 678, delay = 10},
    die = {675, 674, 673, delay = 6},
    flips = true
  },
  hitbox = box(0, 0, 8, 8),
  feetbox = box(0, 0, 8, 8.01),
  weight = 0.1
})

function bomber:die()
  if self.t >= 17 then self.done = true end
end

function bomber:kill()
  if self.state ~= "die" then

    play_sfx("edead")
    self.noexpl = true
    self:become("die")
    g_enemies = g_enemies - 1
    expl(self.pos.x + 4, self.pos.y + 4, false)
  end
end

function bomber:idle()
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)

    if d < 48 then
      self:become("grow")
    end
  end
end

function bomber:grow()
  if self.t >= 17 then self:become("main") end
end

function bomber:main()
  self.vel.x = 0
  if g_guy.state ~= "dead" and g_guy.state ~="dead2" then
    local dx = self.pos.x - g_guy.pos.x
    local dy = self.pos.y - g_guy.pos.y
    local d = math.sqrt(dx * dx + dy * dy)

    if d < 16 then
      self:kill()
    else
      self.vel.x = - dx / (d * 3)
      if dy > 0 and self.supported_by then
        self.vel.y = -1.75
      end
    end
  end
  self:check()
end

function expl(x, y, b)
  play_sfx("expl")
  for i = 1, 10 do
    e_add(particle({
      pos = v(x, y),
      size = 3,
      color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
    }))
  end

  if b then
    for e in all(entities_tagged["blowable"]) do
      local dx = e.pos.x + 4 - x
      local dy = e.pos.y + 4 - y
      local d = math.sqrt(dx * dx + dy * dy)
      if d < 32 then
        e_remove(e)
          for i = 1, 10 do
            e_add(particle({
              pos = v(e.pos.x + 4, e.pos.y + 4),
              size = 3,
              color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
            }))
          if e.map_pos then
              mset(e.map_pos.x, e.map_pos.y, g_dt)
          end
        end
      end
    end
  else
    for e in all(entities_tagged["expl"]) do
      if not e.noexpl then
        local dx = e.pos.x + 4 - x
        local dy = e.pos.y + 4 - y
        local d = math.sqrt(dx * dx + dy * dy)
        if d < 16 then
          if e.kill then e:kill() end
          for i = 1, 10 do
            e_add(particle({
              pos = v(e.pos.x + 4, e.pos.y + 4),
              size = 3,
              color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
            }))
          end
        end
      end
    end
    local e = g_guy
    local dx = e.pos.x + 4 - x
    local dy = e.pos.y + 4 - y
    local d = math.sqrt(dx * dx + dy * dy)
    if d < 16 then
      e:hit()
      for i = 1, 10 do
        e_add(particle({
          pos = v(e.pos.x + 4, e.pos.y + 4),
          size = 3,
          color = (rnd() > 0.5 and 5 or (rnd() > 0.5 and 6 or 7))
        }))
      end
    end
  end
end

wreg = {}

switch = entity:extend({
  sprite = {
    idle = {86},
    off = {86 + 32}
  },
  draw_order = 8,
  hitbox = box(0, 3, 8, 8),
  tags = {"switch","wire"},
  collides_with = {"arrow","guy"}
})

switch:spawns_from(86, 86 + 32)

function switch:init()
  if self.tile == 86 + 32 then
    self:become("off")
  end
  self.w = wreg[flr(self.pos.x / 8) .. ":" .. (flr(self.pos.y / 8) - 1)]

  if self.w then
    local me = self

    self.w.onchange = function(self)
      if self.state ~= me.state then me:toggle() end
    end
  end

  self.collides = 0
end

function switch:collide(o)
  if o:is_a("arrow") and not o.did and o.state == "idle" then
    self:toggle()
    o.did = true
    o.vel.x = 0
    o:become("hidden")
  elseif o:is_a("guy") then
    o.collidei = self
    self.collides = 3
  end
end

function switch:render_hud()
  if self.collides>0  then
    self.collides = self.collides - 1
    ospr(171, self.pos.x + 1, self.pos.y - 8)
    if btnp("x") and self.t > 10 then
      self:toggle()
      btns[kmap["x"]] = false
    end
  end
end

function switch:toggle()
  if self.state == "idle" then self:become("off") else self:become("idle") end
  play_sfx("toggle")
  shake(10, 3)


  if self.w then
    self.w:set(self.state)
  end
end

wire = entity:extend({
  draw_order = 2
})

swire = wire:extend({
  tags = {"walls"},
  collides_with={"guy","arrow","item"},
  hitbox = box(0, 0, 8, 8),
  draw_order = 10
})

owire = wire:extend({

})

owire:spawns_from(344, 345)

function owire:init()
  if self.tile == 344 then self:become("off") end
end

function owire:render()
  spr(self.state == "off" and 344 or 345, self.pos.x, self.pos.y)
end

swire:spawns_from(252 + 32, 252 + 32 + 96, 251 + 64 + 96, 251 + 64)

wire:spawns_from(
250, 251, 252,
 250 + 32,
250 + 64,  252 + 64, 287,
-- on
250 + 96, 251 + 96, 252 + 96,
250 + 32 + 96,
250 + 64 + 96,  252 + 64 + 96, 287 + 96
)

local wdirs = {
[250] = {v(1, 0), v(0, 1)},
[251] = {v(1, 0), v(-1, 0)},
[252] = {v(-1, 0), v(0, 1)},
[250 + 32] = {v(0, 1), v(0, -1)},
[252 + 32] = {v(0, 1), v(0, -1)},
[250 + 64] = {v(1, 0), v(0, -1)},
[251 + 64] = {v(1, 0), v(-1, 0)},
[252 + 64] = {v(-1, 0), v(0, -1)},
[287] = {v(-1, 0), v(0, 1), v(1, 0)}
}


function swire:collide(o)
  return c_push_out
end

function wire:init()
  self.map_pos = v(flr(self.pos.x / 8), flr(self.pos.y / 8))
  wreg[self.map_pos.x .. ":" .. self.map_pos.y] = self

  if self.tile <= 252 + 64 then
    self:become("off")
  else
    self.tile = self.tile - 96

  end
end

function wire:render()
  spr(self.tile + (self.state == "off" and 0 or 96), self.pos.x, self.pos.y)
end

function wire:set(s)

  if self.state ~= s then
    self:become(s)
    if self.onchange then self:onchange() end
    if wdirs[self.tile] then
      for k, d in pairs(wdirs[self.tile]) do
        local x = self.map_pos.x + d.x
        local y = self.map_pos.y + d.y
        local w = wreg[x .. ":" .. y]

        if w~=self and w then
          w:set(s)
        end
      end
    end
  end
end


gate = entity:extend({
  draw_order = 5,
  tags = {"gate"}
})

function gate:preinit()
  self.inputs = {}

  if not self.noout then
    local w = e_add(wire({
      pos = v(self.pos.x + 16, self.pos.y),
      tile = 251
    }))

    self.output = {v(2,0),w=w}
  end
end

function gate:render()
  spr(317, self.pos.x, self.pos.y)
  ospr(self.tile, self.pos.x + 4, self.pos.y + 4)
end

function gate:change()

end

function gate:set_state(s)
  self.output.w:set(s)
end

function gate:get_state(i)
  return self.inputs[i].w.state
end

function gate:add_input(id, p)
  local st = "off"
  local w = wreg[(flr(self.pos.x / 8) + p.x - 1) .. ":" .. (flr(self.pos.y / 8) + p.y)]

  if w then
    st = w.state
  end

  local w = e_add(wire({
    pos = v(self.pos.x + p.x * 8, self.pos.y +  p.y * 8),
    tile = 251,
    onchange = function()
      self:change()
    end
  }))
  w:become(st)
  add(self.inputs, {v=p,t=t,w=w})
end

invert = gate:extend({
  sprite = {
    idle = {381}
  }
})

invert:spawns_from(381)

function invert:tinit()
  self:preinit()
  self:add_input("main", v(-1, 0))
  self:change()
end

function invert:change()
  local i = self:get_state(1)
  self:set_state(i == "idle" and "off" or "idle")
end

function invert:render()
  spr_render(self)
end

gand = gate:extend({
  sprite = {
    idle = {253}
  }
})

gand:spawns_from(253)

function gand:tinit()
  self:preinit()
  self:add_input("1", v(-1, 0))
  self:add_input("2", v(-1, 1))
  self:change()
end

function gand:change()
  local i1 = (self:get_state(1)== "idle")
  local i2 = (self:get_state(2)== "idle")

  self:set_state((i1 and i2) and "idle" or "off")
end

gor = gate:extend({
  sprite = {
    idle = {254}
  }
})

gor:spawns_from(254)

function gor:tinit()
  self:preinit()
  self:add_input("1", v(-1, 0))
  self:add_input("2", v(-1, 1))
  self:change()
end

function gor:change()
  local i1 = (self:get_state(1)== "idle")
  local i2 = (self:get_state(2)== "idle")

  self:set_state((i1 or i2) and "idle" or "off")
end


gxor = gate:extend({
  sprite = {
    idle = {255}
  }
})

gxor:spawns_from(255)

function gxor:tinit()
  self:preinit()
  self:add_input("1", v(-1, 0))
  self:add_input("2", v(-1, 1))
  self:change()
end

function gxor:change()
  local i1 = (self:get_state(1) == "idle")
  local i2 = (self:get_state(2) == "idle")

  self:set_state(((i1 and not i2) or (not i1 and i2)) and "idle" or "off")
end

redgate = gate:extend({
  noout = true,
  sprite = {
    idle = {253 + 32},
    off = {254 + 32}
  },
  color = "red"
})


redgate:spawns_from(253 + 32, 254 + 32)

function redgate:tinit()
  if self.tile == 254 + 32 then
    self:become("off")
  end
  self:preinit()
  self:add_input("1",v(-1, 0))
end

function redgate:render()
  spr_render(self)
end

function redgate:change()
  self:become(self.state == "idle" and "off" or "idle")
  for o in all(entities_tagged[self.color]) do
    if o.state == "idle" or o.state == "toidle" then o:become("tohid")
    else o:become("toidle") end
  end
end

bluegate = redgate:extend({
  sprite = {
    idle = {253 + 32 + 128},
    off = {254 + 32 + 128},
  },
  color = "blue"
})

bluegate:spawns_from(253 + 32 + 128, 254 + 32 + 128)

greengate = redgate:extend({
  sprite = {
    idle = {253 + 32 + 128 + 32},
    off = {254 + 32 + 128 + 32},
  },
  color = "green"
})

greengate:spawns_from(253 + 32 + 128 + 32 , 254 + 32 + 128 + 32)

torch = entity:extend({
  sprite = {
    idle = {452, 453, 454, delay = 4}
  },
  bold = true
})

torch:spawns_from(452)

function torch:init()
  self.t = rnd(1000)
end

function torch:idle()
  addLight(self.pos.x + 4, self.pos.y + 4)
end


function get_amount()
  return (flr(g_index / 20)) * 2 + 4
end


candle = torch:extend({
  sprite = {
    idle = {452 + 160, 453 + 160, 454 + 160, delay = 4}
  },
  hitbox = box(0, 0, 8, 8),
  feetbox = box(0, 0, 8, 8.1),
  collides_with = {"walls","guy"},
  weight = 0.1,
  draw_order = 10
})

candle:spawns_from(452 + 160)

function candle:idle()
  self.vel.x = self.vel.x * 0.8
  addLight(self.pos.x + 4, self.pos.y + 4)
end

function candle:init()
  self.collides = 0
  self.vel = v(0, 0)
end

function candle:render_hud()
  if self.collides > 0 then
    self.collides = self.collides - 1
    ospr(171, g_guy.pos.x + 2, g_guy.pos.y - 10)
    if btnp("x") and self.t > 10 then
      g_guy:peek(self)
      btns[kmap["x"]] = false
    end
  end
end

function candle:collide(o)
  if o:is_a("guy") then
    self.collides = 3
  end
end

rspikes = entity:extend({
  sprite = {
    idle = {58},
    toidle = {59},
    todown = {59},
    down = {60}
  },
  draw_order = 5,
  hitbox = {box(0, 0, 8, 8),toidle=box(0,2,8,6),todown=box(0,2,8,6)},
  tags = {"walls"},
  breaks = true,
  collides_with = {"guy","item","enemy"}
})

rspikes:spawns_from(58, 60)

function rspikes:init()
  if self.tile == 60 then
    self:become("down")
  end
end

function rspikes:todown(t) if self.t >= 15 then self:become("down") end end
function rspikes:toidle(t) if self.t >= 15 then self:become("idle") end end

function rspikes:idle(t) if self.t >= 60 then self:become("todown") end end
function rspikes:down(t) if self.t >= 60 then self:become("toidle") end end

function rspikes:collide(o)
  if o.kill then
    if self.state == "down" and o.pos.y > self.pos.y then
      o:kill()
    elseif self.state == "idle" and o.pos.y < self.pos.y then
      o:kill()
    end
  end

  return c_push_out
end


buffer = gate:extend({
  sprite = {
    idle = {573}
  }
})

buffer:spawns_from(573)

function buffer:tinit()
  self:preinit()
  self:add_input("main", v(-1, 0))
  self:change()

  local i = ( self:get_state(1) == "idle")
  self:set_state(i and "idle" or "off")
end

function buffer:idle()
  if self.t == 60 and self.next ~= self.output.w.state then
    self:set_state(self.next)
    play_sfx("toggle")
  end
end

function buffer:change()
  local i = (self:get_state(1) == "idle")
  self.next = (i and "idle" or "off")
  self.t = 0
end

function buffer:render()
  spr_render(self)
end

disk  = entity:extend({
  draw_order = 3,
  hitbox = box(1,1,6,6),
  collides_with = {"guy","enemy","kills"}
})

disk:spawns_from(307)

g_r = 0
function disk:init()
  self.t = g_r * 130
  g_r = g_r + 1
  self.cx = self.pos.x
  self.cy = self.pos.y
  if self.state == "idle" then self:idle() end
end

function disk:idle()
  self.pos.x = self.cx + cos(self.t / 200) * 16
  self.pos.y = self.cy + sin(self.t / 200) * 16
end

function disk:render()
  if self.state == "idle" then
  ospr(308, self.cx, self.cy)
else

  spr(307, self.pos.x, self.pos.y, 1, 1, 1, 1, self.t / 40)
end
end

function disk:render_hud()
  if self.state == "idle" then love.graphics.setColor(palette[5])
  love.graphics.line(self.pos.x + 3.5, self.pos.y + 3.5, self.cx + 4, self.cy + 4)
  spr(307, self.pos.x, self.pos.y, 1, 1, 1, 1, self.t / 40) end
end

function disk:collide(o)
  if o:is_a("guy") then unlock("meat_boy") end
  if o.kill and not o.killed then
    o:kill()
    play_sfx("saw")
    o.killed = true
    for i = 0, 10 do
      e_add(blood({
        color = 8,
        size = 2,
        pos = v(o.pos.x + 4, o.pos.y + 4)
      }))
    end
  end
end

cutter = entity:extend({
  draw_order = 10,
  hitbox = box(0, 2, 16, 8),
  tags = {"walls"},
  sprite = {
    idle = {307 + 32},
    add = {307 + 32 + 2},
    width = 2
  },
  breaks = true,
  bold = true
})

cutter:spawns_from(307 + 32)

function cutter:init()
  if not self.added then
    e_add(cutter({
      added = true,
      state = "add",
      pos = v(self.pos.x+16,self.pos.y)
    }))

  self.d = e_add(disk({
    state = "bind",
    pos = v(self.pos.x, self.pos.y - 2)
  }))
end
end

function cutter:collide()
  return c_push_out--, {false,false,true,false}
end

function cutter:idle()
  if self.d then self.d.pos.x = cos(self.t/100) * 12 + 12 + self.pos.x end
end


bigs = entity:extend({
  draw_order = 11,
  hitbox = box(2, 2, 14, 14),
  collides_with = {"guy","enemy","kills"}
})

bigs:spawns_from(371)

function bigs:init()
  self.t = rnd(1024)
  self.dir = rnd()>0.5 and 1 or -1
end

function bigs:render()
  spr(371, self.pos.x, self.pos.y, 2, 2, 1, 1, self.t / 100 * self.dir)
end

function bigs:collide(o)
  if o:is_a("guy") then unlock("meat_boy") end
  if o.kill and not o.killed then
    o:kill()
    play_sfx("saw")
    o.killed = true
    for i = 0, 10 do
      e_add(blood({
        color = 8,
        size = 2,
        pos = v(o.pos.x + 4, o.pos.y + 4)
      }))
    end
  end
end

sink = entity:extend({
  sprite = {
    width = 2,
    idle = {513}
  },
  hitbox = box(0, 0, 16, 8),
  collides_with = {"guy"},
  tags = {"walls","sink"},
  draw_order = 10,
  s = 0.4,
  breaks = true,
  up = false
})

sink:spawns_from(513)

function sink:init()
  self.start = self.pos.y + 1
end

function sink:collide(o)
  if o:is_a("arrow") then o.vel.x = 0 o.did = true o:become("hidden") end
  if o:is_a("walls") then
    return c_move_out
  else


    if o.state == "dead" or o.state == "dead2" then return end
    if o.pos.y < self.pos.y - 7  then
    self:become("down")
    self.o = o
    self.t = 0 end
    return c_push_out
  end
end

function sink:down()
  self.pos.y = self.pos.y + self.s * (self.up and -1 or 1)
  self.o.pos.y = self.o.pos.y + self.s* (self.up and -1 or 1)
  self.pos.y = mid(8, 120, self.pos.y)
  if self.t >= 10 then
    self:become("idle")
  end
end

function sink:idle()
  if self.t > 60 then
    if not self.up and self.pos.y > self.start  then
      self.pos.y = self.pos.y - self.s
    end
    if self.up and self.pos.y < self.start then
      self.pos.y = self.pos.y + self.s
    end
  end
    self.pos.y = mid(8, 120, self.pos.y)
end

function sink:render()
  spr(self.up and 515 or 513, self.pos.x, self.pos.y, 2)
end

function sink:render_hud()
  -- oprint(self.t .. " " .. self.state, self.pos.x, self.pos.y, 7)
end


usink = sink:extend({
  up = true
})

usink:spawns_from(515)

pswitch = entity:extend({
  sprite = {
    idle = {517},
    off = {518}
  },
  breaks = true,
  collides_with = {"arrow"},
  draw_order = 5,
  hitbox = box(1, 1, 7, 7)
})

pswitch:spawns_from(517, 518)

function pswitch:collide(o)
  if o:is_a("arrow") and not o.did and o.state == "idle" then
    o.did = true
    o.vel.x = 0
    o:become("hidden")
    self:toggle()
  end
end

function pswitch:toggle()
  play_sfx("toggle")
  shake(20, 3)
  if self.state == "idle" then self:become("off")
  else self:become("idle") end

  for e in all(entities_tagged["sink"]) do
    e.up = not e.up
  end
end

mspike = entity:extend({
  hitbox = box(0, 0, 8, 8),
  bold = true,
  tags = {"jump", "walls"},
  breaks = true,
  draw_order = 5
})

mspike:spawns_from(549, 550, 551, 552)

function mspike:init()
  self.free = true
  self.py = self.pos.y
  self.start = self.pos.y
  self.down = false

  if self.tile == 551 then
    self.tile = 549
    self.py = self.start - 9
    self.pos.y = self.py
  elseif self.tile == 549 then
    self.down = true
  end

  if self.tile == 552 then
    self.tile = 550
    self.py = self.start + 9
    self.pos.y = self.py
  elseif self.tile == 550 then
    self.down = true
  end
end

function mspike:render()
  ospr(self.tile, self.pos.x, self.pos.y)
end

function mspike:jump()
  if not self.free then return end
  self.free = false
  local me = self
  if self.down then
    flux.to(self, 0.005, { py = self.start + (self.tile == 550 and 9 or -9) }):oncomplete(function()
      me.free = true
    end)
    self.down = false
  else
    self.down = true
    flux.to(self, 0.005, { py = self.start }):oncomplete(function()
      me.free = true
    end)
  end
end

function mspike:collide(o) if o.kill then o:kill() end end

function mspike:idle()
  self.pos.y = self.py
end

teleport = entity:extend({
  hitbox = box(3, 3, 5, 5),
  collides_with = {"arrow","item"},
  tags = {"walls","teleport"},
  draw_order = 5
})

teleport:spawns_from(77 - 32, 77, 78)

function teleport:init()
  if entities_tagged["teleport"] then
    for e in all(entities_tagged["teleport"]) do
      if e~=self and not e.pair then self.pair = e e.pair = self break end
    end
  end
  if self.tile == 77 - 32 then
    self:become("wave")
  end
  self.start = self.pos.y
  self.at = 0
end

function teleport:render()
  spr(self.tile, self.pos.x, self.pos.y)
end

function teleport:idle()
  addLight(self.pos.x + 4, self.pos.y + 4)
end

function teleport:wave()
  self.at = self.at + 1
  self.pos.y = self.start + cos(self.at / 300) * 16
  addLight(self.pos.x + 4, self.pos.y + 4)
end

function teleport:collide(o)
  if o:is_a("arrow") or o:is_a("item") then
    if self.pair and self.t > 10 and not o.done and o.state ~= "held" and o.state ~= "hidden" and o.state ~= "stuck" then
      o.pos.x = self.pair.pos.x
      o.pos.y = self.pair.pos.y
      o.nostop = 10
      self.t = 0
      self.pair.t = 0
      play_sfx("teleport")
      for i = 0, 10 do
        e_add(particle({
          pos = v(self.pos.x + 4, self.pos.y + 4),
          size = 4,
          color = rnd() > 0.7 and 5 or 6
        }))
      end
      for i = 0, 10 do
        e_add(particle({
          pos = v(self.pair.pos.x + 4, self.pair.pos.y + 4),
          size = 4,
          color = rnd() > 0.7 and 5 or 6
        }))
      end
    end
  end
end

dino = entity:extend({
  sprite = {
    idle = {546}
  },
  hitbox = box(0, 0, 8, 8),
  bold = true,
  draw_order = 9,
  collides_with = {"guy"}
})

function dino:init()
  self.pos.x = self.pos.x - 1
  self.y = self.pos.y + 9
  self.collides = 0
end

function dino:collide()
  self.collides = 3
end

function dino:idle()
  if self.collides > 0 then
    self.collides = self.collides - 1
    if self.y > self.pos.y + 1 then  self.y = self.y - 0.3 end
  else
    if self.y < self.pos.y + 9 then self.y = self.y + 0.3 end
  end
end

function dino:render()
  ospr(self.sprite.idle[1], self.pos.x, self.y)
end

dino:spawns_from(546)

live = entity:extend({
  sprite = {
    idle = {547}
  },
  hitbox = box(2, 2, 6, 6),
  tags = {"walls"}
})

live:spawns_from(547)

function live:init()
  if g_dif ~= "Easy" then self.done = true end
end

function live:collide() return c_push_out end