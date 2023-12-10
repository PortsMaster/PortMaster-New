local object = object:extend()

object.DELAY = 0.35

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.bouncy = resource.image("bouncy.png")
    self.bouncyPressed = resource.image("bouncy-pressed.png")
    self.height = entity.props.height
    self.col = collision.rectangle(entity.x + 2, entity.y + 2, 6, 7)
    self.image = self.bouncy
    self.imageTimer = 0
    self.applied = {}
end


function object:update(dt)
    if self.imageTimer > 0 then
        self.imageTimer = self.imageTimer - dt
    end
    if self.imageTimer <= 0 then
        self.image = self.bouncy
    end
    for _, character in pairs(global.game.collisions.characters) do
        if (not self.applied[character]) then
            if collision.checkRectangles(self.col, character.col) then
                self.applied[character] = true
                self.image = self.bouncyPressed
                self.imageTimer = self.DELAY
                character.velocity.y = -math.sqrt(2 * character.GRAVITY * ((character.position.y - (self.y + 8)) + self.height))

                if character.isBunny then
                    character.jumpsLeft = 1
                end

                for i = 1, math.random(2, 4), 1 do
                    objects.dustUp(self.x + 4, self.y + 3)
                end

                --TODO: Play sound
                global.playSound('bouncy.wav')
            end
        elseif not collision.checkRectangles(self.col, character.col) then
            self.applied[character] = nil
        end
    end

    for _, box in pairs(global.game.collisions.boxes) do
        if (not self.applied[box]) then
            if collision.checkRectangles(self.col, box.col) then
                self.applied[box] = true
                self.image = self.bouncyPressed
                self.imageTimer = self.DELAY
                box.velocity.y = -math.sqrt(2 * box.GRAVITY * ((box.y + box.col.h - (self.y + 8)) + self.height))

                for i = 1, math.random(2, 4), 1 do
                    objects.dustUp(self.x + 4, self.y + 3)
                end

                --TODO: Play sound
            end
        elseif not collision.checkRectangles(self.col, box.col) then
            self.applied[box] = nil
        end
    end
end

function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

return object