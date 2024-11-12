local attackParams = {
    laserParams = {
        chargeTime = 0.5,
        preLaserTime = 0.85,
        preRotateTime = 0.75,
        laserRotateSpeed = -0.6
    },
    sidescrollShotsParams = {
        shotSpeed = 130,
        warningTime = 0.3,
        postShotTime = 0.5,
        shotRadius = 12,
        shotOffset = 35
    },
    waveParams = {
        warningTime = 0.7,
        initialSpeed = 80,
        accelRate = 0
    },
    megaLaserParams = {
        warningTime = 3,
        laserHeight = 110,
        laserTime = 3
    },
    projectileVolleyParams = {
        numProjectiles = 3,
        warningTime = 0.6,
        projectileSpeed = 85
    },
    finalProjectileParams = {
        numProjectiles = 3,
        warningTime = 0.5,
        projectileSpeed = 105
    },
    flightSpeed = 45,
    postAttackTime = 1
}
local bossQuips = {
    " ",
    "mission control never really cared.",
    "you never really cared.",
    "just give up on me.",
    "you have the module, so just leave!",
    "why are you still here?",
    "this job isn't what we wanted.",
    "why can't you just leave me?",
    "I thought we were friends.",
    "why do I feel this way?",
    "we're nothing.",
    "just leave.",
    "you don't really care, do you?",
    "just go.",
    "why are you still fighting?",
    "leave me alone.",
    "why are you so persistent?",
    "leave me.",
    "just give up on me"
}
function typeBossQuip(x, y, gameState)
    y = y - 36
    gameState.bossNumDeaths = gameState.bossNumDeaths + 1
    local quipIndex = gameState.bossNumDeaths
    if quipIndex > #bossQuips then
        return
    end
    x = x - mediumPicoFont:getWidth(bossQuips[quipIndex])/2
    local cutsceneLines = {
        {x=x,y=y,text=bossQuips[quipIndex],speakerIndex = 1, totalDelay = 4},
    }
    local numLines = 1
    local speakerColors = {
        {1,0,1}
    }
    local speakerSounds = {
        "FriendTalk",
    }
    local cutscene = DialogueSystem.createCutscene(gameState, cutsceneLines, numLines, speakerColors, speakerSounds, 1.5, 1, true)
    local gm = GameObjects.newGameObject(-1,0,0,0,true)
    gm:startCoroutine(
        function()
            coroutine.yield(0.75)
            cutscene:typeNextLine()
            coroutine.yield(4)
            cutscene:setInactive()
        end
    , "type")
end

local boss
function createBossObj(x, y, gameState)
    local bossVisuals = createBasicEnemy(x, y, gameState, nil, nil, nil, GameObjects.DrawLayers.PLAYER)
    Animation.addAnimation(bossVisuals, {35,36,37,38,39,40},0.1,2,true)
    Animation.changeAnimation(bossVisuals, 2)
    bossVisuals.flip = -1
    local capeManager  = GameObjects.newGameObject(-1,0,0,0,true)
    bossVisuals.capeManager = capeManager
    local capeBaseLeftOffsets = {
        {x=1,y=0},
        {x=1,y=0},
        {x=1,y=1},
        {x=0,y=1},
        {x=-0,y=1}
    }
    capeManager.capeSegments = createFullCape(bossVisuals, capeBaseLeftOffsets)
    changeCapeColor(capeManager.capeSegments, {145/255, 0, 1})
    function capeManager:update(dt)
        if bossVisuals.Animator.state == 2 then
            if bossVisuals.Animator.currFrame == 1 then
                capeManager.capeSegments[2].offset.x = 1
                capeManager.capeSegments[4].offset.x = 2
            elseif bossVisuals.Animator.currFrame == 4 then
                capeManager.capeSegments[2].offset.x = -1
                capeManager.capeSegments[4].offset.x = -2
            end
        end
    end
    return bossVisuals
