bow = entity:extend({
  draw_order = 10,
  sprite = {
    idle = {195},
    active = {195}
  },
  cursed = false,
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy"},
  tm = 15
})

bow:spawns_from(195)

function bow:init()
  self.collides = 0
  self.pos.y = self.pos.y + 1
end

function bow:idle()
  self.tm = self.tm + 1
  if g_guy.state~="dead" and g_guy.state~="dead2" and not g_guy.collidei and btnp("x") and g_guy.item == self then self:become("active") end
end

function bow:active()
  if  not btn("x") then self:use() self:become("idle") end
end

function bow:render()
  if (self.state == "active") and g_guy.state ~="dend" then
    spr(self.sprite.active[1], self.pos.x + (self.flipped and - 1 or 1) * 4, self.pos.y, 1, 1, self.flipped, false)
  elseif self.state == "idle" and g_guy.bow == nil then
    spr_render(self)
  end
end

function bow:collide(o) self.collides = 3  end

function bow:render_hud()
  if g_guy.bow == nil and self.collides > 0 and self.state == "idle" then
    self.collides = self.collides - 1
    ospr(171, g_guy.pos.x + 2, g_guy.pos.y - 10)
    if btnp("x") and self.t > 10 then

      play_sfx("pick")
      g_guy.bow = self
      g_guy.item = self
    end
  end
end

function bow:use()
  if self.tm < 15 then return end
  self.tm = 0
  local p = 6
  local m = self.flipped and - 1 or 1

  play_sfx("fire")
  e_add(arrow({
    pos = v(self.pos.x + (self.flipped and 0 or -4), self.pos.y),
    flipped = self.flipped,
    cursed = self.cursed,
    vel = v(p * m, 0)
  }))
end

arrow = entity:extend({
  draw_order = 9,
  sprite = {
    idle = {196},
    stuck = {544 + 32, 544 + 64, 196, delay = 4},
    hidden = {196, 167, 167 - 32, delay = 6},
    width = 2,
    flips = true
  },
  tags = {"walls", "arrow"},
  collides_with = {"walls"},
  hitbox = box(3, 1, 13, 5),
  weight = {0, hidden = 0.1}
})

function arrow:collide(e)
  if not e:is_a("teleport") and e:is_a("walls") and self.state == "idle" and e.state ~= "hidden" and not e:is_a("guy") and not e:is_a("item") and not e:is_a("bridge") then
    if not e.breaks then
      self:become("stuck")
      self.vel = v(0, 0)

      play_sfx("arrow_hit")
    else
      self:become("hidden")

      play_sfx("arrow_hit_breaking")
    end
    return c_move_out, {true, true, false, false}
  elseif e.vel and self.state=="stuck" then
    local dy, vy = e.pos.y - self.pos.y + 4, e.vel.y
    if vy > 0 and dy <= vy + 1 then
      if e:is_a("guy") then self.t = 2 end
      return c_push_out, {false, false, true, false}
    end
  end
end

function arrow:stuck()
  if self.t == 0 then
    e_add(aifx({
      pos = v(self.pos.x + (self.flipped and -2 or 5), self.pos.y - 4),
      _flipped = self.flipped
    }))
  end

  if self.t >= 4 * 2 then self.t = 33 end
  self.at = self.at + 1

  if g_index > 79 and g_index < 100 and self.at >= 180 then
    self:become("hidden")
  end
end

function arrow:hidden(t)
  e_add(blood({
    pos = v(self.pos.x + 4, self.pos.y),
    color = rnd() > 0.7 and 2 or 8,
    size = 2
  }))
  if t>=15 then
    self.done = true
  end
end

function arrow:init()
  if g_arrow and self.cursed then
    g_arrow:become("hidden")
  end

  self.at =  0
  self.did = false
  g_arrow = self
end

barrow = entity:extend({
  sprite = {
    idle = {448},
    up = {196},
    toup = {167 - 32, 167, 196, delay = 4},
    width = 2
  },
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy"},
  draw_order = 10
})

barrow:spawns_from(448)

function barrow:init()
  self.collides = 0
  self.start = self.pos.y
end

function barrow:collide(o)
  self.collides = 3
end

function barrow:render_hud()
  if self.collides > 0 and self.state == "idle" and g_read then
    self.collides = self.collides - 1
    ospr(171, g_guy.pos.x + 2, g_guy.pos.y - 10)
    if btnp("x") and self.t > 10 then
      play_sfx("pick")
      self:become("toup")
      shake(100, 3)
    end
  end
