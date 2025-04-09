local Lighting3D = {}
local maxNumLights = 12
function Lighting3D.initialize()
    Lighting3D.lights = {}
    Lighting3D.tempVector = {0,0,0}
    Lighting3D.defaultShader = love.graphics.newShader('Engine/solidColor.frag', 'Engine/mesh.vert')
    Lighting3D.defaultShaderFcn =
        function(shader, obj)
            shader:send("solidColor", obj.color)
        end
    for k = 1,maxNumLights do
        local light = {
            position = {x=0,y=0,z=0},
            active=false,
            intensity= 1,
            color = {1,1,1},
            -- these come from https://learnopengl.com/Lighting/Light-casters
            -- in the 100 meters column
            constant = 1.0,
            linear = 0.045,
            quadratic = 0.0075,
            reserved = false
        }
        table.insert(Lighting3D.lights, light)
    end
    -- initialize the shader uniforms for the default lighting shader
    Lighting3D.sendShader(Mesh.defaultShader, true)
    Lighting3D.sendShader(Mesh.defaultGLTFShader, true)
    Lighting3D.ambientLighting = 0.5
end

function Lighting3D.makeObjUseSolidColor(obj, color)
    obj.shader = Lighting3D.defaultShader
    obj.shaderFcn = Lighting3D.defaultShaderFcn
    obj.color = {color[1], color[2], color[3], color[4]}
end

function Lighting3D.getFreeLight()
    for k = 1,maxNumLights do
        if not Lighting3D.lights[k].active and not Lighting3D.lights[k].reserved then
            Lighting3D.lights[k].reserved = true
            return Lighting3D.lights[k]
        end
    end
end

function Lighting3D.addLight(x,y,z,intensity,color)
    local light = Lighting3D.getFreeLight()
    light.position.x, light.position.y, light.position.z = x,y,z
    light.intensity = intensity
    light.color = color or {1,1,1}
    light.active = true
    return light
end

function Lighting3D.sendShader(shader, forciblySend)
    for k = 1,#Lighting3D.lights do
        local light = Lighting3D.lights[k]
        if light.active or forciblySend then
            shader:send("lights["..(k-1).."].intensity", light.intensity)
            shader:send("lights["..(k-1).."].isActive", light.active)
            Lighting3D.tempVector[1], Lighting3D.tempVector[2], Lighting3D.tempVector[3] = light.position.x, light.position.y, light.position.z
            shader:send("lights["..(k-1).."].position", Lighting3D.tempVector)
            shader:send("lights["..(k-1).."].color", light.color)
            shader:send("lights["..(k-1).."].constant", light.constant)
            shader:send("lights["..(k-1).."].linear", light.linear)
            shader:send("lights["..(k-1).."].quadratic", light.quadratic)
        end
    end
end


return Lighting3D