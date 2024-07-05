--BRUSH: Palette 2 Brush
--by Richard Fhager 

dofile("../libs/dawnbringer_lib.lua")
--> db.drawBrushRectangle(x,y,w,h,c)


colors = 16
columns = 8
--rows = 8
rows = colors / columns
cellw = 4
cellh = 4

OK,colors,columns,cellw,cellh = inputbox("Draw Palette as Brush",
                       "Colors",               colors,   2,256,0,
                       "Columns",              columns,  1,256,0,    
                       "Cell Width",             cellw,  1,32,0,
                       "Cell Height",            cellh,  1,32,0
                       --"Show Brightness",          1,  0,1,0, 
                     
);


rows = math.ceil(colors / columns)

--
if OK == true then

setbrushsize(columns *  cellw, rows * cellh)

for y = 0, rows-1, 1 do
 for x = 0, columns-1, 1 do

  c = columns*y+x

  if c < colors then
    db.drawBrushRectangle(x*cellw,y*cellh,cellw,cellh,c)
  end

 end
end

end
--