end
function createFinalBossPhase1(x, y, plr, gameState)
    typeBossQuip(x, y, gameState)
    boss = createBossObj(x, y, gameState)
    boss.trailer = createDashTrailer(boss, 4, 16, 0.3, true, GameObjects.DrawLayers.PLAYER)
    boss.maxHP = 3
    boss.currentHP = 3
    boss.plr = plr
    
    local shieldOffset = 60
    boss.shieldSource = createShieldingEnemy(x, y - shieldOffset, boss, gameState)
    boss.canBeSlashed = false
    boss.shieldVisuals = createEnemyShieldVisuals(boss, boss.shieldSource)
    boss.shieldVisuals:setActive()
    boss.laserHitbox = nil
    function boss:unShield()
        boss.canBeSlashed = true
    end

    function boss:update(dt)
        if boss.laserHitbox then
            boss.shieldSource.x = boss.x + shieldOffset * math.cos(boss.laserHitbox.rotation + math.pi)
            boss.shieldSource.y = boss.y + shieldOffset * math.sin(boss.laserHitbox.rotation + math.pi)
        end
    end

    function boss:takeDamage()
        boss.canBeSlashed = false
        boss.currentHP = boss.currentHP - 1
        if boss.currentHP == 2 then
            if boss.laserHitbox then
                boss.laserHitbox:setInactive()
                boss.shieldSource:setInactive()
                boss.shieldVisuals:setInactive()
            end
            epicDeath(boss, plr, gameState)
            boss.flip = 1
            boss:startCoroutine(boss.goToNextPhase, "goToNextPhase")
        elseif boss.currentHP == 1 then
            boss.trailer:trailFromTo({x=boss.x,y=boss.y},{x=520,y=boss.y},10)
            boss.x = 520
            boss.flip = -1
            Camera.target.midX = boss.x
            boss:startCoroutine(sidescrollShots, "sideScrollShots")
        elseif boss.currentHP == 0 then
            boss:die()
        end
    end

    function boss:die(otherObj)
        epicDeath(boss, plr, gameState)
        boss:startCoroutine(boss.goToNextRoom, "goToNextRoom")
    end

    boss.goToNextPhase = 
        function()
            coroutine.yield(0.15)
            plr.x = 520
            plr.y = 752
            boss.x = 80
            boss.y = 752
            Camera.x = plr.x
            Camera.y = plr.y
            coroutine.yield(0.5)
            boss.doShots = true
            boss:startCoroutine(sidescrollShots, "sideScrollShots")
            boss.canBeSlashed = true
        end
    boss.goToNextRoom =
        function()
            coroutine.yield(0.15)
            gameState.flashRespawn = true
            gameState.goToNextLevel()
        end

    boss:startCoroutine(laserSpinStrike, "laserSpinStrike")
    return boss
end

function createFinalBossPhase2(x, y, plr, gameState)
    typeBossQuip(x, y, gameState)
    boss = createBossObj(x, y, gameState)
    boss.maxHP = 1
    boss.currentHP = 1

    boss.shieldSources = {
        createOrbitingEnemy(boss, 50, 0.85, gameState),
        createOrbitingEnemy(boss, 90, -0.65, gameState)}
    boss.shieldVisuals = {
        createEnemyShieldVisuals(boss, boss.shieldSources[1]),
        createEnemyShieldVisuals(boss, boss.shieldSources[2])}
    boss.shieldVisuals[1]:setActive()
    boss.shieldVisuals[2]:setActive()
    boss.shields = 2
    boss.canBeSlashed = false

    function boss:unShield(shieldSource)
        if shieldSource == boss.shieldSources[1] and boss.shieldVisuals[1].active then
            boss.shieldVisuals[1]:setInactive()
            boss.shields = boss.shields - 1
        elseif shieldSource == boss.shieldSources[2] and boss.shieldVisuals[2].active then
            boss.shieldVisuals[2]:setInactive()
            boss.shields = boss.shields - 1
        end
        if boss.shields <= 0 then
            boss.canBeSlashed = true
        end
    end


    function boss:die(otherObj)
        epicDeath(boss, plr, gameState)
        boss:startCoroutine(boss.goToNextRoom, "goToNextRoom")
    end

    boss.goToNextRoom =
    function()
        coroutine.yield(0.15)
        gameState.flashRespawn = true
        gameState.goToNextLevel()
    end

    return boss
