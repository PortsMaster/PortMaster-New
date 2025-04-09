local object = object:extend()
object.tag = "bouncy"
object.layer = 4

local COLLISION_SIZE = {8, 4}
local WAIT_TIME = 0.1

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.height = ldtkEntity.props.height

    self.parent = ldtkEntity.props.parent

    game.world:add(self, ldtkEntity.x, ldtkEntity.y + 4, COLLISION_SIZE[1], COLLISION_SIZE[2])
    self.sprites = {
        idle = sprite("objects/bouncy.png"),
        pressed = sprite("objects/bouncy-pressed.png"),
    }

    self.sprite = self.sprites.idle
    self.isPressed = false
    self.timer = 0
    self.jump = true

    game.shadows:add(self)
end

function object:update(dt)
    if game.paused then
        return
    end
    if self.isPressed then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.isPressed = false
            self.sprite = self.sprites.idle
        end
    end

    if self.parent then
        self.position.x = self.parent.position.x
        self.position.y = self.parent.position.y - 8

        game.world:update(self, self.position.x + 1, self.position.y + 4, COLLISION_SIZE[1] - 2, COLLISION_SIZE[2])
    end
end

function object:playerEnter()
    if not self.isPressed then
        game.playSound("bouncy.wav")
    end
    
    
    self.timer = WAIT_TIME
    self.sprite = self.sprites.pressed
    self.isPressed = true

end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y)
    else
        self.sprite:draw(math.round(self.position.x), math.round(self.position.y))
    end

    if DEBUG then
        love.graphics.setColor(0, 1, 0, 0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end


function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

return object