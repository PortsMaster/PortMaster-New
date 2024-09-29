level = entity:extend({
  draw_order = 2
})

function level:init()
  g_level = self

  local data = require("assets.map")
  local layer = data.layers[1]
  local tiles = layer.data

  self.tiles = {}
  self.data = love.image.newImageData("assets/types.png")
  for y = 0, self.size.y - 1 do
    self.tiles[y] = {}
  end

  local b = self.base

  for y = 0, self.size.y - 1 do
    for x = 0, self.size.x - 1 do
      local xx = b.x + x
      local yy = b.y + y
      local blk = tiles[xx + yy * layer.width + 1]
      if blk then
        blk = blk - 1
      else
        blk = -1
      end

      local cl = entity.spawns[blk]
      if cl then
        local e = cl({
          pos = v(x, y) * 8,
          tile = blk
        })
        e_add(e)
        blk = g_dt
      end
      local bt = block_type(blk)
      if bt then
        bl = bt({
          pos = v(x, y) * 8,
          map_pos = v(x, y),
          typ = bt,
          tile = blk
        })
        if bl.needed then e_add(bl)  end
      end
      if not self.tiles[y][x] then
        self.tiles[y][x] = blk
      end
    end
  end

  if entities_tagged["solid"] then
    for e in all(entities_tagged["solid"]) do
      e:preinit()
    end
    for e in all(entities_tagged["solid"]) do
      mset(e.map_pos, e.map_pos, -1)
    end
  end
  if entities_tagged["gate"] then
    for e in all(entities_tagged["gate"]) do
      if e.tinit then e:tinit() end
    end
  end
end

function mget(x, y)
  if g_level.tiles[y] then
    return g_level.tiles[y][x] or -1
  end

  return 0
end

function mset(x, y, v)
  if g_level.tiles[y] then
    g_level.tiles[y][x] = v
  end
end

function level:render()
  for x = 0, self.size.x - 1 do
    for y = 0, self.size.y - 1 do
      local t = self.tiles[y][x]
      if t >= 0 then
        spr(t, x * 8, y * 8)
      end
    end
  end
end

solid = static:extend({
  tags = {"walls","corrupt","solid"},
  hitbox = box(0, 0, 8, 8)
})

support = solid:extend({
  tags = {"walls", "bridge"},
  draw_order = 7,
  supporing = true,

  hitbox = box(0, 0, 8, 1)
})

breaks = solid:extend({
  tags = {"walls","corrupt"},
  draw_order = 10,

  breaks = true,
  hitbox = box(0, 0, 8, 8)
})

ice = solid:extend({
  tags = {"walls","ice","corrupt","solid"},
  breaks = true,
  draw_order = 10,

  hitbox = box(0, 0, 8, 8),
  ice = true
})

souldsand = solid:extend({
  tags = {"walls","souldsand","solid"},
  draw_order = 10,
  hitbox = box(0, 0, 8, 8),
  souldsand = true
})


function solid:preinit()
  self.top = block_type(mget(self.map_pos.x, self.map_pos.y - 1)) ~= solid
  self.bottom = block_type(mget(self.map_pos.x, self.map_pos.y + 1)) ~= solid
end

function solid:init()
  self.draw_order = 10

  if self.supporing then self.draw_order = 7 end

  if self.tile == 306 or self.tile == 306 + 32 or self.tile == 306 + 64 then
    self.draw_order = 2
  end

  local dirs = {v(-1, 0), v(1, 0), v(0, -1), v(0, 1)}
  local allowed = {}
  local needed = false
  for i = 1, 4 do
    local np = self.map_pos + dirs[i]
    allowed[i] = (block_type(mget(np.x, np.y)) ~= solid)
    needed = needed or allowed[i]
  end
  self.t = flr(rnd(1000))
  self.allowed = allowed
  self.needed = needed

  if self.needed then
    self.render = function()
      if g_guy and not pause then local dx =g_guy.pos.x - self.pos.x
        local dy =g_guy.pos.y - self.pos.y
        local max = 1

        if g_dif == "Normal" then max = 3
        elseif g_dif == "Hard" then max = 5
        elseif g_dif == "Ultra hard" then max = 7 end
        if g_enemies < max and not self.did and self.corrupted
          and math.sqrt(dx * dx + dy * dy) > 64
         and
        (g_time + self.t - 100 ) %1000 == 0 then
            local id = flr(g_index / 20)
            if id == 0 then
              if self.bottom then
                printh("bat")
                e_add(bat({
                  pos = v(self.pos.x, self.pos.y + 8)
                }))
                self.did = true

              elseif self.top then
                printh("zomb")
                e_add(zombie({
                  pos = v(self.pos.x, self.pos.y - 8)
                }))

                self.did = true
              end
            elseif id == 1 then
              if self.top then
                printh("slime")
                e_add(slime({
                  pos = v(self.pos.x, self.pos.y - 8)
                }))

                self.did = true
              elseif self.bottom then
                printh("spider")
                e_add(spider({
                  pos = v(self.pos.x, self.pos.y + 8)
                }))

                self.did = true
              end
            elseif id == 2 then
              if self.top then
                printh("bomber")
                e_add(bomber({
                  pos = v(self.pos.x, self.pos.y - 8)
                }))

                self.did = true
              elseif self.bottom then
                printh("bat")
                e_add(bat({
                  pos = v(self.pos.x, self.pos.y + 8)
                }))
                self.did = true
              end
            end
        end
      end

      if self.corrupted and not pause  and (g_time + self.t ) % 500 == 0 then

        for e in all(entities_tagged["corrupt"]) do
          if e ~= self and (not e.tile or corrupt_map[e.tile])  and not e.corrupted and rnd() > 0.7 then
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
        spr(self.tile, self.pos.x, self.pos.y)
    end
  end
