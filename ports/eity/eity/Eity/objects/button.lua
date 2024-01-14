local button = {}
button.__index = button

local hoverButtonOver

function newButton(x, y, width, height, corner, text, inlineColor, normalOutlineColor, highlightOutlineColor, textAlign, ox, oy, func, isToggle)
  local b = {}
  b.x = x
  b.y = y
  b.width = width
  b.height = height
  b.corner = corner
  b.text = text
  b.inlineColor = inlineColor
  b.normalOutlineColor = normalOutlineColor
  b.highlightOutlineColor = highlightOutlineColor
  b.textAlign = textAlign or "center"
  b.ox = ox or 0
  b.oy = oy or 0
  b.func = func
  b.isToggle = isToggle or false
  b.activeOutlineColor = normalOutlineColor
  
  return setmetatable(b, button)
end

function button:update(dt)                                      
  if self.isMouseOnButton then
    if not self.isToggle then
      self.activeOutlineColor = self.highlightOutlineColor
    end
    if not self.hoverButtonOver then
      self.hoverButtonOver = true
      soundManager.playSoundEffect(soundManager.buttonOversrc)
    end
  else
    self.hoverButtonOver = false
    if not self.isToggle then
      self.activeOutlineColor = self.normalOutlineColor
    end
  end
  
end

function button:draw()  
  self.isMouseOnButton = mx > self.x and mx < self.x + self.width and
                          my > self.y and my < self.y + self.height   
                            
  love.graphics.setColor(self.inlineColor)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, self.corner)
  love.graphics.setColor(self.activeOutlineColor)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height, self.corner)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(self.text, self.x + self.ox, self.y + self.oy, self.width, self.textAlign)
end

function button:mousepressed(x, y, button)
  if self.isMouseOnButton and button == 1 then
    self.func()
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
  end
end

function button:setHighlightOutlineColor()
  self.activeOutlineColor = self.highlightOutlineColor
end

function button:setNormalOutlineColor()
  self.activeOutlineColor = self.normalOutlineColor
end
