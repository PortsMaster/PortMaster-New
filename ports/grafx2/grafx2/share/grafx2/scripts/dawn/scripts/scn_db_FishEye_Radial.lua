--BRUSH/PICTURE: FishEye+Collapse Distortion
--(Radial Distance Method (Photoshop Style))
--by Richard 'DawnBringer' Fhager


dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")

--prePIC / preBRU is set in toolbox-script
--if prePIC == null then prePIC = 1; end
--if preBRU == null then preBRU = 0; end

-- Preselections set in toolbox-script
prePIC = prePIC or 1
preBRU = preBRU or 0
preMOD = preMOD or 2 -- 2 is default standalone mode

suffix = " (Image)"
title = "Radial Distortions"
fisheye = 1
collapse = 0

if preBRU == 1 then
 suffix = " (Brush)"
end

if preMOD == 0 then
 title = "FishEye Distortion"
 fisheye = 1
 collapse = 0
end

if preMOD == 1 then
 title = "Collapse Distortion"
 fisheye = 0
 collapse = 1
end

-- Frequency (scale) and center position, ex: with freq = 0.5 the effect can be placed at an edge f.ex. 0,0
freq = 1.0
cx,cy = 0.5, 0.5
prePIC = prePIC or 1
preBRU = preBRU or 0
OK,fisheye,collapse,str,cx,cy,ip,gamma = inputbox(title..suffix,
                        
                           "1. FISH EYE (expand)",  fisheye,  0,1,-1,
                           "2. COLLAPSE (pinch))",  collapse,  0,1,-1,

                           "Strength %: 1-100",       90,  1,100,1, 
                         
                           "Center X: 0..1",       cx, 0,1,3,
                           "Center Y: 0..1",       cy, 0,1,3, 
                        
                           "Interpolate *",           1,  0,1,0,
                           "* IP Gamma",             1.6,  0.1,5.0,3
                                                                      
);

--"Frequency: 0.1-32",      freq,  0.1,32,2,
--"Picture",        prePIC,  0,1,-1, 
--"Brush",          preBRU,  0,1,-1,

if OK then

 linear = 1
 bi = 0
 cubic = 0
 if ip == 1 then 
  linear = 0
  bi = 1 -- Bilinear is to prefer over bicubic when it comes to distortions
  cubic = 0
 end

strength = 1 - str / 100 -- 0..1, 0 is full effect

pic,bru = 1,0
if preBRU == 1 then pic,bru = 0,1; end

if bru == 1 then
 w, h = getbrushsize()
 f1 = getbrushbackuppixel
 f2 = putbrushpixel
end

if pic == 1 then
 w, h = getpicturesize()
 f1 = getbackuppixel
 f2 = putpicturepixel
end


cos,floor,max,min,abs = math.cos, math.floor, math.max, math.min, math.abs

-- Multiplying position with w or h should stay withing screen pixels (0..w-1)
--xlimit,ylimit = (w-1)/w, (h-1)/h
xlimit,ylimit = 1,1 -- w1,h1

w1,h1 = w-1,h-1

for y = 0, h - 1, 1 do
  oyo = y / h1;
  for x = 0, w - 1, 1 do

      oy = oyo
      ox = x / w1;

      -- Similar to Pinch in Photoshop    

      -- Scaling by distance (d=1 does nothing, d=2 is half size)
      ex = 0.5; mt = 2
      dx = cx-ox
      dy = cy-oy
      dt = (dx*dx + dy*dy)^ex * mt

     if dt <= 1 then -- Just do things inside radius

      d = strength -- 0..1 (also, higher distance exponent increases effect, but it's wider and softer in the centre)

      q = 1-min(1,dt)^(1-min(1,dt)^7) -- Ease out, higer exp approaches the normal (sharp) circle end

      d = d*q + (1-q)*1 -- effect transitions to nothing at edge of circle ("*1" designates normal/no effect)

      if collapse == 1 then
       soft = 0.25 -- Collapse is very strong
       d = (1 + soft) / (d + soft) -- collapse
      end

       ox = cx - dx * d
       oy = cy - dy * d

         ox = max(0,min(ox,xlimit)) -- 1 is a coord outside screen
         oy = max(0,min(oy,ylimit)) 

         posx, posy = ox*w1, oy*h1

          if linear == 1 then
           c = f1(floor(posx + 0.5),floor(posy + 0.5));
           -- AA-levles test, increasing levels seem to approach the result of IP
           --c = matchcolor2(ip_.fractionalSampling(6, posx,posy, w1,h1, (function(ox,oy,w,h) return getcolor(f1(ox*w+0.5,oy*h+0.5)); end), gamma))
          end

          if bi == 1 then
            if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             r,g,b = ip_.pixelRGB_Bilinear(posx, posy, getbackupcolor,f1,ip_.kenip) -- px,py, col_func, get_func, ip_func
             else
              --r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx, posy, getbackupcolor,f1,ip_.kenip,gamma) -- px,py, col_func, get_func, ip_func
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx, posy, getbackupcolor,f1,ip_.linip,gamma)   
           end
           --v = -2 + ((x+y)%2)*4
           c = matchcolor2(r,g,b) 
          end

          if cubic == 1 then
           r,g,b = ip_.pixelRGB_Bicubic(posx, posy, getbackupcolor,f1,ip_.cubip)
           c = matchcolor2(r,g,b) 
          end

          f2(x, y, c);
  
           else f2(x,y,f1(x,y))
        end -- inside radius
     
  end
  --if pic == 1 and y%8==0 then updatescreen();if (waitbreak(0)==1) then return; end; end
  if pic == 1 and db.donemeter(10,y,w,h,true) then return; end

end

end; -- OK