end

function barrow:up()

  if t_calpa > 0 then
  t_calpa = t_calpa - 1 else self.done = true end
end

function barrow:toup()
  if self.pos.y > self.start - 10 then
    self.pos.y = self.pos.y - 1
  else
    self:become("up")
  end
end

ped = entity:extend({
  sprite = {
    idle = {395},
    hidden = {},
    width = 2,
    height = 2
  },
  hitbox = box(0, 0, 16, 1),
  tags = {"walls"},
  draw_order = 2
})

ped:spawns_from(395)


function ped:collide(e)
  if self.state == "hidden" then return end
  if not e.vel then return end
  local dy, vy = e.pos.y - self.pos.y + 4, e.vel.y
  if vy > 0 and dy <= vy + 1 then
    return c_push_out, {false, false, true, false}
  end
end

function ped:render()
  if self.t > 60 or self.t % 20 <= 10 then spr_render(self) end
end

function ped:spawn()
  self:become("idle")
  g_barrow = true
  shake(30, 5)
  t_calpa = 0
  e_add(artifact({
    pos = v(self.pos.x, self.pos.y - 8)
  }))
  play_sfx("expl")
  self.t = 0
end

function ped:idle()

end

function ped:init()
  g_ped = self
  self.undo = -1
  g_barrow = false
  self.t = 100
  if g_index == 101 then self:become("hidden") end
end

tomb = entity:extend({
  sprite = {
    idle = {433},
    width = 2,
    height = 2
  },
  hitbox = box(0, 0, 16, 16),
  collides_with = {"guy"},
  draw_order = 2
})

tomb:spawns_from(433)

function tomb:init()
  g_read = false
end

function tomb:collide()
  if not g_read then
    g_read = true
    g_time = 0
    self.t = 0 end
end

function tomb:render_hud()
  if g_read then
    if g_time < 180 then oprint("[Here lies Sam Swift]", self.pos.x + 2, self.pos.y - 4, 7)
    elseif g_time < 180 * 2 then
      coprint("He's gone... my father is dead...", 112, 6)
    elseif not g_barrow then
      g_ped:spawn()
    end
  end
end

guy = entity:extend({
  vel = v(0, 0),
  tags = {"guy","weight"},
  collides_with = {"walls","rope"},
  hitbox = box(0, 0, 8, 8),
  feetbox = box(0, 7, 8, 8.01),
  sprite = {
    idle = {224, 224 + 64, delay = 30},
    walk = {225, 227, 228, 229, delay = 5},
    fly = {225},
    dead = {578, 579, 580, delay = 15},
    dead2 = {581},
    born = {544 + 96 + 128, 544 + 96 + 128 + 1, 544 + 96 + 128 + 2, delay = 5},
    dend = {544 + 96 + 128 + 2, 544 + 96 + 128 + 1, 544 + 96 + 128, delay = 5},
    climb = {232, 233, delay = 10},
    pushing = {582, 583,  delay = 15},
    flips = true,
  },
  draw_order = 8,
  bold = true,
  weight = {0.1, climb = 0}
})

function guy:born(t) if t>=14 then self:become("idle") end end
function guy:dend(t) if self.item~=self.bow and self.item.todone then self.item:become("todone") end self.vel = v(0, 0) if t>=14 then self.done = true end end

function guy:dead(t)
  addLight(self.pos.x + 4, self.pos.y + 4)
  self.vel = v(0, 0)
  if t == 3 * 15 - 2 then
      g_dead = true
      schedule(restart_level) -- todo
  elseif t >= 3 * 15 - 1 then
    self.t = 3 * 15 - 1
  end
end
function guy:dead2(t)
  addLight(self.pos.x + 4, self.pos.y + 4)
  self.vel = v(0, 0)
  if t == 3 * 15 - 2 then
      g_dead = true
      schedule(restart_level) -- todo
  end
end


function guy:collide(o)
  if o:is_a("rope") then
    self.on_ladder = true
  end
end

function guy:pushing() self:walk() end

function get_hp()

    if g_dif == "Easy" then return 3
    elseif g_dif == "Normal" then  return 2
    elseif g_dif == "Hard" then return 2
    elseif g_dif == "Ultra Hard" then return 1 end

  printh("no")
  printh(g_dif)
