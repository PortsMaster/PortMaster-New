local object = object:extend()
object.tag = "box"
object.layer = 4

local SPEED = 12
local GRAVITY = 250
local MAX_FALL_SPEED = 100


function object:create(ldtkEntity)
    self.sprite = sprite("objects/box.png")
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.velocity = vector(0, 0)

    self.speed = SPEED
    self.platform = nil
    self.platformX = 0

    game.world:add(self, self.position.x, self.position.y, 8, 7)
    game.shadows:add(self)

    
    if ldtkEntity.props.bouncy then
        objects.bouncy({x = self.position.x, y = self.position.y - 7, props = {height = ldtkEntity.props.height, parent = self}})
    end
end

local tags = {
    solid = true,
    jump_through = true,
    platform = true,
    player = true,
    door = true,
}

local function collisionFilter(item, other)
    if other.tag and tags[other.tag]then
        return "slide"
    end
    return "cross"
end

function object:update(dt)
    if game.paused then
        return
    end

    if not self.platform then
        self.velocity.y = self.velocity.y + GRAVITY * dt
        if self.velocity.y > MAX_FALL_SPEED then
            self.velocity.y = MAX_FALL_SPEED
        end
    else
        self.velocity.y = 0.01
    end

    self.platform = nil

    local actualX, actualY, cols, len = game.world:check(self, self.position.x + self.velocity.x * dt, self.position.y + self.velocity.y * dt, collisionFilter)
        
    for i = 1, len do
        if cols[i].type == "slide" then
            if cols[i].normal.y == -1 then
                self.velocity.y = 0
                if cols[i].other.tag == "platform" then
                    if cols[i].normal.y == -1 then
                        cols[i].other.boxes[self] = true
                        self.platform = cols[i].other
                    end
                end
            end

            if cols[i].other.tag == "player" then
                self.position.x = self.position.x + cols[i].normal.x * -0.1
            end
        elseif cols[i].other.tag == "button" then
            cols[i].other:playerEnter()
        end
    end

    self.position.x = actualX
    self.position.y = actualY

    game.world:update(self, self.position.x, self.position.y)

    self.velocity.x = 0
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y)
    else
        self.sprite:draw(math.round(self.position.x), math.round(self.position.y))
    end
    if DEBUG then
        love.graphics.setColor(0, 0.5, 0, 0.5)
        love.graphics.rectangle("fill", game.world:getRect(self))
        love.graphics.setColor(1, 1, 1)
    end
end

function object:remove()
    game.shadows:remove(self)
    game.world:remove(self)
end

return object