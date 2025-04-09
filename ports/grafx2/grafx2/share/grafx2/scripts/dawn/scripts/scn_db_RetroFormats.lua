--SCENE: RETRO FORMATS V2.0
--by Richard 'DawnBringer' Fhager
--
-- I think these algorithms now produce results with very high quality
-- Note: The rendition of wide-pixels employ some advanced color-theory, but there is (yet) no corresponding
--       adjustments in palette-selection for this mode, so the impact may appear insignificant.
--
-- For remapping images to character-based formats like C64 hires or multicolor.
-- Can also be used to just remap an image to a given palette with ordered-dither (set charcols to # of cols in pal)
--
-- Color selection Process:
-- 0. [0/1]  Global color (only if selected)
-- 1. [0/2]  Median-Split;  on darkest and brightest colors (reduces "squariness" and maintains the structure of the image)
-- 2. [1..n] Common colors; find the most common colors (after remapping to new palette)
-- 3. [0..n] Avg-Bri-App.; Add/Reduce brightness to average char-color and look for more colormatches (perfect for Ordered dither)

dofile("../libs/dawnbringer_lib.lua")

function retroFormats(Csx,Csy,charCOLS,globalCOL,dbsplit,hybrid,dither,briweight,ownpalsplit,widepixel,splitcont)
 local i,v,s,l,o,n,c,x,y,ys,xs,r,g,b,yl,cols,col,ro,go,bo,oc
 local rgb,rh,gh,bh,aR,gR,bR,pickCols,HistS,HISTLIM,Points,pal
 local char,darkest,drk_c,brightest,bri_c,median, r1,g1,b1,r2,g2,b2,tot1,tot2,pix
 local M = math, DITHER_TYPE
 local bri,mixbri,trubri,diff
 local rt,gt,bt,qr,qg,qb,wr,wg,wb,lev,fb,fc, chary 
 local newPal, usedCols, newCols
 local sqrt

 local ord

  ord = {{0,4,1,5},
         {6,2,7,3},
         {1,5,0,4},
         {7,3,6,2}}

 sqrt = math.sqrt

 
 --DITHER_TYPE = "random"
 DITHER_TYPE = "ordered"

 SPLIT2_DRKBRI_WEIGHT = splitcont -- Use of Darkest/Brightest (max/min) colors rather than averages.

 -- Median-split (bri-split) makes sure that chars with an edge between dark and bright areas don't get all
 -- dark or bright colors due to either being most common, but instead makes a median brightness-cut.
 -- The reason we have a 2-color bright split treshold is so f.ex that 3-color dithers of fairly
 -- plain ("non edge") areas don't get wrecked into single color blocks with just a few 2nd color pixels.
 -- 80 seem like a good value, and since the median cut has such an impact on the final result...
 -- Changing the treshold often doesn't do much, so a user input-setting could be confusing.
 -- When reducing a photo to its own palette use 0.
 brisplit_treshold = 80 -- Do a Median split if brightness diff is >= treshold

 if ownpalsplit then brisplit_treshold = 0; end

 --dbsplit = 1

 --messagebox(briweight)

 pal = db.makePalList(256)
 pal = db.fixPalette(pal)
 
 pickCols = {}

 xs,ys = getpicturesize() 
 
 cols = 256

 -- We can't have Grafx2 colmatch at palette creation and use my distance-colmatch in the rendering
 colmatch = {}
 for c = 0, cols-1, 1 do
  r,g,b = getbackupcolor(c)
  if hybrid == 1 then
   colmatch[c+1] = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,true)
   else
    colmatch[c+1] = db.getBestPalMatch(r,g,b,pal,true)
  end
 end

 if Csx % 2 ~= 0 then
  messagebox("Can't use widepixels with horizontally odd-sized characters")
  widepixel = 0
 end

 xstep = 1
 if widepixel == 1 then 
  xstep = 2 -- widepixel
 end

 if (globalCOL and charCOLS < 3 and dbsplit == 1) then
  messagebox("2-color split disabled when using Global color with less than 3 colors")
  dbsplit = 0
 end

 if (charCOLS == 1 and dbsplit == 1) then
  messagebox("2-color split disabled when only using 1 color")
  dbsplit = 0
 end

 if (globalCOL) then
  if charCOLS > 1 then
  --if (not(dbsplit == 1 and charCOLS == 2)) then
  -- Histogram: Find average RGB
  rh,gh,bh = 0,0,0
  HistS = 2

  HISTLIM = 10000 
   if ((xs * ys) / HistS > HISTLIM) then
    --alert('Too many Histogram-points - reducing')
    HistS = M.ceil(math.sqrt((xs * ys) / HISTLIM)) 
   end
 
  Points = 0
  for y = 0, ys-1, HistS do
   for x = 0, xs-1, HistS do
    ro,go,bo = getbackupcolor(getbackuppixel(x,y))
    --r,g,b = colfunc(r,g,b,pal)
    r,g,b = getcolor(matchcolor(ro,go,bo))
    rh = rh + r
    gh = gh + g
    bh = bh + b
    Points = Points + 1
  end; end;
  aR = M.floor(rh / Points) -- prev. round
  aG = M.floor(gh / Points)
  aB = M.floor(bh / Points)

  --pickCols[1] = colfunc(aR,aG,aB) -- Set global color
  c = matchcolor(aR,aG,aB)
  --pickCols[1] = c + 1 -- Set global color
  GLOBALcolor = c
  messagebox("Global color is: "..GLOBALcolor)

  --alert(aR + ", " + aG + ", " + aB + " Best col: " + pickCols[0] + " - " + pal[pickCols[0]])

   --else globalCOL = false; messagebox("Global color disabled when using 2-color split")
  --end
   else globalCOL = false; messagebox("Global color disabled when only using 1 color")
  end -- if charCOLS > 1
 end -- eof globalCOL

 local Poccur, newPal, cx,cy,picks,bc
 Poccur = {}
 
 for y = 0, ys-Csy, Csy do  -- Char
 for x = 0, xs-Csx, Csx do

  newPal = {}
  usedCols = {} -- "1" marks used color, null otherwise
  newCols = 0 -- Color currently assigned to char-pal list

  if globalCOL then
   newCols = 1
   r,g,b = getcolor(GLOBALcolor)
   newPal[newCols] = {r,g,b,GLOBALcolor}
   usedCols[GLOBALcolor + 1] = 1
  end

  skip2ColorSplit = false
   -- Split 2 color images into dark/bright colors to avoid "square-jaggies"
  if dbsplit == 1 and charCOLS > 1 then -- charCOLS == 2
   -- 1st: Let's find the darkest and brightest colors 
   char = {}
   darkest,  drk_c = 999,-1
   brightest,bri_c =  -1,-1
   for cy = 0, Csy-1, 1 do -- Pixels in char
    char[cy+1] = {}
    chary = char[cy+1]
    for cx = 0, Csx-1, 1 do
     c = getbackuppixel(x+cx,y+cy)
     r,g,b = getbackupcolor(c)
     bri = db.getBrightness(r,g,b)
     chary[cx+1] = {r,g,b,bri}
     if bri < darkest   then darkest   = bri; drk_c = c end
     if bri > brightest then brightest = bri; bri_c = c end
   end;end   

   -- Brightness Median Cut
   r1,g1,b1,tot1,r2,g2,b2,tot2 = 0,0,0,0,0,0,0,0
   median = (darkest + brightest) / 2

   if (brightest - darkest) ~= 0 and (brightest - darkest) >= brisplit_treshold then

   for cy = 0, Csy-1, 1 do
    chary = char[cy+1] 
    for cx = 0, Csx-1, 1 do
     pix = chary[cx+1]
      if pix[4] <= median then
         r1 = r1 + pix[1]
         g1 = g1 + pix[2]
         b1 = b1 + pix[3]
         tot1 = tot1 + 1
        else
         r2 = r2 + pix[1]
         g2 = g2 + pix[2]
         b2 = b2 + pix[3]
         tot2 = tot2 + 1
      end
   end;end
 
   fb = SPLIT2_DRKBRI_WEIGHT
   fc = 1 - fb
   qr = (r1 / tot1) * fc  +  darkest * fb 
   qg = (g1 / tot1) * fc  +  darkest * fb 
   qb = (b1 / tot1) * fc  +  darkest * fb 

   wr = (r2 / tot2) * fc + brightest * fb 
   wg = (g2 / tot2) * fc + brightest * fb
   wb = (b2 / tot2) * fc + brightest * fb

   --if tot2 == 0 then messagebox("zero"); return; end

   if hybrid == 1 then
    c1 = db.getBestPalMatchHYBRID({qr,qg,qb},pal,briweight,true)
    c2 = db.getBestPalMatchHYBRID({wr,wg,wb},pal,briweight,true)
   else
     c1 = matchcolor(qr,qg,qb)
     c2 = matchcolor(wr,wg,wb)
   end

   if usedCols[c1 + 1] ~= 1 then
    newCols = newCols + 1
    r,g,b = getcolor(c1); newPal[newCols] = {r,g,b,c1}; usedCols[c1+1] = 1
   end
   if usedCols[c2 + 1] ~= 1 then
    newCols = newCols + 1
    r,g,b = getcolor(c2); newPal[newCols] = {r,g,b,c2}; usedCols[c2+1] = 1
   end

   else skip2ColorSplit = true -- Colors are the same or below treshold
 end

 end -- eof 2 col split
 

   for n = 1, cols, 1 do Poccur[n] = {n,0}; end

  if charCOLS > 2 or dbsplit == 0 or skip2ColorSplit == true then
   rt,gt,bt,pix = 0,0,0,0
   for cy = 0, Csy-1, 1 do -- Pixels in char
   for cx = 0, Csx-1, 1 do
 
          oc = getbackuppixel(x+cx,y+cy)
          r,g,b = getbackupcolor(oc)
      
          -- Keep track of medium color
          rt = rt + r
          gt = gt + g
          bt = bt + b
          pix = pix + 1

          c = colmatch[oc+1]

         --if hybrid == 1 then
         -- -- No point using this unless remapping to from another pal
         -- -- Note: Hybrid with 0 bri is not the same as Grafx Colormatch, since I use perceptual color distances
         -- c = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,true)        
         -- else
         -- Spare pal has been copied to current, reading original now remapping to current
         --   c = matchcolor(r,g,b)
         --end

          if usedCols[c+1] ~= 1 then -- Exclude colors picked by Drk/Bri split
            Poccur[c+1] = {c+1, Poccur[c+1][2]+1} 
          end
         
   end; end;

    db.sorti(Poccur,2) -- LO-HI

     picks = 0
     for n=0, charCOLS-1, 1 do -- Get most common colors in char (read backwards) (not taken by other selections)
      o = Poccur[cols-n][2]
      if o > 0 then -- Exclude zero counts
       picks = picks + 1; pickCols[picks] = Poccur[cols-n][1];  -- The sort is low->hi
      end
     end
    
    v = math.min(picks, charCOLS - newCols)
    for n=1, v, 1 do -- Turn colors into pal-format 
       c = pickCols[n] - 1 
       r,g,b = getcolor(c) -- Now these are the new colors copied from spare
       --if usedCols[c+1] == 1 then messagebox("color picked already; "..x..", "..y); end
       newCols = newCols + 1
       newPal[newCols] = {r,g,b,c}
       usedCols[c+1] = 1
    end

   -- Ok, we only found one color, let's apply some brightess to the average char-color
   -- and see if we find some more...this will be very useful for the ordered-dither at least.
   if newCols < charCOLS then 
    --messagebox(newCols.." at "..x..","..y); end
    bri = 10
    lev = 6-- 0 is a level too
    rt = rt / pix -- Average of character total color
    gt = gt / pix
    bt = bt / pix
    for l = -1, lev, 1 do 
    for s = 1, -1, -2 do 
      if newCols < charCOLS then 
       r = rt+l*s*bri
       g = gt+l*s*bri
       b = bt+l*s*bri
       if hybrid == 1 then
        c = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,true)
        else c = matchcolor(r,g,b)
       end
       if usedCols[c+1] ~= 1 then
        newCols = newCols + 1
        r,g,b = getcolor(c)
        newPal[newCols] = {r,g,b,c}; usedCols[c+1] = 1
       end
     end -- if still cols left
    end
    end 
    if (newCols > charCOLS) then messagebox ("TOO MANY COLORS!"); end
    --statusmessage("Add Cols: "..newCols); if (waitbreak(0)==1) then return; end
   end -- eof newCols == 1

   --if newCols < charCOLS then messagebox("-!-"..x.."-"..y); end

    --for n=1, charCOLS - newCols, 1 do -- Turn colors into pal-format 
    --   c = pickCols[n] - 1 
    --   r,g,b = getcolor(c) -- Now these are the new colors copied from spare
    --   --if usedCols[c+1] then messagebox("color picked already; "..x..", "..y); end
    --   newPal[n + newCols] = {r,g,b,c}
   -- end

   --messagebox(x..", "..y)
   --statusmessage(x..", "..y)
  end -- charCOLS > 2

   -- Render char with new colors
    for cy=0, Csy-1, 1 do 
    for cx=0, Csx-1, xstep do   
         --c = colfunc(r,g,b,newPal)
 
 i = 0
 if dither > 0 and charCOLS > 1 then 
  -- Random
  if DITHER_TYPE == "random" then
   if ((x+cx)+(y+cy))%2 == 0 then
    i = math.random()*dither -- 0-100 now
     else 
    i = -math.random()*dither
   end
  end

  -- Ordered
  if DITHER_TYPE == "ordered" then
   i = ((ord[(y+cy) % 4 + 1][(x+cx/xstep) % 4 + 1])*28.444 - 99.55556)/100 * dither
  end
 end -- eof Dither

         --r,g,b = db.rgbcap(r+i,g+i,b+i,255,0)
         --c = db.getBestPalMatch(r,g,b,newPal,true)

         if widepixel == 0 then
           r,g,b = getbackupcolor(getbackuppixel(x+cx,y+cy))
           if hybrid == 1 then
            c = db.getBestPalMatchHYBRID({r+i,g+i,b+i},newPal,briweight,true) -- With few colors to choose from it's unlikely this will produce a different result from any generic colormatch
            else
             c = db.getBestPalMatch(r+i,g+i,b+i,newPal,true)
           end
           putpicturepixel(x+cx,y+cy,c) 
         end

        -- This can be sped up by pre-fetching brightness
        if widepixel == 1 then -- Tru-brightness correction (not much improvement when colors are picked by other critera)
         r1,g1,b1 = getbackupcolor(getbackuppixel(x+cx,y+cy))
         r2,g2,b2 = getbackupcolor(getbackuppixel(x+cx+1,y+cy))
         r = (r1+r2)/2
         g = (g1+g2)/2
         b = (b1+b2)/2
         mixbri = db.getBrightness(r,g,b)
         trubri = sqrt((db.getBrightness(r1,g1,b1)^2 + db.getBrightness(r2,g2,b2)^2) / 2)
         diff = trubri - mixbri
         if hybrid == 1 then
          c = db.getBestPalMatchHYBRID({r+i+diff,g+i+diff,b+i+diff},newPal,briweight,true) -- With few colors to choose from it's unlikely this will produce a different result from any generic colormatch
           else
            c = db.getBestPalMatch(r+i+diff,g+i+diff,b+i+diff,newPal,true)
          end
         putpicturepixel(x+cx,y+cy,c)
         putpicturepixel(x+cx+1,y+cy,c)
        end

        testpal = false
        if testpal then
         --if #newPal ~= 4 then messagebox("!"); break; end
         if #newPal >= (cx+1) then
           c = newPal[cx+1][4]
          putpicturepixel(x+cx,y+cy,c)
           else putpicturepixel(x+cx,y+cy,0)
         end 
        end

    end;end

 end;
   updatescreen(); if (waitbreak(0)==1) then return; end
  end

