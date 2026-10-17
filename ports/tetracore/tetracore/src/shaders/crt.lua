local push = require "libs.push"

local crt = {}

local shaderCode = [[
extern number time;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texcolor = Texel(texture, texture_coords);

        number scanline = sin(screen_coords.y * 3.0 + (time * 5.0)) * 0.08;
        texcolor.rgb -= scanline;

        vec2 uv = texture_coords * (1.0 - texture_coords.yx);
        number vignette = uv.x * uv.y * 15.0;
        vignette = clamp(pow(vignette, 0.25), 0.0, 1.0);
        texcolor.rgb *= vignette;

        return texcolor * color;
    }
]]

local crtShader = nil
local active = false

function crt.init(enabled)
    if enabled == nil then
        enabled = true
    end
    
    active = enabled

    if active then
        if not crtShader then
            crtShader = love.graphics.newShader(shaderCode)
        end
        push:setShader(crtShader)
    else
        push:setShader(nil)
    end
end

function crt.update(dt)
    if crtShader and active then
        crtShader:send("time", love.timer.getTime())
    end
end

return crt
