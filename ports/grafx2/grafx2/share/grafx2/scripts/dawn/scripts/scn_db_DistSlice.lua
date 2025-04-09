--SCENE: DistSlice Palette Redux V1.2
--Color reduction, somewhat similar to Median Cut
--by Richard Fhager

-- V1.2: GetRGBweights, Replaced Colormatching with custom Hybrid to assure only colors in the set are matched


dofile("../libs/dawnbringer_lib.lua")

pal = db.fixPalette(db.makePalList(256))

rw,gw,bw = db.getDefaultRGBweights()

OK,tcols,imgcols,quant,rw,gw,bw,BRIWEIGHT,PROXWEIGHT,bits = inputbox("DistSlice Redux (wip)",
                        
                           "COLORS (in new pal)",         #pal,  2,256,0,  
                           "Image-colors Only",           0,  0,1,0, 
                           "Histogram Power %",           0,  0,100,0, 
                           "  Red Weight: 0..1",         rw,  0.01,1.00,2, 
                           "Green Weight: 0..1",         gw,  0.01,1.00,2, 
                           " Blue Weight: 0..1",         bw,  0.01,1.00,2,
                                            
                           "BriDistance Weight %", 20,  0,100,0, 
                           "Prox-Hybrid Weight %", 70,  0,100,0,
                           "RGB BitDepth: 1-8",        8,  1,8,0                                                                       
);



if OK == true then

w,h = getpicturesize()

 remap = 1

 pal = db.fixPalette(db.makePalList(256))

 hist = {}
 for n = 1, 256, 1 do hist[n] = 1; end 

 if quant > 0 or imgcols == 1 then
   hist = db.makeHistogram()
 end

 quant_flag = false
 quantpow = quant / 100
 if quant > 0 then
  quant_flag = true
 end

if imgcols == 0 then
 --pal = db.fixPalette(db.makePalList(256))
 else
  pal = db.makePalListFromHistogram(hist) 
end

-- Add Histogram to pal
for n = 1, #pal, 1 do 
 pal[n][5] = hist[pal[n][4]+1] 
end

   
npal = db.distSlice(pal, tcols, true, quant_flag, {rw,gw,bw}, bits, quantpow, BRIWEIGHT/100, PROXWEIGHT/100) -- pal, cols qual, quant, weights, bits


for n=0, 255, 1 do setcolor(n,0,0,0); end

mpal = {}
for n=1, #npal, 1 do
 r = npal[n][1]
 g = npal[n][2]
 b = npal[n][3]
 setcolor(n-1,r,g,b) 
 mpal[n] = {r,g,b,n-1}
end



if remap == 1 then
 match = {}
 for n=0, 255, 1 do
  r,g,b = getbackupcolor(n)
  --match[n+1] = matchcolor2(r,g,b,0.25)
  --match[n+1] = matchcolor(r,g,b)
  match[n+1] = db.getBestPalMatchHYBRID({r,g,b},mpal,0.25,true)
 end

 for y=0, h-1, 1 do
  for x=0, w-1, 1 do
   putpicturepixel(x,y,match[getbackuppixel(x,y)+1])
  end
  updatescreen(); if (waitbreak(0)==1) then return; end
 end
end


end -- ok


