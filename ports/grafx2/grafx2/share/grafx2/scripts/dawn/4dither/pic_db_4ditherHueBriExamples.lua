--PICTURE: 4-Dither System - Hue-Brightness Charts  
--(A set of digrams, use a large image)
--by Richard 'DawnBringer' Fhager
  
-- Screen size is not auto-set

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_4dither.lua")



--LIMIT         = 64 -- Max # of colors in palette
Hue_div       = 48 -- In regards to primaries, it's best to use the sizes 6,12,24,48,96 & 192
Bri_div       = 33
Size          = 20
Gamma         = -2.2 -- Mixcolor gamma
Briweight     = 0.25 
Two_Flag      = false -- Only 2-dithers
Gry_lim       = 0.15
Sat_max       = 1.0
Sat_min       = 0.2
Rating_lim    = 100
-- Saturation factor vs Dither rating, at 100 only highest saturation is used for selecting best dither
-- at 0 only Dither Rating is used.
Sat_factor    = 25 

OK,Hue_div,Bri_div,Size,Sat_max,Sat_min,Gry_lim,Sat_factor,Rating_lim,two_only = inputbox("4-Dither HueBri Chart",
                                   
          "HUE Columns: (6-360)",  Hue_div,  6,360,0, -- In regards to primaries, it's best to use the sizes 6,12,24,48,96 & 192
          "BRI Rows:    (4-256)",  Bri_div,  4,256,0,
          "Size: (2-256 EVEN)",    Size,             2,256,0,
          "Saturation Max: (0-1)",  Sat_max,  0,1,2,
          "Saturation Min: (0-1)",  Sat_min,  0,1,2,
          "Grayscale Limit: (0-1)",       Gry_lim,  0,1,2,
          "Saturation vs Rating %",  Sat_factor,  0,100,0, -- Saturation over Rating, Rating is dither-smoothness (not color-matching)
          "Rating Threshold: (0-100)",  Rating_lim,  0,100,2,
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


 Pal = db.fixPalette(db.makePalList(256),1) -- Sorted Bright to Dark

 if #Pal <= 64 then

  mixpal = d4_.makeRatedMixpal(Pal,Gamma,Two_Flag,false)
 

Scale = 1
lg_siz  = {12,6}
sm_siz  = {14,6}
sm_spc  = {399,196}
sm_ypos = {416,214}
-- Small
 sX = 4
 Bord = 6


d4_.HueBriChart_CONTROL(
  {
  MixPal     = mixpal,			-- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)
  Pal        = nil,			-- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
  Gamma      = nil,			-- Mixcolor gamma value, nominal 2.2
  Two_Flag   = nil,			-- Flag: 2-Dithers only
  Xpos       = 10,			-- Diagram x-position
  Ypos       = 8,			-- Diagram y-position
  Hue_div    = 96,			-- Hue columns
  Bri_div    = 33,			-- Brightness rows
  Size       = lg_siz[Scale],		-- Dither swatches size
  Space      = 0,			-- Spacing between dithers
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
                border          = 10 	-- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
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



-- Hi sat
d4_.HueBriChart_CONTROL(
  {
  MixPal     = mixpal,			-- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)
  Pal        = nil,			-- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
  Gamma      = nil,			-- Mixcolor gamma value, nominal 2.2
  Two_Flag   = nil,			-- Flag: 2-Dithers only
  Xpos       = sX + sm_spc[Scale]*0,	-- Diagram x-position
  Ypos       = sm_ypos[Scale],		-- Diagram y-position
  Hue_div    = 24,			-- Hue columns
  Bri_div    = 25,			-- Brightness rows
  Size       = sm_siz[Scale],		-- Dither swatches size
  Space      = 1,			-- Spacing between dithers
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
                border          = Bord 	-- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
               },

  Sat_max    = 1.0,			-- Maximum Saturation of mixcolors (dithers), 0..1
  Sat_min    = 0.7,			-- Minimum ...
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

-- Medium Sat
d4_.HueBriChart_CONTROL(
  {
  MixPal     = mixpal,			-- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)
  Pal        = nil,			-- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
  Gamma      = nil,			-- Mixcolor gamma value, nominal 2.2
  Two_Flag   = nil,			-- Flag: 2-Dithers only
  Xpos       = sX + sm_spc[Scale]*1,	-- Diagram x-position
  Ypos       = sm_ypos[Scale],		-- Diagram y-position
  Hue_div    = 24,			-- Hue columns
  Bri_div    = 25,			-- Brightness rows
  Size       = sm_siz[Scale],		-- Dither swatches size
  Space      = 1,			-- Spacing between dithers
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
                border          = Bord 	-- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
               },

  Sat_max    = 0.7,			-- Maximum Saturation of mixcolors (dithers), 0..1
  Sat_min    = 0.3,			-- Minimum ...
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

-- Low Sat
d4_.HueBriChart_CONTROL(
  {
  MixPal     = mixpal,			-- *OPTIONAL* MixPal (for multiple diagrams with the same palette f.ex)
  Pal        = nil,			-- Palette list {{r,g,b,i},..}, use DB-lib, Pal = db.fixPalette(db.makePalList(256),1)
  Gamma      = nil,			-- Mixcolor gamma value, nominal 2.2
  Two_Flag   = nil,			-- Flag: 2-Dithers only
  Xpos       = sX + sm_spc[Scale]*2,	-- Diagram x-position
  Ypos       = sm_ypos[Scale],		-- Diagram y-position
  Hue_div    = 24,			-- Hue columns
  Bri_div    = 25,			-- Brightness rows
  Size       = sm_siz[Scale],		-- Dither swatches size
  Space      = 1,			-- Spacing between dithers
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
                border          = Bord 	-- Border around diagram, Does not affect pos/offset. If drawing a fullscreen, image; set position (offset) to size value as Border
               },

  Sat_max    = 0.3,			-- Maximum Saturation of mixcolors (dithers), 0..1
  Sat_min    = 0.15,			-- Minimum ...
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



end -- <= 64

end -- ok
--
-------------------------------------------

  -- mixpal[n].single = true/false, solid single original color
  -- mixpal[n].index = n












