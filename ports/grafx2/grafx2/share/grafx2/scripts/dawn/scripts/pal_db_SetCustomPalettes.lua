--PALETTE: Set Custom Palettes V3.1
--by Richard Fhager
--
--
-- 
--

dofile("../libs/dawnbringer_lib.lua")


OK,arne16,pico8,scenery,clean,REMAP = inputbox("Set Custom Palettes", 
        "1. Arne's 16 [16]",      1,  0,1,-1, 
        "2. PICO-8 v0.1.11b [16]",         0,  0,1,-1, 
        "3. Scenery Palette [256]", 0,  0,1,-1,
        "Remove Old Palette", 1,  0,1,0, 
        "Remap Image", 0,  0,1,0 
);


if OK == true then

--
if scenery == 1 then
 db.setSceneryPalette()
 colors = {}
 clean = 0
end
--

--[[ old
if pico8 == 1 then
colors = {
{  0,   0,   0},	-- black
{ 29,  43,  83},	-- dark_blue
{126,  37,  83},	-- dark_purple
{  0, 135,  81},	-- dark_green
{171,  82,  54},	-- brown
{ 95,  87,  79},	-- dark_gray
{194, 195, 199},	-- light_gray
{255, 241, 232},	-- white
{255,   0,  77},	-- red
{255, 163,   0},	-- orange
{255, 255,  39},	-- yellow
{  0, 231,  86},	-- green
{ 41, 173, 255},	-- blue
{131, 118, 156},	-- indigo
{255, 119, 168},	-- pink
{255, 204, 170}}	-- peach
end
--]]

-- PICO-8 v0.1.11B
if pico8 == 1 then
colors = {
 {0, 0, 0}
,{29, 43, 83}
,{126, 37, 83}
,{0, 135, 81}
,{171, 82, 54}
,{95, 87, 79}
,{194, 195, 199}
,{255, 241, 232}
,{255, 0, 77}
,{255, 163, 0}
,{255, 236, 39}
,{0, 228, 54}
,{41, 173, 255}
,{131, 118, 156}
,{255, 119, 168}
,{255, 204, 170}
}
end



if dennis20 == 1 then 
colors = {{ 219,219,219
},{ 212,163,182
},{ 157,162,213
},{ 187,107,228
},{ 160,90,166
},{ 132,97,190
},{ 81,97,181
},{ 97,149,89
},{ 34,149,88
},{ 14,112,90
},{ 0,74,96
},{ 14,46,96
},{ 41,30,41
},{ 76,24,22
},{ 126,12,69
},{ 106,75,73
},{ 138,117,34
},{ 165,162,71
},{ 188,212,135
},{ 117,217,150}}
end

if arne16 == 1 then 
colors = {{0,0,0},
         {157,157,157},
         {255,255,255},
         {190,38,51},
         {224,111,139},
         {73,60,43},
         {164,100,34},
         {235,137,49},
         {247,226,107},
         {47,72,78},
         {68,137,26},
         {163,206,39},
         {27,38,50},
         {0,87,132},
         {49,162,242},
         {178,220,239}}
end

 
 for c = 1, #colors, 1 do
   setcolor(c-1,colors[c][1],colors[c][2],colors[c][3]) 
 end


 if clean == 1 then
   r,g,b = 0,0,0
   --r,g,b = getcolor(matchcolor(0,0,0))
   for c = #colors+1, 256, 1 do 
     setcolor(c-1,r,g,b)  
   end
 end

 if REMAP == 1 then
  db.paletteRemap()
 end

end