--COLOR: ** Find Darker Color **
--Assign script to a KEY
--by Richard 'DawnBringer' Fhager


-- Iterate with increasing brightness weight until an AA-color is found or none exists.

--require("memory")
--require("dawnbringer_lib")

dofile("../libs/dawnbringer_lib.lua")
dofile("../libs/memory.lua")

--arg=memory.load({dark=1,bright=0,dist=1,briweight=50})

--OK,dark,bright,dist,briweight = inputbox("Find/Select PenColor",                        
--                           "1. Darker",               arg.dark,       0,1,-1,
--                           "2. Brighter",             arg.bright,     0,1,-1,
--                           "Min. Differance (1-255)", arg.dist,       1,255,0,                    
--                           "ColMatch Bri-Weight %",   arg.briweight,  0,100,0                                            
--);

OK = true

if OK == true then

dark   = 1
bright = 0
dist =   2 -- 0.02 is the smallest diff I've seen so far (min dist between 2 pure blues is 0.09)
briweight = 5

--memory.save({dark=dark,bright=bright,dist=dist,briweight=briweight})

mindist = dist
if dark == 1 then mindist = -dist; end

step = 0.5 -- <= dist, <= 1


--messagebox("sign of step:"..db.sign(step))


palList = db.makePalList(256)
--messagebox(#palList)

cf = getforecolor()
--cb = getbackcolor()
rf,gf,bf = getcolor(cf)
--rb,gb,bb = getcolor(cb)




v = mindist
c = cf
while (c == cf and math.abs(v) < 128) do
 --messagebox(v.." "..rf+v..", "..gf+v..", "..bf+v)
 c = db.getBestPalMatchHYBRID({db.rgbcap(rf + v, gf + v, bf + v, 255,0)}, palList, briweight/100, false)
 v = v + step * db.sign(mindist)
end


setforecolor( c )

end -- OK
