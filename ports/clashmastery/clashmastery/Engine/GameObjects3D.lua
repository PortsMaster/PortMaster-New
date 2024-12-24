local GameObjects3D = {}

function GameObjects3D.initialize()
    GameObjects3D.all_gameobjects = {}
    GameObjects3D.num_gameobjects = 0
end

function GameObjects3D.newGameObject(meshIndex, x, y, z, active)
    local meshToUse
    if active == nil then
        active = true
    end
    if meshIndex ~= -1 then
        meshToUse = Mesh.meshes[meshIndex]
    else
        meshToUse = -1
    end
    local obj = {
        x = x or 0,
        y = y or 0,
        z = z or 0,
        scaleX = 1,
        scaleY = 1,
        scaleZ = 1,
        rotation = {x=0,y=0,z=0},
        ambientLighting = false, -- if false, use regular lighting. if true, then has natural lighting set to this value
        active = active,
        alpha = 1,
        color={1,1,1},
        coroutines = {},
        id = 'uninitialized',
        numId = -1,
        mesh = meshToUse,
        shader = nil,
        shaderFcn = nil,
        components = {},
        numComponents = 0,
        useViewMatrix = true
    }

    function obj:update(dt)
        -- no op, implement this in your custom objects
    end

    function obj:draw()
        if obj.mesh ~= -1 then
            if obj.mesh.isGLTF then
                Mesh.drawGLTF(obj.mesh, obj.x, obj.y, obj.z, obj.rotation.x, obj.rotation.y, obj.rotation.z, obj.scaleX, obj.scaleY, obj.scaleZ, obj.shader, obj.shaderFcn, obj)
            else
                Mesh.draw(obj.mesh, obj.x, obj.y, obj.z, obj.rotation.x, obj.rotation.y, obj.rotation.z, obj.scaleX, obj.scaleY, obj.scaleZ, obj.shader, obj.shaderFcn, obj)
            end
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

    GameObjects3D.num_gameobjects = GameObjects3D.num_gameobjects + 1
    GameObjects3D.all_gameobjects[GameObjects3D.num_gameobjects] = obj
    obj.id = 'GameObject'..GameObjects3D.num_gameobjects
    obj.numId = GameObjects3D.num_gameobjects
    return obj
end

function GameObjects3D.attachComponent(obj, component)
    table.insert(obj.components, component)
    obj.numComponents = obj.numComponents + 1
    return component
end

function GameObjects3D.update(dt)
    prof.push("Gameobjects update")
    for k = 1,GameObjects3D.num_gameobjects do
        local obj = GameObjects3D.all_gameobjects[k]
        if obj.active then
            obj:update(dt)
            obj:updateCoroutines(dt)
            for k2 = 1,obj.numComponents do
                obj.components[k2]:update(dt, obj)
            end
        end
    end
    prof.pop("Gameobjects update")
end

function GameObjects3D.draw()
    prof.push("Gameobjects draw")
    for k = 1,GameObjects3D.num_gameobjects do
        local obj = GameObjects3D.all_gameobjects[k]
        if obj.active then
            obj:draw()
        end
    end
    prof.pop("Gameobjects draw")
end

return GameObjects3D