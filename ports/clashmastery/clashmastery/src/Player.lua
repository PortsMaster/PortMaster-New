local plrWhiteShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 outputColor = Texel(tex, texture_coords) * color;
        // add a bunch to the sprite to make it white
        outputColor += vec4(0.6, 0.6, 0.6,0);
        return outputColor;
    }
]]

local moveSpeed = 50
local jumpSpeed = -170
local gravityAccel = 700
local fallMultiplier = 1.5

-- active = actual deflect frames
local activeDeflectTime = 0.4
-- regular = amount of time it takes to get control back
local deflectTime = 0.4
-- cooldown = time it takes to be able to deflect again UNLESS you deflect an attack, which resets the cooldown
local deflectCooldown = 0.1
-- slow down falls and give a tiny 'hop' with a succcessful deflect
local deflectFallSlowdown = 0.75
local deflectHopSpeed = -50
local stageMinX = 4
local stageMaxX = 60
local slashTime = 0.32
local slashCooldown = 0.4
local hurtJump = -120
local plrIframes = 1
local plrMaxHealth = 5
function createPlayer(x, y)
    local plr = GameObjects.newGameObject(1,x,y,0,true,GameObjects.DrawLayers.PLAYER)
    Physics.addRigidBody(plr)
    Collision.addCircleCollider(plr, 3, Collision.Layers.PLAYER, {Collision.Layers.HURTER, Collision.Layers.BOSS})
    plr.Collider.onCollisionEnter = playerCollisionEnter -- TODO we also need a collisionStay, because we might be inside the deflect-box while we deflect
    plr.Collider.onCollision = playerCollisionStay
    Animation.addAnimator(plr)
    plr.squashStretcher = createSquashStretcher(plr, 10)
    GameObjects.attachComponent(plr, plr.squashStretcher)

    Animation.addAnimation(plr, {0,0,0,0,0,1,2,1,0,0,0,0,1,2,3,4,3,4,3,2,1}, 0.1, "idle", true)
    Animation.addAnimation(plr, {5,6,7,8,9,10,11,12}, 0.08, "run", true)
    Animation.addAnimation(plr, {13}, 0.1, "jump", true)
    Animation.addAnimation(plr, {15,16,17,18}, 0.1, "fall1", false,
        function(plr)
            Animation.changeAnimation(plr, "fall2")
        end)
    Animation.addAnimation(plr, {17,18}, 0.2, "fall2", true)
    Animation.addAnimation(plr, {22,19,19,19,19,19}, activeDeflectTime/6, "active_deflect", false,
        function(plr)
            Animation.changeAnimation(plr, "deflect")
            end)
    Animation.addAnimation(plr, {22,23}, 0.1, "deflect", false,
        function(plr)
            Animation.changeAnimation(plr, "idle")
            end)
    Animation.addAnimation(plr, {20,21,19,19,19}, 0.1, "deflect_success", false,
        function(plr)
            Animation.changeAnimation(plr, "idle")
        end)
    Animation.addAnimation(plr, {24,25,26,27}, 0.08, "slash", false,
        function(plr)
            Animation.changeAnimation(plr, "idle")
        end)
    Animation.addAnimation(plr, {29,29,30,31}, 0.1, "hurt", false,
        function(plr)
            Animation.changeAnimation(plr, "idle")
            plr.hurt = false
            plr.slashing = false
            plr.deflecting = false
            plr.activeDeflecting = false
        end)

    plr.deflectActiveFX = createDeflectActiveFX(plr)

    plr.maxHP = plrMaxHealth
    plr.currentHP = plr.maxHP
    plr.hpBar = createPlayerHealthbar(plr)
    plr.grounded = true
    plr.activeDeflecting = false
    plr.deflecting = false
    plr.deflectCooldown = 0
    plr.dying = false
    plr.slashCooldown = 0
    plr.slashing = false
    plr.slashHitbox = createPlayerSlashHitbox(plr)
    plr.lineEmitter = ParticleSystem.createEmitter(50, true, GameObjects.DrawLayers.PARTICLES)
    plr.deflectPop = createCircularPop(0,0,global_pallete.orange_color, 3, 8, 1, 0.25, 0.2,GameObjects.DrawLayers.PARTICLES)
    plr.hurt = false
    plr.usingHurtShader = false
    plr.invincible = false
    plr.frozen = false
    plr.fighting = false
    plr.hurtVignette = createHurtVignette()

    plr.hurtRoutine =
        function()
            local numSteps = 3
            local hurtTime = 0.4
            for k = 1,numSteps do
                plr.usingHurtShader = not plr.usingHurtShader
                coroutine.yield(hurtTime / numSteps)
            end
            plr.usingHurtShader = false
            plr.hurt = false
        end

    plr.iframeRoutine =
        function()
            while plr.hurt do
                -- do nothing
                coroutine.yield(0.01)
            end
            local numSteps = 6
            for k = 1,numSteps do
                plr.alpha = plr.alpha == 1 and 0.5 or 1
                coroutine.yield(plrIframes / numSteps)
            end
            plr.alpha = 1
            plr.invincible = false
        end

    plr.successfulDeflect =
        function(other)
            plr.activeDeflecting = true
            plr.deflecting = true
            plr.deflectCooldown = 0
            Animation.changeAnimation(plr, "deflect_success")
            plr.deflectActiveFX:setInactive()
            plr:startCoroutine(plr.deflectRoutine, "deflectRoutine")
            -- vfx
            local tX, tY = plr.x + plr.flip * 3, plr.y - 3
            ParticleSystem.lineBurst(tX, tY, 10, 400, 500, global_pallete.orange_color, 6, 0.95, 0.8, false, 0.5, plr.lineEmitter)
            plr.deflectPop.x, plr.deflectPop.y = tX, tY
            plr.deflectPop:setActive()
            Camera.jiggle(plr.flip * 0.3, 0)

            -- slide back a little and do a little bounce if mid-air
            local dir = -plr.flip
            if other and other.dir then
                dir = other.dir
                plr.flip = -dir
            end
            local deflectDist = 3
            if other.deflectDist then
                deflectDist = other.deflectDist
            end
            plr.x = clamp(stageMinX, plr.x + dir * deflectDist, stageMaxX)
            if not plr.grounded then
                plr.RigidBody.velocity.x = 0
                plr.RigidBody.velocity.y = deflectHopSpeed
                plr.RigidBody.acceleration.y = gravityAccel * deflectFallSlowdown
            end

            SoundManager.playSoundRandomizedPitch("DeflectSuccess1", 0.7, 1.3)
            SoundManager.playSoundRandomizedPitch("DeflectSuccess2", 0.7, 1.3)
            SoundManager.playSoundRandomizedPitch("DeflectSuccess3v2", 0.7, 1.3)
        end


    plr.deflectRoutine =
        function()
            coroutine.yield(activeDeflectTime)
            plr.activeDeflecting = false
            coroutine.yield(deflectTime - activeDeflectTime)
            plr.deflecting = false
        end

    plr.slashRoutine =
        function()
            coroutine.yield(slashTime)
            plr.slashing = false
        end

        
    function plr:draw() -- override so we can use a shader
        if plr.usingHurtShader then
            love.graphics.setShader(plrWhiteShader)
        end
        Texture.draw(plr.texture, plr.spr, plr.x, plr.y, plr.flip, plr.flipY, plr.alpha,plr.color,plr.rotation,plr.cachedQuad, plr.scaleX, plr.scaleY)
        love.graphics.setShader()
    end

    function plr:update(dt)
        if Input.getButtonPressed("9") and debugMode then
            gameState.timeScale = gameState.timeScale == 1 and 0.25 or 1
        end
        if plr.frozen then
            return
        end
        if (not plr.deflecting or not plr.grounded) and not plr.slashing and not plr.hurt then
            local moving = false
            if leftInputHeld() then
                plr.RigidBody.velocity.x = -moveSpeed
                moving = true
                plr.flip = -1
            elseif rightInputHeld() then
                plr.RigidBody.velocity.x = moveSpeed
                moving = true
                plr.flip = 1
            else
                plr.RigidBody.velocity.x = 0
                moving = false
            end
            if plr.grounded then
                Animation.changeAnimIfNecessary(plr, moving and "run" or "idle")
            end
            if Input.getMappedButtonPressed("jump") and plr.grounded then
                Animation.changeAnimation(plr, "jump")
                plr.grounded = false
                plr.RigidBody.velocity.y = jumpSpeed
                plr.RigidBody.acceleration.y = gravityAccel
                plr.squashStretcher:squashStretch(0.75,1.5)
                SoundManager.playSound("Jump")
                ParticleSystem.burst(plr.x, plr.y + 4, 5, 200, 250, global_pallete.white_color, 2, 0.95, 0.6, false, 0.35)
            end
        else
            if not plr.slashing or plr.grounded then
                plr.RigidBody.velocity.x = 0
            end
        end

        if Input.getMappedButtonReleased("jump") and plr.RigidBody.velocity.y < 0 then
            -- releasing jump makes you fall a little faster
            plr.RigidBody.velocity.y = plr.RigidBody.velocity.y / 2
            plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
            if not Animation.isInState(plr, "fall2") and not plr.deflecting and not plr.slashing and not plr.hurt then
                Animation.changeAnimIfNecessary(plr, "fall1")
            end
        elseif plr.RigidBody.velocity.y > 0 and plr.RigidBody.acceleration.y == gravityAccel then
            -- falling in general has heavier gravity than rising
            plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
            if not Animation.isInState(plr, "fall2") and not plr.deflecting and not plr.slashing and not plr.hurt then
                Animation.changeAnimIfNecessary(plr, "fall1")
            end
        end

        if Input.getMappedButtonPressed("deflect") and plr.deflectCooldown <= 0 and not plr.slashing and not plr.hurt then
            plr.deflecting = true
            plr.activeDeflecting = true
            plr.deflectCooldown = deflectCooldown
            plr.deflectActiveFX:setActive()
            plr:startCoroutine(plr.deflectRoutine, "deflectRoutine")
            Animation.changeAnimation(plr, "active_deflect")
            SoundManager.playSound("Deflect")
        end

        if not plr.deflecting and not plr.activeDeflecting and plr.deflectCooldown > 0 then
            plr.deflectCooldown = plr.deflectCooldown - dt
        end

        if Input.getMappedButtonPressed("attack") and plr.slashCooldown <= 0 and not plr.slashing and not plr.deflecting and not plr.hurt then
            plr.slashCooldown = slashCooldown
            plr.slashing = true
            plr.slashHitbox:setActive()
            Animation.changeAnimation(plr, "slash")
            plr:startCoroutine(plr.slashRoutine, "slashRoutine")
            SoundManager.playSoundRandomizedPitch("SwordDownBass", 0.75, 1.25)
        end

        if plr.slashCooldown > 0 then
            plr.slashCooldown = plr.slashCooldown - dt
        end


        if plr.y > gameState.state.floorHeight and plr.RigidBody.velocity.y > 0 then
            plr.y = gameState.state.floorHeight
            plr.grounded = true
            plr.RigidBody.acceleration.y = 0
            plr.RigidBody.velocity.y = 0
            SoundManager.playSound("Land")
            plr.squashStretcher:squashStretch(1.5, 0.8)
            ParticleSystem.burst(plr.x, plr.y + 4, 4, 200, 250, global_pallete.white_color, 3, 0.9, 0.7, false, 0.35)
        end

        -- bounds
        if plr.x < stageMinX and plr.RigidBody.velocity.x < 0 then
            plr.x = stageMinX - 0.5
            plr.RigidBody.velocity.x = 0
        elseif plr.x > stageMaxX and plr.RigidBody.velocity.x > 0 then
            plr.x = stageMaxX
            plr.RigidBody.velocity.x = 0
        end
    end

    return plr
