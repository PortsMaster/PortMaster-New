-- main.lua

lib_baton = require'libs.baton'
lib_obj   = require'libs.Luaoop'

require'libs.tserial'
require'libs.extra'
require'worldVars'
require'weather'
require'flower'
require'rooms'
require'menus'
require'sfx'
require'tex'

obj          = require'classes.object'
obj_area     = require'classes.area'
obj_particle = require'classes.particle'

pengu      = require'classes.entities.pengu'
grassBlade = require'classes.entities.grass'

requireObjects('classes/particles', 'particle')
requireFiles('menus')

----------------------------------------------------------------
-- Virtual resolutions
----------------------------------------------------------------

local BASE_W, BASE_H       = 160, 120   -- world canvas
local UI_BASE_W, UI_BASE_H = 640, 480   -- menus were authored for this

local screenScale    = 4
local screenOffsetX  = 0
local screenOffsetY  = 0

----------------------------------------------------------------
-- Globals
----------------------------------------------------------------

Lang = {} -- set at init

_totalFish      = 10
_totalCassettes = 7
_totalLetters   = 7

_t        = 0
_dt       = 0
cameraX   = 0
WindSpeed = 4

_time   = {}
_date   = {}
_season = ""

_Player = {}

_currentRoom = "inside" -- outside, inside, upstairs, basement

_Particles     = {}
_Interactables = {}
_Grass         = {}
_RainDrops     = {}

canvas         = nil
particlesBatch = nil
raindropsBatch = nil

----------------------------------------------------------------
-- Scaling helpers
----------------------------------------------------------------

local function updateScreenScale()
  local w, h = love.graphics.getDimensions()

  -- integer scale for 160x120 canvas
  local sx = math.floor(w / BASE_W)
  local sy = math.floor(h / BASE_H)
  local scale = math.max(1, math.min(sx, sy))

  screenScale   = scale
  screenOffsetX = math.floor((w - BASE_W * scale) / 2)
  screenOffsetY = math.floor((h - BASE_H * scale) / 2)
end

local function toggleFullscreen()
  local fs = love.window.getFullscreen()

  if fs then
    -- back to windowed using Settings from conf.lua
    local window = Settings.Video.Window
    love.window.setFullscreen(false)
    love.window.setMode(window.w, window.h, {
      resizable  = true,
      fullscreen = false,
    })
  else
    -- desktop fullscreen
    love.window.setFullscreen(true, "desktop")
  end

  updateScreenScale()
end

----------------------------------------------------------------
-- LOVE callbacks
----------------------------------------------------------------

function love.load()
  love.mouse.setVisible(false)
  particlesBatch = love.graphics.newSpriteBatch(Tex)
  raindropsBatch = love.graphics.newSpriteBatch(Tex)

  init()

  init_radioMenu()
  init_mailboxMenu()
end

function love.update(dt)
  _t  = _t + dt
  _dt = dt

  Input:update(dt)

  updateDateTime()
  updateSoundscape(dt)
  updateRooms(dt)
  updateWeather(dt)
  updateMenus(dt)

  for _, v in ipairs(_RainDrops) do v:update(dt) end
  for _, v in ipairs(_Particles) do v:update(dt) end
  for _, v in ipairs(_Grass) do v:update(dt) end

  _Player:update(dt)

  if _currentRoom == "outside" and menu ~= "mainMenu" then
    cameraX = math.floor(_Player.pos.x)
  else
    cameraX = 0
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)

  ------------------------------------------------------------
  -- 1) Draw world to low-res canvas
  ------------------------------------------------------------
  love.graphics.setCanvas(canvas)
    love.graphics.clear()

    -- Discord flicker hack
    love.graphics.line(0, -20, 10, -20)

    love.graphics.push()
      love.graphics.translate(80 - cameraX, 56)

      particlesBatch:clear()
      raindropsBatch:clear()
      GrassBatch_bg:clear()
      GrassBatch_fg:clear()

      for _, v in ipairs(_Particles)  do v:draw() end
      for _, v in ipairs(_RainDrops)  do v:draw() end
      for _, v in ipairs(_Grass)      do v:draw() end

      for layer = 1, 3 do
        drawRooms(layer)
        if layer == 2 then
          love.graphics.draw(particlesBatch)
          love.graphics.draw(raindropsBatch)
        end
        _Player:draw(layer)
      end
    love.graphics.pop()
  love.graphics.setCanvas()

  ------------------------------------------------------------
  -- 2) Draw scaled canvas to actual window
  ------------------------------------------------------------
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    canvas,
    screenOffsetX,
    screenOffsetY,
    0,
    screenScale,
    screenScale
  )

  ------------------------------------------------------------
  -- 3) Draw UI scaled to match (menus use 640x480 coords)
  ------------------------------------------------------------
  local uiScale = screenScale * (BASE_W / UI_BASE_W) -- = screenScale / 4

  love.graphics.push()
    love.graphics.translate(screenOffsetX, screenOffsetY)
    love.graphics.scale(uiScale, uiScale)
    drawMenus()
  love.graphics.pop()

  -- DEBUG: screen-space overlays (unscaled) go here if needed
  -- for _, v in ipairs(_Interactables) do v:draw() end
end

function love.resize(w, h)
  updateScreenScale()
end

function love.keypressed(key)
  if key == "f11" then
    toggleFullscreen()
  end
end

function love.quit()
  saveGame()
end

----------------------------------------------------------------
-- Init
----------------------------------------------------------------

