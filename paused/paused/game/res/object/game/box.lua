local object = object:extend()

object.layer = 0

object.GRAVITY = 500
object.MAX_FALL_SPEED = 120

function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.image = resource.image("box.png")
    self.col = collision.rectangle(entity.x, entity.y - 1, 8, 10)
    self.velocity = vector(0, 0)
    self.maxMovingSpeed = 15
    
    self.weight = {}
    self.offset = 0
    self.forcedOffset = 0

    global.game.collisions.boxes[self] = self
end


function object:update(dt)
    if global.paused then return end
    self.offset = 0

    
    self.velocity.y = self.velocity.y + self.GRAVITY * dt
    if self.velocity.y > self.MAX_FALL_SPEED then
        self.velocity.y = self.MAX_FALL_SPEED
    end
    
    self:moveAndCollide(dt)
    
    if (self.offset > 0) then
        self.col.y = self.y - 2 + self.offset
        for _, character in pairs(self.weight) do
            if not collision.checkRectangles(self.col, character.col)then
                character.position.y = self.y - 1
            end
        end
    else
        self.col.y = self.y - 2
        for _, character in pairs(self.weight) do
            if collision.checkRectangles(self.col, character.col)then
                character.position.y = self.y - 2
            end
        end 
    end
    
    for _, character in pairs(self.weight) do
        character.position.x = character.position.x + self.velocity.x * dt
        character.position.y = character.position.y + self.velocity.y * dt
    end
    
    for _, character in pairs(global.game.collisions.characters) do
        if character.paused and collision.checkRectangles(character.col, self.col) then
            character.position.x = character.position.x + self.velocity.x * dt
        end
    end
    
    self.col.y = self.col.y
    
    self.velocity.x = 0
end

function object:moveAndCollide(dt)
    self.y = self.y + self.velocity.y * dt
    self.x = self.x + self.velocity.x * dt
    self.col.x = self.x
    self.col.y = self.y - 2
    
    for _, block in pairs(global.game.collisions.blocks) do
        if block.col and collision.checkRectangles(self.col, block.col) then
            if self.col.x + self.col.w > block.col.x and self.col.x < block.col.x + block.col.w then
                --- ground
                if self.velocity.y > 0 and self.col.y + self.col.h < block.col.y + 4 then
                    self.velocity.y = 0
                    
                    if global.game.collisions.ids[block.id] and global.game.collisions.ids[block.id].offset > 0 then
                        self.offset = 1
                    end
                    
                    if block.rel and global.game.collisions.ids[block.rel] and global.game.collisions.ids[block.rel].offset > 0 then
                        self.offset = 1
                    end
                    
                    if block.rel2 and global.game.collisions.ids[block.rel2] and global.game.collisions.ids[block.rel2].offset > 0 then
                        self.offset = 1
                    end
                    
                    self.y = block.col.y - self.col.h + 2
                    self.col.y = self.y - 2
                    
                --- ceiling
                elseif self.velocity.y < 0 and self.col.y < block.col.y + block.col.h + 4 then
                    self.velocity.y = 0
                    self.y = block.col.y + block.col.h + 1
                    self.col.y = self.y - 2
                end
            end

            if self.col.y + self.col.h - 1 > block.col.y + 1 and self.col.y + 1 < block.col.y + block.col.h - 1 then
                --- right
                if self.velocity.x > 0 then
                    self.velocity.x = 0
                    self.x = block.col.x - self.col.w
                    self.col.x = self.x
                --- left
                end

                if self.velocity.x < 0 then
                    self.velocity.x = 0
                    self.x = block.col.x + block.col.w
                    self.col.x = self.x
                end
            end
            
        end
    end

    for _, block in pairs(global.game.collisions.jumpThrough) do
        if block.col and collision.checkRectangles(self.col, block.col) then
            if self.col.x + self.col.w > block.col.x and self.col.x < block.col.x + block.col.w then
                --- ground
                if self.velocity.y > 0 and self.col.y + self.col.h < block.col.y + 1 then
                    self.velocity.y = 0
                    
                    if global.game.collisions.ids[block.id] and global.game.collisions.ids[block.id].offset > 0 then
                        self.offset = 1
                    end
                    
                    if block.rel and global.game.collisions.ids[block.rel] and global.game.collisions.ids[block.rel].offset > 0 then
                        self.offset = 1
                    end
                    
                    if block.rel2 and global.game.collisions.ids[block.rel2] and global.game.collisions.ids[block.rel2].offset > 0 then
                        self.offset = 1
                    end
                    
                    self.y = block.col.y - self.col.h + 2
                    self.col.y = self.y - 2
                end
            end 
        end
    end
end

function object:draw()
    color.reset()
    if self.forcedOffset then
        self.offset = self.offset + self.forcedOffset
        self.forcedOffset = 0
    end
    graphics.draw(self.image, self.x, self.y - 1 + self.offset)
    -- graphics.setColor(1, 0, 0, 0.5)
    -- graphics.rectangle('fill', self.col.x, self.col.y, self.col.w, self.col.h)
end

function object:move(dt, direction)
    self.velocity.x = direction * self.maxMovingSpeed
end

function object:remove()
    global.game.collisions.boxes[self] = nil
end

return object