end

function guy:spawn_pet()
  local p
  if g_ppet == "bat" then
    p = bbat
  elseif g_ppet == "meatboy" then
    p = meatboy
  elseif g_ppet == "ufo" then
    p = ufo
  elseif g_ppet == "coin" then
    p = cin
  elseif g_ppet == "strawberry" then
    p = strawberry
  end
  if self.pet then
    e_remove(self.pet)
    for i = 1, 10 do
      e_add(particle({
        pos = v(self.pet.pos.x+ 4, self.pet.pos.y+ 4),
        size = 2,
        color = rnd() > 0.7 and 5 or 6
      }))
    end
  end
  if p then

  self.pet = e_add(p({
    pos = v(self.pos.x, self.pos.y)
  })) end
end

function guy:init()
  g_guy = self

  if state ~= cut and g_ppet then
    self:spawn_pet()
  end

  self.push = 0
  self.hp = get_hp()

  self.invt = 0

  if g_index < 100 then
    self.item = bow({
      pos = self.pos,
      cursed =  true
    })
    self.bow = self.item
    e_add(self.bow)

  end
end

function guy:hit()
  if self.state ~= "dead" and self.state ~="dead2" and self.state ~= "dend"  and self.invt == 0 then
    self.hp = self.hp - 1
    if self.hp == 0 then
      self:kill()
    else
      play_sfx("edead")
      shake(10, 3)
      vibrate(0.3)
      self.invt = 60
    end
  end
end

function guy:idle()
  self:walk()
end

function guy:walk()
  local on_ice = true
  local sand = true
  if not self.supported_by or not self.supported_by.ice then
    self.vel.x = self.vel.x * 0.6
    on_ice = false
  end

  if not self.supported_by or not self.supported_by.souldsand then
    sand = false
  end


  local a = on_ice and 0.6 or (sand and 0.2 or 0.3)
  self.vel.x = mid(-a, a, self.vel.x)

  if btn("left") then
    self.vel.x = self.vel.x - (sand and 0.5 or 1)
    self:become(self.push>0 and "pushing" or "walk")
  end

  if btn("right") then
    self.vel.x = self.vel.x + (sand and 0.5 or 1)
    self:become(self.push>0 and "pushing" or "walk")
  end

  if abs(self.vel.x) < 0.1 then
    self.vel.x = 0
    self:become("idle")
  end

  if self.push>0 then
    self.vel.x = self.vel.x * 0.5
    self:become("pushing")
  end

  if not self.supported_by then
    self:become("fly")
    self:common()

    return
  elseif btnp("z") then
    self.vel.y = -(sand and 0.2 or 1.2)
    self:become("fly")
    play_sfx("jump")

    if entities_tagged["jump"] then
      for e in all(entities_tagged["jump"]) do
        e:jump()
      end
    end

    e_add(jfx({
     pos = v(self.pos.x - 4, self.pos.y)
    }))
    self:common()

    return
  end

  if (self.state == "pushing" or self.state == "walk" ) and self.t%15 == 0 then

    if self.t > 14 then e_add(wfx({
      pos = v(self.pos.x, self.pos.y),
      flipped =  self.facing == "left"
    }))    end
  end

  if ( self.state == "pushing" or self.state == "walk") and self.t%15 == 5 then
    play_sfx(rnd()>0.5 and "step2" or "step")
  end

  self:common()
end

function guy:kill()
  unlock("dead")
  if g_deaths >= 100 then unlock("suid") end
  if self.state ~= "dead" and self.state ~="dead2" and self.state ~= "dend" then
    play_sfx("death")
    vibrate(0.3)
    shake(30, 3)
    self.hp = 0
    if self.supported_by then self:become("dead") else self:become("dead2") end
  end
end

function guy:fly()
  local on_ice = true
  if not self.supported_by or not self.supported_by.ice then
    on_ice = false
  end
  self.vel.x = self.vel.x * 0.9

  if self.supported_by then
    self:become(self.on_ice and "walk" or "idle")
    play_sfx("land")

    e_add(lfx({
      pos = v(self.pos.x - 4, self.pos.y)
    }))
    self:common()

    return
  end

  if btn("z") and self.vel.y < 0 and self.t < 10 then
    self.vel.y = -1.5
  end

  local s = 0.1

  if btn("left") then
    self.vel.x = self.vel.x - s
  end

  if btn("right") then
    self.vel.x = self.vel.x + s
  end

  if self.on_ladder and self.vel.y >= 0 then
    self:become("climb")
  end

  self:common()
