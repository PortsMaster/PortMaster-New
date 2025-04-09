local DialogueSystem = {}

-- fields of textNode
-- x,y,text,letterDelay,totalDelay,speakerIndex,fx,preFcn
function DialogueSystem.createCutscene(gameState, textNodes, speakerColors, speakerSounds, preDelay, postDelay, customFont, blackBG)
    local cutscene = GameObjects.newGameObject(1,0,0,0,true,GameObjects.DrawLayers.POSTCAMERA)
    cutscene.alpha = 0

    cutscene.textNodes = textNodes
    cutscene.numTextNodes = #textNodes
    cutscene.speakerColors = speakerColors
    cutscene.speakerSounds = speakerSounds
    cutscene.currentLine = 0
    cutscene.currentText = ""
    cutscene.customFont = customFont
    cutscene.blackBG = blackBG

    function cutscene:draw()
        local originalFont = love.graphics.getFont()
        if customFont then
            love.graphics.setFont(customFont)
        end
        if cutscene.currentLine > 0 then
            local color = cutscene.speakerColors[cutscene.textNodes[cutscene.currentLine].speakerIndex]
            local currentX = cutscene.textNodes[cutscene.currentLine].x
            local currentY = cutscene.textNodes[cutscene.currentLine].y
            local textWidth = love.graphics.getFont():getWidth(cutscene.textNodes[cutscene.currentLine].text)
            if cutscene.blackBG and not cutscene.textNodes[cutscene.currentLine].noBlackBG then -- lol
                love.graphics.setColor(0,0,0,0.8)
                local border = gameResolution.width / 160
                local textHeight = love.graphics.getFont():getHeight()
                love.graphics.rectangle("fill", currentX - textWidth/2 - border, currentY - border, textWidth + border*2, textHeight + border*2)
            end
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.print(cutscene.currentText, currentX - textWidth/2, currentY)
        end
        if customFont then
            love.graphics.setFont(originalFont)
        end
    end

    function cutscene:runFullCutscene()
        cutscene:startCoroutine(cutscene.runFullCutsceneRoutine, "runFullCutscene")
    end

    cutscene.runFullCutsceneRoutine = function ()
        coroutine.yield(preDelay)
        for k = 1,cutscene.numTextNodes do
            cutscene:typeNextLine()
            local currentNode = cutscene.textNodes[cutscene.currentLine]
            if not currentNode.totalDelay then
                currentNode.totalDelay = #(currentNode.text) * currentNode.letterDelay + 2
            end
            coroutine.yield(currentNode.totalDelay)
        end
        coroutine.yield(postDelay)
        gameState.goToNextLevel()
    end

    function cutscene:typeNextLine()
        cutscene.currentLine = cutscene.currentLine + 1
        if (cutscene.currentLine > cutscene.numTextNodes) then
            cutscene.active = false
            return
        end
        cutscene:startCoroutine(cutscene.typeText, "typeText")
    end

    cutscene.typeText = function ()
        local currentNode = cutscene.textNodes[cutscene.currentLine]
        local currentLength = #(currentNode.text)
        local textMod = currentNode.textMod or 2
        if not currentNode.letterDelay then
            currentNode.letterDelay = 0.025
        end
        if currentNode.preFcn then
            currentNode.preFcn()
        end
        if currentNode.fx ~= nil and currentNode.fx == "shake" then
            Camera.shake(0.4)
            cutscene.currentText = string.sub(currentNode.text, 1, currentLength)
            if cutscene.speakerSounds[currentNode.speakerIndex] then
                SoundManager.playSound(cutscene.speakerSounds[currentNode.speakerIndex])
            end
            -- SoundManager.playSound("DramaticText", 0.6)
            coroutine.yield(currentNode.totalDelay or 1)
        else
            for k = 1,currentLength do
                if string.sub(currentNode.text,k,k+1) == "\n" then
                    k = k + 1
                end
                cutscene.currentText = string.sub(currentNode.text, 1, k)
                if cutscene.speakerSounds[currentNode.speakerIndex] and string.sub(currentNode.text,k,k) ~= " " and string.sub(currentNode.text,k,k) ~= "." and k%textMod == 0 then
                    SoundManager.playSound(cutscene.speakerSounds[currentNode.speakerIndex], 0.8)
                end
                coroutine.yield(currentNode.letterDelay)
                if string.sub(currentNode.text,k,k) == "." or string.sub(currentNode.text,k,k) == ","  or string.sub(currentNode.text,k,k) == "?"then
                    coroutine.yield(0.3)
                end
            end
        end

    end

    return cutscene
end

return DialogueSystem