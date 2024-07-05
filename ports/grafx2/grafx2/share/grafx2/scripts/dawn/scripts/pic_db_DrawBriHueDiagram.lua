--PICTURE: Hue-Brightness Diagram V1.2
--by Richard 'DawnBringer' Fhager


-- (V1.2 Saturation selection)


dofile("../libs/dawnbringer_lib.lua")

OK,w,h,sat_mod1,sat_mod2,sat_mod3,sat   = inputbox("Hue-Brightness Diagram",

                           " Width: 16-1024",  256,  16,1024,0,  
                           "Height: 16-1024", 256,  16,1024,0,
"1. Sat Mode: Purity",         1,  0,1,-1,  
"2. Sat Mode: HSV/HSB",        0,  0,1,-1, 
"3. Sat Mode: HSL",            0,  0,1,-1,  
                           "Saturation: 0-255", 255,  0,255,0
                           --"1. Image",           1,  0,1,-1,
                           --"2. Brush",           0,  0,1,-1                                            
);


if OK == true then

 setpicturesize(w,h)

 sat_func = db.getPurity_255
 if sat_mod2 == 1 then sat_func = db.getSaturationHSV_255; end
 if sat_mod3 == 1 then sat_func = db.getSaturationHSL_255; end

 --palList = db.addHSBtoPalette(db.fixPalette(db.makePalList(256),1))
 palList = db.addHSBtoPalette(db.fixPalette(db.makePalList(256),1), sat_func) -- Will work with any Sat function including Purity

 db.drawHSBdiagram(palList,0,0,w,h,1,sat)
 -- Pal, posz,posy,width,height,size,saturation

end