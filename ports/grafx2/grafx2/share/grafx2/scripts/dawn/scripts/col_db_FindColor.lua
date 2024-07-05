--PEN: Find Brighter/Darker Colors V2.0
--by Richard Fhager 


-- Iterate with increasing brightness weight until an AA-color is found or none exists.
-- Distance is a custom exponential value, RGBdist: 1* = 0.02, 100* = 25, 50* = 8.54

dofile("../libs/memory.lua")
dofile("../libs/dawnbringer_lib.lua")

arg=memory.load({dark=1,bright=0,dist=50,briweight=50})

OK,dark,bright,dist,briweight = inputbox(".Find/Select PenColor",
                        
                           "1. Darker",               arg.dark,       0,1,-1,
                           "2. Brighter",             arg.bright,     0,1,-1,
                           "Min Difference: 1-100", arg.dist,       1,100,0,                    
                           "ColMatch Bri-Weight %",   arg.briweight,  0,100,0                                            
);


if OK == true then

memory.save({dark=dark,bright=bright,dist=dist,briweight=briweight})


dist = math.pow(dist,1.5484) / 50 -- v

mindist = dist
if dark == 1 then mindist = -dist; end

step = math.min(1, dist/2)

palList = db.makePalList(256)

cf = getforecolor()
rf,gf,bf = getcolor(cf)

v = mindist
c = cf

-- Flaws in earlier versions
-- If target has a duplicate color that (self)matches...(ex 2 copies of the same palette and a low min diff)
-- the 2nd instance (selected) will match with the (first found/first iteration) 1st instance (c is not cf)
-- but with the 1st instance selected it will NOT match with 2nd instance, since c == cf 
--  and the loop goes on (inc. mindist so identical cols cannot match anymore)...


abs = math.abs

count = 0
samergb = true
outside = false
while (abs(v) < 255 and samergb and not outside) do -- c == cf
 c = db.getBestPalMatchHYBRID({db.rgbcap(rf + v, gf + v, bf + v, 255,0)}, palList, briweight/100, false)
 v = v + step * db.sign(mindist)

 samergb = false
 r,g,b = getcolor(c)
 if r==rf and g==gf and b==bf then samergb = true; end

 if (rf+v>255 and gf+v>255 and bf+v>255) then outside = true; end
 if (rf+v<0 and gf+v<0 and bf+v<0) then outside = true; end

 count = count + 1
end
--messagebox(count)

if samergb then c = cf; end -- don't change pen-color if matched with a duplicate

setforecolor( c )
--setbackcolor( c )

end -- OK
