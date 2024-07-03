--BRUSH: Advanced Brush Scaling v0.96
--Collection of brush-scaling methods
--by Richard 'DawnBringer' Fhager 

--(V0.96 ip lib, linear for spritemode, cosip for color)


-- This monster of a script combines a large set of user preferences and input-formats
-- with an automatic selection of suitable algorithm for a given scenario (with some weight on pixel-art).
-- It also, in some cases, employ brightness-correction (color-theory) and optional (superior) hybrid-colormatching.

-- !!!NOTE: Bilinear scaling right now uses cosine (linear in sprite mode)

dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")

----------------------
-- Algos / Modes
--  
-- "SIMPLE"   - Basic scale. Any size.  
-- "BILINEAR" - Bi-linear Interpolation. Smoothest possible, x0.5 and up, also default for odd sizes (xd != yd)
-- "SMART"    - SmartFill, upscale x1 - x2 (will fail outside this range), sharper than BLI
-- "OCCUPY"   - DownScale <x1 (Interpolate all the colors that would occupy the same new pixel, very good quality)
--
-- SPRITEMODE tries to maintain sharp edges, combined with HYBRID colormatching the scaling will commonly only user brush-colors
--
--
-- sizing: "FRACTIONS" or "ABSOLUTE"
--

-- Choose the best algorithm for a given senario
function getBestAlgo(a,b,w,h,ip,xscale,yscale,fractions_flag) --ip=0,1,2->Sharp,medium,interpolation

 local algo,ch,xtr

 --     s < X0.5   X0.5<s<X1    X1<s<X2     s > X2
ch = {{"SIMPLE",  "SIMPLE",   "SIMPLE",   "SIMPLE"},   -- Sharp
      {"OCCUPY",  "OCCUPY",   "SMART",    "BILINEAR"}, -- Medium
      {"OCCUPY",  "BILINEAR", "BILINEAR", "BILINEAR"}} -- Interpolation


 algo = "FAILED TO SELECT AN ALGORITHM!"
 
 function lookup(ab,ip)
  local scale
  if ab <1.0 then scale = 2; end
  if ab <0.5 then scale = 1; end
  if ab >1.0 then scale = 3; end
  if ab >2.0 then scale = 4; end
  return ch[ip+1][scale]
 end

 if fractions_flag == true then
  return lookup(a/b,ip)
 end

 if fractions_flag == false then -- Only for absolute values (we also assume that both x&y are processed, no "xonly" etc)
  -- x & y scale different directions, bi-linear isn't perfect (if one axis is scaled to less than 50%), but the best for this (odd) scenario just now. 
  -- (it might be possible to scale one dimension at a time, but brushes cannot currently be finalized(), so it would be tricky)
  if (xscale * yscale) == 1 then -- Both dimensions are about to be scaled
   if ((a > w) and (b < h)) or ((a < w) and (b > h)) then 
     if ip  > 0 then return "BILINEAR"; end
     if ip == 0 then return "SIMPLE"; end
   end 
   -- Ok, so scaling is in the same direction for both x & y
   -- Method will be decided by the most extreme value of the two
    if (a/w > 1) or (b/h > 1) then -- Upscaling
     xtr = math.max(a/w, b/h)
     return lookup(xtr,ip)
    end
    if (a/w < 1) or (b/h < 1) then -- Downscaling
     xtr = math.min(a/w, b/h)
     return lookup(xtr,ip)
    end
  end
 end

 return algo

end


