--SCENE: Mixdither Remapping V3.1
--by Richard 'DawnBringer' Fhager 


--(V3.1 MixDither code cleaned up, Brightness sorted palette for correct dither. Optimized FS dither)

-- NOTE: For MUCH better mixdithering (with 32 color or less) use the 4-dither system (ToolBox/Misc/)

dofile("../libs/dawnbringer_lib.lua")
--> db.makeSparePalList(cols)
--> db.fixPalette(pallist, sort_flag) 
--> db.colormixAnalysis (using db.colormixAnalysisEXTnoshade)
--> db.fusePALandMIX
--> db.getBestPalMatchHybridMIX


  --
  -- MAXDIST is the greatest distance allowed between two color for them to be included as a mix, 
  --  it's mostly a tool to keep mix-count down on big palettes (it can get VERY slow),
  --  as mixtolerance can regulate how likley coarse mixes will be picked.
  --
  -- MIXTOLERANCE: at colormatching the distance between the mixcolors is added to 
  --               the distance of the color; mixtolerance regulates this addition:
  --             100% = mixcolor is treated as a regular color (no "coarseness penalty")
  --               0% = mixcolors distance is added in full to colordistance (total penalty)
  --

OK,nodith,fsdith,mixdith,maxdist,mixtolerance,scanlines,briwt,palcopy = inputbox("MixDither Remapping",
                        
                           --"Current w/ Spare Pal",       1,  0,1,0,              
                           "1. No Dither",                  0,  0,1,-1,
                           "2. Floyd-Steinberg Dith.",      0,  0,1,-1,
                           "3. MixColor Dither",            1,  0,1,-1,
                           "MixColor Max Dist. %", 100,  0,100,0, 
                           "MixColor Tolerance %", 85,  0,100,0, 
                           "MixColor Scanlines",        0,  0,1,0,
                           "Brightness Weight %",  25,  0,100,0,   
                           "Copy Palette",               1,  0,1,0                                              
);


if OK == true then

-- Remap current with spare pal

  -- Read Spare Pal
  pal = db.makeSparePalList(256)
  pal = db.fixPalette(pal,0) 
 
  remap = {}

  if mixdith == 1 then
    mix = {}
    --mix[found] = {score,col#1,col#2,dist,rm,gm,bm, c1_r,c1_g,c1_b, c2_r,c2_g,c2_b}
    mix,dum1,dum2,dum3 = db.colormixAnalysis(-1,true,maxdist) -- (SHADES not used here), spare_flag, custom max dist in % 
 
    mixPal = db.fusePALandMIX(pal,mix,100,255) -- Max Score (0 is perfect), Max distance (0-255)

    for n = 0, 255, 1 do
     r,g,b = getcolor(n)
     mixreduce = 100 - mixtolerance
     cs = db.getBestPalMatchHybridMIX({r,g,b},mixPal,briwt / 100, mixreduce)
     remap[n + 1] = cs
     statusmessage("Mixcol Assign, Col# "..n.."      "); updatescreen(); if (waitbreak(0)==1) then return; end
    end
  end
  
  w, h = getpicturesize()

  if nodith == 1 then
    for n = 0, 255, 1 do
     r,g,b = getcolor(n)
     c = db.getBestPalMatchHYBRID({r,g,b},pal,briwt / 100, true)
     remap[n + 1] = c
    end

    for y = 0, h - 1, 1 do 
     for x = 0, w - 1, 1 do
     putpicturepixel(x, y, remap[getbackuppixel(x,y) + 1]);
     --putpicturepixel(x, y, remap[getbackuppixel(x,y) + 1][1+(y+x*(1-scanlines))%2]);
    end
   end

  end


  if mixdith == 1 then
   for y = 0, h - 1, 1 do 
    for x = 0, w - 1, 1 do
     --putpicturepixel(x, y, remap[getbackuppixel(x,y) + 1]);
     putpicturepixel(x, y, remap[getbackuppixel(x,y) + 1][1+(y+x*(1-scanlines))%2]);
    end
   end
  end --


 if fsdith == 1 then
  fl = {}
  fl[1] = {}
  fl[2] = {}
  i = 1
  j = 2

  MIN = math.min
  MAX = math.max

  function cap(v)
   return MIN(255,MAX(0,v))
  end

  for n = 0, 255, 1 do setcolor(n,getsparecolor(n)); end;

  -- Read the first 2 lines
  for x = 0, w - 1, 1 do
   r,g,b = getbackupcolor(getbackuppixel(x, 0))
   fl[i][x] = {r,g,b}
   r,g,b = getbackupcolor(getbackuppixel(x, 1))
   fl[j][x] = {r,g,b}
  end

  bw = briwt / 100
  pal = db.addUnNormalizedBrightness2Palette(pal) -- p[8], for use with db.getBestPalMatch_Hybrid

   for y = 0, h - 1, 1 do 
    fi = fl[i]
    fj = fl[j]
    for x = 0, w - 1, 1 do
     --o = fl[i][x]
     o = fi[x]
     r = o[1]
     g = o[2]
     b = o[3]

    --c = matchcolor2(r,g,b)
    --c = db.getBestPalMatchHYBRID({r,g,b},pal,bw, true)
    c = db.getBestPalMatch_Hybrid(r,g,b,pal,bw, true) 
 

    putpicturepixel(x, y, c);

    if x>1 and x<w-1 and y<h-1 then
     rn,gn,bn = getcolor(c)
     re = (r - rn) / 16
     ge = (g - gn) / 16
     be = (b - bn) / 16

     o = fi[x+1]; r,g,b = o[1],o[2],o[3]  
     fi[x+1] = {cap(r+re*7), cap(g+ge*7), cap(b+be*7)}
     o = fj[x]; r,g,b = o[1],o[2],o[3]    
     fj[x] = {cap(r+re*5), cap(g+ge*5), cap(b+be*5)}
     o = fj[x-1]; r,g,b = o[1],o[2],o[3]    
     fj[x-1] = {cap(r+re*3), cap(g+ge*3), cap(b+be*3)}
     o = fj[x+1]; r,g,b = o[1],o[2],o[3]    
     fj[x+1] = {cap(r+re), cap(g+ge), cap(b+be)}

    end

  end -- x

  -- Flip ED lines and read the nextline
  t = j; j = i; i = t
  fj = fl[j]
  for x = 0, w - 1, 1 do
   r,g,b = getbackupcolor(getbackuppixel(x, y+2))
   --fl[j][x] = {r,g,b}
   fj[x] = {r,g,b}
  end

  if y%4==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
  end -- y
 end -- floyd


 if palcopy == 1 then for n = 0, 255, 1 do setcolor(n,getsparecolor(n)); end; end


end -- ok
