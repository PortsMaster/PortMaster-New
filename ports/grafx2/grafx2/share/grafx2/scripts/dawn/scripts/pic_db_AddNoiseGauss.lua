--PICTURE: Advanced Noise V1.0
--by Richard Fhager

-- Brightness adjust has no effect in Add-only mode (however Relative effect still works)
-- 
-- Relative effect: Less effect on bright & dark colors, semi-reduced effect on primary colors


dofile("../libs/dawnbringer_lib.lua")



dlev = 50
OK,red,grn,blu,mono,add,gauss,relative,bricorrect = inputbox("Add Image Noise",
                         "RND   Red : 0-255", dlev, 0,255,0,
                         "RND Green*: 0-255", dlev, 0,255,0,
                         "RND  Blue : 0-255", dlev, 0,255,0,
                         "* Monochrome",    0,0,1,0,                  
                         "Add Only (+bri)", 0,0,1,0,
                         "Gaussian Dist.",1,0,1,0,
                         "Relative Effect %", 30, 0,100,0, -- "Gamma adjustment", Less effect on darker colors
                         "Brightness Correction %", 60, 0,100,0 -- Simple, Will not adjust bright noise when dark goes below the deck
                
);


if OK == true then

 rnd = math.random

 b = bricorrect / 100

 -- Derived Bri/Dark adjustment multiples bri = 0.29, dark = 0.71 (See RGB-dither for more info)
 bri = (2*0.29 * b + (1-b))      -- *2 to give a total of -1..1 = 2
 drk = (2*0.71 * b + (1-b)) * -1
 briadjust = {bri,drk} 

 function rand(val,add,gauss)
  local v,n,lev
  if gauss == 1 then
   v = rnd()*rnd() * 2
   n = val * v
    else 
     n = rnd(0,val)
  end
  if add == 0 then
   n = n *  briadjust[rnd(1,2)]  -- 1 = Bri, 2 = Dark, Brightness correction
   --n = n * (rnd(0,1)*2-1)
  end
  return n
 end

 w,h = getpicturesize() 

 p0 = relative / 100
 p1 = 1 - p0

 rel = {}
 for c = 0, 255, 1 do
  r,g,b = getcolor(c)
  -- reduce effect if channels are close to 255 or 0
  -- So we don't darken when we can't brighten and vice-versa
  -- Method 1 will fully protect primary colors (but is similar in bri/dark to method 2)
  -- Method 2 will protect just dark and bright (somewhat harder than method 1) 
  q1 = ((127.5-r)^2 + (127.5-g)^2 + (127.5-b)^2)^0.5 / 221
  q2 = 1 - math.min(math.max(r,g,b),255-math.min(r,g,b)) / 255
  q = (q1 + q2)/2
  rel[c+1] = 1 - q * p0
 end

 
  for y = 0, h, 1 do
   for x = 0, w, 1 do

     col = getbackuppixel(x,y)
     r,g,b = getcolor(col)

     gd = rand(grn,add,gauss)
     if mono == 1 then
      rd,bd = gd,gd
      else
       rd = rand(red,add,gauss)
       bd = rand(blu,add,gauss) 
     end

     q = rel[col+1]  
 
     rv = r+rd*q
     gv = g+gd*q
     bv = b+bd*q

     putpicturepixel(x,y, matchcolor2(rv,gv,bv))

  end

  if db.donemeter(10,y,w,h,true) then return; end

  --if y%8==0 then
  -- statusmessage("Done: "..math.floor((y+1)*100/h).."%")
  -- updatescreen();if (waitbreak(0)==1) then return end
  --end

 end

end -- ok
