local object = object:extend()

object.layer = -1
function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.col = collision.rectangle(entity.x, entity.y + 2, entity.width, 2)
    self.target_y = entity.props.target_y
    self.target_x = entity.props.target_x
    self.inverse_y_velocity = entity.props.inverse_y_velocity

    objects.thingAnimated(entity)
end


function object:update(dt)
    for _, character in pairs(global.game.collisions.characters) do
        if collision.checkRectangles(self.col, character.col) then
            for i = 1, math.random(1, 2), 1 do
                objects.dust(character.position.x, character.position.y - 4)
            end
            character.position.y = self.target_y
            if self.target_x ~= nil then
                character.position.x = self.target_x
            end

            if self.inverse_y_velocity then
                character.velocity.y = -character.velocity.y
            end
            for i = 1, math.random(1, 2), 1 do
                objects.dust(character.position.x, character.position.y - 4)
            end
            -- TODO: play teleport sound

        end
    end
end

function object:draw()

end

function object:remove()
    
end

return object