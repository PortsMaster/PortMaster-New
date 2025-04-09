--TOOLBOX V1.4 MAIN SCRIPT
--by Richard 'DawnBringer' Fhager

TITLE = "TOOLBOX v1.4"


function matchcolor2_missing()
 messagebox("Sorry, your version of GrafX2 is not compatible with this script. The function 'colormatch2()' is missing.")
 do return end
 --error() 
 end

if (type(matchcolor2) ~= 'function') then
 matchcolor2 = matchcolor2_missing
end

exc = dofile

if (type(run) == 'function') then
 exc = run
end


--exc("../libs/dawnbringer_lib.lua")
-- Once the library is loaded, the individual scripts will work without loading it themselves



function sf_pal_adjust()
 selectbox("Palette Adjust"..FOCUS_NOTE,   
    "Contrast/Brightness (c,p)", function () exc("pal_db_Contrast.lua"); end,
    "Natural Brightness (c,p)",  function () exc("pal_db_BriNatural.lua"); end, --A4
    "Color Balance (p)",         function () exc("pal_db_ColorBalance.lua"); end,
    "Make GrayScale (c,p)",      function () exc("pal_db_GrayscaleMethods.lua");end,
    "Hue / Lightness (c,p)",     function () exc("pal_db_HueLightness.lua"); end,
    "Super Saturation (c,p)",    function () exc("pal_db_SuperSaturation.lua"); end,
    "Gamma Adjust (c,p)",        function () exc("pal_db_GammaAdjust.lua"); end,
    "Multiply (c,p)",            function () exc("pal_db_Multiply.lua"); end,
    "Fade 2 Color (p)",          function () exc("pal_db_Fade.lua"); end, --A4
    --"Apply ColorRamps (p)",    function () exc("pal_db_ApplyRamp.lua"); end,
    --"Complementary Colors (p)",function () exc("pal_db_ComplementaryPalette.lua"); end,
    "[Back]", sf_palette
 );
end

function sf_pal_rampmod()
 selectbox("Palette Ramps & Modifiers",
    "Gradient Methods (p)",   function () exc("../gradients/pal_db_PencolGradientMethods.lua"); end, 
    "Curved ColorRamps (p)",   function () exc("pal_db_CurveRamps.lua"); end,   
    "Apply ColorRamps (p)",    function () exc("pal_db_ApplyRamp.lua"); end,      --A4
    "Apply Spare Palette (p)", function () exc("pal_db_ApplySparePal.lua"); end,  --A4
    "Apply Color (p)",         function () exc("pal_db_ApplyColor.lua"); end,     --A4
    "Swap Color Channels (p)", function () exc("pal_db_SwapChannels.lua"); end,   --A4
    "Complementary Colors (p)",function () exc("pal_db_ComplementaryPalette.lua"); end,
    "[Back]", sf_palette
 );
end


function sf_pal_preset()
 selectbox("Palette Presets",
    "DawnBringer Palettes (p)",      function () exc("pal_db_SetDBpalettes.lua"); end,
    "Custom Palettes (p)",           function () exc("pal_db_SetCustomPalettes.lua"); end,
    "C64 Palettes [16] (p)",         function () exc("pal_db_SetC64Palette.lua"); end,
    "Hardware Palettes (p)",         function () exc("pal_db_SetHardwarePalettes.lua"); end,
    "Set BitSpace / Shades (p)",     function () exc("pal_db_SetColorSpaces.lua"); end, 
    "Preset RGB-Levels (p)",         function () exc("pal_db_SetRGBlevels.lua"); end,
    --"Preset Gradients (p)",          function () exc("../gradients/pal_db_PresetGradients.lua"); end, --A4
    "#Gradient Manager (p)",         function () exc("../gradients/pal_db_GradientManager.lua"); end, --A4  
    --"Scenery pal [256] (p)",         function ()  db.setSceneryPalette(); end,
    "[Back]", sf_palette
 );
end

function sf_pal_2brush()
 selectbox("Palette To Brush", 
    "PalTable w/ Hex-values (i)", function () exc("pic_db_PaletteTablePJ.lua"); end,  --V4
    "Palette as Brush (b)",       function () exc("bru_db_Palette2Brush.lua"); end,
    "Histogram as Brush (b)",     function () exc("bru_db_Histogram2Brush.lua"); end,
    "MixColor Table (b)",         function () exc("bru_db_MakeMixColorTable.lua"); end,
    "[Back]", sf_palette
 );
end

