function createBasicEnemy(x, y, gameState, textureIndex, directed, dir, drawLayer)
    local enemy = GameObjects.newGameObject(textureIndex or 4, x, y, 0, true, drawLayer or GameObjects.DrawLayers.BEHINDPLAYER)
    Animation.addAnimator(enemy)
    Animation.addAnimation(enemy, {0,1,2,3,4}, 0.1, 1, true)
    enemy.maxHP = 100
    enemy.currentHP = enemy.maxHP
    enemy.canBeSlashed = true
    enemy.slashCooldown = 0.5
    enemy.directed = directed
    enemy.dir = dir
    enemy.slashCooldownFcn = 
        function()
            coroutine.yield(enemy.slashCooldown)
            enemy.canBeSlashed = true
        end
    
    function enemy:takeDamage(otherObj, angle)
        enemy.canBeSlashed = false
        enemy:startCoroutine(enemy.slashCooldownFcn, "slashCooldownFcn")
        enemy.currentHP = enemy.currentHP - 1
        if enemy.currentHP <= 0 then
            enemy:die(otherObj)
        end
    end

    function enemy:die(otherObj)
        enemy:setInactive()
    end

    table.insert(gameState.allEnemies, enemy)
    return enemy
end

function createEnemyLauncher(x, y, vx, vy, speed, gameState)
    local launcher = createBasicEnemy(x, y, gameState, 7)
    Animation.addAnimation(launcher, {0,0}, 0.2, 2, true)
    Animation.addAnimation(launcher, {1,2,0}, 0.1, 3, false,
        function(obj)
            Animation.changeAnimation(launcher, 2) 
        end)
    Animation.changeAnimation(launcher, 2)
    launcher.slashCooldown = 1 -- Increase the cooldown to prevent people accidentally re-slashing it
    launcher.rotation = math.atan2(vy,vx)
    launcher.shotVelocity = clampVecToLength(vx, vy, speed)
    launcher.currentEnemy = nil
    launcher.enemyVisuals = GameObjects.newGameObject(4, launcher.x, launcher.y, 0, true)
    Animation.addAnimator(launcher.enemyVisuals)
    Animation.addAnimation(launcher.enemyVisuals, {0,1,2,3,4}, 0.1, 1, true)
    
    function launcher:takeDamage(otherObj, angle)
        if launcher.currentEnemy then
            -- TODO fx for deleting the old enemy
            launcher.currentEnemy:setInactive()
        end
        createCircularPop(launcher.x, launcher.y, {1,1,1}, 6, 20, 1, 0.3, 0.25, true)
        ParticleSystem.burst(launcher.x, launcher.y, 10, 300, 600, {1,1,1,1}, 4, 0.8, 0.8, false, 0.4)
        launcher.currentEnemy = createBasicEnemy(launcher.x, launcher.y, gameState)
        Physics.addRigidBody(launcher.currentEnemy, launcher.shotVelocity)
        local jiggleVec = clampVecToLength(vx, vy, 3)
        Camera.jiggle(jiggleVec.x, jiggleVec.y)
        Animation.changeAnimation(launcher, 3)
    end

    function launcher:setInactive()
        launcher.active = false
        launcher.enemyVisuals:setInactive()
    end

    return launcher
end

function setMovementBetweenBounds(enemy, speed, acceleration, bound1, bound2)
    local velocityDir = {x=bound2.x-bound1.x,y=bound2.y-bound1.y}
    local moveTime = math.sqrt(velocityDir.x^2 + velocityDir.y^2) / speed
    local velocity = clampVecToLength(velocityDir.x, velocityDir.y, speed)
    Physics.addRigidBody(enemy, velocity, acceleration)
    
    enemy.moveBetweenBoundsFunction = 
        function()
            while(true) do
                coroutine.yield(moveTime)
                enemy.RigidBody.velocity.x = -enemy.RigidBody.velocity.x
                enemy.RigidBody.velocity.y = -enemy.RigidBody.velocity.y
            end
        end
    enemy.x = bound1.x
    enemy.y = bound1.y
    enemy:startCoroutine(enemy.moveBetweenBoundsFunction, "moveBetweenBounds")
end

