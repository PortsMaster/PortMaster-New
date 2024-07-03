--PALETTE Set: Random Palette V2.0
--by Richard Fhager


-- (V2.0 Brightness range, clear palette)

OK,COLORS,BRANGE = inputbox("Random Palette",                  
                
                           "Colors", 16,  1,256,0, 
                           "Brightness Gradient",     0,  0,1,0 
        
);
--
if OK == true then

 for n = 0, 255, 1 do
  setcolor(n-1,0,0,0) 
 end
 
 f = 1 / COLORS

 for n = 1, COLORS, 1 do
  m1 = -f*1024 + (f * n)^2.0 * 128
  m2 =  f*256  + (f * n)^0.5 * 320
  if BRANGE == 0 then m1,m2 = 0,255; end
  r = math.random(m1,m2)
  g = math.random(m1,m2)
  b = math.random(m1,m2)
  setcolor(n-1,r,g,b) 
 end

end;
--