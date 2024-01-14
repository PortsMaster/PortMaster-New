-- extending the object class
local object = object:extend()

object.layer = 1

object.COLLISION_OFFSET = vector(-4, -4)
object.COLLISION_OFFSET_FLIPPED = vector(-2, -4)
object.COLLISION_SIZE = vector(6, 4)
object.COLLISION_PAUSED_SIZE = vector(8, 4)
object.COLLISION_PAUSED_OFFSET = vector(-1, 0)

object.GRAVITY = 400
object.SPEED = 45
object.JUMP_HEIGHT = 10
object.DOUBLE_JUMP = true
object.GLIDE = false
object.JUMP_BUFFER_TIME = 0.07 --in seconds
object.COYOTE_TIME = 0.07 --in seconds
object.FALL_THROUGH_BUFFER = 0.07 -- in seconds
object.MAX_JUMPS = 2
object.MAX_FALL_SPEED = 120


object.ORIGIN = vector(7, 10)
object.character = 'bunny'
object.isBunny = true
object.isDuckling = false

object.PARTICLE_RATE = 0.2
object.GLIDE_PARTICLE_RATE = 0.3
object.PUSH_PARTICLE_RATE = 0.5
object.DEATH_FLICKER_RATE = 0.07
object.START_DELAY = 0.1

-- create is called once the object is just created in the room
function object:create(entity)
    self.position = vector(entity.x, entity.y)

    self.isGrounded = true
    self.velocity = vector(0, 1)
    self.jumpVelocity = math.sqrt(2 * self.JUMP_HEIGHT * self.GRAVITY)
    self.jumpBufferTimer = 0
    self.coyoteTimer = 0
    self.fallThroughTimer = 0
    self.fallThroughPlatforms = {}
    self.flipped = entity.props.flipped
    self.collisionOffset = self.COLLISION_OFFSET
    self.jumpsLeft = 0
    
    self.paused = true

    self.last_anim = ''
    self.pausedIndicator = resource.image('paused-indicator.png')
    self.particleTimer = 0
    self.glideParticleTimer = 0
    self.pushParticleTimer = 0
    self.startDelayTimer = self.START_DELAY 
    self.canCreateParticle = 0
    self.airUpForce = 0
    self.airGlide = self.MAX_GLIDE_FALL_SPEED

    self.deathFlickerTimer = 0
    self.deathFlickerShow = false

    self.col = collision.rectangle(self.position.x + self.collisionOffset.x, self.position.y + self.collisionOffset.y, self.COLLISION_SIZE.x, self.COLLISION_SIZE.y)
    global.game.collisions.characters[self] = self

    self.sprites = {
        idle = sprite(self.character .. '/idle1.png', self.character .. '/idle2.png', 0.3),
        run = sprite(self.character .. '/run1.png', self.character .. '/run2.png', self.character .. '/run3.png', 0.15),
        jump = sprite(self.character .. '/jump1.png', self.character .. '/jump2.png', 0.2),
        fall = sprite(self.character .. '/fall1.png', self.character .. '/fall2.png', 0.2),
    }

    for _, spr in pairs(self.sprites) do
        spr:setOrigin(self.ORIGIN.x, self.ORIGIN.y)
    end

    self.anim = 'idle'
    self.sprites[self.anim].scaleX = self.flipped and -1 or 1

    if self.isBunny then
        if global.bunny then
            global.bunny:destroy()
        end
        global.bunny = self
    elseif self.isDuckling then
        if global.duckling then
            global.duckling:destroy()
        end
        global.duckling = self
    end

    self.velocity.y = 0
end

function object:_grounded(block, velocity, lastGrounded)
    if not lastGrounded then
        -- TODO: play land sound
        global.playSound('land.wav')
        if self.canCreateParticle <= 0 then
            self:createDustUp(math.random(0, 1))
            self.canCreateParticle = self.PARTICLE_RATE
        end
    end
    self.isGrounded = true
    self.coyoteTimer = self.COYOTE_TIME
    
    -- Stick to the ground
    self.position.y = block.col.y - self.col.h - self.collisionOffset.y
    self.col.y = self.position.y + self.collisionOffset.y

    -- Stop falling
    velocity.y = 0
end