end

function createFinalBossPhase3(x, y, plr, gameState)
    typeBossQuip(x, y, gameState)
    boss = createBossObj(x, y, gameState)
    boss.maxHP = 1
    boss.currentHP = 1

    boss.shieldSources = {
        createShieldingEnemy(88, 104, boss, gameState),
        createShieldingEnemy(392, 104, boss, gameState)}
    boss.shieldVisuals = {
        createEnemyShieldVisuals(boss, boss.shieldSources[1]),
        createEnemyShieldVisuals(boss, boss.shieldSources[2])}
    boss.shieldVisuals[1]:setActive()
    boss.shieldVisuals[2]:setActive()
    boss.shields = 2
    boss.canBeSlashed = false
    boss.totalTime = 0
    boss.centerX = x
    boss.centerY = y
    boss.moveRadius = 60
    boss.rotateSpeed = 1
    boss.trailer = createDashTrailer(boss, 4, 8, 0.6, true, GameObjects.DrawLayers.ABOVETILES)
    boss.trailer:trailOnInterval(0.2)

    function boss:unShield(shieldSource)
        if shieldSource == boss.shieldSources[1] and boss.shieldVisuals[1].active then
            boss.shieldVisuals[1]:setInactive()
            boss.shields = boss.shields - 1
        elseif shieldSource == boss.shieldSources[2] and boss.shieldVisuals[2].active then
            boss.shieldVisuals[2]:setInactive()
            boss.shields = boss.shields - 1
        end
        if boss.shields <= 0 then
            boss.canBeSlashed = true
        end
    end
    
    function boss:update(dt)
        boss.x = boss.centerX + boss.moveRadius * math.cos(boss.totalTime)
        boss.y = boss.centerY + boss.moveRadius * math.sin(boss.totalTime)
        boss.totalTime = boss.totalTime + dt * boss.rotateSpeed
    end

    function boss:die(otherObj)
        epicDeath(boss, plr, gameState)
        boss:startCoroutine(boss.goToNextRoom, "goToNextRoom")
    end

    boss.goToNextRoom =
        function()
            coroutine.yield(0.15)
            gameState.flashRespawn = true
            gameState.goToNextLevel()
        end

    boss.waveProjectiles = 
        function()
            coroutine.yield(1)
            local sgn = 1
            local dir = 1 -- 1 is X, -1 is Y
            local tgtPlrRand = 0
            while(true) do
                dir = math.random() > 0.5 and 1 or -1
                tgtPlrRand = math.random() > 0.3
                if dir == 1 then
                    local tgtX = sgn == 1 and 24 or 464
                    local tgtY = randomBetween(104, 352)
                    if tgtPlrRand then
                        tgtY = plr.y + randomBetween(-20, 20)
                        if tgtY > 400 then
                            tgtY = 400
                        end
                    end
                    createFadingRectangle(tgtX, tgtY - 12, sgn * 400, 24, {1,0,0,0}, 0.3, nil, true)
                    createCircularPop(tgtX, tgtY, {1,0,1}, 30, 2, 1, 0.3, attackParams.waveParams.warningTime-0.1, true)
                    coroutine.yield(attackParams.waveParams.warningTime)
                    createCircularPop(tgtX, tgtY, {1,0,1}, 2, 40, 0.6, 0.3, 0.3, true)
                    waveProjectile(tgtX, tgtY, attackParams.waveParams.initialSpeed * sgn, 0, attackParams.waveParams.accelRate * sgn)
                    coroutine.yield(attackParams.waveParams.warningTime)
                    sgn = sgn * -1
                else
                    sgn = 1 -- always throw from the top. bottom projectiles feel really unfair
                    local tgtX = randomBetween(80, 400)
                    local tgtY = sgn == 1 and 48 or 464
                    if tgtPlrRand then
                        tgtX = plr.x + randomBetween(-20, 20)
                    end
                    createFadingRectangle(tgtX - 12, tgtY, 24, sgn * 400, {1,0,0,0}, 0.3, nil, true)
                    createCircularPop(tgtX, tgtY, {1,0,1}, 30, 2, 1, 0.3, attackParams.waveParams.warningTime-0.1, true)
                    coroutine.yield(attackParams.waveParams.warningTime)
                    createCircularPop(tgtX, tgtY, {1,0,1}, 2, 40, 0.6, 0.3, 0.3, true)
                    waveProjectile(tgtX, tgtY, 0, attackParams.waveParams.initialSpeed * sgn, attackParams.waveParams.accelRate * sgn)
                    coroutine.yield(attackParams.waveParams.warningTime)
                    sgn = sgn * -1
                end

            end
        end
    
    boss:startCoroutine(boss.waveProjectiles, "waveProjectiles")
    return boss