function sf_pal_analyze()
 selectbox("Palette Analyze & Info",
    "Analyze Palette (i)",          function () exc("pic_db_AnalyzePalette18.lua"); end,   
    "Palette Statistics (t)",       function () exc("inf_db_PaletteStats.lua"); end,
    "Compare Colors (t)",           function () exc("inf_db_CompareColors.lua"); end,  
    "Find Duplicates (i)",          function () exc("pic_db_FindPaletteDoubles.lua"); end,
    "Gradient Analyze (i)",         function () exc("../gradients/pic_db_GradientAnalyze.lua"); end, --A4
    "Gamma Adj. Gradients (i)",     function () exc("pic_db_GammaGradients.lua"); end, --A4
    "[Back]", sf_palette
 );
end

function sf_pal_diagrams() -- a4
 selectbox("Palette Diagrams",   
   "Solid Bri-Hue Diagram (i)",   function () exc("pic_db_DrawBriHueDiagram.lua"); end,
   "Plot Bri-Hue Diagram (i)",    function () exc("pic_db_PlotBriHueDiagram.lua"); end,
   "Polar Bri-Hue Diagrams (i)",  function () exc("pic_db_PolarBriHueDiagrams.lua"); end,
   "Bri-Match Diagram (i)",       function () exc("pic_db_DrawBriMatchDiagram.lua"); end,
   "Hue-Saturation Diagram (i)",  function () exc("pic_db_HueSaturationDiagram.lua"); end,
   "Complementaries/Desat (i)",   function () exc("pic_db_ComplementaryDiagram.lua"); end,
   "IsoCube Diagrams (i)",        function () exc("pic_db_IsoCubesRGB_Diagram.lua"); end,
   "[Back]", sf_palette
 );
end

function sf_pal_optimize()
 selectbox("Palette Redux & Optimize",  
    "Remove Color & Remap (i,p)",  function () exc("scn_db_RemoveColor.lua"); end,  
    "MedianCut Redux (i,p)",       function () exc("scn_db_MedianCut.lua"); end,
    "DistSlice Redux (i,p)",       function () exc("scn_db_DistSlice.lua"); end, 
    "Optimize Colors (i,p)",       function () exc("scn_db_NewOptimize4.lua"); end,
    "Reduce (Rare) Cols (i,p)",    function () exc("scn_db_RemoveRarePixels.lua"); end, 
    "[Back]", sf_palette
 );
end

function sf_pal_specialops()
 selectbox("Palette Special Ops",   
    ">COLOR SPACE", sf_pal_colorspace,  
    ">TO BRUSH", sf_pal_2brush,     								-- m4
    "SuperSort (p)",                 function () exc("pal_db_SuperSort6.lua"); end,
    "Fuse Palettes  (p,i)",          function () exc("scn_db_FusePals.lua"); end, 
    "Random Palette (p)",            function () exc("pal_db_RandomPalette.lua"); end, 
    "Distort Palette (p)",           function () exc("pal_db_DistortPalette.lua"); end,
    "Shuffle Palette (p)",           function () exc("pal_db_ShufflePal.lua"); end,
    "Assign Spare 2 Main (p)",       function () exc("pal_db_AssignPalette.lua"); end, 
    "[Back]", sf_palette
 );
end


function sf_pal_colorspace()
 selectbox("Palette Colorspace",
    "Posterize (p)",             function () exc("pal_db_Posterize.lua"); end,
    "Set RGB-Scale (p)",         function () exc("pal_db_SetRGBscale.lua"); end,
    "Custom RGB-Levels (p)",     function () exc("pal_db_CustomRGBlevels.lua"); end,   
    "Expand Colors (p)",         function () exc("pal_db_ExpandColors2.lua"); end,
    "Fill ColorCube (p)",        function () exc("pal_db_FillColorCube3.lua"); end,
    "ColorCigarr (p)",           function () exc("pal_db_ColorCigarr.lua"); end,
    "[Back]", sf_pal_specialops
 );
end

function sf_palette()
  selectbox("Palette",      
    ">ADJUST"..FOCUS_NOTE,    sf_pal_adjust,
    ">PRESETS",               sf_pal_preset,  
    ">ANALYZE & INFO",        sf_pal_analyze,
    ">DIAGRAMS",              sf_pal_diagrams,
    ">REDUX & OPTIMIZE",      sf_pal_optimize,
    ">RAMPS & MODIFIERS",     sf_pal_rampmod,                 
    ">SPECIAL OPS",           sf_pal_specialops, 
    "3D Palette Viewer (a,i)",        function () exc("ani_db_3DPalette.lua"); end, 
    --"Reduce (Rare) Cols (i,p)",   function () exc("scn_db_RemoveRarePixels.lua"); end,      
    --"SuperSort (p)",                function () exc("pal_db_SuperSort6.lua"); end,
    "[Back]", main
 );
end
-- palette

