--PICTURE: Box Pattern


dofile("../libs/dawnbringer_lib.lua")

w,h = getpicturesize()
PIXELS = w*h

OK, size,space,xoff = inputbox("Box Pattern", 
                            "Box Size",            32, 1, 256, 0,
                            "Spacing",             1, 0, 256,0,
                            "Row Offset",          1, 0, 1, 0                                                 
);

--
if OK then

c = getforecolor()

-- 32/2
BLOCKSIZE = size -- 5 and jump 1 for nice blockout with image still readable, 32-2 for nice pattern
JUMP = space + 1
stp = BLOCKSIZE + 1


 for y = 1, h, stp do 
   o = (y/2)%stp * xoff
   for x = -o, w, stp do

    for d = 0, BLOCKSIZE/2, JUMP do
      s = BLOCKSIZE - d*2
      db.drawRectangleLine(x+d,y+d,s,s,c)
    end   

  end
  updatescreen();if (waitbreak(0)==1) then return end
 end

end
--
