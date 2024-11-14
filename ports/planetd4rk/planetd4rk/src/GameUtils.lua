local greenSlashColor = {38/255, 219/255, 110/255, 0.5}
local greenSlashColor2 = {38/255, 219/255, 110/255, 0.25}
local redLockedColor = {194/225, 23/225, 114/225, 1}
function createProjectile(x, y, targetX, targetY, speed, radius, shakeMag)
    local projectile = GameObjects.newGameObject(-1, x, y, 0, true, GameObjects.DrawLayers.PARTICLES)
    Physics.addRigidBody(projectile)
    Collision.addCircleCollider(projectile, radius - 3, Collision.Layers.TRIGGER, {Collision.Layers.FLOOR})

    projectile.onPlayerEnter =
        function(plr)
            plr.die()
            projectile:setInactive()
        end
    
    projectile.Collider.onCollision = 
        function(projectile, floor)
            if floor.Collider.layer == Collision.Layers.FLOOR then
                projectile:setInactive()
            end
        end

    local shootVec = clampVecToLength(targetX - x, targetY - y, speed)
    projectile.RigidBody.velocity.x = shootVec.x
    projectile.RigidBody.velocity.y = shootVec.y
    projectile.lifeTime = 5
    projectile.radius = radius
    projectile.baseRadius = radius

    function projectile:update(dt)
        projectile.lifeTime = projectile.lifeTime - dt
        if projectile.lifeTime < 0 then
            projectile.active = false
        end
        projectile.radius = projectile.baseRadius + math.sin((5 - projectile.lifeTime)*10)*2
    end

    function projectile:draw()
        love.graphics.setColor(1,0,1,1)
        love.graphics.circle('line', projectile.x, projectile.y, projectile.radius)
        love.graphics.setColor(0,0,0,1)
        love.graphics.circle('fill', projectile.x, projectile.y, projectile.radius - 1)
    end

    function projectile:setInactive()
        projectile.active = false
        createCircularPop(projectile.x, projectile.y, {1,1,1}, projectile.baseRadius, projectile.baseRadius + 50, 1, 0.3, 0.15, true)
        ParticleSystem.burst(projectile.x, projectile.y, 20, 400, 900, {1,1,1,1}, 5, 0.95, 0.8, false, 0.5)
        Camera.shake(shakeMag or 5)
        SoundManager.playSound("explosion", 0.5)
    end

    return projectile
end

function createEntryExitTrigger(x, y, width, height, onEntry, onExit)
    local trigger = GameObjects.newGameObject(-1, x, y, 0, true)
    Collision.addBoxCollider(trigger, width, height, Collision.Layers.TRIGGER, {})
    trigger.onPlayerEnter = onEntry
    trigger.onPlayerExit = onExit
end

function createCameraBiasTrigger(x, y, width, height, xBias, yBias)
    local biasFcn =
        function()
            Camera.setFollowBias(xBias, yBias)
        end
    return createEntryExitTrigger(x, y, width, height, biasFcn)
end

function createCameraZoomTrigger(x, y, width, height, zoomLevel)
    return createEntryExitTrigger(x, y, width, height, 
        function()
            Camera.zoomTarget = zoomLevel
        end)
end

function createCameraTargetChangerTrigger(x, y, width, height, target)
    return createEntryExitTrigger(x, y, width, height, 
        function()
            Camera.changeTarget(target)
        end,
        function()
            Camera.resetTarget()
        end)
end

-- Uses the start point as the anchor, and an object to follow in between
-- averages between object and start point positions
function createMidpointFollower(x, y, followObj1)
    local follower = GameObjects.newGameObject(-1, x, y, 0, true)
    follower.followObj1 = followObj1
    follower.midX = x
    follower.midY = y
    function follower:update(dt)
        follower.x = (follower.followObj1.x + follower.midX) / 2
        follower.y = (follower.followObj1.y + follower.midY) / 2
    end
    return follower
end

