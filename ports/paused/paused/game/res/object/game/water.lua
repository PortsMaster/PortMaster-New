local object = object:extend()

function object:create(entity)
    objects.thingAnimated(entity)
    objects.col_kill({x = entity.x, y = entity.y + 3, width = math.floor(entity.width / 8) * 8, height = 5})
    self:destroy()
end

function object:update(dt)
    
end

function object:draw()

end

return object