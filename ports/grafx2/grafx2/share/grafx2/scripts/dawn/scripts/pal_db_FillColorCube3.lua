--PALETTE: Fill ColorCube Voids V1.1
--by Richard Fhager 
--Email: dawnbringer@hem.utfors.se

--
--
-- Create a palette by continously filling the greatest void in the RGB color-cube
--
-- Colors before "From" are read into the colorcube.
--


dofile("../libs/dawnbringer_lib.lua")
--> db.initColorCube
--> db.addColor2Cube
--> db.findVoid

SHADES = 16 -- Going 24bit will probably be too slow and steal too much memory, so we're 12bit (4096 colors) for now

ini = 0
exp = 255




OK,ini,exp,sha16,sha32 = inputbox("Fill Palette Color Voids",
                       "From #: 0-255",         0,  0,255,0,
                       "Replace to #: 1-255",  31,  1,255,0,
                       "16 Shades",             1,  0,1,-1, 
                       "32 Shades (slow/better)",      0,  0,1,-1
);


--

if OK == true then

 -- Perceptual color weights/distances (Dawn 3.0)
 rw = 0.26
 gw = 0.55
 bw = 0.19

 --rw = 0.7447
 --gw = 0.1664
 --bw = 0.0887

 -- Distances in colorspace is a strange phenomena. 
 -- or "Why do all those bright green, yellow & turqoise colors almost look like just one" 
 -- Because: (Example with some basic green colors, no weights needed with just one shade)
 -- [0,32,0] & [0,64,0]:   Color Distance: 32, Brightness 32 & 64,   Bri Distance: 32
 -- [0,208,0] & [0,240,0]: Color Distance: 32, Brightness 208 & 240, Bri Distance: 32
 --
 -- Yes, so?...
 --
 -- The brighter of the dark colors are    64 /  32 = 2.00 times brighter than the darker
 -- The brighter of the bright colors are 240 / 208 = 1.15 times brighter than the darker 
 --
 -- Since the perceptual brightness of a color is such an important factor, the human eye will percieve 
 -- the relative distance between the two darker colors as much greater than that of the brighter ones 
 -- (Even if their spatial color & brightness distances are equal)
 --
 -- In plain English: when making a color range etc. you want more/closer colors in the dark region than in the brighter.
 --

 if sha32 == 1 then
  SHADES = 32
 end

  cube = db.initColorCube(SHADES, {true,9999})
  -- Fill cube with initial colors
  for n = 0, ini-1, 1 do
    r,g,b = getcolor(n)
    div = 256 / SHADES
    db.addColor2Cube(cube,SHADES,math.floor(r/div),math.floor(g/div),math.floor(b/div),rw,gw,bw)
  end

  if ini == 0 then -- With no inital color, some inital data must be added to the colorcube. 
    db.addColor2Cube(cube,SHADES,0,0,0,rw,gw,bw)
    setcolor(0, 0,0,0) 
    ini = ini + 1
  end

  for n = ini, exp, 1 do
    r,g,b = db.findVoid(cube,SHADES)
    mult = 255 / (SHADES - 1)
    setcolor(n, r*mult,g*mult,b*mult)  
    db.addColor2Cube(cube,SHADES,r,g,b,rw,gw,bw)
  end

end