function createEnemySpawner(enemyWaves, spawnerDependent)
    local enemySpawner = GameObjects.newGameObject(-1, 0, 0, 0, true)
    enemySpawner.waves = enemyWaves
    enemySpawner.numEnemiesAlive = 0
    enemySpawner.waveIndex = 1
    enemySpawner.done = false
    function enemySpawner:decrementEnemies()
        enemySpawner.numEnemiesAlive = enemySpawner.numEnemiesAlive - 1
        if enemySpawner.numEnemiesAlive <= 0 then
            -- spawn a wave
            if enemySpawner.waveIndex <= #enemySpawner.waves then
                enemySpawner:startCoroutine(enemySpawner.spawnWave, "spawnWave")
            elseif not enemySpawner.done then
                enemySpawner.done = true
                for k = 1,#spawnerDependent do
                    if spawnerDependent[k].active then
                        spawnerDependent[k]:setInactive()
                    else
                        spawnerDependent[k]:setActive()
                    end
                    createCircularPop(spawnerDependent[k].x, spawnerDependent[k].y, {1,1,1}, 30, 60, 1, 0.2, 0.1, true)
                end
            end
        end
    end

    enemySpawner.spawnWave =
        function()
            local currentWave = enemySpawner.waves[enemySpawner.waveIndex]
            enemySpawner.numEnemiesAlive = #currentWave
            coroutine.yield(1)
            for k = 1,#currentWave do
                Camera.shake(3)
                enemySpawnerFX(currentWave[k].x, currentWave[k].y)
                coroutine.yield(0.8)
                currentWave[k]:setActive()
            end
            enemySpawner.waveIndex = enemySpawner.waveIndex + 1
        end

    -- set the enemy spawner of all relevant enemies
    for k = 1,#enemySpawner.waves do
        for k2 = 1,#enemySpawner.waves[k] do
            enemySpawner.waves[k][k2].spawner = enemySpawner
        end
    end

    enemySpawner:startCoroutine(enemySpawner.spawnWave, "spawnWave")

    return enemySpawner
end

function enemySpawnerFX(x, y)
    local fx = GameObjects.newGameObject(-1, x, y, 0, true, GameObjects.DrawLayers.PARTICLES)
    fx.radius = 10

    function fx:update(dt)
        fx.radius = fx.radius - dt * 10
    end

    function fx:draw()
        love.graphics.setColor(1,0,1,1)
        love.graphics.circle("line", fx.x, fx.y, fx.radius)
        love.graphics.setColor(0,0,0,1)
        love.graphics.circle("fill", fx.x, fx.y, fx.radius-1)
    end

    fx.coolFX =
        function()
            SoundManager.playSound("GhostIncoming2")
            SoundManager.playSound("death2")
            for k = 1,3 do
                fx.radius = fx.radius + 6 + 2*k
                coroutine.yield(0.2)
            end
            coroutine.yield(0.2)
            createCircularPop(fx.x, fx.y, {1,1,1}, fx.radius-10, 80, 1, 0.2, 0.1, true)
            SoundManager.playSound("GhostPopSpawn")
            Camera.shake(3)
            fx:setInactive()
        end
    fx:startCoroutine(fx.coolFX, "coolFX")
    return fx
end

function createShieldingEnemy(x, y, parent, gameState)
    local enemy = createBasicEnemy(x, y, gameState)
    enemy.parent = parent
    enemy.slashCooldown = 1
    function enemy:takeDamage(otherObj, angle)
        enemy.canBeSlashed = false
        enemy:startCoroutine(enemy.slashCooldownFcn, "slashCooldownFcn")
        enemy.parent:unShield(enemy)
    end
    return enemy
end

function createOrbitingEnemy(parent, radius, rotationSpeed, gameState)
    local enemy = createShieldingEnemy(parent.x, parent.y, parent, gameState)
    enemy.radius = radius
    enemy.totalTime = 0
    enemy.target = {x=parent.x, y=parent.y}
    function enemy:update(dt)
        enemy.totalTime = enemy.totalTime + dt
        enemy.target.x = parent.x + math.cos(enemy.totalTime * rotationSpeed * -1) * enemy.radius
        enemy.target.y = parent.y + math.sin(enemy.totalTime * rotationSpeed * -1) * enemy.radius

        enemy.x = (enemy.target.x - enemy.x) * dt * 10 + enemy.x
        enemy.y = (enemy.target.y - enemy.y) * dt * 10 + enemy.y
    end
    return enemy
end

