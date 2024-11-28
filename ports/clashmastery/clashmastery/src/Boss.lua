local bossWhiteShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 outputColor = Texel(tex, texture_coords) * color;
        // add a bunch to the sprite to make it white
        outputColor += vec4(0.3, 0.3, 0.3,0);
        return outputColor;
    }
]]

local boss
local stageMinX = 3
local stageMaxX = 61
local attackParams = {
    slamShockwaveSpeed = 100,
    lightningSpeed = 40,
    dualSlashWarning = 0.5,
    postAttackTime = 2,
    shockwaveSlamWarning = 0.5,
    darkOrbWarning = 0.5,
    redOrbWarning = 0.5,
    lightningSlamWarning = 0.75,
    numHomingProjectiles = 3,
    homingProjectileSpeed = 70,
    interHomingProjectileTime = 0.85,
    homingProjectileArmTime = 2.5,
    numRedProjectiles = 2,
    redProjectileWarning = 0.75,
    interRedProjectileTime = 0.5,
    redProjectileArmDelay = 1.5,
    redProjectileFallWarning = 0.5,
    redProjectileSpeed = 250,
    preLaserTime = 1,
    laserRotateSpeed = 2.5,
    laserRotateTime = 5,
    laserMoveSpeed = 25,
    redLaserPreWarning = 0.75,
    skyLaserWidth = 10,
    numSkyLasers = 3,
    numSkyLasersAcross = 3,
    numRadahnSlams = 4,
    interRadahnSlamDelay = 0.2,
    radahnLightningSpeed = 30
}
function createBoss(x, y, hp, phase2)
    boss = GameObjects.newGameObject(2, x, y, 0, true, GameObjects.DrawLayers.BOSS)
    boss.currentHP = hp
    boss.maxHP = hp
    if gameState.state.justGotBackUp then
        local healthToRegen = (gameState.state.bossHealthPreviousAttempt - gameState.state.bossHealthOnDeath) * gameState.state.bossRegenOnDeath
        boss.currentHP = healthToRegen + gameState.state.bossHealthOnDeath
    else
        boss.currentHP = boss.maxHP
    end
    boss.dying = false
    gameState.state.bossHealthPreviousAttempt = boss.currentHP
    Collision.addCircleCollider(boss, 6, Collision.Layers.BOSS, {Collision.Layers.PLAYER_ATTACK})
    boss.Collider.onCollisionEnter = bossCollision
    Physics.addRigidBody(boss)
    boss.floorY = y
    Animation.addAnimator(boss)
    Animation.addAnimation(boss, {0,0,0,0,0,1,2,1,0,0,0,0,1,2,3,4,3,4,3,2,1}, 0.1, "idle", true)
    Animation.addAnimation(boss, {32,33,34,35,36,37}, 0.1, "battlestance", true)
    Animation.addAnimation(boss, {5}, 0.1, "downslash_prep1", true)
    Animation.addAnimation(boss, {6}, 0.1, "downslash_prep2", true)
    Animation.addAnimation(boss, {5,7,8,9,10,10,11,11}, 0.08, "downslash", false,
        function(boss)
            Animation.changeAnimation(boss, "postsworddown")
        end)
    Animation.addAnimation(boss, {10,11}, 0.2, "postsworddown", true)
    Animation.addAnimation(boss, {13}, 0.1, "upslash_prep1", true)
    Animation.addAnimation(boss, {14}, 0.1, "upslash_prep2", true)
    Animation.addAnimation(boss, {13,15,16,17,18,19,20}, 0.08, "upslash", false,
        function(boss)
            Animation.changeAnimation(boss, "postupslash")
        end)
    Animation.addAnimation(boss, {20,19}, 0.35, "postupslash", true)
    Animation.addAnimation(boss, {21,22,23,24,25}, 0.1, "slamprep_1", false,
        function(boss)
            Animation.changeAnimation(boss, "slamprep_1loop")
        end)
    Animation.addAnimation(boss, {24,25}, 0.1, "slamprep_1loop", true)
    Animation.addAnimation(boss, {26,27,28,27}, 0.1, "slamprep_2", true)
    Animation.addAnimation(boss, {29,30,31}, 0.1, "slam", false,
        function(boss)
            Animation.changeAnimation(boss, "postsworddown")
        end)
    Animation.addAnimation(boss, {38,39,40,41,42,43}, 0.1, "float", true)
    Animation.addAnimation(boss, {44,45,46,47,48,49}, 0.1, "float_noarm", true)
    Animation.addAnimation(boss, {50,51,52}, 0.1, "rasengan", true)
    Animation.addAnimation(boss, {53,54,55,56,56,56,56}, 0.1, "rasengan_crash", false,
        function(boss)
            Animation.changeAnimation(boss, "float")
        end)
    Animation.addAnimation(boss, {14,58,59,60,61,62}, 0.1, "swordthrow", false,
        function(boss)
            Animation.changeAnimation(boss, "postswordthrow")
        end)
    Animation.addAnimation(boss, {63,62}, 0.35, "postswordthrow", true)
    Animation.addAnimation(boss, {64}, 1, "nosword_rasen", true)
    Animation.addAnimation(boss, {65,66,67,66}, 0.1, "upwardprep", true)
    Animation.addAnimation(boss, {68,69,70,71,72}, 0.1, "upwardpulse", false,
        function(boss)
            Animation.changeAnimation(boss, "upwardprep")
        end)

    boss.fakeArm = GameObjects.newGameObject(3,0,0,1,false,GameObjects.DrawLayers.PARTICLES)

    boss.phase2 = phase2
    boss.dashTrailer = createDashTrailer(boss, 2, 15, 0.2, true, GameObjects.DrawLayers.PARTICLES)
    boss.target = {x=0,y=0} -- can be the player OR a target dummy
    boss.hitbox = createSlashHitbox()
    boss.squashStretcher = createSquashStretcher(boss, 10)
    GameObjects.attachComponent(boss, boss.squashStretcher)
    boss.solid = false -- if true, the player can't walk through
    boss.shockwaveSlamming = false
    boss.lightningSlamming = false
    boss.radahnSlamming = false
    boss.shockwavePool = createPool(6, createShockwave)
    boss.lightningPool = createPool(6, createLightning)
    boss.clonePool = createPool(6, createRadahnClone)
    boss.shockwaveHitbox = createCircleHitbox(9)
    boss.shockwaveHitbox.undeflectable = true
    boss.shockwaveWarning = createFadingRectangle2(0,0,18,64,global_pallete.red_color,0.3)
    boss.lightningSlamWarning = createFadingRectangle2(0,0,18,64,global_pallete.black_color,0.3)
    boss.lightningSlamHitbox = createCircleHitbox(9)
    boss.darkOrb = createOrb(8, true)
    boss.redOrb = createOrb(8, false)
    boss.trackingTarget = false
    boss.trackOffset = 12
    boss.darkOrbOffset = 17
    boss.redOrbOffset = 9
    boss.trackDarkOrb = false
    boss.rotateDarkOrb = false
    boss.orbRotateSpeed = 7
    boss.redOrbRotateSpeed = 7
    boss.trackRedOrb = false
    boss.rotateRedOrb = false
    boss.rasenganing = false
    boss.lineEmitter = ParticleSystem.createEmitter(50, true, GameObjects.DrawLayers.PARTICLES)
    boss.sword = createSword()
    boss.hurtWhiteTime = 0
    boss.circleFloating = false
    boss.circleAnchor = {x=32,y=24}
    boss.circleFloatRadius = 16
    boss.circleFloatSpeed = 0.85
    boss.homingProjectilePool = createPool(8, createHomingProjectile)
    boss.redProjectilePool = createPool(6, createRedProjectile)
    boss.laserSpinner = createLaserSpinner(boss.sword, attackParams.laserRotateSpeed, 6, 1)
    boss.initialSkyLaser = createScalingRectangle("vertical", 0, 12, global_pallete.red_color, 0.3, GameObjects.DrawLayers.PARTICLES)
    boss.initialSkyLaser.height = 64
    boss.skyLaserPool = createPool(10, createSkyLaser)
    boss.hpBar = createHealthbar(56)
    boss.makeSkyLaserWarning =
        function()
            return createFadingRectangle2(0,0,attackParams.skyLaserWidth,64,global_pallete.red_color,0.3)
        end
    boss.skyLaserWarningPool = createPool(10, boss.makeSkyLaserWarning)

    function boss:draw() -- override so we can use a shader
        if boss.hurtWhiteTime > 0 then
            love.graphics.setShader(bossWhiteShader)
        end
        Texture.draw(boss.texture, boss.spr, boss.x, boss.y, boss.flip, boss.flipY, boss.alpha,boss.color,boss.rotation,boss.cachedQuad, boss.scaleX, boss.scaleY)
        love.graphics.setShader()
    end

    function boss:update(dt)
        -- TODO remove, testing boss attacks
        if debugMode then
            if Input.getButtonPressed("1") then
                boss:startCoroutine(dualSlashSlam, "dualSlashSlam")
            end
            if Input.getButtonPressed("2") then
                boss:startCoroutine(darkOrbRasenganLightning, "darkOrbRasenganLightning")
            end
            if Input.getButtonPressed("3") then
                boss:startCoroutine(homingProjectilesRedProjectile, "homingProjectilesRedProjectile")
            end
            if Input.getButtonPressed("4") then
                boss:startCoroutine(lightningDiveLaserSpin, "lightningDiveLaserSpin")
            end
            if Input.getButtonPressed("5") then
                boss:startCoroutine(dualSlashTripleSlam, "dualSlashTripleSlam")
            end
            if Input.getButtonPressed("6") then
                boss:startCoroutine(
                    function()
                        lightningSlam(attackParams.lightningSlamWarning, 48, 16, 5, true)
                    end
                , "radahnSlams")
            end
        end
        if boss.shockwaveSlamming and boss.y > boss.floorY then
            Physics.zeroVelocity(boss)
            Physics.zeroAcceleration(boss)
            boss.shockwaveSlamming = false
            boss.solid = true
            boss.y = boss.floorY
            boss.dashTrailer.trailing = false
            boss.shockwaveHitbox.x, boss.shockwaveHitbox.y = boss.x, boss.y
            boss.shockwaveHitbox:setActive()
            ParticleSystem.burst(boss.x, boss.y, 15, 400, 500, global_pallete.red_color, 5, 0.95, 0.75, false, 0.5)
            Animation.changeAnimation(boss, "slam")
            Camera.jiggle(0, -0.5)
            boss.color = global_pallete.white_color
            -- create two shockwaves
            for k = 1,2 do
                local shockwave = boss.shockwavePool:getFromPool()
                local dir = k % 2 == 0 and 1 or -1
                shockwave.flip = dir
                if boss.isTutorial then
                    shockwave:activate(boss.x, boss.floorY, attackParams.slamShockwaveSpeed * dir * 0.75)
                else
                    shockwave:activate(boss.x, boss.floorY, attackParams.slamShockwaveSpeed * dir)
                end
            end
            SoundManager.playSound("BossLandHeavy")
        end
        if boss.lightningSlamming and boss.y > boss.floorY then
            Physics.zeroVelocity(boss)
            Physics.zeroAcceleration(boss)
            boss.lightningSlamming = false
            boss.solid = true
            boss.y = boss.floorY
            boss.dashTrailer.trailing = false
            boss.lightningSlamHitbox.x, boss.lightningSlamHitbox.y = boss.x, boss.y
            boss.lightningSlamHitbox:setActive()
            ParticleSystem.lineBurst(boss.x, boss.y, 15, 400, 500, global_pallete.black_color, 7, 0.95, 0.8, false, 0.5, boss.lineEmitter)
            Animation.changeAnimation(boss, "slam")
            Camera.jiggle(0, -0.5)
            boss.color = global_pallete.white_color
            -- create a bolt of lightning
            local lightning = boss.lightningPool:getFromPool()
            SoundManager.playSound("LightningStrike")
            local dir = boss.x > 32 and -1 or 1
            lightning.RigidBody.velocity.x = dir * (boss.radahnSlamming and attackParams.radahnLightningSpeed or attackParams.lightningSpeed)
            lightning.x, lightning.y = boss.x, 32
            lightning.dir = dir
            lightning:setActive()
            boss.radahnSlamming = false
            SoundManager.playSound("BossLandLight")
        end
        local dir = boss.x > boss.target.x and 1 or -1
        if boss.trackingTarget then
            boss.x, boss.y = clamp(stageMinX, boss.target.x + boss.trackOffset * dir, stageMaxX), boss.target.y
        end
        if boss.trackDarkOrb then
            boss.darkOrb.x, boss.darkOrb.y = boss.x, boss.y + boss.darkOrbOffset
            boss.fakeArm.x, boss.fakeArm.y = boss.x - boss.flip * 2, boss.y - 1
            boss.fakeArm.rotation = math.pi/2
        elseif boss.rotateDarkOrb then
            orbitalMotion(boss.darkOrb, boss, boss.darkOrbOffset, -dir * boss.orbRotateSpeed, dt)
            boss.fakeArm.x, boss.fakeArm.y = boss.x - boss.flip * 2, boss.y - 1
            if boss.darkOrb.active then
                boss.fakeArm.rotation = boss.darkOrb.orbitalTime * -dir * boss.orbRotateSpeed + boss.darkOrb.orbitalOffset
            end
        end
        if boss.rotateRedOrb then
            -- stop the orb once it's at the opposite side
            if boss.redOrb.orbitalTime >= math.pi / boss.redOrbRotateSpeed then
                boss.rotateRedOrb = false
            else
                orbitalMotion(boss.redOrb, boss, boss.redOrbOffset, boss.flip * boss.redOrbRotateSpeed, dt)
            end
        end
        if boss.trackRedOrb then
            boss.redOrb.x, boss.redOrb.y = boss.x + boss.flip * boss.redOrbOffset, boss.y
        end
        if boss.rasenganing then
            -- crash into the wall
            local stageCrashOffset = 2
            if (boss.flip == 1 and boss.x > stageMaxX - stageCrashOffset) or (boss.flip == -1 and boss.x < stageMinX + stageCrashOffset) then
                boss.squashStretcher:squashStretch(0.5, 2)
                Physics.zeroVelocity(boss)
                Physics.zeroAcceleration(boss)
                Camera.jiggle(boss.flip * 0.4, 0)
                boss.redOrb:die()
                ParticleSystem.burst(boss.x + boss.flip * 3, boss.y, 10, 300, 400, global_pallete.red_color, 5, 0.95, 0.8, false, 0.5)
                boss.rasenganing = false
                boss.x = clamp(stageMinX + stageCrashOffset, boss.x, stageMaxX - stageCrashOffset)
                boss.color = global_pallete.white_color
                Animation.changeAnimation(boss, "rasengan_crash")
                SoundManager.playSound("BossLandLight")
            end
        end
        if boss.hurtWhiteTime > 0 then
            boss.hurtWhiteTime = boss.hurtWhiteTime - dt
        end
        if boss.circleFloating then
            orbitalMotion(boss, boss.circleAnchor, boss.circleFloatRadius, boss.circleFloatSpeed, dt)
        end
    end
    boss:setActive() -- activates all components

    local attackStates = {
        dualSlashSlam,
        homingProjectilesRedProjectile,
        darkOrbRasenganLightning,
        lightningDiveLaserSpin
    }
    boss.fighting = false
    if boss.phase2 then
        attackStates = {
            darkOrbRasenganLightning,
            homingProjectilesRedProjectile,
            dualSlashTripleSlam,
            lightningDiveLaserSpin
        }
    end
    boss.stateSelector = stateSelector(boss, attackStates, {1,2,3,4},1.5)
    return boss
