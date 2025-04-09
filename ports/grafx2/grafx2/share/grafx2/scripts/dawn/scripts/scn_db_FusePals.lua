--SCENE: Fuse Main & Spare Palettes
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

 local pall_curr, pal_spar, pal, npal
 local f

--
function main()

--pal = db.fixPalette(db.makePalList(256))

pal_curr = db.makePalList(256)
pal_spar = db.makeSparePalList(256)
pal = db.fixPalette(db.newArrayMerge(pal_curr,pal_spar),0)
num = math.min(#pal,256)

rw,gw,bw = 0.26,0.55,0.19

OK,tcols,imgcols,bits,noremap,remap,dith,briweight = inputbox("Fuse Main & Spare Pals",
                        
                           "COLORS (in new pal)",         num,  2,256,0,  
                           "Image colors only",            0,  0,1,0, 
                           "RGB-BitDepth: 1-8",            8,  1,8,0,  
                           "1. No Remapping",                 0,  0,1,-1, 
                           "2. Remap Image*",                 1,  0,1,-1, 
                           "3. DitherRemap Image*",           0,  0,1,-1, 
                           "*ColMatch Bri-Weight %",      25,  0,100,0 
                                                                       
);



if OK == true then

w,h = getpicturesize()

if imgcols == 0 then
 --pal = db.fixPalette(db.makePalList(256))
 else
  pal_curr = db.makePalListFromHistogram(db.makeHistogram())
  pal_spar = db.makePalListFromSpareHistogram(db.makeSpareHistogram())
  pal = db.fixPalette(db.newArrayMerge(pal_curr,pal_spar),0)
end

quant_flag = false   
npal = db.medianCut(pal, tcols, true, quant_flag, {rw,gw,bw}, bits, quantpow) -- pal, cols qual, quant, weights, bits


for n=0, 255, 1 do setcolor(n,0,0,0); end

for n=1, #npal, 1 do
 r = npal[n][1]
 g = npal[n][2]
 b = npal[n][3]
 setcolor(n-1,r,g,b) 
end

if dith == 1 then
 function f(x,y,w,h)
  return getbackupcolor(getbackuppixel(x,y))
 end

  -- NOTE: Percep is always active in fsrender when Pal provided, so db.getBestPalMatch_Hybrid is used
  --db.fsrender(f,npal,ditherprc,xdith,ydith,percep,-1,ord_bri,ord_hue,bri_change,hue_change,briweight)
  --db.fsrender(f,npal,90,           2,    4,    -1,-1,      0,      0,         0,         0,       briweight)
    -- Here matchcolor2 is used instead
    db.fsrender(f,{},90,           2,    4,    null,null,  null,   null,      null,      null,    briweight)

end


if remap == 1 then
 match = {}
 for n=0, 255, 1 do
  r,g,b = getbackupcolor(n)
  --match[n+1] = matchcolor2(r,g,b,briweight/100)
  match[n+1] = matchcolor(r,g,b)
 end

 for y=0, h-1, 1 do
  for x=0, w-1, 1 do
   putpicturepixel(x,y,match[getbackuppixel(x,y)+1])
  end
  updatescreen(); if (waitbreak(0)==1) then return; end
 end
end


end -- ok

end
-- main


main()


