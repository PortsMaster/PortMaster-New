--SCENE: L-System - Big Whisper
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.44,
       cy = 0.95,

     iter = 5,

     size = 0.00575,

     rota = 0,

      rgb = {128,108,255}, 
      rng = {1.1,0.45,-0.55}, -- Overkilling the red

   transp = 0.25,

     seed = "F",
     rule =  {
              {'Draw',  'F', 'FF+[+F-F+F+F]-[-F+F-F-F]',  0},
              {'Left',  '-', '-',   20},
              {'Right', '+', '+',   20},
              {'Move',  'M', 'M',   0},
              {'Save',  '[', '[',   0},
              {'Load',  ']', ']',   0}
             },

   speed = 1000,         -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

    skipmode = 1,        -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer",  -- "normal" or "buffer"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)