end

---- ATTACK ROUTINES ----
--- Actual attack patterns ----
function dualSlashSlam()
    doubleSlash(attackParams.dualSlashWarning, false)
    coroutine.yield(1)
    Animation.changeAnimation(boss, "battlestance")
    -- dash to an extreme
    local tgtX = boss.target.x > 32 and stageMinX + 3 or stageMaxX - 3
    boss.flip = tgtX > 32 and -1 or 1
    dashToPosition(tgtX, boss.y, 6)
    coroutine.yield(0.5)
    Animation.changeAnimation(boss, "swordthrow")
    coroutine.yield(0.1)
    boss.sword.x, boss.sword.y = boss.x, boss.y
    boss.sword:setActive()
    local tgtXSword, tgtYSword = boss.x + 16 * boss.flip, 12
    boss.sword.color = global_pallete.red_color
    boss.sword.dashTrailer:trailFromTo(boss.sword.x, boss.sword.y, tgtXSword, tgtYSword, 6)
    boss.sword.dashTrailer:trailOnInterval(0.1)
    boss.sword.rotating = true
    SoundManager.playSound("SwordSpin")
    boss.sword.x, boss.sword.y = tgtXSword, tgtYSword
    coroutine.yield(0.1)
    boss.sword.trackingTarget = true
    coroutine.yield(attackParams.shockwaveSlamWarning * 2)
    boss.sword:setInactive()
    boss.sword.color = global_pallete.white_color
    boss.sword.dashTrailer.trailing = false
    boss.sword.rotating = false
    boss.sword.trackingTarget = false
    shockwaveSlam(attackParams.shockwaveSlamWarning, boss.sword.x, boss.sword.y - 4, boss.sword.x)
    waitPostAttackTime()
    goToNextStateIfFighting()
end