end

function guy:common()
  self.collidei = nil
  if self.item then self.item.pos = v(self.pos.x, self.pos.y)
  self.item.flipped = self.facing == "left" end

  addLight(self.pos.x + 4, self.pos.y + 4)

  if btnp("x") and self.item ~= self.bow then

    self.item:become("idle")
    if(self.item.vel and not btn("down")) then self.item.vel.x = (self.flipped and -2 or 2) end
    self.item = self.bow
  end

  self.invt = max(0, self.invt - 1)


  if self.pos.y > 128 then
    self:kill()
  end

  self.pos.x = mid(self.pos.x, 0, 192 - 8)
  self.pos.y = max(self.pos.y, 0)

  if self.on_ladder and (btn("up") or btn("down")) then
    self:become("climb")
  end

  self.push = max(self.push - 1, 0)
end

function guy:render_hud()
  if self.state == "dead" or self.state == "dead2" then
    for i = 1, 10 do
      local d = self.t / 2 + 4
      local a = i / 10 + g_time / 150
      local x = cos(a) * d + self.pos.x + 4
      local y = sin(a) * d + self.pos.y + 4
      circfill(x, y, 2, 7)
    end
  end
end

function guy:render()
  if self.invt == 0 or self.invt % 20 < 10 then
    spr_render(self)
  end
end

function guy:climb()
  if btnp("z") then
    self.vel.y = -1.5
    self.on_ladder = false
    self:become("fly")
    self:common()
    return
  end

  if not self.on_ladder then
    self:become("fly")
    self:common()

    return
  end

  self.vel = v(0, 0)
  if btn("left") then self.vel = self.vel - v(0.6, 0) end
  if btn("right") then self.vel = self.vel + v(0.6, 0) end
  if btn("up") then self.vel = self.vel - v(0, 0.6) end
  if btn("down") then self.vel = self.vel + v(0, 0.6) end

  if self.vel.x == 0 and self.vel.y == 0 then
    self.t = self.t - 1
  end

  self.on_ladder = false
  self:common()
end

function guy:peek(i)
  if self.item ~= self.bow then
    self.item:become("idle")
  end
  play_sfx("pick")
  self.item = i
  i:become("held")
end

function ospr(s, x, y, w, h, fx, fy)
  for xx = x - 1, x + 1 do
    for yy = y - 1, y + 1 do
      if abs(xx - x)+abs(yy - y)== 1 then
        bspr(s, xx, yy, w, h, fx, fy)
      end
    end
  end

  spr(s, x, y, w, h, fx, fy)
end

jfx = entity:extend({
  sprite = {
    idle = {992, 994, 996, 998, 1000, delay = 5},
    width = 2,
  },
  draw_order = 2
})

function jfx:idle(t)
  if t>=5 * 5 - 1 then self.done = true end
end

lfx = entity:extend({
  sprite = {
    idle = {1002, 1004, 1006, 1008, 1010, delay = 5},
    width = 2,
  },
  draw_order = 2
})

function lfx:idle(t)
  if t>=5 * 5 - 1 then self.done = true end
end

wfx = entity:extend({
  sprite = {
    idle = {1012, 1013, 1014, 1015, 1016, delay = 5},
    flips = true
  },
  draw_order = 2
})

function wfx:idle(t)
  if t>=5 * 5 - 1 then self.done = true end
end

aifx = entity:extend({
  sprite = {
    idle = {1017 - 32, 1018 - 32, 1019 - 32, 1020 - 32, 1021 - 32, delay = 5},
    height = 2,
    flips = true
  },
  draw_order = 1
})

function aifx:idle(t)
  if t>=5 * 5 - 1 then self.done = true end
end

lfx = entity:extend({
  sprite = {
    idle = {992 - 32, 994 - 32, 996 - 32, 998 - 32, 1000 - 32, delay = 5},
    width = 2
  },
  draw_order = 3
})

function lfx:idle(t)
  if t>=5 * 5 - 1 then self.done = true end
end

pet = entity:extend({
  draw_order = 10,
  bold = true
})

function pet:init()
  self.vel = v(0, 0)
  self.posy = 12
  for i = 0, 10 do
    e_add(particle({
      size = 2,
      color = rnd() > 0.7 and 5 or 6,
      pos = v(self.pos.x + 4, self.pos.y + 4)
    }))
  end
