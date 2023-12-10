VERSION = 'v' .. love.filesystem.read("version.txt")

ANDROID_EMULATE = false
if ANDROID_EMULATE then
  love.system.getOS = function()
    return "Android"
  end
end

-- Platform info.
print("Platform:" .. love.system.getOS())
ANDROID = love.system.getOS() == "Android"
IOS = love.system.getOS() == "iOS"
MOBILE = ANDROID or IOS
WEB = love.system.getOS() == "Web"

if MOBILE then love.window.setFullscreen(true) end

math.randomseed(os.time()) -- Seed the random number genrator.

log = require 'external.log' -- Logging library.

inspect = require 'external.inspect' -- Pretty printing Lua objects.
class = require 'external.middleclass' -- Middleclass, for following OOP patterns.
Stateful = require 'external.stateful' -- Stateful.lua, for state-based classes.

vector = require 'external.hump.vector' -- HUMP.vector, for the vector primitive.
lume = require 'external.lume' -- Game-related helpers

Timer = require 'external.hump.timer' -- HUMP.timer
Signal = require 'external.hump.signal' -- HUMP.signal

analytics = require 'src.analytics' -- Register error handler and load analytics.

input = require 'src.input' -- Load in input library.
Color = require 'src.color' -- Color utility library.

-- Load ambience once statically.
VENTS_AMBIENCE = love.audio.newSource('assets/sound/vents-ambience.wav', 'static')

require 'src.scene'
require 'src.gamescene'

local AM = require 'src.scenes.am'
local Ending = require 'src.scenes.ending'
local JumpScareWarning = require 'src.scenes.jumpscarewarning'
local MainMenu = require 'src.scenes.mainmenu'
local Intro = require 'src.scenes.intro'

function love.load(arg)
  if not MOBILE then love.mouse.setVisible(false) end
  if arg[1] == 'debug' then
    log.debug("Debug mode enabled.")
    DEBUG = true
    if arg[2] == 'mainmenu' then
      Scene.switchTo(MainMenu())
    elseif arg[2] == 'hour1' then
      Scene.switchTo(GameScene.getSceneForHour(1))
    elseif arg[2] == 'hour2' then
      Scene.switchTo(GameScene.getSceneForHour(2))
    elseif arg[2] == 'hour3' then
      Scene.switchTo(GameScene.getSceneForHour(3))
    elseif arg[2] == 'hour4' then
      Scene.switchTo(GameScene.getSceneForHour(4))
    elseif arg[2] == 'intro' then
      Scene.switchTo(Intro())
    elseif arg[2] == 'am' then
      Scene.switchTo(AM(1))
    elseif arg[2] == 'ending' then
      Scene.switchTo(Ending())
    else
      Scene.switchTo(JumpScareWarning())
    end

    function love.keypressed(key, scancode, isrepeat)
      if key == 'f1' then
        DEBUG = not DEBUG
      end
      if Scene.currentState ~= nil then
        Scene.currentState:keypressed(key, scancode, isrepeat)
      end
    end
  else
    Scene.switchTo(JumpScareWarning())
  end
end

MAX_DELTA_TIME = 1 / 30
function love.update(dt)
  -- Prevent the delta time from getting out of control.
  if dt > MAX_DELTA_TIME then dt = MAX_DELTA_TIME end
  Timer.update(dt) -- Update global timer events.

  -- If there is a current Scene, update it.
  if Scene.currentState ~= nil then Scene.currentState:update(dt) end

  -- Use lurker for live reload in debug mode.
  if DEBUG then require("external.lurker").update() end
end

function love.draw()
  -- If there is a current Scene, draw it.
  if Scene.currentState ~= nil then Scene.currentState:draw() end
end
