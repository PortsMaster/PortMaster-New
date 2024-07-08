
----- engine

-- oop

function deep_copy(obj)
  if type(obj) ~= "table" then
    return obj
  end
  local cpy = {}
  setmetatable(cpy, getmetatable(obj))
  for k, v in pairs(obj) do
    cpy[k] = deep_copy(v)
  end
  return cpy
end

function index_add(idx, prop, elem)
  if not idx[prop] then
    idx[prop] = {}
  end
  add(idx[prop], elem)
end

function event(e, evt, p1, p2)
  local fn = e[evt]
  if fn then
    return fn(e, p1, p2)
  end
end

function state_dependent(e, prop)
  local p = e[prop]
  if not p then return nil end
  if type(p) == "table" and p[e.state] then
    p = p[e.state]
  end
  if type(p) == "table" and p[1] then
    p = p[1]
  end
  return p
end

function round(x)
  return flr(x + 0.5)
end

-------------------------------
-- objects
-------------------------------

object = {}
function object:extend(kob)
  kob = kob or {}
  kob.extends = self
  return setmetatable(kob, {
    __index = self,
    __call = function(self, ob)
      ob = setmetatable(ob or {}, {__index = kob})
      local ko, init_fn = kob
      while ko do
        if ko.init and ko.init ~= init_fn then
          init_fn = ko.init
          init_fn(ob)
        end
        ko = ko.extends
      end
      return ob
    end
  })
end

-------------------------------
-- vectors
-------------------------------

vector = {}
vector.__index = vector
function vector:__add(b)
  return v(self.x + b.x, self.y + b.y)
end
function vector:__sub(b)
  return v(self.x - b.x, self.y - b.y)
end
function vector:__mul(m)
  return v(self.x * m, self.y * m)
end
function vector:__div(d)
  return v(self.x / d, self.y / d)
end
function vector:__unm()
  return v(-self.x, - self.y)
end
function vector:dot(v2)
  return self.x * v2.x + self.y * v2.y
