-- DB-ISO22 Palette (PJ "ISObbean" collab palette) (pfunc)
-- by Richard 'DawnBringer' Fhager

-- Usage: 
-- Set palette: dofile("pfunc_pal_DB-ISO22.lua")(true)
--  Also returns a PalList {{r,g,b,i},..} (in case it's needed for something, f.ex # of colors set)

-- Get palette: 
-- pallist = dofile("pfunc_pal_DB-ISO22.lua")()
-- Returns a PalList {{r,g,b,i},..}




return function(set_flag)
 
 local n,pal, pallist

 pal={
 {0, 12, 8, 22}
,{1, 76, 65, 56}
,{2, 112, 80, 58}
,{3, 188, 95, 78}
,{4, 206, 145, 72}
,{5, 228, 218, 108}
,{6, 144, 196, 70}
,{7, 105, 142, 52}
,{8, 77, 97, 60}
,{9, 38, 50, 60}
,{10, 44, 75, 115}
,{11, 60, 115, 115}
,{12, 85, 141, 222}
,{13, 116, 186, 234}
,{14, 240, 250, 255}
,{15, 207, 182, 144}
,{16, 182, 124, 116}
,{17, 132, 90, 120}
,{18, 85, 84, 97}
,{19, 116, 102, 88}
,{20, 107, 123, 137}
,{21, 147, 147, 136}
}


 -- Convert [i,r,g,b] --> [r,g,b,i] 
 function convert_irgb_2_pallist(pal)
  local n,temp
  for n = 1, #pal, 1 do
   temp = pal[n][1]
   pal[n][1] = pal[n][2]
   pal[n][2] = pal[n][3]
   pal[n][3] = pal[n][4]
   pal[n][4] = temp
  end
  return pal
 end
 --

 pallist = convert_irgb_2_pallist(pal)

 if set_flag then
  for n = 1, #pallist, 1 do
   setcolor(pal[n][4],pal[n][1],pal[n][2],pal[n][3])
  end
 end

 return pallist

end