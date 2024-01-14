local deathScreech = love.audio.newSource('assets/sound/death-screech.wav', 'static')
local GameOver = require "src.scenes.gameover"

function DeathTransitionState(stateName, videoFile)
  local TransitionState = GameScene:addState(stateName)
  local transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})

  function TransitionState:enteredState()
    local data = self:getAnalyticsData()
    data.result = 'loss'
    data.time = self.time
    analytics.logGameResult(data)

    deathScreech:play()
    transitionVideo:play()

    self.ambience:stop() -- Stop ambience sound.
    self.hidden:stop() -- Stop hidden morse code sound.
    self.intro:stop() -- Stop intro call.

    self.tablet:gotoState('Dead') -- Tell tablet to goto dead state, which should end some audio.

    self.timer:after(1, function()
      Scene.switchTo(GameOver())
      transitionVideo:release()
      transitionVideo = love.graphics.newVideo('assets/graphics/' .. videoFile, {audio = false})
    end)
  end

  function TransitionState:uiDraw() end

  function TransitionState:videoDraw()
    GameScene.videoDraw(self)
    love.graphics.push()
    love.graphics.scale(VIDEO_SCALE_FACTOR, VIDEO_SCALE_FACTOR)
    love.graphics.draw(transitionVideo)
    love.graphics.pop()
  end
end

-- Death to the left
DeathTransitionState("ForwardToLeftDeath", "forward-left-death.ogv")
DeathTransitionState("LeftDeath", "left-death.ogv")

-- Death to the right
DeathTransitionState("ForwardToRightDeath", "forward-right-death.ogv")
DeathTransitionState("RightDeath", "right-death.ogv")
