local button = {}
button.__index = button

function newButton(x, y, width, height, func, func2)
  local b = {}
  b.x = x
  b.y = y
  b.width = width
  b.height = height
  b.func = func
  b.func2 = func2 or function() end
  b.hover = false
  
  return setmetatable(b, button)
end

function button:update(dt)    
  self.isMouseOnButton = cursorMX > self.x and cursorMX < self.x + self.width and
                          cursorMY > self.y and cursorMY < self.y + self.height                                       
  if self.isMouseOnButton then
    if (self.hover == false) then
      self.hover = true
      buttonhover:play()
    end
  else
    self.hover = false
  end
end

function button:mousepressed(x, y, button)
  if self.isMouseOnButton and (button == 1) then
    self.func()
    buttonhit:play()
  elseif self.isMouseOnButton and button == 2 then
    self.func2()
    buttonhit:play()
  end
end

function button:gamepadpressed(joystick, button)
  if self.isMouseOnButton and button == "a" then
    self.func()
  elseif self.isMouseOnButton and button == "x" then
    self.func2()
  end
end

function button:getHoverState()
  return self.hover
end
