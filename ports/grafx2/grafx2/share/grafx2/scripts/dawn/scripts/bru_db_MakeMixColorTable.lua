--BRUSH: Make MixColor Table
--by Richard Fhager 


colors = 16
cellw = 8
cellh = 8

OK,colors,cellw,cellh,wide = inputbox("MixColor Table as Brush",
                       "Colors",               colors,  2,256,0,
                       "Cell Width",            cellw,  2,32,0,
                       "Cell Height",           cellh,  2,32,0,
                       "Wide pixels",               0,  0,1,0 
                     
);


--
if OK == true then

xm = 1; if wide == 1 then xm = 2; end

setbrushsize(colors * cellw * xm, colors * cellh)

for y = 0, colors-1, 1 do
 for x = 0, y, 1 do 

  mix = {x,y}
  for cy = 0, cellh-1, 1 do
   for cx = 0, cellw-1, 1 do

    px = x*cellw + cx
    py = y*cellh + cy
     c = mix[1 + (px+py) % 2] 

    putbrushpixel(px*xm,py,c)
    if wide == 1 then putbrushpixel(px*xm+1,py,c); end

   end
  end
  
 end
end

end; 
--

