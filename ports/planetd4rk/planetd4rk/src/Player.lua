local gravityAccel = 1000
local fallMultiplier = 1.5
local plrFloorOffset = 7.5 -- penetrate the collider a tiny bit to allow us to "stay" in it
local plrWallOffset = 4.5
local plrBonkMargin = 4 -- Player must be within this many units of a ceiling to "bonk" head
local jumpSpeed = -300
local wallJumpVSpeed = -270
local wallJumpHSpeed = 240
local wallJumpLerpRate = 5
local terminalVelocity = 250
local terminalWallSlideVelocity = 40
local moveSpeed = 125
local floorClimbMargin = 4
local wallJumpTime = 0.35
local coyoteWallJumpTime = 0.05
local coyoteJumpTime = 0.15
local dashSpeed = 500
local dashTime = 0.2
local dashDragFactor = {x=0.9, y=0.9}
local baseEnemyAttackRange = 50
local slashTime = 0.15
local slashSpeed = 400
local slashLength = 80
local slashGraceTime = 0.2
local slashIntentTime = 0.2
local enableSlashPriority = true
local maxWallHoldOffTime = 0.1 -- The amount of time you need to hold the button to leave a wall
local slashDirs = {
    {x=0,y=-1},
    {x=1,y=-1},
    {x=1,y=0},
    {x=1,y=1},
    {x=0,y=1},
    {x=-1,y=1},
    {x=-1,y=0},
    {x=-1,y=-1},
    {x=0,y=-1}
}
local slashColor = {38/255, 219/255, 1}
local greenSlashColor = {38/255, 219/255, 110/255}
local capeBaseColor = {194/225, 23/225, 114/225}
local capeDepletedColor = {194/225, 191/225, 23/225}
local capeBaseRightOffsets = {
    {x=-1,y=0},
    {x=-1,y=0},
    {x=-1,y=1},
    {x=0,y=1},
    {x=-0,y=1}
}
local capeBaseLeftOffsets = {
    {x=1,y=0},
    {x=1,y=0},
    {x=1,y=1},
    {x=0,y=1},
    {x=-0,y=1}
}

-- Debug: to flip a switch and go to preset slash directions
local debugClampSlashDirs = false

