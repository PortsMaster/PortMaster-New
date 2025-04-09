function createButton(text, x, y, parent, fcn)
    local button = {
        parent = parent,
        x=x,
        y=y,
        text=text,
        hovering = false,
        fcn = fcn,
        tRect = {x=0,y=0,w=0,h=0}
    }
    function button:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(button.text, button.parent.x + button.x - button.parent.font:getWidth(text)/2, button.parent.y + button.y + fontYOffset)
        if button.hovering then
            love.graphics.setColor(1,1,1,0.25)
            local width,height = button.parent.font:getWidth(text), button.parent.font:getHeight(text) + fontYOffset
            local x,y = button.parent.x + button.x - width/2 - 2, button.parent.y + button.y
            love.graphics.rectangle('fill', x, y, width + 3, height)
        end
    end
    function button:hoverOn()
        button.hovering = true
    end
    function button:hoverOff()
        button.hovering = false
    end
    function button:press()
        if button.fcn then
            button.fcn()
        end
    end
    function button:leftRight(dir)

    end
    function button:mouseLeftRight(mouseX)

    end
    function button:click(mouseX)
        button:press()
        button:mouseLeftRight(mouseX)
    end
    function button:isInRect(sx, sy, rx, ry, rwidth, rheight)
        button.tRect.x = rx
        button.tRect.y = ry
        button.tRect.w = rwidth
        button.tRect.h = rheight
        return sx > rx and sx < rx + rwidth and sy > ry and sy < ry + rheight
    end
    function button:mouseInBounds(mouseX, mouseY)
        local width,height = button.parent.font:getWidth(text), button.parent.font:getHeight(text) + fontYOffset
        return button:isInRect(mouseX, mouseY, button.parent.x + button.x - width/2 - 2, button.parent.y + button.y - 2, width, height)
    end
    function button:drawHitbox()
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle('line', button.tRect.x, button.tRect.y, button.tRect.w, button.tRect.h)
    end
    return button
end

function createSlider(text, x, y, parent, fcn, initialValue, stepSize)
    local slider = createButton(text, x, y, parent, function() end)
    slider.leftRightFcn = fcn
    slider.currentValue = initialValue or 1
    slider.stepSize = stepSize or 0.2
    slider.space = 12
    slider.length = 16
    function slider:leftRight(dir)
        slider.currentValue = clamp(0, slider.currentValue + dir * slider.stepSize, 1)
        slider.leftRightFcn(slider.currentValue)
    end
    function slider:mouseLeftRight(mouseX)
        -- the slider starts at the X position with a bit of leeway
        local startX = slider.parent.x + slider.x - 6
        -- the slider ends at the x position plus roughly 70
        local stopX = slider.parent.x + slider.x + 70
        -- The current value is between these two values.
        local currValueX = (stopX - startX) * slider.currentValue + startX
        slider:leftRight(mouseX + 2> currValueX and 1 or -1)
    end
    function slider:draw()
        local width,height = slider.parent.font:getWidth(text), slider.parent.font:getHeight(text) - 2
        love.graphics.setColor(1,1,1,1)
        local txtX = slider.parent.x + slider.x - width - slider.space/2
        if txtX < 1 then
            txtX = 1
        end
        love.graphics.print(slider.text, txtX, slider.parent.y + slider.y + fontYOffset)
        love.graphics.line(slider.parent.x + slider.x + slider.space, slider.parent.y + slider.y + height/2, slider.parent.x + slider.x + slider.length + slider.space, slider.parent.y + slider.y + height/2)
        love.graphics.rectangle('fill', slider.parent.x + slider.x + slider.space + (slider.length) * slider.currentValue - 1, slider.parent.y + slider.y, 2, height)
        if slider.hovering then
            love.graphics.setColor(1,1,1,0.25)
            local x,y = slider.parent.x + slider.x - width - slider.space - 4, slider.parent.y + slider.y
            love.graphics.rectangle('fill', x, y, width + 56, height + 2)
        end
    end
    function slider:mouseInBounds(mouseX, mouseY)
        local width,height = slider.parent.font:getWidth(text), slider.parent.font:getHeight(text) - 2
        return slider:isInRect(mouseX, mouseY, slider.parent.x + slider.x - width - 32 - 4, slider.parent.y + slider.y, width + 4 + 128, height + 4 + fontYOffset)
    end
    return slider
end

