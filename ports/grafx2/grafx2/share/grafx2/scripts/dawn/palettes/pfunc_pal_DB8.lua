-- DB8 Palette (pfunc)
-- by Richard 'DawnBringer' Fhager

-- Usage: 
-- Set palette: dofile("pfunc_pal_DB8.lua")(true)
--  Also returns a PalList {{r,g,b,i},..} (in case it's needed for something, f.ex # of colors set)

-- Get palette: 
-- pallist = dofile("pfunc_pal_DB8.lua")()
-- Returns a PalList {{r,g,b,i},..}


return function(set_flag)
 
 local n,pal,pallist

 pal={
     {0,   0,   0}
    ,{85,  65,  95}
    ,{100, 105, 100}
    ,{215, 115, 85}
    ,{80,  140, 215}
    ,{100, 185, 100}
    ,{230, 200, 110}
    ,{220, 245, 255}
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