function createShooterEnemy(x, y, plr, gameState, leftBound, rightBound, centerBound, maxHP, startingState)
    local enemy = createBasicEnemy(x, y, gameState)
    Animation.addAnimation(enemy, {10,11,12,13,14,15}, 0.1, 2, true)
    Animation.addAnimation(enemy, {16,17,18,19}, 0.2, 3, true)
    enemy.active = false
    enemy.maxHP = maxHP or 1
    enemy.currentHP = enemy.maxHP
    Physics.addRigidBody(enemy)
    enemy.spawner = nil
    enemy.left = true
    enemy.trailer = createDashTrailer(enemy, 4, 15, 0.2, true)
    
    if startingState == 2 then
        local shielder = createShieldingEnemy(enemy.x, enemy.y - 50, enemy, gameState)
        function shielder:update(dt)
            shielder.x = enemy.x
            shielder.y = enemy.y - 50
        end
        enemy.orbiter = shielder
        Animation.changeAnimation(enemy, 3)
    else
        enemy.orbiter = createOrbitingEnemy(enemy, 70, 0.75, gameState)
        Animation.changeAnimation(enemy, 2)
    end
    enemy.shieldVisuals = createEnemyShieldVisuals(enemy, enemy.orbiter)
    enemy.canBeSlashed = false
    enemy.orbiter.active = false
    enemy.speed = 33
    enemy.numVolleys = 3
    enemy.numRadialVolleys = 2
    enemy.warningTime = 0.5
    enemy.shotSpeed = 180
    enemy.radialShotSpeed = 140
    enemy.missileSpeed = 100
    enemy.postAttackTime = 1.5
    enemy.numRadialShots = 8
    enemy.reshieldTime = 5
    enemy.state = startingState or 0
    enemy.boundCounter = 1
    enemy.reShield = 
        function()
            coroutine.yield(enemy.reshieldTime)
            enemy.canBeSlashed = false
        end
    enemy.missileMove = 
        function()
            local sgn = enemy.x > centerBound.x and -1 or 1
            while(true) do
                enemy.RigidBody.velocity.x = 40 * sgn
                coroutine.yield(5)
                sgn = sgn * -1
            end
        end
    enemy.missileLaunch = 
        function()
            while(true) do
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(0.5)
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(0.5)
                SoundManager.playSound("ProjectileShot")
                createEnemyProjectile(enemy, plr, gameState)
                coroutine.yield(1.5)
            end
        end
    enemy.radialShot = 
        function()
            enemy.RigidBody.velocity.x = 0
            dashEnemyToPosition(enemy, centerBound.x, centerBound.y)
            coroutine.yield(0.75)
            ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
            SoundManager.playSound("charge")
            coroutine.yield(enemy.warningTime * 2)
            ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
            SoundManager.playSound("charge")
            coroutine.yield(enemy.warningTime * 2)
            local angle = 0
            for k1 = 1,enemy.numRadialVolleys do
                for k = 1,enemy.numRadialShots do
                    createProjectile(enemy.x, enemy.y, enemy.x + math.cos(math.rad(angle)), enemy.y + math.sin(math.rad(angle)), enemy.radialShotSpeed, 6, 2)
                    angle = angle + 360/enemy.numRadialShots
                end
                SoundManager.playSound("ProjectileShot")
                coroutine.yield(enemy.warningTime * 3)
            end
            coroutine.yield(enemy.warningTime * 2)
            coroutine.yield(enemy.postAttackTime)
            enemy.stateSelector()
        end
    enemy.tripleShot = 
        function()
            if enemy.left then
                dashEnemyToPosition(enemy, leftBound.x, leftBound.y)
            else
                dashEnemyToPosition(enemy, rightBound.x, rightBound.y)
            end
            coroutine.yield(0.75)
            enemy.RigidBody.velocity.x = enemy.speed * (enemy.left and 1 or -1)
            enemy.left = not enemy.left
            for k = 1,enemy.numVolleys do
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(enemy.warningTime)
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(enemy.warningTime)
                for k2 = 1,2 do
                    createProjectile(enemy.x, enemy.y, plr.x, plr.y, enemy.shotSpeed, 6, 2)
                    createProjectile(enemy.x, enemy.y, plr.x+20, plr.y, enemy.shotSpeed, 6, 2)
                    createProjectile(enemy.x, enemy.y, plr.x-20, plr.y, enemy.shotSpeed, 6, 2)
                    SoundManager.playSound("ProjectileShot")
                    coroutine.yield(enemy.warningTime)
                end
                coroutine.yield(enemy.warningTime)
            end
            coroutine.yield(enemy.warningTime * 2)
            enemy.RigidBody.velocity.x = 0
            coroutine.yield(enemy.postAttackTime)
            enemy.stateSelector()
        end
    enemy.dualShot = 
        function()
            local selections = {leftBound, centerBound, rightBound}
            while (true) do
                dashEnemyToPosition(enemy, selections[enemy.boundCounter].x, selections[enemy.boundCounter].y)
                coroutine.yield(0.75)
                -- Double shot
                for k = 1,2 do
                    SoundManager.playSound("charge")
                    ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                    coroutine.yield(enemy.warningTime)
                    createProjectile(enemy.x, enemy.y, plr.x, plr.y, enemy.shotSpeed, 6, 2)
                    createProjectile(enemy.x, enemy.y, plr.x+20, plr.y, enemy.shotSpeed, 6, 2)
                    createProjectile(enemy.x, enemy.y, plr.x-20, plr.y, enemy.shotSpeed, 6, 2)
                    SoundManager.playSound("ProjectileShot")
                    coroutine.yield(enemy.warningTime)
                end
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(enemy.warningTime)
                SoundManager.playSound("charge")
                ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                coroutine.yield(enemy.warningTime)
                local angle = 0
                for k = 1,enemy.numRadialShots do
                    createProjectile(enemy.x, enemy.y, enemy.x + math.cos(math.rad(angle)), enemy.y + math.sin(math.rad(angle)), enemy.radialShotSpeed, 6, 2)
                    angle = angle + 360/enemy.numRadialShots
                end
                SoundManager.playSound("ProjectileShot")
                coroutine.yield(enemy.warningTime * 3)
                enemy.boundCounter = enemy.boundCounter + 1
                if enemy.boundCounter > 3 then
                    enemy.boundCounter = 1
                end
            end
        end
    enemy.stateSelector =
        function()
            if enemy.state == 0 then
                enemy:startCoroutine(enemy.tripleShot, "tripleShot")
                enemy.state = 1
            elseif enemy.state == 1 then
                enemy:startCoroutine(enemy.radialShot, "radialShot")
                enemy.state = 0
            elseif enemy.state == 2 then
                enemy:startCoroutine(enemy.missileMove, "missileMove")
                enemy:startCoroutine(enemy.missileLaunch, "missileLaunch")
            elseif enemy.state == 3 then
                enemy:startCoroutine(enemy.dualShot, "dualShot")
            end
        end
    enemy.go =
        function()
            coroutine.yield(1.0)
            enemy.stateSelector()
        end

    function enemy:die(otherObj)
        enemy.spawner:decrementEnemies()
        -- TODO spawn a cool corpse and slow the game down for a few frames
        if startingState == 2 then
            SoundManager.playSound("GhostDie7")
        else
            SoundManager.playSound("FallenSoldierDie")
        end
        enemy:setInactive()
        enemy.orbiter:setInactive()
        enemy.shieldVisuals:setInactive()
    end

    function enemy:unShield()
        enemy.canBeSlashed = true
        enemy:startCoroutine(enemy.reShield ,"reShield")
    end

    function enemy:setActive()
        enemy:startCoroutine(enemy.go, "go")
        enemy.orbiter.active = true
        enemy.active = true
        enemy.shieldVisuals.active = true
        if startingState == 2 then
            SoundManager.playSound("GhostSpawn7")
        else
            SoundManager.playSound("FallenSoldierSpawn")
        end
    end

    return enemy
