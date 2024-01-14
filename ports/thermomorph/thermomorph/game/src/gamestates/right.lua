local Right = GameScene:addState('Right')

function Right:videoDraw()
  GameScene.videoDraw(self)
  love.graphics.draw(self.right)
end

function Right:uiDraw()
  GameScene.uiDraw(self)
  self:drawLeftArrow()
  self:drawFlamethrower()
end

function Right:update(dt)
  GameScene.update(self, dt)

  if self.rightAttack then
     self:gotoState('RightDeath')
  elseif self.leftAttack then
    self:gotoState('RightToForward')
  elseif self.controls.lookLeft:pressed() then
    self:gotoState('RightToForward')
  elseif self.controls.flame:pressed() then
    self:flame('right')
  end
end
