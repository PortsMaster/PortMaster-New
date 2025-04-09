--PICTURE: Hue-Saturation Diagram
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


OK, sat_mod1, sat_mod2, sat_mod3, sat_mod4, Radius, min_sz, max_sz, nobg = inputbox("Hue-Saturation Diagram",
                      
 "1. Sat: Purity",         1,  0,1,-1,  
 "2. Sat: HSV/HSB",        0,  0,1,-1, 
 "3. Sat: HSL",            0,  0,1,-1, 
 "(4. Sat: 'True')",         0,  0,1,-1,   
 "Diagram Radius",         150,  24,512,0,  
 "Min Plot Size: 1-32",         2,  1,32,0,
 "Max Plot Size: 1-32",         8,  1,32,0,    
 "Exclude Pen-BG Color", 0,  0,1,0

 --"ColorMixes",   1,  0,1,0, 
 --"Close Colors", 1,  0,1,0,
                          
);


if OK then

sat_func = db.getPurity
if sat_mod2 == 1 then sat_func = db.getSaturationHSV; end
if sat_mod3 == 1 then sat_func = db.getSaturationHSL; end
-- 'True' is distance from grayscale axis. Its major flaw is that darker shades of pure colors
-- are considering having falling saturation. 
-- This can be adjusted by normalizing sat by rgb-max value, by which one gets a result fairly close to Purity.
-- It's included here mostly for its neat geometry! :D
if sat_mod4 == 1 then sat_func = (function(r,g,b)return db.getTrueSaturationX(r,g,b)/255; end); end

--sat_func = db.getBrightnessFrac

palList = db.fixPalette(db.makePalList(256),1)
--palList = db.addHSBtoPalette(palList, sat_func) -- db.drawHSBdiagram


 if nobg == 1 then
  r,g,b = getcolor(getbackcolor())
  palList = db.strip_RGB_FromPalList(palList,r,g,b)
 end

--Clearcolor = db.getBestPalMatchHYBRID({0,0,0},palList,0.25,true)



margin = 16
cx = Radius + margin + max_sz
cy = Radius + margin + max_sz
rd = Radius
greytolerance = 0.01
--min_sz = 2 -- Plot sizes depending on Saturation
--max_sz = 8

setpicturesize((Radius+margin)*2 + max_sz*2,(Radius+margin)*2 + max_sz*2) 
clearpicture(matchcolor(0,0,0))

--drawHueSaturationDiagram(db.getPurity, palList, cx,cy,rd) 
db.drawHueSaturationDiagram(sat_func, palList, cx,cy,rd, min_sz,max_sz, greytolerance)

--db.drawHueSaturationDiagram(db.getPurity, palList, 300,350,40, 2,2, greytolerance) -- Purity
--db.drawHueSaturationDiagram(db.getSaturationHSV, palList, 450,110,80, 1,4, greytolerance) -- HSV
--db.drawHueSaturationDiagram((function(r,g,b)return db.getSaturation(r,g,b)/255; end), palList, 450,300,60, 2,2, greytolerance) -- HSL


--drawHueSaturationDiagram(db.getSaturationHSV, palList, cx,cy,rd, min_sz,max_sz, greytolerance) -- HSV
--drawHueSaturationDiagram(db.getSaturationAbs, palList, cx,cy,rd, min_sz,max_sz, greytolerance) -- Absolute (Fraction)
--drawHueSaturationDiagram((function(r,g,b)return db.getTrueSaturationX(r,g,b)/255; end), palList, cx,cy,rd, min_sz,max_sz, greytolerance) -- True (distance from gray-axis)
--drawHueSaturationDiagram((function(r,g,b)return db.getSaturation(r,g,b)/255; end), palList, cx,cy,rd, min_sz,max_sz, greytolerance) -- HSL

end
-- OK

