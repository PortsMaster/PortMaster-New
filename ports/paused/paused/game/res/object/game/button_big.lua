local object = object:extend()

object.layer = -1

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.button = resource.image("button-big.png")
    self.buttonPressed = resource.image("button-big-pressed.png")
    self.col = collision.rectangle(entity.x, entity.y + 2, 16, 7)
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
    local previous = false
    self.isDown = false
    self.image = self.button
    for _, character in pairs(global.game.collisions.characters) do
        if collision.checkRectangles(self.col, character.col) then
            if previous and not self.isDown then
                self.isDown = true
                self:held()
                self.image = self.buttonPressed
                if not last then
                    camera.shake(0.05, 0.02, 0.5, 0.25)
                end
            end
            previous = true
        end
    end

    for _, box in pairs(global.game.collisions.boxes) do
        if collision.checkRectangles(self.col, box.col) then
            if previous and not self.isDown then
                self.isDown = true
                self:held()
                self.image = self.buttonPressed
                if not last then
                    camera.shake(0.05, 0.02, 0.5, 0.25)
                end
            end
            previous = true
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

    -- color.red:set(0.5)
    -- graphics.rectangle('fill', self.col.x, self.col.y, self.col.w, self.col.h)
end

return object