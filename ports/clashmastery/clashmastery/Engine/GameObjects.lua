local Texture = require("Engine.Texture")

local GameObjects = {}

GameObjects.DrawLayers = {
    -- This needs to be defined in MainConfig.lua
}

function GameObjects.initialize()
    GameObjects.all_gameobjects = {}
    GameObjects.num_gameobjects = 0
    GameObjects.DrawLayerObjects = {}
    GameObjects.DrawLayerObjectLengths = {}
    GameObjects.DefaultDrawLayer = mainDefaultDrawLayer

    -- Initialize all draw layers
    for key,value in pairs(GameObjects.DrawLayers) do
        GameObjects.DrawLayerObjects[value] = {}
        GameObjects.DrawLayerObjectLengths[value] = 0
    end
end

function GameObjects.newGameObject(textureIndex, x, y, spr, active, drawLayer)
    textureIndex = textureIndex or -1
    local textureToUse
    -- Use -1 to ignore texture
    if textureIndex == -1 then
        textureToUse = -1
    else
        textureToUse = Texture.textures[textureIndex]
    end
    local obj = {
        texture = textureToUse,
        textureIndex = textureIndex,
        x = x or 0,
        y = y or 0,
        z = 0, -- not used in 2D
        scaleX = 1,
        scaleY = 1,
        rotation = 0,
        spr = spr or 0,
        active = active,
        flip = 1,
        flipY = 1,
        alpha = 1,
        color={1,1,1},
        drawLayer = drawLayer or GameObjects.DefaultDrawLayer,
        coroutines = {},
        fixedRateCoroutines = {},
        id = 'uninitialized',
        numId = -1,
        cachedQuad = textureIndex ~= -1 and love.graphics.newQuad(0,0,0,0,0,0) or -1, -- create a single quad for this object to prevent memory leakage
        components = {},
        numComponents = 0
    }

    function obj:update(dt)
        -- no op, implement this in your custom objects
    end

    function obj:draw()
        if obj.texture ~= -1 then
            if obj.flip == 0 then
                error("game object flip value is 0, it must be 1 or -1")
            end
            Texture.draw(obj.texture, obj.spr, obj.x, obj.y, obj.flip, obj.flipY, obj.alpha,obj.color,obj.rotation,obj.cachedQuad, obj.scaleX, obj.scaleY)
        end
    end

    function obj:pSetActive()
        -- implement this if you want to do something special during your activity
    end

    function obj:setActive()
        obj:pSetActive()
        obj.active = true
        for k = 1,obj.numComponents do
            obj.components[k]:setActive()
        end
    end

    function obj:pSetInactive()
        -- implement this if you want to do something special on deactivation
    end

    function obj:setInactive()
        obj:pSetInactive()
        obj.active = false
        for k = 1,obj.numComponents do
            obj.components[k]:setInactive()
        end
    end

    function obj:startCoroutine(fcn, id)
        obj.coroutines[id] = {}
        obj.coroutines[id].fcn = coroutine.create(fcn)
        obj.coroutines[id].currentTime = 0
        local status
        status, obj.coroutines[id].currentTime = coroutine.resume(obj.coroutines[id].fcn)
    end

    function obj:updateCoroutines(dt)
        local status
        for id,routine in pairs(obj.coroutines) do
            if coroutine.status(routine.fcn) == 'dead' then
                obj.coroutines[id] = nil
            elseif routine.currentTime > 0 then
                routine.currentTime = routine.currentTime - dt
            else
                status, routine.currentTime = coroutine.resume(routine.fcn)
            end
        end
    end

    -- for frame-sensitive coroutines like dashes. Use this for coroutines with very short steps
    -- fixed rate coroutines are synced up with physics updates
    function obj:startFixedRateCoroutine(fcn, id)
        obj.fixedRateCoroutines[id] = {}
        obj.fixedRateCoroutines[id].fcn = coroutine.create(fcn)
        obj.fixedRateCoroutines[id].currentTime = 0
        local status
        status, obj.fixedRateCoroutines[id].currentTime = coroutine.resume(obj.fixedRateCoroutines[id].fcn)
    end

    function obj:updateFixedRateCoroutines(dt)
        local status
        for id,routine in pairs(obj.fixedRateCoroutines) do
            if coroutine.status(routine.fcn) == 'dead' then
                obj.fixedRateCoroutines[id] = nil
            elseif routine.currentTime > 0 then
                routine.currentTime = routine.currentTime - dt
            else
                status, routine.currentTime = coroutine.resume(routine.fcn)
            end
        end
    end

    GameObjects.DrawLayerObjectLengths[obj.drawLayer] = GameObjects.DrawLayerObjectLengths[obj.drawLayer] + 1
    GameObjects.DrawLayerObjects[obj.drawLayer][GameObjects.DrawLayerObjectLengths[obj.drawLayer]] = obj

    GameObjects.num_gameobjects = GameObjects.num_gameobjects + 1
    GameObjects.all_gameobjects[GameObjects.num_gameobjects] = obj
    obj.id = 'GameObject'..GameObjects.num_gameobjects
    obj.numId = GameObjects.num_gameobjects
    return obj
