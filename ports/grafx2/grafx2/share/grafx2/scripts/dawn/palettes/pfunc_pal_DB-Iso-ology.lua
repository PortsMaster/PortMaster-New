-- DB ISO-OLOGY (PJ-Collab) Palette (pfunc)
-- by Richard 'DawnBringer' Fhager

-- Usage: 
-- Set palette: dofile("pfunc_pal_DB-Iso-ology.lua")(true)
--  Also returns a PalList {{r,g,b,i},..} (in case it's needed for something, f.ex # of colors set)

-- Get palette: 
-- pallist = dofile("pfunc_pal_DB-Iso-ology.lua")()
-- Returns a PalList {{r,g,b,i},..}


return function(set_flag)
 
 local n,pal,pallist

     pal = {
            {20,  20, 30}, -- 0  Black
            {71,  44, 53}, -- 1  D.Brown
            {80,  72, 80}, -- 2  D.Grey
            {62,  83,143}, -- 3  D.Blue
            {70,  98, 70}, -- 4  D.Green
            {152, 73, 82}, -- 5  Red
            {94, 110,110}, -- 6  Grey
            {154,106, 86}, -- 7  Brown
            {97, 121,178}, -- 8  B.Blue
            {113,141, 80}, -- 9  B.Green
            {190,132,112}, -- 10 B.Red
            {145,157,161}, -- 11 B.Grey
            {194,170,137}, -- 12 B.Brown/Skin
            {140,188,194}, -- 13 Turqouise/Sky
            {222,208,140}, -- 14 Yellow
            {220,236,218}  -- 15 White
           } 


 -- Convert [r,g,b] --> [r,g,b,i] (Add index to position 4)
 function convert_rgb_2_pallist(pal)
  local n
  for n = 1, #pal, 1 do
   pal[n][4] = n - 1
  end
  return pal
 end
 --

 pallist = convert_rgb_2_pallist(pal)

 if set_flag then
  for n = 1, #pal, 1 do
   setcolor(pal[n][4], pal[n][1],pal[n][2],pal[n][3])
  end
 end

 return pallist

end