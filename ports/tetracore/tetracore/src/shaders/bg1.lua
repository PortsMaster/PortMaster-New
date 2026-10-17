local bg = {}
local GameConfig = require "src.constants.gameConfig"

local colorKeyframes = {
    { r = 1.0, g = 1.0, b = 1.0, a = 0.90 },
    { r = 1.0, g = 0.8, b = 0.0, a = 0.80 },
    { r = 1.0, g = 0.4, b = 0.0, a = 0.70 },
    { r = 1.0, g = 0.0, b = 0.0, a = 0.60 }
}

bg.distExponent = 2.0
local texSize = 512
local canvas

local loopProgress = 0
local LOOP_DURATION = 50
local currentInterpolatedLevel = 1

local retroShaderCode = [[
    uniform float u_angle;
    uniform float u_z1;
    uniform float u_z2;
    uniform float u_blendWeight;
    uniform float u_distExponent;
    uniform float u_scale;
    uniform vec2 u_pixelGrid;

    float hash3D(vec3 p) {
        float dotProduct = dot(p, vec3(443.8975, 397.2973, 491.1871));
        float m = mod(dotProduct, 1.0);
        m = m * (m + 19.19);
        return mod(m * m, 1.0);
    }

    float valueNoise3D(vec3 p) {
        vec3 i = floor(p);
        vec3 f = fract(p);
        vec3 u = f * f * (3.0 - 2.0 * f);

        float c000 = hash3D(i + vec3(0.0, 0.0, 0.0));
        float c100 = hash3D(i + vec3(1.0, 0.0, 0.0));
        float c010 = hash3D(i + vec3(0.0, 1.0, 0.0));
        float c110 = hash3D(i + vec3(1.0, 1.0, 0.0));
        float c001 = hash3D(i + vec3(0.0, 0.0, 1.0));
        float c101 = hash3D(i + vec3(1.0, 0.0, 1.0));
        float c011 = hash3D(i + vec3(0.0, 1.0, 1.0));
        float c111 = hash3D(i + vec3(1.0, 1.0, 1.0));

        return mix(mix(mix(c000, c100, u.x), mix(c010, c110, u.x), u.y),
                    mix(mix(c001, c101, u.x), mix(c011, c111, u.x), u.y), u.z);
    }

    float sampleShapeDensity(vec2 uv, float z1, float z2, float blendWeight) {
        float len = length(uv);

        float n1_a = valueNoise3D(vec3(uv, z1)) * 2.0 - 1.0;
        float noise1Value_a = pow(max(0.0, 1.0 - abs(n1_a)), 3.0);
        float n2_a = valueNoise3D(vec3(uv + vec2(5.3, 2.1), z1 + 1.4)) * 2.0 - 1.0;
        float noise2Value_a = pow(max(0.0, 1.0 - abs(n2_a)), 3.0);
        float density_a = (noise1Value_a * 0.5 + noise2Value_a * 0.5);

        float n1_b = valueNoise3D(vec3(uv, z2)) * 2.0 - 1.0;
        float noise1Value_b = pow(max(0.0, 1.0 - abs(n1_b)), 3.0);
        float n2_b = valueNoise3D(vec3(uv + vec2(5.3, 2.1), z2 + 1.4)) * 2.0 - 1.0;
        float noise2Value_b = pow(max(0.0, 1.0 - abs(n2_b)), 3.0);
        float density_b = (noise1Value_b * 0.5 + noise2Value_b * 0.5);

        float finalNoise = mix(density_a, density_b, blendWeight);
        float densityMultiplier = pow(max(0.0, 1.0 - len * 0.35), u_distExponent);

        return densityMultiplier * finalNoise;
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 pixelatedUV = floor(texture_coords * u_pixelGrid) / u_pixelGrid;
        
        vec2 uv = (pixelatedUV * 2.0 - 1.0) * u_scale;

        float len = length(uv);
        float rotationAngle = u_angle + (len * 4.0);

        float cosA = cos(rotationAngle);
        float sinA = sin(rotationAngle);
        vec2 rUV = vec2(uv.x * cosA - uv.y * sinA, uv.x * sinA + uv.y * cosA);

        float density = sampleShapeDensity(rUV * 0.9, u_z1, u_z2, u_blendWeight);
        float c = clamp(density, 0.0, 1.0);

        c = pow(c, 1.2);

        float colorSteps = 5.0;
        c = floor(c * colorSteps) / colorSteps;

        return vec4(vec3(c), 1.0) * color;
    }
]]

