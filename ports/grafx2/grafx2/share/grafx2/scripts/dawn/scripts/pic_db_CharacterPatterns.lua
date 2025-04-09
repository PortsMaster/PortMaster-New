--PICTURE: Character Patterns V1.0
--(C64 Homage)

dofile("../libs/dawnbringer_lib.lua")


OK, diagonal,lateral, size, diag_dens,late_dens, layers, multi_col = inputbox("Character Patterns",
                            "Diagonals*",           1, 0, 1, 0,  
                            "Laterals#",            0, 0, 1, 0,   
                              
                            "Tile Size",           8, 2, 256, 0,
                           
                            "*Diagonal Density %", 100, 0, 100, 0,
                            "#Lateral  Density % ",100, 0, 100, 0,
                            "Layers@ (exponential)",1, 1, 8,0,
                            "@Next Color Each Layer",  1, 0, 1, 0                                                       
);


--
if OK then

w,h = getpicturesize()

diag = false; if diagonal == 1 then diag = true; end
diag_density = diag_dens / 100
line = false; if lateral == 1 then line = true; end
line_density = late_dens / 100

--size   = 16 -- 3..
--layers = 1 -- 1..

rnd = math.random

for n = 1, layers, 1 do

chary = size * 2^(n-1)
charx = size * 2^(n-1)

col = getforecolor() + (n-1)*multi_col

for y = 0, h, chary do
 for x = 0, w, charx do

 r = rnd(0,1) 

 if diag == true then

  if r == 0 and rnd() < diag_density then
   db.line(x,y,x+charx,y+chary,col)
  end

  if r == 1 and rnd() < diag_density then
   db.line(x+charx,y,x,y+chary,col)
  end

 end


 if line == true then

  r1 = rnd(0,1) 
  r2 = rnd(0,1) 
  if r1 == 1 and rnd() < line_density then
   db.line(x,y,x+charx,y,col)
  end
  if r2 == 1 and rnd() < line_density then
   db.line(x,y,x,y+chary,col)
  end

 end

 end
 updatescreen();if (waitbreak(0)==1) then return end
end

end


end -- OK
--
 