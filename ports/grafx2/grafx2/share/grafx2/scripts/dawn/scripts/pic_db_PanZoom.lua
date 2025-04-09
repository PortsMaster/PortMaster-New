--PICTURE: Pan & Zoom V1.1
--by Richard Fhager 

dofile("../libs/db_interpolation.lua") -- prefix: ip_
dofile("../libs/dawnbringer_lib.lua")


--
function mouse() -- Return screen-coord that user mouseclicks
  local x,y,w,h,mouse_x,old_mouse_x,mouse_y,old_mouse_y,c0,c1, fput,fget, magnify
  w, h = getpicturesize()
  mouse_x, mouse_y = 0,0
  c0 = matchcolor(0,0,0)
  c1 = matchcolor(255,255,255)
  fput,fget = putpicturepixel,getbackuppixel

  --
  function magnify(cx,cy, replace_flag, s,m, ox,oy)
    --s = 12; m = 6; o = 0
    local x,y,c,xx,yy
    for y = -s, s, 1 do 
     for x = -s, s, 1 do
        c = fget(cx + x, cy + y)
        for xx = 0, m-1, 1 do
         for yy = 0, m-1, 1 do
           if replace_flag then
            fput(cx + x*m + xx + ox, cy + y*m + yy + oy, fget(cx + x*m + xx + ox, cy + y*m + yy + oy) )
             else
              fput(cx + x*m + xx + ox, cy + y*m + yy + oy, c)
           end
        end;end -- xx,yy
     end;end -- x,y 
  end
  --

  repeat
   old_mouse_x = mouse_x
   old_mouse_y = mouse_y

   statusmessage("X: "..mouse_x..", Y: "..mouse_y)   
   updatescreen()
   moved, key, mouse_x, mouse_y, mouse_b = waitinput(0)

   if old_mouse_x ~= mouse_x or old_mouse_y ~= mouse_y then

    -- Erase
    --magnify(old_mouse_x, old_mouse_y, true, 12,7, 96,96)

    for y = 0, h-1, 1 do 
     fput(old_mouse_x,y,fget(old_mouse_x,y))
    end
    for x = 0, w-1, 1 do 
     fput(x,old_mouse_y,fget(x,old_mouse_y))
    end

    -- Redraw
    --magnify(mouse_x, mouse_y, false, 12,7, 96,96)

    for y = 0, h-2, 2 do 
     fput(mouse_x,y,c0); fput(mouse_x,y+1,c1)
    end
    for x = 0, w-2, 2 do 
     fput(x,mouse_y,c0); fput(x+1,mouse_y,c1)
    end

   end

  until mouse_b == 1 or key == 27
  return mouse_x,mouse_y
end
--

--
function main(px,py)

 local x,y,h,w,c,n,cx,cy,ox,oy,oyo,f2,f2,zoom,down,near,bi,cubic,r,g,b,c,xlimit,ylimit, cos,floor,max,min
 local nnoff_x, nnoff_y,  ip_func

 -- Bilinear ip function
 --ip_func = ip_.kenip
 ip_func = ip_.linip

 w, h = getpicturesize()
 cx,cy = 0.5, 0.5
 if px == null then px = w * cx; end
 if py == null then py = h * cy; end

  -- Draw Center lines
  for n = 0, 1, 1 do
   c = matchcolor(n*255,n*255,n*255)
   drawline(px-n,0,px-n,h-1,c)
   drawline(0,py-n,w-1,py-n,c)
  end
  updatescreen()
  -- And erase them again (so the final settings will replace these gfx)
  for n = 0, w-1, 1 do 
   putpicturepixel(n,py,getbackuppixel(n,py))
   putpicturepixel(n,py-1,getbackuppixel(n,py-1))
  end
  for n = 0, h-1, 1 do 
   putpicturepixel(px,  n,getbackuppixel(px,  n))
   putpicturepixel(px-1,n,getbackuppixel(px-1,n))
  end


