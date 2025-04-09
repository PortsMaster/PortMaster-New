--SCENE: L-System - Levy C-curve
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.62,
       cy = 0.28,

     iter = 14,

     size = 0.0034,

     rota = 180,

      rgb = {64,320,255}, 
      rng = {1,-1,-1}, 

   transp = 0.65,

     seed = 'F',

     rule = {
             {'Draw',  'F', '+F--F+', 0},
             {'Left',  '-', '-',   45},
             {'Right', '+', '+',   45},
             --{'Build', 'X', '', 0},
             {'Save',  '[', '[',   0},
             {'Load',  ']', ']',   0}
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

-- Levy C-curve
CX = 0.62
CY = 0.28
ITER = 14
SIZE = 0.0034
ROTA = 180
RGB  = {64,320,255}
RNG  = {1,-1,-1}
TRANSP = 0.65
SEED = 'F'
RULE = {
 {'Draw',  'F', '+F--F+',  0},
 {'Left',  '-', '-',   45},
 {'Right', '+', '+',   45},
 --{'Build', 'X', '', 0},
 {'Save',  '[', '[',   0},
 {'Load',  ']', ']',   0}
}


statusmessage("Building Fractal..."); waitbreak(0)
DAT = db.Lsys_makeData(RULE)
SET = db.Lsys_makeSet(SEED,ITER,DAT)
statusmessage("Drawing...        "); waitbreak(0)
xyr = db.Lsys_draw(SET,DAT,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 60, true) -- Skipmode on, but the knottier lines look good too...
--]]