function sf_brush_adjust()
  selectbox("Brush Adjust",
    "Make GrayScale (b)",      function () exc("bru_db_GrayscaleMethods.lua");end,
    "Super Saturation (b)",    function () exc("bru_db_SuperSaturation.lua"); end,
    "Color Balance (b)",       function () exc("bru_db_ColorBalance.lua"); end,
    "Contrast/Brightness (b)", function () exc("bru_db_Contrast.lua"); end,
    "Hue / Lightness (b)",     function () exc("bru_db_HueLightness.lua"); end,
    "Make Negative (b)",       function () exc("bru_db_Negative.lua"); end,
    "[Back]", sf_brush
 );
end
-- brush

function sf_brush_distort()
  selectbox("Brush Distortions",
    "Rotation (i/b)",             function () preBRU=1; prePIC=0; exc("scn_db_Rotation.lua"); end,
    "Waves (i/b)",                function () preBRU=1; prePIC=0; exc("scn_db_Waves4.lua"); end,
    "FishEye (b)",                function () preBRU=1; prePIC=0; preMOD=0; exc("scn_db_FishEye_Radial.lua"); end,
    "Collapse (b)",               function () preBRU=1; prePIC=0; preMOD=1; exc("scn_db_FishEye_Radial.lua"); end,
    "[Back]", sf_brush
 );
end
-- distort


function sf_brush_specops()
  selectbox("Brush Special Operations",
    "Extract PenColor (b)",    function () exc("bru_db_ExtractPenColor.lua"); end,
    "Apply PenColor (b)",      function () exc("bru_db_ApplyColor.lua");end,
    "Smart Outline WIP (b)",   function () exc("bru_db_SmartOutline.lua");end,
    "[Back]", sf_brush
 );
end
-- specops

function sf_brush_borders()
  selectbox("Brush Borders & Trimming",
    "Crop Margins (b)",        function () exc("bru_db_CropMargins.lua"); end,
    "Trim (b)",                function () exc("bru_db_Trim.lua"); end, -- A4
    "Add Brush Border (i)",    function () preBRU=1; prePIC=0; exc("pic_db_AddBorder.lua"); end, -- A4
    "[Back]", sf_brush
 );
end
--

function sf_brush_scaling() -- A4
  selectbox("Brush Scaling",
    "Scale Simple (b)",       function () exc("bru_db_BrushScaleSimple.lua"); end, -- U4
    "Scale2x Algorithm (b)",  function () exc("bru_yr_Scale2x.lua"); end,
    "Scale Advanced (b)",     function () exc("bru_db_AdvancedScaling.lua"); end,
    "Scale Bicubic (b)",      function () exc("bru_db_ScaleBicubic.lua"); end, -- A4
    --"(UberRotScale) (b)",     function () exc("bru_db_uberRotScale.lua"); end,
    --"Scale Matrix (b)",       function () exc("bru_db_ScaleBrush3.lua"); end,
    "[Back]", sf_brush
 );
end
--

function sf_brush()
  selectbox("Brush",
    ">ADJUST", sf_brush_adjust,
    ">SCALING", sf_brush_scaling,
    ">DISTORTIONS", sf_brush_distort,    
    ">SPECIAL OPS", sf_brush_specops,  
    ">BORDER & TRIM", sf_brush_borders,    
    "Brush Info (t)",          function () exc("inf_db_BrushInfo.lua"); end,
    "Brush 2 Image (i)",       function () exc("pic_db_Brush2Picture.lua"); end,
    "[Back]", main
 );
end
-- brush




function sf_img_optimize()
  selectbox("Image Optimize & Remap",       
  "Reduce (Rare) Cols (i,p)",   function () exc("scn_db_RemoveRarePixels.lua"); end,
  "MedianCut Redux (i,p)",      function () exc("scn_db_MedianCut.lua"); end,
  "DistSlice Redux (i,p)",      function () exc("scn_db_DistSlice.lua"); end, 
  "Optimize Colors (i,p)",      function () exc("scn_db_NewOptimize4.lua"); end,
  "RGB Dither Remap (i,p)",     function () exc("scn_db_RGBdither.lua"); end, --A4
  "Dithers Remapping (i,p)",    function () exc("scn_db_miDitherRemap.lua"); end,
  "MixDither Remap (i,p)",      function () exc("scn_db_SpareRemapX.lua"); end,
  "Remove Color & Remap (i,p)", function () exc("scn_db_RemoveColor.lua"); end,
  --"Remove Stray Pixels (i)",    function () exc("pic_db_RemoveIsolated.lua"); end, -- moved to convolutions
  --"Replace FG Col /w BG (i)",   function () exc("pic_db_ReplaceColor.lua"); end, 
  "[Back]", sf_image
 );
end
-- img_optimize