end

function pet:idle()
  if self.dod then self:dod() end

  self.vel.x = self.vel.x * 0.9
  self.vel.y = self.vel.y * 0.9
  if g_guy then
    local dx = g_guy.pos.x - self.pos.x
    local dy = g_guy.pos.y - self.pos.y - self.posy
    local d = math.sqrt(dx * dx + dy * dy)


    if d > 14 then
      --self.pos.x = self.pos.x + dx / d
      --self.pos.y = self.pos.y + dy / d
      self.vel.x = self.vel.x + dx / (d * 14)
      self.vel.y = self.vel.y + dy / (d * 14)
    end
  end

  addLight(self.pos.x + 4, self.pos.y + 4)
end


ufo = pet:extend({
  sprite = {
    idle = {481, 482, delay = 60},
  },
  posy = 12
})

function ufo:dod()
  self.posy = self.posy + cos(self.t / 300) / 10
end

cin = pet:extend({
  sprite = {
    idle = {615, 616, 617, 618, delay = 10},
  },
  posy = 12
})

strawberry = pet:extend({
  sprite = {
    idle = {619},
  }
})

function strawberry:dod()
  self.pos.y = self.pos.y + cos(self.t / 300) / 10
end

meatboy = pet:extend({
  sprite = {
    idle = {620},
  }
})

function meatboy:dod()
  self.posy = 0
  self.pos.x = self.pos.x + cos(self.t / 300) / 5

  e_add(blood({
    pos = v(self.pos.x + rnd(8), self.pos.y + rnd(8)),
    color = rnd() >0.7 and 2 or 8,
    size = 2
  }))
end


bbat = pet:extend({
  sprite = {
    idle = {621, 622, 623, delay = 10}
  }
})

function bbat:dod()
  self.pos.y = self.pos.y + cos(self.t / 300) / 10
end


sm = entity:extend({
  draw_order = 5,
  hitbox = box(0, 4, 8, 8),
  collides_with = {"guy"}
})

sm:spawns_from(399)

local snames = {
  [104] = {
    "Reset Progress"
  },
  [105] = {
    "Vibration",
    "Screenshake",
    "Touch Controls",
    "Timer",
    "Difficulty",
    "Joystick",
    "Key Bindings"
  },
  [106] = {
    "SFX",
    "Music"
  },
  [107] = {
    "1-1",
    "1-2",
    "1-3",
    "1-4",
    "1-5",
    "1-6",
    "1-7",
    "1-8",
    "1-9",
    "1-10"
  },
  [108] = {
    "1-11",
    "1-12",
    "1-13",
    "1-14",
    "1-15",
    "1-16",
    "1-17",
    "1-18",
    "1-19",
    "1-20"
  },
  [109] = {
    "2-1",
    "2-2",
    "2-3",
    "2-4",
    "2-5",
    "2-6",
    "2-7",
    "2-8",
    "2-9",
    "2-10"
  },
  [110] = {
    "2-11",
    "2-12",
    "2-13",
    "2-14",
    "2-15",
    "2-16",
    "2-17",
    "2-18",
    "2-19",
    "2-20"
  },
  [111] = {
    "3-1",
    "3-2",
    "3-3",
    "3-4",
    "3-5",
    "3-6",
    "3-7",
    "3-8",
    "3-9",
    "3-10"
  },
  [112] = {
    "3-11",
    "3-12",
    "3-13",
    "3-14",
    "3-15",
    "3-16",
    "3-17",
    "3-18",
    "3-19",
    "3-20"
  },
  [113] = {
    "4-1",
    "4-2",
    "4-3",
    "4-4",
    "4-5",
    "4-6",
    "4-7",
    "4-8",
    "4-9",
    "4-10"
  },
  [114] = {
    "4-11",
    "4-12",
    "4-13",
    "4-14",
    "4-15",
    "4-16",
    "4-17",
    "4-18",
    "4-19",
    "4-20"
  },
  [115] = {
    "5-1",
    "5-2",
    "5-3",
    "5-4",
    "5-5",
    "5-6",
    "5-7",
    "5-8",
    "5-9",
    "5-10"
  },
  [116] = {
    "5-11",
    "5-12",
    "5-13",
    "5-14",
    "5-15",
    "5-16",
    "5-17",
    "5-18",
    "5-19",
    "5-20"
  }
}