function createSlashKey(x, y, gameState, slashDoor, keyIndex, keyAngle)
    local slashKey = createBasicEnemy(x, y, gameState)
    Animation.addAnimation(slashKey, {8,8}, 0.2, 2, true)
    Animation.addAnimation(slashKey, {9,9}, 0.2, 3, true)
    Animation.changeAnimation(slashKey, 2)
    slashKey.maxHP = 1000
    slashKey.slashCooldown = 0.1 -- allow rapid slashing of keys
    slashKey.currentHP = 1000
    slashKey.keyIndex = keyIndex
    slashKey.slashDoor = slashDoor
    slashKey.keyAngle = keyAngle
    slashKey.slashFX = nil
    slashDoor:addKey(slashKey)

    function slashKey:takeDamage(otherObj, angle)
        slashKey.slashDoor:unlockAttempt(slashKey.keyIndex, angle)
        slashKey.slashFX = createScalingRectangle("horizontal", 0, 20, {1,1,1,1}, 0.2, GameObjects.DrawLayers.PARTICLES, math.rad(angle), {x=slashKey.x, y=slashKey.y})
    end

    function slashKey:unlock()
        Animation.changeAnimation(slashKey, 3)
    end

    function slashKey:isLocked()
        return slashKey.slashDoor.keys[slashKey.keyIndex].locked
    end

    return slashKey
end