function object:moveAndCollide(velocity, dt)
    -- Move 
    self.position = self.position + self.velocity * dt
    self.col.x = self.position.x + self.collisionOffset.x
    self.col.y = self.position.y + self.collisionOffset.y

    -- Reset grounded state
    local lastGrounded = self.isGrounded
    self.isGrounded = false

    -- Reset JumpThrough platforms exceptions if the players moves aways from them
    for _, platform in pairs(self.fallThroughPlatforms) do
        if not collision.checkRectangles(self.col, platform.col) then
            self.fallThroughPlatforms[platform] = nil
        end
    end

    -- Check collisions
    for _, block in pairs(global.game.collisions.blocks) do
        if block.col and collision.checkRectangles(self.col, block.col) then
            -- The player is aligned vertically with the block
            if self.col.x + self.col.w - 2 > block.col.x and self.col.x < block.col.x + block.col.w - 2 then
                -- ground
                if velocity.y >= 0 and block.col.y > self.col.y then
                    self:_grounded(block, velocity, lastGrounded)
                    block.isGrounded = true
                    block.weight[self] = self
                end

                -- ceiling
                if velocity.y < 0 and block.col.y < self.col.y then
                    -- Stick to the ceiling
                    self.position.y = block.col.y + block.col.h - self.collisionOffset.y
                    self.col.y = self.position.y + self.collisionOffset.y

                    -- Stop jumping
                    velocity.y = 1
                end
            end

            -- The player is aligned horizontally with the block
            if self.col.y + self.col.h - 1 > block.col.y and self.col.y < block.col.y + block.col.h then
                -- left
                if velocity.x < 0 and block.col.x < self.col.x then
                    -- Stick to the left
                    self.position.x = block.col.x + block.col.w - self.collisionOffset.x
                    self.col.x = self.position.x + self.collisionOffset.x

                    -- Stop moving left
                    velocity.x = 0
                end

                -- right
                if velocity.x > 0 and block.col.x > self.col.x then
                    -- Stick to the right
                    self.position.x = block.col.x - self.col.w - self.collisionOffset.x
                    self.col.x = self.position.x + self.collisionOffset.x

                    -- Stop moving right
                    velocity.x = 0
                end
            end
        else
            block.isGrounded = false
            block.weight[self] = nil
        end
    end

    for _, block in pairs(global.game.collisions.jumpThrough) do
        if self.fallThroughPlatforms[block] == nil and block.col and collision.checkRectangles(self.col, block.col) then
            if self.fallThroughTimer > 0 then
                self.fallThroughPlatforms[block] = block
                self.coyoteTimer = 0
                break
            end
            
            
            -- The player is aligned vertically with the block
            if self.col.x + self.col.w - 1 > block.col.x and self.col.x < block.col.x + block.col.w - 1 then
                -- ground
                if velocity.y >= 0 and block.col.y > self.col.y + self.col.h - (self.velocity.y * 0.02) - 2 then
                    self:_grounded(block, velocity, lastGrounded)
                    block.isGrounded = true
                    block.weight[self] = self
                end
            end
        end
    end

    for _, block in pairs(global.game.collisions.boxes) do
        if self.fallThroughPlatforms[block] == nil and block.col and collision.checkRectangles(self.col, block.col) then
            if self.fallThroughTimer > 0 then
                self.fallThroughPlatforms[block] = block
                self.coyoteTimer = 0
                break
            end
            
            -- The player is aligned vertically with the block
            if self.col.x + self.col.w - 1 > block.col.x and self.col.x < block.col.x + block.col.w - 1 then
                -- ground
                if velocity.y >= 0 and block.col.y > self.col.y + self.col.h - (self.velocity.y * 0.02) - 2 then
                    self:_grounded(block, velocity, true)
                    block.weight[self] = self
                end
            end

            -- The player is aligned horizontally with the block
            if self.col.y + self.col.h - 1 > block.col.y and self.col.y < block.col.y + block.col.h -1 then
                -- left
                if velocity.x < 0 and block.col.x < self.col.x then
                    -- Move the block
                    block:move(dt, -1)

                    if self.pushParticleTimer <= 0 then
                        --TODO: play push sound
                        for i = 1, math.random(0, 1), 1 do
                            objects.dustUp(self.position.x + 5, self.position.y - 7)
                        end
                        self.pushParticleTimer = self.PUSH_PARTICLE_RATE 
                    end

                    -- Stick to the left
                    self.position.x = block.col.x + block.col.w - self.collisionOffset.x
                    self.col.x = self.position.x + self.collisionOffset.x

                    -- Stop moving left
                    velocity.x = -0.01
                end

                -- right
                if velocity.x > 0 and block.col.x > self.col.x then
                    -- Move the block
                    block:move(dt, 1)

                    if self.pushParticleTimer <= 0 then
                        -- TODO: play push sound
                        for i = 1, math.random(0, 1), 1 do
                            objects.dustUp(self.position.x - 5, self.position.y - 7)
                        end
                        self.pushParticleTimer = self.PUSH_PARTICLE_RATE 
                    end

                    -- Stick to the right
                    self.position.x = block.col.x - self.col.w - self.collisionOffset.x
                    self.col.x = self.position.x + self.collisionOffset.x

                    -- Stop moving right
                    velocity.x = 0.01


                end
            end
        else
            block.weight[self] = nil
        end
    end

    for _, block in pairs(global.game.collisions.characters) do
        if self ~= block and self.fallThroughPlatforms[block] == nil and block.col and collision.checkRectangles(self.col, block.col) then
            if self.fallThroughTimer > 0 then
                self.fallThroughPlatforms[block] = block
                self.coyoteTimer = 0
                break
            end
            
            -- The player is aligned vertically with the block
            if self.col.x + self.col.w - 1 > block.col.x and self.col.x < block.col.x + block.col.w - 1 then
                -- ground
                if velocity.y >= 0 and block.col.y > self.col.y + self.col.h - (self.velocity.y * 0.02) - 2 then
                    self:_grounded(block, velocity, true)
                end
            end
        end
    end

    for _, block in pairs(global.game.collisions.kill) do
        if block.col and collision.checkRectangles(self.col, block.col) then
            self:lose()
        end
    end

    if self.isDuckling then
        self.airUpForce = 0
        self.airGlide = self.MAX_GLIDE_FALL_SPEED
        for _, block in pairs(global.game.collisions.air) do
            if block.col and collision.checkRectangles(self.col, block.col) then
                self.airUpForce = block.force or 0
                self.airGlide = block.glide or self.MAX_GLIDE_FALL_SPEED
            end
        end
    end

    return velocity