end

function createEnemyShieldVisuals(enemy, shieldObj)
    local shieldVisuals = GameObjects.newGameObject(-1, 0, 0, 0, false, GameObjects.DrawLayers.PARTICLES)
    shieldVisuals.enemy = enemy
    shieldVisuals.shieldObj = shieldObj
    function shieldVisuals:draw()
        if not shieldVisuals.enemy.canBeSlashed then
            love.graphics.setColor(1,1,1,0.1)
            love.graphics.circle('fill', shieldVisuals.enemy.x, shieldVisuals.enemy.y, 10)
            love.graphics.setColor(1,1,1,0.7)
            love.graphics.circle('line', shieldVisuals.enemy.x, shieldVisuals.enemy.y, 11)
            love.graphics.setColor(1,1,1,0.7)
            love.graphics.line(shieldVisuals.enemy.x, shieldVisuals.enemy.y, shieldVisuals.shieldObj.x, shieldVisuals.shieldObj.y)
        end
    end
    return shieldVisuals
end

function createAlertEnemyTrigger(x, y, width, height, enemy)
    local trigger = createEntryExitTrigger(x, y, width, height, 
        function()
            enemy.alerted = true
        end,
        function()
            enemy.alerted = false
        end)
    return trigger
end

function createAlertedEnemy(x, y, plr, gameState, startupDelay)
    local enemy = createBasicEnemy(x, y, gameState)
    Animation.addAnimation(enemy, {20,21,22,23}, 0.2, 2, true)
    Animation.changeAnimation(enemy, 2)
    enemy.startupDelay = startupDelay or 0
    enemy.shieldSource = nil
    enemy.reshieldTime = 10
    enemy.shotSpeed = 200
    enemy.warningTime = 0.65
    enemy.alerted = false
    enemy.canBeSlashed = false
    enemy.maxHP = 1
    enemy.shieldVisuals = nil
    enemy.currentHP = enemy.maxHP
    enemy.deactivators = {}
    enemy.attackRoutine = 
        function()
            coroutine.yield(enemy.startupDelay)
            while(true) do
                if enemy.alerted then
                    SoundManager.playSound("charge", 0.5)
                    ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                    coroutine.yield(enemy.warningTime)
                    createProjectile(enemy.x, enemy.y, plr.x, plr.y, enemy.shotSpeed, 6, 4)
                    SoundManager.playSound("ProjectileShot")
                    coroutine.yield(enemy.warningTime)
                else
                    coroutine.yield(0.5)
                end
            end
        end
    enemy.reShield = 
        function()
            coroutine.yield(enemy.reshieldTime)
            enemy.canBeSlashed = false
        end
    function enemy:unShield()
        enemy.canBeSlashed = true
        enemy:startCoroutine(enemy.reShield ,"reShield")
    end


    function enemy:die(otherObj)
        -- TODO spawn a cool corpse and slow the game down for a few frames
        enemy:setInactive()
        SoundManager.playSound("GhostDie7")
    end

    function enemy:setInactive()
        if enemy.shieldSource then
            enemy.shieldSource.active = false
        end
        enemy.active = false
        if enemy.shieldVisuals then
            enemy.shieldVisuals.active = false
        end
        for k = 1,#enemy.deactivators do
            enemy.deactivators[k]:setInactive()
        end
    end

    enemy:startCoroutine(enemy.attackRoutine, "attackRoutine")

    return enemy
