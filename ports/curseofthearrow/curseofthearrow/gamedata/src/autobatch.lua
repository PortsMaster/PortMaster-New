--
-- autobatch.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local autobatch = { _version = "0.1.1" }
setmetatable(autobatch, { __index = love.graphics })

-- Use local reference to love.graphics as we overwrite it later
local love_graphics = love.graphics

autobatch.threshold = 4
autobatch.batches = setmetatable( {}, { __mode = "k" } )
autobatch.pending = { image = nil, draws = 0 }
autobatch.color = { 255, 255, 255 }
autobatch.image = nil


local function switchActiveImage(img)
  -- Draw and reset old image's spritebatch if we have one; if not we reset
  -- love's color state as the spritebatch's color state will be used instead
  if autobatch.image then
    local b = autobatch.batches[autobatch.image]
    love_graphics.draw(b.sb)
    b.sb:clear()
    b.count = 0
  else
    love_graphics.setColor(255, 255, 255)
  end
  -- Activate spritebatch if image was not nil
  if img then
    local b = autobatch.batches[img]
    -- Create batch if it doesn't exist
    if not b then
      b = {}
      b.count = 0
      b.capacity = 16
      b.sb = love_graphics.newSpriteBatch(img, b.capacity, "stream")
      autobatch.batches[img] = b
    end
    -- Init spritebatch's color
    b.sb:setColor( unpack(autobatch.color) )
  end
  -- Set new image
  autobatch.image = img
end


local function flushAndDraw(...)
  autobatch.flush()
  return love_graphics.draw(...)
end


function autobatch.draw(image, ...)
  if image ~= autobatch.image then
    if not autobatch.batches[image] then
      -- Only Textures (Image or Canvas) can be batched -- if the image is
      -- neither of these then we draw normally instead
      if not image:typeOf("Texture") then
        return flushAndDraw(image, ...)
      end
      -- Check to see if it's the pending image, and whether it's reached the
      -- draw count threshold; if so we can switch to it as the active image and
      -- create a batch for it, otherwise we just increment the count and draw
      -- it normally
      if image == autobatch.pending.image then
        autobatch.pending.draws = autobatch.pending.draws + 1
        if autobatch.pending.draws < autobatch.threshold then
          return flushAndDraw(image, ...)
        end
      else
        autobatch.pending.image = image
        autobatch.pending.draws = 1
        return flushAndDraw(image, ...)
      end
    end
    -- Reset pending image
    autobatch.pending.image = nil
    -- Switch active image
    switchActiveImage(image)
  end
  -- Get active batch
  local b = autobatch.batches[autobatch.image]
  -- Increase spritebatch capacity if we've reached it
  if b.count == b.capacity then
    b.capacity = b.capacity * 2
    b.sb:setBufferSize(b.capacity)
  end
  -- Add to spritebatch
  b.sb:add(...)
  b.count = b.count + 1
end


function autobatch.setColor(r, g, b, a)
  local t = autobatch.color
  -- Unpack color if it's a table
  if type(r) == "table" then
    r, g, b, a = unpack(r)
  end
  -- Exit early if color isn't different to the current color
  if t[1] == r and t[2] == g and t[3] == b and t[4] == a then
    return
  end
  -- Set active color
  t[1], t[2], t[3], t[4] = r, g, b, a
  -- Set active color on active spritebatch or in love.graphics if no
  -- image is active
  local b = autobatch.batches[autobatch.image]
  if b then
    b.sb:setColor( unpack(autobatch.color) )
  else
    love_graphics.setColor( unpack(autobatch.color) )
  end
end


function autobatch.getColor()
  return unpack(autobatch.color)
end


function autobatch.reset()
  autobatch.flush()
  autobatch.setColor(255, 255, 255, 255)
  love_graphics.reset()
end


function autobatch.flush()
  -- If we have an active image set switch from it to draw the active batch and
  -- reset love's color to match our internal one
  if autobatch.image then
    switchActiveImage(nil)
    love_graphics.setColor( unpack(autobatch.color) )
  end
end


local function wrap(fn)
  return function(...)
    autobatch.flush()
    return fn(...)
  end
end

-- Initialise wrapper functions for all graphics functions which change the
-- state or draw to the screen, thus requiring that the autobatch be flushed
-- prior. reset() and setColor() are special cases handled above
local names = {
  "arc",
  "circle",
  "clear",
  "discard",
  "ellipse",
  "line",
  "points",
  "polygon",
  "present",
  "print",
  "printf",
  "rectangle",
  "stencil",
  "getStats",
  "setBlendMode",
  "setCanvas",
  "setColorMask",
  "setScissor",
  "setShader",
  "setStencilTest",
  "origin",
  "pop",
  "push",
  "rotate",
  "scale",
  "shear",
  "translate",
}

for i, name in ipairs(names) do
  autobatch[name] = wrap( love_graphics[name] )
end


-- Override love.graphics
love.graphics = autobatch

-- Wrap Canvas functions
local mt = getmetatable( love_graphics.newCanvas(1, 1) )

local fn = mt.renderTo
mt.renderTo = function(self, fn)
  local old = { autobatch.getCanvas() }
  autobatch.setCanvas(self)
  fn()
  autobatch.setCanvas( unpack(old) )
end

mt.newImageData = wrap(mt.newImageData)

-- Wrap Shader functions
local mt = getmetatable( love_graphics.newShader([[
  vec4 effect(vec4 a, Image b, vec2 c, vec2 d) { return a; }
]]) )

mt.send = wrap(mt.send)
mt.sendColor = wrap(mt.sendColor)


return autobatch