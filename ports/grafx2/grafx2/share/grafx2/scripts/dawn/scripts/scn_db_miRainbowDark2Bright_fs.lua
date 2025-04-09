--SCENE: MathRender - Rainbow Dark 2 Bright
--by Richard 'DawnBringer' Fhager


dofile("../libs/dawnbringer_lib.lua")

-- Math-scene render with full Floyd-Steinberg dither

--
function main()

 local f,sin,cap,shiftHue

 sin = math.sin

 cap = db.rgbcaps
 shiftHue = db.shiftHUE

--
function f(x,y,w,h) -- SCENE
  local xf,yf,r,g,b

  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

   r = 255 * sin(yf * 2) 
   g = (yf-0.5)*512 * yf
   b = g

   r,g,b = shiftHue(r,g,b,xf * 360); 

  return cap(r,g,b)
end
--

t1 = os.clock()

db.fsrenderControl(f, "Rainbow Dark 2 Bright", null,null,null, null,null,null, null, null)

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end 
-- main

main()