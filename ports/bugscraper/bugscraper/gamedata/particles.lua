require "util"
local Class = require "class"
local images = require "data.images"
local utf8 = require "utf8"

local Particle = Class:inherit()

function Particle:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.x, self.y = x, y
	self.vx, self.vy = vx or 0, vy or 0

	self.s = s -- size or radius
	self.vs = vs or 20
	
	self.r = r
	self.vr = vr or 0

	self.gravity = g or 0
	self.is_solid = is_solid or false
	self.bounces = 2
	self.bounce_force = 100

	self.max_life = life or 5
	self.life = self.max_life

	self.is_removed = false
end

function Particle:update_particle(dt)
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
	self.s = self.s - self.vs*dt

	self.vy = self.vy + self.gravity
	self.life = self.life - dt

	if self.is_solid then
		local items, len = collision.world:queryPoint(self.x, self.y, function(item) return item.is_solid end)
		if len > 0 then
			self.bounces = self.bounces - 1
			self.vy = -self.bounce_force - random_neighbor(40)
		end
	end

	if self.s <= 0 or self.life <= 0 then
		self.is_removed = true
	end
end
function Particle:update(dt)
	self:update_particle(dt)
end
function Particle:draw()
end

-----------

local CircleParticle = Particle:inherit()

function CircleParticle:init(x,y,s,col, vx,vy,vs, life, g)
	self:init_particle(x,y,s,0, vx,vy,vs,0, life, g)

	self.col = col or COL_WHITE
	self.type = "circle"
end
function CircleParticle:update(dt)
	self:update_particle(dt)
end
function CircleParticle:draw()
	circle_color(self.col, "fill", self.x, self.y, self.s)
end
------------------------------------------------------------

local ImageParticle = Particle:inherit()

function ImageParticle:init(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.is_solid = is_solid
end
function ImageParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local TextParticle = Particle:inherit()

function TextParticle:init(x,y,str,spawn_delay,col)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.str = str

	self.col_in = col
	self.vy = -5
	self.vy2 = 0
	self.spawn_delay = spawn_delay
	
	self.is_front = true
end
function TextParticle:update(dt)
	if self.spawn_delay > 0 then
		self.spawn_delay = self.spawn_delay - dt
		return
	end
	self.vy = self.vy * 0.9
	self.y = self.y + self.vy
	
	if abs(self.vy) <= 0.005 then
		self.vy2 = self.vy2 - dt*2
		self.y = self.y + self.vy2
	end
	if abs(self.vy) <= 0.001 then
		self.is_removed = true
	end
end
function TextParticle:draw()
	if self.spawn_delay > 0 then
		return
	end

	local col = COL_WHITE
	if self.col_in then col = self.col_in end
	print_outline(col, COL_BLACK_BLUE, self.str, self.x, self.y)
end


------------------------------------------------------------

local StompedEnemyParticle = Particle:inherit()

function StompedEnemyParticle:init(x,y,spr)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     2, 0, false)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2

	self.sx = 1
	self.sy = 1
	self.squash = 1
	self.squash_target = 2
end
function StompedEnemyParticle:update(dt)
	self:update_particle(dt)
	self.squash = lerp(self.squash, self.squash_target, 0.2)

	self.sx = self.squash
	self.sy = (1/self.squash) * 0.5

	if abs(self.squash_target - self.squash) <= 0.01 then
		self.is_removed = true
		particles:smoke(self.x, self.y)
	end
end
function StompedEnemyParticle:draw()
	local oy = self.spr_h*.5 - self.spr_h*.5*self.sy
	love.graphics.draw(self.spr, self.x, self.y + oy, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local DeadPlayerParticle = Particle:inherit()

function DeadPlayerParticle:init(x,y,spr,dir_x)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     10, 0, false)
	self.spr = spr
	
	self.dir_x = dir_x
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2

	self.oy = 0

	self.sx = 1
	self.sy = 1

	self.r = 0

	self.cols = {color(0xf6757a), color(0xb55088), color(0xe43b44), color(0x3a4466), color(0x262b44)}

	particles:splash(self.x, self.y - self.oy, 40, self.cols)
end
function DeadPlayerParticle:update(dt)
	self:update_particle(dt)

	local goal_r = 5*sign(self.dir_x)*pi2
	self.r = lerp(self.r, goal_r, 0.06)
	self.oy = lerp(self.oy, 40, 0.05)

	if abs(self.r - goal_r) < 0.1 then
		game:screenshake(10)
		audio:play("explosion")
		particles:splash(self.x, self.y - self.oy, 40, {COL_LIGHT_YELLOW, COL_ORANGE, COL_LIGHT_RED, COL_WHITE})
		self.is_removed = true
	end
end
function DeadPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y - self.oy, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local ParticleSystem = Class:inherit()

function ParticleSystem:init(x,y)
	self.particles = {}
end

