--PICTURE: Voronoi Crystallize Filter
--by Richard 'DawnBringer' Fhager 


dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_voronoi.lua")


 -- Data --
 --
 POINTS = 1000 -- Max points (may be less if randomized into same coords)
 RES = 4   -- Point distribution resolution (min distance)
 --RADIUS = math.min(238, 25 + math.ceil(1.8 * PIXELS^0.5 / POINTS^0.5)) -- Max radius of circles (238 is currently max safe), this is also number of charting iterations.
 --RADIUS = 50
 GRACEPERIOD = 0 -- Diff in iter/time/dist that another circle can lay claim to an already claimed area ("Line thickness")
                -- A value of 0 will only include circles that layed claim at the same time.
                -- Areas with more than one claim ("Contested area") will be post-processed to find the winner.
 RENDOPTION = 1  -- Render Option: 0 = Off, 1 = Point/Area (one color / area), 2 = Iteration (palette index gradient)
 RENDLINES  = 1  -- Render Lines/Contested areas (color 0), If off area will be drawn by first claimed point
 --
 --

OK, POINTS,RES,GRACEPERIOD, circle,square,lines,aa = inputbox("Voronoi Crystallize Filter",
                        
         "POINTS: 3-100.000",       POINTS, 3,100000,0,
         "Min Point Separation",    RES, 0,100,0,
         "Fuzzy Width (Lines)*",    GRACEPERIOD,  0,16,0,
         "1. Euclidean Distance",   1,  0,1,-1,
         "2. Maximum Distance",     0,  0,1,-1,
         "*Draw Fuzzy Lines",       0, 0,1,0, 
         "(*)Interpolation/AA",     1, 0,1,0 
                                                          
);



if OK == true then

  SHAPE = "circle"
  if square == 1 then SHAPE = "square"; end

  AA_FLAG,LINE_FLAG = false,false
  if aa    == 1 then   AA_FLAG = true; end
  if lines == 1 then LINE_FLAG = true; end
 
  --function vor.imageCRYSTALLIZE(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,AA_FLAG,LINE_FLAG,FILLER(optional))
  vor.imageCRYSTALLIZE(POINTS,RES,GRACEPERIOD,1,1,AA_FLAG,LINE_FLAG,SHAPE) 

end
