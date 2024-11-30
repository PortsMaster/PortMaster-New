local Collision = {}

Collision.Layers = {
    -- This needs to be defined in MainConfig.lua
}

Collision.Types = {
    CIRCLE = 1,
    BOX = 2,
    SPHERE = 3
}

function Collision.initialize()
    Collision.all_collider_objects = {}
    Collision.num_collider_objects = 0
    Collision.Map = {}
    Collision.Solids = {
        SolidMap = {},
        SolidContent = {},
        Width = 0
    }
    Collision.MappedLayers = {}
    for k,v in pairs(Collision.Layers) do
        Collision.MappedLayers[v] = {}
    end
    Collision.debugShaderColor = {0,1,0,0.35}
end

function Collision.addCircleCollider(obj, radius, layer, layersToCollide)
    obj.Collider = {
        type = Collision.Types.CIRCLE,
        radius = radius,
        layer = layer,
        layersToCollide = layersToCollide,
        onCollision = function(thisObj, otherObj) end,
        onCollisionExit = function(thisObj, otherObj) end,
        onCollisionEnter = function(thisObj, otherObj) end,
        onSolidCollision = function(thisObj, dX, dY, tileInd) end,
        static = #layersToCollide == 0
    }
    Collision.num_collider_objects = Collision.num_collider_objects + 1
    Collision.all_collider_objects[Collision.num_collider_objects] = obj
    Collision.Map[obj.id] = {}
    table.insert(Collision.MappedLayers[layer], obj)
end

function Collision.addSphereCollider(obj, radius, layer, layersToCollide)
    obj.Collider = {
        type = Collision.Types.SPHERE,
        radius = radius,
        layer = layer,
        layersToCollide = layersToCollide,
        onCollision = function(thisObj, otherObj) end,
        onCollisionExit = function(thisObj, otherObj) end,
        onCollisionEnter = function(thisObj, otherObj) end,
        onSolidCollision = function(thisObj, dX, dY, tileInd) end,
        static = #layersToCollide == 0
    }
    Collision.num_collider_objects = Collision.num_collider_objects + 1
    Collision.all_collider_objects[Collision.num_collider_objects] = obj
    Collision.Map[obj.id] = {}
    table.insert(Collision.MappedLayers[layer], obj)
end

function Collision.addBoxCollider(obj, width, height, layer, layersToCollide)
    obj.Collider = {
        type = Collision.Types.BOX,
        width = width,
        height = height,
        layer = layer,
        layersToCollide = layersToCollide,
        onCollision = function(thisObj, otherObj) end,
        onCollisionExit = function(thisObj, otherObj) end,
        onCollisionEnter = function(thisObj, otherObj) end,
        static = #layersToCollide == 0
    }
    Collision.num_collider_objects = Collision.num_collider_objects + 1
    Collision.all_collider_objects[Collision.num_collider_objects] = obj
    Collision.Map[obj.id] = {}
    table.insert(Collision.MappedLayers[layer], obj)
end

-- Call this in your 'update' function
function Collision.update()
    prof.push("Collision")
    for k = 1,Collision.num_collider_objects do
        local obj = Collision.all_collider_objects[k]
        if obj.active and not obj.Collider.static then
            -- Iterate over all objects in each collision layer for this object
            local allLayersToCollide = obj.Collider.layersToCollide
            for k2 = 1,#allLayersToCollide do
                for j = 1,#Collision.MappedLayers[allLayersToCollide[k2]] do
                    local obj2 = Collision.MappedLayers[allLayersToCollide[k2]][j]
                    if obj2.active then
                        -- Circle-circle collision
                        local col
                        if obj.Collider.type == Collision.Types.CIRCLE and obj2.Collider.type == Collision.Types.CIRCLE then
                            col = Collision.circleCollision(obj, obj2)
                        end

                        if obj.Collider.type == Collision.Types.SPHERE and obj2.Collider.type == Collision.Types.SPHERE then
                            col = Collision.sphereCollision(obj, obj2)
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
    prof.pop("Collision")
end

function Collision.sphereCollision(thisObj, otherObj)
    local sqDist = (thisObj.x - otherObj.x) ^ 2 + (thisObj.y - otherObj.y) ^ 2 + (thisObj.z - otherObj.z) ^ 2
    local sqRad = (thisObj.Collider.radius + otherObj.Collider.radius) ^ 2
    if sqDist < sqRad then
        thisObj.Collider.onCollision(thisObj, otherObj)
        return true
    end
    return false
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

function Collision.debugShaderFunc(shader)
    shader:send("solidColor", Collision.debugShaderColor)
end

function Collision.debugDraw()
    for k = 1,Collision.num_collider_objects do
        local obj = Collision.all_collider_objects[k]
        if obj.active then
            love.graphics.setColor(0, 255, 0, 255)
            if obj.Collider.type == Collision.Types.SPHERE then
                Mesh.draw(Mesh.meshes[1], obj.x, obj.y, obj.z, 0,0,0,obj.Collider.radius, obj.Collider.radius, obj.Collider.radius, Lighting3D.defaultShader, Collision.debugShaderFunc,obj)
            elseif obj.Collider.type == Collision.Types.CIRCLE then
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

function Collision.getXYPos(tileInd)
    return (tileInd % Collision.Solids.Width) * 8 - 4, math.floor(tileInd / Collision.Solids.Width) * 8 + 4
end

function Collision.getMapPos(x, y)
    local mapX = math.floor(x / 8)
    local mapY = math.floor(y / 8)
    return mapY * Collision.Solids.Width + mapX + 1
end

function Collision.tileIsSolidAt(x,y)
    return Collision.Solids.SolidMap[Collision.getMapPos(x,y)]
end

-- terrainInfo is a table with a 'data' and 'width' field from the Tiled editor.
-- Width is the width in # of tiles. 'data' is the linearly indexed tile data.
-- Tiles are hardcoded as 8x8 for now.
function Collision.setupTerrainCollision(terrainInfo)
    local collisionMap, collisionContent = Collision.createCollisionMapAndContent(terrainInfo)
    Collision.setCollisionMapAndContent(terrainInfo.width, collisionMap, collisionContent)
end

function Collision.createCollisionMapAndContent(terrainInfo)
    -- Set up all solid collision
    local solidTiles = { -- 0 based indices of all solid collision tiles from our spritesheet in the tiled editor
    -- TODO put your actual solid tile indices in here from your tilemap
        0
    }
    local solidTileMap = {}
    for k = 1,#solidTiles do
        solidTileMap[solidTiles[k]+1] = true
    end

    -- Serialize all "solid" tiles into a map for our collisions
    local collisionMap = {}
    local collisionContent = {}
    -- Iterate over all the actual tile data in our map
    for k = 1,#terrainInfo.data do
        -- If the tile data corresponds to a solid tile as per the solidTileMap, then mark this tile as "solid" in the collisionMap
        -- The value of "k" here corresponds to the real tile index, which is a linearly indexed version of the 2D array of tiles
        -- that gets input by reading in the map.
        if solidTileMap[terrainInfo.data[k]] then
            collisionMap[k] = true
            -- Also save the actual tile content for that tile
            collisionContent[k] = terrainInfo.data[k]
        end
    end
    return collisionMap, collisionContent
end

function Collision.setCollisionMapAndContent(terrainWidth, collisionMap, collisionContent)
    Collision.Solids.SolidMap = collisionMap
    Collision.Solids.SolidContent = collisionContent
    Collision.Solids.Width = terrainWidth
end

return Collision