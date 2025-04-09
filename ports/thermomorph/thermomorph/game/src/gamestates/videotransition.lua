function VideoTransitionState(stateName, nextState, videoFile)
  local TransitionState = GameScene:addState(stateName)
  local transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})

  function TransitionState:enteredState()
    transitionVideo:play()
  end

  function TransitionState:videoDraw()
    GameScene.videoDraw(self)
    love.graphics.push()
    love.graphics.scale(VIDEO_SCALE_FACTOR, VIDEO_SCALE_FACTOR)
    love.graphics.draw(transitionVideo)
    love.graphics.pop()
  end

  function TransitionState:update(dt)
    GameScene.update(self, dt)

    if not transitionVideo:isPlaying() then
      self:gotoState(nextState)
      transitionVideo:release()
      transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})
    end
  end
end

VideoTransitionState('ForwardToLeft', "Left", 'forward-left.ogv')
VideoTransitionState('LeftToForward', "Forward", 'left-forward.ogv')

VideoTransitionState('FlameLeftEmpty', "Left", 'left-empty.ogv')
VideoTransitionState('FlameLeftMonster', "Left", 'left-monster.ogv')

VideoTransitionState('ForwardToRight', "Right", 'forward-right.ogv')
VideoTransitionState('RightToForward', "Forward", 'right-forward.ogv')

VideoTransitionState('FlameRightEmpty', "Right", 'right-empty.ogv')
VideoTransitionState('FlameRightMonster', "Right", 'right-monster.ogv')