end

function object:handleMovement(dt)
    if not self.paused then
        --restoring original collision size
        self.col.w = self.COLLISION_SIZE.x
        self.col.h = self.COLLISION_SIZE.y

        self.velocity.x = 0
        self.velocity.y = self.velocity.y + self.GRAVITY * dt

        if self.GLIDE  then
            self.velocity.y = self.velocity.y - self.airUpForce * dt

            if self.velocity.y > self.MAX_FALL_SPEED then
                self.velocity.y = self.MAX_FALL_SPEED
            end

            if input.get 'up' then
                if self.velocity.y > 0 then
                    self.velocity.y = self.velocity.y - (self.GRAVITY - self.GLIDE_GRAVITY) * dt
                end

                if self.velocity.y > self.airGlide then
                    self.velocity.y = self.airGlide
                    -- play gliding sound, make a timer for it
                end

                if not self.isGrounded and self.velocity.y > 0 and self.glideParticleTimer <= 0 then
                    self.glideParticleTimer = self.GLIDE_PARTICLE_RATE
                    self:createDust(1)
                end
            end
        elseif self.velocity.y > self.MAX_FALL_SPEED then
            self.velocity.y = self.MAX_FALL_SPEED
        end

        if input.get 'left'  then
            self.velocity.x = self.velocity.x -self.SPEED
        end

        if input.get 'right' then
            self.velocity.x = self.velocity.x + self.SPEED
        end

        if input.get 'jump' then
            self.jumpBufferTimer = self.JUMP_BUFFER_TIME
        end

        if self.fallThroughTimer > 0 then
            self.fallThroughTimer = self.fallThroughTimer - dt
        end
        
        if input.get 'fall' then
            self.fallThroughTimer = self.FALL_THROUGH_BUFFER
        end

        if self.coyoteTimer > 0 then
            self.coyoteTimer = self.coyoteTimer - dt
            self.jumpsLeft = self.MAX_JUMPS
        elseif self.jumpsLeft == self.MAX_JUMPS then
            self.jumpsLeft = self.MAX_JUMPS - 1
        end

        

        if self.jumpBufferTimer > 0 then
            self.jumpBufferTimer = self.jumpBufferTimer - dt

            if self.jumpsLeft > 0 then
                self.jumpsLeft = self.jumpsLeft - 1
                self.jumpBufferTimer = 0
                self.coyoteTimer = 0
                self.velocity.y = -self.jumpVelocity
                if self.canCreateParticle <= 0 then
                    self:createDustUp(math.random(1, 2))
                    self.canCreateParticle = self.PARTICLE_RATE
                end
                -- TODO: play jump sound
                global.playSound('jump.wav')
            end
        end

        self.velocity = self:moveAndCollide(self.velocity, dt)
        if self.position.y > 144 then
            self:lose()
        end

        if self.particleTimer > 0 then
            self.particleTimer = self.particleTimer - dt
        end

        if self.glideParticleTimer > 0 then
            self.glideParticleTimer = self.glideParticleTimer - dt
        end

        if self.pushParticleTimer > 0 then
            self.pushParticleTimer = self.pushParticleTimer - dt
        end

        if self.canCreateParticle > 0 then
            self.canCreateParticle = self.canCreateParticle - dt
        end
        self.startDelayTimer = 0
    elseif self.startDelayTimer > 0 then
        self.velocity.y = self.velocity.y + self.GRAVITY * dt
        self.velocity = self:moveAndCollide(self.velocity, dt)
        self.startDelayTimer = self.startDelayTimer - dt
    else
        -- Making the stop collision slightly larger
        self.col.x = self.position.x + self.collisionOffset.x + self.COLLISION_PAUSED_OFFSET.x
        self.col.y = self.position.y + self.collisionOffset.y + self.COLLISION_PAUSED_OFFSET.y

        self.col.w = self.COLLISION_PAUSED_SIZE.x
        self.col.h = self.COLLISION_PAUSED_SIZE.y
    end
