-- main.lua

-- require
-- require("helper/lovedebug")
-- local Moonshine = require("helper/moonshine")
SceneMain = require("SceneMain")
SceneMenu = require("SceneMenu")
SceneScore = require("SceneScore")
SceneWormHole = require("SceneWormHole")
Gamestate = require("helper/gamestate")
soundMgr = require("script/SoundManager")
-- resPush = require("helper/push")
dotTransition = require("script/DotTransition")

local gameWidth, gameHeight = 320, 240 -- fixed game resolution

function love.load()
    -- font
    initFont()
    soundMgr:init()
    dotTransition:init()
    love.graphics.setDefaultFilter("nearest","nearest")
    Gamestate.registerEvents()
    Gamestate.switch(SceneMain)
    Gamestate.push(SceneMenu)
    -- Signal.register(SG.TIMES_UP, onGameOver)
    -- resPush:setupScreen(gameWidth, gameHeight, gameWidth*2, gameHeight*2, {pixelperfect = true, fullscreen = false})
end

function love.keyreleased()
end

function love.update(dt)
    if love.keyboard.isDown(BTN.MENU) then
        love.event.quit()
    end
    Timer.update(dt)
    soundMgr:update(dt)
end

-- portmaster resolution patch
function love.draw()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scale = math.min(windowWidth / gameWidth, windowHeight / gameHeight)
    local translateX = (windowWidth - (gameWidth * scale)) / 2
    love.graphics.translate(translateX, 0)
    if translateX == 0 then
        love.graphics.setScissor(0, 0, gameWidth * scale, gameHeight * scale)
    end 
    love.graphics.scale(scale, scale)
end
