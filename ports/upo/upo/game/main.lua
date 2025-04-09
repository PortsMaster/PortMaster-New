require 'lib/simpleScale'

require 'globals'
require 'colors'

require 'managers/statemanager'
require 'managers/savemanager'

local appId = require 'applicationId'

function love.load()
  savemanager:load()
  volumeValue = savemanager.settings.volume or 100
  resolutionIndex = savemanager.settings.resolutionIndex or 8
  statemanager:load()
  math.randomseed(os.time())
  if resolutionList[resolutionIndex][1] == 0 and resolutionList[resolutionIndex][2] == 0 then
    isFullScreen = true
  else
    isFullScreen = false
  end
  simpleScale.setWindow(gw, gh, resolutionList[resolutionIndex][1], resolutionList[resolutionIndex][2], {fullscreen = isFullScreen})
  love.window.setVSync(0)
  cursor:load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1)
  love.mouse.setVisible(false)

  joystick = nil

  isJoystickMove = false
  joystickNoticeTextOpacity = 0

  now = os.time(os.date("*t"))
  nextPresenceUpdate = 0
end

function love.update(dt)
    local ok, err = pcall(function()
        collectgarbage()
        mx = love.mouse.getX() / simpleScale.getScale()
        my = love.mouse.getY() / simpleScale.getScale()

        statemanager:update(dt)
    end)

    if not ok then
        logToFile("Error in love.update: " .. err)
    end
end

function love.draw()
    local ok, err = pcall(function()
        simpleScale.set()
        statemanager:draw()
        simpleScale.unSet()
    end)

    if not ok then
        logToFile("Error in love.draw: " .. err)
    end
end

function love.mousepressed(x, y, button)
  statemanager:mousepressed(x, y, button)
end

function love.keypressed(key)
  statemanager:keypressed(key)
  if (key == "y" and statemanager:getState() == "menu" and joystick ~= nil) then
    isJoystickMove = not isJoystickMove
    joystickNoticeTextOpacity = 1
  end
end

function love.quit()
	
  
end