function doScaling(A,B,algo,sizing,xscale,yscale,bricorrect,hybrid,briweight,spritemode)

 local w,h,b,x,y,n,c,px,py,pal,fraction,absolute,nw,nh,AB,BA,ABx,ABy,BAx,BAy,xonly,yonly,Scale,collect

 w, h = getbrushsize()

 --spritemode = 0

 fraction, absolute = 1,0
 if sizing == "ABSOLUTE" then fraction, absolute = 0,1; end

 -- Brightness stuff
 if hybrid == 1 then
  pal = db.makePalList(256) -- Only for hybrid
  pal = db.fixPalette(pal)
 end

 bri = {}
 for b = 0, 255, 1 do
  bri[b+1] = db.getBrightness(getcolor(b))
 end
 --

 xonly = (yscale == 0)
 yonly = (xscale == 0)

 if fraction == 1 then

  AB = A/B
  BA = B/A
  ABx,BAx = AB,BA
  ABy,BAy = AB,BA

  if xonly == true then ABy,BAy = 1,1; end 
  if yonly == true then ABx,BAx = 1,1; end 

  nw = w * ABx 
  nh = h * ABy

 end

 if absolute == 1 then
  ABx = A / w
  BAx = 1 / ABx
  ABy = B / h
  BAy = 1 / ABy
  nw,nh = A,B -- Must use as this, sizes can be lost if using calculations
 end

 Xscale = 0
 Yscale = 0
 if nw < w then Xscale = -1; end
 if nw > w then Xscale =  1; end
 if nh < h then Yscale = -1; end
 if nh > h then Yscale =  1; end 


----------------------------------------------------------------
-- OCCUPY IP (Only for downscaling <= 0.5)
-- Mix colors that would occupy the same pixel when scaling down
-- Sizes between x1 and x0.5 get slighty jagged and a bit sharper than bilinear-interpolation.
-- Scaling below x0.5 seem to produce flawless results.
if algo == "OCCUPY" then
 
 if (Xscale > 0 or Yscale > 0) then messagebox("Algorithm: OCCUPY - can't scale up!"); return; end -- exit doScaling

 setbrushsize(nw,nh)
 
 -- MixDither/Resolution theory
 -- Since brightness is primarily determined by the brightest pixel in a cluster...
 -- just taking average RGB values of a cluster may result in a false brightness.
 --
 -- Looks like keeping both these active produces the most correct result

 briexp1 = 1
 briexp2 = 1 
 gammac1 = 1
 gammac2 = 1

if bricorrect == 1 then
 briexp1 = 2 
 briexp2 = 1 / briexp1
 -- Gamma correction for individual channels
 gammac1 = 2.2
 gammac2 = 1 / gammac1
