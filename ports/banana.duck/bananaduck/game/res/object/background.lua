local object = object:extend()
object.layer = -100

function object:create(ldtkEntity)
    self.sprite = resource.image(ldtkEntity.props.image)
    self.sprite:setWrap("repeat", "repeat")
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.quad = love.graphics.newQuad(0, 0, 64 + self.width * 4, 64 + self.height * 4, self.width, self.height)
    self.speed = vector(ldtkEntity.props.speedX, ldtkEntity.props.speedY)
    self.offset = vector(0, 0)
    self.position = vector(0, 0)
end

function object:update(dt)
    self.offset.x = (self.offset.x + self.speed.x * dt) % self.width
    self.offset.y = (self.offset.y + self.speed.y * dt) % self.height
end

function object:draw()
    if game.subpixel then
        graphics.setColor(1, 1, 1, 1)
        graphics.draw(self.sprite, self.quad, -self.width * 2 + camera.x + self.offset.x, -self.height * 2 + camera.y + self.offset.y)
    else
        graphics.setColor(1, 1, 1, 1)
        graphics.draw(self.sprite, self.quad, -self.width * 2 + math.floor(camera.x + self.offset.x), -self.height * 2 + math.floor(camera.y + self.offset.y))
    end
end

return object