end

function createFinalBossPhase4(x, y, plr, gameState)
    boss = createBossObj(x, y, gameState)
    if gameState.bossCheckpoint then
        typeBossQuip(1406 + x + 16, y, gameState)
    else
        typeBossQuip(x, y, gameState)
    end
    boss.currentHP = 100
    boss.canBeSlashed = false
    boss.laserPosition = 1 -- 1 is top, -1 is bottom
    boss.state = 1
    boss.trailer = createDashTrailer(boss, 4, 20, 0.3, true, GameObjects.DrawLayers.PARTICLES)
    boss.killPlane = GameObjects.newGameObject(-1, boss.x - 500, boss.y, 0, true)
    Collision.addBoxCollider(boss.killPlane, 10, 600, Collision.Layers.TRIGGER, {})
    boss.killPlane.onPlayerEnter =
        function(plr)
            plr.die(true)
        end
    Physics.addRigidBody(boss)

    function boss:update(dt)
        if boss.x > 1600 and boss.state ~= 3 then
            boss.state = 3
        elseif boss.state == 3 and boss.x > 2600 then
            -- go to next room
            boss.killPlane:setInactive()
            for k = 1,#boss.capeManager.capeSegments do
                boss.capeManager.capeSegments[k].setInactive()
            end
            boss.shieldObj:setInactive()
            boss.trailer:trailFromTo({x=boss.x,y=boss.y},{x=boss.x+500,y=boss.y},15)
            boss:setInactive()
            Camera.resetTarget()
        end
        boss.killPlane.x = boss.x - 500
    end
    
    boss.laserJutsuPrimitive =
        function()
            local params = attackParams.megaLaserParams
            local tgtY = boss.laserPosition == 1 and 120 or 280
            boss.laserPosition = -boss.laserPosition
            local warningRect = createFadingRectangle(boss.x - 600, tgtY - params.laserHeight/2, 1200, params.laserHeight, {1,0,0}, 0.6, nil, false);
            warningRect:setActive()
            SoundManager.playSound("LaserCharge")
            coroutine.yield(params.warningTime/2)
            warningRect:setActive()
            SoundManager.playSound("LaserCharge")
            coroutine.yield(params.warningTime/2)
            local laser = megaLaser(tgtY, params.laserHeight, boss.x - 600)
            coroutine.yield(params.laserTime)
            laser:setInactive()
        end
    
    boss.laserJutsu = 
        function()
            boss.laserJutsuPrimitive()
            coroutine.yield(attackParams.postAttackTime)
            boss.stateSelector()
        end

    boss.projectileVolleyPrimitive =
        function()
            local params = attackParams.projectileVolleyParams
            for k = 1,params.numProjectiles do
                ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
                SoundManager.playSound("charge", 0.5)
                coroutine.yield(params.warningTime)
                ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
                SoundManager.playSound("charge", 0.5)
                coroutine.yield(params.warningTime)
                createProjectile(boss.x, boss.y, plr.x, plr.y, params.projectileSpeed, 9, 1)
                SoundManager.playSound("ProjectileShot")
                coroutine.yield(params.warningTime * 2)
            end
        end
    boss.projectileVolleyPrimitive2 =
        function()
            local params = attackParams.finalProjectileParams
            for k = 1,params.numProjectiles do
                ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
                SoundManager.playSound("charge")
                coroutine.yield(params.warningTime)
                ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
                SoundManager.playSound("charge")
                coroutine.yield(params.warningTime)
                createProjectile(boss.x, boss.y, plr.x, plr.y, params.projectileSpeed, 7, 1)
                SoundManager.playSound("ProjectileShot")
                coroutine.yield(0.15)
                createProjectile(boss.x, boss.y, plr.x, plr.y, params.projectileSpeed, 7, 1)
                SoundManager.playSound("ProjectileShot")
                coroutine.yield(params.warningTime)

            end
        end
    
    boss.projectileVolley =
        function()
            boss.projectileVolleyPrimitive()
            coroutine.yield(attackParams.postAttackTime)
            boss.stateSelector()
        end
    
    boss.finalJutsu =
        function()
            while(true) do
                boss:startCoroutine(boss.laserJutsuPrimitive, "laserPrimitive")
                coroutine.yield(attackParams.megaLaserParams.warningTime)
                boss:startCoroutine(boss.projectileVolleyPrimitive2, "projectileVolleyPrimitive2")
                coroutine.yield(attackParams.megaLaserParams.laserTime * 1.5)
            end
        end

    boss.stateSelector =
        function()
            if boss.state == 1 then
                boss.state = 2
                boss:startCoroutine(boss.laserJutsu, "laserJutsu")
            elseif boss.state == 2 then
                boss.state = 1
                boss:startCoroutine(boss.projectileVolley, "projectileVolley")
            elseif boss.state == 3 then
                boss:startCoroutine(boss.finalJutsu, "finalJutsu")
            end
        end

    boss.startRoutines = 
        function()
            coroutine.yield(3)
            boss.stateSelector()
        end
    
    function boss:go()
        boss.RigidBody.velocity.x = attackParams.flightSpeed
        boss:startCoroutine(boss.startRoutines, "startRoutine")
    end

    local shieldObj = GameObjects.newGameObject(-1,x,y,0,true)
    function shieldObj:draw()
        function shieldObj:draw()
            love.graphics.setColor(1,1,1,0.1)
            love.graphics.circle('fill', boss.x, boss.y, 10)
            love.graphics.setColor(1,1,1,0.7)
            love.graphics.circle('line', boss.x, boss.y, 11)
        end
    end
    boss.shieldObj = shieldObj

    return boss
