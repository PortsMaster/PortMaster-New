--SCENE: L-System - Test File

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.5,
       cy = 0.99,

     iter = 7, -- Don't try more than 5 interations on this one! (Gfx grow x10 and data x23 every iteration)

     size = 0.003,

     rota = 0,

      -- Blue-grey-yellow
      --rgb = {80,128,240}, 
      --rng = {1.4,0.5,-0.5}, -- Overkilling the red

      rgb = {-112,144,240}, 
      rng = {2.6,0.45,-0.5}, -- Fast incline Red

   transp = 0.25,

     seed = "X",
     rule =  {
              {'Draw',  'F', 'FF',  0},
              {'Left',  '-', '-',   25},
              {'Right', '+', '+',   25},
 
              {'Build', 'X', 'F-[[X]+X]+F[+FX]-X',   0},
              {'Save',  '[', '[',   0},
              {'Load',  ']', ']',   0}
             },

      speed = 1000,      -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer",  -- "normal" or "buffer"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)