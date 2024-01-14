-- beloved v1.0
-- Copyright (c) 2020 Jeme
-- MIT License
-- Repo: https://github.com/TheJeme/beloved

beloved = {}

local belovedKey = 'h' -- Change this to any key you want to use for activating beloved mode.

local isbelovedMode
local font
local gw, gh
local mouse1Down, mouse2Down

function beloved:load()
  isbelovedMode = false
  font = love.graphics.newFont(12)
  gw = love.graphics.getWidth()
  gh = love.graphics.getHeight()
  mouse1Down = ""
  mouse2Down = ""
end

function beloved:draw()
  if(isbelovedMode) then    
    love.graphics.setFont(font)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(gw * 0.5, 0, gw * 0.5, gh)
    love.graphics.line(0, gh * 0.5, gw, gh * 0.5)
    
      --Mouseposition horizontal and vertical lines
    love.graphics.line(love.mouse.getX(), 0, love.mouse.getX(), gh)
    love.graphics.line(0, love.mouse.getY(), gw, love.mouse.getY())
    
      --Mouseposition x and y in percentage
    love.graphics.print("X: " .. string.format("%0.2f", love.mouse.getX() / gw * 100) .. "%", love.mouse.getX() + 10, love.mouse.getY() - 40)
    love.graphics.print("Y: " .. string.format("%0.2f", love.mouse.getY() / gh * 100) .. "%", love.mouse.getX() + 10, love.mouse.getY() - 20)
    
    love.graphics.print("FPS " .. love.timer.getFPS(), 0, 0)
    love.graphics.print("Mouse position: " .. love.mouse.getX() .. ", " .. love.mouse.getY(), 0, 15)
    if (mouse1Down == "LEFT" and mouse2Down == "RIGHT") then
      love.graphics.print("Mouse button down: " .. mouse1Down .. ", " .. mouse2Down, 0, 30)
    elseif (mouse1Down == "LEFT" or mouse2Down == "RIGHT") then
      love.graphics.print("Mouse button down: " .. mouse1Down .. mouse2Down, 0, 30)
    end
  end
end

function beloved:mousepressed(x, y, button)
  if (isbelovedMode) then
    if (button == 1) then
      print("Mouse left button pressed at " .. love.mouse.getX() .. ", " .. love.mouse.getY())
      mouse1Down = "LEFT"
    end
    if (button == 2) then
      print("Mouse right button pressed at " .. love.mouse.getX() .. ", " .. love.mouse.getY())
      mouse2Down = "RIGHT"
    end
  end
end

function beloved:mousereleased(x, y, button)
  if (isbelovedMode) then
    if button == 1 then
      mouse1Down = ""
    end
    if button == 2 then
      mouse2Down = ""
    end
  end
end

function beloved:keypressed(key)
  if key == belovedKey then
    isbelovedMode = not isbelovedMode
  end
end

return beloved
