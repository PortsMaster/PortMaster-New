local Collision = {}

Collision.Layers = {
    PLAYER = 1,
    FLOOR = 2,
    TRIGGER = 3
}

Collision.Types = {
    CIRCLE = 1,
    BOX = 2
}

function Collision.initialize()
    Collision.all_collider_objects = {}
    Collision.num_collider_objects = 0
    Collision.Map = {}
end

function Collision.addCircleCollider(obj, radius, layer, layersToCollide)
    obj.Collider = {
        type = Collision.Types.CIRCLE,
        radius = radius,
        layer = layer,
        layersToCollide = layersToCollide,
        onCollision = function(thisObj, otherObj) print("oncollision not implemented") end,
        onCollisionExit = function(thisObj, otherObj) end,
        onCollisionEnter = function(thisObj, otherObj) end,
        static = #layersToCollide == 0
    }
    Collision.num_collider_objects = Collision.num_collider_objects + 1
    Collision.all_collider_objects[Collision.num_collider_objects] = obj
    Collision.Map[obj.id] = {}
end

function Collision.addBoxCollider(obj, width, height, layer, layersToCollide)
    obj.Collider = {
        type = Collision.Types.BOX,
        width = width,
        height = height,
        layer = layer,
        layersToCollide = layersToCollide,
        onCollision = function(thisObj, otherObj) print("oncollision not implemented") end,
        onCollisionExit = function(thisObj, otherObj) end,
        onCollisionEnter = function(thisObj, otherObj) end,
        static = #layersToCollide == 0
    }
    Collision.num_collider_objects = Collision.num_collider_objects + 1
    Collision.all_collider_objects[Collision.num_collider_objects] = obj
    Collision.Map[obj.id] = {}
end

-- Call this in your 'update' function
function Collision.update()
    for k = 1,Collision.num_collider_objects do
        local obj = Collision.all_collider_objects[k]
        if obj.active and not obj.Collider.static then
            -- Iterate over all objects that don't match this object
            -- if the layer matches, do collision
            for j = 1,Collision.num_collider_objects do
                -- Ensure the object can't collide with itself
                if j ~= k then
                    -- Check if the object's layer matches the desired layer
                    local obj2 = Collision.all_collider_objects[j]
                    if obj2.active then
                        if Collision.layerIsToBeCollidedWith(obj2.Collider.layer, obj.Collider.layersToCollide) then
                            -- Layer matches, do collision
                            -- Circle-circle collision
                            local col
                            if obj.Collider.type == Collision.Types.CIRCLE and obj2.Collider.type == Collision.Types.CIRCLE then
                                col = Collision.circleCollision(obj, obj2)
                            end
    
                            -- Circle-box collision
                            if obj.Collider.type == Collision.Types.CIRCLE and obj2.Collider.type == Collision.Types.BOX then
                                col = Collision.circleBoxCollision(obj, obj2)
                            end

                            -- Box-circle collision
                            if obj.Collider.type == Collision.Types.BOX and obj2.Collider.type == Collision.Types.CIRCLE then
                                col = Collision.circleBoxCollision(obj2, obj)
                            end

                            -- Box-box collision
                            if obj.Collider.type == Collision.Types.BOX and obj2.Collider.type == Collision.Types.BOX then
                                col = Collision.boxBoxCollision(obj, obj2)
                            end

                            -- Trigger onCollisionExit if necessary
                            if col and not Collision.Map[obj.id][obj2] then
                                -- We just entered a collision, trigger onCollisionEnter
                                obj.Collider.onCollisionEnter(obj, obj2)
                            elseif not col and Collision.Map[obj.id][obj2] then
                                -- We just exited the collision. Trigger onCollisionExit
                                obj.Collider.onCollisionExit(obj, obj2)
                            end
                            Collision.Map[obj.id][obj2] = col
                        end
                    else
                        -- Still need to emit collision exits with objects that just went inactive
                        if Collision.Map[obj.id][obj2] then
                            obj.Collider.onCollisionExit(obj, obj2)
                            Collision.Map[obj.id][obj2] = false
                        end
                    end
                end
            end
        end
    end
end

function Collision.circleCollision(thisObj, otherObj)
    local sqDist = (thisObj.x - otherObj.x) ^ 2 + (thisObj.y - otherObj.y) ^ 2
    local sqRad = (thisObj.Collider.radius + otherObj.Collider.radius) ^ 2
    if sqDist < sqRad then
        thisObj.Collider.onCollision(thisObj, otherObj)
        return true
    end
    return false
end

function Collision.circleBoxCollision(circleObj, boxObj)
    -- Get the point on the box closest to the circle's center
    -- box is defined as x1y1 top left, x2y2 bottom right
    local boxX1 = boxObj.x - boxObj.Collider.width / 2
    local boxY1 = boxObj.y - boxObj.Collider.height / 2

    local boxX2 = boxObj.x + boxObj.Collider.width / 2
    local boxY2 = boxObj.y + boxObj.Collider.height / 2

    local xClosest = math.max(boxX1, math.min(circleObj.x, boxX2))
    local yClosest = math.max(boxY1, math.min(circleObj.y, boxY2))

    -- Get distance between closest point on box and circle center
    local sqDist = (circleObj.x - xClosest) ^ 2 + (circleObj.y - yClosest) ^ 2
    local sqRad = circleObj.Collider.radius ^ 2
    if sqDist <  sqRad then
        circleObj.Collider.onCollision(circleObj, boxObj)
        return true
    end
    return false
end

function Collision.boxBoxCollision(box1Obj, box2Obj)
    local box1X1 = box1Obj.x - box1Obj.Collider.width / 2
    local box1Y1 = box1Obj.y - box1Obj.Collider.height / 2
    local box1X2 = box1Obj.x + box1Obj.Collider.width / 2
    local box1Y2 = box1Obj.y + box1Obj.Collider.height / 2

    local box2X1 = box2Obj.x - box2Obj.Collider.width / 2
    local box2Y1 = box2Obj.y - box2Obj.Collider.height / 2
    local box2X2 = box2Obj.x + box2Obj.Collider.width / 2
    local box2Y2 = box2Obj.y + box2Obj.Collider.height / 2

    if box1X1 < box2X2 and box1X2 > box2X1 and box1Y2 > box2Y1 and box1Y1 < box2Y2 then
        box1Obj.Collider.onCollision(box1Obj, box2Obj)
        return true
    end

    return false
end

function Collision.layerIsToBeCollidedWith(layer, layersToCollide)
    for index,value in ipairs(layersToCollide) do
        if layer == value then
            return true
        end
    end
    return false
end

function Collision.debugDraw()
    for k = 1,Collision.num_collider_objects do
        local obj = Collision.all_collider_objects[k]
        if obj.active then
            love.graphics.setColor(0, 255, 0, 255)
            if obj.Collider.type == Collision.Types.CIRCLE then
                love.graphics.circle('line', obj.x, obj.y, obj.Collider.radius)
            elseif obj.Collider.type == Collision.Types.BOX then
                love.graphics.rectangle('line',
                math.floor(obj.x - obj.Collider.width / 2),
                math.floor(obj.y - obj.Collider.height / 2),
                obj.Collider.width, obj.Collider.height)
            end 
        end
    end
end

return Collision