function dualSlashTripleSlam()
    doubleSlash(attackParams.dualSlashWarning, false)
    coroutine.yield(0.5)
    doubleSlash(attackParams.dualSlashWarning, false)
    coroutine.yield(1)
    Animation.changeAnimation(boss, "battlestance")
    -- dash to an extreme
    local tgtX = boss.target.x > 32 and stageMinX + 3 or stageMaxX - 3
    boss.flip = tgtX > 32 and -1 or 1
    dashToPosition(tgtX, boss.y, 6)
    coroutine.yield(0.5)
    Animation.changeAnimation(boss, "swordthrow")
    coroutine.yield(0.1)
    boss.sword.x, boss.sword.y = boss.x, boss.y
    boss.sword:setActive()
    local tgtXSword, tgtYSword = boss.x + 16 * boss.flip, 12
    boss.sword.color = global_pallete.red_color
    boss.sword.dashTrailer:trailFromTo(boss.sword.x, boss.sword.y, tgtXSword, tgtYSword, 6)
    boss.sword.dashTrailer:trailOnInterval(0.1)
    boss.sword.rotating = true
    SoundManager.playSound("SwordSpin")
    boss.sword.x, boss.sword.y = tgtXSword, tgtYSword
    coroutine.yield(0.1)
    boss.sword.trackingTarget = true
    coroutine.yield(attackParams.shockwaveSlamWarning * 2)
    boss.sword:setInactive()
    boss.sword.color = global_pallete.white_color
    boss.sword.dashTrailer.trailing = false
    boss.sword.rotating = false
    boss.sword.trackingTarget = false
    shockwaveSlam(attackParams.shockwaveSlamWarning, boss.sword.x, boss.sword.y - 4, boss.sword.x)
    while boss.shockwaveSlamming do
        coroutine.yield(0.01)
    end
    coroutine.yield(1)
    -- do 3 more slams
    for k = 1,3 do
        boss.color = global_pallete.red_color
        Animation.changeAnimation(boss, "downslash_prep1")
        SoundManager.playSoundRandomizedPitch("BossSwordPrep", 0.5, 0.6)
        ParticleSystem.charge(boss.x, boss.y, 6, 40, 40, global_pallete.red_color, 3, 0.95, true, 0.4, 16)
        coroutine.yield(k == 3 and 1 or 0.5)
        Animation.changeAnimation(boss, "downslash_prep2")
        SoundManager.playSoundRandomizedPitch("BossSwordPrep", 0.5, 0.6)
        ParticleSystem.charge(boss.x, boss.y, 6, 40, 40, global_pallete.red_color, 3, 0.95, true, 0.4, 16)
        coroutine.yield(k == 3 and 1 or 0.5)
        ParticleSystem.burst(boss.x, boss.y, 15, 400, 500, global_pallete.red_color, 5, 0.95, 0.75, false, 0.5)
        Animation.changeAnimation(boss, "slam")
        Camera.jiggle(0, -0.5)
        -- create two shockwaves
        for k2 = 1,2 do
            local shockwave = boss.shockwavePool:getFromPool()
            local dir = k2 % 2 == 0 and 1 or -1
            shockwave.flip = dir
            shockwave:activate(boss.x, boss.floorY, attackParams.slamShockwaveSpeed * dir)
        end
        if k == 3 then
            boss.color = global_pallete.white_color
            SoundManager.playSound("BossLandLight")
        else
            SoundManager.playSound("BossLandHeavy")
        end
        coroutine.yield(0.5)
    end
    waitPostAttackTime()
    goToNextStateIfFighting()
end

function darkOrbRasenganLightning()
    darkOrbRotate(true, attackParams.darkOrbWarning)
    redOrbRasengan(attackParams.redOrbWarning, boss.target.x > 32 and -1 or 1)
    while(boss.rasenganing) do
        coroutine.yield(0.01)
    end
    coroutine.yield(0.3)
    darkOrbRotate(false, attackParams.darkOrbWarning)
    redOrbRasengan(attackParams.redOrbWarning, boss.target.x > 32 and -1 or 1)
    while(boss.rasenganing) do
        coroutine.yield(0.01)
    end
    Animation.changeAnimation(boss, "nosword_rasen")
    coroutine.yield(0.1)
    boss.sword.x, boss.sword.y = boss.x, boss.y
    boss.sword:setActive()
    local dir = boss.x > 32 and -1 or 1
    local tgtXSword, tgtYSword = boss.x + 32 * dir, 12
    boss.sword.dashTrailer:trailFromTo(boss.sword.x, boss.sword.y, tgtXSword, tgtYSword, 6)
    boss.sword.dashTrailer:trailOnInterval(0.1)
    boss.sword.rotating = true
    SoundManager.playSound("SwordSpin")
    boss.sword.x, boss.sword.y = tgtXSword, tgtYSword
    coroutine.yield(0.1)
    coroutine.yield(attackParams.lightningSlamWarning)
    boss.sword:setInactive()
    boss.sword.dashTrailer.trailing = false
    boss.sword.rotating = false
    lightningSlam(attackParams.lightningSlamWarning, boss.sword.x, boss.sword.y - 4, boss.x > 32 and stageMinX + 6 or stageMaxX - 6, boss.phase2)
    if boss.fighting then
        coroutine.yield(boss.phase2 and attackParams.postAttackTime * 2 or attackParams.postAttackTime * 1.5)
    else
        coroutine.yield(attackParams.postAttackTime)
    end
    Physics.zeroVelocity(boss)
    Physics.zeroAcceleration(boss)
    goToNextStateIfFighting()
end

function lightningDiveLaserSpin()
    Animation.changeAnimation(boss, "battlestance")
    dashToPosition(boss.target.x > 32 and stageMinX + 5 or stageMaxX - 5, boss.floorY, 6)
    boss.flip = boss.x > 32 and -1 or 1
    coroutine.yield(0.5)
    lightningSlam(attackParams.lightningSlamWarning, boss.x + 32 * boss.flip, 12, boss.x > 32 and stageMinX + 6 or stageMaxX - 6)
    coroutine.yield(1)
    boss.solid = true
    swordThrowLaserSpin(false)
    coroutine.yield(1)
    boss.sword:setInactive()
    boss.sword.dashTrailer.trailing = false
    lightningSlam(attackParams.lightningSlamWarning, boss.sword.x, boss.sword.y, boss.x > 32 and stageMinX + 6 or stageMaxX - 6)
    waitPostAttackTime()
    goToNextStateIfFighting()
end

function homingProjectilesRedProjectile()
    homingProjectileVolley(math.random() > 0.5 and 1 or -1)
    coroutine.yield(1.5)
    if boss.phase2 then
        redLaserVolley(attackParams.numSkyLasers, attackParams.numSkyLasersAcross)
    else
        if boss.fighting then
            redProjectileVolley(attackParams.numRedProjectiles + 1)
        else
            redProjectileVolley(attackParams.numRedProjectiles)
        end
    end
    coroutine.yield(attackParams.postAttackTime / 2)
    Animation.changeAnimation(boss, "battlestance")
    waitPostAttackTime()
    goToNextStateIfFighting()
end


---- ATTACK PRIMITIVES ----
---- These shouldn't really be called directly, but rather by attack routines above ----
function waitPostAttackTime()
    if boss.fighting then
        coroutine.yield(attackParams.postAttackTime * 1.5)
    else
        coroutine.yield(attackParams.postAttackTime)
    end
end
function goToNextStateIfFighting()
    if boss.fighting then
        boss.stateSelector:goToNextState()
    end
end
function dashToPosition(tgtX, tgtY, numTrails)
    boss.dashTrailer:trailFromTo(boss.x, boss.y, tgtX, tgtY, numTrails or 6)
    SoundManager.playSoundRandomizedPitch("Dash", 0.6, 1.4)
    boss.x, boss.y = tgtX, tgtY
end

function dashToTarget(side, offset, tgtY, numTrails)
    numTrails = numTrails or 6
    local offsetX = offset * side
    boss.flip = -side
    tgtY = tgtY or boss.floorY
    local tgtX = clamp(stageMinX, boss.target.x + offsetX, stageMaxX)
    boss.dashTrailer:trailFromTo(boss.x, boss.y, tgtX, tgtY, numTrails)
    boss.x, boss.y = tgtX, tgtY
    SoundManager.playSoundRandomizedPitch("Dash", 0.6, 1.4)
end

function activateSwordHitboxAfterDelay(x, y, dir, delay)
    coroutine.yield(delay)
    boss.hitbox:activate(x, y, dir)
end

