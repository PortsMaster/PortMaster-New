--SCENE: L-System - Hilbert Curve
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.96,
       cy = 0.96,

     iter = 7,

     size = 0.00725,

   square = 0,

     rota = 0,

      rgb = {255,128,128}, 
      rng = {-0.5,-0.5,-0.5}, 

   transp = 1.0,

     seed = 'A',

     rule = {
             {'Draw',  'F', 'F'},
             {'Left',  '-', '-',  90},
             {'Right', '+', '+',  90},
             {'Build', 'A', '-BF+AFA+FB-'},
             {'Build', 'B', '+AF-BFB-FA+'},
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

-- Hilbert
CX = 0.96
CY = 0.96
ITER = 7
SIZE = 0.00725
ROTA = 0
RGB  = {255,128,128} -- Color, -1 = Range 0->255, -2 = Range 255->0
RNG  = {0,0,0}
TRANSP = 1.0
SEED = 'A'
RULE = {
 {'Draw',  'F', 'F'},
 {'Left',  '-', '-',  90},
 {'Right', '+', '+',  90},
 {'Build', 'A', '-BF+AFA+FB-'},
 {'Build', 'B', '+AF-BFB-FA+'},
 {'Save',  '[', '[', },
 {'Load',  ']', ']', }
}


db.Lsys_Do(ITER,SEED,RULE,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 10, true) -- last is update speed and skip_flag (true = clean lines)
--]]


