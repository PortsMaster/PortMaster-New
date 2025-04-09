-- All parameters like screen size and pixels found in conf.lua
Input = require("Engine.Input")
Physics = require("Engine.Physics")
Collision = require("Engine.Collision")
GameObjects = require("Engine.GameObjects")
Texture = require("Engine.Texture")
Animation = require("Engine.Animation")
ParticleSystem = require("Engine.ParticleSystem")
Camera = require("Engine.Camera")
SoundManager = require("Engine.SoundManager")
MusicManager = require("Engine.MusicManager")
DialogueSystem = require("Engine.DialogueSystem")
Profile = require("3rdParty.profile")
require("Engine.MathUtils")
require("Engine.VisualEffects")
require("src.Levels")
require("src.Player")
require("src.Enemies")
require("src.GameUtils")
require("src.FinalBoss")
lowresCanvas = nil

-- initialize the randomness
math.randomseed(os.time())
math.random()

-- Global gamestate passed to level scripts
gameState = {
    loadLevel = true,
    levelIndex = 1,
    allEnemies = {},
    learnedDash = false,
    speedrunModeEnabled = false,
    speedrunClock = {minutes=0,seconds=0,milliseconds=0},
    deathRespawn = false,
    flashRespawn = false,
    bossCheckpoint = false,
    roomTransition = {x=0,y=0},
    timeScale = 1,
    totalNumDeaths = 0,
    bossNumDeaths = 0,
    upToJumpEnabled = false,
    goToNextLevel =
    function()
        gameState.levelIndex = gameState.levelIndex + 1
        gameState.loadLevel = true
    end
}

-- put the names of level functions from "src/Levels" here
levelOrder = {
    titleScreen, -- 1
    fallingCutscene, -- 2
    introCutscene, -- 3
    introLevel, -- 4
    testLevel, -- 5
    testLevel2, -- 6
    testLevel3, -- 7
    testLevel4, -- 8
    testLevel5, -- 9
    testLevel6, -- 10
    testLevel7, -- 11
    testLevel8, -- 12
    secondCutscene, -- 13
    testLevel9, -- 14
    testLevel10, -- 15
    testLevel11A, -- 16
    testLevel11, -- 17
    testLevel12, -- 18
    testLevel13, -- 19
    testLevel14, -- 20
    testLevel15, -- 21
    testLevel16, -- 22
    testLevel17A, -- 23
    testLevel17B, -- 24
    thirdCutscene, -- 25
    testLevel18, -- 26
    testLevel19, -- 27
    testLevel20, -- 28
    testLevel20B, -- 29
    testLevel21, -- 30
    testLevel22, -- 31
    preFinalBossCutscene, -- 32
    finalBossPhase1, -- 33
    finalBossPhase2, -- 34
    finalBossPhase3, -- 35
    finalBossPhase3Transition1, -- 36
    finalBossPhase3Transition2, -- 37
    finalBossTalkingPhase, -- 38
    finalBossPhase4, -- 39
    finalBossPhase5, -- 40
    postBossCutscene, -- 41
    endingCutscene, -- 42
    endingScreen, -- 43
}

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

