local SceneMenu = {}
local titleIMG
local transitioning = false
local showPress = false
local timer

function SceneMenu:init()
    titleIMG = love.graphics.newImage("image/title_screen.png")
    timer = Timer.new()
end

function SceneMenu:enter()
    transitioning = false
    timer:clear()
    timer:every(0.8, function()
        showPress = not showPress
    end)
end

function SceneMenu:keyreleased(key)
    if ANY_BTNS[key] then
        self:enterMainGame()
    end
end

function SceneMenu:enterMainGame()
    if transitioning then return end
    transitioning = true
    dotTransition:show()
    soundMgr:playPressBtn()
    Timer.after(0.3, function()
        soundMgr:playBgm()
        Gamestate.pop()
    end)
end

function SceneMenu:update(dt)
    dotTransition:update(dt)
    timer:update(dt)
end

function SceneMenu:draw()
    -- resPush:start()
    resetColor()
    love.graphics.draw(titleIMG,0,0,0,2,2) 
    if showPress then
        resetColor(PCOLOR.D_BLUE)
        love.graphics.rectangle("fill", 36*2, 72*2, 88*2, 30 )
    end
    dotTransition:draw()
    -- resPush:finish()
end

return SceneMenu