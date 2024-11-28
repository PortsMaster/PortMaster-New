-- All parameters like screen size and pixels found in conf.lua
Input = require("Engine.Input")
Physics = require("Engine.Physics")
Collision = require("Engine.Collision")
GameObjects = require("Engine.GameObjects")
GameObjects3D = require("Engine.GameObjects3D")
Texture = require("Engine.Texture")
Matrix = require("Engine.Matrix")
GLTFModel = require("Engine.GLTFModel")
Mesh = require("Engine.Mesh")
Animation = require("Engine.Animation")
ParticleSystem = require("Engine.ParticleSystem")
ParticleSystem3D = require("Engine.ParticleSystem3D")
Camera = require("Engine.Camera")
Camera3D = require("Engine.Camera3D")
SoundManager = require("Engine.SoundManager")
MusicManager = require("Engine.MusicManager")
PauseMenu = require("Engine.PauseMenu")
DialogueSystem = require("Engine.DialogueSystem")
SaveLoad = require("Engine.SaveLoad")
Lighting = require("Engine.Lighting")
Lighting3D = require("Engine.Lighting3D")
EventSystem = require("Engine.EventSystem")
LoadingScreen = require ("Engine.LoadingScreen")
require("Engine.VisualEffects")
require("Engine.UIElements")
require("Engine.WindowUtils")
require("Engine.MathUtils")
require("Engine.Pool")
require("Engine.GameUtils")
require("src.Levels")
require("src.MainConfig")
profile = require("ThirdParty.profile.profile")
prof = require("ThirdParty.jprof.jprof")
tick = require("ThirdParty.tick.tick")
ProFi = require("ThirdParty.ProFi.ProFi")

-- Enable debugging in VSCode via launch.json
-- the last argument in launch.json is "vsc_debug" to allow debugging
if arg[#arg] == "vsc_debug" then
    require("lldebugger").start()
    print("Debugger starting")
end
-- initialize the randomness
math.randomseed(os.time())
math.random()

-- Global gamestate passed to level scripts
gameState = {
    loadLevel = true,
    levelIndex = 1,
    goToNextLevel =
    function()
        gameState.levelIndex = gameState.levelIndex + 1
        gameState.loadLevel = true
    end,
    paused = false,
    timeScale = 1,
    -- defined by MainConfig.lua
    state = startingState
}
-- Defined by MainConfig.lua
levelOrder = mainLevelOrder


-- Boilerplate required for coroutine error reporting
-- https://love2d.org/wiki/coroutine.resume
-- side note: this is sick
_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		error( tostring(result), 2 )	-- Output error message
	end
	return state,result
end

gameCanvasTableInfo = nil
function love.load()
    tick.framerate = 60
    tick.rate = 1/tick.framerate
    -- Set these to get pixel art style
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setDepthMode("lequal", true)
    gameCanvas = love.graphics.newCanvas(gameResolution.width, gameResolution.height) -- our game canvas can be low resolution and still have a smooth camera if we watch that one seanjs video
    uiCanvas = love.graphics.newCanvas(gameResolution.width, gameResolution.height) -- for all post-camera operations
    fxCanvas = love.graphics.newCanvas(renderResolution.width, renderResolution.height) -- an intermediary canvas to draw our game to so we can use shaders at a low resolution
    picoFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 4)
    defaultFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 4)
    smallerMonogram = love.graphics.newFont("Fonts/monogram.ttf", 64)
    fontYOffset = 0
    love.graphics.setFont(defaultFont)
    gameCanvasTableInfo = {gameCanvas, depth=true}

    -- Initialize subsystems
    Input.initialize({
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "left","right","up","down","space","1","2","3","4","5","6","7","8","9","escape","return",
        "tab","lshift","rshift","lctrl","rctrl"
    }, {
        "a","x","b","y","dpright","dpleft","dpup","dpdown","leftshoulder","rightshoulder","start","back","leftstick","rightstick"
    })
    -- mainDefaultControls defined by MainConfig.lua
    Input.map(mainDefaultControls, true)
    Physics.initialize()
    Collision.initialize()
    GameObjects.initialize()
    GameObjects3D.initialize()
    Animation.initialize()
    GLTFModel.initialize()
    -- mainTextures defined by MainConfig.lua
    Texture.initialize(mainTextures)
    -- mainModels defined by MainConfig.lua
    Matrix.initialize()
    if not useLoadingScreen then
        Mesh.initialize(mainMeshes)
        SoundManager.initialize("Sounds",".wav")
        -- mainMusics defined by MainConfig.lua
        MusicManager.initialize("Music", mainMusics, ".ogg")
    else -- defer loading to the loading music, sound, and meshes to the loading screen
        Mesh.initializePropsPreload()
        SoundManager.initializePropsPreload()
        MusicManager.initializePropsPreload()
    end
    ParticleSystem.initialize()
    ParticleSystem3D.initialize()
    Camera.initialize()
    Camera3D.initialize()
    Lighting3D.initialize()
    EventSystem.initialize()
    -- SaveLoad.loadPreferences()
    -- SaveLoad.loadGameData()
    PauseMenu.initialize()
    if profileOn then
        profile.start()
        profileTime = 0
        print("profiler is on")
    end
    if manualGC then
        collectgarbage("stop")
    end

    love.window.setTitle(windowTitle)
    if not web then
        setFullscreen(true, "desktop")
    end
    recomputeWindowParameters(windowWidth, windowHeight)
