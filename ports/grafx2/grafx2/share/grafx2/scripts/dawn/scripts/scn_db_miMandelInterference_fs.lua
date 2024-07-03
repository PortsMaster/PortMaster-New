--SCENE: MathRender - MandelInterference V2.1 
--by Richard 'DawnBringer' Fhager
--
-- Math-scene render with full Floyd-Steinberg dither



-- V2.1: Localizing, Smooth Mandelbrot update


dofile("../libs/dawnbringer_lib.lua")

--
function main()

 -- Localizing and predefining stuff gives about a 2.5% speed increase

 local f, mandel, iter, span, log2, rot, cap, alpha, sin, abs, log, pi

  iter = 64
  span = math.abs(0.7 - (-1.7))
  log2 = math.log(2)
  sin = math.sin
  abs = math.abs
  log = math.log
  pi  = math.pi
 

  rot = db.rotationFrac
  cap = db.rgbcaps
  alpha = db.alpha1

--
 function mandel(x,y,l,r,o,i,s) -- pos. as fraction of 1, left coord, right coord, y coord, iterations 

   local w,a,p,q,n,v

   --s = abs(r-l);

   a = l + s*x;
   p = a;
   b = o - s*(y-0.5);
   q = b;
   n,v,w = 1,0,0;
 
   while ((v+w)<256 and n<i) do n=n+1; v=p*p; w=q*q; q=2*p*q+b; p=v-w+a; end; -- 256 rather than 4 for better smootness

   return n,q,p
 end
 --

--
function f(x,y,w,h) -- SCENE
  local xf,yf,S,r,g,b,c,P,F,S,r,g,b,ma,px,py,Xr,Yr,p1,q1

  xf = x / w
  yf = y / h
  --
  -- Code (This is the only thing that need to be changed in this script to create a new image)
  --

  xf,yf = rot(-120,0.5,0.5,xf,yf);
  Xr = 1-xf; Yr = 1-yf;
  py = 0; if (yf*100 % 10 < 0.25) then py = 1; end
  px = 0; if (xf*100 % 10 < 0.25) then px = 1; end 
  P = 224 - 24*Xr*yf*(px + py); -- Paper
  F = 1-abs(Yr-xf*xf)
  S = 1-(abs(sin(xf*pi) - Yr))^0.5;
  c = 0.25 + alpha(xf,yf,0.25);
  ma,p1,q1 = mandel(xf,yf,-1.7,0.7,0,iter,span); 
  
   if ma < iter then
    nu = log( log(p1*p1 + q1*q1)*0.5 / log2 ) / log2
    ma = ma + 1 - nu
   end

  if ma>=64 then ma = 0; end -- Don't fill with black inside the "bug"

  ma = ma * 26 * (1 - c);

  r = (P - F*(128*yf + 160) + S*144) * c + ma
  g = (P - F*208 + S*128) * c + ma + 24
  b = (P - F*(96*Yr + 160) + S*112) * c + ma

  r = r + (r-127.5)*yf*-2.5;
  g = g + (g-127.5)*yf*-2.2;
  b = b + (b-127.5)*yf*-2;
  
  -- 
  return cap(r,g,b)
end
--


t1 = os.clock()

db.fsrenderControl(f, "Mandel Interference", null,null,null, null,null,null, null, null)

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)

end
-- main

main()








--[[
w,h = getpicturesize()
f1 = function(x,y,w,h) return db.getBrightness(f(x,y,w,h))/255; end
db.gradientRender(f1, w,h, 0, 15,  db.dithOrder8x8_frac)
--]]