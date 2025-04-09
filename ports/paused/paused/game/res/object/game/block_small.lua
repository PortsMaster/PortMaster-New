local object = object:extend()

object.layer = -1

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.block = resource.image("block-small.png")
    self.blockHidden = resource.image("block-small-hidden.png")
    self.collision_rectangle = collision.rectangle(entity.x - 1, entity.y - 1, 5, 6)
    self.upCollision = collision.rectangle(entity.x, entity.y - 2, 8, 2)
    self.col = self.collision_rectangle
    self.visible = entity.props.visible
    global.game.collisions.blocks[self] = self

    self.weight = {}


    if self.visible then
        self.image = self.block
    else
        self.image = self.blockHidden
    end

    self.waitForPlayer = entity.props.waitForPlayer

    self.showFn = entity.props.show
    self.hideFn = entity.props.hide
    self.toggleFn = entity.props.toggle

    if self.showFn then
        if not global.game.level.funcs[self.showFn] then
            global.game.level.funcs[self.showFn] = {}
        end

        local func = function() self:show() end
        global.game.level.funcs[self.showFn][func] = func
    end

    if self.hideFn then
        if not global.game.level.funcs[self.hideFn] then
            global.game.level.funcs[self.hideFn] = {}
        end

        local func = function() self:hide() end
        global.game.level.funcs[self.hideFn][func] = func
    end

    if self.toggleFn then
        if not global.game.level.funcs[self.toggleFn] then
            global.game.level.funcs[self.toggleFn] = {}
        end

        local func = function() self:toggle() end
        global.game.level.funcs[self.toggleFn][func] = func
    end
end


function object:update(dt)
    if self.waitForPlayer and not self.col then
        for _, character in pairs(global.game.collisions.characters) do
            if collision.checkRectangles(self.collision_rectangle, character.col) then
                return
            end
        end

        for _, character in pairs(global.game.collisions.boxes) do
            if collision.checkRectangles(self.collision_rectangle, character.col) then
                return
            end
        end
    end

    if self.visible then
        if not self.col then
            self.col = self.collision_rectangle
            self.image = self.block

            for i = 1, math.random(0, 1), 1 do
                objects.dust(self.x + 4, self.y + 4)
            end
        end

        local offset = (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0)
        self.col.y = self.y - 1 + offset

        if offset > 0 then
            for _, character in pairs(self.weight) do
                if (character.paused) then
                    character.position.y = self.y
                end
            end
        else
            for _, character in pairs(self.weight) do
                if (character.paused) then
                    character.position.y = self.y - 1
                end
            end
        end
    else
        self.col = nil
        self.image = self.blockHidden
    end

    for _, box in pairs(global.game.collisions.boxes) do
        if box.col and self.col and collision.checkRectangles(self.upCollision, box.col) then
            box.forcedOffset = 1
        end
    end
end

function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

function object:remove()
    global.game.collisions.blocks[self] = nil
end

function object:hide()
    if not self.visible then
        return
    end

    -- Optional play sound (make sure it isn't already playing)
    self.visible = false
    for i = 1, math.random(1, 2), 1 do
        objects.dust(self.x + 2, self.y + 2)
    end
end

function object:show()
    if self.visible then
        return
    end

    -- Optional play sound (make sure it isn't already playing)
    self.visible = true
    for i = 1, math.random(1, 2), 1 do
        objects.dust(self.x + 2, self.y + 2)
    end
end

function object:toggle()
    -- Optional play sound (make sure it isn't already playing)
    self.visible = not self.visible
    for i = 1, math.random(1, 2), 1 do
        objects.dust(self.x + 2, self.y + 2)
    end
end

return object