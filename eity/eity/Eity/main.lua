require 'managers/stateManager'
require 'managers/gameManager'
require 'globals'
require 'colors'
require 'lib/simpleScale'

local appId = require 'applicationId'

local joysticks = love.joystick.getJoysticks()
joystick = joysticks[1]

love.mouse.setVisible(false)

function love.load()
  -- Load your cursor image
  cursorImage = love.graphics.newImage("left_ptr.png")
  gameManager:load()
  stateManager:load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1)
  simpleScale.setWindow(gw, gh, resolutionList[saveManager.settings.resolutionIndex][1], resolutionList[saveManager.settings.resolutionIndex][2])
  now = os.time(os.date("*t"))
  detailsNow = "In Mainmenu"
  stateNow = ""
  nextPresenceUpdate = 0
end

function discordApplyPresence()
  if stateManager.GameState == "Maingame" then
    detailsNow = mapManager.getTitleOfIndex(mapList.getSelectedMapIndex())
    stateNow = "By " .. mapManager.getPorterOfIndex(mapList.getSelectedMapIndex())
  else
    detailsNow = "In Mainmenu"
    stateNow = ""
  end

  presence = {
    largeImageKey = "eity_icon",
    largeImageText = "Eity v1.0.0",
    details = detailsNow,
    state = stateNow,
    startTimestamp = now,
  }

  return presence
end

--function love.gamepadpressed(joystick, button)
--  stateManager:gamepadpressed(joystick, button)
--end

function love.update(dt)
  collectgarbage()
  local xOffset = (love.graphics.getWidth() - simpleScale.getScale() * gw) / 2
  mx = (love.mouse.getX() - xOffset) / simpleScale.getScale()
  my = love.mouse.getY() / simpleScale.getScale()
  scoreManager:update(dt)
  gameManager:update(dt)
  stateManager:update(dt)

  if saveManager.settings.isEnabledVSync then
    love.window.setVSync(1)
  else
    love.window.setVSync(0)
  end
end

function drawCursor()
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.draw(cursorImage, mouseX, mouseY)
end

function love.draw()
	simpleScale.set()
    stateManager:draw()
    if saveManager.settings.isEnabledFPS then
      love.graphics.setFont(defaultFont)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf("FPS " .. love.timer.getFPS(), 0, gh - 12, gw, "right")
    end
	simpleScale.unSet()
	drawCursor()
end

function love.quit()
end

function love.mousepressed(x, y, button)
  stateManager:mousepressed(x, y, button)
end

function love.keypressed(key)
  stateManager:keypressed(key)
end
