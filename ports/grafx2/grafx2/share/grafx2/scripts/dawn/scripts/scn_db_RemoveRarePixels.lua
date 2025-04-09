--SCENE: Reduce Rare/Redundant Image Colors
--(Very efficient redux algorithm)
--by Richard 'DawnBringer' Fhager

-- * This algorithm will remove colors in order of rarity & replacability
-- * It will only operate on image colors, unused colors in the palette are not processed
-- * The reassigning of colors usually have high quality, but sometimes a hybrid-colormatch can improve things further
-- * ColorMatch-mode may add palette-colors to the image that was previously unused

dofile("../libs/dawnbringer_lib.lua")

imgcols = #db.makePalListFromHistogram(db.makeHistogram())
maxremcol = math.floor(  imgcols * 0.75 )

OK,FORCE,MAX_COLORS,FUSE,COUNTROOT,proxhybrid,DUMMY,BRIMATCH,BRIWEIGHT,PROXWEIGHT = inputbox("Reduce Rare/Redundant Image Colors",
                    
                           "Removal TOLERANCE %", 50,  0,100,0, 
                           "Max Removed Cols ("..imgcols..")", maxremcol,  0,254,0, 
                           "FUSE Colors",          1,  0,1,0,
                           "Less Weight on PixelCount",    0,  0,1,0,
                           "Prox-Hybrid Distances*#", 0,  0,1,0, 
                           --"* BriWeight 0..1",    0.7,    0,1,2,
                           --"* PrimProx Weight 0..1",  0.6, 0,1,2,

                           "1. REMAP: ReAssigned Cols",    1,  0,1,-1,
                           "2. REMAP: HybridColMatch*",    0,  0,1,-1,
                           "*BriDistance Weight %", 25,  0,100,0, 
                           "#Prox-Hybrid Weight %", 95,  0,100,0  
 

                           --"Don't Square Errors",    0,  0,1,0
--                                                  
);


if OK == true then

w,h = getpicturesize()

rw,gw,bw = db.getDefaultRGBweights()

briweight  = BRIWEIGHT  / 100
proxweight = PROXWEIGHT / 100

if BRIMATCH == 1 then
 startpal = db.makePalList(256)
end

count_exp = 1
if COUNTROOT == 1 then count_exp = 0.5; end
max_point = (10000^0.02)^FORCE * count_exp^2 -- Attempt some compensation for root-counts (it will still remove more colors)


hist = db.makeHistogramIndexed() -- [count,color,r,g,b]

IMG_COLS_START = 0
for h = 1, 256, 1 do
 if hist[h][1] > 0 then IMG_COLS_START = IMG_COLS_START + 1; end
end



assign = {}
remap_count = 0
for rem = 1, MAX_COLORS, 1 do

gotone = false
-- For now we ignore unused colors
plow = {9e99, -1, -1, 0, 0} -- point, histindex, palcol, hcount, colcount
for h = 1, 256, 1 do

 h1 = hist[h]
 count = h1[1] 
 if count > 0 then
  rh,gh,bh = h1[3],h1[4],h1[5] -- [count,color,r,g,b]
  for c = 1, 256, 1 do
    h2 = hist[c]
    if h2[1] ~= -1 then -- Not disabled
    if (h ~= c and h2[1] > 0) then -- Not same col or unused cols
      if proxhybrid == 0 then
        dist = db.getColorDistance_weightNorm(rh,gh,bh,h2[3],h2[4],h2[5],rw,gw,bw)
      end
      if proxhybrid == 1 then -- Perceptual Primary Proximity / Brightness Hybrid Distances 
        dist = db.getColorDistanceProx(rh,gh,bh,h2[3],h2[4],h2[5],0.26,0.55,0.19,1.569, proxweight, briweight) -- pri/bri
      end
      point = count^count_exp * dist *dist
      if point < plow[1] then plow = {point,h-1,c-1,count,h2[1]}; end
      --gotone = true
    end
    end
  end -- c
 end -- if count>0

end -- h

if plow[1] < max_point then gotone = true; 
 else break
end

if gotone then
-- point, histindex, palcol, rem_count, rep_count
remove_col = plow[2] -- hist index - 1
replac_col = plow[3]
rem_count  = plow[4]
rep_count  = plow[5]


