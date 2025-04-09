---------------------------------------------------
---------------------------------------------------
--
--             DawnBringer Library
--              
--                    V2.0
-- 
--                Prefix: db.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  This is a huge collection of various functions (used by most of the DawnBringer (_db_) scripts)

---------------------------------------------------

-- You may access these functions in your own scripts by loading this library,
-- just add the follwing line as one of the first instructions:
--
-- dofile("../libs/dawnbringer_lib.lua") 
--

-- Note that the functions must be called with the full library object-name, "db.function_name..."

---------------------------------------------------




-- Global library object
db = {} 


db.dummy = (function() return -1; end)

-- *************************************
-- ***        Master Settings        ***
-- *************************************
--

-- Return Master/Global RGB-colorspace proportions, i.e. weights used for all pereceptual color calculations
--
function db.getDefaultRGBweights()
 return 0.26, 0.55, 0.19 -- Dawn3.0
end
--

-----------------------------------------



-- *************************************
-- ***         Interactivity         ***
-- *************************************
--
--


 --
 -- Anim update, progress-meter & scanline for image renders
 --
 -- upd: Update frequency, 1 = every line, 10 = every 10th line
 --   y: line (of h)
 --   w: Image width
 --   h: Image height (or 100% of amount to be processed)
 -- scanline: flag (true/false), draw a scanline
 -- ex usage: (at every y line): if db.donemeter(10,y,w,h,true) then return; end -- update every 10th line
 --
 function db.donemeter(upd,y,w,h,scanline,ofx,ofy)
  local x,cols 
  if (y%upd)==0 then
   ofx = ofx or 0
   ofy = ofy or 0
   cols = {matchcolor(0,0,0),matchcolor(192,192,192)}
   statusmessage("Done: "..math.floor((y+1)*100/h).."%")
   if scanline and y<h-1 then for x = 0, w-1, 1 do putpicturepixel(ofx+x,ofy+y+1,cols[1+x%2]); end; end
   updatescreen(); if (waitbreak(0)==1) then return true; end 
  end
  return false
 end
 --

 --
 function db.donemeter_x(upd,x,w,h,scanline,ofx,ofy)
  local y,cols 
  if (x%upd)==0 then
   ofx = ofx or 0
   ofy = ofy or 0
   cols = {matchcolor(0,0,0),matchcolor(192,192,192)}
   statusmessage("Done: "..math.floor((x+1)*100/w).."%")
   if scanline and x<w-1 then for y = 0, h-1, 1 do putpicturepixel(ofx+x+1,ofy+y,cols[1+y%2]); end; end
   updatescreen(); if (waitbreak(0)==1) then return true; end 
  end
  return false
 end
 --

 --
 function db.donetext(upd,y,h, txt)
  if (y%upd)==0 then
   txt = txt or ""
   statusmessage("Done: "..math.floor((y+1)*100/h).."% "..txt)
   if (waitbreak(0)==1) then return true; end 
  end
  return false
 end
 --

-- eof interactivity



-- *************************************
-- ***      Text & Conversions       ***
-- *************************************
--
--

