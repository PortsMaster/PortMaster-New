local object = object:extend()
object.tag = "solid"

function object:create(ldtkEntity)
    self.collisionXOffset = ldtkEntity.props.collisionOffset < 0 and ldtkEntity.props.collisionOffset or 0
    self.collisionWOffset = math.abs(ldtkEntity.props.collisionOffset)
    self.position = vector(ldtkEntity.x + ldtkEntity.props.offsetX, ldtkEntity.y + ldtkEntity.props.offsetY)
    game.world:add(self, self.position.x + 1 + self.collisionXOffset, self.position.y, 2 + self.collisionWOffset, 3)
    game.shadows:add(self)

    self.sprite = sprite("objects/block-small.png")
    self.spriteGhost = sprite("objects/block-small-ghost.png")
    
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