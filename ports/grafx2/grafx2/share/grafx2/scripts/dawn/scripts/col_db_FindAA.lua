--PEN: Find & Set AA-color from pencolors
--by Richard Fhager 

-- Iterate with increasing brightness weight until an AA-color is found or none exists.

dofile("../libs/dawnbringer_lib.lua")

brilim = 0.9 -- Max fraction of brightness allowed

colors = 256

palList = db.makePalList(colors)

cf = getforecolor()
cb = getbackcolor()
rf,gf,bf = getcolor(cf)
rb,gb,bb = getcolor(cb)

gam = 1.2
rgam = 1 / gam

ra = ((rf^gam + rb^gam) * 0.5)^rgam
ga = ((gf^gam + gb^gam) * 0.5)^rgam
ba = ((bf^gam + bb^gam) * 0.5)^rgam

rgb = {ra,ga,ba}

bri = 0.3

c = cf
while ((c == cf or c == cb) and bri <= brilim) do
 c = db.getBestPalMatchHYBRID({ra, ga, ba}, palList, bri, false)
 bri = bri + 0.05
end

if c == cb then c = cf; end

setforecolor(c)


