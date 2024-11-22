function createLifeTimer(obj, lifeTime)
    local timer = GameObjects.newComponent()
    timer.obj = obj
    timer.maxLifeTime = lifeTime
    timer.lifeTime = lifeTime
    function timer:update(dt)
        timer.lifeTime = timer.lifeTime - dt
        if timer.lifeTime <= 0 then
            timer.obj:setInactive()
        end
    end
    function timer:setActive()
        timer.active = true
        timer.lifeTime = timer.maxLifeTime
    end
    function timer:setInactive()
        timer.active = false
    end
    return timer
end

function parallaxUpdate(obj, parallaxFactor)
    obj.x, obj.y = (Camera.x * parallaxFactor), (Camera.y * parallaxFactor)
end

function stateSelector(enemy, stateFcns, stateOrder, initialDelay)
    local selector = GameObjects.newGameObject(-1,0,0,0,true)
    selector.enemy = enemy
    selector.stateFcns = stateFcns
    selector.stateOrder = stateOrder
    selector.stateIndex = 0
    function selector:goToNextState()
        selector.stateIndex = selector.stateIndex + 1
        if selector.stateIndex > #selector.stateOrder then
            selector.stateIndex = 1
        end
        selector.enemy:startCoroutine(selector.stateFcns[selector.stateOrder[selector.stateIndex]], "state"..selector.stateIndex)
    end
    selector.goRoutine = 
        function()
            coroutine.yield(initialDelay or 2)
            selector:goToNextState()
        end
    function selector:go()
        selector:startCoroutine(selector.goRoutine, "go")
    end
    return selector
end

function randomlyChooseIndicesWithoutReplacement(arraySize, numToChoose)
    local indexArray = {}
    for k = 1,arraySize do
        indexArray[k] = k
    end
    local chooseArray = {}
    for k = 1,numToChoose do
        local randInd = math.random(#indexArray)
        chooseArray[k] = indexArray[randInd]
        table.remove(indexArray, randInd)
    end
    return chooseArray
end

function createSinusoidTimer(frequency)
    local timer = {
        frequency=frequency,
        totalTime=0,
        sineValue = 0,
        cosValue = 0
    }
    function timer:update(dt)
        timer.totalTime = timer.totalTime + dt
        timer.sineValue = math.sin(timer.totalTime * timer.frequency)
        timer.cosValue = math.cos(timer.totalTime * timer.frequency)
    end
    function timer:init()
        timer.totalTime = 0
    end
    return timer
end

function createSquashStretcher(parent, kP)
    local squashStretcher = GameObjects.newComponent()
    squashStretcher.parent = parent
    squashStretcher.tScaleX = parent.scaleX
    squashStretcher.tScaleY = parent.scaleY
    -- squashStretcher.tScaleZ = parent.scaleZ
    squashStretcher.kP = kP or 10
    function squashStretcher:update(dt)
        squashStretcher.parent.scaleX = lerp(squashStretcher.parent.scaleX, squashStretcher.tScaleX, squashStretcher.kP * dt)
        squashStretcher.parent.scaleY = lerp(squashStretcher.parent.scaleY, squashStretcher.tScaleY, squashStretcher.kP * dt)
        -- squashStretcher.parent.scaleZ = lerp(squashStretcher.parent.scaleZ, squashStretcher.tScaleZ, squashStretcher.kP * dt)
    end
    function squashStretcher:squashStretch(scaleX, scaleY)--, scaleZ)
        squashStretcher.parent.scaleX = scaleX
        squashStretcher.parent.scaleY = scaleY
        -- squashStretcher.parent.scaleZ = scaleZ
    end
    function squashStretcher:reset()
        squashStretcher.tScaleX = squashStretcher.parent.scaleX
        squashStretcher.tScaleY = squashStretcher.parent.scaleY
        -- squashStretcher.tScaleZ = squashStretcher.parent.scaleZ
    end
    function squashStretcher:setActive()
        squashStretcher.active = true
    end
    function squashStretcher:setInactive()
        squashStretcher.active = false
    end
    return squashStretcher
end

function pPrint(txt, x, y)
    local k = 0
    -- this font is kinda weird about printing newlines, so we'll just eat them and space it ourselves
    for line in string.gmatch(txt, "[^\r\n]+") do
        love.graphics.print(line, x, y + fontYOffset + k * 10)
        k = k + 1
    end
end

function getLongestLineLength(txt)
    local longestLength = 0
    for line in string.gmatch(txt, "[^\r\n]+") do
        if #line > longestLength then
            longestLength = #line
        end
    end
    return longestLength
end

function getNumNewlines(txt)
    local numNewlines = -1
    for line in string.gmatch(txt, "[^\r\n]+") do
        numNewlines = numNewlines + 1
    end
    return numNewlines
end

function stripChar(txt, charToStrip, replaceWith)
    replaceWith = replaceWith or ""
    local strippedText = string.gsub(txt, charToStrip, replaceWith)
    return strippedText