local plr
function createPlayer(x, y, gameState)
    plr = GameObjects.newGameObject(1, x, y, 0, true, GameObjects.DrawLayers.PLAYER)
    plr.gameState = gameState
    Collision.addCircleCollider(plr, 9, Collision.Layers.PLAYER, {Collision.Layers.FLOOR})
    Collision.addBoxCollider(plr, 10, 18, Collision.Layers.PLAYER, {Collision.Layers.FLOOR, Collision.Layers.TRIGGER})
    Physics.addRigidBody(plr, nil, {x=0,y=gravityAccel})

    Animation.addAnimator(plr)
    Animation.addAnimation(plr, {0,1,2,3}, 0.2, 1, true) -- idle
    Animation.addAnimation(plr, {4,5,6,7,8,9}, 0.1, 2, true) -- run
    Animation.addAnimation(plr, {10,11}, 0.15, 3, false, 
        function(obj)
            Animation.changeAnimation(plr, 4) -- change to secondary jump
        end) -- jumpStart
    Animation.addAnimation(plr, {11,11}, 0.2, 4, true) -- jump continue
    Animation.addAnimation(plr, {12,12}, 0.2, 5, true) -- Fall
    Animation.addAnimation(plr, {13,13}, 0.2, 6, true) -- Wall slide
    
    plr.Collider.onCollision = playerOnCollision
    plr.Collider.onCollisionEnter = playerOnCollisionEnter
    plr.Collider.onCollisionExit = playerOnCollisionExit

    plr.Trailer = createDashTrailer(plr, 1, 10, 0.3, true, GameObjects.DrawLayers.PLAYER)

    plr.lastFloor = nil
    plr.lastWall = nil
    plr.coyoteWall = nil
    plr.attackRange = baseEnemyAttackRange

    plr.capeSegments = createFullCape(plr, capeBaseRightOffsets)
    plr.capeObj = createCapeObj(plr)
    plr.slashIndicator = createSlashIndicator(plr)
    plr.slashObj = createSlashObj(plr)
    plr.lastSlashAngle = 0
    plr.triangleSlashFX = nil
    plr.missedSlashInfo = nil
    plr.intendedToSlash = false
    plr.maxSlashIntentTime = slashIntentTime
    plr.slashIntentTime = plr.maxSlashIntentTime


    -- state management
    plr.debug = false
    plr.grounded = false
    plr.touchingWall = false
    plr.canWallJump = false
    plr.wallJumped = false
    plr.dashing = false
    plr.slashing = false
    plr.canDash = true
    plr.canCoyoteJump = false
    plr.wallHoldOffTime = 0
    plr.invincible = false
    plr.die = plrDie

    plr.debugObj = GameObjects.newGameObject(-1,0,0,0,true)
    plr.resetHolder = holdDrawer("hold r to reset level")
    plr.titleHolder = holdDrawer("hold t to return to title")
    plr.upToJumpHolder = holdDrawer((gameState.upToJumpEnabled and "disabling" or "enabling").. " up to jump  ")

    function plr.debugObj:draw()
        if plr.debug then
            love.graphics.print(tostring(plr.wallJumped), 10, 10)
            love.graphics.print(tostring(plr.grounded), 10, 24)
            love.graphics.setColor(0,0,1,1)
            love.graphics.circle('line', plr.x, plr.y, plr.attackRange)
            local slashInfo = getEnemySlashAngle()
            local enemy = slashInfo[1]
            local closestAngle = slashInfo[2]
            if enemy then
                local lineLength = 16
                local xOffset = lineLength * math.cos(math.rad(closestAngle))
                local yOffset = lineLength * math.sin(math.rad(closestAngle))
                love.graphics.line(enemy.x - xOffset * 0.6, enemy.y - yOffset * 0.6, enemy.x + xOffset, enemy.y + yOffset)
            end
        end
    end

    function plr:update(dt)
        if not plr.dashing and not plr.slashing then
            if plr.wallJumped then
                if leftInputHeld() then
                    plr.RigidBody.velocity.x = lerp(plr.RigidBody.velocity.x, -moveSpeed, dt * wallJumpLerpRate)
                elseif rightInputHeld() then
                    plr.RigidBody.velocity.x = lerp(plr.RigidBody.velocity.x, moveSpeed, dt * wallJumpLerpRate)
                else
                    plr.RigidBody.velocity.x = lerp(plr.RigidBody.velocity.x, 0, dt * wallJumpLerpRate)
                end
            else
                if plr.touchingWall and plr.wallHoldOffTime < maxWallHoldOffTime and not plr.grounded then
                    -- If the player is touching the wall, make them hold the side buttons for a little bit
                    -- before they can get off the wall. This is to prevent them from accidentally sliding
                    -- off the wall when walljumping.
                    if (leftInputHeld() and plr.lastWall.x > plr.x) 
                    or (rightInputHeld() and plr.lastWall.x < plr.x) then
                        plr.wallHoldOffTime = plr.wallHoldOffTime + dt
                    elseif plr.RigidBody.velocity.x ~= 0 then
                        plr.wallHoldOffTime = 0
                    end
                else
                    -- Default movement
                    if leftInputHeld() then
                        plr.RigidBody.velocity.x = -moveSpeed
                    elseif rightInputHeld() then
                        plr.RigidBody.velocity.x = moveSpeed
                    elseif plr.RigidBody.velocity.x ~= 0 then
                        plr.RigidBody.velocity.x = 0
                    end
                end
            end
        end

        if Input.getMappedButtonPressed("attack") or plr.intendedToSlash then
            local holdingDir = nil
            if leftInputHeld() then
                holdingDir = -1
            elseif rightInputHeld() then
                holdingDir = 1
            end
            local slashInfo = getEnemySlashAngle(nil, holdingDir)
            local enemy = slashInfo[1]
            local angle = slashInfo[2]
            local index
            if debugClampSlashDirs then
                index = slashInfo[3]
            end
            if not enemy and plr.missedSlashInfo then
                -- If we're not actually in range of an enemy, BUT we recently were in range,
                -- use the cached enemy from before.

                -- Only do this IF the enemy canbeslashed though, to prevent multi-slashing
                if plr.missedSlashInfo[1] and plr.missedSlashInfo[1].canBeSlashed then
                    enemy = plr.missedSlashInfo[1]
                    angle = plr.missedSlashInfo[2]
                    slashInfo = plr.missedSlashInfo
                    print("using cached enemy")
                end
                -- Clear the cached enemy as well so we can't double-slash
                plr.missedSlashInfo = nil
            end
            if enemy then
                if plr.intendedToSlash then
                    print("slash intent accepted")
                    plr.intendedToSlash = false
                end
                SoundManager.playSound("slash")
                SoundManager.playSound("hit")
                plr.lastSlashAngle = angle
                plr.invincible = true
                local slashDir
                if debugClampSlashDirs then
                    slashDir = slashDirs[index]
                else
                    slashDir = slashInfo[3]
                end
                if enemy.directed then
                    slashDir = enemy.dir
                    -- Allow reversal of a directed slash
                    -- provided you're going in the opposite direction
                    -- but only for non vertical ones
                    -- and only on NOT the last level
                    if enemy.dir.x ~= 0 and enemy.dir.y == 0 then
                        if plr.x < enemy.x then
                            slashDir.x = 1
                        elseif plr.x > enemy.x then
                            if gameState.levelIndex ~= 40 then
                                slashDir.x = -1
                            end
                        end
                    end
                end
                plr.slashObj.rotation = math.rad(angle)
                plr.slashObj:setActive()
                Animation.changeAnimation(plr.slashObj, 1)
                plr.alpha = 0
                plr.slashObj.trailer:trailOnInterval(0.02)
                local normSlashVec = clampVecToLength(slashDir.x, slashDir.y, 2)
                plr.triangleSlashFX = createShrinkingTriangleSpike(
                    enemy.x + normSlashVec.x * slashLength, enemy.y + normSlashVec.y * slashLength,
                    enemy.x - normSlashVec.x * slashLength, enemy.y - normSlashVec.y * slashLength, 
                    20, {1,1,1}, 0.2)
                createCircularPop(enemy.x, enemy.y, {1,1,1}, 16, 28, 1, 0.2, 0.15, true)
                ParticleSystem.burst(enemy.x, enemy.y, 15, 300, 600, {1,1,1,1}, 6, 0.95, 0.85, false, 0.8)
                plr.slashing = true
                plr.slashObj.trailer:trailFromTo({x=plr.x,y=plr.y},{x=enemy.x,y=enemy.y},8, true)
                plr.x = enemy.x
                plr.y = enemy.y
                pDash(slashSpeed, slashDir.x, slashDir.y, true)
                refillDash()
                enemy:takeDamage(plr, angle)
                Camera.jiggle(normSlashVec.x * 3, normSlashVec.y * 3)
                plr:startCoroutine(finishSlash, "finishSlash")
            elseif not plr.intendedToSlash then
                -- We clearly intended to slash, so let's queue up a slash in case we get in range
                -- of an enemy.
                plr.intendedToSlash = true
                plr.slashIntentTime = plr.maxSlashIntentTime
            end
        end
        if plr.intendedToSlash then
            plr.slashIntentTime = plr.slashIntentTime - dt
            if plr.slashIntentTime <= 0 then
                plr.intendedToSlash = false
            end
        end


        if Input.getMappedButtonPressed("dash") and plr.canDash and plr.gameState.learnedDash then
            SoundManager.playSound("dash")
            plr.dashing = true
            depleteDash()
            local xDir = 0
            local yDir = 0
            if Input.getMappedButtonHeld("moveleft") then
                xDir = -1
            elseif Input.getMappedButtonHeld("moveright") then
                xDir = 1
            end
            if Input.getMappedButtonHeld("moveup") then
                yDir = -1
            elseif Input.getMappedButtonHeld("movedown") then
                yDir = 1
            end
            if xDir == 0 and yDir == 0 then
                -- Check the joystick for input
                xDir, yDir = getAxisDashDirection()
            end
            if xDir == 0 and yDir == 0 then
                xDir = plr.flip
            end
            if plr.grounded and yDir == 1 then
                yDir = 0 -- prevent dashing into the floor through platforms
            end
            pDash(dashSpeed, xDir, yDir)
            Camera.jiggle(xDir, yDir)
            Animation.changeAnimation(plr, 4)
            createCircularPop(plr.x, plr.y, {1,1,1}, 10, 20, 1, 0.2, 0.15, true)
            ParticleSystem.burst(plr.x, plr.y, 5, 400, 800, {1,1,1,1}, 5, 0.9, 0.75, false, 0.8)
            plr:startCoroutine(finishDash, "finishDash")
        end


        if Input.getMappedButtonPressed("jump") then
            if plr.grounded or (plr.canCoyoteJump and not plr.canWallJump) then
                SoundManager.playSound("jump")
                plr.RigidBody.acceleration.y = gravityAccel
                plr.RigidBody.velocity.y = jumpSpeed
                ParticleSystem.burst(plr.x, plr.y + plrFloorOffset/2, 5, 10, 200, {1,1,1,1}, 3, 0.95, 0.75, false, 0.5)
                if plr.lastFloor ~= nil then
                    leaveFloor(plr, plr.lastFloor, true)
                end
                Animation.changeAnimation(plr, 3)
            elseif plr.canWallJump then
                -- Jump off the wall
                SoundManager.playSound("jump")
                plr.RigidBody.acceleration.y = gravityAccel
                plr.wallJumped = true
                plr.canWallJump = false
                plr.RigidBody.velocity.y = wallJumpVSpeed
                plr.RigidBody.velocity.x = plr.coyoteWall.x < plr.x and wallJumpHSpeed or -wallJumpHSpeed
                local sgn = plr.coyoteWall.x > plr.x and 1 or -1 
                ParticleSystem.burst(plr.x + sgn * plrFloorOffset / 2, plr.y, 5, 10, 200, {1,1,1,1}, 3, 0.95, 0.75, false, 0.5)
                plr:startCoroutine(finishWallJump, "finishWallJump")
                Animation.changeAnimation(plr, 3)
            end
        end
        if Input.getMappedButtonReleased("jump") and plr.RigidBody.velocity.y < 0 and not plr.dashing and not plr.slashing then
            plr.RigidBody.velocity.y = plr.RigidBody.velocity.y / 2
            plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
        elseif plr.RigidBody.velocity.y > 0 and plr.RigidBody.acceleration.y == gravityAccel then
            -- If we're falling and our acceleration is our normal gravity, increase it a bunch
            plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
        end
        
        if not plr.dashing and not plr.slashing then
            if plr.RigidBody.velocity.y > terminalVelocity then
                plr.RigidBody.velocity.y = terminalVelocity
            end
            if plr.touchingWall and plr.RigidBody.velocity.y > terminalWallSlideVelocity then
                plr.RigidBody.acceleration.y = 0
                plr.RigidBody.velocity.y = terminalWallSlideVelocity
            end
        end

        -- Velocity-based animation
        if not plr.dashing and not plr.slashing then
            if plr.grounded then
                if plr.RigidBody.velocity.x > 0 then
                    flipPlr(plr, 1)
                    if plr.Animator.state ~= 2 then
                        Animation.changeAnimation(plr, 2)
                    end
                elseif plr.RigidBody.velocity.x < 0 then
                    flipPlr(plr, -1)
                    if plr.Animator.state ~= 2 then
                        Animation.changeAnimation(plr, 2)
                    end
                elseif plr.RigidBody.velocity.x == 0 then
                    if plr.Animator.state ~= 1 then
                        Animation.changeAnimation(plr, 1)
                    end
                end
            else
                if plr.RigidBody.velocity.y > 0 and not plr.touchingWall and plr.Animator.state ~= 5 then
                    Animation.changeAnimation(plr, 5)
                end
                if plr.RigidBody.velocity.x > 0 then
                    flipPlr(plr, 1)
                elseif plr.RigidBody.velocity.x < 0 then
                    flipPlr(plr, -1)
                end
            end
        end
        
        -- Cape animation for idle
        if plr.Animator.state == 1 then
            if plr.Animator.currFrame == 1 then
                plr.capeSegments[1].offset.y = 0
            elseif plr.Animator.currFrame == 3 then
                plr.capeSegments[1].offset.y = 1
            end
        elseif plr.Animator.state == 2 then
            if plr.Animator.currFrame == 3 or plr.Animator.currFrame == 6 then
                plr.capeSegments[1].offset.y = -1
                plr.capeSegments[5].offset.y = 0
            else
                plr.capeSegments[1].offset.y = 0
                plr.capeSegments[5].offset.y = 1
            end
        end

        if gameState.speedrunModeEnabled then
            updateSpeedrunClock(gameState, dt)
        end

        if Input.getMappedButtonHeld("reset") then
            plr.resetHolder.holding = true
            plr.resetHolder.holdAmount = plr.resetHolder.holdAmount + dt/3
            if plr.resetHolder.holdAmount >= 1 then
                gameState.loadLevel = true
            end
        else
            plr.resetHolder.holding = false
            plr.resetHolder.holdAmount = 0
        end

        if Input.getMappedButtonHeld("title") then
            plr.titleHolder.holding = true
            plr.titleHolder.holdAmount = plr.titleHolder.holdAmount + dt/3
            if plr.titleHolder.holdAmount >= 1 then
                gameState.levelIndex = 1
                gameState.loadLevel = true
            end
        else
            plr.titleHolder.holding = false
            plr.titleHolder.holdAmount = 0
        end

        if Input.getButtonHeld("q") then
            plr.upToJumpHolder.holding = true
            plr.upToJumpHolder.holdAmount = plr.upToJumpHolder.holdAmount + dt/1.25
            if plr.upToJumpHolder.holdAmount >= 1 then
                gameState.upToJumpEnabled = not gameState.upToJumpEnabled
                remapInputs(gameState.upToJumpEnabled)
                plr.upToJumpHolder.holding = false
                plr.upToJumpHolder.holdAmount = 0
                plr.upToJumpHolder.text = (gameState.upToJumpEnabled and "disabling" or "enabling").. " up to jump"
            end
        else
            plr.upToJumpHolder.holding = false
            plr.upToJumpHolder.holdAmount = 0
        end

    end

    function plr:setInactive()
        plr.active = false
        plr.capeObj:setInactive()
        for k = 1,#plr.capeSegments do
            plr.capeSegments[k]:setInactive()
        end
        plr.slashObj:setInactive()
        plr.slashObj.trailer:setInactive()
        plr.Trailer:setInactive()
    end
    
    return plr
