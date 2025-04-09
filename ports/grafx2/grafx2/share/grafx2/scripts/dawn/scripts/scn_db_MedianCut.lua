--SCENE: Median Cut Palette Redux V1.11
--by Richard 'DawnBringer' Fhager


--(V1.11 Replaced Colormatching with custom Hybrid to assure only colors in the set are matched)


dofile("../libs/dawnbringer_lib.lua")

pal = db.fixPalette(db.makePalList(256))

rw,gw,bw = db.getDefaultRGBweights()

OK,tcols,imgcols,quant,rw,gw,bw,bits,remap,briweight = inputbox("Palette - MedianCut Redux",
                        
                           "COLORS (in new pal)",         #pal,  2,256,0,  
                           "Image-colors Only",           0,  0,1,0, 
                           "Histogram Power %",           1,  0,100,0, 
                           "  Red Weight: 0..1",           rw,  0.01,1.00,2, 
                           "Green Weight: 0..1",           gw,  0.01,1.00,2, 
                           " Blue Weight: 0..1",           bw,  0.01,1.00,2,
                           "RGB BitDepth: 1-8",             8,  1,8,0,  
                           "Remap Image*",                 1,  0,1,0, 
                           "*ColMatch Bri-Weight %",      25,  0,100,0 
                                                                       
);



if OK == true then

w,h = getpicturesize()

if imgcols == 0 then
 --pal = db.fixPalette(db.makePalList(256))
 else
  pal = db.makePalListFromHistogram(db.makeHistogram()) 
end

quant_flag = false
quantpow = quant / 100

if quant > 0 then
 quant_flag = true
 SAMPLES = w*h / 10 * math.sqrt(25)
 samples = math.min(SAMPLES,w*h)

 xstep = math.min(w / samples^0.5)
 ystep = math.min(h / samples^0.5)
 v = #pal
 for y=0, h-1, ystep do
  for x=0, w-1, xstep do
   v = v+1
   c = getpicturepixel(x,y)
   r,g,b = getcolor(c)
   pal[v] = {r,g,b,c}
  end
 end
end

statusmessage("Median Cut...");waitbreak(0)
   
npal = db.medianCut(pal, tcols, true, quant_flag, {rw,gw,bw}, bits, quantpow) -- pal, cols qual, quant, weights, bits


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
  --match[n+1] = matchcolor2(r,g,b,briweight/100)
  --match[n+1] = matchcolor(r,g,b)
  match[n+1] = db.getBestPalMatchHYBRID({r,g,b},mpal,briweight/100,true)
 end

 for y=0, h-1, 1 do
  for x=0, w-1, 1 do
   putpicturepixel(x,y,match[getbackuppixel(x,y)+1])
  end
  updatescreen(); if (waitbreak(0)==1) then return; end
 end
end


end -- ok