function doubleSlash(waitTime, sameSide)
    Physics.zeroVelocity(boss)
    Animation.changeAnimation(boss, "battlestance")
    -- dash to the opposite side of the target and prepare your slashes
    local dashDir = boss.x > boss.target.x and -1 or 1
    if sameSide then
        dashDir = -dashDir
    end
    local slashOffset = 12
    dashToTarget(dashDir, slashOffset, boss.floorY, 6)
    boss.solid = true
    local advanceAndFlipTowardsTarget =
        function(dontflip)
            -- if they try to go to our other side, flip
            local tgtDist = boss.target.x - boss.x
            if sign(tgtDist) ~= boss.flip and sign(tgtDist) ~= 0 and not dontflip then
                boss.flip = sign(tgtDist)
            end
            -- if they try to escape us, advance
            if math.abs(tgtDist) > slashOffset then
                -- only advance if we're facing the right way. 
                -- a super crafty player could time it so they don't get advanced on here
                if sign(tgtDist) == boss.flip then
                    local distProportion = math.abs(tgtDist - slashOffset) / 64
                    local computedNumTrails = math.floor(lerp(2,6.9,distProportion))
                    local numTrails = clamp(2, 6, computedNumTrails)
                    dashToTarget(-boss.flip, slashOffset, boss.floorY, numTrails)
                end
            end
        end
    
    local swordHitboxOffset = 12
    coroutine.yield(waitTime)
    Animation.changeAnimation(boss, "downslash_prep1")
    ParticleSystem.charge(boss.x, boss.y, 6, 40, 40, global_pallete.orange_color, 3, 0.95, true, 0.4, 16)
    SoundManager.playSoundRandomizedPitch("BossSwordPrep", 0.7, 1.3)
    coroutine.yield(waitTime)
    Animation.changeAnimation(boss, "downslash_prep2")
    advanceAndFlipTowardsTarget()
    ParticleSystem.charge(boss.x, boss.y, 6, 40, 40, global_pallete.orange_color, 3, 0.95, true, 0.4, 16)
    SoundManager.playSoundRandomizedPitch("BossSwordPrep", 0.7, 1.3)
    coroutine.yield(waitTime)
    Animation.changeAnimation(boss, "downslash")
    activateSwordHitboxAfterDelay(boss.x + boss.flip * swordHitboxOffset, boss.floorY, boss.flip, 0.1)
    SoundManager.playSound("BossSlashDown")
    advanceAndFlipTowardsTarget(true)
    coroutine.yield(waitTime)
    Animation.changeAnimation(boss, "upslash_prep2")
    advanceAndFlipTowardsTarget()
    ParticleSystem.charge(boss.x, boss.y, 6, 40, 40, global_pallete.orange_color, 3, 0.95, true, 0.4, 16)
    SoundManager.playSoundRandomizedPitch("BossSwordPrep", 0.7, 1.3)
    coroutine.yield(waitTime)
    Animation.changeAnimation(boss, "upslash")
    advanceAndFlipTowardsTarget(true)
    activateSwordHitboxAfterDelay(boss.x + boss.flip * swordHitboxOffset, boss.floorY, boss.flip, 0.1)
    SoundManager.playSound("SwordUpBass")
    boss.solid = false
end

function shockwaveSlam(delay, startX, startY, slamX)
    -- jump up and slam down
    boss.solid = false
    Animation.changeAnimation(boss, "slamprep_1")
    local slamHeight = startY or 5
    local tgtX = startX or (boss.x + slamX) / 2
    boss.flip = boss.x > slamX and -1 or 1
    boss.dashTrailer:trailFromTo(boss.x, boss.y, tgtX, slamHeight, 6)
    SoundManager.playSound("BossJump")
    boss.color = global_pallete.red_color
    boss.x, boss.y = tgtX, slamHeight
    ParticleSystem.charge(boss.x, boss.y, 6, 30, 30, global_pallete.red_color, 4, 0.9, true, 0.35, 16)
    local floatSpeed = 3
    local vX, vY = clampVecToLength(slamX - boss.x, boss.floorY - boss.y, floatSpeed)
    boss.RigidBody.velocity.x, boss.RigidBody.velocity.y = vX, vY
    coroutine.yield(delay)
    Animation.changeAnimation(boss, "slamprep_2")
    ParticleSystem.charge(boss.x, boss.y, 6, 30, 30, global_pallete.red_color, 4, 0.9, true, 0.35, 16)
    boss.shockwaveWarning.x, boss.shockwaveWarning.y = slamX, 32
    boss.shockwaveWarning:setActive()
    SoundManager.playSound("FlashWarning")
    coroutine.yield(delay)
    boss.shockwaveSlamming = true
    ParticleSystem.burst(boss.x, boss.y, 5, 300, 300, global_pallete.red_color, 3, 0.9, 0.8, false, 0.3)
    local fallSpeed = 200
    boss.dashTrailer:trailOnInterval(0.1)
    vX, vY = clampVecToLength(slamX - boss.x, boss.floorY - boss.y, fallSpeed)
    boss.RigidBody.velocity.x, boss.RigidBody.velocity.y = vX, vY
    SoundManager.playSound("Dive")
end

function lightningSlam(delay, startX, startY, slamX, radahn)
    -- jump up and slam down
    boss.solid = false
    Animation.changeAnimation(boss, "slamprep_1")
    local slamHeight = startY or 5
    local tgtX = startX or (boss.x + slamX) / 2
    boss.flip = boss.x > slamX and -1 or 1
    boss.dashTrailer:trailFromTo(boss.x, boss.y, tgtX, slamHeight, 6)
    SoundManager.playSound("BossJump")
    boss.x, boss.y = tgtX, slamHeight
    ParticleSystem.charge(boss.x, boss.y, 6, 30, 30, global_pallete.black_color, 4, 0.9, true, 0.35, 16)
    local floatSpeed = 3
    local vX, vY = clampVecToLength(slamX - boss.x, boss.floorY - boss.y, floatSpeed)
    boss.RigidBody.velocity.x, boss.RigidBody.velocity.y = vX, vY
    coroutine.yield(delay)
    Animation.changeAnimation(boss, "slamprep_2")
    SoundManager.playSound("LightningCharge")
    ParticleSystem.charge(boss.x, boss.y, 6, 30, 30, global_pallete.black_color, 4, 0.9, true, 0.35, 16)
    boss.lightningSlamWarning.x, boss.lightningSlamWarning.y = slamX, 32
    boss.lightningSlamWarning:setActive()
    SoundManager.playSound("FlashWarning")
    coroutine.yield(delay)
    local fallSpeed = 200
    if radahn then
        boss.radahnSlamming = true
        Physics.zeroVelocity(boss)
        Physics.zeroAcceleration(boss)
        for k = 1,attackParams.numRadahnSlams do
            local clone = boss.clonePool:getFromPool()
            clone.flip = boss.flip
            clone.x, clone.y = boss.x, boss.y
            vX, vY = clampVecToLength(slamX - boss.x, boss.floorY - boss.y, fallSpeed)
            ParticleSystem.burst(boss.x, boss.y, 5, 300, 300, global_pallete.black_color, 3, 0.9, 0.8, false, 0.3)
            clone.RigidBody.velocity.x, clone.RigidBody.velocity.y = vX, vY
            SoundManager.playSoundRandomizedPitch("Dive", 0.6, 1.4, 0.7)
            clone.dashTrailer:trailOnInterval(0.1)
            Animation.changeAnimation(clone, "fall")
            clone:setActive()
            coroutine.yield(attackParams.interRadahnSlamDelay)
        end
    end
    boss.lightningSlamming = true
    ParticleSystem.burst(boss.x, boss.y, 5, 300, 300, global_pallete.black_color, 3, 0.9, 0.8, false, 0.3)
    boss.dashTrailer:trailOnInterval(0.1)
    vX, vY = clampVecToLength(slamX - boss.x, boss.floorY - boss.y, fallSpeed)
    boss.RigidBody.velocity.x, boss.RigidBody.velocity.y = vX, vY
    SoundManager.playSound("Dive")
end

function createSword()
    local sword = GameObjects.newGameObject(2, 0, 0, 57, false, GameObjects.DrawLayers.PARTICLES)
    Physics.addRigidBody(sword)
    sword.dashTrailer = createDashTrailer(sword, 2, 15, 0.2, true, GameObjects.DrawLayers.PARTICLES)
    sword.rotating = false
    sword.rotateSpeed = 20
    sword.slowRotateSpeed = attackParams.laserRotateSpeed
    sword.slowRotating = false
    sword.rotateDir = 1
    sword.trackingTarget = false
    function sword:update(dt)
        if sword.rotating then
            sword.rotation = wrap(0, sword.rotation + dt * sword.rotateSpeed * sword.rotateDir , math.pi * 2)
        elseif sword.slowRotating then
            sword.rotation = wrap(0, sword.rotation + dt * sword.slowRotateSpeed * sword.rotateDir, math.pi * 2)
            if sword.x < stageMinX - 2 and sword.RigidBody.velocity.x < 0 then
                sword.RigidBody.velocity.x = -sword.RigidBody.velocity.x
                sword.x = stageMinX
                ParticleSystem.burst(sword.x, sword.y, 6, 200, 300, global_pallete.black_color, 3, 0.95, 0.8, false, 0.4)
                Camera.jiggle(0, -0.25)
                SoundManager.playSound("WallHitRumble")
            elseif sword.x > stageMaxX + 2 and sword.RigidBody.velocity.x > 0 then
                sword.RigidBody.velocity.x = -sword.RigidBody.velocity.x
                sword.x = stageMaxX
                ParticleSystem.burst(sword.x, sword.y, 6, 200, 300, global_pallete.black_color, 3, 0.95, 0.8, false, 0.4)
                Camera.jiggle(0, 0.25)
                SoundManager.playSound("WallHitRumble")
            end
        end
        if sword.trackingTarget then
            sword.x = lerp(sword.x, boss.target.x, 3 * dt)
        end
    end
    return sword
