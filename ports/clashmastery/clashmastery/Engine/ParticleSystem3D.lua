local ParticleSystem3D = {}
local num_pooled_emitters = 5

function ParticleSystem3D.initialize()
    ParticleSystem3D.all_emitters = {}
    ParticleSystem3D.numEmitters = num_pooled_emitters
    ParticleSystem3D.currentEmitterIndex = 1
    for k = 1,ParticleSystem3D.numEmitters do
        ParticleSystem3D.all_emitters[k] = ParticleSystem3D.createEmitter(50)
    end
end

-- NOT YET IMPLEMENTED IN 3D
-- function ParticleSystem3D.radialCharge(x, y, numParticles, color, startRadius, radiusMultiplier, lifeTime, offset, fadeAlpha, radialCollapseRate)
--     if not gamePreferences.particlesEnabled then
--         return
--     end
--     local emitter = ParticleSystem3D.getEmitterFromPool()
--     for k = 1,numParticles do
--         emitter.particles[k].r = startRadius
--         for k2 = 1,#color do
--             emitter.particles[k].color[k2] = color[k2]
--         end
--         emitter.particles[k].maxLifeTime = lifeTime
--         emitter.particles[k].currLifeTime = lifeTime

--         local angle = math.rad(360/numParticles * k)
--         emitter.particles[k].x = x + math.cos(angle) * offset
--         emitter.particles[k].y = y + math.sin(angle) * offset
--         emitter.particles[k].vx, emitter.particles[k].vy = clampVecToLength(x - emitter.particles[k].x, y - emitter.particles[k].y, radialCollapseRate)

--         emitter.particles[k].radiusMultiplier = radiusMultiplier
--         emitter.particles[k].velocityMultiplier = 1
--         emitter.particles[k].fadeAlpha = fadeAlpha

--         emitter.particles[k].active = true
--     end
-- end

function ParticleSystem3D.charge(x, y, z, numParticles, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, fadeAlpha, lifeTime, offset, emitter)
    if not gamePreferences.particlesEnabled then
        return
    end
    emitter = emitter or ParticleSystem3D.getEmitterFromPool()
    local k = 1
    for i = 1,numParticles do
        k = (i-1) + emitter.lastInactiveParticleIndex
        if k > emitter.numParticles then
            k = 1
        end
        emitter.particles[k].r = startRadius
        for k2 = 1,#color do
            emitter.particles[k].color[k2] = color[k2]
        end
        emitter.particles[k].maxLifeTime = lifeTime
        emitter.particles[k].currLifeTime = lifeTime

        local randAngle = math.rad(math.random() * 360)
        local randAngle2 = math.rad(math.random() * 360)

        emitter.particles[k].x = x + math.cos(randAngle) * math.sin(randAngle2)*offset
        emitter.particles[k].y = y + math.sin(randAngle) * math.sin(randAngle2)*offset
        emitter.particles[k].z = z + math.cos(randAngle2) * offset

        emitter.particles[k].vx = -math.cos(randAngle) * math.sin(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].vy = -math.sin(randAngle) * math.sin(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].vz = -math.cos(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].ax = 0
        emitter.particles[k].ay = 0
        emitter.particles[k].az = 0

        emitter.particles[k].radiusMultiplier = radiusMultiplier
        emitter.particles[k].velocityMultiplier = 1
        emitter.particles[k].fadeAlpha = fadeAlpha

        emitter.particles[k].active = true
    end
    -- updating this ensures the next particle burst does not interfere with the previous one
    emitter.lastInactiveParticleIndex = k
end