function trim2(s)
  return s:match "^%s*(.-)%s*$"
end
function check_setting(name)
  if name == "Screenshake" then return g_ess
  elseif name == "Vibration" then return g_ev
  elseif name == "Touch Controls" then return g_ek
  elseif name == "Timer" then return g_et
  elseif name == "Difficulty" then return {"Easy","Normal","Hard","Ultra Hard"}
  elseif name == "Joystick" then
    local t = {"None"}

    for k, v in pairs(g_joysticks) do
      add(t, "Joystick #" .. v:getID())
    end

    printh("len " .. #t)

    return t
  elseif name == "Key Bindings" then return false
  elseif name == "SFX" then return g_es
  elseif name == "Music" then return g_em
  elseif tonumber(name:sub(1, 1)) ~= nil then
    local id = tonumber(name:sub(1, 1))
    local lv = tonumber(name:sub(3, #name))
    local i  =(id - 1) * 20 + lv
    local l = g_levels[(id - 1) * 20 + lv]

    if l.unlocked and (not g_demo or id - 1 < 20) then
      return (l.finished and "f" or "u") .. (l.coin and "c" or "n")
    else
      return "l"
    end
  end
end

function set_setting(s, name)
  if g_got_coin then
    g_levels[g_index + 1].coin = true
  end
  local on = s.on
  if name == "Screenshake" then g_ess = on
  elseif name == "Vibration" then g_ev = on
  elseif name == "Touch Controls" then g_ek = on

          if g_ek then
            touch_fade()
          else touch_fadeout( ) end
  elseif name == "Timer" then g_et = on
  elseif name == "Difficulty" then g_dif = s.current
  elseif name == "Joystick" then
    joystick = g_joysticks[s.currenti - 1]
    printh(joystick)
  elseif name == "Key Bindings" then
    if on and flr(g_trans) == 0 then
      swap_state(keyconfig)
    end

  elseif name == "SFX" then g_es = on
  elseif name == "Music" then g_em = on

    if g_em then
      curr_music =nil
      play_music("menu")
    else
      music["menu"]:stop()
      music["menu"]:setVolume(0)
    end
  elseif name == "Reset Progress" then
    printh(love.filesystem.remove("curse_of_the_arrow.save"))
    unlocked = {}
    load()
    g_index = 102
    swap_state(menu)
  elseif tonumber(name:sub(1, 1)) ~= nil  then

      local id = tonumber(name:sub(1, 1))
      local lv = tonumber(name:sub(3, #name))
      local i = (id - 1) * 20 + lv - 1
      local l = g_levels[i + 1]
    if l.unlocked and (not g_demo or i < 20) then
      g_index = i
      restart_level()
    else
      play_sfx("locked")
    end
  end

  save()
end

function tfind(t, vl)
  for i, v in ipairs(t) do
    if v == vl then return i end
  end
  return -1
end

function get_setting(name)
  if name == "Difficulty" then
    return g_dif
  else
    return 1
  end
end

function sm:collide(o)
  if flr(g_trans) ~= 0  then return end
  if o.vel.y > 0.2 and self.t > 10 then
    self.t = 0
    self.on = not self.on


    if self.table then
      self.currenti = (self.currenti + 1) % (#self.prop + 1)
      if self.currenti == 0 then self.currenti = 1 end
      self.current = self.prop[self.currenti ]
    end
    set_setting(self, self.name)
    play_sfx("toggle")
    shake(20, 3)
  end
end

function sm:idle()
  if flr(g_trans) ~= 0  then return end
  if self.table and self.t == 30 and self.on and self.name ~= "Key Bindings"  then
    self.on = false
    play_sfx("toggle")
    shake(20, 3)
    self.t = 0
  end

  if jadded and self.name == "Joystick" then
    printh("check")
    jadded = false
    self.prop = check_setting("Joystick")
    self.current = (self.name == "Joystick" and self.prop[1] or get_setting(self.name))
    self.currenti = tfind(self.prop, self.current)
  end
end

function sm:init()
  self.id = g_sei
  g_sei = g_sei + 1
  local s = snames[g_index]
  if s then
    self.name = s[self.id + 1]
  end
  if not self.name then self.done = true
  else
    self.on = check_setting(self.name)
    if type(self.on) == "table" then
      self.prop = self.on
      self.on = false
      self.table = true
      self.current = (self.name == "Joystick" and self.prop[1] or get_setting(self.name))
      self.currenti = tfind(self.prop, self.current)
    end
    if type(self.on) == "string" then
      self.info = self.on
      self.on = false
      self.level = true
    end
  end
end

function sm:render()
  if not self.name then return end
  local s = 399

  if self.level and self.info:sub(1, 1) == "l" then s = 399 - 32 end
  ospr(s, self.pos.x, self.pos.y + (self.on and 2 or 0))

end

function sm:render_hud()
  if self.table then
    love.graphics.setColor(palette[5])
    oprint(self.current, self.pos.x + 4 - #self.current * 4 / 2, self.pos.y + 12)
  elseif self.level then
    local l = (self.info:sub(1, 1) == "l")
    local c = (self.info:sub(2, 2) == "c")
    local f = (self.info:sub(1, 1) == "f")

    if l then
      ospr(480, self.pos.x, self.pos.y + 12)
    elseif c then
      spr(31,self.pos.x, self.pos.y + 12)
    elseif f then
      ospr(545, self.pos.x, self.pos.y + 12)
    else
      -- other?
    end

    -- love.graphics.setColor(palette[11])
    -- oprint(self.info, self.pos.x + 4 - #self.info * 4 / 2, self.pos.y + 12)
  end
  love.graphics.setColor(palette[13])
  oprint(self.name, self.pos.x + 4 - #self.name * 4 / 2, self.pos.y - 4)
end

shop_item = entity:extend({
  draw_order = 3,
  bold = true,
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy"},
  tags = {"stand"}
})

shop_item:spawns_from(481, 615, 619, 620, 621)

local sinfo = {
  [481] = {
    name = "UFO Pet",
    short = "ufo",
    cost = 15
  },
  [615] = {
    name = "Coin Pet",
    short = "coin",
    cost = 10
  },
  [619] = {
    name = "Strawberry Pet",
    short = "strawberry",
    cost = 20
  },
  [620] = {
    name = "Meatboy Pet",
    short = "meatboy",
    cost = 30
  },
  [621] = {
    name = "Bat Pet",
    short = "bat",
    cost = 25
  }
}

function shop_item:init()
  self.start = self.pos.y - 4
  self.t = rnd(1024)
  self.collides = 0
  self.i = sinfo[self.tile]
  self.did = (g_shopped[self.i.short] ~= nil)
  self.stop = (g_ppet == self.i.short)
end

function shop_item:collide() self.collides = 3 end

function shop_item:idle()
  self.pos.y = self.start + cos(self.t / 200) * 4
end

function guy:isd()
  return self.state == "dead" or self.state == "dead2"
end

function shop_item:render_hud()
  if self.collides > 0 then
    self.collides = self.collides - 1
    love.graphics.setColor(palette[12])
    oprint(self.i.name, self.pos.x - #self.i.name * 4 / 2 + 4, self.pos.y - 8 - 3)
    if not self.did then local s = "$" .. self.i.cost
    love.graphics.setColor(palette[13])
    oprint(s, self.pos.x - #s * 2 + 4, self.pos.y - 5) end
    local b = (self.did and "Select [X]" or "Buy [X]")
    love.graphics.setColor(palette[6])
    oprint(b, self.pos.x - #b * 2 + 4, self.pos.y + 8)

    if btnp("x") then
      if g_money < self.i.cost and not self.did then
        play_sfx("locked")
        shake(20, 3)
      else
        if self.stop then
          g_ppet =""
          self.stop = false
          g_guy:spawn_pet()
          play_sfx("coin")

        else
          play_sfx("coin")
          g_ppet = self.i.short
          if not self.did then printh("buy") g_money = g_money - self.i.cost g_shopped[self.i.short] = true end
          self.did = true

          g_guy:spawn_pet()
          self.stop = true
          for e in all(entities_tagged["stand"]) do
            if e ~= self and e.stop then
              e.stop = false for i = 1, 10 do
                e_add(particle({
                  pos = v(e.pos.x+ 4, e.pos.y + 4),
                  size = 2,
                  color = rnd() > 0.7 and 5 or 6
                }))
              end
            end
          end
        end
        save()
      end
    end
  end
end

function shop_item:render()
  ospr(self.did and (self.stop and 724 or self.tile) or self.tile, self.pos.x, self.pos.y)
end