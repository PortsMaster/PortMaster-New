--PICTURE: Main/Spare INDEX Operations V1.1
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

OK,diff,diffkeep,rubtru,bright,dark,cmix,add,subtract,blend = inputbox("Main/Spare INDEX Operations",
                        
                           "1. Difference --> PenCol",    1,  0,1,-1,
                           "2. Same --> PenCol",          0,  0,1,-1,
                           "3. PenCol --> Spare",         0,  0,1,-1,
                           "4. Keep Brightest",       0,  0,1,-1,
                           "5. Keep Darkest",         0,  0,1,-1,
                           "6. Checkered Mix",        0,  0,1,-1,
                           "7. Add Main & Spare",     0,  0,1,-1,
                           "8. Subtract Spare",       0,  0,1,-1,
                           "9. Blend (average)",      0,  0,1,-1

                          
                           --"AMOUNT % (0-100)", 100,  0,100,0,  
                           --"# Bri/Dark FallOff", 1,  0,1,0,
                           --"ColMatch Bri-Weight %", 25,  0,100,0                                                     
);

if OK then

w,h = getpicturesize()

FG = getforecolor()

--differ = 1
--bright = 0

palsame = true
bri = {}
for c =  0, 255, 1 do
 bri[c+1] = db.getBrightness(getcolor(c))
 r1,g1,b1 = getcolor(c)
 r2,g2,b2 = getsparecolor(c)
 if not(r1==r2 and g1==g2 and b1==b2) then palsame = false; end
end

if palsame == false then messagebox("Palettes are not identical!\n\nNote that this script operates on palette indexes and not RGB-values."); end

for y = 0, h-1, 1 do
 for x = 0, w-1, 1 do

  a = getpicturepixel(x,y)
  b = getsparepicturepixel(x,y)
  c = FG

  -- Differance 2 FG
  if diff == 1 then
   c = a; if a ~= b then c = FG; end 
  end

  if diffkeep == 1 then
   c = FG; if a ~= b then c = a; end 
  end


  -- Replace Background /w spare (Rubthru)
  if rubtru == 1 then
   c = a; if a == FG and b ~= BG then c = b; end 
  end

  -- Brightest
  if bright == 1 then
   c = b; if bri[a+1] >= bri[b+1] then c = a; end
  end

  -- Darkest
  if dark == 1 then
   c = b; if bri[a+1] < bri[b+1] then c = a; end
  end

  -- Checkered
  if cmix == 1 then
   c = a; if ((y+x) % 2 == 0) then c = b; end
  end

  -- Add
  if add == 1 then
   c = math.min(255,a + b)
  end
 
  -- Subtract
  if subtract == 1 then
   c = math.max(0,a - b)
  end

  -- Blend
  if blend == 1 then
   c = math.floor((a + b) * 0.5)
  end

  --[[
  -- Merge
  -- Blend with bias towards extremes (dark and bright)
  -- Ex. At high power, a dark 0 blended with bright 254 will result in a quite dark color, 
  --     because dark is more extreme. 
  merge = 1
  if merge == 1 then
   g = 1.5 -- Power (1 = normal 50/50 blend)
   gr = 1 / g
   s = db.sign

   am = (a - 127.5)/127.5
   ams = s(am)

   bm = (b - 127.5)/127.5
   bms = s(bm)

   sg = db.sign(am+bm)
  
   a = math.abs(am)
   b = math.abs(bm)

   v = sg * math.abs((ams*a^g + bms*b^g) * 0.5)^gr
   c = math.floor(127.5 + v * 127.5)
  end
  --]]


  putpicturepixel(x,y,c)
  
 end
  if y%8 == 0 then
   updatescreen();if (waitbreak(0)==1) then return; end
  end
end

end -- OK
