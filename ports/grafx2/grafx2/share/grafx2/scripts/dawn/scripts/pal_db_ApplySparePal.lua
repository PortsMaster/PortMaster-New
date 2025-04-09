--PALETTE: Apply Spare Palette
--(Tint & Colorize etc)
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

function cap(v) return math.min(255,math.max(v,0)); end


-- Grayscales will not have an affect when colorizing
-- Add/Colorbalance may also seem similar to Colorize (usually a bit softer though) but uses channel-scaling 
-- for errorcorrection  (rather than a add/subtract level adjustment) that handles 0/255 boundary overflows. 
-- Apply orange to a grayscale to see how it preserves the orange rather than having green drop below 0 and leave a red ramp.
-- However, without brightness-preservation the three are vastly different operators.
--
-- For good results it helps greatly if the image/palette to processed is sorted in hue or brightness (if the application palette is a ramp)
--
-- NOTE: Replace/Mix with Brightness preservation is identical(?) to TINT...
-- so for clarity & simplicity, we'll remove briprev from replace and add a dedicated tint.
--
-- Note: Gamma may have an extra effect on Replace/Mix, "Amount" won't work as linear fade.
--
-- Falloff on tint and colorize is cosine.

OK,tin,clz,add,mix,bfuse,difr,brikeep,gamma,amt= inputbox("Apply Spare Palette",
                                              
                          
                           "1. Tint (falloff) *",                   1,  0,1,-1,
                           "2. Colorize (falloff) *",               0,  0,1,-1,
                           "3. ColorBalance/Add *",       0,  0,1,-1,
                           "4. Replace/Mix #",              0,  0,1,-1,                
                           "5. Baseline fusion",          0,  0,1,-1,
                           "6. Difference",               0,  0,1,-1,

                           "* Preserve Brightness",       1,  0,1,0,
                           "# Gamma: 0.1-5.0", 1.0, 0.1,5,2,
                           "AMOUNT %: 1-100", 50, 1,100,0
                     
                                                
);


if OK == true then


  for c = 0, 255, 1 do
 
     rs,gs,bs = getsparecolor(c)
     rc,gc,bc = getcolor(c)
     cbri = db.getBrightness(rc,gc,bc)

     --if cbri >= 254 then messagebox(" "..cbri); end

     ams = amt / 100
     amc = 1 - ams

     if mix == 1 then
      gm = gamma
      r = (rs^gm * ams + rc^gm * amc)^(1/gm)
      g = (gs^gm * ams + gc^gm * amc)^(1/gm)
      b = (bs^gm * ams + bc^gm * amc)^(1/gm)
     --[[
      if brikeep == 1 then  -- Strong Brightness preservation
        for n = 0, 19, 1 do
         rbri = db.getBrightness(cap(r),cap(g),cap(b))
         diff = rbri - cbri
         r = r - diff
         g = g - diff
         b = b - diff 
        end
      end
     --]]
     end

     if add == 1 then
      if brikeep == 1 then -- Add is same as colorbalance
       r,g,b = db.ColorBalance(rc,gc,bc,rs,gs,bs,true,false) -- r,g,b,rd,gd,bd,bri_flag,loose_flag
       r = r * ams + rc * amc
       g = g * ams + gc * amc
       b = b * ams + bc * amc
        else -- Normal add 
           r = rs * ams + rc 
           g = gs * ams + gc 
           b = bs * ams + bc 
      end
     end

     if clz == 1 or tin == 1 then
      -- Normalize SpareColor
      lev = (rs+gs+bs)/3
      --lev = (math.max(rs,gs,bs) + math.min(rs,gs,bs)) / 2
      rs = rs - lev
      gs = gs - lev
      bs = bs - lev
     

      falloff = 1
        -- Falloff (Effect weakens at dark and bright colors)
      if falloff == 1 then
       narrow = 1 -- higher exp = narrower peak (of effect) around medium brightness
       --fo = 1 - math.abs((cbri - 127.5)/127.5)^1 -- smaller exp = more falloff, 1 is good (linear), 0.5 is very noticable. 2 is used in other places
       fo = (1 - (0.5 - math.cos(math.abs((cbri - 127.5)/127.5) * math.pi) * 0.5))^narrow -- wolfram: 0.5 - cos(abs((x- 127.5)/127.5) * pi) * 0.5, x=0to255 
       rs = rs * fo
       gs = gs * fo
       bs = bs * fo
      end   

       if clz == 1 then
        r = (rc + rs) * ams + rc * amc
        g = (gc + gs) * ams + gc * amc
        b = (bc + bs) * ams + bc * amc  
       end

       if tin == 1 then
        r = (cbri + rs) * ams + rc * amc
        g = (cbri + gs) * ams + gc * amc
        b = (cbri + bs) * ams + bc * amc  
       end
 

      if brikeep == 1 then  -- Fairly Strong Brightness preservation
       for n = 0, 6, 1 do -- Bri adjust the final result
        rbri = db.getBrightness(cap(r),cap(g),cap(b))
        diff = rbri - cbri
        r = r - diff
        g = g - diff
        b = b - diff
       end
      end

     end -- clz


     if bfuse == 1 then
      r = (rs + rc - 127) * ams + rc * amc
      g = (gs + gc - 127) * ams + gc * amc
      b = (bs + bc - 127) * ams + bc * amc
     end

     if difr == 1 then
      r = (math.abs(rs - rc)) * ams + rc * amc
      g = (math.abs(gs - gc)) * ams + gc * amc 
      b = (math.abs(bs - bc)) * ams + bc * amc
     end


     setcolor(c,r,g,b)


  end -- c

end -- ok
