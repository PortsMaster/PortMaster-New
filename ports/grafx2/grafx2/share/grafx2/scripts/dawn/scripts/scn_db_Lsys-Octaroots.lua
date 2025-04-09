--SCENE: L-System - OctaRoots (R.Fhager)
-- --> Best with square canvas! --<
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.2, 
       cy = 0.8,

     iter = 7,

     size = 0.02,

   square = 0, -- Square prop. are pref., but Octaroots are aligned to the right side of image, so it won't work properly

     rota = 0,

      rgb = {112,156,255}, -- {128,160,255}
      rng = {0.12,-0.04,0}, 

   transp = 0.25,

     seed = 'X',

     rule = {
             {'Draw',  'F', 'F-FX'},
             {'Left',  '-', '-',  45},
             {'Right', '+', '+',  45},
             {'Build', 'X', 'F[+X][-X]+FX',  0},
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 0,         -- (Yes, octaroots want knots.) Avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer",  -- "normal", "buffer" or "buffer_aa"

      gamma = 1.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)


--[[
dofile("../libs/dawnbringer_lib.lua")

-- Octaroots (by Richard Fhager)
CX = 0.2
CY = 0.8
ITER = 7
SIZE = 0.02
ROTA = 0
RGB  = {128,160,255}
RNG  = {0,0,0}
TRANSP = 0.25
SEED = 'X'
RULE = {
 {'Draw',  'F', 'F-FX',  0},
 {'Left',  '-', '-',   45},
 {'Right', '+', '+',   45},
 {'Build', 'X', 'F[+X][-X]+FX',  0},
 {'Save',  '[', '[',   0},
 {'Load',  ']', ']',   0}
}


DAT = db.Lsys_makeData(RULE)
SET = db.Lsys_makeSet(SEED,ITER,DAT)
xyr = db.Lsys_draw(SET,DAT,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP,50, false) -- no skipmode, we like the knotted lines here
--]]