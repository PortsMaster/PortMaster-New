--PALETTE: Apply (Pen)Color V1.0
--by Richard Fhager 
--BriSort pal b4 applying gradient


dofile("../libs/dawnbringer_lib.lua")

 fg = getforecolor()
 bg = getbackcolor()
 fR,fG,fB = getcolor(fg)
 bR,bG,bB = getcolor(bg)

OK,fR,fG,fB,tin,clz,fade,amt,falloff = inputbox("Palette Apply Color (Pen=Preset)",
                        
       "  Red: 0-255", fR,  0,255,0, 
       "Green: 0-255", fG,  0,255,0, 
       " Blue: 0-255", fB,  0,255,0, 
                           "1. TINT",               1,  0,1,-1,
                           "2. COLORIZE",           0,  0,1,-1,
                           "BG->RGB Fade over Bri", 0,  0,1,0, 
                           "AMOUNT %", 100,  0,100,0,  
                           "Bri/Dark FallOff: 0..9", 1.5,  0,9,2                                                 
);


if OK == true then

 function cap(v) return math.min(255,math.max(v,0)); end

 brikeep = 1

 amtA = amt / 100
 amtR = 1 - amtA

  -- Normalize Pen Color
  lev = (fR+fG+fB)/3
  fR = fR - lev
  fG = fG - lev
  fB = fB - lev

 ---------------------------------------------------
 -- Colorize (Colourant) (just apply colorbalance)
 -- Tint (make grayscale and apply colorbalance)
 --
 -- I think it should be the other way around since colorize is the process of adding color to B&W film...
 -- But this is the what Brilliance and others call it 
 --
 if clz == 1 or tin == 1 then
  cols = {}
  for n = 0, 255, 1 do

  r,g,b = getcolor(n); a = db.getBrightness(r,g,b)
    
  mR,mG,mB = fR,fG,fB

  -- Fade between bg & RGB(fg by default) pencolor across dark-bright
  if fade == 1 then
    lf = a / 255
    lr = 1 - lf
    mR = bR*lr + fR*lf
    mG = bG*lr + fG*lf
    mB = bB*lr + fB*lf
    lev = (mR+mG+mB)/3
    mR = mR - lev
    mG = mG - lev
    mB = mB - lev
  end   

  fr,fg,fb = mR,mG,mB
  
        -- Falloff (Effect weakens at dark and bright colors)
      if falloff > 0 then
       narrow = falloff -- higher exp = narrower peak (of effect) around medium brightness
       fo = (1 - (0.5 - math.cos(math.abs((a - 127.5)/127.5) * math.pi) * 0.5))^narrow
       fr = fr * fo
       fg = fg * fo
       fb = fb * fo
      end   

      if clz == 1 then
        r = (r + fr) * amtA + r * amtR
        g = (g + fg) * amtA + g * amtR
        b = (b + fb) * amtA + b * amtR 
       end

       if tin == 1 then
        r = (a + fr) * amtA + r * amtR
        g = (a + fg) * amtA + g * amtR
        b = (a + fb) * amtA + b * amtR 
       end

      if brikeep == 1 then  -- Strong Brightness preservation
       for n = 0, 19, 1 do -- Bri adjust the final result
        rbri = db.getBrightness(cap(r),cap(g),cap(b))
        diff = rbri - a
        r = r - diff
        g = g - diff
        b = b - diff
       end
      end

      setcolor(n,r,g,b)  

  end

  
end; 
-- eof Colorize & Tint
--------------------------------------------------------

end -- OK

