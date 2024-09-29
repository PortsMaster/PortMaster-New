--PICTURE: Alpha Filters
--(Blend Main/Spare Image)
--by Richard Fhager


dofile("../libs/dawnbringer_lib.lua")
--> db.alpha1(x,y,amp)

OK,m1,m2,m3,m4,inv,BRIWT = inputbox("Select Alpha Filter",                  
                           "1. Horizontal Range",     1,  0,1,-1,
                           "2. Vertical Range",       0,  0,1,-1,     
                           "3. Radial Range",          0,  0,1,-1, 
                           "4. Water Rings",          0,  0,1,-1,                         
                           "Inverted Filter",      0,  0,1,0,
                           --"Use Perceptual Colmatch*", 1,  0,1,0, --hybrid
                           "*ColMatch Bri-Weight %", 25,  0,100,0 
                          
);


if OK == true then

hybrid = 0
if BRIWT > 0 then
 briweight = BRIWT/100
 hybrid = 1
end

--[[
 if hybrid == 1 then
  briweight = BRIWT/100
  pal = db.fixPalette(db.makePalList(256))
 end
--]]

w,h = getpicturesize()

 m = math

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

  xf = x / w
  yf = y / h
  if inv == 1 then xf = 1 - xf; yf = 1 - yf; end

  rc,gc,bc = getcolor(getbackuppixel(x,y))
  rs,gs,bs = getsparecolor(getsparepicturepixel(x,y))

  if m1 == 1 then -- Horizontal range
   xr = 1 - xf
   r = rc * xr + rs * xf
   g = gc * xr + gs * xf
   b = bc * xr + bs * xf
  end

  if m2 == 1 then -- Vertical range
   yr = 1 - yf
   r = rc * yr + rs * yf
   g = gc * yr + gs * yf
   b = bc * yr + bs * yf
  end
  
  if m3 == 1 then -- Radial range
   d = m.min(1,((0.5-xf)^2 + (0.5-yf)^2)^0.5 * 2)
   if inv == 1 then d = 1-d; end
   r = rc * d + (1-d) * rs
   g = gc * d + (1-d) * gs
   b = bc * d + (1-d) * bs
  end

  if m4 == 1 then -- Water rings (Check why we can't get an inverse here)
   d = db.alpha1(xf,yf,1.0)*0.5
   if inv == 1 then d = 1-d; end
   r = rc * d + (1-d) * rs
   g = gc * d + (1-d) * gs
   b = bc * d + (1-d) * bs
  end

  if hybrid == 0 then
   c = matchcolor(r,g,b)
   else
     --c = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,true)
     c = matchcolor2(r,g,b,briweight)
  end 

  putpicturepixel(x,y,c)

 end
 --updatescreen(); if (waitbreak(0)==1) then return; end
  if db.donemeter(10,y,w,h,true) then return; end
end

end -- ok
