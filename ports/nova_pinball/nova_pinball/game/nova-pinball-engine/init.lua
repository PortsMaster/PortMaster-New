-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Nova pinball engine
-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

local pinball = { }

pinball.cfg = {

    -- Constants to convert between degrees and radius
    DEGTORAD = 0.0174532925199432957,
    RADTODEG = 57.295779513082320876,

    -- The keyboard keys that controls the flippers
    leftKey = "lshift",
    rightKey = "rshift",

    -- The camera follows the ball and the game is drawn at scale 1.
    -- If there are multiple balls in play, then the lowest ball is
    -- followed. If this setting is disabled then the entire table
    -- is scaled down to fit the window.
    cameraFollowsBall = true,

    -- Used internally to track the camera's position.
    cameraY = nil,

    translateOffset = {x=0, y=0},

    -- Offset the camera so balls appear in the center of the window
    cameraOffset = love.graphics.getHeight() / 2,
    cameraBorder = love.graphics.getHeight() / 2.5,

    drawScale = 1,

    -- Normal earth gravity is 9.81, but since we are
    -- simulating the ball on a sloped surface we create
    -- faux drag with increased gravity.
    gravity = 12,
    pixelsPerMeter = 64,

    -- Ball speeds can accumulate pretty steep with a lot of kickers
    -- and bumpers in play. We limit these for reasonable play.
    bumperForces = { min = 1, max = 4 },
    ballVelocity = { min = -1000, max = 1000 },
    ballRadius = 15,

    -- time to wait before a ball triggers tag contacts
    ballCooldown = 0.1,
    
    newBallOnUpdate = false,
    
    }

pinball.table = { }
pinball.bodies = { }

-- Call this on window resize to recalculate positions
function pinball:resize(w, h)
    self.cfg.cameraOffset = h / 2
    if (self.table) then self.cfg.drawScale = h / self.table.size.height end
end

function pinball:moveLeftFlippers()
    for _, flip in pairs(self.bodies.flippers) do
        if (flip.orientation == "left") then
            flip.torque = -2000000
        end
    end
end

function pinball:releaseLeftFlippers()
    for _, flip in pairs(self.bodies.flippers) do
        if (flip.orientation == "left") then
            flip.body:applyTorque(2000000)
            flip.torque = nil
        end
    end
end

function pinball:moveRightFlippers()
    for _, flip in pairs(self.bodies.flippers) do
        if (flip.orientation == "right") then
            flip.torque = 2000000
        end
    end
end

function pinball:releaseRightFlippers()
    for _, flip in pairs(self.bodies.flippers) do
        if (flip.orientation == "right") then
            flip.body:applyTorque(-2000000)
            flip.torque = nil
        end
    end
end

function pinball:nudge(minx, maxx, miny, maxy)
    for _, ball in ipairs(self.bodies.balls) do
        local rx = math.random(minx, maxx)
        local ry = math.random(miny, maxy)
        ball.body:applyLinearImpulse(rx, ry)
    end
end

