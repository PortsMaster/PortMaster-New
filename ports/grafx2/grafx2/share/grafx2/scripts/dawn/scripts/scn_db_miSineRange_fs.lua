--SCENE: MathRender - Sine Range
--by Richard 'DawnBringer' Fhager


-- Math-scene render with full Floyd-Steinberg dither


dofile("../libs/dawnbringer_lib.lua")

function f(x,y,w,h) -- SCENE
  local xf,yf,r,g,b
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  r = xf * 255
  g = yf * 255
  b = math.sin((r*r + g*g)^0.5 / 96) * 255

  --
  return db.rgbcaps(r,g,b)
end

db.fsrenderControl(f, "Sine Range", null,null,null, null,null,null, null, null)
