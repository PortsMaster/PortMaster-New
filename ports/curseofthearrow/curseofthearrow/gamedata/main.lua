
love.graphics.setDefaultFilter("nearest","nearest")

require("touchcontrols")
require("api")
require("src.main")

flux = require("flux")

tc = {
  a = 0
}

function love.load()
  love.graphics.setBackgroundColor(0,0,0,1)

  if love.filesystem.getInfo("/gamecontrollerdb.txt") ~= nil then
    love.joystick.loadGamepadMappings("/gamecontrollerdb.txt")
  end

  if love.filesystem.getInfo("/JoystickID.txt") ~= nil then
    joysaveid = love.filesystem.read("/JoystickID.txt")
  end

  initializeAPI()

  if _init then
    _init()
  end

  apiResize()
end

local titleBase = love.window.getTitle().." FPS: "

function love.update(dt)
  love.window.setTitle(titleBase..love.timer.getFPS())
  for k, b in pairs(_keys) do
    if b == true then
      btns[k] = true
    end
  end

  if _update then
    _update(dt)
  end

  if g_ek then
    for k, b in pairs(_keys) do
      if b and b ~= "" then
        _keys[k] = ""
      end
    end
  end
end

function touch_fade()
  flux.to(tc, 0.4, { a = 100 })
end

function touch_fadeout()
  flux.to(tc, 0.4, { a = 0 })
end


function love.draw()
  apiPreDraw()

  if _draw then
    _draw()
  end

  flip()

  love.graphics.setColor(1, 1, 1, 1)

  if (g_ek and state ~= splash) or tc.a ~=0 then
    love.graphics.setScissor()
    local w, h = love.graphics.getDimensions()
    local s = 38--love.window.toPixels(38)--w / 25

    local sp = (state == splash or state == warn)
    local c = 255
    local a = 50
    local ad = 80

    mbutton(w - s * 2.5, h - s * 1.5, s, "z", sp and "X" or "Z", c,tc.a/255,ad)

    if not sp then
      mbutton(w - s * 1.5, h - s * 4, s, "x", "X", c,tc.a/255,ad)
      drawTouchJoy()
      mbutton((w - s), s, s / 2, "escape", "=", c,tc.a/255,100)
      mbutton((w - s), s*2.5, s / 2, "r", "R", c,tc.a/255,100)
    end

    love.graphics.setLineWidth(1)
  end
end

function love.gamepadpressed(joy, b)

  if (joy_map[b]) and joystick == joy then
    btns[joy_map[b]] = true
  end
end

function love.mousepressed(x, y, button, isTouch)
  if (not isTouch) and button == 1 then love.touchpressed(-1, x, y) end
end

function love.mousemoved(x, y, dx, dy, isTouch)
  if (not isTouch) and _touches[-1] then love.touchmoved(-1, x, y) end
end

function love.mousereleased(x, y, button, isTouch)
  if (not isTouch) and button == 1 then love.touchreleased(-1, x, y) end
end

_keys = {}
function mbutton(x, y, s, b, chr, c, al, ad)
  local a = al

  local released = true

  for id, touch in pairs(_touches) do
    if touch then
      local dx = x - touch[1]
      local dy = y - touch[2]
      if math.sqrt(dx * dx + dy * dy) < s then
        a = ad
        if b == "r" and not _keys[b] then
          love.keypressed(b)
        end
        _keys[b] = (_keys[b] and "" or true)
        released = false
        break
      end
    end
  end

  if released then
    _keys[b] = false
  end

  love.graphics.setColor(c, c, c, a)
  love.graphics.circle("fill", x, y, s)

  love.graphics.setColor(0,0,0,a)
  love.graphics.print(chr,x-1.5*(s/4),y-1.3*(s/2),0,s/16,s/16)
end

function love.resize()
  apiResize()
end

g_joysticks = {}

function love.joystickremoved(joy)
  add(aqu,{
    name = "Joystick removed",
    desc = "...",
    spr = 723,
    y = -16,
    bold = true
  })


  jadded = true
  del(g_joysticks, joy)
end

function love.joystickadded(joy)

  add(aqu,{
    name = "Joystick found",
    desc = "...",
    spr = 723,
    y = -32,
    bold = true
  })

  if joystick == nil then
    joystick = joy
  end

  jadded = true
  add(g_joysticks, joy)
  printh("Joystick found")

  if joysaveid then
    local thisSaveId = joy:getName().."_"..joy:getID().."_"..joy:getGUID()
    if joysaveid == thisSaveId then
      joystick = joy
      joyid = #g_joysticks
    end
  end
end

--A custom love.run to no let love.update to be called more than 60 times per second, because egor didn't use the dt argument in his code, pretending that update is called 60 times per second
local cycleTime, cycleTimer = 1/60, 1/60
function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local dt = 0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end
    
    cycleTimer = cycleTimer - dt
    
    if cycleTimer <= 0 or not love.timer then
      cycleTimer = math.max(cycleTime+cycleTimer,0)
      -- Call update and draw
      if love.update then love.update(cycleTime) end -- will pass 0 if love.timer is disabled
    end

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())

      if love.draw then love.draw() end

      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end