end

function GameObjects.newComponent()
    local component = {
        active = false
    }
    function component:setActive()
        self.active = true
    end
    function component:setInactive()
        self.active = false
    end
    function component:update(dt)
        -- implement this
    end
    return component
end

function GameObjects.attachComponent(obj, component)
    table.insert(obj.components, component)
    obj.numComponents = obj.numComponents + 1
    return component
end

function GameObjects.update(dt)
    prof.push("Gameobjects update")
    for k = 1,GameObjects.num_gameobjects do
        local obj = GameObjects.all_gameobjects[k]
        if obj.active then
            obj:update(dt)
            obj:updateCoroutines(dt)
            for k2 = 1,obj.numComponents do
                if obj.components[k2].active then
                    obj.components[k2]:update(dt, obj)
                end
            end
        end
    end
    prof.pop("Gameobjects update")
end

function GameObjects.updateFixedRateCoroutines(dt)
    prof.push("Gameobjects fixedrate update")
    for k = 1,GameObjects.num_gameobjects do
        local obj = GameObjects.all_gameobjects[k]
        if obj.active then
            obj:updateFixedRateCoroutines(dt)
        end
    end
    prof.pop("Gameobjects fixedrate update")
end

function GameObjects.draw()
    prof.push("Gameobjects draw")
    for index,objectTable in ipairs(GameObjects.DrawLayerObjects) do
        if index ~= GameObjects.DrawLayers.POSTCAMERA then
            for k = 1,GameObjects.DrawLayerObjectLengths[index] do
                local obj = objectTable[k]
                if obj.active then
                    obj:draw()
                end
            end
        end
    end
    prof.pop("Gameobjects draw")
end

function GameObjects.drawPostCamera()
    prof.push("Gameobjects draw postcamera")
    local objectTable = GameObjects.DrawLayerObjects[GameObjects.DrawLayers.POSTCAMERA]
    for k = 1,GameObjects.DrawLayerObjectLengths[GameObjects.DrawLayers.POSTCAMERA] do
        local obj = objectTable[k]
        if obj.active then
            love.graphics.setColor(1,1,1,1)
            obj:draw()
        end
    end
    prof.pop("Gameobjects draw postcamera")
end

function GameObjects.updateWithoutTime(dt, trueDT)
    local objectTable = GameObjects.DrawLayerObjects[GameObjects.DrawLayers.IGNORE_DT]
    for k = 1,GameObjects.DrawLayerObjectLengths[GameObjects.DrawLayers.IGNORE_DT] do
        local obj = objectTable[k]
        if obj.active then
            love.graphics.setColor(1,1,1,1)
            obj:update(trueDT, trueDT)
            obj:updateCoroutines(trueDT)
        end
    end
end

return GameObjects