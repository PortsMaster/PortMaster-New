--SCENE: Optimize Image & Palette 
--(DeCluster Colors)
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
--  Usage list:
--> db.makePalList(cols)
--> db.fixPalette(pallist, sort_flag)
--> db.makeHistogram()
--> db.stripBlackFromPalList(pallist)
--> db.makePalListFromHistogram(hist)
--> db.deCluster
--> db.remap

--
-- Now this script is kind of messy...actually the mighty deCluster-algorithm could do even the
-- unused-colors and palette-duplicates removal that is now done by the other mess of code.
-- However I keep it this way so the user have a greater control of the individual operations
-- thus helping to keep the palette closer to the original order.
--
-- Histogram (remove unused colors) also add weights to the occurencies of colors when declustering,
-- If not active; only the palette is considered.

REMAP = 1 -- If Hybrid is not selected then we remap using the cluster-fusion colors
OK,UNUSED,DUPLIC,ARRANG,DCLUST,RADIUS,PROT,DCWT,REMAPHYBRID,briweight = inputbox("Optimize Image & Palette",
                           "Only keep/work Image-cols",        1,  0,1,0, --H/h
                           "Remove Duplicate Cols",     1,  0,1,0,
                           "ReArrange Palette",         1,  0,1,0,
                           "Reduce Colors, DeCluster*", 0,  0,1,0,
                           "*DeCluster Radius %: 0-50",  3.5,0, 50,3,
                           "*Dominant Col Protect Pow",   0,  0,10,3, 
                           "*Weigh Image Cols   ",   1,  0,1,0, --W/w
                           "Hybrid ColMatch#",         1,  0,1,0,
                           "#ColMatch Bri-Weight %", 25,  0,100,0  
--                                                  
);


if OK == true then

-- Result counts
pre_Used = 0
pre_Duplic = 0
epi_Used = 0
epi_Duplic = 0
pre_palUniques = 0
epi_palUniques = 0

-- PreCheck (hist is created here and also used later)

pre_palUniques = #db.fixPalette(db.makePalList(256),0)

hist = db.makeHistogram()
ulist = {}
for n = 1, 256, 1 do
    if hist[n] > 0 then
      r,g,b = getcolor(n-1)
      i = 1 + r * 65536 + g * 256 + b;
      if ulist[i] ~= nil then 
         pre_Duplic = pre_Duplic + 1; 
      end
      ulist[i] = i
      pre_Used = pre_Used + 1 
    end
end 
--

Black_in_image = null

w, h = getpicturesize()

org = {} -- Remap list

 -- Histogram
if UNUSED == 1 then

  --messagebox("Removing unused")
  -- hist
  Black_in_image = false
  for n = 1, 256, 1 do
    if hist[n] == 0 then 
       setcolor(n-1,0,0,0); 
    end 
    -- Black used?
    if hist[n] > 0 then
     r,g,b = getcolor(n-1)
     if r+g+b == 0 then Black_in_image = true; end
    end
  end
   
  -- Fix palette, Create assign list for remapping compability
  -- This for the option of keeping possible duplicate colors and arrange the palette!?...
  if ARRANG == 1 and DUPLIC == 0 and DCLUST == 0 then
    --messagebox("ReArranging")
    count = 0
    for n = 1, 256, 1 do
      if hist[n] > 0 then
       setcolor(n-1,0,0,0)
       setcolor(count,getbackupcolor(n-1))
       org[n] = count -- New location of this color
       count = count + 1 
      end 
    end
  end;
end; -- unused
-- eof histogram


-- Remove duplicate colors
if DUPLIC == 1 then

  --messagebox("Removing Duplicates")

  palList = db.makePalList(256)
  palList = db.fixPalette(palList,0) -- no sort
  --d = palList.double_total
  --messagebox("Duplicates removed: "..d)
 
  -- Strip black from palette list
  if UNUSED == 1 and Black_in_image == false then
    palList = db.stripBlackFromPalList(palList)
  end

  for n = 1, 256, 1 do setcolor(n-1,0,0,0); end 

  -- Just set duplicates as black but keep order of palette
  if ARRANG == 0 then
    for u = 1, #palList, 1 do
       c = palList[u]
       i = c[4]
       org[i+1] = i -- quick way to remap without matchcolor
       setcolor(i,c[1],c[2],c[3])
    end
  end;

  if ARRANG == 1 then
    count = 0
    for u = 1, #palList, 1 do
       c = palList[u]
       i = c[4]
       org[i+1] = count -- quick way to remap without matchcolor
       setcolor(count,c[1],c[2],c[3])
       count = count + 1
    end
  end;