--
function db.rgb2HEX(r,g,b,prefix)
  local c,n,s,t,z
  c = {r,g,b}
  z = {"0",""}
  t = ""
  for n = 1, 3, 1 do
   if c[n] >= 0 and c[n] <= 255 then
    s = string.upper(string.format("%x",c[n]))
    t = t..z[#s]..s
     else  
      if c[n] > 255 then t = t.."++"; end
      if c[n] < 0 then   t = t.."--"; end
   end
     --s = tonumber(c[n],16)
     --t = t..s
  end
  return prefix..t
end
--

--
-- ... eof Text & Conversions ...
--


-- ************************************
-- ***      Number Formatting       ***
-- ************************************

--
function db.format(v,p)
 return math.floor(v * 10^p) / 10^p
end
--

-- Round value up with a given number of decimals, f.ex to be used with color-distances results that may less than full range 
-- ex: 5.3991 with 3 decimals will become 5.4 (5.3991 * 1000 = 5399.1, math.ceil(5399.1) = 5400, 5400 * 0.001 = 5.4)
-- ex: 1.12345678 with 2 decimals will become 1.13
--
function db.roundUp(v,decimals)
 local m
 m = 10^decimals
 return math.ceil(v*m) * (1/m)
end
--

---



-- *************************************
-- ***    Custom Math Functions     ***
-- *************************************
--

--
-- Greatest Common Divisor
--
function db.gcd(a,b)
  local t 
  while(b~=0) do t=b; b=a%b; a=t; end 
  return a
end
--

--
function db.crnd(seed1,seed2)
  seed1 = (seed1 * 17) % 197
  seed2 = (seed2 * 23) % 283
  val = ((seed1 * seed2 + seed1 + seed2) % 9999) / 10000
  return val,seed1,seed2
end
--

--
function db.sign(v) -- 8% faster
  if v > 0 then return 1; end
  if v < 0 then return -1; end
  return 0 
end
--


--function db.distance(ax,ay,bx,by) return math.sqrt((ax-bx)^2 + (ay-by)^2); end

function db.distance(ax,ay,bx,by) return ((ax-bx)*(ax-bx) + (ay-by)*(ay-by))^0.5; end


--
-- Rounded output for drawing purposes
--
function db.rotation(rot_ang,hub_x,hub_y,x,y) -- Rotate coordinates x & y relative hub
  local new_ang,dist,m,xd,yd,v; m = math 
  xd=hub_x-x; 
  yd=hub_y-y; 
  dist = (xd*xd+yd*yd)^0.5;
  new_ang = m.atan2(yd,xd) + rot_ang * 0.017453292 -- + means clockwise, intuitive (PS), (in math + is ccw)
  x = hub_x - m.cos(new_ang)*dist;
  y = hub_y - m.sin(new_ang)*dist;
  return m.floor(x),m.floor(y)
end
--

--
function db.rotationFrac(rot_ang,hub_x,hub_y,x,y) -- Rotate coordinates x & y relative hub
  local new_ang,dist,m,xd,yd; m = math 
  xd=hub_x-x; 
  yd=hub_y-y;
  dist = (xd*xd+yd*yd)^0.5;
  new_ang = m.atan2(yd,xd) + rot_ang * 0.017453292 -- + means clockwise, intuitive (PS), (in math + is ccw)
  return hub_x - m.cos(new_ang)*dist, hub_y - m.sin(new_ang)*dist;
end
--

--
function db.recursiveSum(div,rlev) -- divisons per recursion,recursion levels
 local s,i,m
 s,m = 1,1
 for i = 1, rlev, 1 do
  m = m*div
  s = s + m
 end
 return s
end
--

--
-- ... eof Custom Math Functions ...
--

-- *************************************
-- ***     Fractional Scenery        ***
-- *************************************

--
function db.setSceneryPalette()
 db.colorCigarr(10,28,true) -- 250 colors
 setcolor(250, 208,48,48)
 setcolor(251, 48,208,48)
 setcolor(252, 48,48,208)
 setcolor(253, 224,224,64)
 setcolor(254, 224,64,224)
 setcolor(255, 64,224,224)
end
--

--
function db.star(xf,yf,sx,sy,rgb,haz,out,lum)
 local dist,lumdist

 dist = haz + out * ((xf-sx)*(xf-sx) + (yf-sy)*(yf-sy))^0.5;
 lumdist = lum / dist
 return {rgb[1] * lumdist, rgb[2] * lumdist, rgb[3] * lumdist}

end
--

-- Same as db.star but plain r,g,b values as input and output (no array)
-- r,g,b values are fractions 0..1 (luminance (lum) multiple gives final strength)
function db.star2(xf,yf,sx,sy,r,g,b,haz,out,lum)
 local dist,lumdist

 dist = haz + out * ((xf-sx)*(xf-sx) + (yf-sy)*(yf-sy))^0.5;
 lumdist = lum / dist
 return r * lumdist, g * lumdist, b * lumdist

end
--


--
function db.zoom(xf,yf,zoom,panx,pany) -- Zoom and Pan in a fractional coord-system
  xf = (xf-0.5)/zoom + 0.5 + panx;
  yf = (yf-0.5)/zoom + 0.5 + pany;
  return xf,yf
end
--

--[[
-- Just returns a value beteen 0 and 1 ?
function db.twirlOLD(x,y,arms,trot,tpow,tang)
 local b,ang,vx,vy,vr,m,deg,tw
 m=math; deg=math.pi/180; tw=.5; -- 0.5 + sin(0)
 if (not(x==.5 and y==.5)) then
  ang = m.atan((.5-y)/(.5-x)); 
  b = 0; if (x>.5) then b = m.pi; end
  vx = .5-x; vy = .5-y; vr = m.pow(m.sqrt(vx*vx+vy*vy),tpow);
  tw = .5+m.sin(-tang*deg+vr*trot+(ang + b)*arms)*.5;
 end
 return tw;
end
--
--]]

-- Just returns a value beteen 0 and 1 ?
function db.twirl(x,y,arms,trot,tpow,tang)
  local b,ang,vx,vy,vr,m,deg,tw
  m=math; deg=m.pi/180; tw=0.5

  vx = .5-x; vy = .5-y
  if (not(vx==0 and vy==0)) then
   ang = m.atan(vy/vx);  --ang = m.atan2(vy,vx) -- 0/0 = 0, why doesn't atan2 work properly (right half)
   b = 0; if (x>.5) then b = m.pi; end
   vr = (vx*vx+vy*vy)^(tpow*0.5)
   tw = .5+m.sin(-tang*deg+vr*trot+(ang + b)*arms)*.5;
  end

  return tw

end
--

--- Alpha filters
--
function db.alpha1(x,y,amp) -- Coord, Amplify: 0..n
 local p,a,xh,yh,m
 xh=0.5-x; yh=0.5-y; m = math
 p = m.pow(xh*xh+yh*yh,0.7);
 a = m.cos(32*m.pi*p)*m.sin(8*m.pi*(xh+yh));
 return 1 + (a * amp)
end
--

--
-- ... eof Fractional Scenery ...
--

-- *************************************
-- ***    Custom Array Functions     ***
-- *************************************
--
-- Ok, I don't know Lua that well (still unsure about some scopes & refs etc.)
-- And some features may not be active in Grafx2. So, some of the follwing functions
-- may exist in Lua/Grafx2...but since I'm not sure if and how they work - I'll prefer
-- to add a set of my own of known performance.

--
function db.newArrayInit(xs,val) 
  local x,ary; ary = {}
   for x = 1, xs, 1 do
     ary[x] = val
   end
  return ary
end
--


--
function db.newArrayInit2Dim(xs,ys,val) 
  local x,y,ary; ary = {}
  for y = 1, ys, 1 do
   ary[y] = {}
   for x = 1, xs, 1 do
     ary[y][x] = val
   end
  end
  return ary
end
--

--
-- Merge two arrays into a NEW one: array_c = db.newArrayMerge(array_b,array_b) 
--
function db.newArrayMerge(a,b) 
  local n,ary; ary = {}
  for n = 1, #a, 1 do
   ary[n] = a[n]
  end
  for n = 1, #b, 1 do
   ary[n+#a] = b[n]
  end
  return ary
end
--

--
-- Generate a copy of an array with a new value added Last
--
function db.newArrayInsertLast(a,val) 
  local n,ary; ary = {}
  for n = 1, #a, 1 do
   ary[n] = a[n]
  end
  ary[#a+1] = val
  return ary
end
--

--
-- Generate a copy of an array with a new value added First
--
function db.newArrayInsertFirst(a,val) 
  local n,ary; ary = {}
  ary[1] = val
  for n = 2, #a+1, 1 do
   ary[n] = a[n-1]
  end
  return ary
end
--

--
function db.ary2txt(ary) -- One & two dimensions supported [a,b] -> "a,b". [[a,b],[c,d]] -> "a-b, c-d"
 local t,n,m,v
 t = ""
 for n = 1, #ary, 1 do
   if type(ary[n]) == "table" then 
     t = t..ary[n][1]
     for m = 2, #ary[n], 1 do
       t = t.." - "..ary[n][m]
     end
   else t = t..ary[n]; 
   end
   t = t..", "
 end
 return t 
end
--

--
-- *** Array data manipulation ***
--

--
-- InsertionSort Array, this is chaos...I'm confused and stomped...don't understand how Lua works...
-- ...sorting seem be to ok but this code is ugly...
-- Sort LO-HI
--
-- Screwed up or confused thing here I think, perhaps lo-hi/hi-lo. This is working lo-hi but the code
-- looks like hi-lo...edit this some day
-- 
function db.sorti(d,idx) 
   local a,j,tmp,l,e
   l = #d

   for a=2, l, 1 do
    tmp = d[a];
    e = a
    for j=a, 2, -1 do  
      e = j
      if d[j-1][idx] > tmp[idx] then d[j] = d[j-1]; e = j-1; else break; end;
    end;
    d[e] = tmp; -- WHY THE F**K CAN'T YOU READ j HERE!?! STUPID ASSUCKING LANGUAGE 
      
   end;
   return d
end
--

-- Return a lo-hi insertion-sorted copy (and keep original array intact)
function db.sorti_clone(d,idx) 
   local a,j,tmp,l,e,c
   c = {}
   for a=1, #d, 1 do -- Copy array
    c[a] = d[a] 
   end 

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
function db.shuffle(list)
 local i,n,t,floor,rnd
 floor, rnd = math.floor, math.random
 for n = #list, 2, -1 do
  i = 1+floor(rnd() * n)
  t = list[n]; list[n] = list[i]; list[i] = t
 end
end
--

--
function db.cshuffle(list,seed1,seed2) -- Shuffle with custom rnd-function
 local i,n,t,v,floor
 floor = math.floor
 for n = #list, 2, -1 do
  v,seed1,seed2 = db.crnd(seed1,seed2)
  i = 1+floor(v * n)
  t = list[n]; list[n] = list[i]; list[i] = t
 end
end
--

--
-- ... eof Custom Array Functions ...
--


-- *************************************
-- ***   Misc. Logical Operations    ***
-- *************************************

--
-- palList [r,g,b,palindex] is expected only to contain unique colors 
-- index = -1 --> index of list
--
function db.makeIndexList(list,index)
  local n,ilist
  ilist = {}
  for n = 1, #list, 1 do
   if (index > 0) then ilist[n] = list[n][index]; end
   if (index == -1) then ilist[n] = n; end
  end
  return ilist
end
--

--
-- Return a list of all possible (non-same) pairs from the entries in a list 
-- [a,b,c] --> [[a,b],[a,c],[b,c]]
-- (All entries are treated as unique. i.e it's only the INDEX that counts)
-- mode = 0: Only unique pairs (m = (n^2 - n)/2), [a,b] --> [[a,b]]
-- mode = 1: All pairs, i.e mirror versions as well. (m = n^2 - n), [a,b] --> [[a,b], [b,a]]
--
function db.pairsFromList(list,mode)
 local a,b,l,n,pairs
 pairs = {}
 l = #list
 n = 1
 for a = 1, l, 1 do
   for b = a+1, l, 1 do
     pairs[n] = {list[a],list[b]}; n = n + 1
     if mode == 1 then pairs[n] = {list[b],list[a]}; n = n + 1; end
   end
 end
 return pairs
end
--

function db.valueInArray(ary,val)
 local n,res
 res = false
 for n = 1, #ary, 1 do
   if ary[n] == val then res = true; break; end
 end
 return res
end

-- RAMP specific

-- Remove initial pair (palList) colors from pallist
function db.initiateRamp(pair,pallist,pal_index)
  local n,found,plist
  plist = {}

  found = 1 
  for n = 1, #pallist, 1 do
   if db.valueInArray(pair,pallist[n]) == false then
    plist[found] = pallist[n]; found = found + 1;
   end
  end

  pair[pal_index] = plist -- ex: ["pal"]

  return pair -- Is now a 2 color RAMP
end
--

-- Remove new col entry from ramp's pallist and add it to the ramp, returns an updated ramp
-- RampList = [1,2] ["pal"] = palList = [3,4,5], addindex = 3
-- --> [1,2,3] palList = [4,5]
function db.updateRamp(ramp,addindex,pal_index) 
  local n,found,pallist,plist,newramp
  plist = {}
  pallist = ramp[pal_index]

  -- New palList without added color to IndexList
  found = 1 
  for n = 1, #pallist, 1 do
   if pallist[n] ~= addindex then
    plist[found] = pallist[n]; found = found + 1;
   end
  end

  newramp = db.newArrayInsertLast(ramplist,addindex) 
  newramp[pal_index] = plist
 
  return rlist
end

--
-- Returns a list of all inital ramps from color pairs
--
-- Weeds out bad pairs, attaches remaining palette colors and the first rgb-vector
--
--
function db.initiateRampList(pairs,pallist,pal_index,vec_index,min,maxmult,rw,gw,bw) 
 local n,ramplist,newpairs,accept,dist,c1,c2,max,rD,gD,bD
 ramplist = {}
 max = min + (142 / math.sqrt(#pallist)) * maxmult -- min ex: 8-12
 accept = 0

 for n = 1, #pairs, 1 do
  c1 = pallist[pairs[n][1]]
  c2 = pallist[pairs[n][2]]
  rD = c2[1] - c1[1]
  gD = c2[2] - c1[2]
  bD = c2[3] - c1[3]
  dist = math.sqrt( (rw*rD)^2 + (gw*gD)^2 + (bw*bD)^2 ) 

  if dist >= min and dist <= max then
    accept = accept + 1; ramplist[accept] = db.initiateRamp(pairs[n],pallist,pal_index);
    ramplist[accept][vec_index] = {rD, gD, bD, dist}; -- Add first color vector, ONLY KEEP DISTANCE?
  end
 end

 return ramplist
end


function db.findRampExpansionColors(ramp)
 local clist
 clist = {}
 -- Calculate vectors here?
 return clist
end


function db.findRAMPS(min_len, max_len)
 local i,n,c,pallist,ramp,ramplist,pairs,spairs,palindex,vecindex,found,donelist,newlist,dones
 local colorlist
 palindex = "pal"
 vecindex = "vector"
 pallist =  db.fixPalette(db.makePalList(256), 0)
 pairs =    db.pairsFromList(db.makeIndexList(pallist,-1), 0)
 ramplist = db.initiateRampList(pairs,pallist,palindex,vecindex, 8,0.75, 0.26,0.55,0.19) 

 -- MIN_LEN = 5
 -- MAX_LEN = 10

 -- Split Ramp-build into two parts: 
 -- 1. Build ramps >= MIN_LEN, NONE added to 'Done'
 -- 2. Run til no more ramps can be expanded or reaches MAX_LEN, ALL ramps added to 'Done'

 for i = 1, (min_len - 2), 1 do -- Assuming 2 for inital pairs (2 color ramps)
  newlist = {}
  found = 0
  for n = 1, #ramplist, 1 do
    ramp = ramplist[n]
    colorlist = db.findRampExpansionColors(ramp) -- Colors that can split the current ramp into new expanded ramps
    for c = 1, #colorlist, 1 do
     found = found + 1; newlist[found] = db.updateRamp(ramp,colorlist[c],palindex); -- Ramp is expanded by 1 color
    end
  end
  ramplist = newlist
 end


 donelist = {}; dones = 0

 repeat
  newlist = {}
  found = 0
  for n = 1, #ramplist, 1 do
    ramp = ramplist[n]
    if true == false then
     found = found + 1; newlist[found] = db.updateRamp(ramp,color,palindex); 
      else
      dones = dones + 1; donelist[dones] = ramp;
    end
  end
  --ramplist = newlist
 until found == 0

 return #pairs.." - "..#ramplist
end

--
-- ... eof Misc. Logical Operations ...
--


-- *****************************************************
-- *** General RGB-Color Information & Modifications ***
-- *****************************************************


-- return Greatest colorchannel difference ("saturation") as a fraction of 1.
function db.getRGB_maxDelta(r,g,b)
 return (math.max(r,g,b) - math.min(r,g,b))/255 
end
--

-- Gamma adjustment
-- v is (r,g or b) value, max is typically 255
-- exp>1 = Brighter, exp<1 = darker, PS range is 1/10 to 10
function db.gamma(v,max,exp) 
 return max * (v / max) ^ (1/exp)
end
--

--
function db.sRGB_fromLinear(v,exp) 
 local V,q

 exp = exp or 2.4

 V = v / 255

 if V <= 0.04045 then -- sRGB to Linear
    q = 255 * V / 12.92 
     else
      q = 255 * ((V + 0.055) / 1.055) ^ exp
 end
 
 return q
end
--

--
function db.sRGB_toLinear(v,exp) 
 local V,q

 exp = exp or 2.4

 V = v / 255

 if V <= 0.0031308 then -- Linear to sRGB
    q = 255 * V * 12.92 
     else
      q = 255 * (1.055 * V ^ (1 / exp) - 0.055)
 end
 
 return q
end
--


--
function db.negativeRGB(r,g,b) -- Negative/Inverted RGB-values
  r = 255-r
  g = 255-g
  b = 255-b
  return r,g,b
end
--

-- MAKE COMPLEMENTARY COLOR or BEST NEUTRALIZER
-- 
-- brikeeplev: 
-- 1 = loose
-- 2 = strict
-- 3 = neutralizer (complementary color that will mix to a neutral gray with the smallest possible bri-diff. May write a result output to file)
-- The sister function for finding best neutralizer in palette is: db.findBestNeutralizer()
--
function db.makeComplementaryColor(r,g,b,brikeeplev,file_output) -- v2.0. Lev: 0 = Normal, 1 = Loose BriKeep, 2 = Strict BriKeep, 3 = Neutralizer

 local bri_o,bri_n,bdiff,r1,g1,b1,rn,gn,bn,gm,gmr,base,sat,rsat,rt,gt,bt,list,mult,lev,bri,neu,dir,mf,brigam, txt,res

 file_output = file_output or false -- ("neutralizer.txt")

 mf = math.floor

 function cap(v) return math.max(0,math.min(v,255)); end

 bri_o = db.getBrightness(r,g,b)
 r1,g1,b1 = db.shiftHUE(r,g,b,180)

 if brikeeplev > 0  and brikeeplev < 3 then
  list = {1,2,1}
  mult = list[brikeeplev]

  for n = 0, mult*11-1, 1 do -- Must iterate to reduce brightness error (12 steps at least required for Neutralizer at /8*mult)
    bri_n = db.getBrightness(r1,g1,b1)
    --bdiff = (bri_o - bri_n) / 2 * brikeeplev
    bdiff = (bri_o - bri_n) / 8 * mult
     r1 = cap(r1 + bdiff)
     g1 = cap(g1 + bdiff)
     b1 = cap(b1 + bdiff)
  end
 end -- if 


    -- Neutralizer
    --neu = math.max(r,g,b) + math.min(r,g,b)
    --r1 = neu - r
    --g1 = neu - g
    --b1 = neu - b

   if brikeeplev == 3 then -- Create the complementary color that will mix to a neutral gray with the smallest possible bri-diff.

    gm = 2.0 -- Gamma
    gmr = 1 / gm
   
    -- Neutralizer Gamma (Will find a correct mix, but not always the one with least bri-diff)
    neu = math.max(r,g,b)^gm + math.min(r,g,b)^gm
    rn = (neu - r^gm)^gmr
    gn = (neu - g^gm)^gmr
    bn = (neu - b^gm)^gmr
    bri_n = db.getBrightness(rn,gn,bn)

    found = 0
    count = 0

   --messagebox("Ng: "..r1.." "..g1.." "..b1.." Neu: "..neu)
txt = "Gamma = "..gm.."\n"
txt = txt.."Original Color:    ["..r..", "..g..", "..b.."]\n"
txt = txt.."Gamma Neutralizer: ["..mf(rn)..", "..mf(gn)..", "..mf(bn).."]\n"
txt = txt.."Gamma Mix:         ["..mf(((rn^gm+r^gm)/2)^gmr)..", "..mf(((gn^gm+g^gm)/2)^gmr)..", "..mf(((bn^gm+b^gm)/2)^gmr).."]\n"
txt = txt.."Brightness Difference = "..mf(bri_n - bri_o).."\n\n" 

res = "\nCandidates:\n"
    dir = 1; if bri_n > bri_o then dir = -1; end 
    -- Test adjustments from N --> O (less bri-diff), from "bad to good"
    -- This can find all possible complementary options (but may require smaller steps than 1)
    -- We can't break on 1st failure as working comps. may be "scattered" 
    -- (not all bri-adjusts within a working range may produce a correct comp. 
    -- Best is down the list...but not always at the end of the range (ex: x-x-x-3-2-1-x-x (least diff is best))
    -- Note: End of range is not always good - [74,164,255] has legal comps in 23-29 of a 46 color range (with gamma = 2.0) 
    for n = bri_n, bri_o, dir do -- Smaller incr. than 1 may be needed to find all options (but that will produce duplicate results)
count = count + 1
      bri = n
      brigam = bri^gm * 2
      rt = brigam - r^gm 
      gt = brigam - g^gm
      bt = brigam - b^gm
res = res..count..": ["..mf(rt^gmr)..", "..mf(gt^gmr)..", "..mf(bt^gmr).."]"
      if (rt>=0 and mf(rt^gmr)<=255) and (gt>=0 and mf(gt^gmr)<=255) and (bt>=0 and mf(bt^gmr)<=255) then
       r1 = (brigam - r^gm)^gmr 
       g1 = (brigam - g^gm)^gmr 
       b1 = (brigam - b^gm)^gmr
       found = found + 1
  res = res.." \t\tLegal Comp #"..found.." \tBriDiff = "..mf(db.getBrightness(r1,g1,b1) - bri_o)
  res = res.." \tMix: ["..mf(((r1^gm+r^gm)/2)^gmr)..", "..mf(((g1^gm+g^gm)/2)^gmr)..", "..mf(((b1^gm+b^gm)/2)^gmr).."]"
       else
        --messagebox("Bri Adjusted?".."Dir = "..dir.." Found Comps: "..found)
        --break
      end  
res = res.."\n" 
    end

  -- Is original Gamma Neutralizer the best option?
  if math.abs(db.getBrightness(r1,g1,b1) - bri_o) > math.abs(bri_n - bri_o) then
   r1,g1,b1 = rn,gn,bn
   txt = txt.."Original Neutralizer is best option!\n\n"
  end

  --messagebox(count.." Found: "..found)
  txt = txt.."Range Examined:              "..count.."\n" 
  txt = txt.."Complimentary options found: "..found.."\n" 
  txt = txt.."* Best Neutralizer found:     ["..mf(r1)..", "..mf(g1)..", "..mf(b1).."]\n"
  txt = txt.."* Gamma Mix:                  ["..mf(((r1^gm+r^gm)/2)^gmr)..", "..mf(((g1^gm+g^gm)/2)^gmr)..", "..mf(((b1^gm+b^gm)/2)^gmr).."]\n"
  txt = txt.."* Brightness Difference = "..mf(db.getBrightness(r1,g1,b1) - bri_o).."\n"


  if file_output then
   f = io.open("neutralizer.txt", "w");
   f:write(txt..res) 
   f:close()
  end

 end -- brikeeplev == 3 then

 return r1,g1,b1

end
--


-- *** Color balance (now possible to limit effects to given hue/bri regions) ***
--
-- bri_flag:   Preserve brightness
-- loose_flag: Loose preservation restrictions for brightness and balance
--
-- Jeez, was this a tricky sucker; color-balance is just adding and capping...
-- but trying color-balance with preserved perceptual brightness is a different monster...
-- ...so bad I could only solve it by iterative error correction.
--
function db.ColorBalance(r,g,b,rd,gd,bd,bri_flag,loose_flag) -- preserve brightness
 local ri,gi,bi,itot,rni,gni,bni,ro,go,bo,ovscale,lev,count,rt,gt,bt,rf,gf,bf,bri,m,min,max,abs

 min,max,abs = math.min, math.max, math.abs
 
 bri = db.getBrightness(r,g,b)

 -- Loose brightness & balance preservation, a good compromise.
 if bri_flag == true and loose_flag == true then

   lev = (rd + gd + bd) / 3
   rd = rd - lev
   gd = gd - lev
   bd = bd - lev

   brin = db.getBrightness(db.cap(r+rd),db.cap(g+gd),db.cap(b+bd))
   itot = brin - bri
   rd = rd - itot
   gd = gd - itot
   bd = bd - itot

 end


 if bri_flag == true and loose_flag == false then

  itot = 255
  count = 0

   -- Normalize (Yup, it's right only to normalize once first..cont.norm. will have some counter-effect)
  lev = (rd + gd + bd) / 3
  rd = rd - lev
  gd = gd - lev
  bd = bd - lev

 repeat

  --messagebox("Norm:"..rd..", "..gd..", "..bd)

  -- Calculate total brightness change
  -- Note: Perceptual Brightness is exponential, and can't be delta-adjusted for anything other than greyscales.
  -- Although the formula for the new brightness corrected normalization level can can be derived...
  -- ...it doesn't do much good since the bigger problem is overflow outside the 0-255 boundary.
  -- As for now, I see no other means to solve this issue than with iterative error-correction.

  rt = r+rd 
  gt = g+gd
  bt = b+bd
 
  itot = 9e99
  rni = rd 
  gni = gd 
  bni = bd
 
  -- We can get brightness of negative values etc. So bri-correction is put on hold until values are scaled down
  if (rt>=0 and gt>=0 and bt>=0) and (rt<256 and gt<256 and bt<256) then
    brin = db.getBrightness(rt,gt,bt)
    itot = brin - bri
    --messagebox("Bri Diff: "..itot)
    -- Brightness adjusted balance
     rni = rd - itot
     gni = gd - itot
     bni = bd - itot
  end

  --messagebox("Bri Adj Bal:"..rni..", "..gni..", "..bni)

   -- Apply balance to find overflow (as fraction of the channel change)
   ro = max( max((r + rni)-255,0), abs(min((r + rni),0)) ) / max(abs(rni),1)
   go = max( max((g + gni)-255,0), abs(min((g + gni),0)) ) / max(abs(gni),1)
   bo = max( max((b + bni)-255,0), abs(min((b + bni),0)) ) / max(abs(bni),1)

  ovscale = 1 - max(ro,go,bo)

  -- Scaling balances might be logically incorrect (as they can be seen as constant differences)
  -- But scaling DOWN is quite harmless and I don't see how it could be done otherwise...
  -- ex: +10 red, +5 blue: Scale x2   = +20 red, +10 blue -> More red over blue than ordered, a contrast behaviour.
  --     +10 red, +5 blue: Scale x0.5 = +5 red, +2.5 blue -> Less of everything, but a part of the order. Harmless?
  --
  rd = rni * ovscale
  gd = gni * ovscale  
  bd = bni * ovscale

  count = count + 1 

  --messagebox("Final bal:"..rd..", "..gd..", "..bd)

 until abs(itot) < 1 or count > 5

 end 

 rf = r + rd
 gf = g + gd
 bf = b + bd

 --messagebox("Result color:"..rf..", "..gf..", "..bf)

 return rf,gf,bf
end
--


--
function db.getContrast(ch) -- Channel, returns fraction -1..0..1, negative for ch < 127.5
 --return math.abs((ch / 127.5) - 1)
 return (ch / 127.5) - 1 
end
--

--
function db.getAvgContrast(r,g,b)
 return (math.abs(db.getContrast(r)) + math.abs(db.getContrast(g)) + math.abs(db.getContrast(b))) / 3   
end
--

--
-- Mode = 0: Proportional - all colors reach max contrast at 100%
--
-- Mode = 1: Linear - percentage simply added
-- 
function db.changeContrastOLD(r,g,b,prc,mode)

 local m,rd,gd,bd,rv,gv,bv,rc,gc,bc,base,sign

 base = 1; sign = 1
 if prc < 0 then base = 0; sign = -1; end -- decontrast

 m = prc / 100 * sign

 -- mode 0 
 rc = db.getContrast(r)
 rd = (base - math.abs(rc)) * m  * db.sign(rc)
 rv = (rc+rd+1) * 127.5

 gc = db.getContrast(g)
 gd = (base - math.abs(gc)) * m  * db.sign(gc)
 gv = (gc+gd+1) * 127.5

 bc = db.getContrast(b)
 bd = (base - math.abs(bc)) * m  * db.sign(bc)
 bv = (bc+bd+1) * 127.5

 return rv,gv,bv

end
--

function db.changeContrast(r,g,b,prc) -- Photoshop style, v2.0 (Linear until 90%)

 local m,rd,gd,bd,rv,gv,bv,rc,gc,bc


 --m = 1 + math.pow((255 / 100 * prc),3) / (255*255)

 
 if prc>=0 and prc<=90 then
  m = 1 + 3 * prc / 90
 end

 if prc>90 and prc<=100 then
  m = 4 + 252 * ((prc-90) / 10)^2
 end
 

 -- decontrast
 if prc < 0 then
  m = 1 - math.abs(prc)/100
 end 
  
 rc = db.getContrast(r)
 rd = rc * m 
 rv = (rd+1) * 127.5

 gc = db.getContrast(g)
 gd = gc * m 
 gv = (gd+1) * 127.5

 bc = db.getContrast(b)
 bd = bc * m 
 bv = (bd+1) * 127.5

 return db.rgbcaps(rv,gv,bv)

 --return rv,gv,bv

end




 -- Get Brightness OLD stuff

 --bri = r*0.3 + g*0.59 + b*0.11 -- Luma Y'601
 --bri = r*0.245 + g*0.575 + b*0.18 -- Dawn 2.0

 ---return math.sqrt((r*0.26)^2 + (g*0.55)^2 + (b*0.19)^2) * 1.5690256395005606 -- Dawn 3.0 
 
 --return (r*0.0676 + g*0.3025 + b*0.0361) * 1.5690256395005606
 --return ((r*0.2126)^2.2 + (g*0.7152)^2.2 + (b*0.0722)^2.2)^(1/2.2) * 1.352554611
 --return ((r*0.26)^2.2 + (g*0.55)^2.2 + (b*0.19)^2.2)^(1/2.2) * 1.62

--
-- optimized (weights 0.26, 0.55, 0.19), ..606 is required to get 255
--
function db.getBrightness(r,g,b) -- 0-255
 
  return math.min(255,(r*r*0.0676 + g*g*0.3025 + b*b*0.0361)^0.5 * 1.5690256395005606)
 
end
--


-- 0..1
function db.getBrightnessFrac(r,g,b)
 return db.getBrightness(r,g,b) / 255
end
--

-- Make grayscale
-- Correct and best desaturation method (gamma correction default of 2.0 (only has an impact at <100%))
function db.desaturateBri(percent,r,g,b,gam) -- This function added Jan 2015 (it exists hardcoded in many scripts since many years)
  local p,q,w,rgam
  gam = gam or 2.0
  rgam = 1 / gam
  p = percent / 100
  q = 1 - p
  a = db.getBrightness(r,g,b)^gam
  w = a * p
  r = (r^gam * q + w)^rgam
  g = (g^gam * q + w)^rgam 
  b = (b^gam * q + w)^rgam
  return r,g,b
end

-- Correct and best desaturation method
function db.desaturateBri_A(percent,c) -- list/array version (hardcoded gamma of 2.0)
  local p,q,w,r,g,b,gam,rgam
  gam = 2.0
  rgam = 1 / gam
  r = c[1]
  g = c[2]
  b = c[3]
  p = percent / 100
  q = 1 - p
  --if r<0 then messagebox("R is negative!"); end
  a = db.getBrightness(r,g,b)^gam
  w = a * p
  r = (r^gam * q + w)^rgam 
  g = (g^gam * q + w)^rgam
  b = (b^gam * q + w)^rgam
  return {r,g,b}
end

--
-- Note on desaturation: These functions are all junk, the only way to desaturate
--                       is to fade a color into its corresponding greyscale.
--

--
function db.desaturate(percent,r,g,b) -- HSL ?
 local a,p
 p = percent / 100
 a = (math.min(math.max(r,g,b),255) + math.max(math.min(r,g,b),0)) * 0.5 * p
 r = r + (a-r*p) -- a+r*(1-p)
 g = g + (a-g*p)
 b = b + (a-b*p)
 return r,g,b
end
--

--
function db.desaturateA(percent,c) -- array version
 local r,g,b,a
 r = c[1]
 g = c[2]
 b = c[3]
 p = percent / 100
 a = (math.min(math.max(r,g,b),255) + math.max(math.min(r,g,b),0)) * 0.5 * p
 r = r + (a-r*p)
 g = g + (a-g*p)
 b = b + (a-b*p)
 return {r,g,b}
end
--

--
function db.desatAVG(desat,c) -- Desaturation, simple average
 local r,g,b
 r = c[1]
 g = c[2]
 b = c[3]
 p = desat / 100
 a = (r+g+b)/3
 r = r + p*(a-r) 
 g = g + p*(a-g)
 b = b + p*(a-b) 
 return {r,g,b}
end
--

--
-- Absolute Saturation: 
-- Fraction of distance between a color's brightness (grayscale eq.) and its maximum saturation.
-- Very close to HSL, but more curved than linear

--
function db.getSaturationAbs(r,g,b) -- Iteratively find the value
 local rw,gw,bw,bri,ar,ag,ab,qr,qg,qb,failsafe,d_bri,d_max,abs_sat,div,failmax
 --rw,gw,bw = 0.26, 0.55, 0.19
 rw,gw,bw = 1,1,1
 div = 256
 failsafe = 0
 failmax = div*500 -- seem like we need a large value (250 failed at image:Sara256)
 --bri = db.getBrightness(r,g,b)
 bri = (r+g+b) / 3
 ar,ag,ab = (r-bri)/div,(g-bri)/div,(b-bri)/div
 d_bri = db.getColorDistance_weight(r,g,b,bri,bri,bri,rw,gw,bw) -- just to have any 3d distance, we work with fractions here
 qr,qg,qb = r,g,b

 abs_sat = 0
 if not(r == g and r == b) then

  while ((qr>0 and qr<255) and (qg>0 and qg<255) and (qb>0 and qb<255) and failsafe<failmax) do
   failsafe = failsafe + 1
   qr = qr + ar
   qg = qg + ag
   qb = qb + ab
  end

  d_max = db.getColorDistance_weight(r,g,b,qr,qg,qb,rw,gw,bw) 
  abs_sat = d_bri / (d_bri + d_max)

 end

 --if failsafe == failmax then messagebox("Get Absolute Saturation Failure! "..abs_sat); end

 return abs_sat -- Fraction of 1
end
--

--
function db.getSaturationAbs_255(r,g,b)
 return db.getSaturationAbs(r,g,b) * 255
end
--

-- HSV/HSB 0..1
function db.getSaturationHSV(r,g,b) 
 local M,m,c
 M = math.max(r,g,b)
 m = math.min(r,g,b)
 c = M-m
 if c ~= 0 then return c/M else return 0; end
end
--

--
function db.getSaturationHSV_255(r,g,b)
 return db.getSaturationHSV(r,g,b) * 255
end
--

--
function db.getSaturation(r,g,b) -- HSL
  local M,m,c,s,l
  M = math.max(r,g,b)
  m = math.min(r,g,b)
  c = (M - m)/255
  s = 0
  if c ~= 0 then
    --l = (0.3*r + 0.59*g + 0.11*b)/255 -- HSLuma: Y'601
    l = (M+m)/510 -- This produces a quite "correct looking" divison of saturation
    if l <= 0.5 then s = c / (2*l); end
    if l  > 0.5 then s = c / (2-2*l); end
  end
  s = math.ceil(s * 1000) * 0.001 -- Rounding issue
  return math.min(255,s * 255)
end
--

--
db.getSaturationHSL_255 = db.getSaturation
--

--
function db.getSaturationHSL(r,g,b)
 return db.getSaturation(r,g,b) / 255
end
--

--
-- Adjusting true by max value will produce a result fairly similar to Purity
function db.getTrueSaturationX(r,g,b) -- Distance from grayscale axis. Not HSV/HSL 
 local sat,bri
 bri = (r+g+b) / 3
 sat = math.min(255, math.sqrt((r-bri)^2 + (g-bri)^2 + (b-bri)^2) * 1.224744875) -- / math.max(r,g,b) * 255
 return sat
end
--


-- Should be deactivated
-- WIP. Trying to find a more natural model for estimating Saturation
-- Current: (HSL + True) / 2
function db.getAppSaturation(r,g,b)
  return  math.min(255, (db.getSaturation(r,g,b) + db.getTrueSaturationX(r,g,b)) / 2)
end
--


-- WIP. Trying to find a more natural model for estimating Saturation
-- Current: (Absolute * True)^0.5, returns fraction of 1
function db.getRealSaturation(r,g,b)
  return  math.min(1, (db.getSaturationAbs(r,g,b) * db.getTrueSaturationX(r,g,b)/255)^0.5)
end
--

--
function db.getRealSaturation_255(r,g,b)
 return db.getRealSaturation(r,g,b)*255
end
--

--
function db.saturate(percent,r,g,b) 
  local a,m,p,mc
  a = (math.min(math.max(r,g,b),255) + math.max(math.min(r,g,b),0)) * 0.5
  m = math.min(255-math.max(r,g,b), math.min(r,g,b))
  p = percent * (m / 100)
  mc = math.max((r-a),(g-a),(b-a)) -- Can this be derived elsewhere?
  if mc ~= 0 then
   r = r + (r-a) * p / mc
   g = g + (g-a) * p / mc
   b = b + (b-a) * p / mc
  end
  return r,g,b
end
--

--
-- Super Saturate: Better than Photoshop etc.
--
-- Higher than 100% power is ok 
--
function db.saturateAdv(percent,r,g,b,brikeeplev,greydamp) -- brikeep = 0 - 2 
  local a,m,p,mc,bri_o,bri_n,bdiff,mx,mi,adj,q,n,cap
   function cap(v) return math.max(0,math.min(v,255)); end
  mx = math.max(r,g,b)
  mi = math.min(r,g,b)
  bri_o = db.getBrightness(r,g,b)
  a = (math.min(mx,255) + math.max(mi,0)) * 0.5
  m = math.min(255-mx, mi)
  p = percent * (m / 100)
  mc = math.max((r-a),(g-a),(b-a)) -- Can this be derived elsewhere?
  if mc ~= 0 and m ~= 0 then
   adj = math.min(1,(mx - mi) / m) -- Reduce effect on low saturation
   if greydamp == false then adj = 1; end
   q = p / mc * adj
   r = cap( r + (r-a) * q )
   g = cap( g + (g-a) * q )
   b = cap( b + (b-a) * q )
  end
  for n = 0, brikeeplev*2, 1 do -- Must iterate to reduce brightness error
    bri_n = db.getBrightness(r,g,b)
    bdiff = (bri_o - bri_n) / 2 * brikeeplev
    r = cap(r + bdiff)
    g = cap(g + bdiff)
    b = cap(b + bdiff)
  end
  return r,g,b
end
--

-- "Primarity" is the closeness to a colorcube-corner and distance to the grayscale-axis, a form of Saturation.
-- If the parameter [c = 0..1] is 1 then secondary colors Yellow, Cyan & Magenta are considered Primary colors,
-- if the value is 0 then only Red, Green & Blue are Primary and Yellow, Cyan & Magenta become grayscales.
-- Ex: c = 0.75 means Yellow, Cyan & Magenta are considered 75% as Primary as Red, Green & Blue
--
-- purity_flag: (Purity Mode) Normally a darker color will have less Primarity even if it's a pure hue (Ex: [63,0,0] = 25% Primarity)
--              With purity_flag active Primarity is relative to the strongest color-channel. That is,
--              all colors (except black) in a ramp from black to red will be given 100% Primarity.
--              This mode represents an effective Saturation/Purity evaluation method.
--              Purity is quite close to the HSV-model, major difference is that tertiary colors, such as violet,
--              will have a magnitude of 75% in Purity but 100% in HSV.
--
function db.getPrimarity(r,g,b, c, purity_flag) -- 0..1
 local mx,mn,md,p,scale,ceil

 c = c or 1

 purity_flag = purity_flag or false

 mx,md,mn = r,g,b

 if g > r then mx,md = g,r; end
 if b > md then md,mn = b,md; end
 if md > mx then mx,md = md,mx; end

 if purity_flag and mx > 0 then
  ceil = math.ceil
  scale = 255 / mx; mx = mx * scale; md = md * scale; mn = mn * scale
  mx = ceil(mx * 1000) * 0.001 -- Rounding issue
  md = ceil(md * 1000) * 0.001
  mn = ceil(mn * 1000) * 0.001
 end

 p = ((mx-md) + ( (255-(mx-md))/255 * (md-mn) ) * c) / 255

 return p

end
--

--
function db.getPurity(r,g,b)
 return db.getPrimarity(r,g,b, 1, true)
end
--

--
function db.getPurity_255(r,g,b)
 return db.getPrimarity(r,g,b, 1, true) * 255
end
--


--
function db.getPrimarity_255(r,g,b)
 return db.getPrimarity(r,g,b, 1, false) * 255
end
--

--
-- Lightness: Darken / Brighten color (Argument and returnvalue is a rgb-list)
--            Rate of change is inversely proportional to the distance of the max/min. 
--            i.e. all colors/channels will reach max/min at the same time (at 0 or 100 %)
--            (As opposed to 'Brightness' where all channels are changed by a constant value)
--
-- This is the same as Lightness modifier in PS, but NOT the result of changing Lightness in HSL-space
--
function db.lightness(percent,c)
 local v,r,g,b,p
 r = c[1]
 g = c[2]
 b = c[3]
 p = math.abs(percent/100)
 v = 255
 if percent < 0 then v = 0; end
 r = r + (v - r)*p
 g = g + (v - g)*p 
 b = b + (v - b)*p
 return {r,g,b}
end
--

--
function db.changeLightness(r,g,b,percent)
 local v
 v = db.lightness(percent,{r,g,b})
 return v[1],v[2],v[3]
end
--

--
function db.getLightness(r,g,b) -- HSL bi-hexcone
  return (math.max(r,g,b) + math.min(r,g,b)) / 2
end
--

--
function db.shiftHUE(r,g,b,deg) -- V1.3 R.Fhager 2007, (Heavily derived code, hehe...)
 local c,h,mi,mx,d,s,p,i,f,q,t,m
 m = math
 c = {g,b,r}
 mi = m.min(r,g,b)
 mx = m.max(r,g,b); v = mx;
 d = mx - mi;
 s = 0; if mx ~= 0 then s = d/mx; end
 p = 1; if g ~= mx then p = 2; if b ~= mx then p = 0; end; end
 
 if s~=0 then
  h=(deg/60+(6+p*2+(c[1+p]-c[1+(p+1)%3])/d))%6; 
  i=m.floor(h);
  f=h-i;
  p=v*(1-s);
  q=v*(1-s*f);
  t=v*(1-s*(1-f));
  c={v,q,p,p,t,v}
  r = c[1+i]
  g = c[1+(i+4)%6]
  b = c[1+(i+2)%6]
 end

 return r,g,b
end
--

--
function db.getHUE(r,g,b,greytol) -- 0-6 (6.5 = Greyscale), mult. with 60 for degrees
 -- 1 Color diff is roughly detected by Tolerance = 0.0078125 (Tol. incr. with lightness etc.)
 local c,h,mi,mx,d,s,p,i,f,q,t
 c = {g,b,r}
 mi = math.min(r,g,b)
 mx = math.max(r,g,b); v = mx;
 d = mx - mi;
 s = 0; if mx ~= 0 then s = d/mx; end
 p = 1; if g ~= mx then p = 2; if b ~= mx then p = 0; end; end

 h = 6.5 -- for custom graphical purposes
 if s>greytol then -- can't use >=
  h=(6+p*2+(c[1+p]-c[1+(p+1)%3])/d)%6; 
 end

 return h
end
--

-- Hue-Saturation distance (Conceptual d = hue_delta * min(sat1,sat2) + abs(sat_delta)/2)
-- Input: 
-- Hue: 0-6  (1 = 60 degrees. Values for grayscale doesn't matter as it's multiplied with 0 saturation)
-- Sat: 0..1 (fraction of 1, 1 = 100%)
-- Output: 0..1, fraction of maximum distance, ex distance full Red/full Cyan = 1.0 
function db.getHueSatDistanceC(h1,s1,h2,s2)
 local hd,hf
 hd = math.abs(h1-h2)
 hf = math.min(hd,6-hd) / 3
 return hf*math.min(s1,s2) + math.abs(s1-s2)/2 
end

--
function db.getHSB(r,g,b) -- Mostly for use with HSB regions pencolor values fetching
 local hue, bri, sat
 hue = db.getHUE(r,g,b,0) * 60          -- 0-359
 bri = db.getBrightness(r,g,b)          -- 0-255 
 --sat = db.getSaturationAbs(r,g,b) * 100 -- 0-100% Note: This is NOT Saturation of the HSL Model!
 sat = db.getPurity(r,g,b) * 100
 return hue,bri,sat
end
--

--
function db.HSLtoRGB(h,s,l) -- input as fractions of 1, output as regular values (0-255)
 local C,X,H,A,M,rgb,r,g,b
 if s >0 and h <= 1.0 then -- Hue 6.5 = grayscale, fraction = 1.08
  --messagebox (h..", "..s..", "..l)
   C = (1-math.abs(2*l - 1)) * s
   H = h * 6 -- 0..5.99
   X = C * (1-math.abs(H % 2 - 1))
   A = {{C,X,0},{X,C,0},{0,C,X},{0,X,C},{X,0,C},{C,0,X}}
   M = l - C/2
   rgb = A[1 + math.floor(H)]
   return (rgb[1]+M)*255,(rgb[2]+M)*255,(rgb[3]+M)*255
   else 
     return l*255,l*255,l*255;
 end
end
--

--
   -- HSB REGIONS - effect reduction on areas distancing from ideal HSB values (centres).
   -- return a fraction of how close to Hue,Brightness,Saturation(Purity) regions a color is (Hf * Bf * Sf)
   -- hue/bri/sat: -1 = not considered
   -- Used by operators like ColorBalance & Hue-Lightness to allow (gradient) changes to more specific colorspace areas
   -- hue_cnt: center in degrees (-1 = off)
   -- bri_cnt: center 0-255 (-1 = off)
   -- set_cnt: center 0-100% (-1 = off)
   -- r,g,b: (palette) color to access
   -- wid: width/size of region: 1-100% (f.ex at 100% the effect will range from 100 to 0 % across the entire colorspace)
   -- Note: Using a fractions on RGB values rather than recalculating Hue-values from degrees causes a desaturating effect in
   -- the outer regions of the range. Although this is only apparent with large Hue-shifts (+90 degrees). So for now we keep this.
   -- Besides, this can be an effect in itself.
   function db.HSB_regions(hue_cnt,bri_cnt,sat_cnt,r,g,b,wid) 

    local cnt,hwid,hue,bri,sat,dist
    local hue_factor,bri_factor,sat_factor
    
    hue_factor = 1
    bri_factor = 1
    sat_factor = 1

     -- Hue
    cnt = -1 -- Hue Center 0 = red, 2 = green, 4 = blue, 6 = grey, -1 = off
    hwid = 2 -- just set a default 120 degrees
    if hue_cnt ~= null and wid ~= null and hue_cnt ~= -1 then
     cnt = math.min(math.max(0,hue_cnt),360) / 60
     hwid = math.min(math.max(0,wid),100) * 0.06 -- convert % to 1/60 degrees
    end
    --

    -- cnt: hue center (0-5.999, 6 = Grey, -1 = off)
    -- wid: effect width (0-6, 1 = 60 degrees)
    --db.getHUE(r,g,b,greytol) -- 0-6 (6.5 = Greyscale), mult. with 60 for degrees
    -- hwid is 0-6
    if cnt ~= -1 then
      hue_factor = 0; if cnt == 6 then hue_factor = 1; end -- Grayscales (for when saturation isn't used (Hue = 360))
      hue = db.getHUE(r,g,b,0)
      if hue < 6 then -- we don't deal with greys here...
       --dist = math.min(math.abs(hue - cnt), math.abs((hue-6) - cnt))
      dist = math.min(math.abs(hue - cnt), (math.min(hue,cnt) + 6 - math.max(hue,cnt)))
      if dist < hwid then
       hue_factor = (1 - dist / hwid)
      end
     end
    end
    ------ hue region
  
    -- bri region
    if bri_cnt ~= - 1 then
     bri_factor = 0
     bri = db.getBrightness(r,g,b)
     dist = (math.abs(bri_cnt - bri) / 256) -- 0..1
     bri_factor = math.max(0, 1 - (dist / (wid * 0.01)))
    end
    --

    -- sat region WE MUST USE THE SAME ALGO FOR getHSB() AS WE DO HERE! 
    if sat_cnt ~= - 1 then
     sat_factor = 0
     --sat = db.getSaturationAbs(r,g,b)
     --sat = db.getRealSaturation(r,g,b)
     sat = db.getPurity(r,g,b)
     dist = math.abs(sat_cnt/100 - sat)  -- 0..1
     sat_factor = math.max(0, 1 - (dist / (wid * 0.01)))
    end
    --

   return hue_factor, bri_factor, sat_factor

 end -- HSB_regions
 --



   --
   -- Edit Regions (centre effect in desired hue/bri/sat registers)
   --
   -- This is the application function for any script using HSB-regions
   --
   function db.editHSBregions(ro,go,bo,rn,gn,bn, amount, hue_center, bri_center, sat_center, edit_width, gamma)
    local rf,gf,bf,gamma,rgam,np,op, hue_factor, bri_factor, sat_factor

    gamma = gamma or 2.2
    rgam = 1 / gamma

    -- Returns 1 for each inactive factor
    hue_factor, bri_factor, sat_factor = db.HSB_regions(hue_center, bri_center, sat_center, ro,go,bo, edit_width) 
    np = hue_factor * bri_factor * sat_factor * amount
    op = 1 - np

    rf = (ro^gamma*op + rn^gamma * np)^rgam
    gf = (go^gamma*op + gn^gamma * np)^rgam
    bf = (bo^gamma*op + bn^gamma * np)^rgam

    return rf,gf,bf  

   end
   --

------------------- eof HSB-regions



--
function db.multiply(r,g,b,factor,taper_flag,curve) -- "Division" factor < 1 is the same operator as Lightness (reduction)
 
 -- _l = 1 - _f2 + _f1 * _f2 

 if taper_flag and factor>1 and curve ~= nil then -- Reduce effect as colors approach full value
  --factor = 1 + (factor-1) * (1 - math.max(r,g,b)/255
  r = curve[r+1]
  g = curve[g+1]
  b = curve[b+1]
   else  
     r = r * factor
     g = g * factor
     b = b * factor
 end

 return r,g,b
end
--


--
-- ... eof RGB color modifications ...
--


-- ****************************************
-- *** Color Applications (/ Blend Modes) ***
-- ****************************************

---
-- Alpha functions (From full strength to zero)

function db.alpha_Horizontal(xf,yf) -- Left-Right
 return 1-xf
end

function db.alpha_Vertical(xf,yf) -- Top-Bottom
 return 1-yf
end

function db.alpha_Radial(xf,yf) -- Center-Out
 return 1 - math.min(1,2 * math.sqrt((xf-0.5)*(xf-0.5) + (yf-0.5)*(yf-0.5)))
end

function db.alpha_Diagonal_TL(xf,yf) -- TopLeft-BottomRight 
 return ((1-xf)+(1-yf))/2
end

function db.alpha_Diagonal_BL(xf,yf) -- BottomLeft-TopRight 
 return ((1-xf)+yf)/2
end


--
-- ... eof Color Applications (/ Blend Modes) ...
--


-- *************************************************
-- *** Custom Palette List Creation & Operations ***
-- *************************************************


--# of Unique colors in palette:
--#db.fixPalette(db.makePalList(256))

--# of Colors in Image:
--#db.makePalListFromHistogram(db.makeHistogram())

--# of Unique colors in Image:
--#db.fixPalette(db.makePalListFromHistogram(db.makeHistogram()))


--
function db.makePalList(cols)
 local pal,n,r,g,b
 pal = {}
 for n = 0, cols-1, 1 do
   r,g,b = getcolor(n)
   pal[n+1] = {r,g,b,n}
 end
 return pal
end
--

--
function db.makeSparePalList(cols)
 local pal,n,r,g,b
 pal = {}
 for n = 0, cols-1, 1 do
   r,g,b = getsparecolor(n)
   pal[n+1] = {r,g,b,n}
 end
 return pal
end
--

--
-- Use to remove the black colors (marks unused colors) from palette-list
-- if it's known that no black color exists in the image.
function db.stripBlackFromPalList(pallist)
   local i,u,c,dummy; i = 257 -- Do 'nothing' If using a full 256 col palette with no blacks
   for u = 1, #pallist, 1 do
     c = pallist[u]
     if (c[1]+c[2]+c[3]) == 0 then i = u; end
   end
   dummy = table.remove(pallist,i)
   return pallist
end
--

--
function db.stripIndexFromPalList(pallist,colindex)
   local i,u,c,dummy
   i = -1
   for u = 1, #pallist, 1 do
     c = pallist[u]
     if c[4] == colindex then i = u; end
   end
   if i ~= -1 then dummy = table.remove(pallist,i); end
   return pallist
end
--

--
function db.strip_RGB_FromPalList(pallist,r,g,b)
   local i,u,c,newlist,count
   newlist = {}

   newlist["assigns"] = pallist["assigns"] -- If doubles are undefined (fixPalette hasn't been applied) it won't cause a problem 
   newlist["doubles"] = pallist["doubles"]
   newlist.double_total = pallist.double_total

   count = 0
   for u = 1, #pallist, 1 do
     c = pallist[u]
     if not(c[1]==r and c[2]==g and c[3]==b) then
       count = count + 1; newlist[count] = pallist[u]
     end -- if
   end -- u
   return newlist
end
--

-- Add to Palette: Hue, Saturation and Brightness, perceptual (Not HSL)
-- This data is supposed to be used for Reading & HSB-colormatching, not anything strictly concering the HSL-model 
-- f_sat: optional argument for custom Saturation function, return value 0..255. (Default Real is using the iterative, and sometimes very slow Abs)
function db.addHSBtoPalette(pallist, f_sat)
 local n,hue,sat,rgb,satfunc,t

 t = ""
 if f_sat == null then t = " (Enabling Purity by default)"; end
 --messagebox("Adding HSB to palette"..t)

 --satfunc = f_sat or db.getRealSaturation_255 -- -- (True * Absolute)^0.5
 --satfunc = f_sat or db.getSaturation
 --satfunc = f_sat or db.getSaturationHSV_255
 satfunc = f_sat or db.getPurity_255
 for n=1, #pallist, 1 do
   rgb = pallist[n]
   pallist[n][5] = db.getHUE(rgb[1],rgb[2],rgb[3],0)
   --pallist[n][6] = db.getSaturation(rgb[1],rgb[2],rgb[3])
   pallist[n][6] = satfunc(rgb[1],rgb[2],rgb[3]) 
   pallist[n][7] = db.getBrightness(rgb[1],rgb[2],rgb[3])
 end
 return pallist -- {r,g,b,n,hue,sat,bri}
end
--

--
-- Add UnNormalized (Dawn3.0) Brightness to Palette-list.
-- For use with comparisons. Ex. db.getBestColorMatch_Hybrid
--
function db.addUnNormalizedBrightness2Palette(pallist)
  local n,rgb,r,g,b
  for n=1, #pallist, 1 do
   rgb = pallist[n]
   r,g,b = rgb[1],rgb[2],rgb[3]
   pallist[n][8] = (r*r*0.0676 + g*g*0.3025 + b*b*0.0361)^0.5
  end
  return pallist -- {r,g,b,n,(hue),(sat),(bri), unbri}
end
--

--
function db.makePalListRange(start,ends)
 local pal,n,r,g,b,a
 pal = {}
 a = 1
 for n = start, ends, 1 do
   r,g,b = getcolor(n)
   pal[a] = {r,g,b,n}; a = a + 1;
 end
 return pal
end
--


--
function db.makePalListShade(cols,sha) -- Convert colors to less bits, colorcube operations etc.
 local pal,n,r,g,b,mf,div
 mf = math.floor
 div = 256 / sha
 pal = {}
 for n = 0, cols-1, 1 do
   r,g,b = getcolor(n)
   pal[n+1] = {mf(r/div),mf(g/div),mf(b/div),n}
 end
 return pal
end
--
-- From a pallist so unwanted colors can be pre-stripped
function db.makePalListShade_fromPalList(sha,pallist) -- Convert colors to less bits, colorcube operations etc.
 local pal,n,r,g,b,c,mf,div
 mf = math.floor
 div = 256 / sha
 pal = {}
 for n = 1, #pallist, 1 do
   c = pallist[n]
   pal[n] = {mf(c[1]/div),mf(c[2]/div),mf(c[3]/div),c[4]}
 end
 return pal
end
--
--
function db.makePalListShadeSPARE(cols,sha) -- Convert colors to less bits, colorcube operations etc.
 local pal,n,r,g,b,mf,div
 mf = math.floor
 div = 256 / sha
 pal = {}
 for n = 0, cols-1, 1 do
   r,g,b = getsparecolor(n)
   pal[n+1] = {mf(r/div),mf(g/div),mf(b/div),n}
 end
 return pal
end
--


--
-- Used by PaletteAnalysis.lua, FindRamps(), MixColors() etc.
-- Assigns is used by ApplySpare script
--
function db.fixPalette(pal,sortflag) -- Arrange palette & only keep unique colors

 local n,l,rgb,i,unique,bri,hue,sat,ulist,indexpal,newpal,dtot
 ulist = {}
 indexpal = {}
 newpal = {}
  local doubles,assign 
  doubles = {}; assign = {}

 l = #pal

 unique = 1 -- ok, see how stupid lua is
 dtot = 0
 for n=1, l, 1 do
   rgb = pal[n]; -- actually rgbn
   i = 1 + rgb[1] * 65536 + rgb[2] * 256 + rgb[3];
   bri = db.getBrightness(rgb[1],rgb[2],rgb[3])
   if indexpal[i] == nil then 
      indexpal[i] = rgb; ulist[unique] = {i,bri}; unique = unique+1;
      assign[rgb[4]+1] = rgb[4] -- really n, but can we be sure?
      else
        doubles[rgb[4]] = true; -- Mark as double (This is wrong; starts at 0...but col 0 cannot be a double so...)
        dtot = dtot + 1
        assign[rgb[4]+1] = indexpal[i][4] -- Reassign removed color
   end
 end

 -- sort ulist
 if sortflag == 1 then db.sorti(ulist,2); end -- sort by brightness

 l = #ulist
 for n=1, l, 1 do
  newpal[n] = indexpal[ulist[n][1]]
 end

 newpal["assigns"] = assign -- Complete list of image color assigns (removed cols will point to 1st occurence)
 newpal["doubles"] = doubles
 newpal.double_total = dtot

  --messagebox("unique colors", unique-1)

 return newpal

end
--


-- *** ColorMatching (PalList) ***

-- Used Anywhere? Yes, Retroformats
function db.getBestPalMatch(r,g,b,pal,index_flag) -- pal = [r,g,b,palindex], index_flag -> return palindex if pal is sorted or reduced
 
 --messagebox("getBestPalMatch()")

 local diff,best,bestcol,cols,n,c,p,rw,gw,bw
 rw,gw,bw = db.getDefaultRGBweights()
 cols = #pal
 bestcol = -1
 best = 9e99

 for n=1, cols, 1 do
  p = pal[n]
  --diff = db.getColorDistance_weight(r,g,b,p[1],p[2],p[3],0.26,0.55,0.19)  * 1.5690256395005606
  diff = db.getColorDistance_weightNorm(r,g,b,p[1],p[2],p[3],rw,gw,bw)
  if diff < best then bestcol = n; best = diff; end
 end 

 if index_flag == true then
  bestcol = pal[bestcol][4] + 1 
 end

 return bestcol-1 -- palList index start at 1, image-palette at 0
end
--




-- Normally this function will return the (image)palette index of best color
-- ...but if the palette has been sorted with 'fixPalette' it will return the index
-- of the custom palList, setting index_flag will convert this value to image-palette index
--
-- HYBRID means the colormatch is a combo of color and (perceptual)brightness
--
--
function db.getBestPalMatchHYBRID(rgb,pal,briweight,index_flag) -- Optimized, 43% faster than normal
 local diff,diffC,diffB,best,bestcol,cols,n,c,r,g,b,p,obri,r2,g2,b2,q,abs
 cols = #pal
 bestcol = -1
 best = 9e99

 r,g,b,sq,abs = rgb[1], rgb[2], rgb[3], math.sqrt, math.abs	

 obri = sq(r*r*0.0676 + g*g*0.3025 + b*b*0.0361) -- 0.26,0.55,0.19

 for n=1, cols, 1 do
  p = pal[n]

  r2,g2,b2 = p[1],p[2],p[3]

  diffB = abs(obri - sq(r2*r2*0.0676 + g2*g2*0.3025 + b2*b2*0.0361)) -- Brightness diff

  diffC = sq( 0.0676*(r-r2)*(r-r2) + 0.3025*(g-g2)*(g-g2) + 0.0361*(b-b2)*(b-b2) ) -- Color Distance

  diff = briweight * (diffB - diffC) + diffC
  if diff < best then bestcol = n; best = diff; end
 end 

 if index_flag then
  bestcol = pal[bestcol][4] + 1 -- Since we detract 1 on return, God Lua is stupid 
 end

 return bestcol-1 -- palList index start at 1, image-palette at 0
end
--


--
-- Same as HYBRID but with RGB as separate parameters 
-- Also it requires db.addUnNormalizedBrightness2Palette applied to Pallist for unNormalized Brightness
-- 25% Faster than HYBRID for 256 colors
--
function db.getBestPalMatch_Hybrid(r,g,b,pal,briweight,index_flag) -- Optimized, 43% faster than normal
 local diff,diffC,diffB,best,bestcol,cols,n,c,p,obri,r2,g2,b2,q,abs,rr2,gg2,bb2
 cols = #pal
 bestcol = -1
 best = 9e99

 sq,abs = math.sqrt, math.abs	

 obri = sq(r*r*0.0676 + g*g*0.3025 + b*b*0.0361) -- 0.26,0.55,0.19

 for n=1, cols, 1 do
  p = pal[n]

  r2,g2,b2 = p[1],p[2],p[3]
  rr2,gg2,bb2 = r-r2, g-g2, b-b2

  --diffB = abs(obri - sq(r2*r2*0.0676 + g2*g2*0.3025 + b2*b2*0.0361)) -- Brightness diff

  diffB = abs(obri - p[8]) -- Brightness diff
  --diffC = sq( 0.0676*(r-r2)*(r-r2) + 0.3025*(g-g2)*(g-g2) + 0.0361*(b-b2)*(b-b2) ) -- Color Distance
  diffC = sq( 0.0676*rr2*rr2 + 0.3025*gg2*gg2 + 0.0361*bb2*bb2 ) -- Color Distance
  diff = briweight * (diffB - diffC) + diffC

  if diff < best then bestcol = n; best = diff; end
 end 

 if index_flag then
  bestcol = pal[bestcol][4] + 1 -- Since we detract 1 on return, God Lua is stupid 
 end

 return bestcol-1 -- palList index start at 1, image-palette at 0
end
--



-- Note: Using graytolerance in Hue of other than 0 causes an error, a rift in the red/orange line...why exactly?
--       (Right now, I'm only uisng this with graytolerance=0, and that seem to work as intented)
function db.matchcolorHSB(h,s,b,pallist,index_flag) -- hsb 0..255
 --
 -- why don't we just convert HSB-diagram to RGB and do normal colormatching?
 -- Not the same...
 --
 local n,c,best,bestcol,pb,ph,ps,diff,huediff,huecorr,hue_adj,sat_adj,bri_adj,abs,pb_d,ps_d
 local sat_adj_root,bri_adj_root

 abs = math.abs

 bestcol = -1
 best = 9e99

 -- higher adjust means more impact (higher hue gives more interpolation )
 hue_adj = 4
 sat_adj = 0.075
 bri_adj = 2

 sat_adj_root = sat_adj^0.5
 bri_adj_root = bri_adj^0.5

 huecorr = 255 / 6 -- Our Hue goes from 0.0 - 5.999 

 for n=1, #pallist, 1 do
  c = pallist[n]
  ph = c[5]
  ps = c[6]
  --pb = c[7]
  ps_d = (s - ps)   * sat_adj_root -- x*x*a = (x * a^0.5)^2
  pb_d = (b - c[7]) * bri_adj_root

  huediff = abs(h-ph*huecorr)
  if huediff >= 128 then huediff = huediff - (huediff % 128) * 2; end

  --if ph == 6.5 then huediff = 0; end 

  -- With less saturation, exact hue becomes less important and brightness more usefull
  -- This allows for greyscales and low saturation colors to work smoothly.
  huediff = huediff * (ps/255) --^0.5

  --diff = hue_adj*huediff^2 + (s-ps)^2 * sat_adj + (b-pb)^2 * bri_adj
  --diff = hue_adj*huediff*huediff + (s-ps)*(s-ps) * sat_adj + (b-pb)*(b-pb) * bri_adj
  diff = hue_adj*huediff*huediff + ps_d*ps_d + pb_d*pb_d
  

  if diff <= best then bestcol = n; best = diff; end
 end

 if index_flag == true then
  bestcol = pallist[bestcol][4] + 1 -- Since we detract 1 on return
 end

 return bestcol-1

end
--

--
-- ... eof Custom Palette list operations ...
--



-- ******************************************
-- ***     Color / Palette functions      ***
-- ***    Capping, distances etc.         ***
-- ******************************************

--
function db.cap(v)
 return math.min(255,math.max(0,v))
end
--

--
function db.rgbcaps(r,g,b)
 return math.min(255,math.max(0,r)), math.min(255,math.max(0,g)), math.min(255,math.max(0,b))
end
--

--
function db.rgbcap(r,g,b,mx,mi)
 local m = math
 return m.max(mi,m.min(r,mx)), m.max(mi,m.min(g,mx)), m.max(mi,m.min(b,mx))
end
--

--
function db.rgbcapInt(r,g,b,mx,mi)
 local m = math
 return m.floor(m.max(mi,m.min(r,mx))), m.floor(m.max(mi,m.min(g,mx))), m.floor(m.max(mi,m.min(b,mx)))
end
--

---------------------
-- Color distances --
---------------------

-- NOTE: In order to counter internal rounding issues (the result may never quite reach 255 or 100% distance)
-- one may need to process the final result before applying it in diagrams etc.
-- Ex: dist = math.min(255, math.ceil(dist * 1000) * 0.001)




-- Perceptual Color Distance with custom weight.
-- Result requires multiplication with a normalizer to get a max distance of 255
-- with perceptual weights: 0.26,0.55,0.19, normalizer = 1.569...
--
--return math.sqrt( (rw*(r1-r2))^2 + (gw*(g1-g2))^2 + (bw*(b1-b2))^2 )
--
function db.getColorDistance_weight(r1,g1,b1,r2,g2,b2,rw,gw,bw)
 return ( rw*rw*(r1-r2)*(r1-r2) + gw*gw*(g1-g2)*(g1-g2) + bw*bw*(b1-b2)*(b1-b2) )^0.5   -- Result without normalizer
end
--

-- Returns Normalized result (0..255, 255 is the distance black to white)
function db.getColorDistance_weightNorm(r1,g1,b1,r2,g2,b2,rw,gw,bw)
 return ( (rw*rw*(r1-r2)*(r1-r2) + gw*gw*(g1-g2)*(g1-g2) + bw*bw*(b1-b2)*(b1-b2)) / (rw*rw + gw*gw + bw*bw) )^0.5
end
--

--
--function db.getColorDistance(r1,g1,b1, r2,g2,b2)
-- local rw,gw,bw,exp,rexp,norm
-- rw,gw,bw,exp,norm = 0.26, 0.55, 0.19, 1.5690256395005606 -- Dawn3.0
 --rw,gw,bw,exp,norm = 0.3, 0.5, 0.2, 1.684851093 -- Dawn4.0
-- rexp = 1 / exp
--end
--



--
-- Since brightness is exponential, each channel may work as a "star" drowning the color
-- of a lesser channel. This algorithm is an approximation to adjust distances for this phenomenon.
-- Ex: Adding 32 red to black is visually obvious, but adding 64 red to full green is almost 
-- impossible to detect by the naked eye.
--
-- However this isn't a complete solution so we may weigh in brightness as well...
--
-- If cv = 0 (0..1) then prox acts as ordinary perceptual colordistance
-- if bri = 1 (0..1) then distance is only that of brightness
function db.getColorDistanceProx(r1,g1,b1,r2,g2,b2,rw,gw,bw,normalizer, cv,briweight)
 local rp1,gp1,bp1,rp2,gp2,bp2,v,m1,m2,prox,bdiff,e,ie; 
 
 e = 2 -- only even integer exponents will work right now
 ie = 1/e
 v = 2*255^e
 m1 = math.max(r1,g1,b1)
 m2 = math.max(r2,g2,b2)
 rp1 = 1 - ((r1-m1)^e / v)^ie * cv
 gp1 = 1 - ((g1-m1)^e / v)^ie * cv
 bp1 = 1 - ((b1-m1)^e / v)^ie * cv

 rp2 = 1 - ((r2-m2)^e / v)^ie * cv
 gp2 = 1 - ((g2-m2)^e / v)^ie * cv
 bp2 = 1 - ((b2-m2)^e / v)^ie * cv

 bdiff = math.abs(db.getBrightness(r1,g1,b1) - db.getBrightness(r2,g2,b2)) -- weights are hardcoded in function
 prox = ( (rw*(r1*rp1-r2*rp2))^2 + (gw*(g1*gp1-g2*gp2))^2 + (bw*(b1*bp1-b2*bp2))^2 )^0.5 * normalizer

  return prox * (1-briweight) + bdiff * briweight
end
--


--
-- Special version of Hybrid-remapping for mixPalette list
--
-- mixpal: {score,col#1,col#2,dist,rm,gm,bm, c1_r,c1_g,c1_b, c2_r,c2_g,c2_b}
--
-- returns: {col#1,col#2} (index of palette)
--
-- used by scn_db_SpareRemapX (mixdither)
function db.getBestPalMatchHybridMIX(rgb,mixpal,briweight,mixreduction)

 --if DONE ~= true then messagebox("Using getBestPalMatchHybridMIX");end
 --DONE = true

 local diff,diffC,diffB,best,bestcol,cols,n,c,r,g,b,p,obri,pbri, distmult, abs
 cols = #mixpal
 bestcol = -1
 best = 9e99

 abs = math.abs

 -- We will simply add the the distance to the mix with the distance between the mixcolors and
 -- employ a user tolerance to much the latter will matter.
  --distmult = 255 / 9.56 / 100 * mixreduction -- 16 shades
 distmult = 1 / 100 * mixreduction  -- 24-bit, Dawn3.0 colormodel

 -- Note: Not secured against negative values (this algorithm is SLOW, we cannot afford it)
 r = rgb[1]
 g = rgb[2] 
 b = rgb[3]

 obri = db.getBrightness(r,g,b) -- 0-255

 for n=1, cols, 1 do
  p = mixpal[n]
  --pbri = db.getBrightness(p[5],p[6],p[7])

  pbri = ((db.getBrightness(p[8],p[9],p[10])^2 + db.getBrightness(p[11],p[12],p[13])^2) / 2)^0.5

  diffB = abs(obri - pbri)
 
  -- Distance bewteen source col and mixcol + distance between the two mixcolors (roughness factor)
  diffC = db.getColorDistance_weightNorm(r,g,b,p[5],p[6],p[7], 0.26,0.55,0.19) + p[4]*distmult

  diff = briweight * (diffB - diffC) + diffC
  if diff <= best then bestcol = n; best = diff; end
 end 

 return {mixpal[bestcol][2], mixpal[bestcol][3]}
--return {mixpal[bestcol][2], 0}

end
--
------------ Color functions ------



------------------------------------------
-- GRADIENT COLOR / MIX COLOR FUNCTIONS --
------------------------------------------

-- Basic
-- Gradient Color / Mix Color, Basic Linear Interpolation
-- xf: gradient position 0..1, 0 = color 0, 1 = color 1, 0.5 = Mid gradient or 50/50 mix.
--
function db.getGradientCol_Linear(r0,g0,b0,r1,g1,b1,xf)
 local r,g,b,f0,f1
 f0,f1 = 1 - xf,xf
 r = f0 * r0 + f1 * r1 
 g = f0 * g0 + f1 * g1 
 b = f0 * b0 + f1 * b1
 return r,g,b 
end
--

 
-- Gamma Corrected
-- Gradient Color / Mix Color, Basic Gamma applied
-- xf: gradient position 0..1, 0 = color 0, 1 = color 1, 0.5 = Mid gradient or 50/50 mix.
-- gam: Gamma 1.0 - 2.2, 1.6 is a good nominal value. With a gamma of 1.0 this produces a basic Linear gradient
function db.getGradientCol_Gamma(r0,g0,b0,r1,g1,b1,xf, gam)
 local r,g,b,f0,f1,rgam
 gam = gam or 1.6
 f0,f1 = 1 - xf,xf
 rgam = 1 / gam
 r = (f0 * r0^gam + f1 * r1^gam)^rgam 
 g = (f0 * g0^gam + f1 * g1^gam)^rgam 
 b = (f0 * b0^gam + f1 * b1^gam)^rgam 
 return r,g,b
end
--

-- Gradient Gamma (biggest problem: full color to black (curved), primary 2 white is good (linear))
-- Gradient Color / Mix Color, Gradient Gamma
-- Gamma for each color is proportional to saturation (largest colorchannel differance), then the gamma is a gradient of these two values
--
-- xf: gradient position 0..1, 0 = color 0, 1 = color 1, 0.5 = Mid gradient or 50/50 mix.
-- gam: Gamma 1.0 - 2.2, 1.6 is a good nominal value. With a gamma of 1.0 this produces a basic Linear gradient
--
-- (dif0,dif1:) Max colorchannel differances, may be precalculated as same values apply to the entire gradient [Optional], use dif = db.getRGB_maxDelta(r,g,b)
--
function db.getGradientCol_GammaGradient(r0,g0,b0,r1,g1,b1,xf,gam, dif0,dif1)
 local r,g,b,f0,f1,rgam
 gam = gam or 1.6
 dif0 = dif0 or (math.max(r0,g0,b0) - math.min(r0,g0,b0))/255 
 dif1 = dif1 or (math.max(r1,g1,b1) - math.min(r1,g1,b1))/255 
 f0,f1 = 1 - xf,xf
 lgam = 1.0 + f0*dif0*(gam-1.0) + f1*dif1*(gam-1.0)
 rgam = 1 / lgam
 r = (f0 * r0^lgam + f1 * r1^lgam)^rgam 
 g = (f0 * g0^lgam + f1 * g1^lgam)^rgam 
 b = (f0 * b0^lgam + f1 * b1^lgam)^rgam
 return r,g,b 
end

-- Minimum Gamma (big deviation, full color to bright half-shade: 255,0,0 - 0,128,128), no gamma on primary 2 gray (not linear)
-- Gradient Color / Mix Color, Minimum Gamma
-- Gamma is proportional to the saturation of the least saturated color (working from the custom gamma value)
--
-- xf: gradient position 0..1, 0 = color 0, 1 = color 1, 0.5 = Mid gradient or 50/50 mix.
-- gam: Gamma 1.0 - 2.2, 1.6 is a good nominal value
--
-- min_dif: use getGradient_MinDiff(r0,g0,b0,r1,g1,b1) [Optional]
--
function db.getGradientCol_GammaMin(r0,g0,b0,r1,g1,b1,xf, gam,min_dif)
 local r,g,b,rgam,lgam,f0,f1
 min_dif = min_dif or db.getGradient_MinDiff(r0,g0,b0,r1,g1,b1)
 gam = gam or 1.6
 f0,f1 = 1 - xf,xf
 lgam = 1.0 + min_dif * (gam-1.0)
 rgam = 1 / lgam
 r = (f0 * r0^lgam + f1 * r1^lgam)^rgam 
 g = (f0 * g0^lgam + f1 * g1^lgam)^rgam 
 b = (f0 * b0^lgam + f1 * b1^lgam)^rgam
 return r,g,b 
end
--

-- Product Gamma (Boost gamma (above Minimum) if both colors have saturation) 
-- (For primary 2 primary and primary to gray it will produce the same result as Min Gamma)
--
-- See GammaGradient & GammaMin for arguments
--
function db.getGradientCol_GammaMinProduct(r0,g0,b0,r1,g1,b1,xf, gam, dif0,dif1)
 local r,g,b,f0,f1,lgam,dgam,ngam,rgam,min_dif
 gam = gam or 1.6
 dif0 = dif0 or db.getRGB_maxDelta(r0,g0,b0) 
 dif1 = dif1 or db.getRGB_maxDelta(r1,g1,b1)
 min_dif = math.min(dif0,dif1)  
 f0,f1 = 1 - xf,xf
 lgam = 1.0 + min_dif * (gam-1.0) -- Min gamma
 dgam = gam - lgam -- residual potential gamma
 ngam = lgam + dif0*dif1*dgam  -- = 1 + (gam-1) * (min_dif + (dif0*dif1)*abs(dif0-dif1)) 
 rgam = 1 / ngam
 r = (f0 * r0^ngam + f1 * r1^ngam)^rgam 
 g = (f0 * g0^ngam + f1 * g1^ngam)^rgam 
 b = (f0 * b0^ngam + f1 * b1^ngam)^rgam 
 return r,g,b
end
--

-- Bri-Correction
-- Gradient Color / Mix Color, Brightness corrected
-- Return the Brightness-corrected RGB-value at fractional position [xf] in the "colorgradient" from [r0,g0,b0] to [r1,g1,b1]
-- Eq. to the colormixing of two colors, ex: [255,255,0],[0,0,255],0.25 returns the result of mixing 75% yellow and 25% blue.
-- Applied to all colors in a gradient; this assures that the brightness of the colors are linear from color 0 to color 1
-- xf: gradient position 0..1, 0 = color 0, 1 = color 1, 0.5 = Mid gradient or 50/50 mix.
--
-- (bri0,bri1:) Brightness (0..255) of the source colors, precalc & provide for optimal speed when making a full gradient [Optional]
--
function db.getGradientCol_BriCorr(r0,g0,b0,r1,g1,b1,xf, bri0,bri1)
 local n,min,max,r,g,b,bri_grad,bdif,f0,f1
 bri0 = bri0 or db.getBrightness(r0,g0,b0)
 bri1 = bri1 or db.getBrightness(r1,g1,b1)
 min,max = math.min,math.max
 f0,f1 = 1 - xf,xf
 bri_grad = f0 * bri0 + f1 * bri1
 r = f0 * r0 + f1 * r1 
 g = f0 * g0 + f1 * g1 
 b = f0 * b0 + f1 * b1 
 for n = 0, 25, 1 do -- 26 steps is required to lift blue #1 up to 10,10,255 in a blue-yellow gradient
  bdif = bri_grad - db.getBrightness(r,g,b) 
  r = min(255,max(0,r + bdif))
  g = min(255,max(0,g + bdif))
  b = min(255,max(0,b + bdif))
 end
 return r,g,b
end
--
 
-------------------
-- Support Functions (Gradient Color / Mix Color)
--
-- return the smallest of the two greatest colorchannel differences, for use with Minimum Gamma functions
function db.getGradient_MinDiff(r0,g0,b0,r1,g1,b1)
 return math.min(db.getRGB_maxDelta(r0,g0,b0), db.getRGB_maxDelta(r1,g1,b1))
end
--
------------------


----------------------------
-- NATURAL GRADIENT (WIP) --
----------------------------

-- Here be voodoo ;)
-- 0..1
function db.naturalGradient(n)
 local v
 v = n^3 - (n*(n-1))/(2^0.5)
 return math.min(1,math.max(0,v))
end
--

-- Inverse, Scan naturalGradient curve for a specific Value
-- value: 0-255
-- 
function db.findNaturalGradientValue(value, step)
 local n,b,q
 step = step or 0.25
 q = value/255
 for n = 0, 255, step do
  b = db.naturalGradient(n/255)
  if b == q then return n; end
  if b > q then return n - step*0.5; end -- Stepped over, return approximate value
 end
 return 255
end
--

--
-- Use the Natural Gradient curve to obtain a realistic looking brightness change for a value
-- The result is somewhat similar to Multiply, but NB is also able to affect dark colors.
--
--  value: Color channel / Grayscale value: 0-255
-- amount: Change in Brightness: -255..255
--   step: Precision in Gradient Curve scan, lower value is more exact: +0..1, nominal = 0.25
--
function db.naturalBrightness(value,amount,step)
  local gradient_val
  gradient_val = db.findNaturalGradientValue(value, step) / 255; 
  return math.floor(0.5 + value + (db.naturalGradient(gradient_val + amount/255) - db.naturalGradient(gradient_val)) * 255)
end
--

------------ eof Natural Gradient ------------

--------- eof Gradient Color / Mix Color  ----

--
-- Create (Set in Palette) a curved ramp between three colors (that goes through the mid color)
--
function db.setTriRamp(rgb0,rgb1,rgb2, cols, start_index) -- {r,g,b}..,colors in ramp

  local n,r,g,b,r0,g0,b0,r1,g1,b1,f0,f1

  start_index = start_index or 0

  -- Extended Bezier (Make ramp go through midpoint)
  r = rgb1[1]*2 - (rgb0[1]+rgb2[1])*0.5 -- Same as 2*(c0 - c1 - c2)
  g = rgb1[2]*2 - (rgb0[2]+rgb2[2])*0.5
  b = rgb1[3]*2 - (rgb0[3]+rgb2[3])*0.5
  rgb1 = {r,g,b}

  -- Make a Ramp for branch colors (Extended 3-Point Bezier Curve)
  for n = 0, cols-1, 1 do
   f1 = (1 / (cols-1)) * n
   f0 = 1 - f1
   r0 = rgb0[1]*f0 + rgb1[1]*f1
   g0 = rgb0[2]*f0 + rgb1[2]*f1
   b0 = rgb0[3]*f0 + rgb1[3]*f1
   r1 = rgb1[1]*f0 + rgb2[1]*f1
   g1 = rgb1[2]*f0 + rgb2[2]*f1
   b1 = rgb1[3]*f0 + rgb2[3]*f1
   r = r0 * f0 + r1 * f1
   g = g0 * f0 + g1 * f1
   b = b0 * f0 + b1 * f1
   setcolor(start_index + n, r,g,b)
  end

end
--


---------------------------------------
---------- COLOR DIAGRAMS ------------- 
---------------------------------------

--
function db.drawColorspace12bit(x,y,cols,size)
 local r,g,b,c,rows,row,col,s16,rx,ry,xx,yy,xcols16,yrows16,size1,yyry,r17,g17

 size1 = size - 1
 s16 = size*16
 rows = math.floor(16/cols)

 for g = 0, 15, 1 do
  g17 = g * 17
  col = g % cols
  xcols16 = x+col*s16
  row = math.floor(g / cols)
  yrows16 = y+row*s16
  for r = 0, 15, 1 do
   r17 = r * 17
   xx = xcols16 + r*size
   for b = 0, 15, 1 do
    c  = matchcolor2(r17,g17,b*17)
    yy = yrows16 + b*size
     for ry = 0, size1, 1 do
      yyry = yy+ry
      for rx = 0, size1, 1 do
       putpicturepixel(xx+rx,yyry,c)
     end;end
   end
  end
 end
end
--


--
function db.drawColorspace12bit_fromPalList(x,y,cols,size,pallist)
 local r,g,b,c,rows,row,col,s16,rx,ry,xx,yy,r17,g17,size1,yyry,xcols16,yrows16

 pallist = db.addUnNormalizedBrightness2Palette(pallist)

 size1 = size - 1
 s16 = size*16
 rows = math.floor(16/cols)

 for g = 0, 15, 1 do
  g17 = g * 17
  col = g % cols
  row = math.floor(g / cols)
  xcols16 = x+col*s16
  yrows16 = y+row*s16
  for r = 0, 15, 1 do
   r17 = r * 17
   xx = xcols16 + r*size
   for b = 0, 15, 1 do
    --c  = matchcolor2(r*17,g*17,b*17)
    --c = db.getBestPalMatchHYBRID({r*17,g*17,b*17}, pallist, 0.25, true)
    c = db.getBestPalMatch_Hybrid(r17,g17,b*17, pallist, 0.25, true) 
    yy = yrows16 + b*size
     for ry = 0, size1, 1 do
      yyry = yy+ry
      for rx = 0, size1, 1 do
       putpicturepixel(xx+rx,yyry,c)
     end;end
   end
  end
 updatescreen(); waitbreak(0)
 end

end
--

-- V1.1 Fixed correct dim fractions
function db.drawBriMatchDiagram(pallist,posx,posy,width,height)
 local wf,hf,w,h,bri,c,yp,width1

 if pallist[1][8] == null then
  pallist = db.addUnNormalizedBrightness2Palette(pallist)
 end

 width1 = width - 1
 wf = 1/(width1)
 hf = 1/(height-1)
 
 c = matchcolor(48,48,48)
 for w = 0, width-1, 2 do
  putpicturepixel(posx + w, posy+height, c)
 end

 for h = 0, height-1, 1 do -- Brightness
  bri = (1 - h*hf) * 255
  yp = posy + h
  for w = 0, width1, 1 do -- Match level
    --c = db.getBestPalMatchHYBRID({bri,bri,bri},pallist,w*wf,true)
    c = db.getBestPalMatch_Hybrid(bri,bri,bri,pallist,w*wf,true)  
    putpicturepixel(posx + w, yp, c)
  end
  if h%16 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end
end
--

-- Brightness notches on the side of the BriMatch-diagram
-- There is still a minute discrepency here, very dark colors doesn't always line up 100% correctly with the BriMatchDiagram
-- It may just be a problem when the diagram height is not a multiple of 16?
--
function db.drawBriLevelDiagram(pallist,posx,posy,height, cspace,cwidth) -- cspace & cwidth are bri-lines
 local wf,hf,xmw,h,bri,c,r,g,b,n,linec,levs,levres,offset,ymult
 levres = math.floor(height/16) * 16
 ymult = height/256 * 256/levres 
 cspace = cspace or 5
 cwidth = cwidth or 4
 levs = {}
 for n = 1, levres+1, 1 do 
  levs[n] = 0
 end
 --linec = db.getBestPalMatchHYBRID({127,127,127},pallist,0.25,true) 
 for n = #pallist, 1, -1 do -- Brightest first
  c = pallist[n][4] -- r,g,b,n
  r,g,b = getcolor(c)
  bri = db.getBrightness(r,g,b)
  h = math.floor( (1-math.min(1,bri/255)) * (levres-1)) -- 
  offset = h * ymult
  for x = 0, cwidth-1, 1 do 
   putpicturepixel(x + posx + levs[h+1] * cspace, posy + offset, c)
  end
  levs[h+1] = levs[h+1] + 1
 end
end
--

-- Hue-Brightness Diagram
function db.drawHSBdiagram(pallist,posx,posy,width,height,size,sat)
 --db.addHSBtoPalette(palList)
 local x,y,c,xf,yf,yp,ypos,width1

 width1 = width - 1

 xf = 255.5/ width1
 yf = 255.5/(height-1)

 if size > 1 then
  for y = 0, height-1, 1 do
   bri = yf * y
   ypos = posy + y*size
   for x = 0, width-1, 1 do
    hue = xf * x
    c = db.matchcolorHSB(hue,sat,bri,pallist,true)
    db.drawRectangle(posx + x*size, ypos, size,size, c)
   end
   if y%8 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
  end
 end

 if size == 1 then
  for y = 0, height-1, 1 do
   bri = yf * y
   yp = posy + y
   for x = 0, width1, 1 do
    hue = xf * x
    c = db.matchcolorHSB(hue,sat,bri,pallist,true)
    putpicturepixel(posx + x, yp, c)
   end
   if y%16 == 0 then updatescreen();if (waitbreak(0)==1) then return end; end
  end
 end

end
--

-------------------------------------------------------------
---  POLAR HsB DIAGRAM, Pixel/Render version
--------------------------------------------------------------
-- pallist:          Palette list with HSB-values added.
-- ox,oy:            Position (left corner)
-- radius:           Radius of diagram, (use X.5 values for best result, like 99.5 ...might not be true anymore)
-- saturation:       Saturation level of diagram (0..255)
-- pol_exp:          Pole exponent, enlarge the center, nominal 1.0, use 1.0-2.0 for enlargement
-- dark2bright_flag: Reverse brightness, draw from black center to white edge. Nominal = false.
--
function db.polarHSBdiagram_Pixel(pallist,ox,oy,radius,saturation,pol_exp,dark2bright_flag)

 local x,y,v,c,xp,yp,bri,yp,ang,size,dist,Atan,deg255,v90,mode,sign,yp2,radius05
 local dist_sq, radius_sq, pol_exp_sq, oyy

 size = radius*2
 pol_exp = pol_exp or 1 -- expand the centre if exp > 1
 mode,sign = 255,255; if dark2bright_flag then mode,sign = 0,-255; end -- Multiplied with 255

 Atan     = math.atan
 deg255   = 180 / math.pi * 255/360
 v90      = 255 / 4                  -- math.pi/2 * deg255
 radius05 = radius - 0.5

 --dist_sq
 radius_sq = radius * radius
 pol_exp_sq = 0.5 * pol_exp --  (x^0.5)^e = x^(0.5*e) (Distance root added to pole exponent)

 for y = 0, size-1, 1 do
  yp = y - radius05
  yp2 = yp*yp
  oyy = oy + y
  for x = 0, size-1, 1 do

   xp = x - radius05
  
   --dist = (xp*xp + yp2)^0.5
   dist_sq = xp*xp + yp2

   if dist_sq <= radius_sq then

    -- note: *255 added to mode & sign to save a *255
    bri = (mode - sign*(dist_sq / radius_sq)^pol_exp_sq) -- handle dark2bright and bright2dark

    ang = 0
    if not(xp==0 and yp==0) then
     if xp < 0 then
      ang = (Atan(yp/xp) * deg255 - v90) % 255
       else
        ang = (Atan(yp/xp) * deg255 + v90) % 255
     end
    end

    c = db.matchcolorHSB(ang,saturation,bri,pallist,true) -- overshooting brightness some doesn't seem to matter

    putpicturepixel(ox+x,oyy,c)
   end -- inside radius
 
  end 
  if y%16==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end

 --putpicturepixel(ox+radius,oy+radius,c128)

end -- polar pixel
--


-- Diagram by Triangles, use Pixel version for better quality
--
function db.polarHSBdiagram(ox,oy,radius,pol,brilev,huelev,saturation,dark2bright_flag)

local pal,bstep,bstep2,hstep,hstep2,bri,hue,sx,sy,cx,cy,x,y,p1,p2,c,hmult

pal = db.addHSBtoPalette(db.fixPalette(db.makePalList(256)))

bstep = radius / (brilev + pol)
bstep2 = bstep / 2
hstep = -360 / huelev
hstep2 = hstep / 2

hmult = 255/360

c = 255; if dark2bright_flag then c = 0; end
drawdisk(ox,oy,math.ceil(pol*bstep),matchcolor(c,c,c)) 

for y=pol, brilev+pol-1,1 do
 
 bri = (brilev - y + pol) * (256 / brilev)

 if dark2bright_flag then
  bri = (brilev - (brilev - y + pol)) * (256 / brilev)
 end

 for x=0, huelev-1,1 do

  hue = x * (360 / huelev) * hmult

  c = db.matchcolorHSB(hue,saturation,bri,pal,true)

  sx = ox
  sy = oy - y*bstep

  cx,cy = db.rotationFrac(x*hstep,ox,oy,sx,sy) 

  x1,y1 = db.rotation(x*hstep-hstep2,ox,oy,ox, sy-bstep2) 
  x2,y2 = db.rotation(x*hstep+hstep2,ox,oy,ox, sy-bstep2) 
  x3,y3 = db.rotation(x*hstep-hstep2,ox,oy,ox, sy+bstep2) 
  x4,y4 = db.rotation(x*hstep+hstep2,ox,oy,ox, sy+bstep2) 

  p1 = {{x1,y1},{x2,y2},{x3,y3}}
  p2 = {{x3,y3},{x4,y4},{x2,y2}}

  db.fillTriangle(p1,c,0,true,false) -- triangle, fillcol, linecol, fill, wire
  db.fillTriangle(p2,c,0,true,false)

  --putpicturepixel(x1,y1,c)

 end
 if y%8==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
end

end -- polarHSB
--

--
-- Plotted Brightness-Hue Diagram (The best pal-analysis tool there is!)
--
-- pallist:             Palette list with HSB added: use db.addHSBtoPalette((db.fixPalette(db.makePalList(256),1))
-- ox,oy:               Position
-- xsize:               Width of diagram (Brightness)
-- ysize:               Height of diagram (Hue)
-- space:               frame spacing (inside)
-- sz:                  Plot size (diameter of color discs). 7 is good for small palettes, use less with increasing colors
-- graytolerance (0-1): Threshold for colors to be considered grayscales: Nominal 0.05-0.1, 0 = Only pure grayscales, 1 = Even full saturation treated as grayscales
-- britrace_len:        Color Brightness lines, length in dots (Nominal 3 to 4, use 0 to inactivate)
-- britrace_mono_flag:  Use grayscale rather than colored dots 
-- frame_flag:          Draw framing box
-- grid_flag:           Draw grids, Primary Hue lines and 3 grayscales
-- briplot_flag:        Plot Brightness positions at bottom
--
function db.drawBriHuePlotDiagram(pallist,ox,oy,xsize,ysize,space,sz,graytolerance, britrace_len, britrace_mono_flag, briplot_flag, frame_flag, grid_flag)

 local x,y,n,r,g,b,c,sx,sy,x_scale,y_scale,colors,hue,bri,free,b00,b32
 local gy,gry0,gry32,gry48,gry64,gry80,x127,x000,x255,st,xp,brilev,gray_padding
 
 colors = #pallist

 space = space + 1 -- single pixels fit just inside box at space = 0

 gray_padding = 1 -- Padding space under the bottom grayscale colors (while maintaining the y-size of the diagram)
 x_scale = (xsize - space*2)/256
 y_scale = ((ysize-gray_padding) - space*2)/6.5

 -- Outline really dark colors, esp. black. (Quick fix)
 -- We kind of assume that the diagram will be drawn on a black or dark bg by default
 -- Set to 0 or -1 to deactivate
 mark_dark_limit = 24

 -- Size
 sx = math.floor(space*2  + 256 * x_scale)
 sy = math.floor(space*2  + 6.5 * y_scale) + gray_padding

 gry80 = matchcolor(80,80,80)
 gry64 = matchcolor(64,64,64)
 gry48 = matchcolor(48,48,48)
 gry32 = matchcolor(32,32,32) -- temp
 gry0 = matchcolor(0,0,0)
 b00 = db.getBrightness(getcolor(gry0))
 b32 = db.getBrightness(getcolor(gry32))
 if gry0 == gry32 or (b32-b00) < 28 then gry32 = gry48; end

 if frame_flag then 
   db.drawRectangleLine(ox,oy,sx,sy,gry64)      -- Box
   db.line(ox+1,oy+sy-1,ox+sx-2,oy+sy-1, gry32) -- Bottom Line
   for y = 0, 6, 1 do    
    hy = math.floor(space + y * y_scale)        -- Box Hue Dots   
    putpicturepixel(ox,oy+hy,       gry80)
    putpicturepixel(ox+sx-1,oy+hy,  gry80)
    putpicturepixel(ox,oy+hy+1,     gry32)
    putpicturepixel(ox+sx-1,oy+hy+1,gry32)
   end
 end -- eof frame_flag

 --
 if grid_flag then
  for y = 0, 6, 1 do
   hy = math.floor(space + y * y_scale)                       
   st = 2; if y == 0 or y == 6 then st = 1; end -- Make Red lines solid
   for x = ox+1, ox+sx-2, st do                 -- Hue Lines
    putpicturepixel(x,oy+hy, gry32)
   end -- x
  end -- y
  x000 = ox + 0 * x_scale + space          
  db.line(x000, oy+1,x000,oy+sy-1, gry32) --     0   Brightness line 
  x127 = ox + 127.5 * x_scale + space          
  db.line(x127, oy+1,x127,oy+sy-1, gry32) --   127.5 Brightness line 
  x255 = ox + 255 * x_scale + space          
  db.line(x255, oy+1,x255,oy+sy-1, gry32) --   255   Brightness line
 end -- eof grid_flag
 --
 
 --
 if britrace_len > 0 then
  for n = 1, colors, 1 do
    c = pallist[n][4] -- r,g,b,n,h,s,b
    r,g,b = getcolor(c)
    hue = db.getHUE(r,g,b,graytolerance)
    bri = pallist[n][7]
    if britrace_mono_flag then c = gry64; end
    for y = 1, britrace_len, 1 do
     if hue ~= 6.5 then   -- Don't do downwards lines for grayscales
       putpicturepixel(ox+bri*x_scale+space, math.floor(oy+hue*y_scale+space)+sz/2+0.5+(y*2-1),c) -- 0.5 not 1 makes discs odd&even spaced 1 pixel
     end
     if hue > 0.25 then
      putpicturepixel(ox+bri*x_scale+space, math.floor(oy+hue*y_scale+space)-sz/2-0.5-(y*2-1),c) 
     end
    end -- y
  end -- n
 end -- eof britrace  
 --

 --
 brilev = {};
 for n = 1, math.floor(256*x_scale+space)+1, 1 do
  brilev[n] = 0
 end

 for n = 1, colors, 1 do

  c = pallist[n][4] -- r,g,b,n,h,s,b
  r,g,b = getcolor(c)
  hue = db.getHUE(r,g,b,graytolerance) --hue = pallist[n][5] -- AddHSBtoPalette uses 0 greytolerance so it's not very good here.
  bri = pallist[n][7]
  --sat = math.floor(db.getRealSaturation(r,g,b)*20)-2
  db.drawDisc(ox+bri*x_scale+space,math.floor(oy+hue*y_scale+space),sz/2,c) -- don't use floor(xp) here

  if bri < mark_dark_limit and c ~= gry48 then
   -- This is quick fix, so it's a little untested. Keep an eye out for odd sizes or offsets (looks good so far)
   -- Supports discs of both even and odd width...and the normal odd requires x.5 values
   -- So a Bresenham circle of r=2 would be r=2.5 for db.drawDiscOutline or db.drawCircle (disc)
   db.drawDiscOutline(math.floor(ox+bri*x_scale+space), math.floor(oy+hue*y_scale+space), sz/2, c, gry48) 
  end

  if briplot_flag then
   xp = math.floor(bri*x_scale+space)
   putpicturepixel(ox+xp, oy+sy+brilev[xp+1] ,c) 
   brilev[xp+1] = brilev[xp+1] + 1  
  end

 end -- n
 -- eof colors

end
-- eof drawBriHuePlotDiagram


-- ox,oy:     position
-- width:     physical width of diagram
-- zscale:    scale height of diagram, nom = 1.0
-- pallist:   palette list -- use db.fixPalette(db.makePalList(256),1)
-- plotscale: adjust (relative) size of color plots (they also auto size depending on colorcount), nom = 1.0
-- view:      preset diagram options (rotation views), select 1 or 2
-- bri_base:  base brightness of frame, typically 32-48
-- bri_mult:  brightness multiple for frame depth effect, typically 16. Set to 0 for a diagram of solid color (bri_base)
-------------------------------------
function db.drawIsoCubeRGB_Diagram(ox,oy,width,zscale,pallist,plotscale,view, bri_base,bri_mult) -- keep width at multiples of 16 for good lines

 local r,g,b,xstep,ystep,zstep,div,sz,rgb,col,e,d,step,c,m,l,q,hmult
 local colors, lines, i, r2,g2,b2
 local drawIsoLines

 div = width / 512 -- div*256 = width / 2
 
 hmult = 1.25^0.5 -- (1^2 + 0.5^2)^0.5 -- height (z-axiz) multiple to make height physically the same length as x & y sides

 -- Image is centered on origo, adjust for desired position
 ox = ox + width / 2
 oy = oy + width / 2 * zscale * hmult 

 -- scale
 xstep = div * 1
 ystep = div * 0.5
 zstep = div * zscale * hmult


-- Draw Iso-Cube
function drawIsoLines(lines,xstep,ystep,zstep,bri_base,bri_mult)
 local v,l,n,c1,c2,r1,g1,b1,r2,g2,b2,x1,y1,x2,y2,bri,c,q,col,c0

 col = {}; 
 for n = 0, 3, 1 do
  q = bri_base + n * bri_mult; col[n+1] = matchcolor(q,q,q) 
 end
 c0 = matchcolor(0,0,0); if col[1] == c0 then col[1] = col[2]; end
 
 v = 255 -- (0..255 = 256 in length)
 for n = 1, #lines, 1 do
   l = lines[n]
   c1,c2,bri = l[1], l[2], l[3]
   r1,g1,b1 = c1[1]*v, c1[2]*v, c1[3]*v
   r2,g2,b2 = c2[1]*v, c2[2]*v, c2[3]*v
   x1 = ox + g1*xstep - r1*xstep  
   y1 = oy + r1*ystep + g1*ystep - b1*zstep
   x2 = ox + g2*xstep - r2*xstep  
   y2 = oy + r2*ystep + g2*ystep - b2*zstep
   --drawline(x1,y1,x2,y2,col[bri+1])
   db.line(x1,y1,x2,y2,col[bri+1])
   --q = bri_base + bri * bri_mult; db.lineTranspAA(x1,y1,x2,y2,q,q,q,1) 
 end

end
-- eof draw isocube

 -- r,g,b,bri
 lines = {{{0,0,0},{1,0,0},1}, {{0,0,0},{0,1,0},1}, {{0,0,0},{0,0,1},0}, {{0,0,1},{1,0,1},1}, {{0,0,1},{0,1,1},1},
          {{1,1,0},{1,0,0},3}, {{1,1,0},{0,1,0},3}, {{1,0,0},{1,0,1},2}, {{0,1,0},{0,1,1},2}}
 drawIsoLines(lines,xstep,ystep,zstep,bri_base,bri_mult)


 colors = #pallist
 sz = math.min(8, math.floor(48 / math.sqrt(colors))) * plotscale
 sz = math.max(0.5,math.floor(sz*2)*0.5) -- round to closest 0.5

 for n = 1, colors, 1 do

  i = pallist[n] -- r,g,b,n,h,s,b
  r,g,b,c = i[1],i[2],i[3],i[4] 

  --
  --    B
  --    |
  --   / \
  --  R   G
  --
  -- View 1 (default)
  r2,g2,b2 = r,g,b
 
  if view == 2 then -- iso 2 (rotated 90 degrees around green axis)
   r2 =-b + 255
   g2 = g
   b2 = r
  end

  x = g2*xstep - r2*xstep  
  y = r2*ystep + g2*ystep - b2*zstep
  db.drawDisc(ox+x,oy+y,sz,c)

end

end
-- eof drawIsoCube ---------------------------------



-- Levels:      # of saturation levels or individual Bri-Hue diagrams
-- sat_f:       Saturation function; use [db.getSaturation] for HSL
-- pallist:     Palette list with HSB added: use db.addHSBtoPalette((db.fixPalette(db.makePalList(256),1))
-- xpos:        Horizontal position of diagram 
-- ypos:        Vertical pos.
-- Width:       Width of diagram
-- Height:      Exact Height of ONE level/diagram
-- plotsize:    Radius of colorplots; use 0.5 for single pixels
-- spacing:     Vertical space between each level/diagram, use -1 for frame overlap
-- padding:     Diagram inner padding, min space between plots and frame
-- gauge_flag:  Additional distribution meter left of each level/diagram. Displays fraction of palette colors at each saturation level.
-- gauge_width: Width of gauge-meter; minimum 1 pixel.
-- (greytolerance:) 0..1 Optional
-- Example:
-- palList = db.addHSBtoPalette((db.fixPalette(db.makePalList(256),1))
-- db.drawSatLevelsBriHue_Diagrams(5, db.getSaturation, palList, 10,10, 200, 100, 2.5, 1, 0, true, 2)
---------------------------------------
function db.drawSatLevelsBriHue_Diagrams(Levels, sat_f, pallist, xpos,ypos, Width, Height, plotsize, spacing, padding, gauge_flag, gauge_width, greytolerance)

 local n,is,ds,bs,bsl,hml,ht,div,r,g,b,c,hue,bri,sat,Yspace,Ispace,sz,ax,ay,lev,gry_offset
 local c128,c96,c80,c64,c48,lh,frac,ao,dots

 Yspace = spacing   -- Box Y spacing (-1 = overlap)
 Ispace = padding   -- Plot padding
     sz = plotsize -- Plot size (radius)
 --
 div = 255 / Levels
 
 is = Ispace + 1 + math.floor(sz)   -- box inner spacing (expand frame size)

 Width  = Width  - is*2 -- Adjustment to force diagram to desired size (regardless of other settings)
 Height = Height - is*2

 bs = (Width-1) / 255 -- Edge(0) to Edge(255) makes a gradient of x length over x-1 pixels
 bsl = Width 
 
 hml = Height / 6.0 -- 6.5 to fit grayscales inside
 ht  = Height

 ds = Yspace + Height + is*2 -- box y space

 c128,c96,c80,c64,c48 = matchcolor(128,128,128), matchcolor(96,96,96), matchcolor(80,80,80), matchcolor(64,64,64), matchcolor(48,48,48)

 function p(x,y,c) putpicturepixel(x,y,c); end

 -- HueBri boxes
 for n = 0, Levels-1, 1 do

  ax = xpos
  ay = ypos+ds*n
  lh = ht+is*2
  db.drawRectangleLine(ax, ay, bsl+is*2, lh, c48)
  -- Some fancy specualarities at the corners
  p(ax,ay,c128); p(ax+1,ay,c80); p(ax+2,ay,c64); p(ax+3,ay,c64); p(ax,ay+1,c80); p(ax,ay+2,c64)
  p(ax+bsl+is*2-1,ay+lh-1,c80);p(ax+bsl+is*2-1,ay+lh-2,c64); p(ax+bsl+is*2-2,ay+lh-1,c64)

  -- Distribution Gauge
  if gauge_flag then
   db.drawRectangleLine(ax-gauge_width-3, ay, gauge_width+2, lh, c64); p(ax-gauge_width-3, ay, c96)
  end

 end

 
 --greytolerance = 0.095 
 if greytolerance == null then
  greytolerance = 4.8 / (39+Levels^3) -- 0.120 - 0.102 - 0.073 - 0.047 - 0.029
 end

 dst = db.newArrayInit(Levels+1,0) 

 for n = 1, #pallist, 1 do

   c = pallist[n] -- r,g,b,n,h,s,b
   r,g,b,c,bri = c[1],c[2],c[3],c[4],c[7]
   hue = db.getHUE(r,g,b,greytolerance) 
   sat = sat_f(r,g,b)

   gry_offset = 0
   if hue == 6.5 then -- Quick fix, display all "grayscales" in lowest saturation box
     sat, hue, gry_offset = 0, 6.0, is*2 + 1 -- grayscales are drawn 2 pixels below bottom fram at all times
   end 

   lev = (Levels-1) - math.floor(sat*0.9999 / div)

   -- Level distribution: Don't count grayscales in the sat-distribution. Note that (altered) hue work as offset for gray-plots
   -- Grayscales are by default included in the lowest saturation level, we want to exclude them here...
   if hue < 6.0 then 
     dst[lev+1] = dst[lev+1] + 1 
   end

   if sz > 0.5 then
     db.drawDisc(xpos+bri*bs+is, ypos+hue*hml+ds*lev+gry_offset+is, sz, c) -- +1 coz frame is at xpos,ypos
      else
      putpicturepixel(xpos+bri*bs+is, ypos+hue*hml+ds*lev+gry_offset+is, c)
   end

  end -- n

 -- Distribution Gauge Results
 if gauge_flag then
  for n = 0, Levels-1, 1 do
   ax = xpos
   ay = ypos+ds*n
   lh = ht+is*2
   frac = (dst[n+1] / #pallist)
   ao = math.floor(ay + (lh-(lh*frac))/2 + 0.5)
   dots = math.floor(frac * (lh-2)/1 + 0.5) -- rounding
   if frac > 0 then dots = math.max(1,dots); end -- mark all levels that has colors with at least one dot

   db.drawRectangle(ax-gauge_width-2, ao, gauge_width, dots, c128)

  end
 end
 -- 
   
end
----- eof drawSatLevelsBriHue_Diagrams -------

--
-- Match diagram of a two RGB-values ramp with optional brightness-weight across the vertical
--
-- bw_lo:  Start Brightness weight (use same bw for lo & hi for a solid diagram)
-- bw_hi:    End Brightness weight
-- bw_exp: Change Exponent; nom = 1.0, use <1.0 for faster change towards the End weight, f.ex 0.5.
--
--
function db.drawRampDiagram(pallist,posx,posy,width,height,r1,g1,b1,r2,g2,b2, bw_lo, bw_hi, bw_exp)
 local wf,hf,w,h,bri,c,f,e,bw,r,g,b,bw_mult,px
 bw_lo  = bw_lo or 0
 bw_hi  = bw_hi or 0.85
 bw_exp = bw_exp or 1.0
 bw_mult = bw_hi - bw_lo
 wf = 1/(width-1)
 hf = 1/(height-1)

 pallist = db.addUnNormalizedBrightness2Palette(pallist)

 for w = 0, width-1, 1 do -- Ramp pos
  f = w * wf
  e = 1 - f

  r = r1*e + r2*f
  g = g1*e + g2*f
  b = b1*e + b2*f
 
  px = posx + w

  if bw_mult ~= 0 then
   for h = 0, height-1, 1 do -- Match
    bw = bw_lo + (h*hf)^bw_exp * bw_mult 
    --c = db.getBestPalMatchHYBRID({r,g,b},pallist,bw,true)
    c = db.getBestPalMatch_Hybrid(r,g,b,pallist,bw,true)
    putpicturepixel(px, posy + h, c)
   end
  end

  if bw_mult == 0 then -- Linear (same bri-weight over y)
    --c = db.getBestPalMatchHYBRID({r,g,b},pallist,bw_lo,true)
    c = db.getBestPalMatch_Hybrid(r,g,b,pallist,bw_lo,true)
    for h = 0, height-1, 1 do 
     putpicturepixel(px, posy + h, c)
    end
  end

  if w%32 == 0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end
end
--

--
-- db.drawRampDiagram control function
--
function db.drawRamp_dual(pallist,posx,posy,width,height,r1,g1,b1, r2,g2,b2, r3,g3,b3, bw_lo, bw_hi, bw_exp)
 local wd
 wd = width / 2
 db.drawRampDiagram(pallist,posx,     posy, wd,height, r1,g1,b1, r2,g2,b2, bw_lo, bw_hi, bw_exp)
 db.drawRampDiagram(pallist,posx + wd,posy ,wd,height, r2,g2,b2, r3,g3,b3, bw_lo, bw_hi, bw_exp)
end
--


------------------------------------------------------------------
-- Render a diagram of a gradient between two RGB-values (x) across a gradient of two Gamma-values (y) with optional Ordered Dither
--  or just a RGB-gradient with one specific Gamma-value.
--  A gradient with Gamma-values of 1.0 & 1.0 will produce a basic/classic linear color gradient. 
--
-- rgb0, rgb1: RGB-values in array format {r,g,b}, ex: {255,255,0}
--    gam_min: Lower Gamma-value, +1.0 (Top side of diagram)
--    gam_max: Upper Gamma-value, +1.0
--      width: Width of diagram, Color-axis
--     height: Height of diagram, Gamma-axis
--   
--    posx,posy: Diagram position/offset [Optional]
--    briweight: Colormatch Brightness-weight 0..1, default = 0.25 [Optional]
-- dither_power: Ordered Dither power 0..1, default is 0 (off) [Optional]
--     done_upd: Done-meter update frequency, Nominal = 2 (every 2nd frame), 0 = inactive (no scanline or screen update) [Optional]
--      pallist: Palette list [ex: db.fixPalette(db.makePalList(256),1)] enables custom hybrid colormatch, uses "{}" for none [Optional]
--
-- Example: A gradient of 512x128 pixels between yellow and blue from no gamma (1.0) to standard correction of 2.2
--          Located at coord 75,50, with a 25% brightness-weight (0.25) and 50% dithering (0.5)                        
--          db.gammaGradientDiagram({255,255,0},{0,0,255},1.0,2.2, 512,128, 75,50,0.25,0.5)
--
function db.drawGammaGradientDiagram(rgb0,rgb1,gam_min,gam_max,width,height, posx,posy,briweight,dither_power,done_upd,pallist)

 local x,y,c,p,m,gam,rgam,r0,g0,b0,r1,g1,b1,r2,g2,b2,xf,yf,xs1m,yp,r0g,g0g,b0g,r1g,g1g,b1g,dither,hybrid,gam_dif,update
 local rxf,dithfunc

 posx = posx or 0
 posy = posy or 0
 briweight = briweight or 0.25
 dither_power = dither_power or 0
 pallist = pallist or {}
 done_upd = done_upd or 2

 update = false; if done_upd > 0 then update = true; end
 hybrid = false; if #pallist > 0 then hybrid = true; end
 dither,p = false,0; if dither_power > 0 then dither = true; end
 
 gam_dif = gam_max - gam_min

 dithfunc = db.dithOrder2x2
 --dithfunc = db.dithOrder4x4

 r0,g0,b0 = rgb0[1],rgb0[2],rgb0[3]
 r1,g1,b1 = rgb1[1],rgb1[2],rgb1[3]

 xs1m = 1 / (width - 1)

 if gam_dif == 0 then -- These values won't change with a constant Gamma
  gam = gam_min; rgam = 1/gam
  r0g,g0g,b0g = r0^gam, g0^gam, b0^gam
  r1g,g1g,b1g = r1^gam, g1^gam, b1^gam 
 end

 for x = 0, width-1, 1 do
  xf = x * xs1m
  rxf = 1 - xf 

  if gam_dif > 0 then
   for y = 0, height-1, 1 do
    yf = y / (height-1)
    gam = gam_min + gam_dif * yf; rgam = 1/gam
    r0g,g0g,b0g = r0^gam, g0^gam, b0^gam
    r1g,g1g,b1g = r1^gam, g1^gam, b1^gam
    if dither then 
     p = dithfunc(x,y) * dither_power
    end
    r2 = (r0g * rxf + r1g * xf)^rgam + p
    g2 = (g0g * rxf + g1g * xf)^rgam + p
    b2 = (b0g * rxf + b1g * xf)^rgam + p
    if hybrid then
     c = db.getBestPalMatchHYBRID({r2,g2,b2},pallist,briweight,true) else c = matchcolor2(r2,g2,b2,briweight)
    end
    putpicturepixel(posx + x, posy + y, c)
   end
  end

  if gam_dif == 0 then
   -- gam/rgam calculated before x loop
   r2 = (r0g * rxf + r1g * xf)^rgam
   g2 = (g0g * rxf + g1g * xf)^rgam
   b2 = (b0g * rxf + b1g * xf)^rgam
   
   if dither then -- must do colormatch for each pixel
    for y = 0, height-1, 1 do 
     p = dithfunc(x,y) * dither_power
     if hybrid then
      c = db.getBestPalMatchHYBRID({r2+p,g2+p,b2+p},pallist,briweight,true) else c = matchcolor2(r2+p,g2+p,b2+p,briweight)
     end
     putpicturepixel(posx + x, posy + y, c)
    end
   end

   if dither == false then
    if hybrid then
     c = db.getBestPalMatchHYBRID({r2,g2,b2},pallist,briweight,true) else c = matchcolor2(r2,g2,b2,briweight)
    end
    for y = 0, height-1, 1 do
     putpicturepixel(posx + x, posy + y, c)
    end
   end
   
  end -- gam_dif == 0

  if update and db.donemeter_x(done_upd,x,width,height,true,posx,posy) then return; end
 end

end
-- gammaGradientDiagram



--------------------------------------------------------------
-- [NOTE: This diagram will work for any functions returning a 0..255 value from rgb-input, not just saturation]
-- Saturation (comparison) Diagram, may draw one single, or two comparative diagrams side-by-side. Vertically or Horizontally.
--
-- Saturation functions sat(r,g,b)-->0..255 
-- sat_f1: Saturation function 1; use nil or an undefined to turn of and let the other one scale to fill the width
-- sat_f2: Saturation function 2; use nil or an undefined to turn of and let the other one scale to fill the width
--  width: total span of diagram along the saturation-axis (height if horizontal_flag=true). Odd values are best.
--   cols: Max number of colors (or rows) displayed, i.e height.
-- separ.: Odd value. Separation between the two sides of the diagram (or half the distance to grayplot line)
--   size: Thickness of color-bars in pixels (default is 1)
-- bspace: Spacing between color-bars (default is 1) 
-- horizontal_flag: Horizontal orientation of diagram, i.e. 90 degree rotation
-- hollow_flag: Hollow out (outlined) background bars if size >= 3, activated by default
--
-- ex: saturationComp(db.getSaturation,nil, db.fixPalette(db.makePalList(256),1), 100,50, 69, 32, 3, 2,1, false)
--
function db.saturationComp_Diagram(sat_f1,sat_f2,pallist,xpos,ypos,width,cols,separation, size,bspace, horizontal_flag, hollow_flag)

 local yp,n,l,c,r,g,b,cx,x_scale,sat1,sat2,c0,c32,c48,c64,c80,s50,div,plot1,plot2,line1,line2,plot,mf,s,sum,noplot,noline
 local x0,x1,hf

 mf = math.floor

 size   = size or 1
 bspace = bspace or 1
 
 if hollow_flag == nil then hollow_flag = true; end

 -- Lottsa function trickery to allow for diagram orientations and usage of either side or both
 function noplot(x,y,c)
  -- Do nothing
 end
 function noline(x1,y1,x2,y2,c)
  -- Do nothing
 end

 diag1 = true; if sat_f1 == nil then diag1 = false; end
 diag2 = true; if sat_f2 == nil then diag2 = false; end

 div = 2; if diag1 == false or diag2 == false then div = 1; end

 plot1,plot2,plot = putpicturepixel, putpicturepixel, putpicturepixel
 line1,line2 = db.line, db.line

 if horizontal_flag then -- make diagram horizontal
  xpos,ypos = ypos,xpos
  function line1(x1,y1,x2,y2,c) db.line(y1,x1,y2,x2,c); end
  function plot1(x,y,c) putpicturepixel(y,x,c); end
  line2,plot2,plot = line1,plot1,plot1
 end 

 if diag2 and diag1 == false then xpos = xpos - width; end -- correct offset if only one diagram
  
 if diag1 == false then plot1,line1 = noplot,noline; end
 if diag2 == false then plot2,line2 = noplot,noline; end

 separation = separation or 1
 
 sp = math.ceil(separation/2)

 x_scale = (width/div - sp - 1) / 255          -- -1 is for border

 cx = xpos + math.floor(255*x_scale) + sp + 1  -- +1 is for border
 s50 = math.floor(127.5*x_scale)

 c0,c32,c48,c64,c80  = matchcolor(0,0,0),matchcolor(32,32,32),matchcolor(48,48,48),matchcolor(64,64,64),matchcolor(80,80,80)
 --if c32 == c0 then c32 = c48; end

 xs = math.floor(255 * x_scale)

 --db.line(cx-xs-sp, ypos-2, cx+xs+sp, ypos-2, c64) -- top line

 for s = 0, size-1,1 do -- size (1 = single pixel)
  for n = 0, cols-1, 1 do
   yp = ypos + n*(size+bspace) + s
   line1(cx-xs-sp, yp, cx-sp, yp, c48)
   line2(cx+xs+sp, yp, cx+sp, yp, c48)
   plot1(cx-xs-sp-1,yp+bspace,c64)
   plot2(cx+xs+sp+1,yp+bspace,c64)
   plot1(cx-xs-sp-1,yp,  c80)
   plot2(cx+xs+sp+1,yp,  c80)
  end
 end -- size
 
 -- Half sat lines
 line1(cx-s50-sp, ypos, cx-s50-sp, ypos+(cols+1)*2*size, c0)
 line2(cx+s50+sp, ypos, cx+s50+sp, ypos+(cols+1)*2*size, c0)

 pallist = db.sorti_clone(pallist,4) -- The pallist may be brightness-sorted, so sort in order of pal-index
 for s = 0, size-1,1 do
  sum = 0
  for n = 1, #pallist, 1 do
   l = pallist[n] -- r,g,b,n
   r,g,b,c = l[1],l[2],l[3],l[4]
   if sum < cols then -- c instead of sum for pal-index (in case colors have been omitted, leaving gaps)

    sat1 = 999; if diag1 then sat1 = sat_f1(r,g,b) * x_scale; end
    sat2 = 999; if diag2 then sat2 = sat_f2(r,g,b) * x_scale; end

    yp = ypos + sum*(size+bspace) + s -- c instead of sum for pal-index

    if sat1 > 0 then 
     line1(cx-mf(sat1)-sp, yp, cx-sp, yp, c)
    end

      -- Hollow background color SAT1
      if size >= 3 and s>0 and s<size-1 and hollow_flag then
        x0 = cx-xs-sp
        x1 = cx-sp-mf(sat1)-3
        if x1>=x0 then
         line1(x0, yp, x1, yp, c0)
        end
      end

    if sat2 > 0 then 
     line2(cx+mf(sat2)+sp, yp, cx+sp, yp, c)
    end

      -- Hollow background color SAT2
      if size >= 3 and s>0 and s<size-1 and hollow_flag then
        x0 = cx+xs+sp
        x1 = cx+sp+mf(sat2)+3
        if x1<=x0 then
         line2(x0, yp, x1, yp, c0)
        end
      end

    if sat1 == 0 or sat2 == 0 then
     plot(cx,yp,c)
    end

    plot1(cx-mf(sat1+1)-sp,yp,c0)
    plot2(cx+mf(sat2+1)+sp,yp,c0)

   end 
 
  sum = sum + 1 
  end
 end -- size

end    
--


-- Brightness-Saturation Diagram
--
-- pallist:          Palette list with HSB-values added.
-- ox,oy:            Position
--   hue:            Hue in degrees adjusted to 0..255 (just use deg / 360 * 255)          
--
function db.drawBriSatDiagram(pallist,ox,oy,xsize,ysize,hue)

 local x,y,c,bri,sat,xf,yf

 xf = 1 / (xsize-1) * 255 
 yf = 1 / (ysize-1) * 255

 for y = 0, ysize-1, 1 do

  bri = 255 - yf * y
 
  for x = 0, xsize-1, 1 do
   
    sat = 255 - xf * x 
 
    c = db.matchcolorHSB(hue,sat,bri,pallist,true) -- overshooting brightness some doesn't seem to matter

    putpicturepixel(ox+x,oy+y,c)
   
  end 
  if y%10==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end
 end

 
end -- BriSat
--


--
-- Backdrop of color,black,white and complementary. Gradient from color & comp. to all grayscales.
--
function db.complementaryDiagram(ox,oy,xsize,ysize,pallist,r0,g0,b0,  briweight,gamma,dither_power)

 local r3,g3,b3,xu,yu,x,y,xf,yf,xr,yr,c,rgam,white,mult,p,dither,wxf,xryr,xfyf, oyy

 dither_power = dither_power or 0
 briweight = briweight or 0.25
 gamma = gamma or 1.0

 --r3,g3,b3 = 255-r0,255-g0,255-b0

 rgam = 1 / gamma
 r3,g3,b3 = (255-r0)^gamma,(255-g0)^gamma,(255-b0)^gamma
 r0,g0,b0 = r0^gamma, g0^gamma, b0^gamma
 white = 255^gamma

 xu = 1 / (xsize-1)
 yu = 1 / (ysize-1)

 -- ordered dither
 dither = false
 if dither_power > 0 then
  mult = db.dithOrder_getMultByPalSize(#pallist) * dither_power
  dither = true
 end


 pallist = db.addUnNormalizedBrightness2Palette(pallist)


 for y = 0, ysize - 1, 1 do

   yf = y * yu; yr = 1 - yf
   oyy = oy + y
 
   for x = 0, xsize - 1, 1 do

    xf = x * xu; xr = 1 - xf
  
    xryr,xfyf = xr * yr, xf * yf

    wxf = white * xf * yr
  
    --r = (r0*xr + 255*xf)*yr + r3*xf*yf; -- optimzied for black and white corners
    --g = (g0*xr + 255*xf)*yr + g3*xf*yf;
    --b = (b0*xr + 255*xf)*yr + b3*xf*yf;

    r = (r0*xryr + wxf + r3*xfyf)^rgam -- optimzied for black and white corners
    g = (g0*xryr + wxf + g3*xfyf)^rgam
    b = (b0*xryr + wxf + b3*xfyf)^rgam

    if dither then 
     p = db.dithOrder2x2(x,y) * mult
     --p = db.dithOrder4x4(x,y) * mult
     r = r + p
     g = g + p
     b = b + p
    end
  
    --c = db.getBestPalMatchHYBRID({r,g,b},pallist,briweight,true)
    c = db.getBestPalMatch_Hybrid(r,g,b,pallist,briweight,true)
 
    putpicturepixel(ox+x, oyy, c);

   end

   if y%16 == 0 then
    updatescreen(); if (waitbreak(0)==1) then return; end
   end

 end
end
--


--
-- Hue-Saturation Diagram
--
-- Dependencies:  db.drawHexagon, db.plotCircle, db.drawDiscOutline,  db.filledDisc, db.getHUE
--
-- sat_func:      saturation function with return value 0..1 (ex: db.getPurity, db.getSaturationHSV)
-- cx,cy:         Diagram center position
-- rd:            Radius
-- (min_sz,max_sz): Min & Max radius of color-markers
-- (greytolerance): 0..1, Grayscale threshold. 0 = only pure grayscales considered grayscales, 1 = all colors considered grayscales. Nom = 0.01
-- (bri_frame):   Optional. Preferred brightness/grayscale-value for diagram frame (default = 48)
-- (mark_dark_limit): Optional. Colors darker than this value (nominal = 40) are circled for readability. Set to -1 to deactivate. 
--
-- ex: db.drawHueSaturationDiagram(db.getPurity, db.fixPalette(db.makePalList(256),1), 100,100,80, 2,4)
--
function db.drawHueSaturationDiagram(sat_func, pallist, cx,cy,rd,  min_sz,max_sz, greytolerance, bri_frame, mark_dark_limit)

 local c,i,n,o,s,r,g,b,x,y,m,mf,rad,sat,hue,radius

 m,mf = math, math.floor
 
 min_sz = min_sz or 2
 max_sz = max_sz or 4
 greytolerance = greytolerance or 0.01
 bri_frame = bri_frame or 48
 mark_dark_limit = mark_dark_limit or 40

 c = matchcolor(bri_frame, bri_frame, bri_frame)

 --db.drawDisc(cx,cy,rd,c) --db.ellipse(x,y,a,b,stp,rot,col) 
 --db.ellipse(cx,cy,rd,rd,6,30,c) -- Hexagon 
 db.drawHexagon(cx,cy,rd+0.5,c) -- r+0.5 to make it big enough to line up with primaries, puts top corner pixel outside circle though
 --db.ellipse(cx,cy,rd,rd,120,30,c) -- circle
 db.plotCircle(cx,cy,rd,c)

 if rd >= 40 then

  s = 4
  if rd <= 80 then s = 3; end
  if rd <= 50 then s = 2; end

  --db.drawCircleDotted(cx,cy,rd*0.25,s,c)
  db.plotCircle(cx,cy,m.floor(rd*0.25),c,s)

  --db.drawCircleDotted(cx,cy,rd*0.50,s,c)
  db.plotCircle(cx,cy,m.floor(rd*0.50),c,s)

  --db.drawCircleDotted(cx,cy,rd*0.75,s,c)
  db.plotCircle(cx,cy,m.floor(rd*0.75),c,s)

 end

  putpicturepixel(cx,cy,c)
  for n=2, 5, 1 do
   putpicturepixel(cx+n,cy,c)
   putpicturepixel(cx-n,cy,c)
   putpicturepixel(cx,cy+n,c)
   putpicturepixel(cx,cy-n,c)
 end


for n=1, #pallist, 1 do

 o = pallist[n] -- r,g,b,i,h,s,b
 r,g,b,i = o[1],o[2],o[3],o[4]
 hue = db.getHUE(r,g,b,greytolerance)

  rad = hue/6 * m.pi * 2 - m.pi/2
  sat = sat_func(r,g,b)

  if hue == 6.5 then sat = 0; end -- Set Saturation to 0 if Hue is considered a grayscale

  x = cx + m.cos(rad) * rd * sat 
  y = cy + m.sin(rad) * rd * sat 
 
  radius = min_sz + mf(sat*(max_sz-min_sz)+0.2) -- +0.2 so max-size is not only for 100% saturation

  db.filledDisc(mf(x+0.5), mf(y+0.5), math.floor(radius), i) -- Bresenham. floor(v+0.5) to counter rounding offset &  assure symmetry

   --db.drawDisc(x,y,radius+0.5,i) -- disc
   --putpicturepixel(m.floor(x+0.5),m.floor(y+0.5),i)
   --drawdisk(m.floor(x),m.floor(y),m.floor(min_sz + m.floor(sat*(max_sz-min_sz)+0.2)),i)
   --db.plotCircle(m.floor(x), m.floor(y), m.floor(min_sz + m.floor(sat*(max_sz-min_sz)+0.2)), i)

   
  if db.getBrightness(r,g,b) < mark_dark_limit then
   -- Supports discs of both even and odd width...and the normal odd requires x.5 values
   -- So a Bresenham circle of r=2 would be r=2.5 for db.drawDiscOutline or db.drawCircle (disc)
   db.drawDiscOutline(mf(x+0.5),mf(y+0.5),radius+0.5,i,c) 
  end

 end

end
-- HueSaturation Diagram
--


---------------- eof Diagrams -------------------------------



---------------------------------------
-----------    DITHERS     ------------ 
---------------------------------------



-- Return a Ordered dither power multiplier depending on palette size (to be applied to the base x8 in dithOrder())
-- So final power in dithOrder() for 8 colors is x16
-- 2-8 colors = x2    (x8 = 16.0)
--  16 colors = x1.15 (x8 =  9.2)
--  32 colors = x0.86 (x8 =  6.9)
-- 256 colors = x0.65 (x8 =  5.2)
function db.dithOrder_getMultByPalSize(palsize)
 local mult
 mult = 2
 if palsize > 8 then
  -- Palsize adjusted Power: x2 (8 cols) .. x0.65 (256 cols)
  mult = (32 - 22*(1 - 5 / (palsize - 3))) / 16 -- Yeah, wacky formula but it adjust pretty well for number of colors, it also works here for different size matrixes
 end
 return mult
end
--


--
function db.dithOrder2x2(x,y)
 local m,opow
 m = {1,3, 4,2} -- 2x2           
 return (m[1 + y%2*2 + x%2] - 2.5) * 5.335  -- return a value between -8 and 8 
end
--
--p,q,m = 0, 3, {1,4,9, 8,2,6, 5,7,3} -- 3x3 (imperfect)


--
function db.dithOrder4x4(x,y)
 local m
 m = {1,9,3,11, 13,5,15,7, 4,12,2,10, 16,8,14,6} -- 4x4
 return (m[1 + y%4*4 + x%4] - 8.5) * 1.067 -- return a value between -8 and 8 
end
--


-- Ordered Dither, Fractional versions (_frac). F.ex. Used for intermidiate values in gradients.
-- Returns values between 1/(size+1) and size/(size+1), that is 0..1, but never 0 or 1.
-- F.ex a 2x2 matrix can return the values: 0.0, 0.25, 0.5, & 0.75

--
function db.dithScanline8(x,y)
 local m
 if x == -1 then return 1/8; end 
 m = {1,2,3,4,5,6,7,8} 
 return m[1 + y%8] / 8 - 1/8 
end
--

--
function db.dithOrderNONE_frac(x,y) -- No Dither at all
 local m
 if x == -1 then return 1; end 
 return 0
end
--



--
function db.dithTest2x2(x,y)
 local m,opow
 if x == -1 then return 1/4; end -- return Gradient expansion value (to fit last color: A...B... C)
 m = {0.75,0.75, 0,0} -- 2x2           
 return (m[1 + y%2*2 + x%2])  
end
--

--
function db.dithTest8x8(x,y)
 local m,opow
 if x == -1 then return 0.2; end -- return Gradient expansion value (to fit last color: A...B... C)
 m = {1,1,1,0,0,0,0,0,
      1,0,1,0,2,3,3,2,
      1,1,1,0,3,0,0,3,
      0,0,0,0,2,3,3,2,
      3,4,3,0,0,0,0,0,
      4,0,4,0,1,2,1,0,
      3,4,3,0,2,0,2,0,
      0,0,0,0,1,2,1,0}         
 return (m[1 + y%8*8 + x%8]) * 0.2
end
--


--
function db.dithOrder2x2_frac(x,y) -- Returns 0.0, 0.25, 0.5, & 0.75
 local m
 if x == -1 then return 1/4; end -- return Gradient expansion value (to fit last color: A...B... C)
 m = {1,3, 4,2} -- 2x2 
 return m[1 + y%2*2 + x%2] / 4 - 1/4     
 --return m[1 + y%2*2 + x%2] / 5
end
--

--
function db.dithOrder4x4_frac(x,y)
 local m
 if x == -1 then return 1/16; end 
 m = {1,9,3,11, 13,5,15,7, 4,12,2,10, 16,8,14,6} -- 4x4
 return m[1 + y%4*4 + x%4] / 16 - 1/16 
 --return m[1 + y%4*4 + x%4] / 17 
end
--

--
function db.dithOrder8x8_frac(x,y) -- 8x8
 local m
 if x == -1 then return 1/64; end 
 m = {1, 33, 9,41, 3,35,11,43, 
      49,17,57,25,51,19,59,27, 
      13,45, 5,37,15,47, 7,39, 
      61,29,53,21,63,31,55,23,
       4,36,12,44, 2,34,10,42,
      52,20,60,28,50,18,58,26,
      16,47, 8,40,14,46, 6,38,
      64,32,56,24,62,30,54,22
     }
 return m[1 + y%8*8 + x%8] / 64 - 1/64
 --return ((x*x + x*y + y*y)%64) / 64  
 --return m[1 + y%8*8 + x%8] / 65 
end
--


--  Render (Ordered-dithered) function using the palette colors between the Pen-colors
--
-- f:           function that takes the arguments (x,y,w,h) and returns a fractional value 0..1 (ex: db.getBrightness(r,g,b)/255) or x/w (Horizontal gradient) 
-- w,h:         screen/draw area dimensions
-- start_index: 1st Color index in Palette gradient
-- end_index:   Last Color index in Palette gradient
-- dith_f:      Dither function, ex db.dithOrder2x2_frac, db.dithOrder4x4_frac or db.dithOrder8x8_frac, No arg produces a non-dithered ramp.
--
function db.gradientRender(f, w,h, start_index, end_index, dith_f, ofx, ofy)
 local x,y,cols,c

 ofx = ofx or 0
 ofy = ofy or 0

 if dith_f == null then 
  dith_f = (function(x,y) return 0; end) -- No Dither, Just colors
  cols  = end_index - start_index + 0.9999999
   else
     -- We want to draw A...B...C (x steps) and not A...BB...C (x+1 steps), But x steps only gives A...B... so we must extend the range by 1/x to just add C
    cols = end_index - start_index -- (= colors - 1, since dither adds up to 0.9846...)
    cols = cols + dith_f(-1,0) - 0.0000001 -- Retrieve dither/color expansion value (1/x:  1/4 for 2x2 dither, 1/16 for 4x4, 1/64 for 8x8)
 end
    
 for y = ofy, h-1+ofy, 1 do
  for x = ofx, w-1+ofx, 1 do
   c = start_index + dith_f(x,y) + cols * f(x,y,w,h)
   putpicturepixel(x,y,c)
  end
  if db.donemeter(24,y,w,h,true,ofx,0) then return; end
 end
end
--


------------------------ eof Dithers -------------------------------



--
-- Histograms, remapping etc.
--

--
function db.makeHistogram() 
  local n,y,x,c,w,h,list; list = {}
  w, h = getpicturesize()
  for n = 1, 256, 1 do list[n] = 0; end
  for y = 0, h - 1, 1 do
    for x = 0, w - 1, 1 do
      c = getpicturepixel(x,y)
      list[c+1] = list[c+1] + 1
    end
  end
  return list
end
--

--
function db.makeHistogramIndexed() -- With color index so it can be sorted etc.
  local n,y,x,c,w,h,r,g,b,list; list = {}
  w, h = getpicturesize()
  for n = 1, 256, 1 do
   r,g,b = getcolor(n-1)
   list[n] = {0,n-1,r,g,b}; 
  end
  for y = 0, h - 1, 1 do
    for x = 0, w - 1, 1 do
      c = getpicturepixel(x,y)
      list[c+1][1] = list[c+1][1] + 1
    end
  end
  return list
end
--

--
function db.makeSpareHistogram() 
  local n,y,x,c,w,h,list; list = {}
  w, h = getsparepicturesize()
  --w,h = 512,360
  for n = 1, 256, 1 do list[n] = 0; end
  for y = 0, h - 1, 1 do
    for x = 0, w - 1, 1 do
      c = getsparepicturepixel(x,y)
      list[c+1] = list[c+1] + 1
    end
  end
  return list
end
--


--
-- Makes a palette-list from only the colors (histogram) that occurs in the image
-- Assumes image/palette has not changed since histogram was created
function db.makePalListFromHistogram(hist) 
  local n,r,g,b,list,count
  list = {}
  count = 1
  for n = 1, #hist, 1 do
    if hist[n] > 0 then
      r,g,b = getcolor(n-1)
      list[count] = {r,g,b,n-1}
      count = count + 1
    end
  end
  return list
end
--

--
function db.makePalListFromIndexedHistogram(ihist) -- {count,index,r,g,b}
  local n,r,g,b,hc,list,count
  list = {}
  count = 1
  for n = 1, #ihist, 1 do
    hc = ihist[n]
    if hc[1] > 0 then
      list[count] = {hc[3],hc[4],hc[5],hc[2]} -- {r,g,b,index}
      count = count + 1
    end
  end
  return list
end
--

function db.makePalListFromSpareHistogram(hist) 
  local n,r,g,b,list,count
  list = {}
  count = 1
  for n = 1, #hist, 1 do
    if hist[n] > 0 then
      r,g,b = getsparecolor(n-1)
      list[count] = {r,g,b,n-1}
      count = count + 1
    end
  end
  return list
end
--


-- Used by DeCluster, not sure if we should use matchcolor2 instead
function db.remap(org) -- Working with a remap-list there's no need of reading backuppixel
  --messagebox("Remapping")
  local x,y,c,i,w,h,s,f,col
  f = getpicturepixel
  s = false
  w, h = getpicturesize()
  for y = 0, h - 1, 1 do
   for x = 0, w - 1, 1 do
    c = f(x,y)
    i = org[c+1]
    if i == null then i = matchcolor(getbackupcolor(getbackuppixel(x,y))); s = true; col = c; end -- Find color for a removed double
    putpicturepixel(x,y,i)
   end
  end
  if s then messagebox("Remapping: Not all image colors were found in remap-list (re-assign), probably due to duplicate removal. Matchcolor was used, ex: col# "..col); 
  end
end
--

--
-- Same as db.remap but no comments
--
function db.remapImage(colassignlist) -- assignment list is optional
 local x,y,c,w,i,h,assign
 assign = false
 if colassignlist ~= null then assign = true; end
 w,h = getpicturesize()
 for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
    c = getbackuppixel(x,y)
    i = null; if assign then i = colassignlist[c+1]; end
    if not assign or i == null then
     i = matchcolor(getbackupcolor(c))
    end
    putpicturepixel(x,y,i)
 end
 end
end
--

-- Plain image remapping for when the palette has changed
function db.paletteRemap(bw)
 local n,col,w,h,x,y,r,g,b,pallist
 col = {}
 bw = bw or 0.25
 pallist = db.makePalList(256)
 for n = 0, 255, 1 do 
  r,g,b = getbackupcolor(n)
  --col[n+1] = matchcolor2(r,g,b, bw)
  col[n+1] = db.getBestPalMatchHYBRID({r,g,b}, pallist, bw, false)
 end
 w,h = getpicturesize()
 for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
     putpicturepixel(x,y,col[1+getpicturepixel(x,y)])
 end
 end
end
--

-- Set palette to a grayscale gradient and remap image with perceptual brightness
-- This is (as far as I've tested) eq. to my Make Grayscale script.
-- All other remappings will produce slightly differing results, perhaps just due to rounding issues.
function db.setGrayscaleAndRemap()
 local col,c,w,h,x,y
 col = {}
 for c = 0, 255, 1 do
  setcolor(c,c,c,c)
  col[c+1] = math.floor(db.getBrightness(getbackupcolor(c))) 
 end

 w,h = getpicturesize()
 for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
     putpicturepixel(x,y,col[1+getpicturepixel(x,y)])
  end
 end
end
--

--
-- Palette DeCluster: Color-reduction by fusing similar colors into new ones, using a desired tolerance.
--                    This is a method similar to Median-Cut, but more surgical.
--
-- pallist:   Palette list {r,g,b,palette_index}
-- hist:      Histogram {color 0 pixels, color 1 pixels...etc} always a full 256 color list
-- crad:      Cluster radius treshold in % of distance between black & white
--            A value of 0 will only remove identical colors
--            A value of 3-4 will usally fuse redundant colors without causing notice 
-- prot_pow:  (0..10) Protect common colors in histogram. Distances are increased by ocurrence. 
--            Also gives protection to fused colors even if not using histogram (combined nominal weights)
-- pixels:    Pixels in image (so protection can be calculated)
-- rw,gw,bw:  Color weights (rw+gw+bw = 1, 0.33,0.33,0.33 is nominal)
--
-- Returns:
-- a new (c)palette list {r,g,b,{original palette_indices},fused flag, histogram_weight}
-- a remap list (org) [image color + 1] = remap color (in the new palette)
function db.deCluster(pallist, hist, crad, prot_pow, pixels, rw,gw,bw)

 --messagebox(pixels)

 local u,c,a,i,o,j,n,c1,c2,r,g,b,r1,g1,b1,r2,g2,b2,wt,rt,gt,bt,tot,pd
 local worst,wtot,maxdist,maxDist,distfrac,clusterExists,clustVal,count,crad1
 local cList,cPalList,clusterList,fuseCol,orgcols,newPalList,org

 maxdist = math.sqrt(rw*rw*65025 + gw*gw*65025 + bw*bw*65025)
 distfrac = 100 / maxdist

 -- Let's just make a slightly more suitable format of the pallist (List for original color(s))
 cPalList = {}
 for u = 1, #pallist, 1 do
  c = pallist[u]
  cPalList[u] = {c[1],c[2],c[3],{c[4]},false,hist[c[4]+1]} -- r,g,b,{original colors},fuse_marker,histogram_weight
 end

 --table.insert(cPalList,{255,255,0,{257},false,1})

 clusterExists = true
 while clusterExists do
  clusterExists = false
  clusterList = {}

  crad1 = crad + 1 -- avoid divison by zero
  worst = 9999
  for a = 1, #cPalList, 1 do 
    c1 = cPalList[a]
    r1,g1,b1 = c1[1],c1[2],c1[3]
    wtot = c1[6]
    cList = {a}
    maxDist = 0
    for b = 1, #cPalList, 1 do
      if (b ~= a) then
        c2 = cPalList[b]
        r2,g2,b2 = c2[1],c2[2],c2[3]
        wt = c2[6]
        --pd = math.pow((1 + wt / pixels),  prot_pow) -- Protection, increase distance
        pd = (1 + wt / pixels)^prot_pow -- Protection, increase distance

        dist = db.getColorDistance_weight(r1,g1,b1,r2,g2,b2,rw,gw,bw) * distfrac * pd -- In percent
        if dist <= crad then 
           wtot = wtot + wt
          table.insert(cList,b)
          maxDist = math.max(dist,maxDist)
        end
      end
    end -- b
    if #cList > 1 then 
      clustVal = maxDist / (crad1 * #cList) * (wtot / #cList)   
      if clustVal < worst then
        worst = clustVal
        clusterList = cList
      end
    end
  end -- a
  
  --t = db.ary2txt(clusterList)
  --messagebox("Worst cluster is "..t)
  
   -- Fuse
  if #clusterList > 1 then
    clusterExists = true -- Run another iteration and look for more clusters
    fuseCol = {0,0,0,{}}
    rt,gt,bt,tot = 0,0,0,0
    for n = 1, #clusterList, 1 do
     i = clusterList[n]
     c = cPalList[i]
       --o = c[4][1] -- Original color (always #1 in list since fused colors can't re-fuse) 
     o = c[4] -- Original color list
     --if c[5] == true then messagebox("Re-Fusing..."); end
     r,g,b = c[1],c[2],c[3]
       --wt = hist[o+1] -- Org. colors are 0-255
     wt = c[6]
     rt = rt + r * wt
     gt = gt + g * wt
     bt = bt + b * wt
     tot = tot + wt
     cPalList[i] = -1 -- Erase color
       --table.insert(fuseCol[4],o)
     orgcols = fuseCol[4]
     for j = 1, #o, 1 do
      table.insert(orgcols,o[j])
     end
     fuseCol[4] = orgcols
    end

    rt = rt / tot
    gt = gt / tot
    bt = bt / tot
    fuseCol[1] = rt
    fuseCol[2] = gt
    fuseCol[3] = bt
    fuseCol[5] = true -- fusecol marker
    fuseCol[6] = tot
    table.insert(cPalList,fuseCol)
    --messagebox(#clusterList.." Colors was fused, resulting in "..rt..", "..gt..", "..bt)
    newPalList = {}
    for n = 1, #cPalList, 1 do
     if cPalList[n] ~= -1 then
       table.insert(newPalList,cPalList[n])
      --newPalList = db.newArrayInsertLast(newPalList,cPalList[n])  
     end
    end
    cPalList = newPalList
    --messagebox("Pal length: "..#cPalList)
   statusmessage("DC - Image colors: "..#cPalList.."                       "); waitbreak(0)
  end -- fuse

 end -- while

    -- Create remap-list
    org = {}
    count = 0
    for u = 1, #cPalList, 1 do
       c = cPalList[u]
       for n = 1, #c[4], 1 do
         i = c[4][n]
         org[i+1] = count -- quick way to remap without matchcolor
       end
       count = count + 1
    end

 return org,cPalList

end; -- decluster



-- ------------- MEDIAN CUT V1.0 ------------
--
--   256 color Palette Lua-version (converted from Evalion JS-script)
--
--   by Richard 'DawnBringer' Fhager
--
--
-- pal:    [[r,g,b,i]]  Pallist
-- cnum:                Target number of colors in reduced palette
-- (step:)   1..          Pixel picks for processing, 1 = all pixels in image, best and slowest. 2 = 25% of pixels
-- qual:   Flag         Qualitative color selection (Normal mode)
-- quant:  Flag         Quantative color/pixel selection (Histogram) 100% mean that it count as much as quality
--  (One of or both qual/quant must be selected)
-- rgbw:   [3]          RGB-weights []. Weigh the color channels. ex: [1,1.333,0.75]
-- bits:   1-8          Bits used for each color channel in palette
-- quantpow:            0..1
--
-- return: A palette! A list of [r,g,b] values
--
-- NOTE: Quantity will act as a counterforce to altered colorspace (weights)...
-- Ex: if Green is considered bigger, it will be split into more blocks 
--     but each blocks will have less colors and thus less quantity.
--
-- Perceptual colorspace (rgb-weights) will generally produce the best quality of palettes, but if
-- It's desirable to preserve stronger colors, esp. in small palettes, 
-- it can be good to just use nominal space: 1,1,1
--
-- Histogram may be useful to assign more colors to an object that already covers most of the image,
-- however; if the object of interest is small in relation to a large (unimportant) background, it's
-- usually best not to have any histogram at all. Histogram will dampen strong infrequent colors.


function db.medianCut(pal,cnum,qual,quant,rgbw,bits,quantpow)
 local n,x,y,xs,ys,rgb,blocklist,blocks
 local len,res,chan,diff,maxdiff,maxblock,split
 local qualnorm, quantnorm 

 -- Normalize 256 for quality/quantity relationship
 qualnorm =  1 / math.sqrt(rgbw[1]^2 + rgbw[2]^2 + rgbw[3]^2)
 quantnorm = 256 / #pal 

 blocklist = {}
 blocklist[1] = {}; blocks = 1

 for n=1, #pal, 1 do 
  blocklist[1][n] = pal[n]; 
 end

 analyzeBlock(blocklist[1],qual,quant,rgbw,qualnorm,quantnorm,quantpow)

 failsafe = 0
 while (blocks < cnum and failsafe < 256) do
   failsafe = failsafe + 1
  maxdiff  = -1
  maxblock = -1
  for n=1, blocks, 1 do
    diff = blocklist[n].diff
    if (diff > maxdiff) then maxdiff = diff; maxblock = n; end -- maxchan is stored as .chan in block
  end
  split = splitBlock(blocklist,maxblock,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
  if (split == false) then failsafe = 256; end
  blocks = #blocklist
  --status.value = "MC: " +blocks
 end -- while

 return blocks2Palette(blocklist,bits)

end
--

--
function blocks2Palette(blocklist,bits)
 local n,r,g,b,c,pal,block,rgb,blen,M,dB,cB,rf,gf,bf
 
 M = math
 pal = {}

 --bits = 1
 dB = M.pow(2,8-bits)
 cB = M.ceil(255 / (M.pow(2,bits) - 1))

 for n=1, #blocklist, 1 do
  block = blocklist[n]
  r,g,b = 0,0,0
  blen = #block
  for c=1, blen, 1 do
   rgb = block[c]
   r = r + rgb[1]
   g = g + rgb[2]
   b = b + rgb[3]
  end

  rf = M.floor(M.min(255,M.max(0,M.floor(r/blen))) / dB) * cB
  gf = M.floor(M.min(255,M.max(0,M.floor(g/blen))) / dB) * cB
  bf = M.floor(M.min(255,M.max(0,M.floor(b/blen))) / dB) * cB

  pal[n] = {rf, gf, bf, 0} -- col is avg. of all colors in block (index is set (to 0) for compatibility)
 end -- blocklist

 return pal
end
--

--
function analyzeBlock(block,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
 local r,g,b,n,rmin,gmin,bmin,rmax,gmax,bmax,rdif,gdif,bdif,chan,d,median,diff
 local len,Mm,Mx,rgb,kv,qu
 
 Mx,Mm = math.max, math.min
 len = #block

 rmin,gmin,bmin = 255,255,255
 rmax,gmax,bmax = 0,0,0

 for n=1, len, 1 do
  rgb = block[n]
  r = rgb[1] * rgbw[1] 
  g = rgb[2] * rgbw[2] 
  b = rgb[3] * rgbw[3] 
  --if (!isNaN(r) and !isNaN(g) and !isNaN(b)) then -- Ignore any erroneous data
   rmin = Mm(rmin,r)
   gmin = Mm(gmin,g)
   bmin = Mm(bmin,b)
   rmax = Mx(rmax,r)
   gmax = Mx(gmax,g)
   bmax = Mx(bmax,b)
  --end
 end
 
 rdif = (rmax - rmin) -- * rgbw[1] 
 gdif = (gmax - gmin) -- * rgbw[2]
 bdif = (bmax - bmin) -- * rgbw[3] 

 d = {{rmin,rdif,rmax},{gmin,gdif,gmax},{bmin,bdif,bmax}}

 chan = 1 -- Widest channel
 if (gdif > rdif) then chan = 2; end 
 if (bdif > rdif and bdif > gdif) then chan = 3; end
 
 -- Ok, this is the average of the max/min value rather than an actual median
 -- I guess this will fill the colorspace more uniformly and perhaps select extremes to a greater extent?
 -- Which is better? 
 --median = d[chan][1] + d[chan][2] / 2 -- OLD same as median with nominal weights
 
 median = (d[chan][1] + d[chan][3]) / 2 

 -- quantity and quality are normalized to 256 (256 is the total of colors in the set for quantity)
 -- Note that, regardless of forumla, quality (distance) must always be greater in any block than quantity (colors/pixels)
 -- Coz a block may contain many of only 1 unique color, thus rendering it impossible to split if selected.
 kv = 1
 qu = 1
 if (quant) then kv = 1 + len*quantnorm*quantpow; end
 if (qual)  then qu = d[chan][2] * qualnorm; end
 diff = qu + qu*kv^2.5

 block.chan   = chan
 block.diff   = diff
 block.median = median

 return {chan,diff,median,len}

end
--

--
function splitBlock(blocklist,maxblock,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
  local n,cmax,median,blockA,blockB,len,cB,block,rgb,res
  
  blockA,blockB = {},{}
  block = blocklist[maxblock]

  res = true

  chan   = block.chan 
  median = block.median  

  cB = blocklist[maxblock] -- maxblock starts at 1 when called so it should not hava a +1
  len = #cB

  for n=1, len, 1 do
    rgb = cB[n]
    --if (rgb[chan] >= median) then blockA.push(rgb); end
    --if (rgb[chan] <  median) then blockB.push(rgb); end
    if (rgb[chan]*rgbw[chan] >= median) then table.insert(blockA,rgb); end
    if (rgb[chan]*rgbw[chan] <  median) then table.insert(blockB,rgb); end
  end

  blocklist[maxblock] = blockA  -- Can't be empty right?
  analyzeBlock(blocklist[maxblock],qual,quant,rgbw,qualnorm,quantnorm,quantpow)

  if (#blockB > 0) then
   table.insert(blocklist,blockB)
   analyzeBlock(blocklist[#blocklist],qual,quant,rgbw,qualnorm,quantnorm,quantpow) -- no -1 on blocklist
   else 
    res = false
  end

  return res -- false = no split
end
--

------------ eof MEDIAN CUT --------------------------


-- ------------- DIST-SLICE V1.0 ------------
--
--  Divide space by greatest distance of any two colors (rather than MC-method of any given channel)
--  Basically it allows colorspace to be sliced at any angles rather than the "boxing" of MC.
--
--
--   by Richard 'DawnBringer' Fhager
--
--
-- pal:    [[r,g,b,i,h]]  Pallist (h = histogram/pixelcount)
-- cnum:                Target number of colors in reduced palette
-- (step:)   1..          Pixel picks for processing, 1 = all pixels in image, best and slowest. 2 = 25% of pixels
-- qual:   Flag         Qualitative color selection (Normal mode)
-- quant:  Flag         Quantative color/pixel selection (Histogram) 100% mean that it count as much as quality
--  (One of or both qual/quant must be selected)
-- rgbw:   [3]          RGB-weights []. Weigh the color channels. ex: [0.26, 0.55, 0.19]
-- bits:   1-8          Bits used for each color channel in palette
-- quantpow: 0..1	Quantity vs Quality (put weight into histogram/pixelcount)
-- briweight: 0..1	Brightness distance weight in colordistance
-- proxweight: 0..1	Primary Proximity distance weight in colordistance (ColorTheory-WIP: compensate for brightness of individual channels, the "extra power" of primary colors)	
--
-- return: A palette! A list of [r,g,b] values
--
-- NOTE: Quantity will act as a counterforce to altered colorspace (weights)...
-- Ex: if Green is considered bigger, it will be split into more blocks 
--     but each blocks will have less colors and thus less quantity.
--
-- Perceptual colorspace (rgb-weights) will generally produce the best quality of palettes, but if
-- It's desirable to preserve stronger colors, esp. in small palettes, 
-- it can be good to just use nominal space: 0.33, 0.33, 0.33
--
-- Histogram may be useful to assign more colors to an object that already covers most of the image,
-- however; if the object of interest is small in relation to a large (unimportant) background, it's
-- usually best not to have any histogram at all. Histogram will dampen strong infrequent colors.


function db.distSlice(pal,cnum,qual,quant,rgbw,bits,quantpow, briweight, proxweight) -- pal[r,g,b,i,pixelcount]
 local n,x,y,xs,ys,rgb,blocklist,blocks
 local len,res,chan,diff,maxdiff,maxblock,split
 local qualnorm, quantnorm,count

 blocklist = {}
 blocklist[1] = {}; blocks = 1

 count = 0
 for n=1, #pal, 1 do 
  blocklist[1][n] = pal[n]; 
  count = count + pal[n][5]
 end

 -- Normalize 256 for quality/quantity relationship
 qualnorm =  1 / math.sqrt(rgbw[1]^2 + rgbw[2]^2 + rgbw[3]^2)
 quantnorm = 256 / count


 -- Dist table
 statusmessage("MR: Making Distance Table..."); updatescreen(); if (waitbreak(0)==1) then return; end
 local dy,c,r1,g1,b1,i1,i2
 dt = {}
 for n=1, #pal, 1 do
  c = pal[n]
  r1,g1,b1,i1 = c[1],c[2],c[3],c[4]
  dt[i1+1] = {}
  for m=1, #pal, 1 do
   dt[i1+1][pal[m][4]+1] = db.getColorDistanceProx(r1,g1,b1,pal[m][1],pal[m][2],pal[m][3],rgbw[1],rgbw[2],rgbw[3],qualnorm, proxweight, briweight) -- pri/bri
  end
 end
 --

 statusmessage("MR: Analyzing Block 1..."); updatescreen(); if (waitbreak(0)==1) then return; end
 r_analyzeBlock(dt,blocklist[1],qual,quant,rgbw,qualnorm,quantnorm,quantpow)

 statusmessage("MR: Analyzing Blocks..."); updatescreen(); if (waitbreak(0)==1) then return; end
 failsafe = 0
 while (blocks < cnum and failsafe < 256) do
   failsafe = failsafe + 1
  maxdiff  = -1
  maxblock = -1
  for n=1, blocks, 1 do
    diff = blocklist[n].diff
    if (diff > maxdiff) then maxdiff = diff; maxblock = n; end -- maxchan is stored as .chan in block
  end
  split = r_splitBlock(dt,blocklist,maxblock,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
  if (split == false) then messagebox("Only found "..blocks.." (24-bit) colors!"); break; end
  blocks = #blocklist
  statusmessage("MR: "..blocks); updatescreen(); if (waitbreak(0)==1) then return; end
 end -- while

 return r_blocks2Palette(blocklist,bits)

end
--

--
function r_blocks2Palette(blocklist,bits)
 local n,r,g,b,c,pal,block,rgb,blen,M,dB,cB,rf,gf,bf
 
 M = math
 pal = {}

 --bits = 1
 dB = M.pow(2,8-bits)
 cB = M.ceil(255 / (M.pow(2,bits) - 1))

 for n=1, #blocklist, 1 do
  block = blocklist[n]
  r,g,b = 0,0,0
  blen = #block
  for c=1, blen, 1 do
   rgb = block[c]
   r = r + rgb[1]
   g = g + rgb[2]
   b = b + rgb[3]
  end

  rf = M.floor(M.min(255,M.max(0,M.floor(r/blen))) / dB) * cB
  gf = M.floor(M.min(255,M.max(0,M.floor(g/blen))) / dB) * cB
  bf = M.floor(M.min(255,M.max(0,M.floor(b/blen))) / dB) * cB

  pal[n] = {rf, gf, bf} -- col is avg. of all colors in block
 end -- blocklist

 return pal
end
--

--
function r_analyzeBlock(dt,block,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
 local r,g,b,n,m,rmin,gmin,bmin,rmax,gmax,bmax,rdif,gdif,bdif,chan,d,median,diff
 local len,Mm,Mx,rgb,kv,qu
 local maxdist,dist,r1,g1,b1,r2,g2,b2,c1,c2,count

 Mx,Mm = math.max, math.min
 len = #block

 rmin,gmin,bmin = 255,255,255
 rmax,gmax,bmax = 0,0,0
 
 maxdist,c1,c2,count = 0,-1,-1,0

 for n=1, len, 1 do
   rgb1 = block[n]
   count = count + rgb1[5] -- pixelcount for color
  for m=n+1, len, 1 do
   rgb2 = block[m]
   dist = dt[rgb1[4]+1][rgb2[4]+1] 

   if dist > maxdist then
    maxdist = dist
    c1 = rgb1[4]+1
    c2 = rgb2[4]+1
   end 
 
  end
 end
 
 -- quantity and quality are normalized to 256 (256 is the total of colors in the set for quantity)
 -- Note that, regardless of forumla, quality (distance) must always be greater in any block than quantity (colors/pixels)
 -- Coz a block may contain many of only 1 unique color, thus rendering it impossible to split if selected.
 kv = 1
 qu = 1
 if (quant) then kv = math.pow(1 + count*quantnorm*quantpow, 0.5); end
 if (qual)  then qu = maxdist * qualnorm; end
 diff = qu*(1-quantpow) + qu*kv

 block.chan   = -1
 block.diff   = diff
 block.median = -1
 block.c1     = c1
 block.c2     = c2 

 return {diff,len}

end
--

--
function r_splitBlock(dt,blocklist,maxblock,qual,quant,rgbw,qualnorm,quantnorm,quantpow)
  local n,cmax,median,blockA,blockB,len,cB,block,rgb,res
  local c1,c2,dist1,dist2,medr,medg,medb,r1,g1,b1,r2,g2,b2,rgb1,rgb2  

  blockA,blockB = {},{}
  block = blocklist[maxblock]

  res = true

  --chan   = block.chan 
  --median = block.median  
  c1 = block.c1
  c2 = block.c2

  cB = blocklist[maxblock] -- maxblock starts at 1 when called so it should not hava a +1
  len = #cB

  if len < 2 then return false; end

  for n=1, len, 1 do
    rgb = cB[n]
  
     dist1 = dt[rgb[4]+1][c1]
     dist2 = dt[rgb[4]+1][c2]

    if (dist1 <= dist2) 
     then table.insert(blockA,rgb); 
    end

    if (dist1 > dist2) then 
     table.insert(blockB,rgb); 
    end
  end

  blocklist[maxblock] = blockA  -- Can't be empty right?
  r_analyzeBlock(dt,blocklist[maxblock],qual,quant,rgbw,qualnorm,quantnorm,quantpow)

  if (#blockB > 0) then
   table.insert(blocklist,blockB)
   r_analyzeBlock(dt,blocklist[#blocklist],qual,quant,rgbw,qualnorm,quantnorm,quantpow) -- no -1 on blocklist
   else 
    res = false
  end

  return res -- false = no split
end
--

------------ eof MEDIAN REDUX --------------------------



--
-- This function looks kind of big and bad, but it's so fast I could not even time it for 6 entries...
--
-- v0.95
--
function db.findClosestColors(pallist, entries, briweight) -- !!!>>>brightness sorted palette list<<<!!!, desired number of data  
 local list,dist,n,j,rw,gw,bw,r1,g1,b1,r2,g2,b2,y,c1,c2,j,bridiff,brilimit,bri,len,colweight,nn

 rw = 0.26 -- use as arguments instead?
 gw = 0.55
 bw = 0.19
 nn = 2.46 -- normalizer squared
 list = {}
 len = #pallist

 briweight = briweight or 0.5
 colweight = 1 - briweight

 brilimit = 256 / math.sqrt(len)/2

 local dists,ds,cdist,got,max,iter,maxdist,mindist
 dists = {}
 dn = 0
 maxdist = 0
 mindist = 50000

 for n = 1, #pallist-1, 1 do
  c1 = pallist[n][4]
  r1,g1,b1 = getcolor(c1)
  bri = db.getBrightness(r1,g1,b1)
  --bri = pallist[n][7] -- Brightness, only if we added HSL data
  j = 0
  bridiff = 0
  while (bridiff < brilimit) and (n+j < len) do -- at least one color is checked, NOTE: Palette MUST BE BRIGHTNESS SORTED!
   j = j + 1
   c2 = pallist[n+j][4]
   r2,g2,b2 = getcolor(c2)
   bridiff = db.getBrightness(r2,g2,b2) - bri

   --dist = (((rw*(r1-r2))^2 + (gw*(g1-g2))^2 + (bw*(b1-b2))^2) * colweight + bridiff^2*briweight)^0.5 -- not correct (weights b4 square)

   dist = (((rw*(r1-r2))^2 + (gw*(g1-g2))^2 + (bw*(b1-b2))^2) * nn * colweight^2 + (bridiff*briweight)^2)^0.5 -- (sqrt(x)*n*w)^2 = x*n^2*w^2

   -- Distances should roughly stay within 0-255, none is smaller than 0.1 (blue perceptual)
   --  0.0361 - 26414, root: 0.19 - 163, x16 should be ok, 163*16 = 2608 (0.19*16 = 3.04, 0.26*16 = 4.16)
   -- Since we only (normally) look-up the first entries there is no danger expanding the list, also
   -- it reduces the problem with unsorted sub-lists
   
   -- The art of integer-sorting
   cdist = math.floor(dist * 100)
   if dists[cdist] == null then
    dists[cdist] = {{dist,c1,c2}}
     else table.insert(dists[cdist],{dist,c1,c2})
   end
  
  end -- while

 end

 -- "Sort" the data, good thing: it's already done, hehe! And we only need a part of it
  got = 0 
 iter = 0
  max = 2608 + 20000 -- Ok, I don't know what's required here but you need 19000 to find a match with only black & white. 
 while (got < entries) and (iter < max) do
  iter = iter + 1
  if dists[iter] ~= null then
   for n = 1, #dists[iter], 1 do
    got = got + 1
    list[got] = dists[iter][n]
   end
  end
 end

 --messagebox(#list)
 return list -- {{dist,c1,c2},...}
end;
--
-- eof findclosestcolors




--
-- Find best Neutralizer color in palette list. 
-- That is the complementary color that produces the smoothest mixdither best resembling a grayscale.
-- The formulas and tresholds are quite arbitrary but seem to work rather nicely.
--
-- Sister function for creating optimal neutralizer to a given rgb-value is: db.makeComplementaryColor() (using brikeep=3, output file with all options available
--
function db.findBestNeutralizer(gamma,r,g,b,pal)
 local n,r1,g1,b1,rn,gn,bn,gm,gmr,mix_diff,score,best_score,best_index,bri_o,bri_n,bri_diff,sat_o,sat_n,sat_c,sat_diff,mf
 local dist
 mf = math.floor
 gm  = gamma
 gmr = 1 / gm
 bri_o = db.getBrightness(r,g,b)
 --sat_o = db.getRealSaturation(r,g,b) * 255
 sat_o = db.getPurity_255(r,g,b)

 best_index = -1 -- -1 = Fail / No acceptable color
 best_score = 9999999
 for n = 1, #pal, 1 do
   r1,g1,b1 = pal[n][1],pal[n][2],pal[n][3]
   bri_n = db.getBrightness(r1,g1,b1)
   --sat_n = db.getRealSaturation(r1,g1,b1) * 255
   sat_n = db.getPurity_255(r1,g1,b1)
   bri_diff = math.abs(bri_o - bri_n) 
   sat_diff = math.abs(sat_o - sat_n)
   dist = db.getColorDistance_weightNorm(r,g,b,r1,g1,b1,0.26,0.55,0.19)
    -- Distance Blue-Yellow is 167.4, Don't do grays and match same colors (These 4 req. may be redundant? Nope, not all...)
   if bri_diff<168 and sat_o>20 and sat_n>20 and dist>5 and sat_diff < 100 then
     rn = ((r^gm + r1^gm)/2)^gmr
     gn = ((g^gm + g1^gm)/2)^gmr
     bn = ((b^gm + b1^gm)/2)^gmr
     --sat_c = db.getRealSaturation(mf(rn),mf(gn),mf(bn)) * 255
     sat_c = db.getPurity_255(mf(rn),mf(gn),mf(bn))
     mix_diff = math.max(rn,gn,bn) - math.min(rn,gn,bn) -- Grayscale similarity
     -- Distances scale so adjust for the narrow dark colors.
   if (mix_diff^0.5 * (1.2-bri_o/255)^0.5) < 5.125 then -- Higher penalty for original dark colors (Don't mix so easily with bright ones)
     score = mix_diff*2.5 + (bri_diff)^0.5 + (sat_diff/255 * bri_diff) + ((255-math.min(sat_o,sat_n))/255 * bri_diff)
     -- score < 145 and
     if score < best_score and (sat_c < math.min(sat_o,sat_n)*0.9) then -- Mix must have lower sat then c1 & c2
      best_score = score
      best_index = n 
     end
   end -- dark original penalty
   end -- if < 168
 end
 return best_index
end
--


--
-- ... eof Custom Color / Palette functions ...
--


-- *****************************
-- *** Custom Draw functions ***
-- *****************************

--
function db.line(x1,y1,x2,y2,c) -- Coords doesn't have to be integers w math.floor in place (Broken lines problem with fractions)
 local n,st,m,xd,yd,floor; m = math; floor = m.floor
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   putpicturepixel(floor(x1 + n*xd), floor(y1 + n*yd), c );
 end
end
--

-- Line: No flooring of positions, returns fractional coord of last plot.
--
function db.lineRet(x1,y1,x2,y2,c)
 local n,x,yst,m,xd,yd; m = math
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   x = x1 + n*xd
   y = y1 + n*yd
   putpicturepixel(x,y, c);
 end
 return x,y
end
--

--
function db.lineTransp(x1,y1,x2,y2,c,amt) -- amt: 0-1, 1 = Full color
 local n,st,m,x,y,r,g,b,r1,g1,b1,c2,org; m = math
 org = 1 - amt
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 r1,g1,b1 = getcolor(c)
 for n = 0, st, 1 do
   x = m.floor(x1+n*(x2-x1)/st)
   y = m.floor(y1+n*(y2-y1)/st)
   r,g,b = getcolor(getpicturepixel(x,y))
   c2 = matchcolor(r1*amt+r*org, g1*amt+g*org, b1*amt+b*org) 
   putpicturepixel(x, y, c2 );
 end
end
--


-- Bright on black can look a bit crappy (2:1 lines f.ex)...dunno why, gamma?
function db.lineTranspAA(x1,y1,x2,y2,r0,g0,b0,amt) -- amt: 0-1, 1 = Full color
 local n,st,m,x,y,r,g,b,r1,g1,b1,c2,org; m = math
 org = 1 - amt
 --get = getbackuppixel
 get = getpicturepixel
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 stx = (x2-x1)/st
 sty = (y2-y1)/st
 for n = 0, st, 1 do

   x = x1 + n * stx
   y = y1 + n * sty

   x_1 = m.floor(x)
   y_1 = m.floor(y)

   xf = (x - x_1)
   yf = (y - y_1)

  --xf =  0.5 - math.cos(xf * math.pi) * 0.5 -- Can't see much diff with these
  --yf =  0.5 - math.cos(yf * math.pi) * 0.5
  --xf = xf^3 * (xf*(6*xf - 15) + 10)
  --yf = yf^3 * (yf*(6*yf - 15) + 10)

   p1 = amt * (1-xf)*(1-yf)
   p2 = amt * xf*(1-yf) 
   p3 = amt * (1-xf)*yf 
   p4 = amt * xf*yf     

   r1,g1,b1 = getcolor(get(x_1,y_1))
   c1 = matchcolor(r0*p1+r1*(1-p1), g0*p1+g1*(1-p1), b0*p1+b1*(1-p1)) 
   putpicturepixel(x_1, y_1, c1 );

   r2,g2,b2 = getcolor(get(x_1+1,y_1+0))
   c2 = matchcolor(r0*p2+r2*(1-p2), g0*p2+g2*(1-p2), b0*p2+b2*(1-p2)) 
   putpicturepixel(x_1+1, y_1+0, c2 );

   r3,g3,b3 = getcolor(get(x_1+0,y_1+1))
   c3 = matchcolor(r0*p3+r3*(1-p3), g0*p3+g3*(1-p3), b0*p3+b3*(1-p3)) 
   putpicturepixel(x_1+0, y_1+1, c3 );

   r4,g4,b4 = getcolor(get(x_1+1,y_1+1))
   c4 = matchcolor(r0*p4+r4*(1-p4), g0*p4+g4*(1-p4), b0*p4+b4*(1-p4)) 
   putpicturepixel(x_1+1, y_1+1, c4 );


 end
end
--


--
-- Line: Transparency, Anti-aliased and gamma corrected.
--
-- With transp and/or aa; gamma correction is required to accurately represent resulting colors.
--
-- Since brightness is exponential, esp. with white on black, linear aa & transp will appear to weak/dark, resulting in
-- a look of broken, blotchy lines. Black on white doesn't suffer as much, but GC will produce thinner, sleeker looking lines.
-- gamma = 1.6 seem pretty good, higher will make white on black nice but thick, and black will get a little too thin on white.
-- lower than 1.6 and white on black is getting rapidly worse.
-- If thinner dark lines (on bright bkg) is desired then try a gamma of 2.0 to 2.5 or so.
--
-- NOTE: this algorithm is sequentially reading and drawning to the image, and as such is subject to data/precision loss
-- from colormatching on limited palettes. For higher quality use the Draw Buffer system (Dbuf)
--
function db.lineTranspAAgamma(x1,y1,x2,y2,r0,g0,b0,amt,gamma,skip) -- amt: 0-1, 1 = Full color
 local n,st,m,x,y,r,g,b,r1,g1,b1,org,mf, r0g,g0g,b0g, _r,_g,_b
 local stx,sty,gam,rgam,get,xf,yf,x_1,y_1, sq0, p1r,p2r,p3r,p4r, mc
 m = math; mf = math.floor
 skip = skip or 0
 org = 1 - amt
 --get = getbackuppixel
 get = getpicturepixel
 mc = matchcolor
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 stx = (x2-x1)/st
 sty = (y2-y1)/st
 gam = gamma or 1.6
 rgam = 1 / gam
 r0g,g0g,b0g = r0^gam, g0^gam, b0^gam
 for n = skip, st, 1 do

   x,   y   = x1 + n * stx,  y1 + n * sty    
   x_1, y_1 = mf(x), mf(y)

   xf = x - x_1
   yf = y - y_1

   sq0 = (1-xf)*(1-yf)

   p1 = amt * sq0
   p1r = 1 - p1   

   r1,g1,b1 = getcolor(get(x_1,y_1))
   _r = (r0g*p1 + r1^gam * p1r)^rgam
   _g = (g0g*p1 + g1^gam * p1r)^rgam
   _b = (b0g*p1 + b1^gam * p1r)^rgam
   putpicturepixel(x_1, y_1, mc(_r, _g, _b));

  if sq0 ~= 1 then -- single pixel, nothing to do here but waste time...

   p2 = amt * xf*(1-yf) 
   p3 = amt * (1-xf)*yf 
   p4 = amt * xf*yf     
   p2r, p3r, p4r = 1 - p2, 1 - p3, 1 - p4

   r2,g2,b2 = getcolor(get(x_1+1,y_1+0))
   _r = (r0g*p2 + r2^gam * p2r)^rgam
   _g = (g0g*p2 + g2^gam * p2r)^rgam
   _b = (b0g*p2 + b2^gam * p2r)^rgam
   putpicturepixel(x_1+1, y_1, mc(_r, _g, _b) );

   r3,g3,b3 = getcolor(get(x_1+0,y_1+1))
   _r = (r0g*p3 + r3^gam * p3r)^rgam
   _g = (g0g*p3 + g3^gam * p3r)^rgam
   _b = (b0g*p3 + b3^gam * p3r)^rgam
   putpicturepixel(x_1, y_1+1, mc(_r, _g, _b) );

   r4,g4,b4 = getcolor(get(x_1+1,y_1+1))
   _r = (r0g*p4 + r4^gam * p4r)^rgam
   _g = (g0g*p4 + g4^gam * p4r)^rgam
   _b = (b0g*p4 + b4^gam * p4r)^rgam
   putpicturepixel(x_1+1, y_1+1, mc(_r, _g, _b) );

  end -- single

 end
 return x,y -- for skip process
end
--





-- Brush: Filled Rectangle
function db.drawBrushRectangle(x1,y1,w,h,c)
   local x,y
   for y = y1, y1+h-1, 1 do
    for x = x1, x1+w-1, 1 do
       putbrushpixel(x,y,c);
    end
   end
end
--

-- Filled Rectangle
function db.drawRectangle(x1,y1,w,h,c)
   local x,y
   for y = y1, y1+h-1, 1 do
    for x = x1, x1+w-1, 1 do
       putpicturepixel(x,y,c);
    end
   end
end
--

--
function db.drawRectangleNeg(x1,y1,w,h,c)
   local x,y,xs,ys
   xs = db.sign(w)
   ys = db.sign(h)
   if xs == 0 then xs = 1; end
   if ys == 0 then ys = 1; end
   for y = y1, y1+h-1, ys do
    for x = x1, x1+w-1, xs do
       putpicturepixel(x,y,c);
    end
   end
end
--

--
function db.drawRectangleLine(x,y,w,h,c)
 w = w-1
 h = h-1
 db.line(x,y,x+w,y,c)
 db.line(x,y,x,y+h,c)
 db.line(x,y+h,x+w,y+h,c)
 db.line(x+w,y,x+w,y+h,c)
end
--


--
function db.drawRectangleMix(x1,y1,w,h,c1,c2)
   local x,y,c,n
   c = {c1,c2}
   n = 0
   for y = y1, y1+h-1, 1 do
     n = n + 1
    for x = x1, x1+w-1, 1 do 
       putpicturepixel(x,y,c[(n+x-x1)%2+1]);
    end
   end
end
--



 -- NOTE!
 -- My algos supports discs of both even and odd width...and the (normal) odd requires x.5 values
 -- So a Bresenham circle of r=2 would be r=2.5 for db.drawDiscOutline or db.drawCircle (disc)


-- Outlined filled discs
-- Far from perfect (sometimes outline is extra thick), but should give an unbroken outline
-- for both integer and half-pixel radii (ex: 5 & 7.5), at least upto a size of 22
function db.drawDiscOutline(x1,y1,r,c1,c2) -- ok, lottsa weird adjustments here, can probably be optimized...
   local x,y,d,t,r5,r25,r2,xr5,yr5,mf
   mf = math.floor
   t = 0.97
   if r < 7 then t = 0.96; end
   if r >= 12 then t = 0.98; end
   if r > 18 then t = 0.99; end
   r5,r25,r2,xr5,yr5 = r+0.5,r-0.25,r*2, mf(x1-r-0.5), mf(y1-r-0.5)
   for y = 0, r2+1, 1 do
    for x = 0, r2+1, 1 do
       d = ((x-r5)^2 + (y-r5)^2)^0.5
       if d < (r25+t) then putpicturepixel(x + xr5, y + yr5, c2); end
       if d < r25 then putpicturepixel(x + xr5, y + yr5, c1); end
    end
   end
end
--


-- Filled Disc 
function db.drawDisc(x1,y1,r,c) -- ok, lottsa weird adjustments here, can probably be optimized...
   local x,y,d,r5,r25,r2,xr5,yr5,mf,y_sq,xrev,yrev
   mf = math.floor
   r5,r25,r2,xr5,yr5 = r+0.5,r-0.25,r+1, mf(x1-r-0.5), mf(y1-r-0.5)
   xrev,yrev = xr5 + r*2+1, yr5 + r*2+1
   for y = 0, r2, 1 do
    y_sq = (y-r5)^2
    for x = 0, r2, 1 do
       d = ((x-r5)^2 + y_sq)^0.5
       if d < r25 then 
        putpicturepixel(x + xr5, y + yr5, c); 
        putpicturepixel(xrev - x, y + yr5, c); 
        putpicturepixel(x + xr5, yrev - y, c); 
        putpicturepixel(xrev - x,  yrev - y, c); 
       end
    end
   end
end
--


-- Temporary. All instances od drawCircle should be replaced with db.drawDisc
db.drawCircle = db.drawDisc

---- Bresenham ---

-- Draw Circle: Bresenham algo, radius (and coords?) must be integer, Only circles of odd diameter possible
-- (dot): Optional. Plot nth pixel, nominal = 1 (unbroken). Not Perfect, clumping can occur at axises
function db.plotCircle(xm, ym, r, c, dot)
  local x,y,p,err,q
  dot = dot or 1
  p = putpicturepixel
  x = -r
  y = 0
  err = 2-2*r 
   q = 0
   while (x < 0) do
      if q % dot == 0 then
      p(xm-x, ym+y, c)
      p(xm-y, ym-x, c)
      p(xm+x, ym-y, c)
      p(xm+y, ym+x, c)
      end
      q = q + 1
      r = err;
      if (r <= y) then y = y+1; err = err + y*2+1; end          
      if (r > x or err > y) then x=x+1; err = err + x*2+1; end
   end
end
--


-- Filled Disc: Bresenham algo, radius (and coords?) must be integer, Only discs of odd diameter possible
function db.filledDisc(xm, ym, r, c)
  local x,y,p,n,err
  p = putpicturepixel
  x = -r
  y = 0
  err = 2-2*r 
   while (x < 0) do
      for n=x, 1, 1 do
       p(xm-n, ym+y, c)
       p(xm+n, ym-y, c)
       p(xm-y, ym-n, c)
       p(xm+y, ym+n, c)
      end
      r = err;
      if (r <= y) then y = y+1; err = err + y*2+1; end          
      if (r > x or err > y) then x=x+1; err = err + x*2+1; end
   end
end
--

-- Same but for brush
function db.filledDiscBrush(xm, ym, r, c)
  local x,y,p,n,err
  p = putbrushpixel
  x = -r
  y = 0
  err = 2-2*r 
   while (x < 0) do
      for n=x, 1, 1 do
       p(xm-n, ym+y, c)
       p(xm+n, ym-y, c)
       p(xm-y, ym-n, c)
       p(xm+y, ym+n, c)
      end
      r = err;
      if (r <= y) then y = y+1; err = err + y*2+1; end          
      if (r > x or err > y) then x=x+1; err = err + x*2+1; end
   end
end
--


---- eof Bresenham ---



-- Dotted Circle with plots every [step] pixel (regardless of radius)
-- pos, radius, plot-step, colorindex
--
function db.drawCircleDotted(cx,cy,r,step,c)
 local n,x,y,rad,adj,cos,sin,deg
 sin, cos, deg = math.sin, math.cos, math.pi / 180
 adj = 360 / (math.pi * 2 * r)
 for n=0, 359, step*adj do
  rad = n * deg
  x = cx + cos(rad) * r 
  y = cy + sin(rad) * r
  putpicturepixel(x,y,c)
 end
end
--


-- Filled Ring (Quick fix, hasn't been properly evaluated)
function db.drawRing(x1,y1,r,rin,c) -- ok, lottsa weird adjustments here, can probably be optimized...
   local x,y,d,r5,r25,r2,xr5,yr5
   r5,r25,r2,xr5,yr5,r05 = r+0.5,r-0.25,r*2, x1-r-0.5, y1-r-0.5
   for y = 0, r2, 1 do
    for x = 0, r2, 1 do
       d = math.sqrt((x-r5)^2 + (y-r5)^2)
       if d <= r25 and d>=rin then 
        putpicturepixel(x + xr5,    y + yr5,c); 
        --putpicturepixel(xr5+r2+0.5-x, y + yr5,c); 
        --putpicturepixel(x1 + r - x + 0.25, y1 + r - y + 0.25,c); 
        --putpicturepixel(x + xr5,           y1 + r - y + 0.25,c); 
       end
    end
   end
end
--


--
-- Draw a line Hexagon centered at {int: cx,cy} enclosed in a circle of radius {rd}
--
function db.drawHexagon(cx,cy,rd,c)

  local dx,dy

  dx = math.floor(math.cos(1/6 * math.pi) * rd)
  dy = math.floor(math.sin(1/6 * math.pi) * rd)

  db.line(cx, cy-rd, cx-dx,cy-dy, c)
  db.line(cx, cy-rd, cx+dx,cy-dy, c)
  db.line(cx-dx,cy-dy, cx-dx, cy+dy, c)
  db.line(cx+dx,cy-dy, cx+dx, cy+dy, c)
  db.line(cx, cy+rd, cx-dx,cy+dy, c)
  db.line(cx, cy+rd, cx+dx,cy+dy, c)
end
--

-- PieChart WIP!!!
-- This is created by rendering the chart pixel-by-pixel, the interpolation is great but gets rougher toward the center / small radius
-- Note: the close-center aa get's better with a SMALLER scale (1 is best)
-- only use a scale >1 if there are sectors < 1% or using many small sectors who's integers won't easily add up to 100% / 360 degrees
-- If the slices don't add up (after rounding) to 100%/360 deg the last section will be filled with color 255.
--
-- slices: { {percentage,{r,g,b}},.. }
--
function db.pieChart(x1,y1,rad,offsetangle, slices, aa_flag, scale) 
   local a,x,y,d,q,v,c,cc,r5,r25,r2,xr5,yr5
   local range,pos1,pos2,m,n,deg,rgb,r,g,b,qf,qc,c1,c2,frac,rfrac
   r5,r25,r2,xr5,yr5 = rad+0.5,rad-0.25,rad*2, x1-rad-0.5, y1-rad-0.5
   deg = 180/math.pi

   if scale == null then scale = 1; end

   range = {}
   for n = 1, 361*scale, 1 do 
    range[n] = {-1,-1,-1,-1}
   end
   pos1 = 0
   for n = 1, #slices, 1 do
    rgb =  slices[n][2]
    c = matchcolor2(rgb[1],rgb[2],rgb[3])
    pos2 = slices[n][1] * 3.6 * scale
    for m = pos1, pos1 + math.ceil(pos2)+scale*2, 1 do
     range[1+m] = {c,rgb[1],rgb[2],rgb[3]}
    end
    pos1 = pos1 + math.floor(pos2)
   end
   --messagebox(db.ary2txt(range[1]))
   for y = 0, r2, 1 do
    for x = 0, r2, 1 do
       d = math.sqrt((x-r5)^2 + (y-r5)^2)
       if d < r25 then
         a = 0; if x>rad then a = math.pi; end
         v = math.pi/2; if y > rad then v = -v; end
         if (rad-x) ~= 0 then 
          v = math.atan((rad-y)/(rad-x)) + a
         end
         q = math.abs(629 + v * deg - offsetangle) % 360 -- 360 + 270 = 630
         qf = math.floor(q*scale) 
         qc = math.ceil(q) % 360 * scale
         c1 = range[1+qf][1] 
         c2 = range[1+qc][1]
         cc = c1
          if aa_flag and c1 ~= c2 then -- Interpolation 
            frac = math.min(1,(q - math.floor(q))^1.0 * (0.5 + d^1.25/rad)) -- +rad/250
            --if (d / rad) < 0.2 then frac = 0.5; end -- Another type of AA closer to the center
            rfrac = 1 - frac
            --statusmessage(1+qf)
            r =  range[1+qf][2] * rfrac + range[1+qc][2] * frac
            g =  range[1+qf][3] * rfrac + range[1+qc][3] * frac
            b =  range[1+qf][4] * rfrac + range[1+qc][4] * frac
            cc = matchcolor2(r,g,b)
          end
         putpicturepixel(x + xr5, y + yr5,cc);
       end -- if d
    end
   end

end
--



-- Filled Brush Disc
function db.drawBrushCircle(x1,y1,r,c) -- ok, lottsa weird adjustments here, can probably be optimized...
   local x,y,d,ysq
   for y = 0, r*2, 1 do
    ysq = (y-r-0.5)^2
    for x = 0, r*2, 1 do
       d = ((x-r-0.5)^2 + ysq)^0.5
       if d < r-0.25 then putbrushpixel(x1+x-r-0.5,y1+y-r-0.5,c); end
    end
   end
end
--

-- v2.0 Renamed from ellipse2, uses Line drawing with coord-return (better quality and hopfully avoids gapping)
-- Rotation in degrees
-- Step is # of line segments (more is "better")
-- a & b are axis-radius
function db.ellipse(x,y,a,b,stp,rot,col) 
 local n,m,rad,al,sa,ca,sb,cb,ox,oy,x1,y1,ast
 m = math; rad = m.pi/180; ast = rad * 360/stp;
 sb = m.sin(rot * rad); cb = m.cos(rot * rad)
 for n = 0.5, stp+0.5, 1 do -- 0.5 removes the wonky right side pixel at 0 degrees
  sa = m.sin(ast*n) * b; ca = m.cos(ast*n) * a
  x1 = 0.5 + x + ca * cb - sa * sb
  y1 = 0.5 + y + ca * sb + sa * cb
  --putpicturepixel(x1,y1,col)
  if (n > 0.5) then ox,oy = db.lineRet(ox,oy,x1,y1,col); -- Returns fractional coords of last point (no flooring)
   else ox,oy = x1,y1; --ox = m.floor(x1); oy = m.floor(y1);
  end
 end
end
--

-- Dotted Ellipse with [dots] number of points
function db.ellipseDot(x,y,a,b,dots,rot,col,cross_flag) 
 local n,m,rad,al,sa,ca,sb,cb,x1,y1,ast
 m = math; rad = m.pi/180; ast = rad * 360/dots;
 sb = m.sin(rot * rad); cb = m.cos(rot * rad)
 for n = 0, dots-1, 1 do
  sa = m.sin(ast*n) * b; ca = m.cos(ast*n) * a
  x1 = x + ca * cb - sa * sb 
  y1 = y + ca * sb + sa * cb
  putpicturepixel(x1,y1,col) 
  if cross_flag then
    putpicturepixel(x1-1,y1,col) 
    putpicturepixel(x1+1,y1,col) 
    putpicturepixel(x1,y1-1,col) 
    putpicturepixel(x1,y1+1,col)  
  end 
 end
end
--


--
function db.obliqueCube(side,x,y,r,g,b,bri,cols)
 local n,c,depth,x1,y1,x2,y2,f,v,x0,y0,q,asscols

 asscols = false
 if cols >= 0 and cols<250 then
  asscols = true
  c = cols;                   setcolor(cols,r,g,b);       cols = cols + 1
  cP50 = cols; q =  bri*0.5;  setcolor(cols,r+q,g+q,b+q); cols = cols + 1; 
  --cP75 = cols; q =  bri*0.75; setcolor(cols,r+q,g+q,b+q); cols = cols + 1; 
  cM50 = cols; q = -bri*0.5;  setcolor(cols,r+q,g+q,b+q); cols = cols + 1; 
  --cM100= cols; q = -bri;      setcolor(cols,r+q,g+q,b+q); cols = cols + 1; 
 end

  f = matchcolor2
  if asscols == false then
   v = 0.5
   c = f(r,g,b, v)
   cP50 =  f(r+bri*0.5,g+bri*0.5,b+bri*0.5, v)
   --cP75 =  f(r+bri*0.75,g+bri*0.75,b+bri*0.75, v)
   cM50 =  f(r-bri*0.5,g-bri*0.5,b-bri*0.5, v)
   --cM100 = f(r-bri,g-bri,b-bri, v)
  end


 depth = math.floor(side / 2)

 x0 = x+side
 y0 = y-1  
 for n = 0, depth-1, 1 do
  db.line(x0+n,y0-n,x0+n,y0+side-n -1, cM50) -- -1 fix 2017
  --drawline(x+side+n,y0-n,x+side+n,y0+side-n,cM50)
 end

 x0 = x+side-1
 y0 = y-1
 for n = 0, depth-1, 1 do
  db.line(x+n, y0-n, x0+n, y0-n, cP50)
  --drawline(x+n,y-1-n,x+side+n-1,y-1-n,cP50)
 end

 --  /
 --   
 --db.line(x+side,y-1,x+side+depth-1,y-depth,c)

 -- Smoothing & Shade

 --
 --  /
 --db.line(x+side,y+side-1,x+side+depth-1,y+side-depth,cM100)

 --db.line(x,y,x+side-2,y,cP75)
 --db.line(x,y,x,y+side-2,cP75)

 db.drawRectangle(x,y,side,side,c)

 --[[ 
 -- Front rivets
 c = matchcolor(r+32,g+32,b+32)
 putpicturepixel(x+2,y+2,c)
 putpicturepixel(x+side-3,y+2,c)
 putpicturepixel(x+2,y+side-3,c)
 putpicturepixel(x+side-3,y+side-3,c)
 c = matchcolor(r-32,g-32,b-32)
 putpicturepixel(x+2,y+3,c)
 putpicturepixel(x+side-3,y+3,c)
 putpicturepixel(x+2,y+side-2,c)
 putpicturepixel(x+side-3,y+side-2,c)
 --]]

 return cols

end


-- Currently used anywhere?
function db.obliqueCubeBRI(side,x,y,r,g,b,bri,pallist,briweight,index_flag)
 local n,c,depth,x1,y1,x2,y2

  --f = db.getBestPalMatchHYBRID
  c =  db.getBestPalMatchHYBRID({r,g,b},    pallist, briweight, index_flag)
  cP50 =  db.getBestPalMatchHYBRID({r+bri*0.5,g+bri*0.5,b+bri*0.5},    pallist, briweight, index_flag)
  cP75 =  db.getBestPalMatchHYBRID({r+bri*0.75,g+bri*0.75,b+bri*0.75}, pallist, briweight, index_flag)
  cM50 =  db.getBestPalMatchHYBRID({r-bri*0.5,g-bri*0.5,b-bri*0.5},    pallist, briweight, index_flag)
  cM100 = db.getBestPalMatchHYBRID({r-bri,g-bri,b-bri},                pallist, briweight, index_flag)

 depth = math.floor(side / 2)

 db.drawRectangle(x,y,side,side,c)

 for n = 0, depth-1, 1 do
  db.line(x+side+n,y-1-n,x+side+n,y+side-n-1,cM50)
  --drawline(x+side+n,y-1-n,x+side+n,y+side-n-1,cM50)
 end

 for n = 0, depth-1, 1 do
  db.line(x+n,y-1-n,x+side+n-1,y-1-n,cP50)
  --drawline(x+n,y-1-n,x+side+n-1,y-1-n,cP50)
 end

 --  /
 --   
 db.line(x+side,y-1,x+side+depth-1,y-depth,c)
 --drawline(x+side,y-1,x+side+depth-1,y-depth,c)


 -- Smoothing & Shade

 --
 --  /
 --db.line(x+side,y+side-1,x+side+depth-1,y+side-depth,cM100)

 --db.line(x,y,x+side-2,y,cP75)
 --db.line(x,y,x,y+side-2,cP75)


end
--


--
function db.fillTriangle(p,fcol,lcol,fill,wire) -- p = list of 3 (integer?) points

 local n,x,y,x1,x2,y1,y2,xf,yf,len,mr,adj
 
 mr = math.floor

 adj = 0; if wire == true then adj = 1; end -- Make adjustment to triangle fill if line drawing is active

 -- Convert to screen/matrix-coordinates
 --if (mode == 'percent')  then xf = xx / 100; yf = yy / 100; end
 --if (mode == 'fraction') then xf = xx; yf = yy; end
 --if (mode ~= 'absolute') then screenilizeTriangle(p,xf,yf); end 

 if (fill) then
  local Ax,Ay,Bx,By,Cx,Cy,xd,a,b,yc,ABdy,BCdy,ABix,BCix,ACix

  xd = {}

  --sort(p,1)                    -- Find top and middle y-point
  db.sorti(p,2)   

  Ay = p[1][2]; Ax = p[1][1]
  By = p[2][2]; Bx = p[2][1]
  Cy = p[3][2]; Cx = p[3][1]

  ABdy = By - Ay 
  BCdy = Cy - By
  ABix = (Bx - Ax) / ABdy
  BCix = (Cx - Bx) / BCdy
  ACix = (Cx - Ax) / (Cy - Ay)

  -- Upper
  a=1; b=2; 
  if (ACix < ABix) then a=2; b=1; end
  for y = 0, ABdy - adj, 1 do
   xd[a] = mr(Ax + ABix * y)
   xd[b] = mr(Ax + ACix * y) 
   yc = y+Ay; 
   for x=xd[1] + adj, xd[2], 1 do
    putpicturepixel(x,yc,fcol)
   end
  end

  -- Lower
  a=1; b=2; 
  if (BCix < ACix) then a=2; b=1; end
  for y = 0, BCdy-0, 1 do 
   xd[a] = mr(Cx - BCix * y)
   xd[b] = mr(Cx - ACix * y)
   yc = Cy-y
   for x = xd[1] + adj, xd[2], 1 do 
    putpicturepixel(x,yc,fcol)
   end
  end

 end -- eof fill
 
 if (wire) then
  for n = 0, 2, 1 do -- Outline
   x1 = p[n+1][1]; y1 = p[n+1][2]
   x2 = p[1 + (n+1) % 3][1]; y2 = p[1 + (n+1) % 3][2]
   db.line(x1,y1,x2,y2,lcol)
   --db.lineRet(x1,y1,x2,y2,lcol) -- same as line
   --drawline(x1,y1,x2,y2,lcol)
  end
 end

end -- eof fillTriangle
--


--
-- Drawing a triangle with Bilinear interpolation (between three RGB-values)
--
function db.interpolateTriangle(p) -- p = { {x0, y0, {r0,g0,b0}}, {x1, y1, {r1,g1,b1}}, {x2, y2, {r2,g2,b2}} } 

 local n,x,y,x1,x2,y1,y2,xf,yf,len,mr,max
 local Ax,Ay,Bx,By,Cx,Cy,xd,a,b,yc,ABdy,BCdy,ABix,BCix,ACix
 local c, red,grn,blu, xf,yf,xp,yp,A_rgb,B_rgb,C_rgb, D_rgb, Dy, Ctop, Cmid_left, Cmid_right, Cbot, topmiss, xtrim
 
 mr = math.floor
 max = math.max

  xd = {}
                  
  db.sorti(p,2) -- Find top and middle y-point  

  Ay = p[1][2]; Ax = p[1][1]
  By = p[2][2]; Bx = p[2][1]
  Cy = p[3][2]; Cx = p[3][1]

  A_rgb,B_rgb,C_rgb = p[1][3], p[2][3], p[3][3]
  
  ABdy = By - Ay 
  BCdy = Cy - By
  ABix = (Bx - Ax) / ABdy
  BCix = (Cx - Bx) / BCdy
  ACix = (Cx - Ax) / (Cy - Ay)
 
  -- Calculating 4th point RGB value (A-C intersected by B horisontal)

  -- Fraction of height in top triangle (fraction of bottom color)
  Dy = 1
  if  (Cy - Ay) > 0 then
   Dy = ABdy / (Cy - Ay)
  end

  D_rgb = {A_rgb[1] * (1 - Dy) + C_rgb[1] * Dy,
           A_rgb[2] * (1 - Dy) + C_rgb[2] * Dy,
           A_rgb[3] * (1 - Dy) + C_rgb[3] * Dy} 

 xtrim = 0 -- Don't draw rightmost pixels (for when there's another connecting triangle to the right)

  -- Upper
  topmiss = 0
 if ABdy > 0 then
  a=1; b=2; Ctop,Cmid_left,Cmid_right = A_rgb, D_rgb, B_rgb
  if (ACix < ABix) then a=2; b=1;  Ctop,Cmid_left,Cmid_right = A_rgb, B_rgb, D_rgb; end

  yf = 1 / (ABdy + 0) -- +0 means reaching full end value (0..n  v/n * n = v)
                      -- +1 means NOT reaching full end value 
  -- Top pixel
  c = matchcolor2(A_rgb[1], A_rgb[2], A_rgb[3]); putpicturepixel(Ax,Ay,c)

  for y = 1, ABdy, 1 do
   xd[a] = mr(Ax + ABix * y)
   xd[b] = mr(Ax + ACix * y) 
   yc = y+Ay; 
   xf = 1 / max(1,(xd[2] - xd[1] + 0)) -- +1 means NOT reaching full end value, 0 does (Warning, starting at y=0 is 0-div)
   yp = yf * y
   for x=xd[1], xd[2]-xtrim, 1 do 
    xp = xf * (x-xd[1])
    red = Ctop[1] * (1-yp) + (Cmid_left[1] * xp + Cmid_right[1] * (1-xp)) * yp
    grn = Ctop[2] * (1-yp) + (Cmid_left[2] * xp + Cmid_right[2] * (1-xp)) * yp
    blu = Ctop[3] * (1-yp) + (Cmid_left[3] * xp + Cmid_right[3] * (1-xp)) * yp
    c = matchcolor2(red, grn, blu)
    putpicturepixel(x,yc,c)
   end -- x
  end
   else topmiss = 1
 end

  -- Lower (note: drawn from bottom and up, add one line if upper triangle has 0 height)
 if BCdy > 0 then
  a=1; b=2; Cbot,Cmid_left,Cmid_right = C_rgb, D_rgb, B_rgb
  if (BCix < ACix) then a=2; b=1; Cbot,Cmid_left,Cmid_right = C_rgb, B_rgb, D_rgb; end
  yf = 1 / (BCdy-1+topmiss) -- Full value for when Lower only. looks right when drawing hexagonal grid of triangles
  --yf = 1 / ((BCdy-1+topmiss) + 1) -- Not full value, last line on upper triangle is full value.

  -- Bottom pixel
  c = matchcolor2(C_rgb[1], C_rgb[2], C_rgb[3]); putpicturepixel(Cx,Cy,c)

  for y = 1, BCdy-1+topmiss, 1 do
   xd[a] = mr(Cx - BCix * y)
   xd[b] = mr(Cx - ACix * y)
   yc = Cy-y
   xf = 1 / max(1,(xd[2] - xd[1] + 0)) -- +1 means NOT reaching full end value 
   yp = yf * y
   for x = xd[1], xd[2]-xtrim, 1 do
    xp = xf * (x-xd[1])
    red = Cbot[1] * (1-yp) + (Cmid_left[1] * xp + Cmid_right[1] * (1-xp)) * yp
    grn = Cbot[2] * (1-yp) + (Cmid_left[2] * xp + Cmid_right[2] * (1-xp)) * yp
    blu = Cbot[3] * (1-yp) + (Cmid_left[3] * xp + Cmid_right[3] * (1-xp)) * yp
    c = matchcolor2(red, grn, blu)
    putpicturepixel(x,yc,c)
   end
  end
 end

end 
--


--[[ Reference, Triangle fill and line drawing are two different prcodedures, that's why they don't always line up perfectly
--
func*** db.line(x1,y1,x2,y2,c) -- Coords doesn't have to be integers w math.floor in place (Broken lines problem with fractions)
 local n,st,m,xd,yd,floor; m = math; floor = m.floor
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   putpicturepixel(floor(x1 + n*xd), floor(y1 + n*yd), c );
 end
end
--

-- Line: No flooring of positions, returns fractional coord of last plot.
--
func*** db.lineRet(x1,y1,x2,y2,c)
 local n,x,yst,m,xd,yd; m = math
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   x = x1 + n*xd
   y = y1 + n*yd
   putpicturepixel(x,y, c);
 end
 return x,y
end
--
--]]

--
-- ... eof Custom Draw functions ...
--


-- ******************************
-- *** Filters & Convolutions ***
-- ******************************

-- ht: "height" (rotation radius/offset)
function db.applyConvolution2PicRot(convmx,divisor,bias,neg,amt,rot,ht)
 local r,g,b,mx,my,cx,cy,mxh,myh,mp,rb,gb,bb,xx,yy,x,y,w,h,div,n1,n2,amtr,ro,go,bo
 --local xp,yp
 local mxr,myr,rotmy,convy,div, n1divamt,n2amt
 local rotmatrix

    -- ht      --> PS:Height i.e. radius
    -- divisor --> PS:Amount i.e. strength

 n1 = 1
 n2 = bias
 if neg == 1 then
  n1 = -1
  n2 = 255 + bias
 end
 
 amtr = 1 - amt
 w, h = getpicturesize()
 cy = #convmx
 cx = #convmx[1]
 mxh = math.floor(cx / 2) + 1
 myh = math.floor(cy / 2) + 1

 rotmatrix = {}
 for my = 1, cy, 1 do
    rotmatrix[my] = {}
    for mx = 1, cx, 1 do
     xp = mx-mxh
     yp = my-myh
     xp,yp = db.rotationFrac(rot,0.5,0.5,xp*ht,yp*ht)
     rotmatrix[my][mx] = {xp,yp}
  end
 end

  n2amt = n2 * amt
  div = divisor
  n1divamt = n1 / div * amt

  for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   r,g,b = 0,0,0
   ro,go,bo = getbackupcolor(getbackuppixel(x,y))
  
   for my = 1, cy, 1 do
    rotmy = rotmatrix[my]
    convy = convmx[my]
    for mx = 1, cx, 1 do
 
     --xp = rotmy[mx][1]
     --yp = rotmy[mx][2]
     mp = convy[mx]
     xx = x + rotmy[mx][1]
     yy = y + rotmy[mx][2]

      -- "Extend the image across the border"
      if yy<0 then yy = 0; end
      if yy>=h then yy = h-1; end 
      if xx<0 then xx = 0; end
      if xx>=w then xx = w-1; end

       rb,gb,bb = getbackupcolor(getbackuppixel(xx,yy)) 
       r = r + rb * mp
       g = g + gb * mp
       b = b + bb * mp
  
    end
   end
   --r = ro*amtr + (n2 + (n1 * r) / div)*amt -- +bias
   --g = go*amtr + (n2 + (n1 * g) / div)*amt 
   --b = bo*amtr + (n2 + (n1 * b) / div)*amt
   r = ro*amtr + n2amt + r * n1divamt
   g = go*amtr + n2amt + g * n1divamt 
   b = bo*amtr + n2amt + b * n1divamt  
   putpicturepixel(x,y,matchcolor2(r,g,b))
 end;
  --statusmessage("Done: "..math.floor((y+1)*100/h).."%")
  --updatescreen(); if (waitbreak(0)==1) then return; end
  if db.donemeter(10,y,w,h,true) then return; end
 end;

end
--

-- V1.5 (8% faster for 5x5 Blur)
function db.applyConvolution2Pic(convmx,divisor,bias,neg,amt)
 local r,g,b,mx,my,cx,cy,mxh,myh,mp,rb,gb,bb,xx,yy,x,y,w,h,div,n1,n2,amtr,ro,go,bo,mtx
 local div, n1divamt,n2amt

 n1 = 1
 n2 = bias
 if neg == 1 then
  n1 = -1
  n2 = 255 + bias
 end
 
 amtr = 1 - amt
 w, h = getpicturesize()
 cy = #convmx
 cx = #convmx[1]
 mxh = math.floor(cx / 2) + 1
 myh = math.floor(cy / 2) + 1

  n2amt = n2 * amt
  div = divisor
  n1divamt = n1 / div * amt

  for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   r,g,b = 0,0,0
   ro,go,bo = getcolor(getbackuppixel(x,y))
   --div = divisor
   for my = 1, cy, 1 do
    mtx = convmx[my]
    yp = my-myh
    yy = y + yp
    -- "Extend the image across the border"
    if yy<0 then yy = 0; end
    if yy>=h then yy = h-1; end 
    for mx = 1, cx, 1 do
     xp = mx-mxh   
     mp = mtx[mx]
     xx = x + xp
    
      -- "Extend the image across the border"
      if xx<0 then xx = 0; end
      if xx>=w then xx = w - 1; end

       rb,gb,bb = getcolor(getbackuppixel(xx,yy)) 
       r = r + rb * mp
       g = g + gb * mp
       b = b + bb * mp
     
    end
   end
   --r = ro*amtr + (n2 + (n1 * r) / div)*amt -- +bias
   --g = go*amtr + (n2 + (n1 * g) / div)*amt 
   --b = bo*amtr + (n2 + (n1 * b) / div)*amt
   r = ro*amtr + n2amt + r * n1divamt
   g = go*amtr + n2amt + g * n1divamt 
   b = bo*amtr + n2amt + b * n1divamt  
   putpicturepixel(x,y,matchcolor2(r,g,b))
 end;

  if db.donemeter(10,y,w,h,true) then return; end
 end;

end
--


-- The two following functions (MaxMinRGB3x3) are used for max/min Edge detection and Smart-Sharpening masks

-- Find max/min RGB values in 3x3 matrix around pixel x,y (Core function)
 function db.getMaxMinRGB3x3(x,y,w,h)
   local mx,my, xr,xg,xb, mr,mg,mb, xx,yy, r1,g1,b1,Max,Min
   Max,Min = math.max, math.min
   xr,xg,xb,mr,mg,mb = 0,0,0,255,255,255

   for my = -1, 1, 1 do
    for mx = -1, 1, 1 do
  
     if not(mx == 0 and my == 0) then -- 8

     xx = x + mx
     yy = y + my
 
      -- "Extend the image across the border"
      if yy<0 then yy = 0; end
      if yy>=h then yy = h-1; end 
      if xx<0 then xx = 0; end
      if xx>=w then xx = w - 1; end

      r1,g1,b1 = getbackupcolor(getbackuppixel(xx,yy)) 
      xr = Max(xr,r1)
      xg = Max(xg,g1)
      xb = Max(xb,b1)
      mr = Min(mr,r1)
      mg = Min(mg,g1)
      mb = Min(mb,b1)
     end
    end
   end -- not centre
   return xr,xg,xb,mr,mg,mb
 end
--

--
-- Get the max & min RGB values in the 3x3 matrix at image pixel x,y (and apply exponent & power)
--
--      w,h: Image size
-- r0,g0,b0: RGB value of image pixel at x,y
--      exp: nom=1.0-1.6, Sharpness exponent (0.5-3.0), higher means "more surgical"; effect is restricted to ever harder edges (and less in smoother areas) 
--    pmult: Exponent normalizer and power compunded into one multiple ( pmult = (255/255^Exp) * Power )
--   brired: nom=0.7: Brightness reduction for minima (bright halo), a basic "gamma-correction" to avoid images getting too bright
--                    0.7 means 70% as bright, i.e. 30% reduction
function db.effectMaxMinRGB3x3(x,y,w,h,r0,g0,b0,exp,pmult,brired)

 local xr,xg,xb,mr,mg,mb,maxima,minima,rmax,gmax,bmax,rmin,gmin,bmin,pmultbrired

 xr,xg,xb,mr,mg,mb = db.getMaxMinRGB3x3(x,y,w,h)
 --xr,xg,xb,mr,mg,mb = core2(x,y,W,H,r0,g0,b0)

 -- (vmax - v0) < 0 (isolated bright pixels) is probably not frequent enough to provide possibilty for optimization
 function maxima(v0,vmax,exp,pmult)
  return math.max(0, 255 - math.max(0,(vmax-v0))^exp * pmult) -- Local math pointer may only provide a minute improvement
 end

 function minima(v0,vmin,exp,pmult,brired) -- Note: it's faster to provide a function with all arguments rather than having it go outside to fetch it
  return math.max(0, 255 - math.max(0,(v0-vmin))^exp * pmult) 
 end

 -- Maxima  (More "useful" than minima)
 -- edges around brighter details (no change to dark text 
 rmax = maxima(r0,xr,exp,pmult)
 gmax = maxima(g0,xg,exp,pmult)
 bmax = maxima(b0,xb,exp,pmult)
 
 -- Minima, edges around darker details 
 pmultbrired = pmult * brired
 rmin = minima(r0,mr,exp,pmultbrired)
 gmin = minima(g0,mg,exp,pmultbrired)
 bmin = minima(b0,mb,exp,pmultbrired)

 return rmax,gmax,bmax,rmin,gmin,bmin
end
--

-- core2 was here

--
-- ... eof Filters & Convolutions ...
--




-- *****************************
-- *** Patterns etc.         ***
-- *****************************

--
-- ex
-- { -- Hexa Dot
--    {0,1},
--    {0,0},
--    {1,0},
--    {0,0}
--   }
--
--
function db.dotMatrix(matrix, col, w,h,ofx,ofy) -- {{0/1,0/1,..},..}, pencolor, Width,Height & Offset are optional
  local x,y, iw,ih,mx, xmod,ymod
  iw, ih = getpicturesize()
  w = w or iw
  h = h or ih
  ofx = ofx or 0
  ofy = ofy or 0
  ymod = #matrix
  xmod = #matrix[1]
  for y = 0, h-1, 1 do
   mx = matrix[1+y%ymod]
   for x = 0, w-1, 1 do
     if mx[1+x%xmod] == 1 then
      putpicturepixel(x+ofx,y+ofy,col)
     end
   end
   if y%16==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end 
  end
end
--

--
function db.dotRandom(fraction,col)
  local c,x,y,w,h,rnd
  rnd = math.random
  w, h = getpicturesize()
  c = matchcolor(0,0,0)
  for y = 0, h-1, 1 do
   for x = 0, w-1, 1 do
     if rnd() <= fraction then
      putpicturepixel(x,y,col)
     end
   end
   if y%16==0 then updatescreen(); if (waitbreak(0)==1) then return; end; end 
  end
end
--

-- eof Patterns



-- *****************************
-- *** Fractals etc.         ***
-- *****************************

-- Fractal Pattern V1.0 by Richard Fhager (mod allows for wrapping)
--
-- Pattern matrix example: {{1,1,1},{1,0,1},{1,1,1}}
--
function db.pattern(x,y,p,n,i) -- coord as fraction of 1, pattern, offset(0), iterations (1-15)
 local px,py
 py = #p
 px = #p[1]
 while ((p[1+math.abs(math.floor(y*py))%py][1+math.abs(math.floor(x*px))%px]) > 0 and n<i) do
  x=x*px-math.floor(x*px); 
  y=y*py-math.floor(y*py);
  n = n+1
 end
 return 1 - n/i;
end
--

--
function db.patternDec(x,y,p,n,i) -- coord as fraction of 1, pattern, offset(0), iterations (1-15)
 local px,py,spfrac,nfrac,fx,fy,floor,abs
 abs, floor = math.abs, math.floor
 spfrac = 1
 nfrac = 0 
 py = #p
 px = #p[1]
 while (spfrac > 0 and n<i) do
   fy = floor(abs(y*py))%py
   fx = floor(abs(x*px))%px
   spfrac = p[fy+1][fx+1]
   if (spfrac>0) then 
    x = x*px - fx
    y = y*py - fy
    nfrac = nfrac + spfrac
   end
  n = n+1
 end
 --return 1 - n/i;
 return 1 - nfrac/i
end
--


--
function db.mandel(x,y,l,r,o,i) -- pos. as fraction of 1, left coord, right coord, y coord, iterations 

  local w,s,a,p,q,n,v,w,b

  s=math.abs(r-l);

  a = l + s*x;
  p = a;
  b = o - s*(y-0.5);
  q = b;
  n = 1;
  v = 0;
  w = 0; 

  while (v+w<4 and n<i) do n=n+1; v=p*p; w=q*q; q=2*p*q+b; p=v-w+a; end;

  return n
end
--

--
-- ... eof Fractals etc. ...
--


-- ********************************************
-- *** Color Cube / Space, Custom Functions ***
-- ********************************************
--
-- SHADES (sha): 24bit colors is too complex so we operate with less shades/bits/colors. 
-- 16 shades = 12bit = 16*16*16 = 4096 colors (or cubic-elements)
-- 32 shades = 15bit = 32*32*32 = 32768 colors

--
-- data: {color available flag, 0 (gravity/distance, calculated, init as zero)}
--
function db.initColorCube(sha,data)
  local ary,z,y,x,n,axyz 
  ary = {}
  for z = 0, sha-1, 1 do
   ary[z+1] = {}
   for y = 0, sha-1, 1 do
    ary[z+1][y+1] = {}
      if data ~= nil then
        for x = 0, sha-1, 1 do
           -- This is silly stupid, if you know how to assign one array to another (no ref), plz help!
           -- i.e. how to: data = {false,0}; myArray[z][y][x] = data. 
           ary[z+1][y+1][x+1] = {} 
           axyz = ary[z+1][y+1][x+1]
           for n = 1, #data, 1 do
             --ary[z+1][y+1][x+1][n] = data[n] 
             axyz[n] = data[n] 
           end
        end
      end
   end
  end
  return ary
end
--

--
function db.findVoid(cube,sha) -- void is point with longest distance to closest color
  local weakest,weak_i,x,y,z,c,w,cz,cy
  weakest = -1
   weak_i = {-1,-1,-1}
  for z = 0, sha-1, 1 do
   cz = cube[z+1]
   for y = 0, sha-1, 1 do
    cy = cz[y+1]
    for x = 0, sha-1, 1 do
      --c = cube[z+1][y+1][x+1]
      c = cy[x+1]
      if c[1] == true then
        w = c[2]
        if w > weakest then weakest = w; weak_i = {z,y,x}; end
      end 
    
  end;end;end
  return weak_i[1],weak_i[2],weak_i[3]
end
--

--
--
-- Nearest color version: void is selected by the point that has the greatest distance
-- to the nearest color. Higher value means greater void.
--
function db.addColor2Cube(cube,sha,r,g,b,rw,gw,bw)
  local star,x,y,z,d,rd,gd,bd,cu1,cu2,v,min
  min = math.min
  star = 0
  cube[r+1][g+1][b+1] = {false, star}
  for z = 0, sha-1, 1 do
   v = rw*(z-r); rd = v*v
   cu2 = cube[z+1]
   for y = 0, sha-1, 1 do
    v = gw*(y-g); gd = v*v
    cu1 = cu2[y+1]
    for x = 0, sha-1, 1 do
  
      v = bw*(x-b)
      d = rd + gd + v*v

      --cube[z+1][y+1][x+1][2] = math.min(d, cube[z+1][y+1][x+1][2]) -- Don't add, use nearest color

      cu1[x+1][2] = min(d, cu1[x+1][2]) 

  end;end;end
end
--

-- Should be same as original, but not 100% verified. Using a rgb+1 trick to speed up handling
--
function db.addColor2Cube_test(cube,sha,r,g,b,rw,gw,bw)
  local star,x,y,z,d,rd,gd,bd,cu1,cu2,min,v
  min = math.min
  star = 0
  r = r+1; g = g+1; b = b+1
  cube[r][g][b] = {false, star}
  for z = 1, sha, 1 do
   v = rw*(z-r); rd = v*v
   cu2 = cube[z]
   for y = 1, sha, 1 do
    v = gw*(y-g); gd = v*v
    cu1 = cu2[y]
    for x = 1, sha, 1 do 
      cu1[x][2] = min(rd+gd+(bw*(x-b))^2, cu1[x][2]) 
  end;end;end
end
--



-- Create new allowed colorlines in colorspace (ramps from which colors can be picked)
function db.enableRangeColorsInCube(cube,sha,r1,g1,b1,r2,g2,b2) 

    local div,r,g,b,n,rs,gs,bs
    div = 256 / sha
    rs = (r2 - r1) / sha / div 
    gs = (g2 - g1) / sha / div
    bs = (b2 - b1) / sha / div

    for n = 0, sha-1, 1 do

     r = math.floor(r1/div + rs * n)
     g = math.floor(g1/div + gs * n)
     b = math.floor(b1/div + bs * n)

     cube[r+1][g+1][b+1][1] = true

    end
end
--


function db.colorCigarr(shades,radius,fill_flag)
 local s,rad,radsq,step,shalf,bas,cols,found,x,y,z,bri,con,d,n
 radius = radius / 100
 step = math.floor(255 / (shades-1))
 shalf = math.floor(shades / 2)
 s = shades - 1
 rad = math.floor(shades / 2 * radius) 
 radsq = rad^2

 bas = 0
 cols = {}
 found = 0

 for z = 0, s, 1 do 
  for y = 0, s, 1 do
   for x = 0, s, 1 do

  --0.26,0.55,0.19
  bri = (x + y + z ) / 3
  --bri = math.sqrt(((x*0.26)^2 + (y*0.55)^2 + (z*0.19)^2)) * 1.5609
  con = math.floor((shades - math.abs(bri - shalf)*2) * radius)

  d = math.floor(math.sqrt((bri-x)^2 + (bri-y)^2 + (bri-z)^2))
  --d = math.floor(math.sqrt(((bri-x)*0.26)^2 + ((bri-y)*0.55)^2 + ((bri-z)*0.19)^2)) * 1.5609

  -- Filled cigarr: Less or Equal, cigarr shell: Equal
   if d == con or (d < con and fill_flag) then 
      found = found + 1
      r = bas + x * step
      g = bas + y * step
      b = bas + z * step
      cols[found] = {r,g,b}
   end

  end; end; end

  --messagebox("Colors found: "..found.."\n\n".."Run AnalyzePalette to examine")

  for n = 0, 255, 1 do
   if n < found then
    c = cols[n+1]
    setcolor(n,c[1],c[2],c[3]) 
     else
     setcolor(n,0,0,0) 
    end
  end
end -- eof colorcigarr


--
-- ... eof Color Cube ...
--



-- COLORMIX --
--
-- Returns a list of mixcolors palette entries, that are ranked by by quality & usefulness
--
-- This whole junk my partly locked on 16 shades (4096 colors/ 12bit palette precision) so don't use anything else...
--
--
function db.colormixAnalysis(sha, spare_flag, cust_dist, pallist) -- Interface
  local shades,ilist,custom_max_distance

  shades = sha -- 16 is good
  --messagebox(shades)

  custom_max_distance = -1
  if cust_dist ~= null then
    custom_max_distance = cust_dist -- in % 
  end
 
  if spare_flag == true then -- No shades here for now
    --pallist = db.makePalListShadeSPARE(256,shades)     -- 16 shades so Colorcube processes is possible
    pallist = db.makeSparePalList(256)
    pallist = db.fixPalette(pallist,1)            -- Remove doubles, Must be brightness-sorted for mixdithers
   
   else
     if pallist == null then
      pallist = db.makePalListShade(256,shades)       -- 16 shades so Colorcube processes is possible
      pallist = db.fixPalette(pallist,0)              -- Remove doubles, No need to sort?
       else
        pallist = db.makePalListShade_fromPalList(shades,pallist) 
      end
  end 


  ilist = db.makeIndexList(pallist, -1) 	  -- -1, use list order as index


   if shades > 0 then
    return db.colormixAnalysisEXT(shades,pallist,ilist,custom_max_distance) -- max distance in %
   end
   if shades == -1 then
     return db.colormixAnalysisEXTnoshade(pallist,ilist,custom_max_distance) -- max distance in %
   end
end
--
--
function db.colormixAnalysisEXT(SHADES,pallist,ilist,custom_max_distance) -- Shades, most number of mixes returned
 --messagebox("colormixAnalysisEXT") 
 local n,m,c1,c2,pairs,cube,rm,gm,bm, VACT,DACT
 local mix,total,found,dist,void,ideal,mini,maxi,bestmix,bestscore,floor,max,min

 floor,max,min = math.floor, math.max, math.min
 
 --messagebox("will now make pairs")

  pairs = db.pairsFromList(ilist,0)            -- 0 for unique pairs only, pairs are entries in pallist

 --messagebox(#pairs.." will now add colors to cube")

 cube = db.initColorCube(SHADES,{true,9999})
 for n = 1, #pallist, 1 do
   c1 = pallist[n]
   db.addColor2Cube_test(cube,SHADES,c1[1],c1[2],c1[3],0.26,0.55,0.19)
 end

 -- these values are adjusted for a 12bit palette (0-15) and perceptual weight where r+g+b = 1.0
 -- Ideal distance = 2.5 Green steps = 1.375
 -- Minimum distance = 1 Green step  = 0.55

 --messagebox("colorcube done")

 VACT = 1 -- Lower value will give more importance to smoothness
 DACT = 1 -- Lower value will give more importance to color voids

 total = 9.56  -- Max distance possible with 16 shades ((15*0.26)^2 + (15*0.55)^2 + (15*0.19)^2)^0.5 = 9.56
 ideal = 0.45  -- 1 step = 0.637
 mini = 0.35
 maxi = ideal + (total - ideal) / math.max(1, #pallist / 16)
  if custom_max_distance ~= -1 then
   maxi = total * (custom_max_distance / 100)
  end
 mix = {}
 --mix[1] =  {9e99,0,0,9e99,0,0,0}
 bestmix = -1
 bestscore = 9e99
 found = 0
 for n = 1, #pairs, 1 do

   c1 = pallist[pairs[n][1]]
   c2 = pallist[pairs[n][2]]
   --0.26,0.55,0.19
   dist = db.getColorDistance_weight(c1[1],c1[2],c1[3],c2[1],c2[2],c2[3],0.26,0.55,0.19) -- Not normalized
   --if dist > 10 then messagebox("!"..dist); end

   -- Gamma corr. doesn't seem to make much improvement if any? So we'll just keep the old bri-adj for now
   rm = floor(((c1[1]*c1[1] + c2[1]*c2[1]) / 2)^0.5)
   gm = floor(((c1[2]*c1[2] + c2[2]*c2[2]) / 2)^0.5)
   bm = floor(((c1[3]*c1[3] + c2[3]*c2[3]) / 2)^0.5)

   void = cube[rm+1][gm+1][bm+1][2]

   if dist >= mini and dist <= maxi then
     found = found + 1
     score = ((1+DACT*(dist - ideal)^2) / (1+void*VACT)) -- Lowest is best
     mix[found] = {score,pallist[pairs[n][1]][4],pallist[pairs[n][2]][4],dist,rm*SHADES,gm*SHADES,bm*SHADES,c1[1]*SHADES,c1[2]*SHADES,c1[3]*SHADES,c2[1]*SHADES,c2[2]*SHADES,c2[3]*SHADES} -- mix holds palette entry
     if score < bestscore then bestscore = score; bestmix = found; end
   end

 end


 if true == false then
 -- 2nd pass, add bestmix to colorspace. This reduces many similar mixes.
 m = mix[bestmix]
 db.addColor2Cube(cube,SHADES,m[5],m[6],m[7],0.26,0.55,0.19)
 for n = 1, #mix, 1 do
  if n ~= bestmix then
   m = mix[n]
   dist = m[4]
   void = cube[m[5]+1][m[6]+1][m[7]+1][2]
   score = ((1+DACT*(dist - ideal)^2) / (1+void*VACT)) 
   m[1] = score
  end
 end
 end

 c1,c2 = -1,-1
 if found > 0 then
  db.sorti(mix,1) 
  best = mix[1]
  c1 = best[2]
  c2 = best[3]
 end

 --return found,c1,c2
 return mix,found,c1,c2
end
--


--
-- Mixcolor without colorcube - no scoring or sorting, 24bit colors, faster...
--
-- V3.0 Distances are all 0..255 (Not sure if all functions involved are 100% correct)
-- V2.0 Gamma correction insted of Brightness adjustment of average
-- 
-- 
function db.colormixAnalysisEXTnoshade(pallist,ilist,custom_max_distance)
 --messagebox("colormixAnalysisEXTnoshade") 
 local n,m,c1,c2,pairs,cube,rm,gm,bm,max,min,floor,abs
 local mix,total,found,dist,void,ideal,mini,maxi,bestmix,bestscore,gamma,rgam

 max,min,floor,abs = math.max, math.min, math.floor, math.abs

  pairs = db.pairsFromList(ilist,0)            -- 0 for unique pairs only, pairs are entries in pallist

 total = 255 -- (Max distance possible with 24-bit palette ad Dawn3.0 color weights  unnormalize=162.53)
 ideal = 0
 mini  = 0
 maxi  = ideal + (total - ideal) / max(1, #pallist / 16)

  if custom_max_distance ~= -1 then
   maxi = total * (custom_max_distance / 100)
  end

 statusmessage("Mixcol Analysis ("..#pairs.." pairs) "); 
 updatescreen(); if (waitbreak(0)==1) then return; end

 gamma = 2.2
 rgam = 1 / gamma

 mix = {}
 found = 0
 for n = 1, #pairs, 1 do
   c1 = pallist[pairs[n][1]]
   c2 = pallist[pairs[n][2]]
   --0.26,0.55,0.19
   dist = db.getColorDistance_weightNorm(c1[1],c1[2],c1[3],c2[1],c2[2],c2[3],0.26,0.55,0.19)

  rm = ((c1[1]^gamma + c2[1]^gamma)/2)^rgam
  gm = ((c1[2]^gamma + c2[2]^gamma)/2)^rgam 
  bm = ((c1[3]^gamma + c2[3]^gamma)/2)^rgam

   if dist >= mini and dist <= maxi then
     found = found + 1
     score = 1
     mix[found] = {score,pallist[pairs[n][1]][4],pallist[pairs[n][2]][4],dist,rm,gm,bm,c1[1],c1[2],c1[3],c2[1],c2[2],c2[3]} -- mix holds palette entry
   end

 end

 --messagebox(#mix)

 return mix,found,-1,-1
end
--



-- Fuse a palettelist into an extended mix-anlysis list
function db.fusePALandMIX(pal,mix,max_score,max_dist)
 local n,c,mixlist,tot,score,dist,c1,c2,rm,gm,bm

  mixlist = {}
  tot = 0

  -- {r,g,b,n}
  for n = 1, #pal, 1 do
   tot = tot + 1
   c = pal[n]
   mixlist[tot] = {0,c[4],c[4],0,c[1],c[2],c[3],c[1],c[2],c[3],c[1],c[2],c[3]}
  end

  -- {score,col#1,col#2,dist,rm,gm,bm} low score is best
  for n = 1, #mix, 1 do
   score = mix[n][1]
   dist  = mix[n][4]
   if score <= max_score and dist <= max_dist then -- Distance is 0..255
     tot = tot + 1
      mixlist[tot] = mix[n]
   end
  end

 return mixlist
end
--



-- ********************************************
-- *** L-system (fractal curves & "plants") ***
-- ********************************************
--
-- Now a Program function (see /pfunctions), see october2017 or later version for old code
--
function db.Lsys_Do()
 messagebox("L-System functionality has been moved to a program function; /pfunctions/pfunc_Lsystem.lua")
end
--





---------------------------------------------------------------------------------------



-- ********************************************
-- ***      COMPLEX SPECIAL FUNCTIONS       ***
-- ********************************************
--

---------------------------------------------------------------------------------------
--
-- Render engine for mathscenes (Full Floyd-Steinberg dither etc)
--
-- Providing a palette activates custom (hybrid) color-match ("percep")
--
function db.fsrender(f,pal,ditherprc,xdith,ydith,percep,xonly, ord_bri,ord_hue,bri_change,hue_change,BRIWEIGHT, wd,ht,ofx,ofy) -- f is function

local o,w,h,i,j,c,x,y,r,g,b,d,fl,v,v1,v2,vt,vt1,vt2,dither,m,mathfunc,dpow,fsdiv,ord,d1a,d1b,briweight,updx
local d1,d2,o1,o2,ox,oy,min,max,floor,ceil,fsdivdpow, flj, fli, y2, xdith2, floory2, yoy
local cap,hue
 

 -- Add UnNormalized Brightness for use with optimized _Hybrid colormatch
 if #pal > 0 then
  percep = 1
  pal = db.addUnNormalizedBrightness2Palette(pal)
 end

 -- Force Hybrid-colormatch if a palette is provided
 -- No use for palette without Custom colormatching, though it is possible to provide a palette that
 -- has also been set. 

min,max,floor,ceil = math.min,math.max,math.floor,math.ceil

  -- RECACTIVATED 2016 SINCE Matchcolor2 is unreliable (and we may change the colorspace)
  -- percep & pal is no longer used, matchcolor2 is always active, but the code is kept if there's ever a need to
  -- study the effect of perceptual colorspaces versus matchcolor

  if ord_bri == null then ord_bri = 0; end
  if ord_hue == null then ord_hue = 0; end
  if bri_change == null then bri_change = 0; end
  if hue_change == null then hue_change = 0; end
  if BRIWEIGHT == null then BRIWEIGHT = 0; end  

  briweight = BRIWEIGHT / 100

  ord = {{0,4,1,5},
         {6,2,7,3},
         {1,5,0,4},
         {7,3,6,2}}
 --{1,9,3,11, 13,5,15,7, 4,12,2,10, 16,8,14,6} -- Good

 
   --i = ((ord[y % 4 + 1][x % 4 + 1])*28.444 - 99.55556)/100 * 16
   
      function hue(r,g,b,deg)
         local i,brin,diff,brio,r2,g2,b2
         r2,g2,b2 = db.shiftHUE(r,g,b,deg)
         brio = db.getBrightness(r,g,b)
         for i = 0, 5, 1 do -- 6 iterations, fairly strict brightness preservation
          brin = db.getBrightness(r2,g2,b2)
          diff = brin - brio
diff = 0
          r2,g2,b2 = db.rgbcap(r2-diff, g2-diff, b2-diff, 255,0)
         end
        return r2,g2,b2
       end



fsdiv = 16
if xonly == 1 then fsdiv = 7; end -- Only horizontal dither 

dither = 0; if ditherprc > 0 then dither = 1; end

-- When using standard error-diffusion brightness-matching is not really compatible(?)
matchfunc = matchcolor2
--if dither == 1 then matchfunc = matchcolor; end

dpow = ditherprc / 100


if wd == null then
 w,h = getpicturesize()
  else w = wd; h = ht
end

if ofx == null then
 ox,oy = 0,0
  else ox = ofx; oy = ofy
end


 function cap(v)
  return min(255,max(0,v))
 end



 --
 fl = {}
 fl[1] = {}
 fl[2] = {}
 i = 1
 j = 2
 --

  -- Read the first 2 lines
  v1 = ydith/2 + 0%2 * -ydith
  v2 = ydith/2 + 1%2 * -ydith
  for x = 0, w - 1, 1 do
    d1a,d1b = 0,0
    if ord_bri > 0 then
     o1 = ord[0 % 4 + 1][x % 4 + 1]
     d1a = (o1*28.444 - 99.55556)/100 * ord_bri
     o2 = ord[1 % 4 + 1][(x+2) % 4 + 1] -- +2 To get it in right sequence for some reason
     d1b = (o2*28.444 - 99.55556)/100 * ord_bri
    end 
   -- We skip Hue-ordering for now
   vt1 = v1 + xdith/2 + (x+floor(0/2))%2 * -xdith + d1a
   vt2 = v2 + xdith/2 + (x+floor(1))%2 * -xdith + d1b -- Ok, not sure why 1/2 doesn't make for a nice pattern so we just use 1
   r,g,b = f(x, 0, w, h)
   fl[i][x] = {cap(r+vt1),cap(g+vt1),cap(b+vt1)}
   r,g,b = f(x, 1, w, h)
   fl[j][x] = {cap(r+vt2),cap(g+vt2),cap(b+vt2)}
  end

updx = max(4,ceil(1200 / w)) -- 1200 = every 4th line, 120 = every 10th line

fsdivdpow = dpow / fsdiv 

for y = 0, h-1, 1 do
 fli = fl[i]
 flj = fl[j]
 yoy = y + oy
 for x = 0, w-1, 1 do

  o = fli[x]
  r = o[1] + bri_change
  g = o[2] + bri_change
  b = o[3] + bri_change

  if hue_change ~= 0 then
   r,g,b = hue(r,g,b,hue_change)
  end
 
  if percep == 1 then
 
   -- Note index flag is false since makeSamplePal has been used (no indexes). This to make old Lightsource scripts work.
   -- We should never provide any pals but just have a hybrid-match option and then fetch the screen-colors directly in fsRender (makePal)
   -- Then index_flag would be true as it should (false means we have two, possibly differing, sets of data; the screen-palette and the pal-list)
   --c = matchfunc(r,g,b,briweight)
   --c = db.getBestPalMatchHYBRID({r,g,b},pal,briweight,false)
   c = db.getBestPalMatch_Hybrid(r,g,b,pal,briweight,false) -- 25% faster for 256 colors (also uses db.addUnNormalizedBrightness2Palette)
    else
      c = matchfunc(r,g,b,briweight) -- Upd Sep 2016, note that a 4th arg (briweight) will crash with [matchcolor], only use matchcolor2
  end

  --c = matchcolor2(r,g,b,briweight)

  putpicturepixel(x+ox,yoy,c)

  if dither == 1 then
   if x>1 and x<w-1 and y<h-1 then
     rn,gn,bn = getcolor(c)
     --re = ((r - rn) / fsdiv) * dpow
     --ge = ((g - gn) / fsdiv) * dpow
     --be = ((b - bn) / fsdiv) * dpow
     re = (r - rn) * fsdivdpow
     ge = (g - gn) * fsdivdpow
     be = (b - bn) * fsdivdpow
     o = fli[x+1]; --r,g,b = o[1],o[2],o[3]  
     fli[x+1] = {cap(o[1]+re*7), cap(o[2]+ge*7), cap(o[3]+be*7)}
     if xonly ~= 1 then
       o = flj[x]; --r,g,b = o[1],o[2],o[3]    
       flj[x] =   {cap(o[1]+re*5), cap(o[2]+ge*5), cap(o[3]+be*5)}
       o = flj[x-1]; --r,g,b = o[1],o[2],o[3]    
       flj[x-1] = {cap(o[1]+re*3), cap(o[2]+ge*3), cap(o[3]+be*3)}
       o = flj[x+1]; --r,g,b = o[1],o[2],o[3]    
       flj[x+1] = {cap(o[1]+re), cap(o[2]+ge), cap(o[3]+be)}
     end
    end
   end

 end

  vt = 0
  v = ydith/2 + y%2 * -ydith
  floory2 = floor(y/2)
  xdith2 = xdith / 2
  -- Flip ED lines and read the nextline
  i,j = j,i
  flj = fl[j]
  y2 = y + 2
  for x = 0, w - 1, 1 do

    d1,d2 = 0,0
    if ord_bri > 0 then
     o = ord[y % 4 + 1][x % 4 + 1]
     d1 = (o*28.444 - 99.55556)/100 * ord_bri
    end 
   
   --vt = v + xdith/2 + (x+floor(y/2))%2 * -xdith + d1
   vt = v + xdith2 + (x+floory2)%2 * -xdith + d1
   r,g,b = f(x, y2, w, h)
   --r,g,b = getsparecolor(getsparepicturepixel(x,y))

   if ord_hue > 0 then
    o = ord[y % 4 + 1][x % 4 + 1]
    d2 = (((o + 3.5) % 7) / 7 - 0.5) * ord_hue
    r,g,b = hue(r,g,b,d2)
   end
  
   flj[x] = {cap(r+vt),cap(g+vt),cap(b+vt)}
  end

 if db.donemeter(updx,y,w,h,true,ofx,ofy) then return; end

end


end
-- FS render

--
function db.fsrenderControl(f, title, sampal,usepal,scenepal, ditherprc,xdith,ydith, briweight, sampalcols)

 local OK,w,h,n,npal,pal

 sampal     = sampal     or   1   -- 1. Make Palette
 usepal     = usepal     or   0   -- 2. Use Current Palette
 scenepal   = scenepal   or   0   -- 3. Set 'Scenery' Palette
 ditherprc  = ditherprc  or   90  --    Floyd-Steinberg dither: 0-100% (nom=90)
 xdith      = xdith      or   2   --    X dither: 0-64 (nom=5)
 ydith      = ydith      or   4   --    Y Dither: 0-64 (nom=10)
 briweight  = briweight  or   25  --    ColorMatcing Brightness Weight: 0-100% (nom=25)
 sampalcols = sampalcols or   256 --    Colors in make palette


   OK,sampal,usepal,scenepal,ditherprc,xdith,ydith,briweight,sampalcols = inputbox(title, 
                           "1. Make Sample-Palette*",     sampal,  0,1,-1, 
                           "2. Use Current Palette",       usepal,  0,1,-1,                     
                           "3. Use Scenery Palette",     scenepal,  0,1,-1,                                               
                           "FS Dither Power %",         ditherprc,  0,200,0,
                           "X Bri-Dither: 0-64",             xdith,  0,64,0,
                           "Y Bri-Dither: 0-64",             ydith,  0,64,0,
                           "ColMatch Bri-Weight %",     briweight,  0,100,0,
                           "* Sample-Palette Cols",    sampalcols,  2,256,0
                           --"Perceptual ColorMatch",     0,  0,1,0                        
   );

 if OK == true then

  if sampal == 1 then
   w,h = getpicturesize()
   npal = db.makeSamplePal(w,h,sampalcols,f)
   for n=1, #npal, 1 do setcolor(n-1,npal[n][1],npal[n][2],npal[n][3]); end
   for n=#npal+1, 256, 1 do setcolor(n-1,npal[1][1],npal[1][2],npal[1][3]); end
  end

  if scenepal == 1 then db.setSceneryPalette(); end
  pal = {}
 
  --function db.fsrender(f,pal,ditherprc,xdith,ydith,percep,xonly, ord_bri,ord_hue,bri_change,hue_change,BRIWEIGHT, wd,ht,ofx,ofy) -- f is function
  db.fsrender(f,pal,ditherprc,xdith,ydith, null,null,null,null,null,null, briweight)
 end -- ok

end
--
-------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--
-- PARTICLE v1.0
-- 
-- Draw Sphere or Disc to any target with gradients that may fade to background
--
-- type: "sphere" - volmetric planet-like disc
--       "disc"   - plain disc
-- mode: "blend"  - mix graphics with background color
--       "add"    - add graphics to background color
-- wd,ht:         - Max Width/Height of drawing area, i.e. screen size (needed if drawing to an array-buffer)
-- sx,sy:         - drawing coordinates (center)
-- xrad,yrad:     - x & y radii
-- rgba1:         - rgb+alpha array of center color: {r,g,b,a}, alpha is 0..1 where 1 is no transparency, Extreme rgb-values allowed
-- rgba2:         - rgb+alpha array of edge color: {r,g,b,a}, alpha is 0..1 where 1 is no transparency, Extreme rgb-values allowed
-- update_flag:	  - Display rendering option (and add break feature)
-- f_get:	  - Get pixel function: use getpicturepixel if reading from image (set null for image default)
-- f_put:	  - Put pixel function: use putpicturepixel if drawing to image (set null for image default)
-- f_recur:       - Optional custom control-function for recursion (set null if not used)
-- recur_count    - Recursion depth counter, for use in combination with a custom function (f_recur), 0 as default
--
-- Ex: particle("sphere","add", w,h, w/2,h/2, 40,40, {500,400,255, 0.8},{0,-150,-175, 0.0}, true, null, null, null, 0)
--
function db.particle(type,mode,wd,ht,sx,sy,xrad,yrad,rgba1,rgba2, update_flag, f_get, f_put, f_recur, recur_count)

 local x,y,rev,dix,diy,r3,g3,b3,px,py,alpha,ralpha,add,q,rgb,rgb1,rgb2,rgb3,n,def_get,def_put,mx
 local oy05sq

  mx = math.max

  function def_get(x,y) 
   local r,g,b  
    r,g,b = getcolor(getpicturepixel(x,y)); 
    return {r,g,b}
  end
  function def_put(x,y,r,g,b)     putpicturepixel(x,y, matchcolor2(r,g,b,0.65)); end 
  if f_get == null then f_get = def_get; end
  if f_put == null then f_put = def_put; end

 q = {[true] = 1, [false] = 0}

 rgb,rgb1,rgb2 = {},{},{}

 if mode == 'blend' then
   add = 1
 end

 if mode == 'add' then
   add = 0
 end

 dix = xrad*2
 diy = yrad*2

 for y = 0, diy, 1 do
  py = sy+y-yrad; oy = y / diy;
  if (py >= 0 and py < ht) then
  
   oy05sq = (0.5-oy)*(0.5-oy)
  
  for x = 0, dix, 1 do
   px = sx+x-xrad; ox = x / dix;
   if (px >= 0 and px < wd) then

   if type == 'sphere' then  -- Sphere
    -- a = (mx(0,0.25 - ((0.5-ox)^2+(0.5-oy)^2)))^0.5 * 2
    a = ( mx(0, 0.25 - ( (0.5-ox)^2 + oy05sq) ))^0.5 * 2
   end
  
   if type == 'disc' then  -- Disc
    a = 1-((0.5-ox)^2 + oy05sq)^0.5*2
   end

   if a>0 then

    rev    = 1-a
    rgb3   = f_get(px,py)
    alpha  = mx(rgba1[4] * a + rgba2[4] * rev , 0)
    ralpha = 1 - alpha * add 

    for n = 1, 3, 1 do 
     rgb1[n] = q[rgba1[n]==-1]*rgb3[n] + q[rgba1[n]~=-1]*rgba1[n] -- Fade from background? 
     rgb2[n] = q[rgba2[n]==-1]*rgb3[n] + q[rgba2[n]~=-1]*rgba2[n] -- Fade to background? 
     rgb[n] = (rgb1[n] * a + rgb2[n] * rev) * alpha + rgb3[n] * ralpha
    end

    f_put(px, py, rgb[1],rgb[2],rgb[3]);
    
   end

  end -- if x is good
  end -- x
  if update_flag then updatescreen(); if (waitbreak(0)==1) then return; end; end
  end -- if y is good
 end -- y

 if f_recur ~= null then  -- recursion
  f_recur(type,mode,wd,ht,sx,sy,xrad,yrad,rgba1,rgba2, update_flag, f_get, f_put, f_recur, recur_count); 
  updatescreen(); if (waitbreak(0)==1) then return; end;
 end

end
-- eof PARTICLE


  --
  -- MedianCut a larger palette-list from a MathScene to produce a high-quality BriSorted palette for the final render/colormatching
  --
  function db.makeSamplePal(w,h,colors,frend)
   local n,x,y,r,g,b,pal,xstep,ystep,res,m,rnd,w1,h1
   n,pal,m,rnd,w1,h1 = 0,{},math, math.random, w-1, h-1
   --res = 255
   --xstep = m.ceil(w/res)
   --ystep = m.ceil(h/res)
   xstep = m.floor(w^0.25) 
   ystep = m.floor(h^0.25) 

   for y = 0, h-1, ystep do
   for x = (y%2)*m.floor(xstep/2), w1, xstep do
     r,g,b = frend(x,y,w,h)
     n = n+1
     r,g,b = db.rgbcapInt(r,g,b,255,0)
     pal[n] = {r,g,b,0}
    end;end

    for x = 0, m.ceil((w+h)/2+(w*h)^0.5), 1 do -- Some random points
     r,g,b = frend(rnd(0,w1), rnd(0,h1),w,h)
     n = n+1
     r,g,b = db.rgbcapInt(r,g,b,255,0)
     pal[n] = {r,g,b,0}
    end
    return db.fixPalette(db.medianCut(pal, colors, true, false, {0.26,0.55,0.19}, 8, 0),1) -- pal, cols, qual, quant, weights, bits, quantpower
 end
  --

-- Probably not in use by any Toolbox scripts anymore...(We're trying to use the interpolation library)
-- Backdrop/Gradient Render (May be written to a matrix for rendering with db.fsrender)
--
 function db.backdrop(p0,p1,p2,p3,fput,ip_mode) -- points:{x,y,r,g,b}, IpMode "linear" is default

   local x,y,ox,oy,xr,yr,r,g,b,ax,ay,w,h

   ax,ay = p0[1],p0[2]

   w = p1[1] - p0[1]
   h = p2[2] - p0[2]

  for y = 0, h, 1 do -- +1 to fill screen with FS-render

    oy = y/h
    if ip_mode == "cosine" then oy = 0.5 - math.cos(oy * math.pi) * 0.5; end
    yr = 1 - oy

   for x = 0, w, 1 do 

    ox = x/w
    if ip_mode == "cosine" then ox = 0.5 - math.cos(ox * math.pi) * 0.5; end
    xr = 1 - ox

    r = (p0[3]*xr + p1[3]*ox)*yr + (p2[3]*xr + p3[3]*ox)*oy;
    g = (p0[4]*xr + p1[4]*ox)*yr + (p2[4]*xr + p3[4]*ox)*oy;
    b = (p0[5]*xr + p1[5]*ox)*yr + (p2[5]*xr + p3[5]*ox)*oy;

   fput(x+ax,y+ay,r,g,b)
   --fput(x+ax,y+ay,matchcolor(r,g,b))


   end;end

  end
-- eof backdrop



------------------------------------------------------
-- SPLINES --
--------------------------------------------------------

--
function db.splinePoint(x0,y0,x1,y1,x2,y2,points,point)
 local x,y,sx1,sy1,sx2,sy2,f,fi

  f = point * 1 / points
  fi = 1 - f

  sx1 = x0*fi + x1*f  
  sy1 = y0*fi + y1*f 

  sx2 = x1*fi + x2*f  
  sy2 = y1*fi + y2*f 

  x = sx1 * fi + sx2 * f
  y = sy1 * fi + sy2 * f

  return x,y
end
--


--
function db.drawSplineSegment(x0,y0,x1,y1,x2,y2,x3,y3,points,col)
 
 local list,fx,fy,x,y,n,l

 list = db.makeSplineData(x0,y0,x1,y1,x2,y2,x3,y3,points) 

 fx,fy = list[1][1],list[1][2]

 for n = 2, #list, 1 do
  l = list[n]
  x,y = l[1],l[2]
  db.line(fx,fy,x,y,col)
  fx,fy = x,y
 end

end
--


--
function db.drawSplineSegment_AA(x0,y0,x1,y1,x2,y2,x3,y3,points,col,transp,gamma)
 
 local list,fx,fy,x,y,n,l

 list = db.makeSplineData(x0,y0,x1,y1,x2,y2,x3,y3,points) 

 fx,fy = list[1][1],list[1][2]

 for n = 2, #list, 1 do
  l = list[n]
  x,y = l[1],l[2]
  r,g,b = getcolor(col); db.lineTranspAAgamma(fx,fy,x,y, r,g,b, transp, gamma)
  fx,fy = x,y
 end

end
--



-- zx = 2*x1 - (x0+x2)/2
--
-- Length = Points / 2 + 1
function db.makeSplineData(x0,y0,x1,y1,x2,y2,x3,y3,points) -- Does spline segment p1-p2
 local n,f,x,y,sx1,sy1,sx2,sy2,mid,zx1,zy1,zx2,zy2,fx,fy,list,pd,mid2

 list = {}
 
 mid = math.floor(points / 2) 
 -- Extended Bezier points
 zx1 = 2*x1 - (x0+x2)*0.5  
 zy1 = 2*y1 - (y0+y2)*0.5
 zx2 = 2*x2 - (x1+x3)*0.5
 zy2 = 2*y2 - (y1+y3)*0.5

 pd =  1 / points * 2
 mid2 = mid*2

 fx,fy = x1,y1 -- Segment to be drawn (0),1 - 2,(3)
 for n = 0, mid, 1 do

  f = n * pd

  sx1,sy1 = db.splinePoint(x0,y0,zx1,zy1,x2,y2,mid2, mid + n)
  sx2,sy2 = db.splinePoint(x1,y1,zx2,zy2,x3,y3,mid2, n)

  x = sx1 * (1-f) + sx2 * f
  y = sy1 * (1-f) + sy2 * f

  list[n+1] = {x,y}

 end

 return list
end
--



-- zx = 2*x1 - (x0+x2)/2
--
function db.drawSplineSegmentORG(x0,y0,x1,y1,x2,y2,x3,y3,points,col) -- Does spline segment p1-p2
 local n,x,y,sx1,sy1,sx2,sy2,mid,zx1,zy1,zx2,zy2,fx,fy
 
 mid = math.floor(points / 2) 
 -- Extended Bezier points
 zx1 = 2*x1 - (x0+x2)/2  
 zy1 = 2*y1 - (y0+y2)/2
 zx2 = 2*x2 - (x1+x3)/2
 zy2 = 2*y2 - (y1+y3)/2

 fx,fy = x1,y1 -- Segment to be drawn (0),1 - 2,(3)
 for n = 0, mid, 1 do

  f = n * 1 / points * 2

  sx1,sy1 = db.splinePoint(x0,y0,zx1,zy1,x2,y2,mid*2, mid + n)
  sx2,sy2 = db.splinePoint(x1,y1,zx2,zy2,x3,y3,mid*2, n)

  x = sx1 * (1-f) + sx2 * f
  y = sy1 * (1-f) + sy2 * f

  --putpicturepixel(x,y,col)
  db.line(fx,fy,x,y,col)
  fx,fy = x,y

 end

end
--

-- eof Splines


--------------------------------------------
------------ LIGHTSOURCE -------------------
--------------------------------------------

-- db.fillTriangle(p,fcol,lcol,fill,wire) -- p = list of 3 points
-- Lightsourced


--
function db.calcLightRGB(fcol,z1,z2,z3,light,amp,scl,amb)
 local m, rgb, deg,xd,yd,rx,ry,Pax,Pay,Lax,Lay,n,az,el,co,sp,xD,yD,rdc,lx,ly
 m = math
 rgb = {fcol[1],fcol[2],fcol[3]}
 deg = 180 / math.pi

 yd = (z1 - z2) * scl
 xd = (z1 - z3) * scl
 --rx = m.acos(m.sqrt(1 / (1 + xd*xd))) * db.sign(xd)
 --ry = m.acos(m.sqrt(1 / (1 + yd*yd))) * db.sign(yd)

 rx = m.atan(xd) -- identical to m.acos(m.sqrt(1 / (1 + xd*xd))) * db.sign(xd) ?
 ry = m.atan(yd)

 -- Rotation/Angle of plane
 Pax = m.cos(ry) * rx
 Pay = m.cos(rx) * ry

 for n = 1, #light, 1 do

  az = light[n][1] / deg
  el = light[n][2] / deg
  co = light[n][3]
  sp = light[n][4]
  -- Rotation/Angle of light
  Lax = el * m.cos(az) 
  Lay = el * m.sin(az)

  lx = Lax - Pax 
  ly = Lay - Pay

  xD = m.cos(lx)
  yD = m.cos(ly)

  rdc = amb + amp * m.pow(m.max(0,xD * yD),sp) -- Reduce mult (0..1)
 
  rgb[1] = rgb[1] + co[1] * rdc
  rgb[2] = rgb[2] + co[2] * rdc
  rgb[3] = rgb[3] + co[3] * rdc

 end

 return rgb, lx,ly
end
--

--
function db.calcLightRGBopt(fcol,z1,z2,z3,light,amp,scl,amb) -- WIP optimized version w/o the (odd) lx,ly return
 local m, c, cos, sin, rgb, deg,xd,yd,rx,ry,Pax,Pay,n,az,el,co,sp,xD,yD,rdc,li,r,g,b

 cos,sin,m,deg,r,g,b = math.cos,math.sin,math, 180 / math.pi, fcol[1],fcol[2],fcol[3]
 
 rx = m.atan((z1 - z3) * scl) -- Not 100% sure this is always correct, must test moving lights around
 ry = m.atan((z1 - z2) * scl)

 Pax, Pay = cos(ry) * rx, cos(rx) * ry -- Rotation/Angle of plane

 for n = 1, #light, 1 do

  li = light[n]
  az = li[1] / deg
  el = li[2] / deg
  co = li[3]
  sp = li[4]

  xD = cos(el * cos(az) - Pax) -- Rotation/Angle of light
  yD = cos(el * sin(az) - Pay)

  --rdc = amb + amp * m.pow(m.max(0,xD * yD),sp) -- Reduce mult (0..1)
  rdc = amb + amp * (m.max(0,xD * yD))^sp -- Reduce mult (0..1)

  --for c = 1, 3, 1 do
  -- rgb[c] = rgb[c] + co[c] * rdc
  --end

  r = r + co[1] * rdc
  g = g + co[2] * rdc
  b = b + co[3] * rdc

 end

 return {r,g,b}
end
--


---------------------------------
-- eof Lightsource
---------------------------------

-----------------------------------------------
-- Field Gradient ("Smooth Voronoi diagram") --
-----------------------------------------------
-- Create a gradient between a set of data-points (colors). 
-- The total contribution to a location is normalized; f.ex ([255,0,0] and [0,0,255] both at the same distance will normalize to [127,0,127])
-- The Exponent dictates how the impact of a value/color decreases with distance. 
-- The higher the exponent the more weight is given to the closest color(s), and the result will approach that of a Voronoi-diagram (exp = +9).
-- Exponent: 1 = Linear distance, 2 = Squared etc. Use 1-2 for smooth/blurry results, and +5 for more distinct cells.
--
-- points = {{x,y,r,g,b},...}
-- exponent: distance exponent, 1 = Linear, 2 = squared...
-- f_put: output function, render to screen ex. (function(x,y,r,g,b) putpicturepixel(x, y, matchcolor2(r,g,b));end), or write to array.
--
function db.makeFieldGradient(w,h, points, exponent, f_put, update_flag)

 local x,y,n,p,sum,px,rt,gt,bt,fdist, dist, dists, ydiff, exp, r,g,b,updfreq

 exp = exponent * 0.5 -- speed optimization (we have removed the root from Pythagoras)

 updfreq = 1 + math.floor(60 / (#points)^0.5) -- 25 pts = 13 lines, 50 = 9, 100 = 7, 500 = 3, 1000 = 2, 3601 = 1

 dists, ydiff = {},{}

 for y = 0, h - 1, 1 do

  --[[
  if update_flag then
   for x = 0, w - 1, 1 do
    r,g,b = getcolor(getbackuppixel(x,y))
    putpicturepixel(x,y,matchcolor((r+128)%255, (g+128)%255, (b+128)%255))
   end
   updatescreen(); waitbreak(0)
  end
  --]]

  for n = 1, #points, 1 do
   ydiff[n] = (points[n][2] - y)^2 --  Distances in y are the same for all points on x
  end 
  for x = 0, w - 1, 1 do
  
    sum = 0
    for n = 1, #points, 1 do
     px = points[n][1]-x;
     -- ? Make special case when exp = 0.5 (Linear) and use NO exponent (distances are normalized)
     dist = 1 + (px*px + ydiff[n])^exp -- +1 prevents division by zero, adding/changing this value has no effect on the result
   
     sum = sum + 1/dist
     dists[n] = dist
    end

    rt,gt,bt = 0,0,0
    for n = 1, #points, 1 do
     fdist = 1 / (dists[n] * sum) -- Normalize
     p = points[n]
     rt = rt + p[3] * fdist
     gt = gt + p[4] * fdist
     bt = bt + p[5] * fdist
    end

    f_put(x,y,rt,gt,bt) --c = matchcolor2(rt,gt,bt); putpicturepixel(x, y, c);

  end
  --if update_flag then updatescreen();if (waitbreak(0)==1) then return end; end
  if update_flag and db.donemeter(updfreq,y,w,h,true) then return; end
 end

end
-- eof FieldGradient