end

function createBlastingEnemy(x, y, plr, gameState)
    local enemy = createAlertedEnemy(x, y, plr, gameState, x > 200 and 1 or 0)
    enemy.alerted = true
    enemy.shotSpeed = 160
    enemy.warningTime = 1
    return enemy
end

function createEnemyProjectile(enemy, plr, gameState)
    local proj = createProjectile(enemy.x, enemy.y, plr.x, plr.y, enemy.missileSpeed, 4, 4)
    function proj:draw()
        -- no op
    end
    local enemyShot = createBasicEnemy(enemy.x, enemy.y, gameState)
    enemyShot.flip = -1
    Animation.addAnimation(enemyShot, {24,25,26,27}, 0.1, 2, true)
    enemyShot.rotation = math.atan2(enemy.y-plr.y,enemy.x-plr.x)
    Animation.changeAnimation(enemyShot, 2)
    enemyShot.maxHP = 1
    enemyShot.currentHP = 1
    function enemyShot:setInactive()
        enemyShot.active = false
        proj:setInactive()
    end
    function enemyShot:update(dt)
        enemyShot.x = proj.x
        enemyShot.y = proj.y
        if not proj.active then
            enemyShot:setInactive()
        end
    end
end

function createMissileEnemy(x, y, plr, gameState)
    local enemy = createAlertedEnemy(x, y, plr, gameState)
    Animation.addAnimation(enemy, {16,17,18,19}, 0.2, 3, true)
    Animation.changeAnimation(enemy, 3)
    enemy.missileSpeed = 80
    enemy.warningTime = 0.5
    enemy.postMissileTime = 3
    enemy.canBeSlashed = true
    enemy.attackRoutine =
        function()
            while(true) do
                if enemy.alerted then
                    SoundManager.playSound("charge")
                    ParticleSystem.charge(enemy.x, enemy.y, 10, 100, 300, {1,0,1}, 3, 0.9, false, 0.3, 30)
                    coroutine.yield(enemy.warningTime)
                    SoundManager.playSound("ProjectileShot")
                    createEnemyProjectile(enemy, plr, gameState)
                    coroutine.yield(enemy.postMissileTime)
                else
                    coroutine.yield(0.5)
                end
            end
        end
    enemy:startCoroutine(enemy.attackRoutine, "attackRoutine")
    return enemy
end

function dashEnemyToPosition(enemy, x, y)
    enemy.trailer:trailFromTo({x=enemy.x,y=enemy.y},{x=x,y=y}, 10)
    enemy.x = x
    enemy.y = y
