--PALETTE: Expand Colors V1.1
--by Richard Fhager 
--Email: dawnbringer@hem.utfors.se
--
-- Continously fill the greatest void in the area of the color-cube enclosed by (or along ramps of) initial colors
-- This algorithm will create lines of allowed colors (all ranges) in 3d colorspace and the pick
-- new colors from the most void areas (on any line). Almost like a Median-cut in reverse.
--
-- Rather than filling the colorcube symmetrically it adds intermediate colors to the existing ones.
--
-- Running this script on the C64 16-color palette might be educational
--
--
--   Source cols#, Expand to #, 
--   Ex: 15-31 means that palette colors 0-15 is expanded to 16 new colors placed at slots 16-31
--
--    Spread mode: OFF - New colors will conform to the contrast & saturation of original colors 
--                       (new colors will stay on the ramps possible from the original colors)
--
--                 ON - New colors will expand their variance by each new addition (mostly notable when adding many new colors)
--                      Will add range lines/ramps to all new colors from old ones, but keep within max/min values of the
--                      original colors. 15-bit mode will dampen the spread towards extreme colors (if starting with low contrast)
--
--  15-bit colors: Higher color-resolution, 32768 possible colors rather than the 4096 of 12bit. Slower but perhaps better. 
--

dofile("../libs/dawnbringer_lib.lua")
--> db.initColorCube
--> db.addColor2Cube
--> db.enableRangeColorsInCube
--> db.findVoid

SHADES = 16 -- Going 24bit will probably be too slow and steal too much memory, so start with 12bit (4096 colors) for now

ini = 0
exp = 255

OK,dummy,ini,exp,linemode,fbit = inputbox("Expand Existing Colors",
                           "Ex: 15/31 doubles cols from 16 to 32", 0,0,0,4,
                           "Source Cols, #0..: #1-254", 15,  1,254,0,
                           "Expand to #: 2-255",        31,  2,255,0,
                           "Spread Mode",   0,  0,1,0,
                           "15-bit Colors", 1,  0,1,0   
);

if (fbit == 1) then SHADES = 32; end



if OK == true then

  cube = db.initColorCube(SHADES, {false,9999})

  -- Define allowed colorspace
  for y = 0, ini-1, 1 do
    r1,g1,b1 = getcolor(y)
    for x = y+1, ini, 1 do
      r2,g2,b2 = getcolor(x)
      db.enableRangeColorsInCube(cube,SHADES,r1,g1,b1,r2,g2,b2)
    end
  end

  div = 256 / SHADES

  -- Fill cube with initial colors
  for n = 0, ini, 1 do
    r,g,b = getcolor(n)
    db.addColor2Cube(cube,SHADES,math.floor(r/div),math.floor(g/div),math.floor(b/div),0.26,0.55,0.19)
  end


  for n = ini+1, exp, 1 do
    r,g,b = db.findVoid(cube,SHADES)

    if (r == -1) then messagebox("Report:","No more colors can be found, exit at "..n); break; end

    mult = 255 / (SHADES - 1)
    setcolor(n, r*mult,g*mult,b*mult)  

    if linemode == 1 then
       -- Add lines from new color to all old  
       for x = 0, n-1, 1 do
          r2,g2,b2 = getcolor(x)
          db.enableRangeColorsInCube(cube,SHADES,r*mult,g*mult,b*mult,r2,g2,b2) -- uses 24bit values rgb
       end
    end
    
    db.addColor2Cube(cube,SHADES,r,g,b,0.26,0.55,0.19) -- rgb is in 'shade' format here 
   
  end

end