OK,zoom,down, px,py, dummy, near,cubic,bi,gamma = inputbox("Image Pan & Zoom",

                           "Zoom/Scale: 1.0-32.0",   2,  1,32,2, 
                           "Scale DOWN (simple)",      0,0,1,0,

                           "Center X: (.5 to center )", px, 0,w-1,1,
                           "Center Y: (inside pixel.)",       py, 0,h-1,1, 

                           "--- Interpolation Methods ---",       0,  0,0,4,
                           "1. Nearest Neighbour",       1,  0,1,-1,
                           "2. Bicubic (photo)",         0,  0,1,-1,
                           "3. Bilinear *",              0,  0,1,-1,
                           "* Bilinear Gamma",           1.6,  0.1,5.0,3
                                                                      
);




if OK and zoom ~= 1999 then -- We allow zoom == 1 right now, for testing purposes. If x1 looks crappy...

 cos,floor,max,min = math.cos, math.floor, math.max, math.min

 nnoff_x = 0.5 -- Nearest neighbour will be screwed up at x1 without 0.5 addition
 nnoff_y = 0.5

 -- +0.5 to Zoom in on center of pixel rather than the anchor-corner (0.0)
 -- Identical to adding 0.5 to pixelpostions?
 deadcenter = 0.0 

 cx,cy = px / w, py / h

 f1 = getbackuppixel
 f2 = putpicturepixel

 if down == 0 then
  zoom = 1 / zoom -- yes, zooming in is 1 / zoom
 end

 if zoom < 1 then
  for n = 0, 1, 1 do
   x = px --cx * w
   y = py --cy * h
   c = matchcolor(n*255,n*255,n*255)
   db.line(x-n,0,x-n,h-1,c)
   db.line(0,y-n,w-1,y-n,c)

   x0 = floor(px - w * zoom / 2)
   y0 = floor(py - h * zoom / 2)
   xs = floor(w * zoom + 1.5)
   ys = floor(h * zoom + 1.5)
   db.drawRectangleLine(x0-n,y0-n,xs,ys,c)
  end
 end


 w1 = w-1 -- This is correct, w=3, 0-1-2, 1/w = 1/3, 1/(w-1) = 0.5. For center w * 0.5 = 1.5 is right
 h1 = h-1

for y = 0, h - 1, 1 do
  oyo = y / h1;
  for x = 0, w - 1, 1 do

         oy = oyo
         ox = x / w1;

         ox = (ox - 0.5) * zoom + cx -- Centre is 0.5,0.5 --(X-0.5)/zoom + 0.5 + panx
         oy = (oy - 0.5) * zoom + cy

   c = 0
   if ox >= 0 and ox <= 1 and oy >= 0 and oy <= 1 then -- Fill void with color 0 (rather than stretching border pixels)

        posx = ox * w1 + deadcenter
        posy = oy * h1 + deadcenter

          if near == 1 then
           c = f1(floor(posx + nnoff_x),floor(posy + nnoff_y));
          end

          if bi == 1 then
            if gamma <= 1.0 then
             -- No border protection by default in these interpolations
             r,g,b = ip_.pixelRGB_Bilinear(posx, posy, getbackupcolor,f1,ip_func) -- px,py, col_func, get_func, ip_func
             else
              r,g,b,pal = ip_.pixelRGB_Bilinear_PAL_gamma(posx, posy, getbackupcolor,f1,ip_func, gamma) -- px,py, col_func, get_func, ip_func
             end
           c = matchcolor2(r,g,b) 
          end

          if cubic == 1 then
           r,g,b = ip_.pixelRGB_Bicubic(posx, posy, getbackupcolor,f1,ip_.cubip)
           c = matchcolor2(r,g,b) 
          end
   
  end

          f2(x, y, c);
     
  end
  --if y%8==0 then updatescreen();if (waitbreak(0)==1) then return; end; end
  if db.donemeter(10,y,w,h,true) then return; end

end

end; -- OK
end -- main
--


w, h = getpicturesize()
cx,cy = 0.5, 0.5
px,py = w * cx, h * cy

selectbox("Pan & Zoom: ACTION",
    --"Run Script", main,
    "Run Script", function () main(px,py); end,
    "<User: Select Center>", function () main(mouse()); end
    --"[QUIT]", dummy
);
