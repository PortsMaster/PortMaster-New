local tablex = require('pl.tablex')
local Tablet = require 'src.tablet'
local Monster = require 'src.monster'
local AM = require 'src.scenes.am'
local BlackFader = require "src.blackfader"
local Heating = require "src.heatingsystem"
local Ending  = require "src.scenes.ending"

require "src.difficulty"

STILL_SIZE = vector(1280, 720)
VIDEO_SCALE_FACTOR = 2

REAL_LEVEL_TIME = 60 * 3 -- How much time a level takes in real time
MINUTES_PER_REAL_TIME = 60 / REAL_LEVEL_TIME

GameScene = class('GameScene', Scene)
GameScene:include(Stateful)

WALK_GRAPH = require 'src.walkgraph'

function GameScene:initialize(hour)
  Scene.initialize(self)

  SetDifficulty(hour)
  self.hour = hour

  -- Input controls
  self.controls = {}

  self.uiColor = Color(1, 1, 1, 0.1)

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local margin = sw * 0.03
  local mw = sw / 2

  self.turnLeftTouchRegion = {margin, margin, sw * 0.1, sh  - margin * 2}
  self.turnRightTouchRegion = {sw - margin - sw * 0.1, margin, sw * 0.1, sh  - margin * 2}

  self.flamethrowerTouchRegion = {mw - sw * 0.2, sh - margin - sh * 0.2, sw * 0.4, sh * 0.2}
  self.endCallTouchRegion = {sw - margin - sw * 0.1 - sw * 0.15, margin , sw * 0.1, sh * 0.15}

  self.toggleModeTouchRegion = {mw - sw * 0.2, sh - margin - sh * 0.2, sw * 0.4, sh * 0.2}
  self.heatResetTouchRegion = {mw - sw * 0.2, sh - 2 * margin - 2 * sh * 0.2, sw * 0.4, sh * 0.2}

  self.controls.lookRight = input.Button(input.Or(
    input.Key('right'),
    input.TouchRegion(unpack(self.turnRightTouchRegion))
  ))
  self.controls.lookLeft = input.Button(input.Or(
    input.Key('left'),
    input.TouchRegion(unpack(self.turnLeftTouchRegion))
  ))

  self.controls.flame = input.Button(input.Or(
    input.Key('f'),
    input.TouchRegion(unpack(self.flamethrowerTouchRegion))
  ))

  self.controls.toggleMode = input.Button(input.Or(
    input.Key('space'),
    input.TouchRegion(unpack(self.toggleModeTouchRegion))
  ))
  self.controls.heatReset = input.Button(input.Or(
    input.Key('return'),
    input.TouchRegion(unpack(self.heatResetTouchRegion))
  ))
  self.controls.skipCall = input.Button(input.Or(
    input.Key('escape'),
    input.TouchRegion(unpack(self.endCallTouchRegion))
  ))

  self.forward = love.graphics.newImage("assets/graphics/forward.png")
  self.left = love.graphics.newImage("assets/graphics/left.png")
  self.right = love.graphics.newImage("assets/graphics/right.png")

  self.monsters = {}
  for i=1, NUM_MONSTERS do
    table.insert(self.monsters, Monster(WALK_GRAPH, self, i))
  end

  self.tablet = Tablet(self, self.monsters)

  self.ambience = VENTS_AMBIENCE

  self.blackFader = BlackFader()
  self.blackFader:fadeOut(1)

  self.fuel = FLAME_FUEL
  self.heating = Heating(self)

  self.intro = love.audio.newSource(INTRO_SOUND, 'stream')
  self.hidden = love.audio.newSource(HIDDEN_MESSAGE, 'stream')
  self.hidden:setVolume(0.5)
  self.timer:after(3, function()
    self.intro:play()
  end)

  self.timer:after(REAL_LEVEL_TIME * 0.5, function()
    self.hidden:play()
  end)

  self:gotoState('Forward')
end

function GameScene:enter()
  self.ambience:play()
  self.ambience:setLooping(true)
