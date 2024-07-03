---------------------------------------------------
---------------------------------------------------
--
--              4-Dither Library
--              
--                    V1.0
--
--               September 2015
-- 
--                Prefix: d4_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  A suite of functions exploring the nature of four-color matrix dithering, 
--  a higher order of two-color mixdithering. A mixdither is a subset of a 4-Dither.

---------------------------------------------------

--
-- Use: dofile("../libs/db_4dither.lua") 
--

-- This library contains three major parts
-- 1. Main 4-Dither System
-- 2. Hue-Brightness 4-Dither Diagram system
-- 3. 3-Dither Diagram System (independent from 4dither)

--
-- Note: While the grayscale has its own coords, there's several other parts that make use of it right now
-- so it can't be independently relocated without screwing a few things up...
--

-- Note: This system uses hardcoded formulas for brightness and color-distance (weights: 0.26, 0.55, 0.19)
-- But currently the HueBri-Chart backgrounds uses a custom brightness function (dither brightness are still hardcoded)
-- (i.e. db.getBrightness (which right now is the same formula as the hardcoded))
-- So, if using another custom brightness-formula the dithers may not line up with the metrics in the chart.

--[[

        Gamma = 2.2  -- Dither Gamma power (It seems a higher than "normal" (2.2) works best with 4-dither)

    Briweight = 0.25 -- Color Distance Brightness weight 0..1, 0 = None, 1 = Only Brightness, ignoring color distances
                     -- Note: This has nothing to do with the dither itself, just the quality we prioritize when matching colors. 
                     -- Dither ratings (distance table) are using a hard (and separate) setting of bw=0.25 right now.        
Dither_Factor = 0.025    -- 0 = Best Colormatch only, any Dither goes. 
                         -- At 1.0 Coursness count as much as colormatching (and will result in only solid colors)
                         -- 0.025 is a good starting point, even 0.01 (1%) can have an impact (avoiding the worst dithers) 
                         -- With Primary 8, grey150 will dither at most 0.78
--]]



d4_ = {}

-- Unique 4-color dithers
--   4 colors:          35
--   7 colors:         210 (Highest number possible when adding MixCols to palette)
--   8 colors:         330
--  10 colors:         715
--  11 colors:       1.001 
--  16 colors:       3.876 (2-mix = 136 combos)
--  21 colors              (2-mix = 231 combos => 252 colors with original + mixcolors)
--  22 colors              (2-mix = 253 combos)
--  32 colors:      52.360 (2-mix = 528 combos)
--  48 colors:     249.900
--  64 colors:     766.480
-- 128 colors:  11.716.640
-- 256 colors: 183.181.376  (out of memory)
--
function d4_.four_slots(n) -- Make a list of all possible 4-combos of a set
 local s1,s2,s3,s4,t,list,count
 list = {}
 count = 1
 for s1 = 0, n-1, 1 do
  for s2 = s1, n-1, 1 do
   for s3 = s2, n-1, 1 do
    for s4 = s3, n-1, 1 do 
        list[count] = {s1,s2,s3,s4}
      count = count + 1
 end;end;end;end
 return list
end
--

--
function d4_.two_slots(n) -- Make a list of all possible 2-color 4-combos of a set.
 local s1,s2,t,list,count
 list = {}
 count = 1
 for s1 = 0, n-1, 1 do
  for s2 = s1, n-1, 1 do
        list[count] = {s1,s1,s2,s2}
      count = count + 1
 end;end
 return list
end
--


-----------------------------
-- Generic Local Functions --
-----------------------------

-- Dawn 3.0 (0.26-0.55-0.19 exp=2)
function d4_.getBrightness(r,g,b) -- 0-255
  return math.min(255,(r*r*0.0676 + g*g*0.3025 + b*b*0.0361)^0.5 * 1.5690256395005606) -- optimized (weights 0.26, 0.55, 0.19), ..606 is required to get 255
end
--


-- Return a lo-hi insertion-sorted copy (and keep original array intact)
function d4_.sortClone(d,idx) 
   local a,j,tmp,l,e,c
   c = {}; for a=1, #d, 1 do; c[a] = d[a]; end -- Copy array
   for a=2, #c, 1 do
    tmp = c[a];
    e = a
    for j=a, 2, -1 do  
      e = j
      if c[j-1][idx] > tmp[idx] then c[j] = c[j-1]; e = j-1; else break; end;
    end;
    c[e] = tmp;  
   end;
   return c
end
--


 --
 function d4_.line(x1,y1,x2,y2,c,step,put_func) -- Coords doesn't have to be integers w math.floor in place (Broken lines problem with fractions)
  local n,st,m,xd,yd,l,levels,lev; m = math
  put_func = put_func or putpicturepixel
  step = step or 1
  st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
  xd = (x2-x1) / st
  yd = (y2-y1) / st
  for n = 0, st, step do
    put_func(m.floor(x1 + n*xd), m.floor(y1 + n*yd), c );
  end
 end
 --

 --
 function d4_.rectangle(x,y,w,h,c,step,put_func)
  local line_f
  put_func = put_func or putpicturepixel
  w = w-1
  h = h-1
  line_f = d4_.line
  line_f(x,y,x+w,y,c,step,put_func)
  line_f(x,y,x,y+h,c,step,put_func)
  line_f(x+w,y+h,x,y+h,c,step,put_func)
  line_f(x+w,y+h,x+w,y,c,step,put_func)
 end
 --

---------------------------------
-- eof Generic Local Functions 
---------------------------------


--
-- Make a full color-distance table of all colors in palette-list
-- Perceptual distances using weights 0.26-0.55-0.19, normalizer = 1.5690256395005606
--
function d4_.makeColorDistanceTable(pal) -- Make (full) table of all colordistances of the colors of a palette
 local a,b,l,tab,r1,g1,b1,r2,g2,b2
  local dist,bw,diffB,obri
 tab = {}
  bw = 0.25
 --best = 999,c1,c2
 l = #pal
 for a = 1, l, 1 do
  tab[a] = {}
  r1,g1,b1 = pal[a][1],pal[a][2],pal[a][3]
   obri = (r1*r1*0.0676 + g1*g1*0.3025 + b1*b1*0.0361)^0.5
  for b = 1, l, 1 do
   r2,g2,b2 = pal[b][1],pal[b][2],pal[b][3]
    
   diffB = math.abs(obri - (r2*r2*0.0676 + g2*g2*0.3025 + b2*b2*0.0361)^0.5) -- Brightness diff

   --( rw*rw*(r1-r2)*(r1-r2) + gw*gw*(g1-g2)*(g1-g2) + bw*bw*(b1-b2)*(b1-b2) )^0.5 
   --dist = db.getColorDistance_weight(r1,g1,b1,r2,g2,b2,0.26,0.55,0.19) 
   dist = ((r1-r2)*(r1-r2)*0.0676 + (g1-g2)*(g1-g2)*0.3025 + (b1-b2)*(b1-b2)*0.0361)^0.5

    tab[a][b] = ((1-bw)*dist + bw*diffB) * 1.5690256395005606 -- Normalized to 0..255

   --if tab[a][b] < best and a ~= b then best = tab[a][b]; c1,c2 = pal[a][4],pal[b][4]; end
  end
 end
 --messagebox(c1..", "..c2)
 return tab