end -- eof retroformats



OK,XS,YS,CCOLS,GCOL,PAL2,WIDEPIXELS,DITHER,SPLITCONT,BRIWT = inputbox("Retro Formats (Median Split)",
                         "Char X-Size",  8, 1,32,0,
                         "Char Y-Size",  8, 1,32,0,
                         "Colors/Char",  4, 1,32,0,
                         "Global Color",      0,0,1,0,
                         "Use SPARE palette",    1,0,1,0,                                               
                         --"Two Color Drk/Bri Split",      1,0,1,0,
                         "Widepixels",      0,0,1,0,
                         "Dither %", 12,    0,100,0,  
                         --"Use Hybrid Colormatch",      0,0,1,0,
                         "2Split Drk/Bri Contrast %", 33,  0,100,0,  
                         "ColMatch Bri-Weight %", 25,  0,100,0    
                
);

if OK == true then

 DBSPLIT = 1

 HYBRID  = 0
 if BRIWT > 0 then HYBRID = 1; end

 if PAL2 == 1 then
  for n = 1, 256, 1 do
   setcolor(n,getsparecolor(n)) 
  end
 end

 OWNPALSPLIT = false
 if (PAL2 == 0 and DBSPLIT == 1) then OWNPALSPLIT = true; end

 gc_flag = false; if GCOL == 1 then gc_flag = true; end


 --retroFormats(8,8,2,false)
 retroFormats(XS,YS,CCOLS,gc_flag,DBSPLIT,HYBRID,DITHER,BRIWT/100,OWNPALSPLIT,WIDEPIXELS,SPLITCONT/100)

end
