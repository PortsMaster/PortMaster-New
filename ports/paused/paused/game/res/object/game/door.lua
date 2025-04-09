local object = object:extend()

object.layer = -1

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.image = resource.image("door.png")
    self.col = collision.rectangle(entity.x, entity.y, 11, 11)
    self.target = entity.props.target
    self.active = entity.props.active

    self.activateTarget = entity.props.activateTarget
    self.canBeDeactivated = entity.props.canBeDeactivated
    self.current = 0

    self.activateFn = entity.props.activate
    self.deactivateFn = entity.props.deactivate

    self.isSwitchingLevel = false

    if self.active then
        self.blend = 1
    else
        self.blend = 0
    end

    self.speed = 4

    if self.activateFn then
        if not global.game.level.funcs[self.activateFn] then
            global.game.level.funcs[self.activateFn] = {}
        end

        local func = function() self:activate() end
        global.game.level.funcs[self.activateFn][func] = func
    end

    if self.deactivateFn then
        if not global.game.level.funcs[self.deactivateFn] then
            global.game.level.funcs[self.deactivateFn] = {}
        end

        local func = function() self:deactivate() end
        global.game.level.funcs[self.deactivateFn][func] = func
    end
end


function object:update(dt)
    local all = true
    for _, character in pairs(global.game.collisions.characters) do
        if not collision.checkRectangles(self.col, character.col) then
            all = false
        end
    end

    if self.active then
        if all then
            if not self.isSwitchingLevel then
                self.isSwitchingLevel = true
                if self.target then
                    objects.splash(self.target, 0.7, 0.25, 0.15)
                else
                    objects.splash(room.current, 0.7, 0.25, 0.15)
                end
                
            end
        end
        self.blend = self.blend + dt * self.speed
        if self.blend > 1 then
            self.blend = 1
        end
    else
        self.blend = self.blend - dt * self.speed
        if self.blend < 0 then
            self.blend = 0
        end
    end


end

function object:draw()
    if self.blend == 0 then
        color.red:set()
    elseif self.blend == 1 then
        color.green:set()
    else
        color.blend(color.red, color.green, self.blend):set()
    end
    
    graphics.draw(self.image, self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

function object:activate()
    if self.current < self.activateTarget then
        self.current = self.current + 1
        if self.current < self.activateTarget then
            return
        end
    end

    if self.active then
        return
    end
    
    --play sound
    self.active = true
end

function object:deactivate()
    if not self.canBeDeactivated and self.active then
        return
    end

    if self.current > 0 then
        self.current = self.current - 1
    end

    if not self.active then
        return
    end

    --play sound
    self.active = false
end

return object