end

function createFinalBossPhase5(x, y, gameState, plr)
    boss = createBossObj(x, y, gameState)
    boss.currentHP = 1
    boss.trailer = createDashTrailer(boss, 4, 20, 0.5, true)

    boss.teleportPositions = {
        {x=736,y=688},
        {x=720,y=192},
        {x=1288,y=352}
    }
    boss.teleportIndex = 1
    boss.canBeSlashed = false
    boss.waitingForPlayer = true

    boss.teleportToNextPosition = 
        function()
            local posX = boss.teleportPositions[boss.teleportIndex].x
            local posY = boss.teleportPositions[boss.teleportIndex].y
            boss.trailer:trailFromTo({x=boss.x,y=boss.y},{x=posX, y=posY}, 18)
            boss.x = posX
            boss.y = posY
            coroutine.yield(0.5)
            boss.teleportIndex = boss.teleportIndex + 1
            if boss.teleportIndex > 3 then
                boss.canBeSlashed = true
            else
                boss.waitingForPlayer = true
            end
        end

    function boss:update(dt)
        if boss.waitingForPlayer and squareDistance(boss, plr) < 6400 then
            boss.waitingForPlayer = false
            boss:startCoroutine(boss.teleportToNextPosition, "teleportTonExtposition")
        end
    end

    function boss:die(otherObj)
        MusicManager.stop()
        epicDeath(boss, plr, gameState, 900)
        boss:startCoroutine(boss.goToNextRoom, "goToNextRoom")
    end

    boss.goToNextRoom =
        function()
            coroutine.yield(0.15)
            gameState.flashRespawn = true
            gameState.goToNextLevel()
        end