--
function sf_img_filters_structure()
  selectbox("Image Structured Filters",
    "Voronoi Crystallize (i)",    function () exc("pic_db_VoronoiCrystallize.lua"); end, -- A4
    "Shape Filters (i)",          function () exc("pic_db_ShapeRenders.lua"); end,
    "Disc Filter (i)",            function () exc("pic_db_DiscRender.lua"); end, -- A4
    "Fractal Split Filter (i)",   function () exc("pic_db_FractalSplit.lua"); end, 
    "Square Filter (i)",          function () exc("pic_db_SquareFilter.lua"); end,  -- U4
    "Quad Split Redux (i)",       function () exc("pic_db_QuadSplitRedux.lua"); end, -- A4  
    "Field Gradient (i)",         function () exc("pic_db_FieldGradient.lua"); end,  -- A4 (Also in Scenes/Tiling&Patterns))  
    "[Back]", sf_img_filters
 );
end
-- img_filters_structure

--
function sf_img_filters_convos() -- A4
  selectbox("Image Convolutions",
    "Sharpen Edges (i)",          function () exc("pic_db_EdgeSharpen.lua"); end, -- A4
    "Max/Min Edge Detection (i)", function () exc("pic_db_EdgeMaxMin.lua"); end, -- A4
    "Sobel Edge Detection (i)",   function () exc("pic_db_Sobel.lua"); end, -- A4
    "Color Convolutions (i)",     function () exc("pic_db_ColorConvolutions.lua"); end,
    "Emboss (Conv.) (i)",         function () exc("pic_db_Conv_Emboss.lua"); end,
    "Remove Stray Pixels (i)",    function () exc("pic_db_RemoveIsolated.lua"); end,
    "[Back]", sf_img_filters
 );
end
-- img_filters_convos

--
function sf_img_filters_pattern() -- A4
  selectbox("Image Patterns",
    "Character Patterns (i)",        function () exc("pic_db_CharacterPatterns.lua"); end, -- A4
    ".Matrix Patterns (i)",          function () exc("pic_db_DotMatrixMEM.lua"); end, -- A4
    "Box Pattern (i)",               function () exc("pic_db_BoxPattern.lua"); end, -- A4
    "Scanline Variations (i)",       function () exc("pic_db_ScanlineVariations.lua"); end,
    "Grids (i)",                     function () exc("pic_db_Grids.lua"); end, -- Also in Scenes
    "[Back]", sf_img_filters
 );
end
-- img_filters_convos

--
function sf_img_filters_various() -- A4
  selectbox("Image Various Filters",
   "Max & Min Filters (i)",      function () exc("pic_db_MaxMin.lua"); end,
   "Max & Min Radial (i)",       function () exc("pic_db_MaxMinRadial.lua"); end,  -- A4
   "Distort Pixels (i)",         function () exc("pic_db_DistortPixels.lua"); end, 
   "Shift RGB (i)",              function () exc("pic_db_ShiftRGB.lua"); end, 
    "[Back]", sf_img_filters
 );
end
-- img_filters_convos


function sf_img_filters()
  selectbox("Image Effects & Filters",
    ">STRUCTURED FILTERS", sf_img_filters_structure,
    ">CONVOLUTIONS", sf_img_filters_convos,
    ">VARIOUS", sf_img_filters_various,
    ">PATTERNS", sf_img_filters_pattern,
    "Threshold & GradMap (i)",    function () exc("pic_db_Threshold.lua"); end,
    "Scanlines/Fade (i)",         function () exc("pic_db_Scanlines.lua"); end,
    "Add Noise (i)",              function () exc("pic_db_AddNoiseGauss.lua"); end, -- A4
    "[Back]", sf_image
 );
end
-- img_filters

function sf_img_process()
  selectbox("Image Buffer Processing",
     "Blenders (i,p)",             function () exc("scn_db_Blenders.lua"); end,
     "RubThru PenColor (i)",       function () exc("pic_db_RubthruPencolor.lua"); end,  
     "Apply Spare (Tint etc) (i)", function () exc("pic_db_ApplySpare.lua"); end,
     "Spare Index Operations (i)", function () exc("pic_db_SpareOperations.lua"); end,
     "Alpha Filter (i)",           function () exc("pic_db_Alpha1.lua"); end,   
    "[Back]", sf_image
 );
end
-- img_effects

function sf_img_distort_radial()
  selectbox("Radial Distortions",       
    "#Formula Distortion (i)",  function () exc("pic_db_DistortFormula.lua"); end, -- A4
    "#Alpha Distortion (i)",    function () exc("pic_db_DistortAlpha.lua"); end, -- A4
    "Distortion Mapping (i)",   function () exc("pic_db_DistortMap.lua"); end, -- A4
    "FishEye & Collapse (i)",   function () preBRU=0; prePIC=1; preMOD=0; exc("scn_db_FishEye_Radial.lua"); end, -- U4
    "[Back]", sf_img_distort
 );
end
-- img_distort

