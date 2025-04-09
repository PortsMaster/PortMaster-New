--PICTURE: Distortion Map (using spare-image)
--by Richard Fhager 

--messagebox(math.log(100, 10))
dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")

--
function main()

 local c,r,g,b,w,h,w1,h1,cx,cy,d,fx,fy,oyf,dt,dx,dy,ox,oy,posx,posy,t1,t2,pal
 local Lights, light_strength, Strength_Multiplier, strength, final_strength 
 local cos,floor,max,min,abs,log
 local OK,str,smooth,basic,bilinear,subpixel,Levels,gamma,lightpower,elastic
 local f1,f2,fget
 local Spare_Bri, blurmap
 local getSparePixelValue, lightMap, lightMapNatural, makeBlurMap, control

 cx,cy = 0.5, 0.5
 elastic = 0 -- "elastic" edges
 Strength_Multiplier = 2 -- (1 + 0.5*Strength_Multiplier), 2 means x0.5-x2, 6 means x0.25-x4 (at 100%)

 OK,str,smooth,basic,bilinear,subpixel,Levels,gamma,lightpower,elastic = inputbox("Distortion Mapping (using Spare)",

                           "Strength %: 1-600",       50,  0,600,1,

                           "Blur DistMap (5x5 Gauss)", 1,  0,1,0,

                           "1. Basic (No IP)",0,  0,1,-1,
                           "2. Interpolate#",           1,  0,1,-1,
                           "3. SubPixel Sampling*#",     0,  0,1,-1,
                           "* SubPixel Levels: 1-8",    3,  0,8,0,

                           "# Gamma",             1.6,  0.1,5.0,3,

                           "Depth Shading %: 0-1000",       50,  0,1000,1,

                           "Elastic Edges over Void", elastic,  0,1,0
                                                                      
 );

if OK then

 t1 = os.clock()

 cos,floor,max,min,abs,log = math.cos, math.floor, math.max, math.min, math.abs, math.log

 Spare_Bri = {}
 for c = 0, 255, 1 do
  r,g,b = getsparecolor(c)
  Spare_Bri[c+1] = db.getBrightness(r,g,b) / 255
 end

 -- Brightness of spare image colorindex [i] at pixel x,y as fraction of 1
 function getSparePixelValue(x,y)
  --return x/w
  return Spare_Bri[getsparepicturepixel(x+0.5,y+0.5)+1] 
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

 --
 function lightMapHybrid(r,g,b, v, strength)
  local m,add
  add = (v-0.5) * strength
  m = 1
  if add > 0 then
   m = 1 + add/255
  end
  if add < 0 then
   m = 1 / (1 -add/255) -- add is negative so no div by 0
  end
  --r,g,b = getcolor(i)
  r = min(255,max(0,r*m + add*0.4))
  g = min(255,max(0,g*m + add*0.4))
  b = min(255,max(0,b*m + add*0.4))
  return matchcolor2(r,g,b)
 end
 --

 --
 function lightMapNatural(i,v, strength)
  local bri,r,g,b
  bri = (v-0.5) * strength
  r,g,b = getcolor(i)
  r = db.naturalBrightness(r, bri, 0.5)
  g = db.naturalBrightness(g, bri, 0.5)
  b = db.naturalBrightness(b, bri, 0.5)
  return matchcolor2(r,g,b)
 end
 --

-- db.calcLightRGBopt(fcol,z1,z2,z3,light,amp,scl,amb)


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

    f = getSparePixelValue -- Note that function does +0.5 on pixel coords

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

--
function control(ox,oy,w1,h1)

 local dx,dy,r,g,b,dx,dy,dt,fx,fy,d,xp,yp

 xp = ox * w1
 yp = oy * h1
 dx = cx-ox
 dy = cy-oy
 dt = getSparePixelValue(xp,yp) -- has +0.5
 if smooth == 1 then
  if yp >= 0 and yp <= h1 and xp >= 0 and xp <= w1 then
   -- Yes, +0.5 seem right (sharp, perfectly lines up with IP, that DOESN'T need +0,5!?)
   -- Actually, this makes sense since the sampling matrix is centered at 0,0. +0.5 makes it line up with the blurmap.
   -- Then again, I'm still a little confused why the matrix isn't lined up with the pixel in the first place...but it works right that way...
   dt = blurMap[floor(yp+1+0.5)][floor(xp+1+0.5)]
  end
 end -- smooth

 --dt = 0.5 + db.alpha1(ox,oy,1) * 0.5 * 0.1 -- Lines up with IP 
 
 if dt >= 0.5 then -- Scale Up (gray to white)     
   d = 1 / (1 + (dt-0.5) * final_strength) -- "linear", working
    else -- Scale Down (black to gray)
     d = 1 / (1 - min(1,(0.5-dt) * final_strength)) -- Linear appearance
 end

  ox = cx - dx * d
  oy = cy - dy * d

 r,g,b = getcolor(getbackuppixel(ox*w1+0.5,oy*h1+0.5));

 return r,g,b
end
--

fget = getbackupcolor

for y = 0, h - 1, 1 do
  oyf = y / h1;
  for x = 0, w - 1, 1 do

     fy = oyf
     fx = x / w1;

     --
     if smooth == 1 then
      dt = blurMap[y+1][x+1]
       else
        dt = getSparePixelValue(x,y)
     end -- smooth
     --

  --dt = 0.5 + db.alpha1(fx,fy,1) * 0.5 * 0.1 -- alpha1 returns 0..2 I think


      if dt >= 0.5 then -- Scale Up (gray to white)     
        d = 1 / (1 + (dt-0.5) * final_strength) -- "linear", working
         else -- Scale Down (black to gray)
          d = 1 / (1 - min(1,(0.5-dt) * final_strength)) -- Linear appearance
      end


      dx = cx-fx
      dy = cy-fy

      ox = cx - dx * d
      oy = cy - dy * d

        if elastic == 1 then
         ox = max(0,min(ox,1)); oy = max(0,min(oy,1)) -- "Elastic Edges"
        end

        if (ox >= 0 and ox <= 1 and oy >= 0 and oy <= 1) or elastic == 1 then

          posx,posy = ox*w1, oy*h1

          if basic == 1 then
           c = f1(floor(posx + 0.5),floor(posy + 0.5))
           r,g,b = getcolor(c)
          end

          if subpixel == 1 then
           --c = matchcolor2(ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma))
           r,g,b = ip_.fractionalSampling(Levels, x,y, w1,h1, control, gamma)
          end

          if bilinear == 1 then
            if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             -- Out of bounds means Transparancy color is used (by system)
             r,g,b = ip_.pixelRGB_Bilinear(posx,posy,fget,f1,ip_.kenip) -- px,py, col_func, get_func, ip_func
             else
              --r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.kenip,gamma) -- px,py, col_func, get_func, ip_func
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.linip,gamma)   
           end
           --c = matchcolor2(r,g,b) 
          end

        
          --if Lights then c = lightMapHybrid(c, dt, light_strength * final_strength); end
          if Lights then 
           c = lightMapHybrid(r,g,b, dt, light_strength * final_strength)
            else c = matchcolor2(r,g,b)
          end

          f2(x, y, c);
  
           else f2(x,y,0)
        end
     
  end

  if db.donemeter(10,y,w,h,true) then return; end

end

 t2 = os.clock()
 ts = (t2 - t1) 
 --messagebox("Seconds: "..ts)

end; -- OK

end -- main
--

main()


--if cubic == 1 then
-- r,g,b = ip_.pixelRGB_Bicubic(posx,posy,fget,f1,ip_.cubip)
-- c = matchcolor2(r,g,b) 
--end