end

function playerCollisionEnter(plr, other)
    if other.Collider.layer == Collision.Layers.HURTER and not plr.frozen and not other.ignore then
        if plr.activeDeflecting and not other.undeflectable then
            other:die(plr)
            plr.successfulDeflect(other)
        else
            if not plr.invincible then
                Animation.changeAnimation(plr, "hurt")
                SoundManager.playSound("PlayerHurt")
                plr.hurt = true
                plr.invincible = true
                plr:startCoroutine(plr.hurtRoutine, "hurtRoutine")
                plr:startCoroutine(plr.iframeRoutine, "iframeRoutine")
                plr.RigidBody.velocity.x = 0
                plr.RigidBody.velocity.y = hurtJump
                plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
                plr.grounded = false
                plr.deflectActiveFX:setInactive()
                plr.hurtVignette:setActive()
                if gameState.state.practiceController and not plr.fighting then
                    gameState.state.practiceController:incrementMistakes()
                end
                Camera.shake(0.3)
                if plr.fighting then
                    plr.currentHP = plr.currentHP - 1
                    if plr.currentHP <= 0 and not plr.dying then
                        plr.dying = true
                        playerDeath(other.dir)
                    end
                end
            end
            other:die(plr)
        end
    end
end

function playerCollisionStay(plr, other)
    if other.Collider.layer == Collision.Layers.BOSS and other.solid then
        -- can't walk through the boss when they're solid
        if other.x < plr.x and plr.RigidBody.velocity.x < 0 then
            plr.x = other.x + other.Collider.radius + plr.Collider.radius - 0.5
            plr.RigidBody.velocity.x = 0
        end
        if other.x > plr.x and plr.RigidBody.velocity.x > 0 then
            plr.x = other.x - (other.Collider.radius + plr.Collider.radius) + 0.5
            plr.RigidBody.velocity.x = 0
        end
    end
