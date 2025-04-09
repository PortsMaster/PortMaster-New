--PICTURE: Scanlines V1.2
--by Richard Fhager

scan = 1
amount = 50

dithpow = 0.25 -- 0 - ~0.35

OK,scan,whole,dark,bri,xfade,dither,amount = inputbox("Scanlines",
                           "1. Scanlines",        1,  0,1,-1,  
                           "2. Whole Image",      0,  0,1,-1,  
                           "a) Darken",           1,  0,1,-2,  
                           "b) Brighten",         0,  0,1,-2, 
                           "X-Fade",              0,  0,1,0,      
                           "Dither",              0,  0,1,0,
                           "AMOUNT %",           50,  0,100,0                                                  
);

if OK == true then


adj = amount / 100

corr = 255 * adj
if dark == 1 then corr = -corr; end

ystep = 1
if scan == 1 then ystep = 2; end

w, h = getpicturesize()

for y = 0, h - 1, ystep do
  er,eg,eb = 0,0,0

  for x = 0, w - 1, 1 do

   xf = 1
   if xfade == 1 then xf = 1 / w * x; end

   r,g,b = getcolor(getpicturepixel(x,y))

   cv = corr*xf + (y%2)*dither -- y%2 fake vertical dither
   tr = r + cv + er
   tg = g + cv + eg
   tb = b + cv + eb

   c = matchcolor2(tr, tg, tb)

   if dither == 1  then
    mr,mg,mb = getcolor(c) 
    er = (er + (tr - mr)) * dithpow
    eg = (eg + (tg - mg)) * dithpow
    eb = (eb + (tb - mb)) * dithpow
   end

   --c = matchcolor(r * (1-adj), g * (1-adj), b * (1-adj)) 

   putpicturepixel(x, y, c);

  end
  if y%8 == 0 then
   statusmessage("Done: "..math.floor((y+1)*100/h).."%")
   updatescreen(); if (waitbreak(0)==1) then return; end
  end
end

end -- ok

