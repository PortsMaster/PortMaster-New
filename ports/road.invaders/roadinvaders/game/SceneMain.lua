local objControl = require("script/ObjectControl")
local mainBg = require("script/MainBg")
local bezier = require("script/Bezier")
local mainCountdown = require("script/MainCountdown")
local flashText = require("script/FlashText")
local scorePanel = require("script/ScorePanel")
local explodeEffect = require("script/ExplodeEffect")
local borderLine = require("script/BorderLine")
local floatWord = require("script/FloatWord")
local gear = require("script/Gear")
local dotTransition = require("script/DotTransition")
local panelButton = require("script/PanelButton")
local invaders = require("script/Invaders")

local gfx = love.graphics
local PMODE = {}
PMODE.NONE = 0
PMODE.CAR = 1
PMODE.MONSTER = 2
PMODE.OVER = 3
PMODE.PAUSE = 4
PMODE.FREEZE = 5

local SceneMain = {}
local _spawnDuration = 1.5
local _shakeDuration = 1.5
local _moveCubeDuration = 1.5
local isCarCrash = false
local spawnTimer, invaderTimer, cacheMode
local camera
local flashColor = {0,0,0,1}
local playerMode = PMODE.CAR
local menuIdx = 1

function SceneMain:init()
    Signal.register(SG.PUNCH_CUBE, self.onPunchCube)
    Signal.register(SG.HIT_MONSTER, self.onHitMonster)
    Signal.register(SG.CUBE_STATIC, self.cubeCollideCrash)
    Signal.register(SG.CUBE_MATCH, self.cubeMatch)
    Signal.register(SG.CAR_CRASH, self.carCrash)
    Signal.register(SG.TIMES_UP, self.timesUp)
    Signal.register(SG.CUBE_EXPLODE, self.onCubeExplode)
    Signal.register(SG.TRI_EXPLODE, self.onTriExplode)
    Signal.register(SG.SHIFT_UP_GEAR, self.onShiftUpGear)
    Signal.register(SG.OUTSIDE_PUNCH, self.onCheatOnColumn)
    Signal.register(SG.CUBE_COLLAPSE, self.onCubeCollapse)
    Signal.register(SG.CLEAR_ALL_INVADERS, self.onYouWin)
    Signal.register(SG.PRE_GAME_OVER, self.onPreGameOver)
    -- font init
    camera = Camera()
    setFont(2)
    invaders:init()
    borderLine:init()
    floatWord:init()
    flashText:init()
    gear:init()
    panelButton:init()
    objControl:init()
    explodeEffect:init()
    mainBg:init()
    bezier:init()
    mainCountdown:init()
    scorePanel:init()
    spawnTimer = Timer.new()
    invaderTimer = Timer.new()
    self:enterGame()
end

function SceneMain:resume()
    SceneMain:enterGame()
end

function SceneMain:leave()
    SceneMain:pauseGame()
end

function SceneMain:enterGame()
    self.update = self.mainUpdate
    self.update = self.mainDraw
    isCarCrash = false

    self:switchMode(PMODE.CAR)
    spawnTimer:clear()
    invaderTimer:clear()
    objControl:enter()
    floatWord:enter()
    invaders:enter()
    panelButton:enter()
    gear:enter()
    mainBg:enter()
    flashText:enter()
    bezier:reset()
    explodeEffect:reset()
    scorePanel:enter()
    mainCountdown:enter(60)
    SceneMain.refreshSpawnTimer(1)
    self:startText()
    invaders:uprising(0)
    invaders:uprising(5)
end

function SceneMain.onShiftUpGear()
    local num = gear.num
    SceneMain.refreshSpawnTimer(num)
    mainBg:setSpeedByGear(num)
    scorePanel:setFactor(num)
    local showStr = string.format("SHIFT G%s", num)
    flashText:center(showStr)
    Timer.after(2, function()
        flashText:delete(showStr)
    end)
end

function SceneMain.onPreGameOver()
    if isCarCrash then return end
    SceneMain.keypressed = nil
end