function createSlashDoor(x, y, width, height, totalNumKeys)
    local slashDoor = GameObjects.newGameObject(-1, x, y, 0, true, GameObjects.DrawLayers.PARTICLES)
    Collision.addBoxCollider(slashDoor, width, height, Collision.Layers.FLOOR, {})
    slashDoor.keys = {}
    slashDoor.numKeys = 0
    slashDoor.locked = true
    slashDoor.opening = false
    slashDoor.totalNumKeys = totalNumKeys
    slashDoor.angleMargin = 45

    if width >= height then
        slashDoor.keyDrawDir = {x=1,y=0}
        slashDoor.lockSeparation = width / totalNumKeys
    else
        slashDoor.keyDrawDir = {x=0,y=1}
        slashDoor.lockSeparation = height / totalNumKeys
    end
    slashDoor.lockRadius = 7

    function slashDoor:update(dt)
        slashDoor.locked = false
        for k = 1,slashDoor.numKeys do
            if slashDoor.keys[k].locked then
                slashDoor.locked = true
            end
        end
        if not slashDoor.locked and not slashDoor.opening then
            slashDoor.opening = true
            print("door is open!")
            slashDoor:open()
        end
    end

    function slashDoor:draw()
        love.graphics.setColor(38/255,219/255,1)
        love.graphics.rectangle('line', slashDoor.x-width/2,slashDoor.y-height/2,width,height)
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', slashDoor.x-width/2+1,slashDoor.y-height/2+1,width-2,height-2)
        for k = 1,slashDoor.numKeys do
            love.graphics.setColor(redLockedColor[1],redLockedColor[2],redLockedColor[3], 0.25)
            local style = 'line'
            if not slashDoor.keys[k].locked then
                love.graphics.setColor(greenSlashColor)
                style = 'fill'
            end
            local cX = slashDoor.x - ((slashDoor.numKeys - 1) / 2) * slashDoor.lockSeparation * slashDoor.keyDrawDir.x + (k-1)*slashDoor.lockSeparation * slashDoor.keyDrawDir.x
            local cY = slashDoor.y - ((slashDoor.numKeys - 1) / 2) * slashDoor.lockSeparation * slashDoor.keyDrawDir.y + (k-1)*slashDoor.lockSeparation * slashDoor.keyDrawDir.y
            love.graphics.circle(style,
                cX,
                cY,
                slashDoor.lockRadius)
            love.graphics.setColor(greenSlashColor)
            love.graphics.arc('fill', cX, cY, slashDoor.lockRadius+1, math.rad(slashDoor.keys[k].key.keyAngle-slashDoor.angleMargin), math.rad(slashDoor.keys[k].key.keyAngle+slashDoor.angleMargin))
            love.graphics.arc('fill', cX, cY, slashDoor.lockRadius+1, math.rad(slashDoor.keys[k].key.keyAngle+180-slashDoor.angleMargin), math.rad(slashDoor.keys[k].key.keyAngle+180+slashDoor.angleMargin))
            -- Also draw it for keys
            love.graphics.setColor(greenSlashColor2)
            love.graphics.arc('fill', slashDoor.keys[k].key.x, slashDoor.keys[k].key.y, slashDoor.lockRadius+6, math.rad(slashDoor.keys[k].key.keyAngle-slashDoor.angleMargin), math.rad(slashDoor.keys[k].key.keyAngle+slashDoor.angleMargin))
            love.graphics.arc('fill', slashDoor.keys[k].key.x, slashDoor.keys[k].key.y, slashDoor.lockRadius+6, math.rad(slashDoor.keys[k].key.keyAngle+180-slashDoor.angleMargin), math.rad(slashDoor.keys[k].key.keyAngle+180+slashDoor.angleMargin))
            if slashDoor.keys[k].lastAngle then
                if slashDoor.keys[k].locked then
                    love.graphics.setColor(redLockedColor)
                else
                    love.graphics.setColor(greenSlashColor2)
                end
                local angle = slashDoor.keys[k].lastAngle
                local xOffset = (slashDoor.lockRadius+2) * math.cos(math.rad(angle))
                local yOffset = (slashDoor.lockRadius+2) * math.sin(math.rad(angle))
                love.graphics.line(cX - xOffset, cY - yOffset, cX + xOffset, cY + yOffset)
                local keyX = slashDoor.keys[k].key.x
                local keyY = slashDoor.keys[k].key.y
                love.graphics.line(keyX - 60*math.cos(math.rad(angle)), keyY - 60*math.sin(math.rad(angle)),
                    keyX + 60*math.cos(math.rad(angle)), keyY + 60*math.sin(math.rad(angle)))
            end
        end
    end
    
    function slashDoor:predictUnlockAttempt(keyIndex, angle)
        if slashDoor.keys[keyIndex].locked then
            local targetAngle = slashDoor.keys[keyIndex].key.keyAngle
            local wrappedTargetAngle = targetAngle + 180
            if wrappedTargetAngle > 360 then
                wrappedTargetAngle = wrappedTargetAngle - 360
            end
            local wrappedNegativeTargetAngle = targetAngle - 180
            if math.abs(angle - targetAngle) < slashDoor.angleMargin
                or math.abs(angle - wrappedTargetAngle) < slashDoor.angleMargin
                or math.abs(angle - wrappedNegativeTargetAngle) < slashDoor.angleMargin then
                return true
            else
                return false
            end
        end
    end

    function slashDoor:unlockAttempt(keyIndex, angle)
        if slashDoor.keys[keyIndex].locked then
            slashDoor.keys[keyIndex].lastAngle = angle
            if slashDoor:predictUnlockAttempt(keyIndex, angle) then
                slashDoor.keys[keyIndex].locked = false
                slashDoor.keys[keyIndex].key:unlock()
                SoundManager.playSound("unlock")
            else
                SoundManager.playSound("unlockFailed")
                print('unlock failed')
            end
        end
    end

    function slashDoor:open()
        slashDoor:startCoroutine(slashDoor.openRoutine, "openRoutine")
    end

    function slashDoor:addKey(key)
        slashDoor.numKeys = slashDoor.numKeys + 1
        slashDoor.keys[key.keyIndex] = {key=key,locked=true,lastAngle=nil}
    end

    slashDoor.openRoutine = 
        function()
            SoundManager.playSound("unlockDoorOut")
            createCircularPop(slashDoor.x, slashDoor.y, {1,1,1}, 100, 10, 0.5, 1, 0.25, true)
            coroutine.yield(0.5)
            createCircularPop(slashDoor.x, slashDoor.y, {1,1,1}, 10, 80, 1, 0.3, 0.1, true)
            SoundManager.playSound("unlockDoorIn")
            ParticleSystem.burst(slashDoor.x, slashDoor.y, 20, 400, 900, {1,1,1,1}, 5, 0.95, 0.85, false, 0.5)
            SoundManager.playSound("explosion")
            Camera.shake(5)
            slashDoor:setInactive()
            if slashDoor.dependent then
                slashDoor.dependent:setInactive()
            end
        end

    return slashDoor
