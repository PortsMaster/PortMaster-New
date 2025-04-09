-- FUN16 Palette (PJ ISOtopes Collab) (pfunc)
-- by Richard 'DawnBringer' Fhager

-- Usage: 
-- Set palette: dofile("pfunc_pal_FUN16.lua")(true)
--  Also returns a PalList {{r,g,b,i},..} (in case it's needed for something, f.ex # of colors set)

-- Get palette: 
-- pallist = dofile("pfunc_pal_FUN16.lua")()
-- Returns a PalList {{r,g,b,i},..}


return function(set_flag)
 
 local n,pal,pallist

pal={
 {8, 0, 8}
,{42, 52, 67}
,{93, 70, 50}
,{68, 80, 140}
,{166, 65, 77}
,{94, 102, 96}
,{200, 107, 54}
,{131, 117, 175}
,{82, 144, 60}
,{219, 126, 189}
,{91, 153, 244}
,{222, 172, 133}
,{148, 204, 78}
,{132, 219, 252}
,{242, 222, 112}
,{252, 255, 254}
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