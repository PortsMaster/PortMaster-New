local BlackFader = class('BlackFader')
BlackFader:include(Stateful)

function BlackFader:initialize() end
function BlackFader:draw() end
function BlackFader:update(dt) end

function BlackFader:fadeIn(duration) self:gotoState('FadeIn', duration) end
function BlackFader:fadeOut(duration) self:gotoState('FadeOut', duration) end

local FadeInState = BlackFader:addState('FadeIn')

function FadeInState:enteredState(duration)
  log.debug('Fading in black. Duration: ', duration)
  self.duration = duration
  self.time = 0
end

function FadeInState:update(dt)
  self.time = self.time + dt
end

function FadeInState:draw()
  love.graphics.setColor(0, 0, 0, lume.clamp(self.time, 0, self.duration) / self.duration)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

local FadeOutState = BlackFader:addState('FadeOut')

function FadeOutState:enteredState(duration)
  log.debug('Fading out black. Duration: ', duration)
  self.duration = duration
  self.time = 0
end

function FadeOutState:update(dt)
  self.time = self.time + dt
end

function FadeOutState:draw()
  love.graphics.setColor(0, 0, 0, 1 - (lume.clamp(self.time, 0, self.duration) / self.duration))
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end


return BlackFader
