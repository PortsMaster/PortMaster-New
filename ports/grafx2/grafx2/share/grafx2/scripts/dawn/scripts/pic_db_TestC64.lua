--INFO: Test C64-Formats V1.5
--by Richard Fhager 
--
-- Email: dawnbringer@hem.utfors.se
--
-- Place this script in: ..\share\grafx2\scripts
--
-- Scripts in Grafx2 are run by Right-clicking the Brush-effect button (bottom/middle of menu)
--
--
-- When using this script for debugging in Grafx2; it will help greatly to display a 8x8 grid:
-- Activate by opening "Effects" (F/X) menu, R-click "Grid"-button, make sure X&Y is 8 and check "Show".
--
-- This script...
-- * ..expects the colors used to be the first 16 (error otherwise)
-- * ..does not check validity of the palette since there is no offical/standard C64 palette
-- * ..has perhaps not been thoroughly tested; so please report any bugs/problems or suggestions.
--

-- Thanx to Sven 'Ptoing' Ruthner for suggestions & testing (and everyone else who contributed).


OK,multi,hires,mult_hi,mark,halt,HALFSIZEMODE,defglobcol = inputbox("Check C64 Format v1.5",
                       
                           "1. MultiColor*#    (4x8)", 1,  0,1,-1,
                           "2. Hires           (8x8)", 0,  0,1,-1,
                           "3. MultiCol-Hires# (8x8)", 0,  0,1,-1,
                           "a) Errors: Mark all",     1,  0,1,-2,
                           "b) Errors: Halt at each",  0,  0,1,-2,
                           "*HalfWidth Mode (160x200)", 0, 0,1,0,
                           "#Set Global Col (-1=calc)",   -1,    -1, 15,0
                        
);


--dofile("../libs/dawnbringer_lib.lua")


if OK == true then

 MODE_STRING = "MULTICOLOR"

 xsize  = 320
 xwidth = 8 
 xstep  = 2
 bx = 10 -- Box size

 if HALFSIZEMODE == 1 then
  MODE_STRING = "MULTICOLOR-HALFSIZE"
  xsize  = 160
  xwidth = 4 
  xstep  = 1
  bx = 6
 end

 MULTICOLHIMODE = 0
 if mult_hi == 1 then -- Must override HALFSIZEMODE and activate multicolor
  MODE_STRING = "MULTICOLOR-HIRES"
  xsize  = 320
  xwidth = 8 
  xstep  = 1
  bx = 10
  multi = 1 -- Activate multicolor mode
  MULTICOLHIMODE = 1
  HALFSIZEMODE = 0
 end

MCERROR = false
HIERROR = false
GLOBALFAIL = false

-- Not wide
ERRCOL1 = 16
setcolor(ERRCOL1,255,0,255)

-- Bad color index
ERRCOL2 = 17
setcolor(ERRCOL2,255,255,0)

-- Too many colors
ERRCOL3 = 18
setcolor(ERRCOL3,0,255,255)

-- No global
ERRCOL4 = 19
setcolor(ERRCOL4,255,128,0)

--
function box(x,y,w,h,c)
 w = w-1
 h = h-1
 line(x,y,x+w,y,c)
 line(x,y,x,y+h,c)
 line(x,y+h,x+w,y+h,c)
 line(x+w,y,x+w,y+h,c)
end
--
--
function line(x1,y1,x2,y2,c) -- Coords should be integers or broken lines are possible
 local n,st,m,xd,yd; m = math
 st = m.max(1,m.abs(x2-x1),m.abs(y2-y1));
 xd = (x2-x1) / st
 yd = (y2-y1) / st
 for n = 0, st, 1 do
   putpicturepixel(m.floor(x1 + n*xd), m.floor(y1 + n*yd), c );
 end
end
--


w, h = getpicturesize()

if HALFSIZEMODE == 0 then
 if w ~= 320 or h ~= 200 then 
  messagebox "Error: Image dimensions are not 320 x 200";
  multi, hires = 0,0
 end
end

if HALFSIZEMODE == 1 then
 if w ~= 160 or h ~= 200 then 
  messagebox "Error: Halfsize mode - Image dimensions are not 160 x 200";
  multi, hires = 0,0
 end
end

