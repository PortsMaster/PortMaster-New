---------------------------------------------------
---------------------------------------------------
--
--                Noise Library
--              
--                    V0.5
-- 
--                Prefix: noise_.
--
--        by Richard 'DawnBringer' Fhager
--                                   
--        Email: dawnbringer@hem.utfors.se
--               dawnbringer@bahnhof.se
--
---------------------------------------------------
---------------------------------------------------

-- Abstract:
--  Various functions for creating, converting & modifying noise-maps,
--  and processing noise into textures via Celluar Automata etc.
--  Perlin Noise is NOT in here, there's another library specifcally dedicated to that (db_perlin.lua)

---------------------------------------------------


noise_ = {}


-- Convert Noise data -1..1 to 0..1
function noise_.convertPerlin2Fraction(map)
 local x,y,yline,xsize,ysize
 ysize = #map
 xsize = #map[1]
  for y = 1, ysize, 1 do
   yline = map[y]
   for x = 1, xsize, 1 do
    yline[x] = (yline[x] + 1) * 0.5
   end
  end
end
--

-- Convert Noise data 0..1 to -1..1
function noise_.convertFraction2Perlin(map)
 local x,y,yline,xsize,ysize
 ysize = #map
 xsize = #map[1]
  for y = 1, ysize, 1 do
   yline = map[y]
   for x = 1, xsize, 1 do
    yline[x] = yline[x] * 2 - 1
   end
  end
end
--

--
-- Celluar Automata (0..1 noise, wrapping edges, Diagonals weigh 50%)
-- Requires many iterations to consolidate
-- add_life & dec_life does pretty much what you would think:
--  * hi add and lo dec creates big splotches of white (life) 
--  * lo add and hi dec creates fractured specs/strings of white
function noise_.noiseAutomata(map, iterations, cut_lo, cut_hi, add_life, dec_life, diag_weight)
 local nmap,i,x,y,s,xsize,ysize,ym,ym1,yp1,y0,ynm,max,min

 add_life = add_life or 0.25
 dec_life = dec_life or 0.25
 diag_weight = diag_weight or 1
 cut_lo = cut_lo or 3 -- nominal 3/5 (4 is stable amount), diagonal0.5=2/4 
 cut_hi = cut_hi or 5

 max,min = math.max, math.min

 ysize = #map
 xsize = #map[1]
 for i = 1, iterations, 1 do
  nmap = {}
  for y = 0, ysize-1, 1 do
   nmap[y+1] = {}
   ym1 = map[1+(y-1)%ysize]
   yp1 = map[1+(y+1)%ysize]
   y0  = map[1+(y-0)%ysize]
   ym = map[y+1]
   ynm = nmap[y+1]
   for x = 0, xsize-1, 1 do
     s = 0
     s = s + ym1[1+(x-1)%xsize] * diag_weight
     s = s + ym1[1+(x-0)%xsize]
     s = s + ym1[1+(x+1)%xsize] * diag_weight

     s = s + y0[1+(x-1)%xsize]
     s = s + y0[1+(x+1)%xsize]

     s = s + yp1[1+(x-1)%xsize] * diag_weight
     s = s + yp1[1+(x-0)%xsize]
     s = s + yp1[1+(x+1)%xsize] * diag_weight
     
     ynm[x+1] = ym[x+1]
     if s<= cut_lo then ynm[x+1] = max(0,ym[x+1] - dec_life); end
     if s>= cut_hi then ynm[x+1] = min(1,ym[x+1] + add_life); end
   end  
  end
  map = nmap
 end -- i
  nmap = {}
  return map
end
--


