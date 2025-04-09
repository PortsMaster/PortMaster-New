local Forward = GameScene:addState('Forward')


function Forward:videoDraw()
  GameScene.videoDraw(self)

  Color.WHITE:use()
  love.graphics.draw(self.forward)
  self.tablet:videoDraw()
end

function Forward:isForward() return true end

local space = love.graphics.newImage('assets/ui/keyboard-space.png')
local enter = love.graphics.newImage('assets/ui/keyboard-enter.png')
local esc = love.graphics.newImage('assets/ui/keyboard-esc.png')
local controlFont = love.graphics.newFont('assets/ui/roboto.ttf', 24)

function Forward:uiDraw()
  GameScene.uiDraw(self)
  self:drawRightArrow()
  self:drawLeftArrow()

  self.uiColor:use()
  love.graphics.setFont(controlFont)

  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  if HEATING_ENABLED then
    self:drawToggleMode()

    if self.tablet:canResetHeat() then
      self:drawResetHeat()
    end
  end

  if self.intro:isPlaying() or self.hidden:isPlaying() then
    self:drawEscapeCall()
  end
end

function Forward:drawToggleMode()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local scale = self:calculateUIScale()

  if not MOBILE then
    love.graphics.draw(space, sw/2 - space:getWidth() * scale/2, sh - space:getHeight()*scale - 40, 0, scale, scale)
    love.graphics.printf("TOGGLE MODE", sw/2 - 100, sh - 55, 200, "center")
  else
    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.toggleModeTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.toggleModeTouchRegion))

    love.graphics.printf("TOGGLE MODE",
      self.toggleModeTouchRegion[1] + self.toggleModeTouchRegion[3]/2 - 100,
      self.toggleModeTouchRegion[2] + self.toggleModeTouchRegion[4]/2  - 12,
      200,
      "center")
  end
end

function Forward:drawResetHeat()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local scale = self:calculateUIScale()

  if not MOBILE then
    love.graphics.draw(enter, sw - enter:getWidth() * scale - 40, sh / 2 - enter:getHeight() * scale / 2, 0, scale, scale)
    love.graphics.printf("HEAT RESET", sw - enter:getWidth() * scale - 90, sh / 2 + enter:getHeight() * scale /2 + 5, esc:getWidth() * scale + 100, "center")
  else
    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.heatResetTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.heatResetTouchRegion))

    love.graphics.printf("HEAT RESET",
      self.heatResetTouchRegion[1] + self.heatResetTouchRegion[3]/2 - 100,
      self.heatResetTouchRegion[2] + self.heatResetTouchRegion[4]/2  - 12,
      200,
      "center")
  end
end

local endCall = love.graphics.newImage('assets/ui/end-call.png')
function Forward:drawEscapeCall()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local scale = self:calculateUIScale()

  if not MOBILE then
    love.graphics.draw(esc, sw - esc:getWidth() * scale - 30, 20, 0, scale, scale)
    love.graphics.printf("SKIP CALL", sw - esc:getWidth() * scale - 55, 15 + esc:getHeight() * scale, esc:getWidth() * scale + 40, "center")
  else
    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.endCallTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.endCallTouchRegion))

    local scale = (self.endCallTouchRegion[3] * 0.8) / endCall:getWidth()
    love.graphics.draw(endCall,
      self.endCallTouchRegion[1] + self.endCallTouchRegion[3] / 2 - (endCall:getWidth() * scale) / 2,
      self.endCallTouchRegion[2] + self.endCallTouchRegion[4] / 2 - (endCall:getHeight() * scale) / 2,
      0,
      scale,
      scale)
  end
end

function Forward:update(dt)
  GameScene.update(self, dt)

  if self.leftAttack then
    self:gotoState('ForwardToLeftDeath')
  elseif self.rightAttack then
      self:gotoState('ForwardToRightDeath')
  elseif self.controls.lookLeft:pressed() then
    self:gotoState('ForwardToLeft')
  elseif self.controls.lookRight:pressed() then
    self:gotoState('ForwardToRight')
  elseif self.controls.skipCall:pressed() then
    if self.intro:isPlaying() then
      self.intro:stop()
    end
    if self.hidden:isPlaying() then
      self.hidden:stop()
    end
  end
end
