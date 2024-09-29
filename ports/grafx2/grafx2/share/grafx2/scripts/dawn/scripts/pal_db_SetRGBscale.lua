--PALETTE Adjust: RGB-Scale V1.1
--by Richard Fhager


OK,dummy, rgb_levels = inputbox("Set RGB-Scale (shades)",
   "16 = 12bit / 4096 colors", 0,0,0,4,
   "RGB-Scale: 2-256", 16, 2,256,0
);

if OK == true then

  div  = 256 / rgb_levels
  mult = 255 / (rgb_levels - 1)

  for n = 0, 255, 1 do
   
     r,g,b = getcolor(n)
     r = math.floor(math.floor(r / div) * mult)
     g = math.floor(math.floor(g / div) * mult)
     b = math.floor(math.floor(b / div) * mult)
     setcolor(n, r,g,b)
 
  end

end -- ok
