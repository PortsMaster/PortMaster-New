function createDashTrailer(parent, textureIndex, trailsInPool, lifeTime, fadeAlpha, drawLayer)
    local trailer = GameObjects.newGameObject(1, 0, 0, 0, true)

    trailer.trailObjs = {}
    trailer.numTrailsInPool = trailsInPool
    trailer.trailIndex = 1
    trailer.maxLifeTime = lifeTime
    trailer.parent = parent
    trailer.trailInterval = -1
    trailer.maxTrailInterval = -1
    trailer.trailing = false
    for k = 1,trailsInPool do
        trailer.trailObjs[k] = createFadingTrail(textureIndex, lifeTime, fadeAlpha, drawLayer)
    end

    function trailer:update(dt)
        if trailer.trailing then
            trailer.trailInterval = trailer.trailInterval - dt
            if trailer.trailInterval < 0 then
                local trailObj = trailer:getFromPool()
                trailObj.x = trailer.parent.x
                trailObj.y = trailer.parent.y
                trailObj.maxLifeTime = trailer.maxLifeTime
                trailObj.spr = trailer.parent.spr
                trailObj.color = trailer.parent.color
                trailObj.flip = trailer.parent.flip
                trailObj.rotation = trailer.parent.rotation
                trailObj:setActive()
                trailer.trailInterval = trailer.maxTrailInterval
            end
        end
    end

    function trailer:draw()
        -- no op
    end

    function trailer:trailOnInterval(trailInterval)
        trailer.maxTrailInterval = trailInterval
        trailer.trailInterval = trailInterval
        trailer.trailing = true
    end
    -- Clamp falloff means make the maxLifeTime only at most the max lifetime of the existing trails
    function trailer:trailFromTo(from, to, numTrails, clampFalloff)
        for k = 1,numTrails do
            local trailObj = trailer:getFromPool()
            trailObj.x = (to.x - from.x) * (k/numTrails) + from.x
            trailObj.y = (to.y - from.y) * (k/numTrails) + from.y
            if not clampFalloff then
                trailObj.maxLifeTime = trailer.maxLifeTime * (1 + k/numTrails)
            end
            trailObj.spr = trailer.parent.spr
            trailObj.color = trailer.parent.color
            trailObj.flip = trailer.parent.flip
            trailObj:setActive()
            trailObj.rotation = trailer.parent.rotation
        end
    end

    function trailer:getFromPool()
        local obj = trailer.trailObjs[trailer.trailIndex]
        trailer.trailIndex = trailer.trailIndex + 1
        if trailer.trailIndex > trailer.numTrailsInPool then
            trailer.trailIndex = 1
        end
        return obj
    end

    return trailer
end

function createFadingTrail(textureIndex, lifeTime, fadeAlpha, drawLayer)
    local trailObj = GameObjects.newGameObject(textureIndex, 0, 0, 0, false, drawLayer)
    trailObj.maxLifeTime = lifeTime
    trailObj.currentLifeTime = lifeTime
    trailObj.fadeAlpha = fadeAlpha

    function trailObj:update(dt)
        trailObj.currentLifeTime = trailObj.currentLifeTime - dt
        if trailObj.fadeAlpha then
            trailObj.alpha = trailObj.currentLifeTime / trailObj.maxLifeTime
        end
        if (trailObj.currentLifeTime < 0 ) then
            trailObj.active = false
        end
    end
    
    function trailObj:setActive()
        trailObj.currentLifeTime = trailObj.maxLifeTime
        trailObj.alpha = 1
        trailObj.active = true
    end

    return trailObj
end

function createFadingRectangle(x, y, width, height, color, lifeTime, rotation, active)
    local fadingRect = GameObjects.newGameObject(1, 0, 0, 0, active or false, GameObjects.DrawLayers.PROJECTILES)
    fadingRect.maxLifeTime = lifeTime
    fadingRect.lifeTime = lifeTime
    fadingRect.x = x
    fadingRect.y = y
    fadingRect.width = width
    fadingRect.height = height

    function fadingRect:update(dt)
        fadingRect.lifeTime = fadingRect.lifeTime - dt
        fadingRect.alpha = fadingRect.lifeTime / fadingRect.maxLifeTime
        if fadingRect.lifeTime < 0 then
            fadingRect.active = false
        end
    end

    function fadingRect:draw()
        if rotation then
            love.graphics.push()
            love.graphics.translate(fadingRect.x, fadingRect.y)
            love.graphics.rotate(rotation)
            love.graphics.setColor(color[1],color[2],color[3],fadingRect.alpha)
            love.graphics.rectangle('fill', -fadingRect.width/2, -fadingRect.height/2, fadingRect.width, fadingRect.height)
            love.graphics.pop()
        else
            love.graphics.setColor(color[1],color[2],color[3],fadingRect.alpha)
            love.graphics.rectangle('fill', fadingRect.x, fadingRect.y, fadingRect.width, fadingRect.height)
        end
    end
    
    function fadingRect:setActive()
        fadingRect.lifeTime = fadingRect.maxLifeTime
        fadingRect.alpha = 1
        fadingRect.active = true
    end

    return fadingRect
