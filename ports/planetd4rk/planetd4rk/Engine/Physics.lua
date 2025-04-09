local Physics = {}

function Physics.initialize()
    Physics.all_physics_objects = {}
    Physics.num_physics_objects = 0
end

-- Input a gameobject and optionally initial velocity and acceleration
function Physics.addRigidBody(obj, initialVelocity, initialAcceleration)
    obj.RigidBody = {
        velocity = initialVelocity or {x=0, y=0},
        acceleration = initialAcceleration or {x=0, y=0},
        dragFactor = {x=1,y=1} -- multiplier of velocity. 1 means no change
    }
    Physics.num_physics_objects = Physics.num_physics_objects + 1
    Physics.all_physics_objects[Physics.num_physics_objects] = obj
end

-- Call this in your update loop
function Physics.update(dt)
    for k = 1,Physics.num_physics_objects do
        if Physics.all_physics_objects[k].active then
            Physics.updateObject(Physics.all_physics_objects[k], dt)
        end
    end
end

-- Private function, only gets called by this file
function Physics.updateObject(obj, dt)
    -- Update velocity first as per implicit euler
    -- Put drag to the power of dt / refFps to allow framerate independent drag
    obj.RigidBody.velocity.x = obj.RigidBody.velocity.x * (obj.RigidBody.dragFactor.x ^ (dt / referenceDT)) + obj.RigidBody.acceleration.x * dt
    obj.RigidBody.velocity.y = obj.RigidBody.velocity.y * (obj.RigidBody.dragFactor.y ^ (dt / referenceDT)) + obj.RigidBody.acceleration.y * dt
    
    obj.x = obj.x + obj.RigidBody.velocity.x * dt
    obj.y = obj.y + obj.RigidBody.velocity.y * dt
end

return Physics