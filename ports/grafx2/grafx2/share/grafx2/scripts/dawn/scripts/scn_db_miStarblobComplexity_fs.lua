--SCENE: MathRender - StarBlob Complexity
--by Richard 'DawnBringer' Fhager

-- Math-scene render with full Floyd-Steinberg dither


dofile("../libs/dawnbringer_lib.lua")


--
function main()

 local f,cap,star2,zoom,rot,sin,cos,tan,pi

 sin,cos,tan,pi2 = math.sin, math.cos, math.tan, math.pi * 2

 cap  = db.rgbcaps
 star2 = db.star2
 zoom = db.zoom
 rot  = db.rotationFrac

--
function f(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b, rs,gs,bs

  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

   r,g,b = 0,0,0;
   xf,yf = zoom(xf,yf,0.65,0.5,0.35); -- zoom & pan
   xf,yf = rot(-(15*yf+25*xf),0.5*xf,0.5, xf, yf); 
   rs,gs,bs = star2(xf,yf,xf,0.5+sin(xf*pi2)*0.5,    0.2,0.3,0.5, 1,8,700);   r = r+rs; g = g+gs; b = b+bs;
   rs,gs,bs = star2(xf,yf,xf,0.5+cos(yf*xf*29)*0.2,  0.5,0.3,0.2, 1,9,650);   r = r+rs; g = g+gs; b = b+bs;
   rs,gs,bs = star2(xf,yf,xf,0.5+tan(yf*3-xf*7)*0.5, 0.3,0.5,0.2, 0.5,1,109); r = r+rs; g = g+gs*yf; b = b+bs;

  --
  return cap(r,g,b)
  --return db.rgbcaps(r,g,b)
end
--

t1 = os.clock()

db.fsrenderControl(f, "Starblob Complexity", null,null,null, null,null,null, null, null)

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end -- main

main()