end

function createOrb(radius, deflectable)
    local orb = GameObjects.newGameObject(-1,0,0,0,false,GameObjects.DrawLayers.PARTICLES)
    orb.color = deflectable and global_pallete.black_color or global_pallete.red_color
    Collision.addCircleCollider(orb, radius-1, Collision.Layers.HURTER, {})
    orb.baseRadius = radius
    orb.radius = radius
    orb.undeflectable = not deflectable
    orb.dir = 1 -- to be set by the boss
    function orb:update(dt)
        orb.radius = orb.baseRadius + math.sin(timeElapsed*10) * 3
    end
    function orb:draw()
        love.graphics.setColor(orb.color)
        love.graphics.circle("fill", orb.x, orb.y, orb.radius)
    end
    function orb:die()
        orb:setInactive()
        Camera.shake(0.35)
        ParticleSystem.burst(orb.x, orb.y, 15, 300, 400, orb.color, 5, 0.95, 0.8, false, 0.5)
        SoundManager.playSoundRandomizedPitch("RedProjectileExplosion", 0.8, 1.2, 0.6)
    end
    return orb
end

function darkOrbRotate(oppositeSide, delay)
    -- track the player
    -- summon an orb opposite and rotate it about the player
    Animation.changeAnimation(boss, "float")
    if oppositeSide then
        dashToTarget(boss.x > boss.target.x and -1 or 1, boss.trackOffset, boss.target.y, 6)
    else
        dashToTarget(boss.x > boss.target.x and 1 or -1, boss.trackOffset, boss.target.y, 6)
    end
    boss.trackingTarget = true
    boss.solid = true
    coroutine.yield(0.5)
    ParticleSystem.charge(boss.x, boss.y, 10, 40, 40, global_pallete.black_color, 3, 0.9, true, 0.35, 16)
    SoundManager.playSound("GenericChargeup")
    coroutine.yield(delay/2)
    Animation.changeAnimation(boss, "float_noarm")
    boss.fakeArm:setActive()
    boss.squashStretcher:squashStretch(2,2)
    boss.darkOrb.x, boss.darkOrb.y = boss.x, boss.y + boss.darkOrbOffset
    boss.darkOrb:setActive()
    SoundManager.playSound("BuzzWooshUp")
    SoundManager.playSound("PopSpawn")
    boss.darkOrb.dir = boss.target.x > boss.x and 1 or -1
    ParticleSystem.burst(boss.darkOrb.x, boss.darkOrb.y, 10, 300, 350, global_pallete.black_color, 4, 0.95, 0.8, false, 0.5)
    Camera.shake(0.4)
    boss.trackDarkOrb = true
    coroutine.yield(delay)
    SoundManager.playSound("GenericChargeup")
    ParticleSystem.burst(boss.darkOrb.x, boss.darkOrb.y, 10, 300, 350, global_pallete.black_color, 4, 0.95, 0.8, false, 0.5)
    coroutine.yield(delay)
    ParticleSystem.burst(boss.darkOrb.x, boss.darkOrb.y, 10, 300, 350, global_pallete.black_color, 4, 0.95, 0.8, false, 0.5)
    boss.darkOrb.orbitalTime = 0
    boss.darkOrb.orbitalOffset = math.pi/2
    boss.trackDarkOrb = false
    boss.rotateDarkOrb = true
    SoundManager.playSound("WooshDownLight")
    coroutine.yield(delay * 2)
    boss.fakeArm:setInactive()
    boss.darkOrb:setInactive()
    boss.rotateDarkOrb = false
    boss.trackingTarget = false
    boss.solid = false
end

function redOrbRasengan(delay, side)
    -- Dash far from the target
    boss.fakeArm:setInactive()
    Animation.changeAnimation(boss, "float")
    boss.rotateDarkOrb = false
    boss.trackingTarget = false
    boss.trackRedOrb = false
    boss.solid = false
    boss.darkOrb:setInactive()
    local tX = side == -1 and stageMinX + 3 or stageMaxX - 3
    boss.dashTrailer:trailFromTo(boss.x, boss.y, tX, boss.floorY - 3, 6)
    boss.x, boss.y = tX, boss.floorY - 3
    SoundManager.playSound("Dash")
    local dir = boss.x < 32 and 1 or -1
    boss.flip = dir
    boss.color = global_pallete.red_color
    ParticleSystem.charge(boss.x, boss.y, 6, 30, 30, global_pallete.red_color, 4, 0.9, true, 0.35, 16)
    coroutine.yield(delay)
    boss.squashStretcher:squashStretch(2,2)
    boss.redOrb.x, boss.redOrb.y = boss.x - dir * boss.redOrbOffset, boss.y
    ParticleSystem.burst(boss.redOrb.x, boss.redOrb.y, 6, 300, 350, global_pallete.red_color, 4, 0.95, 0.8, false, 0.5)
    boss.redOrb.orbitalTime = 0
    boss.redOrb.orbitalOffset = dir == 1 and math.pi or 0
    boss.redOrb.dir = dir
    boss.redOrb:setActive()
    SoundManager.playSound("BuzzWooshUp")
    SoundManager.playSound("PopSpawn")
    boss.rotateRedOrb = true
    coroutine.yield(delay)
    Animation.changeAnimation(boss, "rasengan")
    boss.rotateRedOrb = false
    boss.trackRedOrb = true
    local rasenganSpeed = -80
    local rasenganAccel = 400
    boss.RigidBody.velocity.x = dir * rasenganSpeed
    boss.RigidBody.acceleration.x = dir * rasenganAccel
    boss.rasenganing = true
    SoundManager.playSound("RasenganDash")
    ParticleSystem.burst(boss.redOrb.x, boss.redOrb.y, 6, 300, 350, global_pallete.red_color, 4, 0.95, 0.8, false, 0.5)
end

function homingProjectileVolley(side)
    Physics.zeroVelocity(boss)
    Physics.zeroAcceleration(boss)
    boss.solid = false
    Animation.changeAnimation(boss, "float")
    boss.circleFloating = true
    boss.orbitalTime = 0
    boss.orbitalOffset = side == 1 and 0 or math.pi
    boss.circleFloatSpeed = math.abs(boss.circleFloatSpeed) * -side
    dashToPosition(boss.circleAnchor.x + side * boss.circleFloatRadius, boss.circleAnchor.y, 6)
    for k = 1,attackParams.numHomingProjectiles do
        coroutine.yield(attackParams.interHomingProjectileTime)
        boss.squashStretcher:squashStretch(1.5,1.5)
        local proj = boss.homingProjectilePool:getFromPool()
        proj:spawn(boss.x, boss.y - 4)
        SoundManager.playSound("PopSpawn")
    end
    coroutine.yield(attackParams.interHomingProjectileTime * 1.5)
    boss.circleFloating = false
end

function tutorialHomingProjectile()
    Physics.zeroVelocity(boss)
    Physics.zeroAcceleration(boss)
    boss.solid = false
    Animation.changeAnimation(boss, "float")
    dashToPosition(32, 24, 6)

    for k = 1,5 do
        coroutine.yield(attackParams.interHomingProjectileTime)
        boss.squashStretcher:squashStretch(1.5,1.5)
        local proj = boss.homingProjectilePool:getFromPool()
        proj:spawn(boss.x - 8 + (k-1) * 8, boss.y - 20)
        SoundManager.playSound("PopSpawn")
        coroutine.yield(3)
    end
end

function tutorialSlam()
    for k = 1,3 do
        shockwaveSlam(attackParams.shockwaveSlamWarning * 1.5, 32, 16, boss.x > 32 and 8 or 56)
        coroutine.yield(2)
    end
end