end

function flipPlr(plr, flip)
    plr.flip = flip
    if flip == 1 then
        changeCapeOffsets(plr.capeSegments, capeBaseRightOffsets)
    else
        changeCapeOffsets(plr.capeSegments, capeBaseLeftOffsets)
    end
end

function leaveFloor(plr, floor, disableCoyoteJump)
    if plr.lastFloor == floor then
        plr.lastFloor = nil
        plr.RigidBody.acceleration.y = gravityAccel
        plr.grounded = false
        if not disableCoyoteJump then
            plr.canCoyoteJump = true
        end
        plr:startCoroutine(finishLeavingFloor, "finishLeavingFloor")
    end
end

function landOnFloor(plr, floor)
    refillDash()
    SoundManager.playSound("land")
    ParticleSystem.burst(plr.x, plr.y + plrFloorOffset, 10, 40, 300, {1,1,1,1}, 3, 0.95, 0.8, false, 0.5)
    plr.RigidBody.acceleration.y = 0
    plr.RigidBody.velocity.y = 0
    plr.y = floor.y - plrFloorOffset - floor.Collider.height / 2
    plr.grounded = true
    plr.lastFloor = floor
    plr.wallJumped = false
    leaveWall(plr, floor)
end

function touchWall(plr, wall)
    plr.lastWall = wall
    plr.coyoteWall = wall
    plr.touchingWall = true
    plr.canWallJump = true
    if not plr.grounded then
        Animation.changeAnimation(plr, 6)
    end
