local object = object:extend()

object.FLOAT_RATE = 0.8

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.image = resource.image("crown.png")
    self.col = collision.rectangle(entity.x, entity.y, 8, 9)

    self.pickFn = entity.props.pick
    self.timer = entity.props.floatDelay

    self.offset = 0
end

function object:pick()
    -- TODO: play click sound
    if self.pickFn and global.game.level.funcs[self.pickFn] then
        for _, func in pairs(global.game.level.funcs[self.pickFn]) do
            func()
        end
    end
end


function object:update(dt)
    for _, character in pairs(global.game.collisions.characters) do
        if collision.checkRectangles(self.col, character.col) then
            self:pick()
            self:destroy()
            camera.shake(0.04, 0.02, 0.3, 0.1)
            for i = 1, math.random(1, 3), 1 do
                objects.dust(self.x + 4, self.y + 4)
            end
        end
    end

    self.timer = self.timer + dt
    if self.timer > object.FLOAT_RATE then
        self.timer = 0
        if self.offset == 0 then
            self.offset = 1
        else
            self.offset = 0
        end
    end
end

function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + self.offset + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

return object