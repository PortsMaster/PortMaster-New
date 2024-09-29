--SCENE: L-System - Peano-Gosper Curve
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.1,
       cy = 0.38,

     iter = 4, 

     size = 0.015,

     rota = 0,

      rgb = {272,80,112}, 
      rng = {-0.1,0.6,-0.3}, 

   transp = 1.0,

     seed = 'FX',

     rule = {
             {'Draw',  'F', 'F'},
             {'Left',  '-', '-',  60},
             {'Right', '+', '+',  60},
             {'Build', 'X', 'X+YF++YF-FX--FXFX-YF+'},
             {'Build', 'Y', '-FX+YFYF++YF+FX--FX-Y'},
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 10, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)


--[[
dofile("../libs/dawnbringer_lib.lua")

-- Peano-Gosper
CX = 0.1
CY = 0.38
ITER = 4
SIZE = 0.015
ROTA = 0
RGB  = {255,32,64} -- Color, -1 = Range 0->255, -2 = Range 255->0
RNG  = {-0.7,0.8,0.6}
TRANSP = 1.0
SEED = 'FX'
RULE = {
 {'Draw',  'F', 'F'},
 {'Left',  '-', '-',  60},
 {'Right', '+', '+',  60},
 {'Build', 'X', 'X+YF++YF-FX--FXFX-YF+'},
 {'Build', 'Y', '-FX+YFYF++YF+FX--FX-Y'},
 {'Save',  '[', '[', },
 {'Load',  ']', ']', }
}


db.Lsys_Do(ITER,SEED,RULE,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 2, true) -- last is update speed and skip_flag (true = clean lines)

--]]

