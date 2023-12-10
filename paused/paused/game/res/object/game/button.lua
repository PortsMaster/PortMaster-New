local object = object:extend()

object.layer = -1

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.button = resource.image("button.png")
    self.buttonPressed = resource.image("button-pressed.png")
    self.col = collision.rectangle(entity.x - 1, entity.y + 2, 10, 7)
    self.image = self.button
    self.isDown = false
    self.pressedFn = entity.props.press
    self.releasedFn = entity.props.release
    self.heldFn = entity.props.hold
end

function object:pressed()
    -- TODO: play click sound
    global.playSound('button-click.wav')
    if self.pressedFn and global.game.level.funcs[self.pressedFn] then
        for _, func in pairs(global.game.level.funcs[self.pressedFn]) do
            func()
        end
    end
end

function object:released()
    -- TODO: play release sound
    global.playSound('button-release.wav')
    if self.releasedFn and global.game.level.funcs[self.releasedFn] then
        for _, func in pairs(global.game.level.funcs[self.releasedFn]) do
            func()
        end
    end
end

function object:held()
    if self.heldFn and global.game.level.funcs[self.heldFn] then
        for _, func in pairs(global.game.level.funcs[self.heldFn]) do
            func()
        end
    end
end


function object:update(dt)
    local last = self.isDown
    self.isDown = false
    self.image = self.button
    for _, character in pairs(global.game.collisions.characters) do
        if collision.checkRectangles(self.col, character.col) then
            self.isDown = true
            self:held()
            self.image = self.buttonPressed
            if not last then
                camera.shake(0.04, 0.02, 0.3, 0.1)
            end
            break
        end
    end

    for _, box in pairs(global.game.collisions.boxes) do
        if collision.checkRectangles(self.col, box.col) then
            self.isDown = true
            self:held()
            self.image = self.buttonPressed
            if not last then
                camera.shake(0.04, 0.02, 0.3, 0.1)
            end
            break
        end
    end

    if last ~= self.isDown then
        if self.isDown then
            self:pressed()
        else
            self:released()
        end
    end
end

function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

return object