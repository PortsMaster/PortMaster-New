-- tick
-- https://github.com/bjornbytes/tick
-- MIT License

local tick = {
  framerate = nil,
  rate = .03,
  timescale = 1,
  sleep = .001,
  dt = 0,
  accum = 0,
  tick = 1,
  frame = 1
}

local timer = love.timer
local graphics = love.graphics
numUpdates = 0 -- everything related to this is our own custom code to track double updates / stuttering
love.run = function()
  if not timer then
    error('love.timer is required for tick')
  end

  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  timer.step()
  local lastframe = 0

  -- if love.update then love.update(0) end -- Need to comment this because otherwise our initial controller connections don't work

  return function()
    tick.dt = timer.step() * tick.timescale
    if (tick.dt > maxDT) then
      tick.dt = maxDT
      print("clamped DT")
    end
    tick.accum = tick.accum + tick.dt
    if not usetick then
      gameUpdate(tick.dt)
    end
    numUpdates = 0
    while tick.accum >= tick.rate do
      tick.accum = tick.accum - tick.rate

      if love.event then
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
          if name == 'quit' then
            if not love.quit or not love.quit() then
              return a or 0
            end
          end

          love.handlers[name](a, b, c, d, e, f)
        end
      end

      tick.tick = tick.tick + 1
      if usetick then
        if love.update then love.update(tick.rate) end
      else
        if physUpdate(tick.rate) then physUpdate(tick.rate) end
      end
      numUpdates = numUpdates + 1
    end
    logFrameUpdateStatus(numUpdates)

    while tick.framerate and timer.getTime() - lastframe < 1 / tick.framerate do
      timer.sleep(.0005)
    end

    lastframe = timer.getTime()
    if graphics and graphics.isActive() then
      graphics.origin()
      graphics.clear(graphics.getBackgroundColor())
      tick.frame = tick.frame + 1
      if love.draw then love.draw() end
      graphics.present()
    end

    timer.sleep(tick.sleep)
  end
end

return tick
