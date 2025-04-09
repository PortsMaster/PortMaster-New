dofile("../libs/dawnbringer_lib.lua")

-- Math-scene render with full Floyd-Steinberg dither

function f(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,m,c,P,F,S,r,g,b,ma,px,py,Xr,Yr
  m = math
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  r = xf * 255
  g = 0
  b = 0
  
  --
  return db.rgbcaps(r,g,b)
end

db.fsrenderControl(f, "Psycho Twirl", null,null,null, null,null,null, null, null)
