-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

local play = {}
local states = nil

local pinball = require ("nova-pinball-engine")
local targetManager = require("modules.targets")
local bumperManager = require("modules.bumpers")
local mission = require("modules.mission")
local spriteStates = spriteManager:new()
local led = require("modules.led-display")
local pausedScreen = require("modules.paused-screen")
local sprites = { }
local sounds = {}

-- Define the score points
local points = {}
points.gravityLock = 250000
points.kicker = 7500
points.bumper = 5000
points.wordBonus = 12500
points.dotTargets = 1000
points.missionGoal1 = 10000  -- evolve red giant
points.missionGoal2 = 12500  -- hydrogen released
points.missionGoal3 = 15000  -- fusion stage 1
points.missionGoal4 = 17500  -- fusion stage 2
points.missionGoal5 = 22500  -- collapse star
points.missionGoal6 = 500000 -- super gravity bonus (reset)
points.missionGoal7 = 150000 -- multi-ball bonus (extra mission)

-- Stores a collection of all the targets on the table.
local targets = {}

-- The main resource loading point for this pinball game
function play:load()

    play.setupPlayStates()
    play.loadSprites()
    play.loadSounds()

    -- Set graphics
    love.graphics.setBackgroundColor(0, 0, 0)

    -- Load the table layout into the pinball engine
    play.loadTableLayout()
    play.setupStartingValues()

    play.setupBackgroundImage()
    play.setupSpritePositions()
    play.setupBumpers()
    play.loadTargets()
    play.setupMission()
    play.setupWallsCanvas()

    -- Pre-game welcome
    led:add("Welcome to Nova Pinball!", "long")
    led:add("Hit space to launch the ball", "sticky")

    play.flashAllTargets()
end

function play:update(dt)
    states:update(dt)
    play.updateLedDisplayMessages(dt)

    -- Update flashing targets
    targets.wordTarget:update(dt)
    targets.leftTargets:update(dt)
    targets.rightTargets:update(dt)
    targets.rampLights:update(dt)
    targets.bumpers:update(dt)
    
    if (states:on("preview")) then
        led:update(dt)
        if (play.previewPosition > -(pinball.table.size.height-scrHeight)) then
            play.previewPosition = play.previewPosition - (dt*50)
            pinball.cfg.translateOffset.y = play.previewPosition
        end
    elseif (states:on("game over")) then
        led:update(dt)
        -- Scroll the camera up until the table is out of view
        if (play.previewPosition < pinball.table.size.height) then
            play.previewPosition = play.previewPosition + (dt*150)
            pinball.cfg.translateOffset.y = play.previewPosition
        else
            play.quitToScores()
        end
    elseif (states:on("play")) then
        led:update(dt)
        play.updateShakeAnimation(dt)
        pinball:update(dt)
        bumperManager:update(dt)
        spriteStates:update(dt)
        mission:update(dt)
        play.updateNudgeCounters(dt)
        play.updateSafemode(dt)
    elseif (states:on("paused")) then
        pausedScreen:update(dt)
    end

end

function play:keypressed(key)
    if (states:on("preview")) then
        if (key == "space") then play.launchBall(true) end
        if (key == "escape") then mainstate:set("menu") end
    elseif (states:on("play")) then
        if (key == "escape") then states:set("paused") end
        if (key == "lshift" or key == "left") and (not play.tilt) then
            aplay(sounds.leftFlipper)
            pinball:moveLeftFlippers()
        end
        if (key == "rshift" or key == "right") and (not play.tilt) then
            aplay(sounds.rightFlipper)
            pinball:moveRightFlippers()
        end
        if (key == "space") then play.launchBall() end
    elseif (states:on("paused")) then
        if (key == "space") then states:set("play") end
        if (key == "escape") then mainstate:set("menu") end
        pausedScreen:keypressed(key)
    elseif (states:on("game over")) then
        -- Quick escape to the high score list on game over
        if (key == "escape" or key == "space") then
            play.quitToScores()
        end
    end

    -- DEBUG Functions
    if DEBUG then
        if key == "f2" then
            mission:skipWait()
            mission:check(mission:nextTarget())
        elseif key == "f10" then
            play.endGame()
        elseif key == "f1" then
            pinball:newBall()
        elseif key == "f3" then
            play.activateBallSaver()
        end
    end
end