end

function leaveWall(plr, wall)
    if plr.lastWall == wall then
        plr.lastWall = nil
        plr.touchingWall = false
        plr.wallHoldOffTime = 0
        if plr.RigidBody.velocity.y < 0 then
            Animation.changeAnimation(plr, 3)
        else
            Animation.changeAnimation(plr, 5)
        end
        if not plr.grounded then
            plr.RigidBody.acceleration.y = gravityAccel
        end
        plr:startCoroutine(finishTouchingWall, "finishTouchingWall")
    end
end

function finishLeavingFloor()
    coroutine.yield(coyoteJumpTime)
    plr.canCoyoteJump = false
end

function finishTouchingWall()
    coroutine.yield(coyoteWallJumpTime)
    if plr.lastWall == nil then
        plr.coyoteWall = nil
        plr.canWallJump = false
    end
end

function finishWallJump()
    coroutine.yield(wallJumpTime)
    if plr.lastWall == nil then
        plr.wallJumped = false
    end
end

function pDash(speed, xDir, yDir, notrail)
    local vec = {x=0,y=0}
    if xDir ~= 0 or yDir ~= 0 then
        vec = clampVecToLength(xDir, yDir, dashSpeed)
    end
    plr.RigidBody.velocity.x = vec.x
    plr.RigidBody.velocity.y = vec.y
    plr.RigidBody.acceleration.y = 0
    plr.RigidBody.dragFactor.x = dashDragFactor.x
    plr.RigidBody.dragFactor.y = dashDragFactor.y
    if not notrail then
        plr.Trailer:trailOnInterval(0.02)
    end
