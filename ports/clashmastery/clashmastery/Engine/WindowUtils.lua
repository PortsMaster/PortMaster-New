local previousWidth, previousHeight = windowWidth, windowHeight
function resizeWindow(width, height, forceResize)
    if windowWidth ~= width or windowHeight ~= height or forceResize then
        love.window.setMode(width, height)
        recomputeWindowParameters(width, height)
        refreshShaders()
    end
end

function recomputeWindowParameters(width, height)
    windowWidth = width;
    windowHeight = height;
    local scaleX, scaleY, uiScaleX, uiScaleY
    if resizeMode == "stretch" then
        scaleX = windowWidth / renderResolution.width
        scaleY = windowHeight / renderResolution.height
        uiScaleX = windowWidth / gameResolution.width
        uiScaleY = windowHeight / gameResolution.height
    else
        scaleX = math.floor(windowWidth / renderResolution.width)
        scaleY = math.floor(windowHeight / renderResolution.height)
        uiScaleX = math.floor(windowWidth / gameResolution.width)
        uiScaleY = math.floor(windowHeight / gameResolution.height)
    end
    windowCanvasScale = math.min(scaleX, scaleY)
    uiScale = math.min(uiScaleX, uiScaleY)
end

function offsetBasedOnResolution()
    love.graphics.translate((windowWidth - renderResolution.width * windowCanvasScale) * 0.5, (windowHeight - renderResolution.height * windowCanvasScale) * 0.5)
end

function offsetUIBasedOnResolution()
    love.graphics.translate((windowWidth - gameResolution.width * uiScale) * 0.5, (windowHeight - gameResolution.height * uiScale) * 0.5)
end

function getOffsetBasedOnResolution()
    return (windowWidth - gameResolution.width * uiScale) * 0.5, (windowHeight - gameResolution.height * uiScale) * 0.5
end

function getGameOffsetBasedOnResolution()
    return (windowWidth - gameResolution.width * windowCanvasScale) * 0.5, (windowHeight - gameResolution.height * windowCanvasScale) * 0.5
end

function setFullscreen(onOrOff, type)
    previousWidth, previousHeight = windowWidth, windowHeight
    if onOrOff then
        if type == "exclusive" then
            -- When using exclusive mode, we need to set the resolution manually to the monitor's size.
            love.window.setMode(0, 0)
            recomputeWindowParameters(love.graphics.getWidth(), love.graphics.getHeight())
        end
        love.window.setFullscreen(true, type or "desktop")
        refreshShaders()
    else
        love.window.setFullscreen(false, type or "desktop")
        recomputeWindowParameters(previousWidth, previousHeight)
    end
end

function getMouseCanvasPosition()
    local x, y = love.mouse.getPosition()
    local offsetX, offsetY = getOffsetBasedOnResolution()
    -- translate to the canvas
    x = x - offsetX
    y = y - offsetY
    -- scale to the canvas
    x = math.floor(x / uiScale)
    y = math.floor(y / uiScale)
    return x, y
end

function getMouseGamePosition()
    local x, y = love.mouse.getPosition()
    local offsetX, offsetY = getOffsetBasedOnResolution()
    -- translate to the canvas
    x = x - offsetX
    y = y - offsetY
    -- scale to the canvas
    x = math.floor(x / (windowCanvasScale))
    y = math.floor(y / (windowCanvasScale))
    print(x, y)
    return x, y
end

-- Recompile all shaders when the window size changes to avoid a sporadic access violation when the window size changes.
function refreshShaders()
    Mesh.initializePropsPreload()
    Lighting3D.defaultShader = love.graphics.newShader('Engine/solidColor.frag', 'Engine/mesh.vert')
    Lighting3D.sendShader(Mesh.defaultShader, true)
    Lighting3D.sendShader(Mesh.defaultGLTFShader, true)
end