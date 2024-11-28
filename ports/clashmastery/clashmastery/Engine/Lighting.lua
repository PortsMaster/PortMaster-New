local Lighting = {}

local function createLight()
    local light = {
        x=0,
        y=0,
        intensity=1.0,
        active=false,
        radius = 18,
        parent = false
    }
    return light
end

local function createFlashObj()
    local flashObj = GameObjects.newGameObject(-1,0,0,0,false)
    flashObj.lifeTimer = createLifeTimer(flashObj, 0.1)
    function flashObj:setActive()
        flashObj.lifeTimer:init()
        flashObj.active = true
    end
    function flashObj:update(dt)
        flashObj.lifeTimer:update(dt)
    end
    return flashObj
end

function Lighting.initialize()
    Lighting.shader = love.graphics.newShader("Engine/lighting.frag")
    Lighting.trueBaseLightValue = 0.5
    Lighting.ignoreColor = global_pallete.red_color -- red is always red, no lighting applied
    Lighting.ignoreColor2 = global_pallete.primary_color_ignorelight -- a white unlit color for things like numbers and world-space text
    Lighting.secondaryColor = global_pallete.secondary_color -- the secondary color should not have lighting applied to it, as it is technically 'darkness'
    Lighting.baseLightValue = Lighting.trueBaseLightValue
    Lighting.max_num_lights = 32
    Lighting.all_lights = createPool(Lighting.max_num_lights, createLight)
    Lighting.flash_obj_pool = createPool(10, createFlashObj)
    Lighting.global_flash_routine_obj = GameObjects.newGameObject(-1,0,0,0,true)
end


function Lighting.sendShader()
    Lighting.shader:send("base_lighting", Lighting.baseLightValue)
        for k = 1,Lighting.max_num_lights do
            local light = Lighting.all_lights.objects[k]
            Lighting.shader:send("lights["..(k-1).."].position", {
                light.x * 1, light.y * 1 -- if you're using high res shaders (not canvas scale shaders), use windowCanvasScale instead of 1 here. if the camera is rendering in the game canvas, subtract Camera.x and Camera.y
            })
            Lighting.shader:send("lights["..(k-1).."].intensity",light.intensity)
            Lighting.shader:send("lights["..(k-1).."].isActive", light.active)
            Lighting.shader:send("lights["..(k-1).."].radius", light.radius * 1) -- see earlier comment
        end
    Lighting.shader:send("ignore_color", {Lighting.ignoreColor[1], Lighting.ignoreColor[2], Lighting.ignoreColor[3], Lighting.ignoreColor[4]})
    Lighting.shader:send("ignore_color2", {Lighting.ignoreColor2[1], Lighting.ignoreColor2[2], Lighting.ignoreColor2[3], Lighting.ignoreColor2[4]})
    Lighting.shader:send("secondary_color", {Lighting.secondaryColor[1], Lighting.secondaryColor[2], Lighting.secondaryColor[3], Lighting.secondaryColor[4]})
    love.graphics.setShader(Lighting.shader)
end

function Lighting.update()
    for k = 1,Lighting.max_num_lights do
        local currentLight = Lighting.all_lights.objects[k]
        if currentLight.parent then
            currentLight.active = currentLight.parent.active
            currentLight.x, currentLight.y = currentLight.parent.x, currentLight.parent.y
        end
    end
end

function Lighting.attachFreeLightTo(obj, intensity, radius)
    local light = Lighting.all_lights:getFromPool()
    light.intensity = intensity or 1.0
    light.radius = radius or light.radius
    light.parent = obj
    light.active = true
    return light
end

function Lighting.flashAtLocation(x, y, duration, radius, intensity)
    local flashObj = Lighting.flash_obj_pool:getFromPool()
    flashObj.x, flashObj.y = x, y
    flashObj.lifeTimer.maxLifeTime = duration
    Lighting.attachFreeLightTo(flashObj, intensity, radius)
    flashObj:setActive()
end

function Lighting.globalFlash(intensity, duration)
    Lighting.global_flash_routine_obj:startCoroutine(
        function()
            Lighting.baseLightValue = intensity
            coroutine.yield(duration)
            Lighting.baseLightValue = Lighting.trueBaseLightValue
        end
    , "globalFlash")
end

function Lighting.clearShader()
    love.graphics.setShader()
end


return Lighting