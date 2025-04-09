local Camera = {}
local cameraJiggleFalloff = 0.5
local cameraShakeFalloff = 0.5
local frameDependent = true -- Make jiggle framerate dependent
local cameraFollowKP = 2
local cameraZoomKP = 5
local maxShakeTic = referenceDT * 2
local maxJiggleTic = referenceDT * 3
function Camera.initialize()
    Camera.x = 0
    Camera.y = 0
    Camera.defaultTarget = nil
    Camera.followBias = {x=0,y=0}
    Camera.offset = {x=0,y=0}
    Camera.shakeContribution = {x=0,y=0}
    Camera.jiggleContribution = {x=0,y=0}
    Camera.jiggleVec = {x=0,y=0, sgn = 1}
    Camera.shakeMagnitude = 0
    Camera.shaking = false
    Camera.shakeTic = 0
    Camera.jiggling = false
    Camera.jiggleTic = 0
    Camera.target = nil
    Camera.constrainX = true
    Camera.constrainY = true
    Camera.followingTarget = false
    Camera.xBounds = {min=0,max=0}
    Camera.yBounds = {min=0,max=0}
    Camera.followKP = cameraFollowKP
    Camera.zoomKP = cameraZoomKP
    Camera.zoomLevel = 3
    Camera.zoomTarget = Camera.zoomLevel
    Camera.width = canvasWidth / Camera.zoomLevel
    Camera.height = canvasHeight / Camera.zoomLevel
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
            Camera.x = Camera.target.x
        end
        if not Camera.constrainY then
            Camera.y = Camera.target.y
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

function Camera.update(dt)
    if Camera.shaking then
        Camera.pShake(dt)
    end
    if Camera.jiggling then
        Camera.pJiggle(dt)
    end
    Camera.offset.x = Camera.jiggleContribution.x + Camera.shakeContribution.x
    Camera.offset.y = Camera.jiggleContribution.y + Camera.shakeContribution.y

    if Camera.followingTarget then
        Camera.pFollow(dt)
    end
    if Camera.zoomLevel ~= Camera.zoomTarget then
        Camera.pZoom(dt)
    end
end

function Camera.shake(magnitude)
    Camera.shakeMagnitude = Camera.shakeMagnitude + magnitude
    Camera.shaking = true
    Camera.shakeTic = 0
end

function Camera.jiggle(jiggleX, jiggleY)
    Camera.jiggleVec.x = jiggleX
    Camera.jiggleVec.y = jiggleY
    Camera.jiggling = true
    Camera.jiggleTic = 0
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
        Camera.x = Camera.x + ((Camera.target.x + Camera.followBias.x - Camera.width / 2) - Camera.x) * dt * Camera.followKP
    end
    if not Camera.constrainY then
        Camera.y = Camera.y + ((Camera.target.y + Camera.followBias.y - Camera.height / 2) - Camera.y) * dt * Camera.followKP
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
        Camera.shakeContribution.x = (1 - math.random()*2) * Camera.shakeMagnitude
        Camera.shakeContribution.y = (1 - math.random()*2) * Camera.shakeMagnitude
    
        Camera.shakeMagnitude = Camera.shakeMagnitude * (cameraShakeFalloff ^ (dt / referenceDT))
        if (Camera.shakeMagnitude < 0.1) then
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
        Camera.jiggleContribution.x = Camera.jiggleVec.x * Camera.jiggleVec.sgn
        Camera.jiggleContribution.y = Camera.jiggleVec.y * Camera.jiggleVec.sgn
        Camera.jiggleVec.sgn = - Camera.jiggleVec.sgn
        
        if frameDependent then
            Camera.jiggleVec.x = Camera.jiggleVec.x * cameraJiggleFalloff
            Camera.jiggleVec.y = Camera.jiggleVec.y * cameraJiggleFalloff
        else
            Camera.jiggleVec.x = Camera.jiggleVec.x * (cameraJiggleFalloff ^ (dt / referenceDT))
            Camera.jiggleVec.y = Camera.jiggleVec.y * (cameraJiggleFalloff ^ (dt / referenceDT))
        end
        if math.abs(Camera.jiggleVec.x) < 0.2 then
            Camera.jiggleVec.x = 0
            Camera.jiggleContribution.x = 0
        end
        if math.abs(Camera.jiggleVec.y) < 0.2 then
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
    love.graphics.translate(windowWidth / 2 - Camera.width / 2, windowHeight / 2 - Camera.height / 2)
    love.graphics.translate(-(Camera.x + Camera.offset.x), -(Camera.y + Camera.offset.y))
end

-- Call this after all your drawing code (within a texture)
function Camera.postDraw()
    love.graphics.pop()
end

function Camera.zoomDraw()
    love.graphics.translate(windowWidth / 2, windowHeight / 2)
    love.graphics.scale(Camera.zoomLevel, Camera.zoomLevel)
    love.graphics.translate(-windowWidth / 2, -windowHeight / 2)
end

return Camera