end


function object:handleAnimation()    
    if self.velocity.y < 0 then
        self.anim = 'jump'
    elseif self.velocity.y > 0 then
        self.anim = 'fall'
    elseif self.velocity.x ~= 0 and not self.paused then
        self.anim = 'run'
        if self.particleTimer <= 0 then
            self.particleTimer = self.PARTICLE_RATE
            self:createDust(1)
        end
    else
        self.anim = 'idle'
    end

    if self.velocity.x ~= 0 then
        self.flipped = self.velocity.x < 0
    end

    if self.anim ~= self.last_anim then
        self.sprites[self.anim]:goToFrame(1)
        self.last_anim = self.anim
    end

    if self.flipped then
        self.sprites[self.anim].scaleX = -1
        self.collisionOffset = self.COLLISION_OFFSET_FLIPPED
    else
        self.sprites[self.anim].scaleX = 1
        self.collisionOffset = self.COLLISION_OFFSET
    end

    self:setLayer(self.paused and 2 or 1)

end

function object:createDustUp(amount)
    for i = 1, amount, 1 do
        objects.dustUp(self.position.x, self.position.y - 1)
    end
end

function object:createDust(amount, x_offset, y_offset)
    x_offset = x_offset or 0
    y_offset = y_offset or -3
    for i = 1, amount, 1 do
        objects.dust(self.position.x + x_offset, self.position.y + y_offset)
    end
end

function object:lose()
    global.level:lose()
end

-- update is called once every frame
function object:update(dt)
    if not global.paused then
        if not global.dead then
            self:handleMovement(dt)
        else
            self.deathFlickerTimer = self.deathFlickerTimer + dt
            if self.deathFlickerTimer > self.DEATH_FLICKER_RATE then
                self.deathFlickerTimer = 0
                self.deathFlickerShow = not self.deathFlickerShow
            end
        end
        
    end

    self:handleAnimation()
    self.sprites[self.anim]:update(dt)
end

-- draw is called once every draw frame
function object:draw()
    if not global.dead then
        self.sprites[self.anim]:draw(self.position.x, self.position.y)
        if self.paused then
            graphics.draw(self.pausedIndicator, self.position.x + (self.flipped and -2 or -3), self.position.y - 14)
        end
    else
        if self.deathFlickerShow then
            self.sprites[self.anim]:draw(self.position.x, self.position.y)
        end
    end
    
    

    -- graphics.print("FPS: " .. tostring(timer.getFPS()), 10, 10)

    -- draw collision box
    -- graphics.setColor(1, 0, 0, 1)
    -- graphics.rectangle('fill', self.col.x, self.col.y, self.col.w, self.col.h)

    --color.white:set()
end

function object:remove()
    if self.isBunny then
        global.bunny = nil
    elseif self.isDuckling then
        global.duckling = nil
    end

    global.game.collisions.characters[self] = nil
end


return object