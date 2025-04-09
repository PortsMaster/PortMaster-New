--Distortion: Map, Lightsource wip. Current state using ripple-formula, not spare-image or blurring
--by Richard Fhager 


dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")

cx,cy = 0.5, 0.5
elastic = 0 -- "elastic" edges
Strength_Multiplier = 2 -- (1 + 0.5*Strength_Multiplier), 2 means x0.5-x2, 6 means x0.25-x4 (at 100%)

OK,str,elastic,smooth,ip,gamma, lightpower = inputbox("Distortion Mapping",
                        
                           --"1. FISH EYE (Expand)",  fisheye,  0,1,-1,

                           "Strength %: 1-600",       50,  1,600,1,
 
                           "Elastic Edges over Void", elastic,  0,1,0,

                           "Blur DistMap (5x5 Gauss)", 0,  0,1,0,
                        
                           "Interpolate#",           0,  0,1,0,
                           "# IP Gamma",             1.6,  0.1,5.0,3,

                           "Light %: 0-100",       25,  0,1000,1

                                                                      
);

if OK then

 cos,floor,max,min,abs = math.cos, math.floor, math.max, math.min, math.abs

 Spare_Bri = {}
 for c = 0, 255, 1 do
  r,g,b = getsparecolor(c)
  Spare_Bri[c+1] = db.getBrightness(r,g,b) / 255
 end

 -- Brightness of spare image colorindex [i] at pixel x,y as fraction of 1
 function getSparePixelValue(x,y)
  return Spare_Bri[getsparepicturepixel(x,y)+1] 
 end
 --

-- For Lightsource
function getValue(x,y)
 --v = Spare_Bri[getsparepicturepixel(x,y)+1]
 v = 0.5 + db.alpha1(x/w,y/h,1) * 0.5 * 0.1
 --x = min(x,w-1)
 --y = min(y,h-1) 
 --v = blurMap[y+1][x+1]
 return v
end
--

 --
 function lightMap(i,v, strength)
  local m,r,g,b
  m = (v-0.5) * strength
  r,g,b = getcolor(i)
  r = min(255,max(0,r + m))
  g = min(255,max(0,g + m))
  b = min(255,max(0,b + m))
  return matchcolor2(r,g,b)
 end
 --

-- db.calcLightRGBopt(fcol,z1,z2,z3,light,amp,scl,amb)

--fcol = {0,0,0} -- Basecolor RGB (Polygon surface color)
-- AMP = 0.85  -- Lights: Luminance multiple, nom=1.0 (amp); Map: 0.8, Sphere: 0.99
-- SCL = 0.15*256 -- Lights: Angle scale/'Global specularity'/Yscale, nom=1.0? (scl); Map 0.1: Sphere 0.21
-- AMB = 0.01 -- Lights: Ambient addition, 0..1 (amb); 
-- Lightsources: Azimuth,Elevation,[R,G,B], bri-softness/drk-specularity: higher = more specular
-- LS = {{90,60,{255,255,255},2}}

 --
 function lightMap2(i, v0,x,y, strength) -- i is color index (point/polygon base color), v0 is dt in loop
  local m,r,g,b,v1,v2,rgb,light,amp,scl,amb,r1,g1,b1
  --m = (v0-0.5) * strength
  m = 0
  -- Scale of heights changes angles, 1&2 is not the same as 2&4
  -- values are multiplied with 'scl', so either scale the points or 'scl', not both
  v0 = getValue(x,y) -- points are 0..1, at scl=1.0 a max 0/1 diff means 45 degrees (proportions)
  v1 = getValue(x+1,y)
  v2 = getValue(x,y+1)
  
  r,g,b = getcolor(i)
 
  amp = 1.0
  scl = 256.0 -- 256 means that a change in value of 1 (1 color step) has an angle of 45 degrees
  amb = 0.0
  light = {{180+45,55,{255,255,255},1}, {45,60,{85,85,85},2}, {100,70,{64,64,64},3}} -- Zenith is 0, top is 180
  
  rgb = db.calcLightRGBopt({0,0,0},v0,v1,v2,light,amp,scl,amb)

  r1,g1,b1 = rgb[1],rgb[2],rgb[3]

  d = -127
  -- Use natural brightness here?
  r = min(255,max(0,r + strength*(r1+d) + m)) -- Greater strength increases contrast, dark areas also get darker
  g = min(255,max(0,g + strength*(g1+d) + m))
  b = min(255,max(0,b + strength*(b1+d) + m))
  return matchcolor2(r,g,b)
 end
 --

 --
 -- Create a blurred/smoothed version of the Distortion Map (spare image), values are 0..1
 --
 function makeBlurMap(w,h)

    local x,y,sum,xx,yy,blurmap,m5x5,m5x5y,dt,vl,vd,f,abs,ceil

    abs,ceil = math.abs,math.ceil

    blurmap = {}

    m5x5 = {{ 1, 4, 7}, -- Top left quadrant of the matrix, utilize the symmetry in application
            { 4,16,26},
            { 7,26,41}
           }
    m5x5.tot = 273 --* 255 -- 273 is sum of 5x5 matrix and 255 is full grayscale value

    f = getSparePixelValue

    for y = 0, h - 1, 1 do
     blurmap[y+1] = {}
     for x = 0, w - 1, 1 do

      dt = f(x,y)

      -- 5x5 Gaussian blur of distortion map  (Anti-Integer)
      if x > 1 and x < w-2 and y > 1 and y < h-2 then
       sum = 0
       for yy = -2, 2, 1 do
        m5x5y = m5x5[3 - abs(yy)]
        for xx = -2, 2, 1 do 
         sum = sum + m5x5y[3 - abs(xx)] * f(x+xx,y+yy)
        end
       end      
       dt = sum / m5x5.tot
 
        else -- 1 pixel from edge (3x3 matrix)
           
         if x > 0 and x < w-1 and y > 0 and y < h-1 then
          vl = (f(x-1,y) + f(x+1,y) + f(x,y-1) + f(x,y+1)) * 0.5 -- /255 if getsparepixel
          vd = (f(x-1,y-1) + f(x+1,y-1) + f(x-1,y+1) + f(x+1,y+1)) * 0.25
          sum = (dt + vl + vd) * 0.25
          dt = sum
         end -- 3x3
 
      end -- 5x5
      
      blurmap[y+1][x+1] = dt
     end -- x
     if (y%5 == 0) then statusmessage("Blurring DistMap: %"..ceil((y/h)*100));waitbreak(0); end
    end -- y

    return blurmap
 end
 --

 linear = 1
 bi = 0
 cubic = 0
 if ip == 1 then 
  linear = 0
  bi = 1
  cubic = 0
 end

