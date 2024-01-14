local object = object:extend()

object.FLOAT_DELAY = 0.65
function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.ballon = resource.image("balloon.png")
    self.ballonGhost = resource.image("balloon-ghost.png")
    self.height = entity.props.height
    self.col = collision.rectangle(entity.x, entity.y, 5, 7)
    self.image = self.ballon
    self.cooldown = entity.props.cooldown
    self.timer = 0
    self.ready = true
    self.offsetTimer = entity.props.offsetTimer
    self.offset = 0
end


function object:update(dt)
    if self.offsetTimer > 0 then
        self.offsetTimer = self.offsetTimer - dt
    else
        self.offset = self.offset + 1
        if self.offset > 1 then
            self.offset = 0
        end
        self.offsetTimer = self.FLOAT_DELAY
    end

    if global.paused then
        return
    end
    
    if self.timer > 0 then
        self.timer = self.timer - dt
        self.ready = false
        self.image = self.ballonGhost
        return
    else
        if not self.ready then
            -- TODO: play sound
            global.playSound('balloon-appear.wav')
            for i = 1, math.random(2, 3), 1 do
                objects.dust(self.x + 3 + math.randomFloat(-2, 2), self.y + 4 + math.randomFloat(-2, 2))
            end
        end
        self.ready = true
        self.image = self.ballon
    end

    for _, character in pairs(global.game.collisions.characters) do
            if not character.paused and collision.checkRectangles(self.col, character.col) then
            self.timer = self.cooldown
            character.velocity.y = -math.sqrt(2 * character.GRAVITY * ((character.position.y - (self.y + 8)) + self.height))

            if character.isBunny then
                character.jumpsLeft = 1
            end

            for i = 1, math.random(4, 7), 1 do
                objects.dust(self.x + 3 + math.randomFloat(-2, 2), self.y + 4 + math.randomFloat(-2, 2))
            end

            camera.shake(0.04, 0.02, 0.3, 0.1)
            --TODO: Play sound
            global.playSound('pop.wav')
        end
    end

    for _, box in pairs(global.game.collisions.boxes) do
        if collision.checkRectangles(self.col, box.col) then
        self.timer = self.cooldown
        box.velocity.y = -math.sqrt(2 * box.GRAVITY * ((box.y + box.col.h - (self.y + 8)) + self.height))

        for i = 1, math.random(4, 7), 1 do
            objects.dust(self.x + 3 + math.randomFloat(-2, 2), self.y + 4 + math.randomFloat(-2, 2))
        end

        camera.shake(0.04, 0.02, 0.3, 0.1)
        --TODO: Play sound
    end
end
end

function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + self.offset)
end

return object