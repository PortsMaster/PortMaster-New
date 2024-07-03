--PICTURE: Cloud Fractal Presets V1.1
--Use with a 256 color gradient palette
--by Richard 'DawnBringer' Fhager

--dofile("../libs/dawnbringer_lib.lua")

 Max_Iter      = 9	      -- Iterations, zero Iterations produces a 4 point plasma
 Min_Split     = 2            -- Don't split area if its smallest side isn't bigger than this, 1 works fine, use max 2 for with lines
 Offset        = 0.65;        -- Midpoint offset randomization (0..0.99)
 Detail_Exp    = 1.8          -- nom = 2.0, Base for exponetial detail fade by iteration (higher = smoother)
 Var_Strength  = 192          -- Variation, Midpoint color randomization: 0..512 (lower = smoother)
 --Mode          = "lines" (Overlapping lines only, not available from this interface) 
 --Mode          = "rect"
 --Mode          = "linear"
 Mode          = "cosine"
 Line_Strength = 0            -- Draw Lines: 0..1 (0 = off, 0.1 is good)
 Dither_Flag   = true         -- Treshold dithering

--db.drawFractalCloud
pfunc = dofile("../pfunctions/pfunc_CloudFractal.lua")

--
function setgrad()
 for c = 0, 255, 1 do
  setcolor(c,c,c,c) 
 end
 menu()
end
--

--
function menu()
selectbox("Cloud Fractal Presets",
    "[Set Gradient Pal >>]", setgrad,
    "Basic Cloud",                    function () pfunc(9,  1, 0.0,  2.0, 192, "cosine", 0,   Dither_Flag); end,
    "Rough Cloud",                    function () pfunc(10, 1, 0.25, 1.5, 208, "cosine", 0,   Dither_Flag); end,
    --"Soft Cloud",                     function () pfunc(12, 5, 0.15, 2.5, 224, "linear", 0,   Dither_Flag); end,
    "One Iteration Cosine",           function () pfunc(1,  1, 0.5,  1.0, 192, "cosine", 0,   Dither_Flag); end,
    "Canvas Cosine",                  function () pfunc(10, 1, 0.65, 1.8, 192, "cosine", 0,   Dither_Flag); end,
    "Soft Canvas",                    function () pfunc(10, 1, 0.5,  2.2,  64, "linear", 0,   Dither_Flag); end,
    "Canvas Rectangles",              function () pfunc(9,  1, 0.65, 1.8, 192, "rect",   0,   false); end, -- Dither has no effect on rect & lines
    "Rectangles + Lines",             function () pfunc(12, 2, 0.75, 1.6, 224, "rect",   0.1, false); end,
    "Lines Only",                     function () pfunc(11, 2, 0.85, 1.0,   0, "lines",  0.1, false); end
    --"Image Split",                    function () pfunc(5,  4, 0.0,  1.0,   0, "imgrec", 0.0, false); end
);
end
--

menu()