-- Update the pinball simulation
function pinball:update (dt)

    -- Create a new ball on the table at the configured position in the table definition.
    if (self.cfg.newBallOnUpdate) then
        self.cfg.newBallOnUpdate = false
        self:createBall(self.table.ball.x, self.table.ball.y)
    end

    -- Process each ball in play
    for i, ball in ipairs(self.bodies.balls) do

        -- Limit ball velocity
        local xvel, yvel = ball.body:getLinearVelocity()
        xvel = self.clamp(pinball.cfg.ballVelocity.min, xvel, pinball.cfg.ballVelocity.max)
        yvel = self.clamp(pinball.cfg.ballVelocity.min, yvel, pinball.cfg.ballVelocity.max)
        ball.body:setLinearVelocity(xvel, yvel)

        local ballData = ball.body:getUserData() or {}
        
        -- Destroy balls marked for destruction
        if (ballData.action == "destroy") then
            ball.body:destroy()
            table.remove(self.bodies.balls, i)
            if self.ballDrained then self.ballDrained(#self.bodies.balls) end
        else

            -- Lock ball from moving
            if (ballData.action == "lock") then
                ball.body:setPosition(ballData.x, ballData.y)
                ballData.action = "frozen"
                ball.body:setActive(false)
            end

            -- Time frozen balls
            if (ballData.action == "frozen") then
                ballData.delay = ballData.delay - dt
                if (ballData.delay < 0) then
                    -- Unfreeze
                    ballData.action = "release"
                end
            end

            -- UnLock ball
            if (ballData.action == "release") then
                print("releasing ball with velocities", ballData.xvel, ballData.yvel)
                ball.data.cooldown = pinball.cfg.ballCooldown
                ball.body:setLinearVelocity(ballData.xvel, ballData.yvel)
                ball.body:setUserData(nil)
                ball.body:setActive(true)
                -- Fire callback
                if pinball.ballUnlocked then pinball.ballUnlocked(ballData.id) end
            end

            -- Update ball cooldown (this limits triggering tagged objects)
            if (ball.data.cooldown >= 0) then
                ball.data.cooldown = ball.data.cooldown - dt
            end
        end     -- Ball processing
    end

    -- Handle flipper interaction
    for _, flip in pairs(self.bodies.flippers) do
        if (flip.torque) then
            flip.body:applyTorque(flip.torque)
        end
    end
    
    -- Update the physics world
    self.world:update(dt)

end

-- Call this to draw the pinball table to the display.
-- The camera auto tracks ball movement (unless disabled in the cfg above)
function pinball:draw ()

    if (not self.bodies) then return end

    -- drawWall (points)
    if (self.drawWall) then
        for i, wall in pairs(self.bodies.walls) do
            self.drawWall({wall.body:getWorldPoints(wall.shape:getPoints())})
        end
    end

    -- drawBumper (tag, x, y, radius)
    if (self.drawBumper) then
        for i, bump in pairs(self.bodies.bumpers) do
            self.drawBumper(bump.data.tag, bump.body:getX(), bump.body:getY(), bump.shape:getRadius())
        end
    end

    -- drawKicker (tag, points)
    if (self.drawKicker) then
        for i, kick in pairs(self.bodies.kickers) do
            self.drawKicker(kick.data.tag, kick.body:getX(), kick.body:getY(), {kick.body:getWorldPoints(kick.shape:getPoints())})
        end
    end
    
    -- drawTrigger (tag, points)
    if (self.drawTrigger) then
        for i, obj in pairs(self.bodies.triggers) do
            self.drawTrigger(obj.data.tag, {obj.body:getWorldPoints(obj.shape:getPoints())})
        end
    end
    
    -- drawFlipper (points)
    if (self.drawFlipper) then
        for i, flip in pairs(self.bodies.flippers) do
            local position = {x=flip.body:getX(), y=flip.body:getY()}
            local points = {flip.body:getWorldPoints(flip.shape:getPoints())}
            self.drawFlipper(flip.orientation, position, flip.body:getAngle(), flip.origin, points)
        end
    end

    -- drawBall (x, y, radius)
    if (self.drawBall) then
        for k, ball in pairs(self.bodies.balls) do
            self.drawBall(ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
        end
    end

end

function pinball:setCamera ()

    if (self.cfg.cameraFollowsBall) then

        if (#self.bodies.balls > 0) then

            -- Find the position of the lowest ball
            table.sort(self.bodies.balls, function(a, b) return b.body:getY() < a.body:getY() end)
            local lowestY = self.bodies.balls[1].body:getY()
            
            -- Clamp the position to sane limits.
            -- This keeps the view static when near the top or bottom.
            lowestY = self.clamp(self.table.size.y1+self.cfg.cameraBorder, lowestY, self.table.size.y2-self.cfg.cameraBorder)

            -- Offset the lowest point with the camera's (precalculated) offset.
            -- This moves the camera focus to the middle of the window, and not the top.
            local targetY = - lowestY + self.cfg.cameraOffset

            -- Instead of setting the camera to it's intended position
            -- in one step, we ease it in, giving a smooth motion.
            -- This also eliminates "screen bounce" for rapidly bouncing balls.
            if (not self.cfg.cameraY) then
                self.cfg.cameraY = targetY
            else
                self.cfg.cameraY = self.cfg.cameraY + (targetY - self.cfg.cameraY) * 0.1
            end

        end

        -- Apply the translation
        love.graphics.translate(0, (self.cfg.cameraY or 0) + self.cfg.translateOffset.y)

    else
    
        -- Show the full table
        love.graphics.scale(self.cfg.drawScale, self.cfg.drawScale)

    end

end

-- Reset the graphics translation and scale
function pinball:resetCamera ()
    self.cfg.cameraY = 0
end

-- Load a pinball table layout from a definition table.
function pinball:loadTable (pinballTableDefinition)

    self.table = pinballTableDefinition
    self.cfg.drawScale = love.graphics.getHeight() / self.table.size.height

    -- Destroy existing physics objects
    if (self.bodies.all) then
        for k, v in pairs(self.bodies.all) do
            if (v.fixture) then v.fixture:destroy() end
            if (v.body) then v.body:destroy() end
        end
    end

    self.bodies = {
        all = { },
        balls = { },
        walls = { },
        bumpers = { },
        kickers = { },
        flippers = { },
        triggers = { }
        }

    -- Anchor flippers to this static body
    local anchorBody = love.physics.newBody(self.world, 0, 0)
    table.insert(self.bodies.all, anchorBody)

    -- Create each component
    for k, v in pairs(self.table.components) do

        if (v.type == "wall") then
            self:createWall(v)
        end

        if (v.type == "bumper") then
            self:createBumper(v)
        end

        if (v.type == "kicker") then
            self:createKicker(v)
        end

        if (v.type == "trigger") then
            self:createTrigger(v)
        end
    
        if (v.type == "indicator") then
            self:createTrigger(v)
        end
    
        if (v.type == "gate") then
            self:createGate(v)
        end
    
        if (v.type == "flipper") then
            self:createFlipper(v, anchorBody)
        end

    end
    
    -- The Drain catches lost balls
    self:createDrainChain()
    
end

function pinball:createWall (def)
    local worldPoints = pinball.translatePoints(def.x, def.y, def.vertices)
    local shell = { }
    shell.data = def
    shell.body = love.physics.newBody(self.world, 0, 0)
    shell.shape = love.physics.newChainShape(false, unpack(worldPoints))
    shell.fixture = love.physics.newFixture(shell.body, shell.shape)
    shell.fixture:setRestitution(0.4)
    shell.fixture:setUserData(shell.data)
    table.insert(self.bodies.all, shell)
    table.insert(self.bodies.walls, shell)
end

function pinball:createBumper (def)
    local kickforce = def.r / 10
    local bump = { }
    bump.data = def
    bump.body = love.physics.newBody(self.world, def.x, def.y, "kinematic")
    bump.shape = love.physics.newCircleShape(def.r)
    bump.fixture = love.physics.newFixture(bump.body, bump.shape, 1)
    bump.fixture:setUserData(bump.data)
    kickforce = self.clamp(self.cfg.bumperForces, kickforce)
    bump.fixture:setRestitution(kickforce)
    table.insert(self.bodies.all, bump)
    table.insert(self.bodies.bumpers, bump)
end

function pinball:createTrigger (def)
    local obj = { }
    obj.data = def
    obj.body = love.physics.newBody(self.world, def.x, def.y, "static")
    obj.shape = love.physics.newChainShape(false, unpack(def.vertices))
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 0)
    obj.fixture:setSensor(true)
    obj.fixture:setUserData(obj.data)
    table.insert(self.bodies.all, obj)
    table.insert(self.bodies.triggers, obj)
end

function pinball:createGate (def)
    local obj = { }
    obj.data = def
    obj.body = love.physics.newBody(self.world, def.x, def.y, "static")
    obj.shape = love.physics.newChainShape(false, unpack(def.vertices))
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 0)
    obj.fixture:setRestitution(0.25)
    obj.fixture:setUserData(obj.data)
    table.insert(self.bodies.all, obj)
    table.insert(self.bodies.triggers, obj)
end

function pinball:createKicker (def)
    local kickforce = 4
    local kick = { }
    kick.data = def
    kick.body = love.physics.newBody(self.world, def.x, def.y, "kinematic")
    kick.shape = love.physics.newChainShape(false, unpack(def.vertices))
    kick.fixture = love.physics.newFixture(kick.body, kick.shape, 0)
    kick.fixture:setUserData(kick.data)
    kick.fixture:setRestitution(kickforce)
    table.insert(self.bodies.all, kick)
    table.insert(self.bodies.kickers, kick)
end

function pinball:createDrainChain ()
    -- Construct a large "chain" around the table, if the ball
    -- leaves at any point, it is considered a "drain".
    
    local x1, y1 = self.table.size.x1, self.table.size.y1
    local x2, y2 = self.table.size.x2, self.table.size.y2
    local border = 100
    x1, y1 = x1-border, y1-border
    x2, y2 = x2+border, y2+border+border
    local vertices = {
        x1, y1,       -- top left
        x2, y1,     -- top right
        x2, y2,   -- bot right
        x1, y2      -- bot left
        }
    
    local drain = { }
    drain.body = love.physics.newBody(self.world, 0, 0, "kinematic")
    drain.shape = love.physics.newChainShape(true, unpack(vertices))
    drain.fixture = love.physics.newFixture(drain.body, drain.shape, 0)
    drain.fixture:setSensor(true)
    drain.fixture:setUserData({ type = "drain" })
    table.insert(self.bodies.all, drain)
end

function pinball:newBall ()
    self.cfg.newBallOnUpdate = true
end

-- Lock a ball in place for n seconds, after which release with velocities x/y
function pinball:lockBall (id, x, y, delay, xvel, yvel)
    for _, ball in pairs(self.bodies.balls) do
        if (ball.data.id == id) then
            ball.body:setUserData({action="lock", x=x, y=y, xvel=xvel, yvel=yvel, delay=delay})
            if pinball.ballLocked then pinball.ballLocked(id) end
            return
        end
    end
end

--function pinball:releaseBall (id, xvel, yvel)
    --for _, ball in pairs(self.bodies.balls) do
        --if (ball.data.id == id) then
            --ball.data.cooldown = pinball.cfg.ballCooldown
            --ball.body:setLinearVelocity(xvel, yvel)
            --ball.body:setUserData({action="release"})
        --end
    --end
--end

function pinball:getObjectXY (tag)
    for _, c in pairs(self.bodies.all) do
        local data = c.fixture and c.fixture:getUserData() or {}
        if (data.tag == tag) then
            return data.x, data.y
        end
    end
end

function pinball:createBall (x, y)
    local ball = { }
    ball.data = {
        type="ball",
        id=string.format("%x", os.time()),
        cooldown=0
        }
    ball.body = love.physics.newBody(self.world, x, y, "dynamic")
    ball.body:setBullet(true)  -- Force high quality collision detection at performance cost
    ball.shape = love.physics.newCircleShape(pinball.cfg.ballRadius)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setUserData(ball.data)
    --ball.fixture:setRestitution(0.1)
    --table.insert(self.bodies.all, ball)
    table.insert(self.bodies.balls, ball)
end

-- Create a flipper that is controlled by the player.
-- The orientation can be "left" or "right".
function pinball:createFlipper (def, anchorBody)
    local flip = { }
    flip.data = def
    flip.body = love.physics.newBody(self.world, def.x, def.y, "dynamic")
    --flip.body:setGravityScale(0)
    flip.shape = love.physics.newPolygonShape(unpack(def.vertices))
    flip.fixture = love.physics.newFixture(flip.body, flip.shape, 1.5)    -- mass
    flip.fixture:setRestitution(0)
    flip.fixture:setUserData(flip.data)
    -- Revolute Joint + Motor
    flip.joint = love.physics.newRevoluteJoint(anchorBody, flip.body, def.x + def.pivot.x, def.y + def.pivot.y, false)
    --flip.joint:setMotorSpeed(200)
    --flip.joint:setMotorEnabled(true)
    -- Limit movement
    local limitA = def.orientation == "left" and 5 or 30
    local limitB = def.orientation == "right" and 5 or 30
    flip.joint:setLimits(-limitA*self.cfg.DEGTORAD, limitB*self.cfg.DEGTORAD)
    flip.joint:setLimitsEnabled(true)
    flip.orientation = def.orientation
    flip.pivot = def.pivot
    local polyW, polyH = pinball.getPolySize(def.vertices)
    flip.origin = {x=polyW/2, y=polyH/2}
    table.insert(self.bodies.all, flip)
    table.insert(self.bodies.flippers, flip)
end

-- Separate balls from solids.
-- Returns [ball body], [ball definition], [solid body], [solid definition]
function pinball.separateSolids (a, b)
	local aa=a:getUserData() or { }
	local bb=b:getUserData() or { }
    if (aa.type == "ball") then
        return a:getBody(), aa, b:getBody(), bb
    elseif (bb.type == "ball") then
        return b:getBody(), bb, a:getBody(), aa
    end
end

-- Filter which objects collide with each other.
function pinball.contactFilter (a, b)
    local ball, ballDef, solid, solidDef = pinball.separateSolids(a, b)
    
    -- Not a ball collision.
    if (not ball) then
        return true
    end

    -- Gates restrict the ball movement from certain directions
    if (solidDef.type == "gate") then
        local xvel, yvel = ball:getLinearVelocity()
        if (solidDef.action == "left" and xvel < 0) then return false end
        if (solidDef.action == "right" and xvel > 0) then return false end
    end

    return true
end

function pinball.beginContact (a, b, c)
    local ball, ballDef, solid, solidDef = pinball.separateSolids(a, b)
    
    -- Not a ball collision.
    if (not ball) then
        return true
    end

    -- Tagged collisions
    if (solidDef.tag and pinball.tagContact) then
        local isActive = ball:isActive()
        local isCool = ballDef.cooldown < 0
        if (isActive and isCool) then
            ballDef.cooldown = solidDef.cooldown and tonumber(solidDef.cooldown) or pinball.cfg.ballCooldown
            pinball.tagContact(solidDef.tag, ballDef.id)
        end
    end

    -- Triggers
    if (solidDef.type == "trigger") then
        if (solidDef.action == "slingshot") then
            ball:setLinearVelocity(0, -1000)
        end
    end

    -- Ball drained
    if (solidDef.type == "drain") then
        ball:setUserData({action="destroy"})
    end
end

-- Limit value to a range of min and max
function pinball.clamp(min, value, max)
    if (type(min) == "table") then
        max = min.max
        min = min.min
    end
    return math.max(min, math.min(max, value))
end

-- gets the bounding box size of a poly
function pinball.getPolySize (vertices)
    local minx, maxx, miny, maxy = vertices[1], vertices[1], vertices[2], vertices[2]
    for i = 1, #vertices - 1, 2 do
        minx = math.min(minx, vertices[i])
        maxx = math.max(maxx, vertices[i])
        miny = math.min(miny, vertices[i+1])
        maxy = math.max(maxy, vertices[i+1])
    end
    -- Ensure at least n size so the object can be clicked
    return maxx-minx, maxy-miny
end

-- translate relative vertice positions to screen coordinates
function pinball.translatePoints (x, y, vertices)
    local mx = { }
    for i = 1, #vertices - 1, 2 do
        table.insert(mx, vertices[i] + x)
        table.insert(mx, vertices[i+1] + y)
    end
    return mx
end

function pinball:setupPhysics ()
    local allowSleeping = true
    love.physics.setMeter(self.cfg.pixelsPerMeter)
    self.world = love.physics.newWorld(0, self.cfg.gravity * self.cfg.pixelsPerMeter, allowSleeping)
    self.world:setCallbacks(self.beginContact)
    self.world:setContactFilter(self.contactFilter)
end

function pinball:setGravity(g)
    local n = g * self.cfg.pixelsPerMeter
    self.world:setGravity(0, n)
end

function pinball:restoreGravity()
    local n = self.cfg.gravity * self.cfg.pixelsPerMeter
    self.world:setGravity(0, n)
end

function pinball:setBallDampening(value)
    for _, ball in pairs(self.bodies.balls) do
        ball.body:setLinearDamping(value)
    end
end

pinball:setupPhysics()
return pinball
