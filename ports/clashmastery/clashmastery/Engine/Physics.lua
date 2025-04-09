local Physics = {}

function Physics.initialize()
    Physics.all_physics_objects = {}
    Physics.num_physics_objects = 0
end

-- Input a gameobject and optionally initial velocity and acceleration
function Physics.addRigidBody(obj, initialVelocity, initialAcceleration)
    obj.RigidBody = {
        velocity = initialVelocity or {x=0, y=0, z=0},
        acceleration = initialAcceleration or {x=0, y=0, z=0},
        dragFactor = {x=1,y=1, z=1}, -- multiplier of velocity. 1 means no change
        isSolid = false,
        solidIgnoreMap = {},
        jumpingDown = false,
        jumpThroughMap = {}, -- ignores any tiles here when moving upwards or sideways. Also ignores when falling if jumping down
        solidRemainderX = 0,
        solidRemainderY = 0,
        maxVelocity = {minX=-2^30, minY=-2^30, maxX=2^30, maxY=2^30, minZ=-2^30, maxZ=2^30}
    }
    Physics.num_physics_objects = Physics.num_physics_objects + 1
    Physics.all_physics_objects[Physics.num_physics_objects] = obj
end

-- Call this in your update loop
function Physics.update(dt)
    prof.push("Physics")
    for k = 1,Physics.num_physics_objects do
        if Physics.all_physics_objects[k].active then
            Physics.updateObject(Physics.all_physics_objects[k], dt)
        end
    end
    prof.pop("Physics")
end