-- MultiColor & MultiCol-Hires
if multi == 1 then

 function multicolor()
  glob = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- Global color: 0=Anon,1=Potential,-1=No


  -- User selected Global Color
  GLOBALSET = false
  if defglobcol > -1 then
   for n = 1, 16, 1 do
    glob[n] = -1
   end
   glob[defglobcol+1] = 1
   GLOBALSET = true
  end

  for y = 0, 199, 8 do
   for x = 0, xsize-1, xwidth do
     cols = {}
     for cy = 0, 7, 1 do
      for cx = 0, xwidth-1, xstep do
        c1 = getbackuppixel(x+cx,cy+y)
        c2 = getbackuppixel(x+cx+1,cy+y)

        if HALFSIZEMODE == 0 and MULTICOLHIMODE == 0 then -- 160*200 Ignore Widescreen
         if c1 ~= c2 then 
          MCERROR = true
           if mark == 0 then
            err = 1; ex = x+cx; ey = y+cy; return err,ex,ey;
           end 
           if mark == 1 then
            box(x-1,y-1,bx,10, ERRCOL1);  
           end 
         end
        end

         if c1 > 15  then
          MCERROR = true 
          if mark == 0 then
           err = 2; ex = x+cx; ey = y+cy; return err,ex,ey; 
          end
          if mark == 1 then
           box(x-1,y-1,bx,10, ERRCOL2);
          end
         end

         cols[c1+1] = true
      end
     end

    used = 0; for n = 1, 16, 1 do  if cols[n] then used = used + 1; end; end

    if used > 4 then
     GLOBALFAIL = true
     MCERROR = true 
     if mark == 0 then return 3,x,y; end
     if mark == 1 then
      box(x-1,y-1,bx,10, ERRCOL3); 
      box(0,0,320,200, ERRCOL4);
     end
    end

    if used == 4 and (not GLOBALFAIL or GLOBALSET == true) then  
     cand = 0
     for n = 1, 16, 1 do
       if GLOBALSET == false then  
        if cols[n] == true  and glob[n] == 0 then glob[n] = 1; end -- Activate potential
        if cols[n] ~= true then glob[n] = -1; end -- Can't be the global 
        if glob[n] == 1 then cand = cand + 1; end -- possible global colors
       end
       if GLOBALSET == true then  
        if glob[n] == 1 and cols[n] == true then cand = cand + 1; end -- possible global colors
       end     
     end

     if cand == 0 then
      GLOBALFAIL = true
      MCERROR = true 
      if mark == 0 then return 4,x,y; end
      if mark == 1 then 
       box(0,0,320,200, ERRCOL4);
       box(x-1,y-1,bx,10, ERRCOL4); 
      end
     end

    end

   end
  end

  g = "undetermined (no char uses more than 3 colors)"
  for n = 1, 16, 1 do 
   if glob[n] == 1 then g = n-1; break; end -- find global color
  end
  
  return 0,-1,-1,g
 end; -- 

 err,ex,ey,glob = multicolor()

 if mark == 0 then
  title = MODE_STRING.." ERROR!"
  if err == 0 then messagebox("IMAGE VERIFIED!", MODE_STRING.." image is ok!\n\nGlobal color is "..glob); end
  if err == 1 then messagebox(title, "Not a wide pixel at "..ex..", "..ey); end
  if err == 2 then messagebox(title, "Bad color index at "..ex..", "..ey); end
  if err == 3 then messagebox(title, "Too many colors in character at "..ex..", "..ey); end
  if err == 4 then messagebox(title, "Global color error: fail by character at "..ex..", "..ey); end
 end

 if mark == 1 then

  updatescreen()

  if not MCERROR then messagebox("IMAGE VERIFIED!", MODE_STRING.." image is ok!\n\nGlobal color is "..glob); end

  if MCERROR then
   t = "There are errors in the image:\n\n"
   if MULTICOLHIMODE == 0 then t = t.."MAGENTA = Not Widepixel\n"; end -- No widepixels in mc-hires
   t = t.."CYAN... = Too many colors in char\n"
   t = t.."YELLOW. = Bad color index (>15)\n" 
   t = t.."ORANGE. = Global color failure\n"
   if not GLOBALFAIL then
     t = t.."\nGlobal color is "..glob
   end
   messagebox(MODE_STRING.." ERRORS",t)
  end

 end -- mark == 1

end


-- Hires
if hires == 1 then

 function hires()
  for y = 0, 199, 8 do
   for x = 0, 319, 8 do
      cols = {}
      for cy = 0, 7, 1 do
       for cx = 0, 7, 1 do
        c = getbackuppixel(x+cx,cy+y)

        if c > 15  then 
         if mark == 0 then return 2,x+cx,y+cy; end 
         if mark == 1 then box(x-1,y-1,10,10, ERRCOL2); HIERROR = true; end
        end

        cols[c+1] = true
       end
      end
      used = 0; for n = 1, 16, 1 do  if cols[n] then used = used + 1; end; end

      if used > 2 then
       if mark == 0 then return 3,x,y; end
       if mark == 1 then box(x-1,y-1,10,10, ERRCOL3); HIERROR = true; end
      end

   end
  end
  return 0,-1,-1
 end

 err,ex,ey = hires()

 if mark == 0 then
  title = "HIRES ERROR"
  if err == 2 then messagebox(title, "Bad color index at "..ex..", "..ey); end
  if err == 3 then messagebox(title, "Too many colors for HIRES in character at "..ex..", "..ey); end
 end

 if not HIERROR then
  if err == 0 then messagebox("IMAGE VERIFIED!", "HIRES image is ok!"); end
 end

 updatescreen()

 if HIERROR and mark == 1 then
  t = "There are errors in the image:\n\n"
  t = t.."CYAN... = Too many colors in char\n"
  t = t.."YELLOW. = Bad color index (>15)\n"
  messagebox("HIRES ERRORS",t)
 end

end -- hires

end -- eof OK