function tutorialRedProjectiles()
    Animation.changeAnimation(boss, "upwardprep")
    boss.solid = true
    dashToPosition(boss.target.x < 32 and stageMaxX - 5 or stageMinX + 5, boss.floorY, 6)
    coroutine.yield(0.5)
    boss.color = global_pallete.red_color
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 10, 30, 30, global_pallete.red_color, 3, 0.9, true, 0.35, 10)
    SoundManager.playSound("RedProjectileCharge")
    coroutine.yield(attackParams.redProjectileWarning)
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 10, 30, 30, global_pallete.red_color, 3, 0.9, true, 0.35, 10)
    SoundManager.playSound("RedProjectileCharge")
    coroutine.yield(attackParams.redProjectileWarning)
    for k = 1,3 do
        local proj = boss.redProjectilePool:getFromPool()
        proj.x, proj.y = boss.x, boss.y - 6
        proj.RigidBody.velocity.y = -attackParams.redProjectileSpeed
        proj:setActive()
        ParticleSystem.burst(boss.x, boss.y, 8, 300, 400, global_pallete.red_color, 5, 0.95, 0.75, false, 0.5)
        boss.squashStretcher:squashStretch(2, 2)
        SoundManager.playSoundRandomizedPitch("HardShot", 0.75, 1.25)
        Animation.changeAnimation(boss, "upwardpulse")
        if k == 3 then
            boss.color = global_pallete.white_color
        end
        coroutine.yield(2)
    end
end

function redProjectileVolley(numProjectiles)
    -- dash to an extreme, far away from the player
    Animation.changeAnimation(boss, "upwardprep")
    boss.solid = true
    dashToPosition(boss.target.x < 32 and stageMaxX - 5 or stageMinX + 5, boss.floorY, 6)
    coroutine.yield(0.5)
    boss.color = global_pallete.red_color
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 10, 30, 30, global_pallete.red_color, 3, 0.9, true, 0.35, 10)
    SoundManager.playSound("RedProjectileCharge")
    coroutine.yield(attackParams.redProjectileWarning)
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 10, 30, 30, global_pallete.red_color, 3, 0.9, true, 0.35, 10)
    SoundManager.playSound("RedProjectileCharge")
    coroutine.yield(attackParams.redProjectileWarning)
    for k = 1,numProjectiles do
        local proj = boss.redProjectilePool:getFromPool()
        proj.x, proj.y = boss.x, boss.y - 6
        proj.RigidBody.velocity.y = -attackParams.redProjectileSpeed
        proj:setActive()
        ParticleSystem.burst(boss.x, boss.y, 8, 300, 400, global_pallete.red_color, 5, 0.95, 0.75, false, 0.5)
        SoundManager.playSoundRandomizedPitch("HardShot", 0.75, 1.25)
        boss.squashStretcher:squashStretch(2, 2)
        Animation.changeAnimation(boss, "upwardpulse")
        if k == numProjectiles then
            boss.color = global_pallete.white_color
        end
        coroutine.yield(attackParams.interRedProjectileTime)
    end
end

function redLaserVolley(numLasers, numLasersAcross)
    Animation.changeAnimation(boss, "upwardprep")
    boss.solid = true
    dashToPosition(boss.target.x < 32 and stageMaxX - 5 or stageMinX + 5, boss.floorY, 6)
    coroutine.yield(0.5)
    boss.color = global_pallete.red_color
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 15, 30, 30, global_pallete.red_color, 5, 0.9, true, 0.45, 16)
    SoundManager.playSound("LaserChargeUp2")
    coroutine.yield(attackParams.redLaserPreWarning)
    boss.squashStretcher:squashStretch(0.75, 1.2)
    ParticleSystem.charge(boss.x, boss.y, 15, 30, 30, global_pallete.red_color, 5, 0.9, true, 0.45, 16)
    SoundManager.playSound("LaserChargeUp2")
    coroutine.yield(attackParams.redLaserPreWarning)

    for k = 1,numLasers do
        boss.initialSkyLaser.x, boss.initialSkyLaser.y = boss.x, boss.y - 32 - 4
        boss.initialSkyLaser:setActive()
        ParticleSystem.burst(boss.x, boss.y - 4, 10, 350, 450, global_pallete.red_color, 5, 0.95, 0.8, false, 0.5)
        boss.squashStretcher:squashStretch(2, 2)
        Animation.changeAnimation(boss, "upwardpulse")
        Camera.jiggle(0, -0.4)
        if k == numLasers then
            boss.color = global_pallete.white_color
        end
        SoundManager.playSound("MegaQuickLaser")
        coroutine.yield(attackParams.redLaserPreWarning)
    end
    for k = 1,numLasers do
        local xPositions = {}
        local initialOffset = attackParams.skyLaserWidth/2
        if k % 2 == 1 then
            initialOffset = initialOffset + attackParams.skyLaserWidth
        end
        for k2 = 1,numLasersAcross do
            xPositions[k2] = initialOffset + (k2-1) * attackParams.skyLaserWidth*2
            local warning = boss.skyLaserWarningPool:getFromPool()
            warning.x, warning.y = xPositions[k2], 32 - (64 - boss.floorY) + 5
            warning:setActive()
        end
        SoundManager.playSound("FlashWarning")
        coroutine.yield(attackParams.redLaserPreWarning)
        for k2 = 1,numLasersAcross do
            local laser = boss.skyLaserPool:getFromPool()
            laser.x, laser.y = xPositions[k2], 32 - (64 - boss.floorY) + 5
            laser:setActive()
            ParticleSystem.burst(laser.x, boss.floorY + 5, 4, 300, 400, global_pallete.red_color, 3, 0.95, 0.8, false, 0.4)
        end
        SoundManager.playSound("LightningStrike")
        Camera.jiggle(0, -0.45)
        coroutine.yield(attackParams.redLaserPreWarning)
    end
end

function swordThrowLaserSpin(dash)
    if dash then
        Animation.changeAnimation(boss, "battlestance")
        dashToPosition(boss.target.x > 32 and stageMinX + 5 or stageMaxX - 5, boss.floorY, 6)
        boss.solid = true
        coroutine.yield(0.5)
    end
    boss.flip = boss.x > 32 and -1 or 1
    Animation.changeAnimation(boss, "swordthrow")
    coroutine.yield(0.1)
    boss.sword.x, boss.sword.y = boss.x, boss.y
    boss.sword:setActive()
    local tgtXSword, tgtYSword = boss.x + 8 * boss.flip, 16
    boss.sword.dashTrailer:trailFromTo(boss.sword.x, boss.sword.y, tgtXSword, tgtYSword, 6)
    boss.sword.dashTrailer:trailOnInterval(0.1)
    boss.sword.rotateDir = -boss.flip
    boss.sword.rotating = true
    SoundManager.playSound("SwordSpin")
    boss.sword.x, boss.sword.y = tgtXSword, tgtYSword
    coroutine.yield(attackParams.preLaserTime)
    local oldSpr = boss.sword.spr
    boss.sword.spr = 73
    boss.sword.rotation = 0
    boss.sword.rotating = false
    coroutine.yield(attackParams.preLaserTime)
    boss.sword.slowRotating = true
    boss.laserSpinner.clockwise = -boss.flip
    boss.laserSpinner:setActive()
    SoundManager.playSound("MegaQuickLaser")
    boss.laserSpinner.spinning = true
    Camera.jiggle(0, 0.4)
    coroutine.yield(0.5)
    boss.sword.RigidBody.velocity.x = attackParams.laserMoveSpeed * boss.flip
    coroutine.yield(attackParams.laserRotateTime)
    Physics.zeroVelocity(boss.sword)
    boss.laserSpinner:setInactive()
    boss.sword.rotating = true
    SoundManager.playSound("GenericChargeup")
    boss.sword.slowRotating = false
    boss.sword.spr = oldSpr
end