end

function createDeflectActiveFX(parent)
    local fx = GameObjects.newGameObject(1,0,0,29,false,GameObjects.DrawLayers.PARTICLES)
    fx.parent = parent
    fx.startRadius = 1
    fx.finalRadius = 6
    fx.radiusGrowthRate = 60
    fx.radius = fx.startRadius
    GameObjects.attachComponent(fx, createLifeTimer(fx, activeDeflectTime))
    function fx:pSetActive()
        fx.x, fx.y = fx.parent.x, fx.parent.y
        fx.radius = fx.startRadius
    end
    function fx:update(dt)
        fx.x, fx.y = fx.parent.x, fx.parent.y
        if fx.radius < fx.finalRadius then
            fx.radius = fx.radius + fx.radiusGrowthRate * dt
        else
            fx.radius = fx.finalRadius
        end
    end
    function fx:draw()
        love.graphics.setColor(0.494, 0.769, 0.757, 0.5) -- the blue color from na16 palette
        love.graphics.circle("line", fx.x, fx.y, fx.radius)
    end
    return fx
end

function createPlayerSlashHitbox(parent)
    local hitbox = GameObjects.newGameObject(-1,0,0,0,false)
    Collision.addCircleCollider(hitbox, 7, Collision.Layers.PLAYER_ATTACK, {})
    hitbox.parent = parent
    GameObjects.attachComponent(hitbox, createLifeTimer(hitbox, 0.2))
    function hitbox:update(dt)
        hitbox.x, hitbox.y = hitbox.parent.x + hitbox.parent.flip * 8, hitbox.parent.y
    end
    function hitbox:pSetActive()
        hitbox.x, hitbox.y = hitbox.parent.x + hitbox.parent.flip * 8, hitbox.parent.y
    end
    return hitbox