end

function finishSlash()
    coroutine.yield(dashTime)
    plr.slashing = false
    if not plr.grounded and not plr.dashing then
        -- Only reset the gravity if we're not dashing
        plr.RigidBody.acceleration.y = gravityAccel
    end
    if not plr.dashing then
        -- If we're dashing, then we need our drag factor to not be 1
        -- If we're not dashing, we can reset our drag and velocity
        plr.RigidBody.velocity.x = 0
        plr.RigidBody.dragFactor.x = 1
        plr.RigidBody.dragFactor.y = 1
    end
    plr.invincible = false
    plr.alpha = 1
    plr.slashObj.trailer.trailing = false
    plr.slashObj:setInactive()
    if not plr.dashing then
        plr.Trailer.trailing = false
    end
end

function finishDash()
    coroutine.yield(dashTime)
    plr.dashing = false
    if plr.grounded then
        refillDash()
    elseif not plr.slashing then
        -- If we're slashing, we want to keep our gravity low so we can slash far.
        -- Otherwise, we can reset the gravity here.
        plr.RigidBody.acceleration.y = gravityAccel
    end
    if not plr.slashing then
        -- If we're slashing, then we need our drag factor to be not 1
        -- if we're not slashing, then we can reset our drag factor.
        plr.RigidBody.velocity.x = 0
        plr.RigidBody.dragFactor.x = 1
        plr.RigidBody.dragFactor.y = 1
    end
    if not plr.slashing then
        plr.Trailer.trailing = false
    end
end

function refillDash()
    plr.canDash = true
    plr.capeObj.color = capeBaseColor
    changeCapeColor(plr.capeSegments, capeBaseColor)
end

function depleteDash()
    plr.canDash = false
    plr.capeObj.color = capeDepletedColor
    changeCapeColor(plr.capeSegments, capeDepletedColor)
end

