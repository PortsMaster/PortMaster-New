local PanelButton = {}

local timer, btnUpm, btnDown, btnLeft, btnRight

function PanelButton:init()
    timer = Timer.new()
    btnUp = love.graphics.newImage("image/panel_bottom_btn1.png")
    btnDown = love.graphics.newImage("image/panel_bottom_btn2.png")
    btnLeft = btnUp
    btnRight = btnUp
end

function PanelButton:enter()
end

local draw = love.graphics.draw
function PanelButton:draw()
    draw(btnLeft, 0,170-10,0,2,2)
    draw(btnRight, 320,170-10,0,-2,2)
end

local isDown = love.keyboard.isDown
function PanelButton:update(dt)
    timer:update(dt)
    btnLeft = btnUp
    btnRight = btnUp
    if isDown(BTN.LEFT) then
        btnLeft = btnDown
    end
    if isDown(BTN.RIGHT) then
        btnRight = btnDown
    end
end

return PanelButton