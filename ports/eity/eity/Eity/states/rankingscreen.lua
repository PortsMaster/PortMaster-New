Rankingscreen = {}

local bigFont
local smallFont
local titleFont
local descFont
local rankingFont
local isMouseOnBack

function Rankingscreen:load()
  rankingFont = love.graphics.newFont("assets/roboto.ttf", 556)
  bigFont = love.graphics.newFont("assets/roboto.ttf", 78)
  smallFont = love.graphics.newFont("assets/roboto.ttf", 48)
  titleFont = love.graphics.newFont("assets/roboto.ttf", 36)
  descFont = love.graphics.newFont("assets/roboto.ttf", 24)
end

function Rankingscreen:gamepadpressed(joystick, button)
  if button == "a" then
    stateManager.GameState = "Mainmenu"
  end
end

function Rankingscreen:update(dt)
  isMouseOnBack = mx > 50 and mx < 250 and
                  my > gh * 0.9 and my < gh * 0.9 + 75
                          
  if isMouseOnBack then
    if not hoverButtonOver then
      hoverButtonOver = true
      soundManager.playSoundEffect(soundManager.buttonOversrc)
    end
  else
    hoverButtonOver = false
  end
end

function Rankingscreen:draw()
  Rankingscreen.Background()
  Rankingscreen.Topbar()
  Rankingscreen.Results()
  Rankingscreen.Ranking()
  Rankingscreen:Buttons()    
end

function Rankingscreen:mousepressed(x, y,button)
  if isMouseOnBack and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    stateManager.GameState = "Mainmenu"
  end
end

function Rankingscreen:keypressed(key)
  if key == "escape" then
    stateManager.GameState = "Mainmenu"
  end
end

function Rankingscreen.Background()
  love.graphics.push()
  love.graphics.draw(img, 0, 0, 0, scaleX, scaleY)
  love.graphics.setColor(0.3, 0.3, 0.3, gameManager.backgroundDim)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  love.graphics.pop()
end

function Rankingscreen.Topbar()
  love.graphics.setColor(GrayOpacity6)
  love.graphics.rectangle('fill', 0, 0, gw, gh * 0.08)
  love.graphics.setColor(White)
  love.graphics.line(0, gh * 0.08, gw, gh * 0.08)
  

  love.graphics.setFont(titleFont)
  love.graphics.printf(mapManager.getTitleOfIndex(mapList.getSelectedMapIndex()) .. " - " .. mapManager.getPorterOfIndex(mapList.getSelectedMapIndex())
                        .. " [" .. mapManager.getDifficultOfIndex(mapList.getSelectedMapIndex()) .. "]", 15, 10, gw, "left")
  love.graphics.setFont(descFont)  
  love.graphics.printf("Played on " .. os.date("%d/%m/%Y"), 18, 45, gw, "left")
end

function Rankingscreen.Ranking()
  love.graphics.setFont(bigFont)
  love.graphics.setLineWidth(6) 
  
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', gw * 0.6, gh * 0.15, gw * 0.3, 100, 15)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', gw * 0.6, gh * 0.15, gw * 0.3, 100, 15)
  love.graphics.printf("Ranking", gw * 0.6, gh * 0.15, gw * 0.3, "center")
  love.graphics.setFont(rankingFont)
  love.graphics.printf(scoreManager.getGrade(), gw * 0.45 - 6, gh * 0.2 - 6, gw * 0.6, "center")
  love.graphics.printf(scoreManager.getGrade(), gw * 0.45 + 6, gh * 0.2 - 6, gw * 0.6, "center")
  love.graphics.printf(scoreManager.getGrade(), gw * 0.45 - 6, gh * 0.2 + 6, gw * 0.6, "center")
  love.graphics.printf(scoreManager.getGrade(), gw * 0.45 + 6, gh * 0.2 + 6, gw * 0.6, "center")
  love.graphics.setColor(scoreManager.getGradeColor(scoreManager.getGrade()))
  love.graphics.printf(scoreManager.getGrade(), gw * 0.45, gh * 0.2, gw * 0.6, "center")
end

