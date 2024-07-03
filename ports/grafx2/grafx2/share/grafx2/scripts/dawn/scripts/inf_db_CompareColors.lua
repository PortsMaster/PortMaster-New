--INFO: Compare Colors/Palettes 
--by Richard Fhager 


dofile("../libs/dawnbringer_lib.lua")
--> db.makePalList(cols)
--> db.makeSparePalList(cols)
--> db.makeSpareHistogram() 
--> db.makeHistogram() 
--> db.makePalListFromHistogram(hist) 
--> db.fixPalette(pal,sortflag)


OK,Cimg,Cpal,Simg,Spal   = inputbox("Compare Colors",
                        
                           "Current Image Colors",       1,  0,1,-1,
                           "Current Palette",            0,  0,1,-1,
                           "w/ Spare Image Colors",      1,  0,1,-2,
                           "w/ Spare Palette",           0,  0,1,-2                                                             
);


if OK == true then

 -- Current
 C_thing = "Image colors"
 if Cimg == 1 then
  CpalList = db.fixPalette(db.makePalListFromHistogram(db.makeHistogram()),0) 
 end
 if Cpal == 1 then
  C_thing = "Palette colors"
  CpalList = db.fixPalette(db.makePalList(256),0)
 end

 -- Spare
 S_thing = "image colors"
 if Simg == 1 then
  SpalList = db.fixPalette(db.makePalListFromSpareHistogram(db.makeSpareHistogram()),0) 
 end
 if Spal == 1 then
  S_thing = "palette"
  SpalList = db.fixPalette(db.makeSparePalList(256),0)
 end

 sList = {}
 for n = 1, #SpalList, 1 do
   rgb = SpalList[n];
   value = 1 + rgb[1] * 65536 + rgb[2] * 256 + rgb[3];
   sList[value] = {rgb[4]} -- Image palette index
 end

 result = ""
 nomatch = 0
 for n = 1, #CpalList, 1 do
   rgb = CpalList[n];
   value = 1 + rgb[1] * 65536 + rgb[2] * 256 + rgb[3];
  if sList[value] == null then
   nomatch = nomatch + 1
   result = result..nomatch..". #"..rgb[4].." ["..rgb[1]..", "..rgb[2]..", "..rgb[3].."]\n"
  end
 end

 text = nomatch.." "..C_thing.." not in Spare "..S_thing.." (only uniques listed):\n\n"..result

 if nomatch == 0 then 
   text = "Everything ok!\n\nAll "..C_thing.." found in Spare "..S_thing.."\n"
 end

 --if nomatch > 9 then 
 --  text = "Numerous "..C_thing.."s not in Spare "..S_thing.."\n"
 --end

 messagebox(text)

end
