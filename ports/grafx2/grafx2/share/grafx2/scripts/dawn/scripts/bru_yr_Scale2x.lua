--BRUSH: Resize 200% with Scale2x filter
--by Yves Rizoud
--Algorithm from scale2x sourceforge project

-- Copyright 2010 Yves Rizoud
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; version 2
-- of the License. See <http://www.gnu.org/licenses/>

width, height = getbrushsize()

setbrushsize(width*2,height*2)

for x = 0, width - 1, 1 do
  for y = 0, height - 1, 1 do
   
    b = getbrushbackuppixel(x,y-1);
    d = getbrushbackuppixel(x-1,y);
    e = getbrushbackuppixel(x,y);
    f = getbrushbackuppixel(x+1,y);
    h = getbrushbackuppixel(x,y+1);

    if (b ~= h and d ~= f) then
      if (d == b) then e0=d else e0=e end
      if (b == f) then e1=f else e1=e end
      if (d == h) then e2=d else e2=e end
      if (h == f) then e3=f else e3=e end
   else
    	e0 = e
    	e1 = e
    	e2 = e
    	e3 = e
   end

   putbrushpixel(x*2, y*2, e0);
   putbrushpixel(x*2+1, y*2, e1);
   putbrushpixel(x*2, y*2+1, e2);
   putbrushpixel(x*2+1, y*2+1, e3);

 end
end