function createCheckbox(text, x, y, parent, fcn, checkFcn)
    local button = createButton(text, x, y, parent, fcn)
    button.space = 8
    function button:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(button.text, button.parent.x + button.x - button.parent.font:getWidth(text)/2 - button.space, button.parent.y + button.y)
        local width,height = button.parent.font:getWidth(text), button.parent.font:getHeight(text)
        local x,y = button.parent.x + button.x - width/2 - 4 - button.space, button.parent.y + button.y
        love.graphics.circle('line', button.parent.x + button.x + width/2 + height/2, button.parent.y + button.y + height/2, height/4)
        if checkFcn() then
            love.graphics.setColor(1,1,1,1)
            love.graphics.circle('fill', button.parent.x + button.x + width/2 + height/2, button.parent.y + button.y + height/2, height/4)
        end
        if button.hovering then
            love.graphics.setColor(1,1,1,0.25)
            love.graphics.rectangle('fill', x, y, width + 4 + button.space*2, height + fontYOffset)
        end
    end
    function button:mouseInBounds(mouseX, mouseY)
        local width,height = button.parent.font:getWidth(text), button.parent.font:getHeight(text)
        local x,y = button.parent.x + button.x - width/2 - 4 - button.space, button.parent.y + button.y
        return button:isInRect(mouseX, mouseY, x, y, width + 4 + button.space*2, height + 4 + fontYOffset)
    end
    return button
end

function createMultiSelect(text, x, y, parent, fcn, options, optionsValues, checkFcn)
    local button = createButton(text, x, y, parent, fcn)
    button.optionsValues = optionsValues
    button.options = options
    button.currentSelection = 1
    button.currentHover = 1
    button.xPositions = {}
    button.checkFcn = checkFcn
    local totalWidth = 0
    local optionsOffset = 16
    for k = 1,#options do
        totalWidth = totalWidth + parent.font:getWidth(options[k])
    end
    totalWidth = totalWidth + #options * optionsOffset
    button.totalWidth = totalWidth
    for k = 1,#options do
        button.xPositions[k] = -totalWidth / 2 + (k-1)*totalWidth / #options
    end
    function button:draw()
        love.graphics.setColor(1,1,1,1)
        local midY = button.parent.y + button.y
        love.graphics.print(text, button.x + button.parent.x - button.parent.font:getWidth(button.text)/2, midY + fontYOffset)
        for k = 1,#button.options do
            love.graphics.print(button.options[k], button.x + button.parent.x + button.xPositions[k], midY + 10 + fontYOffset)
        end

        local selectionX = button.parent.x + button.x + button.xPositions[button.currentSelection]
        local currOptionWidth = button.parent.font:getWidth(button.options[button.currentSelection])
        love.graphics.rectangle('line', selectionX-1, midY + 14  + fontYOffset, currOptionWidth+3, 9)
        if button.hovering then
            local hoverX = button.parent.x + button.x + button.xPositions[button.currentHover]
            love.graphics.circle('fill', hoverX - 6, midY + 18  + fontYOffset, 3)
        end
        button.checkFcn()
    end
    function button:hoverOn()
        button.hovering = true
        button.currentHover = button.currentSelection
    end
    function button:leftRight(dir)
        button.currentHover = clamp(1,button.currentHover + dir,#button.options)
    end
    function button:click(mouseX)
        for k = 1,#button.options do
            if mouseX < button.x + button.parent.x + button.xPositions[k] + 32 and mouseX > button.x + button.parent.x + button.xPositions[k] then
                button.currentHover = k
                button:press()
                break;
            end
        end
    end
    function button:mouseInBounds(mouseX, mouseY)
        return button:isInRect(mouseX, mouseY, button.parent.x + button.x - 100, button.y + button.parent.y, 200, 16)
    end
    return button
end

function createClickableButton(text, x, y, fcn, font, blackBG)
    local button = GameObjects.newGameObject(-1, x, y, 0, true, GameObjects.DrawLayers.POSTCAMERA)
    button.text = text
    button.font = font
    button.fcn = fcn
    button.textWidth = font:getWidth(text)
    button.textHeight = font:getHeight(text)
    button.width = font:getWidth(text) + 2
    button.height = font:getHeight(text)
    button.hovering = false
    function button:draw()
        if blackBG then
            love.graphics.setColor(0,0,0,1)
            love.graphics.rectangle("fill", x-button.width/2, y-button.height/2 + 2, button.width, button.height - 2)
        end
        if button.hovering then
            love.graphics.setColor(1,1,1,0.35)
            love.graphics.rectangle("fill", x-button.width/2, y-button.height/2 + 2, button.width, button.height - 2)
        end
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("line", x-button.width/2, y-button.height/2 + 2, button.width, button.height - 2)
        local tFont = love.graphics.getFont()
        love.graphics.setFont(font)
        love.graphics.print(button.text, x-button.textWidth/2, y-button.textHeight/2 - 1)
        love.graphics.setFont(tFont)
    end
    function button:update()
        local x, y = getMouseCanvasPosition()
        if x > button.x - button.width/2 and x < button.x + button.width/2 and
            y > button.y - button.height/2 and y < button.y + button.height/2 then
            if not button.hovering then
                button:onHover()
            end
        elseif button.hovering then 
            button:offHover()
        end
        if Input.getButtonPressed("mouse1") and button.hovering then
            button:click()
            -- SoundManager.playSound("Select")
        end
    end
    function button:onHover()
        button.hovering = true
    end
    function button:offHover()
        button.hovering = false
    end
    function button:click()
        button.fcn()
    end
    return button
end