function sf_img_distort()
  selectbox("Image Distortions",
    ">RADIAL DISTORTIONS", sf_img_distort_radial,
    "Rotation (i/b)",           function () exc("scn_db_Rotation.lua"); end, -- U4
    "Twirl (i)",                function () exc("pic_db_Twirl.lua"); end, -- U4
    "Waves (i/b)",              function () exc("scn_db_Waves4.lua"); end, -- U4
    "Pan & Zoom (i)",           function () exc("pic_db_PanZoom.lua"); end, -- A4
    --"#Formula Distortion (i)",  function () exc("scn_db_DistortFormula.lua"); end, -- A4
    --"#Alpha Distortion (i)",    function () exc("scn_db_DistortAlpha.lua"); end, -- A4
    --"Distortion Mapping (i)",   function () exc("scn_db_DistortMap.lua"); end, -- A4
    --"FishEye & Collapse (i)",   function () preBRU=0; prePIC=1; preMOD=0; exc("scn_db_FishEye_Radial.lua"); end, -- U4
    ----"Collapse (i)",             function () preBRU=0; prePIC=1; preMOD=1; exc("scn_db_FishEye_Radial.lua"); end,
    "Shuffle (i)",              function () exc("pic_db_Shuffle.lua"); end,
    "[Back]", sf_image
 );
end
-- img_distort

function sf_img_specop()
  selectbox("Image Special Ops",     
    "C64 test (t,i)",            function () exc("pic_db_TestC64.lua"); end,
    "Retro Formats (i,p)",       function () exc("scn_db_RetroFormats.lua"); end,
    "Altitude Mapping (i)",      function () exc("pic_db_AltitudeMapping.lua"); end,
    "Ordered Gradient Remap (i)",function () exc("pic_db_OrderedGradientRemap.lua"); end, --A4
    "Fill Color w/ Brush (i)",   function () exc("pic_db_FillColorWithBrush.lua"); end,
    "DropShadow & Glow (i,l)",   function () exc("pic_db_Dropshadow_n_Glow.lua"); end,
    "[Back]", sf_image
 );
end
-- img_draw

function sf_image()
  selectbox("Image",
    ">OPTIMIZE & REMAP", sf_img_optimize,    
    ">EFFECTS & FILTERS", sf_img_filters,
    ">BUFFER PROCESSING", sf_img_process,  
    ">DISTORTIONS", sf_img_distort,
    ">SPECIAL OPS", sf_img_specop,
    "Set Image Size (i)",        function () exc("pic_db_SetImageSize.lua"); end,
    "Image 2 Brush (b)",         function () exc("bru_db_Picture2Brush.lua"); end,
    "Add Image Border (i)",      function () exc("pic_db_AddBorder.lua"); end, -- A4
    "Image Statistics (t)",      function () exc("inf_db_ImageStats.lua"); end,
    "[Back]", main
 );
end
-- image


function sf_color()
  selectbox("Color",      
  "Show AA Colors (b)",          function () exc("bru_db_FindAA6.lua"); end,
  "Show Closest Colors (b)",     function () exc("bru_db_FindClosestColors.lua"); end,
  "Find AA Color (n)",           function () exc("col_db_FindAA.lua"); end,
  "Find Best ColorMatch (n)",    function () exc("col_db_FindBestMatch.lua"); end,
  ".Find Bri/Dark Color (n)",    function () exc("col_db_FindColor.lua"); end,
  "Color Balance (c)",           function () exc("col_db_ColorBalance.lua"); end,
  "Color Info (t)",              function () exc("inf_db_ColorInfo.lua"); end,
  "PenColors Info (t)",          function () exc("inf_db_PenColsInfo.lua"); end,
  ".Color Diagram (b)",          function () exc("bru_db_ColorAnalysisMEM.lua"); end,
 
  --"Make Compliment. Col. (p)", function () exc("pal_db_ComplimentaryColor.lua"); end,
  "[Back]", main
 );
end
-- color


-- SCENES, ANIM & MISC Sub-directories are not labelled with category prefixes ('Scene', 'Anim', 'Misc') 


function sf_scn_lsystem()
  selectbox("L-system",  
  ">CONTINOUS CURVES", sf_scn_lsystem_dir1,
  ">PLANTS & STRUCTURES", sf_scn_lsystem_dir2,
  "[Back]", sf_scene
 );
end
-- lsystem

function sf_scn_lsystem_dir1()
  selectbox("L-system: Curves",  
  "Dragon Curve (i,p)",        function () exc("scn_db_Lsys-Dragon.lua"); end,
  "Levy C Curve (i)",          function () exc("scn_db_Lsys-Ccurve.lua"); end,
  "Hilbert Curve (i)",         function () exc("scn_db_Lsys-Hilbert.lua"); end,
  "Peano-Gosper Curve (i,p)",  function () exc("scn_db_Lsys-Gosper.lua"); end,
  "Koch Snowflakes (i)",       function () exc("scn_db_Lsys-Koch.lua"); end,
  "Sierpinsky Arrowhead (i)",  function () exc("scn_db_Lsys-Arrowhead.lua"); end,
  "[Back]", sf_scn_lsystem
 );