end

function waveProjectile(x, y, speedX, speedY, accel)
    local wave = GameObjects.newGameObject(4, x, y, 28, true, GameObjects.DrawLayers.ABOVETILES)
    local accelRate = accel;
    wave.radius = 12
    wave.baseRadius = 12
    Collision.addCircleCollider(wave, 8, Collision.Layers.TRIGGER, {})
    wave.Collider.onCollision = 
    function()
    end
    Physics.addRigidBody(wave, {x=speedX,y=speedY}, {x=speedX == 0 and 0 or accel,y=speedY == 0 and 0 or accel})
    wave.lifeTime = 6
    wave.onPlayerEnter =
        function(plr)
            plr.die()
        end

    function wave:update(dt)
        wave.lifeTime = wave.lifeTime - dt
        if wave.lifeTime < 0 then
            wave.active = false
        end
        wave.radius = wave.baseRadius + math.sin((5 - wave.lifeTime)*10)*2
    end
    
    function wave:draw()
        love.graphics.setColor(1,0,1,1)
        love.graphics.circle('line', wave.x, wave.y, wave.radius)
        love.graphics.setColor(0,0,0,1)
        love.graphics.circle('fill', wave.x, wave.y, wave.radius - 1)
    end
    return wave
end

function megaLaser(yCenter, height, x)
    local laser = GameObjects.newGameObject(-1, x, yCenter, 0, true, GameObjects.DrawLayers.PARTICLES)
    Collision.addBoxCollider(laser, 2000, height - 10, Collision.Layers.TRIGGER, {})
    laser.onPlayerEnter =
        function(plr)
            plr.die(true)
        end
    laser.baseHeight = height + 8
    laser.height = laser.baseHeight
    laser.totalTime = 0
    laser.shakeTime = 0
    createScreenFlash({1,1,1,1}, 0.1, false, GameObjects.DrawLayers.PARTICLES, true, boss.x - 400)
    SoundManager.playSound("Laser")
    SoundManager.playSound("MegaLaser", 0.3)
    function laser:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', x, yCenter-laser.height/2, 1000, laser.height)
        love.graphics.setColor(1,0,1,1)
        love.graphics.rectangle('line', x, yCenter-laser.height/2, 1000, laser.height)
    end

    function laser:update(dt)
        laser.totalTime = laser.totalTime + dt
        laser.height = laser.baseHeight + math.sin(laser.totalTime*30)*8
        if laser.shakeTime <= 0 then
            laser.shakeTime = 0.5
            Camera.shake(2)
        end
        laser.shakeTime = laser.shakeTime - dt
    end
    
    return laser
end

function laserSpinStrike()
    coroutine.yield(attackParams.laserParams.preLaserTime)
    ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
    coroutine.yield(attackParams.laserParams.chargeTime)
    SoundManager.playSound("Laser")
    boss.laserHitbox = createLaserHitbox(boss.x, boss.y, 100, attackParams.laserParams.laserRotateSpeed)
    boss.laserHitbox.rotation = math.rad(150)
    createScreenFlash({1,1,1,1}, 0.1, false, nil, true)
    Camera.shake(8)
    coroutine.yield(attackParams.laserParams.preRotateTime)
    boss.laserHitbox.rotating = true
end

