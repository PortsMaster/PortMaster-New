--SCENE: L-System - Koch Snowflakes
--by Richard 'DawnBringer' Fhager

Cx = {0.485, 0.44, 0.4, 0.349, 0.26}
Cy = {0.535, 0.61, 0.68, 0.7665, 0.92}
Iter = {1,2,3,4,6}
Size = {0.0011*20, 0.0011 * 22, 0.0011 * 12,0.0011 * 6, 0.00115}
Rgb = {{255,128,128}, {255,176,80}, {255,240,112}, {160,255,160}, {144,255,255}}

--
for n = 1, #Cx, 1 do

dofile("../pfunctions/pfunc_Lsystem.lua")(
{ -- Data object

       cx = Cx[n], 
       cy = Cy[n],

     iter = Iter[n],

     size = Size[n],

   square = 0, -- Square keeps original position/anchorpoints so it won't work well with these non-center fractals

     rota = 0,

      rgb = Rgb[n],
      rng = {0,0,0}, 

   transp = 1.0,

     seed = 'F++F++F',

     rule = {
             {'Draw',  'F', 'F-F++F-F',  0},
             {'Left',  '-', '-',   60},
             {'Right', '+', '+',   60},
            },


      speed = 50, 	 -- Lines drawn per screenupdate, set high (+1000) for "buffer"-mode, 0 will deactivate updating (and preplotting in "buffer"-mode)

   skipmode = 1,        

   drawmode = "buffer_aa",  -- "normal", "buffer" or "buffer_aa"

      gamma = 2.2,       -- "buffer"-mode gamma value
    makepal = 0,         -- Generate Palette in Buffer mode? 1 = Yes, 0 = No

  briweight = 0.25       -- Colormatching Brightness-weight 0..1 (nominal = 0.25)

 }
)

end
--


