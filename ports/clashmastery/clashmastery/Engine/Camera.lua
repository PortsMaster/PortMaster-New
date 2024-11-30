local Camera = {}
local cameraJiggleFalloff = 1.85 -- remember to tune these if shake is lasting too long
local cameraShakeFalloff = 1.85 -- remember to tune these if shake is lasting too long
local baseCameraShakeMultiplier = 10
local baseCameraJiggleMultiplier = 10
local simplexYOffset = 10 -- need an offset value for noise in the Y direction to prevent camera shake from just being the same in both directions
local cameraFollowKP = 2
local maxShakeTic = referenceDT * 2
local maxJiggleTic = referenceDT * 2
local minDxDyFollow = 1 -- the minimum delta for a camera movement to trigger. prevents jitter when very close to the target
local maxCameraShakeMagnitude = 0.5 -- Camera shake is supposed to go from 0 to 1, but we can clamp it with this if higher values are unreasonable
-- clamping the above value to something lower than 1 allows us to still have decent shake at low values, but prevents crazy high values that cause
-- the screen to get unreadable
function Camera.initialize()
    Camera.x = renderResolution.width/2
    Camera.y = renderResolution.height/2
    Camera.totalTime = 0 -- used for simplex noise
    Camera.defaultTarget = nil
    Camera.followBias = {x=0,y=0}
    Camera.offset = {x=0,y=0}
    Camera.shakeContribution = {x=0,y=0}
    Camera.jiggleContribution = {x=0,y=0}
    Camera.jiggleVec = {x=0,y=0, sgnx = 1, sgny=1}
    Camera.shakeMagnitude = 0
    Camera.shaking = false
    Camera.shakeTic = 0
    Camera.jiggling = false
    Camera.jiggleTic = 0
    Camera.target = nil
    Camera.constrainX = true
    Camera.constrainY = true
    Camera.followingTarget = false
    Camera.xBounds = {min=-2^30,max=2^30}
    Camera.yBounds = {min=-2^30,max=2^30}
    Camera.followKP = cameraFollowKP
    Camera.width = renderResolution.width
    Camera.height = renderResolution.height
    Camera.minDxDyFollow = minDxDyFollow
    Camera.ignoreDT = false
end

function Camera.setTargetFollow(targetObj, constrainX, constrainY)
    Camera.target = targetObj
    Camera.constrainX = constrainX
    Camera.constrainY = constrainY
    Camera.followingTarget = true
    Camera.defaultTarget = targetObj
end

function Camera.changeTarget(targetObj)
    Camera.target = targetObj
end

function Camera.resetTarget()
    Camera.target = Camera.defaultTarget
end

function Camera.jumpToTarget()
    if Camera.target then
        if not Camera.constrainX then
            Camera.x = Camera.target.x - Camera.width/2
        end
        if not Camera.constrainY then
            Camera.y = Camera.target.y - Camera.height/2
        end
        Camera.constrainToBounds()
    end
end

function Camera.setBounds(minX, minY, maxX, maxY)
    Camera.xBounds.min = minX or Camera.xBounds.min
    Camera.yBounds.min = minY or Camera.yBounds.min
    Camera.xBounds.max = maxX or Camera.xBounds.max
    Camera.yBounds.max = maxY or Camera.yBounds.max
end

function Camera.setFollowBias(xBias, yBias)
    Camera.followBias.x = xBias or 0
    Camera.followBias.y = yBias or 0
end

function Camera.update(dt, trueDT)
    Camera.totalTime = Camera.totalTime + dt
    if Camera.shaking then
        if Camera.ignoreDT then
            Camera.pShake(trueDT)
        else
            Camera.pShake(dt)
        end
    end
    if Camera.jiggling then
        if Camera.ignoreDT then
            Camera.pJiggle(trueDT)
        else
            Camera.pJiggle(dt)
        end
    end
    Camera.offset.x = Camera.jiggleContribution.x + Camera.shakeContribution.x
    Camera.offset.y = Camera.jiggleContribution.y + Camera.shakeContribution.y

    if Camera.followingTarget then
        Camera.pFollow(dt)
    end
end

function Camera.shake(magnitude)
    if magnitude > 1 or magnitude < 0 then
        error("Camera shake magnitude must be between 0 and 1")
    end
    if gamePreferences.cameraShakePreferenceMultiplier ~= 0 then
        -- sqrt of pref value because it affects both x and y direction. if we didn't sqrt, we'd double-dip into this value
        magnitude = magnitude * math.sqrt(gamePreferences.cameraShakePreferenceMultiplier)
        Camera.shakeMagnitude = clamp(0, Camera.shakeMagnitude + magnitude, maxCameraShakeMagnitude)
        Camera.shaking = true
        Camera.shakeTic = 0
    end

end

