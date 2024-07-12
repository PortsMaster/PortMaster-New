cut = {}

function cut:start()
  g_index = 100 -- 100
  ingame.start()
  t_calpa = 255
  g_barrow = false
end

function cut:update()
  local o = btn
  local op = btnp

  --btn = function() return false end
  --btnp = function() return false end
  ingame.update()
  btn = o
  btnp = op
end

function cut:draw()
  ingame.draw()
  if g_index == 101 then
    oprint(kmap["x"] .. " to shoot", 2, 2, 6)
  end
end

dad = guy:extend({
  sprite = {
    idle = {455, 455 - 32, delay = 30},
    walk = {456, 457, 458, 459, delay = 5},
    fly = {456},
    dead = { 460, 461, 462, delay = 15},
    dend = {544 + 96 + 128 + 2, 544 + 96 + 128 + 1, 544 + 96 + 128, delay = 5},
    flips = true
  }
})

dad:spawns_from(455)

function dad:init()
  self.as = "walk"
  self.at = 0
end

function dad:walk()
  local a = 0.3
  self.vel.x = mid(-a, a, self.vel.x)

  self:ai()

  if abs(self.vel.x) < 0.1 then
    self.vel.x = 0
    self:become("idle")
  end


  if not self.supported_by then
    self:become("fly")
    self:common()

    return
  end
  self:common()

  if ( self.state == "pushing" or self.state == "walk") and self.t%15 == 5 then
    play_sfx(rnd()>0.5 and "step2" or "step")
  end
end

function dad:ai()
  if self.as == "walk" then
    self.vel.x = 1
    if self.state~="fly" then self:become("walk") end

  elseif self.as == "take" then
    self.vel.x = 0
    if self.state~="fly" then self:become("idle") end
    self.at = self.at + 1
    if self.at == 120 then
      play_sfx("pick")
      self.item = g_art
      shake(60, 3)
      g_bolder:become("shaking")
      g_art:become("held")
    end
  end
end

function dad:fly()
  self:ai()

  if self.supported_by then
    self:become("walk")

    e_add(lfx({
      pos = v(self.pos.x - 4, self.pos.y)
    }))
    self:common()
    return
  end
  self:common()
end

function dad:kill()
  if self.state ~= "dead" and self.state ~="dead2" then
    play_sfx("death")
    vibrate(0.3)
    shake(30, 3)
    self.item = nil
    e_remove(g_art)
    self:become("dead")
    g_time = 0
    for i = 1, 10 do
      e_add(blood({
        pos = v(self.pos.x + 4, self.pos.y + 4),
        color = rnd() > 0.8 and 2 or 8,
        size = 2
      }))
    end
  end
end

function dad:render_hud()

end

function dad:dead(t)
  self.vel = v(0, 0)
  if t >= 3 * 15 - 2 then
    self.t = 3 * 15 - 2
  end

  if g_time >= 120 then
    g_index = 101
      restart_level()
      g_trans = 1
  end
end

artifact = entity:extend({
  sprite = {
    idle = {196},
    up = {196},
    toup = {167 - 32, 167, 196, delay = 4},
    width = 2
  },
  draw_order = 10,
  hitbox = box(0, 0, 16, 8),
  collides_with = {"guy"}
})

artifact:spawns_from(196)

function artifact:collide(o)
  if g_index == 101 then
    self.collides = 3
    g_guy.collidei = self
  end
end

function artifact:init()
  g_art = self
  self.collides = 0
  self.start = self.pos.y
end

function artifact:render_hud()
  if self.collides > 0 then
    self.collides = self.collides - 1
    ospr(171, g_guy.pos.x + 2, g_guy.pos.y - 10)
    if btnp("x") and self.t > 10 then
      play_sfx("pick")
      self:become("toup")
      shake(100, 3)
    end
  end
end
function artifact:up()
  if flr(g_trans) == 0 then
   t_calpa = 255 e_remove(g_ped) g_index = 0
   g_index = 0
   state = ingame
   g_trans_in = true
   g_trans = 15
   ingame.start()
 end
end

function artifact:toup()
  if self.pos.y > self.start - 10 then
    self.pos.y = self.pos.y - 1
  else
    self:become("up")
  end
end

function artifact:idle(t)
  self.pos.y = self.start + cos(t / 200) * 3
end

function artifact:held()
  self.pos.x = self.pos.x - 4
end

jump = entity:extend({
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy"}
})

jump:spawns_from(397)

function jump:collide(o)
  if o.supported_by and o.state=="walk" and o.t > 1 then
    o:become("fly")
    play_sfx("jump")
    o.vel.y = -2
    e_add(jfx({
     pos = v(o.pos.x - 4, o.pos.y)
    }))
  end
end

stop = entity:extend({
  hitbox = box(0, 0, 8, 8),
  collides_with = {"guy"}
})

stop:spawns_from(398)

function stop:collide(o)
  if o.as=="walk" then o.as = "take"
  printh("stop")
  o.t = 0 end
end


bolder = entity:extend({
  sprite = {
    idle = {431},
    height = 2,
    width = 2
  },
  hitbox = box(0, 0, 16, 16),
  collides_with = {"guy", "walls", "bridge"},
  weight = {0, fall=0.2},
  draw_order = 10
})

bolder:spawns_from(431)

function bolder:init()
  g_bolder = self
  self.vel = v(0, 0)
end

function bolder:collide(o)
  if o:is_a("guy") then
    o:kill()
  end
end

function bolder:shaking(t)
  if self.t >= 60 then self:become("fall") end
end

son = guy:extend({
  sprite = {
    idle = {224, 224 + 64, delay = 30},
    walk = {227, 228, 229, delay = 5},
    fly = {225},
    down = {579},
    flips = true,
  }
})

guy:spawns_from(224)

function son:init()
  self.as = "walk"
  self.at = 0
end

function son:ai()
  if self.as == "walk" then
    if self.state ~="fly" then self:become("walk") end
    self.vel.x = -0.8
  elseif self.as == "take" then
    self.vel.x = 0
    self.at = self.at + 1
    if self.state ~="fly" and self.state ~="down" then self:become("idle") end

    if self.at == 60 then
      self:become("down")
      self.as = "down"
      self.at = 0
    end
  end

end

function son:down()
  self.at = self.at + 1
  if self.at == 60 then
    g_index = 1
    swap_state(menu)
  end
end


function son:idle() self:walk() end

function son:walk()
  local a = 0.3
  self.vel.x = mid(-a, a, self.vel.x)

  self:ai()


  if not self.supported_by then
    self:become("fly")
    self:common()

    return
  end
  self:common()

  if ( self.state == "pushing" or self.state == "walk") and self.t%15 == 5 then
    play_sfx(rnd()>0.5 and "step2" or "step")
  end
end

function son:fly()
  self:ai()

  if self.supported_by then
    self:become("walk")

    e_add(lfx({
      pos = v(self.pos.x - 4, self.pos.y)
    }))
    self:common()
    return
  end
  self:common()
end
