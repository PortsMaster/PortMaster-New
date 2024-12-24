local base, back, window, reflect
local shader = [[
extern vec3 modFactors; // Renamed from modf to avoid conflict
extern bool isGraphic;

vec3 scb(vec3 color, vec3 adj) {
    const vec3 coeffi = vec3(0.2125, 0.7154, 0.0721);
    const vec3 lumins = vec3(0.5, 0.5, 0.5);

    vec3 brtcol = color * adj.z;
    vec3 intens = vec3(dot(brtcol, coeffi));
    vec3 satcol = mix(intens, brtcol, adj.y);
    vec3 concol = mix(lumins, satcol, adj.x);

    return concol;
}

vec4 effect(vec4 color, Image tex, vec2 coords, vec2 _) {
    vec4 pixel = Texel(tex, coords);
    vec3 modif;
    vec4 final;

    if (isGraphic) {
        modif = scb(color.rgb, modFactors);
        final = vec4(modif, color.a);
    } else {
        modif = scb(pixel.rgb, modFactors);
        final = vec4(modif, pixel.a) * color;
    }
    return final;
}
]]

local function lightingAnimation()
    if ClientPrefs.data.flashingLights then
        modify(base, 1, 0.8, 1.6)
        modify(back, 1.25, 1.5, 0.8)
        modify(window, 1, 1, 10)

        reflect.alpha = 1
    end

    state.timer:wait(1 / 12, function()
        local eh = {c = 3, s = 2, b = 0.9}
        local eh2 = {b = 10}

        if ClientPrefs.data.flashingLights then
            modify(base, 1.5, 1, 0.5)
            modify(back, 1.5, 1, 0.5)
            modify(window, 1.3, 1, 0.5)

            reflect.alpha = 0
        else
            -- lower the intensity for next animation
            eh2.b = 1.5
            eh.c, eh.s = 1.5, 1
        end

        state.timer:wait(1 / 24, function()
            game.camera:shake(0.001, 1.4)
            state.camHUD:shake(0.001, 1.4)

            util.playSfx(paths.getSound('gameplay/thunder_' ..
                love.math.random(1, 2)))

            reflect.alpha = 0.9

            state.timer:tween(0.8, eh, {c = 1, s = 1, b = 1}, "linear")
            state.timer:tween(0.8, eh2, {b = 1}, "linear")

            state.timer:tween(0.7, reflect, {alpha = 0.6}, "linear")

            state.timer:during(1.5, function()
                modify(base, eh.c, eh.s, eh.b)
                modify(back, eh.c, eh.s, eh.b)
                modify(window, 1, 1, eh2.b)
            end)

            if state.boyfriend then
                state.boyfriend:playAnim('scared', true)
                state.boyfriend.lastHit = PlayState.conductor.time + 300
            end
            if state.gf then
                state.gf:playAnim('scared', true)
                state.gf.lastHit = PlayState.conductor.time + 300
            end
        end)
    end)
end

local function modify(obj, c, s, b)
    -- Use the new name 'modFactors' instead of 'modf'
    obj.shader:send("isGraphic", obj:is(Graphic))
    obj.shader:send("modFactors", {c, s, b})  -- Send the new variable name
end

function create()
    self.dadCam.y = 34

    base = Graphic(-350, -260, 2000, 2000, Color.fromString("#32325A"))
    base:setScrollFactor()
    base.shader = love.graphics.newShader(shader)
    self:add(base)

    window = Sprite(243, 68, paths.getImage(SCRIPT_PATH .. "window"))
    window.shader = love.graphics.newShader(shader)
    self:add(window)

    local windowBlend = Sprite(243, 68, paths.getImage(SCRIPT_PATH .. "window"))
    windowBlend.blend = "add"
    windowBlend.alpha = 0.22
    self:add(windowBlend)

    back = Sprite(-200, -100, paths.getImage(SCRIPT_PATH .. "bg_shadows"))
    back.shader = love.graphics.newShader(shader)
    self:add(back)

    reflect = Sprite(262, 609, paths.getImage(SCRIPT_PATH .. "windowReflect"))
    reflect.alpha = 0.5
    reflect.blend = "add"
    reflect.shader = window.shader
    self:add(reflect)

    modify(base, 1, 1, 1)
    modify(back, 1, 1, 1)
    modify(window, 1, 1, 1)
end

local lightningStrikeBeat = 0
local lightningOffset = love.math.random(8, 24)
function beat()
    if love.math.randomBool(10) and curBeat > lightningStrikeBeat +
        lightningOffset then
        lightingAnimation()

        lightningStrikeBeat = curBeat
        lightningOffset = love.math.random(8, 24)
    end
end

function close()
    base.shader:release()
    back.shader:release()
    window.shader:release()
end