function love.load()
    if manualGC or manualGCPerFrame then
        collectgarbage("stop")
        print("Manual garbage collection enabled")
    end
    -- Set these to get pixel art style
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    lowresCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)

    -- pico 8 font
    -- make sure to use fontsize 4 otherwise it's either too big or blurry
    picoFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 4)
    mediumPicoFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 6)
    largePicoFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 12)
    massivePicoFont = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 24)
    love.graphics.setFont(picoFont)

    -- Initialize subsystems
    Input.initialize({
        "left","right","up","down","space", "x", "c","r","z","k","r","t","w","a","s","d","u","i","o","q"
    }, {
        "a","x","b","dpright","dpleft","dpup","dpdown","leftshoulder","rightshoulder","start"
    })
    Input.map({
        {buttonName="attack", keyboard={"x","i"}, gamepad={"x","rightshoulder"}},
        {buttonName="jump", keyboard={"space","z","u"}, gamepad={"a"}},
        {buttonName="dash", keyboard={"c","o"}, gamepad={"b","leftshoulder"}},
        {buttonName="moveleft", keyboard={"left","a"}, gamepad={"dpleft"}},
        {buttonName="moveright", keyboard={"right","d"}, gamepad={"dpright"}},
        {buttonName="moveup", keyboard={"up","w"}, gamepad={"dpup"}},
        {buttonName="movedown", keyboard={"down","s"}, gamepad={"dpdown"}},
        {buttonName="skip", keyboard={"k"}, gamepad={}},
        {buttonName="reset", keyboard={"r"}, gamepad={}},
        {buttonName="title", keyboard={"t"}, gamepad={}},
        {buttonName="select", keyboard={"space","z"}, gamepad={"a"}},
    }, 11)
    Physics.initialize()
    Collision.initialize()
    GameObjects.initialize()
    Animation.initialize()
    Texture.initialize(
        {
            {filename = "Textures/Player-Sheet.png", width=80, height=64, slice=16},
            {filename = "Textures/Cape-Sheet.png", width=64, height=64, slice=16},
            {filename = "Textures/Tileset.png", width=64, height=64, slice=8},
            {filename = "Textures/Enemies-Sheet.png", width=112, height=112, slice=16},
            {filename = "Textures/StarryBackground.png", width=340, height=340, slice=340},
            {filename = "Textures/BackgroundTileset.png", width=48, height=24, slice=8},
            {filename = "Textures/Sprites32px-Sheet.png", width=96, height=32, slice=32},
        }
    )
    SoundManager.initialize("Sounds",{
        "dash",
        "death1",
        "death2",
        "death3",
        "explosion",
        "jump",
        "land",
        "slash",
        "unlock",
        "unlockDoorIn",
        "unlockDoorOut",
        "unlockFailed",
        "hit",
        "BossFinish1",
        "charge",
        "ProjectileShot",
        "WhitenBackground",
        "GhostIncoming2",
        "FallenSoldierSpawn",
        "FallenSoldierDie",
        "GhostDie7",
        "GhostSpawn7",
        "GhostPopSpawn",
        "PlayerTalk",
        "MissionControlTalk",
        "FriendTalk",
        "WalkieTalkieOn",
        "WalkieTalkieOff",
        "DramaticText",
        "Laser",
        "MegaLaser",
        "LaserCharge"
    },".wav")
    MusicManager.initialize("Music", {
        "MainLevelsCalm",
        "MainLevelsHype",
        "FriendEncounter",
        "BossTrack",
        "EndingTrack",
        "PostBossTrack"
    }, ".ogg")
    ParticleSystem.initialize()
    Camera.initialize()
    mySpritebatch = love.graphics.newSpriteBatch(Texture.textures[3].image, 64)
    tileQuads = {}
    for k = 0,63 do
        local tx = (k % 8) * 8
        local ty = math.floor(k / 8) * 8
        tileQuads[k] = love.graphics.newQuad(tx,ty,8,8,64,64)
    end
end

function remapInputs(upToJump)
    Input.initialize({
        "left","right","up","down","space", "x", "c","r","z","k","r","t","w","a","s","d","u","i","o","q"
    }, {
        "a","x","b","dpright","dpleft","dpup","dpdown","leftshoulder","rightshoulder","start"
    })
    if upToJump then
        Input.map({
            {buttonName="attack", keyboard={"x","i"}, gamepad={"x","rightshoulder"}},
            {buttonName="jump", keyboard={"space","z","w","u","up"}, gamepad={"a"}},
            {buttonName="dash", keyboard={"c","o"}, gamepad={"b","leftshoulder"}},
            {buttonName="moveleft", keyboard={"left","a"}, gamepad={"dpleft"}},
            {buttonName="moveright", keyboard={"right","d"}, gamepad={"dpright"}},
            {buttonName="moveup", keyboard={"up","w"}, gamepad={"dpup"}},
            {buttonName="movedown", keyboard={"down","s"}, gamepad={"dpdown"}},
            {buttonName="skip", keyboard={"k"}, gamepad={}},
            {buttonName="reset", keyboard={"r"}, gamepad={}},
            {buttonName="title", keyboard={"t"}, gamepad={}},
            {buttonName="select", keyboard={"space","z"}, gamepad={"a"}},
        }, 11)
    else
        Input.map({
            {buttonName="attack", keyboard={"x","i"}, gamepad={"x","rightshoulder"}},
            {buttonName="jump", keyboard={"space","z","u"}, gamepad={"a"}},
            {buttonName="dash", keyboard={"c","o"}, gamepad={"b","leftshoulder"}},
            {buttonName="moveleft", keyboard={"left","a"}, gamepad={"dpleft"}},
            {buttonName="moveright", keyboard={"right","d"}, gamepad={"dpright"}},
            {buttonName="moveup", keyboard={"up","w"}, gamepad={"dpup"}},
            {buttonName="movedown", keyboard={"down","s"}, gamepad={"dpdown"}},
            {buttonName="skip", keyboard={"k"}, gamepad={}},
            {buttonName="reset", keyboard={"r"}, gamepad={}},
            {buttonName="title", keyboard={"t"}, gamepad={}},
            {buttonName="select", keyboard={"space","z"}, gamepad={"a"}},
        }, 11)
    end
