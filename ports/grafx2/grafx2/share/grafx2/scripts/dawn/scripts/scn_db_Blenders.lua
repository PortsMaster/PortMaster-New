--SCENE: Image Blenders
--by Richard 'DawnBringer' Fhager

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/db_blender.lua")


-- This script should be replaced/updated with the new alpha/curve system and the AlphaCurve pfunction

w,h = getpicturesize()

Rf,Gf,Bf = getcolor(getforecolor())


----------------------
function menu(name)
 OK,dummy1, PEN,SPARE, dummy2, PAL,IMG,REND, ALPHA, AMOUNT, BRIWEIGHT   = inputbox("Blender: "..name,
                           "-- Application Source --",0,0,0,-2,
                           "1. PenColor ["..Rf..","..Gf..","..Bf.."]",  0,  0,1,-1,
                           "2. Spare Image (*or pal)",                  1,  0,1,-1,
                           "-- Output / Target --",0,0,0,-2,
                           "a) *Palette",              0,  0,1,-2,
                           "b) Image#",                 0,  0,1,-2,
                           "c) Render#",                1,  0,1,-2,
                           "# Select an ALPHA channel",  0,  0,1,0,
                           "AMOUNT %", 100,  0,100,0  
                      
                           --"ColMatch Bri-Weight %", 25,  0,100,0                                                     
 );


afunc = null
if OK then


--AMOUNT = 100
--_INPUT  = "spare"   -- "rgb",("pen"),"spare","math"
--_OUTPUT = "render" -- "pal","image","render" 

if PEN   == 1 then _INPUT = "rgb"; end
if SPARE == 1 then _INPUT = "spare"; end

if PAL == 1  then _OUTPUT = "pal"; end
if IMG == 1  then _OUTPUT = "image"; end
if REND == 1 then _OUTPUT = "render"; end

-- Alpha Channel (optional)
 if ALPHA == 1 and (_OUTPUT == "image" or _OUTPUT == "render") then

  alphas = {}
  alphas[1] = {"Horizontal Left->Right", db.alpha_Horizontal}
  alphas[2] = {"Vertical Top->Bottom",   db.alpha_Vertical}
  alphas[3] = {"Radial Center->Edge",    db.alpha_Radial}
  alphas[4] = {"Diagonal TL->BR",        db.alpha_Diagonal_TL}
  alphas[5] = {"Diagonal BL->TR",        db.alpha_Diagonal_BL}

  --t = "'"..alphas[1][1].."',1,0,1,-1\n"
  --for n = 2, #alphas, 1 do
  -- t = t..",\n'"..n..". "..alphas[n][1].."',0,0,1,-1"
  --end  

 
  OK2,a1,a2,a3,a4,a5,INV,COS,OFS = inputbox("Select Alpha Channel", 
                        
                           "1. "..alphas[1][1],                  1,  0,1,-1,
                           "2. "..alphas[2][1],                  0,  0,1,-1,
                           "3. "..alphas[3][1],                  0,  0,1,-1, 
                           "4. "..alphas[4][1],                  0,  0,1,-1,
                           "5. "..alphas[5][1],                  0,  0,1,-1,
                           --"6. "..alphas[6][1],                  0,  0,1,-1,
                           "Inverted",                           0,  0,1,0,
                           --"Cosine (S-curve transit.)",        0,  0,1,0, 
                           "S-curve Power*: 0(off)..4",               0,  0,4,0,   
                           "*Offset/Size %: -50..50",                0,  -50,50,0                                                                         
  );
 end

 if OK2 then
  --v = a1 + a2*2 + a3*4 + a4*8 + a5*16 --+ a6*32
  --n = 1 + math.log(v) / math.log(2)
  n = a1 + a2*2 + a3*3 + a4*4 + a5*5
  afunc = {alphas[n][2], INV, COS, OFS}
 end
 
 ----


amt = AMOUNT / 100