end
-- lsystem_dir1

function sf_scn_lsystem_dir2()
  selectbox("L-system: Plants",  
  "Plant 1 (i,p)",        function () exc("scn_db_Lsys-Plant1.lua"); end,
  "Plant 2 (i,p)",        function () exc("scn_db_Lsys-Plant2.lua"); end,
  "Plant 3 (i,p)",        function () exc("scn_db_Lsys-Plant3.lua"); end, -- A4
  "Big Whisper 2 (i,p)",  function () exc("scn_db_Lsys-BigWhisper2.lua"); end, -- A4
  "Islands & Lakes (i)",  function () exc("scn_db_Lsys-Islands.lua"); end,
  "DB's Octaroots (i,p)", function () exc("scn_db_Lsys-Octaroots.lua"); end,
  "[Back]", sf_scn_lsystem
 );
end
-- lsystem_dir2


function sf_scn_cloudnoise()
  selectbox("Clouds & Noise",  
  "Cloud Fractal Presets (i)",  function () exc("pic_db_CloudFractal_Presets.lua"); end,  --A4
  "Cloud Fractal (i)",          function () exc("pic_db_CloudFractal.lua"); end,          --A4
  "Color Clouds (i,p)",         function () exc("scn_db_FractalCloud.lua"); end,          --u4
  "Perlin Noise (i)",           function () exc("pic_db_PerlinNoise.lua"); end,           --A4
  "#LANDSCAPER (i,p)",          function () exc("../landscaper/scn_db_Landscaper.lua"); end, --A4
  "[Back]", sf_scene
 );
end
-- scn_cloudnoise

function sf_scn_fractal()
  selectbox("Fractals",  
  "Menger Sponge (a,i,p)",      function () exc("ani_db_ObliqueSpongeRec.lua"); end,        --A4
  "Fractal Tree (a,i,p)",       function () exc("ani_db_FractalTree.lua"); end,             --A4
  ".Mandelbrot (i/b)",          function () exc("bru_db_MandelbrotMEM.lua"); end,           --f4
  ".Smooth Mandelbrot (i)",     function () exc("scn_db_MandelbrotSmooth.lua"); end,        --A4
  "Fractal Fern (i,p)",         function () exc("scn_db_Fern256.lua"); end,
  "Fractal Patterns (i)",       function () exc("pic_db_FractalPatterns.lua"); end,
  "[Back]", sf_scene
 );
end
-- scn_fractal

function sf_scn_tiling() -- A4
  selectbox("Tiling & Patterns",
  "Voronoi 3D+ Render (i)",     function () exc("scn_db_Voronoi3DRenderOptimized.lua"); end,  --A4 
  "Voronoi 2D FillRender (i)",  function () exc("scn_db_VoronoiFillRender.lua"); end,  --A4
  "Voronoi Diagram (i)",        function () exc("scn_db_VoronoiDiagram.lua"); end,  --A4
  "Field Gradient (i)",         function () exc("pic_db_FieldGradient.lua"); end,  --A4
  "Hexagonal Pattern (i)",      function () exc("pic_db_HexagonalPattern.lua"); end, 
  "[Back]", sf_scene
 );
end
-- scn_tiling

function sf_scn_gradients() -- A4
  selectbox("Gradients & Alphas",
  "Linear Dith. Gradients (i)",      function () exc("../gradients/pic_db_OrderedGradientsLinear.lua"); end,  --A4 
  "Radial Dith. Gradients (i)",      function () exc("../gradients/pic_db_OrderedGradientsRadial.lua"); end,  --A4 
  "#Alpha Channel Manager (i)",      function () exc("pic_db_AlphaManager.lua"); end, -- A4
  "Backdrop Gradient (i)",           function () exc("pic_db_Backdrop_fs.lua"); end,
  "Gradient Analyze (i)",            function () exc("../gradients/pic_db_GradientAnalyze.lua"); end, --A4 (Also under Pal/Analyze))
  "[Back]", sf_scene
 );
end
-- scn_gradients



function sf_scn_shapes()
  selectbox("Draw Shapes & Grids", 
    "Composition Helper (i)",     function () exc("pic_db_CompositionHelper.lua"); end, 
    ".Draw Geometric Shapes (i)", function () exc("pic_db_GeometricShapes.lua"); end,  
    "Grids (i)",                  function () exc("pic_db_Grids.lua"); end,
    "Draw Spirals (i)",           function () exc("pic_db_Spirals.lua"); end, 
    "Draw Fractal String (i)",    function () exc("pic_db_FractalString.lua"); end,           
    "[Back]", sf_scene
 );
