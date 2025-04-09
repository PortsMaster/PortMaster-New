function createDashTrailer(parent, textureIndex, trailsInPool, lifeTime, fadeAlpha, drawLayer)
    drawLayer = drawLayer or parent.drawLayer
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
                trailObj.scaleX = trailer.parent.scaleX
                trailObj.scaleY = trailer.parent.scaleY
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

    function trailer:trailFromTo(fromx, fromy,tox, toy, numTrails)
        numTrails = numTrails or math.floor(trailer.numTrailsInPool * 0.75)
        for k = 1,numTrails do
            local trailObj = trailer:getFromPool()
            trailObj.x = (tox - fromx) * (k/numTrails) + fromx
            trailObj.y = (toy - fromy) * (k/numTrails) + fromy
            trailObj.maxLifeTime = trailer.maxLifeTime * (1 + k/numTrails)
            trailObj.spr = trailer.parent.spr
            trailObj.color = trailer.parent.color
            trailObj.flip = trailer.parent.flip
            trailObj.rotation = trailer.parent.rotation
            trailObj.scaleX = trailer.parent.scaleX
            trailObj.scaleY = trailer.parent.scaleY
            trailObj:setActive()
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

-- Written to be actually easy to use
function createFadingRectangle2(x, y, width, height, color, lifeTime, rotation)
    local fadingRect = GameObjects.newGameObject(1, 0, 0, 0, false, GameObjects.DrawLayers.PROJECTILES)
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
            love.graphics.rectangle('fill', fadingRect.x - fadingRect.width/2, fadingRect.y - fadingRect.height/2, fadingRect.width, fadingRect.height)
        end
    end
    
    function fadingRect:setActive()
        fadingRect.lifeTime = fadingRect.maxLifeTime
        fadingRect.alpha = 1
        fadingRect.active = true
    end

    return fadingRect
end

function createFadingRectangle(x, y, width, height, color, lifeTime, rotation)
    local fadingRect = GameObjects.newGameObject(1, 0, 0, 0, false, GameObjects.DrawLayers.PROJECTILES)
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

function createPulsingCircle(x, y, color, baseRadius, sinFrequency, sinMagnitude, drawLayer, outlineColor)
    local pulsingCircle = GameObjects.newGameObject(-1, x, y, 0, false, drawLayer or GameObjects.DrawLayers.PLAYER)
    pulsingCircle.sinusoidTimer = createSinusoidTimer(sinFrequency)
    pulsingCircle.baseRadius = baseRadius
    pulsingCircle.color = color
    pulsingCircle.sinMagnitude = sinMagnitude
    pulsingCircle.radius = pulsingCircle.baseRadius
    pulsingCircle.outlineColor = outlineColor
    function pulsingCircle:setActive()
        pulsingCircle.sinusoidTimer:init()
        pulsingCircle.active = true
    end
    function pulsingCircle:update(dt)
        pulsingCircle.sinusoidTimer:update(dt)
        pulsingCircle.radius = pulsingCircle.baseRadius + pulsingCircle.sinusoidTimer.sineValue * pulsingCircle.sinMagnitude
    end
    function pulsingCircle:draw()
        love.graphics.setColor(pulsingCircle.color[1], pulsingCircle.color[2], pulsingCircle.color[3], pulsingCircle.alpha)
        love.graphics.circle("fill", pulsingCircle.x, pulsingCircle.y, pulsingCircle.radius)
        if outlineColor then
            love.graphics.setColor(outlineColor)
            love.graphics.circle("line", pulsingCircle.x, pulsingCircle.y, pulsingCircle.radius)
        end
    end
    return pulsingCircle
end

