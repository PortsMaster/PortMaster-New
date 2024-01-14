local squareButton = {}
squareButton.__index = squareButton


function newSquareButton(x, y, radius, text, inlineColor, outlineColor, ox, oy, func)
  local s = {}
  s.x = x
  s.y = y
  s.radius = radius
  s.text = text
  s.inlineColor = inlineColor
  s.outlineColor = outlineColor  
  s.ox = ox or 0
  s.oy = oy or 0
  s.func = func
  s.scale = 1.0
  
  return setmetatable(s, squareButton)
end

function squareButton:update(dt)                
  self.isMouseOnButton = mx > (self.x - self.radius * 0.81) and mx < (self.x + self.radius * 2 * 0.39) and
                          my > (self.y - self.radius * 0.81) and my < (self.y + self.radius * 2 * 0.39)
                                                                
  if self.isMouseOnButton then
    self.scale = self.scale + 220 * dt
    if self.scale > 30 then
      self.scale = 30
    end
  else 
    self.scale = self.scale - 220 * dt
    if self.scale < 1 then
      self.scale = 1
    end
  end
  
end


function squareButton:draw()
    
  love.graphics.setColor(self.outlineColor)
  love.graphics.circle("line", self.x, self.y, self.radius + self.scale, 4)
  love.graphics.setColor(self.inlineColor)
  love.graphics.circle("fill", self.x, self.y, self.radius + self.scale, 4)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(self.text, self.x - self.radius + self.ox, self.y + self.oy, self.radius * 2, "center")
end

function squareButton:mousepressed(x, y, button)                          
  if self.isMouseOnButton and button == 1 then
    self.func()
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
  end
end