end; -- duplicate

-- Not need when removing unused cols without rearranging pal, but we'll keep it like this
if REMAP == 1 and (DUPLIC == 1 or (UNUSED == 1 and ARRANG == 1)) then 
 db.remap(org)
end


if DCLUST == 1 then

 statusmessage("DeCluster, initating..."); waitbreak(0)

 -- Codes: (To keep track of the 4 possible combinations)
 -- Image/Palette mode: H/h  (H = UNUSED) 
 -- Weights Yes/No:     W/w

if DCWT == 1 then -- W
 Hist = db.makeHistogram()
  if UNUSED == 0 then for n = 1, 256, 1 do Hist[n] = Hist[n] + 1; end; end -- hW: Pal+Weight (Odd thing), Can't have zeroes, histo is used as weights
  else 
   Hist = {}
   for n = 1, 256, 1 do Hist[n] = 1; end -- h Neutral histogram/weights, just coz DeCluster needs it
end

if UNUSED == 1 then -- H
  palList = db.makePalListFromHistogram(Hist)
   else
    palList = db.makePalList(256)  -- h
end


 -- Perceptual color weights: Dawn 3.0
 -- rw = 0.26
 -- gw = 0.55
 -- bw = 0.19

 statusmessage("DeCluster, processing..."); waitbreak(0)
 w, h = getpicturesize()
 pixels = w * h
 rw,gw,bw = db.getDefaultRGBweights()
 Org,CpalList = db.deCluster(palList, Hist, RADIUS, PROT, pixels, rw, gw, bw)

 for n = 1, 256, 1 do setcolor(n-1,0,0,0); end 


 for u = 1, #CpalList, 1 do
   c = CpalList[u]
   setcolor(u-1, c[1],c[2],c[3])
 end

 -- Let's remap with hybridmatch instead of reassigned clusters
 pal = db.makePalList(256)
 cols = {}
 for n = 0, 255, 1 do
  r,g,b = getbackupcolor(n)
  cols[n+1] = db.getBestPalMatchHYBRID({r,g,b},pal,briweight/100,true) 
 end
 


 --REMAPHYBRID = 1
 if REMAP == 1 then

   if REMAPHYBRID == 1 then
     -- Hybrid
     w, h = getpicturesize()
     for x = 0, w - 1, 1 do
      for y = 0, h - 1, 1 do
       putpicturepixel(x, y, cols[getbackuppixel(x,y) + 1]); -- backup isn't needed since no pixel has changed, but still...
      end
     end
   end

   if REMAPHYBRID == 0 then
    db.remap(Org) -- Use reassigned from clusters
   end

 end

end -- dclust

 
-- EpiCheck
-- We make the wild assumption that no duplicate colors were generated in the image

epi_palUniques = #db.fixPalette(db.makePalList(256),0)

hist = db.makeHistogram()
ulist = {}
for n = 1, 256, 1 do
    if hist[n] > 0 then
      r,g,b = getcolor(n-1)
      i = 1 + r * 65536 + g * 256 + b;
      if ulist[i] ~= nil then 
        epi_Duplic = epi_Duplic + 1; 
      end
      ulist[i] = i
      epi_Used = epi_Used + 1 
    end
end 


t = ""
t = t.."BEFORE:"
t = t.."\n\nImage colors: "..pre_Used.." ("..pre_Duplic.." duplicates)"
t = t.."\n\nUnique colors in palette: "..pre_palUniques

t = t.."\n\n\nAFTER:"
t = t.."\n\nColors in image: "..epi_Used.." (Reduced: "..(pre_Used-epi_Used)..")"
--t = t.."\n\nDuplicate colors removed: "..(pre_Duplic-epi_Duplic)
t = t.."\n\nUnique colors in palette: "..epi_palUniques
messagebox("Result:", t)

end; -- ok