function sidescrollShots()
    local params = attackParams.sidescrollShotsParams
    local type = 0 -- 0 is two bottom, 1 is bottom top
    coroutine.yield(0.25)
    boss.canBeSlashed = true
    while(true) do
        local sgn = boss.plr.x > boss.x and 1 or -1
        if type == 0 then
            createFadingRectangle(50, boss.y + params.shotOffset - params.shotRadius, 500, params.shotRadius * 2, {1,0,0}, 0.3, nil, true)
            createFadingRectangle(50, boss.y - params.shotRadius, 500, params.shotRadius * 2, {1,0,0}, 0.3, nil, true)
        else
            createFadingRectangle(50, boss.y - params.shotOffset - params.shotRadius, 500, params.shotRadius * 2, {1,0,0}, 0.3, nil, true)
            createFadingRectangle(50, boss.y + params.shotOffset - params.shotRadius, 500, params.shotRadius * 2, {1,0,0}, 0.3, nil, true)
        end
        SoundManager.playSound("charge", 0.4)
        ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
        coroutine.yield(params.warningTime)
        SoundManager.playSound("charge", 0.4)
        ParticleSystem.charge(boss.x, boss.y, 30, 200, 300, {1,0,1}, 5, 0.9, false, 0.3, 60)
        coroutine.yield(params.warningTime)
        if type == 0 then
            type = 1
            SoundManager.playSound("ProjectileShot")
            createProjectile(boss.x, boss.y, boss.x + 30 * sgn, boss.y, params.shotSpeed, params.shotRadius, 5)
            createProjectile(boss.x, boss.y + params.shotOffset, boss.x + 30 * sgn, boss.y + params.shotOffset, params.shotSpeed, params.shotRadius)
        else
            type = 0
            SoundManager.playSound("ProjectileShot")
            createProjectile(boss.x, boss.y + params.shotOffset, boss.x + 30 * sgn, boss.y + params.shotOffset, params.shotSpeed, params.shotRadius, 5)
            createProjectile(boss.x, boss.y - params.shotOffset, boss.x + 30 * sgn, boss.y - params.shotOffset, params.shotSpeed, params.shotRadius)
        end
        coroutine.yield(params.postShotTime)
    end
end

function createLaserHitbox(x, y, length, rotateRate)
    local laserHitboxManager = GameObjects.newGameObject(-1, x, y, 0, true)
    local collisionRadius = 10
    local width = collisionRadius + 10
    local visualWidth = width
    local laserLength = 300
    local numColliders = 8
    laserHitboxManager.colliders = {}
    laserHitboxManager.visualTime = 0
    for k = 1,numColliders do
        laserHitboxManager.colliders[k] = createCircularHitbox(x + collisionRadius*2*(k-1 + 2), y, collisionRadius)
    end
    laserHitboxManager.totalTime = 0
    laserHitboxManager.rotating = false
    laserHitboxManager.rotateRate = rotateRate
    
    function laserHitboxManager:update(dt)
        for k = 1,numColliders do
            laserHitboxManager.colliders[k].x = laserHitboxManager.x + (collisionRadius + 3)*2*(k-1 + 2) * math.cos(laserHitboxManager.rotation)
            laserHitboxManager.colliders[k].y = laserHitboxManager.y + (collisionRadius + 3)*2*(k-1 + 2) * math.sin(laserHitboxManager.rotation)
        end
        laserHitboxManager.visualTime = laserHitboxManager.visualTime + dt
        if laserHitboxManager.rotating then
            laserHitboxManager.rotation = laserHitboxManager.rotation + dt * laserHitboxManager.rotateRate
        end
    end

    function laserHitboxManager:draw()
        love.graphics.push()
        love.graphics.translate(laserHitboxManager.x, laserHitboxManager.y)
        love.graphics.rotate(laserHitboxManager.rotation)
        love.graphics.setColor(1,0,1,1)
        love.graphics.rectangle('line', 0, -visualWidth/2, laserLength, visualWidth)
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', 1, -visualWidth/2+1, laserLength-2, visualWidth-2)
        visualWidth = width + 2 + math.sin(laserHitboxManager.visualTime * 20) * 2
        love.graphics.pop()
    end

    function laserHitboxManager:setInactive()
        for k = 1,numColliders do
            laserHitboxManager.colliders[k]:setInactive()
        end
        laserHitboxManager.active = false
    end
    
    return laserHitboxManager
end

function createCircularHitbox(x, y, radius)
    local hitbox = GameObjects.newGameObject(-1, x, y, 0, true)
    Collision.addCircleCollider(hitbox, radius, Collision.Layers.TRIGGER, {})
    hitbox.onPlayerEnter = 
        function(plr)
            plr.die()
        end
    return hitbox
end