function createLaserSpinner(parent, rotateSpeed, width, clockwise) -- adapted from TRYH4RD
    local laserSpinner = GameObjects.newGameObject(-1,0,0,0,false, GameObjects.DrawLayers.BOSS)
    laserSpinner.alpha = 0
    -- Create a bunch of circle colliders and just rotate them around the center
    laserSpinner.hitcircles = {}
    laserSpinner.time = 0
    laserSpinner.visualTime = 0
    laserSpinner.spinning = false
    laserSpinner.clockwise = clockwise
    local visualWidth = width + 2
    for k = 1,16 do
        local hitCircle = GameObjects.newGameObject(-1,0,0,0,false)
        hitCircle.index = k
        hitCircle.dir = -clockwise
        function hitCircle:die(other)
            local minBound, maxBound = 1,16
            if hitCircle.index < 8 then
                minBound, maxBound = 1,8
            else
                minBound, maxBound = 8,16
            end
            laserSpinner.reactivateSpinners(minBound, maxBound)
        end
        laserSpinner.hitcircles[k] = hitCircle
        Collision.addCircleCollider(laserSpinner.hitcircles[k], width/2, Collision.Layers.HURTER, {})
    end
    laserSpinner.reactivateSpinners =
        function(minBound, maxBound)
            laserSpinner:startCoroutine(
                function()
                    for k = minBound,maxBound do
                        laserSpinner.hitcircles[k]:setInactive()
                    end
                    coroutine.yield(0.75)
                    for k = minBound,maxBound do
                        laserSpinner.hitcircles[k]:setActive()
                    end
                end
            , "reactivate")

        end
    function laserSpinner:update(dt)
        laserSpinner.visualTime = laserSpinner.visualTime + dt * rotateSpeed * laserSpinner.clockwise
        if laserSpinner.spinning then
            laserSpinner.time = laserSpinner.time + dt * rotateSpeed * laserSpinner.clockwise
            for k = 1,8 do
                laserSpinner.hitcircles[k].x = k * width * math.cos(laserSpinner.time) + parent.x
                laserSpinner.hitcircles[k].y = k * width * math.sin(laserSpinner.time) + parent.y
            end
            for k = 9,16 do
                laserSpinner.hitcircles[k].x = -(k - 8) * width * math.cos(laserSpinner.time) + parent.x
                laserSpinner.hitcircles[k].y = -(k - 8) * width * math.sin(laserSpinner.time) + parent.y
            end
        end
    end
    function laserSpinner:draw()
        love.graphics.push()
        love.graphics.translate(parent.x, parent.y)
        love.graphics.rotate(laserSpinner.time)
        love.graphics.setColor(global_pallete.black_color)
        love.graphics.rectangle('fill', -64, -visualWidth/2, 128, visualWidth)
        visualWidth = width + 2 + math.sin(laserSpinner.visualTime * 20) * 2
        love.graphics.pop()
    end
    function laserSpinner:pSetInactive()
        for k = 1,16 do
            laserSpinner.hitcircles[k].active = false
            laserSpinner.hitcircles[k].coroutines = {}
        end
        laserSpinner.coroutines = {}
    end
    function laserSpinner:pSetActive()
        laserSpinner.time = 0
        laserSpinner.visualTime = 0
        for k = 1,16 do
            laserSpinner.hitcircles[k]:setActive()
            laserSpinner.hitcircles[k].dir = -laserSpinner.clockwise
        end
        for k = 1,8 do
            laserSpinner.hitcircles[k].x = k * width * math.cos(laserSpinner.time) + parent.x
            laserSpinner.hitcircles[k].y = k * width * math.sin(laserSpinner.time) + parent.y
        end
        for k = 9,16 do
            laserSpinner.hitcircles[k].x = -(k - 8) * width * math.cos(laserSpinner.time) + parent.x
            laserSpinner.hitcircles[k].y = -(k - 8) * width * math.sin(laserSpinner.time) + parent.y
        end
    end
    return laserSpinner
end

function createRedProjectile()
    local proj = GameObjects.newGameObject(-1,0,0,0,false,GameObjects.DrawLayers.PARTICLES)
    Collision.addCircleCollider(proj, 8, Collision.Layers.HURTER, {})
    Physics.addRigidBody(proj)
    proj.explosionHitbox = createCircleHitbox(8)
    proj.explosionHitbox.undeflectable = true
    proj.dir = nil
    proj.undeflectable = true
    proj.verticalWarning = createFadingRectangle2(0,0,16,64,global_pallete.red_color,0.3)
    proj.goingDown = false
    proj.speed = 0
    proj.goDown =
        function()
            coroutine.yield(attackParams.redProjectileArmDelay)
            local tgtX = boss.target.x
            proj.verticalWarning.x, proj.verticalWarning.y = tgtX, 32
            proj.verticalWarning:setActive()
            SoundManager.playSound("FlashWarning")
            coroutine.yield(attackParams.redProjectileFallWarning)
            proj.x, proj.y = tgtX, -10
            SoundManager.playSound("WooshDownQuick")
            proj.RigidBody.velocity.y = proj.speed
        end
    function proj:update(dt)
        if proj.y < -10 and not proj.goingDown then
            -- start going down baby
            proj.goingDown = true
            proj.ignore = false
            proj.speed = math.abs(proj.RigidBody.velocity.y)
            Physics.zeroVelocity(proj)
            proj.x, proj.y = -64, -64
            proj:startCoroutine(proj.goDown, "goDown")
        end
        if proj.y > boss.floorY + 5 then
            proj:die()
        end
    end
    function proj:die()
        ParticleSystem.burst(proj.x, proj.y, 8, 400, 450, global_pallete.red_color, 4, 0.95, 0.75, false, 0.5)
        proj.explosionHitbox.x, proj.explosionHitbox.y = proj.x, proj.y
        proj.explosionHitbox:setActive()
        proj:setInactive()
        SoundManager.playSoundRandomizedPitch("RedProjectileExplosion", 0.75, 1.25, 0.6)
        Camera.jiggle(0, -0.3)
    end
    function proj:pSetActive()
        proj.goingDown = false
        proj.ignore = true
    end
    function proj:draw()
        love.graphics.setColor(global_pallete.red_color)
        love.graphics.circle("fill", proj.x, proj.y, 8)
    end

    return proj
end

function createSlashHitbox()
    local hitbox = GameObjects.newGameObject(-1,0,0,0,false)
    GameObjects.attachComponent(hitbox, createLifeTimer(hitbox, 0.2))
    Collision.addCircleCollider(hitbox, 12, Collision.Layers.HURTER, {})
    hitbox.dir = 1
    hitbox.deflectDist = 5
    function hitbox:activate(x, y, dir)
        hitbox.x, hitbox.y, hitbox.dir = x, y, dir
        hitbox:setActive()
    end
    function hitbox:die()
        hitbox:setInactive()
    end
    return hitbox
end

function createShockwave()
    local shockwave = GameObjects.newGameObject(3,0,0,0,false,GameObjects.DrawLayers.PARTICLES)
    Collision.addCircleCollider(shockwave, 3, Collision.Layers.HURTER, {})
    Physics.addRigidBody(shockwave)
    GameObjects.attachComponent(shockwave, createLifeTimer(shockwave, 4))
    shockwave.undeflectable = true
    function shockwave:activate(x, y, speed)
        shockwave.x, shockwave.y = x, y
        shockwave.RigidBody.velocity.x = speed
        shockwave:setActive()
    end
    function shockwave:die()
        -- no op
    end
    return shockwave
end

function createCircleHitbox(radius)
    local hitbox = GameObjects.newGameObject(-1,0,0,0,false)
    GameObjects.attachComponent(hitbox, createLifeTimer(hitbox, 0.1))
    Collision.addCircleCollider(hitbox, radius, Collision.Layers.HURTER, {})
    function hitbox:die()
        hitbox:setInactive()
    end
    return hitbox
end

function createLightning() -- largely adapted from TRYH4RD
    local lightning = GameObjects.newGameObject(-1,0,0,0,false,GameObjects.DrawLayers.PARTICLES)
    Physics.addRigidBody(lightning)
    Collision.addBoxCollider(lightning, 2, 64, Collision.Layers.HURTER, {})
    GameObjects.attachComponent(lightning, createLifeTimer(lightning, 3))
    lightning.tic = 2/60
    lightning.xPoints = {}
    lightning.dir = 1
    lightning.deflectDist = 4
    function lightning:update(dt)
        lightning.tic = lightning.tic - dt
        if lightning.tic <= 0 then
            lightning.tic = 2/60
            lightning.points = lightning:generatePoints(lightning.points)
        end
        for k = 1,#lightning.points do
            if k%2 == 1 then
                lightning.xPoints[k] = lightning.points[k] + lightning.x
            else
                lightning.xPoints[k] = lightning.points[k]
            end
        end
    end
    function lightning:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.line(lightning.xPoints)
    end

    function lightning:generatePoints(points)
        local y = lightning.y - 32
        local numSteps = 20
        local offsetMag = 2
        local sgn = 1
        for k = 1,numSteps do
            points[k * 2 - 1] = math.random() * offsetMag * sgn
            points[k * 2] = y
            y = y + 72 / numSteps
            sgn = sgn * -1
        end
        return points
    end

    function lightning:pSetActive()
        lightning.points = lightning:generatePoints({})
        for k = 1,#lightning.points do
            if k%2 == 1 then
                lightning.xPoints[k] = lightning.points[k] + lightning.x
            else
                lightning.xPoints[k] = lightning.points[k]
            end
        end
    end
    function lightning:die(other)
        lightning:setInactive()
        ParticleSystem.lineBurst(other.x, other.y, 15, 400, 500, global_pallete.black_color, 7, 0.95, 0.8, false, 0.5, boss.lineEmitter)
    end
    return lightning
end

