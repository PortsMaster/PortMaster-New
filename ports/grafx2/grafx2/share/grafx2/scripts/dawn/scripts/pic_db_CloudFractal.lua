--PICTURE: Cloud Fractal V1.0
--Use with a 256 color gradient palette
--by Richard 'DawnBringer' Fhager

--dofile("../libs/dawnbringer_lib.lua")

 Max_Iter      = 9	      -- zero Iterations produces a 4 point plasma
 Min_Split     = 1            -- Don't split area if its smallest side isn't bigger than this, 1 works fine, use max 2 for with lines
 Offset        = 0.25;        -- offset randomization (0..0.99)
 Detail_Exp    = 2.0          -- nom = 2.0, Base for exponetial detail fade by iteration (higher = smoother)
 Var_Strength  = 192          -- 0..512 (lower = smoother)
 --Mode          = "lines" (Overlapping lines only, not available from this interface) 
 --Mode          = "rect"
 --Mode          = "linear"
 Mode          = "cosine"
 Line_Strength = 0
 Dither_Flag   = true

--
OK,MAXITER,OFFSET,AMP,SMOOTH,DETAIL,COSINE,LINEAR,RECT,LINESTR = inputbox("Cloud Fractal (256 col gradient)",
                        
  "Iterations: 0-14", Max_Iter,       0,14,0, 
  "Displacement Freq. %", Offset*100,       0,100,0, 
  "Amplitude: 0-512", Var_Strength,       0,512,0, 
  "Smoothness: 0-20", (Detail_Exp - 1)*10,       0,20,0, 
  "Detail Minimum: 1-16", Min_Split,       1,16,0, 
  "1. Cosine Interpolation",           1,  0,1,-1,
  "2. Linear Interpolation",           0,  0,1,-1,
  "3. Rectangles",                     0,  0,1,-1,  
  "Line Strength %",  Line_Strength *100,         0,100,0                                                              
  --"Set Screen to 800x600",      1,0,1,0
                                                                        
);
--


if OK then
 MODE = "cosine"
 if LINEAR == 1 then MODE = "linear"; end
 if RECT   == 1 then MODE = "rect"; end
 --db.drawFractalCloud(MAXITER, DETAIL, OFFSET/100, 1+SMOOTH/10, AMP, MODE, LINESTR/100, Dither_Flag)
 dofile("../pfunctions/pfunc_CloudFractal.lua")(MAXITER, DETAIL, OFFSET/100, 1+SMOOTH/10, AMP, MODE, LINESTR/100, Dither_Flag)
end