function Rankingscreen.Results()
  love.graphics.setFont(smallFont)
  love.graphics.setLineWidth(6)
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', 50, gh * 0.15, gw * 0.5, gh * 0.53, 15)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', 50, gh * 0.15, gw * 0.5, gh * 0.53, 15)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Score " .. string.format("%08d", scoreManager.score), 50, gh * 0.16, gw / 2, "center")
  Rankingscreen:Blues()   
  --Rankingscreen:yellows()
  Rankingscreen:reds()    
  love.graphics.printf("Combo " .. scoreManager.maxCombo .. "x", 100, gh * 0.59, 450, "left")           
  love.graphics.printf("Accuracy " ..string.format("%0.2f",  scoreManager.getAccuracy()) .. "%" , 475, gh * 0.59, 450, "left")                      
                        
end

function Rankingscreen:Buttons()
  love.graphics.setFont(smallFont)
  love.graphics.setLineWidth(6)
  
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', 50, gh * 0.9, 200, 75, 10)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', 50, gh * 0.9, 200, 75, 10)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Back", 50, gh * 0.9 + 10, 200, "center")


end

function Rankingscreen:Blues()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf( scoreManager.collectedBlueArrows .. "/" .. scoreManager.totalBlueArrows, -26 + 130 + 90, gh / 2 - gh * 0.23, 500, "left")
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(scoreManager.collectedBlueSliders .. "/" .. scoreManager.totalBlueSliders, -26 + 600 + 90, gh / 2 - gh * 0.23, 500, "left")
  
  
  love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, 1)
  love.graphics.polygon('fill', -26 + 130, gh / 2 - gh * 0.2,
                        13 + 130, gh / 2 + 40 - gh * 0.2,
                        33 + 130, gh / 2 + 20 - gh * 0.2,
                        13 + 130, gh / 2 - gh * 0.2,
                        33 + 130, gh / 2 - 20 - gh * 0.2,
                        13 + 130, gh / 2 - 40 - gh * 0.2)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 130, gh / 2 - gh * 0.2,
                        13 + 130, gh / 2 + 40 - gh * 0.2,
                        33 + 130, gh / 2 + 20 - gh * 0.2,
                        13 + 130, gh / 2 - gh * 0.2,
                        33 + 130, gh / 2 - 20 - gh * 0.2,
                        13 + 130, gh / 2 - 40 - gh * 0.2,
                        -26 + 130, gh / 2 - gh * 0.2)
                        
  love.graphics.setColor(0.25, 0.25, 0.25, 1)
  love.graphics.rectangle('fill', 13 + 500, gh / 2 - 40 - gh * 0.2, 100, 80)

  love.graphics.setColor(34 / 255, 150 / 255, 227 / 255, 1)
  love.graphics.polygon('fill', -26 + 500, gh / 2 - gh * 0.2,
                        13 + 500, gh / 2 + 40 - gh * 0.2,
                        33 + 500, gh / 2 + 20 - gh * 0.2,
                        13 + 500, gh / 2 - gh * 0.2,
                        33 + 500, gh / 2 - 20 - gh * 0.2,
                        13 + 500, gh / 2 - 40 - gh * 0.2)
                        
  love.graphics.polygon('fill', -26 + 500 + 100, gh / 2 - gh * 0.2,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.2,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.2,
                        13 + 500 + 100, gh / 2 - gh * 0.2,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.2,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.2)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 500, gh / 2 - gh * 0.2,
                        13 + 500, gh / 2 + 40 - gh * 0.2,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.2,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.2,
                        13 + 500 + 100, gh / 2 - gh * 0.2,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.2,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.2,
                        13 + 500, gh / 2 - 40 - gh * 0.2,
                        -26 + 500, gh / 2 - gh * 0.2)

end

