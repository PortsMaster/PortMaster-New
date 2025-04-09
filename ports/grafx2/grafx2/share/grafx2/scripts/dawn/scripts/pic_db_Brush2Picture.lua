--PICTURE: Brush to Picture V1.1
--by Richard Fhager 

  w,h = getbrushsize()

  setpicturesize(w,h)


for x = 0, w - 1, 1 do
 for y = 0, h - 1, 1 do
   putpicturepixel(x, y, getbrushbackuppixel(x,y));
 end
end
