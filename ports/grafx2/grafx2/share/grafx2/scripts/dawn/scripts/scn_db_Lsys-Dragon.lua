--SCENE: L-System - Dragon Curve
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.758,
       cy = 0.5,

     iter = 14, 

     size = 0.0052,

     rota = 20,

      rgb = {283,240,0}, 
      rng = {-0.8,-0.25,1}, 

   transp = 0.8,

     seed = 'FX',

     rule = {
             {'Draw',  'F', 'F'},
             {'Left',  '-', '-',  90},
             {'Right', '+', '+',  90},
             {'Build', 'X', 'X+YF'},
             {'Build', 'Y', 'FX-Y'},
             {'Save',  '[', '[', },
             {'Load',  ']', ']', }
            },


      speed = 500, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 1.8,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)



--[[
dofile("../libs/dawnbringer_lib.lua")

-- Dragon Curve
CX = 0.75
CY = 0.5
ITER = 14
SIZE = 0.005
ROTA = 20
RGB  = {255,255,0} -- Color, -1 = Range 0->255, -2 = Range 255->0
RNG  = {-1,-0.25,1}
TRANSP = 0.65
SEED = 'FX'
RULE = {
 {'Draw',  'F', 'F'},
 {'Left',  '-', '-',  90},
 {'Right', '+', '+',  90},
 {'Build', 'X', 'X+YF'},
 {'Build', 'Y', 'FX-Y'},
 {'Save',  '[', '[', },
 {'Load',  ']', ']', }
}



db.Lsys_Do(ITER,SEED,RULE,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 30, true) -- last is update speed and skip_flag (true = clean lines)

--]]


