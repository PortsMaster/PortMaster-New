--PALETTE Set: C64 Palettes V4.0
--by Richard Fhager

-- (V4.0 added Colodore (Pepto 2) version)
-- (V3.0 added wikipedia version)

dofile("../libs/dawnbringer_lib.lua")

OK,pt,pe,colo,wiki,sort_bri,sort_c64,clean,REMAP = inputbox("Set C64 Palettes", 
         "1. Ptoing's  [16]",   1,  0,1,-1,
         "2. Pepto's   [16]",   0,  0,1,-1,
         "3. Colodore  [16]",   0,  0,1,-1,
         "4. Wikipedia [16]",   0,  0,1,-1,
         "a) Brightness Sorted",   1,  0,1,-2,
         "b) C64 Hardware Order",  0,  0,1,-2,    
         "Remove Old Palette", 1,  0,1,0,
         "Remap Image", 0,  0,1,0 
);


            -- R,  G,  B, C64 reg
 ptoing =  {{0,    0,  0, 0}, -- 0  Black
            {62,  49,162, 6}, -- 1  D.Blue
            {87,  66,  0, 9}, -- 2  Brown
            {140, 62, 52, 2}, -- 3  D.Red
            {84,  84, 84, 11},-- 4  D.Grey
            {141, 71,179, 4}, -- 5  Purple -- V1.2 Changed green ch from 72 to 71
            {144, 95, 37, 8}, -- 6  Orange
            {124,112,218, 14},-- 7  B.Blue
            {128,128,128, 12},-- 8  Grey
            {104,169, 65, 5}, -- 9  Green
            {187,119,109, 10},-- 10 B.Red
            {122,191,199, 3}, -- 11 Cyan
            {171,171,171, 15},-- 12 B.Grey 
            {208,220,113, 7}, -- 13 Yellow
            {172,234,136, 13},-- 14 B.Green
            {255,255,255, 1}  -- 15 White
           } 

 pepto =   {{0,    0,  0, 0}, -- 0  Black
            {53,  40,121, 6}, -- 1  D.Blue
            {67,  57,  0, 9}, -- 2  Brown
            {104, 55, 43, 2}, -- 3  D.Red
            {68,  68, 68, 11},-- 4  D.Grey
            {111, 61,134, 4}, -- 5  Purple 
            {111, 79, 37, 8}, -- 6  Orange
            {108, 94,181, 14},-- 7  B.Blue
            {108,108,108, 12},-- 8  Grey
            { 88,141, 67, 5}, -- 9  Green
            {154,103, 89, 10},-- 10 B.Red
            {112,164,178, 3}, -- 11 Cyan
            {149,149,149, 15},-- 12 B.Grey 
            {184,199,111, 7}, -- 13 Yellow
            {154,210,132, 13},-- 14 B.Green
            {255,255,255, 1}  -- 15 White
           } 


colodore={
 {0, 0, 0,        0}
,{255, 255, 255,  1}
,{129, 51, 56,    2}
,{117, 206, 200,  3}
,{142, 60, 151,   4}
,{86, 172, 77,    5}
,{46, 44, 155,    6}
,{237, 241, 113,  7}
,{142, 80, 41,    8}
,{85, 56, 0,      9}
,{196, 108, 113, 10}
,{74, 74, 74,    11}
,{123, 123, 123, 12}
,{169, 255, 159, 13}
,{112, 109, 235, 14}
,{178, 178, 178, 15}
}

wikipedia = {
{0,0,0,       0}, 
{255,255,255, 1},
{136,57,50,   2}, 
{103,182,189, 3}, 
{139,63,150,  4}, 
{85,160,73,   5}, 
{64,49,141,   6},
{191,206,114, 7},
{139,84,41,   8}, 
{87,66,0,     9},  
{184,105,98, 10}, 
{80,80,80,   11}, 
{120,120,120,12}, 
{148,224,137,13}, 
{120,105,196,14},
{159,159,159,15}
}


if OK == true then

 colors = ptoing
 if pe   == 1 then colors = pepto; end
 if colo == 1 then colors = colodore; end
 if wiki == 1 then colors = wikipedia; end

 if sort_bri == 1 then
  colors = db.fixPalette(colors,1) -- Brightness sort
 end

 if sort_c64 == 1 then
  db.sorti(colors,4) 
 end

 for c = 1, #colors, 1 do
   setcolor(c-1,colors[c][1],colors[c][2],colors[c][3]) 
 end


 if clean == 1 then
   for c = #colors+1, 256, 1 do 
     setcolor(c-1,0,0,0)  
   end
 end

 if REMAP == 1 then
  db.paletteRemap()
 end


end