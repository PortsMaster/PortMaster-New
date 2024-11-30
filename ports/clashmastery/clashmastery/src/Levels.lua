require("src.Player")
require("src.Boss")
local bossTalkColor = {1,0,1,1}
function testLevel(gameState)
    local gm = GameObjects.newGameObject(-1,gameResolution.width/2, gameResolution.height/2, 0, true)
    function gm:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("fill", -32, 0, 128, 64)

        love.graphics.setColor(0.25,0.25,0.25,1)
        love.graphics.rectangle("fill", -10, gameState.state.floorHeight + 4, gameResolution.width * 1.5, 100)
    end

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active

    local boss = createBoss(48, gameState.state.floorHeight, 1000)
    boss.flip = -1
    boss.target = plr

    gameState.state.boss = boss
end

function flashIntro()
    local flash = createScreenFlash(global_pallete.white_color, 0.1, true, GameObjects.DrawLayers.POSTCAMERA)
    flash:setActive()
end

function createBackground()
    local background = GameObjects.newGameObject(5, 30, 30, 7, true, GameObjects.DrawLayers.BACKGROUND)
    return background
end

function coolTextIntro(coolText, delay)
    flashIntro()
    local gm = GameObjects.newGameObject(-1,gameResolution.width/2, gameResolution.height/2, 0, true)
    function gm:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("fill", -32, 0, 128, 64)

        love.graphics.setColor(0,0,0,1)
        love.graphics.rectangle("fill", -10, gameState.state.floorHeight + 4, gameResolution.width * 1.5, 100)
    end
    local plr = GameObjects.newGameObject(1,16,gameState.state.floorHeight,0,true,GameObjects.DrawLayers.PLAYER)

    local boss = GameObjects.newGameObject(2,48,gameState.state.floorHeight,0,true,GameObjects.DrawLayers.BOSS)
    boss.flip = -1

    plr.color = global_pallete.black_color
    boss.color = global_pallete.black_color
    local coolTextObj = GameObjects.newGameObject(-1,0,0,0,true)
    coolTextObj:startCoroutine(
        function()
            local rect = createScalingRectangle("horizontal", 14, 12, global_pallete.black_color, 0.15, GameObjects.DrawLayers.PLAYER)
            rect:setActive()
            ParticleSystem.burst(32, 12, 10, 350, 450, global_pallete.black_color, 5, 0.95, 0.8, false, 0.5)
            local txt = worldSpaceText(coolText, 32, 12, global_pallete.black_color, GameObjects.DrawLayers.PLAYER)
            Camera.jiggle(0.4, 0)
            SoundManager.playSound("HypeParticles")
            SoundManager.playSound("HypeRectangle")
            coroutine.yield(delay or 1)

            local rect2 = createScalingRectangle("horizontal", 26, 12, global_pallete.black_color, 0.15, GameObjects.DrawLayers.PLAYER)
            rect2:setActive()
            ParticleSystem.burst(32, 24, 10, 350, 450, global_pallete.black_color, 5, 0.95, 0.8, false, 0.5)
            local txt2 = worldSpaceText("GO", 32, 24, global_pallete.black_color, GameObjects.DrawLayers.PLAYER)
            Camera.jiggle(-0.4, 0)
            SoundManager.playSound("HypeParticles")
            SoundManager.playSound("HypeRectangle")
            coroutine.yield(delay and delay*2 or 2)
            gameState.goToNextLevel()
        end
    , "coolText")
end

