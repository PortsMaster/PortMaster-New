VERSION = "11.2"
local states = require ("states")
gui = require("gui")
viewPositionX, viewPositionY = 150, -400
undoLimit = 200
tableDef = nil
history = { }
tool = { type=nil }
selection = { }
saveDirectory = "tables"
currentFilename = nil
disableEditor = false
hasUnsavedChanges = false
startupLogo = love.graphics.newImage("icons/startup-logo.png")

function love.load()
    screenWidth, screenHeight = love.graphics.getDimensions()
    states:new (states.startup)
    states.flags["has loaded"] = false
    createGuidelineBackground()
    love.graphics.setNewFont(42)
    copyExampleTable()
end

function love.update(dt)
    states:update(dt)
    if (states.current == states.loading) then
        if (not states.flags["has loaded"]) then
            states.flags["has loaded"] = true
            loveframes = require("loveframes")
            checkSaveDirectory()
            loveframes.config["ENABLE_SYSTEM_CURSORS"] = false
            registerTools()
            gui.createStatusbar()
            clearTableDefinition()
            gui.setComponentTag = setComponentTag
            gui.setComponentCooldown = setComponentCooldown
        end
    elseif (states.current == states.editor) then
        moveSelectedComponent()
        loveframes.update(dt)
    end
end

function love.draw()
    if (states.current == states.startup or states.current == states.loading) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(backgroundImage, 0, 0)
        love.graphics.draw(startupLogo, 50, screenHeight - startupLogo:getHeight())
        love.graphics.print("v"..VERSION)
    elseif (states.current == states.editor) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(backgroundImage, 0, 0)
        love.graphics.translate(viewPositionX, viewPositionY)
        drawPinballComponents()
        drawSelectedComponent()
        love.graphics.origin()
        drawTool()
        loveframes.draw()
    end
end

function love.wheelmoved(x, y)

    if (y > 0) then
        if (love.keyboard.isDown ("lshift")) then
            viewPositionX = viewPositionX + 50
        else
            viewPositionY = viewPositionY + 50
        end
    end

    if (y < 0) then
        if (love.keyboard.isDown ("lshift")) then
            viewPositionX = viewPositionX - 50
        else
            viewPositionY = viewPositionY - 50
        end
    end
    
end


function love.mousepressed(x, y, button)

    if (states.current ~= states.editor) then return end
    loveframes.mousepressed(x, y, "l")
    if (disableEditor) then return end
    
    if (x < gui.toolboxWidth) then return end
    if (x > gui.advancedPaneX) then return end

    if (button == 1) then

        if (tool.type == "select") then
        -- Selection Tool
            local tablePosition = toScreen (-viewPositionX, -viewPositionY, {x, y})
            selectComponentAt (unpack (tablePosition))
            if (selection.item) then
                --gui.setCursor ("icons/transform-move.png")
                if (selection.canMove) then
                    gui.status ("Moving " .. selection.item.type)
                else
                    showSelectionStatus()
                end
            else
                gui.setCursor()
            end
        elseif (tool.vertices) then
        -- Place polygon
            createUndoPoint()
            placeVertices()
            useSelectTool()
        elseif (tool.r) then
        -- Place Circle
            createUndoPoint()
            placeCircle()
            useSelectTool()
        elseif (tool.type == "ball") then
        -- Place ball
            createUndoPoint()
            local tablePosition = toScreen (-viewPositionX, -viewPositionY, {getMouse ()})
            tableDef.ball.x = tablePosition[1]
            tableDef.ball.y = tablePosition[2]
            useSelectTool()
            gui.status("Placed the ball start position")
        end
    end

end

function love.mousereleased(x, y, button)
    if (states.current ~= states.editor) then return end
    loveframes.mousereleased(x, y, "l")
    if (disableEditor) then return end
    if (selection.item and selection.canMove) then
        createUndoPoint ()
        tableDef.components[selection.idx] = selection.item
        selection.item = nil
        selection.canMove = false
        gui.setCursor()
    end
end

function isCtrl()
    return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end

function isShift()
    return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

