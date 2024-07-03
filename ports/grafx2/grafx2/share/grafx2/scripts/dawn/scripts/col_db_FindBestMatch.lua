--PEN: Find Best Match
--(Set pen-color to best match of a RGB-value)
--by Richard Fhager

dofile("../libs/dawnbringer_lib.lua")

 FC = getforecolor()
 --BC = getbackcolor()

 r1,g1,b1 = getcolor(FC)


OK,r1,g1,b1,briweight,nopen = inputbox("Find Best ColorMatch (setpen)",
                           "R",    r1,  0,255,0,
                           "G",    g1,  0,255,0,
                           "B",    b1,  0,255,0, 
                           "ColMatch Bri-Weight %", 25,  0,100,0,
                           "Exclude Pencolor", 1, 0,1,0

);

if OK == true then

 pal = db.fixPalette(db.makePalList(256))
 
 if nopen == 1 then
  pal = db.stripIndexFromPalList(pal,FC)
 end

 c = db.getBestPalMatchHYBRID({r1,g1,b1},pal,briweight/100,true) 

 --messagebox(c)

 setforecolor( c )

end