function play:keyreleased(key)
    if (key == "lshift" or key == "left") then pinball:releaseLeftFlippers() end
    if (key == "rshift" or key == "right") then pinball:releaseRightFlippers() end

    -- Apply any config settings
    if (key == "enter" or key == "return" or key == "space") then
        -- Pinball engine camera view
        play.positionDrawingElements()
        -- LED and Lights (1 is LED, 2 is lights, 3 is both
        play.ledHints = (cfg:get("missionHints") == 1 or cfg:get("missionHints") == 3)
        local flashHints = (cfg:get("missionHints") == 2 or cfg:get("missionHints") == 3)
        for _, target in pairs(targets) do
            target.flashingEnabled = flashHints
        end
    end
end

function play:draw()

    -- Reset drawing color
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor (1, 1, 1, 1)

    -- Center in the screen
    love.graphics.translate(play.leftAlign, play.topAlign)

    -- Fix the coordinate system so that we draw relative to the table.
    pinball:setCamera()

    -- Draw the background image. It has a 20px border we account for.
    love.graphics.setColor(1, 1, 1, 1)
    sprites.background:draw()

    -- Draw targets and sprites
    targets.wordTarget:draw()
    targets.leftTargets:draw()
    targets.rightTargets:draw()
    targets.rampLights:draw()
    spriteStates:draw()

    -- Draw the pinball components
    pinball:draw()

    -- Draw the walls (at the top-most table point y1, that may be negative)
    love.graphics.draw(play.wallCanvas, 0, pinball.table.size.y1)

    -- Draw bumpers
    targets.bumpers:draw()

    -- Draw the launch cover over the pinball components
    -- (reposition the camera as the pinball module resets it after it draws)
    love.graphics.setColor (1, 1, 1, 1)
    sprites.launchCover:draw()

    -- Draw the status box
    love.graphics.origin()
    play.drawStatusBar()

    -- Draw the LED display
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, scrHeight - led.size.h, scrWidth, led.size.h)
    love.graphics.setFont(largeFont)
    love.graphics.setColor(50/256, 1, 50/256, 1)
    led:draw()

    -- Simple text overlays
    if (states:on("paused")) then
        pausedScreen:draw()
    elseif (states:on("game over")) then
        printShadowText("GAME OVER", 200, {1, 0.5, 1, 200/256})
    end

end

function play:resize(w, h)
    play.positionDrawingElements()
    pinball:resize (w, h)
end

-- Returns if a game is in progress
function play.gameInProgress()
    return states:on("play") or states:on("paused")
end

-- Set the game over state and position the camera for upward scroll
function play.endGame()
    pinball:resetCamera()
    states:set("game over")
    play.previewPosition = -(pinball.table.size.height-scrHeight)
end

-- Register the current score and quit to the scores list
function play.quitToScores()
    scores:register(play.score)
    play.resetGame()
    mainstate:set("menu")
    menu.state:set("scores")
end

function play.drawStatusBar()
    local height = 20
    
    if play.isSafe() then
        local g = play.safeMode*(1/play.safeModePeriod)
        love.graphics.setColor(0, g, 0, 155/256)
    else
        love.graphics.setColor(0, 0, 0, 1)
    end
    
    love.graphics.rectangle("fill", 0, 0, scrWidth, height)
    love.graphics.setFont(smallFont)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Balls:" .. play.balls, play.ballStatXPosition, 2)
    love.graphics.print("Score:" .. play.scoreFormatted, 10, 2)
    
    if play.isSafe() then
        local g = play.safeMode*(1/play.safeModePeriod)
        love.graphics.setColor(g, g, 0, 1)
        love.graphics.print("BALL SAVER", play.ballStatXPosition-200, 2)
    end
    
    if (DEBUG) then
        love.graphics.setColor(1, 100/256, 100/256, 1)
        love.graphics.print("DEBUG", 340, 30)
    end
end

function play.updateShakeAnimation(dt)
    if (play.nudgeOffset > 0) then
        pinball.cfg.translateOffset.y = play.nudgeOffset
        play.nudgeOffset = play.nudgeOffset - (play.nudgeOffset / 2)
    end
end

-- Set flashing on all targets
function play.flashAllTargets()
    for _, targetGroup in pairs(targets) do
        targetGroup:reset()
        targetGroup:flash(nil)
    end
end

-- Reset flashing and status on all targets
function play.resetAllTargets()
    for _, targetGroup in pairs(targets) do
        targetGroup:reset()
    end
end

function play.positionDrawingElements()
    led.size.w = scrWidth
    led.size.h = 36
    led.position.y = scrHeight - led.size.h
    play.ballStatXPosition = scrWidth - smallFont:getWidth("Balls: 0") - 10

    -- Set the camera mode from the game config
    pinball.cfg.cameraFollowsBall = (cfg:get("cameraFollowsBall") == 1) and true or false
    -- Recalculate the pinball scales
    pinball:resize(scrWidth, scrHeight)
    -- Apply drawing offsets for each mode
    if (pinball.cfg.cameraFollowsBall) then
        play.leftAlign = (scrWidth - pinball.table.size.width) / 2
        play.topAlign = 0
    else
        play.leftAlign = (scrWidth - (pinball.table.size.width * pinball.cfg.drawScale)) / 2
        -- Offset the top a little to draw past the stats bar
        play.topAlign = 45
        -- Scale the table a little smaller to account for the stats and LED bars
        pinball.cfg.drawScale = pinball.cfg.drawScale - 0.1
    end