function _amount(amt,rgbo,rgba,xf,yf,afunc) -- Also handles Alpha channel
 local r,g,b,ra,ga,ba,a,ofs,mul,sub,m
 m = math
 a = 1 
  if afunc ~= null then
   a = afunc[1](xf,yf)
   if afunc[3] > 0 then -- Cosine (arg = 0..4, 0 == off)
     -- Note that offset can't be used without the curve, also offset means full value may not be reached (off=50% will reach 50% of full value)
     ofs = afunc[4] / 100 -- Offset (We can't really use more than 50% offset)
     --a = 1 - (math.cos(math.min(1,math.max(0,(a+ofs))) * math.pi) + 1)/2
      --a = 1 - (math.cos(a*2 * math.pi) + 1)/2 -- Center bar / donut
      --a = 1 - (math.cos(math.abs(a-0.5)*2 * math.pi) + 1)/2 -- Side bars
      --a = 1 - (math.cos(math.min(1,math.max(0,(a-0.25+ofs)*2)) * math.pi) + 1)/2 -- Sharp
      --a = 1 - (math.cos(math.min(1,math.max(0,(a-0.375+ofs)*4)) * math.pi) + 1)/2 -- Sharper

      mul = afunc[3]
      --mul = 4.9
      sub = 0.5 - 0.5 / mul
      a = 1 - (m.cos(m.min(1,m.max(0,(a-sub+ofs)*mul)) * m.pi) + 1)/2 -- variable
   end

   if afunc[2] == 1 then -- Inverted (arg = 1)
     a = 1 - a 
   end

  end
 amt = amt * a
 r,g,b = db.rgbcaps(bfunc(rgbo,rgba)) -- current blender function (capped coz some blender may return extreme values (which could be cool))
 ra = r * amt + (1-amt) * rgbo[1]
 ga = g * amt + (1-amt) * rgbo[2]
 ba = b * amt + (1-amt) * rgbo[3]
 return ra,ga,ba
end


-- Input functions
function in_spare(x,y) return getsparecolor(getsparepicturepixel(x,y)); end
function in_rgb(x,y)   return Rf,Gf,Bf; end
function in_math(x,y)  return 0,0,0; end


ifunc = in_rgb -- default input function

if _OUTPUT == "image" or _OUTPUT == "render" then
 if _INPUT == "rgb" then -- also pen
  ifunc = in_rgb
 end
 if _INPUT == "spare" then
  ifunc = in_spare
 end
end


--

if _OUTPUT == "pal" then
 if _INPUT == "rgb" then
  for n = 0, 255, 1 do  
   setcolor(n, _amount(amt,{getcolor(n)}, {Rf,Gf,Bf}) )
  end
 end
 if _INPUT == "spare" then -- spare palette
  for n = 0, 255, 1 do  
   setcolor(n, _amount(amt,{getcolor(n)}, {getsparecolor(n)}) )
  end
 end
end

if _OUTPUT == "image" then
 for y = 0, h-1, 1 do
  for x = 0, w-1, 1 do
   -- Note: we don't really need backuppixel since the 2-line dithersystem has the scanline already stored before overdrawn
   putpicturepixel(x,y,matchcolor2( _amount(amt, {getbackupcolor(getbackuppixel(x,y))}, {ifunc(x,y)}, x/w,y/h,afunc ) ))
  end
  --updatescreen(); if (waitbreak(0)==1) then return; end
  if db.donemeter(4,y,w,h,true) then return; end
 end
end

if _OUTPUT == "render" then
  function _f(x,y)
   return _amount(amt, {getbackupcolor(getbackuppixel(x,y))}, {ifunc(x,y)}, x/w,y/h,afunc ) 
  end 
  db.fsrenderControl(_f, "Blender Render (Amount: "..AMOUNT.."%)", null,null,null, null,null,null, null, null)
end


end -- ok
end -- menu
----------------------


--bfunc = blend_.Overlay
--bfunc = blend_.SoftLight
--bfunc = blend_.Multiply
--bfunc = blend_.Screen
--bfunc = blend_.ColorBurn
--bfunc = blend_.ColorDodge
--bfunc = blend_.Stamp
--bfunc = blend_.BaseLineFusion
--bfunc = blend_.Reflect
--bfunc = blend_.Glow
--bfunc = blend_.Brand

function blenders4()
 selectbox("Select Blender",
  "Normal ><",              function() bfunc = blend_.Normal;         menu("Normal (50% amt = avg)"); end, 
  "Add (Linear Dodge) <<",  function() bfunc = blend_.Add;            menu("Add"); end,
  "Subtract ><",            function() bfunc = blend_.Subtract;       menu("Subtract"); end,
  "Divide ><",              function() bfunc = blend_.Divide;         menu("Divide???"); end,
  "[BACK]", main
 )
end

function psblenders1()
 selectbox("Select Blender",
  "Multiply <<",    function() bfunc = blend_.Multiply;   menu("Multiply"); end,
  "Screen <<",      function() bfunc = blend_.Screen;     menu("Screen"); end,
  "Overlay >< Hard Light",     function() bfunc = blend_.Overlay;    menu("Overlay"); end,
  "Soft Light ><",  function() bfunc = blend_.SoftLight;  menu("SoftLight"); end,
  "Color Dodge ><", function() bfunc = blend_.ColorDodge; menu("Color Dodge"); end,
  "Color Burn ><",  function() bfunc = blend_.ColorBurn;  menu("Color Burn"); end,
  "[BACK]", main
 )
end

function psblenders2()
 selectbox("Select Blender",
  "Darken <<",      function() bfunc = blend_.Darken;      menu("Darken"); end,
  "Lighten <<",     function() bfunc = blend_.Lighten;     menu("Lighten"); end,
  "Difference <<",  function() bfunc = blend_.Difference;  menu("Difference"); end,
  "Exclusion <<",   function() bfunc = blend_.Exclusion;   menu("Exclusion"); end,
  "Linear Burn <<", function() bfunc = blend_.LinearBurn;  menu("Linear Burn"); end,
  --"Vivid Light ><", function() bfunc = blend_.VividLight;  menu("Vivid Light"); end,
  "[BACK]", main
 )
end


function blenders2()
 selectbox("Select Blender", 
  "Stamp ><",          function() bfunc = blend_.Stamp;          menu("Stamp"); end,
  "Reflect ><",        function() bfunc = blend_.Reflect;        menu("Reflect"); end,
  "Glow ><",           function() bfunc = blend_.Glow;           menu("Glow"); end,
  "[BACK]", main
 )
end

function blenders3()
 selectbox("Select Blender",
  "Brand ><",          function() bfunc = blend_.Brand;          menu("Brand"); end, 
  "BaseLineFusion <<", function() bfunc = blend_.BaseLineFusion; menu("BaseLineFusion"); end,
  "AverageBright <<",  function() bfunc = blend_.AverageBright;  menu("AverageBright"); end,
  "Appliance <<",      function() bfunc = blend_.Appliance;      menu("Appliance"); end,
  "Dominance <<",      function() bfunc = blend_.Dominance;      menu("Dominance"); end,
  "Submission <<",     function() bfunc = blend_.Submission;     menu("Submission"); end,
  "Multinvert <<",     function() bfunc = blend_.Multinvert;     menu("Multinvert"); end,
  "MultiplyRoot <<",   function() bfunc = blend_.MultiplyRoot;   menu("MultiplyRoot "); end,
  "[BACK]", main
 )
end

function blenders5()
 selectbox("Select Blender",
  "NegShade <<",       function() bfunc = blend_.NegShade;       menu("NegShade"); end,
  "Chromatic ><",      function() bfunc = blend_.Chromatic;      menu("Chromatic"); end,
  "StrongColor ><",    function() bfunc = blend_.StrongColor;    menu("StrongColor"); end,
  "Ghost ><",          function() bfunc = blend_.Ghost;          menu("Ghost"); end,
  "[BACK]", main
 )
end


function nada() end

function main()
 selectbox("Select Blender Menu",
    "BASIC BLENDERS",     blenders4,
    "PHOTOSHOP BLENDERS I",  psblenders1,
    "PHOTOSHOP BLENDERS II", psblenders2,
    "OTHER BLENDERS",     blenders2,
    "DB BLENDERS I",      blenders3,
    "DB BLENDERS II",     blenders5,
    "[QUIT]", nada
 );
end

main()