function init()
  initLanguages()

  local window = Settings.Video.Window

  love.window.setTitle(Lang.windowTitle or "")
  love.window.setMode(window.w, window.h, {
    resizable      = true,
    fullscreen     = true,       -- make it start fullscreen
    fullscreentype = "desktop",  -- use desktop resolution
  })

  love.graphics.setBackgroundColor(23/255, 17/255, 26/255)
  love.keyboard.setKeyRepeat(true)

  love.graphics.setFont(love.graphics.newFont('Lunarie ExtCond.ttf', 18))
  mailFont     = love.graphics.newFont('smalle.ttf', 18)
  itemFont     = love.graphics.newFont('Lunarie ExtCond.ttf', 36)
  itemTipFont  = love.graphics.newFont('Lunarie ExtCond.ttf', 24)
  fishLogFont  = love.graphics.newFont('smalle.ttf', 12)

  love.graphics.setLineStyle('rough')
  love.graphics.setLineJoin('bevel')
  love.graphics.setLineWidth(1)

  canvas = love.graphics.newCanvas(BASE_W, BASE_H)

  sfx_soundscape:setVolume(0)
  sfx_soundscape:setLooping(true)
  sfx_soundscape:play()
  sfx_fireplace:setVolume(0)
  sfx_fireplace:setLooping(true)
  sfx_fireplace:play()

  updateSeason()

  rSeed = stringToSeed("PENGU".._date.month.._date.day.._time.h.._time.m.._time.s)
  love.math.setRandomSeed(rSeed)

  _flowerVariant = love.math.random(1, 4)

  initControls()
  pengu({x = -3, y = 32})
  initRooms()
  loadGame()

  updateScreenScale()
end

----------------------------------------------------------------
-- Languages / Controls
----------------------------------------------------------------

function initLanguages()
  local langFiles = love.filesystem.getDirectoryItems("langs")
  for _, v in ipairs(langFiles) do
    local name = v:gsub("%.lua$", "")
    table.insert(Settings.supportedLanguages, name)
    print('found language file: "' .. name .. '"')
  end

  local languageData = prerequire("langs." .. Settings.language)
  if languageData then
    Lang = languageData
    print('loaded language file: "' .. Settings.language .. '"')
    love.window.setTitle(Lang.windowTitle)
  else
    error('language file "' .. Settings.language .. '" doesn\'t exist!')
  end
end

function initControls()
  Input = lib_baton.new {
    controls = {
      up         = {'sc:w','key:up','button:dpup','axis:lefty-'},
      down       = {'sc:s','key:down','button:dpdown','axis:lefty+'},
      left       = {'sc:a','key:left','button:dpleft','axis:leftx-'},
      right      = {'sc:d','key:right','button:dpright','axis:leftx+'},
      confirm    = {'sc:e','key:return','button:a','button:b'},
      esc        = {'key:escape'},
      switchTool = {'key:tab','button:y','button:x'},
    },
    pairs = {
      move = {'left','right','up','down'},
    },
    joystick = love.joystick.getJoysticks()[1],
  }
end

----------------------------------------------------------------
-- Time / Season
----------------------------------------------------------------

function updateDateTime()
  local h, m, s = os.date("%X"):match("(%d%d):(%d%d):(%d%d)")
  _time.h = tonumber(h)
  _time.m = tonumber(m)
  _time.s = tonumber(s)
  _date.month = tonumber(os.date("%m"))
  _date.day   = tonumber(os.date("%d"))
  _date.year  = tonumber(os.date("%Y"))
end

function updateSeason()
  updateDateTime()
  firePlaceOn = false
  if (_date.month >= 1 and _date.month < 3) or _date.month >= 12 then
    _season = "winter"
    firePlaceOn = true
  elseif _date.month < 6 then
    _season = "spring"
  elseif _date.month < 9 then
    _season = "summer"
  else
    _season = "autumn"
  end
end

----------------------------------------------------------------
-- Utilities
----------------------------------------------------------------

function getWaveY(x, offset, onlyTideOffset)
  offset = offset or 0
  local ox = x/2 + offset + _t/4
  local t = ((_time.h*100) + _time.m + (_time.s/600)) / 2400
  local tideOffset = math.sin(t * 2) * 4
  local waveSine   = math.sin(math.cos(_t/2 + ox/16)) * 2
  local mediumSine = math.cos(-_t/2)
  local detailSine = math.sin((math.cos(_t+ox/2) + math.sin(_t*2+ox/4)) / 2)

  if onlyTideOffset then
    return tideOffset
  else
    return 54 + waveSine - mediumSine + detailSine + tideOffset
  end
end

function sourceHasEffect(source, effect)
  for _, v in pairs(source:getActiveEffects()) do
    if v.type == effect then return true end
  end
  return false
end

function sourceSetEffect(source, effectName, enabled)
  if not enabled and sourceHasEffect(source, effectName) then
    local time = source:tell("seconds")
    source:stop()
    source:setEffect(effectName, false)
    source:seek(time)
    source:play()
  else
    source:setEffect(effectName, enabled)
  end
end

function playSfx(sfx, vol, reverb, pitch)
  if sfx:isPlaying() then sfx:stop() end

  local filter = {type='lowpass', highgain=.7}
  if reverb then sfx:setFilter(filter) else sfx:setFilter() end

  sfx:setPitch(pitch or 1)
  sfx:setVolume(Settings.Audio.Volume * vol)
  sfx:play()
end

