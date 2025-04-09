--PICTURE: Polar Hue-Bri Diagrams V2.0
--by Richard 'DawnBringer' Fhager

-- (V2.0 Saturation selection, New function, render/pixel)

dofile("../libs/dawnbringer_lib.lua")

OK,radius,sat_mod1,sat_mod2,sat_mod3,hisat,medsat,losat = inputbox("Polar Bri-Hue Diagrams",
    "Radius",          100, 8,256,0,                
    "1. Sat Mode: Purity",         1,  0,1,-1,  
    "2. Sat Mode: HSV/HSB",        0,  0,1,-1, 
    "3. Sat Mode: HSL",            0,  0,1,-1,  
    "Hi  Saturation: 0-255", 255, 0,255,0,
    "Med Saturation: 0-255", 128, 0,255,0,
    "Lo  Saturation: 0-255", 48,  0,255,0                            
);

if OK then

 sat_func = db.getPurity_255
 if sat_mod2 == 1 then sat_func = db.getSaturationHSV_255; end
 if sat_mod3 == 1 then sat_func = db.getSaturationHSL_255; end

ox = 3
oy = 3
sp = 2 -- 50% of spacing 
pol_exp = 1.25

both = 2
w = radius*6 + sp*2*2 + ox*2
h = radius*2*both + sp*2*(both-1)   + oy*2

setpicturesize(w,h)
clearpicture(matchcolor(128,128,128))


--db.polarHSBdiagram_Pixel(palList,ox,oy,radius,saturation,pol_exp,dark2bright_flag)

palList = db.addHSBtoPalette(db.fixPalette(db.makePalList(256),1), sat_func) -- db.drawHSBdiagram
  
db.polarHSBdiagram_Pixel(palList,ox              ,oy,radius,hisat,pol_exp,dark)
db.polarHSBdiagram_Pixel(palList,ox+(radius+sp)*2,oy,radius,medsat,pol_exp,dark)
db.polarHSBdiagram_Pixel(palList,ox+(radius+sp)*4,oy,radius,losat,pol_exp,dark)

 db.polarHSBdiagram_Pixel(palList,ox,              oy+(radius+sp)*2,radius,hisat,pol_exp,true)
 db.polarHSBdiagram_Pixel(palList,ox+(radius+sp)*2,oy+(radius+sp)*2,radius,medsat,pol_exp,true)
 db.polarHSBdiagram_Pixel(palList,ox+(radius+sp)*4,oy+(radius+sp)*2,radius,losat,pol_exp,true)

end