-- Private function, only gets called by this file
function Physics.updateObject(obj, dt)
    -- Update velocity first as per implicit euler
    -- Put drag to the power of dt / refFps to allow framerate independent drag
    obj.RigidBody.velocity.x = obj.RigidBody.velocity.x * (obj.RigidBody.dragFactor.x ^ (dt / referenceDT)) + obj.RigidBody.acceleration.x * dt
    obj.RigidBody.velocity.y = obj.RigidBody.velocity.y * (obj.RigidBody.dragFactor.y ^ (dt / referenceDT)) + obj.RigidBody.acceleration.y * dt
    obj.RigidBody.velocity.z = obj.RigidBody.velocity.z * (obj.RigidBody.dragFactor.z ^ (dt / referenceDT)) + obj.RigidBody.acceleration.z * dt

    -- Clamp velocity within the bounds it is allowed
    obj.RigidBody.velocity.x = clamp(obj.RigidBody.maxVelocity.minX, obj.RigidBody.velocity.x,  obj.RigidBody.maxVelocity.maxX)
    obj.RigidBody.velocity.y = clamp(obj.RigidBody.maxVelocity.minY, obj.RigidBody.velocity.y, obj.RigidBody.maxVelocity.maxY)
    obj.RigidBody.velocity.z = clamp(obj.RigidBody.maxVelocity.minZ, obj.RigidBody.velocity.z, obj.RigidBody.maxVelocity.maxZ)

    if obj.RigidBody.isSolid then
        -- perform solid collision with this object and the collision map
        -- Accumulate a move 'remainder' each frame until it exceeds a single unit
        obj.RigidBody.solidRemainderX = obj.RigidBody.solidRemainderX + obj.RigidBody.velocity.x * dt
        obj.RigidBody.solidRemainderY = obj.RigidBody.solidRemainderY + obj.RigidBody.velocity.y * dt
        local roundedX = roundTo(obj.RigidBody.solidRemainderX)
        local roundedY = roundTo(obj.RigidBody.solidRemainderY)
        local dX, dY = 0, 0
        if obj.RigidBody.solidRemainderX ~= 0 then
            dX = obj.RigidBody.solidRemainderX > 0 and 1 or -1
        end
        if obj.RigidBody.solidRemainderY ~= 0 then
            dY = obj.RigidBody.solidRemainderY > 0 and 1 or -1
        end

        -- Get the bounds of the collider. If it's a circle, still treat it as if it's a rectangle
        local width, height = 0, 0
        if obj.Collider.type == Collision.Types.BOX then
            width = obj.Collider.width
            height = obj.Collider.height
        else
            width = obj.Collider.radius*2
            height = obj.Collider.radius*2
        end

        -- Go one pixel at a time and figure out if we've collided with anything
        -- X Direction
        -- If the movement exceeds a single unit, then we can start moving
        if roundedX ~= 0 then
            obj.RigidBody.solidRemainderX = obj.RigidBody.solidRemainderX - roundedX
        end
        while roundedX ~= 0 do
            -- Move one unit at a time and figure out if we collided with any solids
            local sideDown = Collision.getMapPos(obj.x + dX * width/2, obj.y + height/2-1)
            local sideUp = Collision.getMapPos(obj.x + dX * width/2, obj.y - height/2+1)
            if Collision.Solids.SolidMap[sideDown] and not obj.RigidBody.solidIgnoreMap[Collision.Solids.SolidContent[sideDown]]
                and not obj.RigidBody.jumpThroughMap[Collision.Solids.SolidContent[sideDown]] then -- pass through all "jump through" platforms
                obj.Collider.onSolidCollision(obj, dX, 0, sideDown)
                obj.RigidBody.solidRemainderX = 0
                break
            elseif Collision.Solids.SolidMap[sideUp] and not obj.RigidBody.solidIgnoreMap[Collision.Solids.SolidContent[sideUp]]
                and not obj.RigidBody.jumpThroughMap[Collision.Solids.SolidContent[sideUp]] then -- pass through all "jump through" platforms
                obj.Collider.onSolidCollision(obj, dX, 0, sideUp)
                obj.RigidBody.solidRemainderX = 0
                break
            else
                obj.x = obj.x + dX
                roundedX = roundedX - dX
            end
        end
        -- Repeat for Y
        if roundedY ~= 0 then
            obj.RigidBody.solidRemainderY = obj.RigidBody.solidRemainderY - roundedY
        end
        while roundedY ~= 0 do
            local vertRight = Collision.getMapPos(obj.x + width/2-1, obj.y + dY * height/2)
            local vertLeft = Collision.getMapPos(obj.x - width/2+1, obj.y + dY * height/2)
            local fallingAndNotJumpingDown = dY > 0 and not obj.RigidBody.jumpingDown
            if Collision.Solids.SolidMap[vertRight] and not obj.RigidBody.solidIgnoreMap[Collision.Solids.SolidContent[vertRight]]
                and (fallingAndNotJumpingDown or not obj.RigidBody.jumpThroughMap[Collision.Solids.SolidContent[vertRight]]) then
                obj.Collider.onSolidCollision(obj, 0, dY, vertRight)
                obj.RigidBody.solidRemainderY = 0
                break
            elseif Collision.Solids.SolidMap[vertLeft] and not obj.RigidBody.solidIgnoreMap[Collision.Solids.SolidContent[vertLeft]]
                and (fallingAndNotJumpingDown or not obj.RigidBody.jumpThroughMap[Collision.Solids.SolidContent[vertLeft]]) then
                obj.Collider.onSolidCollision(obj, 0, dY, vertLeft)
                obj.RigidBody.solidRemainderY = 0
                break
            else
                obj.y = obj.y + dY
                roundedY = roundedY - dY
            end
        end
    else
        obj.x = obj.x + obj.RigidBody.velocity.x * dt
        obj.y = obj.y + obj.RigidBody.velocity.y * dt
        obj.z = obj.z + obj.RigidBody.velocity.z * dt
    end
end

function Physics.zeroVelocity(obj)
    obj.RigidBody.velocity.x, obj.RigidBody.velocity.y, obj.RigidBody.velocity.z = 0, 0, 0
end

function Physics.zeroAcceleration(obj)
    obj.RigidBody.acceleration.x, obj.RigidBody.acceleration.y, obj.RigidBody.acceleration.z = 0, 0, 0
end

function Physics.setVelocity(obj, x,y,z)
    obj.RigidBody.velocity.x, obj.RigidBody.velocity.y, obj.RigidBody.velocity.z = x,y,z
end

-- use 0 based indexing from the Tiled editor to populate the ignoreMap.
-- we increment cause lua
function Physics.setSolidIgnoreMap(obj, ignoreMap)
    for k = 1,#ignoreMap do
        obj.RigidBody.solidIgnoreMap[ignoreMap[k]+1] = true
    end
end

-- use 0 based indexing from the Tiled editor to populate the jumpThroughMap.
-- we increment cause lua
function Physics.setJumpThroughMap(obj, jumpThroughMap)
    for k = 1,#jumpThroughMap do
        obj.RigidBody.jumpThroughMap[jumpThroughMap[k]+1] = true
    end
end

return Physics