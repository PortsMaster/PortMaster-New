--TEST SCRIPT
--Warning! 4-dither Render is very slow with "larger" palettes, 8 colors work ok. 32 colors will take hours.

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")

--
function f(fx,fy) -- Horizontal Grayscale
    r = fx * 255
    g = fx * 255
    b = fx * 255
    return r,g,b
end
--

--
function f(xf,yf) -- Rainbow Dark-2-Bright
  local S,r,g,b,m
  m = math

   r = 255 * m.sin(yf * 2) 
   g = (yf-0.5)*512 * yf
   b = (yf-0.5)*512 * yf

   r,g,b = db.shiftHUE(r,g,b,xf * 360); 

  return db.rgbcaps(r,g,b)
end
--


Gamma = 2.2 -- MixColor Gamma power (It seems a higher than "normal" (2.2) works best with 4-dither)

Briweight = 0.25 -- Color Distance Brightness weight 0..1, 0 = None, 1 = Only Brightness, ignoring color distances
                     -- Note: This has nothing to do with the dither itself, just the quality we prioritize when matching colors. 
                     -- Dither ratings (distance table) are using a hard (and separate) setting of bw=0.25 right now.        
Dither_Factor = 0.025    -- 0 = Best Colormatch only, any Dither goes. 
                         -- At 1.0 Coursness count as much as colormatching (and will result in only solid colors)
                         -- 0.025 is a good starting point, even 0.01 (1%) can have an impact (avoiding the worst dithers) 
                         -- With Primary 8, grey150 will dither at most 0.78

TWO_FLAG = false

w,h = getpicturesize()

Pal = db.fixPalette(db.makePalList(256),1) 
d4_.renderScene(w,h,0,0,f,Pal,Gamma,Dither_Factor,Briweight,TWO_FLAG)