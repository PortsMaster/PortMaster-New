local object = object:extend()
object.layer = 3

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.sprite = sprite(ldtkEntity.props.sprite)
    
    self.hoverSpeed = ldtkEntity.props.hoverSpeed or 0
    self.hover = (self.hoverSpeed) > 0
    self.hoverTimer = 0
    self.offset = 0
    
    game.shadows:add(self)

end

function object:update(dt)
    if game.paused then
        return
    end
    if not self.hover then return end
    
    if self.hoverTimer < 0 then
        self.hoverTimer = self.hoverSpeed
        self.offset = self.offset == 1 and 0 or 1
    else
        self.hoverTimer = self.hoverTimer - dt
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y + self.offset)
    else
        self.sprite:draw(math.floor(self.position.x), math.floor(self.position.y) + self.offset)
    end
end

function object:remove()
    game.shadows:remove(self)
end

return object