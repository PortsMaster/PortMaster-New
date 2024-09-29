--SCENE: Voronoi Diagram V1.0
--by Richard 'DawnBringer' Fhager 
--

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_voronoi.lua")


 -- Data --
 --
 POINTS = 100 -- Max points (may be less if randomized into same coords)
 RES = 4   -- Point distribution resolution (min distance)
 GRACEPERIOD = 1 -- Diff in iter/time/dist that another circle can lay claim to an already claimed area ("Line thickness")
                -- A value of 0 will only include circles that layed claim at the same time.
                -- Areas with more than one claim ("Contested area") will be post-processed to find the winner.
 RENDOPTION = 1  -- Render Option: 0 = Off, 1 = Point/Area (one color / area), 2 = Iteration (palette index gradient)
 RENDLINES  = 1  -- Render Lines/Contested areas (color 0), If off area will be drawn by first claimed point
 --
 --

OK, POINTS,read,RES,GRACEPERIOD, circle,square,lines,aa, mark = inputbox("Voronoi Diagram",
                        
         "POINTS: 3-100.000",       POINTS, 3,100000,0,
         "Get POINTS from Image", 0, 0,1,0,    
         "Min Point Separation",     RES, 0,100,0,
         "Fuzzy Width (lines)*",     GRACEPERIOD,  0,16,0,
         "1. Euclidean Distance", 1,  0,1,-1,
         "2. Maximum Distance", 0,  0,1,-1,
         "*Draw Fuzzy Lines",    1,  0,1,0, 
         "(*)Interpolation/AA",      1, 0,1,0, 
         "Mark Source-Points",       1, 0,1,0    
                                                       
);



if OK == true then

  READ_FLAG = false
  if read == 1 then
   READ_FLAG = true
  end

  POINT_FLAG = false
  if mark == 1 then
   POINT_FLAG = true
  end

  SHAPE = "circle"
  if square == 1 then SHAPE = "square"; end

  AA_FLAG,LINE_FLAG = false,false
  if aa    == 1 then   AA_FLAG = true; end
  if lines == 1 then LINE_FLAG = true; end
  
  vor.makeDiagram(POINTS,RES,GRACEPERIOD,RENDOPTION,RENDLINES,SHAPE,READ_FLAG,AA_FLAG,LINE_FLAG,POINT_FLAG)

end
