local object = object:extend()
object.tag = "solid"

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    game.world:add(self, self.position.x + 1, self.position.y + 1, 6, 6)
    game.shadows:add(self)

    self.sprite = sprite("objects/block.png")
    self.spriteGhost = sprite("objects/block-ghost.png")
    
    self.visible = ldtkEntity.props.visible
    self.tag = self.visible and "solid" or ""

    for _, event in ipairs(ldtkEntity.props.show) do
        game.level:listenToEvent(self, event, function ()
            self.visible = true
            self.tag = "solid"
        end)
    end

    for _, event in ipairs(ldtkEntity.props.hide) do
        game.level:listenToEvent(self, event, function ()
            self.visible = false
            self.tag = ""
        end)
    end

    for _, event in ipairs(ldtkEntity.props.toggle) do
        game.level:listenToEvent(self, event, function ()
            self.visible = not self.visible
            self.tag = self.visible and "solid" or ""
        end)
    end
end

function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

function object:draw()
    if game.subpixel then
        if self.visible then
            self.sprite:draw(self.position.x, self.position.y)
        else
            self.spriteGhost:draw(self.position.x, self.position.y)
        end
    else
        if self.visible then
            self.sprite:draw(math.round(self.position.x), math.round(self.position.y))
        else
            self.spriteGhost:draw(math.round(self.position.x), math.round(self.position.y))
        end
    end

    if DEBUG then
        color.reset(0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

return object