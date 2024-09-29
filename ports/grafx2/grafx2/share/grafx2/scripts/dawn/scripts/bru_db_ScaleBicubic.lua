--BRUSH: Bicubic Scale 
--(Use primarily for UP-Scaling non-pixelart)
--by Richard Fhager 

-- Allowing for < x0.25 right now for evaluation, interpolations break down at lower scales

dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")

function main()

 local x,y,w,h,w1,h1,wb,hb,wb1,hb1,new_wb,new_hb,brushtxt,floor,max,scalemode, posx,posy,txt
 local OK,ScaleX,ScaleY,SizeX,SizeY,Scale2Img,Bicubic,Bilinear,Basic
 local f_put, f_get, f_getcol, f_match

 wb,hb = getbrushsize()
 w,h = getpicturesize()

 brushtxt = "("..wb.."x"..hb..")"
 OK,ScaleX,ScaleY,SizeX,SizeY,Scale2Img,Bicubic,Bilinear,Basic = inputbox("BiCubic Brush Scaling "..brushtxt,
                        
                           "A: X Scale: x0.01-100.0",       1,  0.01,100,2,
                           "   Y Scale: x0.01-100.0",       1,  0.01,100,2,
 
                           "B: X Size: "..brushtxt,         -1, -1,2048,0,
                           "   Y Size: (-1 = off)",         -1, -1,2048,0,

                           "C: Scale 2 Img ("..w.."x"..h..")",   0, 0,1,-1,

                           "1. Bicubic",                 1,  0,1,-2,
                           "2. Bilinear (linear ip_)",   0,  0,1,-2,
                           "3. Nearest Neighbour",       0,  0,1,-2
                           

                           --"# Gamma",             1.6,  0.1,5.0,3
                                                                      
 );

 if OK then

 floor,max = math.floor, math.max

 wb1,hb1 = wb-1, hb-1 -- Original Brush Size

 --f_get = getbackuppixel
 f_get = getbrushbackuppixel
 --f_put = putpicturepixel

 scalemode = 0 -- No scalemode verified
 if not (ScaleX == 1 and ScaleY == 1) then scalemode = 1; end
 if scalemode == 0 and SizeX > 0 and SizeY > 0 then scalemode = 2; end
 if Scale2Img == 1 then scalemode = 3; end

 txt = ""

 if scalemode == 1 then
  new_wb = max(1,floor(wb * ScaleX + 0.5))
  new_hb = max(1,floor(hb * ScaleY + 0.5))
  setbrushsize(new_wb, new_hb)
  f_put = putbrushpixel
  w1,h1 = new_wb-1,new_hb-1
  txt = "(Scale)"
 end

 if scalemode == 2 then
  setbrushsize(SizeX, SizeY)
  f_put = putbrushpixel
  w1,h1 = SizeX-1, SizeY-1
  txt = "(Size)"
 end

 if scalemode == 3 or scalemode == 0 then
  f_put = putpicturepixel
  w1,h1 = w-1,h-1
  txt = "N/A for image donemeter right now"
 end

 if scalemode > 0 then

  f_getcol = getbackupcolor
  f_match  = matchcolor2

  for y = 0, h1, 1 do
    posy = y / h1 * hb1

   if Bicubic == 1 then
    for x = 0, w1, 1 do
     posx = x / w1 * wb1    
     f_put(x, y, f_match(ip_.pixelRGB_Bicubic(posx,posy,f_getcol,f_get,ip_.cubip)));  
    end
   end

   if Bilinear == 1 then
    for x = 0, w1, 1 do
     posx = x / w1 * wb1    
     f_put(x, y, f_match(ip_.pixelRGB_Bilinear(posx,posy,f_getcol,f_get,ip_.linip)));
    end
   end

   if Basic == 1 then
    for x = 0, w1, 1 do
     posx = x / w1 * wb1    
     f_put(x,y,f_get(posx+0.5,posy+0.5))
    end
   end

    if scalemode == 3 then
     if db.donemeter(10,y,w,h,true) then return; end
      else if db.donetext(10,y,h1+1, txt) then return; end
    end

  end -- y
 
  else messagebox("Notice","No applicable settings selected!")
 end -- scalemode>0

end; -- OK

end -- main

main()








--[[
if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             -- Out of bounds means Transparancy color is used (by system)
             r,g,b = ip_.pixelRGB_Bilinear(posx,posy,fget,f1,ip_.kenip) -- px,py, col_func, get_func, ip_func
             else
              --r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.kenip,gamma) -- px,py, col_func, get_func, ip_func
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx,posy,fget,f1,ip_.linip,gamma)   
           end
--]]

