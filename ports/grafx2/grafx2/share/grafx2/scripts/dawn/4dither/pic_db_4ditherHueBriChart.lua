--PICTURE: 4-Dither System - Hue-Brightness Chart  
--by Richard 'DawnBringer' Fhager

-- Screen size is not auto-set

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")


-- Good sizes for 1200 width
-- 46,32,24 
-- 72,48,16
-- 192,128,6
-- Good sizes for 800 width
-- 96,64,8

--LIMIT         = 64 -- Max # of colors in palette
Hue_div       = 48 -- In regards to primaries, it's best to use the sizes 6,12,24,48,96 & 192
Bri_div       = 33
Size          = 20
Gamma         = -2.2 -- Mixcolor gamma, dynamic mode
Briweight     = 0.25 
Two_Flag      = false -- Only 2-dithers
Gry_lim       = 0.15
Sat_max       = 1.0
Sat_min       = 0.2
Rating_lim    = 100
-- Saturation factor vs Dither rating, at 100 only highest saturation is used for selecting best dither
-- at 0 only Dither Rating is used.
Sat_factor    = 25 

-- Is both a Saturation Factor and Rating Threshold needed?
-- Yes, Rating Threshold allows the choice of keeping or stripping rough dithers in areas where no oher good ones exists.
-- It's possible to set Saturation Factor to 100% and lower the Rating Threshold in order to get colorful and smooth dithers
-- (if using a lower threshold, there's little reason not to use a high saturation factor)
-- However this will also strip rough but desireable dithers in areas (mostly darkest colors) where there's only one option.
-- (This may however be corrected to some degree with a better saturation algorithm)


--roughness = (1-Dither_Factor) * 100
--roughness = 1

OK,Hue_div,Bri_div,Size,Sat_max,Sat_min,Gry_lim,Sat_factor,Rating_lim,two_only = inputbox("4-Dither HueBri Chart",
                                   
          "HUE Columns: 6-360",  Hue_div,  6,360,0, -- In regards to primaries, it's best to use the sizes 6,12,24,48,96 & 192
          "BRI    Rows: 4-256",  Bri_div,  4,256,0,
          "Size: 2-256 (EVEN)",    Size,             2,256,0,
          "Saturation  Max: 0..1",  Sat_max,  0,1,2,
          "Saturation  Min: 0..1",  Sat_min,  0,1,2,
          "Grayscale Limit: 0..1",       Gry_lim,  0,1,2,
          "Saturation vs Rating %",  Sat_factor,  0,100,0, -- Saturation over Rating, Rating is dither-smoothness (not color-matching)
          "Rating Threshold: 0-100",  Rating_lim,  0,100,2,
          "2 Col Dithers Only",                 0,0,1,0
);


--
if OK then

 -- Bri & Sat expects return values of 0-255, Sat 0-5.999...
 Bri_f   = db.getBrightness
 Hue_f   = db.getHUE
 --Sat_f   = db.getAppSaturation
 --Sat_f   = db.getRealSaturation_255
 --Sat_f   = db.getTrueSaturationX
 --Sat_f   = db.getSaturationAbs_255
 Sat_f   = db.getSaturation -- "Problem"? with HSL is that bright-pale colors can be considered hi-sat 
 Shift_f = db.shiftHUE
 
 Mark1dith_Flag = true -- Mark 1 color dithers (the original palette colors)
 Mark2dith_Flag = false

 if two_only == 1 then Two_Flag = true; end

 Spacing = 1
 if Size < 8 then Spacing = 0; end

 Pal = db.fixPalette(db.makePalList(256),1) -- Sorted Bright to Dark
 --mp = d4_.makeRatedMixpal(Pal,2.2,false,false)


d4_.HueBriChart_CONTROL(
  {
  MixPal     = nil,			-- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)

  Pal        = Pal,			-- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
  Gamma      = Gamma,			-- Mixcolor gamma value, nominal 2.2
  Two_Flag   = Two_Flag,		-- Flag: 2-Dithers only

  Xpos       = 8,			-- Diagram x-position
  Ypos       = 8,			-- Diagram y-position
  Hue_div    = Hue_div,			-- Hue columns
  Bri_div    = Bri_div,			-- Brightness rows
  Size       = Size,			-- Dither swatches size
  Space      = Spacing,			-- Spacing between dithers
  Mark1dith_Flag = Mark1dith_Flag,	-- Flag: Mark Solid "Dithers" (Original palette colors) 
  Mark2dith_Flag = Mark2dith_Flag,	-- Flag: Mark two color dithers

  Diagram    = {
                clear_flag      = true, -- Flag: Draw/Clear background
                curves_flag     = true, -- Flag: Draw Brightness curves
                grid_flag       = true, -- Flag: Draw Grid
                bg_value        = 90, 	-- Background (color) grayscale value 
                grid_value      = 87,	-- Grid grayscale value 
                primary_value   = 120, 	-- Primary ([255,0,0] shifted) curve grayscale value
                secondary_value = 75, 	-- Seconary curves grayscale values
                setcols_flag    = true,	-- Flag: Set grayscale values (defined above) in palette (color 252-255)
                border          = 8 	-- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
               },

  Sat_max    = Sat_max,			-- Maximum Saturation of mixcolors (dithers), 0..1
  Sat_min    = Sat_min,			-- Minimum ...
  Gry_lim    = Gry_lim,			-- Grayscale Saturation limit 0..1, all dithers below this value are eligable for grayscale ramp

  Sat_factor = Sat_factor,		-- Saturation vs Dither rating (smoothness) when selecting dither for a given slot (if there's more than one candidate)
                                        -- 0% = Pick the best (smoothest) dither, 100% = pick the color with highest allowed saturation, nom = 25%
  
  Rating_lim = Rating_lim,		-- Dither Rating Threshold: only allow dithers with a rating of or below this value (0-100(worst))
 					-- 50 = remove the junk, 25 = keep all decent, 10 = Only the best, 0 = Just original solid colors

  Hue_f      = Hue_f,			-- Hue function (r,g,b)-->(r,g,b),      ex. db.getHUE 
  Sat_f      = Sat_f,			-- Saturation function (r,g,b)-->0-255, ex. db.getAppSaturation
  Bri_f      = Bri_f,			-- Brightness function (r,g,b)-->0-255, ex. db.getBrightness
  Shift_f    = Shift_f			-- HueShift func (r,g,b,deg)-->(r,g,b), ex. db.shiftHUE
  }
)


end -- ok
--
-------------------------------------------

  -- mixpal[n].single = true/false, solid single original color
  -- mixpal[n].index = n