local shader

local function lerpColor(c1, c2, t)
    return {
        r = c1.r + (c2.r - c1.r) * t,
        g = c1.g + (c2.g - c1.g) * t,
        b = c1.b + (c2.b - c1.b) * t,
        a = c1.a + (c2.a - c1.a) * t
    }
end

local function getColorForLevel(level)
    level = math.max(1, math.min(10, level or 1))
    local progress = (level - 1) / 9

    local scaledProgress = progress * (#colorKeyframes - 1)
    local index = math.floor(scaledProgress) + 1
    local t = scaledProgress - (index - 1)

    local color
    if index >= #colorKeyframes then
        color = colorKeyframes[#colorKeyframes]
    else
        color = lerpColor(colorKeyframes[index], colorKeyframes[index + 1], t)
    end

    local levelAlpha = 1.0 - (progress * 0.2)

    return {
        r = color.r,
        g = color.g,
        b = color.b,
        a = color.a * levelAlpha
    }
end

local function getScaleForLevel(level)
    level = math.max(1, math.min(10, level or 1))
    local progress = (level - 1) / 9
    local minScale = 2.2
    local maxScale = 0.6
    return minScale + (maxScale - minScale) * progress
end

local function getSpeedMultiplierForLevel(level)
    level = math.max(1, math.min(10, level or 1))
    local progress = (level - 1) / 9
    local minSpeed = 1.0
    local maxSpeed = 3.5
    return minSpeed + (maxSpeed - minSpeed) * progress
end

function bg.init()
    canvas = love.graphics.newCanvas(texSize, texSize)
    canvas:setFilter("nearest", "nearest")

    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()

    shader = love.graphics.newShader(retroShaderCode)
end

function bg.update(dt)
end

function bg.draw(level)
    if not canvas or not shader then return end

    level = math.max(1, math.min(10, level or 1))

    local dt = love.timer.getDelta()
    currentInterpolatedLevel = currentInterpolatedLevel + (level - currentInterpolatedLevel) * math.min(1.0, dt * 4.0)

    local speedMultiplier = getSpeedMultiplierForLevel(currentInterpolatedLevel)

    loopProgress = loopProgress + ((dt / LOOP_DURATION) * speedMultiplier)
    if loopProgress >= 1.0 then loopProgress = loopProgress - 1.0 end

    local angle = loopProgress * math.pi * 2
    local z1 = math.sin(angle) * 1.5
    local z2 = math.sin(angle + math.pi) * 1.5
    local blendWeight = (math.cos(angle) + 1.0) * 0.5
    local activeScale = getScaleForLevel(currentInterpolatedLevel)

    shader:send("u_angle", angle)
    shader:send("u_z1", z1)
    shader:send("u_z2", z2)
    shader:send("u_blendWeight", blendWeight)
    shader:send("u_distExponent", bg.distExponent)
    shader:send("u_scale", activeScale)
    shader:send("u_pixelGrid", {texSize, texSize})

    local targetW = GameConfig.VIRTUAL_WIDTH
    local targetH = GameConfig.VIRTUAL_HEIGHT

	local activeColor = getColorForLevel(level)

    love.graphics.setShader(shader)
		love.graphics.setColor(activeColor.r, activeColor.g, activeColor.b, activeColor.a)
		love.graphics.draw(canvas, 0, 0, 0, targetW / texSize, targetH / texSize)
    love.graphics.setShader()

    love.graphics.setColor(1, 1, 1, 1)
end

return bg
