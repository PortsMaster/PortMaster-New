--BRUSH: 4-Dither System 
--Make Dither *Selection* Best Matching RGB-Value
--by Richard 'DawnBringer' Fhager

-- Create a brush with the best 4-dither patterns possible for a given RGB-value
-- The best colormatch, disregarding dither courseness is marked (if one of the best dithers displayed)
-- Finding the top dithers (rather than just the one best) requires sorting of the scores...
-- ..this can get very slow with +16 dithers (sorting 32 colors is 177(!) times slower than 16 colors...f.ex 2s vs 5m55s)
-- .. but luckily we have an optimization in place...so 32 colors will work fine.

-- Note: Currently there's no option to exclude the current pen-color from the dithers

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

 FC = getforecolor()
 BC = getbackcolor()

 gam = 1.3 
 rgm = 1 / gam
 r1,g1,b1 = getcolor(FC)
 r2,g2,b2 = getcolor(BC)

 -- Slightly Gamma-corrected average of the Pen-colors as inital RGB-selection
 r = (0.5*r1^gam + 0.5*r2^gam)^rgm
 g = (0.5*g1^gam + 0.5*g2^gam)^rgm
 b = (0.5*b1^gam + 0.5*b2^gam)^rgm


LIMIT         = 32 -- Max # of colors in palette
Samples       = 10
Size          = 32
Gamma         = -2.2 -- MixColor composition, Negative values enables Dynamic Gamma
Briweight     = 0.25 
Dither_Factor = 0.025 -- 0 = Best Colormatch only, any Dither goes. 
Two_Flag      = false -- Only 2-dithers

roughness = (1-Dither_Factor) * 100

bw = Briweight*100

OK,r,g,b,Samples,Size,roughness,bw,Gamma,two_only = inputbox("4-Dither Brush Selection",
                                         
          "  Red: 0-255",    r,  0,255,0,
          "Green: 0-255",    g,  0,255,0,
          " Blue: 0-255",    b,  0,255,0,
          "Samples: 1-32", Samples, 1,32,0,
          "   Size: 2-128",    Size,  2,128,0,
          "Roughness Tolerance %",  roughness,  0,100,2,
          "ColMatch Bri-Weight %",    bw,  0,100,0,
          "Gamma (MixColors)",  Gamma,  -5.0,5.0,2,
          "2 Col Dithers Only",  0,0,1,0
);


--
if OK then

--
--
--   num: Number of dithers, starting with the best
-- xs,ys: Size of each dither
--
function make4DitherBrush_multi(num,xs,ys,r,g,b,pal,gamma,dither_factor,briweight,two_flag)
 local n,match,scores,mixpal,n,i,c,s,x,y,w,h,v,cols,dith,best,combo,spacing
 
 spacing = 1

 mixpal = d4_.makeRatedMixpal(pal,gamma,two_flag,true) --  {r,g,b, v1,v2,v3,v4, rating}

 -- We could strip rough dithers here (reduce mixpal size), but since only one color is matched it doesn't steal too much time.
 -- The much bigger problem is sorting; but that's handled by score stripping.

 -- match[1] is best dither in mixpal
 match,scores = d4_.scoreMatchDithers(mixpal, {{r,g,b,-1}}, dither_factor, briweight) -- scores = {mixpal index,score}
 -- To extract the best color matching dither, regardless of courseness/score..make another call with dither_factor = 0
 best = d4_.scoreMatchDithers(mixpal, {{r,g,b,-1}}, 0, briweight)[1][1] -- best mixpal dither colormatch

 --messagebox(" "..best)
 --
 -- reduce scorelist (dither matches) to the best 5% to improve speed of sorting (we only need the best)
 -- A 32 color palette will be sorted over 200 times faster with this in place, yes 1-2s instead of 5m55s.
 if #mixpal >= 1001 then -- 1001 = 11 colors, 715 = 10 colors (will sort quickly)
  scores = d4_.stripScores(scores)
  --messagebox(#scores)
 end
 --
 statusmessage("Sorting ("..#scores..")...");waitbreak(0) 
 db.sorti(scores,2) -- Insertion sort
 
 --num,xs,ys = 12,32,32
 
 num = math.min(num, #scores) -- just in case scores was stripped to hard
 w,h = (xs+spacing)*num,ys
 setbrushsize(w,h+2)

for s = 0, num-1, 1 do 

 combo = scores[1+s][1]
 d4_.put4Dither(xs,ys,s*(xs+spacing),0,mixpal,combo,putbrushpixel) -- draw the dither

  if combo == best then
    c = matchcolor(255,255,255)
    for n = 0, xs-1, 1 do
     putbrushpixel((xs+spacing)*s+n,ys,c)
     putbrushpixel((xs+spacing)*s+n,ys+1,matchcolor(0,0,0))
    end 
  end
 end

end
--

 if two_only == 1 then Two_Flag = true; end
 Dither_Factor = 1-(roughness * 0.01)
 Briweight = bw / 100
 Pal = db.fixPalette(db.makePalList(256),1) -- Sorted Bright to Dark

 if #Pal <= LIMIT then
  make4DitherBrush_multi(Samples,Size,Size,r,g,b,Pal,Gamma,Dither_Factor,Briweight,Two_Flag)
   else messagebox("Too Many Colors in Palette!","Max number of Colors: "..LIMIT)
 end

 

end -- ok

