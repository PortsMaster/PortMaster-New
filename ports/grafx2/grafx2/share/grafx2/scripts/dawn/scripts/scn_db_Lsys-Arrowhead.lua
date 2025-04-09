--SCENE: L-System - Sierpinsky Arrowhead
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.024,
       cy = 0.9,

     iter = 7,

     size = 0.0075,

     rota = 90,

      rgb = {0,128,255}, 
      rng = {1,-0.25,-0.25}, 

   transp = 1.0,

     seed = 'YF',

     rule = {
             {'Draw',  'F', 'F'},
             {'Left',  '-', '-',  60},
             {'Right', '+', '+',  60},
             {'Build', 'X', 'YF+XF+Y'},
             {'Build', 'Y', 'XF-YF-X'},
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "normal",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 0,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)

--[[

dofile("../libs/dawnbringer_lib.lua")

-- Sierpinsky Arrowhead
CX = 0.024
CY = 0.9
ITER = 7
SIZE = 0.0075
ROTA = 90
RGB  = {0,128,255} 
RNG  = {1,-0.25,-0.25}
TRANSP = 1.0
SEED = 'YF'
RULE = {
 {'Draw',  'F', 'F'},
 {'Left',  '-', '-',  60},
 {'Right', '+', '+',  60},
 {'Build', 'X', 'YF+XF+Y'},
 {'Build', 'Y', 'XF-YF-X'},
 {'Save',  '[', '[', },
 {'Load',  ']', ']', }
}



db.Lsys_Do(ITER,SEED,RULE,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 5, true) -- last is update speed and skip_flag (true = clean lines)

--]]