strength = str / 100 -- 0..1, 0 is full effect

Lights = false
if lightpower > 0 then
 Lights = true
 light_strength = lightpower / 100 * 512 -- 512 is max (0.5 * 512 = 256)
end


w, h = getpicturesize()
f1 = getbackuppixel
f2 = putpicturepixel


-- Multiplying position with w or h should stay withing screen pixels (0..w-1)
--xlimit,ylimit = (w-1)/w, (h-1)/h

 w1,h1 = w-1,h-1

 if smooth == 1 then
  --statusmessage("Bluring Distortion Map (Spare image)")
  blurMap = makeBlurMap(w,h)
 end 

 final_strength = strength * Strength_Multiplier

for y = 0, h - 1, 1 do
  oyo = y / h1;
  for x = 0, w - 1, 1 do

      oy = oyo
      ox = x / w1;

      -- Scaling by distance (d=1 does nothing, d=2 is half size)
      --ex = 0.5; mt = 2
      dx = cx-ox
      dy = cy-oy
      --dt = (dx*dx + dy*dy)^ex * mt
      --dt = getsparepicturepixel(x,y)/255
      --dt = getSparePixelValue(x,y)

     --
     if smooth == 1 then
      dt = blurMap[y+1][x+1]
       else
        dt = getSparePixelValue(x,y)
     end -- smooth
     --

 dt = 0.5 + db.alpha1(ox,oy,1) * 0.5 * 0.1 -- alpha1 returns 0..2 I think
--dt = 0.5

      -- 1..2 / 1..0.5 range will produce a x0.5 (black) to x2 (white) zoom.
      -- Note: Running *2 at 100% strength is the same as *4 at 50 % strength

      if dt >= 0.5 then -- Scale Up (gray to white)     
         d = 1 / (1 + (dt-0.5) * final_strength) -- "linear", working
         --d = 1 - (dt-0.5) * final_strength -- Curved (classic, works for all values, but flips out near white)

        else -- Scale Down (black to gray)
         
         d = 1 / (1 - min(1,(0.5-dt) * final_strength)) -- Linear appearance
         --d = 1 + (0.5-dt) * final_strength  -- "curved", working 1..2
     
      end

       ox = cx - dx * d
       oy = cy - dy * d

        if elastic == 1 then
         ox = max(0,min(ox,1)); oy = max(0,min(oy,1)) -- "Elastic Edges"
        end

        if (ox >= 0 and ox <= 1 and oy >= 0 and oy <= 1) or elastic == 1 then

          posx,posy = ox*w1, oy*h1

          if linear == 1 then
           c = f1(floor(posx + 0.5),floor(posy + 0.5)) 
          end

          fget = getbackupcolor


          if bi == 1 then
            if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             -- Out of bounds means Transparancy color is used (by system)
             r,g,b = ip_.pixelRGB_Bilinear(posx,posy,fget,f1,ip_.kenip) -- px,py, col_func, get_func, ip_func
             else
              --r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.kenip,gamma) -- px,py, col_func, get_func, ip_func
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.linip,gamma)   
           end
           c = matchcolor2(r,g,b) 
          end

          if cubic == 1 then
           r,g,b = ip_.pixelRGB_Bicubic(posx,posy,fget,f1,ip_.cubip)
           c = matchcolor2(r,g,b) 
          end

          --if Lights then c = lightMap(c, dt, light_strength * final_strength); end
          if Lights then c = lightMap2(c, dt,x,y, light_strength * final_strength / 512); end

          f2(x, y, c);
  
           else f2(x,y,0)
        end
     
  end
  --if pic == 1 and y%8==0 then updatescreen();if (waitbreak(0)==1) then return; end; end
  if db.donemeter(10,y,w,h,true) then return; end

end

end; -- OK


