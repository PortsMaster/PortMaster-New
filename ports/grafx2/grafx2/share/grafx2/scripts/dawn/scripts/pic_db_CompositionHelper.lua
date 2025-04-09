--PICTURE: Composition Helper
--by Richard Fhager

w,h = getpicturesize()

w3 = math.floor(w/3)
h3 = math.floor(h/3)

  function plot(x,y)
   r,g,b = getcolor(getpicturepixel(x,y))
   r = (r + 128) % 255
   g = (g + 128) % 255
   b = (b + 128) % 255
   c = matchcolor2(r,g,b)
   putpicturepixel(x,y,c)
  end

for s = 1, 2, 1 do
 x = s * w3
 for y = 0, h-1, 1 do
  plot(x,y)
 end

 y = s * h3
 for x = 0, w-1, 1 do
  plot(x,y)
 end

end

 x = w / 2
 for y = 0, h-1, 3 do
  plot(x,y)
 end

 y = h / 2
 for x = 0, w-1, 3 do
  plot(x,y)
 end