end

function love.resize(width, height)
    recomputeWindowParameters(width, height)
end

function love.keypressed(key)
    Input.setButtonStatus(key, true)
    Input.lastKeyPressed = key
    Input.activelyUsingController = true
    hideMouse()
end

function love.keyreleased(key)
    Input.setButtonStatus(key, false)
    Input.activelyUsingController = true
end

function love.gamepadpressed(joystick, button)
    Input.setButtonStatus(Input.gamepadPrefix..button, true)
    Input.lastGamepadPressed = button
    Input.activelyUsingController = true
    hideMouse()
end

function love.gamepadreleased(joystick, button)
    Input.setButtonStatus(Input.gamepadPrefix..button, false)
    Input.activelyUsingController = true
end

function love.gamepadaxis(joystick, axis, value)
    Input.setAxisValue(axis, value)
end

function love.joystickadded(joystick)
    Input.numJoysticksConnected = Input.numJoysticksConnected + 1
    Input.controllerType = string.find(joystick:getName(), "PS4") and "PS4" or "XBOX"
    -- Reset the gamepad submenu just in case
    PauseMenu.gamepadControlsSubmenu = controlsSubMenu(PauseMenu, true)
end

function love.joystickremoved(joystick)
    Input.numJoysticksConnected = Input.numJoysticksConnected - 1
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        Input.setButtonStatus("mouse1", true)
        Input.lastKeyPressed = "mouse1"
    elseif button == 2 then
        Input.setButtonStatus("mouse2", true)
        Input.lastKeyPressed = "mouse2"
    end
end

function love.mousereleased(x, y, button, istouch)
    if button == 1 then 
        Input.setButtonStatus("mouse1", false)
    elseif button == 2 then
        Input.setButtonStatus("mouse2", false)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    Camera3D.FPSControls(dx, dy)
end

numDoubleUpdates = 0
numZeroUpdates = 0
appStartTime = os.time()
timeElapsed = 0
fps = 0
function love.update(dt) -- note: this will NOT run if 'usetick' is set to false. instead gameUpdate and physUpdate will be called by tick directly
    fps = 1/dt
    prof.push("frame")
    prof.push("update")
    gameUpdate(dt)
    physUpdate(dt)
    if profileOn then
        profileTime = profileTime + dt
        if profileTime > profileInterval then
            profileTime = 0
            print(profile.report(10))
            profile.reset()
        end
    end
    prof.pop("update")
end

function gameUpdate(dt)
    local trueDT = dt
    dt = dt * gameState.timeScale
    timeElapsed = timeElapsed + dt
    if gameState.loadLevel then
        reset()
        levelOrder[gameState.levelIndex](gameState)
        gameState.loadLevel = false
        PauseMenu.createMainMenu()
    else
        if gameState.paused then
            PauseMenu.update(dt)
            Input.updateButtons()
        else
            GameObjects.update(dt)
            GameObjects3D.update(dt)
            GameObjects.updateWithoutTime(dt, trueDT)
            Animation.update(dt)
            GLTFModel.updateAnimationsCached(dt)
            Camera.update(dt, trueDT)
            Camera3D.update(dt, trueDT)
            PauseMenu.update(dt)
            -- Make sure to call 'update buttons' AFTER you do all the input checking.
            Input.updateButtons()
            -- Physics has been moved to its own function
        end
    end
    if manualGCPerFrame then
        collectgarbage("collect")
    end
    if logGC then
        print(collectgarbage("count"))
    end
end

-- Physics update occurs in a separate loop to allow for taking multiple physics steps
-- per simulation
function physUpdate(dt)
    if not gameState.loadLevel and not gameState.paused then
        dt = dt * gameState.timeScale
        GameObjects.updateFixedRateCoroutines(dt)
        Collision.update()
        Physics.update(dt)
    end
