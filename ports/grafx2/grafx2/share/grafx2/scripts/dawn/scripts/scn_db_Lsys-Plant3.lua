--SCENE: L-System - Plant 3 (Bushy/Algae) 
--(CodeTrain example etc.)
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.4,
       cy = 0.98,

     iter = 5,

     size = 0.0085,

     rota = 0,

      rgb = {48,96,112}, 
      rng = {0.8,0.45,0.1}, 

   transp = 0.4,

     seed = 'F',

     rule = {
             {'Draw',  'F', 'FF+[+F-F-F]-[-F+F+F]',  0},
             {'Left',  '-', '-',  25},
             {'Right', '+', '+',  25},
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer",  -- "normal", "buffer" or "buffer_aa"

      gamma = 1.8,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)


--[[
dofile("../libs/dawnbringer_lib.lua")

-- Plant 3, Bushy/Algae (CodeTrain example etc.)
-- Designed for black background
CX = 0.35
CY = 0.98
ITER = 5
SIZE = 0.0085
ROTA = 0
RGB  = {96,80,255}
RNG  = {1.0,0.6,-0.6}
TRANSP = 0.5
SEED = 'F'
RULE = {
 {'Draw',  'F', 'FF+[+F-F-F]-[-F+F+F]',  0},
 {'Left',  '-', '-',   25},
 {'Right', '+', '+',   25},
 --{'Build', '', '',  0},
 {'Save',  '[', '[',   0},
 {'Load',  ']', ']',   0}
}


SKIPMODE = true -- clean lines, no double plotted joints
SPEED = 500


statusmessage("Building Fractal..."); waitbreak(0)
DAT = db.Lsys_makeData(RULE)
SET = db.Lsys_makeSet(SEED,ITER,DAT)
statusmessage("Drawing...        "); waitbreak(0)
xyr = db.Lsys_draw(SET,DAT,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, SPEED, SKIPMODE) -- skipmode on (clean lines)
--]]