function Rankingscreen:yellows()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(scoreManager.collectedYellowArrows .. "/" .. scoreManager.totalYellowArrows, -26 + 130 + 90, gh / 2 - gh * 0.08, 500, "left")
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(scoreManager.collectedYellowSliders .. "/" .. scoreManager.totalYellowSliders, -26 + 600 + 90, gh / 2 - gh * 0.08, 500, "left")
  
  
  love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, 1)
  love.graphics.polygon('fill', -26 + 130, gh / 2 - gh * 0.05,
                        13 + 130, gh / 2 + 40 - gh * 0.05,
                        33 + 130, gh / 2 + 20 - gh * 0.05,
                        13 + 130, gh / 2 - gh * 0.05,
                        33 + 130, gh / 2 - 20 - gh * 0.05,
                        13 + 130, gh / 2 - 40 - gh * 0.05)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 130, gh / 2 - gh * 0.05,
                        13 + 130, gh / 2 + 40 - gh * 0.05,
                        33 + 130, gh / 2 + 20 - gh * 0.05,
                        13 + 130, gh / 2 - gh * 0.05,
                        33 + 130, gh / 2 - 20 - gh * 0.05,
                        13 + 130, gh / 2 - 40 - gh * 0.05,
                        -26 + 130, gh / 2 - gh * 0.05)
                        
  love.graphics.setColor(0.25, 0.25, 0.25, 1)
  love.graphics.rectangle('fill', 13 + 500, gh / 2 - 40 - gh * 0.05, 100, 80)

  love.graphics.setColor(219 / 255, 130 / 255, 52 / 255, 1)
  love.graphics.polygon('fill', -26 + 500, gh / 2 - gh * 0.05,
                        13 + 500, gh / 2 + 40 - gh * 0.05,
                        33 + 500, gh / 2 + 20 - gh * 0.05,
                        13 + 500, gh / 2 - gh * 0.05,
                        33 + 500, gh / 2 - 20 - gh * 0.05,
                        13 + 500, gh / 2 - 40 - gh * 0.05)
                        
  love.graphics.polygon('fill', -26 + 500 + 100, gh / 2 - gh * 0.05,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.05,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - gh * 0.05,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.05)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 500, gh / 2 - gh * 0.05,
                        13 + 500, gh / 2 + 40 - gh * 0.05,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.05,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - gh * 0.05,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.05,
                        13 + 500, gh / 2 - 40 - gh * 0.05,
                        -26 + 500, gh / 2 - gh * 0.05)

end

function Rankingscreen:reds()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(scoreManager.collectedRedArrows .. "x", -26 + 130 + 90, gh / 2 - gh * 0.08, 500, "left")
  
  --love.graphics.setColor(1, 1, 1, 1)
  --love.graphics.printf(scoreManager.collectedRedSliders .. "x", -26 + 600 + 90, gh / 2 - gh * 0.08, 500, "left")
  
  
  love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, 1)
  love.graphics.polygon('fill', -26 + 130, gh / 2 - gh * 0.05,
                        13 + 130, gh / 2 + 40 - gh * 0.05,
                        33 + 130, gh / 2 + 20 - gh * 0.05,
                        13 + 130, gh / 2 - gh * 0.05,
                        33 + 130, gh / 2 - 20 - gh * 0.05,
                        13 + 130, gh / 2 - 40 - gh * 0.05)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 130, gh / 2 - gh * 0.05,
                        13 + 130, gh / 2 + 40 - gh * 0.05,
                        33 + 130, gh / 2 + 20 - gh * 0.05,
                        13 + 130, gh / 2 - gh * 0.05,
                        33 + 130, gh / 2 - 20 - gh * 0.05,
                        13 + 130, gh / 2 - 40 - gh * 0.05,
                        -26 + 130, gh / 2 - gh * 0.05)
  --[[                 
  love.graphics.setColor(0.25, 0.25, 0.25, 1)
  love.graphics.rectangle('fill', 13 + 500, gh / 2 - 40 - gh * 0.05, 100, 80)

  love.graphics.setColor(219 / 255, 52 / 255, 52 / 255, 1)
  love.graphics.polygon('fill', -26 + 500, gh / 2 - gh * 0.05,
                        13 + 500, gh / 2 + 40 - gh * 0.05,
                        33 + 500, gh / 2 + 20 - gh * 0.05,
                        13 + 500, gh / 2 - gh * 0.05,
                        33 + 500, gh / 2 - 20 - gh * 0.05,
                        13 + 500, gh / 2 - 40 - gh * 0.05)
                        
  love.graphics.polygon('fill', -26 + 500 + 100, gh / 2 - gh * 0.05,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.05,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - gh * 0.05,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.05)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(-26 + 500, gh / 2 - gh * 0.05,
                        13 + 500, gh / 2 + 40 - gh * 0.05,
                        13 + 500 + 100, gh / 2 + 40 - gh * 0.05,
                        33 + 500 + 100, gh / 2 + 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - gh * 0.05,
                        33 + 500 + 100, gh / 2 - 20 - gh * 0.05,
                        13 + 500 + 100, gh / 2 - 40 - gh * 0.05,
                        13 + 500, gh / 2 - 40 - gh * 0.05,
                        -26 + 500, gh / 2 - gh * 0.05)
                          ]]     
end

return Rankingscreen