function createCircularPop(x, y, color, startRadius, endRadius, startAlpha, endAlpha, lifeTime, drawLayer, outlined, outlineColor)
    local circularPop = GameObjects.newGameObject(1,x,y,0,false,drawLayer or GameObjects.DrawLayers.PROJECTILES)

    circularPop.outlined = outlined
    circularPop.outlineColor = outlineColor
    circularPop.color = color
    circularPop.ignorePref = false
    -- ignore the player's explosion preferences if the color is black, because black is used for screen fading
    if #circularPop.color >= 3 then
        if circularPop.color[1] == 0 and circularPop.color[2] == 0 and circularPop.color[3] == 0 then
            circularPop.ignorePref = true
        end
    end

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

        circularPop.alpha = lerp(circularPop.startAlpha, circularPop.endAlpha, circularPop.lifetimeFraction)
        circularPop.radius = lerp(circularPop.startRadius, circularPop.endRadius, circularPop.lifetimeFraction)
        if circularPop.lifeTime <= 0 then
            circularPop.active = false
        end
    
    end

    function circularPop:draw()
        love.graphics.setColor(circularPop.color[1],circularPop.color[2],circularPop.color[3],circularPop.alpha)
        love.graphics.circle('fill', circularPop.x, circularPop.y, circularPop.radius)
        if circularPop.outlined then
            love.graphics.setColor(circularPop.outlineColor[1],circularPop.outlineColor[2],circularPop.outlineColor[3],circularPop.alpha)
            love.graphics.circle('line', circularPop.x, circularPop.y, circularPop.radius)
        end
    end

    function circularPop:activateOnParent(parent)
        circularPop.x = parent.x
        circularPop.y = parent.y
        circularPop:setActive()
    end

    function circularPop:setActive()
        circularPop.lifeTime = circularPop.maxLifeTime
        circularPop.radius = circularPop.startRadius
        circularPop.alpha = circularPop.startAlpha
        circularPop.active = true
    end
    
    return circularPop
end

function createScreenFlash(color, lifeTime, fadeAlpha, drawLayer)
    local screenFlash = GameObjects.newGameObject(1, 0, 0, 0, false, drawLayer or GameObjects.DrawLayers.UI)
    screenFlash.maxLifeTime = lifeTime
    screenFlash.lifeTime = lifeTime
    screenFlash.color = {}
    for k = 1,#color do
        screenFlash.color[k] = color[k]
    end
    screenFlash.startAlpha = color[4]

    function screenFlash:update(dt)
        screenFlash.lifeTime = screenFlash.lifeTime - dt
        if fadeAlpha then
            screenFlash.color[4] = screenFlash.startAlpha * screenFlash.lifeTime / screenFlash.maxLifeTime
        end
        if screenFlash.lifeTime <= 0 then
            screenFlash:setInactive()
        end
    end

    function screenFlash:draw()
        if (gamePreferences.screenFlashIntensity ~= 0) or (screenFlash.color[1] == 0 or screenFlash.color[2] == 0 or screenFlash.color[3] == 0) then
            if screenFlash.color[1] ~= 0 or screenFlash.color[2] ~= 0 or screenFlash.color[3] ~= 0 then
                love.graphics.setColor(screenFlash.color[1] * gamePreferences.screenFlashIntensity,screenFlash.color[2] * gamePreferences.screenFlashIntensity,screenFlash.color[3] * gamePreferences.screenFlashIntensity,screenFlash.color[4] * gamePreferences.screenFlashIntensity)
            else
                -- For pure black flashes, still use the flash FX
                love.graphics.setColor(screenFlash.color[1],screenFlash.color[2],screenFlash.color[3],screenFlash.color[4])
            end
            love.graphics.rectangle('fill', -gameResolution.width, -gameResolution.height, gameResolution.width * 2, gameResolution.height * 2)
        end
    end

    function screenFlash:setActive()
        screenFlash.lifeTime = screenFlash.maxLifeTime
        screenFlash.color[4] = screenFlash.startAlpha
        screenFlash.active = true
    end

    return screenFlash
end

