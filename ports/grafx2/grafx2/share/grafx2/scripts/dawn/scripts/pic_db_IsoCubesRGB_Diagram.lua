--PICTURE: Isometric RGB-Cube Diagrams
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")


OK,plotscale,zscale,dummy,bri_base,bri_mult = inputbox("IsoCube RGB-Diagrams",

                           "Plot Scale",    0.5,  0.1,10,2,
                           "Height Scale",  1.25, 0.1,10,2, 

                           "----- Cube Frame -----", -1,  0,0,4,     
                           "Brightness Base", 40,  0,255,0, 
                           "Brightness Mult", 20,  0,64,0

                           --"Brightness Diagram?", 1, 0, 1, 0,
                           --"Omitt BG-Color (by RGB)?", 0, 0, 1, 0
                                                                                   
);

if OK == true then

 palList = db.makePalList(256)
 palList = db.fixPalette(palList,1)
 
 w,h = getpicturesize()

 space = 0.05 -- fraction of width (left+middle+right = space*3)
 width = w * (1-space*3) / 2 -- width of 1 each diagram

 px1 = space * w
 px2 = space*2*w + width

 awid = math.floor(width) - 1 -- actual width of digram seem closer to this

 --messagebox(width.." "..awid)

 hmult = 1.25^0.5
 bottom = awid * 0.5 -- 2:1 lines

 side = math.floor(awid / 1.77 / hmult) -- 3^0.5 doesn't seem like the right value 1.77 is better!?

 zheight = bottom + side * zscale * hmult 
 py = (h - zheight) / 2 -- y center on zscaled height

 -- ox,oy,width,zscale,pallist,plotscale,view, bri_base, bri_mult --zscale is height, nom=1.0
 db.drawIsoCubeRGB_Diagram(px1,py, width, zscale, palList,plotscale,1, bri_base,bri_mult)
 db.drawIsoCubeRGB_Diagram(px2,py, width, zscale, palList,plotscale,2, bri_base,bri_mult)

end