function Camera.jiggle(jiggleX, jiggleY)
    if jiggleX > 1 or jiggleX < -1 then
        error("Camera jiggleX must be between -1 and 1")
    end
    if jiggleY > 1 or jiggleY < -1 then
        error("Camera jiggleY must be between -1 and 1")
    end
    if gamePreferences.cameraShakePreferenceMultiplier ~= 0 then
        -- sqrt of pref value because it affects both x and y direction. if we didn't sqrt, we'd double-dip into this value
        jiggleX = jiggleX * math.sqrt(gamePreferences.cameraShakePreferenceMultiplier)
        jiggleY = jiggleY * math.sqrt(gamePreferences.cameraShakePreferenceMultiplier)
        Camera.jiggleVec.x = math.abs(jiggleX)
        Camera.jiggleVec.y = math.abs(jiggleY)
        Camera.jiggleVec.sgnx = jiggleX > 0 and 1 or -1
        Camera.jiggleVec.sgny = jiggleY > 0 and 1 or -1
        Camera.jiggling = true
        Camera.jiggleTic = 0
    end
end

function Camera.constrainToBounds()
    if Camera.x > Camera.xBounds.max then
        Camera.x = Camera.xBounds.max
    elseif Camera.x < Camera.xBounds.min then
        Camera.x = Camera.xBounds.min
    end
    if Camera.y > Camera.yBounds.max then
        Camera.y = Camera.yBounds.max
    elseif Camera.y < Camera.yBounds.min then
        Camera.y = Camera.yBounds.min
    end
end

function Camera.pFollow(dt)
    -- Follow the target, ensuring they are centered on the screen
    if not Camera.constrainX then
        local dX = (((Camera.target.x + Camera.followBias.x) - Camera.width / 2) - Camera.x) * dt * Camera.followKP
        if math.abs(dX) > Camera.minDxDyFollow*dt then
            Camera.x = Camera.x + dX
        end
    end
    if not Camera.constrainY then
        local dY = (((Camera.target.y + Camera.followBias.y) - Camera.height / 2) - Camera.y) * dt * Camera.followKP
        if math.abs(dY) > Camera.minDxDyFollow*dt then
            Camera.y = Camera.y + dY
        end
    end

    Camera.constrainToBounds()
end

function Camera.pZoom(dt)
    if math.abs(Camera.zoomLevel - Camera.zoomTarget) > 0.02 then
        Camera.zoomLevel = Camera.zoomLevel + (Camera.zoomTarget - Camera.zoomLevel) * dt * Camera.zoomKP
    else
        Camera.zoomLevel = Camera.zoomTarget
    end
end

function Camera.pShake(dt)
    Camera.shakeTic = Camera.shakeTic - dt
    if Camera.shakeTic <= 0 then
        -- Shake is proportional to the square of the shake magnitude
        local vX, vY
        -- random
        vX = math.random()
        vY = math.random()
        -- noise
        -- vX = love.math.noise(Camera.totalTime*10)
        -- vY = love.math.noise(Camera.totalTime*10+ simplexYOffset)
        Camera.shakeContribution.x = (1 - vX * 2) * (Camera.shakeMagnitude ^ 2) * baseCameraShakeMultiplier
        Camera.shakeContribution.y = (1 - vY * 2) * (Camera.shakeMagnitude ^ 2) * baseCameraShakeMultiplier

        -- Shake falls of linearly
        Camera.shakeMagnitude = Camera.shakeMagnitude - cameraShakeFalloff * maxShakeTic

        if (Camera.shakeMagnitude < 0) then
            Camera.shakeMagnitude = 0
            Camera.shaking = false
            Camera.shakeContribution.x = 0
            Camera.shakeContribution.y = 0
        end
        Camera.shakeTic = maxShakeTic
    end
end

function Camera.pJiggle(dt)
    Camera.jiggleTic = Camera.jiggleTic - dt
    if Camera.jiggleTic <= 0 then
        -- Jiggle is also proportional to the square of the jiggle vec
        Camera.jiggleContribution.x = (Camera.jiggleVec.x^2) * Camera.jiggleVec.sgnx * baseCameraJiggleMultiplier
        Camera.jiggleContribution.y = (Camera.jiggleVec.y^2) * Camera.jiggleVec.sgny * baseCameraJiggleMultiplier
        Camera.jiggleVec.sgnx = - Camera.jiggleVec.sgnx
        Camera.jiggleVec.sgny = - Camera.jiggleVec.sgny
        
        -- Jiggle falls off linearly
        Camera.jiggleVec.x = Camera.jiggleVec.x - cameraJiggleFalloff * maxJiggleTic
        Camera.jiggleVec.y = Camera.jiggleVec.y - cameraJiggleFalloff * maxJiggleTic

        if Camera.jiggleVec.x < 0 then
            Camera.jiggleVec.x = 0
            Camera.jiggleContribution.x = 0
        end
        if Camera.jiggleVec.y < 0 then
            Camera.jiggleVec.y = 0
            Camera.jiggleContribution.y = 0
        end
        if (Camera.jiggleVec.x == 0 and Camera.jiggleVec.y == 0) then
            Camera.jiggling = false
        end
        Camera.jiggleTic = maxJiggleTic
    end
end

-- Call this at the start of your drawing code (within a texture)
function Camera.preDraw()
    love.graphics.push()
    love.graphics.translate(Camera.width / 2, Camera.height / 2)
    -- Flooring camera position mitigates camera jitter
    -- love.graphics.translate(-math.floor(Camera.x + Camera.offset.x), -math.floor(Camera.y + Camera.offset.y))
    love.graphics.translate(-(Camera.x + Camera.offset.x), -(Camera.y + Camera.offset.y))
end

-- Call this after all your drawing code (within a texture)
function Camera.postDraw()
    love.graphics.pop()
end

return Camera