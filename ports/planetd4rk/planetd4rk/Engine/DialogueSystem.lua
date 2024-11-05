local DialogueSystem = {}

-- fields of textNode
-- x,y,text,letterDelay,totalDelay,speakerIndex,fx,preFcn
function DialogueSystem.createCutscene(gameState, textNodes, numTextNodes, speakerColors, speakerSounds, preDelay, postDelay, bigFont)
    local cutscene = GameObjects.newGameObject(1,0,0,0,true,GameObjects.DrawLayers.UI)
    cutscene.alpha = 0

    cutscene.textNodes = textNodes
    cutscene.numTextNodes = numTextNodes
    cutscene.speakerColors = speakerColors
    cutscene.speakerSounds = speakerSounds
    cutscene.currentLine = 0
    cutscene.currentText = ""

    function cutscene:draw()
        if cutscene.currentLine > 0 then
            local color = cutscene.speakerColors[cutscene.textNodes[cutscene.currentLine].speakerIndex]
            love.graphics.setColor(color[1], color[2], color[3], 1)
            local currentX = cutscene.textNodes[cutscene.currentLine].x
            local currentY = cutscene.textNodes[cutscene.currentLine].y
            local cachedFont
            if bigFont then
                cachedFont = love.graphics.getFont()
                love.graphics.setFont(mediumPicoFont)
            end
            love.graphics.print(cutscene.currentText, currentX, currentY)
            if bigFont then
                love.graphics.setFont(cachedFont)
            end
        end
    end

    function cutscene:runFullCutscene()
        cutscene:startCoroutine(runFullCutscene, "runFullCutscene")
    end

    function runFullCutscene()
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
        cutscene:startCoroutine(typeText, "typeText")
    end

    function typeText()
        local currentNode = cutscene.textNodes[cutscene.currentLine]
        local currentLength = #(currentNode.text)
        if not currentNode.letterDelay then
            currentNode.letterDelay = 0.01
        end
        if currentNode.preFcn then
            currentNode.preFcn()
        end
        if not currentNode.soundMod then
            currentNode.soundMod = 2
        end
        if currentNode.fx ~= nil and currentNode.fx == "shake" then
            Camera.shake(4)
            cutscene.currentText = string.sub(currentNode.text, 1, currentLength)
            if cutscene.speakerSounds[currentNode.speakerIndex] then
                SoundManager.playSound(cutscene.speakerSounds[currentNode.speakerIndex])
            end
            SoundManager.playSound("DramaticText", 0.8)
            coroutine.yield(currentNode.totalDelay)
        else
            for k = 1,currentLength do
                if string.sub(currentNode.text,k,k+1) == "\n" then
                    k = k + 1
                end
                cutscene.currentText = string.sub(currentNode.text, 1, k)
                if cutscene.speakerSounds[currentNode.speakerIndex] and string.sub(currentNode.text,k,k) ~= " " and string.sub(currentNode.text,k,k) ~= "."
                    and k % currentNode.soundMod == 0 then
                    SoundManager.playSound(cutscene.speakerSounds[currentNode.speakerIndex], 0.8)
                end
                coroutine.yield(currentNode.letterDelay)
                if string.sub(currentNode.text,k,k) == "." or string.sub(currentNode.text,k,k) == ","then
                    coroutine.yield(0.3)
                end
            end
        end

    end

    return cutscene
end

return DialogueSystem