function getEnemySlashAngle(range, facingDir)
    local enemy
    if enableSlashPriority then
        if facingDir then
            enemy = getClosestEnemyInFacingDir(plr.x, plr.y, range or plr.attackRange, plr.gameState, facingDir, true)
            -- This is just debug code to check if our assist system works.
            -- Uncomment this to see how often the game properly prioritizes
            -- if enemy then
            --     local enemy2 = getClosestEnemyWithinRange(plr.x, plr.y, range or plr.attackRange, plr.gameState)
            --     if enemy ~= enemy2 then
            --         print("slash directional priority worked!")
            --     end
            -- end
        end
        -- If we couldn't find an enemy in our holding direction, then try again for all enemies that aren't launchers
        if not enemy then
            enemy = getClosestEnemyWithinRange(plr.x, plr.y, range or plr.attackRange, plr.gameState, true)
            -- Same as above comment
            -- if enemy then
            --     local enemy2 = getClosestEnemyWithinRange(plr.x, plr.y, range or plr.attackRange, plr.gameState)
            --     if enemy ~= enemy2 then
            --         print("slash prioritization of non-launchers worked!")
            --     end
            -- end
        end
        -- If we still couldn't find any enemies, then just check all enemies
        if not enemy then
            enemy = getClosestEnemyWithinRange(plr.x, plr.y, range or plr.attackRange, plr.gameState, false)
        end
    else
        enemy = getClosestEnemyWithinRange(plr.x, plr.y, range or plr.attackRange, plr.gameState)
    end
    local closestAngle = 0
    local closestAngleIndex = 2
    local slashDir = {x=0,y=0}
    if enemy then
        -- Get a cardinal angle between you and the enemy
        local angle = math.deg(math.atan((enemy.y - plr.y) / (enemy.x - plr.x)))
        if plr.x > enemy.x then
            angle = angle + 180
        end
        if not debugClampSlashDirs then
            closestAngle = angle
            slashDir.x = enemy.x - plr.x
            slashDir.y = enemy.y - plr.y
        else
            local angles = {-90,-45,0,45,90,135,180,225,270}
            local diff = 10000
            local currDiff = diff
            for k = 1,#angles do
                currDiff = math.abs(angle - angles[k])
                if currDiff < diff then
                    diff = currDiff
                    closestAngle = angles[k]
                    closestAngleIndex = k
                end
            end
        end
    end
    if debugClampSlashDirs then
        return {enemy, closestAngle, closestAngleIndex}
    else
        return {enemy, closestAngle, slashDir}
    end
end

function changeCapeColor(segments, newColor)
    for k = 1,#segments do
        segments[k].color = newColor
    end
end

function changeCapeOffsets(segments, newOffsets)
    for k = 1,#segments do
        segments[k].offset = newOffsets[k]
    end
end

function createCapeObj(plr)
    local capeObj = GameObjects.newGameObject(2, plr.x, plr.y, 0, true, GameObjects.DrawLayers.PLAYER)
    capeObj.color = capeBaseColor
    Animation.addAnimator(capeObj)
    Animation.addAnimation(capeObj, {0,1,2,3}, 0.2, 1, true) -- idle
    Animation.addAnimation(capeObj, {4,5,6,7,8,9}, 0.1, 2, true) -- run
    Animation.addAnimation(capeObj, {10,11}, 0.15, 3, true, 
        function(obj)
            Animation.changeAnimation(capeObj, 4) -- change to secondary jump
        end) -- jumpStart
    Animation.addAnimation(capeObj, {11,11}, 0.2, 4, true) -- jump continue
    Animation.addAnimation(capeObj, {12,12}, 0.2, 5, true) -- Fall
    Animation.addAnimation(capeObj, {13,13}, 0.2, 6, true) -- Wall slide

    function capeObj:update(dt)
        capeObj.x = plr.x
        capeObj.y = plr.y
        capeObj.flip = plr.flip
        if capeObj.Animator.state ~= plr.Animator.state then
            Animation.changeAnimation(capeObj, plr.Animator.state)
        end
    end
    return capeObj
end

function createFullCape(plr, offsets)
    local segments = {}
    segments[1] = createCapeSegment(plr, offsets[1])
    for k = 2,#offsets do
        segments[k] = createCapeSegment(segments[k-1], offsets[k])
    end
    return segments
end

function createCapeSegment(parent, offset)
    local capeSegment = GameObjects.newGameObject(-1, parent.x + offset.x, parent.y + offset.y, 0, true, GameObjects.DrawLayers.BEHINDPLAYER)
    capeSegment.offset = offset
    capeSegment.color = capeBaseColor
    capeSegment.kP = 30

    function capeSegment:draw()
        love.graphics.setColor(capeSegment.color)
        love.graphics.circle('fill', capeSegment.x, capeSegment.y, 2)
    end

    function capeSegment:update(dt)
        local dX = parent.x + capeSegment.offset.x - capeSegment.x
        local dY = parent.y + capeSegment.offset.y - capeSegment.y
        local md = capeSegment.kP * dt
        if md > 1 then -- prevent the cape from jumping too far from the player
            md = 1
        end
        capeSegment.x = capeSegment.x + dX * md
        capeSegment.y = capeSegment.y + dY * md
    end
    
    return capeSegment
end

