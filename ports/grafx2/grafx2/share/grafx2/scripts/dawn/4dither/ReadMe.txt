4-Dither System:

A collection of scripts exploring the nature of four-color matrix dithering, 
a higher order of two-color mixdithering. A classic (2-color) mixdither is a subset of a 4-Dither.

The 2x2 matrix has the format:

24
31

Where the numbers indicate colors in order brightness, 1 = Brightest color, 4 = Darkest color.


An outstanding and very central problem is quantifying the percieved color of a given dither.
Basic gamma-correction does not suffice here. I intuitively developed a formula using
"dynamic gradient gamma" that seem to produce very accurate results (examples in \images), 
but a solid scientific understanding still eludes me.


Most scripts are limited to 32 color palettes beacuse of the exponentially growing number of dithers.

-- Unique 4-color dithers
--   4 colors:          35
--   7 colors:         210 (Highest number possible when adding MixCols to palette)
--   8 colors:         330
--  10 colors:         715
--  11 colors:       1.001 
--  16 colors:       3.876 (2-mix = 136 combos)
--  21 colors              (2-mix = 231 combos => 252 colors with original + mixcolors)
--  22 colors              (2-mix = 253 combos)
--  32 colors:      52.360 (2-mix = 528 combos)
--  48 colors:     249.900
--  64 colors:     766.480
-- 128 colors:  11.716.640
-- 256 colors: 183.181.376  (out of memory)

/Richard Fhager

