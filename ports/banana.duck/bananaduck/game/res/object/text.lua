local object = object:extend()
object.layer = 2

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y + 1)
    self.text = ldtkEntity.props.text
    self.align = ldtkEntity.props.align
    self.color = ldtkEntity.props.color
    self.width = ldtkEntity.width
    self.visible = ldtkEntity.props.visible

    self.hoverSpeed = ldtkEntity.props.hoverSpeed or 0.5
    self.hover = ldtkEntity.props.hover

    self.hoverTimer = 0
    self.offset = 0

    game.shadows:add(self)

    for _, event in ipairs(ldtkEntity.props.show) do
        game.level:listenToEvent(self, event, function ()
            self.visible = true
        end)
    end

    for _, event in ipairs(ldtkEntity.props.hide) do
        game.level:listenToEvent(self, event, function ()
            self.visible = false
        end)
    end

    for _, event in ipairs(ldtkEntity.props.toggle) do
        game.level:listenToEvent(self, event, function ()
            self.visible = not self.visible
        end)
    end
end

function object:update(dt)
    if game.paused then
        return
    end

    if not self.hover then
        return
    end

    if self.hoverTimer < 0 then
        self.hoverTimer = self.hoverSpeed
        self.offset = self.offset == 1 and 0 or 1
    else
        self.hoverTimer = self.hoverTimer - dt
    end
end

function object:draw()
    if not self.visible then
        return
    end
    
    color[self.color]:set()
    graphics.printf(self.text, self.position.x, self.position.y + self.offset, self.width, self.align)
end

function object:remove()
    game.shadows:remove(self)
end

return object