function isAlt()
    return love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")
end

function love.keypressed(key, unicode)

    if (states.current ~= states.editor) then return end
    loveframes.keypressed(key, unicode)
    if (disableEditor) then return end

    local scaleRatio = 0.1
    local moveAmt = 5
    if isAlt() then scaleRatio = 0.01; moveAmt = 1; end

    if isCtrl() then
        -- Clone selection
        if (key == "c") then cloneObject(); return; end
        -- Undo and Redo
        if (key == "z") then undo(); return; end
        if (key == "y") then redo(); return; end
        -- Save and Load
        if (key == "s") then saveToFile(); return; end
        if (key == "l") then loadFromFile(); return; end
        if (key == "up") then scaleObject(scaleRatio, scaleRatio) end
        if (key == "down") then scaleObject(-scaleRatio, -scaleRatio) end
        if (key == "h") then flipSelection(true, false) end
        if (key == "v") then flipSelection(false, true) end
        if (key == "e") then exportBitmap() end
        return
    end

    if isShift() then
        if (key == "up") then scaleObject(0, scaleRatio) end
        if (key == "down") then scaleObject(0, -scaleRatio) end
        if (key == "left") then scaleObject(-scaleRatio, 0) end
        if (key == "right") then scaleObject(scaleRatio, 0) end
        return
    end

    -- arrow keys moves the current selection.
    -- hold left-shift to move in small steps.
    if (selection.item) then
        if (key == "left") then
            selection.item.x = selection.item.x - moveAmt
        elseif (key == "right") then
            selection.item.x = selection.item.x + moveAmt
        elseif (key == "up") then
            selection.item.y = selection.item.y - moveAmt
        elseif (key == "down") then
            selection.item.y = selection.item.y + moveAmt
        end
    end

    if (key == "space") then useSelectTool() end
    if (key == "kpenter"or key == "return") then applySelection() end
    if (key == "delete") then deleteSelected() end
    if (key == "f1") then gui.showHelp() end

end

function love.keyreleased(key)
    if (states.current ~= states.editor) then return end
    loveframes.keyreleased(key)
end

function love.textinput(text)
    if (states.current ~= states.editor) then return end
    loveframes.textinput(text)
end

-----------------------------------------------------------


-- UI

-- This tool places a polygon shape. The tool type determines where
-- it gets stored in the pinball table definition.
function usePolyTool(button)
    tool = button.data
    --gui.setCursor(button.data.icon)
    gui.setTool(tool.text .. " Tool")
end

function usePlaceBallTool()
    tool = { type="ball" }
    gui.setTool("Place Ball")
end

function useSelectTool()
    tool = { type="select" }
    gui.setTool("Select Tool")
    gui.setCursor()
end

function unselect()
    selection.item = nil
    gui.setCursor()
    showSelectionStatus()
    gui.setComponentCyclerItems()
end

function deleteSelected()
    if (selection.item) then
        createUndoPoint()
        table.remove (tableDef.components, selection.idx)
        gui.status ("Deleted a " .. selection.item.type)
        unselect ()
    end
end

function moveSelectedComponent()
    if (selection.item and selection.canMove and love.mouse.isDown(1)) then
        local x, y = getMouse ()
        x = x + selection.xOffset
        y = y + selection.yOffset
        local mxy = toScreen (-viewPositionX, -viewPositionY, {x, y})
        selection.item.x, selection.item.y = mxy[1], mxy[2]
    end
end

function createGuidelineBackground()
    backgroundImage = love.graphics.newCanvas()
    backgroundImage:renderTo(function()
        love.graphics.clear({89/256, 157/256, 220/256, 1})
        local gridSize = 10
        local width, height = love.graphics.getDimensions()
        love.graphics.setColor(106/256, 165/256, 220/256)
        love.graphics.setLineWidth(1)
        --love.graphics.setLineStyle("rough")
        for h = 0, height, gridSize do
            love.graphics.line(0, h, width, h)
            for w = 0, width, gridSize do
                love.graphics.line(w, 0, w, height)
            end
        end
    end)
end

