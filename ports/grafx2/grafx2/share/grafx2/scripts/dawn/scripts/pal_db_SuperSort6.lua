--PALETTE: SuperSort V2.1
--Advanced palette sorting & remapping 
--by Richard 'DawnBringer' Fhager
-- Email: dawnbringer@hem.utfors.se


dofile("../libs/dawnbringer_lib.lua")
--> db.makePalListRange(start,ends)
--> db.fixPalette(pallist,sort_flag)
--> db.newArrayInit2Dim
--> db.newArrayInsertLast
--> db.getHUE(r,g,b,0,greytolerance)
--> db.getBrightness(r,g,b)
--> db.getAppSaturation(r,g,b)	
--> db.sorti(list,index)
--> db.remapImage(org)

q1 = 0
q2 = 0
q3 = 0
q4 = 0
q5 = 0
remap = 1
fix = 1
start = 0
ends = 255

OK,histo,q5,q4,q1,q2,q3,fix,start,ends = inputbox("Sort Palette: Select method...",
                       
                           "1. Histogram (* n/a)",     1,  0,1,-1,
                           "2. Brightness (real)",     0,  0,1,-1,
                           "3. Hue - Bri - Sat",       0,  0,1,-1,
                           "4. Sat - Hue - Bri",       0,  0,1,-1,
                           "5. Sat - Bri - Hue",       0,  0,1,-1, 
                           "6. Bri - Hue - Sat",       0,  0,1,-1,
                           --"REMAP IMAGE?",          remap,  0,1,0,  
                           "*Remove Doubles",         fix,  0,1,0,
                           "*Start Color: 0-254",       0,  0,255,0, 
                           "  *End Color: 1-255",     255,  1,255,0   
);

if OK == true then
  m = q1 + q2*2 + q3*4 + q4*8 + q5*16
  --if m == 0 then messagebox("Select a sorting mode!"); OK = false; end
  modes = {1,2,0,3,0,0,0,4,0,0,0,0,0,0,0,5}
  Q = modes[m]
  --if Q == 0 then messagebox("Only check one sorting mode!"); OK = false; end
end

if OK == true then


if histo == 1 then -- Histogram
 w, h = getpicturesize()
  list = {}
  for n = 1, 256, 1 do list[n] = 0; end
  for y = 0, h - 1, 1 do
    for x = 0, w - 1, 1 do
      c = getpicturepixel(x,y) + 1
      list[c] = list[c] + 1
    end
  end
 
  ilist = {}
  for n = 1, 256, 1 do
   r,g,b = getcolor(n-1) 
   ilist[n] = {w*h-list[n],n,r,g,b} -- Sorting is lo-hi so we trick it
  end
  db.sorti(ilist,1)
  org={}
  for n = 1, 256, 1 do 
   i = ilist[n]
   org[i[2]] = n-1
   setcolor(n-1,i[3],i[4],i[5])
  end

end -- histo



----
if histo == 0 then -- HSV sortings

-- Analysis 
--palList = db.makePalList(256)
palList = db.makePalListRange(start,ends)
if fix == 1 then
 palList = db.fixPalette(palList,1)
 --for n = start, ends, 1 do setcolor(n,0,0,0); end
end

colors = #palList
--greytolerance = 0.1 + colors / 2000 -- Ability to count as greyshade
--greytolerance = 0.0078125 * 4
greytolerance = (0.0078125 * 64) / math.sqrt(colors)

--messagebox(db.getSaturation(87,66,0))

set = {}
--        Hue-Bri-Sat
set[1] = {15, 256, 5}    -- Sat-Hue-Bri
set[2] = {256,8,   4}    -- Sat-Bri-Hue
set[3] = {12, 8,   256}  -- Bri-Hue-Sat
set[4] = {15, 256, 32}   -- Hue-Bri-Sat (15-16 seem good for hue)
set[5] = {16,256,16}     -- Brightness (Hue & Sat is not active but used to calc the range value)

--set[4] = {9, 256, 32}

huerange = set[Q][1]
brirange = set[Q][2]
satrange = set[Q][3]

ymult = huerange / 6.5 -- 0.5 is for grey (+2 is grey+modulus-trick to make grey 0)

range = (huerange+2) * brirange * satrange 

match = db.newArrayInit2Dim(range,0,nil) 


for n = 1, colors, 1 do
 c = palList[n] -- r,g,b,n
 --r,g,b = getcolor(c)
 r = c[1]
 g = c[2]
 b = c[3]
 --i = c[4]
 hue = (((db.getHUE(r,g,b,greytolerance) + 1) % 7.5) * ymult)       -- 0 - 5.999 (6.5)
 bri = db.getBrightness(r,g,b)				-- 0 - 255
 --sat = db.getSaturation(r,g,b)				-- 0 - 255
 --sat = db.getTrueSaturationX(r,g,b)				-- 0 - 255
 --sat = db.getAppSaturation(r,g,b)				-- 0 - 255
 sat = db.getPurity_255(r,g,b)

 sat_a = math.floor(sat / 256 * satrange)
 bri_a = math.floor(bri / 256 * brirange)
 hue_a = math.floor(hue) 

 --messagebox(sat_a.." "..bri_a.." "..hue_a)

-- Brightness
if Q == 5 then val = math.floor(bri * brirange); end

 -- Hue-Bri-Sat
if Q == 4 then val = hue_a * satrange*brirange + bri_a * satrange + sat_a; end


 -- Hue-Sat-Bri
--if Q == 4 then val = hue_a * satrange*brirange + sat_a * brirange + bri_a; end

 -- Sat-Hue-Bri
if Q == 1 then val = sat_a * (huerange+1)*brirange + hue_a * brirange + bri_a; end
 -- Sat-Bri-Hue
if Q == 2 then val = sat_a * (huerange+1)*brirange + bri_a * huerange + hue_a; end
 -- Bri-Hue-Sat
if Q == 3 then val = bri_a * (huerange+1)*satrange + hue_a * satrange + sat_a; end

 val = val + 1

 if val > range then messagebox(val.." - "..range.." "..hue_a.." "..bri_a.." "..sat_a.." "..sat); break; end

 --messagebox(n.." "..val)

 if match[val] == nil then 
  match[val] = {n} -- i is color in palList
  else match[val] = db.newArrayInsertLast(match[val],n);
 end

end

--messagebox("Let's sort...")

if fix == 1 then
 for n = start, ends, 1 do setcolor(n,0,0,0); end
end

org = {}
assigned = start
for n = 1, range, 1 do
 list = match[n]
 if list ~= nil then
  -- sublists should be sorted on brightness?
  for u = 1, #list, 1 do
     col = list[u]
     c = palList[col]
     i = c[4]
     org[i+1] = assigned -- quick way to remap without matchcolor
     setcolor(assigned,c[1],c[2],c[3])
     assigned = assigned + 1
  end
 end
end


end -- Q < 6

if remap == 1 then
 db.remapImage(org)
end


end -- eof OK
