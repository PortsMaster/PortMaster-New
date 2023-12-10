local object = object:extend()
object.tag = "player"
object.layer = 5

local SPEED = 37
local GRAVITY = 300
local MAX_FALL_SPEED = 100
local JUMP_HEIGHT = 12
local JUMP_BUFFER_TIME = 0.15
local COYOTE_TIME = 0.05

local COLLISION_SIZE = {4, 6}

-- Used for collision filtering
local filters = {
    solid = "slide",
    jump_through = "slide",
    platform = "slide",
    door = "slide",
    box = "slide",
}
local function collisionFilter(item, other)
    if filters[other.tag] then
        return filters[other.tag]
    end

    return 'cross'
end

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y + 2)
    self.velocity = vector(0, 0)

    self.platformVelocity = vector(0, 0)

    self.jumpVelocity = math.sqrt(2 * GRAVITY * JUMP_HEIGHT)
    self.jumpBuffer = 0
    self.coyoteTimer = 0
    self.grounded = true 
    self.lastGrounedState = true
    self.flipped = ldtkEntity.props.flipped

    self.alive = true

    self.keys = {}

    self.delayedCollisions = {}
    self.removedCollisions = {}


    self.sprites = {
        idle = sprite("player/1.png", "player/2.png", 0.4),
        run = sprite("player/3.png", "player/4.png", "player/5.png", 0.15),
        jump = sprite("player/6.png", 0.1),
        fall = sprite("player/7.png", 0.1),
    }

    for key, sprite in pairs(self.sprites) do
        sprite:setOrigin(6, 11)
    end

    self.currentSprite = "idle"

    -- Add player collision to the world
    game.world:add(self, self.position.x, self.position.y, COLLISION_SIZE[1], COLLISION_SIZE[2])

    game.shadows:add(self)

    game.player = self

    objects.menu_pause()

    -- update camera to follow player
    camera.x = math.floor((self.position.x + game.level.data.props.x + (self.flipped and 0 or 4)) / 64) * 64
    camera.y = math.floor((self.position.y + game.level.data.props.y) / 64) * 64
end

local collisions = {
    solid = function (self, other, col)
        if math.abs(col.normal.y) == 1 and col.itemRect.y + col.itemRect.h < col.otherRect.y + 1 then
            self.grounded = true
        elseif math.abs(col.normal.y) == 1 and col.itemRect.y > col.otherRect.y + col.otherRect.h then
            self.velocity.y = 0
            -- ceiling hit
        end
    end,
    jump_through = function (self, other, col)
        if col.normal.y == -1 and self.position.y + COLLISION_SIZE[2] < other.position.y + 1 and self.velocity.y > 0 then
            self.grounded = true
            return
        end
        -- remove the object and collide again
        table.insert(self.removedCollisions, {other, {game.world:getRect(other)}})
        game.world:remove(other)
        self.doCollision = true
    
    end,
    button = function (self, other, col)
        other:playerEnter()
    end,
    bouncy = function (self, other, col)
        if other.jump then
            self.bouncy = other
            self.targetJump = -math.sqrt(2 * GRAVITY * (other.height + (self.position.y + self.velocity.y * love.timer.getDelta() + COLLISION_SIZE[2] - other.position.y)))

            if self.targetJump > 0 then
                self.targetJump = nil
            end
        end
    end,
    key = function (self, other, col)
        self.keys[other] = true
        other:playerEnter(self, table.count(self.keys))
        other.tag = ""
    end,
    pickable = function (self, other, col)
        other:playerEnter()
    end,
    door = function (self, other, col)
        if math.abs(col.normal.y) == 1 and col.itemRect.y + col.itemRect.h < col.otherRect.y + 1 then
            self.grounded = true
        elseif math.abs(col.normal.y) == 1 and col.itemRect.y > col.otherRect.y + col.otherRect.h then
            self.velocity.y = 0
            -- ceiling hit
        end

        if not other.keyNeeded then
            return
        end
        
        for key, _ in pairs(self.keys) do
            if not other.isOpen and key.speedModifier == 1 then
                
                key.target = other.position
                if other.yScale then
                    key.targetOffset = vector(0, other.yScale * 4 - 4)
                elseif other.xScale then
                    key.targetOffset = vector(other.xScale * 4 - 4, 0)
                end
                
                self.keys[key] = nil
                other:open(key)

                for key, value in pairs(self.keys) do
                    key.targetOffset.y = key.targetOffset.y + 6
                    key.speedModifier = key.speedModifier - 1
                end

                return
            end
        end
    end,
    danger = function (self, other, col)
        -- die
        if self.alive then
            self:destroy()
            local dead = objects.player_dead(self.position.x + self.velocity.x * timer.getDelta(), self.position.y + self.velocity.y * timer.getDelta(), self.flipped, self.sprites[self.currentSprite])
            self.alive = false

            for key, _ in pairs(self.keys) do
                key.target = dead.position
            end
        end
    end,
    box = function (self, other, col)
        if math.abs(col.normal.y) == 1 and col.itemRect.y + col.itemRect.h < col.otherRect.y + 1 then
            self.grounded = true
        elseif math.abs(col.normal.y) == 1 and col.itemRect.y > col.otherRect.y + col.otherRect.h then
            self.velocity.y = 0
            -- ceiling hit
        end
        
        if col.normal.x == -1 then
            other.velocity.x = other.speed
        elseif col.normal.x == 1 then
            other.velocity.x = -other.speed
        end
    end,
    checkpoint = function (self, other, col)
        if not other.active then
            other:playerEnter()
        end
    end,
    platform = function (self, other, col)
        if col.normal.y == -1 and col.itemRect.y + col.itemRect.h < col.otherRect.y + 1 and self.velocity.y > 0 then
            self.grounded = true
            self.platformVelocity.x = other.velocity.x
            self.platformVelocity.y = other.velocity.y
            other.player = self
            return
        end

        -- remove the object and collide again
        table.insert(self.removedCollisions, {other, {game.world:getRect(other)}})
        game.world:remove(other)
        self.doCollision = true
    end,
    event = function (self, other, col)
        other:playerEnter()
    end,
}