end
function vector:norm()
  return self / sqrt(#self)
end
function vector:len()
  return sqrt(#self)
end
function vector:__len()
  return self.x^2 + self.y^2
end
function vector:str()
  return self.x..","..self.y
end

function v(x, y)
  return setmetatable({
    x = x, y = y
  }, vector)
end

-------------------------------
-- collision boxes
-------------------------------

cbox = object:extend()

function cbox:translate(v)
  return cbox({
    xl = self.xl + v.x,
    yt = self.yt + v.y,
    xr = self.xr + v.x,
    yb = self.yb + v.y
  })
end

function cbox:overlaps(b)
  return (self.xr > b.xl and
  b.xr > self.xl and
  self.yb > b.yt and
  b.yb > self.yt)
end

function cbox:sepv(b, allowed, d, a)
  local candidates = {
    v(b.xl - self.xr, 0) / d,
    v(b.xr - self.xl, 0) / d,
    v(0, b.yt - self.yb) / d,
    v(0, b.yb - self.yt) / d
  }
  if type(allowed) ~= "table" then
    allowed = {true, true, true, true}
  end
  local ml, mv = 100
  for d, v in pairs(candidates) do
    local len = math.sqrt(v.x * v.x + v.y * v.y)
    -- if d == 3 or d == 4 then len = len + 1 end
    if allowed[d] and len < ml then
      ml, mv = len, v
    end
  end
  return mv
end

function cbox:str()
  return self.xl..","..self.yt..":"..self.xr..","..self.yb
end

function box(xl, yt, xr, yb)
  return cbox({
    xl = min(xl, xr), xr = max(xl, xr),
    yt = min(yt, yb), yb = max(yt, yb)
  })
end

function vbox(v1, v2)
  return box(v1.x, v1.y, v2.x, v2.y)
end

-------------------------------
-- entities
-------------------------------

entity = object:extend({
  state = "idle", t = 0,
  dynamic = true,
  spawns = {}
})

function entity:init()
  if self.sprite then
    self.sprite = deep_copy(self.sprite)
    if not self.render then
      self.render = spr_render
    end
  end
end

function entity:become(state)
  if state ~= self.state then
    self.state, self.t = state, 0
  end
end

function entity:is_a(tag)
  if not self.tags then
    return false
  end
  for i = 1, #self.tags do
    if self.tags[i] == tag then
      return true
    end
  end
  return false
end

function entity:spawns_from(...)
  for tile in all({...}) do
    entity.spawns[tile] = self
  end
end

static = entity:extend({
  dynamic = false
})

function spr_render(e)
  local s, p = e.sprite, e.pos

  function s_get(prop, dflt)
    local st = s[e.state]
    if st ~= nil and st[prop] ~= nil then return st[prop] end
    if s[prop] ~= nil then return s[prop] end
    return dflt
  end

  local sp = p + s_get("offset", v(0, 0))

  local w, h =
  s.width or 1, s.height or 1

  local flip_x = false
  local frames = s[e.state] or s.idle
  if s.turns then
    frames = frames.r

    flip_x =(e.facing == "left")
    end
  if s_get("flips") then
    flip_x = e.flipped
  end

  local delay = frames.delay or 1
  if type(frames) ~= "table" then frames = {frames} end
  local frm_index = flr(e.t / delay) % #frames + 1
  local frm = frames[frm_index]
  local f = e.bold and ospr or spr
  f(frm, round(sp.x), round(sp.y), w, h, flip_x, false)

  return frm_index
end

-------------------------------
-- entity registry
-------------------------------

function entity_reset()
  entities, entities_with,
  entities_tagged = {}, {}, {}
end

function e_add(e)
  add(entities, e)
  for p in all(indexed_properties) do
    if e[p] then index_add(entities_with, p, e) end
  end
  if e.tags then
    for t in all(e.tags) do
      index_add(entities_tagged, t, e)
    end
    c_update_bucket(e)
  end
  return e
end

function e_remove(e)
  del(entities, e)
  for p in all(indexed_properties) do
    if e[p] then del(entities_with[p], e) end
  end
  if e.tags then
    for t in all(e.tags) do
      del(entities_with[t], e)
      if e.bkt then
        del(c_bucket(t, e.bkt.x, e.bkt.y), e)
      end
    end
  end
  e.bkt = nil
end

indexed_properties = {
  "dynamic",
  "render",
  "render_hud",
  "vel",
  "collides_with",
  "feetbox"
}

-- systems

-------------------------------
-- update system
-------------------------------

function e_update_all()
  if not entities_with.dynamic then return end
  for ent in all(entities_with.dynamic) do
    local state = ent.state
    if ent[state] then
      ent[state](ent, ent.t)
    end
    if ent.done then
      e_remove(ent)
    elseif state ~= ent.state then
      ent.t = 0
    else
      ent.t = ent.t + 1
    end
  end
end

function schedule(fn)
  scheduled = fn
end

-------------------------------
-- render system
-------------------------------

function r_render_all(prop)
  if not entities_with[prop] then return end
  local drawables = {}
  for ent in all(entities_with[prop]) do
    local order = ent.draw_order or 0
    if not drawables[order] then
      drawables[order] = {}
    end
    add(drawables[order], ent)
  end
  for o = 0, 15 do
    if drawables[o] then
      for ent in all(drawables[o]) do
        r_reset(prop)
        ent[prop](ent, ent.pos)
      end
    end
  end
end

function r_reset()

end

-------------------------------
-- movement system
-------------------------------

function do_movement()
  if not entities_with.vel then return end
  for ent in all(entities_with.vel) do
    local ev = ent.vel
    ent.pos = ent.pos + ev
    if ev.x ~= 0 then
      ent.flipped = ev.x < 0
    end
    if ev.x ~= 0 then
      ent.facing = ev.x > 0 and "right" or "left"
    end
    if ent.weight then
      local w = state_dependent(ent, "weight")
      ent.vel = ent.vel + v(0, w)
    end
  end
end

-------------------------------
-- collision
-------------------------------

function c_bkt_coords(e)
  local p = e.pos
  return flr(p.x/16), flr(p.y/16)
end

function c_bucket(t, x, y)
  local key = t..":"..x..","..y
  if not c_buckets[key] then
    c_buckets[key] = {}
  end
  return c_buckets[key]
end

function c_update_buckets()
  for e in all(entities_with.dynamic) do
    c_update_bucket(e)
  end
end

function c_update_bucket(e)
  if not e.pos or not e.tags then return end
  local bx, by = c_bkt_coords(e)
  if not e.bkt or e.bkt.x ~= bx or e.bkt.y ~= by then
    if e.bkt then
      for t in all(e.tags) do
        local old = c_bucket(t, e.bkt.x, e.bkt.y)
        del(old, e)
      end
    end
    e.bkt = v(bx, by)
    for t in all(e.tags) do
      add(c_bucket(t, bx, by), e)
    end
  end
end

function c_potentials(e, tag)
  local cx, cy = c_bkt_coords(e)
  local bx, by = cx - 2, cy - 1
  local bkt, nbkt, bi = {}, 0, 1
  return function()
    while bi > nbkt do
      bx = bx + 1
      if bx > cx + 1 then bx, by = cx - 1, by + 1 end
      if by > cy + 1 then return nil end
      bkt = c_bucket(tag, bx, by)
      nbkt, bi = #bkt, 1
    end
    local e = bkt[bi]
    bi = bi + 1
    return e
  end
end

function collision_reset()
  c_buckets = {}
end

function do_collisions()
  if not entities_with.collides_with then return end
  c_update_buckets()
  for e in all(entities_with.collides_with) do
    for tag in all(e.collides_with) do
      if entities_tagged[tag] then
        local nothers =
        #entities_tagged[tag]
        if nothers > 4 then
          for o in c_potentials(e, tag) do
            if o ~= e then
              local ec, oc =
              c_collider(e), c_collider(o)
              if ec and oc then
                c_one_collision(ec, oc)
              end
            end
          end
        else
          for oi = 1, nothers do
            local o = entities_tagged[tag][oi]
            local dx, dy =
            abs(e.pos.x - o.pos.x),
            abs(e.pos.y - o.pos.y)
            if dx <= 20 and dy <= 20 then
              local ec, oc =
              c_collider(e), c_collider(o)
              if ec and oc then
                c_one_collision(ec, oc)
              end
            end
          end
        end
      end
    end
  end
end

function c_check(box, tags, e)
  local fake_e = {pos = v(box.xl, box.yt)}
  for tag in all(tags) do
    for o in c_potentials(fake_e, tag) do
      local oc = c_collider(o)
      if oc.e ~= e and oc and oc.e.state ~= "hidden" and box:overlaps(oc.b) then
        return oc.e
      end
    end
  end
  return nil
end

function c_one_collision(ec, oc)
  if ec.b:overlaps(oc.b) then
    c_reaction(ec, oc)
    c_reaction(oc, ec)
  end
end

function c_reaction(ec, oc)
  local reaction, param =
  event(ec.e, "collide", oc.e)
  if type(reaction) == "function" then
    reaction(ec, oc, param)
  end
end

function c_collider(ent)
  if ent.collider then
    if ent.coll_ts == g_time or not ent.dynamic then
      return ent.collider
    end
  end
  local hb = state_dependent(ent, "hitbox")
  if not hb then return nil end
  local coll = {
    b = hb:translate(ent.pos),
    e = ent
  }
  ent.collider, ent.coll_ts =
  coll, g_time
  return coll
end

function c_push_out(oc, ec, allowed_dirs)
  local sepv = ec.b:sepv(oc.b, allowed_dirs, oc.e.force or (ec.e.force or 1), oc.e.tags ~= nil and oc.e.tags["snk"])
  ec.e.pos = ec.e.pos + sepv
  if ec.e.vel then
    local vdot = ec.e.vel:dot(sepv)
    if vdot < 0 then
      if sepv.y ~= 0 then ec.e.vel.y = 0 end
      if sepv.x ~= 0 then ec.e.vel.x = 0 end
    end
  end
  ec.b = ec.b:translate(sepv)
end

function c_push_out_vel(oc, ec, allowed_dirs)
  local sepv = ec.b:sepv(oc.b, allowed_dirs, oc.e.force or (ec.e.force or 1))
  if ec.e.vel then
    ec.e.vel = sepv
  end
  ec.b = ec.b:translate(sepv)
end

function c_move_out(oc, ec, allowed)
  return c_push_out(ec, oc, allowed)
end

function c_move_out_vel(oc, ec, allowed)
  return c_push_out_vel(ec, oc, allowed)
end

-------------------------------
-- support
-------------------------------

function do_supports()
  if not entities_with.feetbox then return end
  for e in all(entities_with.feetbox) do
    local fb = e.feetbox
    if fb then
      fb = fb:translate(e.pos)
      local support = c_check(fb, {"walls"}, e)
      if not support or not (support:is_a("arrow") and support.state ~= "stuck") then
        e.supported_by = support
      end
      if support and support.vel and not support:is_a("arrow") then
        e.pos = e.pos + support.vel
      end
    end
  end
end