end

function createHurtVignette()
    local hurtFX = GameObjects.newGameObject(4,32,32,0,false,GameObjects.DrawLayers.POSTCAMERA)
    hurtFX.lifeTimer = createLifeTimer(hurtFX, 0.3)
    GameObjects.attachComponent(hurtFX, hurtFX.lifeTimer)
    hurtFX.color = global_pallete.red_color
    function hurtFX:update(dt)
        hurtFX.alpha = hurtFX.lifeTimer.lifeTime / hurtFX.lifeTimer.maxLifeTime * 0.5
    end
    return hurtFX
end

function createPlayerHealthbar(plr)
    local hpBar = GameObjects.newGameObject(-1,14,2,0,true,GameObjects.DrawLayers.POSTCAMERA)
    hpBar.plr = plr
    local segmentWidth = 4
    local segmentSpacing = 1
    local totalWidth = (plr.maxHP + 1) * segmentSpacing + plr.maxHP * segmentWidth
    local height = 4
    function hpBar:draw()
        if hpBar.plr.fighting then
            love.graphics.setColor(global_pallete.black_color)
            love.graphics.rectangle("fill", hpBar.x - totalWidth/2, hpBar.y - height/2, totalWidth, height)
            for k = 1,hpBar.plr.currentHP do
                love.graphics.setColor(global_pallete.red_color)
                love.graphics.rectangle("fill", hpBar.x - totalWidth/2 + segmentSpacing*k + (k-1)*segmentWidth, hpBar.y - height/2 + 1, segmentWidth, height-2)
            end
        end
    end
    return hpBar
end