end


function love.draw()
    prof.push("draw")
    -- Draw the game contents ----------------------------------------------
    -- love.graphics.setCanvas(gameCanvasTableInfo) -- uncomment this and comment out the next line for 3D with depth
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(global_pallete.secondary_color[1], global_pallete.secondary_color[2], global_pallete.secondary_color[3],1)

    love.graphics.push()
    Camera.preDraw()
    love.graphics.setColor(1, 1, 1, 1)
    GameObjects.draw()
    -- GameObjects3D.draw()

    -- Debug draw colliders
    -- Collision.debugDraw()
    Camera.postDraw()
    love.graphics.pop()
    ------------------------------------------------------------------------

    -- Draw shaders and canvas-space FX ------------------------------------
    love.graphics.setCanvas(fxCanvas)
    love.graphics.setColor(1, 1, 1, 1)
    -- Here's where you'd do your shader sending.
    -- TODO set up some pipeline for handling multiple shaders in a row
    -- Lighting.sendShader()
    -- if you want a high-res camera, you'd do camera pre/postdraw here instead of earlier
    -- Camera.preDraw()
    love.graphics.draw(gameCanvas, 0, 0, 0, renderResolution.width / gameResolution.width, renderResolution.height / gameResolution.height)
    -- Camera.postDraw()
    -- Lighting.clearShader()
    ------------------------------------------------------------------------

    -- Draw the final result to the window ---------------------------------
    love.graphics.setCanvas()
    love.graphics.push()
    offsetBasedOnResolution()
    -- https://love2d.org/wiki/love.graphics.setBlendMode
    -- "Premultiplied alpha should generally be used when drawing a canvas to the screen"
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(fxCanvas, 0, 0, 0, windowCanvasScale, windowCanvasScale)
    love.graphics.pop()
    ----------------------------------------------------------------------

    -- Draw all post-game content like UI and HUD --------------------------
    love.graphics.setCanvas(uiCanvas)
    love.graphics.setBlendMode('alpha') -- if you don't do this, text will look weird
    love.graphics.clear(0,0,0,0)
    GameObjects.drawPostCamera()
    -- Draw Pause Menu Elements scaled on the canvas
    if gameState.paused then
        PauseMenu.draw()
    end
    love.graphics.setCanvas()
    love.graphics.push()
    offsetUIBasedOnResolution()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(uiCanvas, 0, 0, 0, uiScale, uiScale)
    love.graphics.setBlendMode('alpha')
    love.graphics.pop()
    if showFPS then
        love.graphics.print(tostring(love.timer.getFPS()), 10, 10)
    end
    prof.pop("draw")
    prof.pop("frame")
end

function reset()
    gameState.timeScale = 1
    gameState.state.isCutscene = false
    PauseMenu.canPause = true
    timeElapsed = 0
    -- Set any globals that may have dangling gameobjects to nil to force them to be collected
    resetAllPools()
    collectgarbage("collect")
    love.graphics.setFont(defaultFont)
    Physics.initialize()
    Collision.initialize()
    GameObjects.initialize()
    GameObjects3D.initialize()
    Animation.initialize()
    GLTFModel.initialize()
    ParticleSystem.initialize()
    ParticleSystem3D.initialize()
    Matrix.initialize()
    Camera.initialize()
    Camera3D.initialize()
    EventSystem.initialize()
    resetPalette()
    Lighting3D.initialize()
    collectgarbage("collect")
end

function love.quit()
    SaveLoad.savePreferences()
    SaveLoad.saveGameData()
    writeFrameUpdateStatusFile()
    -- prof.write("prof.mpack")
end

frameUpdateStatuses = {}
function logFrameUpdateStatus(numUpdates)
    if debugMode then
        if not frameUpdateStatuses[numUpdates] then
            frameUpdateStatuses[numUpdates] = 0
        end
        frameUpdateStatuses[numUpdates] = frameUpdateStatuses[numUpdates] + 1
    end
end

function writeFrameUpdateStatusFile()
    if debugMode then
        local updateString = ""
        for k,v in pairs(frameUpdateStatuses) do
            local currString = "Number of frames with " .. tostring(k) .. " updates: " .. tostring(v) .. "\n"
            updateString = updateString .. currString
        end
        updateString = updateString .. "Total time elapsed: "..(os.time() - appStartTime) .. " seconds"
        love.filesystem.write("frameUpdateStatus"..os.time()..".txt", updateString)
    end
end
