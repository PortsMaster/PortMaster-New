--PICTURE: Apply Spare to Main (Tint etc.) V2.5
--by Richard Fhager 


-- V2.5 Major bug fix (leading dummy arg in menu), Optimized array handling


--dofile("dawnbringer_lib.lua")
dofile("../libs/dawnbringer_lib.lua")

-- Note that duplicate colors will be omitted from calculations

OK,tin,clz,blend,base,add,differ,amt,falloff,briweight = inputbox("Apply Spare to Main",
                           "1. Tint *",               1,  0,1,-1,
                           "2. Colorize *",           0,  0,1,-1,
                           "3. Blend (not index)",    0,  0,1,-1,
                           "4. Baseline Fusion",      0,  0,1,-1,
                           "5. Add (normal)",         0,  0,1,-1,
                           "6. Difference",           0,  0,1,-1,
                           "AMOUNT %", 100,  0,100,0,  
                           "* Bri/Dark FallOff", 1,  0,1,0,
                           "ColMatch Bri-Weight %", 25,  0,100,0                                                     
);


brikeep = 1
if add == 1 or base == 1 or differ == 1 then
 brikeep = 0
end

if OK == true then

 function cap(v) return math.min(255,math.max(v,0)); end

 ws,hs = getsparepicturesize()
 w, h = getpicturesize()
 w = math.min(w,ws)
 h = math.min(h,hs)

 --fg = getforecolor()
 BG = getbackcolor()
 --fR,fG,fB = getcolor(fg)
 --bR,bG,bB = getcolor(bg)

 spal = db.fixPalette(db.makeSparePalList(256))
 pal = db.fixPalette(db.makePalList(256))

 cbri = {}
 for n =  1, #pal, 1 do
   c = pal[n]
   r,g,b,CurrCol = c[1],c[2],c[3],c[4]
   cbri[CurrCol+1] = db.getBrightness(r,g,b)
 end

 --if nobg == 1 then
 -- pal = db.stripIndexFromPalList(pal,bg) -- Remove background color from pallist
 --end

 amtA = amt / 100
 amtR = 1 - amtA


 ---------------------------------------------------
 -- Colorize (Colourant) (just apply colorbalance)
 -- Tint (make grayscale and apply colorbalance)
 --
 -- I think it should be the other way around since colorize is the process of adding color to B&W film...
 -- But this is the what Brilliance and others call it 
 --
 if clz == 1 or tin == 1 or add == 1 or blend == 1 or base == 1 or differ == 1 then
  cols = {}
 for s =  1, #spal, 1 do

  c = spal[s]
  fR,fG,fB,SpareCol = c[1],c[2],c[3],c[4]
  cols[SpareCol+1] = {}

  -- Normalize
  if tin == 1 or clz == 1 then
   lev = (fR+fG+fB)/3
   fR = fR - lev
   fG = fG - lev
   fB = fB - lev
  end

  sC = cols[SpareCol+1]

  for n = 1, #pal, 1 do

  c = pal[n]
  r,g,b,CurrCol = c[1],c[2],c[3],c[4]
  --a = db.getBrightness(r,g,b)
  a = cbri[CurrCol+1]  

  fr,fg,fb = fR,fG,fB
  itot = 0

     -- No effect on: Add & Baseline
     if brikeep == 1 then
       if blend == 0 then -- Tint & Colorize
         -- Loose Brightness preservation (ex: applying full red to dark colors)
         brin = db.getBrightness(cap(r+fR),cap(g+fG),cap(b+fB))
         itot = brin - a
         fr = fR - itot 
         fg = fG - itot
         fb = fB - itot
       end

       if blend == 1 then
         sbri = db.getBrightness(fR,fG,fB)
         brin = db.getBrightness((r+fR)/2,(g+fG)/2,(b+fB)/2)
         avg = (sbri + a)/2
         itot = brin - avg
       end
     end 
     


     -- Falloff (Effect weakens at dark and bright colors)
     -- No effect on: Add,Baseline & Blend
     if falloff == 1 and blend == 0 then
      fo =  1 - math.abs((a - 127.5)/127.5)^2
      fr = fr * fo
      fg = fg * fo
      fb = fb * fo
     end

     if tin == 1 then
      --cols[SpareCol+1][CurrCol+1] = db.getBestPalMatchHYBRID({cap(a+fr)*amtA+r*amtR, cap(a+fg)*amtA + g*amtR, cap(a+fb)*amtA + b*amtR},pal,briweight / 100,true)
      sC[CurrCol+1] = matchcolor2((a+fr)*amtA+r*amtR, (a+fg)*amtA + g*amtR, (a+fb)*amtA + b*amtR,briweight / 100)
     end
     if clz == 1 then
      --cols[SpareCol+1][CurrCol+1] = db.getBestPalMatchHYBRID({cap(r+fr)*amtA+r*amtR, cap(g+fg)*amtA + g*amtR, cap(b+fb)*amtA + b*amtR},pal,briweight / 100,true)
      sC[CurrCol+1] = matchcolor2((r+fr)*amtA+r*amtR, (g+fg)*amtA + g*amtR, (b+fb)*amtA + b*amtR,briweight / 100)
     end

     if base == 1 then
      --cols[SpareCol+1][CurrCol+1] = db.getBestPalMatchHYBRID({cap(r+fR-127)*amtA+r*amtR, cap(g+fG-127)*amtA + g*amtR, cap(b+fB-127)*amtA + b*amtR},pal,briweight / 100,true)
      sC[CurrCol+1] = matchcolor2(cap(r+fR-127)*amtA+r*amtR, cap(g+fG-127)*amtA + g*amtR, cap(b+fB-127)*amtA + b*amtR,briweight / 100)
     end

     if add == 1 then
      --cols[SpareCol+1][CurrCol+1] = db.getBestPalMatchHYBRID({cap((r+fR)*amtA+r*amtR), cap((g+fG)*amtA + g*amtR), cap((b+fB)*amtA + b*amtR)},pal,briweight / 100,true)
      sC[CurrCol+1] = matchcolor2((r+fR)*amtA+r*amtR, (g+fG)*amtA + g*amtR, (b+fB)*amtA + b*amtR,briweight / 100) 
     end

     if blend == 1 then
      --cols[SpareCol+1][CurrCol+1] = db.getBestPalMatchHYBRID({cap((fR+r)/2-itot)*amtA+r*amtR, cap((fG+g)/2-itot)*amtA + g*amtR, cap((fB+b)/2-itot)*amtA + b*amtR},pal,briweight / 100,true)
      sC[CurrCol+1] = matchcolor2(cap((fR+r)/2-itot)*amtA+r*amtR, cap((fG+g)/2-itot)*amtA + g*amtR, cap((fB+b)/2-itot)*amtA + b*amtR,briweight / 100)
     end

    if differ == 1 then
      --if SpareCol == CurrCol then 
      -- cols[SpareCol+1][CurrCol+1] = BG
      --  else cols[SpareCol+1][CurrCol+1] = CurrCol; 
      --end
      -- Photoshop style
      sC[CurrCol+1] = matchcolor2(math.abs(r-fR)*amtA+r*amtR, math.abs(g-fG)*amtA+g*amtR, math.abs(b-fB)*amtA+b*amtR, briweight / 100)
      --cols[SpareCol+1][CurrCol+1] = matchcolor2(math.abs(fR-r)*amtA+r*amtR, math.abs(fG-g)*amtA+g*amtR, math.abs(fB-b)*amtA+b*amtR, briweight / 100)
      --cols[SpareCol+1][CurrCol+1] = matchcolor2((127+(fR-r)/2)*amtA+r*amtR, (127+(fG-g)/2)*amtA+g*amtR, (127+(fB-b)/2)*amtA+b*amtR, briweight / 100)
    end

  end
  statusmessage("Color: #"..SpareCol.." (total: "..#spal..")");  waitbreak(0)
end

  --if nobg == 1 then cols[getbackcolor()+1] = getbackcolor(); end

  sASS = spal["assigns"]
  cASS = pal["assigns"]
  for x = 0, w - 1, 1 do
   for y = 0, h - 1, 1 do
    SpareCol = sASS[getsparepicturepixel(x,y) + 1] + 1 -- Use Assign lists in case of duplicate removals
    CurrCol = cASS[getpicturepixel(x,y) + 1] + 1
      if cols[SpareCol] ~= nil then -- Ignore duplicate colors removed from pallists
      if cols[SpareCol][CurrCol] ~= nil then
       putpicturepixel(x, y, cols[SpareCol][CurrCol]);
      end
      end
  end
  if x%4 == 0 then
   updatescreen(); if (waitbreak(0)==1) then return; end
  end
 end

end; 
-- eof Colorize & Tint
--------------------------------------------------------

end -- OK