end


 brushpal = {}; bcoldone = {}; brushcols = 0
 collect = {}
 for y = 0, h - 1, 1 do -- Place org. pixels at new locations
 
  collect[y+1] = {}
  for x = 0, w - 1, 1 do
 
    px = math.floor(x * ABx) + 1
    py = math.floor(y * ABy) + 1
    c = getbrushbackuppixel(x,y)
    
    if bcoldone[c+1] ~= true then
      bcoldone[c+1] = true
      brushcols = brushcols + 1
      r,g,b = getcolor(c)
      brushpal[brushcols] = {r,g,b,c}
    end

    if collect[py][px] == nil then  
       collect[py][px] = {c}
      else
       table.insert(collect[py][px],c) -- Build color list (insert last)
    end 
 
   --putbrushpixel(px, py, getbrushbackuppixel(x,y));

  end
 end

 --messagebox(brushcols)

 mode = "normal"
 --mode = "dominant"

 
 usepal = pal
 if spritemode == 1 then usepal = brushpal; end

 BC = getbackcolor()
 if mode == "normal" then
  for y = 0, nh - 1, 1 do
   statusmessage("OCCUPY Scaling: "..math.floor(y/nh*100).. "%    "); if (waitbreak(0)==1) then return; end
   for x = 0, nw - 1, 1 do
     list = collect[y+1][x+1]
     rt,gt,bt,len,britot = 0,0,0,#list,0
     aclen = 0
     for n = 1, len, 1 do
       if spritemode == 0 or list[n] ~= BC then 
        r,g,b = getcolor(list[n])
        xamt = 1
        -- Enhance contrast (so black and white details don't get washed out.
        -- Pref. this should have a threshold/detection to adjust to the image average brightness
        --xamt = 1 + (bri[list[n]+1]-128)^2 / 512 -- 16384 = x2, 8192 = x3
        rt = rt + r^gammac1 * xamt
        gt = gt + g^gammac1 * xamt
        bt = bt + b^gammac1 * xamt
        britot = britot + bri[list[n]+1]^briexp1 * xamt
        aclen = aclen + xamt -- +1 if no xamt
       end
     end 

   if (spritemode == 0 or aclen > 0) then 
     len = aclen 

    diff = 0
    if bricorrect == 1 then
     diff = (britot / len)^briexp2 - db.getBrightness((rt/len)^gammac2, (gt/len)^gammac2, (bt/len)^gammac2)
    end
 
    r,g,b = (rt/len)^gammac2+diff, (gt/len)^gammac2+diff, (bt/len)^gammac2+diff

    if hybrid == 1 then 
       c = db.getBestPalMatchHYBRID({db.rgbcap(r,g,b,255,0)},usepal,briweight/100,true) -- true for fixed palette
        else 
         c = matchcolor2(r,g,b) 
    end

    else c = BC
   end -- if aclen

    putbrushpixel(x, y, c)

  end
  end
 end

 function findDominant(list)
  local n,c,v,found,unique,exist,domc,domv
  exist,unique = {},{}

  found = 0
  for n = 1, #list, 1 do
   c = list[n]
   if exist[c] == nil then
    found = found + 1
    unique[found] = c
    exist[c] = 1
     else
      exist[c] = exist[c] + 1
   end
  end

  domv = -1
  domc = -1
  for n = 1, #unique, 1 do
   v = exist[unique[n]]
   if v >= domv then domv = v; domc = unique[n]; end 
  end

  return domc
 end

 if mode == "dominant" then
  for y = 0, nh - 1, 1 do
   for x = 0, nw - 1, 1 do
     list = collect[y+1][x+1]
     c = findDominant(list)
     putbrushpixel(x, y, c)
  end
  end
 end

end
----------------------------------------------------------------




----------------------------------------------------------------
-- SMARTFILL (Only for upscaling <= x2) !!! Need some last pixel-bkg IP prevention
-- Surgically filling the gaps for a sharper look than bi-linear
if algo == "SMART" then

 if (Xscale < 0 or Yscale < 0) then messagebox("Algorithm: SMARTFILL - can't scale down!"); return; end -- exit doScaling

 setbrushsize(nw,nh)

 xfill = {}
 yfill = {}
 for x = 0, w - 1, 1 do -- Place org. pixels at new locations
 
  px = x * ABx
  xfill[1+math.floor(px)] = true
 
  for y = 0, h - 1, 1 do
 
    py = y * ABy
    yfill[1+math.floor(py)] = true
 
   putbrushpixel(px, py, getbrushbackuppixel(x,y));

  end
 end

 BC = getbackcolor()
 for x = 0, nw - 1, 1 do
  statusmessage("SMARTFILL Scaling, Done: "..math.floor(x/nw*100).. "%    "); if (waitbreak(0)==1) then return; end
  for y = 0, nh - 1, 1 do

    xf = 0; if xfill[math.floor(x)+1] == nil then xf = 1; end
    yf = 0; if yfill[math.floor(y)+1] == nil then yf = 1; end
 
    draw = 0  
    britot = 0 
    len = 0

     if xf == 1 and yf == 0 then   
      c1 = getbrushpixel(x-1,y)
      c2 = getbrushpixel(x+1,y)
      if spritemode == 1 then
       if c1 == BC then c1 = c2; end
       if c2 == BC then c2 = c1; end
      end
      r1,g1,b1 = getcolor(c1)
        britot = britot + bri[c1+1]
      r2,g2,b2 = getcolor(c2)
        britot = britot + bri[c2+1]
      r,g,b = (r1+r2)/2, (g1+g2)/2, (b1+b2)/2 
      draw = 1
      len = 2
     end
   
     if xf == 0 and yf == 1 then   
      c1 = getbrushpixel(x,y-1)
      c2 = getbrushpixel(x,y+1)
      if spritemode == 1 then
       if c1 == BC then c1 = c2; end
       if c2 == BC then c2 = c1; end
      end
      r1,g1,b1 = getcolor(c1)
        britot = britot + bri[c1+1]
      r2,g2,b2 = getcolor(c2)
        britot = britot + bri[c2+1]
      r,g,b = (r1+r2)/2, (g1+g2)/2, (b1+b2)/2
      draw = 1
      len = 2 
     end
     
     if xf == 1 and yf == 1 then   
      c1 = getbrushpixel(x-1,y-1)
      c2 = getbrushpixel(x+1,y-1)
      c3 = getbrushpixel(x-1,y+1)
      c4 = getbrushpixel(x+1,y+1)
      r1,g1,b1 = getcolor(c1); britot = britot + bri[c1+1]
      r2,g2,b2 = getcolor(c2); britot = britot + bri[c2+1]
      r3,g3,b3 = getcolor(c3); britot = britot + bri[c3+1]
      r4,g4,b4 = getcolor(c4); britot = britot + bri[c4+1]
      div = 4
      if spritemode == 1 then
       if c1 == BC then r1,g1,b1 = 0,0,0; div = div-1; britot = britot - bri[c1+1]; end
       if c2 == BC then r2,g2,b2 = 0,0,0; div = div-1; britot = britot - bri[c2+1]; end
       if c3 == BC then r3,g3,b3 = 0,0,0; div = div-1; britot = britot - bri[c3+1]; end
       if c4 == BC then r4,g4,b4 = 0,0,0; div = div-1; britot = britot - bri[c4+1] ; end
        if div == 0 then div = 1; r1,g1,b1 = getcolor(BC); britot = bri[BC+1]; end
      end
      r,g,b = (r1+r2+r3+r4)/div, (g1+g2+g3+g4)/div, (b1+b2+b3+b4)/div
      draw = 1 
      len = div
     end


      if draw == 1 then
 
       if bricorrect == 1 then
        diff = (britot / len) - db.getBrightness(r, g, b)
        r = r + diff
        g = g + diff
        b = b + diff
       end

       if hybrid == 1 then 
        c = db.getBestPalMatchHYBRID({db.rgbcap(r,g,b,255,0)},pal,briweight/100,true) -- true for fixed palette
         else 
         c = matchcolor(r,g,b) 
       end

   
       putbrushpixel(x, y, c)
      end

  end
 end
 
end
----------------------------------------------------------------


----------------------------------------------------------------
-- SIMPLE / SHARP scaling
if algo == "SIMPLE" then
 
 setbrushsize(nw,nh)

 for x = 0, nw - 1, 1 do
  for y = 0, nh - 1, 1 do
    px = x * BAx
    py = y * BAy
    putbrushpixel(x, y, getbrushbackuppixel(px,py));
  end
 end
end
-- eof Simple
-----------------------------------------------------------------

-----------------------------------------------------------------
-- BI-LINEAR INTERPOLATION x0.5 - x10 
-- (Dunno if it's 100% correct but looks exactly like in Photoshop)
-- For scaling UP, scaling down work well for sizes >= 0.5 
-- Sizes less than 0.5 represents a larger amount of data than the 4 pixels used here.
-- Downscaling < 0.5 results in rather sharp images.

if algo == "BILINEAR" then

 setbrushsize(nw,nh)

 ifunc = ip_.cosip  -- sharp ip for color mode
 if spritemode == 1 then
  ifunc = ip_.linip -- Basic linear seem best for spritemode
 end
 

--if AB < 0.5 then messagebox("Bi-linear will not scale to sizes <0.5 with correct interpolation"); end

  -- Adjustment, this seem to work very nicely. Trial & Error, haven't bothered to figure out why.
 --adjX = (1 - BAx) / 2 
 --adjY = (1 - BAy) / 2 

 for x = 0, nw - 1, 1 do

  px = BAx * (x+0.5) - 0.5  -- Eq. 2 adjust? 1/3 works here
  xi = math.floor(px)
  xf = px - xi
  mx = math.min(px+1,(nw-1)*BAx)

  BC = getbackcolor()
  statusmessage("BILINEAR Scaling: "..math.floor(x/nw*100).. "%    "); if (waitbreak(0)==1) then return; end
  for y = 0, nh - 1, 1 do

    py = BAy * (y+0.5) - 0.5 
    yi = math.floor(py)
    yf = py - yi
    my = math.min(py+1,(nh-1)*BAy)

    c1 = getbrushbackuppixel(px,py)
    c2 = getbrushbackuppixel(mx,py)
    c3 = getbrushbackuppixel(px,my)
    c4 = getbrushbackuppixel(mx,my)

    r1,g1,b1 = getcolor(c1)
    r2,g2,b2 = getcolor(c2)
    r3,g3,b3 = getcolor(c3)
    r4,g4,b4 = getcolor(c4)  

        -- ken in color, linear in sprite
        r = ifunc(r1,r2,r3,r4,xf,yf)
        g = ifunc(g1,g2,g3,g4,xf,yf)
        b = ifunc(b1,b2,b3,b4,xf,yf)
 

        -- Right now these ip functions does not have edge protection, and note that bricorrection
        -- deceptively "corrects" most of this problem. 
        -- In fact; bicubic with bricorrection produces an output virtually identical to ken's formula
        --r,g,b = ip_.pixelRGB_Bilinear(px,py, getcolor, getbrushbackuppixel, ifunc) -- this works too
        --r,g,b = ip_.pixelRGB_Bicubic(px,py, getcolor, getbrushbackuppixel, ip_.cubip)


        xr = 1 - xf
        yr = 1 - yf

       -- Pretty crappy code here...perhaps improve
       dc = c1
       if spritemode == 1 then 
        colz = {}
        v = 0.5 -- Using the rootvalue (0.5) will produce a result almost identical to the ScaleX algorithm
                -- 0.7 may produce less jaggies than 0.5
        for nn = 1, 256, 1 do colz[nn] = 0; end
        colz[c1+1] = colz[c1+1] + math.pow(xr*yr,v)
        colz[c2+1] = colz[c2+1] + math.pow(xf*yr,v)
        colz[c3+1] = colz[c3+1] + math.pow(xr*yf,v)
        colz[c4+1] = colz[c4+1] + math.pow(xf*yf,v)
        --d = math.max(colz[c1+1],colz[c2+1],colz[c3+1],colz[c4+1])
        --if d == colz[c1+1] then dc = c1; end
        --if d == colz[c2+1] then dc = c2; end
        --if d == colz[c3+1] then dc = c3; end
        --if d == colz[c4+1] then dc = c4; end
        
        -- Find 2 dominant
        if colz[c1+1] >= colz[c2+1] then col1,col2 = {c1,colz[c1+1],r1,g1,b1},{c2,colz[c2+1],r2,g2,b2} else col1,col2 = {c2,colz[c2+1],r2,g2,b2},{c1,colz[c1+1],r1,g1,b1}; end
        if colz[c3+1] > col1[2] then 
          col1,col2 = {c3,colz[c3+1],r3,g3,b3},col1
           else if colz[c3+1] > col2[2] then col2 = {c3,colz[c3+1],r3,g3,b3}; end 
        end
        if col1[1] == col2[1] then col2 = {c3,colz[c3+1],r3,g3,b3}; end -- c1&c2 same and bigger than c3
        if c4 ~= c1 and c4 ~= c2 then
          if colz[c4+1] > col1[2] then 
           col1,col2 = {c4,colz[c4+1],r4,g4,b4},col1
            else if colz[c4+1] > col2[2] then col2 = {c4,colz[c4+1],r4,g4,b4}; end 
          end 
        end
        if col1[1] == col2[1] then col2 = {c4,colz[c4+1],r4,g4,b4}; end
        d2pal = {{col1[3],col1[4],col1[5],col1[1]}, {col2[3],col2[4],col2[5],col2[1]}}
        --if c1==c2 and c3==c4 and c1==c4 then -- Special case, but it doesn't seem to make any differance
        -- d2pal = {{r1,g1,b1,c1},{r2,g2,b2,c2},{r3,g3,b3,c3},{r4,g4,b4,c4}};
        --end
       end

        diff = 0
        if bricorrect == 1 then
          diff = ifunc(bri[c1+1],bri[c2+1],bri[c3+1],bri[c4+1],xf,yf) - db.getBrightness(r,g,b)
           --diff = (bri[c1+1]*xr + bri[c2+1]*xf)*yr + (bri[c3+1]*xr + bri[c4+1]*xf)*yf - db.getBrightness(r,g,b)
        end
     
        if hybrid == 1 then 
          dopal = pal
          if spritemode == 1 then dopal = {{r1,g1,b1,c1},{r2,g2,b2,c2},{r3,g3,b3,c3},{r4,g4,b4,c4}}; end
          c = db.getBestPalMatchHYBRID({db.rgbcap(r+diff,g+diff,b+diff,255,0)},dopal,briweight/100,true) -- true for fixed palette
            else 
           if spritemode == 1 then 
             --c = dc else c = matchcolor(r+diff,g+diff,b+diff);
             c = db.getBestPalMatchHYBRID({db.rgbcap(r+diff,g+diff,b+diff,255,0)},d2pal,briweight/100,true)
              else c = matchcolor(r+diff,g+diff,b+diff);
           end; 
        end

    putbrushpixel(x, y, c);

  end
 end
end
-- eof Bi-linear
-----------------------------------------------------------------


end -- doScaling


----
function sf_algo()
 local w,h,algo,xscale,yscale
 w, h = getbrushsize()
 OK,A,B,SIMPLE,BILINEAR,SMART,OCCUPY,bricorrect,hybrid,briweight = inputbox("Scale Brush "..w.." x "..h,
                           "N / D  (2/1 = x2)",        2,  1,4000,0,
                           "",                         1,  1,4000,0,
                            
                           "1. Simple scaling (sharp)",     1,  0,1,-1,
                           "2. Bilinear IP (x0.5..)",       0,  0,1,-1,
                           "3. SmartFill (up x1..x2)",      0,  0,1,-1,
                           "4. OccupyIP (down < 1x)",       0,  0,1,-1,
                           "BriCorrection",            1,  0,1,0,
                           "Hybrid ColMatch",  0,  0,1,0,   -- "(No SpM)" removed, did this mean No spritemode?, obsolete remenant?
                           "ColMatch Bri-Weight %", 50,  0,100,0                                                                        
 );


 if OK == true then 
  algo = 0
  if SIMPLE   == 1 then algo = "SIMPLE";   end 
  if BILINEAR == 1 then algo = "BILINEAR"; end
  if SMART    == 1 then algo = "SMART";    end
  if OCCUPY   == 1 then algo = "OCCUPY";   end   
  xscale = 1
  yscale = 1
  doScaling(A,B,algo,"FRACTIONS",xscale,yscale,bricorrect,hybrid,briweight, 0); 
 end
end -- eof sf_algo
-----

----
function sf_frac() -- Fractions
 local w,h,algo,xscale,yscale
 w, h = getbrushsize()
 OK,A,B,IP0,IP1,IP2,bricorrect,hybrid,briweight,SPRITEMODE = inputbox("Scale Brush "..w.." x "..h,
                           "N / D  (2/1 = x2)",        2,  1,4000,0,
                           "",                         1,  1,4000,0,
                       
                           "1. Sharp",              1,  0,1,-2,
                           "2. Medium(*)",             0,  0,1,-2,
                           "3. Full Interpolation*", 0,  0,1,-2,                                                
                           "BriCorrection",            1,  0,1,0,
                           "*Hybrid ColMatch>",  0,  0,1,0,   
                           "*ColMatch Bri-Weight %", 50,  0,100,0,
                           ">SPRITEMODE",            0,  0,1,0
                                               
 );

 if OK == true then 
  xscale = 1
  yscale = 1
  ip = 0
  if IP1 == 1 then ip = 1; end
  if IP2 == 1 then ip = 2; end
  algo = getBestAlgo(A,B,w,h,ip,xscale,yscale,true)

  messagebox(algo)

  doScaling(A,B,algo,"FRACTIONS",xscale,yscale,bricorrect,hybrid,briweight, SPRITEMODE); 
 end
end -- eof sf_frac
-----

----
function sf_abs()
 local w,h,algo,xscale,yscale
 w, h = getbrushsize()
 OK,A,B,IP0,IP1,IP2,bricorrect,hybrid,briweight,SPRITEMODE = inputbox("Scale Brush "..w.." x "..h,
                           "X Size",        w,  1,4000,0,
                           "Y Size",        h,  1,4000,0, 
                           "1. Sharp",              1,  0,1,-2,
                           "2. Medium(*)",             0,  0,1,-2,
                           "3. Full Interpolation*", 0,  0,1,-2,                                                
                           "BriCorrection",            1,  0,1,0,
                           "*Hybrid ColMatch>",  0,  0,1,0,   
                           "*ColMatch Bri-Weight %", 50,  0,100,0, 
                           ">SPRITEMODE",            0,  0,1,0                                           
 );

 if OK == true then
   xscale = 1
   yscale = 1
   ip = 0
   if IP1 == 1 then ip = 1; end
   if IP2 == 1 then ip = 2; end
   algo = getBestAlgo(A,B,w,h,ip,xscale,yscale,false)

   messagebox(algo)

   doScaling(A,B,algo,"ABSOLUTE",xscale,yscale,bricorrect,hybrid,briweight, SPRITEMODE); 
 end
end -- eof sf_frac
-----


-----
function sf_rel()
 local w,h,algo,xscale,yscale,hybrid,briweight,bricorrect,A,B,ip
 w, h = getbrushsize()
 OK,X05,X2,X3,X03,IP0,IP1,IP2,XSCALE,YSCALE = inputbox("Scale Brush "..w.." x "..h,

                           "1. HALF",     1,  0,1,-1,
                           "2. DOUBLE",   0,  0,1,-1,
                           "3. X 3",       0,  0,1,-1,
                           "4. X 1/3",     0,  0,1,-1,
                     
                           "a) Sharp",              1,  0,1,-2,
                           "b) Medium",             0,  0,1,-2,
                           "c) Full Interpolation", 0,  0,1,-2,

                           "X-Scale only",  0,  0,1,0,
                           "Y-Scale only",  0,  0,1,0
                                                                                             
 );

 if OK == true then
  if X05 == 1 then A = 1; B = 2; end
  if X2  == 1 then A = 2; B = 1; end
  if X3  == 1 then A = 3; B = 1; end
  if X03 == 1 then A = 1; B = 3; end

  xscale,yscale = 1,1
  if XSCALE == 1 then yscale = 0; end
  if YSCALE == 1 then xscale = 0; end

  algo = "SIMPLE"
 
  ip = 0
  if IP1 == 1 then ip = 1; end
  if IP2 == 1 then ip = 2; end

  algo = getBestAlgo(A,B,w,h,ip,xscale,yscale,true)

  messagebox(algo)

  bricorrect = 1
  hybrid = 0
  briweight = 50

  doScaling(A,B,algo,"FRACTIONS",xscale,yscale,bricorrect,hybrid,briweight, 0); 
 end
end -- eof sf_frac
-----

function _quit() end

function main()
selectbox("Brush Scale - Sel. Sizing", 
  ">FRACTIONS", sf_frac,
  ">RELATIVE",  sf_rel,
  ">ABSOLUTE",  sf_abs,
  ">ALGORITHM", sf_algo,
  "[Quit]", _quit
);
end

main()


