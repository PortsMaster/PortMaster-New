--PICTURE: Distort Pixels
--by Richard Fhager

w,h = getpicturesize() 
pix = math.ceil((w*h)^1.1 * 0.5)

OK,pix = inputbox("Distort Pixels",
                         "Pixel Swaps", pix, 10,5000000,0                  
                         --"Add only",      0,0,1,0              
);

if OK == true then

 div = 100

 upd = math.ceil(pix/div)

 rnd = math.random
 
 for i = 1, div, 1 do

  for n = 1, upd, 1 do
     x = rnd(1,w-2)
     y = rnd(1,h-2) 
     xd = rnd(0,1)*2 - 1
     yd = rnd(0,1)*2 - 1
     c1 = getpicturepixel(x,y)
     c2 = getpicturepixel(x+xd,y+yd)
     putpicturepixel(x+xd,y+yd,c1)
     putpicturepixel(x,y,c2)
  end

  updatescreen();if (waitbreak(0)==1) then return end
 end

end -- ok
