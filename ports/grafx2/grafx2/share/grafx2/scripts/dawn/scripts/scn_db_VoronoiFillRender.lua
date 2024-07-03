--SCENE: Voronoi 2D Render (256 color gradient)
--by Richard 'DawnBringer' Fhager 
--

dofile("../libs/db_voronoi.lua")


 -- Data --
 --
 POINTS = 250 -- Max points (may be less if randomized into same coords)
 RES = 1   -- Point distribution resolution (min distance)
 GRACEPERIOD = 0 -- Diff in iter/time/dist that another circle can lay claim to an already claimed area ("Line thickness")
                -- A value of 0 will only include circles that layed claim at the same time.
                -- Areas with more than one claim ("Contested area") will be post-processed to find the winner.
 RENDOPTION = 1  -- Render Option: 0 = Off, 1 = Point/Area (one color / area), 2 = Iteration (palette index gradient)
 RENDLINES  = 1  -- Render Lines/Contested areas (color 0), If off area will be drawn by first claimed point
 MULT = 1.0 -- Strength/Brightness/PalIndex Multiple, nom = 1.0
 --
 --

OK, POINTS,read,MULT,circle,square,gradient = inputbox("Voronoi 2D Render",
                        
         "POINTS: 3-100.000",       POINTS, 3,100000,0,
         "Get POINTS from Image", 0, 0,1,0,    
         "Strength Mult.: 0.1-5.0",  MULT, 0.1,5,2,
         "1. Euclidean Distance", 1,  0,1,-1,
         "2. Maximum Distance",   0,  0,1,-1,
         "Set Gradient Palette",  0, 0,1,0 
         --"Min Point Separation",     RES, 0,100,0,
         --"Fuzzy Width (Lines)*",     GRACEPERIOD,  0,16,0,
         --"a. Clean Cells",        1,  0,1,-2,
         --"b. (*) AA [WIP]",       0,  0,1,-2,
         --"c. *Fuzzy Lines",       0,  0,1,-2
                                                          
);



if OK == true then

  SHAPE = "circle"
  if square == 1 then SHAPE = "square"; end

  READ_FLAG = false
  if read == 1 then
   READ_FLAG = true
  end
 
  if gradient == 1 then
   for n = 0, 255, 1 do
    setcolor(n,n,n,n)
   end
  end

  --vor.mapRENDER_1(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,FILLER,MULT,READ_FLAG)

  vor.mapRENDER_1(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,SHAPE, MULT, READ_FLAG)

end
