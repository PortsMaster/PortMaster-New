local Left = GameScene:addState('Left')

function Left:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.left)
end

function Left:uiDraw()
  GameScene.uiDraw(self)
  self:drawRightArrow()
  self:drawFlamethrower()
end

function Left:update(dt)
  GameScene.update(self, dt)

  if self.leftAttack then
    self:gotoState('LeftDeath')
  elseif self.rightAttack then
    self:gotoState('LeftToForward')
  elseif self.controls.lookRight:pressed() then
    self:gotoState('LeftToForward')
  elseif self.controls.flame:pressed() then
    self:flame('left')
  end
end