function createSlashObj(plr)
    local slashObj = GameObjects.newGameObject(1, plr.x, plr.y, 17, false,GameObjects.DrawLayers.PARTICLES)
    Animation.addAnimator(slashObj)
    Animation.addAnimation(slashObj, {17,18,19,19,19}, 0.2, 1, true)
    slashObj.trailer = createDashTrailer(slashObj, 1, 20, 0.3, true, GameObjects.DrawLayers.PARTICLES)

    function slashObj:update(dt)
        slashObj.x = plr.x
        slashObj.y = plr.y
    end
    return slashObj
end

function plrDie(kill)
    if plr.invincible and not kill then
        return
    end
    plr.gameState.deathRespawn = true
    plr:setInactive()
    local deathRoutineObj = GameObjects.newGameObject(-1,0,0,0,true)
    deathRoutineObj:startCoroutine(deathRoutine, "deathRoutine")
    plr.gameState.totalNumDeaths = plr.gameState.totalNumDeaths + 1
end

function createSlashIndicator(plr)
    local slashIndicator = GameObjects.newGameObject(-1, 0, 0, 0, true, GameObjects.DrawLayers.PLAYER)
    slashIndicator.currentTime = 0
    slashIndicator.enemy = nil
    slashIndicator.angle = nil
    slashIndicator.maxGraceTime = slashGraceTime
    slashIndicator.graceTime = slashIndicator.maxGraceTime

    function slashIndicator:update(dt)
        slashIndicator.currentTime = slashIndicator.currentTime + dt
        local holdingDir = nil
        if leftInputHeld() then
            holdingDir = -1
        elseif rightInputHeld() then
            holdingDir = 1
        end
        local slashInfo = getEnemySlashAngle(plr.attackRange - 2, holdingDir) -- Cut the visual range a tiny bit to prevent 'barely outranged' scenarios
        slashIndicator.enemy = slashInfo[1]
        slashIndicator.angle = slashInfo[2]
        -- If we're in range of an enemy, cache that enemy on the player and start the gracetime clock
        if slashIndicator.enemy then
            plr.missedSlashInfo = slashInfo
            slashIndicator.graceTime = slashIndicator.maxGraceTime
        elseif plr.missedSlashInfo and plr.missedSlashInfo[1] then
            -- If we're no longer in an enemy's range, BUT we were recently in an enemy's range
            -- then tick down the graceTime clock till it hits 0 at which point, we un-cache the enemy.
            slashIndicator.graceTime = slashIndicator.graceTime - dt
            if slashIndicator.graceTime < 0 then
                plr.missedSlashInfo = nil
            end
        end
    end

    function slashIndicator:draw()
        local enemy = slashIndicator.enemy
        local angle = slashIndicator.angle
        if enemy then
            local lineLength = 12 + math.sin(slashIndicator.currentTime*5)
            local xOffset = lineLength * math.cos(math.rad(angle))
            local yOffset = lineLength * math.sin(math.rad(angle))
            -- Draw slash key lock indicators if necessary
            if enemy.slashDoor and enemy:isLocked() then
                if enemy.slashDoor:predictUnlockAttempt(enemy.keyIndex, angle) then
                    love.graphics.setColor(greenSlashColor)
                else
                    love.graphics.setColor(capeBaseColor)
                end
                love.graphics.line(enemy.x - xOffset * 0.8, enemy.y - yOffset * 0.8, enemy.x + xOffset, enemy.y + yOffset)
            else
                love.graphics.setColor(slashColor)
            end
            love.graphics.circle('line', enemy.x, enemy.y, 8 + math.sin(slashIndicator.currentTime*5))
        end
    end
    return slashIndicator
end

function playerOnCollision(plr, otherObj)
    if otherObj.Collider.layer == Collision.Layers.FLOOR then
        -- Within horizontal bounds
        if playerInFloorHorizontalBounds(plr, otherObj) and not plr.grounded then
            -- Floor is below us, land on the floor.
            if (otherObj.y - otherObj.Collider.height / 2 + floorClimbMargin) > plr.y
                and plr.RigidBody.velocity.y > 0 then
                landOnFloor(plr, otherObj)
            elseif (otherObj.y + otherObj.Collider.height / 2 - 1) < plr.y and plr.RigidBody.velocity.y < 0 
                and playerInBonkBounds(plr, otherObj) then
                -- Bonk head on ceiling
                plr.RigidBody.velocity.y = 0
                plr.RigidBody.acceleration.y = gravityAccel * fallMultiplier
            end
        end
        -- Within vertical bounds
        if playerInFloorVerticalBounds(plr, otherObj) then
            if plr.x > otherObj.x then
                plr.x = otherObj.x + otherObj.Collider.width / 2 + plrWallOffset
                touchWall(plr, otherObj)
            elseif plr.x < otherObj.x then
                plr.x = otherObj.x - otherObj.Collider.width / 2 - plrWallOffset
                touchWall(plr, otherObj)
            end
        elseif otherObj == plr.lastWall and plr.y > (otherObj.y + otherObj.Collider.height / 2) then
            -- We should just fall here
            leaveWall(plr, otherObj)
        end
    end
