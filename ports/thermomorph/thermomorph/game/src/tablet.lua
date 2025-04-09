Tablet = class('Tablet')
Tablet:include(Stateful)

-- The shader used for projecting the 2D tablet screen canvas onto the plane in the pre-rendered video.
Tablet.static.SCREEN_SHADER = love.graphics.newShader('src/shader/screen.frag', 'src/shader/screen.vert')

Tablet.static.CANVAS_SIZE = vector(850, 480)

-- How long motion sensor dots last.
Tablet.static.DOT_LIFETIME = 5

Tablet.static.CLOCK_FONT = love.graphics.newFont('assets/ui/digital-font.ttf', 50)
Tablet.static.CALL_FONT = love.graphics.newFont('assets/ui/digital-font.ttf', 30)
Tablet.static.CRASH_TIME_RANGE = vector(60, 120)
Tablet.static.toggleSound = love.audio.newSource('assets/sound/click.wav', 'static')

function Tablet:initialize(gameScene, monsters)
  self.gameScene = gameScene

  self.mesh = love.graphics.newMesh({
      {"VertexPosition", "float", 2},
      {"ZPositionAttribute", "float", 1},
      {"VertexTexCoord", "float", 2},
  }, require("assets.graphics.motionsensor_coords"), "strip")

  self.canvas = love.graphics.newCanvas(Tablet.CANVAS_SIZE:unpack())
  self.canvas:setWrap('clampzero', 'clampzero')
  self.mesh:setTexture(self.canvas)

  self.monsters = monsters
  self.dots = lume.map(monsters, function()
    return {pos = vector(0, 0), lifetime = Tablet.DOT_LIFETIME} end)

  self.nextScanTime = love.timer.getTime() + 5

  self:setupCrashTimer()

  self:gotoState('MotionSensor')
end

function Tablet:canResetHeat() return false end
function Tablet:canCrash() return true end

function Tablet:setupCrashTimer()
  local crashTime = lume.random(Tablet.CRASH_TIME_RANGE:unpack())
  log.debug(string.format("Crashing in %s seconds.", crashTime))
  self.gameScene.timer:after(crashTime, function()
    if self:canCrash() then
      self:gotoState('Crashed')
    else
      self:setupCrashTimer()
    end
  end)
end

-- Draw to the canvas.
function Tablet:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(0, 0, 0, 0)

  Color.GREEN:use()
  love.graphics.setFont(Tablet.CLOCK_FONT)

  local minutes = math.min(self.gameScene.time * MINUTES_PER_REAL_TIME, 59)
  love.graphics.printf(self.gameScene.hour .. ":" .. string.format("%02d", minutes) .. " AM", Tablet.CANVAS_SIZE.x - 170, Tablet.CANVAS_SIZE.y - 60, 150, "right")

  love.graphics.setLineWidth(4)
  love.graphics.rectangle('line', 0, 0, Tablet.CANVAS_SIZE.x, Tablet.CANVAS_SIZE.y)

  if self.gameScene.intro:isPlaying() then
    love.graphics.setLineWidth(2)
    love.graphics.setFont(Tablet.CALL_FONT)
    love.graphics.rectangle('line', 650, 160 + 80, 180, 80)
    love.graphics.printf("INCOMING CALL\n\nFROM: SYSTEM", 650, 170 + 80, 180, "center")
  end

  love.graphics.setCanvas()
end

function Tablet:drawMotion(selected)
  Color.GREEN:use()
  love.graphics.setLineWidth(2)
  love.graphics.setFont(Tablet.CLOCK_FONT)
  local rectMode = 'line'
  if selected then rectMode = 'fill' end
  love.graphics.rectangle(rectMode, 650, 30, 180, 60)
  if selected then Color.BLACK:use() end
  love.graphics.printf("MOTION", 650, 70 - 30, 180, "center")
end

function Tablet:drawHeating(selected)
  Color.GREEN:use()
  love.graphics.setLineWidth(2)
  love.graphics.setFont(Tablet.CLOCK_FONT)
  local rectMode = 'line'
  if selected then rectMode = 'fill' end
  love.graphics.rectangle(rectMode, 650, 110, 180, 60)
  if selected then Color.BLACK:use() end
  love.graphics.printf("HEATING", 650, 150 - 30, 180, "center")
end

function Tablet:update(dt)
  lume.each(self.dots, function(dot)
    dot.lifetime = dot.lifetime + dt
  end)
end

-- Invoke when you want to draw the page to the actual game screen.
function Tablet:videoDraw()
  love.graphics.setShader(Tablet.SCREEN_SHADER)
  love.graphics.draw(self.mesh)
  love.graphics.setShader()
end

require 'src.tabletstates.crashed'
require 'src.tabletstates.heating'
require 'src.tabletstates.motionsensor'
require 'src.tabletstates.scanning'
require 'src.tabletstates.heatreset'
require 'src.tabletstates.dead'

return Tablet