end

-- Update the LED display every game loop
function play.updateLedDisplayMessages(dt)
  
    -- Count down until the next LED refresh
    play.missionStatusUpdateTime = play.missionStatusUpdateTime - dt
    
    -- Time to refresh the LED display with a new message
    if (play.missionStatusUpdateTime < 0 or dt == 0) then
        
        -- Reset the time until the next update (in seconds)
        play.missionStatusUpdateTime = 20
        
        -- A lookup of mission targets and their human readable texts
        local missionDescriptions = {
          ["nova word"]="Complete the NOVA word bonus",
          }
        
        -- A set of encouraging words while the mission state is waiting
        local waitingWords = {
            "Keep it up",
            "Looking good",
            "Don't drop that ball",
            "Hope you're enjoying Nova Pinball",
            "You are in the Zone"
          }
          
        -- Only when busy playing
        if (states:on("play")) then
          
            -- Display a hint of the next goal
            local title = mission:nextTarget()
          
            -- Show encouraging words while waiting on a goal
            if (title == "wait") then
                title = waitingWords[math.random(1, #waitingWords)]
            elseif (missionDescriptions[title]) then
                -- Display a hint of the next goal
                title = missionDescriptions[title]
            else
                -- A generic message if no descriptive text is available for this goal
                title = "Shoot for the " .. title
            end
            if (play.ledHints) then
                led:add(title)
            elseif (mission:nextTarget() == "wait") then
                -- Always show waiting messages
                led:add(title)
            end
        end
    end
end

function pinball.drawWall(points)
    -- Draw the table walls onto a canvas
    if (play.predraw) then
        -- Accommodate points that go into the negative Y-axiz
        local YInc = (pinball.table.size.y1 < 0) and pinball.table.size.y1*-1 or 0
        for i = 1, #points - 1, 2 do
            local yp = points[i+1] + YInc
            points[i+1] = yp
        end
        play.wallCanvas:renderTo( function()
            love.graphics.setLineWidth(6)
            love.graphics.setColor(55/256, 53/256, 140/256, 1)
            love.graphics.line(points)
            end
        )
    end
end

function pinball.drawBumper(tag, x, y, r)
    bumperManager:draw(tag, x, y)
end

function pinball.drawKicker(tag, x, y, points)
    bumperManager:draw(tag, x, y)
end

function pinball.drawTrigger(tag, points)
end

function pinball.drawFlipper(orientation, position, angle, origin, points)
    -- orientation is "left" or "right"
    -- position {x,y}
    -- angle is in radians
    -- origin {x,y} is offset from the physics body center
    -- points {} are polygon vertices

    ---- The flipper body is positioned relative to it's center, given
    ---- as the origin parameter. When we draw the image we offset by the
    ---- origin to line the top-left corner of our image with the body.
    love.graphics.setColor(1, 1, 1, 1)
    local scaleX = (orientation == "left") and 1 or -1  -- a negative scale flips the image horizontally
    love.graphics.draw(sprites.leftflipper.image, position.x, position.y, angle, scaleX, 1, origin.x, origin.y)
end

function pinball.drawBall(x, y, radius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(sprites.ball.image, x, y, 0, 1, 1, sprites.ball.ox, sprites.ball.oy)
end

-- Called when a ball has drained out of play.
-- The number of balls still in play are passed.
function pinball.ballDrained(ballsInPlay)
    aplay(sounds.drained)
    if play.isSafe() then
        play.launchBall(false)
        led:add("Ball Saved", "priority")
    elseif (ballsInPlay == 0) then
        led:add("Ball drained", "priority")
        play.balls = play.balls - 1
        if (play.balls == 0) then play.endGame() end
    end
end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
    aplay(sounds.blackHoleLock)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
    aplay(sounds.blackHoleRelease)
end

-- The ball made contact with a tagged component
function pinball.tagContact(tag, id)

    if (tag == "black hole" and not play.tilt) then
        local blackHoleVisible = spriteStates:item("black hole").visible
        if blackHoleVisible then
            local sign1 = math.random(-1, 1) < 0 and -1 or 1
            local sign2 = math.random(-10, 1) < 0 and -1 or 1   -- More chance to shoot up
            local v1 = (300 + math.random() * 600) * sign1
            local v2 = (300 + math.random() * 600) * sign2
            pinball:lockBall (id, sprites.blackhole.x, sprites.blackhole.y, 1, v1, v2)
            play.addScore(points.gravityLock)
            led:add("Gravity Lock Bonus")
        end
    end

    if (tag == "left bumper") then
        aplay(sounds.leftBumper)
        play.addScore(points.bumper)
    end
    if (tag == "middle bumper") then
        aplay(sounds.middleBumper)
        play.addScore(points.bumper)
    end
    if (tag == "right bumper") then
        aplay(sounds.rightBumper)
        play.addScore(points.bumper)
    end
    if (tag == "left kicker" or tag == "right kicker") then
        play.addScore(points.kicker)
        aplay(sounds.leftBumper)
    end
    if (tag == "left ramp" or tag == "right ramp") then
        aplay(sounds.ramp)
    end

    if (tag == "wall") then
        aplay(sounds.wall)
    end

    -- Switch targets on when their tag is hit
    targets.wordTarget:switchOn(tag)
    targets.leftTargets:switchOn(tag)
    targets.rightTargets:switchOn(tag)
    
    bumperManager:hit(tag)
    if (not play.tilt) then mission:check(tag) end
    
end

function play.onWordTargetSwitch(letter)
    aplay(sounds.target)
end

function play.onWordTargetComplete()
    play.addScore(points.wordBonus)
    aplay(sounds.wordBonus)
    led:add("Word Bonus")
    mission:check("nova word")
end

function play.onLeftTargetSwitch(letter)
    aplay(sounds.target)
end

function play.onLeftTargetsComplete()
    play.addScore(points.dotTargets)
    mission:check("left targets")
end

function play.onRightTargetsSwitch(letter)
    aplay(sounds.target)
end

function play.onRightTargetsComplete()
    play.addScore(points.dotTargets)
    mission:check("right targets")
end

function mission.onMissionCheckPassed(signal)
    -- Force to display the next goal
    play.updateLedDisplayMessages(0)

    -- Clear flashing targets
    targets.wordTarget:clearFlashing()
    targets.leftTargets:clearFlashing()
    targets.rightTargets:clearFlashing()
    targets.rampLights:clearFlashing()
    targets.bumpers:clearFlashing()

    -- Set new flashing targets
    targets.wordTarget:flash(mission:nextTarget())
    targets.leftTargets:flash(mission:nextTarget())
    targets.rightTargets:flash(mission:nextTarget())
    targets.rampLights:flash(mission:nextTarget())
    targets.bumpers:flash(mission:nextTarget())
end

function mission.onMissionAdvanced(title)

    if (title == "red giant") then
        play.addScore(points.missionGoal1)
        led:add("Star evolved into a Red Giant", "priority")
        spriteStates:item("red star"):setVisible(true):scale(0.1)
    elseif (title == "hydrogen release") then
        play.addScore(points.missionGoal2)
        led:add("Hydrogen released", "priority")
        aplay(sounds.hydrogenReleased)
    elseif (title == "fusion stage 1") then
        play.addScore(points.missionGoal3)
        led:add("Fusion first stage complete", "priority")
        spriteStates:item("wheel 1"):setVisible(true):scale(0.02)
        aplay(sounds.fusion1)
    elseif (title == "fusion stage 2") then
        play.addScore(points.missionGoal4)
        led:add("Fusion second stage complete", "priority")
        spriteStates:item("wheel 2"):setVisible(true):scale(0.02)
        aplay(sounds.fusion2)
    elseif (title == "fusion burn") then
        led:add("Fusion burning... ", "priority")
    elseif (title == "fusion unstable") then
        led:add("Fusion unstable", "priority")
        spriteStates:item("rays"):setVisible(true):scale(0.03)
    elseif (title == "collapse star") then
        play.addScore(points.missionGoal5)
        led:add("Star collapsing", "priority")
        led:add("Black hole created", "priority")
        play.showBlackHole()
    elseif (title == "wormhole") then
        led:clear()
        led:add("Wormhole Alert!", "priority,sticky")
        play.showWormhole()
    elseif (title == "reset") then
        play.addScore(points.missionGoal6)
        led:add("Supergravity Bonus", "priority")
        aplay(sounds.supergravityBonus)
        play.resetMissionSprites()
        play.showStarFlare()
        play.insertBonusMission()
    elseif (title == "bonus ball notice") then
        led:add("Matter Jetisson")
        led:add("Score another ball")
    elseif (title == "bonus ball") then
        play.addScore(points.missionGoal7)
        play.releaseBonusBall()
        play.activateBallSaver()
    end

    -- Update the led display instantly after a mission goal completes
    play.updateLedDisplayMessages(0)

end

function play.resetMissionSprites()
    -- hide the nova rings and black hole
    spriteStates:item("wheel 1"):scale(-1)
    spriteStates:item("wheel 2"):scale(-1)
    spriteStates:item("rays"):scale(-1)
    spriteStates:item("red star"):scale(-1)
    spriteStates:item("black hole"):scale(-1)
    -- hide the wormhole and restore gravity
    spriteStates:item("worm hole"):scale(-0.6)
    spriteStates:item("worm hole clouds"):scale(-0.6)
    -- Slowly retract the rays
    spriteStates:item("worm hole rays"):scale(-0.4)
    love.audio.stop(sounds.wormhole)
    aplay(sounds.wormholeClose)
end

function play.showStarFlare()
    spriteStates:item("star flare"):scale(0.04):setVisible(true)
    pinball:restoreGravity()
    pinball:setBallDampening(0)
end

function play.hideStarFlare()
    spriteStates:item("star flare"):scale(-0.5)
end

function play.showBlackHole()
    spriteStates:item("black hole"):setVisible(true):scale(0.2)
    aplay(sounds.blackHole)
end

function play.showWormhole()
    pinball:setGravity(-0.2)
    pinball:setBallDampening(1)
    spriteStates:item("worm hole rays"):setVisible(true):scale(0.1)
    spriteStates:item("worm hole"):setVisible(true):scale(0.3)
    spriteStates:item("worm hole clouds"):setVisible(true):scale(0.3)
    aplay(sounds.wormhole)
    aplay(sounds.timewarp)
    -- Activate safe mode during the wormhole
    play.activateBallSaver()
end

function play.insertBonusMission()
    if (not mission:has("bonus ball")) then
        -- Pre-mission notice
        local n = mission:define("bonus ball notice")
        n:wait(30)
        n:moveAfter("hydrogen release")
        -- Multi-ball mission
        local m = mission:define("bonus ball")
        m:on("left bumper")
        m:on("nova word")
        m:on("right bumper")
        m:on("nova word")
        m:on("middle bumper")
        m:on("left targets")
        m:on("right targets")
        m:moveAfter("bonus ball notice")
    end
end

function play.releaseBonusBall()
    led:add("Multi-ball Bonus")
    pinball:newBall()
end

function play.updateSafemode(dt)
    if play.isSafe() then
        play.safeMode = play.safeMode - dt
        if not play.isSafe() then
            play.deactivateBallSaver()
        end
    end
end

function play.isSafe()
    return play.safeMode > 0
end

function play.activateBallSaver()
    led:add("Safe Mode Activated")
    play.safeMode = play.safeModePeriod
end

function play.deactivateBallSaver()
    play.safeMode = 0
    led:add("Safe Mode Off")
end

function play.addScore(amount)
    if (not play.tilt) then
        play.score = play.score + amount
        -- store a thousand-formatted value
        local formatted = play.score
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then break end
        end
        play.scoreFormatted = formatted
    end
end

function play.launchBall(firstLaunch)
    if (firstLaunch) then
        play.tilt = false
        led:clear()
        -- Stop the pre-launch scroll effect
        pinball.cfg.translateOffset.y = 0
        -- Switch to the play game state
        states:set("play")
        -- Display the LED message
        led:add("Make the star go Nova", "priority")
        -- Light up the first target (the mission check callback won't fire at this point as no goals are met yet)
        play.resetAllTargets()
        targets.wordTarget:flash("nova word")
        -- First ball gets a safe period
        --play.activateBallSaver()
        -- Play the launch sound
        aplay(sounds.launch)
        pinball:newBall()
    else
        -- Launch another ball, or shake the table
        if (#pinball.bodies.balls == 0) then
            pinball:newBall()
            -- Reset tilt and nudges
            play.tilt = false
            play.nudgeCount = 0
            aplay(sounds.launch)
        else
            if (not play.tilt) then
                pinball:nudge(0, 0, -100, 0)
                play.nudgeOffset = 20
                play.nudgeCount = play.nudgeCount + 1
                if (play.nudgeCount == play.nudgeThreshhold) then
                    play.tilt = true
                    led:add("TILT!", "priority,sticky")
                end
                aplay(sounds.nudge)
            end
        end
    end
end

function play.updateNudgeCounters(dt)
    if (play.nudgeCount > 0) then
        play.nudgeTimer = play.nudgeTimer - dt
        if (play.nudgeTimer < 0) then
            -- Decrease the nudge count
            play.nudgeCount = play.nudgeCount - 1
            play.nudgeTimer = play.nudgeCooldown
        end
    end
end

function play.resetGame()
    -- Reposition the camera to default
    play.previewPosition = 0
    -- Reset mission progress and sprites
    play.setupMission()
    play.resetMissionSprites()
    play.hideStarFlare()
    -- Clear score and ball count
    play.score = 0
    play.scoreFormatted = "0"
    play.balls = 6
    pinball:newBall()
    -- Prepare for the next game:
    led:clear()
    led:add("Welcome to Nova Pinball!", "long")
    led:add("Hit space to launch the ball", "sticky")
    play.flashAllTargets()
    states:set("preview")
end


-- // SETUP AND LOAD FUNCTIONS


-- Loads the table layout from file
function play.loadTableLayout()
    local mydata, size = love.filesystem.read("nova.pinball", nil)
    local pickle = require("modules.pickle")
    local tableDefinition = pickle.unpickle(mydata)
    pinball:loadTable(tableDefinition)
end

-- Set up the states that manage play.
function play.setupPlayStates()
    states = stateManager:new()
    -- Preview scrolls the screen from top-to-bottom before play starts.
    states:add("preview")
    states:add("play")
    states:add("paused")
    states:add("game over")
    -- Set initial game state
    states:set("preview")
end

-- Load game sounds into the sounds table.
function play.loadSounds()
    sounds.leftFlipper = love.audio.newSource("audio/flipper.wav", "static")
    sounds.rightFlipper = love.audio.newSource("audio/flipper.wav", "static")
    sounds.wall = love.audio.newSource("audio/wall.wav", "static")
    sounds.leftBumper = love.audio.newSource("audio/bumper.wav", "static")
    sounds.middleBumper = love.audio.newSource("audio/bumper.wav", "static")
    sounds.rightBumper = love.audio.newSource("audio/bumper.wav", "static")
    sounds.wordBonus = love.audio.newSource("audio/wordbonus.wav", "static")
    sounds.target = love.audio.newSource("audio/target.wav", "static")
    sounds.ramp = love.audio.newSource("audio/ramp.wav", "static")
    sounds.launch = love.audio.newSource("audio/launch.wav", "static")
    sounds.wormhole = love.audio.newSource("audio/wormhole.wav", "static")
    sounds.wormhole:setLooping(true)
    sounds.wormholeClose = love.audio.newSource("audio/wormhole-close.wav", "static")
    sounds.timewarp = love.audio.newSource("audio/timewarp.wav", "static")
    sounds.blackHole = love.audio.newSource("audio/blackhole.wav", "static")
    sounds.blackHoleRelease = love.audio.newSource("audio/blackhole-release.wav", "static")
    sounds.blackHoleLock = love.audio.newSource("audio/blackhole-lock.wav", "static")
    sounds.nudge = love.audio.newSource("audio/nudge.wav", "static")
    sounds.hydrogenReleased = love.audio.newSource("audio/hydrogen-released.wav", "static")
    sounds.fusion1 = sounds.hydrogenReleased
    sounds.fusion2 = sounds.hydrogenReleased
    sounds.drained = love.audio.newSource("audio/ball-drained.wav", "static")
    sounds.supergravityBonus = love.audio.newSource("audio/supergravity-bonus.wav", "static")
end

-- Position the background image.
-- It is offset against the table top-left position (which may not be 0,0)
-- depending on how the table was designed.
function play.setupBackgroundImage()
    -- Position the background image
    local border = 20
    sprites.background.x = pinball.table.size.x1-border
    sprites.background.y = pinball.table.size.y1-border
    sprites.background.ox = 0   -- Position relative to top-left corner
    sprites.background.oy = 0   -- and not the center of the image
    -- Position the launch cover over the ball
    sprites.launchCover.x = pinball.table.ball.x
    sprites.launchCover.y = pinball.table.ball.y
end

-- Position all the animated sprites on the table.
-- The star, the flares, light rays, black hole and worm hole.
function play.setupSpritePositions()
      -- All these center around the black hole's position.
    local x, y = pinball:getObjectXY("black hole")
    sprites.blackhole.x = x
    sprites.blackhole.y = y
    sprites.wormholeRays.x = x
    sprites.wormholeRays.y = y
    sprites.wormhole.x = x
    sprites.wormhole.y = y
    sprites.wormholeClouds.x = x
    sprites.wormholeClouds.y = y
    sprites.rays.x = x
    sprites.rays.y = y
    sprites.star.x = x
    sprites.star.y = y
    sprites.starFlare.x = x
    sprites.starFlare.y = y
    sprites.redStar.x = x
    sprites.redStar.y = y
    sprites.wheel1.x = x
    sprites.wheel1.y = y
    sprites.wheel2.x = x
    sprites.wheel2.y = y
    sprites.wheel2.scale = -1

    -- Set up the sprite state manager.
    -- It handles scaling and rotation of these sprites.
    spriteStates:add("star", sprites.star)
    spriteStates:add("wheel 1", sprites.wheel1):setRotation(0.01):setScale(0)
    spriteStates:add("wheel 2", sprites.wheel2):setRotation(0.02):setScale(0)
    spriteStates:add("rays", sprites.rays):setRotation(-0.1):setScale(0)
    spriteStates:add("red star", sprites.redStar):setScale(0)
    spriteStates:add("star flare", sprites.starFlare):setRotation(-0.01):setScale(0)
    spriteStates:add("worm hole rays", sprites.wormholeRays):setRotation(0.1):setScale(0)
    spriteStates:add("worm hole", sprites.wormhole):setRotation(0.1):setScale(0)
    spriteStates:add("worm hole clouds", sprites.wormholeClouds):setRotation(0.6):setScale(0):setBlendmode("add")
    spriteStates:add("black hole", sprites.blackhole):setScale(0)
end

-- Set up the bumper manager.
-- It tracks bumpers by their tag names in the table.
function play.setupBumpers()
    bumperManager:add("left bumper", "images/bumper.png")
    bumperManager:add("middle bumper", "images/bumper.png")
    bumperManager:add("right bumper", "images/bumper.png")
    bumperManager:add("left kicker", "images/kicker.png")
    bumperManager:add("right kicker", "images/kicker.png", -1)
end

-- Set the starting values of all play variables.
function play.setupStartingValues()
      -- Calculated to center the table in the screen
    play.leftAlign = 0
    play.topAlign = 0
    -- Show hints of the next target in the LED display
    play.ledHints = true
    -- Pre-game scroll effect drawing offset
    play.previewPosition = 0
    -- Table nudge shake offset
    play.nudgeOffset = 0
    -- Tracks when to display the current mission goal on the LED display
    play.missionStatusUpdateTime = 0
    -- Safe-mode fires a new ball if any ball drains
    play.safeMode = 0
    -- How long safe-mode lasts (seconds)
    play.safeModePeriod = 30
    -- Position to draw the balls remaining stat line (gets updated on resize)
    play.ballStatXPosition = 0
    -- Store the current player score
    play.score = 0
    play.scoreFormatted = "0"
    play.balls = 6
    -- Tracks how many nudges the player did
    play.nudgeCount = 0
    -- Nudges before we tilt
    play.nudgeThreshhold = 3
    -- Cooldown before decreasing the nudge count
    play.nudgeCooldown = 5
    play.nudgeTimer = play.nudgeCooldown
    -- Too many nudges in a short time tilts the game (flippers turn off)
    play.tilt = false
    -- Pre-draw walls onto a canvas (performance optimization)
    play.predraw = true
    play.wallCanvas = nil
    -- Calculate positions of elements
    play.positionDrawingElements()
end

-- Draw the table walls on to a canvas 
-- We draw this canvas during play, instead of drawing each wall every loop.
-- This gives a good performance boost.
function play.setupWallsCanvas()
    play.wallCanvas = love.graphics.newCanvas(scrWidth, pinball.table.size.height)
    pinball:draw()
    play.predraw = false
end

-- Load game images and sprites
function play.loadSprites()
    sprites.background = loadSprite ("images/background.png")
    sprites.launchCover = loadSprite("images/launcher-cover.png")
    sprites.ball = loadSprite ("images/ball.png")
    sprites.leftflipper = loadSprite ("images/leftflip.png")
    sprites.blackhole = loadSprite("images/black-hole.png")
    sprites.wheel1 = loadSprite("images/nova-wheel.png")
    sprites.wheel2 = loadSprite("images/nova-wheel.png")
    sprites.rays = loadSprite("images/nova-rays.png")
    sprites.redStar = loadSprite("images/red-star.png")
    sprites.wormholeRays = loadSprite("images/wormhole-rays.png")
    sprites.wormhole = loadSprite("images/wormhole-background.png")
    sprites.wormholeClouds = loadSprite("images/wormhole-clouds.png")
    sprites.starFlare = loadSprite("images/star-flare.png")
    sprites.star = loadSprite("images/stable-star.png")
end

-- Set up the missions to complete
function play.setupMission()
    -- Define the mission goals
    mission:clear()
    mission:define("red giant"):on("nova word")
    mission:define("hydrogen release"):on("left ramp"):on("right ramp")
    mission:define("fusion stage 1"):on("left targets"):on("left ramp"):on("left bumper")
    mission:define("fusion stage 2"):on("right targets"):on("right ramp"):on("right bumper")
    mission:define("fusion burn"):wait(30):on("left ramp"):on("right ramp"):on("nova word")
    mission:define("fusion unstable"):wait(30):on("left ramp"):on("right ramp"):on("nova word")
    mission:define("collapse star"):on("left ramp"):on("right ramp"):on("nova word")
    mission:define("wormhole"):on("black hole"):on("black hole"):on("black hole")
    mission:define("reset"):wait(7)
    mission:start()
end

-- Load and position the words target, the left and right spot targets.
function play.loadTargets()

    -- "NOVA" word target
    targets.wordTarget = targetManager:new()
    targets.wordTarget.onComplete = play.onWordTargetComplete
    targets.wordTarget.onSwitch = play.onWordTargetSwitch
    -- N
    local x, y = pinball:getObjectXY("n")
    local target = targets.wordTarget:add("n")
    target.x = x
    target.y = y
    target:setOffImage("images/word-target-off.png")
    target:setOnImage("images/word-target-n.png")
    target:setFlashImage("images/word-target-flash.png")
    target:addToGroup("nova word")
    -- O
    local x, y = pinball:getObjectXY("o")
    local target = targets.wordTarget:add("o")
    target.x = x
    target.y = y
    target:setOffImage("images/word-target-off.png")
    target:setOnImage("images/word-target-o.png")
    target:setFlashImage("images/word-target-flash.png")
    target:addToGroup("nova word")
    -- V
    local x, y = pinball:getObjectXY("v")
    local target = targets.wordTarget:add("v")
    target.x = x
    target.y = y
    target:setOffImage("images/word-target-off.png")
    target:setOnImage("images/word-target-v.png")
    target:setFlashImage("images/word-target-flash.png")
    target:addToGroup("nova word")
    -- A
    local x, y = pinball:getObjectXY("a")
    local target = targets.wordTarget:add("a")
    target.x = x
    target.y = y
    target:setOffImage("images/word-target-off.png")
    target:setOnImage("images/word-target-a.png")
    target:setFlashImage("images/word-target-flash.png")
    target:addToGroup("nova word")

    -- Set up the left targets
    targets.leftTargets = targetManager:new()
    targets.leftTargets.onComplete = play.onLeftTargetsComplete
    targets.leftTargets.onSwitch = play.onLeftTargetSwitch
    -- left 1
    local x, y = pinball:getObjectXY("dot4")
    local target = targets.leftTargets:add("dot4")
    target.x = x
    target.y = y
    target:setOffImage("images/circle-target-off.png")
    target:setOnImage("images/circle-target-on.png")
    target:setFlashImage("images/circle-target-flash.png")
    target:addToGroup("left targets")
    -- left 2
    local x, y = pinball:getObjectXY("dot5")
    local target = targets.leftTargets:add("dot5")
    target.x = x
    target.y = y
    target:setOffImage("images/circle-target-off.png")
    target:setOnImage("images/circle-target-on.png")
    target:setFlashImage("images/circle-target-flash.png")
    target:addToGroup("left targets")

    -- Set up the right targets
    targets.rightTargets = targetManager:new()
    targets.rightTargets.onComplete = play.onRightTargetsComplete
    targets.rightTargets.onSwitch = play.onRightTargetsSwitch
    -- Right 1
    local x, y = pinball:getObjectXY("dot1")
    local target = targets.rightTargets:add("dot1")
    target.x = x
    target.y = y
    target:setOffImage("images/circle-target-off.png")
    target:setOnImage("images/circle-target-on.png")
    target:setFlashImage("images/circle-target-flash.png")
    target:addToGroup("right targets")
    -- Right 2
    local x, y = pinball:getObjectXY("dot2")
    local target = targets.rightTargets:add("dot2")
    target.x = x
    target.y = y
    target:setOffImage("images/circle-target-off.png")
    target:setOnImage("images/circle-target-on.png")
    target:setFlashImage("images/circle-target-flash.png")
    target:addToGroup("right targets")

    -- Add ramp indicator lights as pseudo targets (no hit interaction here)
    targets.rampLights = targetManager:new()
    -- Left
    local x, y = pinball:getObjectXY("left ramp slingshot")
    local target = targets.rampLights:add("left ramp")
    target.x = x
    target.y = y
    target:setOffImage("images/slingshot-off.png")
    --target:setOnImage("images/arrow-indicator-off.png")
    target:setFlashImage("images/slingshot-on.png")
    -- Right
    local x, y = pinball:getObjectXY("right ramp slingshot")
    local target = targets.rampLights:add("right ramp")
    target.x = x
    target.y = y
    target:setOffImage("images/slingshot-off.png")
    target:setFlashImage("images/slingshot-on.png")

    -- Bumper lights
    targets.bumpers = targetManager:new()
    -- Left
    local x, y = pinball:getObjectXY("left bumper")
    local target = targets.bumpers:add("left bumper")
    target.x = x
    target.y = y
    target:setFlashImage("images/bumper-flash.png")
    -- Middle
    local x, y = pinball:getObjectXY("middle bumper")
    local target = targets.bumpers:add("middle bumper")
    target.x = x
    target.y = y
    target:setFlashImage("images/bumper-flash.png")
    -- Right
    local x, y = pinball:getObjectXY("right bumper")
    local target = targets.bumpers:add("right bumper")
    target.x = x
    target.y = y
    target:setFlashImage("images/bumper-flash.png")

end

return play