hist[replac_col + 1][1] = rep_count + rem_count
hist[remove_col + 1][1] = -1

if FUSE == 1 then -- Fuse
 ch = hist[remove_col+1] -- rgb stored in histogram
 cp = hist[replac_col+1]
 tot = rem_count + rep_count

  --r = (ch[3]*rem_count + cp[3]*rep_count) / tot
  --g = (ch[4]*rem_count + cp[4]*rep_count) / tot
  --b = (ch[5]*rem_count + cp[5]*rep_count) / tot

  -- Gamma correct / Colorfulness (1 = Normal mix)
  -- It's doubtful if the concept of Gammacorrection applies in any way to palette reduction...
  -- However it can be used as a tweaking tool to increase saturation of the selection.
  -- Still, the drastic changes to an image from palette reduction overshadows any
  -- color-fusing issues by several orders of magnitude. 
  -- Subjective and aestethical factors are of way greater importance.
  e = 2.0
  r = ((ch[3]^e*rem_count + cp[3]^e*rep_count) / tot)^(1/e)
  g = ((ch[4]^e*rem_count + cp[4]^e*rep_count) / tot)^(1/e)
  b = ((ch[5]^e*rem_count + cp[5]^e*rep_count) / tot)^(1/e)


 hist[replac_col+1] = {tot,replac_col,r,g,b}
 -- must update hist too
 setcolor(replac_col,r,g,b); 
end


hist[remove_col+1] = {-1,-1,-1,-1} -- disable pal color


-- Must update remap list in case of re-assigns
for n = 1, #assign, 1 do
 if assign[n][2] == remove_col then assign[n][2] = replac_col; end
end

remap_count = remap_count + 1
assign[remap_count] = {remove_col, replac_col}

setcolor(remove_col,255,0,255)
updatescreen()

statusmessage("Color: "..rem.."              "); waitbreak(0)


end -- gotone

end; -- rem



-- *** REMAP ***

-- Data
histcount_after = 0
for c = 1, 256, 1 do
 if hist[c][1] > 0 then histcount_after = histcount_after + 1; end
end

remap = {}
for c = 0, 255, 1 do remap[c+1] = c; end

if BRIMATCH == 0 then
 for n = 1, #assign, 1 do
  remap[assign[n][1]+1] = assign[n][2]
 end
end

if BRIMATCH == 1 then
 afterpal = {}
 count = 0
 --[count,color,r,g,b]
 --afterpal = db.fixPalette(db.makePalList(256),0)
 for n = 1, 256, 1 do -- Let's make a custom pal-list with only image/hist colors
  if hist[n][1] > 0 then
   hc = hist[n]; count = count + 1
   afterpal[count] = {hc[3],hc[4],hc[5],hc[2]} -- r,g,b,n
  end
 end
 for n = 1, 256, 1 do
  c = startpal[n]
  remap[n] = db.getBestPalMatchHYBRID({c[1],c[2],c[3]},afterpal,briweight,true) 
 end
end

w,h = getpicturesize()
for y = 0, h - 1, 1 do 
 for x = 0, w - 1, 1 do 
  putpicturepixel(x,y,remap[getpicturepixel(x,y)+1])
 end
end



updatescreen()

-- Make a new histogram to see what actually happened
hist = db.makeHistogramIndexed() -- [count,color,r,g,b]
IMG_COLS_AFTER = 0
for h = 1, 256, 1 do
 if hist[h][1] > 0 then IMG_COLS_AFTER = IMG_COLS_AFTER + 1; end
end

DUPREM = histcount_after - IMG_COLS_AFTER 


t = "Colors, inital: "..IMG_COLS_START
t = t.."\n"
t = t.."Colors, after: "..IMG_COLS_AFTER
t = t.."\nREMOVED: "..(IMG_COLS_START-histcount_after)
if BRIMATCH == 1 then
 if DUPREM > 0 then
  --t = t.."\nColormatching removed "..DUPREM.." duplicate colors" -- This can be confused with not using some available colors
 end
 if DUPREM < 0 then
  t = t.."\nColormatching added "..(-DUPREM).." colors (found use for some palette-colors)"
 end
end
messagebox("RESULT",t)


end;
-- ok