end

function orbitalMotion(obj, anchor, radius, rate, dt)
    if not obj.orbitalTime then
        obj.orbitalTime = 0
    end
    if not obj.orbitalOffset then
        obj.orbitalOffset = 0
    end
    obj.x = anchor.x + radius * math.cos(obj.orbitalOffset + obj.orbitalTime * rate)
    obj.y = anchor.y + radius * math.sin(obj.orbitalOffset + obj.orbitalTime * rate)
    obj.orbitalTime = obj.orbitalTime + dt
end

-- adapted from here https://stackoverflow.com/questions/1426954/split-string-in-lua
function splitAlongDelimiterAndExtract (inputstr, delimiter)
    local splitContents={}
    local delimitContents = {}
    local delimitIndices = {}
    inputstr:gsub(delimiter,
    function(str)
        table.insert(delimitContents, str)
        local strIndex = string.find(inputstr, str)
        table.insert(delimitIndices, strIndex)
    end)
    -- Once we've extracted the delimited contents and indices, replace all delimiters with a null char
    -- We need to do this because if we try to split along arbitrary patterns, we might run into issues of mistakenly filtering some parts of the pattern
    -- i.e if we split along #%d, we might lose other digits in the process.
    inputstr = inputstr:gsub(delimiter, "\0")
    -- now we can just split the string along the null character instead of this pattern "[^"..delimiter.."]+"
    -- The null character in this version of lua is %z, not \0 in patterns
    for str in string.gmatch(inputstr, "[^%z]+") do
        table.insert(splitContents, str)
    end
    return splitContents, delimitContents, delimitIndices
end

-- Shoot a projectile in a direction at terrain
-- used in place of raycasting
function createTerrainTestProjectile()
    local proj = GameObjects.newGameObject(-1,0,0,0,false)
    Collision.addCircleCollider(proj, 1, Collision.Layers.CORPSE, {})
    Physics.addRigidBody(proj)
    proj.RigidBody.isSolid = true
    Physics.setSolidIgnoreMap(proj, {3,4,5,75,76,77,83,85,91,92,93})
    proj.Collider.onSolidCollision =
        function()
            Physics.zeroVelocity(proj)
            proj:setInactive()
        end
    function proj:go(sX, sY, tX, tY)
        proj.x, proj.y = sX, sY
        proj.RigidBody.velocity.x, proj.RigidBody.velocity.y = clampVecToLength(tX - sX, tY - sY, 1000)
        proj:setActive()
    end
    return proj
end

-- specify a prompt with the "~" character where the button should be. for example
-- "Press ~ to jump"
function createControlsPrompt(x, y, mappedButtonName, text, font)
    local controlsPrompt = GameObjects.newGameObject(-1, x, y, 0, false, GameObjects.DrawLayers.POSTCAMERA)
    controlsPrompt.mappedButtonName = mappedButtonName
    controlsPrompt.buttonNameString = Input.getControlString(mappedButtonName, Input.activelyUsingController)
    controlsPrompt.originalText = text
    controlsPrompt.text = string.gsub(controlsPrompt.originalText, "~", controlsPrompt.buttonNameString)
    controlsPrompt.font = font or defaultFont
    controlsPrompt.textWidth = controlsPrompt.font:getWidth(controlsPrompt.text)
    controlsPrompt.textHeight =  controlsPrompt.font:getHeight() * (getNumNewlines(controlsPrompt.text) + 1)
    controlsPrompt.color = global_pallete.primary_color
    controlsPrompt.useBlackBG = true
    function controlsPrompt:update(dt)
        local controlString = Input.getControlString(controlsPrompt.mappedButtonName, Input.activelyUsingController)
        if controlString ~= controlsPrompt.buttonNameString then
            controlsPrompt.buttonNameString = controlString
            controlsPrompt.text = string.gsub(controlsPrompt.originalText, "~", controlsPrompt.buttonNameString)
            controlsPrompt.textWidth = controlsPrompt.font:getWidth(controlsPrompt.text)
        end
    end
    function controlsPrompt:draw()
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(controlsPrompt.font)
        love.graphics.setColor(global_pallete.secondary_color[1], global_pallete.secondary_color[2], global_pallete.secondary_color[3], 0.7)
        local margin = gameResolution.width / 160
        if controlsPrompt.useBlackBG then
            love.graphics.rectangle("fill", controlsPrompt.x - controlsPrompt.textWidth/2 - margin, controlsPrompt.y - margin, controlsPrompt.textWidth+margin*2, controlsPrompt.textHeight + margin*2)
        end
        love.graphics.setColor(controlsPrompt.color)
        love.graphics.print(controlsPrompt.text, controlsPrompt.x - controlsPrompt.textWidth/2, controlsPrompt.y)
        love.graphics.setFont(oldFont)
    end
    return controlsPrompt
end