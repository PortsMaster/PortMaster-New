local Heating = class('Monster')
Heating:include(Stateful)

-- How long it takes heating to malfunction.
local HEAT_MALFUNCTION_RANGE = vector(40, 80)
-- How long you have to fix heating before it shuts off.
local MALFUNCTION_TIME = 30

local shutdown = love.audio.newSource('assets/sound/shutdown.wav', 'static')

function Heating:initialize(gameScene)
  self.gameScene = gameScene
  self:gotoState('Working')
  self.targetTemp = 98.6
  self.temp = self.targetTemp + self:getError()
end

function Heating:getError()
  return 4 * math.sin(love.timer.getTime() / 50)
end

function Heating:update(dt)
  local error = self.targetTemp + self:getError()

  if self.temp < error then
    self.temp = math.min(self.temp + dt, error)
  elseif self.temp > error then
    self.temp = math.max(self.temp - dt, error)
  end
end

-- No-op
function Heating:startFixing() end

local Working = Heating:addState('Working')

function Working:getState() return "working" end

function Working:enteredState()
  self.targetTemp = 98.6
  if HEATING_ENABLED then
    local time_to_malfunction = lume.random(HEAT_MALFUNCTION_RANGE:unpack())
    self.gameScene.timer:after(time_to_malfunction, function()
      self:gotoState('Malfunction')
    end)
  end
end

local Malfunction = Heating:addState('Malfunction')
function Malfunction:getState() return "malfunction" end

function Malfunction:enteredState()
  self.targetTemp = 90
  log.debug("Heat malfunctioning.")
  self.callback = self.gameScene.timer:after(MALFUNCTION_TIME, function()
    self:gotoState('TurnedOff')
  end)
end

function Malfunction:startFixing()
  self.gameScene.timer:cancel(self.callback)
end


local TurnedOff = Heating:addState('TurnedOff')
function TurnedOff:getState() return "off" end

function TurnedOff:enteredState()
  self.targetTemp = 70
  self.gameScene.ambience:pause()
  shutdown:play()
  log.debug("Heat turned off.")
end

function TurnedOff:exitedState()
  self.gameScene.ambience:play()
  log.debug("Heat turned back on.")
end

return Heating