end

function love.keypressed(key)
    Input.setButtonStatus(key, true)
end

function love.keyreleased(key)
    Input.setButtonStatus(key, false)
end

function love.gamepadpressed(joystick, button)
    Input.setButtonStatus(Input.gamepadPrefix..button, true)
end

function love.gamepadreleased(joystick, button)
    Input.setButtonStatus(Input.gamepadPrefix..button, false)
end

function love.gamepadaxis(joystick, axis, value)
    Input.setAxisValue(axis, value)
end

function love.update(dt)
    if logGC then
        print(collectgarbage("count"))
    end
    if manualGCPerFrame then
        collectgarbage()
    end
    if (dt > maxDT) then
        dt = maxDT
        print("clamped DT")
    end
    dt = dt * gameState.timeScale
    if gameState.loadLevel then
        reset()
        levelOrder[gameState.levelIndex](gameState)
        gameState.loadLevel = false
    else
        GameObjects.update(dt)
        Animation.update(dt)
        Camera.update(dt)
    
        -- Make sure to call 'update buttons' AFTER you do all the input checking.
        Input.updateButtons()
    
        Collision.update()
        Physics.update(dt)
    end
end


function love.draw()
    love.graphics.push()
    -- Set the canvas to our low res canvas and do all drawing operations on it
    love.graphics.setCanvas(lowresCanvas)
    love.graphics.clear(0.0078, 0.0078, 0.051)

    -- DO ALL DRAWING HERE
    love.graphics.setColor(1, 1, 1, 1)
    Camera.preDraw()
    GameObjects.draw()

    -- Debug draw colliders
    -- Collision.debugDraw()

    Camera.postDraw()
--Camera.zoomDraw()
    -- set the canvas back to the default window canvas
    love.graphics.setCanvas()

    -- https://love2d.org/wiki/love.graphics.setBlendMode
    -- "Premultiplied alpha should generally be used when drawing a canvas to the screen"
    love.graphics.setBlendMode('alpha', 'premultiplied')

    -- Make sure to reset the color of our final canvas
    love.graphics.setColor(1, 1, 1, 1)

local aspectRatio = canvasWidth / canvasHeight
local cw = love.graphics.getWidth()
local ch = love.graphics.getHeight()
local upscaleFactor = 3

if cw / ch > aspectRatio then
    scaleY = (ch / canvasHeight) * upscaleFactor
    scaleX = scaleY
else
    scaleX = (cw / canvasWidth) * upscaleFactor
    scaleY = scaleX
end

local xco = (cw - (canvasWidth * scaleX)) / 2
local yco = (ch - (canvasHeight * scaleY)) / 2

-- Calculate dimensions for the one-third size scissor area
local scissorWidth = (canvasWidth * scaleX) / 3
local scissorHeight = (canvasHeight * scaleY) / 3

-- Adjust x and y coordinates to center the scissor area within the play area
local scissorX = xco + (canvasWidth * scaleX - scissorWidth) / 2
local scissorY = yco + (canvasHeight * scaleY - scissorHeight) / 2

-- Set the scissor area to restrict drawing
love.graphics.setScissor(scissorX, scissorY, scissorWidth, scissorHeight)

-- Draw the upscaled canvas within the scissor area
love.graphics.draw(lowresCanvas, xco, yco, 0, scaleX, scaleY)

-- Clear the scissor after drawing to reset clipping
love.graphics.setScissor()

    love.graphics.setBlendMode('alpha')
    love.graphics.pop()
    -- Draw all post-camera elements like UI and transitions
    -- This is where high resolution elements can go as well
    GameObjects.drawPostCamera()
    -- Draw speedrun clock if necessary
    if gameState.speedrunModeEnabled then
        drawSpeedrunClock(gameState)
    end
    if showFPS then
        love.graphics.print(love.timer.getFPS(), 10, 10)
    end
end

function reset()
    collectgarbage() -- it seems like collecting garbage at the start of each level has no drawbacks for now
    love.graphics.setFont(picoFont) -- if something font related breaks, remove this. this is a failsafe to prevent font changes from sticking
    gameState.allEnemies = {}
    gameState.timeScale = 1
    Physics.initialize()
    Collision.initialize()
    GameObjects.initialize()
    Animation.initialize()
    ParticleSystem.initialize()
    Camera.initialize()
end