function object:update(dt)
    if game.paused then
        return
    end

    -- X axis movement
    self.velocity.x = 0
    if input.get("left") then
        self.velocity.x = self.velocity.x - SPEED
    end
    
    if input.get("right") then
        self.velocity.x = self.velocity.x + SPEED
    end

    if self.velocity.x ~= 0 then
        self.flipped = self.velocity.x < 0
    end

    -- Cap fall speed
    if self.velocity.y > MAX_FALL_SPEED then
        self.velocity.y = MAX_FALL_SPEED
    end

    -- Caching jump input
    if input.get("jump") then
        self.jumpBuffer = JUMP_BUFFER_TIME
    elseif self.jumpBuffer > 0 then
        self.jumpBuffer = self.jumpBuffer - dt
    end
    
    -- Apply gravity
    self.velocity.y = self.velocity.y + GRAVITY * dt

    -- a simple trick to make the one way collision work, beware of multiple collisions on things like coins, etc.
    self.doCollision = true

    -- reset platform velocity
    self.platformVelocity.x = 0
    self.platformVelocity.y = 0
    
    local actualX, actualY, cols, len
    while self.doCollision do
        
        -- reset colliding objects
        for key, value in pairs(self.delayedCollisions) do
            self.delayedCollisions[key] = nil
        end

        self.doCollision = false

        self.targetJump = nil
        self.targetY = nil
        self.bouncy = nil

        -- Updating collision
        actualX, actualY, cols, len = game.world:check(self, self.position.x + self.velocity.x * dt, self.position.y + self.velocity.y * dt, collisionFilter)
        
        -- reset grounded state
        self.grounded = false

        -- Check for collisions
        for i=1,len do
            local other = cols[i].other
            if other.tag == "jump_through" or other.tag == "platform" then
                if collisions[other.tag] then
                    collisions[other.tag](self, other, cols[i])
                end
            else
                self.delayedCollisions[i] = {function (col)
                    if collisions[other.tag] then
                        collisions[other.tag](self, other, col)
                    end
                end, cols[i]}
            end
        end
    end
    
    -- apply delayed collisions
    for key, value in pairs(self.delayedCollisions) do
        value[1](value[2])
        self.delayedCollisions[key] = nil
    end
    
    -- re-add removed collisions
    for index, value in ipairs(self.removedCollisions) do
        game.world:add(value[1], unpack(value[2]))
        self.removedCollisions[index] = nil
    end

    -- applying movement
    self.position.x = actualX + self.platformVelocity.x
    self.position.y = actualY 

    game.world:update(self, self.position.x, self.position.y)

    -- Grounded
    if self.grounded then
        -- reset velocity
        self.velocity.y = 0
        
        -- reset coyote timer
        self.coyoteTimer = COYOTE_TIME
        
        if self.lastGrounedState == false then
 
            -- objects.land_particles(self.position.x - 6, self.position.y - 2):setLayer(self.layer + 1)
            for i = 1, math.random(2,4), 1 do
                --objects.particle(self.position.x + math.random(-2, 2), self.position.y + math.random(-2, 2) + 2)
            end
        end
    else
        if self.coyoteTimer > 0 then
            self.coyoteTimer = self.coyoteTimer - dt
        end
    end
    
    -- Apply bouncy jump
    if self.targetJump then
        self.velocity.y = self.targetJump
        self.targetJump = nil
        self.jumpBuffer = 0
        self.coyoteTimer = 0
        self.platformVelocity.y = 0
        self.bouncy:playerEnter()
    end
    
    
    -- Jumping
    if self.coyoteTimer > 0 and self.jumpBuffer > 0 then
        -- jump
        self.velocity.y = -self.jumpVelocity
        self.jumpBuffer = 0
        self.coyoteTimer = 0
        self.platformVelocity.y = 0
        self.grounded = false
        
        if game.saveStats then
            game.stats.jumps = game.stats.jumps + 1
        end

        game.playSound("jump.wav")
    end

    -- caching grounded state
    self.lastGrounedState = self.grounded

    -- Handle animation
    if not self.grounded then
        if self.velocity.y < 0 then
            if self.currentSprite ~= "jump" then
                self.currentSprite = "jump"
            end
        elseif self.velocity.y > 0 then
            if self.currentSprite ~= "fall" then
                self.currentSprite = "fall"
            end
        end
    else
        if self.velocity.x ~= 0 then
            if self.currentSprite ~= "run" then
                self.currentSprite = "run"
                self.sprites["fall"]:setFrame(1)
            end
        else
            if self.currentSprite ~= "idle" then
                self.currentSprite = "idle"
                self.sprites["jump"]:setFrame(1)
            end
        end
    end
    
    -- update sprite
    if self.sprites[self.currentSprite] then
        self.sprites[self.currentSprite]:setScale(self.flipped and -1 or 1, 1)
        self.sprites[self.currentSprite]:update(dt)
    end

    if game.saveStats then
        game.stats.time = game.stats.time + dt
    end

    game.playing = true

    -- update camera to follow player
    camera.x = math.floor((self.position.x - game.level.data.props.x + (self.flipped and -1 or 5)) / 64) * 64 + game.level.data.props.x
    camera.y = math.floor((self.position.y - game.level.data.props.y  + 2) / 64) * 64 + game.level.data.props.y

    if camera.x < game.level.data.props.x then
        camera.x = game.level.data.props.x
    elseif camera.x > game.level.data.props.x + game.level.data.width - 64 then
        camera.x = game.level.data.props.x + game.level.data.width - 64
    end

    if camera.y < game.level.data.props.y then
        camera.y = game.level.data.props.y
    elseif camera.y > game.level.data.props.y + game.level.data.height - 64 then
        camera.y = game.level.data.props.y + game.level.data.height - 64
    end

end

function object:draw()
    if self.sprites[self.currentSprite] then
        if game.subpixel then
            self.sprites[self.currentSprite]:draw(self.position.x + 2, self.position.y + 6)
        else
            self.sprites[self.currentSprite]:draw(math.round(self.position.x + 2), math.round(self.position.y + 6))
        end
    end

    if DEBUG then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", game.world:getRect(self))
    end
    -- local x, y, w, h = game.world:getRect(self)
    -- graphics.rectangle("fill", x, y, w, h)

end

function object:remove()
    -- remove player collision from the world
    game.world:remove(self)

    -- remove player shadow from the world
    game.shadows:remove(self)

    game.player = nil
end

return object