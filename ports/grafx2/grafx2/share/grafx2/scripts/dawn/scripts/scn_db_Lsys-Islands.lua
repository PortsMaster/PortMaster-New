--SCENE: L-System - Islands and Lakes
--by Richard 'DawnBringer' Fhager

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.25,
       cy = 0.75,

     iter = 2,

     size = 0.014,

     rota = 0,

      rgb = {255,80,192}, 
      rng = {-0.25,0.75,-0.25}, 

   transp = 1.0,

     seed = 'F+F+F+F',

     rule = {
             {'Draw',  'F', 'F+M-FF+F+FF+FM+FF-M+FF-F-FF-FM-FFF'},
             {'Left',  '-', '-',  90},
             {'Right', '+', '+',  90},
             {'Move',  'M', 'MMMMMM'},
             --{'Save',  '[', '[', },
             --{'Load',  ']', ']', }
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


CX = 0.25
CY = 0.75
ITER = 2
SIZE = 0.014
ROTA = 0
RGB  = {255,80,192} 
RNG  = {-0.25,0.75,-0.25}
TRANSP = 1.0
SEED = 'F+F+F+F'
RULE = {
 {'Draw',  'F', 'F+M-FF+F+FF+FM+FF-M+FF-F-FF-FM-FFF'},
 {'Left',  '-', '-',  90},
 {'Right', '+', '+',  90},
 --{'Build', 'X', ''},
 --{'Build', 'Y', ''},
 {'Move',  'M', 'MMMMMM'},
 --{'Save',  '[', '[', },
 --{'Load',  ']', ']', }
}

db.Lsys_Do(ITER,SEED,RULE,CX,CY,SIZE,ROTA,RGB,RNG,TRANSP, 30, true) -- last is update speed and skip_flag (true = clean lines)
--]]

