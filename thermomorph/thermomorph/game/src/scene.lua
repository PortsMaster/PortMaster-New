Scene = class('Scene')

-- Store the current, active Scene in a static variable.
Scene.static.currentState = nil
-- Static method to switch to a game state.
function Scene.static.switchTo(state)
  -- If we are moving away from an existing state, invoke the 'exit' function.
  if Scene.static.currentState ~= nil then
    Scene.static.currentState:exit()
  end

  -- Transition to the new state and invoke the 'enter' function.
  Scene.static.currentState = state
  if Scene.static.currentState ~= nil then
    Scene.static.currentState:enter()
  end
end

-- Make callbacks redirect to the current Scene
local CALLBACKS = {'directorydropped', 'filedropped', 'focus', 'keypressed', 'keyreleased',
  'lowmemory', 'mousefocus', 'mousemoved', 'mousepressed', 'mousereleased', 'quit', 'resize', 'textedited',
  'textinput', 'threaderror', 'touchmoved', 'touchpressed', 'touchreleased', 'visible', 'wheelmoved',
  'joystickadded', 'joystickaxis', 'joystickhat', 'joystickpressed', 'joystickreleased', 'joystickremoved',
  'gamepadaxis', 'gamepadpressed', 'gamepadreleased'}

-- Input events.
for _, callback in ipairs(CALLBACKS) do
  Scene[callback] = function(self, ...) self.signals:emit(callback, ...) end
end

for _, callback in ipairs(CALLBACKS) do
  love[callback] = function(...)
    if Scene.currentState ~= nil then
      Scene.currentState[callback](Scene.currentState, ...)
    end
  end
end

-- Turn on mobile mode after first touch on Web.
if love.system.getOS() == "Web" then
  local touchpressed = love.touchpressed
  function love.touchpressed(...)
    MOBILE = true
    touchpressed(...)
  end
end

if ANDROID_EMULATE then
  function love.mousepressed(x, y, button, istouch, presses)
    love.touchpressed('mouse', x, y, 0, 0, 1)
  end
  function love.mousereleased(x, y, button, istouch, presses)
    love.touchreleased('mouse', x, y, 0, 0, 1)
  end
end

function Scene:initialize()
  self.timer = Timer.new() -- Timer for handling tweening and delayed callbacks.
  self.signals = Signal.new() -- A signal dispatcher.
  self.time = 0 -- Global time measure.
end

function Scene:update(dt)
  -- Update total time.
  self.time = self.time + dt
  -- Step the timer / tweening system for this state forward.
  self.timer:update(dt)
end

function Scene:draw()
end

-- Empty enter and exit functions.
function Scene:enter() end
function Scene:exit() end


function Scene:calculateUIScale()
  return math.min(love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720)
end

return Scene
