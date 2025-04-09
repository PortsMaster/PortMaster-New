--BRUSH: 4-Dither System - 3 Color Pyramid
--(This script works with any size palette)
--by Richard 'DawnBringer' Fhager



dofile("../libs/db_4dither.lua")

c1 = 1
c2 = 2
c3 = 3
Xsize = 32
Ysize = 32
Space = 1


OK,c1,c2,c3, pyramid_mode, yflip_mode, xflip_mode, Xsize, Ysize, Space = inputbox("3-Dither Pyramid",
                                   
          "Color 1 (top)  ",  c1,  0,255,0,
          "Color 2 (right)",  c2,  0,255,0,
          "Color 3 (left) ",  c3,  0,255,0,
          "Pyramid mode",  1,0,1,0,
          "Y-Flip",  0,0,1,0,
          "X-Flip",  0,0,1,0,
          "Swatch  Width: 8-256",  Xsize,  8,256,0,
          "Swatch Height: 8-256",  Ysize,  8,256,0,
          "Spacing: 0-15",  Space,  0,15,0
  
);


--
if OK then

 xs = (Xsize + Space) * 5 
 ys = (Ysize + Space) * 5 

 setbrushsize(xs,ys)

 Xflip_flag   = false; if xflip_mode   == 1 then Xflip_flag   = true; end
 Yflip_flag   = false; if yflip_mode   == 1 then Yflip_flag   = true; end
 Pyramid_flag = false; if pyramid_mode == 1 then Pyramid_flag = true; end

 if Pyramid_flag and Xflip_flag then -- Pyramids can't be x-flipped so let's swap the colors
  Xflip_flag = false
  c2,c3 = c3,c2  
 end
 

 -- Color indexes, position, swatch size, spacing, xflip_flag, yflip_flag, pyramid_flag
 d4_.d3_CTRL_drawPyramid(c1,c2,c3, 0,0, Xsize,Ysize, Space, Xflip_flag, Yflip_flag, Pyramid_flag, putbrushpixel)
 

end
--