end

function createCircularPop(x, y, color, startRadius, endRadius, startAlpha, endAlpha, lifeTime, active)
    local circularPop = GameObjects.newGameObject(1,x,y,0,active,GameObjects.DrawLayers.PROJECTILES)

    circularPop.color = color

    circularPop.maxLifeTime = lifeTime
    circularPop.lifeTime = lifeTime
    circularPop.lifetimeFraction = 1

    circularPop.alpha = startAlpha
    circularPop.startAlpha = startAlpha
    circularPop.endAlpha = endAlpha

    circularPop.radius = startRadius
    circularPop.startRadius = startRadius
    circularPop.endRadius = endRadius

    function circularPop:update(dt)
        circularPop.lifeTime = circularPop.lifeTime - dt
        circularPop.lifetimeFraction = 1 - circularPop.lifeTime / circularPop.maxLifeTime

        circularPop.alpha = interpolateBetween(circularPop.startAlpha, circularPop.endAlpha, circularPop.lifetimeFraction)
        circularPop.radius = interpolateBetween(circularPop.startRadius, circularPop.endRadius, circularPop.lifetimeFraction)
        if circularPop.lifeTime <= 0 then
            circularPop.active = false
        end
    
    end

    function circularPop:draw()
        love.graphics.setColor(circularPop.color[1],circularPop.color[2],circularPop.color[3],circularPop.alpha)
        love.graphics.circle('fill', circularPop.x, circularPop.y, circularPop.radius)
    end

    function circularPop:setActive()
        circularPop.lifeTime = circularPop.maxLifeTime
        circularPop.radius = circularPop.startRadius
        circularPop.alpha = circularPop.startAlpha
        circularPop.active = true
    end
    
    return circularPop
end

function createScreenFlash(color, lifeTime, fadeAlpha, drawLayer, active, tX)
    active = active or false
    local screenFlash = GameObjects.newGameObject(1, 0, 0, 0, active, drawLayer or GameObjects.DrawLayers.UI)
    screenFlash.maxLifeTime = lifeTime
    screenFlash.lifeTime = lifeTime
    screenFlash.color = color
    screenFlash.startAlpha = color[4]
    local tX = tX or -200

    function screenFlash:update(dt)
        screenFlash.lifeTime = screenFlash.lifeTime - dt
        if fadeAlpha then
            screenFlash.color[4] = screenFlash.startAlpha * screenFlash.lifeTime / screenFlash.maxLifeTime
        end
        if screenFlash.lifeTime <= 0 then
            screenFlash.setInactive()
        end
    end

    function screenFlash:draw()
        love.graphics.setColor(screenFlash.color[1],screenFlash.color[2],screenFlash.color[3],screenFlash.color[4])
        love.graphics.rectangle('fill', tX, -4, canvasHeight * 2, canvasWidth * 2)
    end

    function screenFlash:setActive()
        screenFlash.lifeTime = screenFlash.maxLifeTime
        screenFlash.color[4] = screenFlash.startAlpha
        screenFlash.active = true
    end

    return screenFlash
end

function createScalingRectangle(direction, xOrY, startSize, color, lifeTime, drawLayer, rotation, xy)
    local rect = GameObjects.newGameObject(1, 0, 0, 0, true, drawLayer or GameObjects.DrawLayers.PROJECTILES)
    rect.color = color
    rect.rotation = rotation or 0
    local horizontal = false
    if direction == "horizontal" then
        horizontal = true
        rect.y = xOrY
        rect.x = 32
        rect.width = 300
        rect.height = startSize
    else
        dir = false
        rect.x = xOrY
        rect.y = 32
        rect.width = startSize
        rect.height = 300
    end
    rect.maxLifeTime = lifeTime
    rect.lifeTime = lifeTime

    function rect:update(dt)
        rect.lifeTime = rect.lifeTime - dt
        if horizontal then
            rect.height = startSize * rect.lifeTime / rect.maxLifeTime
        else
            rect.width = startSize * rect.lifeTime / rect.maxLifeTime
        end
        if rect.lifeTime <= 0 then
            rect.active = false
        end
    end

    function rect:draw()
        if rect.rotation == 0 then
            love.graphics.setColor(rect.color[1],rect.color[2],rect.color[3],1)
            love.graphics.rectangle('fill', rect.x - rect.width / 2, rect.y - rect.height / 2, rect.width, rect.height)
        else
            love.graphics.push()
            love.graphics.translate(xy.x, xy.y)
            love.graphics.rotate(rect.rotation)
            love.graphics.setColor(rect.color[1],rect.color[2],rect.color[3],1)
            love.graphics.rectangle('fill', -rect.width/2, -rect.height/2, rect.width, rect.height)
            love.graphics.pop()
        end
    end

    return rect
