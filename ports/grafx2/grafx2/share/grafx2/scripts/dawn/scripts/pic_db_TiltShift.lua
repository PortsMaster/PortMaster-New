--PICTURE: Tilt-Shift
--by Richard 'DawnBringer' Fhager

 upper = 0.35 -- Blur fades down from top/max to this fraction of the image
 lower = 0.75 -- Blur fades up from min from this fraction of the image to the bottom
 cweight = 0.5 -- 1.0 = Center weigh as much as all samples, 0.5 = 1/3 of all
 radius = 6
 samples = 25  -- Number of random locations to use as replacement for a complete matrix


OK,upp_prc,low_prc,blur_rad,blur_samp, c_wt = inputbox("Tilt-Shift",
                         "   Top/BG Blur-Size %",    upper*100,     0,100,0,
                         "Bottom/FG Blur-Size %", 100-lower*100, 0,100,0,
                         "Blur Radius",           radius,  1,50,0,
                         "Blur Points (quality)", samples, 1,100,0,   
                         "Centerpoint Weight %",  cweight*100,0,100,0                                     
           
);


if OK == true then

upper = upp_prc / 100
lower = (100 - low_prc) / 100
radius = blur_rad
samples = blur_samp
cweight = c_wt / 100


function tiltShift(upper, lower, cweight, radius, samples)
 local dist,sum,xp,yp,div,est,c,sqrt,rnd,rad2,rad05
 local r,g,b,mx,my,cx,cy,mxh,myh,mp,rb,gb,bb,xx,yy,x,y,w,h,div,n1,n2,rn,gn,bn,rad,q1,q2

 sqrt = math.sqrt
 rnd = math.random

 w, h = getpicturesize()

  for y = 0, h-1, 1 do

   q1 = 0
   q2 = 1

   yf = y / h
   --xf = x / w
   if yf < upper then -- Upper/Far unfocus, decreases rapidly near end
    q1 = (1 - yf * (1 / upper))^0.5
    q2 = 1 - q1
   end
   if yf > lower then -- Bottom/Neat unfocues, linear effect
    q1 = (yf - lower) / (1 - lower) --(yf - lower) * (1 / (1 - lower))
    q2 = 1 - q1
   end

   rad = radius * q1
   rad2 = rad * 2
   rad05 = -rad + 0.5
   est = (1 / math.max(1,rad)^2) * samples * cweight

  for x = 0, w-1, 1 do
 
   sum = 0
   div = 0

  r,g,b = getcolor(getbackuppixel(x,y))

  if rad > 0 then

   r = r * est
   g = g * est
   b = b * est
   div = div + est

   for n = 1, samples, 1 do
    xd = rnd()*rad2 + rad05 -- +0.5 adjusts dor internal rounding down
    yd = rnd()*rad2 + rad05
    xp = x + xd 
    yp = y + yd 
    if xp >= 0 and xp < w and yp >= 0 and yp < h then 
      dist = 1 + sqrt(xd*xd + yd*yd) -- Yup, we want opposite of gauss
      rb,gb,bb = getcolor(getbackuppixel(xp,yp))
      r = r + rb / dist
      g = g + gb / dist
      b = b + bb / dist
      div = div + (1 / dist)
    end
   end
     else div = 1
  end -- radius

   r = r / div
   g = g / div 
   b = b / div 

   -- Effect reduction
   --rn = r * q1 + ro * q2 
   --gn = g * q1 + go * q2 
   --bn = b * q1 + bo * q2

   rn,gn,bn = r,g,b
   c = matchcolor(rn,gn,bn)
   --c = db.getBestPalMatchHYBRID({db.rgbcap(rn, gn, bn, 255,0)},palList,0.25,false)

   putpicturepixel(x,y,c)
 end;
 if y%8==0 then
  statusmessage("Done: %"..math.floor(y/(h-1)*100 + 0.5))
  updatescreen(); if (waitbreak(0)==1) then return; end
 end
end;

end
--

tiltShift(upper, lower, cweight, radius, samples)

end -- ok