end

function GameScene:exit()
  self.ambience:stop()
  self.tablet:gotoState('Dead')
end

function GameScene:scaling()
  local x_scale = love.graphics.getWidth() / STILL_SIZE.x
  local y_scale = love.graphics.getHeight() / STILL_SIZE.y

  if x_scale > y_scale then
    love.graphics.scale(x_scale, x_scale)
    love.graphics.translate(0, -STILL_SIZE.y/2 + love.graphics.getHeight() / (2 * x_scale))
  else
    love.graphics.scale(y_scale, y_scale)
    love.graphics.translate(-STILL_SIZE.x/2 + love.graphics.getWidth() / (2 * y_scale), 0)
  end
end

function GameScene:draw()
  Scene.draw(self)

  self.tablet:draw()

  love.graphics.push()
  self:scaling()

  Color.WHITE:use()
  self:videoDraw()
  love.graphics.pop()

  self:uiDraw()

  self.blackFader:draw()

  if DEBUG then self:debugDraw() end
end

local error = love.audio.newSource('assets/sound/error.wav', 'static')
local flameSFX = love.audio.newSource('assets/sound/flamethrower.wav', 'static')
local hurtScreech = love.audio.newSource('assets/sound/hurt-screech.wav', 'static')

function GameScene:flame(dir)
  local node, flameMonsterState, flameEmptyState
  if dir == "left" then
    node = WALK_GRAPH.attackLeft
    flameMonsterState = 'FlameLeftMonster'
    flameEmptyState = 'FlameLeftEmpty'
  elseif dir == "right" then
    node = WALK_GRAPH.attackRight
    flameMonsterState = 'FlameRightMonster'
    flameEmptyState = 'FlameRightEmpty'
  else
    error("Unknown dir " .. dir)
  end

  if self.fuel > 0 then
    local hitMonster = false
    for _, monster in ipairs(self.monsters) do
      if monster.node == node then
        self:gotoState(flameMonsterState)
        hurtScreech:clone():play()
        monster:runaway(dir)
        hitMonster = true
        break
      end
    end

    if not hitMonster then
      self:gotoState(flameEmptyState)
    end

    flameSFX:clone():play()
    self.fuel = self.fuel - 1
  else
    error:clone():play()
  end
end

function GameScene:uiDraw()
  love.graphics.setColor(1, 0, 0, 0.7)

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local barW = w * 0.2

  love.graphics.setLineWidth(1)
  love.graphics.rectangle('line', 20, 20, barW, w * 0.02)

  love.graphics.rectangle('fill', 20, 20, barW * (self.fuel / FLAME_FUEL), w * 0.02)
end

local debugFont = love.graphics.newFont(12)
function GameScene:debugDraw()
  love.graphics.push()
  love.graphics.pop()
end

function GameScene:videoDraw()
end

function GameScene.static.getSceneForHour(hour)
  if hour < 4 then return GameScene(hour)
  else return Ending() end
end

function GameScene:getAnalyticsData()
  return {
    hour = self.hour,
    fuel = self.fuel,
  }
end

function GameScene:update(dt)
  Scene.update(self, dt)

  self.blackFader:update(dt)
  self.heating:update(dt)

  if self.time >= REAL_LEVEL_TIME then
    local data = self:getAnalyticsData()
    data.result = 'win'
    analytics.logGameResult(data)

    local nextHour = self.hour + 1
    Scene.switchTo(AM(nextHour, function()
      Scene.switchTo(GameScene.getSceneForHour(nextHour))
    end))
  else
    -- Update monsters.
    for _, monster in pairs(self.monsters) do monster:update(dt) end

    -- Update tablet.
    self.tablet:update(dt)

    -- Update all of the controls
    for _, control in pairs(self.controls) do control:update() end
  end
end

local controlFont = love.graphics.newFont('assets/ui/roboto.ttf', 24)