end

function playerInFloorHorizontalBounds(plr, otherObj)
    local plrWidth = plr.Collider.width / 2
    return ((plr.x + plrWidth) < (otherObj.x + otherObj.Collider.width / 2) and (plr.x + plrWidth) > (otherObj.x - otherObj.Collider.width / 2))
        or ((plr.x - plrWidth) > (otherObj.x - otherObj.Collider.width / 2) and (plr.x - plrWidth) < (otherObj.x + otherObj.Collider.width / 2))
end

function playerInBonkBounds(plr, otherObj)
    local plrWidth = plrBonkMargin
    return ((plr.x + plrWidth) < (otherObj.x + otherObj.Collider.width / 2) and (plr.x + plrWidth) > (otherObj.x - otherObj.Collider.width / 2))
        or ((plr.x - plrWidth) > (otherObj.x - otherObj.Collider.width / 2) and (plr.x - plrWidth) < (otherObj.x + otherObj.Collider.width / 2))
end

function playerInFloorVerticalBounds(plr, otherObj)
    local playerIsAboveBottom = plr.y < (otherObj.y + otherObj.Collider.height / 2)
    local playerIsBelowTop = plr.y - floorClimbMargin > (otherObj.y - otherObj.Collider.height / 2)
    return playerIsAboveBottom and playerIsBelowTop
end

function playerOnCollisionEnter(plr, otherObj)
    if otherObj.Collider.layer == Collision.Layers.TRIGGER then
        if otherObj.onPlayerEnter then
            otherObj.onPlayerEnter(plr)
        end
    end
end

function playerOnCollisionExit(plr, otherObj)
    if otherObj.Collider.layer == Collision.Layers.FLOOR then
        if plr.grounded then
            leaveFloor(plr, otherObj)
        end
        leaveWall(plr, otherObj)
    elseif otherObj.Collider.layer == Collision.Layers.TRIGGER then
        if otherObj.onPlayerExit then
            otherObj.onPlayerExit(plr)
        end
    end
end

function deathRoutine()
    Camera.shake(10)
    SoundManager.playSound("death1")
    local deathCircle = GameObjects.newGameObject(-1, plr.x, plr.y, 0, true, GameObjects.DrawLayers.TOPUI)
    deathCircle.radius = 12;
    function deathCircle:update(dt)
        deathCircle.radius = deathCircle.radius - 40*dt;
    end

    function deathCircle:draw()
        love.graphics.setColor(1,1,1,1);
        love.graphics.circle('fill', deathCircle.x, deathCircle.y, deathCircle.radius);
    end
    SoundManager.playSound("death2")
    deathCircle.pulseRoutine =
    function()
        local numPulses = 3;
        for k = 1,numPulses do
            deathCircle.radius = 12+k*5;
            coroutine.yield(0.1);
        end
        coroutine.yield(0.2);
        createCircularPop(deathCircle.x, deathCircle.y, {1,1,1}, 20, 100, 1, 0.2, 0.1, true)
        SoundManager.playSound("death3")
        Camera.shake(5)
        deathCircle:setInactive()
        coroutine.yield(0.5)
        levelTransitionCircleOut(plr.gameState)
    end

    local coroutineObj = GameObjects.newGameObject(-1,0,0,0,true)
    coroutineObj:startCoroutine(deathCircle.pulseRoutine, "pulseRoutine")
end

-- note: if we get input issues, just pull joystick support and use dpad buttons.
function leftInputHeld()
    return Input.getMappedButtonHeld("moveleft") or Input.getAxisValue("leftx") < -0.2
end

function rightInputHeld()
    return Input.getMappedButtonHeld("moveright") or Input.getAxisValue("leftx") > 0.2
end

function getAxisDashDirection()
    local x = Input.getAxisValue("leftx")
    local y = Input.getAxisValue("lefty")
    local dx = 0
    local dy = 0
    local angle = math.deg(math.atan2(y,x))
    if x == 0 and y == 0 then
        -- Neutral dash, return 0
        return 0,0
    end
    if angle >= -22.5 and angle <= 22.5 then -- right
        dx = 1
        dy = 0
    elseif angle < -22.5 and angle > -67.5 then -- up-right
        dx = 1
        dy = -1
    elseif angle <= -67.5 and angle >= -112.5 then -- up
        dy = -1
        dx = 0
    elseif angle < -112.5 and angle > -157.5 then -- up-left
        dy = -1
        dx = -1
    elseif (angle <= -157.5 and angle >= -180) or (angle >= 157.5 and angle <= 180) then -- left
        dx = -1
        dy = 0
    elseif angle < 157.5 and angle > 112.5 then -- down-left
        dx = -1
        dy = 1
    elseif angle <= 112.5 and angle >= 67.5 then -- down
        dx = 0
        dy = 1
    elseif angle < 67.5 and angle > 22.5 then -- down-right
        dx = 1
        dy = 1
    end
    return dx, dy
end