end
--


-------------------------
-- Quick sRGB test
function sG(v) -- sRGB to Linear
 a = 0.055
 if v <= 0.04045 then return v / 12.92
   else
      return ( (v+a) / (1+a) ) ^ 2.4
 end
end

function sRGB(v1,v2,v3,v4) -- Linear to sRGB
  a = 0.055
  s = (sG(v1) + sG(v2) + sG(v3) + sG(v4))/4
  if s <= 0.0031308 then return 12.92 * s
   else
     return (1+a) * s^(1/2.4) - a
  end
end
------------------------

------------------------
--- Dynamic gamma WIP
-- Not sure about the 4.82 but it's produces very accurate values and it's the square of 2.2 (no idea if there's a logic to this)
-- The only method I could think of for inversing the gamma was using the strongest of the 4 colors, 
-- again I'm not sure this is 100% correct or what exact logic behind this is...but it all produces pretty damn correct results.

--[[
function dG(v,gamma) -- v = 0..1
 local g
 g = gamma*gamma * (1-v) + gamma*v -- Gradient gamma
 return v^g
end
 --s = (dG(v1,gamma) + dG(v2,gamma) + dG(v3,gamma) + dG(v4,gamma))/4
 --l = math.max(v1,v2,v3,v4)
 --return s ^ (1 / (gamma*gamma * (1-l) + gamma*l))
--]]

-- Dynamic Gamma
-- Colors are fractions of 1
-- Will produce more accurate colors than normal gamma, especially in the dark-range. Will perform great at standard 2.2 level.
-- At lower values, like 1.5, dynamic gamma will produce darker colors in the mid-range than normal gamma, while the dark-range is brighter.
-- Is there a more correct way to calculate the inverse other than the max-value?
function d4_.dynGam(v1,v2,v3,v4,gam)
 local s,l,gsq
 gam = gam or 2.2
 gsq = gam*gam
 
 s = ( v1^(gsq*(1-v1)+gam*v1) + v2^(gsq*(1-v2)+gam*v2) + v3^(gsq*(1-v3)+gam*v3) + v4^(gsq*(1-v4)+gam*v4) ) * 0.25
 
 --s = ( v1^(gsq*(1-v1*v1)+gam*v1*v1) + v2^(gsq*(1-v2*v2)+gam*v2*v2) + v3^(gsq*(1-v3*v3)+gam*v3*v3) + v4^(gsq*(1-v4*v4)+gam*v4*v4) ) * 0.25

 l = math.max(v1,v2,v3,v4)
 --l = ((v1*v1 + v2*v2 + v3*v3 + v4*v4)/4)^0.5 -- Not correct, too bright

 return s ^ (1 / (gsq * (1-l) + gam*l)) 
 
end
--

------------

-- Make MixPal
function d4_.make4DithPal(combos,pal,gamma)
 local mixpal,c1,c2,c3,c4,r1,r2,r3,r4,g1,g2,g3,g4,b1,b2,b3,b4,i1,i2,i3,i4,combo,r,g,b,gN,gR,n,mf,gam

 mf = math.floor

 gN = gamma or 2.2 -- Gamma
 gR = 1 / gN

 mixpal = {}
 for n = 1, #combos, 1 do -- Combos are always in number order, lowest first
  combo = combos[n]
  c1 = pal[combo[1]+1]
  r1,g1,b1,i1 = c1[1],c1[2],c1[3],c1[4]
  c2 = pal[combo[2]+1]
  r2,g2,b2,i2 = c2[1],c2[2],c2[3],c2[4] 
  c3 = pal[combo[3]+1]
  r3,g3,b3,i3 = c3[1],c3[2],c3[3],c3[4] 
  c4 = pal[combo[4]+1]
  r4,g4,b4,i4 = c4[1],c4[2],c4[3],c4[4]  

  if gN < 0 then

   gam = -gN

   -- Dynamic Gamma
   r = d4_.dynGam(r1/255,r2/255,r3/255,r4/255, gam) * 255
   g = d4_.dynGam(g1/255,g2/255,g3/255,g4/255, gam) * 255
   b = d4_.dynGam(b1/255,b2/255,b3/255,b4/255, gam) * 255

   else

   r = ((r1^gN + r2^gN + r3^gN + r4^gN)/4)^gR
   g = ((g1^gN + g2^gN + g3^gN + g4^gN)/4)^gR
   b = ((b1^gN + b2^gN + b3^gN + b4^gN)/4)^gR
 
  end

  -- sRGB actually considers dark-dithers represents even darker mixcols than normal (when color often should be brigther) 
  --r = sRGB(r1/255,r2/255,r3/255,r4/255) * 255
  --g = sRGB(g1/255,g2/255,g3/255,g4/255) * 255
  --b = sRGB(b1/255,b2/255,b3/255,b4/255) * 255

 

  -- Culling: These exponent calcs may cause values to be returned as slightly larger, non-integer. 
  -- Ex: 255 will be returned larger than 255 (although it's so little it may not show in any displays, it can still screw up cals and algos)
  r = mf(r*100) * 0.01 -- A precision of 2 decimals should be enough for all applications
  g = mf(g*100) * 0.01
  b = mf(b*100) * 0.01

  -- Combos are palette indexes in the current sorted palette, 
  mixpal[n] = {r,g,b,combo[1],combo[2],combo[3],combo[4]} -- i1,i2,i3,i4 Dark to bright 1-4, we want 3,1,2,4 (April -15)
  mixpal[n].index = n
  -- Single color dither 
  mixpal[n].twodither = false
  mixpal[n].single = false
  if combo[1] == combo[2] and combo[3] == combo[4] then
   mixpal[n].twodither = true
   if combo[1] == combo[3] then
    mixpal[n].single = true
    mixpal[n].twodither = false
   end
  end 

  --setcolor(256-n,r,g,b) -- Add the mixcolors to palette

 end -- n (combos)

 mixpal.pal = pal

 return mixpal
end
--


------------------------------
-- New stuff
------------------------------


 -- Draw/Put 4-dither
 -- matrix: [OPTIONAL]ex 4-dither = {2,0,1,3} (3 is the brightest color)
 -- combo: index of mixpal to be drawn 
 function d4_.put4Dither(xs,ys,ox,oy,mixpal,combo,put_func,matrix) 
  local x,y,y2,cols,dith,pal
  pal = mixpal.pal -- Original palette list
  matrix = matrix or {2,0,1,3}
  cols = mixpal[combo] -- {r,g,b, v1,v2,v3,v4, (rating)} -- Combo-values (v) refers to pallist indexes
  dith = {1+cols[matrix[1]+4], 1+cols[matrix[2]+4], 1+cols[matrix[3]+4], 1+cols[matrix[4]+4]} -- dither matrix of mixpal pallist indexes, +1 is for pal start index 
  for y = 0, ys - 1, 1 do 
   y2 = 1 + (y%2)*2
   for x = 0, xs - 1, 1 do
    put_func(x+ox,y+oy, pal[dith[y2 + x%2]][4])
   end
  end
 end
 --

--
-- Strip MixPal of dithers with rating over the desired limit (to speed up colormatching)
-- Ratings/Limit are 0-100, 0 is perfect.
--
function d4_.stripMixpal(mixpal,limit)
 local n,newmix,count,rating
 newmix,count = {},0
 for n = 1, #mixpal, 1 do -- {r,g,b, v1,v2,v3,v4}
  rating = mixpal[n][8]
  if rating <= limit then
   count = count + 1
   newmix[count] = mixpal[n]
   newmix[count].index     = mixpal[n].index
   newmix[count].single    = mixpal[n].single
   newmix[count].twodither = mixpal[n].twodither
  end
 end

 newmix.pal = mixpal.pal

 return newmix
end
--

--
-- ok, Combo values start at 0 so we need a +1 to address the palette-list (rewrite combos to start at 1?)
--
function d4_.rateDithers(mixpal,dtab) -- MixPal, Distances table
 local n,c1,c2,c3,c4,bri_dist,dark_dist,max_dist,mid_dist,rating,e1,e2,e3,e4,pow

 pow = 0.123 -- Power/Scale, for now trying to make worst dither a 100 rating
 --pow = 0.2345 -- 1.9-2.2-1.6
 -- pow = 0.1955 -- 1.9-2.2-2.0
 -- Distance Exponents
 e1 = 1.9 -- Darkest colors
 e2 = 2.4 -- Brightest colors, used to be 2.2
 e3 = 2.0 -- Brightest-Darkest
 --e4 = 2.0 -- 2nd Brightest - 2nd Darkest

 for n = 1, #mixpal, 1 do -- {r,g,b, v1,v2,v3,v4}
  mix = mixpal[n] -- In order of brightness, darkest first


  dark_dist = dtab[1+mix[4]][1+mix[5]] -- Color distance two darkest colors
   bri_dist = dtab[1+mix[6]][1+mix[7]] -- Color distance two brightest colors
   max_dist = dtab[1+mix[4]][1+mix[7]] -- Darkest/Brightest
   --mid_dist = dtab[1+mix[5]][1+mix[6]] -- 2nd Darkest/Brightest

   rating = pow * (dark_dist^e1 + bri_dist^e2 + max_dist^e3)^0.5

  mixpal[n][8] = math.floor(rating*10)*0.1 -- Add dither rating
 end
 return mixpal
end
--

-- Remap image with 4-dither
function d4_.fourDither_Score(mixpal,match,matrix) -- matrix is optional
 local w,h,dith,x,y,p,i,o,c,ymod,pal
 w,h = getpicturesize()
 pal = mixpal.pal
 matrix = matrix or {2,0,1,3}
 dith = {matrix[1]+4,matrix[2]+4,matrix[3]+4,matrix[4]+4} -- dither matrix
 for y = 0, h - 1, 1 do 
  ymod = 1 + 2*(y%2) -- (+1 is for dith[] index)
  for x = 0, w - 1, 1 do
    p = getbackuppixel(x,y) + 1
    i = match[p][1]
    o = x%2 + ymod -- index 0..3
    c = pal[1 + mixpal[i][dith[o]]][4] -- mixpal{r,g,b,v1,v2,v3,v4,rating,brightness}, pal{r,g,b,i}
    putpicturepixel(x, y, c);
  end
  if y%8 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end;end
 end

end 
-- four dither


--
-- Add UNNORMALIZED brightness of mixcolor to MixPal. This is just a support function of MixPal setup.
--
function d4_.addBrightness2Mixpal(mixpal) -- Index #9 {r,g,b, v1,v2,v3,v4, rating, brightness}
 local m,d,r1,g1,b1,sq
 sq = math.sqrt
 for m = 1, #mixpal, 1 do 
  d = mixpal[m]
  r1,g1,b1 = d[1],d[2],d[3]
  mixpal[m][9] = sq(r1*r1*0.0676 + g1*g1*0.3025 + b1*b1*0.0361) -- derived from weights 0.26,0.55,0.19
 end
 return mixpal
end
--

-- Find best dither for each palette color
-- Note: If used for directly remapping an image, an intact palette corresponding with the orginal palette
--       indexes is required (if an image as a pixel of color 7 then the match #7 (+1) will be used)
-- Note: This is the part of the 4-dither system that takes most of the time.
function d4_.scoreMatchDithers(mixpal, pal, dither_factor, briweight)
 local norm,match,scores,mixbri,sq,abs,Bw,Cw,c,n,r,g,b,d,m,obri,best,bestscore,diffB,diffC,dist,r1,g1,b1,bri
 norm = 1.5690256395005606 / 2.55 -- Normalizer for weights 0.26,0.55,0.19
 match,scores = {},{} -- Scores: all scores for a single color (Make Brush-dither)
 sq,abs = math.sqrt, math.abs

 Bw = briweight or 0.25
 Cw = 1 - Bw

 for n = 1, #pal, 1 do -- Note that we always process the full 256 colors in every image/pal coz duplicate colors in image may fail with fixpalette()
  c = pal[n]; r,g,b = c[1],c[2],c[3]
  obri = sq(r*r*0.0676 + g*g*0.3025 + b*b*0.0361)
  best,bestscore = 1,100001
  for m = 1, #mixpal, 1 do
    d = mixpal[m]; r1,g1,b1,rating,bri = d[1],d[2],d[3], d[8], d[9]

    diffB = abs(obri - bri) -- Brightness diff 
    diffC = sq( 0.0676*(r-r1)*(r-r1) + 0.3025*(g-g1)*(g-g1) + 0.0361*(b-b1)*(b-b1) ) -- Color Distance
    dist = (diffB*Bw + diffC*Cw)*norm

    -- Note that color distances and dither-courseness aren't equivalent factors (regardless of norm=100)
    -- Best Color-distances will rarely be more than 10% of max, so dither-rating should rather be weighed
    -- against such values.
    score = dist*dist + dither_factor*rating*rating -- Just relative / comparison...no need to root
    scores[m] = {m,score} -- Scores for a single color (Brush-dither)
    if score < bestscore then best,bestscore = m,score; end -- "Direct Sorting", best way of finding the best dither
  end
 if #pal > 1 then statusmessage("Match Dither: Col "..n);waitbreak(0);end
 match[n] = {best,bestscore} 
 end
 return match,scores
end
--





--
function d4_.make4DitherBrush(xs,ys,r,g,b,pal,gamma,dither_factor,briweight,two_flag)
  local mixpal,combo
  mixpal = d4_.makeRatedMixpal(pal,gamma,two_flag,false) --  {r,g,b, v1,v2,v3,v4, rating}
  -- Returns match = {best combo,bestscore}
  combo = d4_.scoreMatchDithers(mixpal, {{r,g,b,-1}}, dither_factor, briweight)[1][1] -- scores = {mixpal index,score}
  setbrushsize(xs,ys)
  d4_.put4Dither(xs,ys,0,0,mixpal,combo,putbrushpixel) -- draw the dither, match is best combo (mixpal index)
end
--

 -- Strip away the worst (dither-->color matching) scores {mixpal_index,score} to improve sorting speed
 -- This only pertains to all the dithers match with a single color.
 --
 -- keep_fraction roughly corresponds with the % of combos that will be kept (f=0.1 means keep the best)
 -- keep_fraction: target fraction of the best scores (i.e. dithers) we'd like to keep. 0.1 = Try keeping the best 10%
 -- Note: This tend to approach the upper limit, usually the remainder is a much lower fraction
 -- F.ex. 32 colors is about 52.000 combos, a fraction of 0.05 should ideally give a stripped score-list of about 2600.
 -- But more commonly it's 100-1000, and even as little as 60 (or less?), it can however never be smaller than 1.
 -- Purpose of this function is
 -- 1. Improve Score-based sorting by removing the worst scoring dither-color matches (before sorting)
 -- 2. Nothing else...?
 function d4_.stripScores(scores,keep_fraction) -- keep_fraction is optional, the default formula seem pretty good
  local s,sc,slim,smin,stot,savg,newscores,scount
  smin,stot,savg,newscores,scount = 999999,0,-1,{},0
  keep_fraction = keep_fraction or (1/(#scores)^0.5) * 9 -- Higher multiple means more scores are kept.
  for s = 1, #scores, 1 do
   sc = scores[s][2]; smin,stot = math.min(smin,sc), stot + sc;
  end 
  savg = stot / #scores; 
  --slim = 0.9*smin + 0.1*savg -- We're looking for the lowest scores (0 is best), this formula will ideally extract the best 5%
  slim = smin + (savg-smin)*keep_fraction*2 

  for s = 1, #scores, 1 do 
   sc = scores[s][2]; if sc<=slim then scount = scount + 1; newscores[scount] = scores[s]; end
  end
  return newscores
 end
 --


-- Control function
-- Make a complete MixPal {r,g,b, v1,v2,v3,v4, rating, brightness}
function d4_.makeRatedMixpal(pal,gamma,two_flag,message_flag)
 local dtab,mixpal,combos,txt
  txt = ""
  if not two_flag then
   combos = d4_.four_slots(#pal);  txt = "Palette size: "..#pal.."\n\n4-Mixes possible: "..#combos
   else
    combos = d4_.two_slots(#pal);  txt = "Palette size: "..#pal.."\n\n2-Mixes possible: "..#combos
  end

  if message_flag then messagebox(txt); end

  statusmessage("Creating MixPal...");waitbreak(0)
 mixpal = d4_.make4DithPal(combos,pal,gamma)
  statusmessage("Creating Distance Table...");waitbreak(0)
   dtab = d4_.makeColorDistanceTable(pal)
  statusmessage("Rating Dithers...");waitbreak(0)
 mixpal = d4_.rateDithers(mixpal,dtab)
   --mixpal = d4_.stripMixpal(mixpal,20) -- We could possibly add the option of stripping here or even directly to rateDithers()
  statusmessage("Calculating Brightness...");waitbreak(0)
 mixpal = d4_.addBrightness2Mixpal(mixpal) -- Note: Not needed when not matching with rgb-values (using scoreMatchDither()) like drawCombos()
  statusmessage("...");waitbreak(0)
 return mixpal
end
--



-----------------------------------------------------------------------
--  d4._HueBriChart - Hue-Brightness 4-Dither Diagram system
-----------------------------------------------------------------------

--[[
--      d4_.HueBriChart_CONTROL(o) -- Chart object o:     

 o.MixPal     -- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)
                  If omitted, the Mixpal is created by the control function, use "nil" as value.
 o.Pal        -- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
 o.Gamma      -- Mixcolor gamma value, nominal 2.2
 o.Two_Flag   -- Flag: 2-Dithers only
 o.Xpos       -- Diagram x-position
 o.Ypos       -- Diagram y-position
 o.Hue_div    -- Hue columns
 o.Bri_div    -- Brightness rows
 o.Size       -- Dither swatches size
 o.Space      -- Spacing between dithers
 o.Mark1dith_Flag -- Flag: Mark Solid "Dithers" (Original palette colors) 
 o.Mark2dith_Flag -- Flag: Mark two color dithers
 o.Diagram     {
                clear_flag      -- Flag: Draw/Clear background
                curves_flag     -- Flag: Draw Brightness curves
                grid_flag       -- Flag: Draw Grid
                bg_value        -- Background (color) grayscale value 
                grid_value      -- Grid grayscale value 
                primary_value   -- Primary ([255,0,0] shifted) curve grayscale value
                secondary_value -- Seconary curves grayscale values
                setcols_flag    -- Flag: Set grayscale values (defined above) in palette (color 252-255)
                border          -- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
               },

 o.Sat_max    -- Maximum Saturation of mixcolors (dithers), 0..1
 o.Sat_min    -- Minimum ...
 o.Gry_lim    -- Grayscale Saturation limit 0..1, all dithers below this value are eligable for grayscale ramp
 o.Sat_factor -- Saturation vs Dither rating (smoothness) when selecting dither for a given slot (if there's more than one candidate)
              --  0% = Pick the best (smoothest) dither, 100% = pick the color with highest allowed saturation, nom = 25%
 o.Rating_lim -- Dither Rating Threshold: only allow dithers with a rating of or below this value (0-100(worst))
 	      --  50 = remove the junk, 25 = keep all decent, 10 = Only the best, 0 = Just original solid colors
 o.Hue_f      -- Hue function (r,g,b)-->(r,g,b),      ex. db.getHUE 
 o.Sat_f      -- Saturation function (r,g,b)-->0-255, ex. db.getAppSaturation
 o.Bri_f      -- Brightness function (r,g,b)-->0-255, ex. db.getBrightness
 o.Shift_f    -- HueShift func (r,g,b,deg)-->(r,g,b), ex. db.shiftHUE
--]]

--[[
  Example: (Requires db-library)

  chart_obj = {
   MixPal     = nil,
   Pal        = db.fixPalette(db.makePalList(256),1),  
   Gamma      = 2.2,
   Two_Flag   = false,	
   Xpos       = 8,
   Ypos       = 8,	
   Hue_div    = 36,	
   Bri_div    = 32,	
   Size       = 20,			
   Space      = 1,	
   Mark1dith_Flag = true
   Mark2dith_Flag = false,
   Diagram    = {
                clear_flag      = true,
                curves_flag     = true,
                grid_flag       = true,
                bg_value        = 90,
                grid_value      = 85,
                primary_value   = 120,
                secondary_value = 75,
                setcols_flag    = true,
                border          = 8
               },
  Sat_max    = 1.0
  Sat_min    = 0.25,	
  Gry_lim    = 0.15,	
  Sat_factor = 25,
  Rating_lim = 100,
  Hue_f      = db.getHUE 
  Sat_f      = db.getSaturation
  Bri_f      = db.getBrightness
  Shift_f    = db.shiftHUE
 }

 d4_.HueBriChart_CONTROL(chart_obj)

--]]

--
function d4_.HueBriChart_CONTROL(o)

 local w,h,xs,ys,Mixpal,Mtable,Limit

 Limit = 64

 -- Right now this system is screen-image only, so we can read picture size here...
 w,h = getpicturesize()
 xs,ys = d4_.HueBriChart_getSize(o)
 if xs>w or ys>h then
  messagebox("Alert!","Chart may not fit in screen\n\nChart Size: "..xs.." x "..ys.."\n\nImage Size: "..w.." x "..h)
 end
 --

 if #Pal <= Limit then

           d4_.HueBriChart_Back(o.Xpos,o.Ypos, o.Hue_div, o.Bri_div, o.Size, o.Space, o.Diagram, o.Bri_f, o.Shift_f)
           updatescreen();waitbreak(0); 
  Mixpal = o.MixPal or d4_.makeRatedMixpal(o.Pal,o.Gamma,o.Two_Flag,false) --  {r,g,b, v1,v2,v3,v4, rating, brightness}
  Mtable = d4_.HueBriChart_Data(Mixpal, o.Hue_div, o.Bri_div, o.Size, o.Sat_max, o.Sat_min, o.Gry_lim, o.Sat_factor, o.Rating_lim, o.Hue_f, o.Sat_f)
           d4_.HueBriChart_Draw(Mtable, Mixpal, o.Xpos,o.Ypos, o.Hue_div, o.Bri_div, o.Size, o.Space, o.Mark1dith_Flag, o.Mark2dith_Flag)

  else
   messagebox("Too Many Colors in Palette!","Max number of Colors: "..Limit)
 end
end
--

--
-- Get dimensions of Hue-Bri chart
--           o: Chart object
-- screen_flag: true  = return required size of image (top/left border may be outside screen depending on offset)
--              false = return actual dimensions of chart (regardless of where it's drawn)
--
function d4_.HueBriChart_getSize(o)
   -- +1 since grids are drawn outside dither area
  return (o.Hue_div+2)* (o.Size+o.Space) + o.Diagram.border*2 + 1,
          o.Bri_div   * (o.Size+o.Space) + o.Diagram.border*2 + 1
end
--

-------------------------------------------
--  Hue-Brightness Diagram, Create Table
--
--    Sat_max: 0..1   Highest Saturation allowed in the Mixcolors/Dithers
--    Sat_min: 0..1   Lowest Saturation allowed
--    Gry_lim: 0..1   Grayscale, highest saturation at which a dither can be considered grayscale
-- Sat_Factor: 0-100  Saturation over Rating, Sliding value. 100 = Select dither only by highest saturation, 0 = Select only by Rating (smoothness)
-- Rating_lim: 0-100  Highest (worst) Rating allowed in dithers. 50 = remove the junk, 25 = keep all decent, 10 = Only the best, 0 = Just original solid colors
--                    Note that the best dither (according to Sat_Factor) will be kept for a given slot if more than one is eligble,
--                    So there's no danger of having a bad dither replaced by a good one, even when allowing all dithers (100)
--
--
-- returns a table with mixpal-indexes (mtable)
--
function d4_.HueBriChart_Data(mixpal, Hue_div, Bri_div, Size, Sat_max, Sat_min, Gry_lim, Sat_Factor, Rating_lim, hue_f, sat_f)

 local mtable,x,y,v,r,g,b,n,m,mf,norm,sat,bri,hue,score,rat_factor,sat_factor,rating,rating_sq,brightness,score
 local gry_y,hue_y,Bri_div_Offset,Bri_Baseline

 mf = math.floor

 mtable = {}
   for y = 1, Bri_div+1, 1 do
    mtable[y] = {}
    for x = 1, Hue_div+1, 1 do
     mtable[y][x] = {-1,10000}
   end
   end

 -- Dither rating vs Saturation in selecting best dither
 --Sat_Factor = 100
 sat_factor = Sat_Factor / 100
 rat_factor = 1 - sat_factor
 statusmessage("Creating Diagram..."); updatescreen();waitbreak(0); 
 norm = 1.5690256395005606 / 255 -- Normalizer to max 1 for weights 0.26,0.55,0.19

 -- Note: Everything else being equal among candidates; the darkest color is selected for a slot (since colors are sorted)

 -- These are brightness row offsets to help nudge values into a well distributed range.
 -- This, with the formula [mf( (1-bri) * (Bri_div-1) + Bri_div_Offset)] will also make sure the range
 -- Start at 0 and end at 255 (as opposed to centering on the slots). 
 -- And the first/last rows are NOT exclusive to Black/White
 -- 0.95 is the lowest value that will put white on top row with bri_div=4
 Bri_div_Offset = 0.95
 if Bri_div > 4  then Bri_div_Offset = 0.9; end
 if Bri_div > 7  then Bri_div_Offset = 0.8; end
 if Bri_div > 20 then Bri_div_Offset = 0.75; end
 if Bri_div > 31 then Bri_div_Offset = 0.5; end

 -- THIS IS FOR HUES ONLY and not the Grayscale
 -- Top-row is brighter than the spatial position (with 16 rows it's not the full brightest 1/16 that will fall into that slot)
 -- + full white is not a hue - so the top-row is pretty must wasted in the Hue-part of the digram.
 -- This is only small adjustment, so the Hue-brightness won't be noticeable unaligned with the grayscale.
 -- There's also a logic in not pushing brights up too much as we want some room for bright dithers aswell.
 -- Adjust Brightness rows (rounding/threshold) up/down.. Negative = Up (Darker colors on higher rows)
 -- NOTE: Adjusting up also means that Pure white may not get the top slot as a darker shade could fall into that slot.
 --       It also means that the two darkest rows can clump closer (though there's usually little there in a the color-part)
 -- Basline just globally adjusts the Bri_div_Offset values.
 -- At 0, Blue 13 will hit bottom row with 32 slots, at -0.35 Blue 5.
 Bri_Baseline = -0.22

 for n = 1, #mixpal, 1 do

     m = mixpal[n]; r,g,b,rating,brightness = m[1],m[2],m[3],m[8],m[9];  rating_sq = rating ^ 2

     bri = brightness * norm
     hue_y = math.max(0,mf( (1-bri) * (Bri_div-1) + Bri_div_Offset + Bri_Baseline)) 
     gry_y = mf( (1-bri) * (Bri_div-1) + Bri_div_Offset) 

     sat = sat_f(r,g,b)/255 
    
     if sat > Sat_min and sat <= Sat_max and rating <= Rating_lim then
       -- Adjustment to make hue centered on tile rather than starting at left edge.
       -- F.ex unadjusted, with 12 hues, orange [255,127,0] will fall into the the first (red) column instead of the correct mid red-yellow column
       hue = ((hue_f(r,g,b,0) + 3/Hue_div) % 6) / 6 
       x = mf(hue * Hue_div)
       v = mtable[hue_y+1][x+1][2] -- score
       score = rat_factor * rating_sq + sat_factor*((1-sat)*100)^2 -- Lowest score is best, unclear if a low max_sat will skew results relative hi max_sat
       if v == -1 then
        mtable[hue_y+1][x+1] = {n,score}
         else
          if score < v then mtable[hue_y+1][x+1] = {n,score}; end 
       end
     end
 
 
     if sat < Gry_lim and rating <= Rating_lim then
       v = mtable[gry_y+1][Hue_div+1][2]
       -- A large Saturation factor (75-90%) seem to look better for grayscales
       -- but since a rather low (25-50%)works best for hues, and we don't have room
       -- for a separate grayscale parameter, let's just exponent the value (25% --> 66%, 50% --> 81%)
       -- Actually, an exponent of 0.3 behaves very well even at high sat-factors, the roughness of
       -- the grayscales seem to match that of the hues quite organically.
       -- However, 0.3 selects some rough bright gray dithers with db32, 0.5 works better there...
       score = rat_factor * rating_sq + sat_factor*(sat^0.5*100)^2 -- Note that the inverse of saturation is valued here 
       if v == -1 then
        mtable[gry_y+1][Hue_div+1] = {n,score}
         else
          if score < v then mtable[gry_y+1][Hue_div+1] = {n,score}; end 
       end
     end

   end -- n in mixpal
   --

  return mtable

end
-- huebri diagram data


-------------------------------------------
--  Hue-Brightness Diagram, Draw Background
--
function d4_.HueBriChart_Back(ox,oy, Hue_div, Bri_div, Size, Space, Diag, bri_f, shift_f)

 local x,y,r,g,b,ro,go,bo,d,d2,c,c0,c1,c2,c3,gry_ox,gry_oy,hb_ox,hb_oy, xsize,ysize, Border
 local line_f,rect_f

 Size = Size + Space

 Border = Diag.border or 0

 gry_ox = ox 
 gry_oy = oy
 hb_ox = ox + Size*2
 hb_oy = oy

 line_f = d4_.line
 rect_f = d4_.rectangle

 --Diagram = {clear_flag=true, curves_flag=true, grid_flag=true, bg_value=90, grid_value=85, primary_value=120, secondary_value=75, setcols_flag=true} -- Draw BG Flag, BG shade, Grid shade, Primary Hue Shade, Secondary Hue Shade, Set Colors (in Pal) Flag

  if Diag.setcols_flag then
   c0 = 255; setcolor(c0, Diag.bg_value, Diag.bg_value, Diag.bg_value)
   c1 = 254; setcolor(c1, Diag.grid_value, Diag.grid_value, Diag.grid_value)
   c2 = 253; setcolor(c2, Diag.primary_value, Diag.primary_value, Diag.primary_value)
   c3 = 252; setcolor(c3, Diag.secondary_value, Diag.secondary_value, Diag.secondary_value)
   else
    c0 = matchcolor(90,90,90)
    c1 = matchcolor(85,85,85)    -- Grid 
    c2 = matchcolor(120,120,120) -- Main Hue curves (Primaries)
    c3 = matchcolor(75,75,75)    -- Secondary Hue curves
  end

  if Diag.clear_flag then
   xsize = (Hue_div+2)*Size + Border 
   ysize = (Bri_div)*Size + Border
   for y = -Border, ysize do -- Grid draws outside dither-area (left/bottom) so no -1
    for x = -Border, xsize do
     putpicturepixel(gry_ox+x, gry_oy+y,c0)
    end
   end
  end 

  -- Draw Lines & curves
  if Diag.grid_flag then
    for b = 0, Bri_div, 1 do -- inc. bottom line
     x = gry_ox
     y = hb_oy + b*Size
     line_f(x,y,x+Size*(Hue_div+2),y,c1)
    end
    for b = 0, Hue_div+2, 1 do  -- gray+space+hue+rightedge --> + 2
     x = gry_ox + b*Size
     y = hb_oy
     line_f(x,y,x,y+Size*Bri_div,c1)
    end
    
    -- Mid Brightness
    y = hb_oy + Bri_div/2 * Size
    line_f(gry_ox,y,gry_ox+Size*(Hue_div+2),y,c3,2)

    -- Gray Box
    rect_f(gry_ox,gry_oy, Size+1, Bri_div*Size+1,c3,1)

    -- HueBri Box
    rect_f(hb_ox,hb_oy, Hue_div*Size+1, Bri_div*Size+1,c3,1)

     -- Primaries lines
    for b = 0, 5, 1 do
     x = gry_ox + Size*2 + Size/2 + (Hue_div/6) * Size * b
     line_f(x,hb_oy,x,hb_oy+Size*Bri_div,c2,3)
    end
    -- Secondaries lines
    if Hue_div >= 24 then
     for b = 0, 5, 1 do
      x = gry_ox + Size*2 + Size/2 + (Hue_div/6) * Size * (b+0.5)
      line_f(x,hb_oy,x,hb_oy+Size*Bri_div,c3,2)
     end
    end

  end
  --

  if Diag.curves_flag then
    levels = {{255,0,0,c2}, {63,0,0,c3},{127,0,0,c3},{191,0,0,c3},{255,63,63,c3},{255,127,127,c3},{255,191,191,c3}}
    for l = 1, #levels, 1 do
     lev = levels[l]
     ro,go,bo,c = lev[1],lev[2],lev[3],lev[4]
     for d = 0, 360, 0.5 do
      d2 = (d - (360/Hue_div)*0.5) % 360 -- Adjust lines to match the tile centering
       r,g,b = shift_f(ro,go,bo,d2)
       x = hb_ox + d/360 * Hue_div*Size
       y = hb_oy + (1-bri_f(r,g,b) / 255) * Bri_div*Size
       putpicturepixel(x,y,c)
     end
   end -- curves

  end
  -- drawing

end
--


-------------------------------------------
--
--
function d4_.HueBriChart_Draw(mtable, mixpal, ox,oy, Hue_div, Bri_div, Size, Space, Mark1dith_flag, Mark2dith_flag)

 local x,y,n,m,tx,ty,gry_ox,gry_oy,hb_ox,hb_oy,sp,ofs
 local rect_f

 rect_f = d4_.rectangle

 -- Space between dithers
 sp = Space
 -- Offset depending on Space (so dithers align nicely with grid)
 offsets = {0,1,2,2}; if Space < 4 then ofs = offsets[Space+1] else ofs = math.ceil(Space/2); end
 
 if Mark1dith_flag == nil then
  Mark1dith_flag = true
 end
 
 gry_ox = ox + ofs
 gry_oy = oy + ofs
 hb_ox = ox + (Size+sp)*2 + ofs
 hb_oy = oy + ofs

   statusmessage("Drawing Dithers..."); updatescreen();waitbreak(0); 
   for y = 1, Bri_div, 1 do
    for x = 1, Hue_div+1, 1 do

     n = mtable[y][x][1]

     if n > 0 then
    
      if x < Hue_div+1 then
       tx = hb_ox + (x-1) * (Size+sp)
       ty = hb_oy + (y-1) * (Size+sp)
        else
         tx = gry_ox
         ty = gry_oy + (y-1) * (Size+sp)
      end
 
      d4_.put4Dither(Size,Size,tx,ty,mixpal,n,putpicturepixel) -- draw the dither, match is best combo (mixpal index)

      if Mark1dith_flag and mixpal[n].single then
       rect_f(tx+1,ty+1,Size-2,Size-2,matchcolor(0,0,0),1)
       if Size >= 16 and Mark2dith_flag then -- make double thickness if two dithers are also marked
        rectangle(tx+2,ty+2,Size-4,Size-4,matchcolor(0,0,0),1)
       end
      end 

      if Mark2dith_flag and mixpal[n].twodither then
       rect_f(tx+1,ty+1,Size-2,Size-2,matchcolor(0,0,0),2) -- dotted lines for two dithers
      end    

     end -- n>0
 
    end
    updatescreen();waitbreak(0); 
   end

end
--

-----------------------------------------------------------------------
-- eof d4._HueBriChart
----------------------------------------------------------------------- 



-----------------------------------------------------------------------
--------------- 3-Dither Diagrams System (d4_.d3_) --------------------
-----------------------------------------------------------------------

-- matrix: [OPTIONAL]ex 4-dither = {2,0,1,3} (3 is the brightest color)
 -- Dedicated 3Dither version, not compatible with 4Dither system. (It's still 4 pixels, just 3 colors and a tweaked matrix (indexes))
 function d4_.d3_put3Dither(xs,ys,ox,oy,pal,cols,put_func,matrix) 
  local x,y,y2,dith
  matrix = matrix or {3,1,2,4}
  dith = {cols[matrix[1]], cols[matrix[2]], cols[matrix[3]], cols[matrix[4]]} -- dither matrix of mixpal pallist indexes, +1 is for pal start index 
  for y = 0, ys - 1, 1 do 
   y2 = 1 + (y%2)*2
   for x = 0, xs - 1, 1 do
    put_func(x+ox,y+oy, pal[dith[y2 + x%2]][4])
   end
  end
 end
 --

-- ABC {1,2,3} pyramid (Man, this took some thinking to get right & smart)
function d4_.d3_makePyramid(pal_sort)
  local pyr,x,y,d,dist,i,s
  -- Brightness order list to smart-sort colordistribution
  order = {pal_sort[1][5], pal_sort[2][5], pal_sort[3][5]}
  pyr = {}
  for y = 0, 4, 1 do
   pyr[y+1] = {}
   for x = 0, y, 1 do
    d,dist = {},{4-y,x,y-x} -- A,B,C  # of each color Distribution list (A is color 1 at top of pyramid)
    -- Sort/Build distribution by brightness ex [1,1,2,3] --> [2,1,1,3] (if col 1 is brighter than col 2)
    for i = 1, 3, 1 do; for n = 1, dist[order[i]], 1 do; d[#d+1] = order[i]; end; end
    pyr[y+1][x+1] = d
    s = false; if dist[1] == 4 or dist[2] == 4 or dist[3] == 4 then s = true; end
    pyr[y+1][x+1].single = s
   end
  end
  return pyr 
end
--
 
 
--  A           A   C#####B  B#####C
--  #           #    ####      ####
--  ##         ##    ###        ###
--  ###       ###    ##          ##   
--  ####     ####    #            #
-- C#####B B#####C   A            A
--  Normal  Xflip   Yflip    Xflip+Yflip
--
-- pyramid_flag: arrow head/pyramid (offset x by y/2)
--
-- Note: x-flip makes no sense with Pyramid mode
--
function d4_.d3_drawPyramid(ox,oy, sx,sy, data, pal, space, xflip_flag, yflip_flag, pyramid_flag, put_func, mark1dith_flag)
 local x,y,xm,xv,ym,yv,pyr,xp,yp
 if mark1dith_flag == nil then mark1dith_flag = true; end
 pyr = 0; if pyramid_flag then pyr = (sx+space)*0.5; end 
 xv,xm = 0,-1; if xflip_flag then xv,xm = 4,1; end
 yv,ym = 0,-1; if yflip_flag then yv,ym = 4,1; end
 for y = 0, 4, 1 do
  for x = 0, y, 1 do
   xp = ox+(sx+space)*(xv-x*xm)+pyr*(4-y)
   yp = oy+(sy+space)*(yv-y*ym)
   d4_.d3_put3Dither(sx,sy,xp,yp,pal,data[y+1][x+1],put_func)
   if mark1dith_flag and data[y+1][x+1].single then d4_.rectangle(xp+1,yp+1,sx-2,sy-2,matchcolor(0,0,0), 1, put_func); end -- Mark solid colors
  end
 end 
end
--


--
-- Brightness function (0..255) is optional
function d4_.d3_make3Pal(c1,c2,c3,bri_func) 
 --local p1,p2,p3,i,gc
 --i,gc = table.insert, getcolor
 --p1 = {gc(c1)};i(p1,c1);i(p1,1)
 --p2 = {gc(c2)};i(p2,c2);i(p2,2)
 --p3 = {gc(c3)};i(p3,c3);i(p3,3)
 --return {p1,p2,p3}

 bri_func = bri_fun or d4_.getBrightness

 local r1,g1,b1,r2,g2,b2,b3,g3,b3
 r1,g1,b1 = getcolor(c1)
 r2,g2,b2 = getcolor(c2)
 r3,g3,b3 = getcolor(c3)
 return {{r1,g1,b1,c1,1,bri_func(r1,g1,b1)}, {r2,g2,b2,c2,2,bri_func(r2,g2,b2)}, {r3,g3,b3,c3,3,bri_func(r3,g3,b3)}}
end
--

--
-- 3Dither Control functions (note that Brightness-function args are optional)
--

-- CONTROL, PYRAMID: 3-Dither, 3 color Pyramid 
-- Color indexes (top-right-left-bottom), xpos,ypos, width,height, spacing
function d4_.d3_CTRL_drawPyramid(c1,c2,c3, ox,oy, sx,sy, space, xflip_flag, yflip_flag, pyramid_flag, put_func, bri_func)
 local pal1,pal2,pyr1,pyr2
 pal1 = d4_.d3_make3Pal(c1,c2,c3,bri_func) 
 pyr1 = d4_.d3_makePyramid(d4_.sortClone(pal1,6)) -- Sort on brightness (lo-hi), argument only, we can't sort the original pal-list
 d4_.d3_drawPyramid(ox,oy,sx,sy, pyr1, pal1, space, xflip_flag, yflip_flag, pyramid_flag, put_func) -- Normal
end
--


-- CONTROL, DIAMOND: 3-Dither, 4 color Diamond 
-- Color indexes (top-right-left-bottom), xpos,ypos, width,height, spacing
function d4_.d3_CTRL_drawDiamond(c1,c2,c3,c4, ox,oy, sx,sy, space, put_func, bri_func)
 local pal1,pal2,pyr1,pyr2
 pal1 = d4_.d3_make3Pal(c1,c2,c3,bri_func) 
 pal2 = d4_.d3_make3Pal(c4,c2,c3,bri_func)
 pyr1 = d4_.d3_makePyramid(d4_.sortClone(pal1,6)) -- Sort on brightness (lo-hi), argument only, we can't sort the original pal-list
 pyr2 = d4_.d3_makePyramid(d4_.sortClone(pal2,6)) -- {r,g,b, c, #, brightness}
 d4_.d3_drawPyramid(ox,oy,              sx,sy, pyr1, pal1, space, false, false, true, put_func) -- Normal
 d4_.d3_drawPyramid(ox,oy+(sy+space)*4, sx,sy, pyr2, pal2, space, false, true,  true, put_func) -- Yflip
end
--

-- CONTROL, SQUARE1 \: 3-Dither, 4 color Square, 1st & last colors are dominant (double lateral, ramps diagonally)
-- Color indexes (top-right-left-bottom), xpos,ypos, width,height, spacing
function d4_.d3_CTRL_drawSquare1(c1,c2,c3,c4, ox,oy, sx,sy, space, put_func, bri_func)
 local pal1,pal2,pyr1,pyr2
 pal1 = d4_.d3_make3Pal(c1,c4,c3,bri_func) 
 pal2 = d4_.d3_make3Pal(c4,c1,c2,bri_func)
 pyr1 = d4_.d3_makePyramid(d4_.sortClone(pal1,6)) -- Sort on brightness (lo-hi), argument only, we can't sort the original pal-list
 pyr2 = d4_.d3_makePyramid(d4_.sortClone(pal2,6)) -- {r,g,b, c, #, brightness}
 d4_.d3_drawPyramid(ox,oy, sx,sy, pyr1, pal1, space, false, false, false, put_func) -- Normal
 d4_.d3_drawPyramid(ox,oy, sx,sy, pyr2, pal2, space, true,  true,  false, put_func) -- Xflip+Yflip
end
--


-- CONTROL, SQUARE2 /: 3-Dither, 4 color Square, 2nd & 3d colors are dominant (double lateral, ramps diagonally)
-- Color indexes (top-right-left-bottom), xpos,ypos, width,height, spacing
function d4_.d3_CTRL_drawSquare2(c1,c2,c3,c4, ox,oy, sx,sy, space, put_func, bri_func)
 local pal1,pal2,pyr1,pyr2
 pal1 = d4_.d3_make3Pal(c3,c2,c1,bri_func) 
 pal2 = d4_.d3_make3Pal(c2,c3,c4,bri_func)
 pyr1 = d4_.d3_makePyramid(d4_.sortClone(pal1,6)) -- Sort on brightness (lo-hi), argument only, we can't sort the original pal-list
 pyr2 = d4_.d3_makePyramid(d4_.sortClone(pal2,6)) -- {r,g,b, c, #, brightness}
 d4_.d3_drawPyramid(ox,oy, sx,sy, pyr1, pal1, space, false, true,  false, put_func) -- Xflip
 d4_.d3_drawPyramid(ox,oy, sx,sy, pyr2, pal2, space, true,  false, false, put_func) -- Yflip
end
--

-- CONTROL*, WHEEL: 3-Dither, 7 color wheel 
-- Color indexes (top-right-left-bottom), xpos,ypos, width,height, spacing
function d4_.d3_CTRL_drawWheel(c1,c2,c3,c4,c5,c6,c7, ox,oy, sx,sy, space, put_func, bri_func)
 local pal1,pal2,pyr1,pyr2

 d4_.d3_CTRL_drawDiamond(c2,c1,c3,c6, ox,oy, sx,sy,              space, put_func, bri_func)
 d4_.d3_CTRL_drawDiamond(c4,c5,c1,c7, ox+(sx+space)*4,oy, sx,sy, space, put_func, bri_func)
 --                                                                        xflip  yflip  pyramid
 d4_.d3_CTRL_drawPyramid(c1,c4,c2, ox+(sx+space)*2,oy, sx,sy,              space, false, true,  true, put_func, bri_func)
 d4_.d3_CTRL_drawPyramid(c1,c7,c6, ox+(sx+space)*2,oy+(sy+space)*4, sx,sy, space, false, false, true, put_func, bri_func)

end
--


-----------------------------------------------------------------------
-- eof 3-Dither Diagrams System 
-----------------------------------------------------------------------


-----------------------------------------------
-- FUNCTION RENDER                           --
-----------------------------------------------


-- Example function, Horizontal grayscale
-- function f(fx,fy)
--    r = fx * 255
--    g = fx * 255
--    b = fx * 255
--    return r,g,b
--   end
--
-- Gamma = 2.2 -- MixColor Gamma power (It seems a higher than "normal" (2.2) works best with 4-dither)
--
--    Briweight = 0.25 -- Color Distance Brightness weight 0..1, 0 = None, 1 = Only Brightness, ignoring color distances
--                     -- Note: This has nothing to do with the dither itself, just the quality we prioritize when matching colors. 
--                     -- Dither ratings (distance table) are using a hard (and separate) setting of bw=0.25 right now.        
--Dither_Factor = 0.025    -- 0 = Best Colormatch only, any Dither goes. 
--                         -- At 1.0 Coursness count as much as colormatching (and will result in only solid colors)
--                         -- 0.025 is a good starting point, even 0.01 (1%) can have an impact (avoiding the worst dithers) 
--                         -- With Primary 8, grey150 will dither at most 0.78
--
-- Pal = db.fixPalette(db.makePalList(256),1) 
-- d4_.renderScene(w,h,0,0,f,Pal,Gamma,Dither_Factor,Briweight,TWO_FLAG)



-- 4-Dither a mathscene (function)
 function d4_.renderScene(w,h,ox,oy,func,pal,gamma,dither_factor,briweight,two_flag)
   local x,y,i,o,c,r,g,b,yf,ymod,dith,mixpal

   mixpal = d4_.makeRatedMixpal(pal,gamma,two_flag,true) --  {r,g,b, v1,v2,v3,v4, rating, Brightness(unnormalized)}
   mixpal = d4_.stripMixpal(mixpal,20) 
   dith = {2+4,0+4,1+4,3+4} -- dither matrix, +4 is mixpal index

   for y = 0, h - 1, 1 do 
    ymod = 1 + 2*(y%2) -- (+1 is for dith[] index)
    yf = y/h
    dithf = dither_factor
    for x = 0, w - 1, 1 do
      r,g,b = func(x/w,yf)
      i = d4_.scoreMatchDithers(mixpal, {{r,g,b,-1}}, dithf, briweight, two_flag)[1][1]
      o = x%2 + ymod -- index 0..3
      c = pal[1 + mixpal[i][dith[o]]][4] -- mixpal{r,g,b,v1,v2,v3,v4,rating,brightness}, pal{r,g,b,i}
      putpicturepixel(x, y, c);
    end
    statusmessage("Done: %"..math.floor(y*100/h))
    updatescreen(); if (waitbreak(0.1)==1) then return; end
   end
 end
 --