function SceneMain.onYouWin()
    if isCarCrash then return end
    soundMgr:onStopReverseSFX()
    objControl:pauseUpdate()
    flashText:center("YOU WIN!")
    Timer.after(4, function()
        soundMgr:stopBgm()
        flashText:delete("YOU WIN!")
        SceneMain:pushToScoreScene()
    end)
end

function SceneMain.onCubeCollapse()
    if playerMode == PMODE.NONE then return end
    SceneMain.carCrash()
end

function SceneMain.onCheatOnColumn(column)
    if objControl.reverseMode then
        -- SceneMain.fallCubes()
    else
        SceneMain.moveHoldCubes()
    end
end

function SceneMain.onShiftDownGear()
    local num = gear.num
    SceneMain.refreshSpawnTimer(num)
    mainBg:setSpeedByGear(num)
end

local DIFF = {
    {moveCubeDuration = 1.5, spawnDuration = 1.5, shakeDuration = 1},
    {moveCubeDuration = 1.3, spawnDuration = 1.3, shakeDuration = 1},
    {moveCubeDuration = 1.2, spawnDuration = 1.2, shakeDuration = 0.9},
    {moveCubeDuration = 1.0, spawnDuration = 1.0, shakeDuration = 0.9},
    {moveCubeDuration = 0.8, spawnDuration = 0.8, shakeDuration = 0.7},
}
function SceneMain.refreshSpawnTimer(num)
    num = math.max(math.min(num or 1, #DIFF),1)
    _moveCubeDuration = DIFF[num].moveCubeDuration
    _spawnDuration = DIFF[num].spawnDuration
    _shakeDuration = DIFF[num].shakeDuration
    spawnTimer:clear()
    spawnTimer:every(_moveCubeDuration, SceneMain.moveHoldCubes)
    spawnTimer:every(_spawnDuration, SceneMain.fallCubes)
    spawnTimer:every(15, SceneMain.spawnBlocker)
end

function SceneMain.spawnBlocker()
    if not objControl.reverseMode then
        objControl:spawnBlockCube(_shakeDuration)
    end
end

function SceneMain.fallCubes()
    if objControl.reverseMode then
        objControl:fallRandomCubeRV(_shakeDuration)
    else
        objControl:fallRandomCube(_shakeDuration)
    end
end

function SceneMain.moveHoldCubes()
    if not objControl.reverseMode then 
        objControl:checkInsertCube()
        objControl:moveAllHoldCubes()
        objControl:checkCubeCollapse()
    else
        objControl:checkInsertCubeRV()
        objControl:moveAllHoldCubesRV()
    end
end

function SceneMain.triAttact()
    local column = randi(6) - 1
end

function SceneMain:carKeypressed(key)
    if key == BTN.LEFT or key == BTN.L1 or key == BTN.L2 then
        objControl:sideMoveCar(-1)
    elseif key == BTN.RIGHT or key == BTN.R1 or key == BTN.R2 then
        objControl:sideMoveCar(1)
    elseif key == BTN.START then
        self:pauseGame()
        soundMgr:playPressBtn()
    end
end

function SceneMain:pushToScoreScene()
    dotTransition:show()
    Timer.after(0.3, function()
        local score = scorePanel:getScore()
        Gamestate.push(SceneScore, score)
    end)
end

function SceneMain:panelKeypressed(key)
    if key == BTN.START then
        -- self:enterGame()
    end
end

function SceneMain:pauseKeypressed(key)
    if key == BTN.LEFT then
        menuIdx = 1
    elseif key == BTN.RIGHT then
        menuIdx = 2
    elseif key == BTN.START then
        if menuIdx == 1 then
            soundMgr:playPressBtn()
            self:switchMode(cacheMode)
        elseif menuIdx == 2 then
            soundMgr:playPressBtn()
            self:enterGame()
        end
    end
end

function SceneMain:freezeGame(frameCount)
    if playerMode == PMODE.FREEZE then
        return
    end
    cacheMode = playerMode
    self:switchMode(PMODE.FREEZE)
    Timer.after(FRM*frameCount, function()
        self:switchMode(cacheMode)
    end)
end

function SceneMain:pauseGame()
    cacheMode = playerMode
    self:switchMode(PMODE.PAUSE)
end

function SceneMain.cubeCollideCrash()
    camera:shake(6, 0.5, 30, "y")
end

function SceneMain.onHitMonster()
    if isCarCrash then return end
    SceneMain:freezeGame(6)
    scorePanel:addScore(8)
    camera:shake(4, 0.4, 60)
end

function SceneMain:switchMode(mode)
    playerMode = mode
    self:switchKeypressed()
    self:switchUpdate()
end

function SceneMain:switchUpdate()
    if playerMode == PMODE.PAUSE then
        menuIdx = 1
        self.update = nil
        self.draw = self.pauseDraw
    elseif playerMode == PMODE.FREEZE then
        self.update = nil
    else
        self.update = self.mainUpdate
        self.draw = self.mainDraw
    end
end

function SceneMain:switchKeypressed()
    if playerMode == PMODE.CAR then
        self.keypressed = self.carKeypressed
    elseif playerMode == PMODE.OVER then
        self.keypressed = self.panelKeypressed
    elseif playerMode == PMODE.FREEZE then
        self.keypressed = self.panelKeypressed
    else
        self.keypressed = self.pauseKeypressed
    end
end

function SceneMain.onCubeExplode(posX, posY)
    explodeEffect:cubeExplode(posX + CUBE_WID/2, posY)
    camera:shake(4, 0.6, 60)
end

function SceneMain.onTriExplode(posX, posY)
    explodeEffect:triExplode(posX + CUBE_WID/2, posY)
    SceneMain:freezeGame(8)
    scorePanel:addScore(10)
    camera:shake(8, 0.6, 60)
end

function SceneMain:gameOver()
    local score = scorePanel:getScore()
    Timer.script(function(wait)
        wait(0.4)
        flashText:center("GAME OVER")
        SceneMain:switchMode(PMODE.OVER)
        soundMgr:onStopReverseSFX()
        mainCountdown:stop()
        objControl:pauseUpdate()
        wait(3)
        dotTransition:show()
        wait(0.4)
        flashText:delete("GAME OVER")
        Gamestate.push(SceneScore, score)
    end)
end

function SceneMain.timesUp()
    if isCarCrash then return end
    SceneMain:invadersIntro()
end

local chargeDelay = 0.6
function SceneMain.cubeMatch(posX, posY)
    if playerMode == PMODE.CAR then
        camera:shake(2, 0.6, 60)
        local cube = objControl:getTargetCube()
        if not cube then return end
        cube.beingTarget = true
        bezier:spawn(
            chargeDelay,
            {posX + CUBE_WID/2, posY + CUBE_HEI/2}, 
            {cube.posX+ CUBE_WID/2, cube.posY+ CUBE_HEI/2},
            function()
                scorePanel:addCubeScore(10)
                objControl:_flashAndRemoveCube(cube, true)
            end)
    end
end

function SceneMain.carCrash()
    if isCarCrash then return end
    if playerMode == PMODE.NONE then return end
    isCarCrash = true
    SceneMain:freezeGame(14)
    camera:shake(20, 2, 15)
    local carData = objControl:getCarData()
    local posX = carData.posX + CAR_SP_OFFSET.X
    local posY = carData.posY + CAR_SP_OFFSET.Y + CAR_SP_HEI/2
    explodeEffect:carExplode(posX, posY)
    floatWord:onCarCrash(posX, posY)
    SceneMain:gameOver()
    soundMgr:stopBgm()
end

function SceneMain:invadersIntro()
    Timer.script(function(wait)
        soundMgr:playIncommingSFX()
        wait(0.5)
        soundMgr:playIncommingSFX()
        wait(0.5)
        soundMgr:playIncommingSFX()
        wait(0.5)
        self:switchMode(PMODE.NONE)
        objControl:explodeUpperCubes()
        objControl:playCar("idle", true)
        mainBg:setSpeedByGear(0)
        SceneMain:finalStageScript()
        wait(1)
        flashText:center("SHIFT BACK!!")
        soundMgr:onPlayReverseSFX()
        wait(2)
        flashText:delete("SHIFT BACK!!")
        gear:reverseGear()
        self:startText()
        self:switchMode(PMODE.CAR)
        self:onShiftDownGear()
        objControl:toggleReverse()
    end)
end

function SceneMain:finalStageScript()
    for i = 1,4 do
        invaders:attack(i, 7)
    end
    invaders:attack(0, 8)
    invaders:attack(2, 8)
    invaders:attack(3, 8)
    invaders:attack(5, 8)
    for i = 0,5 do
        invaders:attack(i, 9)
    end
end

function SceneMain:startText()
    flashText:center("START")
    Timer.after(2, function()
        flashText:delete("START")
    end)
end

function SceneMain.moveCameraUp()
    local info = {x = 320/2, y = 240/2}
    camera.x = info.x
    camera.y = info.y
    Timer.tween(2, info, {y = 240/2 - 60}, "out-cubic")
    Timer.every(FRM,function()
        camera.x = info.x
        camera.y = info.y
    end,2/FRM)
end

function SceneMain.moveCameraDown()
    local info = {x = 320/2, y = 240/2 - 60}
    camera.x = info.x
    camera.y = info.y
    Timer.tween(2, info, {y = 240/2}, "out-cubic")
    Timer.every(FRM,function()
        camera.x = info.x
        camera.y = info.y
    end,2/FRM)
end

function SceneMain.onPunchCube()
    SceneMain:freezeGame(10)
    camera:shake(6, 0.5, 30, "x")
    scorePanel:addScore(5)
end

function SceneMain:mainUpdate(dt)
    borderLine:update(dt)
    objControl:update(dt)
    flashText:update(dt)
    invaders:update(dt)
    camera:update(dt)
    floatWord:update(dt)
    gear:update(dt)
    dotTransition:update(dt)
    mainCountdown:update(dt)
    mainBg:update(dt)
    scorePanel:update(dt)
    bezier:update(dt)
    panelButton:update(dt)
    explodeEffect:update(dt)
    if playerMode == PMODE.CAR then
        spawnTimer:update(dt)
        invaderTimer:update(dt)
    elseif playerMode == PMODE.MONSTER then
    end
end

function SceneMain:pauseDraw()
    self:mainDraw()
    resetColor(PCOLOR.PEACH)
    -- resPush:start()
    setFont(2)
    gfx.rectangle("fill", 0, 70, 320, 100 )
    gfx.printf({PCOLOR.BLACK, "PAUSE"}, 0, 77+10, 320, "center")
    if menuIdx == 1 then
        resetColor(PCOLOR.RED)
        gfx.rectangle("fill", 76, 113+10-2, 65, 20+2 )
        setFont(1)
        resetColor()
        gfx.printf({PCOLOR.WHITE, "RESUME"}, -50, 117+10, 320, "center")
        gfx.printf({PCOLOR.BLACK, "RESTART"}, 50, 117+10, 320, "center")
    else
        resetColor(PCOLOR.RED)
        gfx.rectangle("fill", 176, 113+10-2, 65, 20+2 )
        setFont(1)
        resetColor()
        gfx.printf({PCOLOR.BLACK, "RESUME"}, -50, 117+10, 320, "center")
        gfx.printf({PCOLOR.WHITE, "RESTART"}, 50, 117+10, 320, "center")
    end
    -- resPush:finish()
end

function SceneMain:mainDraw()
    -- resPush:start()
    -- draw
    camera:attach()
    mainBg:draw()
    gear:draw()
    objControl:draw()
    bezier:draw()
    invaders:draw()
    explodeEffect:draw()
    borderLine:draw()
    camera:detach()
    -- gui 
    floatWord:draw()
    mainCountdown:draw()
    flashText:draw()
    panelButton:draw()
    scorePanel:draw()
    dotTransition:draw()
    -- gfx.print(love.timer.getFPS(), 0, 0)
    -- gfx.print(os.date(" FPS / By Blasin %Y-%m-%d %a"), 20, 0)
    -- resPush:finish()
end

return SceneMain