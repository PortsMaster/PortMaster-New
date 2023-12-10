-- extending the object class
local object = object:extend()

object.layer = -1
object.OFFSET_DELAY = 0.2

-- create is called once the object is just created in the room
function object:create(entity)
    self.col = collision.rectangle(entity.x, entity.y, entity.width, entity.height)
    global.game.collisions.jumpThrough[self] = self
    if entity.props.id then
        global.game.collisions.ids[entity.props.id] = self
    end

    self.id = entity.props.id
    
    self.floaty = entity.props.floaty
    self.offset = self.floaty and 0 or 1
    self.isGrounded = false
    self.timer = 0
    self.weight = {}
    self.rel = entity.props.rel
    self.rel2 = entity.props.rel2
end

-- update is called once every frame
function object:update(dt)
    if global.paused then
        return
    end

    if not self.floaty then
        return
    end

    if self.isGrounded then
        self.offset = 1
        self.timer = self.OFFSET_DELAY
    else
        if self.timer > 0 then
            self.timer = self.timer - dt
        else
            self.offset = 0
        end
    end

    if self.rel and global.game.collisions.ids[self.rel] then
        global.game.collisions.ids[self.rel].isGrounded = false
    end

    if self.rel2 and global.game.collisions.ids[self.rel2] then
        global.game.collisions.ids[self.rel2].isGrounded = false
    end

    self.isGrounded = false

    self.col.y = self.col.y - 2
    for _, character in pairs(self.weight) do
        if collision.checkRectangles(self.col, character.col)then
            self.isGrounded = true
            self.offset = 1
        else
            self.weight[character] = nil
        end
    end

    self.col.y = self.col.y + 2

    if self.isGrounded then
        if self.rel and global.game.collisions.ids[self.rel] then
            global.game.collisions.ids[self.rel].offset = 1
            global.game.collisions.ids[self.rel].isGrounded = true

        end
    
        if self.rel2 and global.game.collisions.ids[self.rel2] then
            global.game.collisions.ids[self.rel2].offset = 1
            global.game.collisions.ids[self.rel].isGrounded = true
        end
    end
end

-- draw is called once every draw frame
function object:draw()
    -- graphics.setColor(0.8, 0.8, 0.8)
    -- love.graphics.rectangle('fill', self.col.x, self.col.y + self.offset, self.col.w, self.col.h)
end

function object:remove()
    global.game.collisions.jumpThrough[self] = nil
    if self.id then
        global.game.collisions.ids[self.id] = nil
    end
end

return object