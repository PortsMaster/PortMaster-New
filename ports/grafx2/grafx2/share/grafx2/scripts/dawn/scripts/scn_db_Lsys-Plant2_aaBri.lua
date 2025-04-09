--SCENE: L-System - Plant 2 (BKG & AA-version)
--by Richard 'DawnBringer' Fhager

setpicturesize(812,812)
--setpicturesize(400,812)
setcolor(1,250,255,210)
clearpicture(1)
finalizepicture()

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.5,
       cy = 0.99,

     iter = 7,

     size = 0.0028,
  
   square = 1, -- Keep proportions square at all image dimensions

     rota = -10,

      rgb = {64,40,48}, 
      rng = {0.3,0.5,0}, 

   transp = 0.5,

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

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 1,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)




--[[
dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = 0.525,
       cy = 0.99,

     iter = 7, -- Don't try more than 5 interations on this one! (Gfx grow x10 and data x23 every iteration)

     size = 0.0038,

   square = 1,

     rota = 0,

      rgb = {64,16,48}, 
      rng = {0.3,0.6,0},  

   transp = 0.75,

     seed = 'X',

     rule = {
             {'Draw',  'F', 'FF',  0},
             {'Left',  '-', '-',   20},
             {'Right', '+', '+',   20},
             {'Build', 'X', 'F[+X][-X]F[--X]+X',  0},
             {'Save',  '[', '[',   0},
             {'Load',  ']', ']',   0}
            },

      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,         -- avoid double-drawing connecting points, 1 = active, 0 = deactivated (Normal mode only?)

   drawmode = "buffer_aa",  -- "normal" or "buffer"

      gamma = 1.8,       -- "buffer"-mode gamma value
    makepal = 0,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)
--]]


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