end
-- scn_draw


function sf_scn_fscenery()
  selectbox("Rendered Scenery",      
  "Starblob Complexity (i,p)", function () exc("scn_db_miStarblobComplexity_fs.lua"); end,
  "Nice Curves (i,p)",         function () exc("scn_db_miNiceCurves_fs.lua"); end,
  "Psycho Twirl (i,p)",        function () exc("scn_db_miTwirlPsycho_fs.lua"); end,
  "Mandel Interference (i,p)", function () exc("scn_db_miMandelInterference_fs.lua"); end, -- u4
  "Scanline X-fade (i,p)",     function () exc("scn_db_miScanlineXfade_fs.lua"); end,
  "SineRange (i,p)",           function () exc("scn_db_miSineRange_fs.lua"); end,
  "RainBow Dark2Bright (i,p)", function () exc("scn_db_miRainbowDark2Bright_fs.lua"); end,
  "Collage (i,p)",             function () exc("scn_db_miCollage_fs.lua"); end,
  "[Back]", sf_scene
 );
end
-- demo

--[[
function sf_scn_demo()
  selectbox("Demos & Fun",      
  "Oblique Logo (i)",         function () exc("pic_db_ObliqueLogo.lua"); end,
  "Line Demo (a,i)",          function () exc("pic_db_LineDemo.lua"); end,
  "3D Sphere (a,i,p)",        function () exc("ani_db_3Dsphere5_correct.lua"); end,
  "Homing Missiles (a,i)",    function () exc("ani_db_HomingMissiles.lua"); end,
  "Numy Fractal Demo (a,i)",  function () exc("ani_db_Numy06avg.lua"); end,
  --"TicTacToe Game! (i,p)",  function () exc("scn_db_TicTacToe.lua"); end,
  "[Back]", sf_scene
 );
end
-- demo
--]]


function sf_scene()
  selectbox("Scene",     
  ">DRAW SHAPES & GRIDS", sf_scn_shapes, 
  ">CLOUDS & NOISE", sf_scn_cloudnoise,
  ">FRACTALS", sf_scn_fractal,
  ">L-SYSTEM", sf_scn_lsystem, 
  ">TILING & PATTERNS", sf_scn_tiling, --A4
  ">GRADIENTS & ALPHAS", sf_scn_gradients, --A4
  ">RENDERED SCENERY", sf_scn_fscenery,
  --">'UPDATE' ANIMS", sf_scn_update,
  --">DEMOS & FUN", sf_scn_demo,
  "[Back]", main
 );
end
-- scenes



function sf_misc()
  selectbox("Misc", 
  ">TILE & SPRITE SHEETS", sf_misc_tilework,
  ">4-DITHER TOOLS", sf_misc_4dither, 
  ">OLD & ODD STUFF", sf_misc_oldstuff,     
  "Set Gryscale & Remap (i,p)", function () exc("scn_db_GrayscaleSetRemap.lua"); end,

  --"Rainbow (Dark2Bright) (i)",   function () exc("pic_db_Rainbow-Dark2Bright2.lua"); end,
  --"Inverted RGB (c,p)",        function () exc("pal_db_InvertedRGB.lua"); end, -- Feature added to complementary script

  "Save Palette as Script (f)", function () exc("../_save_palette/fil_db_SavePalette.lua"); end,
  "Text Library Tutorial (i)",  function () exc("pic_db_TextTutorial.lua"); end,
  "[Back]", main
 );
end

function sf_misc_oldstuff()
 selectbox("Old & Odd Stuff", 
   "Tilt-Shift Photo-fx (i)",     function () exc("pic_db_TiltShift.lua"); end,
   "Particle Explosion WIP (i)",  function () exc("scn_db_Explosion8fs.lua"); end,
   "Find Complement. Col. (n)",   function () exc("col_db_FindComplementaryColor.lua"); end,
   "Amiga BoingBall Brush (b)",function () exc("bru_db_Amigaball.lua"); end,
   "Pen-Color Sphere (b)",        function () exc("bru_db_ColorSphere.lua"); end,
   --"Ellipse Demo (a,i,p)",        function () exc("ani_db_EllipseDemo.lua"); end, 
   "[Back]", sf_misc
 );
end

function sf_misc_tilework()
  selectbox("Tile & Sprite Sheets", 
  "#ReOrganize Sheet (i)",            function () exc("pic_db_ReTile.lua"); end,
  ".SpriteSheet Animator(a,i)",       function () exc("ani_db_SpriteAnimatorMEM.lua"); end, 
  "[Back]", sf_misc
 );
end

