local MainMenu = class('MainMenu', Scene)

local error = love.audio.newSource('assets/sound/error.wav', 'static')


local Credits = require 'src.scenes.credits'
local AM = require 'src.scenes.am'
local Intro = require 'src.scenes.intro'

local star = love.graphics.newImage("assets/graphics/star.png")

local MAXIMUM_SIZE = vector(1920, 1080)

local save = require 'src.save'

function MainMenu:resize()
  local scale = self:calculateUIScale()
  self.titleFont = love.graphics.newFont("assets/ui/digital-font.ttf", scale * 100)
  self.optionFont = love.graphics.newFont("assets/ui/digital-font.ttf", scale * 40)
  self.versionFont = love.graphics.newFont("assets/ui/digital-font.ttf", scale * 30)
end

function MainMenu:initialize()
  Scene.initialize(self)

  self.ambience = VENTS_AMBIENCE
  self.ambience:setLooping(true)

  self.video = love.graphics.newVideo('assets/graphics/mainmenu-loop.ogv', {audio = false})
  self.video:play()

  if save.data.hour == nil then
    self.current = 2
  else
    self.current = 1
  end

  self.confirmNewGame = false

  self:resize()

  local continueName = "Continue Game (No Save)"
  if save.data.hour ~= nil then
    continueName = "Continue Game (" .. save.data.hour .. ":00 AM)"
  end

  local continueGame = { name = continueName,
    enabled = save.data.hour ~= nil,
    action = function()
      local hour = save.data.hour
      Scene.switchTo(AM(hour, function()
        Scene.switchTo(GameScene.getSceneForHour(hour))
      end))
    end}

  local newGame = { name = 'New Game',
    enabled = true
  }
  newGame.action = function()
    if self.confirmNewGame then
      Scene.switchTo(Intro())
    else
      self.confirmNewGame = true
      newGame.name = "New Game (Confirm)"
      log.debug("Requesting confirmation...")
    end
  end

  local toggleFullscreen = { name = 'Toggle Fullscreen', enabled = true, action = function()
    if love.window.getFullscreen() then
      _, _, flags = love.window.getMode()
      flags.fullscreen = false
      love.window.setMode(1280, 720, flags)
    else
      _, _, flags = love.window.getMode()
      flags.fullscreen = true

      modes = love.window.getFullscreenModes()
      table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)

      local best_mode = modes[1]
      for i, mode in ipairs(modes) do
        if mode.width <= MAXIMUM_SIZE.x and mode.height <= MAXIMUM_SIZE.y then
          best_mode = mode
        end
      end

      log.debug("Best Mode", inspect(best_mode))
      love.window.setMode(best_mode.width, best_mode.height, flags)
    end
  end}

  local credits = { name = 'Credits', enabled = true, action = function()
      Scene.switchTo(Credits())
    end}

    local quit = { name = 'Quit', enabled = true, action = function()
      love.event.quit()
    end}

  if WEB then
    self.options = {
      continueGame,
      newGame,
      credits,
    }
  elseif not MOBILE then
    self.options = {
      continueGame,
      newGame,
      toggleFullscreen,
      credits,
      quit
    }
  elseif ANDROID then
    self.options = {
      continueGame,
      newGame,
      credits,
      quit
    }
  else
    self.options = {
      continueGame,
      newGame,
      credits,
    }
  end
end

function MainMenu:enter()
  self.ambience:play()
end

function MainMenu:exit()
  self.ambience:stop()
end

function MainMenu:update(dt)
  Scene.update(self, dt)
  if self.video:tell() > (19 + 14 / 30) then
    self.video:rewind()
    log.debug("Rewinding background video.")
  end
end

function MainMenu:keypressed(key, scancode, isrepeat)
  local click = love.audio.newSource('assets/sound/click.wav', 'static')
  if key == 'down' then
    self.current = self.current + 1
    click:play()
  elseif key == 'up' then
    self.current = self.current - 1
    click:play()
  elseif key == 'return' then
    if self.options[self.current].enabled then
      self.options[self.current].action()
      click:play()
    else
      error:play()
    end
  end

  if self.current > #self.options then self.current = 1 end
  if self.current < 1 then self.current = #self.options end
end

function MainMenu:draw()
  love.graphics.push()
  GameScene.scaling(self)
  love.graphics.setColor(1, 1, 1, 0.7)
  love.graphics.draw(self.video)
  love.graphics.pop()

  Color.GREEN:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2

  love.graphics.setFont(self.titleFont)
  love.graphics.printf("THERMOMORPH", 100, sh * 0.15, sw - 200, "center")

  local uiScale = self:calculateUIScale()

  for i, option in ipairs(self.options) do
      love.graphics.setFont(self.optionFont)

      if option.enabled then
        Color.GREEN:use()
      else
        love.graphics.setColor(0, 0.3, 0, 1)
      end

      local text = option.name
      if not MOBILE and self.current == i then
        text = '> ' .. text .. ' <'
      end
      love.graphics.printf(text, 100, sh * 0.45 + uiScale * 60 * (i- 1), sw - 200, "center")

      if MOBILE then
        love.graphics.setLineWidth(1)
      love.graphics.rectangle('line', 100, sh * 0.45 + uiScale * 60 * (i- 1) - 5, sw - 200, uiScale * 40 + 5)
      end
  end

  love.graphics.setFont(self.versionFont)
  love.graphics.printf(VERSION, uiScale * 30, love.graphics.getHeight() - uiScale * 50, 200, "left")

  if save.data.completed then
    love.graphics.draw(star, love.graphics.getWidth() - star:getWidth() - 10,
      love.graphics.getHeight() - star:getHeight() - 15)
  end
end

function MainMenu:touchreleased(id, x, y, dx, dy, pressure)
  local uiScale = self:calculateUIScale()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local click = love.audio.newSource('assets/sound/click.wav', 'static')

  for i, option in ipairs(self.options) do
      local region = {x = 100, y = sh * 0.45 + uiScale * 60 * (i- 1), width = sw - 200, height = 40}

      if x > region.x and y > region.y and x < region.x + region.width and y < region.y + region.height then
        if option.enabled then
          option.action()
          click:play()
        else
          error:play()
        end
      end
  end

end


return MainMenu
