--SCENE: L-System - Big Whisper 2
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.54,
       cy = 0.05,

     iter = 5, -- Don't try more than 5 interations on this one! (Gfx grow x10 and data x23 every iteration)

     size = 0.0062,

     rota = 180,

      -- Blue-grey-yellow
      --rgb = {80,128,240}, 
      --rng = {1.4,0.5,-0.5}, -- Overkilling the red

      rgb = {-112,144,240}, 
      rng = {2.6,0.45,-0.5}, -- Fast incline Red

   transp = 0.25,

     seed = "F",
     rule =  {
              {'Draw',  'F', 'Fr[+F-F+F+F]lF[-F+F-F-F]',  0},
              {'Left',  '-', '-',   20},
              {'Right', '+', '+',   20},
   {'Left',  'l', 'l',   15}, -- Rotates the right side up a bit
   {'Right', 'r', 'r',   15},
              {'Move',  'M', 'M',   0},
              {'Save',  '[', '[',   0},
              {'Load',  ']', ']',   0}
             },

      speed = 1000,      -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)