function sf_misc_4dither() -- A4
  selectbox("4-Dither Tools", 
  "Make 4-Dither Brush (b)",              function () exc("../4dither/bru_db_4ditherBrush.lua"); end, -- A4
  "Make Brush Selection (b)",             function () exc("../4dither/bru_db_4ditherBrushMulti.lua"); end, -- A4
  "Make 4-Dither Gradient (b)",           function () exc("../4dither/bru_db_4ditherGradient.lua"); end, -- A4
  "4-Dither Remap (i,p)",                 function () exc("../4dither/pic_db_4ditherRemap.lua"); end, -- A4
  "List 4-Dither Combos (i)",             function () exc("../4dither/pic_db_4ditherDrawCombos.lua"); end, -- A4
  "Combos + Set MixCols (i,p)",           function () exc("../4dither/pic_db_4ditherDrawCombosSetCols.lua"); end, -- A4
  "Hue-Brightness Chart (i)",             function () exc("../4dither/pic_db_4ditherHueBriChart.lua"); end, -- A4
  "3 Color Pyramid (b)",                  function () exc("../4dither/bru_db_4dither3colPyramid.lua"); end, -- A4  
 "[Back]", sf_misc
 );
end

function _update_info()
 local t
 t = "Update Anims utilizes the Lua-script feature updatescreen() to create anims etc."
 t = t.."\n\nPress Escape-key to exit an animation."
 messagebox("Update Anims Info",t)
 sf_anim()
end

function sf_anim_demo()
  selectbox("Demos & Fun",      
  "Oblique Logo (i)",         function () exc("pic_db_ObliqueLogo.lua"); end,
  "Line Demo (a,i)",          function () exc("pic_db_LineDemo.lua"); end,
  "3D Sphere (a,i,p)",        function () exc("ani_db_3Dsphere5_correct.lua"); end,
  "Homing Missiles (a,i)",    function () exc("ani_db_HomingMissiles.lua"); end,
  "Numy Fractal Demo (a,i)",  function () exc("ani_db_Numy06avg.lua"); end,
  "Ellipse Demo (a,i,p)",        function () exc("ani_db_EllipseDemo.lua"); end, 
  --"TicTacToe Game! (i,p)",  function () exc("scn_db_TicTacToe.lua"); end,
  "[Back]", sf_anim
 );
end
-- demo

function sf_anim()
  selectbox("Anim",      
  "[Info]", _update_info,
  ">DEMOS & FUN", sf_anim_demo,
  "3D Palette Viewer (a,i)",     function () exc("ani_db_3DPalette.lua"); end,   
  ".SpriteSheet Animator(a,i)",  function () exc("ani_db_SpriteAnimatorMEM.lua"); end, 
  "Palette Operators (a,i,p)",   function () exc("ani_db_PaletteOperators.lua"); end,
  "Spline Demo (a,i)",           function () exc("ani_db_SplineDemo.lua"); end, 
  "Iso Train (a,i,p)",           function () exc("ani_db_IsoTrain.lua"); end,
  "Oblique Pal Cubes (a,i)",     function () exc("ani_db_ObliquePal.lua"); end,
  "[Back]", main
 );
end
-- anim


function _info()
 local t
 t = "+200 scripts by Richard Fhager."
 t = t.."\n\nLetters inside () after scripts indicate what they affect/output:\n"
 t = t.."i = image, b = brush, p = palette, c = color, t = text, l = layer,   a = anim/prg and n = pen."
 t = t.."\nLeading point '.' = memory script."
 t = t.."\n'#' = Interactive Script/Prg."
 t = t.."\n\nMenu '*' = Focus ON (pen1 = pen2)"
 t = t.."\n\nContact: dawnbringer@hem.utfors.se"
 --t = t.."\n 1"
 --t = t.."\n 2"
 --t = t.."\n 3"
  
 messagebox("ABOUT - "..TITLE, t)
 main()
end

function _quit()
 -- nada
end

function _back(caller)
 --caller()
end


--
function _unfocus()
 local c
 c = getbackcolor() -- Back and forecolor should be the same here
 if c<255 then 
  setforecolor(c+1)
   else
    setbackcolor(c-1) 
 end
 setcolor(0,getcolor(0))
 --updatescreen(); waitbreak(0)
 main()
end
--

--
function main()

 local info,func

 info,func = "[Info]", _info

 -- Notification/warning about active focus regions feature
 FOCUS_NOTE = ""
 if getforecolor() == getbackcolor() then
  FOCUS_NOTE = " *"
  info,func = "[* Focus OFF >>]", _unfocus
 end


selectbox(TITLE, 
  ">COLOR", sf_color,
  ">BRUSH", sf_brush,
  ">PALETTE"..FOCUS_NOTE, sf_palette,
  ">IMAGE", sf_image,
  ">SCENE", sf_scene,
  ">ANIM", sf_anim,
  ">MISC", sf_misc,
  --"[Info]", function()messagebox("Hi there!");main();end,
  info, func,
  "[Quit]", _quit
);

end
--

main()
