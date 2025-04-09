-- DB32 Palette (pfunc)
-- by Richard 'DawnBringer' Fhager

-- Usage: 
-- Set palette: dofile("pfunc_pal_DB32.lua")(true)
--  Also returns a PalList {{r,g,b,i},..} (in case it's needed for something, f.ex # of colors set)

-- Get palette: 
-- pallist = dofile("pfunc_pal_DB32.lua")()
-- Returns a PalList {{r,g,b,i},..}


return function(set_flag)
 
 local n,pal,pallist

pal = {
  {0,0,0
},{34,32,52
},{69,40,60
},{102,57,49
},{143,86,59
},{223,113,38
},{217,160,102
},{238,195,154
},{251,242,54
},{153,229,80
},{106,190,48
},{55,148,110
},{75,105,47
},{82,75,36
},{50,60,57
},{63,63,116
},{48,96,130
},{91,110,225
},{99,155,255
},{95,205,228
},{203,219,252
},{255,255,255
},{155,173,183
},{132,126,135
},{105,106,106
},{89,86,82
},{118,66,138
},{172,50,50
},{217,87,99
},{215,123,186
},{143,151,74
},{138,111,48
}}

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