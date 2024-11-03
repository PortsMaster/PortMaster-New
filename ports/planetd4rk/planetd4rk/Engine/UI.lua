function uiPanel(x, y, width, height)
    local panel = GameObjects.newGameObject(-1, x, y, 0, false, GameObjects.DrawLayers.TOPUI)
    panel.fillColor = {0,0,0,0.7}
    panel.children = {}
    panel.numChildren = 0

    function panel:addChild(child)
        panel.numChildren = panel.numChildren + 1
        panel.children[panel.numChildren] = child
    end

    function panel:draw()
        love.graphics.setColor(panel.fillColor)
        love.graphics.rectangle('fill', x-width/2, y-height/2, width, height)
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle('line', x-width/2, y-height/2, width, height)
    end

    function panel:setInactive()
        for k = 1,panel.numChildren do
            panel.children[k]:setInactive()
        end
        panel.active = false
    end

    function panel:setActive()
        for k = 1,panel.numChildren do
            panel.children[k]:setActive()
        end
        panel.active = true
    end

    return panel
end

function uiButton(x, y, width, height, clickFcn)
    local button = GameObjects.newGameObject(-1, x, y, 0, false, GameObjects.DrawLayers.TOPUI)
    button.hoverColor = {1,1,1,0.3}
    button.hovering = false
    button.clickFcn = clickFcn

    function button:onHover()
        button.hovering = true
    end

    function button:offHover()
        button.hovering = false
    end

    function button:click(obj)
        button.clickFcn(obj)
    end

    function button:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle('line', x-width/2, y-height/2, width, height)
        if button.hovering then
            love.graphics.setColor(button.hoverColor)
            love.graphics.rectangle('fill', x-width/2, y-height/2, width, height)
        end
    end
    
    return button
end

function uiText(x, y, text, limit, align, style, fadeOut)
    local textObj = GameObjects.newGameObject(-1, x, y, 0, false, GameObjects.DrawLayers.TOPUI)
    textObj.color = {1,1,1}
    textObj.alpha = 1
    textObj.text = text
    textObj.align = align
    textObj.limit = limit or love.graphics.getFont():getWidth(textObj.text)
    textObj.height = math.ceil((love.graphics.getFont():getWidth(text)) / textObj.limit) * love.graphics.getFont():getHeight()
    textObj.fadeOut = fadeOut
    textObj.fadeSpeed = 2
    if textObj.align == "center" then
        textObj.x = textObj.x -  textObj.limit / 2
    end
    if style == "spooky" then
        textObj.spooky = true
        textObj.spookTexts = {}
        textObj.maxSpookCounter = 0.1
        textObj.spookCounter = textObj.maxSpookCounter
        textObj.spookIndex = 1
        textObj.spookOffset = 4
        for k = 1,3 do
            textObj.spookTexts[k] = uiText(x, y, text, textObj.limit, textObj.align, "fade")
        end
    elseif style == "fade" then
        textObj.fade = true
    elseif style == "wiggly" then
        textObj.wiggly = true
        textObj.amplitude = 2
        textObj.kOffset = 1.5
        textObj.frequency = 8
        textObj.totalTime = 0
        textObj.letters = {}
        for k = 1,#text do
            local tX = x
            if k > 1 then
                tX = x + love.graphics.getFont():getWidth(string.sub(textObj.text, 1, k-1))
            end
            textObj.letters[k] = uiText(tX, y, string.sub(text, k, k), nil, "left")
        end
    elseif style == "fadeDown" then
        textObj.fadeDown = true
        textObj.alpha = 0
        textObj.targetY = textObj.y
        textObj.y = textObj.y - 8
        textObj.startY = textObj.y
        textObj.maxTimeToFade = 0.2
        textObj.timeToFade = textObj.maxTimeToFade
    end

    function textObj:update(dt)
        if textObj.fade then
            textObj.alpha = textObj.alpha - dt * 2
            if textObj.alpha < 0 then
                textObj.alpha = 0
                textObj.active = false
            end
        elseif textObj.spooky then
            textObj.spookCounter = textObj.spookCounter - dt
            if textObj.spookCounter <= 0 then
                textObj.spookCounter = textObj.maxSpookCounter
                textObj.spookTexts[textObj.spookIndex].x = textObj.x + randomBetween(-textObj.spookOffset, textObj.spookOffset)
                textObj.spookTexts[textObj.spookIndex].y = textObj.y + randomBetween(-textObj.spookOffset, textObj.spookOffset)
                textObj.spookTexts[textObj.spookIndex]:setActive()
                textObj.spookIndex = textObj.spookIndex + 1
                if textObj.spookIndex > #textObj.spookTexts then
                    textObj.spookIndex = 1
                end
            end
        elseif textObj.wiggly then
            textObj.totalTime = textObj.totalTime + dt
        elseif textObj.fadeDown and textObj.alpha < 1 then
            textObj.y = textObj.startY + (textObj.targetY - textObj.startY) * (textObj.maxTimeToFade - textObj.timeToFade) / textObj.maxTimeToFade
            textObj.alpha = (textObj.maxTimeToFade - textObj.timeToFade) / textObj.maxTimeToFade
            textObj.timeToFade = textObj.timeToFade - dt
            if textObj.timeToFade <= 0 then
                textObj.y = textObj.targetY
                textObj.alpha = 1
            end
        end
    end

    function textObj:setActive()
        if textObj.fade then
            textObj.alpha = 0.5
        end
        textObj.active = true
    end

    function textObj:setInactive()
        if textObj.fadeOut then
            textObj.fade = true
        else
            textObj.active = false
        end
    end

    function textObj:draw()
        if textObj.wiggly then
            love.graphics.setColor(textObj.color[1], textObj.color[2], textObj.color[3], textObj.alpha)
            local tX = textObj.x
            for k = 1,#textObj.text do
                if k > 1 then
                    tX = textObj.x + love.graphics.getFont():getWidth(string.sub(textObj.text, 1, k-1))
                end
                love.graphics.printf(string.sub(textObj.text, k, k), tX, textObj.y + math.sin(textObj.totalTime * textObj.frequency + k * textObj.kOffset) * textObj.amplitude, textObj.limit, "left")    
            end
        else
            love.graphics.setColor(textObj.color[1], textObj.color[2], textObj.color[3], textObj.alpha)
            love.graphics.printf(textObj.text, textObj.x, textObj.y, textObj.limit, "left")      
        end
    end

    return textObj
end