function createScalingRectangle(direction, xOrY, startSize, color, lifeTime, drawLayer, rotation, xy)
    local rect = GameObjects.newGameObject(1, 0, 0, 0, false, drawLayer or GameObjects.DrawLayers.PROJECTILES)
    rect.color = color
    rect.rotation = rotation or 0
    rect.xy = xy
    local horizontal = false
    if direction == "horizontal" then
        horizontal = true
        rect.y = xOrY
        rect.x = gameResolution.width / 2
        rect.width = gameResolution.width * 2
        rect.height = startSize
    else
        dir = false
        rect.x = xOrY
        rect.y = gameResolution.height / 2
        rect.width = startSize
        rect.height = gameResolution.height * 2
    end
    rect.maxLifeTime = lifeTime
    rect.lifeTime = lifeTime

    function rect:setActive()
        rect.active = true
        rect.lifeTime = rect.maxLifeTime
        if horizontal then
            rect.height = startSize
        else
            rect.width = startSize
        end
    end

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
            love.graphics.translate(rect.xy.x, rect.xy.y)
            love.graphics.rotate(rect.rotation)
            love.graphics.setColor(rect.color[1],rect.color[2],rect.color[3],1)
            love.graphics.rectangle('fill', -rect.width/2, -rect.height/2, rect.width, rect.height)
            love.graphics.pop()
        end
    end

    return rect
end