function ParticleSystem:update(dt)
	for i,p in pairs(self.particles) do
		p:update(dt)
		if p.is_removed then
			table.remove(self.particles, i)
		end
	end
end

function ParticleSystem:draw()
	for i,p in pairs(self.particles) do
		if not p.is_front then
			p:draw()
		end
	end
end
function ParticleSystem:draw_front()
	for i,p in pairs(self.particles) do
		if p.is_front then
			p:draw()
		end
	end
end

function ParticleSystem:add_particle(ptc)
	table.insert(self.particles, ptc)
end

function ParticleSystem:clear()
	self.particles = {}
end

function ParticleSystem:smoke_big(x, y)
	self:smoke(x, y, 15, COL_WHITE, 16, 8, 4)
end

function ParticleSystem:smoke(x, y, number, col, spw_rad, size, sizevar)
	number = number or 10
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local col = col or {v,v,v,1}
		self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life))
	end
end

function ParticleSystem:dust(x, y, col, size, rnd_pos, sizevar)
	rnd_pos = rnd_pos or 3
	size = size or 4
	sizevar = sizevar or 2

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local v = random_range(0.6, 1)
	local col = col or {v,v,v,1}
	self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life))
end


function ParticleSystem:fire(x, y, size, sizevar, velvar, vely)
	rnd_pos = rnd_pos or 3
	size = size or 4
	sizevar = sizevar or 2

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local col_fire = {1, random_range(0, 1),0.2,1}
	local v = random_range(0.6, 1)
	local col_smoke = {v,v,v,1}
	local col = random_sample{col_fire, col_smoke}

	velvar = velvar or 5
	vely = vely or -2
	local vy = random_range(vely - velvar, vely)
	self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, vy, _vr, _life))
end


function ParticleSystem:splash(x, y, number, col, spw_rad, size, sizevar)
	number = number or 10
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local c = col or {v,v,v,1}
		if type(col) == "table" then
			c = random_sample(col)
		end

		local vx = random_neighbor(50)
		local vy = random_range(-200, 0)
		local vy = random_neighbor(50)
		local vs = random_range(6,12)

		self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, c, vx, vy, vs, _life, 0))
	end
end


function ParticleSystem:glow_dust(x, y, size, sizevar)
	size = size or 4
	sizevar = sizevar or 2

	local ang = love.math.random() * pi2
	local spd = random_neighbor(50)
	local vx = cos(ang) * spd
	local vy = sin(ang) * spd
	local vs = random_range(6,12)
	local dsize = random_neighbor(sizevar)

	self:add_particle(CircleParticle:new(x, y, size+dsize, COL_WHITE, vx, vy, vs, _life, 0))
end


function ParticleSystem:flash(x, y)
	-- x,y,r,col, vx,vy,vr, life
	local r = 8 + random_neighbor(2)
	-- self:add_particle(x, y, r, COL_LIGHT_YELLOW, 0, 0, 220, _life)
	self:add_particle(CircleParticle:new(x, y, r, COL_WHITE, 0, 0, 220, _life))
end

function ParticleSystem:image(x, y, number, spr, spw_rad, life, vs, g, parms)
	number = number or 10
	spw_rad = spw_rad or 8
	life = life or 1
	-- size = size or 4
	-- sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		-- local dsize = random_neighbor(sizevar)

		local rot = random_neighbor(pi)
		local vx = random_neighbor(100)
		local vy = -random_range(40, 80)
		local vs = vs or random_range(1, 0.5)
		local vr = random_neighbor(1)
		local life = life + random_neighbor(0.5)
		local g = (g or 1) * 3

		if parms and parms.vx1 and parms.vx2 then   vx = random_range(parms.vx1, parms.vx2)   end
		if parms and parms.vy1 and parms.vy2 then   vy = random_range(parms.vy1, parms.vy2)   end

		local sprite = spr
		if type(spr) == "table" then
			sprite = random_sample(spr)
		end
		self:add_particle(ImageParticle:new(sprite , x+dx, y+dy, 1, rot, vx,vy,vs,vr, life, g, true))
	end
end

function ParticleSystem:stomped_enemy(x, y, spr)
	self:add_particle(StompedEnemyParticle:new(x, y, spr))
end

function ParticleSystem:dead_player(x, y, spr, dir_x)
	self:add_particle(DeadPlayerParticle:new(x, y, spr, dir_x))
end

function ParticleSystem:letter(x, y, str, spawn_delay, col)
	self:add_particle(TextParticle:new(x, y, str, spawn_delay, col))
end

function ParticleSystem:word(x, y, str, col)
	local x = x - get_text_width(str)/2
	for i=1, #str do
		local letter = utf8.sub(str, i,i)
		particles:letter(x, y, letter, i*0.05, col)
		x = x + get_text_width(letter)
	end
end

ParticleSystem.text = ParticleSystem.word



return ParticleSystem