end

function updateSpeedrunClock(gameState, dt)
    gameState.speedrunClock.milliseconds = math.floor(gameState.speedrunClock.milliseconds + dt * 1000)
    if gameState.speedrunClock.milliseconds >= 999 then
        gameState.speedrunClock.seconds = gameState.speedrunClock.seconds + 1
        gameState.speedrunClock.milliseconds = 0
    end
    if gameState.speedrunClock.seconds >= 60 then
        gameState.speedrunClock.minutes = gameState.speedrunClock.minutes + 1
        gameState.speedrunClock.seconds = 0
    end
end

function drawSpeedrunClock(gameState)
    local cachedFont = love.graphics.getFont()
    love.graphics.setFont(largePicoFont)
    local referenceX = canvasWidth
    local referenceY = canvasHeight
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.rectangle('fill', referenceX-112, referenceY-22, 110, 20)
    love.graphics.setColor(1,1,1,1)
    local minutesPadding = ""
    local secondsPadding = ""
    local millisecondsPadding = ""
    if (gameState.speedrunClock.minutes < 10) then
        minutesPadding = "0"
    end
    if gameState.speedrunClock.seconds < 10 then
        secondsPadding = "0"
    end
    if gameState.speedrunClock.milliseconds < 10 then
        millisecondsPadding = "00"
    elseif gameState.speedrunClock.milliseconds < 100 then
        millisecondsPadding = "0"
    end
    love.graphics.print(
        minutesPadding..
        gameState.speedrunClock.minutes..":"..
        secondsPadding..
        gameState.speedrunClock.seconds..":"..
        millisecondsPadding..
        gameState.speedrunClock.milliseconds,
        referenceX-110,referenceY-20)
    love.graphics.setFont(cachedFont)
end

function createStarryBackground()
    local xOffset = Camera.width / 2
    local yOffset = Camera.height / 2 + randomBetween(-40, 40)
    local xStart = Camera.x + xOffset
    local yStart = Camera.y + yOffset
    local starryBackground = GameObjects.newGameObject(5, xStart, yStart, 0, true, GameObjects.DrawLayers.BACKGROUND)

    function starryBackground:update(dt)
        -- Always move with the camera
        starryBackground.y = math.floor(Camera.y + yOffset)
        starryBackground.x = math.floor(Camera.x + xOffset)
    end

    return starryBackground
end

function createWorldSpaceText(x, y, text, color, forceCenter, bigFont)
    if forceCenter then
        x = 160 - love.graphics.getFont():getWidth(text)/2
    end
    local textObj = GameObjects.newGameObject(-1, x, y, 0, true, GameObjects.DrawLayers.PLAYER)
    textObj.text = text
    textObj.fade = false
    textObj.fadeIn = false
    color = color or {1,1,1}
    function textObj:draw()
        local cachedFont
        if bigFont then
            cachedFont = love.graphics.getFont()
            love.graphics.setFont(largePicoFont)
        end
        love.graphics.setColor(color[1],color[2],color[3],textObj.alpha)
        love.graphics.print(textObj.text, x, y)
        if bigFont then
            love.graphics.setFont(cachedFont)
        end
    end

    function textObj:update(dt)
        if textObj.fade then
            textObj.alpha = textObj.alpha - dt * 5
            if textObj.alpha <= 0 then
                textObj.alpha = 0
                textObj.fade = false
                textObj:setInactive()
            end
        end
        if textObj.fadeIn then
            textObj.alpha = textObj.alpha + dt * 5
            if textObj.alpha >= 1 then
                textObj.alpha = 1
                textObj.fadeIn = false
            end
        end
    end
    return textObj
end