local rightArrow = love.graphics.newImage('assets/ui/keyboard-arrow-right.png')
local chevronRight = love.graphics.newImage('assets/ui/chevron-right.png')
function GameScene:drawRightArrow()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local scale = self:calculateUIScale()

  if not MOBILE then
    self.uiColor:use()
    love.graphics.setFont(controlFont)

    love.graphics.draw(rightArrow, sw - rightArrow:getWidth() * scale - 30, sh - 50 - rightArrow:getHeight() * scale, 0, scale, scale)
    love.graphics.printf("LOOK RIGHT", sw - rightArrow:getWidth() * scale - 55, sh - 55, rightArrow:getWidth() * scale + 40, "center")
  else
    local margin = sw * 0.025

    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.turnRightTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.turnRightTouchRegion))

    local scale = (self.turnRightTouchRegion[3] * 0.8) / chevronRight:getWidth()
    love.graphics.draw(chevronRight,
      self.turnRightTouchRegion[1] + self.turnRightTouchRegion[3] / 2 - (chevronRight:getWidth() * scale) / 2,
      self.turnRightTouchRegion[2] + self.turnRightTouchRegion[4] / 2 - (chevronRight:getHeight() * scale) / 2,
      0,
      scale,
      scale)
  end
end

local leftArrow = love.graphics.newImage('assets/ui/keyboard-arrow-left.png')
local chevronLeft = love.graphics.newImage('assets/ui/chevron-left.png')
function GameScene:drawLeftArrow()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local scale = self:calculateUIScale()

  if not MOBILE then
    self.uiColor:use()
    love.graphics.setFont(controlFont)

    love.graphics.draw(leftArrow, 30, sh - 50 - leftArrow:getHeight() * scale, 0, scale, scale)
    love.graphics.printf("LOOK LEFT", 10, sh - 55, leftArrow:getWidth() * scale + 40, "center")
  else
    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.turnLeftTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.turnLeftTouchRegion))

    local scale = (self.turnLeftTouchRegion[3] * 0.8) / chevronLeft:getWidth()
    love.graphics.draw(chevronLeft,
      self.turnLeftTouchRegion[1] + self.turnLeftTouchRegion[3] / 2 - (chevronLeft:getWidth() * scale) / 2,
      self.turnLeftTouchRegion[2] + self.turnLeftTouchRegion[4] / 2 - (chevronLeft:getHeight() * scale) / 2,
      0,
      scale,
      scale)
  end
end

function GameScene:isForward() return false end

local flamethrower = love.graphics.newImage('assets/ui/keyboard-f.png')
local flamethrowerIcon = love.graphics.newImage('assets/ui/flamethrower.png')
function GameScene:drawFlamethrower()
  self.uiColor:use()
  love.graphics.setFont(controlFont)

  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  local mw = sw / 2
  local scale = self:calculateUIScale()

  if not MOBILE then
    love.graphics.draw(flamethrower, mw - flamethrower:getWidth() * scale / 2, sh - 50 - flamethrower:getHeight() * scale, 0, scale, scale)
    love.graphics.printf("FLAMETHROWER", mw - 100, sh - 55, 200, "center")
  else
    self.uiColor:use()
    love.graphics.rectangle('fill', unpack(self.flamethrowerTouchRegion))
    Color.WHITE:use()
    love.graphics.rectangle('line', unpack(self.flamethrowerTouchRegion))

    local scale = (self.flamethrowerTouchRegion[4] * 0.8) / flamethrowerIcon:getHeight()
    love.graphics.draw(flamethrowerIcon,
      self.flamethrowerTouchRegion[1] + self.flamethrowerTouchRegion[3] / 2 - (flamethrowerIcon:getWidth() * scale) / 2,
      self.flamethrowerTouchRegion[2] + self.flamethrowerTouchRegion[4] / 2 - (flamethrowerIcon:getHeight() * scale) / 2,
      0,
      scale,
      scale)
  end
end

require "src.gamestates.forward"
require "src.gamestates.left"
require "src.gamestates.right"
require "src.gamestates.videotransition"
require "src.gamestates.deathtransition"

return GameScene
