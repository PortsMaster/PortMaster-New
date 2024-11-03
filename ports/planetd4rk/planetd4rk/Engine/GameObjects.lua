local Texture = require("Engine.Texture")

local GameObjects = {}

GameObjects.DrawLayers = {
    BACKGROUND = 1,
    ABOVEBACKGROUND = 2,
    BEHINDPLAYER = 3,
    ABOVETILES = 4,
    PLAYER = 5,
    UI = 6,
    PARTICLES = 7,
    TOPUI = 8,
    POSTCAMERA = 9
}

function GameObjects.initialize()
    GameObjects.all_gameobjects = {}
    GameObjects.num_gameobjects = 0
    GameObjects.DrawLayerObjects = {}
    GameObjects.DrawLayerObjectLengths = {}

    -- Initialize all draw layers
    for key,value in pairs(GameObjects.DrawLayers) do
        GameObjects.DrawLayerObjects[value] = {}
        GameObjects.DrawLayerObjectLengths[value] = 0
    end
end

function GameObjects.newGameObject(textureIndex, x, y, spr, active, drawLayer)
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
        x = x,
        y = y,
        rotation = 0,
        spr = spr,
        active = active,
        flip = 1,
        alpha = 1,
        color={1,1,1},
        drawLayer = drawLayer or GameObjects.DrawLayers.ABOVEBACKGROUND,
        coroutines = {},
        id = 'uninitialized',
        numId = -1,
        cachedQuad = love.graphics.newQuad(0,0,0,0,0,0) -- create a single quad for this object to prevent memory leakage
    }

    function obj:update(dt)
        -- no op, implement this in your custom objects
    end

    function obj:draw()
        if obj.texture ~= -1 then
            Texture.draw(obj.texture, obj.spr, obj.x, obj.y, obj.flip, obj.alpha,obj.color,obj.rotation,obj.cachedQuad)
        end
    end

    function obj:setActive()
        obj.active = true
    end

    function obj:setInactive()
        obj.active = false
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

    GameObjects.DrawLayerObjectLengths[obj.drawLayer] = GameObjects.DrawLayerObjectLengths[obj.drawLayer] + 1
    GameObjects.DrawLayerObjects[obj.drawLayer][GameObjects.DrawLayerObjectLengths[obj.drawLayer]] = obj

    GameObjects.num_gameobjects = GameObjects.num_gameobjects + 1
    GameObjects.all_gameobjects[GameObjects.num_gameobjects] = obj
    obj.id = 'GameObject'..GameObjects.num_gameobjects
    obj.numId = GameObjects.num_gameobjects
    return obj
end

function GameObjects.update(dt)
    for k = 1,GameObjects.num_gameobjects do
        local obj = GameObjects.all_gameobjects[k]
        if obj.active then
            obj:update(dt)
            obj:updateCoroutines(dt)
        end
    end
end

function GameObjects.draw()
    for index,objectTable in ipairs(GameObjects.DrawLayerObjects) do
        if index ~= GameObjects.DrawLayers.POSTCAMERA then
            for k = 1,GameObjects.DrawLayerObjectLengths[index] do
                local obj = objectTable[k]
                if obj.active then
                    love.graphics.setColor(1, 1, 1, 1)
                    obj:draw()
                end
            end
        end
    end
end

function GameObjects.drawPostCamera()
    local objectTable = GameObjects.DrawLayerObjects[GameObjects.DrawLayers.POSTCAMERA]
    for k = 1,GameObjects.DrawLayerObjectLengths[GameObjects.DrawLayers.POSTCAMERA] do
        local obj = objectTable[k]
        if obj.active then
            love.graphics.setColor(1,1,1,1)
            obj:draw()
        end
    end
end

return GameObjects