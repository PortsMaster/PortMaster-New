-- extending the object class
local object = object:extend()

object.layer = 0

-- create is called once the object is just created in the room
function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.id = entity.props.id
    self.col = collision.rectangle(entity.x + 5, entity.y + 5, 5, 7)
    global.game.collisions.kill[self] = self

    self.sprites = {
        idle = sprite('enemies/penguin/idle1.png', 'enemies/penguin/idle2.png', 'enemies/penguin/idle3.png', 'enemies/penguin/idle4.png', 0.2),
        shoot = sprite('enemies/penguin/shoot.png')
    }

    self.sprite = self.sprites.idle
end

-- update is called once every frame
function object:update(dt)
   self.sprite:update(dt)
end

-- draw is called once every draw frame
function object:draw()
    self.sprite:draw(self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

function object:remove()
    global.game.collisions.kill[self] = nil
end

return object