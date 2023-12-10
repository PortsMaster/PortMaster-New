--- A parser/renderer for Aseprite animations in LÖVE.
-- @classmod peachy

local peachy = {
  _VERSION = "1.0.0-alpha",
  _DESCRIPTION = "A parser/renderer for Aseprite animations in LÖVE.",
  _URL = "https://github.com/josh-perry/peachy",
  _LICENSE = [[
    MIT License

    Copyright (c) 2018 Josh Perry

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}

local json = require("helper/json")
local cron = require("helper/cron")

peachy.__index = peachy

--- Creates a new Peachy animation object.
  --
  -- If imageData isn't specified then Peachy will attempt to load it using the
  -- filename from the JSON data.
  --
  -- If no initial tag is set then the object will be paused (i.e. not displayed) with no tag.
  -- The animation will start playing immediately once created.
  --
  -- @usage
  -- -- Load the image ourselves and set animation tag to "Spin".
  -- -- Will start playing immediately.
  -- spinner = peachy.new("spinner.json", love.graphics.newImage("spinner.png"), "Spin")
  --
  -- @tparam string dataFile a path to an Aseprite JSON file. It is also possible to pass a predecoded table,
  -- which is useful for performance when creating large amounts of the same animation.
  -- @tparam Image imageData a LÖVE image  to animate.
  -- @tparam string initialTag the name of the animation tag to use initially.
  -- @return the new Peachy object.
  function peachy.new(dataFile, imageData, initialTag)
    assert(dataFile ~= nil, "No JSON data!")
  
    local self = setmetatable({}, peachy)
    
    -- check if datafile is a lua table (i.e. pre decoded)
    if type(dataFile) == 'table' then
      self._jsonData = dataFile
    else
      -- Read the data
      self._jsonData = json.decode(love.filesystem.read(dataFile))
    end

  -- Load the image
  self.image = imageData or love.graphics.newImage(self._jsonData.meta.image)

  self:_checkImageSize()

  self:_initializeFrames()
  self:_initializeTags()

  self.paused = true

  self.tag = nil
  self.tagName = nil
  self.direction = nil

  if initialTag then
    self:setTag(initialTag)
    self.paused = false
  end

  return self
end

--- Switch to a different animation tag.
-- In the case that we're attempting to switch to the animation currently playing,
-- nothing will happen.
--
-- @tparam string tag the animation tag name to switch to.
function peachy:setTag(tag)
  assert(tag, "No animation tag specified!")
  assert(self.frameTags[tag], "Tag "..tag.." not found in frametags!")

  if self.tag == self.frameTags[tag] then
    return
  end

  self.tagName = tag
  self.tag = self.frameTags[self.tagName]
  self.frameIndex = nil
  self.direction = self.tag.direction

  if self.direction == "pingpong" then
    self.direction = "forward"
  end

  self:nextFrame()
end

--- Jump to a particular frame index (1-based indexes) in the current animation.
--
-- Errors if the frame is outside the tag's frame range.
--
-- @usage
-- -- Go to the 4th frame
-- sound:setFrame(4)
--
-- @tparam number frame the frame index to jump to.
function peachy:setFrame(frame)
  if frame < 1 or frame > #self.tag.frames then
    error("Frame "..frame.." is out of range of tag '"..self.tagName.."' (1.."..#self.tag.frames..")")
  end

  self.frameIndex = frame

  self.frame = self.tag.frames[self.frameIndex]
  self.frameTimer = cron.after(self.frame.duration, self.nextFrame, self)
end

--- Draw the animation's current frame in a specified location.
-- @tparam number x the x position.
-- @tparam number y the y position.
-- @tparam number rot the rotation to draw at.
-- @tparam number sx the x scaling.
-- @tparam number sy the y scaling.
-- @tparam number ox the origin offset x.
-- @tparam number oy the origin offset y.
function peachy:draw(x, y, rot, sx, sy, ox, oy)
  if not self.frame then
    return
  end

  love.graphics.draw(self.image, self.frame.quad, x, y, rot or 0, sx or 1, sy or 1, ox or 0, oy or 0)
end

--- Update the animation.
-- @tparam number dt frame delta. Should be called from love.update and given the dt.
function peachy:update(dt)
  assert(dt, "No dt passed into update!")

  if self.paused then
    return
  end

  -- If we're trying to play an animation and it's nil or hasn't been set up
  -- properly then error
  assert(self.tag, "No animation tag has been set!")
  assert(self.frameTimer, "Frame timer hasn't been initialized!")

  -- Update timer in milliseconds since that's how Aseprite stores durations
  self.frameTimer:update(dt * 1000)
end

--- Move to the next frame.
-- Internal: unless you want to skip frames, this generally will not ever
-- need to be called manually.
function peachy:nextFrame()
  local forward = self.direction == "forward"

  if forward then
    self.frameIndex = (self.frameIndex or 0) + 1
  else
    self.frameIndex = (self.frameIndex or #self.tag.frames + 1) - 1
  end

  -- Looping
  if forward and self.frameIndex > #self.tag.frames then
    if self.tag.direction == "pingpong" then
      self:_pingpongBounce()
    else
      self.frameIndex = 1
    end
    self:call_onLoop()
  elseif not forward and self.frameIndex < 1 then
    if self.tag.direction == "pingpong" then
      self:_pingpongBounce()
    else
      self.frameIndex = #self.tag.frames
      self:call_onLoop()
    end
  end

  -- Get next frame
  self.frame = self.tag.frames[self.frameIndex]

  self.frameTimer = cron.after(self.frame.duration, self.nextFrame, self)
end

--- Check for callbacks
function peachy:call_onLoop()
  if self.callback_onLoop then self.callback_onLoop(unpack(self.args_onLoop)) end
end

--- Pauses the animation.
function peachy:pause()
  self.paused = true
end

--- Unpauses the animation.
function peachy:play()
  self.paused = false
end

--- Stops the animation (pause it then return to first frame or last if specified)
function peachy:stop(onLast)
  local index = 1
  self.paused = true
  if onLast then index = #self.tag.frames end
  self:setFrame(index)
end

--- Adds a callback function that will be called when the animation loops
function peachy:onLoop(fn, ...)
  self.callback_onLoop = fn
  self.args_onLoop = {...}
end

--- Toggle between playing/paused.
function peachy:togglePlay()
  if self.paused then
    self:play()
  else
    self:pause()
  end
end

--- Provides width stored in the metadata of a current frame
function peachy:getWidth()
    return self._jsonData.frames[self.frameIndex].frame.w
end

--- Provides height stored in the metadata of a current frame
function peachy:getHeight()
    return self._jsonData.frames[self.frameIndex].frame.h
end

--- Internal: handles the ping-pong animation type.
--
-- Should only be called when we actually want to bounce.
-- Swaps the direction.
function peachy:_pingpongBounce()
  -- We need to increment/decrement frame index by 2 because
  -- at this point we've already gone to the next frame
  if self.direction == "forward" then
    self.direction = "reverse"
    self.frameIndex = self.frameIndex - 2
  else
    self.direction = "forward"
    self.frameIndex = self.frameIndex + 2
  end
end

--- Internal: loads all of the frames
--
-- Loads quads and frame duration data from the JSON.
--
-- Called from peachy.new
function peachy:_initializeFrames()
  assert(self._jsonData ~= nil, "No JSON data!")
  assert(self._jsonData.meta ~= nil, "No metadata in JSON!")
  assert(self._jsonData.frames ~= nil, "No frame data in JSON!")

  -- Initialize all the quads
  self.frames = {}
  for _, frameData in ipairs(self._jsonData.frames) do
    local frame = {}

    local fd = frameData.frame
    frame.quad = love.graphics.newQuad(fd.x, fd.y, fd.w, fd.h, self._jsonData.meta.size.w, self._jsonData.meta.size.h)
    frame.duration = frameData.duration

    table.insert(self.frames, frame)
  end
end

--- Internal: loads all of the animation tags
--
-- Called from peachy.new
function peachy:_initializeTags()
  assert(self._jsonData ~= nil, "No JSON data!")
  assert(self._jsonData.meta ~= nil, "No metadata in JSON!")
  assert(self._jsonData.meta.frameTags ~= nil, "No frame tags in JSON! Make sure you exported them in Aseprite!")

  self.frameTags = {}

  for _, frameTag in ipairs(self._jsonData.meta.frameTags) do
    local ft = {}
    ft.direction = frameTag.direction
    ft.frames = {}

    for frame = frameTag.from + 1, frameTag.to + 1 do
      table.insert(ft.frames, self.frames[frame])
    end

    self.frameTags[frameTag.name] = ft
  end
end

--- Internal: checks that the loaded image size matches the metadata
--
-- Called from peachy.new
function peachy:_checkImageSize()
  local imageWidth, imageHeight = self._jsonData.meta.size.w, self._jsonData.meta.size.h
  assert(imageWidth == self.image:getWidth(), "Image width metadata doesn't match actual width of file")
  assert(imageHeight == self.image:getHeight(), "Image height metadata doesn't match actual height of file")
end

return peachy