function drawTool()
    love.graphics.setLineWidth (2)
    love.graphics.setColor (1, 1, 1, 1)
    if (tool.vertices) then
        local vertii = toMouse (tool.vertices)
        love.graphics.line(vertii)
    elseif (tool.type == "ball" or tool.type == "bumper") then
        local mx, my = getMouse ()
        love.graphics.circle ("line", mx, my, tableDef.ball.r)
    end
end

function drawSelectedComponent()
    if (selection.item) then
        love.graphics.setColor (0, 0, 0)
        love.graphics.setLineWidth (1)
        if (selection.item.vertices) then
            -- polygon shape
            local worldVertices = toScreen (selection.item.x, selection.item.y, selection.item.vertices)
            -- bounding box (offset so it's centered around the poly shape)
            love.graphics.rectangle ("line",
                selection.item.x-selection.item.w/2, selection.item.y-selection.item.h/2,
                selection.item.w, selection.item.h)
            love.graphics.line (worldVertices)
            love.graphics.setColor (1, 1, 1, 0.25)
            love.graphics.line(worldVertices)
            local worldVertices = toScreen (selection.original.x, selection.original.y, selection.original.vertices)
            love.graphics.line(worldVertices)
        elseif (selection.item.r) then
            love.graphics.circle("line", selection.item.x, selection.item.y, selection.item.r)
            love.graphics.setColor (1, 1, 1, 0.25)
            love.graphics.circle("fill", selection.item.x, selection.item.y, selection.item.r)
            love.graphics.circle("fill", selection.original.x, selection.original.y, selection.original.r)
        elseif (selection.item.x and selection.item.w) then
            -- rectangle shape
            -- rectangles draw centered around their middle point
            local rx = selection.item.x - (selection.item.w/2)
            local ry = selection.item.y - (selection.item.h/2)
            love.graphics.rectangle ("line",
                rx, ry,
                selection.item.w, selection.item.h)
            love.graphics.setColor (1, 1, 1, 0.25)
            love.graphics.rectangle ("fill",
                rx, ry,
                selection.item.w, selection.item.h)
            -- rectangles draw centered around their middle point
            local rx = selection.original.x - (selection.original.w/2)
            local ry = selection.original.y - (selection.original.h/2)
            love.graphics.rectangle ("fill",
                rx, ry,
                selection.original.w, selection.original.h)
        end
    end
end

function drawPinballComponents()

    love.graphics.setLineStyle("rough")
    love.graphics.setColor(1, 1, 1, 1)
    
    for _, component in pairs(tableDef.components) do

        -- WALLS
        if (component.type == "wall") then
            love.graphics.setLineWidth (6)
            love.graphics.setColor(1, 1, 1)
            --love.graphics.polygon("line", toScreen (component.x, component.y, component.vertices))
            love.graphics.line(toScreen (component.x, component.y, component.vertices))
        end

        -- BUMPERS
        if (component.type == "bumper") then
            love.graphics.setLineWidth (2)
            love.graphics.setColor(161/256, 42/256, 42/256)
            love.graphics.circle("fill", component.x, component.y, component.r)
        end

        -- KICKERS
        if (component.type == "kicker") then
            love.graphics.setLineWidth (1)
            love.graphics.setColor(0.75, 0.75, 0)
            love.graphics.polygon("fill", toScreen (component.x, component.y, component.vertices))
        end

        -- TRIGGERS
        if (component.type == "trigger") then
            love.graphics.setLineWidth (1)
            love.graphics.setColor(0, 0.5, 0)
            love.graphics.polygon("fill", toScreen (component.x, component.y, component.vertices))
        end

        -- INDICATORS
        if (component.type == "indicator") then
            love.graphics.setLineWidth (1)
            love.graphics.setColor(0, 0.5, 0.5)
            love.graphics.polygon("fill", toScreen (component.x, component.y, component.vertices))
        end

        -- GATES
        if (component.type == "gate") then
            love.graphics.setLineWidth (1)
            love.graphics.setColor(0, 0, 0.5)
            love.graphics.polygon("fill", toScreen (component.x, component.y, component.vertices))
        end

        -- FLIPPERS
        if (component.type == "flipper") then
            love.graphics.setLineWidth (4)
            love.graphics.setColor(108/256, 113/256, 196/256)
            love.graphics.polygon("fill", toScreen (component.x, component.y, component.vertices))
        end

    end

    -- BALL
    love.graphics.setLineWidth (1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", tableDef.ball.x, tableDef.ball.y, tableDef.ball.r)

end

function toGrid(v)
    local gridSize = 10
    return math.floor(v/gridSize) * gridSize
end

-- Get the mouse coordinates snapped to a grid
function getMouse()
    local x, y = love.mouse.getPosition()
    if (not love.keyboard.isDown("lctrl")) then
        x = toGrid (x)
        y = toGrid (y)
    end
    return x, y
end

-- translate points relative to the mouse coordinates
function toMouse(vertices)
    local x, y = getMouse ()
    local mx = { }
    for i = 1, #vertices - 1, 2 do
        table.insert(mx, vertices[i] + x)
        table.insert(mx, vertices[i+1] + y)
    end
    return mx
end

-- translate relative vertice positions to screen coordinates
function toScreen(x, y, vertices)
    local mx = { }
    for i = 1, #vertices - 1, 2 do
        table.insert(mx, vertices[i] + x)
        table.insert(mx, vertices[i+1] + y)
    end
    return mx
end

function registerTools()

    local tools = {
        {
        category="Tools",
        type="select",
        text="Select Tool",
        icon="icons/input-mouse.png",
        guiAction=useSelectTool,
        };
        {
        category="Tools",
        type="ball",
        text="Place the start position of the ball.",
        icon="icons/ball.png",
        guiAction=usePlaceBallTool,
        };
        {
        category="Tools",
        type="flipper",
        text="Left Flipper",
        icon="icons/flipper-left-large.png",
        orientation="left",
        guiAction=usePolyTool,
        vertices={60,8, 60,-8, -60,-16, -60,16},
        pivot={x=-60, y=0}
        };
        {
        category="Tools",
        type="flipper",
        text="Right Flipper",
        icon="icons/flipper-right-large.png",
        orientation="right",
        guiAction=usePolyTool,
        vertices={60,16, 60,-16, -60,-8, -60,8},
        pivot={x=60, y=0}
        };
        {
        category="Tools",
        type="indicator",
        text="Indicator",
        icon="icons/triangle.png",
        guiAction=usePolyTool,
        vertices={20, 17, -21, 17, -1, -18, 20, 17},
        }
    }

    -- Kicker Templates
    table.insert (tools, {
    category="Kickers and Bumpers",
    type="kicker",
    text="Kicker (90 deg)",
    icon="icons/kicker90.png",
    guiAction=usePolyTool,
    vertices={ 30, 30, -30, -30, -30, 30, 30, 30 }
    })

    table.insert (tools, {
    category="Kickers and Bumpers",
    type="kicker",
    text="Kicker (30 deg)",
    icon="icons/kicker30.png",
    guiAction=usePolyTool,
    vertices={ 10, 20, -10, -24, -10, 8, 10, 20 }
    })

    table.insert (tools, {
    category="Kickers and Bumpers",
    type="bumper",
    text="Bumper",
    icon="icons/bumper.png",
    guiAction=usePolyTool,
    r=20
    })

    table.insert (tools, {
    category="Kickers and Bumpers",
    type="kicker",
    text="Kicker (30 deg)",
    icon="icons/slope30.png",
    guiAction=usePolyTool,
    vertices={ -27, 15, 0, 0, 26, -16 }
    })

    table.insert (tools, {
    category="Kickers and Bumpers",
    type="kicker",
    text="Kicker (60 deg)",
    icon="icons/slope60.png",
    guiAction=usePolyTool,
    vertices={ -50, -86, 0, 0, 50, 87 }
    })

    table.insert (tools, {
    category="Triggers",
    type="trigger",
    gameAction="slingshot",
    text="Slingshot",
    icon="icons/slingshot.png",
    guiAction=usePolyTool,
    vertices={ -10, -40, 0, -50, 10, -40, 10, 40, 0, 30, -10, 40, -10, -40 }
    })

    table.insert (tools, {
    category="Triggers",
    type="trigger",
    gameAction="none",
    text="Trigger Plate",
    icon="icons/octagon.png",
    guiAction=usePolyTool,
    vertices={ 26, -25, 0, -35, -25, -25, -35, 1, -25, 26, 0, 36, 26, 26, 36, 1, 26, -25 }
    })

    table.insert (tools, {
    category="Triggers",
    type="gate",
    gameAction="left",
    text="Left only Gate",
    icon="icons/gate-left.png",
    guiAction=usePolyTool,
    vertices={ -25, -25, 50, -25, 50, 50, -25, 50, -25, -25 }
    })

    table.insert (tools, {
    category="Triggers",
    type="gate",
    gameAction="right",
    text="Right only Gate",
    icon="icons/gate-right.png",
    guiAction=usePolyTool,
    vertices={ -25, -25, 50, -25, 50, 50, -25, 50, -25, -25 }
    })

    -- Wall Templates
    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Vertical Wall",
    icon="icons/vertical-wall.png",
    guiAction=usePolyTool,
    vertices={ 0, -100, 0, 100 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Horizontal Wall",
    icon="icons/horizontal-wall.png",
    guiAction=usePolyTool,
    vertices={ -100, 0, 100, 0 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Round Hat",
    icon="icons/round-hat.png",
    guiAction=usePolyTool,
    vertices={ -310, 102, -310, -4, -310, -30, -308, -51, -300,
    -68, -290, -81, -276, -91, -259, -97, -217, -102, 216,
    -102, 262, -97, 279, -90, 292, -80, 302, -67, 308, -50,
    310, -4, 310, 102 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Angle Hat",
    icon="icons/angle-hat.png",
    guiAction=usePolyTool,
    vertices={ -310, 102, -310, -4, -217, -102, 216, -102, 310, -4, 310, 102 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Angle 90 deg",
    icon="icons/angle90.png",
    guiAction=usePolyTool,
    vertices={ -60, -60, -60, 60, 60, 60 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Angle 45 deg",
    icon="icons/angle45.png",
    guiAction=usePolyTool,
    vertices={ -88, 44, 0, -44, 88, 44 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Hooked Slope (30 deg)",
    icon="icons/hookedslope30.png",
    guiAction=usePolyTool,
    vertices={ -30, -20, -30, -10, 26, 23 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Slope (30 deg)",
    icon="icons/slope30.png",
    guiAction=usePolyTool,
    vertices={ -27, 15, 26, -16 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Slope (60 deg)",
    icon="icons/slope60.png",
    guiAction=usePolyTool,
    vertices={ -50, -86, 50, 87 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Half Moon",
    icon="icons/halfmoon.png",
    guiAction=usePolyTool,
    vertices={ 83.916, 42.342, 82.212, 25.428, 77.322, 9.672, 69.582,
    -4.584, 59.334, -17.01, 46.908, -27.258, 32.652, -34.998, 16.896,
    -39.888, -0.018, -41.592, -16.932, -39.888, -32.688, -34.998,
    -46.944, -27.258, -59.364, -17.01, -69.612, -4.584, -77.352, 9.672,
    -82.242, 25.428, -83.946, 42.342 }
    })

    table.insert (tools, {
    category="Walls",
    type="wall",
    text="Quarter Moon",
    icon="icons/quartermoon.png",
    guiAction=usePolyTool,
    vertices={ 40, 40, 40, 32, 39, 24, 37, 17, 34, 9, 31, 2, 27, -4,
    22, -10, 17, -16, 11, -21, 5, -26, -1, -30, -8, -33, -16, -36, -23,
    -38, -31, -39, -40, -40 }
    })

    gui.createToolbox (tools)

end

function setComponentTag(tag)
    if (selection.item) then
        createUndoPoint()
        selection.item.tag = tag
        gui.status("Set component tag to " .. tag)
    end
end

function setComponentCooldown(cooldown)
    if (selection.item) then
        createUndoPoint()
        selection.item.cooldown = cooldown
        gui.status("Set component cooldown to " .. cooldown)
    end
end

function increase(p)
    local s = ""
    for i, v in pairs(p) do
        p[i] = math.floor(v + (v * 10))
        s = s .. p[i] .. ", "
    end
    print(s)
end

-----------------------------------------------------------

-- TABLE DEFINITION


function applySelection()
    if (selection.item) then
        createUndoPoint()
        tableDef.components[selection.idx] = deepcopy(selection.item)
        unselect()
    end
end

function cloneObject()
    if (selection.item) then
        local newIdx = #tableDef.components+1
        tableDef.components[newIdx] = deepcopy(selection.item)
        selection.item = tableDef.components[newIdx]
        selection.idx = newIdx
        gui.status("Cloned " .. selection.item.type)
    end
end

function scaleObject(xratio, yratio)
    if (selection.item and selection.item.vertices) then
        selection.item.w = selection.item.w + (selection.item.w * xratio)
        selection.item.h = selection.item.h + (selection.item.h * yratio)
        for i = 1, #selection.item.vertices - 1, 2 do
            local v = selection.item.vertices[i]
            selection.item.vertices[i] = v + (v * xratio)
            local v = selection.item.vertices[i+1]
            selection.item.vertices[i+1] = v + (v * yratio)
        end
        -- scale the pivot point if there is one
        if selection.item.pivot then
            selection.item.pivot.x = selection.item.pivot.x + (selection.item.pivot.x * xratio)
            selection.item.pivot.y = selection.item.pivot.y + (selection.item.pivot.y * yratio)
        end
    elseif (selection.item and selection.item.r) then
        selection.item.r = selection.item.r + (selection.item.r * xratio)
    end
end

function flipSelection(horizontal, vertical)
    if (selection.item and selection.item.vertices) then
        local vertices = selection.item.vertices
        local flipped = { }
        for i = 1, #vertices - 1, 2 do
            flipped[i] = vertices[i]        -- x
            flipped[i+1] = vertices[i+1]    -- y
            if (horizontal) then flipped[i] = -vertices[i] end
            if (vertical) then flipped[i+1] = -vertices[i+1] end
        end
        selection.item.vertices = flipped
        selection.item.w, selection.item.h = getPolySize(flipped)
    end
end

function selectComponentAt(x, y)

    gui.readComponentTag ("")
    gui.readComponentCooldown("")
    local hitComponents = { }
    local prevIdx = selection.item and selection.idx or 0

    local apply = function (i, c)
        selection.item = deepcopy(c)
        selection.canMove = i == prevIdx
        selection.idx = i
        selection.xOffset = c.x - toGrid(x)
        selection.yOffset = c.y - toGrid(y)
        if (prevIdx ~= i) then
            selection.original = deepcopy(c)
        end
    end

    -- for i, component in ipairs(tableDef.components) do
    for i = #tableDef.components, 1, -1 do
        local component = tableDef.components[i]
        if (component.vertices and component.w) then
            -- bounding box (offset so it's centered around the poly shape)
            local cx = component.x-component.w/2
            local cy = component.y-component.h/2
            if (x > cx and x < cx + component.w) and
                (y > cy and y < cy + component.h) then
                --apply(i, component)
                --return
                table.insert(hitComponents, {idx=i, component=component})
            end
        elseif (component.w and component.h) then
            -- rectangle shapes
            -- rectangles draw centered around their middle point
            local rx = component.x - (component.w/2)
            local ry = component.y - (component.h/2)
            if (x > rx and x < rx + component.w) and
                (y > ry and y < ry + component.h) then
                --apply(i, component)
                --return
                table.insert(hitComponents, {idx=i, component=component})
            end
        elseif (component.r) then
            -- circle shapes (radius)
            local dist = math.sqrt((component.x - x) ^ 2 + (component.y - y) ^ 2)
            if (dist <= component.r) then
                --apply(i, component)
                --return
                table.insert(hitComponents, {idx=i, component=component})
            end
        end
    end

    if (#hitComponents == 0) then
        selection.item = nil
        gui.setComponentCyclerItems ()
    else
        apply(hitComponents[1].idx, hitComponents[1].component)
        -- build list for the component cycler
        local items = { }
        for _, c in pairs(hitComponents) do
            table.insert(items, {idx=c.idx, text=c.component.type})
        end
        gui.setComponentCyclerItems (items, selectComponentByIdx)
    end
end

function selectComponentByIdx(button)
    local i = button.data
    local c = tableDef.components[i]
    selection.item = deepcopy(c)
    selection.canMove = i == prevIdx
    selection.idx = i
    selection.xOffset = 0
    selection.yOffset = 0
    selection.original = deepcopy(c)
    showSelectionStatus()
end

function showSelectionStatus()
    if (selection.item) then
        local sizeText = selection.item.w and " (" .. math.floor(selection.item.w) .. "x" .. math.floor(selection.item.h) .. ")" or ""
        local posText = " x:" .. selection.item.x .. " y:" .. selection.item.y
        gui.status ("Selected " .. selection.item.type .. sizeText .. posText)
        gui.readComponentTag(selection.item.tag and selection.item.tag or "")
        gui.readComponentCooldown(selection.item.cooldown and selection.item.cooldown or "")
    else
        gui.readComponentTag("")
        gui.readComponentCooldown("")
    end
end

-- gets the bounding box size of a poly
function getPolySize(vertices)
    local minx, maxx, miny, maxy = vertices[1], vertices[1], vertices[2], vertices[2]
    for i = 1, #vertices - 1, 2 do
        minx = math.min(minx, vertices[i])
        maxx = math.max(maxx, vertices[i])
        miny = math.min(miny, vertices[i+1])
        maxy = math.max(maxy, vertices[i+1])
    end
    -- Ensure at least n size so the object can be clicked
    return math.max(10, maxx-minx), math.max(10, maxy-miny)
end

function placeVertices()
    local mousey = toScreen (-viewPositionX, -viewPositionY, {getMouse()})
    local polyW, polyH = getPolySize (tool.vertices)
    table.insert(tableDef.components, {
        type=tool.type,
        x=mousey[1],
        y=mousey[2],
        w=polyW,
        h=polyH,
        orientation=tool.orientation,
        vertices=tool.vertices,
        pivot=tool.pivot,
        action=tool.gameAction
        })
    gui.status ("Placed a " .. tool.text)
end

function placeCircle()
    local mousey = toScreen (-viewPositionX, -viewPositionY, {getMouse()})
    if (tool.type == "bumper") then
        table.insert(tableDef.components, {
            type=tool.type,
            x=mousey[1],
            y=mousey[2],
            w=tool.r*2,
            h=tool.r*2,
            r=tool.r
            })
    end
    gui.status ("Placed a " .. tool.text)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function createUndoPoint()

    hasUnsavedChanges = true
    
    -- Destroy obsolete
    for i = history.idx, #history.data do
        history.data[i] = nil
    end

    -- Capture new
    history.idx = #history.data + 1
    history.data[history.idx] = deepcopy(tableDef)
    -- Forward pointer to indicate the current state
    history.idx = history.idx + 1

    -- Cull to a sensible limit
    while (#history.data > undoLimit) do
        table.remove (history.data, 1)
        history.idx = history.idx - 1
    end

end

function undo()
    -- create a restore point to be able to return to the current state
    unselect()
    if (history.idx > #history.data) then
        createUndoPoint()
        history.idx = history.idx - 1
    end
    if (history.idx > 1) then
        history.idx = history.idx - 1
        tableDef = history.data[history.idx]
    end
end

function redo()
    unselect()
    if (history.idx < #history.data) then
        history.idx = history.idx + 1
        tableDef = history.data[history.idx]
    end
end

function clearTableDefinition()
    tableDef = {
        height = 1000,
        width = 650,
        ball = { x=625, y=890, r=15 },
        components = { }
        }
    history = { data={}, idx=0 }
end

function calculateTableSize()
    local minx, maxx, miny, maxy = 1000, -1000, 1000, -1000
    for _, v in pairs(tableDef.components) do
        if (v.vertices) then
            local vertices = toScreen (v.x, v.y, v.vertices)
            for i = 1, #vertices - 1, 2 do
                local x = vertices[i]
                local y = vertices[i+1]
                minx = math.min(minx, x)
                miny = math.min(miny, y)
                maxx = math.max(maxx, x)
                maxy = math.max(maxy, y)
            end
        end
    end

    local width, height = math.ceil(maxx-minx), math.ceil(maxy-miny)
    
    -- adjust for negative values
    if (miny < 0) then
        height = math.ceil(maxy + math.abs(miny))
    end
    if (minx < 0) then
        width = math.ceil(maxx + math.abs(minx))
    end

    return {x1=minx, y1=miny, x2=maxx, y2=maxy, width=width, height=height}
end

-----------------------------------------------------------

-- FILE OPERATIONS

function checkSaveDirectory()
    local exists = love.filesystem.exists(saveDirectory)
    if (not exists) then
        love.filesystem.createDirectory(saveDirectory)
    end
end

function exportBitmap()
    if (not currentFilename) then return end
    local size = calculateTableSize()
    local canvas = love.graphics.newCanvas(size.width+40, size.height)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(1, 1, 1, 1)
    local border = 20
    love.graphics.translate(-math.abs(size.x1)+border, math.abs(size.y1)+border)
    drawPinballComponents()
    love.graphics.origin()
    love.graphics.setCanvas()
    local data = canvas:getImageData()
    data:encode(currentFilename .. ".png")
    gui.status("Bitmap saved as " .. currentFilename .. ".png")
end

function saveToFile()

    tableDef.identifier = "nova pinball table layout"
    tableDef.version = VERSION
    tableDef.size = calculateTableSize()

    -- nillify empty tags
    for _, c in pairs(tableDef.components) do
        if (c.tag == "") then c.tag = nil end
    end
    
    local saveCallback = function(filename)
        local pickle = require("pickle")
        local mydata = pickle.pickle(tableDef)
        love.filesystem.write(filename, mydata, nil)
        local sizeText = " (" .. tableDef.size.width .. " x " .. tableDef.size.height .. ")"
        gui.status("Saved " .. filename .. sizeText)
        hasUnsavedChanges = false
    end

    if (currentFilename) then
        saveCallback(currentFilename)
        return
    end

    -- Show file dialog for unnamed files
    unselect()
    disableEditor = true
    local saveCallbackDlg = function(filename)
        disableEditor = false
        if (not filename) then return end
        saveCallback(filename)
    end
    -- Display the file chooser
    gui.fileDialog ("Save", saveDirectory, saveCallbackDlg, false)
    
end

function loadFromFile()
    unselect()
    disableEditor = true
    local loadCallback = function(filename)
        disableEditor = false
        if (not filename) then return end
        is_file = love.filesystem.isFile(filename)
        if (is_file) then
            currentFilename = filename
            clearTableDefinition()
            local mydata, size = love.filesystem.read(filename, nil)
            local pickle = require("pickle")
            local derez = pickle.unpickle(mydata)
            
            if (type(derez) == "table" and derez.identifier == "nova pinball table layout") then
                tableDef = derez
                gui.hideMain()
                gui.status("Loaded " .. filename)
                hasUnsavedChanges = false
            else
                gui.status("Not a valid pinball layout file")
            end
        else
            gui.status(filename .. " not a valid file")
        end
    end
    -- Display the file chooser
    gui.fileDialog ("Load", saveDirectory, loadCallback, hasUnsavedChanges)
end

--- Copy the example table to the save directory if empty
function copyExampleTable()

    local tablePath = "tables"
    if not love.filesystem.exists(tablePath) then
        local contents, size = love.filesystem.read("example.pinball")
        local filename = tablePath.."/example.pinball"
        love.filesystem.createDirectory(tablePath)
        love.filesystem.write(filename, contents, size)
        print("created example table: "..filename)
    end

end
