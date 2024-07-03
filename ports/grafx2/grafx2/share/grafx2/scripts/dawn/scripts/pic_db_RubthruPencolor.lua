--PICTURE: Rubthru Pencolor (spare to current)
--by Richard Fhager 

  w,h = getpicturesize()


FC = getforecolor()


for x = 0, w - 1, 1 do
 for y = 0, h - 1, 1 do
   if getpicturepixel(x,y) == FC then
    putpicturepixel(x, y, getsparepicturepixel(x,y));
   end
 end
end
