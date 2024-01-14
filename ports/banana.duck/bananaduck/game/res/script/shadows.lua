local shadows = object:extend()
shadows.persistent = true
shadows.layer = -10

shadows.objects = {}

local shaderCode = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        if (pixel.a == 0.0) {
            return pixel;
        }
        return vec4(0.0, 0.0, 0.0, 0.5);
    }
]]
local shadowShader = love.graphics.newShader(shaderCode)

function shadows:add(object)
    shadows.objects[object] = object
end

function shadows:remove(object)
    if object then
        shadows.objects[object] = nil
    end
end

function shadows:draw()
    graphics.translate(-1, 1)
    graphics.setColor(0, 0, 0, 0.5)
    love.graphics.setShader(shadowShader)
    for _, object in pairs(shadows.objects) do
        object:draw()
    end
    love.graphics.setShader()
    graphics.translate(1, -1)
end

return shadows