function bossDeath()
    local whiteScreen = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.DEATHLAYER_1)
    function whiteScreen:draw()
        love.graphics.setColor(global_pallete.white_color)
        love.graphics.rectangle("fill", -10, -10, 100, 100)
    end
    local plr = gameState.state.plr
    local fakePlr = GameObjects.newGameObject(1,plr.x, plr.y, plr.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
    fakePlr.flip = plr.flip
    local fakeBoss = GameObjects.newGameObject(2,boss.x, boss.y, boss.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
    fakeBoss.flip = boss.flip
    plr.invincible = true
    boss.coroutines = {}
    boss.hpBar:setInactive()
    plr.hpBar:setInactive()
    fakePlr.color = global_pallete.black_color
    fakeBoss.color = global_pallete.black_color
    local deathEmitter = ParticleSystem.createEmitter(30, false, GameObjects.DrawLayers.IGNORE_DT)
    local deathRoutineObj = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.IGNORE_DT)
    deathRoutineObj:startCoroutine(
        function()
            Camera.ignoreDT = true
            gameState.timeScale = 0
            SoundManager.playSound("BossFinish")
            Camera.shake(0.7)
            ParticleSystem.burst(boss.x, boss.y, 20, 350, 450, global_pallete.black_color, 5, 0.95, 0.8, false, 1, deathEmitter)
            coroutine.yield(2)
            gameState.timeScale = 0.1
            whiteScreen:setInactive()
            fakePlr:setInactive()
            fakeBoss:setInactive()
            SoundManager.playSound("Whitenbackground_Slow")
            local pop = createCircularPop(32, 32, global_pallete.white_color, 100, 100, 0, 1, 0.33, GameObjects.DrawLayers.POSTCAMERA)
            pop:setActive()
            if not boss.fighting or boss.phase2 then
                MusicManager.fadeOut(2)
            end
            coroutine.yield(3)
            if not boss.fighting or boss.phase2 then
                MusicManager.stopAllTracks()
            end
            local pop2 = createCircularPop(32, 32, global_pallete.white_color, 100, 100, 1, 1, 2, GameObjects.DrawLayers.POSTCAMERA)
            pop2:setActive()
            coroutine.yield(1)
            gameState.timeScale = 1
            Camera.ignoreDT = false
            gameState.goToNextLevel()
        end
    ,"deathRoutine")
end

function bossCollision(boss, other)
    if other.Collider.layer == Collision.Layers.PLAYER_ATTACK and boss.hurtWhiteTime <= 0 then
        boss.currentHP = boss.currentHP - 1
        boss.squashStretcher:squashStretch(0.7, 1.3)
        boss.hurtWhiteTime = 0.3
        SoundManager.playSoundRandomizedPitch("Hit", 0.5, 1.5)
        ParticleSystem.burst(boss.x, boss.y, 5, 300, 350, global_pallete.light_blue_color, 3, 0.9, 0.75, false, 0.35)
        if boss.currentHP <= 0 and not boss.dying then
            boss.dying = true
            bossDeath()
        end
    end
end

function createHomingProjectile()
    local proj = GameObjects.newGameObject(-1, 0, 0, 0, false, GameObjects.DrawLayers.PARTICLES)
    Collision.addCircleCollider(proj, 3, Collision.Layers.HURTER, {})
    Physics.addRigidBody(proj)
    proj.baseRadius = 3
    proj.radius = 3
    proj.fired = false
    proj.anchorPos = {x=0,y=0}
    proj.figure8Speed = 5
    proj.seekSpeed = attackParams.homingProjectileSpeed
    proj.randOffset = math.random() * math.pi * 2
    proj.jetEmitter = ParticleSystem.createJetEmitter(proj, 10, 10, global_pallete.black_color, 2, 0.95, 0.9, false, 0.3)
    GameObjects.attachComponent(proj, createLifeTimer(proj, 10))
    function proj:draw()
        love.graphics.setColor(global_pallete.black_color)
        love.graphics.circle("fill", proj.x, proj.y, proj.radius)
    end
    function proj:update(dt)
        if not proj.fired then
            proj.x = proj.anchorPos.x + 4 * math.cos((timeElapsed + proj.randOffset)* proj.figure8Speed)
            proj.y = proj.anchorPos.y + 4 * math.sin((timeElapsed + proj.randOffset)* proj.figure8Speed * 2)
        end
    end
    function proj:spawn(x, y)
        proj.x, proj.y, proj.anchorPos.x, proj.anchorPos.y = x, y, x, y
        proj.radius = proj.baseRadius
        proj.fired = false
        ParticleSystem.burst(proj.x, proj.y, 5, 200, 300, global_pallete.black_color, 3, 0.95, 0.85, false, 0.4)
        proj:setActive()
        proj:startCoroutine(proj.seekAfterDelay, "seekAfterDelay")
    end

    proj.seekAfterDelay =
        function()
            coroutine.yield(attackParams.homingProjectileArmTime * 0.75)
            ParticleSystem.charge(proj.x, proj.y, 5, 30, 30, global_pallete.black_color, 3, 0.9, true, 0.3, 8)
            SoundManager.playSound("GenericChargeup")
            coroutine.yield(attackParams.homingProjectileArmTime * 0.25)
            SoundManager.playSoundRandomizedPitch("WooshDownQuick", 0.75, 1.25)
            ParticleSystem.burst(proj.x, proj.y, 5, 200, 300, global_pallete.black_color, 3, 0.95, 0.85, false, 0.4)
            proj.fired = true
            proj.jetEmitter:setActive()
            proj.jetEmitter.emitting = true
            proj:startCoroutine(proj.seekTarget, "seekTarget")
        end

    function proj:pSetInactive()
        ParticleSystem.burst(proj.x, proj.y, 5, 200, 300, global_pallete.black_color, 3, 0.95, 0.85, false, 0.4)
        proj.coroutines = {}
        proj.jetEmitter.emitting = false
    end
    function proj:die(other)
        proj:setInactive()
    end

    proj.seekTarget =
        function()
            while(true) do
                proj.RigidBody.velocity.x, proj.RigidBody.velocity.y = clampVecToLength(boss.target.x - proj.x, boss.target.y - proj.y, proj.seekSpeed)
                coroutine.yield(0.1)
            end
        end
    return proj
end

function createSkyLaser()
    local laser = createScalingRectangle("vertical", 0, attackParams.skyLaserWidth, global_pallete.red_color, 0.15, GameObjects.DrawLayers.PARTICLES)
    laser.height = 64
    Collision.addBoxCollider(laser, attackParams.skyLaserWidth-5, 64, Collision.Layers.HURTER, {})
    laser.undeflectable = true
    function laser:die()
         -- no op
    end
    return laser
end

function createHealthbar(y)
    local hpBar = GameObjects.newGameObject(-1,32,y,0,true,GameObjects.DrawLayers.POSTCAMERA)
    local width = 60
    local height = 4
    function hpBar:draw()
        if boss.fighting then
            love.graphics.setColor(global_pallete.white_color)
            love.graphics.rectangle("fill", hpBar.x - width/2, hpBar.y - height/2, width, height)
            love.graphics.setColor(global_pallete.red_color)
            love.graphics.rectangle("fill", hpBar.x - width/2 + 1, hpBar.y - height/2 + 1, clamp(1,width * boss.currentHP / boss.maxHP - 2,width) , height - 2)
        end
    end
    return hpBar
end

function createRadahnClone()
    local clone = GameObjects.newGameObject(2,0,0,26,false,GameObjects.DrawLayers.PARTICLES)
    Animation.addAnimator(clone)
    Animation.addAnimation(clone, {26}, 0.1, "fall", true)
    Animation.addAnimation(clone, {29,30,31}, 0.1, "slam", false,
        function(clone)
            clone:setInactive()
            clone.dashTrailer.trailing = false
        end)
    Physics.addRigidBody(clone)
    clone.dashTrailer = createDashTrailer(clone, 2, 10, 0.3, true, GameObjects.DrawLayers.PARTICLES)
    clone.color = {0.25, 0.25, 0.25, 1}
    clone.lightningSlamHitbox = createCircleHitbox(9)
    function clone:update(dt)
        if clone.y > boss.floorY then
            Physics.zeroVelocity(clone)
            Physics.zeroAcceleration(clone)
            clone.y = boss.floorY
            Animation.changeAnimation(clone, "slam")
            clone.lightningSlamHitbox.x, clone.lightningSlamHitbox.y = clone.x, clone.y
            clone.lightningSlamHitbox:setActive()
            ParticleSystem.lineBurst(clone.x, clone.y, 15, 400, 500, global_pallete.black_color, 7, 0.95, 0.8, false, 0.5, boss.lineEmitter)
            Camera.jiggle(0, -0.3)
            -- create a bolt of lightning
            local lightning = boss.lightningPool:getFromPool()
            local dir = clone.x > 32 and -1 or 1
            lightning.RigidBody.velocity.x = dir * attackParams.radahnLightningSpeed
            lightning.x, lightning.y = clone.x, 32
            lightning.dir = dir
            lightning:setActive()
            SoundManager.playSoundRandomizedPitch("BossLandLight", 0.75, 1.25)
        end
    end
    return clone
end