local object = object:extend()

function object:create(entity)
    objects.thing(entity)
    objects.col_kill({x = entity.x + 2, y = entity.y + 7, width = math.floor(entity.width / 4) * 4 - 3, height = 2})
    self:destroy()
end

function object:update(dt)
    
end

function object:draw()

end

return object