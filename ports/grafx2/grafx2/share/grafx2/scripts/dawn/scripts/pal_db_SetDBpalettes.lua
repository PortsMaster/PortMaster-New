--PALETTE: Set Dawnbringer Palettes V2.8 (Pfunc's)
--by Richard Fhager
--
-- 
--
dofile("../libs/dawnbringer_lib.lua")

OK,db8,db16,db32,dbiso22,fun16,dbiso,aurora,clean,REMAP = inputbox("Set DawnBringer Palettes",
        "1. DB8  [8]", 0,     0,1,-1,
        "2. DB16 [16]", 1,     0,1,-1,
        "3. DB32 [32]", 0,     0,1,-1,
        "4. DB-ISO22 [22]",     0,0,1,-1, -- (ISObbean)
        "5. Fun16 (ISOtopes) [16]", 0,  0,1,-1,
        "6. DB's ISO-OLOGY [16]", 0,  0,1,-1,
        "7. Aurora v1.1 [256]", 0,  0,1,-1,
        "Remove Old Palette", 1,  0,1,0, 
        "Remap Image", 0,  0,1,0 
);

  --"DB's HeartAttackH. [16]", 0,  0,1,-1, -- dbhah

if OK == true then

SETCOLORS = true


if dbiso22 == 1 then
 SETCOLORS = false
 colors = dofile("../palettes/pfunc_pal_DB-ISO22.lua")(true) -- return a pallist for length
end


if db8 == 1 then
 SETCOLORS = false
 colors = dofile("../palettes/pfunc_pal_DB8.lua")(true) -- return a pallist for length
end

if fun16 == 1 then
 SETCOLORS = false
 colors = dofile("../palettes/pfunc_pal_FUN16.lua")(true)
end

if db32 == 1 then
 SETCOLORS = false
 colors = dofile("../palettes/pfunc_pal_DB32.lua")(true)
end

if db16 == 1 then
 SETCOLORS = false
 colors = dofile("../palettes/pfunc_pal_DB16.lua")(true)
end

 --DB's ISO-OLOGY
 if dbiso == 1 then 
  SETCOLORS = false
  colors = dofile("../palettes/pfunc_pal_DB-Iso-ology.lua")(true)
end

 --DawnBringer's Aurora v.1.1 Skin Palette
 if aurora == 1 then 
  SETCOLORS = false
  colors = dofile("../palettes/pfunc_pal_Aurora11.lua")(true) -- return a pallist for length
 end
 --

if SETCOLORS then

 if #colors[1] == 3 then -- RGB triplets
  for c = 1, #colors, 1 do
    setcolor(c-1,colors[c][1],colors[c][2],colors[c][3]) 
  end
 end

 if #colors[1] == 4 then -- Data with leading index
  for c = 1, #colors, 1 do
    setcolor(colors[c][1],colors[c][2],colors[c][3],colors[c][4]) 
  end
 end

end



 if clean == 1 then
   r,g,b = 0,0,0
   for c = #colors+1, 256, 1 do 
     setcolor(c-1,r,g,b)  
   end
 end

 if REMAP == 1 then
  db.paletteRemap()
 end

end



--[[ 
colors={ -- db8
{0, 0, 0}
,{85, 65, 95}
,{100, 105, 100}
,{215, 115, 85}
,{80, 140, 215}
,{100, 185, 100}
,{230, 200, 110}
,{220, 245, 255}

if dbhah == 1 then
colors = {{0,0,0
},{34,34,34
},{51,51,68
},{85,68,51
},{85,85,68
},{68,102,102
},{136,102,85
},{119,119,102
},{187,119,119
},{119,136,85
},{119,136,170
},{153,153,153
},{204,170,136
},{170,187,204
},{221,204,136
},{221,238,221
}}
end
}
--]]