--BRUSH: Picture 2 Brush
--(Make a brush from the current image)
--by Richard Fhager 



w,h = getpicturesize()

setbrushsize(w,h)

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

  putbrushpixel(x,y,getpicturepixel(x,y))

 end
end


