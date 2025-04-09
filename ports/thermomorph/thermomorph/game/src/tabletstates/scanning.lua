local ScanningState = Tablet:addState('Scanning')

Tablet.static.SCAN_PERIOD = 5
Tablet.static.SCAN_DURATION = 2

local bleep = love.audio.newSource('assets/sound/bleep.wav', 'static')
local click = love.audio.newSource('assets/sound/click.wav', 'static')
local hum = love.audio.newSource('assets/sound/electrical-hum.ogg', 'static')
hum:setVolume(0.2)

function ScanningState:enteredState()
  self.scanTimer = 0
  self.foundDot = lume.map(self.monsters, function()
    return false
  end)

  -- Play a short click and a low frequency hum.
  click:play()
  hum:play()
end

function ScanningState:exitedState()
  hum:stop()
  click:play()
end

function ScanningState:update(dt)
  Tablet.update(self, dt)

  if HEATING_ENABLED and self.gameScene:isForward() and self.gameScene.controls.toggleMode:pressed() then
    self:gotoState('Heating')
    Tablet.toggleSound:clone():play()
    return
  end

  self.scanTimer = self.scanTimer + dt

  local scanPos = self:getScanPos()

  for i, monster in ipairs(self.monsters) do
    if scanPos > monster.pos.x and not self.foundDot[i] then
      self.dots[i].pos = monster.pos
      self.dots[i].lifetime = 0
      self.foundDot[i] = true
      bleep:clone():play()
    end
  end

  if self.scanTimer > Tablet.SCAN_DURATION then
    self:gotoState('MotionSensor')
  end
end

function ScanningState:getScanPos()
  return (self.scanTimer / Tablet.SCAN_DURATION) * Tablet.CANVAS_SIZE.x
end

function ScanningState:draw()
  self.class.static.states['MotionSensor'].draw(self)

  love.graphics.setCanvas(self.canvas)
  Color.GREEN:use()
  local scanPos = self:getScanPos()
  love.graphics.setLineWidth(4)
  love.graphics.line(scanPos, 0, scanPos, Tablet.CANVAS_SIZE.y)
  love.graphics.setCanvas()
end
