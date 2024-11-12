local ParticleSystem = {}
local num_pooled_emitters = 5

function ParticleSystem.initialize()
    ParticleSystem.all_emitters = {}
    ParticleSystem.numEmitters = num_pooled_emitters
    ParticleSystem.currentEmitterIndex = 1
    for k = 1,ParticleSystem.numEmitters do
        ParticleSystem.all_emitters[k] = ParticleSystem.createEmitter(50)
    end
end

function ParticleSystem.charge(x, y, numParticles, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, fadeAlpha, lifeTime, offset)
    local emitter = ParticleSystem.getEmitterFromPool()
    for k = 1,numParticles do
        emitter.particles[k].r = startRadius
        emitter.particles[k].color = color
        emitter.particles[k].maxLifeTime = lifeTime
        emitter.particles[k].currLifeTime = lifeTime

        local randAngle = math.rad(math.random() * 360)
        emitter.particles[k].x = x + math.cos(randAngle) * offset
        emitter.particles[k].y = y + math.sin(randAngle) * offset
        emitter.particles[k].vx = -math.cos(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].vy = -math.sin(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].ay = 0

        emitter.particles[k].radiusMultiplier = radiusMultiplier
        emitter.particles[k].velocityMultiplier = 1
        emitter.particles[k].fadeAlpha = fadeAlpha

        emitter.particles[k].active = true
    end
end

function ParticleSystem.burst(x, y, numParticles, minSpeed, maxSpeed, color, startRadius, radiusMultiplier, velocityMultiplier,fadeAlpha, lifeTime)
    local emitter = ParticleSystem.getEmitterFromPool()
    for k = 1,numParticles do
        emitter.particles[k].x = x
        emitter.particles[k].y = y
        emitter.particles[k].r = startRadius
        emitter.particles[k].ay = 0
        emitter.particles[k].color = color
        emitter.particles[k].maxLifeTime = lifeTime
        emitter.particles[k].currLifeTime = lifeTime

        local randAngle = math.rad(math.random() * 360)
        emitter.particles[k].vx = math.cos(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))
        emitter.particles[k].vy = math.sin(randAngle) * (minSpeed + math.random()*(maxSpeed - minSpeed))

        emitter.particles[k].radiusMultiplier = radiusMultiplier
        emitter.particles[k].velocityMultiplier = velocityMultiplier
        emitter.particles[k].fadeAlpha = fadeAlpha

        emitter.particles[k].active = true
    end
end

function ParticleSystem.gravParticles(x, y, numParticles, gravAccel, color, radius, lifeTime)
    local emitter = ParticleSystem.getEmitterFromPool()
    for k = 1,numParticles do
        emitter.particles[k].x = x
        emitter.particles[k].y = y
        emitter.particles[k].r = radius
        emitter.particles[k].color = color
        emitter.particles[k].maxLifeTime = lifeTime
        emitter.particles[k].currLifeTime = lifeTime

        emitter.particles[k].vx = 0
        emitter.particles[k].vy = 0
        emitter.particles[k].ay = gravAccel

        emitter.particles[k].radiusMultiplier = 1
        emitter.particles[k].velocityMultiplier = 1
        emitter.particles[k].fadeAlpha = false

        emitter.particles[k].active = true
    end
end

function ParticleSystem.getEmitterFromPool()
    local emitter = ParticleSystem.all_emitters[ParticleSystem.currentEmitterIndex]
    ParticleSystem.currentEmitterIndex = ParticleSystem.currentEmitterIndex + 1
    if ParticleSystem.currentEmitterIndex > ParticleSystem.numEmitters then
        ParticleSystem.currentEmitterIndex = 1
    end
    return emitter
end

function ParticleSystem.createEmitter(numParticles)
    local emitter = GameObjects.newGameObject(-1, 0, 0, 1, true, GameObjects.DrawLayers.PARTICLES)
    emitter.particles = {}
    emitter.numParticles = numParticles
    
    -- pool particles
    for k = 1,numParticles do
        emitter.particles[k] = ParticleSystem.createParticle()
    end

    function emitter:update(dt)
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                emitter.particles[k]:update(dt)
            end
        end
    end

    function emitter:draw(dt)
        for k = 1,emitter.numParticles do
            if emitter.particles[k].active then
                emitter.particles[k]:draw()
            end
        end
    end

    return emitter
end

function ParticleSystem.createParticle()
    local particle = {
        x=0,y=0,vx=0,vy=0,r=4,ay=0,
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
        particle.vy = particle.vy + particle.ay * dt
        
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
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
        love.graphics.setColor(particle.color[1],particle.color[2],particle.color[3],particle.color[4])
        love.graphics.circle('fill', particle.x, particle.y, particle.r)
    end

    return particle
end

return ParticleSystem