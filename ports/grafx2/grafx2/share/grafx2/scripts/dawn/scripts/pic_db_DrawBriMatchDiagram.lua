--PICTURE: Draw Palette Bri-Match Diagram
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")

palList = db.fixPalette(db.makePalList(256),1)


OK,w,h,nobg,clear,setsize   = inputbox("Brightness Match Diagram",
                           " Width: 16-512",  48,  16,512,0,  
                           "Height: 16-512", 256, 16,512,0,  
                           "Omitt BG-Color (by RGB)", 0, 0, 1, 0,
                           "Clear Screen", 1, 0, 1, 0,
                           "Autosize Screen", 1, 0, 1, 0   
   
   
                                                          
);


if OK == true then

 BG = getbackcolor() 

 if nobg == 1 then
  --palList = db.stripIndexFromPalList(palList,BG)
  r,g,b = getcolor(BG)
  palList = db.strip_RGB_FromPalList(palList,r,g,b)
 end

 if setsize == 1 then setpicturesize(w + 100, h+2); end 

 if clear == 1 then clearpicture(BG); end

 db.drawBriMatchDiagram(palList,1,1,w,h)
 db.drawBriLevelDiagram(palList,w+4,1,h, 5,4)
end