end

function getClosestEnemyInFacingDir(x, y, range, gameState, facingDir, excludeLaunchers)
    local enemy = nil
    local minDist = range * range -- square distance
    local currDist = minDist
    local currentEnemy = nil
    for k = 1,#gameState.allEnemies do
        currentEnemy = gameState.allEnemies[k]
        if currentEnemy.active then
            if (facingDir > 0 and currentEnemy.x > x)
            or (facingDir < 0 and currentEnemy.x < x) then
                if excludeLaunchers and currentEnemy.shotVelocity then
                    -- print('avoided slashing launcher')
                    -- Leaving this comment in just to give us a better idea of the logic for this code.
                else
                    currDist = squareDistance({x=x,y=y},{x=currentEnemy.x, y=currentEnemy.y})
                    if currDist < minDist and currentEnemy.canBeSlashed then
                        minDist = currDist
                        enemy = currentEnemy
                    end
                end
            end
        end
    end
    return enemy
end

function getClosestEnemyWithinRange(x, y, range, gameState, excludeLaunchers)
    local enemy = nil
    local minDist = range * range -- square distance
    local currDist = minDist
    local currentEnemy = nil
    for k = 1,#gameState.allEnemies do
        currentEnemy = gameState.allEnemies[k]
        if currentEnemy.active then
            if excludeLaunchers and currentEnemy.shotVelocity then
                -- print('avoided slashing launcher')
                -- Leaving this comment in just to give us a better idea of the logic for this code.
            else
                currDist = squareDistance({x=x,y=y},{x=currentEnemy.x, y=currentEnemy.y})
                if currDist < minDist and currentEnemy.canBeSlashed then
                    minDist = currDist
                    enemy = currentEnemy
                end
            end
        end
    end
    return enemy
end

function velocityLines(centerX, centerY, rotation, speed)
    local fallingLineGenerator = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.PLAYER)
    local fallingLineInterval = 0.01
    fallingLineGenerator.interval = fallingLineInterval
    local widthBounds = {1,3}
    local fallingSpeed = speed or 8000
    local boundsSize = 140
    local minBound = 40
    local heightBounds = {40,80}
    local yStart = -180
    function fallingLineGenerator:update(dt)
        fallingLineGenerator.interval = fallingLineGenerator.interval - dt
        if fallingLineGenerator.interval < 0 then
            createFallingLine(randomBetween(-boundsSize,-minBound),yStart,randomBetween(widthBounds[1],widthBounds[2]),randomBetween(heightBounds[1],heightBounds[2]),fallingSpeed,0.5, centerX, centerY, rotation)
            createFallingLine(randomBetween(minBound,boundsSize),yStart,randomBetween(widthBounds[1],widthBounds[2]),randomBetween(heightBounds[1],heightBounds[2]),fallingSpeed,0.5, centerX, centerY, rotation)
            fallingLineGenerator.interval = fallingLineInterval
        end
    end
    return fallingLineGenerator
end

function epicDeath(enemy, plr, gameState, tx)
    local routineObj = GameObjects.newGameObject(-1,0,0,0,true)
    routineObj.coolRoutine = 
        function()
            local whiteFlasher = createScreenFlash({1,1,1,1}, 30, false, GameObjects.DrawLayers.ABOVETILES, true, tx)
            local whiteCoverup = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.POSTCAMERA)
            function whiteCoverup:draw()
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle('fill',0, windowHeight - 20, 80, 40)
            end
            if plr.triangleSlashFX then
                plr.triangleSlashFX.color = {0,0,0}
            end
            if enemy.capeManager then
                for k = 1,#enemy.capeManager.capeSegments do
                    enemy.capeManager.capeSegments[k]:setInactive()
                end
            end
            plr.slashObj.color = {0,0,0}
            SoundManager.playSound("BossFinish1")
            gameState.timeScale = 0.1
            local lines = velocityLines(enemy.x, enemy.y, math.rad(plr.lastSlashAngle + 90))
            SoundManager.playSound("WhitenBackground")
            coroutine.yield(0.1)
            whiteCoverup:setInactive()
            gameState.timeScale = 1
            whiteFlasher:setInactive()
            createScreenFlash({1,1,1,1}, 0.5, true, GameObjects.DrawLayers.ABOVETILES, true)
            lines:setInactive()
            plr.slashObj.color = {1,1,1}
        end
    routineObj:startCoroutine(routineObj.coolRoutine, "coolRoutine")
end