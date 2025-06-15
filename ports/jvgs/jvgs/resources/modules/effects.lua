module("effects", package.seeall)

function stars(position, amount, names)
    amount = amount or 1
    names = names or {"moon", "skull", "spiral", "star"}
    local sm = jvgslua.SketchManager_getInstance()
    local em = jvgslua.EffectManager_getInstance()
    local sketches = jlib.map(names,
            function(e)
                return sm:getSketch("resources/effects/" .. e .. ".svg")
            end)

    local gravity = jvgslua.Vector2D(0, 0.003)

    for i = 1, math.random(amount * 10, amount * 30) do
        local velocity = jvgslua.Vector2D_fromPolar(0.1 + 1.9 * math.random(),
                math.random() * 360)

        particle = jvgslua.Particle(jlib.randomItem(sketches),
                1000 + 3000 * math.random(), position, velocity, gravity)
        em:addEffect(particle)
    end
end

function text(position, str)
    str = str or jlib.randomItem{"Whack!", "Splash!", "Pow!"}
    local em = jvgslua.EffectManager_getInstance()
    local e = jvgslua.TextEffect(str, position, 1000 + 1000 * math.random(),
            0.1 + 0.1 * math.random(), 360 * math.random())
    em:addEffect(e)
end

function staticText(position, str)
    local em = jvgslua.EffectManager_getInstance()
    local e = jvgslua.TextEffect(str, position, 0, 0, 0)
    em:addEffect(e)
end

function commonDie(entity)
    -- Drop him.
    entity:setController(nil)
    local positioner = jvgslua.NaivePositioner(entity)
    entity:setPositioner(positioner)
    local velocity = jvgslua.Vector2D(0, 2 * entity:getSpeed())
    entity:setVelocity(velocity)

    -- Effects.
    effects.text(entity:getPosition())
    effects.stars(entity:getPosition())

    -- Play optional sound.
    if entity:isSet("die-sound") then
        local am = jvgslua.AudioManager_getInstance()
        am:playSound(entity:get("die-sound"))
    end
end

function nextLevelAnimation(entity)
    -- Lift him.
    entity:setController(nil)
    local positioner = jvgslua.NaivePositioner(entity)
    entity:setPositioner(positioner)
    local velocity = jvgslua.Vector2D(0, -entity:getSpeed())
    entity:setVelocity(velocity)
end
