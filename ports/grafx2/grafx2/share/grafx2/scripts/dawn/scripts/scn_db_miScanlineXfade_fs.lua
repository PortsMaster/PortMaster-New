--SCENE: MathRender - Scanline X-Fade
--by Richard 'DawnBringer' Fhager


-- Math-scene render with full Floyd-Steinberg dither


dofile("../libs/dawnbringer_lib.lua")

function main()

 local T1,T2,S
 local f,cap,twirl,zoom,star2,rot
 local sin, cos, tan, pi2

 cap = db.rgbcaps
 twirl = db.twirl
 zoom = db.zoom
 star2 = db.star2
 rot = db.rotationFrac

 sin,cos,tan,pi2 = math.sin, math.cos, math.tan, math.pi * 2

--
function f(x,y,w,h) -- SCENE
  local xf,yf,r,g,b,rs,gs,bs
  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  if y%2 == 0 then
   -- PsychoTwirl
   T1 = twirl(xf+0.025,yf+0.025,32,360,0.05,0); --  #Arms,Twirl,DistPow,Rot
   T2 = twirl(xf-0.025,yf-0.025,32,-360,0.05,0); -- #Arms,Twirl,DistPow,Rot
   r = xf * (16 + (T1 * 208 * (0.5+yf/2)) + (T2 * 208 * (0.5+yf/2)))
   g = xf * (16 + (T1 * 176) + (T2 * 96))
   b = xf * (48 + (T2 * 192) + (T1 * 160))
   return cap(r,g,b)
  end
 
  if y%2 == 1 then
   xr = 1-xf
   xf,yf = zoom(xf,yf,0.65,0.5,0.35); 
   xf,yf = rot(-(15*yf+25*xf),0.5*xf,0.5, xf, yf); 
   r,g,b = 0,0,0;
   rs,gs,bs = star2(xf,yf,xf,0.5+sin(xf*pi2)*0.5, 0.2,0.3,0.5, 1,8,700);      r = r+rs; g = g+gs; b = b+bs;
   rs,gs,bs = star2(xf,yf,xf,0.5+cos(yf*xf*29)*0.2, 0.5,0.3,0.2, 1,9,650);    r = r+rs; g = g+gs; b = b+bs;
   rs,gs,bs = star2(xf,yf,xf,0.5+tan(yf*3-xf*7)*0.5, 0.3,0.5,0.2, 0.5,1,109); r = r+rs; g = g+gs*yf; b = b+bs;
   r,g,b = r*xr,g*xr,b*xr
   return cap(r,g,b)
  end

  --
  --return cap(r,g,b)
end
--

t1 = os.clock()

db.fsrenderControl(f, "Scanline X-Fade", null,null,null, null,5,0, null, null)

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end 
-- main

main()