end

corrupt_map = {
  [0] = 771,
  [1] = 772,
  [2] = 773,

  [97] = 803,

  [129] = 835,
  [130] = 836,

  [260] = 774,
  [261] = 775,

  [356] = 806,
  [357] = 807,

  [384] = 819,
  [385] = 820,
  [383 + 32] = 819 + 32,
  [385 + 32] = 820 + 32,

  [384 + 2] = 819+ 2,
  [385 + 2] = 820+ 2,
  [384 + 32 + 2] = 819 + 32+ 2,
  [385 + 32 + 2] = 820 + 32+ 2,
  [384 + 64 + 2] = 819 + 64+ 2,
  [385 + 64 + 2] = 820 + 64+ 2,

  [296] = 839,
  [298] = 841,

  [265] = 808,
  [266] = 809,
  [267] = 810,
  [265 + 32] = 808 + 32,
  [266 + 32] = 809 + 32,
  [265 + 64] = 808 + 64,
  [266 + 64] = 809 + 64,
  [267 + 64] = 810 + 64,

  [140] = 811,
  [141] = 812,
  [142] = 813,
  [140 + 32] = 811 + 32,
  [141 + 32] = 812 + 32,
  [142 + 32] = 813 + 32,
  [140 + 64] = 811 + 64,
  [141 + 64] = 812 + 64,
  [142 + 64] = 813 + 64,

  [109] = 814,
  [110] = 815,

  [236] = 878,
  [237] = 879,

  [333] = 846,

  [258] = 847,

  [176] = 848,
  [177] = 849,

  [114] = 786,
  [115] = 787,
  [116] = 788,
  [117] = 789,

  [245] = 818,

  [32] = 864,
  [34] = 866,

  [64] = 864 + 32,
  [65] = 865 + 32,
  [66] = 866 + 32,

  [262] = 867,
  [263] = 868,
  [262+32] = 867+32,
  [263+32] = 868+32,

  -- todo
  [358] = 869,
  [359] = 870,
  [358 + 32] = 869 + 32,
  [359 + 32] = 870 + 32,

  [324] = 931,
  [325] = 932,

  [420] = 933,
  [421] = 934,

  [146] = 881,
  [146 + 32] = 881 + 32,
  [149] = 884,
  [149 + 32] = 884 + 32,

  [146 + 64] = 881 + 64,
  [147 + 64] = 882 + 64,
  [148 + 64] = 883 + 64,
  [149 + 64] = 884 + 64,

  [208] = 903,
  [209] = 904,

  [35] = 905,
  [35 + 32] = 905 + 32,
  [160] = 903 + 32,
  [161] = 904 + 32,
}

function solid:corrupt()
  if g_index == 100 then return end
  if corrupt_map[self.tile] then
    self.tile = corrupt_map[self.tile]
  end
  self.corrupted = true
end

function solid:collide(e)
  if e:is_a("arrow") and e.cursed then self:corrupt() end
  return c_push_out, self.allowed
end

function support:collide(e)
  if not e.vel then return end
  local dy, vy = e.pos.y - self.pos.y + 4, e.vel.y
  if vy > 0 and dy <= vy + 1 then
    return c_push_out, {false, false, true, false}
  end
end

function ice:collide(e)
  -- e.on_ice = true
    if e:is_a("arrow") and e.cursed then self:corrupt() end
  return c_push_out, self.allowed
end

types = {
  ["FF004D"] = solid,
  ["FFE727"] = support,
  ["00E232"] = breaks,
  ["20337B"] = ice,
  ["008331"] = souldsand
}

function rgbToHex(rgb)
	local hexadecimal = ''

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

function block_type(blk)
  if blk == -1 or blk>1023 then return nil end

  local r, g, b = g_level.data:getPixel(blk % 32 * 8, flr(blk / 32) * 8)
  local id = rgbToHex({ r * 255, g * 255, b * 255 })

  return types[id]
end
