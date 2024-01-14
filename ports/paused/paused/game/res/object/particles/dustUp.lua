-- extending the object class
local object = object:extend()

object.layer = 3



-- create is called once the object is just created in the room
function object:create(x, y)
    self.direction = math.rad(math.random(180, 360))
    self.sin = math.sin(self.direction)
    self.cos = math.cos(self.direction)
    self.speed = math.randomFloat(3, 7)
    self.time = math.randomFloat(0.4, 0.6)
    self.timeLeft = math.randomFloat(0.35, self.time)
    self.position = vector(x + math.randomFloat(-2.5, 2.5) , y + math.randomFloat(-1.5, 0.5))
    self.size = math.randomFloat(0.3, 0.8)
    self.sizeDifference = math.randomFloat(0, 1.2)
end

-- update is called once every frame
function object:update(dt)
    self.position = self.position + vector(self.cos, self.sin) * self.speed * dt
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self:destroy()
    end
end

-- draw is called once every draw frame
function object:draw()
    local progress = self.timeLeft / self.time
    color.white:set(progress)
    graphics.circle("fill", self.position.x, self.position.y, self.size + (self.sizeDifference * progress), 8)
end

return object