function playerDeath(attackDir)
    gameState.state.numDeaths = gameState.state.numDeaths + 1
    gameState.state.bossHealthOnDeath = gameState.state.boss.currentHP
    gameState.state.justGotBackUp = true
    gameState.state.bossStateIndex = gameState.state.boss.stateSelector.stateIndex - 1
    local plr, boss = gameState.state.plr, gameState.state.boss
    plr:setInactive()
    boss:setInactive()
    plr.hpBar:setInactive()
    boss.hpBar:setInactive()

    local deathEmitter = ParticleSystem.createEmitter(30, false, GameObjects.DrawLayers.DEATHLAYER_2)

    local fakePlr = GameObjects.newGameObject(1, plr.x, plr.y, plr.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
    Physics.addRigidBody(fakePlr)
    function fakePlr:update(dt)
        if fakePlr.y > gameState.state.floorHeight and fakePlr.RigidBody.velocity.y > 0 then
            Physics.zeroVelocity(fakePlr)
            Physics.zeroAcceleration(fakePlr)
        end
        if fakePlr.x > 58 then
            fakePlr.x = 58
            fakePlr.RigidBody.velocity.x = 0
        end
        if fakePlr.x < 6 then
            fakePlr.x = 6
            fakePlr.RigidBody.velocity.x = 0
        end
    end
    local fakeBoss = GameObjects.newGameObject(2, boss.x, boss.y, boss.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
    fakeBoss.flip = boss.flip

    fakePlr.dashTrailer = createDashTrailer(fakePlr, 1, 10, 0.2, true, GameObjects.DrawLayers.DEATHLAYER_2)
    fakeBoss.dashTrailer = createDashTrailer(fakeBoss, 2, 10, 0.2, true, GameObjects.DrawLayers.DEATHLAYER_2)

    fakePlr.color = global_pallete.black_color
    fakeBoss.color = global_pallete.black_color

    local deathScreen = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.DEATHLAYER_1)
    function deathScreen:draw()
        love.graphics.setColor(global_pallete.red_color)
        love.graphics.rectangle("fill", -10, -10, 100, 100)
        love.graphics.setColor(global_pallete.black_color)
        love.graphics.rectangle("fill", -10, gameState.state.floorHeight + 6, 100, 64)
    end

    -- slowly move the two to the extremes of the arena
    local minX = 4
    local maxX = 60
    -- separate the two
    local dir = attackDir or (plr.x > boss.x and 1 or -1)
    local plrTarget = dir == 1 and maxX or minX
    local bossTarget = dir == 1 and minX or maxX
    local plrDir = dir
    fakePlr.flip = -plrDir

    Animation.addAnimator(fakePlr)
    Animation.addAnimation(fakePlr, {29,29,30,30,31,31,31,31,31,31}, 0.4, "death1", true)
    Animation.addAnimation(fakePlr, {35}, 1, "death2", true)
    Animation.changeAnimation(fakePlr, "death1")

    ParticleSystem.burst(fakePlr.x, fakePlr.y, 10, 350, 450, global_pallete.black_color, 5, 0.95, 0.8, false, 1, deathEmitter)
    deathScreen.readyToRestart = false
    deathScreen:startCoroutine(
        function()
            -- take 8 steps, with trails
            local distToBossTarget = bossTarget - fakeBoss.x
            fakePlr.RigidBody.velocity.x = plrDir * 15
            fakePlr.RigidBody.velocity.y = -30
            fakePlr.RigidBody.acceleration.y = 40
            SoundManager.playSound("PlayerDeath")
            Camera.shake(0.35)
            coroutine.yield(0.1)


            local numSteps = 8
            for k = 1,numSteps do
                local tgtXboss, tgtYboss = fakeBoss.x + distToBossTarget/numSteps, fakeBoss.y
                fakeBoss.dashTrailer:trailFromTo(fakeBoss.x, fakeBoss.y, tgtXboss, tgtYboss, 2)
                fakeBoss.x, fakeBoss.y = tgtXboss, tgtYboss
                coroutine.yield(0.1)
                if k == 1 then
                    gameState.timeScale = 0.1
                elseif k == 2 then
                    gameState.timeScale = 1
                end
            end
            coroutine.yield(0.5)

            fakePlr.spr = 35
            Animation.changeAnimation(fakePlr, "death2")
            fakePlr.dashTrailer:trailFromTo(fakePlr.x, fakePlr.y, plrTarget, gameState.state.floorHeight, 5)
            Physics.zeroVelocity(fakePlr)
            Physics.zeroAcceleration(fakePlr)
            fakePlr.x, fakePlr.y = plrTarget, gameState.state.floorHeight
            fakeBoss.x = bossTarget
            coroutine.yield(1)
            worldSpaceText("KNOCKED DOWN", 32, 8, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
            SoundManager.playSound("HypeParticles")
            Camera.shake(0.5)
            coroutine.yield(1)
            local prompt = createControlsPrompt(32, 16, "attack", "press ~\nto get back up")
            prompt.color = global_pallete.black_color
            prompt.useBlackBG = false
            prompt:setActive()
            gameState.state.playerKnockdownXPosition = fakePlr.x
            gameState.state.bossKnockdownXPosition = fakeBoss.x
            deathScreen.readyToRestart = true
        end
    , "deathRoutine")

    function deathScreen:update(dt)
        if deathScreen.readyToRestart and Input.getMappedButtonPressed("attack") then
            gameState.loadLevel = true
        end
    end
end