Mainmenu_Particles = {}

function Mainmenu_Particles:load()
  local img = love.graphics.newImage("assets/menu-snow.png")
   
  psystem = love.graphics.newParticleSystem(img, 500)
	psystem:setParticleLifetime(20)
	psystem:setEmissionRate(10)
	psystem:setSpeed(10, 30)
  psystem:setSpin(1, 5)
	psystem:setSizeVariation(1)
  psystem:setDirection(math.pi / 2)
	psystem:setLinearAcceleration(-200, 60, 200, 60)
end

function Mainmenu_Particles:update(dt)
  psystem:update(dt)
end

function Mainmenu_Particles:draw()
  love.graphics.draw(psystem, gw / 2, -200)
end

return Mainmenu_Particles
