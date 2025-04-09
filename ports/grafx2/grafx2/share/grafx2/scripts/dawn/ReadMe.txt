ToolBox V1.4 (+200 Lua-scripts for GrafX2 by Richard 'DawnBringer' Fhager, December 2017)

----
INSTALLATION:
Place the directory "dawn" with its content anywhere (it should work), 
but preferably in GrafX2\share\grafx2\scripts.
Note: On Mac/OSX the "script" dir is found at "Contents\Resources\scripts\" 

Most scripts should be runnable on their own, but most easily accessed 
via the ToolBox menu-script: _DBTOOLBOX.lua (assign it to a key, I use [alt-1])
_DBTOOLBOX.lua is found in the \scripts dir.

The GrafX2 program can be downloaded from:
http://pulkomandy.tk/projects/GrafX2/downloads
These scripts have been developed on and work well with the windows version 2.4.2035
----


----
USING SCRIPTS IN GRAFX2:
1. Right-Click the "Brush-Factory" button (middle of 2nd row, left of the text-button)
2. Select your script and double-click or press "run"-button.

Key Scripts:
Also note that there is a selection of "key-scripts" which are meant to be assigned to keys ONLY.
These typically work with the mousepointer-position and performs functions such as dither fills and brush grabbing etc.
These scripts are found in "\key": 

bru_db_ColorAreaGrab.lua	-- Grabs a brush from the floodfilled area of color under the mouse-pointer
bru_db_MagicBrushGrab.lua	-- Grabs a brush of the image under the mouse-pointer (that is not bg-col)
bru_db_MagicBrushGrab_remove.lua-- Same as MagicBrushGrab, but removes the grabbed gfx from the image (Sprite move)
col_db_FindColorBRIGHT92.lua	-- Selects the next brighter color in the palette, from the current pen-color
col_db_FindColorDark92.lua	-- Selects the next darker color in the palette, from the current pen-color
pic_db_checkDitherPenColor.lua	-- Dithers all image instances of the color under the mouse-pointer with current pen-color
pic_db_floodDither.lua		-- Dither floodfills the area/color under the mouse-pointer with current pen-color
pic_db_floodInline.lua		-- "Outlines" the inside of the area/color under the mouse-pointer using current pen-color
----


----
ASSIGNING KEYS: 
1. Open Brush-Factory
2. Select a script
3. Click the bottom-row in bottom window "Key: none"
4. Click one of the big "None"-buttons
5. Now press the key or key-combo you want to assign.
---- 


 ----
 EFFECT FOCUS:
 If an asterisk '*' is visible on the [Palette] button both pen-colors are set to the same index (FG=BG,Pen1=Pen2).
 The appearing [*Focus OFF] button will change the Pen-color to the next index (and thus deactivating effect focus).
 What is Effect focus?
 Some palette manipulating scripts have an EFFECT FOCUS feature where the impact 
 of the operator may be centered at a Hue, Brightness and/or Saturation region of colorspace.
 F.ex you can limit a color-adjustment to affect mostly RED colors by setting Hue to 0 (degrees)
 This feature is by default inactive (-1 = off). 
 BUT, if the two pen-colors in the GrafX2 interface is set to the same color-index (as they are at start-up)
 THIS COLOR WILL BE LOADED AS THE EFFECT-FOCUS VALUES! (indicated by '*' before HUE/BRI/SAT)
 So, if nothing happens or you get odd results when running a palette-tweaking script; this is probably the reason.
 ---


----
Categories of the Toolbox (and what the scripts in them predominantly can and/or will do)

>COLOR: 
 * Change individual palette colors
 * Set Pen-color
 * Perform analysis of a single or a pair of colors (output can be brushes, text or image)

>BRUSH:
 * Manipulate the current user brush
 * Provide info about the current brush

>PALETTE:
 * Load preset palettes and colorspaces
 * Adjust the current palette colors
 * Expand palette and various colorspace operations
 * Palette manipulations such as: sorting, fusing, distorting etc.
 * Analyze palette and generate diagrams
 * Output palette as various brushes and tables
 * Generate and apply ramps via different methods

>IMAGE:
 * Image size presets & modifications
 * Image optimizations and palette reductions
 * Remapping methods
 * Filter applications (convolutions, structures, voronoi, fractal splits, patterns, noise etc.)  
 * Buffer processing (blending methods and index operations between main and spare image)
 * Image Distortions (rotation, waves etc.)
 * C64-compatbility testing and retro-format conversions

>SCENE:
 Scene is an umbrella category that includes scripts that...
 * May change/affect more than one thing, or anything (color/palette/brush/image)
 * Generate content (ex: fractals, complex patterns, procedurals)

>ANIM:
 Anims are scripts that update and play content over time,
 and like Scenes they may change anything.
 * Demos
 * Sprite-sheet players

>MISC:
 * Various stuff that didn't fit in any of the above categories very well
 * Old and/or experimental scripts
----


----
SCRIPT OUTPUT INDICATORS:
 Letters inside parentheses () on the script-buttons in the Toolbox indicate what that script
 may affect/change/output, as a kind warning to the user.
 a = Anim
 b = Brush
 c = Color (in the palette)
 i = Image
 l = Layer
 n = Pen (currently selected palette index)
 p = Palette
 t = Text (messagebox)
 
Leading Indicators:
 '.' = (Point) means it's a memory script (uses the memory.lua library) which remembers the last input-settings.  
 '#' = Interactive script/program (a more complex type of script)
----


----
FILE NAME SYNTAX:
The syntax for basic standalone scripts is [output_author_name.lua]
Author: initals or short name of script author (in my case "db" for DawnBringer)
  Name: Name of script (function/description)
Output: Specification of what the script will affect/change/create/display...
ani = Animation/Demo, may change anything and everything as animation is a subset of Scene
bru = Brush
col = Single color or Pen-index (feel free to use 'pen' to specify index changers in your own scripts)
fil = Creates a file
inf = Text prompt / Message (info)
pal = Palette
pic = Picture
scn = Scene, may change any number of things things. Also used for scripts that produces content; fractals etc.
(lyr = Layer(s))
(pen = Pen index)
----

Thanks to everyone who contributed with ideas and betatesting!
Special thanks to Yves 'Yrizoud' Rizoud for his scale2x script (bru_yr_Scale2x.lua).


Send your bugreports, questions or ideas/suggestions to:

Richard 'DawnBringer' Fhager
dawnbringer@hem.utfors.se alt. dawnbringer@bahnhof.se
Or visit my PixelJoint profile where you can find a link to the ToolBox-thread in the forum:
http://pixeljoint.com/p/23821.htm


The GrafX2 project page is currently:
http://pulkomandy.tk/projects/GrafX2