function titleScreen(gameState)
    flashIntro()
    MusicManager.stopAllTracks()
    resetGameData()
    createBackground()

    local plr = createPlayer(32, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(56, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true
    plr.lineEmitter = ParticleSystem.createEmitter(50, true, GameObjects.DrawLayers.DEATHLAYER_2)
    plr.deflectPop = createCircularPop(0,0,global_pallete.black_color, 3, 8, 1, 0.25, 0.2,GameObjects.DrawLayers.DEATHLAYER_2)
    plr.dashTrailer = createDashTrailer(plr, 1, 10, 0.3, true, GameObjects.DrawLayers.PLAYER)
    local otherEmitter = ParticleSystem.createEmitter(50, false, GameObjects.DrawLayers.IGNORE_DT)
    local makeAHypeRect =
        function(yPos)
            local hypeRect = createScalingRectangle("horizontal", yPos + 3, 8, global_pallete.black_color, 0.15, GameObjects.DrawLayers.IGNORE_DT)
            hypeRect:setActive()
            SoundManager.playSound("HypeRectangle")
            SoundManager.playSound("HypeParticles")
            Camera.shake(0.35)
        end
    local sickRoutineObj = GameObjects.newGameObject(-1,0,0,0,true, GameObjects.DrawLayers.IGNORE_DT)
    sickRoutineObj.go =
        function()
            sickRoutineObj:startCoroutine(
                function()
                    coroutine.yield(1.5)
                    Animation.changeAnimation(boss, "slamprep_1")
                    dashToPosition(48, 16, 6)
                    boss.flip = -1
                    coroutine.yield(2)
                    Animation.changeAnimation(boss, "slam")
                    plr.x = plr.x - 4
                    dashToPosition(plr.x + 16, plr.y - 12, 2)
                    plr.flip = 1
                    Animation.changeAnimation(plr, "deflect_success")
                    MusicManager.playTrack("CalmTrackDay2V2", 1)
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess1", 0.7, 1.3)
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess2", 0.7, 1.3)
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess3v2", 0.7, 1.3)
                    SoundManager.playSound("HypeParticles")
                    local tX, tY = plr.x + plr.flip * 3, plr.y - 3
                    ParticleSystem.lineBurst(tX, tY, 10, 400, 400, global_pallete.black_color, 6, 0.95, 0.8, false, 0.5, plr.lineEmitter, true)
                    plr.deflectPop.x, plr.deflectPop.y = tX, tY
                    plr.deflectPop:setActive()
                    Camera.jiggle(plr.flip * 0.3, 0)
                    coroutine.yield(0.1)
                    gameState.timeScale = 0
                    local flash = createScreenFlash(global_pallete.white_color, 10, false, GameObjects.DrawLayers.DEATHLAYER_1)
                    flash:setActive()
                    local fakeBoss = GameObjects.newGameObject(2, boss.x, boss.y, boss.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
                    fakeBoss.flip = boss.flip
                    local fakePlr = GameObjects.newGameObject(1, plr.x, plr.y, plr.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
                    fakePlr.flip = plr.flip
                    fakeBoss.color = global_pallete.black_color
                    fakePlr.color = global_pallete.black_color
                    SoundManager.playSound("WhitenBackground")
                    local lines = velocityLines(32, 8, math.rad(90), 500, nil, GameObjects.DrawLayers.IGNORE_DT)
                    local lines2 = velocityLines(32, 56, math.rad(270), 500, nil, GameObjects.DrawLayers.IGNORE_DT)
                    coroutine.yield(0.454*2)
                    lines:setInactive()
                    lines2:setInactive()
                    Camera.ignoreDT = true
                    coroutine.yield(0.454)
                    worldSpaceText("CLASH", 18, 8, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    ParticleSystem.burst(18, 8, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    makeAHypeRect(8)
                    coroutine.yield(0.454/2)
                    worldSpaceText("MASTERY", 48, 8, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    ParticleSystem.burst(48, 8, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    makeAHypeRect(8)
                    coroutine.yield(0.454 * 4)
                    gameState.timeScale = 0.25
                    Camera.ignoreDT = false
                    flash:setInactive()
                    fakePlr:setInactive()
                    fakeBoss:setInactive()
                    plr.flip = 1
                    plr.dashTrailer:trailFromTo(plr.x, plr.y, 12, gameState.state.floorHeight, 3)
                    plr.x, plr.y = 12, gameState.state.floorHeight
                    Animation.changeAnimation(boss, "idle")
                    boss.flip = -1
                    dashToPosition(52, boss.floorY, 3)
                    coroutine.yield(0.5)
                    gameState.timeScale = 1
                    worldSpaceText("by\nabhi sundu", 32, 16, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    local prompt = createControlsPrompt(32, 52, "select", "press ~")
                    prompt.useBlackBG = false
                    prompt.color = global_pallete.white_color
                    prompt:setActive()
                    sickRoutineObj.canGoNext = true
                    Animation.changeAnimation(plr, "idle")
                    Animation.changeAnimation(boss, "idle")
                end
            , "sickRoutine")
        end
    sickRoutineObj.go()
    sickRoutineObj.canGoNext = false
    function sickRoutineObj:update(dt)
        if sickRoutineObj.canGoNext and Input.getMappedButtonPressed("select") then
            sickRoutineObj.canGoNext = false
            SoundManager.playSound("WhitenBackground")
            MusicManager.stopAllTracks()
            gameState.goToNextLevel()
        end
    end
end

function preTutorialScene(gameState)
    flashIntro()
    resetPersistentBossData()
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true

    -- need a total of 14.545 seconds of cutscene to get the music to sync up perfectly with the text intro
    local cutsceneLines = {
        {x=40,y=8,text="nice to see\na new face!",speakerIndex = 1, totalDelay = 3},
        {x=42,y=16,text="now. . .",speakerIndex = 1, totalDelay = 2},
        {x=42,y=8,text="let's get\nwarmed up.",speakerIndex = 1, totalDelay = 2}
    }
    local cutscene = DialogueSystem.createCutscene(gameState,cutsceneLines,{bossTalkColor}, {"MidTalk"},1.5,1)
    cutscene:runFullCutscene()
end

function tutorialIntro(gameState)
    coolTextIntro("WARMUP PHASE", 0.909)
    MusicManager.playTrack("CalmTrack_TutorialArr")
end

function tutorialStage(gameState)
    flashIntro()
    MusicManager.setVolume(0.8)
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    boss.isTutorial = true

    local tutorialController = GameObjects.newGameObject(-1,0,0,0,true)
    tutorialController.moveText = worldSpaceText("d-pad\nto move", 32, 48, global_pallete.white_color, GameObjects.DrawLayers.POSTCAMERA)
    tutorialController.deflectText = createControlsPrompt(32, 42, "deflect", "~ to\ndeflect")
    tutorialController.deflectText.useBlackBG = false
    tutorialController.deflectText.color = global_pallete.white_color
    tutorialController.deflectText2 = worldSpaceText("deflect the\norbs", 32, 52, global_pallete.white_color, GameObjects.DrawLayers.POSTCAMERA)
    tutorialController.noRedAttacks = worldSpaceText("red attacks\ncannot be\ndeflected", 32, 42, global_pallete.red_color, GameObjects.DrawLayers.POSTCAMERA)
    tutorialController.jumpText = createControlsPrompt(32, 48, "jump", "~ to jump")
    tutorialController.jumpText.color = global_pallete.white_color
    tutorialController.jumpText.useBlackBG = false
    tutorialController.attackText = createControlsPrompt(32, 48, "attack", "~ to attack")
    tutorialController.attackText.color = global_pallete.white_color
    tutorialController.attackText.useBlackBG = false
    tutorialController.moveText:setInactive()
    tutorialController.deflectText:setInactive()
    tutorialController.noRedAttacks:setInactive()
    tutorialController.jumpText:setInactive()
    tutorialController.attackText:setInactive()
    tutorialController.deflectText2:setInactive()

    function tutorialController:update(dt)
        if boss.currentHP <= 0 then
            tutorialController.attackText:setInactive()
        end
    end

    tutorialController:startCoroutine(
        function()
            coroutine.yield(1)
            tutorialController.moveText:setActive()
            tutorialRedProjectiles()
            coroutine.yield(1)
            tutorialController.deflectText:setActive()
            tutorialController.deflectText2:setActive()
            tutorialController.moveText:setInactive()
            tutorialHomingProjectile()
            coroutine.yield(2)
            tutorialController.deflectText:setInactive()
            tutorialController.deflectText2:setInactive()
            tutorialController.noRedAttacks:setActive()
            coroutine.yield(4)
            tutorialController.noRedAttacks:setInactive()
            tutorialController.jumpText:setActive()
            tutorialSlam()
            coroutine.yield(1)
            tutorialController.jumpText:setInactive()
            tutorialController.attackText:setActive()
            dashToPosition(32, boss.floorY, 6)
            boss.solid = true
            Animation.changeAnimation(boss, "idle")
            boss.currentHP = 7
        end
    , "tutorial")
end

function prePracticeCutscene(gameState)
    flashIntro()
    MusicManager.playTrack("CalmTrackDay2V2", 1)
    resetPersistentBossData()
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true

    -- need a total of 14.545 seconds of cutscene to get the music to sync up perfectly with the text intro
    local cutsceneLines = {
        {x=48,y=16,text="nice!",speakerIndex = 1, totalDelay = 2},
        {x=38,y=8,text="not bad for\na newcomer.",speakerIndex = 1, totalDelay=3.15},
        {x=36,y=8,text="but that was\njust a warmup.",speakerIndex = 1, totalDelay=3.25},
        {x=42,y=16,text="now. . .",speakerIndex = 1, totalDelay = 1.5},
        {x=32,y=16,text="let's practice.",speakerIndex = 1, totalDelay = 1.5}
    }
    local cutscene = DialogueSystem.createCutscene(gameState,cutsceneLines,{bossTalkColor}, {"MidTalk"},1,2)
    cutscene:runFullCutscene()
end

function practiceModeIntro(gameState)
    coolTextIntro("PRACTICE PHASE", 0.909)
    MusicManager.playTrack("CalmTrackDay2V2", 1)
end

function practiceModeStage(gameState)
    flashIntro()
    MusicManager.setVolume(0.8)
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = -1
    boss.target = plr

    gameState.state.boss = boss

    -- practice mode controller
    local textNode = {x=0,y=0,text="default text",speakerIndex = 1}
    local numReps = 3
    local numPatterns = 4
    local patternGradeObjs = {}
    for k = 1,numPatterns do
        patternGradeObjs[k] = createPatternGradeObj(4*k, 60)
    end
    local bossDialogues = { -- need to have 'numpatterns' number of these. 2 per pattern
        {
            {x=0,y=4,text="let's start\nsimple.",speakerIndex = 1},
            {x=0,y=4,text="deflect the\nslashes,\njump the\nslam.\ngot it?",speakerIndex = 1}
        },
        {
            {x=0,y=4,text="let's try\nsome more\ndeflection",speakerIndex = 1},
            {x=0,y=4,text="deflect the\ndark orbs,\ndodge the\nred orbs.\ngot it?",speakerIndex = 1}
        },
        {
            {x=0,y=4,text="how about\nthis?",speakerIndex = 1},
            {x=0,y=4,text="deflect the\nlaser and\nlightning.\ngot that?",speakerIndex = 1}
        },
        {
            {x=0,y=4,text="this one's\na bit\nharder.",speakerIndex = 1},
            {x=0,y=2,text="deflect the\ndark orb,\njump the\nred orb,\ndeflect the\nlightning",speakerIndex = 1}
        }
    }
    local bossGoodDialogues = {
        {x=0,y=12,text="nice work",speakerIndex = 1},
        {x=0,y=12,text="you've got it",speakerIndex = 1},
        {x=0,y=12,text="well done",speakerIndex = 1},
    }
    local bossBadDialogues = {
        {x=0,y=12,text="not bad",speakerIndex = 1},
        {x=0,y=4,text="almost",speakerIndex = 1},
        {x=0,y=4,text="let's\nkeep going",speakerIndex = 1}
    }
    local practiceNodes = {}
    local spacing = 12
    for k = 1,numReps do
        local node = createLocalPracticeNode()
        node.x, node.y = 32 - spacing + (k-1)*spacing, 52
        node:setActive()
        practiceNodes[k] = node
    end

    local practiceModeController = GameObjects.newGameObject(-1,0,0,0,true, GameObjects.DrawLayers.POSTCAMERA)
    local cutsceneObj = DialogueSystem.createCutscene(gameState, textNode, {bossTalkColor}, {"MidTalk"}, 0, 0)
    gameState.state.practiceController = practiceModeController
    practiceModeController.text = ""
    practiceModeController.formattedText = {}
    practiceModeController.numMistakes = 0
    practiceModeController.patternIndex = 1
    practiceModeController.allPatterns = {
        dualSlashSlam,
        homingProjectilesRedProjectile,
        lightningDiveLaserSpin,
        darkOrbRasenganLightning
    }
    practiceModeController.currentBossAttack = practiceModeController.allPatterns[practiceModeController.patternIndex]
    function practiceModeController:incrementMistakes()
        practiceModeController.numMistakes = practiceModeController.numMistakes + 1
    end
    practiceModeController.gradeMapping = { -- scores range from 6 to 12. scores from 0 to 5 are impossible
        "S","S","S","S","S",
        "S", -- all perfect
        "A", -- ehhh lets not to pluses for now
        "A",
        "B",
        "B",
        "C",
        "C",
    }
    practiceModeController.gradeColorMapping = {
        ["S"] = {0,0,1,1},
        ["A+"] = {1,1,0,1},
        ["A"] = {1,1,0,1},
        ["B+"] = {0,1,0,1},
        ["B"] = {0,1,0,1},
        ["C+"] = {1,0.6,0,1},
        ["C"] = {1,0.6,0,1}
    }
    practiceModeController.bossTalksToYou =
        function(textNode)
            Animation.changeAnimation(boss, "battlestance")
            dashToPosition(36,boss.floorY,6)
            textNode.x = 36
            cutsceneObj.textNodes[1] = textNode
            cutsceneObj.currentLine = 1
            cutsceneObj.typeText()
        end
    local fakePlr = GameObjects.newGameObject(1,0,0,0,false,GameObjects.DrawLayers.PLAYER)
    fakePlr.dashTrailer = createDashTrailer(fakePlr, 1, 10, 0.25, true, GameObjects.DrawLayers.PLAYER)
    practiceModeController.dummy = createTargetDummy()
    practiceModeController.demonstrateAttack =
        function()
            -- send the player into a bubble
            coroutine.yield(0.5)
            textNode.x = 36
            cutsceneObj.textNodes[1] = {x=32,y=6,text="watch\ncarefully. .",speakerIndex = 1}
            cutsceneObj.currentLine = 1
            cutsceneObj.typeText()
            coroutine.yield(1)
            SoundManager.playSound("GetBubbled")
            SoundManager.playSound("Dash")
            cutsceneObj.currentText = ""
            ParticleSystem.burst(plr.x, plr.y, 6, 300, 400, global_pallete.light_blue_color, 3, 0.95, 0.8, false, 0.5)
            fakePlr.dashTrailer:trailFromTo(plr.x, plr.y, 8, 8, 6)
            plr.x, plr.y = 8, 8
            plr.frozen = true
            plr.attacking = false
            plr.deflecting = false
            plr.activeDeflecting = false
            plr.hurt = false
            plr.grounded = false
            Physics.zeroVelocity(plr)
            Physics.zeroAcceleration(plr)
            Animation.changeAnimation(plr, "fall2")
            ParticleSystem.burst(plr.x, plr.y, 6, 300, 400, global_pallete.light_blue_color, 3, 0.95, 0.8, false, 0.5)
            coroutine.yield(1)
            practiceModeController.currentBossAttack = practiceModeController.allPatterns[practiceModeController.patternIndex]
            practiceModeController.dummy:setActive()
            SoundManager.playSound("PopSpawn")
            ParticleSystem.burst(practiceModeController.dummy.x, practiceModeController.dummy.y, 10, 300, 300, global_pallete.white_color, 4,  0.95, 0.8, false, 0.5, nil, true)
            coroutine.yield(0.5)
            practiceModeController.bossTalksToYou(bossDialogues[practiceModeController.patternIndex][1])
            coroutine.yield(1)
            cutsceneObj.currentText = ""
            boss.target = practiceModeController.dummy
            practiceModeController.currentBossAttack()
            coroutine.yield(0.5)
            boss.target = plr
            practiceModeController.dummy:setInactive()
            SoundManager.playSound("PopSpawn")
            ParticleSystem.burst(practiceModeController.dummy.x, practiceModeController.dummy.y, 10, 300, 300, global_pallete.white_color, 4,  0.95, 0.8, false, 0.5, nil, true)
            coroutine.yield(0.5)
            practiceModeController.bossTalksToYou(bossDialogues[practiceModeController.patternIndex][2])
            coroutine.yield(2)
            cutsceneObj.currentText = ""
            plr.frozen = false
            plr.x, plr.y = 8, 8
            plr.RigidBody.acceleration.y = 800
            SoundManager.playSound("PopSpawn")
            ParticleSystem.burst(plr.x, plr.y, 6, 300, 400, global_pallete.light_blue_color, 3, 0.95, 0.8, false, 0.5)
        end
    practiceModeController.goodBadIndex = 1
    practiceModeController.practiceAttack =
        function()
            boss.target = plr
            practiceModeController.currentBossAttack = practiceModeController.allPatterns[practiceModeController.patternIndex]
            practiceModeController.numMistakes = 0
            practiceModeController.goodBadIndex = 1
            coroutine.yield(1)
            for k = 1,numReps do
                practiceModeController.currentBossAttack()
                practiceNodes[k]:getLocallyGraded(practiceModeController.numMistakes)
                if practiceModeController.goodBadIndex > 3 then
                    practiceModeController.goodBadIndex = 1
                end
                if practiceModeController.numMistakes == 0 then
                    practiceModeController.bossTalksToYou(bossGoodDialogues[practiceModeController.goodBadIndex])
                else
                    practiceModeController.bossTalksToYou(bossBadDialogues[practiceModeController.goodBadIndex])
                end
                practiceModeController.goodBadIndex = practiceModeController.goodBadIndex + 1
                practiceModeController.numMistakes = 0
                coroutine.yield(1.5)
                cutsceneObj.currentText = ""
            end
            -- show a grade
            coroutine.yield(1)
            local gradeTotal = 0
            for k = 1,numReps do
                gradeTotal = gradeTotal + practiceNodes[k].icon.spr
            end
            local finalGrade = practiceModeController.gradeMapping[gradeTotal]
            if not finalGrade then
                finalGrade = "A" -- invalid grade lol, just assume it's an A
            end

            local color = practiceModeController.gradeColorMapping[finalGrade]
            if not color then
                color = global_pallete.black_color -- oops
            end
            ParticleSystem.burst(32, 16, 10, 300, 400, color, 6, 0.95, 0.75, false, 1, nil, true)
            practiceModeController.formattedText = {global_pallete.black_color, "GRADE: ", color, finalGrade}
            practiceModeController.text = "GRADE: " .. finalGrade
            SoundManager.playSound("HypeParticles")
            coroutine.yield(2)
            practiceModeController.text = ""
            practiceModeController.formattedText = {}
            local patternGradeObj = patternGradeObjs[practiceModeController.patternIndex]
            local trueGrade = patternGradeObj.trueGrade
            trueGrade.grade = finalGrade
            trueGrade.color = color
            gameState.state.practiceGrades[practiceModeController.patternIndex] = finalGrade
            patternGradeObj.alpha = 0
            ParticleSystem.burst(patternGradeObj.x, patternGradeObj.y, 10, 300, 400, color, 4, 0.95, 0.75, false, 0.75, nil, true)
            SoundManager.playSound("HardShot")
            for k = 1,numReps do
                practiceNodes[k].icon:setInactive()
            end
            practiceModeController.patternIndex = practiceModeController.patternIndex + 1
            coroutine.yield(0.5)
        end
    function practiceModeController:draw()
        love.graphics.printf(practiceModeController.formattedText, 32 - defaultFont:getWidth(practiceModeController.text)/2, 16, 48, "left")
        if plr.frozen then
            love.graphics.setColor(global_pallete.light_blue_color)
            love.graphics.circle("line", plr.x, plr.y, 7 + math.sin(timeElapsed * 2) * 2)
        end
    end
    practiceModeController:startCoroutine(
        function()
            for k = 1,numPatterns do
                practiceModeController.demonstrateAttack()
                coroutine.yield(1)
                practiceModeController.practiceAttack()
            end
            coroutine.yield(1.5)
            practiceModeController.bossTalksToYou({x=32,y=20,text="great work!",speakerIndex = 1})
            coroutine.yield(1)
            practiceModeController.bossTalksToYou({x=32,y=20,text="now. . .",speakerIndex = 1})
            coroutine.yield(1)
            practiceModeController.bossTalksToYou({x=32,y=6,text="hit me as\nhard as you\ncan.",speakerIndex = 1})
            coroutine.yield(3)
            cutsceneObj.currentText = ""
            coroutine.yield(1)
            boss.currentHP = 3
        end, "fullPracticeMode")
end

function prePhase1Cutscene(gameState)
    flashIntro()
    MusicManager.playTrack("BattleTrackDay2V1", 1)
    resetPersistentBossData()
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true

    -- need a total of 11.29 seconds of cutscene to get the music to sync up perfectly with the text intro
    local cutsceneLines = {
        {x=44,y=16,text="well done!",speakerIndex = 1, totalDelay = 2.5},
        {x=40,y=16,text="i think\nyou're ready.",speakerIndex = 1, totalDelay = 2.8},
        {x=34,y=8,text="let's put that\npractice to\nthe test.",speakerIndex = 1, totalDelay = 3.55}
    }
    local cutscene = DialogueSystem.createCutscene(gameState,cutsceneLines,{bossTalkColor}, {"MidTalk"},1.3,1)
    cutscene:runFullCutscene()
end

function bossPhase1Intro(gameState)
    coolTextIntro("BATTLE PHASE", 0.706)
end

function bossFightPhase1(gameState)
    flashIntro()
    MusicManager.setVolume(0.75)
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    if gameState.state.justGotBackUp then
        plr.x = clamp(5, gameState.state.playerKnockdownXPosition, 59)
    end
    plr:setActive() -- make sure to do this so the components get set active
    plr.fighting = true
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 40, false)
    if gameState.state.justGotBackUp then
        boss.x = clamp(5, gameState.state.bossKnockdownXPosition, 59)
    end
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    boss.fighting = true
    local startingState = 0
    if gameState.state.bossStateIndex ~= -1 then
        startingState = gameState.state.bossStateIndex
    end
    boss.stateSelector.stateIndex = startingState
    boss.stateSelector:go()
end

function prePhase2Cutscene(gameState)
    flashIntro()
    MusicManager.playTrack("BattleTrackDay2V1", 1)
    resetPersistentBossData()
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true

    local cutsceneLines = {
        {x=44,y=16,text="nice work!",speakerIndex = 1, totalDelay = 2},
        {x=40,y=4,text="all that\npractice is\npaying off.",speakerIndex = 1, totalDelay = 3.5},
        {x=42,y=16,text="now. . .",speakerIndex = 1, totalDelay = 2},
        {x=40,y=16,text="let's mix\nit up.",speakerIndex = 1, totalDelay = 2}
    }
    local cutscene = DialogueSystem.createCutscene(gameState,cutsceneLines,{bossTalkColor}, {"MidTalk"},1,1)
    cutscene:runFullCutscene()
end

function bossPhase2Intro(gameState)
    coolTextIntro("PHASE 2", 0.706)
end

function bossFightPhase2(gameState)
    flashIntro()
    MusicManager.playTrack("BattleTrackDay2V1", 1)
    MusicManager.setVolume(0.8)
    createBackground()

    local plr = createPlayer(16, gameState.state.floorHeight)
    if gameState.state.justGotBackUp then
        plr.x = clamp(5, gameState.state.playerKnockdownXPosition, 59)
    end
    plr:setActive() -- make sure to do this so the components get set active
    plr.fighting = true
    gameState.state.plr = plr

    local boss = createBoss(48, gameState.state.floorHeight, 50, true)
    if gameState.state.justGotBackUp then
        boss.x = clamp(5, gameState.state.bossKnockdownXPosition, 59)
    end
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    boss.fighting = true
    local startingState = 0
    if gameState.state.bossStateIndex ~= -1 then
        startingState = gameState.state.bossStateIndex
    end
    boss.stateSelector.stateIndex = startingState
    boss.stateSelector:go()
end

function finalCutscene(gameState)
    flashIntro()
    MusicManager.stopAllTracks()
    resetPersistentBossData()
    createBackground()

    local plr = createPlayer(32, gameState.state.floorHeight)
    plr:setActive() -- make sure to do this so the components get set active
    gameState.state.plr = plr

    local boss = createBoss(52, gameState.state.floorHeight, 10000, false)
    boss.flip = boss.x > 32 and -1 or 1
    boss.target = plr
    gameState.state.boss = boss
    plr.frozen = true
    plr.lineEmitter = ParticleSystem.createEmitter(50, true, GameObjects.DrawLayers.DEATHLAYER_2)
    plr.deflectPop = createCircularPop(0,0,global_pallete.black_color, 3, 8, 1, 0.25, 0.2,GameObjects.DrawLayers.DEATHLAYER_2)
    local otherEmitter = ParticleSystem.createEmitter(50, false, GameObjects.DrawLayers.IGNORE_DT)
    local makeAHypeRect =
        function(yPos)
            local hypeRect = createScalingRectangle("horizontal", yPos + 3, 8, global_pallete.black_color, 0.15, GameObjects.DrawLayers.IGNORE_DT)
            hypeRect:setActive()
            SoundManager.playSound("HypeRectangle")
            SoundManager.playSound("HypeParticles")
            Camera.shake(0.35)
        end
    local sickRoutineObj = GameObjects.newGameObject(-1,0,0,0,true, GameObjects.DrawLayers.IGNORE_DT)
    sickRoutineObj.go =
        function()
            sickRoutineObj:startCoroutine(
                function()
                    Animation.changeAnimation(boss, "slamprep_1")
                    dashToPosition(16, 16, 6)
                    boss.flip = 1
                    coroutine.yield(2)
                    Animation.changeAnimation(boss, "slam")
                    plr.x = plr.x + 6
                    dashToPosition(plr.x - 10, plr.y - 12, 2)
                    plr.flip = -1
                    Animation.changeAnimation(plr, "deflect_success")
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess1", 0.7, 1.3)
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess2", 0.7, 1.3)
                    SoundManager.playSoundRandomizedPitch("DeflectSuccess3v2", 0.7, 1.3)
                    local tX, tY = plr.x + plr.flip * 3, plr.y - 3
                    ParticleSystem.lineBurst(tX, tY, 10, 400, 400, global_pallete.black_color, 6, 0.95, 0.8, false, 0.5, plr.lineEmitter, true)
                    plr.deflectPop.x, plr.deflectPop.y = tX, tY
                    plr.deflectPop:setActive()
                    Camera.jiggle(plr.flip * 0.3, 0)
                    coroutine.yield(0.1)
                    gameState.timeScale = 0
                    local flash = createScreenFlash(global_pallete.white_color, 10, false, GameObjects.DrawLayers.DEATHLAYER_1)
                    flash:setActive()
                    local fakeBoss = GameObjects.newGameObject(2, boss.x, boss.y, boss.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
                    fakeBoss.flip = boss.flip
                    local fakePlr = GameObjects.newGameObject(1, plr.x, plr.y, plr.spr, true, GameObjects.DrawLayers.DEATHLAYER_2)
                    fakePlr.flip = plr.flip
                    fakeBoss.color = global_pallete.black_color
                    fakePlr.color = global_pallete.black_color
                    SoundManager.playSound("WhitenBackground")
                    local lines = velocityLines(32, 8, math.rad(90), 500, nil, GameObjects.DrawLayers.IGNORE_DT)
                    local lines2 = velocityLines(32, 56, math.rad(270), 500, nil, GameObjects.DrawLayers.IGNORE_DT)
                    coroutine.yield(0.454*2)
                    lines:setInactive()
                    lines2:setInactive()
                    Camera.ignoreDT = true
                    worldSpaceText("PRACTICE", 32, 3, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    makeAHypeRect(6)
                    ParticleSystem.burst(32, 4, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    coroutine.yield(0.454)
                    worldSpaceText("MAKES", 12, 28, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    makeAHypeRect(28)
                    ParticleSystem.burst(12, 28, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    coroutine.yield(0.454/2)
                    worldSpaceText("YOU", 56, 28, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    makeAHypeRect(28)
                    ParticleSystem.burst(52, 28, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    coroutine.yield(0.454/2)
                    worldSpaceText("TOUGH", 32, 56, global_pallete.black_color, GameObjects.DrawLayers.DEATHLAYER_2)
                    ParticleSystem.burst(32, 56, 10, 300, 400, global_pallete.black_color, 4, 0.95, 0.75, false, 0.75, otherEmitter)
                    makeAHypeRect(58)
                    coroutine.yield(0.454*4)
                    Camera.ignoreDT = false
                    gameState.goToNextLevel()
                end
            , "sickRoutine")
        end

        -- need a total of 14.545 seconds of cutscene to get the music to sync up perfectly with the text intro
    local cutsceneLines = {
        {x=40,y=10,text="great first\nday!",speakerIndex = 1, totalDelay = 2},
        {x=36,y=6,text="looking\nforward to\ntomorrow.",speakerIndex = 1, totalDelay = 3},
        {x=28,y=10,text="what happens\ntomorrow?",speakerIndex = 2, totalDelay = 2.5},
        {x=40,y=10,text="same thing.\nwe practice.",speakerIndex = 1, totalDelay = 3, preFcn=function() MusicManager.playTrack("CalmTrackDay2V2",1 )end},
        {x=40,y=10,text="day in,\nday out.",speakerIndex = 1, totalDelay = 2.5},
        {x=16,y=16,text=". . .",speakerIndex = 2, totalDelay = 2},
        {x=24,y=10,text="really?\nbut why?",speakerIndex = 2, totalDelay = 2.8},
        {x=40,y=16,text="you tell me.",speakerIndex = 1, totalDelay = 3.045},
        {x=34,y=8,text=" ",speakerIndex = 1, totalDelay = 4, preFcn=sickRoutineObj.go},
    }
    local cutscene = DialogueSystem.createCutscene(gameState,cutsceneLines,{bossTalkColor, {0.894, 0.580, 0.227, 1}}, {"MidTalk", "PlayerTalk"},1.3,1)
    cutscene:runFullCutscene()
end

function postGameScreen(gameState)
    local blackScreen = GameObjects.newGameObject(-1,0,0,0,true,GameObjects.DrawLayers.PLAYER)
    function blackScreen:draw()
        love.graphics.setColor(global_pallete.black_color)
        love.graphics.rectangle("fill", -10, -10, 100, 100)
    end

    local makeAHypeRect =
        function(yPos)
            local hypeRect = createScalingRectangle("horizontal", yPos + 3, 8, global_pallete.white_color, 0.15, GameObjects.DrawLayers.PARTICLES)
            hypeRect:setActive()
            SoundManager.playSound("HypeRectangle")
            SoundManager.playSound("HypeParticles")
            ParticleSystem.burst(32, yPos, 10, 300, 400, global_pallete.white_color, 4, 0.95, 0.75, false, 0.75)
            Camera.shake(0.3)
        end

    local practiceColorMapping = {
        ["S"] = {0,0,1,1},
        ["A+"] = {1,1,0,1},
        ["A"] = {1,1,0,1},
        ["B+"] = {0,1,0,1},
        ["B"] = {0,1,0,1},
        ["C+"] = {1,0.6,0,1},
        ["C"] = {1,0.6,0,1}
    }

    blackScreen:startCoroutine(function()
        local beat = 0.454
        makeAHypeRect(4)
        worldSpaceText("THE END", 32, 4, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        coroutine.yield(beat * 3)
        makeAHypeRect(10)
        worldSpaceText("PRACTICE GRADES", 32, 10, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        coroutine.yield(beat * 3)
        local grades = gameState.state.practiceGrades
        local gradeSpacing = 6
        local xStart = 32 - (#grades-1)/2 * gradeSpacing
        for k = 1,#grades do
            local currentGrade = grades[k]
            local color = practiceColorMapping[currentGrade]
            if not color then
                color = global_pallete.white_color
            end
            local xPos = xStart + (k-1) * gradeSpacing
            worldSpaceText(currentGrade, xPos, 16, color, GameObjects.DrawLayers.BOSS)
            if currentGrade == "S" then
                ParticleSystem.burst(xPos, 18, 15, 300, 400, color, 5, 0.95, 0.8, false, 0.5, nil, true)
                SoundManager.playSound("HypeParticles")
                SoundManager.playSound("DeflectSuccess3v2")
                coroutine.yield(beat * 2)
            else
                ParticleSystem.burst(xPos, 18, 10, 300, 400, color, 5, 0.95, 0.8, false, 0.5, nil, false)
                SoundManager.playSound("HypeParticles")
                coroutine.yield(beat)
            end
        end
        coroutine.yield(beat * 2)
        makeAHypeRect(26)
        worldSpaceText("BATTLE PHASE", 32, 26, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        coroutine.yield(beat * 2)
        if gameState.state.numDeaths == 0 then
            local txt = worldSpaceText("UNDEFEATED", 32, 35, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
            local str = "UNDEFEATED"
            txt.text = ""
            for k = 1,10 do
                txt.text = string.sub(str,1,k)
                ParticleSystem.burst(12 + (k-1) * 4, 37, 4, 250, 350, global_pallete.white_color, 3, 0.9, 0.8, false, 0.4)
                SoundManager.playSoundRandomizedPitch("Hit", 0.5 + k*0.05, 0.51 + k*0.05)
                Camera.shake(0.3)
                coroutine.yield(beat / 2)
            end
            coroutine.yield(beat)
            ParticleSystem.burst(16, 37, 10, 350, 350, global_pallete.white_color, 4, 0.95, 0.75, false, 0.75, nil, true)
            SoundManager.playSound("HypeParticles")
            SoundManager.playSoundRandomizedPitch("DeflectSuccess3v2", 0.75, 0.8)
            Camera.shake(0.3)
            coroutine.yield(beat / 2)
            ParticleSystem.burst(48, 37, 10, 350, 350, global_pallete.white_color, 4, 0.95, 0.75, false, 0.75, nil, true)
            SoundManager.playSound("HypeParticles")
            SoundManager.playSoundRandomizedPitch("DeflectSuccess3v2", 1, 1.2)
            coroutine.yield(beat / 2)
        else
            worldSpaceText("got back up", 32, 32, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
            coroutine.yield(beat * 2)
            if gameState.state.numDeaths == 1 then
                worldSpaceText(gameState.state.numDeaths .. " time", 32, 38, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
            else
                worldSpaceText(gameState.state.numDeaths .. " times", 32, 38, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
            end
        end

        coroutine.yield(beat * 4)
        worldSpaceText("ty for playing", 32, 44, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        worldSpaceText("by abhi sundu", 32, 50, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        worldSpaceText("z: title", 32, 56, global_pallete.white_color, GameObjects.DrawLayers.BOSS)
        blackScreen.canGoToTitle = true
    end, "postGameScreen")
    function blackScreen:update(dt)
        if blackScreen.canGoToTitle and (Input.getMappedButtonPressed("attack") or Input.getMappedButtonPressed("select")) then
            goToTitleScreen()
        end
    end
end

function resetPersistentBossData()
	gameState.state.bossHealthOnDeath = 0
    gameState.state.bossHealthPreviousAttempt = 0
    gameState.state.justGotBackUp = false
    gameState.state.playerKnockdownXPosition = 0
	gameState.state.bossKnockdownXPosition = 0
    gameState.state.bossStateIndex = -1
end

function resetGameData()
    resetPersistentBossData()
    gameState.state.numDeaths = 0
    gameState.state.practiceGrades = {"N","N","N","N"}
end

function createLocalPracticeNode()
    local node = GameObjects.newGameObject(3,0,0,5,false,GameObjects.DrawLayers.PARTICLES)
    node.icon = GameObjects.newGameObject(3,0,0,0,false,GameObjects.DrawLayers.PARTICLES)
    function node:getLocallyGraded(numMistakes)
        if numMistakes >= 2 then
            node.icon.spr = 4
            SoundManager.playSound("RedX")
        elseif numMistakes == 1 then
            node.icon.spr = 3
            SoundManager.playSound("OrangeLine")
        else
            node.icon.spr = 2
            SoundManager.playSound("GreenCheck")
        end
        ParticleSystem.burst(node.x, node.y, 10, 350, 350, global_pallete.white_color, 4, 0.95, 0.8, false, 0.5, nil, true)
        node.icon.x, node.icon.y = node.x, node.y
        node.icon:setActive()
    end
    return node
end

function createPatternGradeObj(x, y)
    local patternGrade = GameObjects.newGameObject(3, x, y, 6, true, GameObjects.DrawLayers.POSTCAMERA)
    local trueGrade = GameObjects.newGameObject(-1,x,y,0,true,GameObjects.DrawLayers.POSTCAMERA)
    trueGrade.grade = ""
    trueGrade.color = global_pallete.white_color
    function trueGrade:draw()
        love.graphics.setColor(trueGrade.color)
        love.graphics.print(self.grade, self.x-2,self.y-3)
    end
    patternGrade.trueGrade = trueGrade
    return patternGrade
end

function loadingScreen(gameState)
    LoadingScreen.loadingScreen(gameState)
end

function createTargetDummy()
    local dummy = GameObjects.newGameObject(3,32,gameState.state.floorHeight,7,false,GameObjects.DrawLayers.PLAYER)
    dummy.squashStretcher = createSquashStretcher(dummy, 10)
    GameObjects.attachComponent(dummy, dummy.squashStretcher)
    Collision.addCircleCollider(dummy, 5, Collision.Layers.PLAYER, {Collision.Layers.HURTER})
    dummy.Collider.onCollisionEnter =
        function(dummy, other)
            if other.Collider.layer == Collision.Layers.HURTER then
                dummy.squashStretcher:squashStretch(2,2)
                ParticleSystem.burst(dummy.x, dummy.y, 6, 200, 300, global_pallete.white_color, 3, 0.95, 0.8, false, 0.5)
                Camera.shake(0.3)
                SoundManager.playSoundRandomizedPitch("Hit", 0.7, 1.3)
                other:die(dummy)
            end
        end
    return dummy
end