function ParticleSystem3D.createContinuousEmitter(emissionRate, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime, drawLayer)
    local emitter = ParticleSystem3D.createEmitter(emissionRate * lifeTime * 2, false)
    emitter.emissionRate = 1/emissionRate
    emitter.currentEmissionRate = 1/emissionRate
    emitter.emitting = false
    emitter.color = {}
    for k2 = 1,#color do
        emitter.color[k2] = color[k2]
    end
    function emitter:emit(particle)
        -- to be implemented by other continuous emitters
    end
    function emitter:pEmit(particle)
        particle.maxLifeTime = lifeTime
        particle.currLifeTime = lifeTime
        particle.color = emitter.color
        particle.r = startRadius
        particle.radiusMultiplier = radiusMultiplier
        particle.velocityMultiplier = velocityMultiplier
        particle.fadeAlpha = fadeAlpha
        particle.active = true
    end
    function emitter:update(dt)
        if not gamePreferences.particlesEnabled then
            return
        end
        if emitter.emitting then
            emitter.currentEmissionRate = emitter.currentEmissionRate - dt
            if emitter.currentEmissionRate <= 0 then
                while (emitter.currentEmissionRate <= 0) do
                    if emitter.lastInactiveParticleIndex > emitter.numParticles then
                        emitter.lastInactiveParticleIndex = 1
                    end
                    local k = emitter.lastInactiveParticleIndex
                    emitter:emit(emitter.particles[k])
                    emitter:pEmit(emitter.particles[k])
                    emitter.currentEmissionRate = emitter.currentEmissionRate + emitter.emissionRate
                    emitter.lastInactiveParticleIndex = emitter.lastInactiveParticleIndex + 1
                end
                emitter.currentEmissionRate = emitter.emissionRate
            end
        end
        local anyParticlesActive = false
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                anyParticlesActive = true
                emitter.particles[k]:update(dt)
            end
        end
        -- Clean up this emitter once it has no more particles to update
        if not anyParticlesActive and not emitter.emitting then
            emitter:setInactive()
        end
    end
    emitter.active = false
    return emitter
end

function ParticleSystem3D.createRadialEmitter(emissionRate, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime, drawLayer, offset)
    local emitter = ParticleSystem3D.createContinuousEmitter(emissionRate, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime, drawLayer or GameObjects.DrawLayers.PARTICLES)
    emitter.minSpeed = minSpeed
    emitter.maxSpeed = maxSpeed
    function emitter:emit(particle)
        local randAngle = math.rad(math.random() * 360)
        local randAngle2 = math.rad(math.random() * 360)

        local dx = math.cos(randAngle) * math.sin(randAngle2)
        local dy = math.sin(randAngle) * math.sin(randAngle2)
        local dz = math.cos(randAngle2)

        particle.vx = dx * (minSpeed + math.random()*(maxSpeed - minSpeed))
        particle.vy = dy * (minSpeed + math.random()*(maxSpeed - minSpeed))
        particle.vz = dz * (minSpeed + math.random()*(maxSpeed - minSpeed))

        particle.x, particle.y,particle.z = emitter.x + dx * offset, emitter.y + dy * offset, emitter.z + dz * offset

    end
    return emitter
end

-- NOT YET IMPLEMENTED IN 3D
-- function ParticleSystem3D.createAmbientParallaxEmitter(spawnRate, xBounds, yBounds, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime, drawLayer, parallaxFactor)
--     local emitter = ParticleSystem3D.createContinuousEmitter(spawnRate, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime, drawLayer or GameObjects.DrawLayers.PARTICLES)
--     emitter.xBounds, emitter.yBounds = xBounds, yBounds
--     emitter.minSpeed, emitter.maxSpeed = minSpeed, maxSpeed
--     emitter.parallaxFactor = parallaxFactor
--     -- set all the particles in this pool to be parallax particles
--     for k = 1,emitter.numParticles do
--         local particle = emitter.particles[k]
--         function particle:update(dt)
--             particle.vx = particle.vx * (particle.velocityMultiplier ^ (dt / referenceDT))
--             particle.vy = particle.vy * (particle.velocityMultiplier ^ (dt / referenceDT))

--             -- Particle should move with the emitter, which moves with the camera
--             particle.tx = particle.tx + particle.vx * dt
--             particle.ty = particle.ty + particle.vy * dt
--             particle.x = particle.tx + emitter.x
--             particle.y = particle.ty + emitter.y
--             particle.currLifeTime = particle.currLifeTime - dt

--             -- update graphical properties
--             if particle.fadeAlpha then
--                 particle.color[4] = particle.currLifeTime / particle.maxLifeTime
--             else
--                 particle.color[4] = 1
--             end
--             particle.r = particle.r * (particle.radiusMultiplier ^ (dt / referenceDT))

--             if particle.currLifeTime <= 0 then
--                 particle.active = false
--             end
--         end
--     end