function worldSpaceTextWithIcons(text, x, y, textureIndex, color, drawLayer, iconOffsetX, iconOffsetY, blackBG)
    local texts, icons, iconIndices = splitAlongDelimiterAndExtract(text, iconControlChar.."%d")
    local quads = {}
    for k = 1,#icons do
        icons[k] = tonumber(icons[k]:sub(2)) -- get rid of the control char and convert to number
        quads[k] = love.graphics.newQuad(0,0,0,0,0,0)
    end
    local iconText = GameObjects.newGameObject(-1, x, y + fontYOffset, 0, false, drawLayer or GameObjects.DrawLayers.PLAYER)
    iconText.originalText = text
    iconText.originalTextLength = defaultFont:getWidth(text)
    iconText.font = defaultFont
    iconText.texts = texts
    iconText.icons = icons
    iconText.iconIndices = iconIndices
    iconText.textureIndex = textureIndex
    iconText.color = {color[1],color[2],color[3],color[4]}
    iconText.quads = quads
    iconText.iconOffset = {x=iconOffsetX or 1, y=iconOffsetY or -3}
    iconText.blackBG = blackBG
    iconText.totalTextLength = 0
    iconText.numNewlines = getNumNewlines(text) + 1
    for k = 1,#texts do
        iconText.totalTextLength = iconText.totalTextLength + defaultFont:getWidth(texts[k])
    end
    for k = 1,#icons do
        iconText.totalTextLength = iconText.totalTextLength + Texture.textures[iconText.textureIndex].slice + iconText.iconOffset.x
    end

    iconText.drawText =
        function(currentText, textX, textY)
            -- draw text first
            local numNewlines = getNumNewlines(currentText)
            local firstNewlineInd = currentText:find("\n")
            local lastNewlineInd = currentText:find("\n[^\n]*$")
            if firstNewlineInd then
                if firstNewlineInd == 1 then
                    textY = textY + 10
                end
                textX = iconText.x
            end
            pPrint(currentText, textX, textY)
            if lastNewlineInd then
                textX = iconText.x + iconText.font:getWidth(string.sub(currentText, lastNewlineInd, #currentText)) -- reset the x position if a newline is found
                textY = textY + 10 * numNewlines
            else
                textX = textX + iconText.font:getWidth(currentText)
            end
            return textX, textY
        end
    function iconText:draw()
        if iconText.blackBG then
            love.graphics.setColor(global_pallete.secondary_color)
            love.graphics.rectangle("fill", iconText.x-1, iconText.y-2, iconText.totalTextLength, 10*iconText.numNewlines)
        end
        love.graphics.setColor(iconText.color)
        local textInd = 1
        local textX, textY = iconText.x, iconText.y
        if iconIndices[1] ~= 1 then
            textX, textY = iconText.drawText(iconText.texts[textInd], textX, textY)
            textInd = textInd + 1
        end
        for k = 1,#iconIndices do
            Texture.draw(Texture.textures[iconText.textureIndex], iconText.icons[k], textX + iconText.iconOffset.x + Texture.textures[iconText.textureIndex].slice/2, textY + iconText.iconOffset.y + Texture.textures[iconText.textureIndex].slice/2, 1, 1, iconText.color[4], iconText.color, 0, iconText.quads[k], 1, 1)
            textX = textX + Texture.textures[iconText.textureIndex].slice
            -- also draw our next piece of text
            if textInd <= #iconText.texts then
                textX, textY = iconText.drawText(iconText.texts[textInd], textX, textY)
                textInd = textInd + 1
            end
        end
    end
    return iconText
end

function worldSpaceText(text, x, y, color, drawLayer, loveText, blackBG)
    local yOffset = fontYOffset or 0
    local textObj = GameObjects.newGameObject(0,x,y + yOffset,0,true,drawLayer)
    textObj.loveText = defaultFont
    if loveText then
        textObj.loveText = loveText
    end
    local textWidth = 0
    if type(text) == "string" then
        textWidth = textObj.loveText:getWidth(text)
    elseif type(text) == "table" then
        for k = 1,#text do
            if k % 2 == 0 then
                textWidth = textWidth + textObj.loveText:getWidth(text[k])
            end
        end
    end
    textObj.textWidth = textWidth
    textObj.blackBG = blackBG
    textObj.text = text
    textObj.nonDefaultFont = loveText ~= nil
    textObj.color = color
    textObj.numNewlines = getNumNewlines(text) + 1
    textObj.textHeight = textObj.loveText:getHeight() * textObj.numNewlines
    function textObj:draw()
        local oldFont
        if textObj.nonDefaultFont then
            oldFont = love.graphics.getFont()
        end
        if textObj.blackBG then
            local pixBorder = gameResolution.width / 160
            love.graphics.setColor(global_pallete.secondary_color[1], global_pallete.secondary_color[2], global_pallete.secondary_color[3], 0.7)
            love.graphics.rectangle('fill', textObj.x - textObj.textWidth/2 - pixBorder, textObj.y - pixBorder, textObj.textWidth + 2*pixBorder, textObj.textHeight + 2*pixBorder)
        end
        love.graphics.setFont(textObj.loveText)
        love.graphics.setColor(textObj.color[1],textObj.color[2],textObj.color[3],textObj.alpha)
        love.graphics.print(textObj.text, textObj.x - textObj.textWidth/2, textObj.y)
        if textObj.nonDefaultFont then
            love.graphics.setFont(oldFont)
        end
    end

    return textObj
end

function fadingWorldSpaceText(text, x, y, tY, color, drawLayer, loveText, fadeInSpeed, fadeOutSpeed, toMove, moveKP)
    local textObj = worldSpaceText(text, x, y, color, drawLayer, loveText)
    fadeInSpeed = fadeInSpeed or 1
    fadeOutSpeed = fadeOutSpeed or 1
    textObj.fading = 0 -- -1 is fading out, 1 is fading in
    textObj.tY = tY
    textObj.originalY = textObj.y
    moveKP = moveKP or 5
    function textObj:update(dt)
        if textObj.fading ~= 0 then
            textObj.alpha = textObj.alpha + dt * textObj.fading * (textObj.fading == 1 and fadeInSpeed or fadeOutSpeed)
            if textObj.alpha <= 0 or textObj.alpha >= 1 then
                textObj.alpha = clamp(0, textObj.alpha, 1)
                textObj.fading = 0
                if textObj.alpha <= 0 then
                    textObj.active = false
                end
            end
        end
        if toMove and math.abs(textObj.tY - textObj.y) > 1 then
            textObj.y = lerp(textObj.y, textObj.tY, dt * moveKP)
        end
    end
    function textObj:setActive()
        textObj.active = true
        textObj.alpha = 0
        textObj.fading = 1
        textObj.y = textObj.originalY
    end
    function textObj:setInactive()
        textObj.alpha = 1
        textObj.fading = -1
    end
    return textObj
end

function verticalScreenTransition(dir)
    local transition = GameObjects.newGameObject(-1,0,dir == 1 and 0 or gameResolution.height,0,true,GameObjects.DrawLayers.POSTCAMERA)
    transition.height = gameResolution.height
    local dY = dir == 1 and 0 or -1
    local dH = dir == 1 and -1 or 1
    local rate = 2000
    function transition:update(dt)
        transition.y = transition.y + dY * rate * dt
        transition.height = transition.height + rate * dt * dH
    end
    function transition:draw()
        love.graphics.setColor(global_pallete.secondary_color)
        love.graphics.rectangle("fill", 0, transition.y, gameResolution.width, transition.height)
    end
    return transition
end

function createFallingLine(x, y, width, height, velocity, lifeTime, centerX, centerY, rotation, layer)
    local fallingLine = GameObjects.newGameObject(-1,x,y,0,false,layer or GameObjects.DrawLayers.IGNORE_DT)
    fallingLine.lifeTime = lifeTime
    fallingLine.width = width
    fallingLine.height = height
    fallingLine.lineRotation = rotation
    fallingLine.centerX = centerX
    fallingLine.centerY = centerY
    fallingLine.velocity = velocity
    function fallingLine:update(dt)
        fallingLine.y = fallingLine.y + fallingLine.velocity * dt
        fallingLine.lifeTime = fallingLine.lifeTime - dt
        if fallingLine.lifeTime < 0 then
            fallingLine:setInactive()
        end
    end

    function fallingLine:draw()
        love.graphics.push()
        love.graphics.translate(fallingLine.centerX, fallingLine.centerY)
        love.graphics.rotate(fallingLine.lineRotation)
        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle('fill', fallingLine.x, fallingLine.y, fallingLine.width, fallingLine.height)
        love.graphics.pop()
    end

    return fallingLine
end

function velocityLines(centerX, centerY, rotation, speed, yStart, layer)
    local fallingLineGenerator = GameObjects.newGameObject(-1,0,0,0,true,layer or GameObjects.DrawLayers.IGNORE_DT)
    local fallingLineInterval = 0.06
    fallingLineGenerator.interval = fallingLineInterval
    local widthBounds = {1,1}
    local fallingSpeed = speed or 8000
    local boundsSize = 6
    local minBound = 0
    local heightBounds = {30,50}
    local yStart = -64
    fallingLineGenerator.pool = createPool(300, createFallingLine)
    fallingLineGenerator.getLine = 
        function(x, y, width, height, velocity, lifeTime, centerX, centerY, rotation, layer)
            local line = fallingLineGenerator.pool:getFromPool()
            line.x = x
            line.y = y
            line.width = width
            line.height = height
            line.velocity = velocity
            line.lifeTime = lifeTime
            line.centerX = centerX
            line.centerY = centerY
            line.lineRotation = rotation
            line.drawLayer = layer
            line.active = true
        end
    function fallingLineGenerator:update(dt)
        fallingLineGenerator.interval = fallingLineGenerator.interval - dt
        if fallingLineGenerator.interval < 0 then
            fallingLineGenerator.getLine(randomBetween(-boundsSize,-minBound),yStart,randomBetween(widthBounds[1],widthBounds[2]),randomBetween(heightBounds[1],heightBounds[2]),fallingSpeed,0.5, centerX, centerY, rotation,fallingLineGenerator.drawLayer)
            fallingLineGenerator.getLine(randomBetween(minBound,boundsSize),yStart,randomBetween(widthBounds[1],widthBounds[2]),randomBetween(heightBounds[1],heightBounds[2]),fallingSpeed,0.5, centerX, centerY, rotation,fallingLineGenerator.drawLayer)
            fallingLineGenerator.interval = fallingLineInterval
        end
    end
    return fallingLineGenerator
end