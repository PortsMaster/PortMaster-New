--SCENE: L-System - Plant 2
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.5,
       cy = 0.99,

     iter = 7,

     size = 0.0028,

     rota = -10,

      rgb = {144,128,96}, 
      rng = {0,0.2,0}, 

   transp = 0.45,

     seed = 'X',

     rule = {
             {'Draw',  'F', 'FF'},
             {'Left',  '-', '-',  20},
             {'Right', '+', '+',  20},
             {'Build', 'X', 'F-[[X]+X]+F[+FX]-X',  0},  
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)


--[[

dofile("../libs/dawnbringer_lib.lua")

-- Plant 2
CX = 0.5
CY = 0.99
ITER = 7
SIZE = 0.0028
ROTA = -10
RGB  = {144,128,96}
RNG  = {0,0.2,0}
TRANSP = 0.45
SEED = 'X'
RULE = {
 {'Draw',  'F', 'FF',  0},
 {'Left',  '-', '-',   20},
 {'Right', '+', '+',   20},
 {'Build', 'X', 'F-[[X]+X]+F[+FX]-X',  0},
 {'Save',  '[', '[',   0},
 {'Load',  ']', ']',   0}
}

statusmessage("Building Fractal..."); waitbreak(0)
DAT = db.Lsys_makeData(RULE)
SET = db.Lsys_makeSet(SEED,ITER,DAT)
statusmessage("Drawing...        "); waitbreak(0)
xyr = db.Lsys_draw(SET,DAT,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 80, true) -- skipmode on (clean lines)

--]]