end

function worldSpaceText(text, x, y, color, drawLayer)
    local textObj = GameObjects.newGameObject(0,0,0,0,true,drawLayer)

    function textObj:draw()
        love.graphics.setColor(color[1],color[2],color[3],color[4])
        love.graphics.print(text, x - 4 * #text/2, y)
    end

    return textObj
end

function createFallingLine(x, y, width, height, velocity, lifeTime, centerX, centerY, rotation)
    local fallingLine = GameObjects.newGameObject(-1,x,y,0,true,GameObjects.DrawLayers.PLAYER)
    fallingLine.lifeTime = lifeTime
    function fallingLine:update(dt)
        fallingLine.y = fallingLine.y + velocity * dt
        fallingLine.lifeTime = fallingLine.lifeTime - dt
        if fallingLine.lifeTime < 0 then
            fallingLine:setInactive()
        end
    end

    function fallingLine:draw()
        love.graphics.push()
        love.graphics.translate(centerX, centerY)
        love.graphics.rotate(rotation)
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', fallingLine.x, fallingLine.y, width, height)
        love.graphics.pop()
    end

    return fallingLine
end

function createShrinkingTriangleSpike(frontX, frontY, tipX, tipY, startWidth, color, lifeTime)
    local shrinkingTriangle = GameObjects.newGameObject(-1, frontX, frontY, 0, true, GameObjects.DrawLayers.PLAYER)
    shrinkingTriangle.maxLifeTime = lifeTime
    shrinkingTriangle.lifeTime = lifeTime
    shrinkingTriangle.startWidth = startWidth
    shrinkingTriangle.width = startWidth
    shrinkingTriangle.startLength = math.sqrt((frontX - tipX) ^ 2 + (frontY - tipY) ^ 2)
    shrinkingTriangle.length = shrinkingTriangle.startLength
    shrinkingTriangle.color = color
    shrinkingTriangle.vertices = {0,0,0,0,0,0}
    function shrinkingTriangle:update(dt)
        shrinkingTriangle.lifeTime = shrinkingTriangle.lifeTime - dt
        if shrinkingTriangle.lifeTime <= 0 then
            shrinkingTriangle:setInactive()
        end
        shrinkingTriangle.width = shrinkingTriangle.startWidth * shrinkingTriangle.lifeTime / shrinkingTriangle.maxLifeTime
        shrinkingTriangle.length = shrinkingTriangle.startLength * shrinkingTriangle.lifeTime / shrinkingTriangle.maxLifeTime
        shrinkingTriangle:computeVertices()
    end

    function shrinkingTriangle:draw()
        love.graphics.setColor(shrinkingTriangle.color)
        love.graphics.polygon('fill', shrinkingTriangle.vertices)
    end
    
    function shrinkingTriangle:computeVertices()
        -- Tip computation
        shrinkingTriangle.vertices[1] = frontX - (frontX - tipX) * shrinkingTriangle.length / shrinkingTriangle.startLength
        shrinkingTriangle.vertices[2] = frontY - (frontY - tipY) * shrinkingTriangle.length / shrinkingTriangle.startLength

        -- Front vertices
        local dX = math.abs(frontX - tipX)
        local dY = math.abs(frontY - tipY)
        if dX == 0 then
            shrinkingTriangle.vertices[3] = frontX - shrinkingTriangle.width / 2
            shrinkingTriangle.vertices[4] = frontY
            shrinkingTriangle.vertices[5] = frontX + shrinkingTriangle.width / 2
            shrinkingTriangle.vertices[6] = frontY
        elseif dY == 0 then
            shrinkingTriangle.vertices[3] = frontX
            shrinkingTriangle.vertices[4] = frontY + shrinkingTriangle.width / 2
            shrinkingTriangle.vertices[5] = frontX
            shrinkingTriangle.vertices[6] = frontY - shrinkingTriangle.width / 2
        else
            local slope = dX / (dX + dY)
            local sgn = 1
            -- Honestly idk why this works but it does
            if (frontX > tipX and frontY > tipY) or (frontX < tipX and frontY < tipY) then
                sgn = -1
            end
            shrinkingTriangle.vertices[3] = frontX + shrinkingTriangle.width * (1 - slope) / 2 * sgn
            shrinkingTriangle.vertices[4] = frontY + shrinkingTriangle.width * slope / 2
            shrinkingTriangle.vertices[5] = frontX - shrinkingTriangle.width * (1 - slope) / 2 * sgn
            shrinkingTriangle.vertices[6] = frontY - shrinkingTriangle.width * slope / 2
        end
    end
    return shrinkingTriangle
end

function levelTransitionCircleOut(gameState)
    local circleOut = GameObjects.newGameObject(-1,canvasWidth/2, canvasHeight/2, 0, true, GameObjects.DrawLayers.POSTCAMERA)
    circleOut.radius = canvasWidth / 10;

    function circleOut:update(dt)
        circleOut.radius = circleOut.radius + dt * canvasWidth * 2.5
        if circleOut.radius > canvasWidth * 1.5 then
            gameState.loadLevel = true
        end
    end

    function circleOut:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.circle('fill', circleOut.x, circleOut.y, circleOut.radius)
    end

    return circleOut
end

function levelTransitionCircleIn(gameState)
    local circleOut = GameObjects.newGameObject(-1,canvasWidth/2, canvasHeight/2, 0, true, GameObjects.DrawLayers.POSTCAMERA)
    circleOut.radius = canvasWidth + 10;

    function circleOut:update(dt)
        circleOut.radius = circleOut.radius - dt * (canvasWidth * 2)
        if circleOut.radius < 1 then
            circleOut:setInactive()
        end
    end

    function circleOut:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.circle('fill', circleOut.x, circleOut.y, circleOut.radius)
    end

    return circleOut
end

function levelTransitionRectangle(gameState, rectDirection, isOut)
    local rectTransition = GameObjects.newGameObject(-1, 0, 0, 0, true, GameObjects.DrawLayers.POSTCAMERA)
    rectTransition.width = 0
    rectTransition.height = 0
    rectTransition.widthGrow = 0
    rectTransition.heightGrow = 0
    if rectDirection.x ~= 0 then
        local sgn = rectDirection.x > 0 and 1 or -1
        rectTransition.x = rectDirection.x > 0 and 0 or canvasWidth
        rectTransition.width = 0
        rectTransition.height = canvasHeight
        rectTransition.widthGrow = canvasWidth * 4 * sgn
    elseif rectDirection.y ~= 0 then
        local sgn = rectDirection.y > 0 and 1 or -1
        rectTransition.y = rectDirection.y > 0 and 0 or canvasHeight
        rectTransition.width = canvasWidth
        rectTransition.height = 0
        rectTransition.heightGrow = canvasHeight * 4 * sgn
    end
    if isOut then
        rectTransition.width = (canvasWidth + 10) * (rectTransition.widthGrow < 0 and -1 or 1)
        rectTransition.height = (canvasHeight + 10) * (rectTransition.heightGrow < 0 and -1 or 1)
        rectTransition.widthGrow = rectTransition.widthGrow * -1
        rectTransition.heightGrow = rectTransition.heightGrow * -1
    end

    function rectTransition:update(dt)
        rectTransition.width = rectTransition.width + rectTransition.widthGrow * dt
        rectTransition.height = rectTransition.height + rectTransition.heightGrow * dt
        if rectTransition.widthGrow ~= 0 and math.abs(rectTransition.width) > canvasWidth * 1.25 and not isOut then
            gameState.goToNextLevel()
        end
        if rectTransition.heightGrow ~= 0 and math.abs(rectTransition.height) > canvasHeight * 1.25 and not isOut then
            gameState.goToNextLevel()
        end
        if isOut then
            if rectTransition.heightGrow > 0 and rectTransition.height > 0 then
                rectTransition:setInactive()
            elseif rectTransition.heightGrow < 0 and rectTransition.height < 0 then
                rectTransition:setInactive()
            end
            if rectTransition.widthGrow > 0 and rectTransition.width > 0 then
                rectTransition:setInactive()
            elseif rectTransition.widthGrow < 0 and rectTransition.width < 0 then
                rectTransition:setInactive()
            end
        end
    end

    function rectTransition:draw()
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', rectTransition.x, rectTransition.y, rectTransition.width, rectTransition.height)
    end
end