--     function emitter:emit(particle)
--         -- Spawn particles randomly within the range of the emitter
--         particle.tx, particle.ty = emitter.x + randomBetween(emitter.xBounds[1], emitter.xBounds[2]), emitter.y + randomBetween(emitter.yBounds[1], emitter.yBounds[2])
--         local randAngle = math.rad(math.random() * 360)
--         particle.vx = math.cos(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
--         particle.vy = math.sin(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
--     end

--     -- Move the emitter with the camera to allow parallax
--     local parallaxObj = GameObjects.newGameObject(-1,0,0,0,true)
--     parallaxObj.emitter = emitter
--     function parallaxObj:update(dt)
--         parallaxUpdate(parallaxObj.emitter, emitter.parallaxFactor)
--     end
--     emitter.parallaxObj = parallaxObj
--     return emitter
-- end

function ParticleSystem3D.createJetEmitter(parent, emissionRate, jetSpread, color, startRadius, radiusMultiplier, velocityMultiplier, fadeAlpha, lifeTime)
    local emitter = ParticleSystem3D.createEmitter(emissionRate+5+10*lifeTime)
    emitter.emissionRate = 1/emissionRate
    emitter.currentEmissionRate = 1/emissionRate
    emitter.parent = parent
    emitter.emitting = false
    emitter.color = {}
    for k2 = 1,#color do
        emitter.color[k2] = color[k2]
    end
    function emitter:update(dt)
        if not gamePreferences.particlesEnabled then
            emitter:setInactive()
            return
        end
        if emitter.emitting then
            -- This is just the standard particle emission code, but since we're bad programmers we are doing this
            emitter.x = emitter.parent.x
            emitter.y = emitter.parent.y
            emitter.z = emitter.parent.z
            emitter.currentEmissionRate = emitter.currentEmissionRate - dt
            if emitter.currentEmissionRate <= 0 then
                while (emitter.currentEmissionRate <= 0) do
                    if emitter.lastInactiveParticleIndex > emitter.numParticles then
                        emitter.lastInactiveParticleIndex = 1
                    end
                    local k = emitter.lastInactiveParticleIndex
                    emitter.particles[k].x = emitter.x
                    emitter.particles[k].y = emitter.y
                    emitter.particles[k].z = emitter.z
                    emitter.particles[k].r = startRadius
                    emitter.particles[k].ax = 0
                    emitter.particles[k].ay = 0
                    emitter.particles[k].az = 0
                    emitter.particles[k].color = emitter.color

                    emitter.particles[k].maxLifeTime = lifeTime
                    emitter.particles[k].currLifeTime = lifeTime

                    -- emit particles opposite the direction of the parent's velocity
                    emitter.particles[k].vx = -emitter.parent.RigidBody.velocity.x
                    emitter.particles[k].vy = -emitter.parent.RigidBody.velocity.y
                    emitter.particles[k].vz = -emitter.parent.RigidBody.velocity.z
                    emitter.particles[k].vx, emitter.particles[k].vz = rotateVec(-emitter.parent.RigidBody.velocity.x, -emitter.parent.RigidBody.velocity.z, randomBetween(-jetSpread/2, jetSpread/2))

                    emitter.particles[k].radiusMultiplier = radiusMultiplier
                    emitter.particles[k].velocityMultiplier = velocityMultiplier
                    emitter.particles[k].fadeAlpha = fadeAlpha

                    emitter.particles[k].active = true
                    emitter.currentEmissionRate = emitter.currentEmissionRate + emitter.emissionRate
                    emitter.lastInactiveParticleIndex = emitter.lastInactiveParticleIndex + 1
                end
                emitter.currentEmissionRate = emitter.emissionRate
            end
        end
        local anyParticlesActive = false
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                anyParticlesActive = true
                emitter.particles[k]:update(dt)
            end
        end
        -- Clean up this emitter once it has no more particles to update
        if not anyParticlesActive and not emitter.emitting then
            emitter:setInactive()
        end
    end
    emitter.active = false
    return emitter
end

function ParticleSystem3D.burst(x, y, z, numParticles, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, velocityMultiplier,fadeAlpha, lifeTime, emitter, isEven, radialOffset)
    if not gamePreferences.particlesEnabled then
        return
    end
    emitter = emitter or ParticleSystem3D.getEmitterFromPool()
    local k = 1
    for i = 1,numParticles do
        k = (i-1) + emitter.lastInactiveParticleIndex
        if k > emitter.numParticles then
            k = 1
        end
        emitter.particles[k].x = x
        emitter.particles[k].y = y
        emitter.particles[k].z = z
        emitter.particles[k].r = startRadius
        emitter.particles[k].ax = 0
        emitter.particles[k].ay = 0
        for k2 = 1,#color do
            emitter.particles[k].color[k2] = color[k2]
        end
        emitter.particles[k].maxLifeTime = lifeTime
        emitter.particles[k].currLifeTime = lifeTime

        local randAngle = math.rad(math.random() * 360)
        local randAngle2 = math.rad(math.random() * 360)
        if isEven then
            -- space the particles evenly in all directions
            randAngle = math.rad(360 / numParticles * k)
            randAngle2 = math.rad(360 / numParticles * k)
            emitter.particles[k].vx = math.cos(randAngle) * math.sin(randAngle2) * (maxSpeed)
            emitter.particles[k].vy = math.sin(randAngle) * math.sin(randAngle2) * (maxSpeed)
            emitter.particles[k].vz = math.cos(randAngle2) * (maxSpeed)
        else
            emitter.particles[k].vx = math.cos(randAngle) * math.sin(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
            emitter.particles[k].vy = math.sin(randAngle) * math.sin(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
            emitter.particles[k].vz = math.cos(randAngle2) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        end
        
        radialOffset = radialOffset or 0
        emitter.particles[k].x = emitter.particles[k].x + math.cos(randAngle) * math.sin(randAngle2)*radialOffset
        emitter.particles[k].y = emitter.particles[k].y + math.sin(randAngle) * math.sin(randAngle2)*radialOffset
        emitter.particles[k].z = emitter.particles[k].z + math.cos(randAngle2) * radialOffset

        emitter.particles[k].radiusMultiplier = radiusMultiplier
        emitter.particles[k].velocityMultiplier = velocityMultiplier
        emitter.particles[k].fadeAlpha = fadeAlpha

        emitter.particles[k].active = true
    end
    -- updating this ensures the next particle burst does not interfere with the previous one
    emitter.lastInactiveParticleIndex = k
end

-- NOT YET IMPLEMENTED IN 3D
-- function ParticleSystem3D.lineBurst(x, y, numParticles, minSpeed, maxSpeed, color, startLength, lengthMultiplier, velocityMultiplier,fadeAlpha, lifeTime, emitter, isEven)
--     if not gamePreferences.particlesEnabled then
--         return
--     end
--     emitter = emitter or ParticleSystem3D.getEmitterFromPool()
--     local k = 1
--     for i = 1,numParticles do
--         k = (i-1) + emitter.lastInactiveParticleIndex
--         if k > emitter.numParticles then
--             k = 1
--         end
--         emitter.particles[k].x = x
--         emitter.particles[k].y = y
--         emitter.particles[k].l = startLength
--         emitter.particles[k].ax = 0
--         emitter.particles[k].ay = 0
--         for k2 = 1,#color do
--             emitter.particles[k].color[k2] = color[k2]
--         end
--         emitter.particles[k].maxLifeTime = lifeTime
--         emitter.particles[k].currLifeTime = lifeTime

--         local randAngle = math.rad(math.random() * 360)
--         if isEven then
--             -- space the particles evenly in all directions
--             randAngle = math.rad(360 / numParticles * k)
--             emitter.particles[k].vx = math.cos(randAngle) * (maxSpeed)
--             emitter.particles[k].vy = math.sin(randAngle) * (maxSpeed)
--         else
--             emitter.particles[k].vx = math.cos(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
--             emitter.particles[k].vy = math.sin(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
--         end
--         emitter.particles[k].angle = randAngle
--         emitter.particles[k].lengthMultiplier = lengthMultiplier
--         emitter.particles[k].velocityMultiplier = velocityMultiplier
--         emitter.particles[k].fadeAlpha = fadeAlpha

--         emitter.particles[k].active = true
--     end
--     -- updating this ensures the next particle burst does not interfere with the previous one
--     emitter.lastInactiveParticleIndex = k
-- end

-- NOT YET IMPLEMENTED IN 3D
-- function ParticleSystem3D.gravParticles(x, y, numParticles, gravAccel, color, radius, lifeTime)
--     if not gamePreferences.particlesEnabled then
--         return
--     end
--     local emitter = ParticleSystem3D.getEmitterFromPool()
--     for k = 1,numParticles do
--         emitter.particles[k].x = x
--         emitter.particles[k].y = y
--         emitter.particles[k].r = radius
--         emitter.particles[k].color = color
--         emitter.particles[k].maxLifeTime = lifeTime
--         emitter.particles[k].currLifeTime = lifeTime

--         emitter.particles[k].vx = 0
--         emitter.particles[k].vy = 0
--         emitter.particles[k].ay = gravAccel

--         emitter.particles[k].radiusMultiplier = 1
--         emitter.particles[k].velocityMultiplier = 1
--         emitter.particles[k].fadeAlpha = false

--         emitter.particles[k].active = true
--     end
-- end

function ParticleSystem3D.getEmitterFromPool()
    local emitter = ParticleSystem3D.all_emitters[ParticleSystem3D.currentEmitterIndex]
    ParticleSystem3D.currentEmitterIndex = ParticleSystem3D.currentEmitterIndex + 1
    if ParticleSystem3D.currentEmitterIndex > ParticleSystem3D.numEmitters then
        ParticleSystem3D.currentEmitterIndex = 1
    end
    return emitter
end

function ParticleSystem3D.createEmitter(numParticles, isLine)
    local emitter = GameObjects3D.newGameObject(-1, 0, 0, 0, true)
    emitter.particles = {}
    emitter.numParticles = numParticles
    emitter.lastInactiveParticleIndex = 1 -- used by single emitters
    -- pool particles
    for k = 1,numParticles do
        if isLine then
            emitter.particles[k] = ParticleSystem3D.createLineParticle()
        else
            emitter.particles[k] = ParticleSystem3D.createParticle()
        end
    end

    function emitter:update(dt)
        prof.push("Particle update")
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                emitter.particles[k]:update(dt)
            end
        end
        prof.pop("Particle update")
    end

    function emitter:draw(dt)
        prof.push("Particle draw")
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                emitter.particles[k]:draw()
            end
        end
        prof.pop("Particle draw")
    end
    return emitter
end

function ParticleSystem3D.createParticle()
    local particle = {
        x=0,y=0,z=0,vx=0,vy=0,vz=0,r=4,
        active=false,
        color={1,1,1,1},
        maxLifeTime=1,currLifeTime=1,
        fadeAlpha=false,
        radiusMultiplier=1,
        velocityMultiplier=1
    }
    function particle:update(dt)
        particle.vx = particle.vx * (particle.velocityMultiplier ^ (dt / referenceDT))
        particle.vy = particle.vy * (particle.velocityMultiplier ^ (dt / referenceDT))
        particle.vz = particle.vz * (particle.velocityMultiplier ^ (dt / referenceDT))
        
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.z = particle.z + particle.vz * dt
        particle.currLifeTime = particle.currLifeTime - dt

        -- update graphical properties
        if particle.fadeAlpha then
            particle.color[4] = particle.currLifeTime / particle.maxLifeTime
        else
            particle.color[4] = 1
        end
        particle.r = particle.r * (particle.radiusMultiplier ^ (dt / referenceDT))
        
        if particle.currLifeTime <= 0 then
            particle.active = false
        end
    end

    function particle:draw()
        Mesh.draw(Mesh.meshes[1], particle.x, particle.y, particle.z, 0, 0, 0, particle.r, particle.r, particle.r, Lighting3D.defaultShader, Lighting3D.defaultShaderFcn, particle)
    end

    return particle
end

-- NOT YET IMPLEMENTED IN 3D
-- function ParticleSystem3D.createLineParticle()
--     local particle = {
--         x=0,y=0,vx=0,vy=0,l=4,ay=0,
--         active=false,
--         color={1,1,1,1},
--         maxLifeTime=1,currLifeTime=1,
--         fadeAlpha=false,
--         lengthMultiplier=1,
--         velocityMultiplier=1,
--         angle = 0
--     }
--     function particle:update(dt)
--         particle.vx = particle.vx * (particle.velocityMultiplier ^ (dt / referenceDT))
--         particle.vy = particle.vy * (particle.velocityMultiplier ^ (dt / referenceDT))
        
--         particle.x = particle.x + particle.vx * dt
--         particle.y = particle.y + particle.vy * dt
--         particle.currLifeTime = particle.currLifeTime - dt

--         -- update graphical properties
--         if particle.fadeAlpha then
--             particle.color[4] = particle.currLifeTime / particle.maxLifeTime
--         else
--             particle.color[4] = 1
--         end
--         particle.l = particle.l * (particle.lengthMultiplier ^ (dt / referenceDT))

--         if particle.currLifeTime <= 0 then
--             particle.active = false
--         end
--     end

--     function particle:draw()
--         love.graphics.setColor(particle.color[1],particle.color[2],particle.color[3],particle.color[4])
--         love.graphics.line(particle.x, particle.y, particle.x - math.cos(particle.angle)*particle.l, particle.y - math.sin(particle.angle)*particle.l)
--     end

--     return particle
-- end

return ParticleSystem3D